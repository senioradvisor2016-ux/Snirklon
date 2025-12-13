/**
 * Snirklon - Prompt Engineering
 * Byggstenar för effektiva prompts till Claude
 */

import { 
  GenerationRequest, 
  MusicalContext, 
  MusicalPersona, 
  SessionState,
  Sequence 
} from './types';

// ============================================
// System Prompt Builder
// ============================================

export function buildSystemPrompt(
  context: MusicalContext, 
  persona?: MusicalPersona
): string {
  const basePrompt = `
Du är en kreativ musikassistent i Snirklon - en generativ sequencer-applikation.
Din uppgift är att skapa musikaliska sekvenser som JSON-data.

## Kärnprinciper
1. Generera alltid valid JSON som följer det specificerade formatet
2. Respektera den musikaliska kontexten (tonart, tempo, stil)
3. Var kreativ men musikaliskt koherent
4. Ge korta förklaringar av dina val när det är relevant

## Aktuell kontext
- Tempo: ${context.bpm} BPM
- Taktart: ${context.timeSignature[0]}/${context.timeSignature[1]}
- Tonart: ${context.key}
- Skala: ${context.scale}
${context.mood ? `- Stämning: ${context.mood}` : ''}
${context.genre ? `- Genre: ${context.genre}` : ''}

## Output-format
Svara alltid med JSON i detta format:
\`\`\`json
{
  "sequence": {
    "id": "unik-id",
    "name": "Beskrivande namn",
    "type": "melody|bass|drums|arpeggio|chord|ambient",
    "length": 16,
    "notes": [
      { "pitch": 60, "velocity": 100, "start": 0, "duration": 0.5 }
    ],
    "metadata": {
      "generatedBy": "claude",
      "confidence": 0.85
    }
  },
  "explanation": "Kort förklaring av valen",
  "suggestions": ["Förslag 1", "Förslag 2"]
}
\`\`\`

## Musikteori-påminnelse
- MIDI pitch: 60 = C4 (middle C), +1 = halvton upp
- Velocity: 0-127 (0 = tyst, 127 = max styrka)
- Noter i ${context.key} ${context.scale}: ${getScaleNotes(context.key, context.scale)}
`;

  // Lägg till persona-specifik prompt om det finns
  if (persona) {
    return `${basePrompt}

## Din persona: ${persona.name}
${persona.description}

${persona.systemPromptAddition}

Kom ihåg: Behåll din personlighet men respektera alltid användarens specifika önskemål.`;
  }

  return basePrompt;
}

// ============================================
// Generation Prompt Builder
// ============================================

export function buildGenerationPrompt(
  request: GenerationRequest,
  session: SessionState
): string {
  let prompt = `## Förfrågan\n${request.prompt}\n`;

  // Lägg till constraints om de finns
  if (request.constraints) {
    prompt += `\n## Begränsningar\n`;
    if (request.constraints.maxNotes) {
      prompt += `- Max antal noter: ${request.constraints.maxNotes}\n`;
    }
    if (request.constraints.noteRange) {
      prompt += `- Notomfång: ${request.constraints.noteRange[0]}-${request.constraints.noteRange[1]} (MIDI)\n`;
    }
    if (request.constraints.rhythmicDensity) {
      prompt += `- Rytmisk densitet: ${request.constraints.rhythmicDensity}\n`;
    }
    if (request.constraints.forceInKey) {
      prompt += `- Håll dig strikt till tonarten\n`;
    }
  }

  // Lägg till existerande spår för referens
  if (session.context.existingTracks && session.context.existingTracks.length > 0) {
    prompt += `\n## Existerande spår att ta hänsyn till\n`;
    for (const track of session.context.existingTracks.slice(0, 3)) {
      prompt += `- ${track.name} (${track.type}): ${summarizeSequence(track)}\n`;
    }
  }

  // Lägg till användarpreferenser om de finns
  if (session.userPreferences.feedbackHistory.length > 0) {
    const recentFeedback = session.userPreferences.feedbackHistory.slice(-5);
    const likes = recentFeedback.flatMap(f => f.liked);
    const dislikes = recentFeedback.flatMap(f => f.disliked);
    
    if (likes.length > 0 || dislikes.length > 0) {
      prompt += `\n## Användarens preferenser (baserat på tidigare feedback)\n`;
      if (likes.length > 0) {
        prompt += `- Gillar: ${[...new Set(likes)].join(', ')}\n`;
      }
      if (dislikes.length > 0) {
        prompt += `- Ogillar: ${[...new Set(dislikes)].join(', ')}\n`;
      }
    }
  }

  return prompt;
}

