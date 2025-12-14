import SwiftUI

struct TransportBarView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.l) {
            // Play/Stop
            TransportControls()
            
            Spacer()
            
            // BPM
            bpmControl
            
            // Swing (Advanced mode only)
            if store.features.showSwing {
                swingControl
            }
            
            Spacer()
            
            // Current step display
            stepDisplay
            
            // Mode toggle
            ModeToggleButton(modeManager: store.modeManager)
            
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
    
    private var bpmControl: some View {
        HStack(spacing: DS.Space.xs) {
            Text(Iconography.Label.bpm)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("\(store.bpm)")
                .font(DS.Font.monoL)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(minWidth: 44)
            
            VStack(spacing: 2) {
                Button(action: { store.setBPM(store.bpm + 1) }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                }
                Button(action: { store.setBPM(store.bpm - 1) }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .foregroundStyle(DS.Color.textSecondary)
        }
        .modifier(PanelStyles.panelButtonModifier(isOn: false))
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
