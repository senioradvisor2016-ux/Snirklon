import SwiftUI

struct ToggleChip: View {
    let label: String
    let isOn: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DS.Space.xs) {
                // Status indicator
                Text(isOn ? Iconography.Sym.on : Iconography.Sym.off)
                    .font(DS.Font.monoS)
                    .foregroundStyle(isOn ? DS.Color.led : DS.Color.textMuted)
                
                // Label
                Text(label)
                    .font(DS.Font.monoS)
                    .foregroundStyle(isOn ? DS.Color.textPrimary : DS.Color.textSecondary)
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
            .frame(minHeight: DS.Size.minTouch)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(isOn ? DS.Color.surface2 : DS.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .stroke(isOn ? DS.Color.selectedStroke : DS.Color.etchedLineSoft, lineWidth: DS.Stroke.hairline)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
