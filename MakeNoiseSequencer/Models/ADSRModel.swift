import SwiftUI

/// ADSR Envelope Generator Model
/// Generates control voltage envelopes for modular synthesis
struct ADSREnvelope: Identifiable, Equatable {
    let id: UUID
    var name: String
    
    // ADSR Parameters (all times in milliseconds, levels 0-1)
    var attack: Double          // Attack time (1-10000 ms)
    var decay: Double           // Decay time (1-10000 ms)
    var sustain: Double         // Sustain level (0-1)
    var release: Double         // Release time (1-10000 ms)
    
    // Advanced parameters
    var attackCurve: EnvelopeCurve
    var decayCurve: EnvelopeCurve
    var releaseCurve: EnvelopeCurve
    
    // Output scaling
    var peakLevel: Double       // Maximum output level (0-1)
    var velocitySensitivity: Double  // How much velocity affects peak (0-1)
    
    // Retrigger behavior
    var retriggerMode: RetriggerMode
    
    // Looping (for LFO-like behavior)
    var loopEnabled: Bool
    var loopPoint: LoopPoint
    
    init(
        id: UUID = UUID(),
        name: String = "ENV",
        attack: Double = 10,
        decay: Double = 100,
        sustain: Double = 0.7,
        release: Double = 200,
        attackCurve: EnvelopeCurve = .linear,
        decayCurve: EnvelopeCurve = .exponential,
        releaseCurve: EnvelopeCurve = .exponential,
        peakLevel: Double = 1.0,
        velocitySensitivity: Double = 0.5,
        retriggerMode: RetriggerMode = .reset,
        loopEnabled: Bool = false,
        loopPoint: LoopPoint = .sustain
    ) {
        self.id = id
        self.name = name
        self.attack = attack
        self.decay = decay
        self.sustain = sustain
        self.release = release
        self.attackCurve = attackCurve
        self.decayCurve = decayCurve
        self.releaseCurve = releaseCurve
        self.peakLevel = peakLevel
        self.velocitySensitivity = velocitySensitivity
        self.retriggerMode = retriggerMode
        self.loopEnabled = loopEnabled
        self.loopPoint = loopPoint
    }
    
    /// Total envelope time (excluding sustain hold)
    var totalTime: Double {
        attack + decay + release
    }
    
    /// Calculate envelope value at a given time (0 = gate on, negative = before gate)
    /// gateOn: true while gate is held, false after release
    func value(at time: Double, gateOn: Bool, velocity: Double = 1.0) -> Double {
        let velocityScale = 1.0 - velocitySensitivity + (velocitySensitivity * velocity)
        let peak = peakLevel * velocityScale
        
        if gateOn {
            // Attack phase
            if time < attack {
                let t = time / attack
                return peak * attackCurve.apply(t)
            }
            // Decay phase
            else if time < attack + decay {
                let t = (time - attack) / decay
                let decayAmount = (1.0 - sustain) * decayCurve.apply(t)
                return peak * (1.0 - decayAmount)
            }
            // Sustain phase
            else {
                return peak * sustain
            }
        } else {
            // Release phase (time is relative to gate off)
            if time < release {
                let t = time / release
                let startLevel = sustain  // Assumes release from sustain
                return peak * startLevel * (1.0 - releaseCurve.apply(t))
            }
            return 0
        }
    }
    
    /// Generate envelope points for visualization
    func generatePoints(resolution: Int = 100) -> [CGPoint] {
        var points: [CGPoint] = []
        let totalDuration = attack + decay + release
        let sustainDuration = totalDuration * 0.3  // Visual sustain period
        let fullDuration = attack + decay + sustainDuration + release
        
        for i in 0...resolution {
            let t = Double(i) / Double(resolution)
            let time = t * fullDuration
            
            let y: Double
            if time < attack + decay + sustainDuration {
                // Gate on phase
                y = value(at: min(time, attack + decay + sustainDuration), gateOn: true)
            } else {
                // Release phase
                let releaseTime = time - (attack + decay + sustainDuration)
                y = value(at: releaseTime, gateOn: false)
            }
            
            points.append(CGPoint(x: t, y: y))
        }
        
        return points
    }
}

// MARK: - Envelope Curve Types

enum EnvelopeCurve: String, CaseIterable, Equatable {
    case linear = "Linear"
    case exponential = "Exponential"
    case logarithmic = "Logarithmic"
    case sCurve = "S-Curve"
    
    /// Apply curve transformation to normalized value (0-1)
    func apply(_ t: Double) -> Double {
        let clamped = max(0, min(1, t))
        switch self {
        case .linear:
            return clamped
        case .exponential:
            // Faster start, slower end
            return clamped * clamped
        case .logarithmic:
            // Slower start, faster end
            return sqrt(clamped)
        case .sCurve:
            // Smooth S-curve (ease in-out)
            return clamped * clamped * (3 - 2 * clamped)
        }
    }
    
