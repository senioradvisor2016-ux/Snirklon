import SwiftUI

struct PatternModel: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var index: Int         // 0-15 for pattern slot
    var tracks: [TrackModel]
    var isPlaying: Bool
    var isQueued: Bool
    var bpm: Int?          // Pattern-specific BPM (nil = use global)
    var swing: Int?        // Pattern-specific swing (nil = use global)
    var chainTo: Int?      // Next pattern to chain to (nil = loop self)
    
    init(
        id: UUID = UUID(),
        name: String = "PATTERN",
        index: Int = 0,
        tracks: [TrackModel] = [],
        isPlaying: Bool = false,
        isQueued: Bool = false,
        bpm: Int? = nil,
        swing: Int? = nil,
        chainTo: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.index = index
        self.tracks = tracks
        self.isPlaying = isPlaying
        self.isQueued = isQueued
        self.bpm = bpm
        self.swing = swing
        self.chainTo = chainTo
    }
    
    // MARK: - Computed Properties
    
    /// Maximum track length in this pattern
    var maxLength: Int {
        tracks.map { $0.length }.max() ?? 16
    }
    
    /// Total number of active steps across all tracks
    var totalActiveSteps: Int {
        tracks.reduce(0) { $0 + $1.activeStepCount }
    }
    
    /// Overall pattern density
    var density: Int {
        let total = tracks.reduce(0) { $0 + $1.steps.count }
        guard total > 0 else { return 0 }
        return Int((Double(totalActiveSteps) / Double(total)) * 100)
    }
    
    // MARK: - Mutations
    
    /// Clear all tracks
    mutating func clearAll() {
        for i in 0..<tracks.count {
            tracks[i].clearAllSteps()
        }
    }
    
    /// Set all tracks to same length
    mutating func setAllTracksLength(_ length: Int) {
        for i in 0..<tracks.count {
            tracks[i].setLength(length)
        }
    }
    
    /// Copy pattern with new ID
    func copy() -> PatternModel {
        var newPattern = self
        newPattern.id = UUID()
        newPattern.tracks = tracks.map { $0.copy() }
        return newPattern
    }
    
    // MARK: - Factory Methods
    
    /// Create a default pattern with mock tracks
    /// Using 64 steps (maximum supported by Cirklon)
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
            if i == 0 { // Kick on beat 1 of each bar
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
    
    /// Create an empty pattern
    static func createEmpty(index: Int = 0, trackCount: Int = 4, length: Int = 16) -> PatternModel {
        let tracks = (0..<trackCount).map { i in
            TrackModel(
                name: "TRK \(i + 1)",
                color: TrackModel.trackColors[i % TrackModel.trackColors.count],
                midiChannel: i + 1,
                length: length
            )
        }
        
        return PatternModel(
            name: "P\(index + 1)",
            index: index,
            tracks: tracks
        )
    }
    
    /// Create pattern from Euclidean generator
    static func createEuclidean(
        index: Int = 0,
        steps: Int = 16,
        pulsesPerTrack: [Int] = [4, 8, 12, 3]
    ) -> PatternModel {
        let trackNames = ["KICK", "SNARE", "HAT", "BASS"]
        
        let tracks = trackNames.enumerated().map { i, name in
            let pulses = i < pulsesPerTrack.count ? pulsesPerTrack[i] : 4
            let pattern = EuclideanGenerator.generate(steps: steps, pulses: pulses)
            
            var track = TrackModel(
                name: name,
                color: TrackModel.trackColors[i % TrackModel.trackColors.count],
                midiChannel: i + 1,
                length: steps
            )
            
            for (stepIdx, isOn) in pattern.enumerated() {
                track.steps[stepIdx].isOn = isOn
                if isOn {
                    track.steps[stepIdx].velocity = stepIdx % 4 == 0 ? 120 : 100
                }
            }
            
            return track
        }
        
        return PatternModel(
            name: "E\(index + 1)",
            index: index,
            tracks: tracks
        )
    }
}
