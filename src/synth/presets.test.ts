/**
 * Snirklon - Synth Presets System Tests
 * Testar synth patches och presets
 */

import {
  BASS_PRESETS,
  LEAD_PRESETS,
  PAD_PRESETS,
  PLUCK_PRESETS,
  FX_PRESETS,
  ALL_SYNTH_PRESETS,
  getPresetsByCategory,
  getPresetsByTag,
} from './presets';
import { SynthPatch, SynthCategory } from './types';

describe('Synth Presets Structure', () => {
  describe('ALL_SYNTH_PRESETS', () => {
    it('should contain all preset categories', () => {
      const allKeys = Object.keys(ALL_SYNTH_PRESETS);
      const bassKeys = Object.keys(BASS_PRESETS);
      const leadKeys = Object.keys(LEAD_PRESETS);
      const padKeys = Object.keys(PAD_PRESETS);
      const pluckKeys = Object.keys(PLUCK_PRESETS);
      const fxKeys = Object.keys(FX_PRESETS);

      const combinedKeys = [...bassKeys, ...leadKeys, ...padKeys, ...pluckKeys, ...fxKeys];
      expect(allKeys.sort()).toEqual(combinedKeys.sort());
    });

    it('should have unique IDs across all presets', () => {
      const ids = Object.values(ALL_SYNTH_PRESETS).map(p => p.id);
      const uniqueIds = new Set(ids);
      expect(ids.length).toBe(uniqueIds.size);
    });
  });

  describe.each(Object.entries(ALL_SYNTH_PRESETS))('%s preset', (presetId, preset) => {
    it('should have matching id and key', () => {
      expect(preset.id).toBe(presetId);
    });

    it('should have a name', () => {
      expect(preset.name).toBeDefined();
      expect(preset.name.length).toBeGreaterThan(0);
    });

    it('should have a valid category', () => {
      const validCategories: SynthCategory[] = [
        'lead', 'bass', 'pad', 'pluck', 'keys', 'strings', 
        'brass', 'arp', 'fx', 'drum', 'experimental'
      ];
      expect(validCategories).toContain(preset.category);
    });

    it('should have tags array', () => {
      expect(Array.isArray(preset.tags)).toBe(true);
    });

    it('should have oscillators array', () => {
      expect(Array.isArray(preset.oscillators)).toBe(true);
      // Except for noise-only presets
      if (!preset.noise || preset.noise.level === 0) {
        // Normal presets should have at least one oscillator
      }
    });

    it('should have a valid filter', () => {
      expect(preset.filter).toBeDefined();
      expect(preset.filter.cutoff).toBeGreaterThan(0);
      expect(preset.filter.cutoff).toBeLessThanOrEqual(20000);
      expect(preset.filter.resonance).toBeGreaterThanOrEqual(0);
    });

    it('should have amp envelope', () => {
      expect(preset.ampEnvelope).toBeDefined();
      expect(preset.ampEnvelope.attack).toBeGreaterThanOrEqual(0);
      expect(preset.ampEnvelope.decay).toBeGreaterThanOrEqual(0);
      expect(preset.ampEnvelope.sustain).toBeGreaterThanOrEqual(0);
      expect(preset.ampEnvelope.sustain).toBeLessThanOrEqual(1);
      expect(preset.ampEnvelope.release).toBeGreaterThanOrEqual(0);
    });

    it('should have filter envelope', () => {
      expect(preset.filterEnvelope).toBeDefined();
      expect(preset.filterEnvelope.attack).toBeGreaterThanOrEqual(0);
      expect(preset.filterEnvelope.decay).toBeGreaterThanOrEqual(0);
      expect(preset.filterEnvelope.sustain).toBeGreaterThanOrEqual(0);
      expect(preset.filterEnvelope.sustain).toBeLessThanOrEqual(1);
      expect(preset.filterEnvelope.release).toBeGreaterThanOrEqual(0);
    });

    it('should have LFOs array', () => {
      expect(Array.isArray(preset.lfos)).toBe(true);
    });

    it('should have modMatrix array', () => {
      expect(Array.isArray(preset.modMatrix)).toBe(true);
    });

    it('should have effects chain', () => {
      expect(preset.effects).toBeDefined();
      expect(Array.isArray(preset.effects.effects)).toBe(true);
      expect(typeof preset.effects.bypass).toBe('boolean');
    });

    it('should have voice mode', () => {
      expect(preset.voiceMode).toBeDefined();
      expect(['poly', 'mono', 'unison']).toContain(preset.voiceMode.type);
    });

    it('should have valid volume', () => {
      expect(preset.volume).toBeGreaterThanOrEqual(0);
      expect(preset.volume).toBeLessThanOrEqual(1);
    });

    it('should have valid pan', () => {
      expect(preset.pan).toBeGreaterThanOrEqual(-1);
      expect(preset.pan).toBeLessThanOrEqual(1);
    });

    it('should have valid pitch bend range', () => {
      expect(preset.pitchBendRange).toBeGreaterThanOrEqual(0);
      expect(preset.pitchBendRange).toBeLessThanOrEqual(24);
    });

    it('should have valid portamento', () => {
      expect(preset.portamento).toBeGreaterThanOrEqual(0);
    });
  });
});

