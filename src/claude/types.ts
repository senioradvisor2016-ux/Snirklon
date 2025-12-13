/**
 * Snirklon - Claude Integration Types
 * Typdefinitioner för sekvens-generering med Claude
 */

// ============================================
// Grundläggande musiktyper
// ============================================

export interface Note {
  pitch: number;        // MIDI note number (0-127)
  velocity: number;     // Hur hårt (0-127)
  start: number;        // Starttid i beats
  duration: number;     // Längd i beats
  probability?: number; // För probabilistiska sekvenser (0-1)
}

export interface Sequence {
  id: string;
  name: string;
  type: 'melody' | 'bass' | 'drums' | 'arpeggio' | 'chord' | 'ambient';
  length: number;       // Längd i beats
  notes: Note[];
  metadata: SequenceMetadata;
}

export interface SequenceMetadata {
  generatedBy: 'claude' | 'user' | 'evolved';
  prompt?: string;
  confidence?: number;
  timestamp: number;
  persona?: string;
  tags?: string[];
}

// ============================================
// Kontext för Claude
// ============================================

export interface MusicalContext {
  bpm: number;
  timeSignature: [number, number];  // [beats, noteValue] t.ex. [4, 4]
  key: string;                      // t.ex. "Am", "C", "F#m"
  scale: ScaleType;
  mood?: string;
  genre?: string;
  existingTracks?: Sequence[];
}

export type ScaleType = 
  | 'major' | 'minor' | 'dorian' | 'phrygian' 
  | 'lydian' | 'mixolydian' | 'locrian'
  | 'pentatonic_major' | 'pentatonic_minor'
  | 'blues' | 'harmonic_minor' | 'melodic_minor'
  | 'whole_tone' | 'chromatic';

// ============================================
// Musikaliska Personas
// ============================================

export interface MusicalPersona {
  id: string;
  name: string;
  description: string;
  traits: PersonaTraits;
  systemPromptAddition: string;
}

export interface PersonaTraits {
  preferredScales: ScaleType[];
  tempoRange: [number, number];
  complexity: 'minimal' | 'moderate' | 'complex' | 'chaotic';
  rhythmicStyle: 'steady' | 'syncopated' | 'polyrhythmic' | 'free';
  harmonicApproach: 'consonant' | 'tense' | 'experimental';
  energyLevel: 'calm' | 'moderate' | 'energetic' | 'intense';
}

// ============================================
// Genererings-förfrågningar
// ============================================

export interface GenerationRequest {
  prompt: string;
  context: MusicalContext;
  persona?: string;
  constraints?: GenerationConstraints;
  variationType?: VariationType;
}

export interface GenerationConstraints {
  maxNotes?: number;
  noteRange?: [number, number];  // Min/max MIDI pitch
  allowedIntervals?: number[];   // Tillåtna melodiska hopp
  rhythmicDensity?: 'sparse' | 'normal' | 'dense';
  forceInKey?: boolean;
}

export type VariationType = 
  | 'rhythmic'    // Behåll tonhöjder, variera rytm
  | 'melodic'     // Behåll rytm, variera melodin  
  | 'harmonic'    // Lägg till harmonier
  | 'textural'    // Ändra klangfärg/articulation
  | 'structural'  // Omstrukturera sektioner
  | 'dynamics';   // Variera dynamik

// ============================================
// Genererings-svar från Claude
// ============================================

export interface GenerationResponse {
  success: boolean;
  sequence?: Sequence;
  explanation?: string;
  suggestions?: string[];
  alternatives?: Sequence[];
  error?: string;
}

// ============================================
// Evolutionär musik
// ============================================

export interface EvolutionConfig {
  populationSize: number;
  generations: number;
  mutationRate: number;
  crossoverRate: number;
  fitnessWeights: FitnessWeights;
}

export interface FitnessWeights {
  userRating: number;
  musicalCoherence: number;
  rhythmicInterest: number;
  melodicVariety: number;
  uniqueness: number;
}

export interface SequenceWithFitness {
  sequence: Sequence;
  fitness: number;
  userRating?: number;
}

// ============================================
// Storytelling / Narrativ musik
// ============================================

export interface MusicalStory {
  title: string;
  chapters: StoryChapter[];
  overallMood: string;
  duration: number;  // Total längd i beats
}

export interface StoryChapter {
  name: string;
  description: string;
  sequence: Sequence;
  transitionToNext?: 'smooth' | 'abrupt' | 'fade';
}

// ============================================
// Feedback & Lärande
// ============================================

export interface UserFeedback {
  sequenceId: string;
  rating: number;           // 1-5
  liked: string[];          // Vad användaren gillade
  disliked: string[];       // Vad användaren ogillade
  freeformComment?: string;
}

export interface UserPreferences {
  favoritePersonas: string[];
  preferredGenres: string[];
  avoidPatterns: string[];
  complexityPreference: 'simple' | 'moderate' | 'complex';
  feedbackHistory: UserFeedback[];
}

// ============================================
// Session & Minne
// ============================================

export interface SessionState {
  id: string;
  startTime: number;
  context: MusicalContext;
  conversationHistory: ConversationEntry[];
  generatedSequences: Sequence[];
  userPreferences: UserPreferences;
  activePersona?: string;
}

export interface ConversationEntry {
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
  relatedSequenceId?: string;
}
