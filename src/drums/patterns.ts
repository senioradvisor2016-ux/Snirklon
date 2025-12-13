/**
 * Snirklon - Drum Patterns
 * Fördefinierade trummönster och kits
 */

import { 
  DrumKit, 
  DrumSequence, 
  DrumTrack, 
  DrumStep,
  DrumStyle,
  EuclideanConfig,
  GrooveTemplate,
  DrumInstrument
} from './types';

// ============================================
// Drum Kits
// ============================================

export const DRUM_KITS: Record<string, DrumKit> = {
  kit_808: {
    id: 'kit_808',
    name: 'Classic 808',
    category: '808',
    sounds: [
      { id: 'kick', instrument: 'kick_808', name: 'Kick', midiNote: 36, params: { pitch: 0, pitchEnvAmount: 0.5, pitchEnvDecay: 0.1, tone: 0.3, decay: 0.8, attack: 0.8, body: 0.9, drive: 0.1, noise: 0, noiseDecay: 0, level: 1, pan: 0, compression: 0.3 }, sendA: 0, sendB: 0 },
      { id: 'snare', instrument: 'snare_808', name: 'Snare', midiNote: 38, params: { pitch: 0, pitchEnvAmount: 0.3, pitchEnvDecay: 0.05, tone: 0.6, decay: 0.3, attack: 0.9, body: 0.4, drive: 0.2, noise: 0.5, noiseDecay: 0.2, level: 0.9, pan: 0, compression: 0.2 }, sendA: 0.2, sendB: 0.1 },
      { id: 'clap', instrument: 'clap', name: 'Clap', midiNote: 39, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.7, decay: 0.25, attack: 0.5, body: 0.3, drive: 0.1, noise: 0.8, noiseDecay: 0.15, level: 0.85, pan: 0, compression: 0.3 }, sendA: 0.3, sendB: 0.15 },
      { id: 'hihat_closed', instrument: 'hihat_808', name: 'Closed HH', midiNote: 42, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0.1, pitchEnvDecay: 0.01, tone: 0.8, decay: 0.05, attack: 1, body: 0.1, drive: 0, noise: 0.9, noiseDecay: 0.03, level: 0.7, pan: 0.1, compression: 0 }, sendA: 0.1, sendB: 0.2 },
      { id: 'hihat_open', instrument: 'hihat_808', name: 'Open HH', midiNote: 46, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0.1, pitchEnvDecay: 0.01, tone: 0.75, decay: 0.4, attack: 1, body: 0.1, drive: 0, noise: 0.9, noiseDecay: 0.3, level: 0.65, pan: 0.1, compression: 0 }, sendA: 0.2, sendB: 0.25 },
      { id: 'tom_low', instrument: 'tom_low', name: 'Low Tom', midiNote: 45, params: { pitch: -5, pitchEnvAmount: 0.6, pitchEnvDecay: 0.15, tone: 0.4, decay: 0.5, attack: 0.7, body: 0.8, drive: 0.1, noise: 0.1, noiseDecay: 0.1, level: 0.8, pan: -0.3, compression: 0.2 }, sendA: 0.2, sendB: 0 },
      { id: 'tom_high', instrument: 'tom_high', name: 'High Tom', midiNote: 50, params: { pitch: 5, pitchEnvAmount: 0.5, pitchEnvDecay: 0.1, tone: 0.5, decay: 0.35, attack: 0.8, body: 0.6, drive: 0.1, noise: 0.1, noiseDecay: 0.08, level: 0.75, pan: 0.3, compression: 0.2 }, sendA: 0.2, sendB: 0 },
      { id: 'cowbell', instrument: 'cowbell', name: 'Cowbell', midiNote: 56, params: { pitch: 0, pitchEnvAmount: 0.2, pitchEnvDecay: 0.02, tone: 0.9, decay: 0.2, attack: 1, body: 0.3, drive: 0.2, noise: 0, noiseDecay: 0, level: 0.6, pan: 0.2, compression: 0 }, sendA: 0.15, sendB: 0.1 },
    ],
    globalSettings: { volume: 0.85, swing: 0, velocityCurve: 'linear' },
    effectsSends: {
      sendA: { type: 'reverb', params: { size: 0.3, decay: 1.2, damping: 0.6 } },
      sendB: { type: 'delay', params: { time: 0.375, feedback: 0.25 } },
    },
  },

  kit_909: {
    id: 'kit_909',
    name: 'Classic 909',
    category: '909',
    sounds: [
      { id: 'kick', instrument: 'kick_909', name: 'Kick', midiNote: 36, params: { pitch: 0, pitchEnvAmount: 0.4, pitchEnvDecay: 0.08, tone: 0.5, decay: 0.5, attack: 0.9, body: 0.85, drive: 0.2, noise: 0.05, noiseDecay: 0.02, level: 1, pan: 0, compression: 0.4 }, sendA: 0, sendB: 0 },
      { id: 'snare', instrument: 'snare_909', name: 'Snare', midiNote: 38, params: { pitch: 0, pitchEnvAmount: 0.25, pitchEnvDecay: 0.04, tone: 0.65, decay: 0.25, attack: 0.95, body: 0.5, drive: 0.15, noise: 0.6, noiseDecay: 0.18, level: 0.9, pan: 0, compression: 0.25 }, sendA: 0.15, sendB: 0.1 },
      { id: 'clap', instrument: 'clap', name: 'Clap', midiNote: 39, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.75, decay: 0.2, attack: 0.6, body: 0.25, drive: 0.1, noise: 0.85, noiseDecay: 0.12, level: 0.85, pan: 0, compression: 0.3 }, sendA: 0.25, sendB: 0.15 },
      { id: 'hihat_closed', instrument: 'hihat_909', name: 'Closed HH', midiNote: 42, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0.05, pitchEnvDecay: 0.005, tone: 0.85, decay: 0.04, attack: 1, body: 0.05, drive: 0, noise: 0.95, noiseDecay: 0.02, level: 0.7, pan: 0.15, compression: 0 }, sendA: 0.05, sendB: 0.15 },
      { id: 'hihat_open', instrument: 'hihat_909', name: 'Open HH', midiNote: 46, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0.05, pitchEnvDecay: 0.005, tone: 0.8, decay: 0.35, attack: 1, body: 0.05, drive: 0, noise: 0.95, noiseDecay: 0.25, level: 0.65, pan: 0.15, compression: 0 }, sendA: 0.15, sendB: 0.2 },
      { id: 'ride', instrument: 'ride', name: 'Ride', midiNote: 51, params: { pitch: 0, pitchEnvAmount: 0.02, pitchEnvDecay: 0.01, tone: 0.7, decay: 1.2, attack: 0.9, body: 0.2, drive: 0, noise: 0.7, noiseDecay: 0.8, level: 0.55, pan: 0.25, compression: 0 }, sendA: 0.2, sendB: 0.1 },
      { id: 'crash', instrument: 'crash', name: 'Crash', midiNote: 49, params: { pitch: 0, pitchEnvAmount: 0.03, pitchEnvDecay: 0.02, tone: 0.6, decay: 2, attack: 0.8, body: 0.3, drive: 0, noise: 0.75, noiseDecay: 1.5, level: 0.5, pan: -0.2, compression: 0 }, sendA: 0.3, sendB: 0.1 },
      { id: 'rimshot', instrument: 'rimshot', name: 'Rimshot', midiNote: 37, params: { pitch: 0, pitchEnvAmount: 0.15, pitchEnvDecay: 0.01, tone: 0.9, decay: 0.08, attack: 1, body: 0.4, drive: 0.3, noise: 0.3, noiseDecay: 0.05, level: 0.75, pan: 0, compression: 0.2 }, sendA: 0.1, sendB: 0.2 },
    ],
    globalSettings: { volume: 0.85, swing: 0, velocityCurve: 'linear' },
    effectsSends: {
      sendA: { type: 'reverb', params: { size: 0.25, decay: 0.8, damping: 0.7 } },
      sendB: { type: 'delay', params: { time: 0.25, feedback: 0.2 } },
    },
  },

  kit_acoustic: {
    id: 'kit_acoustic',
    name: 'Acoustic Kit',
    category: 'acoustic',
    sounds: [
      { id: 'kick', instrument: 'kick_acoustic', name: 'Kick', midiNote: 36, params: { pitch: 0, pitchEnvAmount: 0.2, pitchEnvDecay: 0.05, tone: 0.5, decay: 0.4, attack: 0.7, body: 0.8, drive: 0.05, noise: 0.1, noiseDecay: 0.05, level: 1, pan: 0, compression: 0.3 }, sendA: 0.2, sendB: 0 },
      { id: 'snare', instrument: 'snare_acoustic', name: 'Snare', midiNote: 38, params: { pitch: 0, pitchEnvAmount: 0.15, pitchEnvDecay: 0.03, tone: 0.6, decay: 0.3, attack: 0.85, body: 0.5, drive: 0.05, noise: 0.5, noiseDecay: 0.2, level: 0.9, pan: 0, compression: 0.2 }, sendA: 0.25, sendB: 0.1 },
      { id: 'hihat_closed', instrument: 'hihat_closed', name: 'Closed HH', midiNote: 42, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.7, decay: 0.08, attack: 0.9, body: 0.1, drive: 0, noise: 0.85, noiseDecay: 0.05, level: 0.7, pan: 0.2, compression: 0 }, sendA: 0.1, sendB: 0.15 },
      { id: 'hihat_open', instrument: 'hihat_open', name: 'Open HH', midiNote: 46, chokeGroup: 1, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.65, decay: 0.5, attack: 0.85, body: 0.1, drive: 0, noise: 0.8, noiseDecay: 0.35, level: 0.65, pan: 0.2, compression: 0 }, sendA: 0.2, sendB: 0.2 },
      { id: 'tom_high', instrument: 'tom_high', name: 'High Tom', midiNote: 50, params: { pitch: 0, pitchEnvAmount: 0.3, pitchEnvDecay: 0.08, tone: 0.55, decay: 0.4, attack: 0.8, body: 0.6, drive: 0.05, noise: 0.15, noiseDecay: 0.1, level: 0.8, pan: 0.25, compression: 0.15 }, sendA: 0.25, sendB: 0.05 },
      { id: 'tom_mid', instrument: 'tom_mid', name: 'Mid Tom', midiNote: 47, params: { pitch: 0, pitchEnvAmount: 0.35, pitchEnvDecay: 0.1, tone: 0.5, decay: 0.45, attack: 0.75, body: 0.7, drive: 0.05, noise: 0.12, noiseDecay: 0.12, level: 0.8, pan: 0, compression: 0.15 }, sendA: 0.25, sendB: 0.05 },
      { id: 'tom_floor', instrument: 'tom_floor', name: 'Floor Tom', midiNote: 43, params: { pitch: 0, pitchEnvAmount: 0.4, pitchEnvDecay: 0.12, tone: 0.45, decay: 0.55, attack: 0.7, body: 0.8, drive: 0.05, noise: 0.1, noiseDecay: 0.15, level: 0.8, pan: -0.25, compression: 0.15 }, sendA: 0.25, sendB: 0.05 },
      { id: 'crash', instrument: 'crash', name: 'Crash', midiNote: 49, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.55, decay: 2.5, attack: 0.7, body: 0.25, drive: 0, noise: 0.7, noiseDecay: 2, level: 0.55, pan: -0.3, compression: 0 }, sendA: 0.35, sendB: 0.1 },
      { id: 'ride', instrument: 'ride', name: 'Ride', midiNote: 51, params: { pitch: 0, pitchEnvAmount: 0, pitchEnvDecay: 0, tone: 0.6, decay: 1.5, attack: 0.8, body: 0.2, drive: 0, noise: 0.6, noiseDecay: 1, level: 0.55, pan: 0.35, compression: 0 }, sendA: 0.2, sendB: 0.1 },
    ],
    globalSettings: { volume: 0.8, swing: 0, velocityCurve: 'soft' },
    effectsSends: {
      sendA: { type: 'reverb', params: { size: 0.5, decay: 1.8, damping: 0.4 } },
      sendB: { type: 'delay', params: { time: 0.25, feedback: 0.15 } },
    },
  },
};

