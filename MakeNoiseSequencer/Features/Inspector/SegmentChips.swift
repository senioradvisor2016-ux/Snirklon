import SwiftUI

struct SegmentChips<T: Hashable>: View {
    let label: String
    let options: [T]
    let selected: T
    let labelForOption: (T) -> String
    let onSelect: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            // Label
            Text(label)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            // Chips row
            HStack(spacing: DS.Space.xxs) {
                ForEach(options, id: \.self) { option in
                    chipButton(for: option)
                }
            }
        }
    }
    
    @ViewBuilder
    private func chipButton(for option: T) -> some View {
        let isSelected = option == selected
        
        Button(action: { onSelect(option) }) {
            Text(labelForOption(option))
                .font(DS.Font.monoS)
                .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textSecondary)
                .padding(.horizontal, DS.Space.s)
                .padding(.vertical, DS.Space.xs)
                .frame(minHeight: 36)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .fill(isSelected ? DS.Color.surface2 : DS.Color.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.s)
                                .stroke(isSelected ? DS.Color.selectedStroke : DS.Color.etchedLineSoft, lineWidth: DS.Stroke.hairline)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// Convenience for Int options
extension SegmentChips where T == Int {
    init(label: String, options: [Int], selected: Int, onSelect: @escaping (Int) -> Void) {
        self.label = label
        self.options = options
        self.selected = selected
        self.labelForOption = { "\($0)" }
        self.onSelect = onSelect
    }
}

// Convenience for String options
extension SegmentChips where T == String {
    init(label: String, options: [String], selected: String, onSelect: @escaping (String) -> Void) {
        self.label = label
        self.options = options
        self.selected = selected
        self.labelForOption = { $0 }
        self.onSelect = onSelect
    }
}
