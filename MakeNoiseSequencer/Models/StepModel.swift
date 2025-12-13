import SwiftUI

struct StepModel: Identifiable, Equatable {
    let id: UUID
    var index: Int
    var isOn: Bool
    var note: Int          // MIDI note 0-127
    var velocity: Int      // 1-127
    var length: Int        // in ticks (1-96)
    var timing: Int        // microtiming offset (-48 to +48 ticks)
    var probability: Int   // 0-100%
    var repeat_: Int       // 0-8 repeats
    
    init(
        id: UUID = UUID(),
        index: Int,
        isOn: Bool = false,
        note: Int = 60,
        velocity: Int = 100,
        length: Int = 24,
        timing: Int = 0,
        probability: Int = 100,
        repeat_: Int = 0
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
    }
    
    // Clamp velocity to valid range
    mutating func adjustVelocity(by delta: Int) {
        velocity = max(1, min(127, velocity + delta))
    }
    
    // Clamp timing to valid range
    mutating func adjustTiming(by delta: Int) {
        timing = max(-48, min(48, timing + delta))
    }
}
