import SwiftUI

/// First-time user onboarding experience with spotlight highlighting
struct OnboardingOverlay: View {
    @EnvironmentObject var store: SequencerStore
    @State private var currentStep: Int = 0
    @State private var highlightRects: [HighlightArea: CGRect] = [:]
    
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
        GeometryReader { geometry in
            ZStack {
                // Spotlight overlay med hål för highlighted area
                SpotlightMask(
                    highlightRect: currentHighlightRect,
                    cornerRadius: DS.Radius.m
                )
                .fill(Color.black.opacity(0.85))
                .ignoresSafeArea()
                
                // Pulsande ram runt highlighted area
                if let rect = currentHighlightRect {
                    SpotlightBorder(rect: rect, cornerRadius: DS.Radius.m)
                }
                
                // Content card - positionerad baserat på highlight
                contentCard
                    .position(cardPosition(in: geometry.size))
            }
        }
        .transition(.opacity)
        .onAppear {
            setupHighlightRects()
        }
    }
    
    private var currentHighlightRect: CGRect? {
        guard let highlight = steps[currentStep].highlight else { return nil }
        return highlightRects[highlight]
    }
    
    private func cardPosition(in size: CGSize) -> CGPoint {
        guard let rect = currentHighlightRect else {
            // Centrerat om ingen highlight
            return CGPoint(x: size.width / 2, y: size.height / 2)
        }
        
        // Placera kortet så det inte överlappar med highlight
        let cardHeight: CGFloat = 280
        let padding: CGFloat = DS.Space.xl
        
        // Om highlight är i övre halvan, placera kort under
        if rect.midY < size.height / 2 {
            return CGPoint(x: size.width / 2, y: rect.maxY + cardHeight / 2 + padding)
        } else {
            // Annars placera kort över
            return CGPoint(x: size.width / 2, y: rect.minY - cardHeight / 2 - padding)
        }
    }
    
    private var contentCard: some View {
        VStack(spacing: DS.Space.l) {
            // Progress dots
            HStack(spacing: DS.Space.xs) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? DS.Color.led : DS.Color.textMuted)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentStep ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
            
            // Icon med animation
            Image(systemName: steps[currentStep].icon)
                .font(.system(size: 48))
                .foregroundStyle(DS.Color.led)
                .shadow(color: DS.Color.led.opacity(0.5), radius: 10)
                .id(currentStep) // Trigger animation vid byte
                .transition(.scale.combined(with: .opacity))
            
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
    
    private func setupHighlightRects() {
        // Standardpositioner - dessa kan uppdateras via PreferenceKey
        // för mer exakta positioner baserat på faktisk layout
        highlightRects = [
            .grid: CGRect(x: 220, y: 120, width: 500, height: 300),
            .transport: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56),
            .sidebar: CGRect(x: 0, y: 56, width: 200, height: 400),
            .settings: CGRect(x: UIScreen.main.bounds.width - 150, y: 8, width: 120, height: 40),
            .help: CGRect(x: UIScreen.main.bounds.width - 50, y: 8, width: 40, height: 40)
        ]
    }
    
    private func nextStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = min(currentStep + 1, steps.count - 1)
        }
        HapticEngine.selection()
    }
    
    private func previousStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = max(currentStep - 1, 0)
        }
        HapticEngine.selection()
    }
    
    private func complete() {
        withAnimation(DS.Anim.fast) {
            store.completeOnboarding()
        }
        HapticEngine.success()
    }
}

// MARK: - Spotlight Mask

/// Skapar en mask med ett genomskinligt "hål" för spotlight-effekt
struct SpotlightMask: Shape {
    let highlightRect: CGRect?
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Hela skärmen
        path.addRect(rect)
        
        // Dra av highlight-området (skapar hålet)
        if let highlightRect = highlightRect {
            let expandedRect = highlightRect.insetBy(dx: -DS.Space.s, dy: -DS.Space.s)
            let holePath = Path(roundedRect: expandedRect, cornerRadius: cornerRadius)
            path = path.subtracting(holePath)
        }
        
        return path
    }
}

// MARK: - Spotlight Border

/// Pulsande ram runt det highlightade området
struct SpotlightBorder: View {
    let rect: CGRect
    let cornerRadius: CGFloat
    
    @State private var isPulsing = false
    
    var body: some View {
        let expandedRect = rect.insetBy(dx: -DS.Space.s, dy: -DS.Space.s)
        
        ZStack {
            // Glow
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(DS.Color.led, lineWidth: 3)
                .blur(radius: isPulsing ? 8 : 4)
                .opacity(isPulsing ? 0.8 : 0.4)
            
            // Solid border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(DS.Color.led, lineWidth: 2)
        }
        .frame(width: expandedRect.width, height: expandedRect.height)
        .position(x: expandedRect.midX, y: expandedRect.midY)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Data Models

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let highlight: HighlightArea?
}

enum HighlightArea: Hashable {
    case grid
    case transport
    case sidebar
    case settings
    case help
}

// MARK: - Preference Key for Dynamic Positions

/// PreferenceKey för att rapportera UI-elementens positioner
struct HighlightAreaPreferenceKey: PreferenceKey {
    static var defaultValue: [HighlightArea: CGRect] = [:]
    
    static func reduce(value: inout [HighlightArea: CGRect], nextValue: () -> [HighlightArea: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

/// Modifier för att markera ett område som highlightable
struct HighlightableModifier: ViewModifier {
    let area: HighlightArea
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: HighlightAreaPreferenceKey.self,
                        value: [area: geo.frame(in: .global)]
                    )
                }
            )
    }
}

extension View {
    /// Markera denna vy som highlightable för onboarding
    func highlightable(_ area: HighlightArea) -> some View {
        modifier(HighlightableModifier(area: area))
    }
}

// MARK: - Preview

#Preview {
    OnboardingOverlay()
        .environmentObject(SequencerStore())
}
