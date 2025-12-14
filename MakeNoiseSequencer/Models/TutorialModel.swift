import SwiftUI
import AVKit

/// Tutorial video system for interactive learning
class TutorialManager: ObservableObject {
    @Published var tutorials: [Tutorial] = Tutorial.allTutorials
    @Published var currentTutorial: Tutorial?
    @Published var progress: [String: TutorialProgress] = [:]
    @Published var showTutorialOverlay: Bool = false
    
    init() {
        loadProgress()
    }
    
    // MARK: - Tutorial Management
    
    func startTutorial(_ tutorial: Tutorial) {
        currentTutorial = tutorial
        showTutorialOverlay = true
    }
    
    func completeTutorial(_ tutorial: Tutorial) {
        var tutorialProgress = progress[tutorial.id] ?? TutorialProgress(tutorialID: tutorial.id)
        tutorialProgress.isCompleted = true
        tutorialProgress.completedAt = Date()
        progress[tutorial.id] = tutorialProgress
        saveProgress()
    }
    
    func completeStep(_ tutorial: Tutorial, stepIndex: Int) {
        var tutorialProgress = progress[tutorial.id] ?? TutorialProgress(tutorialID: tutorial.id)
        if !tutorialProgress.completedSteps.contains(stepIndex) {
            tutorialProgress.completedSteps.append(stepIndex)
        }
        tutorialProgress.lastStepIndex = stepIndex
        progress[tutorial.id] = tutorialProgress
        saveProgress()
    }
    
    func closeTutorial() {
        showTutorialOverlay = false
        currentTutorial = nil
    }
    
    // MARK: - Progress
    
    func progressPercent(for tutorial: Tutorial) -> Double {
        guard let tutorialProgress = progress[tutorial.id] else { return 0 }
        return Double(tutorialProgress.completedSteps.count) / Double(tutorial.steps.count)
    }
    
    func isCompleted(_ tutorial: Tutorial) -> Bool {
        progress[tutorial.id]?.isCompleted ?? false
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "TutorialProgress")
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "TutorialProgress"),
           let loaded = try? JSONDecoder().decode([String: TutorialProgress].self, from: data) {
            progress = loaded
        }
    }
}

// MARK: - Data Types

struct Tutorial: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let duration: String
    let difficulty: Difficulty
    let category: TutorialCategory
    let steps: [TutorialStep]
    let videoURL: URL?
    
    enum Difficulty: String {
        case beginner = "Nybörjare"
        case intermediate = "Medel"
        case advanced = "Avancerad"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

enum TutorialCategory: String, CaseIterable {
    case gettingStarted = "Komma igång"
    case sequencing = "Sekvensering"
    case cv = "CV & Modulär"
    case advanced = "Avancerat"
    
    var icon: String {
        switch self {
        case .gettingStarted: return "star"
        case .sequencing: return "square.grid.4x3.fill"
        case .cv: return "bolt"
        case .advanced: return "gearshape.2"
        }
    }
}

struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: TutorialAction?
    let highlightArea: HighlightArea?
    let imageURL: URL?
    let videoTimestamp: Double?
}

enum TutorialAction {
    case tap(area: HighlightArea)
    case drag(from: HighlightArea, direction: DragDirection)
    case longPress(area: HighlightArea)
    case wait(seconds: Double)
    
    enum DragDirection {
        case up, down, left, right
    }
}

struct TutorialProgress: Codable {
    let tutorialID: String
    var completedSteps: [Int] = []
    var lastStepIndex: Int = 0
    var isCompleted: Bool = false
    var completedAt: Date?
}

// MARK: - Tutorial Content

extension Tutorial {
    static let allTutorials: [Tutorial] = [
        basicSequencing,
        velocityAndTiming,
        patternsAndArrangement,
        cvBasics,
        adsrDeepDive,
        advancedTechniques
    ]
    
