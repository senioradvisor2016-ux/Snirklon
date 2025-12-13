import SwiftUI

struct PatternLauncherGridView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: DS.Space.xs) {
            // Header
            HStack {
                Text("PATTERNS")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                Spacer()
            }
            
            // Pattern slots
            HStack(spacing: DS.Space.xs) {
                ForEach(Array(store.patterns.enumerated()), id: \.element.id) { index, pattern in
                    PatternSlotView(
                        pattern: pattern,
                        isSelected: index == store.currentPatternIndex,
                        onSelect: { store.selectPattern(index) }
                    )
                }
                
                Spacer()
            }
        }
        .padding(.vertical, DS.Space.s)
    }
}
