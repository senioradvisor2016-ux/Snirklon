import SwiftUI

struct TrackModel: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var colorHex: String   // Store color as hex for Codable
    var midiChannel: Int   // 1-16
    var isMuted: Bool
    var isSolo: Bool
    var length: Int        // pattern length in steps (1-64)
    var steps: [StepModel]
    var rootNote: Int      // Root note for the track (default C3 = 48)
    var scale: ScaleType   // Scale type for note quantization
    
    /// SwiftUI Color computed from hex
    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        color: Color,
        midiChannel: Int = 1,
        isMuted: Bool = false,
        isSolo: Bool = false,
        length: Int = 16,
        steps: [StepModel]? = nil,
        rootNote: Int = 48,
        scale: ScaleType = .chromatic
    ) {
        self.id = id
        self.name = name
        self.colorHex = color.toHex()
        self.midiChannel = max(1, min(16, midiChannel))
        self.isMuted = isMuted
        self.isSolo = isSolo
        self.length = max(1, min(64, length))
        self.steps = steps ?? (0..<self.length).map { StepModel(index: $0) }
        self.rootNote = max(0, min(127, rootNote))
        self.scale = scale
    }
    
    // MARK: - Computed Properties
    
    /// Number of active (on) steps
    var activeStepCount: Int {
        steps.filter { $0.isOn }.count
    }
    
    /// Density as percentage
    var density: Int {
        guard length > 0 else { return 0 }
        return Int((Double(activeStepCount) / Double(length)) * 100)
    }
    
    /// Average velocity of active steps
    var averageVelocity: Int {
        let activeSteps = steps.filter { $0.isOn }
        guard !activeSteps.isEmpty else { return 0 }
        return activeSteps.reduce(0) { $0 + $1.velocity } / activeSteps.count
    }
    
    // MARK: - Mutations
    
    /// Clear all steps
    mutating func clearAllSteps() {
        for i in 0..<steps.count {
            steps[i].isOn = false
        }
    }
    
    /// Fill all steps
    mutating func fillAllSteps(velocity: Int = 100) {
        for i in 0..<steps.count {
            steps[i].isOn = true
            steps[i].velocity = velocity
        }
    }
    
    /// Set length and adjust steps array
    mutating func setLength(_ newLength: Int) {
        let validLength = max(1, min(64, newLength))
        if validLength > steps.count {
            // Add new steps
            for i in steps.count..<validLength {
                steps.append(StepModel(index: i))
            }
        } else if validLength < steps.count {
            // Remove extra steps
            steps = Array(steps.prefix(validLength))
        }
        length = validLength
    }
    
    /// Shift pattern left
    mutating func shiftLeft() {
        guard steps.count > 1 else { return }
        let first = steps.removeFirst()
        steps.append(first)
        // Update indices
        for i in 0..<steps.count {
            steps[i].index = i
        }
    }
    
    /// Shift pattern right
    mutating func shiftRight() {
        guard steps.count > 1 else { return }
        let last = steps.removeLast()
        steps.insert(last, at: 0)
        // Update indices
        for i in 0..<steps.count {
            steps[i].index = i
        }
    }
    
    /// Reverse pattern
    mutating func reverse() {
        steps.reverse()
        // Update indices
        for i in 0..<steps.count {
            steps[i].index = i
        }
    }
    
    /// Double pattern length
    mutating func double() {
        let originalSteps = steps
        for step in originalSteps {
            var newStep = step.copy()
            newStep.index = steps.count
            steps.append(newStep)
        }
        length = steps.count
    }
    
    /// Halve pattern (keep every other step)
    mutating func halve() {
        guard steps.count > 1 else { return }
        steps = stride(from: 0, to: steps.count, by: 2).map { steps[$0] }
        // Update indices
        for i in 0..<steps.count {
            steps[i].index = i
        }
        length = steps.count
    }
    
    /// Copy of track with new ID
    func copy() -> TrackModel {
        var newTrack = self
        newTrack.id = UUID()
        newTrack.steps = steps.map { $0.copy() }
        return newTrack
    }
    
    // MARK: - Track Colors
    
    /// Track colors palette (Make Noise inspired - muted, industrial)
    static let trackColors: [Color] = [
        Color(red: 0.75, green: 0.75, blue: 0.75),  // Silver
        Color(red: 0.85, green: 0.65, blue: 0.55),  // Copper
        Color(red: 0.70, green: 0.78, blue: 0.82),  // Ice blue
        Color(red: 0.82, green: 0.76, blue: 0.68),  // Tan
        Color(red: 0.65, green: 0.72, blue: 0.65),  // Sage
        Color(red: 0.78, green: 0.72, blue: 0.78),  // Mauve
        Color(red: 0.72, green: 0.68, blue: 0.62),  // Warm grey
        Color(red: 0.68, green: 0.75, blue: 0.75),  // Teal grey
    ]
    
    static let trackColorHexes: [String] = [
        "BFBFBF", // Silver
        "D9A68C", // Copper
        "B3C7D1", // Ice blue
        "D1C2AD", // Tan
        "A6B8A6", // Sage
        "C7B8C7", // Mauve
        "B8AE9E", // Warm grey
        "ADBFBF", // Teal grey
    ]
}

