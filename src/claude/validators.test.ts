/**
 * Snirklon - Validator System Tests
 * Testar validering och parsing av sekvenser
 */

import {
  validateSequence,
  validateNote,
  parseSequenceFromResponse,
  repairSequence,
  validateMusicality,
} from './validators';
import { Sequence, Note } from './types';

describe('validateNote', () => {
  it('should validate a correct note', () => {
    const note: Note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(true);
  });

  it('should validate note with probability', () => {
    const note: Note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: 0.5,
      probability: 0.75,
    };
    expect(validateNote(note)).toBe(true);
  });

  it('should reject note with invalid pitch (too low)', () => {
    const note = {
      pitch: -1,
      velocity: 100,
      start: 0,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with invalid pitch (too high)', () => {
    const note = {
      pitch: 128,
      velocity: 100,
      start: 0,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with invalid velocity (too low)', () => {
    const note = {
      pitch: 60,
      velocity: -1,
      start: 0,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with invalid velocity (too high)', () => {
    const note = {
      pitch: 60,
      velocity: 128,
      start: 0,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with negative start time', () => {
    const note = {
      pitch: 60,
      velocity: 100,
      start: -1,
      duration: 0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with zero duration', () => {
    const note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: 0,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with negative duration', () => {
    const note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: -0.5,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with invalid probability (too low)', () => {
    const note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: 0.5,
      probability: -0.1,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject note with invalid probability (too high)', () => {
    const note = {
      pitch: 60,
      velocity: 100,
      start: 0,
      duration: 0.5,
      probability: 1.1,
    };
    expect(validateNote(note)).toBe(false);
  });

  it('should reject null or undefined', () => {
    expect(validateNote(null)).toBe(false);
    expect(validateNote(undefined)).toBe(false);
  });

  it('should reject non-object values', () => {
    expect(validateNote('not a note')).toBe(false);
    expect(validateNote(42)).toBe(false);
    expect(validateNote([])).toBe(false);
  });

  it('should accept boundary values', () => {
    // Min values
    const minNote: Note = {
      pitch: 0,
      velocity: 0,
      start: 0,
      duration: 0.001,
      probability: 0,
    };
    expect(validateNote(minNote)).toBe(true);

    // Max values
    const maxNote: Note = {
      pitch: 127,
      velocity: 127,
      start: 1000,
      duration: 100,
      probability: 1,
    };
    expect(validateNote(maxNote)).toBe(true);
  });
});

describe('validateSequence', () => {
  const validSequence: Sequence = {
    id: 'test-seq-1',
    name: 'Test Sequence',
    type: 'melody',
    length: 16,
    notes: [
      { pitch: 60, velocity: 100, start: 0, duration: 0.5 },
      { pitch: 62, velocity: 90, start: 1, duration: 0.5 },
    ],
    metadata: {
      generatedBy: 'user',
      timestamp: Date.now(),
    },
  };

  it('should validate a correct sequence', () => {
    expect(validateSequence(validSequence)).toBe(true);
  });

  it('should validate all sequence types', () => {
    const types: Array<Sequence['type']> = ['melody', 'bass', 'drums', 'arpeggio', 'chord', 'ambient'];
    types.forEach(type => {
      const seq = { ...validSequence, type };
      expect(validateSequence(seq)).toBe(true);
    });
  });

  it('should reject sequence with invalid type', () => {
    const seq = { ...validSequence, type: 'invalid' as any };
    expect(validateSequence(seq)).toBe(false);
  });

  it('should reject sequence without id', () => {
    const seq = { ...validSequence, id: '' };
    expect(validateSequence(seq)).toBe(false);
  });

  it('should reject sequence with invalid length', () => {
    expect(validateSequence({ ...validSequence, length: 0 })).toBe(false);
    expect(validateSequence({ ...validSequence, length: -1 })).toBe(false);
  });

  it('should reject sequence with invalid notes', () => {
    const seq = {
      ...validSequence,
      notes: [{ pitch: 200, velocity: 100, start: 0, duration: 0.5 }],
    };
    expect(validateSequence(seq)).toBe(false);
  });

  it('should validate empty notes array', () => {
    const seq = { ...validSequence, notes: [] };
    expect(validateSequence(seq)).toBe(true);
  });

  it('should reject non-array notes', () => {
    const seq = { ...validSequence, notes: 'not an array' as any };
    expect(validateSequence(seq)).toBe(false);
  });

  it('should reject null or undefined', () => {
    expect(validateSequence(null)).toBe(false);
    expect(validateSequence(undefined)).toBe(false);
  });
});

describe('parseSequenceFromResponse', () => {
  it('should parse JSON from code block', () => {
    const response = `
Here's a melody for you:

\`\`\`json
{
  "sequence": {
    "id": "seq-1",
    "name": "Test Melody",
    "type": "melody",
    "length": 8,
    "notes": [
      {"pitch": 60, "velocity": 100, "start": 0, "duration": 0.5}
    ],
    "metadata": {
      "generatedBy": "claude",
      "timestamp": 1234567890
    }
  },
  "explanation": "A simple melody"
}
\`\`\`
    `;

    const result = parseSequenceFromResponse(response);
    expect(result).not.toBeNull();
    expect(result?.sequence.name).toBe('Test Melody');
    expect(result?.explanation).toBe('A simple melody');
  });

  it('should parse direct sequence format', () => {
    const response = `
\`\`\`json
{
  "id": "seq-direct",
  "name": "Direct Sequence",
  "type": "bass",
  "notes": [
    {"pitch": 36, "velocity": 120, "start": 0, "duration": 1}
  ]
}
\`\`\`
    `;

    const result = parseSequenceFromResponse(response);
    expect(result).not.toBeNull();
    expect(result?.sequence.type).toBe('bass');
  });

  it('should parse raw JSON without code block', () => {
    const response = JSON.stringify({
      sequence: {
        id: 'raw-seq',
        name: 'Raw Sequence',
        type: 'chord',
        length: 4,
        notes: [],
        metadata: { generatedBy: 'claude', timestamp: Date.now() },
      },
    });

    const result = parseSequenceFromResponse(response);
    expect(result).not.toBeNull();
    expect(result?.sequence.name).toBe('Raw Sequence');
  });

  it('should return null for invalid JSON', () => {
    const response = 'This is not valid JSON at all';
    const result = parseSequenceFromResponse(response);
    expect(result).toBeNull();
  });

  it('should handle response without sequence object', () => {
    const response = `
\`\`\`json
{
  "something": "else",
  "notASequence": true
}
\`\`\`
    `;
    const result = parseSequenceFromResponse(response);
    expect(result).toBeNull();
  });

  it('should add metadata if missing', () => {
    const response = `
\`\`\`json
{
  "id": "no-meta",
  "name": "No Metadata",
  "type": "melody",
  "notes": []
}
\`\`\`
    `;
    const result = parseSequenceFromResponse(response);
    expect(result).not.toBeNull();
    expect(result?.sequence.metadata).toBeDefined();
    expect(result?.sequence.metadata.generatedBy).toBe('claude');
  });
});

describe('repairSequence', () => {
  it('should repair a sequence with missing fields', () => {
    const partial = {
      notes: [
        { pitch: 60, velocity: 100, start: 0, duration: 0.5 },
      ],
    };

    const repaired = repairSequence(partial);
    expect(repaired).not.toBeNull();
    expect(repaired?.id).toBeDefined();
    expect(repaired?.name).toBe('Repaired Sequence');
    expect(repaired?.type).toBe('melody');
  });

  it('should clamp note values to valid ranges', () => {
    const partial = {
      notes: [
        { pitch: 200, velocity: 200, start: -5, duration: -1 },
      ],
    };

    const repaired = repairSequence(partial);
    expect(repaired).not.toBeNull();
    expect(repaired?.notes[0].pitch).toBe(127);
    expect(repaired?.notes[0].velocity).toBe(127);
    expect(repaired?.notes[0].start).toBe(0);
    expect(repaired?.notes[0].duration).toBeGreaterThan(0);
  });

  it('should preserve valid type', () => {
    const partial = {
      type: 'drums' as const,
      notes: [],
    };

    const repaired = repairSequence(partial);
    expect(repaired?.type).toBe('drums');
  });

  it('should default invalid type to melody', () => {
    const partial = {
      type: 'invalid-type' as any,
      notes: [],
    };

    const repaired = repairSequence(partial);
    expect(repaired?.type).toBe('melody');
  });

  it('should calculate length from notes', () => {
    const partial = {
      notes: [
        { pitch: 60, velocity: 100, start: 0, duration: 0.5 },
        { pitch: 64, velocity: 100, start: 7, duration: 1 },
      ],
    };

    const repaired = repairSequence(partial);
    expect(repaired?.length).toBeGreaterThanOrEqual(8);
  });
});

describe('validateMusicality', () => {
  it('should pass for well-formed sequence', () => {
    const sequence: Sequence = {
      id: 'test',
      name: 'Well-formed',
      type: 'melody',
      length: 8,
      notes: [
        { pitch: 60, velocity: 100, start: 0, duration: 0.5 },
        { pitch: 62, velocity: 90, start: 1, duration: 0.5 },
        { pitch: 64, velocity: 110, start: 2, duration: 0.5 },
      ],
      metadata: { generatedBy: 'user', timestamp: Date.now() },
    };

    const result = validateMusicality(sequence);
    expect(result.valid).toBe(true);
    expect(result.warnings).toHaveLength(0);
  });

  it('should warn about large pitch range', () => {
    const sequence: Sequence = {
      id: 'test',
      name: 'Wide Range',
      type: 'melody',
      length: 8,
      notes: [
        { pitch: 24, velocity: 100, start: 0, duration: 0.5 },
        { pitch: 96, velocity: 100, start: 1, duration: 0.5 },
      ],
      metadata: { generatedBy: 'user', timestamp: Date.now() },
    };

    const result = validateMusicality(sequence);
    expect(result.warnings.some(w => w.includes('omfång'))).toBe(true);
  });

  it('should suggest velocity variation', () => {
    const sequence: Sequence = {
      id: 'test',
      name: 'Flat Velocity',
      type: 'melody',
      length: 8,
      notes: [
        { pitch: 60, velocity: 100, start: 0, duration: 0.5 },
        { pitch: 62, velocity: 100, start: 1, duration: 0.5 },
        { pitch: 64, velocity: 100, start: 2, duration: 0.5 },
      ],
      metadata: { generatedBy: 'user', timestamp: Date.now() },
    };

    const result = validateMusicality(sequence);
    expect(result.suggestions.some(s => s.includes('velocity'))).toBe(true);
  });

  it('should warn about high note density', () => {
    const notes: Note[] = [];
    for (let i = 0; i < 40; i++) {
      notes.push({ pitch: 60 + (i % 12), velocity: 100, start: i * 0.1, duration: 0.1 });
    }

    const sequence: Sequence = {
      id: 'test',
      name: 'Dense',
      type: 'melody',
      length: 4,
      notes,
      metadata: { generatedBy: 'user', timestamp: Date.now() },
    };

    const result = validateMusicality(sequence);
    expect(result.warnings.some(w => w.includes('densitet'))).toBe(true);
  });

  it('should detect overlapping notes on same pitch', () => {
    const sequence: Sequence = {
      id: 'test',
      name: 'Overlapping',
      type: 'melody',
      length: 8,
      notes: [
        { pitch: 60, velocity: 100, start: 0, duration: 2 },
        { pitch: 60, velocity: 100, start: 1, duration: 2 },
      ],
      metadata: { generatedBy: 'user', timestamp: Date.now() },
    };

    const result = validateMusicality(sequence);
    expect(result.warnings.some(w => w.includes('överlappande'))).toBe(true);
  });
});