// ============================================
// Groove Templates
// ============================================

export const GROOVE_TEMPLATES: Record<string, GrooveTemplate> = {
  mpc_60: {
    name: 'MPC 60',
    // 16th note swing pattern
    timingOffsets: [0, 0, 15, 0, 0, 0, 15, 0, 0, 0, 15, 0, 0, 0, 15, 0],
    velocityOffsets: [10, -5, -10, -5, 5, -5, -10, -5, 10, -5, -10, -5, 5, -5, -10, -5],
  },
  sp1200: {
    name: 'SP-1200',
    timingOffsets: [0, 0, 20, 0, 0, 0, 18, 0, 0, 0, 22, 0, 0, 0, 17, 0],
    velocityOffsets: [15, -8, -12, -3, 8, -6, -10, -4, 12, -7, -14, -2, 6, -5, -11, -5],
  },
  shuffle_light: {
    name: 'Light Shuffle',
    timingOffsets: [0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0],
    velocityOffsets: [5, -3, -5, -2, 3, -2, -5, -2, 5, -3, -5, -2, 3, -2, -5, -2],
  },
  shuffle_heavy: {
    name: 'Heavy Shuffle',
    timingOffsets: [0, 0, 25, 0, 0, 0, 25, 0, 0, 0, 25, 0, 0, 0, 25, 0],
    velocityOffsets: [10, -5, -8, -3, 5, -4, -8, -3, 10, -5, -8, -3, 5, -4, -8, -3],
  },
  human_loose: {
    name: 'Human Loose',
    timingOffsets: [2, -3, 5, -2, 1, -4, 6, -1, 3, -2, 4, -3, 2, -5, 7, -2],
    velocityOffsets: [8, -4, -6, 2, -3, 5, -7, 1, 6, -5, -4, 3, -2, 4, -8, 2],
  },
};