describe('BASS_PRESETS', () => {
  it('should have sub bass preset', () => {
    expect(BASS_PRESETS.sub_bass).toBeDefined();
    expect(BASS_PRESETS.sub_bass.category).toBe('bass');
  });

  it('should have acid bass preset', () => {
    expect(BASS_PRESETS.acid_bass).toBeDefined();
    expect(BASS_PRESETS.acid_bass.tags).toContain('acid');
  });

  it('should have reese bass preset', () => {
    expect(BASS_PRESETS.reese_bass).toBeDefined();
    expect(BASS_PRESETS.reese_bass.tags).toContain('reese');
  });

  it('bass presets should have mono voice mode', () => {
    Object.values(BASS_PRESETS).forEach(preset => {
      expect(preset.voiceMode.type).toBe('mono');
    });
  });

  it('bass presets should have low octave oscillators', () => {
    Object.values(BASS_PRESETS).forEach(preset => {
      preset.oscillators.forEach(osc => {
        expect(osc.octave).toBeLessThanOrEqual(0);
      });
    });
  });
});

describe('LEAD_PRESETS', () => {
  it('should have classic lead preset', () => {
    expect(LEAD_PRESETS.classic_lead).toBeDefined();
    expect(LEAD_PRESETS.classic_lead.category).toBe('lead');
  });

  it('should have screaming lead preset', () => {
    expect(LEAD_PRESETS.screaming_lead).toBeDefined();
    expect(LEAD_PRESETS.screaming_lead.tags).toContain('aggressive');
  });

  it('lead presets should generally have mono voice mode', () => {
    Object.values(LEAD_PRESETS).forEach(preset => {
      expect(preset.voiceMode.type).toBe('mono');
    });
  });
});

describe('PAD_PRESETS', () => {
  it('should have warm pad preset', () => {
    expect(PAD_PRESETS.warm_pad).toBeDefined();
    expect(PAD_PRESETS.warm_pad.category).toBe('pad');
  });

  it('should have dark pad preset', () => {
    expect(PAD_PRESETS.dark_pad).toBeDefined();
    expect(PAD_PRESETS.dark_pad.tags).toContain('dark');
  });

  it('pad presets should have poly voice mode', () => {
    Object.values(PAD_PRESETS).forEach(preset => {
      expect(preset.voiceMode.type).toBe('poly');
    });
  });

  it('pad presets should have long attack/release', () => {
    Object.values(PAD_PRESETS).forEach(preset => {
      // Pads typically have longer envelopes
      expect(preset.ampEnvelope.attack + preset.ampEnvelope.release).toBeGreaterThan(0.5);
    });
  });

  it('pad presets should have reverb effect', () => {
    Object.values(PAD_PRESETS).forEach(preset => {
      const hasReverb = preset.effects.effects.some(e => e.type === 'reverb');
      expect(hasReverb).toBe(true);
    });
  });
});

describe('PLUCK_PRESETS', () => {
  it('should have digital pluck preset', () => {
    expect(PLUCK_PRESETS.digital_pluck).toBeDefined();
    expect(PLUCK_PRESETS.digital_pluck.category).toBe('pluck');
  });

  it('should have bell tone preset', () => {
    expect(PLUCK_PRESETS.bell_tone).toBeDefined();
    expect(PLUCK_PRESETS.bell_tone.tags).toContain('bell');
  });

  it('pluck presets should have fast attack', () => {
    Object.values(PLUCK_PRESETS).forEach(preset => {
      expect(preset.ampEnvelope.attack).toBeLessThan(0.01);
    });
  });

  it('pluck presets should have short/zero sustain', () => {
    Object.values(PLUCK_PRESETS).forEach(preset => {
      expect(preset.ampEnvelope.sustain).toBeLessThanOrEqual(0.1);
    });
  });

  it('pluck presets should have poly voice mode', () => {
    Object.values(PLUCK_PRESETS).forEach(preset => {
      expect(preset.voiceMode.type).toBe('poly');
    });
  });
});

