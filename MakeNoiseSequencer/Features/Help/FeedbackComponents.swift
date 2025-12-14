import SwiftUI

// MARK: - Success Feedback

/// Animated success checkmark
struct SuccessFeedback: View {
    @State private var isAnimating = false
    let message: String
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.green)
                .scaleEffect(isAnimating ? 1 : 0)
            
            Text(message)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
                .opacity(isAnimating ? 1 : 0)
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .shadow(color: .green.opacity(0.2), radius: 8)
        )
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Toast Notification

struct ToastNotification: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case info, success, warning, error
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .info: return DS.Color.led
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)
            
            Text(message)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(type.color.opacity(0.3), lineWidth: DS.Stroke.hairline)
                )
                .shadow(color: .black.opacity(0.2), radius: 8)
        )
    }
}

// MARK: - Loading Indicator

struct LoadingIndicator: View {
    let message: String
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16))
                .foregroundStyle(DS.Color.led)
                .rotationEffect(.degrees(rotation))
            
            Text(message)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double // 0-1
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Text(label)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DS.Color.surface)
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DS.Color.led)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Confirmation Dialog

struct ConfirmationDialog: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    init(
        title: String,
        message: String,
        confirmTitle: String = "Bekräfta",
        cancelTitle: String = "Avbryt",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Icon
            Image(systemName: isDestructive ? "exclamationmark.triangle.fill" : "questionmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(isDestructive ? .orange : DS.Color.led)
            
            // Title
            Text(title)
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
            
            // Message
            Text(message)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            
            // Buttons
            HStack(spacing: DS.Space.m) {
                Button(action: onCancel) {
                    Text(cancelTitle)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.s)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.s)
                                .fill(DS.Color.surface)
                        )
                }
                .buttonStyle(.plain)
                
                Button(action: onConfirm) {
                    Text(confirmTitle)
                        .font(DS.Font.monoS)
                        .foregroundStyle(isDestructive ? .white : DS.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.s)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.s)
                                .fill(isDestructive ? .red : DS.Color.led)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DS.Space.l)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
    }
}

// MARK: - Value Change Indicator

struct ValueChangeIndicator: View {
    let value: Int
    let previousValue: Int
    
    private var delta: Int { value - previousValue }
    private var isIncrease: Bool { delta > 0 }
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
            
            if delta != 0 {
                HStack(spacing: 0) {
                    Image(systemName: isIncrease ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10))
                    Text("\(abs(delta))")
                        .font(DS.Font.monoXS)
                }
                .foregroundStyle(isIncrease ? .green : .red)
            }
        }
    }
}

// MARK: - Pulse Animation Modifier

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.5 : 1)
                    .opacity(isPulsing ? 0 : 0.5)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulseAnimation(color: Color = DS.Color.led) -> some View {
        modifier(PulseAnimation(color: color))
    }
}

// MARK: - Step Highlight

struct StepHighlight: View {
    let isPlaying: Bool
    
    var body: some View {
        if isPlaying {
            Circle()
                .fill(DS.Color.led)
                .frame(width: 8, height: 8)
                .pulseAnimation()
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        SuccessFeedback(message: "Mönster kopierat!")
        
        ToastNotification(message: "CV-spår tillagt", type: .success)
        ToastNotification(message: "Ingen DC-koppling", type: .warning)
        
        LoadingIndicator(message: "Laddar...")
        
        ProgressBar(progress: 0.65, label: "Exporterar")
            .frame(width: 200)
        
        ValueChangeIndicator(value: 120, previousValue: 110)
    }
    .padding()
    .background(DS.Color.background)
}
