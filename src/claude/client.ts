/**
 * Snirklon - Claude Client
 * Huvudsaklig integration med Claude API för generativa sekvenser
 */

import Anthropic from '@anthropic-ai/sdk';
import { 
  GenerationRequest, 
  GenerationResponse, 
  Sequence,
  MusicalContext,
  MusicalPersona,
  SessionState 
} from './types';
import { MUSICAL_PERSONAS } from './personas';
import { buildSystemPrompt, buildGenerationPrompt } from './prompts';
import { validateSequence, parseSequenceFromResponse } from './validators';

// ============================================
// Konfiguration
// ============================================

const DEFAULT_CONFIG = {
  model: 'claude-sonnet-4-20250514' as const,
  maxTokens: 4096,
  defaultTemperature: 0.8,  // Högre för kreativitet
};

// ============================================
// Claude Client Klass
// ============================================

export class SnirklonClaudeClient {
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

  updateContext(context: Partial<MusicalContext>): void {
    if (this.session) {
      this.session.context = { ...this.session.context, ...context };
    }
  }

  setPersona(personaId: string): void {
    if (this.session) {
      this.session.activePersona = personaId;
    }
  }

  // ----------------------------------------
  // Huvudsaklig Generering
  // ----------------------------------------

  async generateSequence(request: GenerationRequest): Promise<GenerationResponse> {
    if (!this.session) {
      return { success: false, error: 'No active session. Call startSession() first.' };
    }

    const persona = request.persona 
      ? MUSICAL_PERSONAS[request.persona] 
      : this.session.activePersona 
        ? MUSICAL_PERSONAS[this.session.activePersona]
        : undefined;

    const systemPrompt = buildSystemPrompt(this.session.context, persona);
    const userPrompt = buildGenerationPrompt(request, this.session);

    try {
      const response = await this.anthropic.messages.create({
        model: DEFAULT_CONFIG.model,
        max_tokens: DEFAULT_CONFIG.maxTokens,
        temperature: this.getTemperatureForRequest(request),
        system: systemPrompt,
        messages: this.buildMessages(userPrompt),
      });

      const content = response.content[0];
      if (content.type !== 'text') {
        return { success: false, error: 'Unexpected response type' };
      }

      const parsed = parseSequenceFromResponse(content.text);
      
      if (!parsed || !validateSequence(parsed.sequence)) {
        // Försök igen med feedback
        return this.regenerateWithFeedback(request, 'Invalid sequence format');
      }

      // Spara i session
      this.addToHistory('user', request.prompt);
      this.addToHistory('assistant', content.text, parsed.sequence.id);
      this.session.generatedSequences.push(parsed.sequence);

      return {
        success: true,
        sequence: parsed.sequence,
        explanation: parsed.explanation,
        suggestions: parsed.suggestions,
      };

    } catch (error) {
      return this.handleError(error, request);
    }
  }

  // ----------------------------------------
  // Streaming Generation (för realtid)
  // ----------------------------------------

