import SwiftUI

struct TransportBarView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.l) {
            // Play/Stop
            TransportControls()
            
            Spacer()
            
            // BPM
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
            
            // Swing
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
            
            Spacer()
            
            // Current step display
            HStack(spacing: DS.Space.xs) {
                Text("STEP")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Text(String(format: "%02d", store.currentStep + 1))
                    .font(DS.Font.monoL)
                    .foregroundStyle(store.isPlaying ? DS.Color.led : DS.Color.textPrimary)
            }
            .modifier(PanelStyles.panelButtonModifier(isOn: store.isPlaying))
            
            // Audio Interface / CV Settings button
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
}
