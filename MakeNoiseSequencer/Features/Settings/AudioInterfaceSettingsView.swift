import SwiftUI

struct AudioInterfaceSettingsView: View {
    @EnvironmentObject var store: SequencerStore
    @State private var showInterfaceList = false
    @State private var selectedTab: SettingsTab = .interface
    
    enum SettingsTab: String, CaseIterable {
        case interface = "INTERFACE"
        case cvTracks = "CV/ADSR"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            settingsHeader
            
            // Tab selector
            tabSelector
            
            ScrollView {
                VStack(spacing: DS.Space.l) {
                    switch selectedTab {
                    case .interface:
                        interfaceTabContent
                    case .cvTracks:
                        cvTracksTabContent
                    }
                }
                .padding(DS.Space.m)
            }
        }
        .frame(width: DS.Size.inspectorWidth + 80)
        .background(DS.Color.background)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(width: DS.Stroke.hairline),
            alignment: .leading
        )
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(DS.Font.monoS)
                        .foregroundStyle(selectedTab == tab ? DS.Color.textPrimary : DS.Color.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.s)
                        .background(selectedTab == tab ? DS.Color.surface2 : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    // MARK: - Interface Tab
    
    private var interfaceTabContent: some View {
        VStack(spacing: DS.Space.l) {
            interfaceSelectionSection
            
            Divider()
                .background(DS.Color.etchedLine)
            
            if store.selectedInterface.isDCCoupled {
                interfaceInfoSection
                
                Divider()
                    .background(DS.Color.etchedLine)
                
                cvOutputSection
            } else {
                acCoupledWarning
            }
        }
    }
    
    // MARK: - CV Tracks Tab
    
    private var cvTracksTabContent: some View {
        VStack(spacing: DS.Space.l) {
            if !store.selectedInterface.isDCCoupled {
                acCoupledWarning
            } else {
                cvTracksListSection
                
                if store.selectedCVTrack != nil {
                    Divider()
                        .background(DS.Color.etchedLine)
                    
                    cvTrackEditorSection
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var settingsHeader: some View {
        HStack {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 14))
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("CV/AUDIO SETTINGS")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Spacer()
            
            Button(action: { store.toggleSettings() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .frame(width: 28, height: 28)
        }
        .padding(.horizontal, DS.Space.m)
        .padding(.vertical, DS.Space.s)
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    // MARK: - Interface Selection
    
    private var interfaceSelectionSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("AUDIO INTERFACE")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            // Current selection button
            Button(action: { showInterfaceList.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.selectedInterface.name)
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                        
                        Text(store.selectedInterface.manufacturer)
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    
                    Spacer()
                    
                    // DC-coupled badge
                    if store.selectedInterface.isDCCoupled {
                        dcCoupledBadge
                    }
                    
                    Image(systemName: showInterfaceList ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .padding(DS.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .fill(DS.Color.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.m)
                                .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Interface list dropdown
            if showInterfaceList {
                interfaceListView
            }
        }
    }
    
    private var interfaceListView: some View {
        VStack(spacing: 0) {
            ForEach(AudioInterfaceModel.allPresets, id: \.id) { interface in
                Button(action: {
                    store.selectAudioInterface(interface)
                    showInterfaceList = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(interface.name)
                                .font(DS.Font.monoS)
                                .foregroundStyle(DS.Color.textPrimary)
                            
                            HStack(spacing: DS.Space.xs) {
                                Text(interface.manufacturer)
                                    .font(DS.Font.monoXS)
                                    .foregroundStyle(DS.Color.textMuted)
                                
                                Text("•")
                                    .foregroundStyle(DS.Color.textMuted)
                                
                                Text("\(interface.outputCount) out / \(interface.inputCount) in")
                                    .font(DS.Font.monoXS)
                                    .foregroundStyle(DS.Color.textMuted)
                            }
                        }
                        
                        Spacer()
                        
                        if interface.isDCCoupled {
                            Text("DC")
                                .font(DS.Font.monoXS)
                                .foregroundStyle(DS.Color.led)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(DS.Color.led.opacity(0.2))
                                )
                        }
                        
                        if store.selectedInterface.id == interface.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(DS.Color.led)
                        }
                    }
                    .padding(DS.Space.s)
                    .background(
                        store.selectedInterface.id == interface.id
                            ? DS.Color.surface2
                            : Color.clear
                    )
                }
                .buttonStyle(.plain)
                
                if interface.id != AudioInterfaceModel.allPresets.last?.id {
                    Divider()
                        .background(DS.Color.etchedLineSoft)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                )
        )
    }
    
    private var dcCoupledBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(DS.Color.led)
                .frame(width: 6, height: 6)
                .shadow(color: DS.Color.led.opacity(0.6), radius: 3)
            
            Text("DC")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.led)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(DS.Color.led.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(DS.Color.led.opacity(0.3), lineWidth: DS.Stroke.hairline)
                )
        )
    }
    
    // MARK: - Interface Info
    
    private var interfaceInfoSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("SPECIFICATIONS")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            HStack(spacing: DS.Space.l) {
                infoCard(label: "OUTPUTS", value: "\(store.selectedInterface.outputCount)")
                infoCard(label: "INPUTS", value: "\(store.selectedInterface.inputCount)")
                infoCard(label: "VOLTAGE", value: store.selectedInterface.voltageRange.rawValue)
            }
            
            // Features
            if !store.selectedInterface.features.isEmpty {
                Text("FEATURES")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                    .padding(.top, DS.Space.xs)
                
                FlowLayout(spacing: DS.Space.xxs) {
                    ForEach(store.selectedInterface.features, id: \.self) { feature in
                        Text(feature.rawValue)
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DS.Color.surface)
                            )
                    }
                }
            }
        }
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
    
    private func infoCard(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
            
            Text(label)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - CV Output Configuration
    
    private var cvOutputSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Text("CV OUTPUTS")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Button(action: { store.addCVConfig() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .frame(width: 28, height: 28)
                .background(DS.Color.surface)
                .clipShape(Circle())
            }
            
            if store.cvOutputConfigs.isEmpty {
                Text("No CV outputs configured")
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(DS.Space.m)
                    .background(PanelStyles.cutoutBackground())
            } else {
                ForEach(store.cvOutputConfigs) { config in
                    CVOutputConfigRow(config: config)
                }
            }
        }
    }
    
    // MARK: - CV Tracks List
    
    private var cvTracksListSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Text("ENVELOPE GENERATORS")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Button(action: { store.addCVTrack() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("ADD")
                            .font(DS.Font.monoXS)
                    }
                    .foregroundStyle(DS.Color.textSecondary)
                    .padding(.horizontal, DS.Space.s)
                    .padding(.vertical, DS.Space.xs)
                    .background(
                        Capsule()
                            .fill(DS.Color.surface)
                    )
                }
                .buttonStyle(.plain)
            }
            
            if store.cvTracks.isEmpty {
                VStack(spacing: DS.Space.s) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 24))
                        .foregroundStyle(DS.Color.textMuted)
                    
                    Text("No envelope generators")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    Text("Add an envelope generator to create ADSR CV signals")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DS.Space.l)
                .background(PanelStyles.cutoutBackground())
            } else {
                ForEach(store.cvTracks) { cvTrack in
                    CVTrackRow(cvTrack: cvTrack, isSelected: store.selectedCVTrackID == cvTrack.id)
                }
            }
        }
    }
    
    // MARK: - CV Track Editor
    
    private var cvTrackEditorSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            if let cvTrack = store.selectedCVTrack {
                // Header with track info
                HStack {
                    Text(cvTrack.name)
                        .font(DS.Font.monoM)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    Text("CH\(cvTrack.outputChannel)")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.led)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(DS.Color.led.opacity(0.2))
                        )
                    
                    Spacer()
                    
                    // Enable/Disable toggle
                    Button(action: { store.toggleCVTrackEnabled(cvTrack.id) }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(cvTrack.isEnabled ? DS.Color.led : DS.Color.textMuted)
                                .frame(width: 8, height: 8)
                            Text(cvTrack.isEnabled ? "ON" : "OFF")
                                .font(DS.Font.monoXS)
                        }
                        .foregroundStyle(cvTrack.isEnabled ? DS.Color.led : DS.Color.textMuted)
                    }
                    .buttonStyle(.plain)
                }
                
                // ADSR Editor
                ADSREditorView(
                    envelope: Binding(
                        get: { cvTrack.envelope },
                        set: { store.updateCVTrackEnvelope(cvTrack.id, envelope: $0) }
                    ),
                    height: 140
                )
                
                // Preset selector
                ADSRPresetSelector(
                    envelope: Binding(
                        get: { cvTrack.envelope },
                        set: { store.updateCVTrackEnvelope(cvTrack.id, envelope: $0) }
                    )
                )
                
                Divider()
                    .background(DS.Color.etchedLine)
                
                // Routing section
                routingSection(for: cvTrack)
                
                // Advanced settings
                advancedEnvelopeSettings(for: cvTrack)
            }
        }
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
    
    private func routingSection(for cvTrack: CVTrack) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("ROUTING")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            HStack(spacing: DS.Space.m) {
                // Source track selector
                VStack(alignment: .leading, spacing: DS.Space.xxs) {
                    Text("TRIGGER")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    Menu {
                        ForEach(store.currentPattern?.tracks ?? [], id: \.id) { track in
                            Button(action: { store.setCVTrackSource(cvTrack.id, sourceTrackID: track.id) }) {
                                HStack {
                                    Text(track.name)
                                    if cvTrack.sourceTrackID == track.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            if let sourceID = cvTrack.sourceTrackID,
                               let sourceTrack = store.currentPattern?.tracks.first(where: { $0.id == sourceID }) {
                                Circle()
                                    .fill(sourceTrack.color)
                                    .frame(width: 8, height: 8)
                                Text(sourceTrack.name)
                            } else {
                                Text("Select...")
                            }
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .padding(.horizontal, DS.Space.s)
                        .padding(.vertical, DS.Space.xs)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.s)
                                .fill(DS.Color.surface)
                        )
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Color.textMuted)
                
                // Destination selector
                VStack(alignment: .leading, spacing: DS.Space.xxs) {
                    Text("DESTINATION")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    Menu {
                        ForEach(ModulationDestination.allCases, id: \.self) { dest in
                            Button(action: { store.setCVTrackDestination(cvTrack.id, destination: dest) }) {
                                HStack {
                                    Text(dest.rawValue)
                                    if cvTrack.modulationDestination == dest {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(cvTrack.modulationDestination.rawValue)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .padding(.horizontal, DS.Space.s)
                        .padding(.vertical, DS.Space.xs)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.s)
                                .fill(DS.Color.surface)
                        )
                    }
                }
            }
        }
    }
    
    private func advancedEnvelopeSettings(for cvTrack: CVTrack) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("ADVANCED")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            // Curve selectors
            HStack(spacing: DS.Space.m) {
                CurveSelector(
                    label: "ATK CURVE",
                    curve: Binding(
                        get: { cvTrack.envelope.attackCurve },
                        set: { 
                            var env = cvTrack.envelope
                            env.attackCurve = $0
                            store.updateCVTrackEnvelope(cvTrack.id, envelope: env)
                        }
                    )
                )
                
                CurveSelector(
                    label: "DEC CURVE",
                    curve: Binding(
                        get: { cvTrack.envelope.decayCurve },
                        set: {
                            var env = cvTrack.envelope
                            env.decayCurve = $0
                            store.updateCVTrackEnvelope(cvTrack.id, envelope: env)
                        }
                    )
                )
                
                CurveSelector(
                    label: "REL CURVE",
                    curve: Binding(
                        get: { cvTrack.envelope.releaseCurve },
                        set: {
                            var env = cvTrack.envelope
                            env.releaseCurve = $0
                            store.updateCVTrackEnvelope(cvTrack.id, envelope: env)
                        }
                    )
                )
            }
            
            // Retrigger mode
            HStack(spacing: DS.Space.m) {
                VStack(alignment: .leading, spacing: DS.Space.xxs) {
                    Text("RETRIGGER")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    HStack(spacing: DS.Space.xxs) {
                        ForEach(RetriggerMode.allCases, id: \.self) { mode in
                            Button(action: {
                                var env = cvTrack.envelope
                                env.retriggerMode = mode
                                store.updateCVTrackEnvelope(cvTrack.id, envelope: env)
                            }) {
                                Text(mode.rawValue)
                                    .font(DS.Font.monoXS)
                                    .foregroundStyle(
                                        cvTrack.envelope.retriggerMode == mode
                                            ? DS.Color.textPrimary
                                            : DS.Color.textMuted
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                cvTrack.envelope.retriggerMode == mode
                                                    ? DS.Color.surface2
                                                    : DS.Color.surface
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
                
                // Velocity sensitivity
                VStack(alignment: .leading, spacing: DS.Space.xxs) {
                    Text("VEL SENS")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    Text("\(Int(cvTrack.envelope.velocitySensitivity * 100))%")
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                }
            }
        }
    }
    
    // MARK: - AC Coupled Warning
    
    private var acCoupledWarning: some View {
        VStack(spacing: DS.Space.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(DS.Color.textMuted)
            
            Text("AC-COUPLED INTERFACE")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("This interface cannot output DC signals for CV control. Select a DC-coupled interface like Expert Sleepers ES-9 to use CV outputs.")
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.l)
        .background(PanelStyles.cutoutBackground())
    }
}

// MARK: - CV Track Row

struct CVTrackRow: View {
    let cvTrack: CVTrack
    let isSelected: Bool
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        Button(action: { store.selectCVTrack(cvTrack.id) }) {
            HStack(spacing: DS.Space.s) {
                // Enable indicator
                Circle()
                    .fill(cvTrack.isEnabled ? DS.Color.led : DS.Color.textMuted.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .shadow(color: cvTrack.isEnabled ? DS.Color.led.opacity(0.6) : .clear, radius: 3)
                
                // Channel number
                Text("CH\(cvTrack.outputChannel)")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.led)
                    .frame(width: 32)
                
                // Track name
                Text(cvTrack.name)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Spacer()
                
                // Mini envelope preview
                ADSRCompactView(envelope: cvTrack.envelope, width: 60, height: 24)
                
                // Source track indicator
                if let sourceID = cvTrack.sourceTrackID,
                   let sourceTrack = store.currentPattern?.tracks.first(where: { $0.id == sourceID }) {
                    Text(sourceTrack.name)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(sourceTrack.color.opacity(0.3))
                        )
                }
                
                // Delete button
                Button(action: { store.removeCVTrack(cvTrack.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DS.Color.textMuted)
                }
                .frame(width: 24, height: 24)
            }
            .padding(DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(isSelected ? DS.Color.surface2 : DS.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .stroke(
                                isSelected ? DS.Color.selectedStroke : DS.Color.etchedLineSoft,
                                lineWidth: DS.Stroke.hairline
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CV Output Config Row

struct CVOutputConfigRow: View {
    let config: CVOutputConfig
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            // Channel number
            Text("CH\(config.outputChannel)")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.led)
                .frame(width: 40)
            
            // Output type
            Text(config.outputType.rawValue)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
            
            Spacer()
            
            // Track assignment indicator
            if let trackID = config.trackID,
               let track = store.currentPattern?.tracks.first(where: { $0.id == trackID }) {
                Text(track.name)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(track.color.opacity(0.3))
                    )
            }
            
            // Delete button
            Button(action: { store.removeCVConfig(config.id) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .frame(width: 24, height: 24)
        }
        .padding(DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
        )
    }
}

// MARK: - Flow Layout for Feature Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    AudioInterfaceSettingsView()
        .environmentObject(SequencerStore())
}
