/**
 * Snirklon - Drum Sequencer Types
 * Avancerade typer för trumsekvensering
 */

// ============================================
// Drum Sounds / Instruments
// ============================================

export type DrumInstrument = 
  // Kicks
  | 'kick'
  | 'kick_acoustic'
  | 'kick_electronic'
  | 'kick_808'
  | 'kick_909'
  | 'kick_sub'
  // Snares
  | 'snare'
  | 'snare_acoustic'
  | 'snare_electronic'
  | 'snare_808'
  | 'snare_909'
  | 'snare_clap'
  | 'rimshot'
  // Hi-hats
  | 'hihat_closed'
  | 'hihat_open'
  | 'hihat_pedal'
  | 'hihat_808'
  | 'hihat_909'
  // Cymbals
  | 'crash'
  | 'ride'
  | 'ride_bell'
  | 'china'
  | 'splash'
  // Toms
  | 'tom_high'
  | 'tom_mid'
  | 'tom_low'
  | 'tom_floor'
  // Percussion
  | 'clap'
  | 'snap'
  | 'shaker'
  | 'tambourine'
  | 'cowbell'
  | 'conga_high'
  | 'conga_low'
  | 'bongo_high'
  | 'bongo_low'
  | 'timbale'
  | 'woodblock'
  | 'triangle'
  | 'cabasa'
  | 'guiro'
  | 'vibraslap'
  | 'cuica'
  // Electronic
  | 'perc_blip'
  | 'perc_noise'
  | 'perc_click'
  | 'perc_zap'
  | 'perc_fm';

// ============================================
// Drum Sound Parameters
// ============================================

export interface DrumSoundParams {
  // Pitch
  pitch: number;            // Tuning (-24 to +24 semitones)
  pitchEnvAmount: number;   // Pitch envelope depth
  pitchEnvDecay: number;    // Pitch envelope decay time
  
  // Tone
  tone: number;             // High frequency content (0-1)
  decay: number;            // Overall decay time
  attack: number;           // Attack snap (0-1)
  
  // Body
  body: number;             // Low frequency content (0-1)
  
  // Character
  drive: number;            // Distortion/saturation (0-1)
  noise: number;            // Noise amount (0-1)
  noiseDecay: number;       // Noise decay time
  
  // Mix
  level: number;            // 0-1
  pan: number;              // -1 to 1
  
  // Compression
  compression: number;      // 0-1
  
  // Sample
  sampleStart?: number;     // Sample start point (0-1)
  sampleEnd?: number;       // Sample end point (0-1)
  reverse?: boolean;
}

// ============================================
// Drum Kit
// ============================================

export interface DrumKit {
  id: string;
  name: string;
  category: DrumKitCategory;
  
  // Sound slots
  sounds: DrumSound[];
  
  // Global settings
  globalSettings: {
    volume: number;
    swing: number;
    velocityCurve: VelocityCurve;
  };
  
  // Effects per sound or global
  effectsSends: DrumEffectsSends;
}

export type DrumKitCategory = 
  | 'acoustic'
  | 'electronic'
  | '808'
  | '909'
  | 'hybrid'
  | 'lo-fi'
  | 'industrial'
  | 'world'
  | 'experimental';

export interface DrumSound {
  id: string;
  instrument: DrumInstrument;
  name: string;
  midiNote: number;         // Trigger note
  params: DrumSoundParams;
  chokeGroup?: number;      // Sounds that mute each other
  
  // Send levels
  sendA: number;            // e.g., reverb send
  sendB: number;            // e.g., delay send
}

export type VelocityCurve = 'linear' | 'soft' | 'hard' | 'fixed';

export interface DrumEffectsSends {
  sendA: {
    type: 'reverb' | 'delay';
    params: Record<string, number>;
  };
  sendB: {
    type: 'reverb' | 'delay';
    params: Record<string, number>;
  };
  masterCompressor?: {
    threshold: number;
    ratio: number;
    attack: number;
    release: number;
    makeupGain: number;
  };
}

// ============================================
// Drum Pattern / Step
// ============================================

export interface DrumStep {
  active: boolean;          // Is this step triggered?
  velocity: number;         // 0-127
  
  // Micro-timing
  nudge: number;            // Timing offset (-50 to +50 ms or %)
  
  // Probability
  probability: number;      // 0-1, chance of playing
  
  // Variations
  fillProbability?: number; // Extra probability during fills
  
