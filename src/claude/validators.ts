/**
 * Snirklon - Validators
 * Validering och parsing av Claude-genererade sekvenser
 */

import { Sequence, Note, GenerationResponse } from './types';

// ============================================
// Sekvens-validering
// ============================================

export function validateSequence(sequence: unknown): sequence is Sequence {
  if (!sequence || typeof sequence !== 'object') {
    return false;
  }

  const seq = sequence as Record<string, unknown>;

  // Kontrollera obligatoriska fält
  if (typeof seq.id !== 'string' || seq.id.length === 0) {
    console.warn('Validation failed: invalid or missing id');
    return false;
  }

  if (typeof seq.name !== 'string') {
    console.warn('Validation failed: invalid or missing name');
    return false;
  }

  const validTypes = ['melody', 'bass', 'drums', 'arpeggio', 'chord', 'ambient'];
  if (!validTypes.includes(seq.type as string)) {
    console.warn(`Validation failed: invalid type "${seq.type}"`);
    return false;
  }

  if (typeof seq.length !== 'number' || seq.length <= 0) {
    console.warn('Validation failed: invalid length');
    return false;
  }

  if (!Array.isArray(seq.notes)) {
    console.warn('Validation failed: notes is not an array');
    return false;
  }

  // Validera varje not
  for (let i = 0; i < seq.notes.length; i++) {
    if (!validateNote(seq.notes[i])) {
      console.warn(`Validation failed: invalid note at index ${i}`);
      return false;
    }
  }

  return true;
}

export function validateNote(note: unknown): note is Note {
  if (!note || typeof note !== 'object') {
    return false;
  }

  const n = note as Record<string, unknown>;

  // Pitch: 0-127 (MIDI standard)
  if (typeof n.pitch !== 'number' || n.pitch < 0 || n.pitch > 127) {
    return false;
  }

  // Velocity: 0-127
  if (typeof n.velocity !== 'number' || n.velocity < 0 || n.velocity > 127) {
    return false;
  }

  // Start: måste vara >= 0
  if (typeof n.start !== 'number' || n.start < 0) {
    return false;
  }

  // Duration: måste vara > 0
  if (typeof n.duration !== 'number' || n.duration <= 0) {
    return false;
  }

  // Probability är optional men om det finns måste det vara 0-1
  if (n.probability !== undefined) {
    if (typeof n.probability !== 'number' || n.probability < 0 || n.probability > 1) {
      return false;
    }
  }

  return true;
}

// ============================================
// JSON Parsing
// ============================================

interface ParsedResponse {
  sequence: Sequence;
  explanation?: string;
  suggestions?: string[];
}

export function parseSequenceFromResponse(responseText: string): ParsedResponse | null {
  try {
    // Försök hitta JSON i svaret
    const jsonMatch = responseText.match(/```json\n?([\s\S]*?)\n?```/);
    
    let jsonStr: string;
    if (jsonMatch) {
      jsonStr = jsonMatch[1];
    } else {
      // Försök parsa hela svaret som JSON
      jsonStr = responseText;
    }

    const parsed = JSON.parse(jsonStr);

    // Hantera olika responsformat
    let sequence: Sequence;
    let explanation: string | undefined;
    let suggestions: string[] | undefined;

    if (parsed.sequence) {
      sequence = parsed.sequence;
      explanation = parsed.explanation;
      suggestions = parsed.suggestions;
    } else if (parsed.notes && parsed.type) {
      // Direkt sekvens utan wrapper
      sequence = {
        id: parsed.id || generateId(),
        name: parsed.name || 'Untitled',
        type: parsed.type,
        length: parsed.length || calculateLength(parsed.notes),
        notes: parsed.notes,
        metadata: parsed.metadata || {
          generatedBy: 'claude',
          timestamp: Date.now(),
        },
      };
    } else {
      console.warn('Could not find sequence in response');
      return null;
    }

    // Säkerställ att metadata finns
    if (!sequence.metadata) {
      sequence.metadata = {
        generatedBy: 'claude',
        timestamp: Date.now(),
      };
    }

    // Generera ID om det saknas
    if (!sequence.id) {
      sequence.id = generateId();
    }

    return { sequence, explanation, suggestions };

  } catch (error) {
    console.error('Failed to parse response:', error);
    return null;
  }
}

// ============================================
// Sekvens-reparation
// ============================================

