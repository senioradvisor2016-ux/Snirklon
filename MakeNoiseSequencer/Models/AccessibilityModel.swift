import SwiftUI

/// Accessibility settings and VoiceOver support
class AccessibilityManager: ObservableObject {
    @Published var settings: AccessibilitySettings {
        didSet {
            saveSettings()
        }
    }
    
    init() {
        self.settings = AccessibilityManager.loadSettings()
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "AccessibilitySettings")
        }
    }
    
    private static func loadSettings() -> AccessibilitySettings {
        if let data = UserDefaults.standard.data(forKey: "AccessibilitySettings"),
           let settings = try? JSONDecoder().decode(AccessibilitySettings.self, from: data) {
            return settings
        }
        return AccessibilitySettings()
    }
}

struct AccessibilitySettings: Codable {
    var reduceMotion: Bool = false
    var increaseContrast: Bool = false
    var largerText: Bool = false
    var boldText: Bool = false
    var voiceOverHints: Bool = true
    var hapticFeedback: Bool = true
    var audioFeedback: Bool = false
    var colorBlindMode: ColorBlindMode = .none
    var customTextScale: Double = 1.0
    
    enum ColorBlindMode: String, Codable, CaseIterable {
        case none = "Normal"
        case protanopia = "Protanopia (röd)"
        case deuteranopia = "Deuteranopia (grön)"
        case tritanopia = "Tritanopia (blå)"
        
        var description: String {
            switch self {
            case .none: return "Standardfärger"
            case .protanopia: return "Optimerat för röd-grön färgblindhet (typ 1)"
            case .deuteranopia: return "Optimerat för röd-grön färgblindhet (typ 2)"
            case .tritanopia: return "Optimerat för blå-gul färgblindhet"
            }
        }
    }
}

// MARK: - Accessibility Labels

enum A11yLabel {
    // Transport
    static let playButton = "Spela"
    static let stopButton = "Stoppa"
    static let bpmControl = "Tempo, %d slag per minut"
    static let swingControl = "Swing, %d procent"
    
    // Grid
    static func step(index: Int, track: String, isOn: Bool, velocity: Int) -> String {
        let state = isOn ? "aktivt" : "inaktivt"
        return "Steg \(index + 1) på spår \(track), \(state), velocity \(velocity)"
    }
    
    static func track(name: String, isMuted: Bool, isSolo: Bool) -> String {
        var state = ""
        if isMuted { state += ", tystat" }
        if isSolo { state += ", solo" }
        return "Spår \(name)\(state)"
    }
    
    // Patterns
    static func pattern(index: Int, isPlaying: Bool) -> String {
        let state = isPlaying ? ", spelar nu" : ""
        return "Mönster \(index + 1)\(state)"
    }
    
    // ADSR
    static func adsrParameter(name: String, value: String) -> String {
        return "\(name), värde \(value)"
    }
    
    // Actions
    static let muteButton = "Tysta spår"
    static let soloButton = "Solo"
    static let inspectorButton = "Öppna inspektör"
    static let settingsButton = "Öppna inställningar"
    static let helpButton = "Öppna hjälp"
}

// MARK: - Accessibility Hints

enum A11yHint {
    static let step = "Dubbelklicka för att aktivera eller inaktivera. Dra vertikalt för att justera velocity."
    static let track = "Dubbelklicka för att välja spår"
    static let pattern = "Dubbelklicka för att byta mönster"
    static let bpm = "Dra vertikalt för att ändra tempo"
    static let knob = "Dra vertikalt för att justera värdet"
}

// MARK: - Accessible Modifier

struct AccessibleModifier: ViewModifier {
    let label: String
    let hint: String?
    let value: String?
    let traits: AccessibilityTraits
    
    init(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) {
        self.label = label
        self.hint = hint
        self.value = value
        self.traits = traits
    }
    
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
}

extension View {
    func accessible(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        modifier(AccessibleModifier(label: label, hint: hint, value: value, traits: traits))
    }
}

// MARK: - Accessibility Settings View

struct AccessibilitySettingsView: View {
    @ObservedObject var accessibilityManager: AccessibilityManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("TILLGÄNGLIGHET")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            // Visual
            settingsSection(title: "VISUELLT") {
                toggleRow("Ökad kontrast", binding: $accessibilityManager.settings.increaseContrast)
                toggleRow("Större text", binding: $accessibilityManager.settings.largerText)
                toggleRow("Fet text", binding: $accessibilityManager.settings.boldText)
                toggleRow("Reducerad rörelse", binding: $accessibilityManager.settings.reduceMotion)
                
                // Color blind mode
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("Färgblindhet")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    ForEach(AccessibilitySettings.ColorBlindMode.allCases, id: \.self) { mode in
                        colorBlindModeRow(mode)
                    }
                }
            }
            
            // Audio & Haptics
            settingsSection(title: "LJUD & HAPTIK") {
                toggleRow("Haptisk feedback", binding: $accessibilityManager.settings.hapticFeedback)
                toggleRow("Ljudfeedback", binding: $accessibilityManager.settings.audioFeedback)
            }
            
            // VoiceOver
            settingsSection(title: "VOICEOVER") {
                toggleRow("VoiceOver-tips", binding: $accessibilityManager.settings.voiceOverHints)
            }
        }
        .padding(DS.Space.m)
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(title)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            content()
        }
    }
    
    private func toggleRow(_ label: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(DS.Color.led)
        }
        .padding(DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
        )
    }
    
    private func colorBlindModeRow(_ mode: AccessibilitySettings.ColorBlindMode) -> some View {
        Button(action: { accessibilityManager.settings.colorBlindMode = mode }) {
            HStack {
                Text(mode.rawValue)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Spacer()
                
                if accessibilityManager.settings.colorBlindMode == mode {
                    Image(systemName: "checkmark")
                        .foregroundStyle(DS.Color.led)
                }
            }
            .padding(DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(accessibilityManager.settings.colorBlindMode == mode ? DS.Color.surface2 : DS.Color.surface)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    
    func trigger() {
        #if canImport(UIKit)
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
        #endif
    }
}