// ============================================
// Classic Drum Patterns
// ============================================

function createStep(active: boolean, velocity = 100, probability = 1): DrumStep {
  return {
    active,
    velocity,
    nudge: 0,
    probability,
  };
}

function createTrack(
  id: string, 
  soundId: string, 
  name: string, 
  pattern: boolean[], 
  velocities?: number[]
): DrumTrack {
  const steps = pattern.map((active, i) => 
    createStep(active, velocities?.[i] ?? (active ? 100 : 0))
  );
  
  return {
    id,
    soundId,
    name,
    steps,
    length: pattern.length,
    mute: false,
    solo: false,
    volume: 1,
    pan: 0,
  };
}

export const CLASSIC_PATTERNS: Record<string, Partial<DrumSequence>> = {
  four_on_floor: {
    name: 'Four on the Floor',
    tracks: [
      createTrack('kick', 'kick', 'Kick', 
        [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
        [120, 0, 0, 0, 110, 0, 0, 0, 115, 0, 0, 0, 108, 0, 0, 0]
      ),
      createTrack('snare', 'snare', 'Snare',
        [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
        [0, 0, 0, 0, 115, 0, 0, 0, 0, 0, 0, 0, 112, 0, 0, 0]
      ),
      createTrack('hihat', 'hihat_closed', 'Hi-Hat',
        [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
        [90, 0, 70, 0, 85, 0, 65, 0, 88, 0, 72, 0, 82, 0, 68, 0]
      ),
    ],
    metadata: { generatedBy: 'user', style: 'house', tags: ['house', 'techno', 'four-on-floor'], timestamp: Date.now() },
  },

  breakbeat_basic: {
    name: 'Basic Breakbeat',
    tracks: [
      createTrack('kick', 'kick', 'Kick',
        [true, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false],
        [120, 0, 0, 0, 0, 0, 100, 0, 0, 0, 115, 0, 0, 0, 0, 0]
      ),
      createTrack('snare', 'snare', 'Snare',
        [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, true],
        [0, 0, 0, 0, 115, 0, 0, 0, 0, 0, 0, 0, 110, 0, 0, 90]
      ),
      createTrack('hihat', 'hihat_closed', 'Hi-Hat',
        [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
        [80, 60, 70, 55, 85, 58, 72, 52, 82, 62, 68, 54, 80, 60, 75, 50]
      ),
    ],
    metadata: { generatedBy: 'user', style: 'breakbeat', tags: ['breakbeat', 'hip-hop'], timestamp: Date.now() },
  },

  dnb_basic: {
    name: 'D&B Basic',
    tracks: [
      createTrack('kick', 'kick', 'Kick',
        [true, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
        [125, 0, 0, 0, 0, 0, 0, 0, 0, 0, 118, 0, 0, 0, 0, 0]
      ),
      createTrack('snare', 'snare', 'Snare',
        [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
        [0, 0, 0, 0, 120, 0, 0, 0, 0, 0, 0, 0, 115, 0, 0, 0]
      ),
      createTrack('hihat', 'hihat_closed', 'Hi-Hat',
        [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
        [75, 55, 70, 50, 80, 58, 68, 48, 78, 52, 72, 55, 76, 56, 65, 45]
      ),
    ],
    metadata: { generatedBy: 'user', style: 'drum_and_bass', tags: ['dnb', 'jungle'], timestamp: Date.now() },
  },

  trap_basic: {
    name: 'Trap Basic',
    tracks: [
      createTrack('kick', 'kick', 'Kick',
        [true, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false],
        [127, 0, 0, 0, 0, 0, 0, 95, 0, 0, 120, 0, 0, 0, 0, 0]
      ),
      createTrack('snare', 'snare', 'Snare',
        [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
        [0, 0, 0, 0, 120, 0, 0, 0, 0, 0, 0, 0, 115, 0, 0, 0]
      ),
      createTrack('hihat', 'hihat_closed', 'Hi-Hat',
        [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
        [85, 45, 90, 50, 82, 48, 88, 52, 80, 46, 92, 55, 78, 44, 85, 48]
      ),
    ],
    metadata: { generatedBy: 'user', style: 'trap', tags: ['trap', 'hip-hop', '808'], timestamp: Date.now() },
  },

  techno_minimal: {
    name: 'Minimal Techno',
    tracks: [
      createTrack('kick', 'kick', 'Kick',
        [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
        [118, 0, 0, 0, 115, 0, 0, 0, 120, 0, 0, 0, 112, 0, 0, 0]
      ),
      createTrack('hihat', 'hihat_closed', 'Hi-Hat',
        [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false],
        [0, 0, 85, 0, 0, 0, 80, 0, 0, 0, 88, 0, 0, 0, 78, 0]
      ),
      createTrack('perc', 'rimshot', 'Rimshot',
        [false, false, false, true, false, false, false, false, false, false, false, true, false, false, false, false],
        [0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 70, 0, 0, 0, 0]
      ),
    ],
    metadata: { generatedBy: 'user', style: 'minimal', tags: ['techno', 'minimal'], timestamp: Date.now() },
  },
};

// ============================================
// Euclidean Rhythm Generator
// ============================================

export function generateEuclidean(config: EuclideanConfig): boolean[] {
  const { hits, steps, rotation } = config;
  
  if (hits > steps) return new Array(steps).fill(true);
  if (hits === 0) return new Array(steps).fill(false);
  
  // Bjorklund's algorithm
  let pattern: number[][] = [];
  let remainder: number[][] = [];
  
  for (let i = 0; i < hits; i++) pattern.push([1]);
  for (let i = 0; i < steps - hits; i++) remainder.push([0]);
  
  while (remainder.length > 1) {
    const newPattern: number[][] = [];
    const minLen = Math.min(pattern.length, remainder.length);
    
    for (let i = 0; i < minLen; i++) {
      newPattern.push([...pattern[i], ...remainder[i]]);
    }
    
    const leftover = pattern.length > remainder.length 
      ? pattern.slice(minLen) 
      : remainder.slice(minLen);
    
    pattern = newPattern;
    remainder = leftover;
  }
  
  const result = [...pattern, ...remainder].flat();
  
  // Apply rotation
  const rotated = [
    ...result.slice(rotation % steps),
    ...result.slice(0, rotation % steps)
  ];
  
  return rotated.map(v => v === 1);
}

export function euclideanToTrack(
  config: EuclideanConfig,
  soundId: string,
  name: string,
  baseVelocity = 100
): DrumTrack {
  const pattern = generateEuclidean(config);
  
  let accentPattern: boolean[] | undefined;
  if (config.accent) {
    accentPattern = generateEuclidean(config.accent);
  }
  
  const steps: DrumStep[] = pattern.map((active, i) => ({
    active,
    velocity: active 
      ? (accentPattern?.[i] ? Math.min(127, baseVelocity + 20) : baseVelocity)
      : 0,
    nudge: 0,
    probability: 1,
  }));
  
  return {
    id: `euclidean_${soundId}`,
    soundId,
    name,
    steps,
    length: config.steps,
    mute: false,
    solo: false,
    volume: 1,
    pan: 0,
  };
}

// ============================================
// Style-based Pattern Generation Hints
// ============================================

export const STYLE_CHARACTERISTICS: Record<DrumStyle, {
  tempoRange: [number, number];
  swingRange: [number, number];
  kickPattern: string;
  snarePattern: string;
  hihatDensity: 'sparse' | 'normal' | 'dense';
  characteristics: string[];
}> = {
  techno: {
    tempoRange: [125, 145],
    swingRange: [0, 0.1],
    kickPattern: 'four-on-floor',
    snarePattern: 'backbeat or none',
    hihatDensity: 'normal',
    characteristics: ['driving', 'mechanical', 'hypnotic'],
  },
  house: {
    tempoRange: [118, 130],
    swingRange: [0, 0.15],
    kickPattern: 'four-on-floor',
    snarePattern: 'backbeat with claps',
    hihatDensity: 'normal',
    characteristics: ['groovy', 'soulful', 'funky'],
  },
  deep_house: {
    tempoRange: [118, 125],
    swingRange: [0.1, 0.2],
    kickPattern: 'four-on-floor with variations',
    snarePattern: 'light backbeat',
    hihatDensity: 'sparse',
    characteristics: ['laid-back', 'warm', 'subtle'],
  },
  tech_house: {
    tempoRange: [124, 130],
    swingRange: [0, 0.1],
    kickPattern: 'four-on-floor with offbeats',
    snarePattern: 'minimal',
    hihatDensity: 'dense',
    characteristics: ['groovy', 'hypnotic', 'percussive'],
  },
  minimal: {
    tempoRange: [120, 135],
    swingRange: [0, 0.15],
    kickPattern: 'sparse, syncopated',
    snarePattern: 'rimshots and clicks',
    hihatDensity: 'sparse',
    characteristics: ['subtle', 'spacious', 'hypnotic'],
  },
  trance: {
    tempoRange: [135, 150],
    swingRange: [0, 0],
    kickPattern: 'four-on-floor, punchy',
    snarePattern: 'backbeat or offbeat',
    hihatDensity: 'dense',
    characteristics: ['driving', 'euphoric', 'energetic'],
  },
  drum_and_bass: {
    tempoRange: [160, 180],
    swingRange: [0, 0.1],
    kickPattern: 'syncopated, complex',
    snarePattern: 'backbeat, heavy',
    hihatDensity: 'dense',
    characteristics: ['fast', 'breakbeat', 'energetic'],
  },
  jungle: {
    tempoRange: [160, 175],
    swingRange: [0.1, 0.2],
    kickPattern: 'broken, syncopated',
    snarePattern: 'chopped breaks',
    hihatDensity: 'dense',
    characteristics: ['chaotic', 'organic', 'reggae-influenced'],
  },
  dubstep: {
    tempoRange: [138, 142],
    swingRange: [0, 0.1],
    kickPattern: 'half-time feel',
    snarePattern: 'on beat 3',
    hihatDensity: 'normal',
    characteristics: ['heavy', 'bass-focused', 'half-time'],
  },
  garage: {
    tempoRange: [130, 140],
    swingRange: [0.15, 0.25],
    kickPattern: 'shuffled',
    snarePattern: 'syncopated',
    hihatDensity: 'normal',
    characteristics: ['shuffled', 'skippy', 'soulful'],
  },
  breakbeat: {
    tempoRange: [120, 140],
    swingRange: [0, 0.15],
    kickPattern: 'broken, funky',
    snarePattern: 'syncopated',
    hihatDensity: 'dense',
    characteristics: ['funky', 'syncopated', 'energetic'],
  },
  idm: {
    tempoRange: [80, 160],
    swingRange: [0, 0.3],
    kickPattern: 'experimental',
    snarePattern: 'unpredictable',
    hihatDensity: 'sparse',
    characteristics: ['experimental', 'complex', 'glitchy'],
  },
  ambient: {
    tempoRange: [60, 100],
    swingRange: [0, 0.2],
    kickPattern: 'sparse or none',
    snarePattern: 'sparse or none',
    hihatDensity: 'sparse',
    characteristics: ['spacious', 'atmospheric', 'subtle'],
  },
  rock: {
    tempoRange: [100, 140],
    swingRange: [0, 0.1],
    kickPattern: 'downbeat focused',
    snarePattern: 'backbeat',
    hihatDensity: 'normal',
    characteristics: ['driving', 'powerful', 'dynamic'],
  },
  pop: {
    tempoRange: [100, 130],
    swingRange: [0, 0.15],
    kickPattern: 'four-on-floor or standard',
    snarePattern: 'backbeat',
    hihatDensity: 'normal',
    characteristics: ['catchy', 'accessible', 'clean'],
  },
  funk: {
    tempoRange: [95, 120],
    swingRange: [0.1, 0.25],
    kickPattern: 'syncopated',
    snarePattern: 'ghost notes',
    hihatDensity: 'dense',
    characteristics: ['groovy', 'syncopated', 'tight'],
  },
  jazz: {
    tempoRange: [80, 200],
    swingRange: [0.2, 0.35],
    kickPattern: 'sparse, supportive',
    snarePattern: 'brush patterns',
    hihatDensity: 'sparse',
    characteristics: ['swinging', 'dynamic', 'improvised'],
  },
  hip_hop: {
    tempoRange: [85, 115],
    swingRange: [0.1, 0.25],
    kickPattern: 'boom bap',
    snarePattern: 'backbeat, layered',
    hihatDensity: 'normal',
    characteristics: ['groovy', 'head-nodding', 'sampled'],
  },
  trap: {
    tempoRange: [130, 170],
    swingRange: [0, 0.1],
    kickPattern: '808 patterns',
    snarePattern: 'snare rolls',
    hihatDensity: 'dense',
    characteristics: ['heavy 808s', 'hi-hat rolls', 'aggressive'],
  },
  'r&b': {
    tempoRange: [70, 110],
    swingRange: [0.1, 0.2],
    kickPattern: 'laid-back',
    snarePattern: 'soft backbeat',
    hihatDensity: 'normal',
    characteristics: ['smooth', 'soulful', 'groove-focused'],
  },
  reggae: {
    tempoRange: [70, 90],
    swingRange: [0.15, 0.25],
    kickPattern: 'one drop',
    snarePattern: 'on beat 3',
    hihatDensity: 'sparse',
    characteristics: ['laid-back', 'one-drop', 'offbeat'],
  },
  latin: {
    tempoRange: [90, 130],
    swingRange: [0, 0.15],
    kickPattern: 'clave-based',
    snarePattern: 'timbale patterns',
    hihatDensity: 'dense',
    characteristics: ['clave', 'polyrhythmic', 'percussion-heavy'],
  },
  afrobeat: {
    tempoRange: [100, 130],
    swingRange: [0.1, 0.2],
    kickPattern: 'polyrhythmic',
    snarePattern: 'multiple layers',
    hihatDensity: 'dense',
    characteristics: ['polyrhythmic', 'layered', 'driving'],
  },
  bossa_nova: {
    tempoRange: [120, 150],
    swingRange: [0.1, 0.2],
    kickPattern: 'subtle',
    snarePattern: 'brush, cross-stick',
    hihatDensity: 'sparse',
    characteristics: ['subtle', 'elegant', 'syncopated'],
  },
  industrial: {
    tempoRange: [100, 140],
    swingRange: [0, 0.05],
    kickPattern: 'aggressive',
    snarePattern: 'mechanical',
    hihatDensity: 'normal',
    characteristics: ['harsh', 'mechanical', 'aggressive'],
  },
  noise: {
    tempoRange: [40, 200],
    swingRange: [0, 0.5],
    kickPattern: 'chaotic',
    snarePattern: 'chaotic',
    hihatDensity: 'sparse',
    characteristics: ['experimental', 'harsh', 'unpredictable'],
  },
  glitch: {
    tempoRange: [100, 160],
    swingRange: [0, 0.3],
    kickPattern: 'fragmented',
    snarePattern: 'glitchy',
    hihatDensity: 'sparse',
    characteristics: ['stuttering', 'fragmented', 'digital'],
  },
  polyrhythmic: {
    tempoRange: [80, 140],
    swingRange: [0, 0.15],
    kickPattern: 'interlocking',
    snarePattern: 'interlocking',
    hihatDensity: 'dense',
    characteristics: ['complex', 'layered', 'african-influenced'],
  },
};