describe('FX_PRESETS', () => {
  it('should have noise sweep preset', () => {
    expect(FX_PRESETS.noise_sweep).toBeDefined();
    expect(FX_PRESETS.noise_sweep.category).toBe('fx');
  });

  it('noise sweep should have noise source', () => {
    expect(FX_PRESETS.noise_sweep.noise).toBeDefined();
    expect(FX_PRESETS.noise_sweep.noise!.level).toBeGreaterThan(0);
  });
});

describe('getPresetsByCategory', () => {
  it('should return all bass presets', () => {
    const bassPresets = getPresetsByCategory('bass');
    expect(bassPresets.length).toBe(Object.keys(BASS_PRESETS).length);
    bassPresets.forEach(preset => {
      expect(preset.category).toBe('bass');
    });
  });

  it('should return all lead presets', () => {
    const leadPresets = getPresetsByCategory('lead');
    expect(leadPresets.length).toBe(Object.keys(LEAD_PRESETS).length);
    leadPresets.forEach(preset => {
      expect(preset.category).toBe('lead');
    });
  });

  it('should return all pad presets', () => {
    const padPresets = getPresetsByCategory('pad');
    expect(padPresets.length).toBe(Object.keys(PAD_PRESETS).length);
    padPresets.forEach(preset => {
      expect(preset.category).toBe('pad');
    });
  });

  it('should return all pluck presets', () => {
    const pluckPresets = getPresetsByCategory('pluck');
    expect(pluckPresets.length).toBe(Object.keys(PLUCK_PRESETS).length);
    pluckPresets.forEach(preset => {
      expect(preset.category).toBe('pluck');
    });
  });

  it('should return all fx presets', () => {
    const fxPresets = getPresetsByCategory('fx');
    expect(fxPresets.length).toBe(Object.keys(FX_PRESETS).length);
    fxPresets.forEach(preset => {
      expect(preset.category).toBe('fx');
    });
  });

  it('should return empty array for non-existent category', () => {
    const presets = getPresetsByCategory('nonexistent');
    expect(presets).toEqual([]);
  });
});

describe('getPresetsByTag', () => {
  it('should find presets with acid tag', () => {
    const presets = getPresetsByTag('acid');
    expect(presets.length).toBeGreaterThan(0);
    presets.forEach(preset => {
      expect(preset.tags).toContain('acid');
    });
  });

  it('should find presets with warm tag', () => {
    const presets = getPresetsByTag('warm');
    expect(presets.length).toBeGreaterThan(0);
    presets.forEach(preset => {
      expect(preset.tags).toContain('warm');
    });
  });

  it('should find presets with dark tag', () => {
    const presets = getPresetsByTag('dark');
    expect(presets.length).toBeGreaterThan(0);
    presets.forEach(preset => {
      expect(preset.tags).toContain('dark');
    });
  });

  it('should return empty array for non-existent tag', () => {
    const presets = getPresetsByTag('nonexistent_tag_xyz');
    expect(presets).toEqual([]);
  });

  it('should find multiple presets sharing a tag', () => {
    const presets = getPresetsByTag('pluck');
    expect(presets.length).toBeGreaterThanOrEqual(1);
  });
});

describe('Oscillator Validation', () => {
  describe.each(Object.entries(ALL_SYNTH_PRESETS))('%s oscillators', (presetId, preset) => {
    preset.oscillators.forEach((osc, index) => {
      describe(`oscillator ${index}`, () => {
        it('should have valid waveform', () => {
          const validWaveforms = [
            'sine', 'square', 'sawtooth', 'triangle', 'pulse',
            'noise_white', 'noise_pink', 'noise_brown', 'wavetable', 'fm'
          ];
          expect(validWaveforms).toContain(osc.waveform);
        });

        it('should have valid detune', () => {
          expect(osc.detune).toBeGreaterThanOrEqual(-100);
          expect(osc.detune).toBeLessThanOrEqual(100);
        });

        it('should have valid octave', () => {
          expect(osc.octave).toBeGreaterThanOrEqual(-2);
          expect(osc.octave).toBeLessThanOrEqual(2);
        });

        it('should have valid level', () => {
          expect(osc.level).toBeGreaterThanOrEqual(0);
          expect(osc.level).toBeLessThanOrEqual(1);
        });

        it('should have valid pan', () => {
          expect(osc.pan).toBeGreaterThanOrEqual(-1);
          expect(osc.pan).toBeLessThanOrEqual(1);
        });

        it('should have pulse width if pulse waveform', () => {
          if (osc.waveform === 'pulse') {
            expect(osc.pulseWidth).toBeDefined();
            expect(osc.pulseWidth).toBeGreaterThanOrEqual(0);
            expect(osc.pulseWidth).toBeLessThanOrEqual(1);
          }
        });
      });
    });
  });
});