    var icon: String {
        switch self {
        case .linear: return "line.diagonal"
        case .exponential: return "arrow.down.right"
        case .logarithmic: return "arrow.up.right"
        case .sCurve: return "s.circle"
        }
    }
}

// MARK: - Retrigger Modes

enum RetriggerMode: String, CaseIterable, Equatable {
    case reset = "Reset"           // Jump to attack start
    case legato = "Legato"         // Continue from current level
    case none = "None"             // Ignore retrigger during envelope
    
    var description: String {
        switch self {
        case .reset: return "Restart envelope from zero"
        case .legato: return "Continue from current level"
        case .none: return "Ignore new triggers"
        }
    }
}

// MARK: - Loop Points

enum LoopPoint: String, CaseIterable, Equatable {
    case sustain = "Sustain"       // Loop at sustain (AD loop)
    case release = "End"           // Loop full ADSR
    case decay = "Decay"           // Loop attack-decay only
    
    var description: String {
        switch self {
        case .sustain: return "Loop Attack → Decay → Attack"
        case .release: return "Loop full envelope"
        case .decay: return "Loop Attack → Decay start"
        }
    }
}

// MARK: - Preset Envelopes

extension ADSREnvelope {
    
    /// Snappy percussive envelope
    static let percussion = ADSREnvelope(
        name: "PERC",
        attack: 1,
        decay: 150,
        sustain: 0,
        release: 100,
        attackCurve: .linear,
        decayCurve: .exponential
    )
    
    /// Plucky synth envelope
    static let pluck = ADSREnvelope(
        name: "PLUCK",
        attack: 5,
        decay: 300,
        sustain: 0.2,
        release: 200,
        attackCurve: .linear,
        decayCurve: .exponential
    )
    
    /// Pad/string envelope
    static let pad = ADSREnvelope(
        name: "PAD",
        attack: 500,
        decay: 1000,
        sustain: 0.8,
        release: 1500,
        attackCurve: .logarithmic,
        decayCurve: .exponential
    )
    
    /// Classic organ envelope
    static let organ = ADSREnvelope(
        name: "ORGAN",
        attack: 5,
        decay: 10,
        sustain: 1.0,
        release: 50,
        attackCurve: .linear,
        decayCurve: .linear
    )
    
    /// Slow attack swell
    static let swell = ADSREnvelope(
        name: "SWELL",
        attack: 2000,
        decay: 500,
        sustain: 0.7,
        release: 1000,
        attackCurve: .sCurve,
        decayCurve: .exponential
    )
    
    /// Snare-like envelope
    static let snare = ADSREnvelope(
        name: "SNARE",
        attack: 0.5,
        decay: 80,
        sustain: 0,
        release: 80,
        attackCurve: .linear,
        decayCurve: .exponential
    )
    
    /// Kick drum envelope
    static let kick = ADSREnvelope(
        name: "KICK",
        attack: 0.5,
        decay: 200,
        sustain: 0,
        release: 50,
        attackCurve: .linear,
        decayCurve: .exponential
    )
    
    /// AR envelope (no sustain, for triggers)
    static let ar = ADSREnvelope(
        name: "A/R",
        attack: 10,
        decay: 1,
        sustain: 1.0,
        release: 200,
        attackCurve: .linear,
        decayCurve: .linear,
        releaseCurve: .exponential
    )
    
    /// All presets
    static let presets: [ADSREnvelope] = [
        .percussion,
        .pluck,
        .pad,
        .organ,
        .swell,
        .snare,
        .kick,
        .ar
    ]
}

// MARK: - CV Track with ADSR

struct CVTrack: Identifiable, Equatable {
    let id: UUID
    var name: String
    var outputChannel: Int
    var envelope: ADSREnvelope
    var sourceTrackID: UUID?        // Which sequencer track triggers this
    var isEnabled: Bool
    
    // Modulation routing
    var modulationDestination: ModulationDestination
    var modulationAmount: Double    // -1 to 1
    
    init(
        id: UUID = UUID(),
        name: String = "CV 1",
        outputChannel: Int = 1,
        envelope: ADSREnvelope = ADSREnvelope(),
        sourceTrackID: UUID? = nil,
        isEnabled: Bool = true,
        modulationDestination: ModulationDestination = .vca,
        modulationAmount: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.outputChannel = outputChannel
        self.envelope = envelope
        self.sourceTrackID = sourceTrackID
        self.isEnabled = isEnabled
        self.modulationDestination = modulationDestination
        self.modulationAmount = modulationAmount
    }
}

enum ModulationDestination: String, CaseIterable, Equatable {
    case vca = "VCA"
    case vcf = "VCF"
    case vco = "VCO"
    case pwm = "PWM"
    case pan = "PAN"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .vca: return "Amplitude/Volume"
        case .vcf: return "Filter Cutoff"
        case .vco: return "Oscillator Pitch"
        case .pwm: return "Pulse Width"
        case .pan: return "Stereo Panning"
        case .custom: return "Custom Destination"
        }
    }
}
