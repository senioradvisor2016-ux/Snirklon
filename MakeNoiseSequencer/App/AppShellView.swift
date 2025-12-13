import SwiftUI

struct AppShellView: View {
    @EnvironmentObject var store: SequencerStore
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        ZStack {
            // Panel background
            PanelStyles.panelBackground()
            
            // Navigation structure
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // Sidebar: Track list
                TrackSidebarView()
                    .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
            } detail: {
                // Main content: Performance view with grid + transport
                PerformanceView()
            }
            .navigationSplitViewStyle(.balanced)
        }
        .onAppear {
            // Ensure we have a track selected
            if store.selection.selectedTrackID == nil,
               let firstTrack = store.currentPattern?.tracks.first {
                store.selectTrack(firstTrack.id)
            }
        }
    }
}

#Preview {
    AppShellView()
        .environmentObject(SequencerStore())
}
