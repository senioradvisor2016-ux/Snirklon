import SwiftUI

/// User interface mode - controls complexity level
enum UserMode: String, Codable, CaseIterable, Identifiable {
    case standard = "Standard"
    case advanced = "Advanced"
    
    var id: String { rawValue }
    
    /// Icon for the mode
    var icon: String {
        switch self {
        case .standard: return "square.grid.2x2"
        case .advanced: return "square.grid.4x3.fill"
        }
    }
    
    /// Description of what each mode offers
    var description: String {
        switch self {
        case .standard:
            return "Enklare gränssnitt med grundläggande funktioner. Perfekt för att komma igång."
        case .advanced:
            return "Fullständigt gränssnitt med alla funktioner: probability, ratchet, euclidean, CV/ADSR."
        }
    }
    
    /// Short tagline
    var tagline: String {
        switch self {
        case .standard: return "Enkelt & snabbt"
        case .advanced: return "Full kontroll"
        }
    }
}

/// Feature visibility based on mode
struct ModeFeatures {
    let mode: UserMode
    
    // MARK: - Step Features
    
    /// Show probability control
    var showProbability: Bool {
        mode == .advanced
    }
    
    /// Show ratchet/repeat control
    var showRatchet: Bool {
        mode == .advanced
    }
    
    /// Show timing/microtiming offset
    var showTiming: Bool {
        mode == .advanced
    }
    
    /// Show slide toggle
    var showSlide: Bool {
        mode == .advanced
    }
    
    /// Show accent toggle
    var showAccent: Bool {
        mode == .advanced
    }
    
    // MARK: - Grid Features
    
    /// Show grid toolbar with pattern operations
    var showGridToolbar: Bool {
        mode == .advanced
    }
    
    /// Enable drag-to-paint gesture
    var enablePaintMode: Bool {
        mode == .advanced
    }
    
    /// Show step indicators (P, R, timing)
    var showStepIndicators: Bool {
        mode == .advanced
    }
    
    // MARK: - Pattern Features
    
    /// Show Euclidean generator
    var showEuclidean: Bool {
        mode == .advanced
    }
    
    /// Show humanize function
    var showHumanize: Bool {
        mode == .advanced
    }
    
    /// Show pattern transformations (shift, reverse)
    var showTransformations: Bool {
        mode == .advanced
    }
    
    /// Show copy/paste for patterns
    var showCopyPaste: Bool {
        mode == .advanced
    }
    
    // MARK: - Track Features
    
    /// Show scale selection
    var showScales: Bool {
        mode == .advanced
    }
    
    /// Show root note selection
    var showRootNote: Bool {
        mode == .advanced
    }
    
    /// Maximum track length
    var maxTrackLength: Int {
        mode == .advanced ? 64 : 16
    }
    
    // MARK: - CV/Audio Features
    
    /// Show CV output configuration
    var showCVConfig: Bool {
        mode == .advanced
    }
    
    /// Show ADSR envelope editor
    var showADSR: Bool {
        mode == .advanced
    }
    
    /// Show audio interface selection
    var showAudioInterface: Bool {
        mode == .advanced
    }
    
    // MARK: - Transport Features
    
    /// Show swing control
    var showSwing: Bool {
        mode == .advanced
    }
    
    /// BPM range
    var bpmRange: ClosedRange<Int> {
        mode == .advanced ? 20...300 : 60...200
    }
    
    // MARK: - Inspector Features
    
    /// Show advanced inspector section
    var showAdvancedInspector: Bool {
        mode == .advanced
    }
    
    /// Show multi-step editing
    var showMultiStepEdit: Bool {
        mode == .advanced
    }
    
    // MARK: - Help Features
    
    /// Show keyboard shortcuts panel
    var showKeyboardShortcuts: Bool {
        mode == .advanced
    }
    
    /// Show tutorials
    var showTutorials: Bool {
        true // Always available
    }
    
    // MARK: - Other Features
    
    /// Show MIDI learn
    var showMIDILearn: Bool {
        mode == .advanced
    }
    
    /// Show export options
    var showExport: Bool {
        mode == .advanced
    }
    
    /// Show cloud sync
    var showCloudSync: Bool {
        mode == .advanced
    }
    
    /// Show themes beyond dark/light
    var showAdvancedThemes: Bool {
        mode == .advanced
    }
}

// MARK: - Mode Manager

@MainActor
class UserModeManager: ObservableObject {
    @Published var currentMode: UserMode {
        didSet {
            saveMode()
        }
    }
    
    /// Feature visibility helper
    var features: ModeFeatures {
        ModeFeatures(mode: currentMode)
    }
    
    /// Whether advanced mode is active
    var isAdvanced: Bool {
        currentMode == .advanced
    }
    
    /// Whether standard mode is active
    var isStandard: Bool {
        currentMode == .standard
    }
    
    private let userDefaultsKey = "userInterfaceMode"
    