  // Per-step sound modifications
  paramLocks?: Partial<DrumSoundParams>;
  
  // Flams & rolls
  flam?: {
    enabled: boolean;
    time: number;           // Time before main hit (ms)
    velocity: number;       // Flam hit velocity ratio (0-1)
  };
  
  roll?: {
    enabled: boolean;
    divisions: number;      // 2, 3, 4, etc. hits per step
    velocityRamp: number;   // -1 to 1 (crescendo/decrescendo)
  };
  
  // Retrigger
  retrigger?: {
    count: number;
    rate: number;           // Retrigger speed
    decay: number;          // Velocity decay per retrigger
  };
}

export interface DrumTrack {
  id: string;
  soundId: string;          // Reference to DrumSound
  name: string;
  
  // Pattern
  steps: DrumStep[];
  length: number;           // Steps (can differ per track for polymetry!)
  
  // Track settings
  mute: boolean;
  solo: boolean;
  volume: number;
  pan: number;
  
  // Per-track swing override
  swing?: number;
  
  // Fill mode
  fillPattern?: DrumStep[]; // Alternative pattern for fills
}

// ============================================
// Drum Sequence
// ============================================

export interface DrumSequence {
  id: string;
  name: string;
  type: 'drums';
  
  // Timing
  length: number;           // Total length in beats
  stepsPerBeat: number;     // Resolution (4 = 16th notes)
  timeSignature: [number, number];
  
  // Global swing
  swing: number;            // 0-1
  swingResolution: '8th' | '16th';
  
  // Tracks
  tracks: DrumTrack[];
  
  // Kit reference
  kit: DrumKit | string;
  
  // Pattern variations
  variations?: DrumVariation[];
  currentVariation: number;
  
  // Fill settings
  fillMode: FillMode;
  
  // Metadata
  metadata: {
    generatedBy: 'claude' | 'user' | 'evolved';
    prompt?: string;
    timestamp: number;
    style?: DrumStyle;
    tags?: string[];
  };
}

export interface DrumVariation {
  id: string;
  name: string;
  tracks: Partial<DrumTrack>[];  // Override specific track patterns
}

export type FillMode = 
  | { type: 'off' }
  | { type: 'manual'; pattern: number[] }  // Specific bars
  | { type: 'interval'; every: number }    // Every N bars
  | { type: 'probability'; chance: number };

// ============================================
// Drum Styles / Genres
// ============================================

export type DrumStyle = 
  // Electronic
  | 'techno'
  | 'house'
  | 'deep_house'
  | 'tech_house'
  | 'minimal'
  | 'trance'
  | 'drum_and_bass'
  | 'jungle'
  | 'dubstep'
  | 'garage'
  | 'breakbeat'
  | 'idm'
  | 'ambient'
  // Acoustic/Traditional
  | 'rock'
  | 'pop'
  | 'funk'
  | 'jazz'
  | 'hip_hop'
  | 'trap'
  | 'r&b'
  | 'reggae'
  | 'latin'
  | 'afrobeat'
  | 'bossa_nova'
  // Experimental
  | 'industrial'
  | 'noise'
  | 'glitch'
  | 'polyrhythmic';

// ============================================
// Euclidean Rhythm Generator
// ============================================

export interface EuclideanConfig {
  hits: number;             // Number of active steps
  steps: number;            // Total steps
  rotation: number;         // Pattern rotation (0 to steps-1)
  accent?: {
    hits: number;           // Accented hits
    steps: number;          // Same as main or different
    rotation: number;
  };
}

// ============================================
// Humanization
// ============================================

export interface HumanizeSettings {
  timing: number;           // Random timing variation (0-1)
  velocity: number;         // Random velocity variation (0-1)
  
  // Advanced
  groove?: GrooveTemplate;
  feel?: 'tight' | 'loose' | 'drunk' | 'robotic';
}

export interface GrooveTemplate {
  name: string;
  timingOffsets: number[];  // Per-step timing offsets
  velocityOffsets: number[]; // Per-step velocity offsets
}

// ============================================
// Polyrhythm / Polymeter
// ============================================

export interface PolyrhythmConfig {
  // Different track lengths create polymeters
  trackLengths: Map<string, number>;
  
  // Or explicit polyrhythm
  baseRhythm: number;       // e.g., 4
  overlayRhythm: number;    // e.g., 3 (creates 4:3)
}
