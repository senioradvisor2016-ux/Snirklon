/**
 * Snirklon - Synth Presets
 * Fördefinierade synth patches och ljud
 */

import { SynthPatch, ADSREnvelope, Filter, Oscillator, LFO, VoiceMode } from './types';

// ============================================
// Hjälpfunktioner för att skapa presets
// ============================================

const defaultAmpEnv: ADSREnvelope = {
  attack: 0.01,
  decay: 0.3,
  sustain: 0.7,
  release: 0.3,
};

const defaultFilterEnv: ADSREnvelope = {
  attack: 0.01,
  decay: 0.5,
  sustain: 0.3,
  release: 0.5,
};

const defaultFilter: Filter = {
  type: 'lowpass',
  cutoff: 5000,
  resonance: 1,
  drive: 0,
  keyTracking: 0.5,
  envelopeAmount: 0.3,
};

// ============================================
// Bass Presets
// ============================================

export const BASS_PRESETS: Record<string, SynthPatch> = {
  sub_bass: {
    id: 'sub_bass',
    name: 'Sub Bass',
    category: 'bass',
    tags: ['sub', 'deep', 'clean'],
    oscillators: [{
      id: 'osc1',
      waveform: 'sine',
      detune: 0,
      octave: -1,
      semitone: 0,
      fine: 0,
      level: 1,
      pan: 0,
    }],
    filter: { ...defaultFilter, cutoff: 200, resonance: 0 },
    ampEnvelope: { attack: 0.005, decay: 0.1, sustain: 1, release: 0.1 },
    filterEnvelope: defaultFilterEnv,
    lfos: [],
    modMatrix: [],
    effects: { effects: [], bypass: false },
    voiceMode: { type: 'mono', legato: true, retrigger: false },
    portamento: 0.05,
    pitchBendRange: 2,
    volume: 0.8,
    pan: 0,
  },

  acid_bass: {
    id: 'acid_bass',
    name: 'Acid Bass',
    category: 'bass',
    tags: ['acid', '303', 'squelchy'],
    oscillators: [{
      id: 'osc1',
      waveform: 'sawtooth',
      detune: 0,
      octave: -1,
      semitone: 0,
      fine: 0,
      level: 1,
      pan: 0,
    }],
    filter: { 
      type: 'lowpass', 
      cutoff: 400, 
      resonance: 15, 
      drive: 0.6,
      keyTracking: 0.3,
      envelopeAmount: 0.8,
    },
    ampEnvelope: { attack: 0.001, decay: 0.2, sustain: 0, release: 0.05 },
    filterEnvelope: { attack: 0.001, decay: 0.15, sustain: 0, release: 0.1 },
    lfos: [],
    modMatrix: [],
    effects: { 
      effects: [{
        type: 'distortion',
        bypass: false,
        mix: 0.3,
        params: { drive: 0.4, tone: 0.6 }
      }], 
      bypass: false 
    },
    voiceMode: { type: 'mono', legato: true, retrigger: true },
    portamento: 0.03,
    pitchBendRange: 12,
    volume: 0.7,
    pan: 0,
  },

  reese_bass: {
    id: 'reese_bass',
    name: 'Reese Bass',
    category: 'bass',
    tags: ['reese', 'dnb', 'detuned'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sawtooth',
        detune: -15,
        octave: -1,
        semitone: 0,
        fine: 0,
        level: 0.7,
        pan: -0.3,
      },
      {
        id: 'osc2',
        waveform: 'sawtooth',
        detune: 15,
        octave: -1,
        semitone: 0,
        fine: 0,
        level: 0.7,
        pan: 0.3,
      },
    ],
    filter: { 
      type: 'lowpass', 
      cutoff: 800, 
      resonance: 2, 
      drive: 0.3,
      keyTracking: 0.5,
      envelopeAmount: 0.4,
    },
    ampEnvelope: { attack: 0.01, decay: 0.5, sustain: 0.8, release: 0.3 },
    filterEnvelope: { attack: 0.01, decay: 0.8, sustain: 0.2, release: 0.5 },
    lfos: [{
      id: 'lfo1',
      shape: 'sine',
      rate: 0.5,
      sync: 'free',
      depth: 0.3,
      phase: 0,
      delay: 0,
      destinations: [{ target: 'filter_cutoff', amount: 0.2 }]
    }],
    modMatrix: [],
    effects: { effects: [], bypass: false },
    voiceMode: { type: 'mono', legato: true, retrigger: false },
    portamento: 0.1,
    pitchBendRange: 2,
    volume: 0.75,
    pan: 0,
  },
};