    static let basicSequencing = Tutorial(
        id: "basic-sequencing",
        title: "Grundläggande sekvensering",
        description: "Lär dig skapa ditt första beat",
        icon: "play.circle",
        duration: "5 min",
        difficulty: .beginner,
        category: .gettingStarted,
        steps: [
            TutorialStep(
                title: "Välkommen!",
                description: "I den här guiden lär du dig grunderna i att skapa ett enkelt trummönster.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Välj KICK-spåret",
                description: "Klicka på KICK i spårlistan till vänster för att välja bastrumman.",
                action: .tap(area: .sidebar),
                highlightArea: .sidebar,
                imageURL: nil,
                videoTimestamp: 10
            ),
            TutorialStep(
                title: "Lägg till steg",
                description: "Tryck på steg 1, 5, 9 och 13 för ett klassiskt four-on-the-floor-mönster.",
                action: .tap(area: .grid),
                highlightArea: .grid,
                imageURL: nil,
                videoTimestamp: 25
            ),
            TutorialStep(
                title: "Starta uppspelning",
                description: "Tryck på PLAY-knappen eller använd SPACE för att höra ditt beat.",
                action: .tap(area: .transport),
                highlightArea: .transport,
                imageURL: nil,
                videoTimestamp: 45
            ),
            TutorialStep(
                title: "Lägg till snare",
                description: "Välj SNARE-spåret och lägg till steg på 5 och 13 för backbeat.",
                action: .tap(area: .sidebar),
                highlightArea: .grid,
                imageURL: nil,
                videoTimestamp: 60
            ),
            TutorialStep(
                title: "Grattis!",
                description: "Du har skapat ditt första beat! Experimentera med hi-hats och andra ljud.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: 90
            )
        ],
        videoURL: nil
    )
    
    static let velocityAndTiming = Tutorial(
        id: "velocity-timing",
        title: "Velocity & Timing",
        description: "Skapa dynamik och groove",
        icon: "waveform",
        duration: "7 min",
        difficulty: .beginner,
        category: .sequencing,
        steps: [
            TutorialStep(
                title: "Velocity - dynamik",
                description: "Velocity bestämmer hur hårt en not spelas. Dra vertikalt på ett steg för att justera.",
                action: .drag(from: .grid, direction: .up),
                highlightArea: .grid,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Visuell feedback",
                description: "Ljusstyrkan på steget visar velocity - ljusare = hårdare slag.",
                action: nil,
                highlightArea: .grid,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Mikrotiming",
                description: "I inspektören kan du justera TIME för att förskjuta noter framåt eller bakåt.",
                action: .tap(area: .inspector),
                highlightArea: .inspector,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Swing",
                description: "Justera SWING i transportfältet för att ge ditt beat shuffle-känsla.",
                action: .tap(area: .transport),
                highlightArea: .transport,
                imageURL: nil,
                videoTimestamp: nil
            )
        ],
        videoURL: nil
    )
    
