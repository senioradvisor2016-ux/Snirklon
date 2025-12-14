import SwiftUI

/// Represents a DC-coupled audio interface for CV output
struct AudioInterfaceModel: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let manufacturer: String
    let outputCount: Int
    let inputCount: Int
    let isDCCoupled: Bool
    let voltageRange: VoltageRange
    let features: [InterfaceFeature]
    
    enum VoltageRange: String, CaseIterable {
        case unipolar5V = "0 to +5V"
        case unipolar10V = "0 to +10V"
        case bipolar5V = "-5V to +5V"
        case bipolar10V = "-10V to +10V"
        
        var minVoltage: Double {
            switch self {
            case .unipolar5V, .unipolar10V: return 0
            case .bipolar5V: return -5
            case .bipolar10V: return -10
            }
        }
        
        var maxVoltage: Double {
            switch self {
            case .unipolar5V, .bipolar5V: return 5
            case .unipolar10V, .bipolar10V: return 10
            }
        }
    }
    
    enum InterfaceFeature: String, CaseIterable {
        case cvOutput = "CV Out"
        case cvInput = "CV In"
        case gateOutput = "Gate Out"
        case gateInput = "Gate In"
        case clockSync = "Clock Sync"
        case midi = "MIDI"
        case adat = "ADAT"
        case spdif = "S/PDIF"
    }
}

// MARK: - Preset Interfaces

extension AudioInterfaceModel {
    
    /// Expert Sleepers ES-9
    static let es9 = AudioInterfaceModel(
        id: "expert-sleepers-es9",
        name: "ES-9",
        manufacturer: "Expert Sleepers",
        outputCount: 16,
        inputCount: 16,
        isDCCoupled: true,
        voltageRange: .bipolar10V,
        features: [.cvOutput, .cvInput, .gateOutput, .gateInput, .clockSync, .adat]
    )
    
    /// Expert Sleepers ES-8
    static let es8 = AudioInterfaceModel(
        id: "expert-sleepers-es8",
        name: "ES-8",
        manufacturer: "Expert Sleepers",
        outputCount: 8,
        inputCount: 4,
        isDCCoupled: true,
        voltageRange: .bipolar10V,
        features: [.cvOutput, .cvInput, .gateOutput, .gateInput, .adat]
    )
    
    /// Expert Sleepers ES-3
    static let es3 = AudioInterfaceModel(
        id: "expert-sleepers-es3",
        name: "ES-3 mk4",
        manufacturer: "Expert Sleepers",
        outputCount: 8,
        inputCount: 0,
        isDCCoupled: true,
        voltageRange: .bipolar10V,
        features: [.cvOutput, .gateOutput, .adat]
    )
    
    /// MOTU UltraLite mk5
    static let motuUltraliteMk5 = AudioInterfaceModel(
        id: "motu-ultralite-mk5",
        name: "UltraLite mk5",
        manufacturer: "MOTU",
        outputCount: 10,
        inputCount: 10,
        isDCCoupled: true,
        voltageRange: .bipolar5V,
        features: [.cvOutput, .midi, .adat, .spdif]
    )
    
    /// MOTU 828es
    static let motu828es = AudioInterfaceModel(
        id: "motu-828es",
        name: "828es",
        manufacturer: "MOTU",
        outputCount: 28,
        inputCount: 28,
        isDCCoupled: true,
        voltageRange: .bipolar5V,
        features: [.cvOutput, .midi, .adat, .spdif]
    )
    
    /// RME Fireface UCX II (partial DC coupling)
    static let rmeFirefaceUcxII = AudioInterfaceModel(
        id: "rme-fireface-ucx-ii",
        name: "Fireface UCX II",
        manufacturer: "RME",
        outputCount: 20,
        inputCount: 20,
        isDCCoupled: true,
        voltageRange: .bipolar5V,
        features: [.cvOutput, .midi, .adat, .spdif]
    )
    
    /// Frap Tools CGM (Creative Mixer with DC outputs)
    static let frapToolsCGM = AudioInterfaceModel(
        id: "frap-tools-cgm",
        name: "CGM Creative Mixer",
        manufacturer: "Frap Tools",
        outputCount: 8,
        inputCount: 8,
        isDCCoupled: true,
        voltageRange: .bipolar10V,
        features: [.cvOutput, .cvInput]
    )
    
    /// Generic/None - standard AC-coupled interface
    static let genericAC = AudioInterfaceModel(
        id: "generic-ac",
        name: "Standard Audio Interface",
        manufacturer: "Generic",
        outputCount: 2,
        inputCount: 2,
        isDCCoupled: false,
        voltageRange: .bipolar5V,
        features: []
    )
    
    /// Custom interface
    static func custom(
        name: String,
        outputs: Int,
        inputs: Int,
        voltageRange: VoltageRange
    ) -> AudioInterfaceModel {
        AudioInterfaceModel(
            id: "custom-\(UUID().uuidString)",
            name: name,
            manufacturer: "Custom",
            outputCount: outputs,
            inputCount: inputs,
            isDCCoupled: true,
            voltageRange: voltageRange,
            features: [.cvOutput, .cvInput, .gateOutput, .gateInput]
        )
    }
    
    /// All preset interfaces
    static let allPresets: [AudioInterfaceModel] = [
        .es9,
        .es8,
        .es3,
        .motuUltraliteMk5,
        .motu828es,
        .rmeFirefaceUcxII,
        .frapToolsCGM,
        .genericAC
    ]
    
    /// DC-coupled presets only
    static let dcCoupledPresets: [AudioInterfaceModel] = allPresets.filter { $0.isDCCoupled }
}

// MARK: - CV Output Configuration

struct CVOutputConfig: Identifiable, Equatable {
    let id: UUID
    var outputChannel: Int          // 1-based channel number
    var outputType: CVOutputType
    var trackID: UUID?              // Associated track
    var voltageScale: Double        // Scaling factor
    var voltageOffset: Double       // Offset in volts
    var slew: Double                // Slew rate limiting (0 = instant)
    
    enum CVOutputType: String, CaseIterable {
        case pitch = "Pitch (1V/Oct)"
        case gate = "Gate"
        case velocity = "Velocity"
        case modulation = "Modulation"
        case clock = "Clock"
        case trigger = "Trigger"
        case envelope = "Envelope"
        case lfo = "LFO"
    }
    
    init(
        id: UUID = UUID(),
        outputChannel: Int = 1,
        outputType: CVOutputType = .pitch,
        trackID: UUID? = nil,
        voltageScale: Double = 1.0,
        voltageOffset: Double = 0.0,
        slew: Double = 0.0
    ) {
        self.id = id
        self.outputChannel = outputChannel
        self.outputType = outputType
        self.trackID = trackID
        self.voltageScale = voltageScale
        self.voltageOffset = voltageOffset
        self.slew = slew
    }
}
