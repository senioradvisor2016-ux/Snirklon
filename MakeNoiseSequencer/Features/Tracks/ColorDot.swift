import SwiftUI

struct ColorDot: View {
    let color: Color
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(color.opacity(isActive ? 0.85 : 0.35))
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: DS.Stroke.hairline)
            )
            .shadow(color: isActive ? color.opacity(0.4) : .clear, radius: 4)
    }
}