// ============================================
// Lead Presets
// ============================================

export const LEAD_PRESETS: Record<string, SynthPatch> = {
  classic_lead: {
    id: 'classic_lead',
    name: 'Classic Lead',
    category: 'lead',
    tags: ['classic', 'analog', 'warm'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sawtooth',
        detune: -7,
        octave: 0,
        semitone: 0,
        fine: 0,
        level: 0.7,
        pan: -0.2,
      },
      {
        id: 'osc2',
        waveform: 'pulse',
        detune: 7,
        octave: 0,
        semitone: 0,
        fine: 0,
        pulseWidth: 0.5,
        level: 0.5,
        pan: 0.2,
      },
    ],
    filter: { 
      type: 'lowpass', 
      cutoff: 3000, 
      resonance: 3, 
      drive: 0.1,
      keyTracking: 0.7,
      envelopeAmount: 0.5,
    },
    ampEnvelope: { attack: 0.01, decay: 0.3, sustain: 0.7, release: 0.2 },
    filterEnvelope: { attack: 0.05, decay: 0.4, sustain: 0.3, release: 0.3 },
    lfos: [{
      id: 'lfo1',
      shape: 'triangle',
      rate: 5.5,
      sync: 'free',
      depth: 0.1,
      phase: 0,
      delay: 0.5,
      destinations: [{ target: 'pitch', amount: 0.02 }]
    }],
    modMatrix: [],
    effects: { 
      effects: [{
        type: 'delay',
        bypass: false,
        mix: 0.2,
        params: { time: 0.375, feedback: 0.3, pingPong: 1 }
      }], 
      bypass: false 
    },
    voiceMode: { type: 'mono', legato: true, retrigger: false },
    portamento: 0.08,
    pitchBendRange: 2,
    volume: 0.7,
    pan: 0,
  },

  screaming_lead: {
    id: 'screaming_lead',
    name: 'Screaming Lead',
    category: 'lead',
    tags: ['aggressive', 'distorted', 'high'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sawtooth',
        detune: 0,
        octave: 0,
        semitone: 0,
        fine: 0,
        level: 1,
        pan: 0,
      },
    ],
    filter: { 
      type: 'lowpass', 
      cutoff: 8000, 
      resonance: 8, 
      drive: 0.7,
      keyTracking: 1,
      envelopeAmount: 0.6,
    },
    ampEnvelope: { attack: 0.001, decay: 0.1, sustain: 0.9, release: 0.1 },
    filterEnvelope: { attack: 0.001, decay: 0.3, sustain: 0.4, release: 0.2 },
    lfos: [],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'distortion', bypass: false, mix: 0.5, params: { drive: 0.7 } },
        { type: 'delay', bypass: false, mix: 0.15, params: { time: 0.125, feedback: 0.2 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'mono', legato: false, retrigger: true },
    portamento: 0,
    pitchBendRange: 12,
    volume: 0.6,
    pan: 0,
  },
};

// ============================================
// Pad Presets
// ============================================

