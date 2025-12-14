import Foundation

/// Generates Euclidean rhythm patterns
/// Based on Bjorklund's algorithm for distributing pulses evenly across steps
///
/// Common patterns:
/// - E(3,8) = [x . . x . . x .] - Cuban tresillo
/// - E(4,12) = [x . . x . . x . . x . .] - West African bell pattern
/// - E(5,8) = [x . x x . x x .] - Cuban cinquillo
/// - E(7,16) = [x . x . x . x . x . x . x . x .] - Brazilian samba
struct EuclideanGenerator {
    
    /// Generate a Euclidean rhythm pattern
    /// - Parameters:
    ///   - steps: Total number of steps in the pattern
    ///   - pulses: Number of active (on) steps
    ///   - rotation: Offset rotation (default 0)
    /// - Returns: Array of booleans where true = active step
    static func generate(steps: Int, pulses: Int, rotation: Int = 0) -> [Bool] {
        guard steps > 0 else { return [] }
        guard pulses > 0 else { return Array(repeating: false, count: steps) }
        guard pulses <= steps else { return Array(repeating: true, count: steps) }
        
        // Bjorklund's algorithm
        var pattern = bjorklund(steps: steps, pulses: pulses)
        
        // Apply rotation
        let rot = ((rotation % steps) + steps) % steps
        if rot > 0 {
            pattern = Array(pattern.suffix(from: rot)) + Array(pattern.prefix(rot))
        }
        
        return pattern
    }
    
    /// Bjorklund's algorithm implementation
    private static func bjorklund(steps: Int, pulses: Int) -> [Bool] {
        var counts = [Int]()
        var remainders = [Int]()
        
        var divisor = steps - pulses
        remainders.append(pulses)
        var level = 0
        
        while remainders[level] > 1 {
            counts.append(divisor / remainders[level])
            let newRemainder = divisor % remainders[level]
            divisor = remainders[level]
            remainders.append(newRemainder)
            level += 1
        }
        counts.append(divisor)
        
        var pattern = [Bool]()
        build(level: level, counts: counts, remainders: remainders, pattern: &pattern)
        
        return pattern
    }
    
    private static func build(level: Int, counts: [Int], remainders: [Int], pattern: inout [Bool]) {
        if level == -1 {
            pattern.append(false)
        } else if level == -2 {
            pattern.append(true)
        } else {
            for _ in 0..<counts[level] {
                build(level: level - 1, counts: counts, remainders: remainders, pattern: &pattern)
            }
            if remainders[level] != 0 {
                build(level: level - 2, counts: counts, remainders: remainders, pattern: &pattern)
            }
        }
    }
    
    /// Generate pattern with velocity variations
    /// - Parameters:
    ///   - steps: Total steps
    ///   - pulses: Active steps
    ///   - rotation: Rotation offset
    ///   - accentEvery: Accent every N pulses (higher velocity)
    ///   - baseVelocity: Base velocity for non-accented steps
    ///   - accentVelocity: Velocity for accented steps
    /// - Returns: Array of optional velocities (nil = off, value = on with velocity)
    static func generateWithVelocity(
        steps: Int,
        pulses: Int,
        rotation: Int = 0,
        accentEvery: Int = 4,
        baseVelocity: Int = 80,
        accentVelocity: Int = 120
    ) -> [Int?] {
        let pattern = generate(steps: steps, pulses: pulses, rotation: rotation)
        var pulseCount = 0
        
        return pattern.map { isOn in
            guard isOn else { return nil }
            pulseCount += 1
            return (pulseCount % accentEvery == 1) ? accentVelocity : baseVelocity
        }
    }
    
    /// Get a description of the pattern
    static func patternString(steps: Int, pulses: Int, rotation: Int = 0) -> String {
        let pattern = generate(steps: steps, pulses: pulses, rotation: rotation)
        return pattern.map { $0 ? "●" : "○" }.joined(separator: " ")
    }
    
    /// Common preset patterns
    static let presets: [(name: String, steps: Int, pulses: Int)] = [
        ("Tresillo (3,8)", 8, 3),
        ("Cinquillo (5,8)", 8, 5),
        ("Son Clave (5,16)", 16, 5),
        ("Rumba Clave (5,16)", 16, 5),  // with rotation
        ("Samba (7,16)", 16, 7),
        ("Bossa Nova (5,16)", 16, 5),
        ("West African (4,12)", 12, 4),
        ("Aksak (2,5)", 5, 2),
        ("Sparse (3,16)", 16, 3),
        ("Dense (13,16)", 16, 13),
        ("Quarter Notes (4,16)", 16, 4),
        ("Eighth Notes (8,16)", 16, 8),
    ]
    
    /// Suggest complementary pattern for given pattern
    static func complementary(steps: Int, pulses: Int) -> (steps: Int, pulses: Int) {
        return (steps, steps - pulses)
    }
}

// MARK: - Pattern Transformations

extension EuclideanGenerator {
    
    /// Reverse the pattern
    static func reverse(_ pattern: [Bool]) -> [Bool] {
        return pattern.reversed()
    }
    
    /// Invert the pattern (swap on/off)
    static func invert(_ pattern: [Bool]) -> [Bool] {
        return pattern.map { !$0 }
    }
    
    /// Double the pattern length
    static func double(_ pattern: [Bool]) -> [Bool] {
        return pattern + pattern
    }
    
    /// Halve the pattern length (keep every other step)
    static func halve(_ pattern: [Bool]) -> [Bool] {
        return stride(from: 0, to: pattern.count, by: 2).map { pattern[$0] }
    }
    
    /// Shift pattern left
    static func shiftLeft(_ pattern: [Bool], by amount: Int = 1) -> [Bool] {
        guard !pattern.isEmpty else { return pattern }
        let shift = amount % pattern.count
        return Array(pattern.suffix(from: shift)) + Array(pattern.prefix(shift))
    }
    
    /// Shift pattern right
    static func shiftRight(_ pattern: [Bool], by amount: Int = 1) -> [Bool] {
        guard !pattern.isEmpty else { return pattern }
        let shift = amount % pattern.count
        return Array(pattern.suffix(shift)) + Array(pattern.prefix(pattern.count - shift))
    }
}
