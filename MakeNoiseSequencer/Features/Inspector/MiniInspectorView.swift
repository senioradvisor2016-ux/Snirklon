import SwiftUI

/// Compact inspector that appears above selected step
/// Provides quick access to common step parameters without opening full inspector
struct MiniInspectorView: View {
    @EnvironmentObject var store: SequencerStore
    let step: StepModel
    let trackColor: Color
    let onDismiss: () -> Void
    let onOpenFullInspector: () -> Void
    
    @State private var localVelocity: Double
    @State private var localNote: Double
    
    init(step: StepModel, trackColor: Color, onDismiss: @escaping () -> Void, onOpenFullInspector: @escaping () -> Void) {
        self.step = step
        self.trackColor = trackColor
        self.onDismiss = onDismiss
        self.onOpenFullInspector = onOpenFullInspector
        self._localVelocity = State(initialValue: Double(step.velocity))
        self._localNote = State(initialValue: Double(step.note))
    }
    
    var body: some View {
        VStack(spacing: DS.Space.s) {
            // Header with step info and close button
            HStack {
                // Step indicator
                HStack(spacing: DS.Space.xs) {
                    Circle()
                        .fill(trackColor)
                        .frame(width: 8, height: 8)
                    
                    Text("STEG \(step.index + 1)")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textSecondary)
                }
                
                Spacer()
                
                // Note name
                Text(step.noteName)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Spacer()
                
                // Actions
                HStack(spacing: DS.Space.xs) {
                    // Open full inspector
                    Button(action: onOpenFullInspector) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Color.textMuted)
                    }
                    .buttonStyle(.plain)
                    
                    // Close
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DS.Color.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Quick controls
            HStack(spacing: DS.Space.m) {
                // Note control
                VStack(spacing: 2) {
                    Text("NOT")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    HStack(spacing: 4) {
                        Button(action: { adjustNote(-1) }) {
                            Image(systemName: "minus")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                        
                        Text("\(Int(localNote))")
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textPrimary)
                            .frame(width: 30)
                        
                        Button(action: { adjustNote(1) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundStyle(DS.Color.textSecondary)
                }
                
                // Velocity slider
                VStack(spacing: 2) {
                    HStack {
                        Text("VEL")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                        Spacer()
                        Text("\(Int(localVelocity))")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textPrimary)
                    }
                    
                    Slider(value: $localVelocity, in: 1...127, step: 1)
                        .tint(trackColor)
                        .onChange(of: localVelocity) { _, newValue in
                            store.setStepVelocity(step.id, velocity: Int(newValue))
                        }
                }
                .frame(maxWidth: 120)
                
                // Toggle on/off
                Button(action: { store.toggleStep(step.id) }) {
                    Image(systemName: step.isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(step.isOn ? trackColor : DS.Color.textMuted)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(step.isOn ? trackColor.opacity(0.2) : DS.Color.surface)
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Quick octave buttons
            HStack(spacing: DS.Space.xs) {
                ForEach([-12, -1, 1, 12], id: \.self) { delta in
                    Button(action: { adjustNote(delta) }) {
                        Text(delta > 0 ? "+\(delta)" : "\(delta)")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(DS.Color.surface)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.background)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(trackColor.opacity(0.3), lineWidth: DS.Stroke.thin)
                )
                .shadow(color: .black.opacity(0.3), radius: 10)
        )
        .frame(width: 240)
    }
    
    private func adjustNote(_ delta: Int) {
        let newNote = max(0, min(127, Int(localNote) + delta))
        localNote = Double(newNote)
        store.setStepNote(step.id, note: newNote)
        HapticEngine.selection()
    }
}

/// Floating action button for opening inspector
struct InspectorFAB: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18))
                .foregroundStyle(DS.Color.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(DS.Color.surface)
                        .shadow(color: .black.opacity(0.2), radius: 8)
                )
                .overlay(
                    Circle()
                        .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Step action bar that appears when step is selected
struct StepActionBar: View {
    @EnvironmentObject var store: SequencerStore
    let step: StepModel
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            // Toggle
            actionButton(
                icon: step.isOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                label: step.isOn ? "PÅ" : "AV",
                isActive: step.isOn
            ) {
                store.toggleStep(step.id)
            }
            
            Divider()
                .frame(height: 24)
            
            // Copy
            actionButton(icon: "doc.on.doc", label: "KOPIERA") {
                store.copySelectedSteps()
            }
            
            // Paste
            actionButton(icon: "doc.on.clipboard", label: "KLISTRA") {
                store.pasteSteps(startingAt: step.index)
            }
            
            Divider()
                .frame(height: 24)
            
            // Inspector
            actionButton(icon: "slider.horizontal.3", label: "REDIGERA") {
                store.openInspector()
            }
        }
        .padding(.horizontal, DS.Space.m)
        .padding(.vertical, DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .shadow(color: .black.opacity(0.2), radius: 8)
        )
    }
    
    private func actionButton(icon: String, label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(isActive ? DS.Color.led : DS.Color.textSecondary)
            .frame(width: 50)
        }
        .buttonStyle(.plain)
    }
}
