import SwiftUI

struct TrackSidebarView: View {
    @EnvironmentObject var store: SequencerStore
    @State private var editMode: EditMode = .inactive
    @State private var showColorPicker: Bool = false
    @State private var colorPickerTrackID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TRACKS")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                // Edit mode toggle
                Button(action: { 
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }) {
                    Image(systemName: editMode == .active ? "checkmark" : "arrow.up.arrow.down")
                        .font(.system(size: 12))
                        .foregroundStyle(editMode == .active ? DS.Color.led : DS.Color.textMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(editMode == .active ? "Klar med omordning" : "Ordna om spår")
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
            .background(DS.Color.surface)
            
            // Track list
            List {
                if let pattern = store.currentPattern {
                    ForEach(pattern.tracks) { track in
                        TrackRowView(
                            track: track,
                            isSelected: store.selection.selectedTrackID == track.id,
                            onSelect: { store.selectTrack(track.id) },
                            onToggleMute: { store.toggleMute(for: track.id) },
                            onToggleSolo: { store.toggleSolo(for: track.id) }
                        )
                        .listRowInsets(EdgeInsets(top: DS.Space.xxs, leading: DS.Space.xs, bottom: DS.Space.xxs, trailing: DS.Space.xs))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                colorPickerTrackID = track.id
                                showColorPicker = true
                            }) {
                                Label("Färg", systemImage: "paintpalette")
                            }
                            .tint(.purple)
                        }
                        .contextMenu {
                            trackContextMenu(for: track)
                        }
                    }
                    .onMove { indices, newOffset in
                        store.reorderTracks(from: indices, to: newOffset)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
        }
        .background(DS.Color.background)
        .sheet(isPresented: $showColorPicker) {
            if let trackID = colorPickerTrackID {
                TrackColorPickerSheet(trackID: trackID)
                    .presentationDetents([.height(280)])
            }
        }
    }
    
    @ViewBuilder
    private func trackContextMenu(for track: TrackModel) -> some View {
        Button(action: { store.selectTrack(track.id) }) {
            Label("Välj", systemImage: "checkmark.circle")
        }
        
        Divider()
        
        Button(action: { store.toggleMute(for: track.id) }) {
            Label(track.isMuted ? "Slå på" : "Tysta", systemImage: track.isMuted ? "speaker.wave.2" : "speaker.slash")
        }
        
        Button(action: { store.toggleSolo(for: track.id) }) {
            Label(track.isSolo ? "Ta bort Solo" : "Solo", systemImage: "s.circle")
        }
        
        Divider()
        
        Button(action: {
            colorPickerTrackID = track.id
            showColorPicker = true
        }) {
            Label("Ändra färg", systemImage: "paintpalette")
        }
        
        Divider()
        
        Button(action: {
            store.selectTrack(track.id)
            store.copyTrack()
        }) {
            Label("Kopiera spår", systemImage: "doc.on.doc")
        }
        
        Button(action: {
            store.selectTrack(track.id)
            store.clearTrack()
        }) {
            Label("Rensa spår", systemImage: "trash")
        }
    }
}

// MARK: - Track Color Picker Sheet

struct TrackColorPickerSheet: View {
    let trackID: UUID
    @EnvironmentObject var store: SequencerStore
    @Environment(\.dismiss) private var dismiss
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint,
        .cyan, .blue, .indigo, .purple, .pink,
        Color(red: 1.0, green: 0.4, blue: 0.4), // Light red
        Color(red: 1.0, green: 0.8, blue: 0.4), // Gold
        Color(red: 0.6, green: 0.8, blue: 0.4), // Lime
        Color(red: 0.4, green: 0.8, blue: 0.8), // Teal
        Color(red: 0.8, green: 0.6, blue: 1.0), // Lavender
    ]
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Header
            HStack {
                Text("VÄLJ FÄRG")
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            // Current track preview
            if let track = store.currentPattern?.tracks.first(where: { $0.id == trackID }) {
                HStack {
                    Circle()
                        .fill(track.color)
                        .frame(width: 24, height: 24)
                    
                    Text(track.name)
                        .font(DS.Font.monoM)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    Spacer()
                }
                .padding(DS.Space.s)
                .background(DS.Color.surface)
                .cornerRadius(DS.Radius.s)
            }
            
            // Color grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Space.s), count: 5), spacing: DS.Space.s) {
                ForEach(colors, id: \.self) { color in
                    colorButton(color)
                }
            }
            
            Spacer()
        }
        .padding(DS.Space.l)
        .background(DS.Color.background)
    }
    
    private func colorButton(_ color: Color) -> some View {
        let isSelected = store.currentPattern?.tracks.first(where: { $0.id == trackID })?.color == color
        
        return Button(action: {
            store.setTrackColor(trackID, color: color)
            HapticEngine.selection()
            dismiss()
        }) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(isSelected ? 1 : 0)
                )
                .shadow(color: color.opacity(0.5), radius: isSelected ? 8 : 0)
        }
        .buttonStyle(.plain)
    }
}