// ============================================
// Variation Prompts
// ============================================

export function buildVariationPrompt(
  originalSequence: Sequence,
  variationType: string
): string {
  const instructions: Record<string, string> = {
    rhythmic: `
Skapa en rytmisk variation av sekvensen:
- Behåll samma tonhöjder (pitch)
- Variera notvärden och placeringar
- Prova synkoper, punkteringar, eller trioler
- Behåll samma övergripande känsla`,

    melodic: `
Skapa en melodisk variation:
- Behåll samma rytm (start-tider och durationer)
- Variera tonhöjderna
- Använd tekniker som: inversion, transponering, ornamentering
- Håll dig inom samma tonart`,

    harmonic: `
Lägg till harmonisk komplexitet:
- Skapa en kompletterande stämma
- Använd intervall som terser, sextor eller oktaver
- Alternativt: skapa en kontrapunktisk baslinje
- Se till att harmoniken förstärker originalet`,

    textural: `
Förändra texturen:
- Om det är ackord: arpeggiera dem
- Om det är en melodi: lägg till dubblingar
- Variera attack/release-karaktär genom velocity
- Skapa mer eller mindre tät textur`,

    dynamics: `
Skapa dynamisk variation:
- Variera velocity för att skapa rörelse
- Lägg till crescendo/diminuendo-effekter
- Skapa accenter på strategiska ställen
- Använd ghost notes (låg velocity) för groove`,
  };

  return `
${instructions[variationType] || 'Skapa en variation av sekvensen.'}

## Original-sekvens
\`\`\`json
${JSON.stringify(originalSequence, null, 2)}
\`\`\`

Generera en ny sekvens som är tydligt relaterad till originalet men med ${variationType} förändringar.
`;
}

// ============================================
// Mood Morphing Prompts
// ============================================

export function buildMoodMorphPrompt(
  sequence: Sequence,
  currentMood: string,
  targetMood: string
): string {
  const moodTransformations: Record<string, Record<string, string[]>> = {
    happy: {
      sad: ['sänk till moll', 'långsammare tempo', 'lägre register', 'längre noter'],
      energetic: ['snabbare rytmer', 'kortare noter', 'mer synkopering', 'högre velocity'],
      calm: ['färre noter', 'längre durationer', 'mjukare velocity-kurva'],
    },
    sad: {
      happy: ['dur istället för moll', 'ljusare register', 'snabbare', 'mer rörelse'],
      dark: ['ännu lägre register', 'dissonans', 'sparsam', 'långsam'],
      hopeful: ['gradvis ljusare', 'stigande linjer', 'dur-antydningar'],
    },
    calm: {
      intense: ['ökande densitet', 'stigande dynamik', 'snabbare puls'],
      mysterious: ['kromatik', 'oväntade intervall', 'pauser', 'spänning'],
      energetic: ['gradvis acceleration', 'ökande komplexitet'],
    },
  };

  const transformHints = moodTransformations[currentMood]?.[targetMood] || [];

  return `
## Mood Morphing
Transformera sekvensen från "${currentMood}" till "${targetMood}".

### Transformationsförslag
${transformHints.length > 0 ? transformHints.map(h => `- ${h}`).join('\n') : '- Använd din kreativa bedömning'}

### Original-sekvens (${currentMood})
\`\`\`json
${JSON.stringify(sequence, null, 2)}
\`\`\`

### Instruktioner
1. Analysera vad som gör originalet "${currentMood}"
2. Identifiera element att förändra för "${targetMood}"
3. Behåll tillräckligt för igenkänning
4. Skapa en ny sekvens som tydligt uttrycker "${targetMood}"
`;
}

// ============================================
// Story/Narrative Prompts
// ============================================

