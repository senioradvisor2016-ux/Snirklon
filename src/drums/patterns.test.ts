/**
 * Snirklon - Drum Patterns System Tests
 * Testar Euclidean generator, kits och patterns
 */

import {
  generateEuclidean,
  euclideanToTrack,
  DRUM_KITS,
  CLASSIC_PATTERNS,
  GROOVE_TEMPLATES,
  STYLE_CHARACTERISTICS,
} from './patterns';
import { DrumStyle, EuclideanConfig } from './types';

describe('generateEuclidean', () => {
  describe('basic patterns', () => {
    it('should generate E(3,8) - classic tresillo pattern', () => {
      const pattern = generateEuclidean({ hits: 3, steps: 8, rotation: 0 });
      expect(pattern.length).toBe(8);
      expect(pattern.filter(Boolean).length).toBe(3);
      // Classic tresillo: [x . . x . . x .]
      expect(pattern).toEqual([true, false, false, true, false, false, true, false]);
    });

    it('should generate E(5,8) - cinquillo pattern', () => {
      const pattern = generateEuclidean({ hits: 5, steps: 8, rotation: 0 });
      expect(pattern.length).toBe(8);
      expect(pattern.filter(Boolean).length).toBe(5);
    });

    it('should generate E(4,16) - four on the floor', () => {
      const pattern = generateEuclidean({ hits: 4, steps: 16, rotation: 0 });
      expect(pattern.length).toBe(16);
      expect(pattern.filter(Boolean).length).toBe(4);
      // Should be evenly spaced
      expect(pattern[0]).toBe(true);
      expect(pattern[4]).toBe(true);
      expect(pattern[8]).toBe(true);
      expect(pattern[12]).toBe(true);
    });

    it('should generate E(7,16) - common clave-like pattern', () => {
      const pattern = generateEuclidean({ hits: 7, steps: 16, rotation: 0 });
      expect(pattern.length).toBe(16);
      expect(pattern.filter(Boolean).length).toBe(7);
    });
  });

  describe('edge cases', () => {
    it('should handle all hits (full pattern)', () => {
      const pattern = generateEuclidean({ hits: 8, steps: 8, rotation: 0 });
      expect(pattern).toEqual(new Array(8).fill(true));
    });

    it('should handle zero hits (empty pattern)', () => {
      const pattern = generateEuclidean({ hits: 0, steps: 8, rotation: 0 });
      expect(pattern).toEqual(new Array(8).fill(false));
    });

    it('should handle single hit', () => {
      const pattern = generateEuclidean({ hits: 1, steps: 8, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(1);
      expect(pattern[0]).toBe(true);
    });

    it('should handle hits > steps (cap at all hits)', () => {
      const pattern = generateEuclidean({ hits: 10, steps: 8, rotation: 0 });
      expect(pattern).toEqual(new Array(8).fill(true));
    });

    it('should handle single step', () => {
      const pattern = generateEuclidean({ hits: 1, steps: 1, rotation: 0 });
      expect(pattern).toEqual([true]);
    });
  });

  describe('rotation', () => {
    it('should rotate pattern by specified amount', () => {
      const base = generateEuclidean({ hits: 3, steps: 8, rotation: 0 });
      const rotated = generateEuclidean({ hits: 3, steps: 8, rotation: 1 });
      
      // Rotated pattern should be shifted - rotation moves pattern left
      // So rotated[0] should be base[1], rotated[1] should be base[2], etc.
      // And rotated[7] should wrap around to base[0]
      expect(rotated[0]).toBe(base[1]);
      expect(rotated[7]).toBe(base[0]);
    });

    it('should handle rotation larger than steps', () => {
      const pattern1 = generateEuclidean({ hits: 3, steps: 8, rotation: 0 });
      const pattern2 = generateEuclidean({ hits: 3, steps: 8, rotation: 8 });
      expect(pattern1).toEqual(pattern2);
    });

    it('should handle rotation equal to steps (full rotation)', () => {
      const pattern1 = generateEuclidean({ hits: 4, steps: 16, rotation: 0 });
      const pattern2 = generateEuclidean({ hits: 4, steps: 16, rotation: 16 });
      expect(pattern1).toEqual(pattern2);
    });

    it('should create different patterns with different rotations', () => {
      const patterns: boolean[][] = [];
      for (let i = 0; i < 8; i++) {
        patterns.push(generateEuclidean({ hits: 3, steps: 8, rotation: i }));
      }
      
      // Not all patterns should be identical
      const uniquePatterns = new Set(patterns.map(p => p.join(',')));
      expect(uniquePatterns.size).toBeGreaterThan(1);
    });
  });

  describe('musically significant patterns', () => {
    it('E(2,5) - kpanlogo bell pattern', () => {
      const pattern = generateEuclidean({ hits: 2, steps: 5, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(2);
    });

    it('E(3,4) - cumbia beat', () => {
      const pattern = generateEuclidean({ hits: 3, steps: 4, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(3);
    });

    it('E(5,6) - York-Samai pattern', () => {
      const pattern = generateEuclidean({ hits: 5, steps: 6, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(5);
    });

    it('E(5,12) - venda pattern', () => {
      const pattern = generateEuclidean({ hits: 5, steps: 12, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(5);
    });

    it('E(7,12) - West African bell pattern', () => {
      const pattern = generateEuclidean({ hits: 7, steps: 12, rotation: 0 });
      expect(pattern.filter(Boolean).length).toBe(7);
    });
  });
});

describe('euclideanToTrack', () => {
  it('should create a valid drum track', () => {
    const config: EuclideanConfig = { hits: 4, steps: 16, rotation: 0 };
    const track = euclideanToTrack(config, 'kick', 'Kick');

    expect(track.id).toContain('euclidean_kick');
    expect(track.soundId).toBe('kick');
    expect(track.name).toBe('Kick');
    expect(track.steps.length).toBe(16);
    expect(track.mute).toBe(false);
    expect(track.solo).toBe(false);
  });

  it('should create active steps matching euclidean pattern', () => {
    const config: EuclideanConfig = { hits: 4, steps: 16, rotation: 0 };
    const track = euclideanToTrack(config, 'kick', 'Kick');

    const activeSteps = track.steps.filter(s => s.active);
    expect(activeSteps.length).toBe(4);
  });

  it('should apply base velocity to active steps', () => {
    const config: EuclideanConfig = { hits: 4, steps: 16, rotation: 0 };
    const track = euclideanToTrack(config, 'kick', 'Kick', 110);

    const activeSteps = track.steps.filter(s => s.active);
    activeSteps.forEach(step => {
      expect(step.velocity).toBeGreaterThanOrEqual(110);
    });
  });

  it('should set zero velocity for inactive steps', () => {
    const config: EuclideanConfig = { hits: 4, steps: 16, rotation: 0 };
    const track = euclideanToTrack(config, 'kick', 'Kick');

    const inactiveSteps = track.steps.filter(s => !s.active);
    inactiveSteps.forEach(step => {
      expect(step.velocity).toBe(0);
    });
  });

  it('should apply accent pattern when provided', () => {
    const config: EuclideanConfig = {
      hits: 4,
      steps: 16,
      rotation: 0,
      accent: { hits: 2, steps: 16, rotation: 0 },
    };
    const track = euclideanToTrack(config, 'kick', 'Kick', 100);

    const activeSteps = track.steps.filter(s => s.active);
    // Some steps should have higher velocity due to accent
    const velocities = activeSteps.map(s => s.velocity);
    const uniqueVelocities = new Set(velocities);
    expect(uniqueVelocities.size).toBeGreaterThan(1);
  });

  it('should set probability to 1 for all steps', () => {
    const config: EuclideanConfig = { hits: 4, steps: 16, rotation: 0 };
    const track = euclideanToTrack(config, 'kick', 'Kick');

    track.steps.forEach(step => {
      expect(step.probability).toBe(1);
    });
  });
});

describe('DRUM_KITS', () => {
  it('should have 808 kit', () => {
    expect(DRUM_KITS.kit_808).toBeDefined();
    expect(DRUM_KITS.kit_808.name).toContain('808');
    expect(DRUM_KITS.kit_808.category).toBe('808');
  });

  it('should have 909 kit', () => {
    expect(DRUM_KITS.kit_909).toBeDefined();
    expect(DRUM_KITS.kit_909.name).toContain('909');
    expect(DRUM_KITS.kit_909.category).toBe('909');
  });

  it('should have acoustic kit', () => {
    expect(DRUM_KITS.kit_acoustic).toBeDefined();
    expect(DRUM_KITS.kit_acoustic.category).toBe('acoustic');
  });

  describe.each(Object.entries(DRUM_KITS))('%s kit', (kitId, kit) => {
    it('should have valid structure', () => {
      expect(kit.id).toBe(kitId);
      expect(kit.name).toBeDefined();
      expect(kit.sounds).toBeDefined();
      expect(kit.sounds.length).toBeGreaterThan(0);
    });

    it('should have valid global settings', () => {
      expect(kit.globalSettings.volume).toBeGreaterThanOrEqual(0);
      expect(kit.globalSettings.volume).toBeLessThanOrEqual(1);
      expect(kit.globalSettings.swing).toBeGreaterThanOrEqual(0);
    });

    it('should have effects sends', () => {
      expect(kit.effectsSends.sendA).toBeDefined();
      expect(kit.effectsSends.sendB).toBeDefined();
    });

    it.each(kit.sounds)('sound %# should have valid params', (sound) => {
      expect(sound.id).toBeDefined();
      expect(sound.name).toBeDefined();
      expect(sound.midiNote).toBeGreaterThanOrEqual(0);
      expect(sound.midiNote).toBeLessThanOrEqual(127);
      expect(sound.params.level).toBeGreaterThanOrEqual(0);
      expect(sound.params.level).toBeLessThanOrEqual(1);
    });
  });
});

describe('CLASSIC_PATTERNS', () => {
  it('should have four on the floor pattern', () => {
    expect(CLASSIC_PATTERNS.four_on_floor).toBeDefined();
    expect(CLASSIC_PATTERNS.four_on_floor.name).toContain('Four');
  });

  it('should have breakbeat pattern', () => {
    expect(CLASSIC_PATTERNS.breakbeat_basic).toBeDefined();
    expect(CLASSIC_PATTERNS.breakbeat_basic.metadata?.style).toBe('breakbeat');
  });

  it('should have D&B pattern', () => {
    expect(CLASSIC_PATTERNS.dnb_basic).toBeDefined();
    expect(CLASSIC_PATTERNS.dnb_basic.metadata?.style).toBe('drum_and_bass');
  });

  it('should have trap pattern', () => {
    expect(CLASSIC_PATTERNS.trap_basic).toBeDefined();
    expect(CLASSIC_PATTERNS.trap_basic.metadata?.style).toBe('trap');
  });

  it('should have minimal techno pattern', () => {
    expect(CLASSIC_PATTERNS.techno_minimal).toBeDefined();
    expect(CLASSIC_PATTERNS.techno_minimal.metadata?.style).toBe('minimal');
  });

  describe.each(Object.entries(CLASSIC_PATTERNS))('%s pattern', (patternId, pattern) => {
    it('should have tracks', () => {
      expect(pattern.tracks).toBeDefined();
      expect(pattern.tracks!.length).toBeGreaterThan(0);
    });

    it('should have metadata', () => {
      expect(pattern.metadata).toBeDefined();
      expect(pattern.metadata!.style).toBeDefined();
    });

    it.each(pattern.tracks || [])('track %# should have valid structure', (track) => {
      expect(track.id).toBeDefined();
      expect(track.soundId).toBeDefined();
      expect(track.steps).toBeDefined();
      expect(track.steps.length).toBe(16);
    });
  });
});

describe('GROOVE_TEMPLATES', () => {
  it('should have MPC 60 groove', () => {
    expect(GROOVE_TEMPLATES.mpc_60).toBeDefined();
    expect(GROOVE_TEMPLATES.mpc_60.name).toContain('MPC');
  });

  it('should have SP-1200 groove', () => {
    expect(GROOVE_TEMPLATES.sp1200).toBeDefined();
  });

  it('should have shuffle grooves', () => {
    expect(GROOVE_TEMPLATES.shuffle_light).toBeDefined();
    expect(GROOVE_TEMPLATES.shuffle_heavy).toBeDefined();
  });

  it('should have human groove', () => {
    expect(GROOVE_TEMPLATES.human_loose).toBeDefined();
  });

  describe.each(Object.entries(GROOVE_TEMPLATES))('%s groove', (grooveId, groove) => {
    it('should have timing offsets', () => {
      expect(groove.timingOffsets).toBeDefined();
      expect(groove.timingOffsets.length).toBe(16);
    });

    it('should have velocity offsets', () => {
      expect(groove.velocityOffsets).toBeDefined();
      expect(groove.velocityOffsets.length).toBe(16);
    });
  });
});

describe('STYLE_CHARACTERISTICS', () => {
  const styles: DrumStyle[] = [
    'techno', 'house', 'deep_house', 'tech_house', 'minimal', 'trance',
    'drum_and_bass', 'jungle', 'dubstep', 'garage', 'breakbeat', 'idm',
    'ambient', 'rock', 'pop', 'funk', 'jazz', 'hip_hop', 'trap', 'r&b',
    'reggae', 'latin', 'afrobeat', 'bossa_nova', 'industrial', 'noise',
    'glitch', 'polyrhythmic',
  ];

  it('should have all defined styles', () => {
    styles.forEach(style => {
      expect(STYLE_CHARACTERISTICS[style]).toBeDefined();
    });
  });

  describe.each(styles)('%s style', (style) => {
    const characteristics = STYLE_CHARACTERISTICS[style];

    it('should have valid tempo range', () => {
      expect(characteristics.tempoRange[0]).toBeGreaterThan(0);
      expect(characteristics.tempoRange[1]).toBeGreaterThan(characteristics.tempoRange[0]);
    });

    it('should have valid swing range', () => {
      expect(characteristics.swingRange[0]).toBeGreaterThanOrEqual(0);
      expect(characteristics.swingRange[1]).toBeLessThanOrEqual(0.5);
      expect(characteristics.swingRange[1]).toBeGreaterThanOrEqual(characteristics.swingRange[0]);
    });

    it('should have pattern descriptions', () => {
      expect(characteristics.kickPattern).toBeDefined();
      expect(characteristics.snarePattern).toBeDefined();
    });

    it('should have hi-hat density', () => {
      expect(['sparse', 'normal', 'dense']).toContain(characteristics.hihatDensity);
    });

    it('should have characteristics list', () => {
      expect(characteristics.characteristics).toBeDefined();
      expect(characteristics.characteristics.length).toBeGreaterThan(0);
    });
  });

  it('should have realistic tempo ranges for electronic styles', () => {
    expect(STYLE_CHARACTERISTICS.techno.tempoRange[0]).toBeGreaterThanOrEqual(120);
    expect(STYLE_CHARACTERISTICS.drum_and_bass.tempoRange[0]).toBeGreaterThanOrEqual(160);
    expect(STYLE_CHARACTERISTICS.house.tempoRange[0]).toBeGreaterThanOrEqual(115);
  });

  it('should have realistic tempo ranges for acoustic styles', () => {
    expect(STYLE_CHARACTERISTICS.jazz.tempoRange[0]).toBeGreaterThanOrEqual(60);
    expect(STYLE_CHARACTERISTICS.hip_hop.tempoRange[0]).toBeGreaterThanOrEqual(70);
    expect(STYLE_CHARACTERISTICS.reggae.tempoRange[0]).toBeGreaterThanOrEqual(60);
  });
});
