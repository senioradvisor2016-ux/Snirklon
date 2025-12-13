import SwiftUI

struct GridRulerView: View {
    let stepCount: Int
    let currentStep: Int
    let isPlaying: Bool
    
    var body: some View {
        HStack(spacing: DS.Space.xxs) {
            ForEach(0..<stepCount, id: \.self) { index in
                stepMarker(index: index)
            }
        }
    }
    
    @ViewBuilder
    private func stepMarker(index: Int) -> some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.clear)
                .frame(width: DS.Size.minTouch, height: 20)
            
            // Beat marker (every 4 steps)
            if index % 4 == 0 {
                Text("\(index / 4 + 1)")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
            } else {
                Text(Iconography.Sym.step)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            // Playhead indicator
            if isPlaying && index == currentStep {
                Circle()
                    .fill(DS.Color.led)
                    .frame(width: 6, height: 6)
                    .offset(y: 10)
                    .shadow(color: DS.Color.led.opacity(0.6), radius: 4)
            }
        }
    }
}