    init() {
        // Load saved mode or default to standard
        if let savedMode = UserDefaults.standard.string(forKey: userDefaultsKey),
           let mode = UserMode(rawValue: savedMode) {
            self.currentMode = mode
        } else {
            self.currentMode = .standard
        }
    }
    
    func setMode(_ mode: UserMode) {
        currentMode = mode
        HapticEngine.medium()
    }
    
    func toggleMode() {
        currentMode = currentMode == .standard ? .advanced : .standard
        HapticEngine.medium()
    }
    
    private func saveMode() {
        UserDefaults.standard.set(currentMode.rawValue, forKey: userDefaultsKey)
    }
}

// MARK: - Mode Selector View

struct ModeSelectorView: View {
    @ObservedObject var modeManager: UserModeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Header
            VStack(spacing: DS.Space.s) {
                Text("VÄLJ LÄGE")
                    .font(DS.Font.monoL)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text("Anpassa gränssnittet efter din erfarenhetsnivå")
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Mode cards
            VStack(spacing: DS.Space.m) {
                modeCard(mode: .standard)
                modeCard(mode: .advanced)
            }
            
            // Current mode indicator
            HStack {
                Text("Aktivt läge:")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
                
                Text(modeManager.currentMode.rawValue.uppercased())
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.textPrimary)
            }
            .padding(.top, DS.Space.m)
            
            Spacer()
        }
        .padding(DS.Space.l)
        .background(DS.Color.background)
    }
    
    private func modeCard(mode: UserMode) -> some View {
        let isSelected = modeManager.currentMode == mode
        
        return Button(action: {
            modeManager.setMode(mode)
            dismiss()
        }) {
            VStack(alignment: .leading, spacing: DS.Space.m) {
                // Header row
                HStack {
                    Image(systemName: mode.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isSelected ? DS.Color.led : DS.Color.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.rawValue.uppercased())
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                        
                        Text(mode.tagline)
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(DS.Color.led)
                    }
                }
                
                // Description
                Text(mode.description)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Feature list
                featureList(for: mode)
            }
            .padding(DS.Space.m)
            .background(isSelected ? DS.Color.surface2 : DS.Color.surface)
            .cornerRadius(DS.Radius.m)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .stroke(isSelected ? DS.Color.led : DS.Color.etchedLine, lineWidth: isSelected ? DS.Stroke.thin : DS.Stroke.hairline)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func featureList(for mode: UserMode) -> some View {
        let features = ModeFeatures(mode: mode)
        
        let items: [(String, Bool)] = mode == .standard ? [
            ("Grundläggande stegsekvensering", true),
            ("4 mönster × 4 spår × 16 steg", true),
            ("Note, Velocity, Length", true),
            ("Play/Stop, BPM", true),
            ("Mute/Solo per spår", true),
        ] : [
            ("Allt i Standard +", true),
            ("64 steg per spår", true),
            ("Probability & Ratchet", true),
            ("Euclidean generator", true),
            ("Drag-to-paint", true),
            ("CV/Gate output", true),
            ("ADSR envelopes", true),
            ("MIDI Learn", true),
            ("Export MIDI/WAV", true),
        ]
        
        return VStack(alignment: .leading, spacing: DS.Space.xxs) {
            ForEach(items, id: \.0) { item in
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: item.1 ? "checkmark" : "xmark")
                        .font(.system(size: 10))
                        .foregroundStyle(item.1 ? DS.Color.accent : DS.Color.textMuted)
                    
                    Text(item.0)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
        }
    }
}

// MARK: - Compact Mode Toggle

struct ModeToggleButton: View {
    @ObservedObject var modeManager: UserModeManager
    @State private var showModeSelector = false
    
    var body: some View {
        Button(action: { showModeSelector = true }) {
            HStack(spacing: DS.Space.xs) {
                Image(systemName: modeManager.currentMode.icon)
                    .font(.system(size: 12))
                
                Text(modeManager.currentMode == .standard ? "STD" : "ADV")
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(modeManager.isAdvanced ? DS.Color.accent : DS.Color.textSecondary)
            .padding(.horizontal, DS.Space.s)
            .padding(.vertical, DS.Space.xs)
            .background(DS.Color.surface)
            .cornerRadius(DS.Radius.s)
        }
        .sheet(isPresented: $showModeSelector) {
            ModeSelectorView(modeManager: modeManager)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Quick Mode Switch

struct QuickModeSwitch: View {
    @ObservedObject var modeManager: UserModeManager
    
    var body: some View {
        HStack(spacing: 0) {
            modeButton(.standard)
            modeButton(.advanced)
        }
        .background(DS.Color.surface)
        .cornerRadius(DS.Radius.s)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
        )
    }
    
    private func modeButton(_ mode: UserMode) -> some View {
        let isSelected = modeManager.currentMode == mode
        
        return Button(action: { modeManager.setMode(mode) }) {
            Text(mode == .standard ? "STD" : "ADV")
                .font(DS.Font.monoS)
                .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textMuted)
                .padding(.horizontal, DS.Space.m)
                .padding(.vertical, DS.Space.s)
                .background(isSelected ? DS.Color.surface2 : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
