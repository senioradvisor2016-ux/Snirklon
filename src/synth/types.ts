/**
 * Snirklon - Synth Sequencer Types
 * Avancerade typer för synthesizer-sekvensering
 */

// ============================================
// Oscillator & Waveforms
// ============================================

export type WaveformType = 
  | 'sine' 
  | 'square' 
  | 'sawtooth' 
  | 'triangle' 
  | 'pulse'
  | 'noise_white'
  | 'noise_pink'
  | 'noise_brown'
  | 'wavetable'
  | 'fm';

export interface Oscillator {
  id: string;
  waveform: WaveformType;
  detune: number;           // Cents (-100 to 100)
  octave: number;           // -2 to +2
  semitone: number;         // -12 to +12
  fine: number;             // Fine tuning (-100 to 100 cents)
  pulseWidth?: number;      // För pulse wave (0-1)
  wavetablePosition?: number; // För wavetable (0-1)
  level: number;            // 0-1
  pan: number;              // -1 to 1
}

export interface FMOperator extends Oscillator {
  ratio: number;            // Frequency ratio
  modulationIndex: number;  // FM depth
  feedback: number;         // Self-modulation (0-1)
}

// ============================================
// Filter
// ============================================

export type FilterType = 
  | 'lowpass' 
  | 'highpass' 
  | 'bandpass' 
  | 'notch'
  | 'lowshelf'
  | 'highshelf'
  | 'peaking'
  | 'allpass'
  | 'comb'
  | 'formant';

export interface Filter {
  type: FilterType;
  cutoff: number;           // Hz (20-20000)
  resonance: number;        // Q factor (0-40)
  drive: number;            // Saturation (0-1)
  keyTracking: number;      // How much pitch affects cutoff (0-1)
  envelopeAmount: number;   // Filter envelope depth (-1 to 1)
}

// ============================================
// Envelopes
// ============================================

export interface ADSREnvelope {
  attack: number;           // Seconds (0-10)
  decay: number;            // Seconds (0-10)
  sustain: number;          // Level (0-1)
  release: number;          // Seconds (0-10)
  attackCurve?: number;     // -1 to 1 (exponential to logarithmic)
  decayCurve?: number;      
  releaseCurve?: number;    
}

export interface MultiStageEnvelope {
  stages: EnvelopeStage[];
  loop?: {
    start: number;          // Stage index
    end: number;            // Stage index
    count: number;          // -1 for infinite
  };
}

export interface EnvelopeStage {
  time: number;             // Seconds
  level: number;            // 0-1
  curve: number;            // -1 to 1
}

// ============================================
// LFO (Low Frequency Oscillator)
// ============================================

export type LFOShape = 
  | 'sine' 
  | 'square' 
  | 'triangle' 
  | 'sawtooth' 
  | 'random' 
  | 'sample_hold'
  | 'custom';

export type LFOSync = 'free' | 'tempo' | 'key';

export interface LFO {
  id: string;
  shape: LFOShape;
  rate: number;             // Hz or beat division
  sync: LFOSync;
  tempoDivision?: string;   // "1/4", "1/8", "1/16", etc.
  depth: number;            // 0-1
  phase: number;            // 0-360 degrees
  delay: number;            // Fade-in time in seconds
  destinations: LFODestination[];
}

export interface LFODestination {
  target: ModulationTarget;
  amount: number;           // -1 to 1
}

export type ModulationTarget = 
  | 'pitch'
  | 'filter_cutoff'
  | 'filter_resonance'
  | 'amplitude'
  | 'pan'
  | 'osc1_level'
  | 'osc2_level'
  | 'pulse_width'
  | 'wavetable_position'
  | 'fm_index'
  | 'delay_time'
  | 'delay_feedback'
  | 'reverb_mix';

// ============================================
// Modulation Matrix
// ============================================

export interface ModulationRoute {
  id: string;
  source: ModulationSource;
  destination: ModulationTarget;
  amount: number;           // -1 to 1
  curve?: number;           // Response curve
}

export type ModulationSource = 
  | 'env_amp'
  | 'env_filter'
  | 'env_mod'
  | 'lfo1'
  | 'lfo2'
  | 'lfo3'
  | 'velocity'
  | 'aftertouch'
  | 'mod_wheel'
  | 'pitch_bend'
  | 'key_tracking'
  | 'random'
  | 'sequencer';

// ============================================
// Effects
// ============================================

export interface EffectChain {
  effects: Effect[];
  bypass: boolean;
}

export type EffectType = 
  | 'delay'
  | 'reverb'
  | 'chorus'
  | 'flanger'
  | 'phaser'
  | 'distortion'
  | 'bitcrusher'
  | 'compressor'
  | 'eq'
  | 'filter'
  | 'tremolo'
  | 'vibrato'
  | 'ring_mod'
  | 'vocoder';

export interface Effect {
  type: EffectType;
  bypass: boolean;
  mix: number;              // Dry/wet (0-1)
  params: Record<string, number>;
}

