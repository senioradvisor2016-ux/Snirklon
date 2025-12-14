import SwiftUI
import Combine

/// MIDI Learn system for hardware controller mapping
class MIDILearnManager: ObservableObject {
    @Published var isLearning: Bool = false
    @Published var learningParameter: MIDILearnParameter?
    @Published var mappings: [MIDIMapping] = []
    @Published var lastReceivedCC: MIDIControlChange?
    @Published var midiDevices: [MIDIDevice] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMappings()
        scanMIDIDevices()
    }
    
    // MARK: - Learning
    
    func startLearning(for parameter: MIDILearnParameter) {
        isLearning = true
        learningParameter = parameter
    }
    
    func cancelLearning() {
        isLearning = false
        learningParameter = nil
    }
    
    func receivedMIDI(channel: Int, cc: Int, value: Int) {
        let controlChange = MIDIControlChange(channel: channel, cc: cc, value: value)
        lastReceivedCC = controlChange
        
        if isLearning, let parameter = learningParameter {
            // Create or update mapping
            let mapping = MIDIMapping(
                parameter: parameter,
                channel: channel,
                cc: cc
            )
            
            // Remove existing mapping for this parameter
            mappings.removeAll { $0.parameter == parameter }
            
            // Add new mapping
            mappings.append(mapping)
            
            // End learning
            isLearning = false
            learningParameter = nil
            
            saveMappings()
        }
    }
    
    // MARK: - Mapping Management
    
    func removeMapping(for parameter: MIDILearnParameter) {
        mappings.removeAll { $0.parameter == parameter }
        saveMappings()
    }
    
    func clearAllMappings() {
        mappings.removeAll()
        saveMappings()
    }
    
    func mapping(for parameter: MIDILearnParameter) -> MIDIMapping? {
        mappings.first { $0.parameter == parameter }
    }
    
    // MARK: - Persistence
    
    private func saveMappings() {
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: "MIDIMappings")
        }
    }
    
    private func loadMappings() {
        if let data = UserDefaults.standard.data(forKey: "MIDIMappings"),
           let loaded = try? JSONDecoder().decode([MIDIMapping].self, from: data) {
            mappings = loaded
        }
    }
    
    // MARK: - Device Scanning
    
    func scanMIDIDevices() {
        // In a real implementation, this would use CoreMIDI
        // For now, we'll create some mock devices
        midiDevices = [
            MIDIDevice(id: "device1", name: "Arturia KeyStep", isConnected: true),
            MIDIDevice(id: "device2", name: "Novation LaunchControl", isConnected: true),
            MIDIDevice(id: "device3", name: "Korg nanoKONTROL", isConnected: false)
        ]
    }
}

// MARK: - Data Types

struct MIDIMapping: Identifiable, Codable, Equatable {
    let id: UUID
    let parameter: MIDILearnParameter
    let channel: Int
    let cc: Int
    var min: Int
    var max: Int
    var isInverted: Bool
    
    init(
        id: UUID = UUID(),
        parameter: MIDILearnParameter,
        channel: Int,
        cc: Int,
        min: Int = 0,
        max: Int = 127,
        isInverted: Bool = false
    ) {
        self.id = id
        self.parameter = parameter
        self.channel = channel
        self.cc = cc
        self.min = min
        self.max = max
        self.isInverted = isInverted
    }
    
    var displayName: String {
        "CH\(channel) CC\(cc)"
    }
}

struct MIDIControlChange {
    let channel: Int
    let cc: Int
    let value: Int
}

struct MIDIDevice: Identifiable {
    let id: String
    let name: String
    var isConnected: Bool
}

enum MIDILearnParameter: String, Codable, CaseIterable, Equatable {
    // Transport
    case play = "Play/Stop"
    case bpm = "BPM"
    case swing = "Swing"
    
    // Track
    case trackSelect = "Track Select"
    case trackMute = "Track Mute"
    case trackSolo = "Track Solo"
    case trackVolume = "Track Volume"
    
    // Step
    case stepVelocity = "Step Velocity"
    case stepLength = "Step Length"
    case stepProbability = "Step Probability"
    case stepTiming = "Step Timing"
    
    // Pattern
    case patternSelect = "Pattern Select"
    
    // ADSR
    case adsrAttack = "ADSR Attack"
    case adsrDecay = "ADSR Decay"
    case adsrSustain = "ADSR Sustain"
    case adsrRelease = "ADSR Release"
    
    // Knobs
    case knobA = "Knob A"
    case knobB = "Knob B"
    case knobC = "Knob C"
    case knobD = "Knob D"
    
    var category: String {
        switch self {
        case .play, .bpm, .swing:
            return "Transport"
        case .trackSelect, .trackMute, .trackSolo, .trackVolume:
            return "Track"
        case .stepVelocity, .stepLength, .stepProbability, .stepTiming:
            return "Step"
        case .patternSelect:
            return "Pattern"
        case .adsrAttack, .adsrDecay, .adsrSustain, .adsrRelease:
            return "ADSR"
        case .knobA, .knobB, .knobC, .knobD:
            return "Knobs"
        }
    }
    
    var icon: String {
        switch self {
        case .play: return "play.fill"
        case .bpm: return "metronome"
        case .swing: return "waveform.path"
        case .trackSelect: return "list.bullet"
        case .trackMute: return "speaker.slash"
        case .trackSolo: return "headphones"
        case .trackVolume: return "speaker.wave.2"
        case .stepVelocity: return "arrow.up.arrow.down"
        case .stepLength: return "ruler"
        case .stepProbability: return "percent"
        case .stepTiming: return "clock"
        case .patternSelect: return "square.grid.2x2"
        case .adsrAttack, .adsrDecay, .adsrSustain, .adsrRelease: return "waveform.path"
        case .knobA, .knobB, .knobC, .knobD: return "dial.low"
        }
    }
}

// MARK: - MIDI Learn View

struct MIDILearnIndicator: View {
    @ObservedObject var midiManager: MIDILearnManager
    let parameter: MIDILearnParameter
    
    var body: some View {
        HStack(spacing: 4) {
            if let mapping = midiManager.mapping(for: parameter) {
                // Has mapping
                Text(mapping.displayName)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.led)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(DS.Color.led.opacity(0.2))
                    )
            } else if midiManager.isLearning && midiManager.learningParameter == parameter {
                // Learning mode
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 6, height: 6)
                    Text("LEARN...")
                        .font(DS.Font.monoXS)
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.2))
                )
            }
        }
        .onTapGesture {
            if midiManager.mapping(for: parameter) != nil {
                // Remove existing
                midiManager.removeMapping(for: parameter)
            } else {
                // Start learning
                midiManager.startLearning(for: parameter)
            }
        }
    }
}
