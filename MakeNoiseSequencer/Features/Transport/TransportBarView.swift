import SwiftUI

struct TransportBarView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.l) {
            // Play/Stop
            TransportControls()
            
            // Undo/Redo buttons
            UndoRedoButtons()
            
            Spacer()
            
            // BPM
            bpmControl
            
            // Swing (Advanced mode only)
            if store.features.showSwing {
                swingControl
            }
            
            Spacer()
            
            // Save indicator
            saveIndicator
            
            // Current step display
            stepDisplay
            
            // Mode toggle
            ModeToggleButton(modeManager: store.modeManager)
            
            // Keyboard shortcuts button
            Button(action: { store.toggleKeyboardShortcuts() }) {
                Image(systemName: "keyboard")
                    .font(.system(size: 14))
                    .foregroundStyle(store.showKeyboardShortcuts ? DS.Color.led : DS.Color.textMuted)
            }
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(store.showKeyboardShortcuts ? DS.Color.surface2 : Color.clear)
            )
            
            // Latency indicator (Advanced mode only)
            if store.features.showAudioInterface {
                LatencyIndicator()
            }
            
            // Audio Interface / CV Settings button (Advanced mode only)
            if store.features.showAudioInterface {
                audioInterfaceButton
            }
            
            // Help button
            helpButton
        }
        .padding(.horizontal, DS.Space.l)
        .frame(height: DS.Size.transportHeight)
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    // MARK: - BPM Control
    
    @State private var showBPMInput: Bool = false
    @State private var bpmInputValue: String = ""
    
    private var bpmControl: some View {
        HStack(spacing: DS.Space.s) {
            // Minus-knapp med 44×44pt touch target
            Button(action: { store.setBPM(store.bpm - 1) }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: DS.Size.minTouch, height: DS.Size.minTouch)
                    .background(DS.Color.surface2)
                    .cornerRadius(DS.Radius.s)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in startBPMDecrement() }
            )
            .accessibilityLabel("Minska tempo")
            .accessibilityHint("Håll nedtryckt för snabb minskning")
            
            // BPM-värde (tappbart för direktinmatning)
            Button(action: { 
                bpmInputValue = "\(store.bpm)"
                showBPMInput = true 
            }) {
                VStack(spacing: 2) {
                    Text(Iconography.Label.bpm)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    Text("\(store.bpm)")
                        .font(DS.Font.monoL)
                        .foregroundStyle(DS.Color.textPrimary)
                }
                .frame(minWidth: 56)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tempo \(store.bpm) slag per minut")
            .accessibilityHint("Dubbelklicka för att ange exakt värde")
            
            // Plus-knapp med 44×44pt touch target
            Button(action: { store.setBPM(store.bpm + 1) }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: DS.Size.minTouch, height: DS.Size.minTouch)
                    .background(DS.Color.surface2)
                    .cornerRadius(DS.Radius.s)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in startBPMIncrement() }
            )
            .accessibilityLabel("Öka tempo")
            .accessibilityHint("Håll nedtryckt för snabb ökning")
        }
        .modifier(PanelStyles.panelButtonModifier(isOn: false))
        .alert("Ange BPM", isPresented: $showBPMInput) {
            TextField("BPM", text: $bpmInputValue)
                .keyboardType(.numberPad)
            Button("OK") {
                if let newBPM = Int(bpmInputValue) {
                    store.setBPM(newBPM)
                }
            }
            Button("Avbryt", role: .cancel) { }
        } message: {
            Text("Ange tempo (20-300 BPM)")
        }
    }
    
    @State private var bpmTimer: Timer?
    
    private func startBPMIncrement() {
        HapticEngine.light()
        bpmTimer?.invalidate()
        bpmTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if store.bpm < 300 {
                store.setBPM(store.bpm + 1)
                HapticEngine.tick()
            }
        }
    }
    
    private func startBPMDecrement() {
        HapticEngine.light()
        bpmTimer?.invalidate()
        bpmTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if store.bpm > 20 {
                store.setBPM(store.bpm - 1)
                HapticEngine.tick()
            }
        }
    }
    
    // MARK: - Swing Control
    
    private var swingControl: some View {
        HStack(spacing: DS.Space.xs) {
            Text(Iconography.Label.swing)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("\(store.swing)%")
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(minWidth: 44)
        }
        .modifier(PanelStyles.panelButtonModifier(isOn: false))
    }
    
    // MARK: - Step Display
    
    private var stepDisplay: some View {
        HStack(spacing: DS.Space.xs) {
            Text("STEP")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text(String(format: "%02d", store.currentStep + 1))
                .font(DS.Font.monoL)
                .foregroundStyle(store.isPlaying ? DS.Color.led : DS.Color.textPrimary)
        }
        .modifier(PanelStyles.panelButtonModifier(isOn: store.isPlaying))
    }
    
    // MARK: - Save Indicator
    
    private var saveIndicator: some View {
        HStack(spacing: 4) {
            if store.isSaving {
                ProgressView()
                    .scaleEffect(0.6)
                    .tint(DS.Color.textMuted)
                Text("Sparar...")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            } else if store.hasUnsavedChanges {
                Circle()
                    .fill(DS.Color.led)
                    .frame(width: 6, height: 6)
                Text("Ej sparat")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            } else if let lastSave = store.lastSaveTime {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.green.opacity(0.7))
                Text(timeAgo(lastSave))
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
        .frame(minWidth: 60)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 5 {
            return "Sparat"
        } else if seconds < 60 {
            return "\(seconds)s sedan"
        } else {
            return "\(seconds / 60)m sedan"
        }
    }
    
    // MARK: - Audio Interface Button
    
    private var audioInterfaceButton: some View {
        Button(action: { store.toggleSettings() }) {
            HStack(spacing: DS.Space.xs) {
                // DC indicator
                if store.selectedInterface.isDCCoupled {
                    Circle()
                        .fill(DS.Color.led)
                        .frame(width: 6, height: 6)
                        .shadow(color: DS.Color.led.opacity(0.6), radius: 3)
                }
                
                Text(store.selectedInterface.name)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .modifier(PanelStyles.panelButtonModifier(isOn: store.showSettings))
    }
    
    // MARK: - Help Button
    
    private var helpButton: some View {
        Button(action: { store.toggleHelp() }) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 16))
                .foregroundStyle(store.showHelp ? DS.Color.led : DS.Color.textSecondary)
        }
        .frame(width: 36, height: 36)
        .background(
            Circle()
                .fill(store.showHelp ? DS.Color.surface2 : DS.Color.surface)
        )
    }
}
