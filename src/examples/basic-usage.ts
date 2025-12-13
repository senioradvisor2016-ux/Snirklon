/**
 * Snirklon - Basic Usage Example
 * Visar hur man använder Claude-integrationen
 */

import { 
  SnirklonClaudeClient, 
  MUSICAL_PERSONAS,
  getPersonaByMood 
} from '../claude';

async function main() {
  // ============================================
  // 1. Skapa en klient och starta session
  // ============================================
  
  const client = new SnirklonClaudeClient();
  
  const session = client.startSession({
    bpm: 120,
    timeSignature: [4, 4],
    key: 'Am',
    scale: 'minor',
    mood: 'dark, atmospheric',
    genre: 'electronic',
  });
  
  console.log('Session startad:', session.id);

  // ============================================
  // 2. Grundläggande generering
  // ============================================
  
  console.log('\n--- Grundläggande generering ---');
  
  const basicResult = await client.generateSequence({
    prompt: 'Skapa en mörk, pulserande bassslinga i 16 steg',
    context: session.context,
  });
  
  if (basicResult.success && basicResult.sequence) {
    console.log('Genererad sekvens:', basicResult.sequence.name);
    console.log('Antal noter:', basicResult.sequence.notes.length);
    console.log('Förklaring:', basicResult.explanation);
  }

  // ============================================
  // 3. Generering med Persona
  // ============================================
  
  console.log('\n--- Generering med Persona ---');
  
  // Lista alla tillgängliga personas
  console.log('Tillgängliga personas:', Object.keys(MUSICAL_PERSONAS));
  
  // Använd en specifik persona
  const technoResult = await client.generateSequence({
    prompt: 'Skapa en hypnotisk arpeggio',
    context: session.context,
    persona: 'techno_engineer',
  });
  
  if (technoResult.success) {
    console.log('Techno-sekvens:', technoResult.sequence?.name);
  }
  
  // Eller hitta en persona baserat på stämning
  const dreamyPersona = getPersonaByMood('dreamy');
  console.log('Drömlikt persona:', dreamyPersona?.name);

  // ============================================
  // 4. Mood Morphing
  // ============================================
  
  console.log('\n--- Mood Morphing ---');
  
  if (basicResult.sequence) {
    const morphedResult = await client.moodMorph(
      basicResult.sequence,
      'hopeful and uplifting'
    );
    
    if (morphedResult.success) {
      console.log('Transformerad sekvens:', morphedResult.sequence?.name);
    }
  }

  // ============================================
  // 5. Skapa variationer
  // ============================================
  
  console.log('\n--- Variationer ---');
  
  if (basicResult.sequence) {
    const variations = ['rhythmic', 'melodic', 'harmonic'] as const;
    
    for (const type of variations) {
      const variation = await client.createVariation(basicResult.sequence, type);
      if (variation.success) {
        console.log(`${type} variation:`, variation.sequence?.notes.length, 'noter');
      }
    }
  }

  // ============================================
  // 6. Musikalisk berättelse
  // ============================================
  
  console.log('\n--- Musikalisk Berättelse ---');
  
  const storyResult = await client.createMusicalStory(
    'En resa genom natten till gryningen',
    4
  );
  
  if (storyResult.success) {
    console.log('Berättelse skapad:', storyResult.explanation);
  }

  // ============================================
  // 7. Streaming (för realtidsrespons)
  // ============================================
  
  console.log('\n--- Streaming ---');
  
  const streamGenerator = client.streamSequence({
    prompt: 'Skapa en melodisk fras',
    context: session.context,
  });
  
  process.stdout.write('Streaming: ');
  for await (const chunk of streamGenerator) {
    process.stdout.write('.');
  }
  console.log(' Klart!');

  // ============================================
  // 8. Generering med begränsningar
  // ============================================
  
  console.log('\n--- Generering med Begränsningar ---');
  
  const constrainedResult = await client.generateSequence({
    prompt: 'Skapa en minimal melodi',
    context: session.context,
    constraints: {
      maxNotes: 8,
      noteRange: [60, 72], // En oktav från C4
      forceInKey: true,
      rhythmicDensity: 'sparse',
    },
  });
  
  if (constrainedResult.success && constrainedResult.sequence) {
    console.log('Begränsad sekvens:', constrainedResult.sequence.notes.length, 'noter');
    console.log('Inom begränsning:', constrainedResult.sequence.notes.length <= 8 ? 'Ja' : 'Nej');
  }

  console.log('\n--- Exempel klart! ---');
}

// Kör exemplet
main().catch(console.error);
