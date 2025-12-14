import SwiftUI

struct PatternModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var index: Int         // 0-15 for pattern slot
    var tracks: [TrackModel]
    var isPlaying: Bool
    var isQueued: Bool
    
    init(
        id: UUID = UUID(),
        name: String = "PATTERN",
        index: Int = 0,
        tracks: [TrackModel] = [],
        isPlaying: Bool = false,
        isQueued: Bool = false
    ) {
        self.id = id
        self.name = name
        self.index = index
        self.tracks = tracks
        self.isPlaying = isPlaying
        self.isQueued = isQueued
    }
    
    // Create a default pattern with mock tracks
    // Using 64 steps (maximum supported by Cirklon)
    static func createDefault(index: Int = 0) -> PatternModel {
        let trackNames = ["KICK", "SNARE", "HAT", "BASS"]
        let tracks = trackNames.enumerated().map { i, name in
            var track = TrackModel(
                name: name,
                color: TrackModel.trackColors[i % TrackModel.trackColors.count],
                midiChannel: i + 1,
                length: 64  // Maximum steps
            )
            // Add some default steps for visual interest (4 bars of 16 steps)
            if i == 0 { // Kick on beat 1 of each bar (steps 0, 16, 32, 48) and beat 3 (steps 8, 24, 40, 56)
                for bar in 0..<4 {
                    let barOffset = bar * 16
                    for stepIdx in [0, 4, 8, 12] {
                        track.steps[barOffset + stepIdx].isOn = true
                        track.steps[barOffset + stepIdx].velocity = 120
                    }
                }
            } else if i == 1 { // Snare on beats 2 and 4 of each bar
                for bar in 0..<4 {
                    let barOffset = bar * 16
                    for stepIdx in [4, 12] {
                        track.steps[barOffset + stepIdx].isOn = true
                        track.steps[barOffset + stepIdx].velocity = 110
                    }
                }
            } else if i == 2 { // Hi-hat on every other step across all 64 steps
                for stepIdx in stride(from: 0, to: 64, by: 2) {
                    track.steps[stepIdx].isOn = true
                    track.steps[stepIdx].velocity = stepIdx % 4 == 0 ? 100 : 70
                }
            }
            return track
        }
        
        return PatternModel(
            name: "P\(index + 1)",
            index: index,
            tracks: tracks
        )
    }
}
