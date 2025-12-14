import SwiftUI

/// Help system model for contextual assistance
struct HelpTopic: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let summary: String
    let content: [HelpSection]
    let relatedTopics: [String]
    let keywords: [String]
}

struct HelpSection: Identifiable, Equatable {
    let id = UUID()
    let heading: String?
    let body: String
    let tip: String?
    let warning: String?
}

/// Chat message for help assistant
struct HelpMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let relatedTopicID: String?
    
    init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        relatedTopicID: String? = nil
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.relatedTopicID = relatedTopicID
    }
}

/// Quick action suggestions
struct QuickAction: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let action: HelpAction
}

enum HelpAction {
    case showTopic(String)
    case showGuide
    case showShortcuts
    case showTips
    case askQuestion(String)
}

// MARK: - Help Content Database

enum HelpContent {
    
    // MARK: - All Topics
    
    static let allTopics: [HelpTopic] = [
        gettingStarted,
        stepSequencing,
        transportControls,
        trackManagement,
        patternManagement,
        cvOutput,
        adsrEnvelopes,
        audioInterface,
        keyboardShortcuts,
        troubleshooting
    ]
    
    // MARK: - Getting Started
    
    static let gettingStarted = HelpTopic(
        id: "getting-started",
        title: "Komma igång",
        icon: "sparkles",
        summary: "Lär dig grunderna i sekvensern",
        content: [
            HelpSection(
                heading: "Välkommen till MakeNoise Sequencer!",
                body: """
                Den här sekvensern är inspirerad av Cirklon och designad för att styra modulärsyntar via CV/Gate-utgångar.
                
                Gränssnittet är uppbyggt som en klassisk trummaskin med ett 64-stegs rutnät där du kan programmera mönster för flera spår samtidigt.
                """,
                tip: "Börja med att trycka på stegen i rutnätet för att aktivera noter!",
                warning: nil
            ),
            HelpSection(
                heading: "Grundläggande arbetsflöde",
                body: """
                1. Välj ett spår i sidofältet (KICK, SNARE, etc.)
                2. Tryck på steg i rutnätet för att aktivera/avaktivera
                3. Tryck på PLAY för att höra ditt mönster
                4. Justera BPM och SWING efter smak
                5. Byt mellan mönster (P1-P4) för variationer
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["step-sequencing", "transport-controls"],
        keywords: ["start", "börja", "intro", "grunderna", "tutorial"]
    )
    
    // MARK: - Step Sequencing
    
    static let stepSequencing = HelpTopic(
        id: "step-sequencing",
        title: "Stegsekvensering",
        icon: "square.grid.4x3.fill",
        summary: "Hur du programmerar steg och mönster",
        content: [
            HelpSection(
                heading: "Rutnätet",
                body: """
                Rutnätet visar 64 steg (4 takter × 16 steg) för varje spår. Varje steg representerar en 16-delsnot.
                
                • Aktiva steg lyser upp med spårets färg
                • Ljusstyrkan visar velocity (hur hårt noten spelas)
                • Den aktuella positionen visas med en pulserande LED
                """,
                tip: "Scrolla horisontellt för att se alla 64 steg",
                warning: nil
            ),
            HelpSection(
                heading: "Redigera steg",
                body: """
                • TAP - Aktivera/avaktivera steg
                • DROG VERTIKALT - Justera velocity
                • LÅNGTRYCK - Öppna inspektören för detaljerad redigering
                """,
                tip: "Håll SHIFT och tryck på flera steg för att markera flera samtidigt",
                warning: nil
            ),
            HelpSection(
                heading: "Inspektören",
                body: """
                I inspektören kan du finjustera varje steg:
                
                • NOTE - MIDI-not (C0-G10)
                • VEL - Velocity/styrka (1-127)
                • LEN - Notlängd i ticks
                • TIME - Mikrotiming offset
                • PROB - Sannolikhet att steget spelas (0-100%)
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["track-management", "pattern-management"],
        keywords: ["steg", "step", "grid", "rutnät", "velocity", "not", "programmera"]
    )
    
    // MARK: - Transport Controls
    
    static let transportControls = HelpTopic(
        id: "transport-controls",
        title: "Transport & Tempo",
        icon: "play.fill",
        summary: "Play, stop, BPM och swing",
        content: [
            HelpSection(
                heading: "Transportkontroller",
                body: """
                • PLAY/STOP - Starta och stoppa uppspelning
                • BPM - Tempo i slag per minut (20-300)
                • SWING - Timing-förskjutning för groove (0-100%)
                """,
                tip: "Swing på 50% = rakt, högre värden ger mer shuffle",
                warning: nil
            ),
            HelpSection(
                heading: "Synkronisering",
                body: """
                Sekvensern kan synkroniseras med extern utrustning via:
                • MIDI Clock
                • CV Clock (via DC-kopplat ljudkort)
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["getting-started"],
        keywords: ["play", "stop", "bpm", "tempo", "swing", "groove", "transport"]
    )
    
    // MARK: - Track Management
    
    static let trackManagement = HelpTopic(
        id: "track-management",
        title: "Spårhantering",
        icon: "list.bullet",
        summary: "Arbeta med flera spår",
        content: [
            HelpSection(
                heading: "Spårlistan",
                body: """
                I sidofältet ser du alla spår. Varje spår har:
                • Färgkodad indikator
                • Namn (KICK, SNARE, HAT, BASS)
                • MIDI-kanal
                • Mute/Solo-knappar
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "Mute & Solo",
                body: """
                • MUTE (M) - Tystar spåret utan att ta bort stegen
                • SOLO (S) - Spelar bara detta spår, tystar alla andra
                
                Du kan ha flera spår på solo samtidigt.
                """,
                tip: "Dubbelklicka på SOLO för att återställa alla spår",
                warning: nil
            )
        ],
        relatedTopics: ["step-sequencing"],
        keywords: ["spår", "track", "mute", "solo", "kanal"]
    )
    
    // MARK: - Pattern Management
    
    static let patternManagement = HelpTopic(
        id: "pattern-management",
        title: "Mönsterhantering",
        icon: "square.grid.2x2",
        summary: "Byta och hantera mönster",
        content: [
            HelpSection(
                heading: "Mönsterväljaren",
                body: """
                Överst i rutnätsvyn finns mönsterväljaren (P1-P4).
                
                • Tryck för att byta mönster direkt
                • Aktuellt mönster markeras med fylld bakgrund
                • Köat mönster (nästa att spelas) visas med ram
                """,
                tip: "Mönsterbyten sker vid nästa takt för smidig övergång",
                warning: nil
            ),
            HelpSection(
                heading: "Kopiera mönster",
                body: """
                Du kan kopiera ett mönster till en annan plats:
                1. Välj källmönstret
                2. Använd menyn för att kopiera
                3. Välj destinationsmönster
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["step-sequencing"],
        keywords: ["mönster", "pattern", "kopiera", "byta"]
    )
    
    // MARK: - CV Output
    
    static let cvOutput = HelpTopic(
        id: "cv-output",
        title: "CV-utgångar",
        icon: "bolt",
        summary: "Skicka CV till modulärsynt",
        content: [
            HelpSection(
                heading: "Vad är CV?",
                body: """
                CV (Control Voltage) är analoga signaler som används för att styra modulärsyntar.
                
                • Pitch CV - Styr tonhöjd (vanligtvis 1V/oktav)
                • Gate - On/off-signal för att trigga enveloper
                • Velocity CV - Styrka/dynamik
                • Modulation - För att styra filter, LFO, etc.
                """,
                tip: nil,
                warning: "Du behöver ett DC-kopplat ljudkort för att skicka CV!"
            ),
            HelpSection(
                heading: "Konfigurera CV-utgångar",
                body: """
                1. Öppna inställningarna (kugghjulet i transportfältet)
                2. Välj ditt DC-kopplade ljudkort
                3. Konfigurera vilka kanaler som ska skicka vad
                4. Koppla utgångarna till din modulärsynt
                """,
                tip: "Expert Sleepers ES-9 rekommenderas för bäst CV-prestanda",
                warning: nil
            )
        ],
        relatedTopics: ["audio-interface", "adsr-envelopes"],
        keywords: ["cv", "gate", "voltage", "modulär", "pitch", "eurorack"]
    )
    
    // MARK: - ADSR Envelopes
    
    static let adsrEnvelopes = HelpTopic(
        id: "adsr-envelopes",
        title: "ADSR-enveloper",
        icon: "waveform.path",
        summary: "Skapa envelop-CV för VCA, VCF, etc.",
        content: [
            HelpSection(
                heading: "Vad är ADSR?",
                body: """
                ADSR står för Attack, Decay, Sustain, Release:
                
                • ATTACK - Tid för att nå maxnivå
                • DECAY - Tid för att sjunka till sustain
                • SUSTAIN - Nivå som hålls medan noten är aktiv
                • RELEASE - Tid för att återgå till noll
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "Skapa en CV-envelop",
                body: """
                1. Gå till CV/ADSR-fliken i inställningarna
                2. Tryck "+ ADD" för att skapa en ny envelop
                3. Välj källspår (triggerkälla)
                4. Justera ADSR-parametrarna
                5. Välj destination (VCA, VCF, etc.)
                """,
                tip: "Använd presets som utgångspunkt och finjustera sedan",
                warning: nil
            ),
            HelpSection(
                heading: "Kurvtyper",
                body: """
                Varje fas kan ha olika kurvform:
                
                • Linear - Rak linje
                • Exponential - Snabb start, långsam slut
                • Logarithmic - Långsam start, snabb slut
                • S-Curve - Mjuk övergång
                """,
                tip: "Exponentiell decay låter mest naturligt för de flesta ljud",
                warning: nil
            )
        ],
        relatedTopics: ["cv-output", "audio-interface"],
        keywords: ["adsr", "envelope", "attack", "decay", "sustain", "release", "vca", "vcf"]
    )
    
    // MARK: - Audio Interface
    
    static let audioInterface = HelpTopic(
        id: "audio-interface",
        title: "Ljudkort",
        icon: "cable.connector",
        summary: "Välj och konfigurera ljudkort",
        content: [
            HelpSection(
                heading: "DC-kopplade ljudkort",
                body: """
                För att skicka CV behöver du ett DC-kopplat ljudkort. Vanliga ljudkort filtrerar bort DC-komponenten (AC-kopplade).
                
                Rekommenderade modeller:
                • Expert Sleepers ES-9 (16 in/out, ±10V)
                • Expert Sleepers ES-8 (8 out, 4 in)
                • MOTU UltraLite mk5 (±5V)
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "Spänningsområden",
                body: """
                Olika ljudkort har olika spänningsområden:
                
                • ±10V - Fullt Eurorack-kompatibelt
                • ±5V - Fungerar men med begränsat omfång
                • 0-5V - Endast positiva spänningar
                """,
                tip: "ES-9 med ±10V ger bäst kompatibilitet med Eurorack",
                warning: nil
            )
        ],
        relatedTopics: ["cv-output"],
        keywords: ["ljudkort", "audio interface", "es-9", "es-8", "motu", "dc-coupled"]
    )
    
    // MARK: - Keyboard Shortcuts
    
    static let keyboardShortcuts = HelpTopic(
        id: "keyboard-shortcuts",
        title: "Tangentbordsgenvägar",
        icon: "keyboard",
        summary: "Snabba genvägar för effektivt arbete",
        content: [
            HelpSection(
                heading: "Transport",
                body: """
                • SPACE - Play/Stop
                • ENTER - Play från början
                • ESC - Stop och återställ
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "Navigation",
                body: """
                • ↑↓ - Byt spår
                • ←→ - Flytta i rutnätet
                • 1-4 - Byt mönster (P1-P4)
                • TAB - Växla inspektör
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "Redigering",
                body: """
                • DELETE - Ta bort markerade steg
                • CMD+C - Kopiera
                • CMD+V - Klistra in
                • CMD+Z - Ångra
                • CMD+A - Markera alla
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["getting-started"],
        keywords: ["tangentbord", "keyboard", "genvägar", "shortcuts", "snabbkommandon"]
    )
    
    // MARK: - Troubleshooting
    
    static let troubleshooting = HelpTopic(
        id: "troubleshooting",
        title: "Felsökning",
        icon: "wrench.and.screwdriver",
        summary: "Lösningar på vanliga problem",
        content: [
            HelpSection(
                heading: "Inget ljud",
                body: """
                1. Kontrollera att spåret inte är MUTE
                2. Kontrollera att steg är aktiverade
                3. Verifiera MIDI/CV-kopplingar
                4. Kontrollera ljudkortsinställningar
                """,
                tip: nil,
                warning: nil
            ),
            HelpSection(
                heading: "CV fungerar inte",
                body: """
                1. Är ljudkortet DC-kopplat?
                2. Är rätt utgångskanal vald?
                3. Är CV-spåret aktiverat (ON)?
                4. Kontrollera kablarna till modulärsynthen
                """,
                tip: "Testa med ett enkelt patch först - en oscillator och VCA",
                warning: nil
            ),
            HelpSection(
                heading: "Timing-problem",
                body: """
                1. Kontrollera BPM-inställningen
                2. Stäng av swing om du vill ha rakt tempo
                3. Vid extern sync, kontrollera clock-källan
                """,
                tip: nil,
                warning: nil
            )
        ],
        relatedTopics: ["cv-output", "audio-interface"],
        keywords: ["problem", "fel", "fungerar inte", "hjälp", "support"]
    )
    
    // MARK: - Search
    
    static func search(_ query: String) -> [HelpTopic] {
        let lowercased = query.lowercased()
        return allTopics.filter { topic in
            topic.title.lowercased().contains(lowercased) ||
            topic.summary.lowercased().contains(lowercased) ||
            topic.keywords.contains { $0.lowercased().contains(lowercased) }
        }
    }
    
    // MARK: - Quick Answers
    
    static func quickAnswer(for query: String) -> String? {
        let lowercased = query.lowercased()
        
        // Common questions
        if lowercased.contains("hur") && lowercased.contains("börja") {
            return "Tryck på stegen i rutnätet för att aktivera noter, sedan PLAY för att höra ditt mönster! Se 'Komma igång' för mer detaljer."
        }
        
        if lowercased.contains("cv") && (lowercased.contains("vad") || lowercased.contains("hur")) {
            return "CV (Control Voltage) är analoga signaler för att styra modulärsyntar. Du behöver ett DC-kopplat ljudkort som Expert Sleepers ES-9. Se 'CV-utgångar' för mer info."
        }
        
        if lowercased.contains("adsr") || lowercased.contains("envelope") {
            return "ADSR står för Attack, Decay, Sustain, Release - fyra faser som formar hur ett ljud utvecklas över tid. Gå till CV/ADSR-fliken i inställningarna för att skapa enveloper."
        }
        
        if lowercased.contains("mute") || lowercased.contains("solo") {
            return "MUTE (M) tystar ett spår, SOLO (S) spelar bara det spåret. Du hittar knapparna i spårlistan till vänster."
        }
        
        if lowercased.contains("tempo") || lowercased.contains("bpm") {
            return "Justera BPM i transportfältet överst. Klicka på pilarna eller dra för att ändra tempo (20-300 BPM)."
        }
        
        if lowercased.contains("swing") || lowercased.contains("groove") {
            return "Swing ger en 'shuffle'-känsla genom att förskjuta vissa steg. 50% = rakt, högre värden = mer swing. Justera i transportfältet."
        }
        
        if lowercased.contains("velocity") || lowercased.contains("styrka") {
            return "Velocity bestämmer hur hårt en not spelas (1-127). Dra vertikalt på ett steg för att justera, eller använd inspektören."
        }
        
        return nil
    }
}
