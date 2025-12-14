import SwiftUI

struct StepModel: Identifiable, Equatable, Codable {
    let id: UUID
    var index: Int
    var isOn: Bool
    var note: Int          // MIDI note 0-127
    var velocity: Int      // 1-127
    var length: Int        // in ticks (1-96)
    var timing: Int        // microtiming offset (-48 to +48 ticks)
    var probability: Int   // 0-100%
    var repeat_: Int       // 0-8 repeats (ratchet)
    var slide: Bool        // Slide/glide to next note
    var accent: Bool       // Accent flag
    
    init(
        id: UUID = UUID(),
        index: Int,
        isOn: Bool = false,
        note: Int = 60,
        velocity: Int = 100,
        length: Int = 24,
        timing: Int = 0,
        probability: Int = 100,
        repeat_: Int = 0,
        slide: Bool = false,
        accent: Bool = false
    ) {
        self.id = id
        self.index = index
        self.isOn = isOn
        self.note = note
        self.velocity = velocity
        self.length = length
        self.timing = timing
        self.probability = probability
        self.repeat_ = repeat_
        self.slide = slide
        self.accent = accent
    }
    
    // MARK: - Mutations
    
    /// Clamp velocity to valid range
    mutating func adjustVelocity(by delta: Int) {
        velocity = max(1, min(127, velocity + delta))
    }
    
    /// Clamp timing to valid range
    mutating func adjustTiming(by delta: Int) {
        timing = max(-48, min(48, timing + delta))
    }
    
    /// Adjust note value
    mutating func adjustNote(by delta: Int) {
        note = max(0, min(127, note + delta))
    }
    
    /// Adjust probability
    mutating func adjustProbability(by delta: Int) {
        probability = max(0, min(100, probability + delta))
    }
    
    /// Adjust ratchet/repeat count
    mutating func adjustRepeat(by delta: Int) {
        repeat_ = max(0, min(8, repeat_ + delta))
    }
    
    /// Toggle step on/off
    mutating func toggle() {
        isOn.toggle()
    }
    
    /// Reset to default values
    mutating func reset() {
        isOn = false
        note = 60
        velocity = 100
        length = 24
        timing = 0
        probability = 100
        repeat_ = 0
        slide = false
        accent = false
    }
    
    // MARK: - Computed Properties
    
    /// Validated velocity (clamped to MIDI range)
    var validatedVelocity: Int {
        max(1, min(127, velocity))
    }
    
    /// Validated note (clamped to MIDI range)
    var validatedNote: Int {
        max(0, min(127, note))
    }
    
    /// Validated length
    var validatedLength: Int {
        max(1, min(96, length))
    }
    
    /// Note name (e.g., "C4", "F#3") - uses cached lookup for performance
    var noteName: String {
        NoteNameCache.shared.name(for: note)
    }
    
    /// Octave number
    var octave: Int {
        (note / 12) - 1
    }
    
    /// Note within octave (0-11)
    var noteInOctave: Int {
        note % 12
    }
    
    /// Velocity as percentage (0-100)
    var velocityPercent: Int {
        Int((Double(velocity) / 127.0) * 100)
    }
    
    /// Dynamic marking based on velocity
    var velocityDescription: String {
        switch velocity {
        case 1...20: return "ppp"
        case 21...40: return "pp"
        case 41...60: return "p"
        case 61...80: return "mp"
        case 81...95: return "mf"
        case 96...110: return "f"
        case 111...120: return "ff"
        case 121...127: return "fff"
        default: return "-"
        }
    }
    
    /// Length in musical notation
    var lengthDescription: String {
        switch length {
        case 1...6: return "1/64"
        case 7...12: return "1/32"
        case 13...18: return "1/16t"
        case 19...24: return "1/16"
        case 25...36: return "1/8t"
        case 37...48: return "1/8"
        case 49...72: return "1/4"
        case 73...96: return "1/2"
        default: return "\(length)t"
        }
    }
    
    /// Timing offset description
    var timingDescription: String {
        if timing == 0 { return "±0" }
        return timing > 0 ? "+\(timing)" : "\(timing)"
    }
    
    /// Whether probability is less than 100%
    var hasProbability: Bool {
        probability < 100
    }
    
    /// Whether step has ratchet/repeat
    var hasRatchet: Bool {
        repeat_ > 0
    }
    
    /// Whether step has microtiming offset
    var hasTimingOffset: Bool {
        timing != 0
    }
    
    // MARK: - Static Helpers
    
    /// All note names
    static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// Convert note name to MIDI note number
    static func noteNumber(from name: String, octave: Int) -> Int? {
        guard let index = noteNames.firstIndex(of: name.uppercased()) else { return nil }
        let midiNote = (octave + 1) * 12 + index
        guard midiNote >= 0 && midiNote <= 127 else { return nil }
        return midiNote
    }
    
    /// Create a copy with new ID
    func copy() -> StepModel {
        var newStep = self
        newStep.id = UUID()
        return newStep
    }
}