export function repairSequence(sequence: Partial<Sequence>): Sequence | null {
  try {
    const repaired: Sequence = {
      id: sequence.id || generateId(),
      name: sequence.name || 'Repaired Sequence',
      type: isValidType(sequence.type) ? sequence.type : 'melody',
      length: sequence.length || 16,
      notes: [],
      metadata: {
        generatedBy: 'claude',
        timestamp: Date.now(),
        ...sequence.metadata,
      },
    };

    // Reparera noter
    if (Array.isArray(sequence.notes)) {
      for (const note of sequence.notes) {
        const repairedNote = repairNote(note);
        if (repairedNote) {
          repaired.notes.push(repairedNote);
        }
      }
    }

    // Beräkna om längden om det behövs
    if (repaired.notes.length > 0) {
      const maxEnd = Math.max(...repaired.notes.map(n => n.start + n.duration));
      repaired.length = Math.max(repaired.length, Math.ceil(maxEnd));
    }

    return validateSequence(repaired) ? repaired : null;

  } catch {
    return null;
  }
}

function repairNote(note: Partial<Note>): Note | null {
  if (!note || typeof note !== 'object') {
    return null;
  }

  try {
    return {
      pitch: clamp(Math.round(note.pitch ?? 60), 0, 127),
      velocity: clamp(Math.round(note.velocity ?? 100), 0, 127),
      start: Math.max(0, note.start ?? 0),
      duration: Math.max(0.0625, note.duration ?? 0.5), // Minst 1/64 not
      probability: note.probability !== undefined 
        ? clamp(note.probability, 0, 1) 
        : undefined,
    };
  } catch {
    return null;
  }
}

// ============================================
// Musikalisk validering
// ============================================

export function validateMusicality(sequence: Sequence): {
  valid: boolean;
  warnings: string[];
  suggestions: string[];
} {
  const warnings: string[] = [];
  const suggestions: string[] = [];

  // Kontrollera notomfång
  const pitches = sequence.notes.map(n => n.pitch);
  const minPitch = Math.min(...pitches);
  const maxPitch = Math.max(...pitches);
  const range = maxPitch - minPitch;

  if (range > 36) { // Mer än 3 oktaver
    warnings.push(`Stort tonhöjdsomfång (${range} halvtoner). Kan vara svårt att spela.`);
  }

  // Kontrollera velocitydynamik
  const velocities = sequence.notes.map(n => n.velocity);
  const velocityRange = Math.max(...velocities) - Math.min(...velocities);
  
  if (velocityRange < 10) {
    suggestions.push('Överväg att variera velocity för mer dynamik.');
  }

  // Kontrollera notdensitet
  const notesPerBeat = sequence.notes.length / sequence.length;
  
  if (notesPerBeat > 4) {
    warnings.push(`Hög notdensitet (${notesPerBeat.toFixed(1)} noter/beat). Kan bli rörigt.`);
  }

  // Kontrollera överlappande noter på samma pitch
  const overlaps = findOverlappingNotes(sequence.notes);
  if (overlaps.length > 0) {
    warnings.push(`${overlaps.length} överlappande noter på samma tonhöjd.`);
  }

  // Kontrollera stora hopp
  const largeLeaps = findLargeLeaps(sequence.notes);
  if (largeLeaps.length > 3) {
    suggestions.push('Många stora melodiska hopp. Överväg fler stegvisa rörelser.');
  }

  return {
    valid: warnings.length === 0,
    warnings,
    suggestions,
  };
}

function findOverlappingNotes(notes: Note[]): Array<[Note, Note]> {
  const overlaps: Array<[Note, Note]> = [];
  
  for (let i = 0; i < notes.length; i++) {
    for (let j = i + 1; j < notes.length; j++) {
      const a = notes[i];
      const b = notes[j];
      
      if (a.pitch === b.pitch) {
        const aEnd = a.start + a.duration;
        const bEnd = b.start + b.duration;
        
        if (a.start < bEnd && b.start < aEnd) {
          overlaps.push([a, b]);
        }
      }
    }
  }
  
  return overlaps;
}

function findLargeLeaps(notes: Note[]): number[] {
  const leaps: number[] = [];
  const sortedByStart = [...notes].sort((a, b) => a.start - b.start);
  
  for (let i = 1; i < sortedByStart.length; i++) {
    const interval = Math.abs(sortedByStart[i].pitch - sortedByStart[i - 1].pitch);
    if (interval > 7) { // Större än en kvint
      leaps.push(interval);
    }
  }
  
  return leaps;
}

// ============================================
// Hjälpfunktioner
// ============================================

function generateId(): string {
  return `seq_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

function calculateLength(notes: Note[]): number {
  if (notes.length === 0) return 16;
  const maxEnd = Math.max(...notes.map(n => n.start + n.duration));
  return Math.ceil(maxEnd / 4) * 4; // Runda upp till närmaste 4 beats
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function isValidType(type: unknown): type is Sequence['type'] {
  return ['melody', 'bass', 'drums', 'arpeggio', 'chord', 'ambient'].includes(type as string);
}

// ============================================
// Export
// ============================================

export const validators = {
  sequence: validateSequence,
  note: validateNote,
  musicality: validateMusicality,
  parse: parseSequenceFromResponse,
  repair: repairSequence,
};
