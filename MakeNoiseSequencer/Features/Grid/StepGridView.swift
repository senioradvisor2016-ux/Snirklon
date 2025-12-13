import SwiftUI

struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    
    private let columns = Array(repeating: GridItem(.fixed(DS.Size.minTouch + DS.Space.xxs), spacing: DS.Space.xxs), count: 16)
    
    var body: some View {
        ZStack {
            // Etched grid background
            PanelStyles.etchedGrid(spacing: DS.Size.minTouch + DS.Space.xxs)
            
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    // Grid ruler at top
                    GridRulerView(stepCount: 16, currentStep: store.currentStep, isPlaying: store.isPlaying)
                        .padding(.leading, DS.Space.xs)
                    
                    // Step grid
                    if let pattern = store.currentPattern {
                        ForEach(pattern.tracks) { track in
                            trackRow(track: track)
                        }
                    }
                }
                .padding(DS.Space.m)
            }
        }
    }
    
    @ViewBuilder
    private func trackRow(track: TrackModel) -> some View {
        HStack(spacing: DS.Space.xxs) {
            ForEach(track.steps) { step in
                StepCellView(
                    step: step,
                    isSelected: store.selection.selectedStepIDs.contains(step.id),
                    isPlaying: store.isPlaying && store.currentStep == step.index && store.selection.selectedTrackID == track.id,
                    trackColor: track.color,
                    onToggle: { store.toggleStep(step.id) },
                    onSelect: {
                        store.selectTrack(track.id)
                        store.selectStep(step.id)
                    },
                    onVelocityDelta: { delta in store.adjustVelocity(for: step.id, delta: delta) },
                    onTimingDelta: { delta in store.adjustTiming(for: step.id, delta: delta) },
                    onOpenInspector: { store.openInspector() }
                )
            }
        }
        .opacity(track.isMuted ? 0.4 : 1.0)
    }
}
