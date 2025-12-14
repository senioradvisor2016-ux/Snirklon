# 🔍 Analys och Förbättringsförslag

## Sammanfattning

MakeNoise Sequencer är en välstrukturerad SwiftUI-app med god separation av concerns. Kodbasen följer moderna SwiftUI-mönster och har ett konsekvent designsystem. Nedan följer en detaljerad analys med prioriterade förbättringsförslag.

---

## 📊 Övergripande bedömning

| Område | Betyg | Kommentar |
|--------|-------|-----------|
| **Arkitektur** | ⭐⭐⭐⭐ | Bra separation, men Store växer |
| **Kodkvalitet** | ⭐⭐⭐⭐ | Konsekvent, välskriven |
| **Designsystem** | ⭐⭐⭐⭐⭐ | Utmärkt token-baserat system |
| **Prestanda** | ⭐⭐⭐ | Potential för optimering |
| **Testbarhet** | ⭐⭐ | Saknar tester |
| **Tillgänglighet** | ⭐⭐⭐⭐ | Bra grund, kan förbättras |

---

## 🔴 Kritiska förbättringar (Prioritet: HÖG)

### 1. Dela upp SequencerStore

**Problem:** `SequencerStore` är 450+ rader och hanterar för många ansvarsområden.

**Lösning:** Bryt ut till domän-specifika stores:

```swift
// FÖRE: En stor store
class SequencerStore: ObservableObject { /* 450+ rader */ }

// EFTER: Domän-separerade stores
class TransportStore: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var bpm: Int = 120
    @Published var swing: Int = 50
    @Published var currentStep: Int = 0
    
    func play() { ... }
    func stop() { ... }
}

class PatternStore: ObservableObject {
    @Published var patterns: [PatternModel] = []
    @Published var currentPatternIndex: Int = 0
    
    func selectPattern(_ index: Int) { ... }
}

class SelectionStore: ObservableObject {
    @Published var selectedTrackID: UUID?
    @Published var selectedStepIDs: Set<UUID> = []
}

// Koordinator som kombinerar alla stores
class SequencerCoordinator: ObservableObject {
    let transport = TransportStore()
    let patterns = PatternStore()
    let selection = SelectionStore()
    let cv = CVStore()
    let ui = UIStore()
}
```

### 2. Lägg till enhetstester

**Problem:** Inga tester finns, vilket gör refaktorering riskabel.

**Lösning:** Skapa tester för kritisk logik:

```swift
// Tests/SequencerTests/TransportTests.swift
import XCTest
@testable import MakeNoiseSequencer

class TransportTests: XCTestCase {
    var store: TransportStore!
    
    override func setUp() {
        store = TransportStore()
    }
    
    func testPlaySetsIsPlayingTrue() {
        store.play()
        XCTAssertTrue(store.isPlaying)
    }
    
    func testBPMClampedToValidRange() {
        store.setBPM(500)
        XCTAssertEqual(store.bpm, 300) // Max
        
        store.setBPM(5)
        XCTAssertEqual(store.bpm, 20) // Min
    }
    
    func testSwingCalculation() {
        store.setSwing(75)
        let expected = 0.125 // 25% av 0.5
        XCTAssertEqual(store.swingOffset, expected, accuracy: 0.01)
    }
}
```

### 3. Implementera riktig Undo-integration

**Problem:** UndoManager finns men är inte kopplad till state-ändringar.

**Lösning:**

```swift
// Före varje state-ändring, registrera undo
func toggleStep(_ stepID: UUID) {
    guard let (patternIdx, trackIdx, stepIdx) = findStep(stepID) else { return }
    
    let previousState = patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn
    
    // Registrera undo
    undoManager.registerUndo(
        name: "Växla steg",
        undo: { [weak self] in
            self?.patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn = previousState
        },
        redo: { [weak self] in
            self?.patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn.toggle()
        }
    )
    
    // Utför ändring
    patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn.toggle()
}
```

---

## 🟡 Viktiga förbättringar (Prioritet: MEDEL)

### 4. Optimera StepGridView för prestanda

**Problem:** Alla 64 steg × 4 spår = 256 vyer renderas om vid varje ändring.

**Lösning:**