export const PAD_PRESETS: Record<string, SynthPatch> = {
  warm_pad: {
    id: 'warm_pad',
    name: 'Warm Pad',
    category: 'pad',
    tags: ['warm', 'soft', 'evolving'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sawtooth',
        detune: -8,
        octave: 0,
        semitone: 0,
        fine: 0,
        level: 0.5,
        pan: -0.4,
      },
      {
        id: 'osc2',
        waveform: 'sawtooth',
        detune: 8,
        octave: 0,
        semitone: 0,
        fine: 0,
        level: 0.5,
        pan: 0.4,
      },
      {
        id: 'osc3',
        waveform: 'triangle',
        detune: 0,
        octave: -1,
        semitone: 0,
        fine: 0,
        level: 0.3,
        pan: 0,
      },
    ],
    filter: { 
      type: 'lowpass', 
      cutoff: 2000, 
      resonance: 1, 
      drive: 0,
      keyTracking: 0.3,
      envelopeAmount: 0.3,
    },
    ampEnvelope: { attack: 0.8, decay: 1, sustain: 0.8, release: 1.5 },
    filterEnvelope: { attack: 1.2, decay: 2, sustain: 0.5, release: 2 },
    lfos: [
      {
        id: 'lfo1',
        shape: 'sine',
        rate: 0.2,
        sync: 'free',
        depth: 0.3,
        phase: 0,
        delay: 0,
        destinations: [{ target: 'filter_cutoff', amount: 0.15 }]
      },
      {
        id: 'lfo2',
        shape: 'triangle',
        rate: 0.08,
        sync: 'free',
        depth: 0.5,
        phase: 90,
        delay: 0,
        destinations: [{ target: 'pan', amount: 0.3 }]
      },
    ],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'chorus', bypass: false, mix: 0.3, params: { rate: 0.5, depth: 0.5 } },
        { type: 'reverb', bypass: false, mix: 0.4, params: { size: 0.7, decay: 3, damping: 0.4 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'poly', voices: 8 },
    portamento: 0,
    pitchBendRange: 2,
    volume: 0.6,
    pan: 0,
  },

  dark_pad: {
    id: 'dark_pad',
    name: 'Dark Pad',
    category: 'pad',
    tags: ['dark', 'cinematic', 'brooding'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sawtooth',
        detune: -10,
        octave: -1,
        semitone: 0,
        fine: 0,
        level: 0.6,
        pan: -0.3,
      },
      {
        id: 'osc2',
        waveform: 'square',
        detune: 10,
        octave: -1,
        semitone: 0,
        fine: 0,
        level: 0.4,
        pan: 0.3,
      },
    ],
    noise: { type: 'brown', level: 0.1 },
    filter: { 
      type: 'lowpass', 
      cutoff: 800, 
      resonance: 2, 
      drive: 0.2,
      keyTracking: 0.2,
      envelopeAmount: 0.2,
    },
    ampEnvelope: { attack: 2, decay: 2, sustain: 0.6, release: 3 },
    filterEnvelope: { attack: 3, decay: 4, sustain: 0.3, release: 4 },
    lfos: [{
      id: 'lfo1',
      shape: 'sine',
      rate: 0.05,
      sync: 'free',
      depth: 0.4,
      phase: 0,
      delay: 2,
      destinations: [
        { target: 'filter_cutoff', amount: 0.2 },
        { target: 'amplitude', amount: 0.1 },
      ]
    }],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'reverb', bypass: false, mix: 0.6, params: { size: 0.9, decay: 6, damping: 0.7 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'poly', voices: 6 },
    portamento: 0.2,
    pitchBendRange: 2,
    volume: 0.5,
    pan: 0,
  },
};

// ============================================
// Arpeggio / Pluck Presets
// ============================================

