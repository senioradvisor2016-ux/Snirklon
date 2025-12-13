/**
 * Snirklon - Synth & Drums Example
 * Visar hur man använder både synth- och drum-sekvensering
 */

import { SnirklonSequencerClient } from '../sequencer';
import { DRUM_KITS, CLASSIC_PATTERNS, generateEuclidean, euclideanToTrack } from '../drums';
import { ALL_SYNTH_PRESETS } from '../synth';

async function main() {
  const client = new SnirklonSequencerClient();

  // Starta session
  const session = client.startSession({
    bpm: 128,
    timeSignature: [4, 4],
    key: 'Dm',
    scale: 'minor',
    mood: 'dark, driving',
    genre: 'techno',
  });

  console.log('🎹 Snirklon Session Started');
  console.log(`   ID: ${session.id}`);
  console.log(`   BPM: ${session.context.bpm}`);
  console.log(`   Key: ${session.context.key} ${session.context.scale}`);
  console.log('');

  // ============================================
  // 1. Generera Drum Pattern
  // ============================================
  
  console.log('🥁 === DRUM GENERATION ===\n');

  // Grundläggande techno-beat
  console.log('Generating techno beat...');
  const technoResult = await client.generateDrumSequence({
    prompt: 'Skapa en driving techno-beat med tung kick och tight hi-hats',
    context: session.context,
    style: 'techno',
    kitId: 'kit_909',
  });

  if (technoResult.success && technoResult.drumSequence) {
    console.log(`✓ Generated: ${technoResult.drumSequence.name}`);
    console.log(`  Tracks: ${technoResult.drumSequence.tracks.length}`);
    console.log(`  Explanation: ${technoResult.explanation}`);
  }

  // Euclidean drums
  console.log('\nGenerating euclidean pattern...');
  const euclideanKick = generateEuclidean({ hits: 4, steps: 16, rotation: 0 });
  const euclideanHat = generateEuclidean({ hits: 7, steps: 16, rotation: 2 });
  console.log(`  Kick (4/16): ${euclideanKick.map(b => b ? 'X' : '-').join('')}`);
  console.log(`  Hat  (7/16): ${euclideanHat.map(b => b ? 'X' : '-').join('')}`);

  // Polyrhythmic pattern
  console.log('\nGenerating polyrhythmic pattern...');
  const polyResult = await client.generateDrumSequence({
    prompt: 'Skapa ett polymetriskt pattern: kick i 4, hi-hat i 3, percussion i 5',
    context: session.context,
    constraints: {
      allowPolyrhythm: true,
      complexity: 'complex',
    },
  });

  if (polyResult.success) {
    console.log(`✓ Generated polyrhythmic pattern`);
    console.log(`  Explanation: ${polyResult.explanation}`);
  }

  // Style transform
  console.log('\nTransforming techno to jungle...');
  if (technoResult.drumSequence) {
    const jungleResult = await client.styleTransform(technoResult.drumSequence, 'jungle');
    if (jungleResult.success) {
      console.log(`✓ Transformed to jungle style`);
      console.log(`  Explanation: ${jungleResult.explanation}`);
    }
  }

  // ============================================
  // 2. Generera Synth Sequences
  // ============================================

  console.log('\n🎹 === SYNTH GENERATION ===\n');

  // Bass line
  console.log('Generating acid bass line...');
  const bassResult = await client.generateSynthSequence({
    prompt: 'Skapa en squelchy acid bassline med slides och accenter',
    context: session.context,
    patchHint: 'acid_bass',
    constraints: {
      noteRange: [36, 60],
      patchCategory: 'bass',
    },
  });

  if (bassResult.success && bassResult.synthSequence) {
    console.log(`✓ Generated: ${bassResult.synthSequence.name}`);
    console.log(`  Notes: ${bassResult.synthSequence.notes.length}`);
    console.log(`  Patch: ${bassResult.suggestedPatch?.name || 'custom'}`);
    console.log(`  Explanation: ${bassResult.explanation}`);
  }

  // Pad
  console.log('\nGenerating atmospheric pad...');
  const padResult = await client.generateSynthSequence({
    prompt: 'Skapa ett mörkt, evolverande pad med långa noter och subtle rörelse',
    context: session.context,
    persona: 'cosmic_explorer',
    patchHint: 'dark_pad',
    constraints: {
      maxPolyphony: 4,
      patchCategory: 'pad',
    },
  });

  if (padResult.success) {
    console.log(`✓ Generated atmospheric pad`);
    console.log(`  Explanation: ${padResult.explanation}`);
  }

  // Arpeggio
  console.log('\nGenerating arpeggio...');
  const arpeggioResult = await client.generateArpeggio(
    [62, 65, 69, 72], // Dm chord
    {
      prompt: 'Skapa en hypnotisk arpeggio som bygger upp energi',
      context: session.context,
      patchHint: 'digital_pluck',
    }
  );

  if (arpeggioResult.success) {
    console.log(`✓ Generated arpeggio`);
    if (arpeggioResult.arpeggiatorConfig) {
      console.log(`  Mode: ${arpeggioResult.arpeggiatorConfig.mode}`);
      console.log(`  Rate: ${arpeggioResult.arpeggiatorConfig.rate}`);
    }
  }

  // ============================================
  // 3. Design Custom Patch
  // ============================================

  console.log('\n🔧 === PATCH DESIGN ===\n');

  console.log('Designing custom synth patch...');
  const customPatch = await client.designSynthPatch(
    'En aggressiv lead med metallisk karaktär, snabb attack, resonant filter, och lite distortion'
  );

  if (customPatch) {
    console.log(`✓ Designed: ${customPatch.patch.name}`);
    console.log(`  Category: ${customPatch.patch.category}`);
    console.log(`  Oscillators: ${customPatch.patch.oscillators.length}`);
    console.log(`  Filter: ${customPatch.patch.filter.type} @ ${customPatch.patch.filter.cutoff}Hz`);
    console.log(`  Explanation: ${customPatch.explanation.substring(0, 100)}...`);
  }

  // ============================================
  // 4. Full Arrangement
  // ============================================

  console.log('\n🎼 === FULL ARRANGEMENT ===\n');

  console.log('Generating 4-section arrangement...');
  const arrangement = await client.generateFullArrangement(
    'En mörk techno-track som börjar minimalt och bygger upp till ett intensivt klimax',
    4
  );

  console.log(`✓ Generated arrangement`);
  console.log(`  Synth sections: ${arrangement.synth.length}`);
  console.log(`  Drum sections: ${arrangement.drums.length}`);
  console.log(`  Arrangement notes: ${arrangement.arrangement.substring(0, 200)}...`);

  // ============================================
  // 5. Jam Session
  // ============================================

  console.log('\n🎸 === JAM SESSION ===\n');

  if (bassResult.synthSequence) {
    console.log('AI responding to bass line with drums...');
    const jamResponse = await client.jamSession(
      { type: 'synth', sequence: bassResult.synthSequence },
      'drums'
    );

    if (jamResponse.drums?.success) {
      console.log(`✓ AI generated complementary drum pattern`);
      console.log(`  Explanation: ${jamResponse.drums.explanation}`);
    }
  }

  // ============================================
  // Summary
  // ============================================

  console.log('\n📊 === AVAILABLE PRESETS ===\n');
  
  console.log('Synth Presets:');
  Object.entries(ALL_SYNTH_PRESETS).forEach(([id, preset]) => {
    console.log(`  - ${id}: ${preset.name} (${preset.category})`);
  });

  console.log('\nDrum Kits:');
  Object.entries(DRUM_KITS).forEach(([id, kit]) => {
    console.log(`  - ${id}: ${kit.name} (${kit.sounds.length} sounds)`);
  });

  console.log('\nClassic Patterns:');
  Object.entries(CLASSIC_PATTERNS).forEach(([id, pattern]) => {
    console.log(`  - ${id}: ${pattern.name}`);
  });

  console.log('\n✨ Demo complete!');
}

// Run
main().catch(console.error);
