import SwiftUI

/// Skeleton loading animation for content
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                DS.Color.surface,
                DS.Color.surface.opacity(0.5),
                DS.Color.surface
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(Rectangle())
        .offset(x: isAnimating ? 200 : -200)
        .animation(
            Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

/// Skeleton for step grid
struct StepGridSkeletonView: View {
    let trackCount: Int
    let stepCount: Int
    
    var body: some View {
        VStack(spacing: DS.Space.s) {
            // Ruler skeleton
            HStack(spacing: DS.Space.xxs) {
                ForEach(0..<min(stepCount, 16), id: \.self) { _ in
                    skeletonRect(width: DS.Size.minTouch, height: 20)
                }
            }
            .padding(.leading, DS.Space.xs)
            
            // Track skeletons
            ForEach(0..<trackCount, id: \.self) { _ in
                HStack(spacing: DS.Space.xxs) {
                    ForEach(0..<min(stepCount, 16), id: \.self) { _ in
                        skeletonRect(width: DS.Size.minTouch, height: DS.Size.minTouch)
                            .cornerRadius(DS.Radius.s)
                    }
                }
            }
        }
        .padding(DS.Space.m)
    }
    
    private func skeletonRect(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(DS.Color.surface)
            .frame(width: width, height: height)
            .overlay(SkeletonView())
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

/// Skeleton for pattern slot
struct PatternSlotSkeletonView: View {
    var body: some View {
        VStack(spacing: DS.Space.xs) {
            skeletonRect(width: 60, height: 40)
                .cornerRadius(DS.Radius.s)
            
            skeletonRect(width: 40, height: 12)
                .cornerRadius(2)
        }
    }
    
    private func skeletonRect(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(DS.Color.surface)
            .frame(width: width, height: height)
            .overlay(SkeletonView())
    }
}

/// Skeleton for inspector panel
struct InspectorSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            // Header
            skeletonRect(width: 80, height: 16)
            
            // Controls
            ForEach(0..<4, id: \.self) { _ in
                HStack {
                    skeletonRect(width: 50, height: 14)
                    Spacer()
                    skeletonRect(width: 100, height: 32)
                }
            }
            
            Spacer()
        }
        .padding(DS.Space.m)
        .frame(width: DS.Size.inspectorWidth)
        .background(DS.Color.background)
    }
    
    private func skeletonRect(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(DS.Color.surface)
            .frame(width: width, height: height)
            .overlay(SkeletonView())
            .cornerRadius(4)
    }
}

/// Loading overlay for entire view
struct LoadingOverlayView: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: DS.Space.m) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(DS.Color.led)
                
                Text(message)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.xl)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(DS.Color.surface)
            )
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        StepGridSkeletonView(trackCount: 4, stepCount: 16)
        
        HStack {
            PatternSlotSkeletonView()
            PatternSlotSkeletonView()
            PatternSlotSkeletonView()
        }
    }
    .background(DS.Color.background)
}