```swift
struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        // Använd LazyVStack för att bara rendera synliga rader
        ScrollView([.horizontal, .vertical]) {
            LazyVStack(spacing: DS.Space.s) {
                if let pattern = store.currentPattern {
                    ForEach(pattern.tracks) { track in
                        // Extrahera till egen vy som bara uppdateras när spåret ändras
                        TrackRowContainer(track: track)
                    }
                }
            }
        }
    }
}

// Separera för att isolera uppdateringar
struct TrackRowContainer: View {
    let track: TrackModel
    
    var body: some View {
        // Använd EquatableView för att undvika onödiga re-renders
        EquatableView(content: TrackRowView(track: track))
    }
}
```

### 5. Lägg till riktigt ljud/MIDI-output

**Problem:** Sekvensern spelar men producerar inget ljud.

**Lösning:**

```swift
import CoreMIDI
import AVFoundation

class AudioEngine: ObservableObject {
    private var midiClient: MIDIClientRef = 0
    private var outputPort: MIDIPortRef = 0
    
    init() {
        setupMIDI()
    }
    
    private func setupMIDI() {
        MIDIClientCreate("MakeNoise" as CFString, nil, nil, &midiClient)
        MIDIOutputPortCreate(midiClient, "Output" as CFString, &outputPort)
    }
    
    func sendNoteOn(note: UInt8, velocity: UInt8, channel: UInt8) {
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        packet.data.0 = 0x90 | channel  // Note On
        packet.data.1 = note
        packet.data.2 = velocity
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        
        // Send to all destinations
        for i in 0..<MIDIGetNumberOfDestinations() {
            let dest = MIDIGetDestination(i)
            MIDISend(outputPort, dest, &packetList)
        }
    }
    
    func sendNoteOff(note: UInt8, channel: UInt8) {
        // Similar implementation...
    }
}
```

### 6. Implementera riktigt CV-output via Audio Unit

**Problem:** CV-konfiguration finns men ingen faktisk signal genereras.

**Lösning:**

```swift
import AudioToolbox
import AVFoundation

class CVOutputEngine: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var cvGeneratorNode: AVAudioSourceNode?
    
    // Sample buffer för CV-signal
    private var cvBuffer: [Float] = []
    
    func setupCVOutput(channels: Int) {
        audioEngine = AVAudioEngine()
        
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 48000,
            channels: AVAudioChannelCount(channels),
            interleaved: false
        )!
        
        cvGeneratorNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            self?.renderCV(frameCount: frameCount, bufferList: audioBufferList)
            return noErr
        }
        
        audioEngine?.attach(cvGeneratorNode!)
        audioEngine?.connect(cvGeneratorNode!, to: audioEngine!.mainMixerNode, format: format)
        
        try? audioEngine?.start()
    }
    
    private func renderCV(frameCount: AVAudioFrameCount, bufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        // Generera ADSR envelope
        // Skala till rätt spänningsområde
        // Fyll buffer med CV-värden
        return noErr
    }
}
```

---

## 🟢 Mindre förbättringar (Prioritet: LÅG)

### 7. Förbättra tillgänglighet ytterligare

```swift
// Lägg till mer detaljerade labels
struct StepCellView: View {
    var body: some View {
        // ... existing code ...
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Dubbelklicka för att växla. Dra vertikalt för velocity.")
        .accessibilityAddTraits(step.isOn ? .isSelected : [])
    }
    
    private var accessibilityLabel: String {
        "Steg \(step.index + 1), \(step.isOn ? "aktivt" : "inaktivt")"
    }
    
    private var accessibilityValue: String {
        step.isOn ? "Velocity \(step.velocity), Not \(noteName(step.note))" : "Tom"
    }
    
    private func noteName(_ midiNote: Int) -> String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = (midiNote / 12) - 1
        let note = notes[midiNote % 12]
        return "\(note)\(octave)"
    }
}
```

### 8. Lägg till tangentbordsnavigation

```swift
struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    @FocusState private var focusedStep: UUID?
    
    var body: some View {
        // ... existing code ...
        .focusable()
        .focused($focusedStep)
        .onKeyPress(.space) {
            store.togglePlayback()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            moveFocus(direction: .left)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            moveFocus(direction: .right)
            return .handled
        }
        .onKeyPress(.upArrow) {
            moveFocus(direction: .up)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveFocus(direction: .down)
            return .handled
        }
        .onKeyPress(.return) {
            if let stepID = focusedStep {
                store.toggleStep(stepID)
            }
            return .handled
        }
    }
}
```

### 9. Optimera designsystem med dynamic colors