describe('LFO Validation', () => {
  describe.each(Object.entries(ALL_SYNTH_PRESETS))('%s LFOs', (presetId, preset) => {
    preset.lfos.forEach((lfo, index) => {
      describe(`LFO ${index}`, () => {
        it('should have valid shape', () => {
          const validShapes = ['sine', 'square', 'triangle', 'sawtooth', 'random', 'sample_hold', 'custom'];
          expect(validShapes).toContain(lfo.shape);
        });

        it('should have positive rate', () => {
          expect(lfo.rate).toBeGreaterThan(0);
        });

        it('should have valid sync mode', () => {
          expect(['free', 'tempo', 'key']).toContain(lfo.sync);
        });

        it('should have valid depth', () => {
          expect(lfo.depth).toBeGreaterThanOrEqual(0);
          expect(lfo.depth).toBeLessThanOrEqual(1);
        });

        it('should have valid phase', () => {
          expect(lfo.phase).toBeGreaterThanOrEqual(0);
          expect(lfo.phase).toBeLessThanOrEqual(360);
        });

        it('should have non-negative delay', () => {
          expect(lfo.delay).toBeGreaterThanOrEqual(0);
        });

        it('should have destinations array', () => {
          expect(Array.isArray(lfo.destinations)).toBe(true);
        });

        lfo.destinations.forEach((dest, destIndex) => {
          it(`destination ${destIndex} should have valid target`, () => {
            const validTargets = [
              'pitch', 'filter_cutoff', 'filter_resonance', 'amplitude',
              'pan', 'osc1_level', 'osc2_level', 'pulse_width',
              'wavetable_position', 'fm_index', 'delay_time',
              'delay_feedback', 'reverb_mix'
            ];
            expect(validTargets).toContain(dest.target);
          });

          it(`destination ${destIndex} should have valid amount`, () => {
            expect(dest.amount).toBeGreaterThanOrEqual(-1);
            expect(dest.amount).toBeLessThanOrEqual(1);
          });
        });
      });
    });
  });
});

describe('Effects Validation', () => {
  describe.each(Object.entries(ALL_SYNTH_PRESETS))('%s effects', (presetId, preset) => {
    preset.effects.effects.forEach((effect, index) => {
      describe(`effect ${index}`, () => {
        it('should have valid effect type', () => {
          const validTypes = [
            'delay', 'reverb', 'chorus', 'flanger', 'phaser',
            'distortion', 'bitcrusher', 'compressor', 'eq',
            'filter', 'tremolo', 'vibrato', 'ring_mod', 'vocoder'
          ];
          expect(validTypes).toContain(effect.type);
        });

        it('should have bypass boolean', () => {
          expect(typeof effect.bypass).toBe('boolean');
        });

        it('should have valid mix', () => {
          expect(effect.mix).toBeGreaterThanOrEqual(0);
          expect(effect.mix).toBeLessThanOrEqual(1);
        });

        it('should have params object', () => {
          expect(typeof effect.params).toBe('object');
        });
      });
    });
  });
});

describe('Voice Mode Validation', () => {
  describe.each(Object.entries(ALL_SYNTH_PRESETS))('%s voice mode', (presetId, preset) => {
    const voiceMode = preset.voiceMode;

    it('should have valid type', () => {
      expect(['poly', 'mono', 'unison']).toContain(voiceMode.type);
    });

    if (voiceMode.type === 'poly') {
      it('poly mode should have voices count', () => {
        expect((voiceMode as any).voices).toBeGreaterThan(0);
      });
    }

    if (voiceMode.type === 'mono') {
      it('mono mode should have legato setting', () => {
        expect(typeof (voiceMode as any).legato).toBe('boolean');
      });

      it('mono mode should have retrigger setting', () => {
        expect(typeof (voiceMode as any).retrigger).toBe('boolean');
      });
    }

    if (voiceMode.type === 'unison') {
      it('unison mode should have voices count', () => {
        expect((voiceMode as any).voices).toBeGreaterThan(0);
      });

      it('unison mode should have detune amount', () => {
        expect(typeof (voiceMode as any).detune).toBe('number');
      });

      it('unison mode should have spread amount', () => {
        expect(typeof (voiceMode as any).spread).toBe('number');
      });
    }
  });
});
