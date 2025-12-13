/**
 * Snirklon - Unified Sequencer Client
 * Claude-integration för både synth och drum sequencing
 */

import Anthropic from '@anthropic-ai/sdk';
import { MusicalContext, MusicalPersona, SessionState, GenerationResponse } from '../claude/types';
import { MUSICAL_PERSONAS } from '../claude/personas';
import { SynthSequence, SynthPatch, SynthNote, Arpeggiator } from '../synth/types';
import { DrumSequence, DrumTrack, DrumStyle, EuclideanConfig } from '../drums/types';
import { ALL_SYNTH_PRESETS } from '../synth/presets';
import { DRUM_KITS, CLASSIC_PATTERNS, STYLE_CHARACTERISTICS } from '../drums/patterns';

// ============================================
// Types
// ============================================

export interface SynthGenerationRequest {
  prompt: string;
  context: MusicalContext;
  persona?: string;
  patchHint?: string;              // Hint about sound type
  constraints?: SynthConstraints;
}

export interface DrumGenerationRequest {
  prompt: string;
  context: MusicalContext;
  style?: DrumStyle;
  kitId?: string;
  constraints?: DrumConstraints;
}

export interface SynthConstraints {
  maxNotes?: number;
  noteRange?: [number, number];
  maxPolyphony?: number;
  useArpeggiator?: boolean;
  patchCategory?: string;
}

export interface DrumConstraints {
  maxTracks?: number;
  instruments?: string[];         // Limit to specific instruments
  useEuclidean?: boolean;
  complexity?: 'minimal' | 'moderate' | 'complex';
  allowPolyrhythm?: boolean;
}

export interface SynthGenerationResponse extends GenerationResponse {
  synthSequence?: SynthSequence;
  suggestedPatch?: SynthPatch;
  arpeggiatorConfig?: Arpeggiator;
}

export interface DrumGenerationResponse extends GenerationResponse {
  drumSequence?: DrumSequence;
  suggestedKit?: string;
  fillVariations?: DrumTrack[];
}

// ============================================
// Unified Sequencer Client
// ============================================

export class SnirklonSequencerClient {
  private anthropic: Anthropic;
  private session: SessionState | null = null;

  constructor(apiKey?: string) {
    this.anthropic = new Anthropic({
      apiKey: apiKey || process.env.ANTHROPIC_API_KEY,
    });
  }

  // ----------------------------------------
  // Session Management
  // ----------------------------------------

  startSession(context: MusicalContext): SessionState {
    this.session = {
      id: crypto.randomUUID(),
      startTime: Date.now(),
      context,
      conversationHistory: [],
      generatedSequences: [],
      userPreferences: {
        favoritePersonas: [],
        preferredGenres: [],
        avoidPatterns: [],
        complexityPreference: 'moderate',
        feedbackHistory: [],
      },
    };
    return this.session;
  }

  // ----------------------------------------
  // SYNTH Generation
  // ----------------------------------------

