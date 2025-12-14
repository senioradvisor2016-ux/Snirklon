import SwiftUI
import Combine

/// Manages toast notifications throughout the app
@MainActor
class ToastManager: ObservableObject {
    @Published var currentToast: Toast?
    @Published var toastQueue: [Toast] = []
    
    private var dismissTask: Task<Void, Never>?
    
    struct Toast: Identifiable, Equatable {
        let id = UUID()
        let message: String
        let type: ToastType
        let duration: TimeInterval
        let action: ToastAction?
        
        static func == (lhs: Toast, rhs: Toast) -> Bool {
            lhs.id == rhs.id
        }
        
        enum ToastType {
            case info, success, warning, error, undo
            
            var icon: String {
                switch self {
                case .info: return "info.circle.fill"
                case .success: return "checkmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .error: return "xmark.circle.fill"
                case .undo: return "arrow.uturn.backward.circle.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .info: return DS.Color.led
                case .success: return .green
                case .warning: return .orange
                case .error: return .red
                case .undo: return DS.Color.accent
                }
            }
        }
        
        struct ToastAction {
            let title: String
            let handler: () -> Void
        }
    }
    
    // MARK: - Show Toast
    
    func show(_ message: String, type: Toast.ToastType = .info, duration: TimeInterval = 2.5, action: Toast.ToastAction? = nil) {
        let toast = Toast(message: message, type: type, duration: duration, action: action)
        
        if currentToast == nil {
            displayToast(toast)
        } else {
            toastQueue.append(toast)
        }
    }
    
    private func displayToast(_ toast: Toast) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentToast = toast
        }
        
        // Schedule dismissal
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await dismiss()
        }
    }
    
    func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            currentToast = nil
        }
        
        // Show next toast in queue
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s gap
            if let next = toastQueue.first {
                toastQueue.removeFirst()
                displayToast(next)
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    func success(_ message: String) {
        show(message, type: .success)
        HapticEngine.success()
    }
    
    func error(_ message: String) {
        show(message, type: .error, duration: 4.0)
        HapticEngine.error()
    }
    
    func warning(_ message: String) {
        show(message, type: .warning, duration: 3.0)
        HapticEngine.warning()
    }
    
    func info(_ message: String) {
        show(message, type: .info)
    }
    
    func undo(_ message: String, undoAction: @escaping () -> Void) {
        show(message, type: .undo, duration: 4.0, action: Toast.ToastAction(title: "Ångra", handler: undoAction))
    }
}

// MARK: - Toast View

struct ToastView: View {
    let toast: ToastManager.Toast
    let onDismiss: () -> Void
    let onAction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 18))
                .foregroundStyle(toast.type.color)
            
            Text(toast.message)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
            
            if let action = toast.action {
                Button(action: {
                    action.handler()
                    onDismiss()
                }) {
                    Text(action.title)
                        .font(DS.Font.monoS)
                        .foregroundStyle(toast.type.color)
                        .padding(.horizontal, DS.Space.s)
                        .padding(.vertical, DS.Space.xs)
                        .background(
                            Capsule()
                                .stroke(toast.type.color, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DS.Space.m)
        .padding(.vertical, DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(toast.type.color.opacity(0.3), lineWidth: DS.Stroke.hairline)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
}

// MARK: - Toast Container Modifier

struct ToastContainerModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if let toast = toastManager.currentToast {
                    ToastView(
                        toast: toast,
                        onDismiss: { toastManager.dismiss() },
                        onAction: toast.action?.handler
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, DS.Space.xl)
                }
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: toastManager.currentToast)
    }
}

extension View {
    func toastContainer(_ toastManager: ToastManager) -> some View {
        modifier(ToastContainerModifier(toastManager: toastManager))
    }
}

// MARK: - Confirmation Manager

@MainActor
class ConfirmationManager: ObservableObject {
    @Published var currentConfirmation: Confirmation?
    
    struct Confirmation: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let confirmTitle: String
        let cancelTitle: String
        let isDestructive: Bool
        let onConfirm: () -> Void
        let onCancel: () -> Void
    }
    
    func show(
        title: String,
        message: String,
        confirmTitle: String = "Bekräfta",
        cancelTitle: String = "Avbryt",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        currentConfirmation = Confirmation(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            isDestructive: isDestructive,
            onConfirm: {
                onConfirm()
                self.dismiss()
            },
            onCancel: {
                onCancel()
                self.dismiss()
            }
        )
    }
    
    func dismiss() {
        withAnimation {
            currentConfirmation = nil
        }
    }
    
    // MARK: - Common Confirmations
    
    func confirmClearTrack(onConfirm: @escaping () -> Void) {
        show(
            title: "Rensa spår?",
            message: "Alla steg i detta spår kommer att tas bort. Detta går att ångra.",
            confirmTitle: "Rensa",
            isDestructive: true,
            onConfirm: onConfirm
        )
    }
    
    func confirmClearPattern(onConfirm: @escaping () -> Void) {
        show(
            title: "Rensa mönster?",
            message: "Alla spår i detta mönster kommer att tömmas. Detta går att ångra.",
            confirmTitle: "Rensa",
            isDestructive: true,
            onConfirm: onConfirm
        )
    }
    
    func confirmDeletePreset(name: String, onConfirm: @escaping () -> Void) {
        show(
            title: "Ta bort preset?",
            message: "Preseten \"\(name)\" kommer att tas bort permanent.",
            confirmTitle: "Ta bort",
            isDestructive: true,
            onConfirm: onConfirm
        )
    }
    
    func confirmOverwritePattern(onConfirm: @escaping () -> Void) {
        show(
            title: "Skriv över mönster?",
            message: "Det befintliga mönstret kommer att ersättas.",
            confirmTitle: "Skriv över",
            isDestructive: true,
            onConfirm: onConfirm
        )
    }
}

// MARK: - Confirmation Container Modifier

struct ConfirmationContainerModifier: ViewModifier {
    @ObservedObject var confirmationManager: ConfirmationManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let confirmation = confirmationManager.currentConfirmation {
                // Dimmed background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        confirmationManager.dismiss()
                    }
                
                // Dialog
                ConfirmationDialog(
                    title: confirmation.title,
                    message: confirmation.message,
                    confirmTitle: confirmation.confirmTitle,
                    cancelTitle: confirmation.cancelTitle,
                    isDestructive: confirmation.isDestructive,
                    onConfirm: confirmation.onConfirm,
                    onCancel: confirmation.onCancel
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: confirmationManager.currentConfirmation != nil)
    }
}

extension View {
    func confirmationContainer(_ confirmationManager: ConfirmationManager) -> some View {
        modifier(ConfirmationContainerModifier(confirmationManager: confirmationManager))
    }
}