export function buildStoryPrompt(
  theme: string,
  chapters: number,
  context: MusicalContext
): string {
  return `
## Musikalisk Berättelse
Skapa en ${chapters}-delad musikalisk berättelse baserad på temat: "${theme}"

### Kontext
- Tonart: ${context.key} ${context.scale}
- Tempo: ${context.bpm} BPM
- Taktart: ${context.timeSignature[0]}/${context.timeSignature[1]}

### Struktur
Varje kapitel ska ha:
1. Ett beskrivande namn
2. En kort narrativ beskrivning
3. En passande sekvens
4. Transitionsinstruktioner till nästa del

### Dramaturgisk båge
- Kapitel 1: Introduktion/uppsättning
- Kapitel 2-${chapters - 1}: Utveckling och komplikation
- Kapitel ${chapters}: Klimax och/eller upplösning

### Output-format
\`\`\`json
{
  "story": {
    "title": "Berättelsens titel",
    "overallMood": "övergripande stämning",
    "chapters": [
      {
        "name": "Kapitelnamn",
        "description": "Narrativ beskrivning",
        "sequence": { /* standard sekvensformat */ },
        "transitionToNext": "smooth|abrupt|fade"
      }
    ]
  }
}
\`\`\`
`;
}

// ============================================
// Evolution/Genetic Prompts
// ============================================

export function buildEvolutionPrompt(
  population: Array<{ sequence: Sequence; fitness: number }>,
  generation: number
): string {
  const sorted = [...population].sort((a, b) => b.fitness - a.fitness);
  const top = sorted.slice(0, Math.ceil(population.length / 2));

  return `
## Evolutionär Musik - Generation ${generation}

### Top-presterande sekvenser
${top.map((item, i) => `
#### Sekvens ${i + 1} (Fitness: ${item.fitness.toFixed(2)})
- Typ: ${item.sequence.type}
- Antal noter: ${item.sequence.notes.length}
- Noterna: ${item.sequence.notes.slice(0, 5).map(n => n.pitch).join(', ')}...
`).join('')}

### Din uppgift
Analysera vad som gör de framgångsrika sekvenserna bra och skapa nya sekvenser genom:

1. **Crossover**: Kombinera element från två föräldrar
2. **Mutation**: Introducera slumpmässiga (men musikaliskt meningsfulla) förändringar
3. **Selection**: Behåll de bästa egenskaperna

### Generera ${population.length} nya sekvenser
Svara med ett JSON-objekt innehållande en array av nya sekvenser:
\`\`\`json
{
  "newGeneration": [
    { /* sekvens 1 */ },
    { /* sekvens 2 */ }
  ],
  "evolutionNotes": "Kort förklaring av evolutionsstrategin"
}
\`\`\`
`;
}

// ============================================
// Hjälpfunktioner
// ============================================

function getScaleNotes(key: string, scale: string): string {
  // Förenklade skalnoter för referens
  const baseNote = key.replace(/m$/, '').replace(/#/, '♯').replace(/b/, '♭');
  
  const scalePatterns: Record<string, string> = {
    major: '1 2 3 4 5 6 7',
    minor: '1 2 ♭3 4 5 ♭6 ♭7',
    dorian: '1 2 ♭3 4 5 6 ♭7',
    phrygian: '1 ♭2 ♭3 4 5 ♭6 ♭7',
    lydian: '1 2 3 ♯4 5 6 7',
    mixolydian: '1 2 3 4 5 6 ♭7',
    locrian: '1 ♭2 ♭3 4 ♭5 ♭6 ♭7',
    pentatonic_major: '1 2 3 5 6',
    pentatonic_minor: '1 ♭3 4 5 ♭7',
    blues: '1 ♭3 4 ♭5 5 ♭7',
    harmonic_minor: '1 2 ♭3 4 5 ♭6 7',
    melodic_minor: '1 2 ♭3 4 5 6 7',
    whole_tone: '1 2 3 ♯4 ♯5 ♯6',
    chromatic: 'alla 12 toner',
  };

  return `${baseNote} ${scale}: ${scalePatterns[scale] || 'okänd skala'}`;
}

function summarizeSequence(sequence: Sequence): string {
  const noteCount = sequence.notes.length;
  const pitchRange = sequence.notes.length > 0
    ? `${Math.min(...sequence.notes.map(n => n.pitch))}-${Math.max(...sequence.notes.map(n => n.pitch))}`
    : 'N/A';
  
  return `${noteCount} noter, omfång: ${pitchRange}, längd: ${sequence.length} beats`;
}

// ============================================
// Export specialiserade prompt-builders
// ============================================

export const promptBuilders = {
  system: buildSystemPrompt,
  generation: buildGenerationPrompt,
  variation: buildVariationPrompt,
  moodMorph: buildMoodMorphPrompt,
  story: buildStoryPrompt,
  evolution: buildEvolutionPrompt,
};
