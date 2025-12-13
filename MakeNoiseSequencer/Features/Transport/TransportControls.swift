import SwiftUI

struct TransportControls: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            // Play button
            Button(action: { store.play() }) {
                ZStack {
                    Image(systemName: Iconography.SF.play)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(store.isPlaying ? DS.Color.led : DS.Color.textPrimary)
                    
                    if store.isPlaying {
                        PanelStyles.ledGlow(color: DS.Color.led, intensity: 0.8)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .modifier(PanelStyles.panelButtonModifier(isOn: store.isPlaying))
            
            // Stop button
            Button(action: { store.stop() }) {
                Image(systemName: Iconography.SF.stop)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)
            }
            .modifier(PanelStyles.panelButtonModifier(isOn: false))
            
            // Record button (placeholder for now)
            Button(action: { /* TODO: implement record */ }) {
                Image(systemName: Iconography.SF.rec)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .modifier(PanelStyles.panelButtonModifier(isOn: false))
        }
    }
}
