import SwiftUI

struct InspectorStepSection: View {
    @EnvironmentObject var store: SequencerStore
    @State private var showAdvanced: Bool = false
    
    var body: some View {
        VStack(spacing: DS.Space.m) {
            // Section header
            HStack {
                Text("STEP")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                if let step = store.selectedStep {
                    HStack(spacing: DS.Space.xs) {
                        Text(step.noteName)
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textPrimary)
                        
                        Text("#\(step.index + 1)")
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
            }
            
            if let step = store.selectedStep {
                VStack(spacing: DS.Space.s) {
                    // Note with note name display
                    HStack {
                        SteppedValueControl(
                            label: Iconography.Label.note,
                            value: step.note,
                            min: 0,
                            max: 127,
                            step: 1,
                            onChange: { store.setStepNote(step.id, note: $0) }
                        )
                        
                        // Octave shortcuts
                        HStack(spacing: 2) {
                            ForEach([-12, -1, 1, 12], id: \.self) { delta in
                                Button(action: {
                                    let newNote = max(0, min(127, step.note + delta))
                                    store.setStepNote(step.id, note: newNote)
                                }) {
                                    Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                        .font(DS.Font.monoXS)
                                        .foregroundStyle(DS.Color.textMuted)
                                        .frame(width: 28, height: 24)
                                        .background(DS.Color.surface)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Velocity with dynamic marking
                    HStack {
                        SteppedValueControl(
                            label: Iconography.Label.vel,
                            value: step.velocity,
                            min: 1,
                            max: 127,
                            step: 1,
                            onChange: { store.setStepVelocity(step.id, velocity: $0) }
                        )
                        
                        Text(step.velocityDescription)
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textMuted)
                            .frame(width: 30)
                    }
                    
                    // Length with musical notation
                    HStack {
                        SteppedValueControl(
                            label: Iconography.Label.len,
                            value: step.length,
                            min: 1,
                            max: 96,
                            step: 6,
                            onChange: { store.setStepLength(step.id, length: $0) }
                        )
                        
                        Text(step.lengthDescription)
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textMuted)
                            .frame(width: 40)
                    }
                    
                    Divider()
                        .background(DS.Color.etchedLineSoft)
                    
                    // Probability
                    SteppedValueControl(
                        label: Iconography.Label.prob,
                        value: step.probability,
                        min: 0,
                        max: 100,
                        step: 10,
                        suffix: "%",
                        onChange: { store.setStepProbability(step.id, probability: $0) }
                    )
                    
                    // Ratchet / Repeat
                    SteppedValueControl(
                        label: "RATCHET",
                        value: step.repeat_,
                        min: 0,
                        max: 8,
                        step: 1,
                        onChange: { store.setStepRepeat(step.id, repeatCount: $0) }
                    )
                    
                    // Advanced section toggle
                    Button(action: { withAnimation(DS.Anim.fast) { showAdvanced.toggle() } }) {
                        HStack {
                            Text("ADVANCED")
                                .font(DS.Font.monoXS)
                                .foregroundStyle(DS.Color.textMuted)
                            Spacer()
                            Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(DS.Color.textMuted)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showAdvanced {
                        VStack(spacing: DS.Space.s) {
                            // Timing offset
                            SteppedValueControl(
                                label: "TIMING",
                                value: step.timing,
                                min: -48,
                                max: 48,
                                step: 1,
                                onChange: { store.adjustTiming(for: step.id, delta: $0 - step.timing) }
                            )
                            
                            // Toggles row
                            HStack(spacing: DS.Space.s) {
                                // Slide toggle would need store method
                                ToggleChip(
                                    label: "SLIDE",
                                    isOn: step.slide,
                                    onToggle: { /* TODO: Add slide toggle to store */ }
                                )
                                
                                ToggleChip(
                                    label: "ACCENT",
                                    isOn: step.accent,
                                    onToggle: { /* TODO: Add accent toggle to store */ }
                                )
                            }
                        }
                    }
                    
                    Divider()
                        .background(DS.Color.etchedLineSoft)
                    
                    // On/Off toggle
                    ToggleChip(
                        label: "ACTIVE",
                        isOn: step.isOn,
                        onToggle: { store.toggleStep(step.id) }
                    )
                }
            }
        }
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
}

// MARK: - Multi-Step Inspector

struct InspectorMultiStepSection: View {
    @EnvironmentObject var store: SequencerStore
    @State private var commonVelocity: Int = 100
    @State private var commonNote: Int = 60
    @State private var commonProbability: Int = 100
    
    var body: some View {
        VStack(spacing: DS.Space.m) {
            // Section header
            HStack {
                Text("MULTI-STEP")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Text("\(store.selection.selectedStepIDs.count) selected")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            VStack(spacing: DS.Space.s) {
                // Set velocity for all
                HStack {
                    Text("SET VEL")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .frame(width: 60, alignment: .leading)
                    
                    Slider(value: Binding(
                        get: { Double(commonVelocity) },
                        set: { commonVelocity = Int($0) }
                    ), in: 1...127, step: 1)
                    .tint(DS.Color.accent)
                    
                    Text("\(commonVelocity)")
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .frame(width: 30)
                }
                
                Button(action: { store.setVelocityForSelection(commonVelocity) }) {
                    Text("APPLY VELOCITY")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(DS.Space.xs)
                        .background(DS.Color.surface)
                        .cornerRadius(DS.Radius.s)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .background(DS.Color.etchedLineSoft)
                
                // Quick actions
                HStack(spacing: DS.Space.xs) {
                    quickActionButton(label: "HUMANIZE", icon: "wand.and.stars") {
                        store.humanizeSelection()
                    }
                    
                    quickActionButton(label: "TOGGLE", icon: "square.on.square") {
                        store.toggleSteps(store.selection.selectedStepIDs)
                    }
                }
            }
        }
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
    
    private func quickActionButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(DS.Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(DS.Space.s)
            .background(DS.Color.surface)
            .cornerRadius(DS.Radius.s)
        }
        .buttonStyle(.plain)
    }
}
