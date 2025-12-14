import SwiftUI

/// Comprehensive settings view with all features
struct SettingsView: View {
    @EnvironmentObject var store: SequencerStore
    @State private var selectedSection: SettingsSection = .general
    
    enum SettingsSection: String, CaseIterable {
        case general = "ALLMÄNT"
        case audio = "LJUD/CV"
        case midi = "MIDI"
        case appearance = "UTSEENDE"
        case accessibility = "TILLGÄNGLIGHET"
        case cloud = "MOLN"
        case about = "OM"
        
        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .audio: return "waveform"
            case .midi: return "pianokeys"
            case .appearance: return "paintbrush"
            case .accessibility: return "accessibility"
            case .cloud: return "icloud"
            case .about: return "info.circle"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            settingsSidebar
            
            // Content
            settingsContent
        }
        .frame(width: 700, height: 500)
        .background(DS.Color.background)
    }
    
    // MARK: - Sidebar
    
    private var settingsSidebar: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text("INSTÄLLNINGAR")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
                .padding(.horizontal, DS.Space.m)
                .padding(.top, DS.Space.m)
            
            ForEach(SettingsSection.allCases, id: \.self) { section in
                sectionButton(section)
            }
            
            Spacer()
            
            // Version
            Text("v1.0.0")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
                .padding(DS.Space.m)
        }
        .frame(width: 160)
        .background(DS.Color.surface)
    }
    
    private func sectionButton(_ section: SettingsSection) -> some View {
        Button(action: { selectedSection = section }) {
            HStack(spacing: DS.Space.s) {
                Image(systemName: section.icon)
                    .frame(width: 20)
                Text(section.rawValue)
                    .font(DS.Font.monoXS)
                Spacer()
            }
            .foregroundStyle(selectedSection == section ? DS.Color.textPrimary : DS.Color.textSecondary)
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
            .background(selectedSection == section ? DS.Color.surface2 : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Content
    
    private var settingsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                switch selectedSection {
                case .general:
                    generalSettings
                case .audio:
                    audioSettings
                case .midi:
                    midiSettings
                case .appearance:
                    appearanceSettings
                case .accessibility:
                    accessibilitySettings
                case .cloud:
                    cloudSettings
                case .about:
                    aboutSettings
                }
            }
            .padding(DS.Space.l)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - General Settings
    
    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            sectionHeader("Allmänna inställningar")
            
            // Tooltips
            settingToggle(
                title: "Visa tooltips",
                description: "Visa hjälptexter vid hovring",
                isOn: $store.tooltipsEnabled
            )
            
            // Auto-save
            settingToggle(
                title: "Auto-spara",
                description: "Spara ändringar automatiskt",
                isOn: .constant(true)
            )
            
            Divider()
            
            // Undo/Redo info
            sectionHeader("Ångra/Gör om")
            
            HStack {
                Text("Historikstorlek: 50 steg")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                
                Spacer()
                
                Button("Rensa historik") {
                    store.undoManager.clearHistory()
                }
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textSecondary)
            }
            
            // Undo/Redo status
            HStack(spacing: DS.Space.l) {
                VStack(alignment: .leading) {
                    Text("Kan ångra")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    Text(store.undoManager.canUndo ? "Ja" : "Nej")
                        .font(DS.Font.monoS)
                        .foregroundStyle(store.undoManager.canUndo ? .green : DS.Color.textMuted)
                }
                
                VStack(alignment: .leading) {
                    Text("Kan göra om")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    Text(store.undoManager.canRedo ? "Ja" : "Nej")
                        .font(DS.Font.monoS)
                        .foregroundStyle(store.undoManager.canRedo ? .green : DS.Color.textMuted)
                }
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
            )
        }
    }
    
    // MARK: - Audio Settings
    
    private var audioSettings: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            sectionHeader("Ljudkort & CV")
            
            // Current interface
            HStack {
                VStack(alignment: .leading) {
                    Text("Valt ljudkort")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    HStack {
                        if store.selectedInterface.isDCCoupled {
                            Circle()
                                .fill(DS.Color.led)
                                .frame(width: 8, height: 8)
                        }
                        Text(store.selectedInterface.name)
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                    }
                }
                
                Spacer()
                
                Button("Ändra") {
                    // Would open interface selector
                }
                .font(DS.Font.monoXS)
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
            )
            
            // CV tracks count
            HStack {
                Text("CV-spår: \(store.cvTracks.count)")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Text("\(store.selectedInterface.outputCount) utgångar tillgängliga")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
    }
    
    // MARK: - MIDI Settings
    
    private var midiSettings: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            sectionHeader("MIDI Learn")
            
            Text("Tilldela hårdvarukontroller till parametrar")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            // MIDI mappings
            if store.midiLearnManager.mappings.isEmpty {
                Text("Inga mappningar konfigurerade")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
                    .padding(DS.Space.m)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .fill(DS.Color.surface)
                    )
            } else {
                ForEach(store.midiLearnManager.mappings) { mapping in
                    midiMappingRow(mapping)
                }
            }
            
            // Clear all button
            if !store.midiLearnManager.mappings.isEmpty {
                Button("Rensa alla mappningar") {
                    store.midiLearnManager.clearAllMappings()
                }
                .font(DS.Font.monoXS)
                .foregroundStyle(.red)
            }
            
            Divider()
            
            // Available parameters
            sectionHeader("Tillgängliga parametrar")
            
            let categories = Set(MIDILearnParameter.allCases.map { $0.category })
            ForEach(Array(categories).sorted(), id: \.self) { category in
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(category)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    FlowLayout(spacing: DS.Space.xs) {
                        ForEach(MIDILearnParameter.allCases.filter { $0.category == category }, id: \.self) { param in
                            midiParamChip(param)
                        }
                    }
                }
            }
        }
    }
    
    private func midiMappingRow(_ mapping: MIDIMapping) -> some View {
        HStack {
            Image(systemName: mapping.parameter.icon)
                .foregroundStyle(DS.Color.led)
            
            Text(mapping.parameter.rawValue)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
            
            Spacer()
            
            Text(mapping.displayName)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(DS.Color.surface2))
            
            Button(action: { store.midiLearnManager.removeMapping(for: mapping.parameter) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
        .padding(DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
        )
    }
    
    private func midiParamChip(_ param: MIDILearnParameter) -> some View {
        Button(action: { store.midiLearnManager.startLearning(for: param) }) {
            HStack(spacing: 4) {
                Image(systemName: param.icon)
                    .font(.system(size: 10))
                Text(param.rawValue)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(
                store.midiLearnManager.mapping(for: param) != nil
                    ? DS.Color.led
                    : DS.Color.textSecondary
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        store.midiLearnManager.mapping(for: param) != nil
                            ? DS.Color.led.opacity(0.2)
                            : DS.Color.surface
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Appearance Settings
    
    private var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            sectionHeader("Utseende")
            
            ThemeSelectorView(themeManager: store.themeManager)
        }
    }
    
    // MARK: - Accessibility Settings
    
    private var accessibilitySettings: some View {
        AccessibilitySettingsView(accessibilityManager: store.accessibilityManager)
    }
    
    // MARK: - Cloud Settings
    
    private var cloudSettings: some View {
        CloudSyncSettingsView(cloudManager: store.cloudSyncManager)
    }
    
    // MARK: - About Settings
    
    private var aboutSettings: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            sectionHeader("Om MakeNoise Sequencer")
            
            VStack(alignment: .leading, spacing: DS.Space.m) {
                // Logo area
                HStack(spacing: DS.Space.m) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 40))
                        .foregroundStyle(DS.Color.led)
                    
                    VStack(alignment: .leading) {
                        Text("MakeNoise Sequencer")
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                        
                        Text("Version 1.0.0")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
                
                Text("En Cirklon-inspirerad 64-stegs sekvenser för modulärsyntar.")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Divider()
                
                // Features
                Text("FUNKTIONER")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    featureRow("64 steg (4 takter)")
                    featureRow("DC-kopplat CV-stöd")
                    featureRow("ADSR-envelopgenerator")
                    featureRow("MIDI Learn")
                    featureRow("iCloud-synk")
                    featureRow("Export till MIDI/WAV")
                }
                
                Divider()
                
                // Credits
                Text("TACK TILL")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                
                Text("Sequentix (Cirklon), Make Noise, Expert Sleepers")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(DS.Color.surface)
            )
        }
    }
    
    private func featureRow(_ text: String) -> some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: "checkmark")
                .font(.system(size: 10))
                .foregroundStyle(.green)
            Text(text)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(DS.Font.monoS)
            .foregroundStyle(DS.Color.textSecondary)
    }
    
    private func settingToggle(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                Text(description)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DS.Color.led)
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(SequencerStore())
}
