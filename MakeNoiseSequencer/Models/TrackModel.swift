import SwiftUI

struct TrackModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var color: Color
    var midiChannel: Int   // 1-16
    var isMuted: Bool
    var isSolo: Bool
    var length: Int        // pattern length in steps (1-64)
    var steps: [StepModel]
    
    init(
        id: UUID = UUID(),
        name: String,
        color: Color,
        midiChannel: Int = 1,
        isMuted: Bool = false,
        isSolo: Bool = false,
        length: Int = 16,
        steps: [StepModel]? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.midiChannel = max(1, min(16, midiChannel))
        self.isMuted = isMuted
        self.isSolo = isSolo
        self.length = max(1, min(64, length))
        self.steps = steps ?? (0..<length).map { StepModel(index: $0) }
    }
    
    // Track colors palette (Make Noise inspired - muted, industrial)
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
}
