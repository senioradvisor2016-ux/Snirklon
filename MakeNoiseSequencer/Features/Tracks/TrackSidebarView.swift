import SwiftUI

struct TrackSidebarView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TRACKS")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                Spacer()
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
            .background(DS.Color.surface)
            
            // Track list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DS.Space.xxs) {
                    if let pattern = store.currentPattern {
                        ForEach(pattern.tracks) { track in
                            TrackRowView(
                                track: track,
                                isSelected: store.selection.selectedTrackID == track.id,
                                onSelect: { store.selectTrack(track.id) },
                                onToggleMute: { store.toggleMute(for: track.id) },
                                onToggleSolo: { store.toggleSolo(for: track.id) }
                            )
                        }
                    }
                }
                .padding(DS.Space.xs)
            }
        }
        .background(DS.Color.background)
    }
}
