import SwiftUI

struct GridRulerView: View {
    let stepCount: Int
    let currentStep: Int
    let isPlaying: Bool
    
    /// Steps per bar (16th notes in a 4/4 bar)
    private let stepsPerBar: Int = 16
    
    var body: some View {
        HStack(spacing: DS.Space.xxs) {
            ForEach(0..<stepCount, id: \.self) { index in
                stepMarker(index: index)
            }
        }
    }
    
    @ViewBuilder
    private func stepMarker(index: Int) -> some View {
        let isBarStart = index % stepsPerBar == 0
        let isBeatStart = index % 4 == 0
        let barNumber = index / stepsPerBar + 1
        let beatInBar = (index % stepsPerBar) / 4 + 1
        
        ZStack {
            // Background - highlight bar starts
            Rectangle()
                .fill(isBarStart ? DS.Color.surface.opacity(0.3) : Color.clear)
                .frame(width: DS.Size.minTouch, height: 24)
            
            VStack(spacing: 0) {
                // Bar number at bar starts
                if isBarStart {
                    Text("B\(barNumber)")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textPrimary)
                }
                
                // Beat marker (every 4 steps within bar)
                if isBeatStart {
                    Text("\(beatInBar)")
                        .font(DS.Font.monoS)
                        .foregroundStyle(isBarStart ? DS.Color.textPrimary : DS.Color.textSecondary)
                } else {
                    Text(Iconography.Sym.step)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            // Playhead indicator
            if isPlaying && index == currentStep {
                Circle()
                    .fill(DS.Color.led)
                    .frame(width: 6, height: 6)
                    .offset(y: 12)
                    .shadow(color: DS.Color.led.opacity(0.6), radius: 4)
            }
        }
    }
}
