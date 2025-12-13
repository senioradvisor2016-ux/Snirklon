import SwiftUI

struct InspectorStepSection: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: DS.Space.m) {
            // Section header
            HStack {
                Text("STEP")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                if let step = store.selectedStep {
                    Text("#\(step.index + 1)")
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            if let step = store.selectedStep {
                VStack(spacing: DS.Space.s) {
                    // Note
                    SteppedValueControl(
                        label: Iconography.Label.note,
                        value: step.note,
                        min: 0,
                        max: 127,
                        step: 1,
                        onChange: { store.setStepNote(step.id, note: $0) }
                    )
                    
                    // Velocity
                    SteppedValueControl(
                        label: Iconography.Label.vel,
                        value: step.velocity,
                        min: 1,
                        max: 127,
                        step: 1,
                        onChange: { store.setStepVelocity(step.id, velocity: $0) }
                    )
                    
                    // Length
                    SteppedValueControl(
                        label: Iconography.Label.len,
                        value: step.length,
                        min: 1,
                        max: 96,
                        step: 6,
                        onChange: { store.setStepLength(step.id, length: $0) }
                    )
                    
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
