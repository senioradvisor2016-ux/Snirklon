import SwiftUI

struct InspectorTrackSection: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: DS.Space.m) {
            // Section header
            HStack {
                Text("TRACK")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                if let track = store.selectedTrack {
                    ColorDot(color: track.color, isActive: !track.isMuted)
                }
            }
            
            if let track = store.selectedTrack {
                VStack(spacing: DS.Space.s) {
                    // Track name display
                    HStack {
                        Text("NAME")
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textSecondary)
                        Spacer()
                        Text(track.name)
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                    }
                    .padding(.vertical, DS.Space.xs)
                    
                    // MIDI Channel
                    HStack {
                        Text("CH")
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textSecondary)
                        Spacer()
                        Text("\(track.midiChannel)")
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                    }
                    .padding(.vertical, DS.Space.xs)
                    
                    // Length
                    HStack {
                        Text(Iconography.Label.len)
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textSecondary)
                        Spacer()
                        Text("\(track.length)")
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                    }
                    .padding(.vertical, DS.Space.xs)
                    
                    // Mute/Solo toggles
                    HStack(spacing: DS.Space.s) {
                        ToggleChip(
                            label: "MUTE",
                            isOn: track.isMuted,
                            onToggle: { store.toggleMute(for: track.id) }
                        )
                        
                        ToggleChip(
                            label: "SOLO",
                            isOn: track.isSolo,
                            onToggle: { store.toggleSolo(for: track.id) }
                        )
                    }
                }
            }
        }
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
}
