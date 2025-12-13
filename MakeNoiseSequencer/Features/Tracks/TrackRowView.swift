import SwiftUI

struct TrackRowView: View {
    let track: TrackModel
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleMute: () -> Void
    let onToggleSolo: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            // Color dot
            ColorDot(color: track.color, isActive: !track.isMuted)
            
            // Track name
            Text(track.name)
                .font(DS.Font.monoM)
                .foregroundStyle(track.isMuted ? DS.Color.textMuted : DS.Color.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            // Mute/Solo buttons
            MuteSoloButtons(
                isMuted: track.isMuted,
                isSolo: track.isSolo,
                onToggleMute: onToggleMute,
                onToggleSolo: onToggleSolo
            )
        }
        .padding(.horizontal, DS.Space.s)
        .padding(.vertical, DS.Space.xs)
        .frame(minHeight: DS.Size.minTouch)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(isSelected ? DS.Color.selectedFill : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .stroke(isSelected ? DS.Color.selectedStroke : Color.clear, lineWidth: DS.Stroke.hairline)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}
