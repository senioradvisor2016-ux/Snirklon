import SwiftUI

/// Undo/Redo history dropdown view
struct UndoHistoryView: View {
    @EnvironmentObject var store: SequencerStore
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            // Header
            HStack {
                Text("HISTORIK")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            Divider()
                .background(DS.Color.etchedLine)
            
            // Undo/Redo buttons
            HStack(spacing: DS.Space.m) {
                undoButton
                redoButton
            }
            
            Divider()
                .background(DS.Color.etchedLine)
            
            // Recent actions
            if store.undoHistory.isEmpty {
                Text("Ingen historik")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DS.Space.m)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        ForEach(Array(store.undoHistory.enumerated()), id: \.offset) { index, action in
                            historyRow(action: action, index: index)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(DS.Space.m)
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                )
                .shadow(color: .black.opacity(0.3), radius: 10)
        )
    }
    
    private var undoButton: some View {
        Button(action: {
            store.performUndo()
            HapticEngine.light()
        }) {
            HStack(spacing: DS.Space.xs) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12))
                Text("Ångra")
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(store.canUndo ? DS.Color.textPrimary : DS.Color.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.xs)
            .background(DS.Color.surface2)
            .cornerRadius(DS.Radius.s)
        }
        .buttonStyle(.plain)
        .disabled(!store.canUndo)
    }
    
    private var redoButton: some View {
        Button(action: {
            store.performRedo()
            HapticEngine.light()
        }) {
            HStack(spacing: DS.Space.xs) {
                Text("Gör om")
                    .font(DS.Font.monoXS)
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 12))
            }
            .foregroundStyle(store.canRedo ? DS.Color.textPrimary : DS.Color.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.xs)
            .background(DS.Color.surface2)
            .cornerRadius(DS.Radius.s)
        }
        .buttonStyle(.plain)
        .disabled(!store.canRedo)
    }
    
    private func historyRow(action: UndoAction, index: Int) -> some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: action.icon)
                .font(.system(size: 10))
                .foregroundStyle(DS.Color.textMuted)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(action.name)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(1)
                
                Text(action.timestamp)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            Spacer()
            
            // Undo to this point
            if index > 0 {
                Button(action: {
                    store.undoToAction(at: index)
                    HapticEngine.medium()
                }) {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Color.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DS.Space.xxs)
        .padding(.horizontal, DS.Space.xs)
        .background(
            index == 0 ? DS.Color.surface2.opacity(0.5) : Color.clear
        )
        .cornerRadius(4)
    }
}

/// Represents an undoable action
struct UndoAction: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let date: Date
    
    var timestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    static func toggle() -> UndoAction {
        UndoAction(name: "Växla steg", icon: "square.fill", date: Date())
    }
    
    static func velocityChange() -> UndoAction {
        UndoAction(name: "Velocity ändrad", icon: "speaker.wave.2", date: Date())
    }
    
    static func noteChange() -> UndoAction {
        UndoAction(name: "Not ändrad", icon: "music.note", date: Date())
    }
    
    static func humanize() -> UndoAction {
        UndoAction(name: "Humanisera", icon: "wand.and.stars", date: Date())
    }
    
    static func euclidean() -> UndoAction {
        UndoAction(name: "Euclidean", icon: "circle.hexagongrid", date: Date())
    }
    
    static func clearTrack() -> UndoAction {
        UndoAction(name: "Rensa spår", icon: "trash", date: Date())
    }
    
    static func clearPattern() -> UndoAction {
        UndoAction(name: "Rensa mönster", icon: "trash.fill", date: Date())
    }
    
    static func paste() -> UndoAction {
        UndoAction(name: "Klistra in", icon: "doc.on.clipboard", date: Date())
    }
    
    static func reorderTracks() -> UndoAction {
        UndoAction(name: "Omordna spår", icon: "arrow.up.arrow.down", date: Date())
    }
}

/// Compact undo/redo buttons for transport bar
struct UndoRedoButtons: View {
    @EnvironmentObject var store: SequencerStore
    @State private var showHistory: Bool = false
    
    var body: some View {
        HStack(spacing: DS.Space.xxs) {
            // Undo
            Button(action: {
                store.performUndo()
                HapticEngine.light()
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12))
                    .foregroundStyle(store.canUndo ? DS.Color.textSecondary : DS.Color.textMuted.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(!store.canUndo)
            .tooltip("Ångra", shortcut: "⌘Z")
            
            // Redo
            Button(action: {
                store.performRedo()
                HapticEngine.light()
            }) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 12))
                    .foregroundStyle(store.canRedo ? DS.Color.textSecondary : DS.Color.textMuted.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(!store.canRedo)
            .tooltip("Gör om", shortcut: "⌘⇧Z")
            
            // History dropdown
            Button(action: { showHistory.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 12))
                    .foregroundStyle(showHistory ? DS.Color.led : DS.Color.textMuted)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showHistory, arrowEdge: .bottom) {
                UndoHistoryView(isPresented: $showHistory)
                    .environmentObject(store)
            }
            .tooltip("Undo-historik")
        }
        .padding(.horizontal, DS.Space.xs)
        .background(DS.Color.surface)
        .cornerRadius(DS.Radius.s)
    }
}
