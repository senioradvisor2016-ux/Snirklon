import SwiftUI

struct MuteSoloButtons: View {
    let isMuted: Bool
    let isSolo: Bool
    let onToggleMute: () -> Void
    let onToggleSolo: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.xxs) {
            // Mute button
            Button(action: onToggleMute) {
                Image(systemName: Iconography.SF.mute)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isMuted ? DS.Color.led : DS.Color.textMuted)
            }
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(isMuted ? DS.Color.surface2 : Color.clear)
            )
            
            // Solo button
            Button(action: onToggleSolo) {
                Image(systemName: Iconography.SF.solo)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSolo ? DS.Color.led : DS.Color.textMuted)
            }
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(isSolo ? DS.Color.surface2 : Color.clear)
            )
        }
    }
}