```swift
enum DS {
    enum Color {
        // Använd semantic colors för automatisk dark/light mode
        static let background = SwiftUI.Color("Background")
        static let surface = SwiftUI.Color("Surface")
        
        // Eller beräkna dynamiskt
        static func background(for colorScheme: ColorScheme) -> SwiftUI.Color {
            colorScheme == .dark 
                ? SwiftUI.Color.black.opacity(0.96)
                : SwiftUI.Color.white.opacity(0.96)
        }
    }
}
```

### 10. Lägg till dokumentationskommentarer

```swift
/// Representerar ett enskilt steg i sekvensern.
///
/// Varje steg har en position (index), on/off-state, och flera
/// parametrar som påverkar hur noten spelas.
///
/// ## Exempel
/// ```swift
/// var step = StepModel(index: 0)
/// step.isOn = true
/// step.velocity = 100
/// step.note = 60 // Middle C
/// ```
///
/// ## MIDI-mapping
/// - `note`: MIDI-notnummer (0-127)
/// - `velocity`: MIDI velocity (1-127)
/// - `length`: Längd i ticks (1-96)
struct StepModel: Identifiable, Equatable {
    // ...
}
```

---

## 🏗️ Arkitekturförslag

### Nuvarande arkitektur

```
┌─────────────────────────────────────────────┐
│                    Views                     │
│  (StepGridView, TransportBarView, etc.)     │
└─────────────────────┬───────────────────────┘
                      │ @EnvironmentObject
                      ▼
┌─────────────────────────────────────────────┐
│              SequencerStore                  │
│  (450+ rader, alla managers)                │
└─────────────────────────────────────────────┘
```

### Föreslagen arkitektur

```
┌─────────────────────────────────────────────┐
│                    Views                     │
└──────────┬──────────────────────┬───────────┘
           │                      │
           ▼                      ▼
┌──────────────────┐    ┌──────────────────┐
│  ViewModels      │    │  Managers        │
│  (per feature)   │    │  (singleton)     │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────┐
│              Domain Services                 │
│  TransportService, PatternService, etc.     │
└─────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│                 Models                       │
│  StepModel, TrackModel, PatternModel        │
└─────────────────────────────────────────────┘
```

---

## 📈 Prestanda-optimeringar

### Mätbar förbättring

| Område | Nuvarande | Mål | Metod |
|--------|-----------|-----|-------|
| Grid render | ~16ms | <8ms | LazyVStack |
| Step toggle | ~5ms | <2ms | Lokal state |
| Pattern switch | ~20ms | <10ms | Preload |
| Memory | ~50MB | ~30MB | Cache management |

### Implementera caching

```swift
class PatternCache {
    private var cache: [Int: PatternModel] = [:]
    private let maxCacheSize = 8
    
    func preloadPattern(_ index: Int, from patterns: [PatternModel]) {
        guard index < patterns.count else { return }
        
        // Preload next/prev patterns
        let indicesToCache = [index - 1, index, index + 1].filter { $0 >= 0 && $0 < patterns.count }
        
        for i in indicesToCache {
            cache[i] = patterns[i]
        }
        
        // Evict old entries
        if cache.count > maxCacheSize {
            let oldestKey = cache.keys.filter { !indicesToCache.contains($0) }.first
            if let key = oldestKey {
                cache.removeValue(forKey: key)
            }
        }
    }
}
```

---

## ✅ Implementationsplan

### Fas 1: Stabilitet (1-2 veckor)
- [ ] Lägg till grundläggande tester
- [ ] Implementera riktig undo-integration
- [ ] Fixa minnesläckor i timer

### Fas 2: Prestanda (1 vecka)
- [ ] Optimera grid rendering
- [ ] Implementera lazy loading
- [ ] Lägg till pattern caching

### Fas 3: Arkitektur (2-3 veckor)
- [ ] Bryt ut SequencerStore
- [ ] Skapa feature-modules
- [ ] Dokumentera API

### Fas 4: Funktionalitet (2+ veckor)
- [ ] Implementera MIDI output
- [ ] Implementera CV output
- [ ] Lägg till audio preview

---

## 🎯 Sammanfattning

De viktigaste förbättringarna att prioritera:

1. **Dela upp SequencerStore** - Förbättrar underhållbarhet och testbarhet
2. **Lägg till tester** - Möjliggör säker refaktorering
3. **Optimera prestanda** - Bättre användarupplevelse
4. **Implementera ljud** - Gör appen funktionell

Kodbasen har en solid grund och följer bra mönster. Med dessa förbättringar blir den en professionell produkt.