  async generateSynthSequence(request: SynthGenerationRequest): Promise<SynthGenerationResponse> {
    if (!this.session) {
      return { success: false, error: 'No active session' };
    }

    const persona = request.persona ? MUSICAL_PERSONAS[request.persona] : undefined;
    const systemPrompt = this.buildSynthSystemPrompt(request.context, persona);
    const userPrompt = this.buildSynthGenerationPrompt(request);

    try {
      const response = await this.anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 4096,
        temperature: 0.8,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }],
      });

      const content = response.content[0];
      if (content.type !== 'text') {
        return { success: false, error: 'Unexpected response type' };
      }

      return this.parseSynthResponse(content.text);

    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  async generateArpeggio(
    chordNotes: number[],
    request: SynthGenerationRequest
  ): Promise<SynthGenerationResponse> {
    const prompt = `
      Create an arpeggio pattern using these chord notes: ${chordNotes.join(', ')}
      
      Original request: ${request.prompt}
      
      Consider:
      - Arpeggio direction (up, down, up-down, random)
      - Octave range
      - Gate length for each note
      - Velocity patterns
      - Probability for variation
      
      Return both the arpeggiator settings and a rendered sequence.
    `;

    return this.generateSynthSequence({
      ...request,
      prompt,
      constraints: { ...request.constraints, useArpeggiator: true },
    });
  }

  async designSynthPatch(description: string): Promise<{ patch: SynthPatch; explanation: string } | null> {
    const prompt = `
      Design a synthesizer patch based on this description: "${description}"
      
      Consider all parameters:
      - Oscillators (waveforms, detuning, levels)
      - Filter (type, cutoff, resonance, envelope)
      - Envelopes (amp, filter, mod)
      - LFOs (targets, rates, shapes)
      - Effects (delay, reverb, distortion, etc.)
      - Voice mode (poly, mono, unison)
      
      Return a complete SynthPatch JSON object with explanation.
    `;

    try {
      const response = await this.anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 4096,
        temperature: 0.7,
        system: this.buildPatchDesignSystemPrompt(),
        messages: [{ role: 'user', content: prompt }],
      });

      const content = response.content[0];
      if (content.type !== 'text') return null;

      const jsonMatch = content.text.match(/```json\n?([\s\S]*?)\n?```/);
      if (!jsonMatch) return null;

      const parsed = JSON.parse(jsonMatch[1]);
      return {
        patch: parsed.patch,
        explanation: parsed.explanation || '',
      };

    } catch {
      return null;
    }
  }

  // ----------------------------------------
  // DRUM Generation
  // ----------------------------------------

  async generateDrumSequence(request: DrumGenerationRequest): Promise<DrumGenerationResponse> {
    if (!this.session) {
      return { success: false, error: 'No active session' };
    }

    const styleInfo = request.style ? STYLE_CHARACTERISTICS[request.style] : undefined;
    const systemPrompt = this.buildDrumSystemPrompt(request.context, styleInfo);
    const userPrompt = this.buildDrumGenerationPrompt(request);

    try {
      const response = await this.anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 4096,
        temperature: 0.75,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }],
      });

      const content = response.content[0];
      if (content.type !== 'text') {
        return { success: false, error: 'Unexpected response type' };
      }

      return this.parseDrumResponse(content.text, request.kitId);

    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  async generateEuclideanPattern(
    configs: Array<{ instrument: string; euclidean: EuclideanConfig }>,
    context: MusicalContext
  ): Promise<DrumGenerationResponse> {
    const prompt = `
      Create a drum pattern using these Euclidean configurations:
      ${configs.map(c => `- ${c.instrument}: ${c.euclidean.hits} hits in ${c.euclidean.steps} steps, rotation ${c.euclidean.rotation}`).join('\n')}
      
      Add musical context:
      - Velocity variations for groove
      - Micro-timing for human feel
      - Consider how patterns interact
      - Add fills or variations where appropriate
    `;

    return this.generateDrumSequence({
      prompt,
      context,
      constraints: { useEuclidean: true },
    });
  }

  async generateFill(
    basePattern: DrumSequence,
    fillType: 'buildup' | 'breakdown' | 'transition' | 'drop'
  ): Promise<DrumGenerationResponse> {
    const prompt = `
      Create a drum fill for this pattern, type: ${fillType}
      
      Base pattern info:
      - Style: ${basePattern.metadata.style}
      - Tracks: ${basePattern.tracks.map(t => t.name).join(', ')}
      - Length: ${basePattern.length} beats
      
      Fill requirements for "${fillType}":
      ${fillType === 'buildup' ? '- Increasing intensity, snare rolls, rising energy' : ''}
      ${fillType === 'breakdown' ? '- Stripping elements, creating space, tension' : ''}
      ${fillType === 'transition' ? '- Smooth connection between sections' : ''}
      ${fillType === 'drop' ? '- Maximum impact, reintroduce all elements' : ''}
    `;

    return this.generateDrumSequence({
      prompt,
      context: this.session!.context,
      style: basePattern.metadata.style,
    });
  }

  async styleTransform(
    sequence: DrumSequence,
    targetStyle: DrumStyle
  ): Promise<DrumGenerationResponse> {
    const sourceStyle = sequence.metadata.style;
    const targetInfo = STYLE_CHARACTERISTICS[targetStyle];

    const prompt = `
      Transform this ${sourceStyle || 'generic'} drum pattern to ${targetStyle} style.
      
      Target style characteristics:
      - Tempo range: ${targetInfo.tempoRange.join('-')} BPM
      - Swing: ${targetInfo.swingRange.join('-')}
      - Kick pattern: ${targetInfo.kickPattern}
      - Snare pattern: ${targetInfo.snarePattern}
      - Hi-hat density: ${targetInfo.hihatDensity}
      - Characteristics: ${targetInfo.characteristics.join(', ')}
      
      Current pattern:
      ${JSON.stringify(sequence.tracks.map(t => ({ name: t.name, steps: t.steps.map(s => s.active) })), null, 2)}
      
      Maintain recognizable elements while adapting to the new style.
    `;

    return this.generateDrumSequence({
      prompt,
      context: this.session!.context,
      style: targetStyle,
    });
  }

  // ----------------------------------------
  // Combined / Advanced Generation
  // ----------------------------------------

  async generateFullArrangement(
    description: string,
    sections: number = 4
  ): Promise<{
    synth: SynthGenerationResponse[];
    drums: DrumGenerationResponse[];
    arrangement: string;
  }> {
    const prompt = `
      Create a ${sections}-section arrangement based on: "${description}"
      
      For each section, provide:
      1. A synth sequence (melody, bass, or pad)
      2. A drum pattern
      3. How they interact
      
      Consider:
      - Energy progression across sections
      - Variation and development
      - Contrast between sections
      - Musical coherence
    `;

    try {
      const response = await this.anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 8192,
        temperature: 0.8,
        system: this.buildArrangementSystemPrompt(),
        messages: [{ role: 'user', content: prompt }],
      });

      const content = response.content[0];
      if (content.type !== 'text') {
        return { synth: [], drums: [], arrangement: 'Failed to generate' };
      }

      // Parse the combined response
      return this.parseArrangementResponse(content.text);

    } catch (error) {
      return { synth: [], drums: [], arrangement: String(error) };
    }
  }

  async jamSession(
    input: { type: 'synth' | 'drums'; sequence: SynthSequence | DrumSequence },
    responseType: 'synth' | 'drums' | 'both'
  ): Promise<{
    synth?: SynthGenerationResponse;
    drums?: DrumGenerationResponse;
  }> {
    const prompt = `
      I'm playing this ${input.type} pattern:
      ${JSON.stringify(input.sequence, null, 2)}
      
      Create a complementary ${responseType === 'both' ? 'synth and drum' : responseType} response.
      
      Consider:
      - Harmonic compatibility
      - Rhythmic interplay
      - Call and response possibilities
      - Energy matching
    `;

    const results: { synth?: SynthGenerationResponse; drums?: DrumGenerationResponse } = {};

    if (responseType === 'synth' || responseType === 'both') {
      results.synth = await this.generateSynthSequence({
        prompt: `Respond to this with a synth part: ${prompt}`,
        context: this.session!.context,
      });
    }

    if (responseType === 'drums' || responseType === 'both') {
      results.drums = await this.generateDrumSequence({
        prompt: `Respond to this with drums: ${prompt}`,
        context: this.session!.context,
      });
    }

    return results;
  }

  // ----------------------------------------
  // System Prompts
  // ----------------------------------------

  private buildSynthSystemPrompt(context: MusicalContext, persona?: MusicalPersona): string {
    return `
Du är en expert synthesizer-programmerare och melodisk kompositör i Snirklon.
Din uppgift är att skapa synth-sekvenser som JSON-data.

## Aktuell kontext
- Tempo: ${context.bpm} BPM
- Tonart: ${context.key} ${context.scale}
- Taktart: ${context.timeSignature[0]}/${context.timeSignature[1]}
${context.mood ? `- Stämning: ${context.mood}` : ''}

## Tillgängliga Synth-presets
${Object.keys(ALL_SYNTH_PRESETS).join(', ')}

## Output-format för SynthSequence
\`\`\`json
{
  "synthSequence": {
    "id": "unik-id",
    "name": "Beskrivande namn",
    "type": "synth",
    "length": 16,
    "timeSignature": [4, 4],
    "notes": [
      {
        "pitch": 60,
        "velocity": 100,
        "start": 0,
        "duration": 0.5,
        "slide": false,
        "accent": false,
        "filterOffset": 0,
        "probability": 1
      }
    ],
    "patch": "preset_name eller inline patch",
    "automation": [],
    "transpose": 0,
    "octave": 0,
    "metadata": {
      "generatedBy": "claude",
      "timestamp": ${Date.now()}
    }
  },
  "explanation": "Förklaring av designval",
  "suggestedPatch": "patch_name"
}
\`\`\`

## Synth-specifika tips
- Använd slide för legato-fraser och acid-linjer
- Accent boostar velocity och filter
- filterOffset ger per-not filter-variation
- automation kan styra synth-parametrar över sekvensen

${persona ? `\n## Din persona: ${persona.name}\n${persona.systemPromptAddition}` : ''}
`;
  }

  private buildDrumSystemPrompt(
    context: MusicalContext, 
    styleInfo?: typeof STYLE_CHARACTERISTICS[keyof typeof STYLE_CHARACTERISTICS]
  ): string {
    return `
Du är en expert trummaskinsprogrammerare och rytmisk kompositör i Snirklon.
Din uppgift är att skapa drum-sekvenser som JSON-data.

## Aktuell kontext
- Tempo: ${context.bpm} BPM
- Taktart: ${context.timeSignature[0]}/${context.timeSignature[1]}
${context.mood ? `- Stämning: ${context.mood}` : ''}
${context.genre ? `- Genre: ${context.genre}` : ''}

${styleInfo ? `
## Stil-karakteristik
- Tempo-range: ${styleInfo.tempoRange.join('-')} BPM
- Swing: ${styleInfo.swingRange.join('-')}
- Kick-mönster: ${styleInfo.kickPattern}
- Snare-mönster: ${styleInfo.snarePattern}
- Hi-hat densitet: ${styleInfo.hihatDensity}
- Karaktär: ${styleInfo.characteristics.join(', ')}
` : ''}

## Tillgängliga Drum Kits
${Object.keys(DRUM_KITS).join(', ')}

## Output-format för DrumSequence
\`\`\`json
{
  "drumSequence": {
    "id": "unik-id",
    "name": "Pattern namn",
    "type": "drums",
    "length": 4,
    "stepsPerBeat": 4,
    "timeSignature": [4, 4],
    "swing": 0,
    "swingResolution": "16th",
    "tracks": [
      {
        "id": "kick",
        "soundId": "kick",
        "name": "Kick",
        "steps": [
          { "active": true, "velocity": 120, "nudge": 0, "probability": 1 },
          { "active": false, "velocity": 0, "nudge": 0, "probability": 1 }
        ],
        "length": 16,
        "mute": false,
        "solo": false,
        "volume": 1,
        "pan": 0
      }
    ],
    "kit": "kit_909",
    "currentVariation": 0,
    "fillMode": { "type": "off" },
    "metadata": {
      "generatedBy": "claude",
      "style": "techno",
      "timestamp": ${Date.now()}
    }
  },
  "explanation": "Förklaring av rytmiska val",
  "suggestedKit": "kit_name"
}
\`\`\`

## Drum-specifika tips
- Velocity är avgörande för groove (variera mellan 60-127)
- Nudge ger micro-timing (-50 till +50 ms)
- Probability skapar variation (0-1)
- Använd flam och roll för fills
- Ghost notes (låg velocity) ger mänsklig känsla
- Olika track-längder skapar polymetri
`;
  }

  private buildPatchDesignSystemPrompt(): string {
    return `
Du är en expert synthesizer sound designer.
Skapa detaljerade synth patches baserat på beskrivningar.

Returnera alltid valid JSON med denna struktur:
\`\`\`json
{
  "patch": {
    "id": "unik-id",
    "name": "Patch namn",
    "category": "bass|lead|pad|pluck|keys|strings|brass|arp|fx|drum|experimental",
    "tags": ["tag1", "tag2"],
    "oscillators": [...],
    "filter": {...},
    "ampEnvelope": {...},
    "filterEnvelope": {...},
    "lfos": [...],
    "modMatrix": [...],
    "effects": {...},
    "voiceMode": {...},
    "portamento": 0,
    "pitchBendRange": 2,
    "volume": 0.8,
    "pan": 0
  },
  "explanation": "Detaljerad förklaring av sound design-valen"
}
\`\`\`
`;
  }

  private buildArrangementSystemPrompt(): string {
    return `
Du är en expert musikproducent som skapar kompletta arrangemang.
Generera både synth och drum-sekvenser som passar ihop.

Tänk på:
- Frekvensseparering mellan element
- Rytmisk komplementaritet
- Dynamisk utveckling
- Harmonisk koherens
`;
  }

  // ----------------------------------------
  // Generation Prompts
  // ----------------------------------------

  private buildSynthGenerationPrompt(request: SynthGenerationRequest): string {
    let prompt = `## Förfrågan\n${request.prompt}\n`;

    if (request.patchHint) {
      prompt += `\n## Ljud-hint\nAnvänd eller inspirieras av: ${request.patchHint}\n`;
    }

    if (request.constraints) {
      prompt += `\n## Begränsningar\n`;
      if (request.constraints.maxNotes) prompt += `- Max noter: ${request.constraints.maxNotes}\n`;
      if (request.constraints.noteRange) prompt += `- Notomfång: ${request.constraints.noteRange[0]}-${request.constraints.noteRange[1]}\n`;
      if (request.constraints.maxPolyphony) prompt += `- Max polyfoni: ${request.constraints.maxPolyphony}\n`;
      if (request.constraints.useArpeggiator) prompt += `- Använd arpeggiator\n`;
      if (request.constraints.patchCategory) prompt += `- Patch-kategori: ${request.constraints.patchCategory}\n`;
    }

    return prompt;
  }

  private buildDrumGenerationPrompt(request: DrumGenerationRequest): string {
    let prompt = `## Förfrågan\n${request.prompt}\n`;

    if (request.style) {
      prompt += `\n## Stil: ${request.style}\n`;
    }

    if (request.kitId) {
      prompt += `\n## Använd kit: ${request.kitId}\n`;
    }

    if (request.constraints) {
      prompt += `\n## Begränsningar\n`;
      if (request.constraints.maxTracks) prompt += `- Max spår: ${request.constraints.maxTracks}\n`;
      if (request.constraints.instruments) prompt += `- Instrument: ${request.constraints.instruments.join(', ')}\n`;
      if (request.constraints.useEuclidean) prompt += `- Använd Euclidean-mönster\n`;
      if (request.constraints.complexity) prompt += `- Komplexitet: ${request.constraints.complexity}\n`;
      if (request.constraints.allowPolyrhythm) prompt += `- Polymetri tillåten\n`;
    }

    return prompt;
  }

  // ----------------------------------------
  // Response Parsing
  // ----------------------------------------

  private parseSynthResponse(text: string): SynthGenerationResponse {
    try {
      const jsonMatch = text.match(/```json\n?([\s\S]*?)\n?```/);
      if (!jsonMatch) {
        return { success: false, error: 'No JSON found in response' };
      }

      const parsed = JSON.parse(jsonMatch[1]);

      return {
        success: true,
        synthSequence: parsed.synthSequence,
        suggestedPatch: parsed.suggestedPatch ? ALL_SYNTH_PRESETS[parsed.suggestedPatch] : undefined,
        arpeggiatorConfig: parsed.arpeggiator,
        explanation: parsed.explanation,
        suggestions: parsed.suggestions,
      };

    } catch (error) {
      return { success: false, error: `Parse error: ${error}` };
    }
  }

  private parseDrumResponse(text: string, kitId?: string): DrumGenerationResponse {
    try {
      const jsonMatch = text.match(/```json\n?([\s\S]*?)\n?```/);
      if (!jsonMatch) {
        return { success: false, error: 'No JSON found in response' };
      }

      const parsed = JSON.parse(jsonMatch[1]);

      // Assign kit if specified
      if (parsed.drumSequence && kitId) {
        parsed.drumSequence.kit = kitId;
      }

      return {
        success: true,
        drumSequence: parsed.drumSequence,
        suggestedKit: parsed.suggestedKit,
        fillVariations: parsed.fillVariations,
        explanation: parsed.explanation,
        suggestions: parsed.suggestions,
      };

    } catch (error) {
      return { success: false, error: `Parse error: ${error}` };
    }
  }

  private parseArrangementResponse(text: string): {
    synth: SynthGenerationResponse[];
    drums: DrumGenerationResponse[];
    arrangement: string;
  } {
    try {
      const jsonMatch = text.match(/```json\n?([\s\S]*?)\n?```/);
      if (!jsonMatch) {
        return { synth: [], drums: [], arrangement: text };
      }

      const parsed = JSON.parse(jsonMatch[1]);

      return {
        synth: (parsed.synthSequences || []).map((s: any) => ({
          success: true,
          synthSequence: s,
        })),
        drums: (parsed.drumSequences || []).map((d: any) => ({
          success: true,
          drumSequence: d,
        })),
        arrangement: parsed.arrangement || parsed.explanation || '',
      };

    } catch {
      return { synth: [], drums: [], arrangement: text };
    }
  }
}

// ============================================
// Export
// ============================================

export const sequencerClient = new SnirklonSequencerClient();