// MARK: - Scale Types

enum ScaleType: String, Codable, CaseIterable, Identifiable {
    case chromatic = "Chromatic"
    case major = "Major"
    case minor = "Minor"
    case pentatonicMajor = "Pentatonic Major"
    case pentatonicMinor = "Pentatonic Minor"
    case blues = "Blues"
    case dorian = "Dorian"
    case phrygian = "Phrygian"
    case lydian = "Lydian"
    case mixolydian = "Mixolydian"
    case harmonicMinor = "Harmonic Minor"
    case melodicMinor = "Melodic Minor"
    case wholeTone = "Whole Tone"
    case diminished = "Diminished"
    
    var id: String { rawValue }
    
    /// Intervals from root (in semitones)
    var intervals: [Int] {
        switch self {
        case .chromatic: return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        case .major: return [0, 2, 4, 5, 7, 9, 11]
        case .minor: return [0, 2, 3, 5, 7, 8, 10]
        case .pentatonicMajor: return [0, 2, 4, 7, 9]
        case .pentatonicMinor: return [0, 3, 5, 7, 10]
        case .blues: return [0, 3, 5, 6, 7, 10]
        case .dorian: return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian: return [0, 1, 3, 5, 7, 8, 10]
        case .lydian: return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian: return [0, 2, 4, 5, 7, 9, 10]
        case .harmonicMinor: return [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor: return [0, 2, 3, 5, 7, 9, 11]
        case .wholeTone: return [0, 2, 4, 6, 8, 10]
        case .diminished: return [0, 2, 3, 5, 6, 8, 9, 11]
        }
    }
    
    /// Quantize a note to this scale
    func quantize(_ note: Int, root: Int = 0) -> Int {
        let noteInOctave = (note - root) % 12
        let octave = (note - root) / 12
        
        // Find closest scale degree
        var closest = intervals[0]
        var minDist = abs(noteInOctave - intervals[0])
        
        for interval in intervals {
            let dist = min(abs(noteInOctave - interval), abs(noteInOctave - interval + 12))
            if dist < minDist {
                minDist = dist
                closest = interval
            }
        }
        
        return root + octave * 12 + closest
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (128, 128, 128)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
    
    /// Convert to hex string
    func toHex() -> String {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else {
            return "808080"
        }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components else {
            return "808080"
        }
        #else
        return "808080"
        #endif
        
        let r = Int(max(0, min(1, components[0])) * 255)
        let g = Int(max(0, min(1, components.count > 1 ? components[1] : components[0])) * 255)
        let b = Int(max(0, min(1, components.count > 2 ? components[2] : components[0])) * 255)
        
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
