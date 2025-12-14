import SwiftUI

/// First-time user onboarding experience
struct OnboardingOverlay: View {
    @EnvironmentObject var store: SequencerStore
    @State private var currentStep: Int = 0
    
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Välkommen! 👋",
            description: "MakeNoise Sequencer är en kraftfull stegsekvenser designad för att styra modulärsyntar via CV.",
            icon: "sparkles",
            highlight: nil
        ),
        OnboardingStep(
            title: "Stegsekvensering",
            description: "Tryck på rutnätet för att aktivera steg. Varje rad är ett spår (KICK, SNARE, etc.) och varje kolumn är ett steg i sekvensen.",
            icon: "square.grid.4x3.fill",
            highlight: .grid
        ),
        OnboardingStep(
            title: "Transport",
            description: "Använd PLAY/STOP för att starta uppspelning. Justera BPM och SWING för tempo och groove.",
            icon: "play.fill",
            highlight: .transport
        ),
        OnboardingStep(
            title: "Spårhantering",
            description: "I sidofältet kan du välja spår och använda MUTE/SOLO för att kontrollera vilka som hörs.",
            icon: "list.bullet",
            highlight: .sidebar
        ),
        OnboardingStep(
            title: "CV & ADSR",
            description: "Anslut ett DC-kopplat ljudkort som ES-9 för att skicka CV till din modulärsynt. Skapa ADSR-enveloper under inställningarna.",
            icon: "bolt",
            highlight: .settings
        ),
        OnboardingStep(
            title: "Hjälp alltid nära",
            description: "Tryck på ? för hjälp och guide när som helst. Lycka till med ditt skapande! 🎵",
            icon: "questionmark.circle",
            highlight: .help
        )
    ]
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Content card
            VStack(spacing: DS.Space.l) {
                // Progress dots
                HStack(spacing: DS.Space.xs) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? DS.Color.led : DS.Color.textMuted)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Icon
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 48))
                    .foregroundStyle(DS.Color.led)
                    .shadow(color: DS.Color.led.opacity(0.5), radius: 10)
                
                // Title
                Text(steps[currentStep].title)
                    .font(DS.Font.monoL)
                    .foregroundStyle(DS.Color.textPrimary)
                
                // Description
                Text(steps[currentStep].description)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                
                // Navigation buttons
                HStack(spacing: DS.Space.l) {
                    if currentStep > 0 {
                        Button(action: previousStep) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Tillbaka")
                            }
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button(action: nextStep) {
                            HStack {
                                Text("Nästa")
                                Image(systemName: "chevron.right")
                            }
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.textPrimary)
                            .padding(.horizontal, DS.Space.l)
                            .padding(.vertical, DS.Space.s)
                            .background(
                                Capsule()
                                    .fill(DS.Color.led)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: complete) {
                            HStack {
                                Text("Kom igång!")
                                Image(systemName: "arrow.right")
                            }
                            .font(DS.Font.monoS)
                            .foregroundStyle(DS.Color.background)
                            .padding(.horizontal, DS.Space.l)
                            .padding(.vertical, DS.Space.s)
                            .background(
                                Capsule()
                                    .fill(DS.Color.led)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: 300)
                
                // Skip button
                Button(action: complete) {
                    Text("Hoppa över guiden")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Space.xl)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(DS.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.m)
                            .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
        .transition(.opacity)
    }
    
    private func nextStep() {
        withAnimation(DS.Anim.fast) {
            currentStep = min(currentStep + 1, steps.count - 1)
        }
    }
    
    private func previousStep() {
        withAnimation(DS.Anim.fast) {
            currentStep = max(currentStep - 1, 0)
        }
    }
    
    private func complete() {
        withAnimation(DS.Anim.fast) {
            store.completeOnboarding()
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let highlight: HighlightArea?
}

enum HighlightArea {
    case grid
    case transport
    case sidebar
    case settings
    case help
}

#Preview {
    OnboardingOverlay()
        .environmentObject(SequencerStore())
}
