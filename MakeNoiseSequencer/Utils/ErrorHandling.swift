import SwiftUI

/// App-specific error types with recovery suggestions
enum SequencerError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidFormat(String)
    case exportFailed(String)
    case midiConnectionLost
    case audioInterfaceUnavailable(String)
    case presetCorrupted(String)
    case cloudSyncFailed(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Filen '\(name)' hittades inte"
        case .invalidFormat(let detail):
            return "Ogiltigt filformat: \(detail)"
        case .exportFailed(let reason):
            return "Export misslyckades: \(reason)"
        case .midiConnectionLost:
            return "MIDI-anslutningen förlorades"
        case .audioInterfaceUnavailable(let name):
            return "Ljudkortet '\(name)' är inte tillgängligt"
        case .presetCorrupted(let name):
            return "Preseten '\(name)' är skadad"
        case .cloudSyncFailed(let reason):
            return "Molnsynkronisering misslyckades: \(reason)"
        case .unknown(let error):
            return "Ett oväntat fel uppstod: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .fileNotFound:
            return "Kontrollera att filen finns och försök igen."
        case .invalidFormat:
            return "Kontrollera att filen är i rätt format (MIDI, JSON, eller WAV)."
        case .exportFailed:
            return "Kontrollera att du har tillräckligt med diskutrymme och försök igen."
        case .midiConnectionLost:
            return "Kontrollera att MIDI-enheten är ansluten och starta om appen."
        case .audioInterfaceUnavailable:
            return "Kontrollera att ljudkortet är anslutet och valt som output i systeminställningarna."
        case .presetCorrupted:
            return "Försök att ladda en backup eller skapa preseten på nytt."
        case .cloudSyncFailed:
            return "Kontrollera din internetanslutning och att iCloud är aktiverat."
        case .unknown:
            return "Försök starta om appen. Om problemet kvarstår, kontakta support."
        }
    }
    
    var icon: String {
        switch self {
        case .fileNotFound: return "doc.questionmark"
        case .invalidFormat: return "doc.badge.ellipsis"
        case .exportFailed: return "square.and.arrow.up.trianglebadge.exclamationmark"
        case .midiConnectionLost: return "cable.connector.slash"
        case .audioInterfaceUnavailable: return "speaker.slash"
        case .presetCorrupted: return "exclamationmark.triangle"
        case .cloudSyncFailed: return "icloud.slash"
        case .unknown: return "questionmark.circle"
        }
    }
}

/// Error manager for handling and displaying errors
@MainActor
class ErrorManager: ObservableObject {
    @Published var currentError: DisplayableError?
    @Published var errorHistory: [DisplayableError] = []
    
    struct DisplayableError: Identifiable {
        let id = UUID()
        let error: SequencerError
        let timestamp: Date
        var isResolved: Bool = false
    }
    
    func show(_ error: SequencerError) {
        let displayable = DisplayableError(error: error, timestamp: Date())
        currentError = displayable
        errorHistory.append(displayable)
        HapticEngine.error()
    }
    
    func dismiss() {
        withAnimation {
            currentError = nil
        }
    }
    
    func resolve(_ id: UUID) {
        if let index = errorHistory.firstIndex(where: { $0.id == id }) {
            errorHistory[index].isResolved = true
        }
    }
    
    func clearHistory() {
        errorHistory.removeAll()
    }
}

/// Error display view with recovery suggestions
struct ErrorView: View {
    let error: SequencerError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    init(error: SequencerError, onDismiss: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Icon
            Image(systemName: error.icon)
                .font(.system(size: 40))
                .foregroundStyle(.red)
            
            // Title
            Text("Något gick fel")
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textPrimary)
            
            // Error message
            Text(error.localizedDescription)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            
            // Recovery suggestion
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.yellow)
                    Text("Förslag")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
                
                Text(error.recoverySuggestion)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.m)
            .background(DS.Color.cutout)
            .cornerRadius(DS.Radius.s)
            .frame(maxWidth: 280)
            
            // Buttons
            HStack(spacing: DS.Space.m) {
                Button(action: onDismiss) {
                    Text("Stäng")
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
                
                if let retry = onRetry {
                    Button(action: retry) {
                        Text("Försök igen")
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Space.s)
                            .background(
                                RoundedRectangle(cornerRadius: DS.Radius.s)
                                    .fill(DS.Color.led)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(DS.Space.l)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(.red.opacity(0.3), lineWidth: DS.Stroke.thin)
                )
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
    }
}

/// Error container modifier
struct ErrorContainerModifier: ViewModifier {
    @ObservedObject var errorManager: ErrorManager
    var onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let displayError = errorManager.currentError {
                // Dimmed background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        errorManager.dismiss()
                    }
                
                // Error view
                ErrorView(
                    error: displayError.error,
                    onDismiss: { errorManager.dismiss() },
                    onRetry: onRetry
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: errorManager.currentError != nil)
    }
}

extension View {
    func errorContainer(_ errorManager: ErrorManager, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorContainerModifier(errorManager: errorManager, onRetry: onRetry))
    }
}

/// Inline error banner
struct ErrorBanner: View {
    let message: String
    let suggestion: String?
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                if let suggestion = suggestion {
                    Text(suggestion)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .stroke(.red.opacity(0.3), lineWidth: DS.Stroke.hairline)
                )
        )
    }
}

#Preview {
    VStack(spacing: 30) {
        ErrorView(
            error: .audioInterfaceUnavailable("ES-9"),
            onDismiss: {},
            onRetry: {}
        )
        
        ErrorBanner(
            message: "MIDI-anslutningen förlorades",
            suggestion: "Kontrollera kablarna",
            onDismiss: {}
        )
    }
    .padding()
    .background(DS.Color.background)
}
