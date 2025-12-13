import SwiftUI

struct InspectorPanelView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("INSPECTOR")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Button(action: { store.closeInspector() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DS.Color.textMuted)
                }
                .frame(width: 28, height: 28)
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
            .background(DS.Color.surface)
            .overlay(
                Rectangle()
                    .fill(DS.Color.etchedLine)
                    .frame(height: DS.Stroke.hairline),
                alignment: .bottom
            )
            
            // Content - no scroll, fixed layout
            VStack(spacing: DS.Space.l) {
                // Step section
                if store.selection.hasSelection {
                    InspectorStepSection()
                } else {
                    emptyStepSection
                }
                
                Divider()
                    .background(DS.Color.etchedLine)
                
                // Track section
                if store.selectedTrack != nil {
                    InspectorTrackSection()
                } else {
                    emptyTrackSection
                }
                
                Spacer()
            }
            .padding(DS.Space.m)
        }
        .frame(width: DS.Size.inspectorWidth)
        .background(DS.Color.background)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(width: DS.Stroke.hairline),
            alignment: .leading
        )
    }
    
    private var emptyStepSection: some View {
        VStack(spacing: DS.Space.s) {
            Text("STEP")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("No step selected")
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
    
    private var emptyTrackSection: some View {
        VStack(spacing: DS.Space.s) {
            Text("TRACK")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text("No track selected")
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.m)
        .background(PanelStyles.cutoutBackground())
    }
}
