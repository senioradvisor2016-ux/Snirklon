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
