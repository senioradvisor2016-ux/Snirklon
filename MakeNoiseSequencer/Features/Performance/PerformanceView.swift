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
                if store.selection.showInspector && !store.showSettings && !store.showHelp {
                    InspectorPanelView()
                        .transition(.move(edge: .trailing))
                }
                
                // Audio Interface Settings panel
                if store.showSettings {
                    AudioInterfaceSettingsView()
                        .transition(.move(edge: .trailing))
                }
                
                // Help panel
                if store.showHelp {
                    HelpChatView()
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .animation(DS.Anim.fast, value: store.selection.showInspector)
        .animation(DS.Anim.fast, value: store.showSettings)
        .animation(DS.Anim.fast, value: store.showHelp)
        .overlay {
            // Onboarding overlay
            if store.showOnboarding {
                OnboardingOverlay()
            }
        }
        .sheet(isPresented: $store.showEuclideanGenerator) {
            EuclideanGeneratorSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        // Keyboard shortcuts
        .onKeyPress(.space) {
            store.togglePlayback()
            return .handled
        }
        .onKeyPress(.escape) {
            store.closeInspector()
            store.showSettings = false
            store.showHelp = false
            return .handled
        }
        .onKeyPress("c", modifiers: .command) {
            store.copySelectedSteps()
            return .handled
        }
        .onKeyPress("v", modifiers: .command) {
            if let firstSelected = store.selection.selectedStepIDs.first,
               let step = store.selectedTrack?.steps.first(where: { $0.id == firstSelected }) {
                store.pasteSteps(startingAt: step.index)
            }
            return .handled
        }
        .onKeyPress("z", modifiers: .command) {
            // TODO: Undo
            return .handled
        }
        .onKeyPress("e", modifiers: .command) {
            store.toggleEuclideanGenerator()
            return .handled
        }
        .onKeyPress("h", modifiers: .command) {
            store.humanize()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            store.shiftTrackLeft()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            store.shiftTrackRight()
            return .handled
        }
        .onKeyPress("i", modifiers: .command) {
            store.toggleInspector()
            return .handled
        }
    }
}