export interface DelayParams {
  time: number;             // Seconds or beat division
  feedback: number;         // 0-1
  sync: boolean;
  pingPong: boolean;
  lowCut: number;           // Hz
  highCut: number;          // Hz
}

export interface ReverbParams {
  size: number;             // Room size (0-1)
  decay: number;            // Seconds
  damping: number;          // High freq decay (0-1)
  predelay: number;         // Seconds
  diffusion: number;        // 0-1
}

// ============================================
// Synth Patch / Preset
// ============================================

export interface SynthPatch {
  id: string;
  name: string;
  category: SynthCategory;
  tags: string[];
  
  // Sound generation
  oscillators: Oscillator[];
  noise?: {
    type: 'white' | 'pink' | 'brown';
    level: number;
  };
  
  // Shaping
  filter: Filter;
  filter2?: Filter;
  
  // Envelopes
  ampEnvelope: ADSREnvelope;
  filterEnvelope: ADSREnvelope;
  modEnvelope?: ADSREnvelope | MultiStageEnvelope;
  
  // Modulation
  lfos: LFO[];
  modMatrix: ModulationRoute[];
  
  // Effects
  effects: EffectChain;
  
  // Voice settings
  voiceMode: VoiceMode;
  portamento: number;       // Glide time in seconds
  pitchBendRange: number;   // Semitones
  
  // Master
  volume: number;           // 0-1
  pan: number;              // -1 to 1
}

export type SynthCategory = 
  | 'lead'
  | 'bass'
  | 'pad'
  | 'pluck'
  | 'keys'
  | 'strings'
  | 'brass'
  | 'arp'
  | 'fx'
  | 'drum'
  | 'experimental';

export type VoiceMode = 
  | { type: 'poly'; voices: number }
  | { type: 'mono'; legato: boolean; retrigger: boolean }
  | { type: 'unison'; voices: number; detune: number; spread: number };

// ============================================
// Synth Sequence Note (utökad från bas-Note)
// ============================================

export interface SynthNote {
  pitch: number;            // MIDI note (0-127)
  velocity: number;         // 0-127
  start: number;            // Position in beats
  duration: number;         // Length in beats
  
  // Expressiva parametrar
  slide?: boolean;          // Portamento till nästa not
  accent?: boolean;         // Extra velocity/filter boost
  
  // Per-note modulation
  filterOffset?: number;    // Cutoff offset (-1 to 1)
  pitchBend?: number;       // Pitch offset in semitones
  pan?: number;             // Override pan (-1 to 1)
  
  // Automation curves
  automation?: NoteAutomation[];
  
  // Probability
  probability?: number;     // 0-1, chance of playing
  
  // Humanize
  timingOffset?: number;    // Milliseconds
  velocityOffset?: number;  // -127 to 127
}

export interface NoteAutomation {
  parameter: ModulationTarget;
  curve: AutomationPoint[];
}

export interface AutomationPoint {
  time: number;             // 0-1 (relative to note duration)
  value: number;            // Depends on parameter
  curve?: number;           // Interpolation curve
}

// ============================================
// Synth Sequence
// ============================================

export interface SynthSequence {
  id: string;
  name: string;
  type: 'synth';
  
  // Timing
  length: number;           // Beats
  timeSignature: [number, number];
  swing?: number;           // 0-1
  
  // Notes
  notes: SynthNote[];
  
  // Sound
  patch: SynthPatch | string; // Inline or reference ID
  
  // Sequence-level automation
  automation: SequenceAutomation[];
  
  // Pattern settings
  transpose: number;        // Semitones
  octave: number;           // Octave shift
  
  // Metadata
  metadata: {
    generatedBy: 'claude' | 'user' | 'evolved';
    prompt?: string;
    timestamp: number;
    tags?: string[];
  };
}

export interface SequenceAutomation {
  parameter: string;        // Can be synth param or effect param
  points: AutomationPoint[];
  loop?: boolean;
}

// ============================================
// Arpeggiator
// ============================================

export type ArpMode = 
  | 'up'
  | 'down'
  | 'up_down'
  | 'down_up'
  | 'random'
  | 'order'
  | 'chord'
  | 'pattern';

export interface Arpeggiator {
  enabled: boolean;
  mode: ArpMode;
  rate: string;             // "1/4", "1/8", "1/16", etc.
  octaveRange: number;      // 1-4
  gateLength: number;       // 0-1 (relative to step)
  swing: number;            // 0-1
  pattern?: number[];       // Custom step pattern
  velocityPattern?: number[]; // Per-step velocity
  probability?: number[];   // Per-step probability
}

// ============================================
// Parameter Lock (per-step automation à la Elektron)
// ============================================

export interface ParameterLock {
  step: number;
  parameter: string;
  value: number;
}

export interface StepSequencerData {
  steps: number;            // Total steps (16, 32, 64)
  triggerPattern: boolean[]; // Which steps trigger
  parameterLocks: ParameterLock[];
  accentPattern: boolean[];
  slidePattern: boolean[];
  probabilityPattern: number[];
}
