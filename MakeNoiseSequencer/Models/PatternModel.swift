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
    static func createDefault(index: Int = 0) -> PatternModel {
        let trackNames = ["KICK", "SNARE", "HAT", "BASS"]
        let tracks = trackNames.enumerated().map { i, name in
            var track = TrackModel(
                name: name,
                color: TrackModel.trackColors[i % TrackModel.trackColors.count],
                midiChannel: i + 1,
                length: 16
            )
            // Add some default steps for visual interest
            if i == 0 { // Kick on 1, 5, 9, 13
                for stepIdx in [0, 4, 8, 12] {
                    track.steps[stepIdx].isOn = true
                    track.steps[stepIdx].velocity = 120
                }
            } else if i == 1 { // Snare on 5, 13
                for stepIdx in [4, 12] {
                    track.steps[stepIdx].isOn = true
                    track.steps[stepIdx].velocity = 110
                }
            } else if i == 2 { // Hi-hat on every other step
                for stepIdx in stride(from: 0, to: 16, by: 2) {
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