    static let patternsAndArrangement = Tutorial(
        id: "patterns-arrangement",
        title: "Mönster & Arrangement",
        description: "Organisera din musik",
        icon: "square.grid.2x2",
        duration: "8 min",
        difficulty: .intermediate,
        category: .sequencing,
        steps: [
            TutorialStep(
                title: "Flera mönster",
                description: "Du har 4 mönster (P1-P4) för att skapa variationer i din låt.",
                action: nil,
                highlightArea: .patterns,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Byta mönster",
                description: "Tryck på P2 för att byta mönster. Byten sker vid nästa takt.",
                action: .tap(area: .patterns),
                highlightArea: .patterns,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Kopiera mönster",
                description: "Kopiera ett befintligt mönster som utgångspunkt för variationer.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            )
        ],
        videoURL: nil
    )
    
    static let cvBasics = Tutorial(
        id: "cv-basics",
        title: "CV-grunderna",
        description: "Anslut till modulärsynt",
        icon: "bolt",
        duration: "10 min",
        difficulty: .intermediate,
        category: .cv,
        steps: [
            TutorialStep(
                title: "Vad är CV?",
                description: "CV (Control Voltage) är analoga signaler som styr modulärsyntar.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "DC-kopplat ljudkort",
                description: "Du behöver ett DC-kopplat ljudkort som Expert Sleepers ES-9.",
                action: nil,
                highlightArea: .settings,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Konfigurera utgångar",
                description: "Öppna inställningarna och välj ditt ljudkort.",
                action: .tap(area: .settings),
                highlightArea: .settings,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Pitch & Gate",
                description: "Tilldela en kanal för Pitch (1V/oktav) och en för Gate.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            )
        ],
        videoURL: nil
    )
    
    static let adsrDeepDive = Tutorial(
        id: "adsr-deep-dive",
        title: "ADSR på djupet",
        description: "Mästra enveloper",
        icon: "waveform.path",
        duration: "12 min",
        difficulty: .advanced,
        category: .cv,
        steps: [
            TutorialStep(
                title: "ADSR-faserna",
                description: "Attack, Decay, Sustain, Release - fyra faser som formar ljudet.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Skapa en envelop",
                description: "Gå till CV/ADSR-fliken och tryck + ADD.",
                action: .tap(area: .settings),
                highlightArea: .settings,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Kurvtyper",
                description: "Exponentiella kurvor låter mer naturliga för de flesta ljud.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Routing",
                description: "Anslut envelopen till VCA för volymkontroll eller VCF för filter.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            )
        ],
        videoURL: nil
    )
    
    static let advancedTechniques = Tutorial(
        id: "advanced-techniques",
        title: "Avancerade tekniker",
        description: "Polyrytmik, probability & mer",
        icon: "sparkles",
        duration: "15 min",
        difficulty: .advanced,
        category: .advanced,
        steps: [
            TutorialStep(
                title: "Probability",
                description: "Använd PROB för att slumpmässigt aktivera steg - perfekt för hi-hats!",
                action: nil,
                highlightArea: .inspector,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Polyrytmik",
                description: "Olika spårlängder skapar intressanta polymetriska mönster.",
                action: nil,
                highlightArea: nil,
                imageURL: nil,
                videoTimestamp: nil
            ),
            TutorialStep(
                title: "Parameter locks",
                description: "Varje steg kan ha unika parametervärden.",
                action: nil,
                highlightArea: .inspector,
                imageURL: nil,
                videoTimestamp: nil
            )
        ],
        videoURL: nil
    )
}

// MARK: - Tutorial Overlay View

struct TutorialOverlayView: View {
    @ObservedObject var tutorialManager: TutorialManager
    @State private var currentStepIndex: Int = 0
    
    var body: some View {
        if let tutorial = tutorialManager.currentTutorial {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Dismiss on background tap
                    }
                
                // Tutorial card
                VStack(spacing: DS.Space.l) {
                    // Header
                    HStack {
                        Image(systemName: tutorial.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(DS.Color.led)
                        
                        Text(tutorial.title)
                            .font(DS.Font.monoM)
                            .foregroundStyle(DS.Color.textPrimary)
                        
                        Spacer()
                        
                        Button(action: { tutorialManager.closeTutorial() }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(DS.Color.textMuted)
                        }
                    }
                    
                    // Progress
                    ProgressView(value: Double(currentStepIndex + 1), total: Double(tutorial.steps.count))
                        .tint(DS.Color.led)
                    
                    // Step content
                    if currentStepIndex < tutorial.steps.count {
                        let step = tutorial.steps[currentStepIndex]
                        
                        VStack(spacing: DS.Space.m) {
                            Text(step.title)
                                .font(DS.Font.monoM)
                                .foregroundStyle(DS.Color.textPrimary)
                            
                            Text(step.description)
                                .font(DS.Font.monoS)
                                .foregroundStyle(DS.Color.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(DS.Space.m)
                    }
                    
                    // Navigation
                    HStack {
                        if currentStepIndex > 0 {
                            Button("Tillbaka") {
                                withAnimation { currentStepIndex -= 1 }
                            }
                            .foregroundStyle(DS.Color.textSecondary)
                        }
                        
                        Spacer()
                        
                        if currentStepIndex < tutorial.steps.count - 1 {
                            Button("Nästa") {
                                tutorialManager.completeStep(tutorial, stepIndex: currentStepIndex)
                                withAnimation { currentStepIndex += 1 }
                            }
                            .foregroundStyle(DS.Color.led)
                        } else {
                            Button("Klar!") {
                                tutorialManager.completeTutorial(tutorial)
                                tutorialManager.closeTutorial()
                            }
                            .foregroundStyle(DS.Color.led)
                        }
                    }
                }
                .padding(DS.Space.l)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .fill(DS.Color.surface)
                )
                .frame(maxWidth: 400)
                .padding(DS.Space.l)
            }
        }
    }
}

// MARK: - Tutorial List View

struct TutorialListView: View {
    @ObservedObject var tutorialManager: TutorialManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("TUTORIALS")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            ForEach(TutorialCategory.allCases, id: \.self) { category in
                categorySection(category)
            }
        }
    }
    
    private func categorySection(_ category: TutorialCategory) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(DS.Font.monoXS)
            .foregroundStyle(DS.Color.textMuted)
            
            ForEach(tutorialManager.tutorials.filter { $0.category == category }) { tutorial in
                tutorialRow(tutorial)
            }
        }
    }
    
    private func tutorialRow(_ tutorial: Tutorial) -> some View {
        Button(action: { tutorialManager.startTutorial(tutorial) }) {
            HStack {
                Image(systemName: tutorial.icon)
                    .foregroundStyle(DS.Color.led)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tutorial.title)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    HStack(spacing: DS.Space.xs) {
                        Text(tutorial.duration)
                        Text("•")
                        Text(tutorial.difficulty.rawValue)
                            .foregroundStyle(tutorial.difficulty.color)
                    }
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                }
                
                Spacer()
                
                if tutorialManager.isCompleted(tutorial) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    let progress = tutorialManager.progressPercent(for: tutorial)
                    if progress > 0 {
                        Text("\(Int(progress * 100))%")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
            }
            .padding(DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(DS.Color.surface)
            )
        }
        .buttonStyle(.plain)
    }
}
