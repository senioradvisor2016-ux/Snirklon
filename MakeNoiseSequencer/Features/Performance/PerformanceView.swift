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
                
                // Audio Interface Settings panel (Advanced mode only)
                if store.showSettings && store.features.showAudioInterface {
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
        .animation(DS.Anim.fast, value: store.modeManager.currentMode)
        .overlay {
            // Onboarding overlay
            if store.showOnboarding {
                OnboardingOverlay()
            }
        }
        // Euclidean Generator sheet (Advanced mode only)
        .sheet(isPresented: Binding(
            get: { store.showEuclideanGenerator && store.features.showEuclidean },
            set: { store.showEuclideanGenerator = $0 }
        )) {
            EuclideanGeneratorSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        // Mode selector sheet
        .sheet(isPresented: .constant(false)) {
            ModeSelectorView(modeManager: store.modeManager)
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
        // Advanced mode shortcuts
        .onKeyPress("c", modifiers: .command) {
            guard store.features.showCopyPaste else { return .ignored }
            store.copySelectedSteps()
            return .handled
        }
        .onKeyPress("v", modifiers: .command) {
            guard store.features.showCopyPaste else { return .ignored }
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
            guard store.features.showEuclidean else { return .ignored }
            store.toggleEuclideanGenerator()
            return .handled
        }
        .onKeyPress("h", modifiers: .command) {
            guard store.features.showHumanize else { return .ignored }
            store.humanize()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            guard store.features.showTransformations else { return .ignored }
            store.shiftTrackLeft()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            guard store.features.showTransformations else { return .ignored }
            store.shiftTrackRight()
            return .handled
        }
        .onKeyPress("i", modifiers: .command) {
            store.toggleInspector()
            return .handled
        }
        // Mode toggle shortcut
        .onKeyPress("m", modifiers: .command) {
            store.modeManager.toggleMode()
            return .handled
        }
    }
}