  async *streamSequence(request: GenerationRequest): AsyncGenerator<string, GenerationResponse> {
    if (!this.session) {
      return { success: false, error: 'No active session' };
    }

    const persona = request.persona ? MUSICAL_PERSONAS[request.persona] : undefined;
    const systemPrompt = buildSystemPrompt(this.session.context, persona);
    const userPrompt = buildGenerationPrompt(request, this.session);

    try {
      const stream = await this.anthropic.messages.stream({
        model: DEFAULT_CONFIG.model,
        max_tokens: DEFAULT_CONFIG.maxTokens,
        temperature: this.getTemperatureForRequest(request),
        system: systemPrompt,
        messages: this.buildMessages(userPrompt),
      });

      let fullResponse = '';

      for await (const event of stream) {
        if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
          fullResponse += event.delta.text;
          yield event.delta.text;
        }
      }

      const parsed = parseSequenceFromResponse(fullResponse);
      
      if (!parsed || !validateSequence(parsed.sequence)) {
        return { success: false, error: 'Invalid sequence in stream' };
      }

      this.session.generatedSequences.push(parsed.sequence);
      
      return {
        success: true,
        sequence: parsed.sequence,
        explanation: parsed.explanation,
      };

    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  // ----------------------------------------
  // Kreativa Funktioner
  // ----------------------------------------

  async moodMorph(
    sequence: Sequence, 
    targetMood: string
  ): Promise<GenerationResponse> {
    const prompt = `
      Transform this sequence to express: "${targetMood}"
      
      Original sequence:
      ${JSON.stringify(sequence, null, 2)}
      
      Analyze the emotional characteristics needed and modify:
      - Tempo suggestions
      - Scale/mode changes  
      - Rhythmic adjustments
      - Velocity/dynamics
      - Note density
      
      Return a transformed sequence that captures the new mood while 
      maintaining musical coherence with the original.
    `;

    return this.generateSequence({
      prompt,
      context: this.session!.context,
    });
  }

  async createVariation(
    sequence: Sequence,
    variationType: 'rhythmic' | 'melodic' | 'harmonic' | 'textural' | 'dynamics'
  ): Promise<GenerationResponse> {
    const variationInstructions = {
      rhythmic: 'Keep the pitches but vary the rhythm. Try syncopation, different note values, or rhythmic displacement.',
      melodic: 'Keep the rhythm but vary the melody. Use neighboring tones, inversions, or sequence the motifs.',
      harmonic: 'Add harmonic layers. Create counterpoint, add bass notes, or harmonize in thirds/sixths.',
      textural: 'Change the texture. Try arpeggiation, block chords, or vary articulation.',
      dynamics: 'Vary the dynamics. Create crescendos, accents, ghost notes, or velocity patterns.',
    };

    return this.generateSequence({
      prompt: `Create a ${variationType} variation: ${variationInstructions[variationType]}`,
      context: this.session!.context,
      variationType,
    });
  }

  async evolveSequences(
    sequences: Array<{ sequence: Sequence; fitness: number }>
  ): Promise<GenerationResponse[]> {
    const sortedByFitness = [...sequences].sort((a, b) => b.fitness - a.fitness);
    const topSequences = sortedByFitness.slice(0, Math.ceil(sequences.length / 2));

    const prompt = `
      You are guiding musical evolution. Here are the top-performing sequences:
      
      ${topSequences.map((s, i) => `
        Sequence ${i + 1} (fitness: ${s.fitness}):
        ${JSON.stringify(s.sequence.notes, null, 2)}
      `).join('\n')}
      
      Create ${sequences.length} new sequences by:
      1. Combining successful elements from top performers
      2. Introducing creative mutations
      3. Maintaining musical coherence
      
      Focus on what made the high-fitness sequences successful.
    `;

    const response = await this.generateSequence({
      prompt,
      context: this.session!.context,
    });

    return response.alternatives ? 
      response.alternatives.map(seq => ({ success: true, sequence: seq })) : 
      [response];
  }

  async createMusicalStory(
    theme: string,
    chapters: number = 4
  ): Promise<GenerationResponse> {
    const prompt = `
      Create a ${chapters}-part musical story based on: "${theme}"
      
      For each chapter, provide:
      - A descriptive name
      - The emotional journey
      - A sequence that captures that moment
      - Transition instructions to the next chapter
      
      The overall arc should have:
      - Introduction/setup
      - Development/rising action
      - Climax
      - Resolution
      
      Return as a structured story with sequences for each chapter.
    `;

    return this.generateSequence({
      prompt,
      context: this.session!.context,
    });
  }

  // ----------------------------------------
  // Hjälpfunktioner
  // ----------------------------------------

  private buildMessages(userPrompt: string): Array<{ role: 'user' | 'assistant'; content: string }> {
    const messages: Array<{ role: 'user' | 'assistant'; content: string }> = [];
    
    // Lägg till konversationshistorik för kontinuitet
    if (this.session) {
      const recentHistory = this.session.conversationHistory.slice(-10);
      for (const entry of recentHistory) {
        messages.push({ role: entry.role, content: entry.content });
      }
    }
    
    messages.push({ role: 'user', content: userPrompt });
    return messages;
  }

  private addToHistory(role: 'user' | 'assistant', content: string, sequenceId?: string): void {
    if (this.session) {
      this.session.conversationHistory.push({
        role,
        content,
        timestamp: Date.now(),
        relatedSequenceId: sequenceId,
      });
    }
  }

  private getTemperatureForRequest(request: GenerationRequest): number {
    // Anpassa temperature baserat på typ av förfrågan
    if (request.constraints) {
      return 0.5; // Lägre för mer strukturerade förfrågningar
    }
    if (request.variationType === 'melodic') {
      return 0.9; // Högre för melodisk kreativitet
    }
    return DEFAULT_CONFIG.defaultTemperature;
  }

  private async regenerateWithFeedback(
    originalRequest: GenerationRequest,
    feedback: string
  ): Promise<GenerationResponse> {
    const retryPrompt = `
      Previous attempt failed: ${feedback}
      
      Please try again with the original request, ensuring:
      - Valid JSON output
      - All required fields present
      - Notes within valid MIDI range (0-127)
      - Positive durations
      
      Original request: ${originalRequest.prompt}
    `;

    return this.generateSequence({
      ...originalRequest,
      prompt: retryPrompt,
    });
  }

  private handleError(error: unknown, request: GenerationRequest): GenerationResponse {
    if (error instanceof Anthropic.RateLimitError) {
      return { 
        success: false, 
        error: 'Rate limited. Please wait a moment and try again.' 
      };
    }
    
    if (error instanceof Anthropic.APIError) {
      return { 
        success: false, 
        error: `API Error: ${error.message}` 
      };
    }

    return { 
      success: false, 
      error: `Unknown error: ${String(error)}` 
    };
  }
}

// ============================================
// Export singleton instance
// ============================================

export const claudeClient = new SnirklonClaudeClient();
