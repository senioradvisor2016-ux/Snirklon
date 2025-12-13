import SwiftUI

struct PerformanceView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Transport bar at top
            TransportBarView()
            
            // Main content
            HStack(spacing: 0) {
                // Main grid area
                VStack(spacing: 0) {
                    // Pattern launcher strip
                    PatternLauncherGridView()
                        .frame(height: 80)
                        .padding(.horizontal, DS.Space.m)
                        .background(DS.Color.surface)
                        .overlay(
                            Rectangle()
                                .fill(DS.Color.etchedLine)
                                .frame(height: DS.Stroke.hairline),
                            alignment: .bottom
                        )
                    
                    // Step grid
                    StepGridView()
                }
                
                // Inspector panel (conditionally shown)
                if store.selection.showInspector {
                    InspectorPanelView()
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .animation(DS.Anim.fast, value: store.selection.showInspector)
    }
}
