import SwiftUI

struct PatternSlotView: View {
    let pattern: PatternModel
    let isSelected: Bool
    let onSelect: () -> Void
    
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Cutout background
                PanelStyles.cutoutBackground(cornerRadius: DS.Radius.s)
                
                // Selected state
                if isSelected {
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .fill(DS.Color.selectedFill)
                }
                
                // Playing LED ring
                if isSelected && store.isPlaying {
                    PanelStyles.ledRing(cornerRadius: DS.Radius.s,
                                        color: DS.Color.led,
                                        lineWidth: DS.Stroke.thin,
                                        glow: 0.6)
                }
                
                // Queued indicator
                if pattern.isQueued && !pattern.isPlaying {
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .stroke(DS.Color.ledSoft, style: StrokeStyle(lineWidth: DS.Stroke.thin, dash: [4, 4]))
                }
                
                // Label
                VStack(spacing: 2) {
                    Text(pattern.name)
                        .font(DS.Font.monoM)
                        .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textSecondary)
                    
                    // Track activity indicators
                    HStack(spacing: 2) {
                        ForEach(pattern.tracks.prefix(4)) { track in
                            Circle()
                                .fill(track.color.opacity(track.isMuted ? 0.3 : 0.7))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 56, height: 48)
        }
        .buttonStyle(.plain)
    }
}