export const PLUCK_PRESETS: Record<string, SynthPatch> = {
  digital_pluck: {
    id: 'digital_pluck',
    name: 'Digital Pluck',
    category: 'pluck',
    tags: ['pluck', 'digital', 'bright'],
    oscillators: [{
      id: 'osc1',
      waveform: 'sawtooth',
      detune: 0,
      octave: 0,
      semitone: 0,
      fine: 0,
      level: 1,
      pan: 0,
    }],
    filter: { 
      type: 'lowpass', 
      cutoff: 8000, 
      resonance: 2, 
      drive: 0,
      keyTracking: 0.8,
      envelopeAmount: 0.7,
    },
    ampEnvelope: { attack: 0.001, decay: 0.4, sustain: 0, release: 0.3 },
    filterEnvelope: { attack: 0.001, decay: 0.2, sustain: 0, release: 0.2 },
    lfos: [],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'delay', bypass: false, mix: 0.3, params: { time: 0.375, feedback: 0.4, pingPong: 1 } },
        { type: 'reverb', bypass: false, mix: 0.2, params: { size: 0.5, decay: 1.5 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'poly', voices: 16 },
    portamento: 0,
    pitchBendRange: 2,
    volume: 0.7,
    pan: 0,
  },

  bell_tone: {
    id: 'bell_tone',
    name: 'Bell Tone',
    category: 'pluck',
    tags: ['bell', 'fm', 'metallic'],
    oscillators: [
      {
        id: 'osc1',
        waveform: 'sine',
        detune: 0,
        octave: 0,
        semitone: 0,
        fine: 0,
        level: 0.6,
        pan: 0,
      },
      {
        id: 'osc2',
        waveform: 'sine',
        detune: 0,
        octave: 2,
        semitone: 7,  // Fifth above + 2 octaves
        fine: 0,
        level: 0.3,
        pan: 0,
      },
    ],
    filter: { 
      type: 'lowpass', 
      cutoff: 12000, 
      resonance: 0.5, 
      drive: 0,
      keyTracking: 0.5,
      envelopeAmount: 0.2,
    },
    ampEnvelope: { attack: 0.001, decay: 2, sustain: 0, release: 2 },
    filterEnvelope: { attack: 0.001, decay: 1, sustain: 0.2, release: 1 },
    lfos: [],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'reverb', bypass: false, mix: 0.4, params: { size: 0.8, decay: 4, damping: 0.3 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'poly', voices: 12 },
    portamento: 0,
    pitchBendRange: 2,
    volume: 0.6,
    pan: 0,
  },
};

// ============================================
// FX / Experimental Presets
// ============================================

export const FX_PRESETS: Record<string, SynthPatch> = {
  noise_sweep: {
    id: 'noise_sweep',
    name: 'Noise Sweep',
    category: 'fx',
    tags: ['noise', 'riser', 'transition'],
    oscillators: [],
    noise: { type: 'white', level: 1 },
    filter: { 
      type: 'bandpass', 
      cutoff: 1000, 
      resonance: 8, 
      drive: 0.3,
      keyTracking: 0,
      envelopeAmount: 0.9,
    },
    ampEnvelope: { attack: 2, decay: 0.5, sustain: 0.8, release: 1 },
    filterEnvelope: { attack: 4, decay: 0.1, sustain: 1, release: 0.5 },
    lfos: [],
    modMatrix: [],
    effects: { 
      effects: [
        { type: 'reverb', bypass: false, mix: 0.5, params: { size: 0.9, decay: 5 } },
      ], 
      bypass: false 
    },
    voiceMode: { type: 'mono', legato: true, retrigger: false },
    portamento: 0,
    pitchBendRange: 0,
    volume: 0.5,
    pan: 0,
  },
};

// ============================================
// Alla presets samlade
// ============================================

export const ALL_SYNTH_PRESETS: Record<string, SynthPatch> = {
  ...BASS_PRESETS,
  ...LEAD_PRESETS,
  ...PAD_PRESETS,
  ...PLUCK_PRESETS,
  ...FX_PRESETS,
};

export function getPresetsByCategory(category: string): SynthPatch[] {
  return Object.values(ALL_SYNTH_PRESETS).filter(p => p.category === category);
}

export function getPresetsByTag(tag: string): SynthPatch[] {
  return Object.values(ALL_SYNTH_PRESETS).filter(p => p.tags.includes(tag));
}
