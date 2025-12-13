import SwiftUI

struct SteppedValueControl: View {
    let label: String
    let value: Int
    let min: Int
    let max: Int
    let step: Int
    var suffix: String = ""
    let onChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            // Label
            Text(label)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
                .frame(width: 50, alignment: .leading)
            
            Spacer()
            
            // Decrement button
            Button(action: decrement) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(canDecrement ? DS.Color.textPrimary : DS.Color.textMuted)
            }
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
            )
            .disabled(!canDecrement)
            
            // Value display
            Text("\(value)\(suffix)")
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(minWidth: 50)
                .multilineTextAlignment(.center)
            
            // Increment button
            Button(action: increment) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(canIncrement ? DS.Color.textPrimary : DS.Color.textMuted)
            }
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
            )
            .disabled(!canIncrement)
        }
        .frame(minHeight: DS.Size.minTouch)
    }
    
    private var canDecrement: Bool {
        value > min
    }
    
    private var canIncrement: Bool {
        value < max
    }
    
    private func decrement() {
        let newValue = Swift.max(min, value - step)
        onChange(newValue)
    }
    
    private func increment() {
        let newValue = Swift.min(max, value + step)
        onChange(newValue)
    }
}
