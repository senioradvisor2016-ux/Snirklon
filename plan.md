# Snirklon - Cirklon-inspirerad Sequencer i Swift

## Projektöversikt

Snirklon är en professionell MIDI-sequencer inspirerad av Sequentix Cirklon, byggd i Swift för macOS/iOS. Projektet implementerar alla kärnfunktioner från Cirklon tillsammans med modern MIDI-utmatning, MIDI-synkronisering och Ableton Link-integration.

---

## Fas 1: Grundläggande Arkitektur & Datamodeller

### 1.1 Projektstruktur

```
Snirklon/
├── Sources/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Engine/
│   │   ├── MIDI/
│   │   └── Sync/
│   ├── UI/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Components/
│   └── Utils/
├── Tests/
├── Resources/
└── Package.swift
```

### 1.2 Datamodeller (Core/Models/)

#### Project.swift
```swift
struct Project {
    var name: String
    var tempo: Double              // 20-300 BPM
    var timeSignature: TimeSignature
    var patterns: [Pattern]
    var songs: [Song]
    var instruments: [Instrument]  // Upp till 64 instrument
    var globalSettings: GlobalSettings
}
```

#### Pattern.swift
```swift
struct Pattern {
    var id: UUID
    var name: String
    var tracks: [Track]            // Upp till 64 spår per pattern
    var length: Int                // 1-128 steg
    var timeSignature: TimeSignature
    var swing: Double              // 0-100%
    var scale: Scale?              // Valfri skala för kvantisering
}
```

#### Track.swift
```swift
struct Track {
    var id: UUID
    var name: String
    var type: TrackType            // .instrument, .cv, .auxiliary, .p3
    var instrumentId: UUID?
    var steps: [Step]
    var length: Int                // Individuell spårlängd (polymetrisk)
    var muted: Bool
    var solo: Bool
    var transpose: Int             // -48 till +48 halvtoner
    var velocity: Int              // Standardvelocity
    var gateTime: Double           // Standardgate-tid
    var midiChannel: Int           // 1-16
    var outputPort: MIDIOutputPort
    
    // P3-modulatorer per spår
    var p3Modulators: [P3Modulator]
}

enum TrackType {
    case instrument    // CK-spår för noter
    case cv            // CV/Gate-utmatning
    case auxiliary     // Hjälpspår för CC/NRPN
    case p3            // Parametermoduleringsspår
}
```

#### Step.swift
```swift
struct Step {
    var enabled: Bool
    var note: Note?
    var velocity: Int?             // 1-127, nil = använd spårets standard
    var gateTime: Double?          // 0-400%, nil = använd spårets standard
    var probability: Int           // 0-100%
    var condition: StepCondition   // Villkorlig triggning
    var ratchet: Ratchet?          // Roll/upprepningar
    var microTiming: Int           // -96 till +96 ticks offset
    var chord: [Int]?              // Ytterligare noter för ackord
    var slide: Bool                // Legato/glide till nästa steg
    var accent: Bool
    
    // Parametermodulering per steg
    var parameterLocks: [ParameterLock]
}

struct Note {
    var pitch: Int                 // 0-127 MIDI-not
    var octave: Int                // -2 till +8
}

struct Ratchet {
    var count: Int                 // 1-8 upprepningar
    var velocity: RatchetVelocity  // .constant, .decay, .crescendo
    var gatePattern: [Bool]        // Vilka ratchets som spelas
}

enum StepCondition {
    case always
    case fill                      // Endast vid fill
    case notFill                   // Inte vid fill
    case firstLoop
    case notFirstLoop
    case probability(Int)          // X% chans
    case aPattern                  // 1:2, 2:2, 1:3, 2:3, 3:3, etc.
    case bPattern
    case pre                       // Pre-condition (beroende av förra steget)
    case nei                       // Neighbor condition
}
```

#### Instrument.swift
```swift
struct Instrument {
    var id: UUID
    var name: String
    var midiChannel: Int           // 1-16
    var outputPort: MIDIOutputPort
    var bankMSB: Int?
    var bankLSB: Int?
    var program: Int?
    var transpose: Int
    var velocityOffset: Int
    
    // Instrumentspecifika parametrar för P3
    var parameters: [InstrumentParameter]
}

struct InstrumentParameter {
    var name: String
    var ccNumber: Int?             // CC 0-127
    var nrpnMSB: Int?
    var nrpnLSB: Int?
    var min: Int
    var max: Int
    var defaultValue: Int
}
```

### 1.3 Tidssystem

#### TimeSignature.swift
```swift
struct TimeSignature {
    var numerator: Int             // 1-32
    var denominator: Int           // 1, 2, 4, 8, 16, 32
}
```

#### Clock.swift
```swift
struct ClockPosition {
    var bar: Int
    var beat: Int
    var tick: Int                  // 96 PPQN (Pulses Per Quarter Note)
}
```

---

## Fas 2: Sequencer Engine

### 2.1 Huvudmotor (Core/Engine/)

#### SequencerEngine.swift
```swift
class SequencerEngine: ObservableObject {
    // Tillstånd
    @Published var isPlaying: Bool
    @Published var isRecording: Bool
    @Published var currentPosition: ClockPosition
    @Published var tempo: Double
    
    // Komponenter
    private var clockSource: ClockSource
    private var midiEngine: MIDIEngine
    private var linkSession: LinkSession?
    
    // Metoder
    func play()
    func stop()
    func pause()
    func record()
    func setTempo(_ bpm: Double)
    func setPosition(_ position: ClockPosition)
    
    // Pattern-hantering
    func queuePattern(_ pattern: Pattern, immediate: Bool)
    func getCurrentPattern() -> Pattern
    
    // Intern tick-hantering
    private func processTick(_ tick: Int)
    private func processStep(track: Track, stepIndex: Int)
}
```

#### ClockSource.swift
```swift
protocol ClockSource {
    var tempo: Double { get set }
    var isRunning: Bool { get }
    var tickCallback: ((Int) -> Void)? { get set }
    
    func start()
    func stop()
}

class InternalClock: ClockSource {
    // Högprecisionstimer med CoreAudio/AudioToolbox
    private var audioUnit: AudioUnit?
    // 96 PPQN timing
}

class MIDIClock: ClockSource {
    // Slav till extern MIDI-klocka
    // Hanterar MIDI Clock, Start, Stop, Continue
}

class LinkClock: ClockSource {
    // Ableton Link-synkronisering
    // Fas- och tempo-synk
}
```

### 2.2 Step Processing

#### StepProcessor.swift
```swift
class StepProcessor {
    func processStep(
        step: Step,
        track: Track,
        context: PlaybackContext
    ) -> [MIDIEvent]? {
        
        // 1. Kontrollera sannolikhet
        guard checkProbability(step) else { return nil }
        
        // 2. Kontrollera villkor
        guard checkCondition(step.condition, context) else { return nil }
        
        // 3. Beräkna timing (inkl. micro-timing och swing)
        let timing = calculateTiming(step, track, context)
        
        // 4. Generera MIDI-events
        var events: [MIDIEvent] = []
        
        // Huvudnot
        if let note = step.note {
            events.append(createNoteEvent(note, step, track, timing))
        }
        
        // Ackordnoter
        if let chord = step.chord {
            events.append(contentsOf: createChordEvents(chord, step, track, timing))
        }
        
        // Ratchets
        if let ratchet = step.ratchet {
            events.append(contentsOf: createRatchetEvents(ratchet, step, track, timing))
        }
        
        // Parameter locks
        events.append(contentsOf: createParameterLockEvents(step.parameterLocks, timing))
        
        return events
    }
}
```

### 2.3 Pattern Chaining & Song Mode

#### PatternChain.swift
```swift
struct PatternChain {
    var patterns: [PatternReference]
    var loopStart: Int?
    var loopEnd: Int?
}

struct PatternReference {
    var patternId: UUID
    var repetitions: Int           // 1-64
    var transpose: Int
    var tempo: Double?             // Valfri tempoändring
}
```

#### Song.swift
```swift
struct Song {
    var id: UUID
    var name: String
    var sections: [SongSection]
}

struct SongSection {
    var name: String
    var chains: [PatternChain]     // Parallella kedjor per instrumentgrupp
    var repetitions: Int
}
```

---

## Fas 3: MIDI-system

### 3.1 MIDI Engine (Core/MIDI/)

#### MIDIEngine.swift
```swift
class MIDIEngine {
    private var midiClient: MIDIClientRef = 0
    private var outputPorts: [String: MIDIPortRef] = [:]
    private var inputPorts: [String: MIDIPortRef] = [:]
    
    // Initiering
    func setup() throws
    func listAvailableOutputs() -> [MIDIEndpointInfo]
    func listAvailableInputs() -> [MIDIEndpointInfo]
    
    // Output
    func send(_ event: MIDIEvent, to port: MIDIOutputPort)
    func sendSysEx(_ data: [UInt8], to port: MIDIOutputPort)
    
    // Input
    func setInputCallback(_ callback: @escaping (MIDIEvent) -> Void)
    
    // Klocka
    func sendClock()
    func sendStart()
    func sendStop()
    func sendContinue()
    func sendSongPosition(_ position: Int)
}
```

#### MIDIEvent.swift
```swift
enum MIDIEvent {
    case noteOn(channel: Int, note: Int, velocity: Int, timestamp: UInt64)
    case noteOff(channel: Int, note: Int, velocity: Int, timestamp: UInt64)
    case controlChange(channel: Int, controller: Int, value: Int, timestamp: UInt64)
    case programChange(channel: Int, program: Int, timestamp: UInt64)
    case pitchBend(channel: Int, value: Int, timestamp: UInt64)
    case aftertouch(channel: Int, pressure: Int, timestamp: UInt64)
    case polyAftertouch(channel: Int, note: Int, pressure: Int, timestamp: UInt64)
    case nrpn(channel: Int, paramMSB: Int, paramLSB: Int, valueMSB: Int, valueLSB: Int, timestamp: UInt64)
    case sysEx(data: [UInt8], timestamp: UInt64)
    
    // Klockmeddelanden
    case clock
    case start
    case stop
    case `continue`
    case songPosition(position: Int)
}
```

#### MIDIOutputPort.swift
```swift
struct MIDIOutputPort: Identifiable, Codable {
    var id: String
    var name: String
    var isVirtual: Bool
}
```

### 3.2 MIDI Sync (Core/Sync/)

#### MIDISyncManager.swift
```swift
class MIDISyncManager: ObservableObject {
    enum SyncMode {
        case master                // Skicka MIDI-klocka
        case slave                 // Ta emot MIDI-klocka
        case off
    }
    
    @Published var syncMode: SyncMode = .master
    @Published var sendClock: Bool = true
    @Published var sendTransport: Bool = true  // Start/Stop/Continue
    @Published var sendSongPosition: Bool = true
    
    // Slav-läge
    @Published var externalTempo: Double?
    @Published var isLocked: Bool = false
    
    // Konfiguration
    var clockOutputPorts: [MIDIOutputPort] = []
    var clockInputPort: MIDIOutputPort?
    
    func sendClockPulse()
    func handleIncomingClock(_ event: MIDIEvent)
}
```

---

## Fas 4: Ableton Link Integration

### 4.1 Link Session (Core/Sync/)

#### LinkSession.swift
```swift
import LinkKit  // Ableton Link SDK

class LinkSession: ObservableObject {
    private var linkRef: ABLLinkRef?
    private var sessionState: ABLLinkSessionStateRef?
    
    @Published var isEnabled: Bool = false
    @Published var isConnected: Bool = false
    @Published var numPeers: Int = 0
    @Published var tempo: Double = 120.0
    @Published var quantum: Double = 4.0  // Takter för fas-synk
    
    // Start/Stop synk (kräver Link 3.0+)
    @Published var isPlaying: Bool = false
    @Published var startStopSyncEnabled: Bool = true
    
    func enable()
    func disable()
    func setTempo(_ bpm: Double)
    func requestStart()
    func requestStop()
    
    // Hämta beat-position för synkronisering
    func getBeatAtTime(_ hostTime: UInt64) -> Double
    func getPhaseAtTime(_ hostTime: UInt64) -> Double
    
    // Callback för tempoändringar från andra peers
    var tempoChangedCallback: ((Double) -> Void)?
    var playStateChangedCallback: ((Bool) -> Void)?
}
```

### 4.2 Sync Coordinator

#### SyncCoordinator.swift
```swift
class SyncCoordinator: ObservableObject {
    enum ClockSourceType {
        case `internal`
        case midiExternal
        case abletonLink
    }
    
    @Published var clockSource: ClockSourceType = .internal
    @Published var linkSession: LinkSession
    @Published var midiSyncManager: MIDISyncManager
    
    // Prioritetsordning för klocksynk
    var syncPriority: [ClockSourceType] = [.abletonLink, .midiExternal, .internal]
    
    func getCurrentTempo() -> Double
    func setTempo(_ bpm: Double)
    func isExternallyClocked() -> Bool
    
    // Kvantiserad transport
    func requestPlayAtNextBeat()
    func requestStopAtNextBeat()
}
```

---

## Fas 5: P3-modulering (Parameter Sequencing)

### 5.1 P3 Modulator

#### P3Modulator.swift
```swift
struct P3Modulator {
    var id: UUID
    var name: String
    var targetParameter: InstrumentParameter
    var type: P3ModulatorType
    var depth: Double              // 0-100%
    var bipolar: Bool              // Positiv/Negativ eller endast positiv
}

enum P3ModulatorType {
    case lfo(LFOSettings)
    case envelope(EnvelopeSettings)
    case stepModulator(StepModulatorSettings)
    case random(RandomSettings)
}

struct LFOSettings {
    var shape: LFOShape            // .sine, .triangle, .square, .saw, .random
    var rate: Double               // Hz eller synkad till tempo
    var syncToTempo: Bool
    var tempoDiv: TempoDiv         // 1/1, 1/2, 1/4, etc.
    var phase: Double              // 0-360°
    var retrigger: Bool
}

struct EnvelopeSettings {
    var attack: Double
    var decay: Double
    var sustain: Double
    var release: Double
    var curve: EnvelopeCurve
}

struct StepModulatorSettings {
    var steps: [Double]            // Värden per steg
    var length: Int
    var interpolation: Interpolation  // .step, .linear, .smooth
}
```

### 5.2 Parameter Locks

#### ParameterLock.swift
```swift
struct ParameterLock {
    var parameterId: UUID
    var value: Int
    var interpolation: Interpolation?  // Valfri glide till nästa lock
}
```

---

## Fas 6: Användargränssnitt (SwiftUI)

### 6.1 Huvudvyer

#### MainView.swift
```swift
struct MainView: View {
    @StateObject var engine: SequencerEngine
    
    var body: some View {
        NavigationSplitView {
            // Sidopanel: Projekt, Patterns, Instruments
            ProjectBrowserView()
        } detail: {
            VStack {
                // Transport och tempo
                TransportBar()
                
                // Huvudinnehåll
                TabView {
                    PatternEditorView()
                        .tabItem { Label("Pattern", systemImage: "square.grid.3x3") }
                    
                    SongArrangerView()
                        .tabItem { Label("Song", systemImage: "list.bullet") }
                    
                    InstrumentEditorView()
                        .tabItem { Label("Instruments", systemImage: "pianokeys") }
                    
                    MIDIConfigView()
                        .tabItem { Label("MIDI", systemImage: "cable.connector") }
                    
                    SyncSettingsView()
                        .tabItem { Label("Sync", systemImage: "link") }
                }
            }
        }
    }
}
```

#### PatternEditorView.swift
```swift
struct PatternEditorView: View {
    @ObservedObject var pattern: Pattern
    @State var selectedTrack: Track?
    @State var viewMode: ViewMode = .grid
    
    enum ViewMode {
        case grid          // Traditionell step-sequencer vy
        case pianoRoll     // Piano roll för detaljerad editering
        case list          // Lista av events
    }
    
    var body: some View {
        VStack {
            // Spårlista (vänster)
            // Step-grid (höger)
            // Parameterpanel (nederkant)
        }
    }
}
```

### 6.2 Step Grid

#### StepGridView.swift
```swift
struct StepGridView: View {
    @Binding var track: Track
    var stepsPerPage: Int = 16
    @State var currentPage: Int = 0
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: stepsPerPage)) {
            ForEach(visibleSteps) { step in
                StepCell(step: step)
                    .onTapGesture { toggleStep(step) }
                    .onLongPressGesture { editStep(step) }
            }
        }
    }
}

struct StepCell: View {
    @Binding var step: Step
    
    var body: some View {
        ZStack {
            // Bakgrund baserat på tillstånd
            Rectangle()
                .fill(stepColor)
            
            // Velocity-indikator
            if step.enabled {
                VelocityBar(velocity: step.velocity ?? 100)
            }
            
            // Villkorsindikator
            if step.condition != .always {
                ConditionIndicator(condition: step.condition)
            }
            
            // Ratchet-indikator
            if step.ratchet != nil {
                RatchetIndicator()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
```

### 6.3 Transport & Sync UI

#### TransportBar.swift
```swift
struct TransportBar: View {
    @ObservedObject var engine: SequencerEngine
    @ObservedObject var syncCoordinator: SyncCoordinator
    
    var body: some View {
        HStack {
            // Play/Stop/Record
            Button(action: engine.togglePlay) {
                Image(systemName: engine.isPlaying ? "stop.fill" : "play.fill")
            }
            
            Button(action: engine.toggleRecord) {
                Image(systemName: "record.circle")
                    .foregroundColor(engine.isRecording ? .red : .primary)
            }
            
            Divider()
            
            // Tempo
            TempoControl(tempo: $engine.tempo, isExternalSync: syncCoordinator.isExternallyClocked())
            
            Divider()
            
            // Position
            PositionDisplay(position: engine.currentPosition)
            
            Spacer()
            
            // Sync-status
            SyncStatusIndicator(syncCoordinator: syncCoordinator)
            
            // Link-indikator
            if syncCoordinator.linkSession.isEnabled {
                LinkIndicator(session: syncCoordinator.linkSession)
            }
        }
        .padding()
    }
}
```

#### SyncSettingsView.swift
```swift
struct SyncSettingsView: View {
    @ObservedObject var syncCoordinator: SyncCoordinator
    
    var body: some View {
        Form {
            Section("Clock Source") {
                Picker("Source", selection: $syncCoordinator.clockSource) {
                    Text("Internal").tag(ClockSourceType.internal)
                    Text("MIDI External").tag(ClockSourceType.midiExternal)
                    Text("Ableton Link").tag(ClockSourceType.abletonLink)
                }
            }
            
            Section("MIDI Clock") {
                Toggle("Send MIDI Clock", isOn: $syncCoordinator.midiSyncManager.sendClock)
                Toggle("Send Transport", isOn: $syncCoordinator.midiSyncManager.sendTransport)
                
                // Port-val för MIDI Clock ut
                MultiPortPicker(selected: $syncCoordinator.midiSyncManager.clockOutputPorts)
            }
            
            Section("Ableton Link") {
                Toggle("Enable Link", isOn: $syncCoordinator.linkSession.isEnabled)
                
                if syncCoordinator.linkSession.isEnabled {
                    HStack {
                        Text("Connected Peers")
                        Spacer()
                        Text("\(syncCoordinator.linkSession.numPeers)")
                    }
                    
                    Toggle("Start/Stop Sync", isOn: $syncCoordinator.linkSession.startStopSyncEnabled)
                    
                    Stepper("Quantum: \(syncCoordinator.linkSession.quantum, specifier: "%.0f") bars",
                            value: $syncCoordinator.linkSession.quantum, in: 1...8)
                }
            }
        }
    }
}
```

---

## Fas 7: Avancerade Funktioner

### 7.1 Euclidean Sequencing

```swift
struct EuclideanGenerator {
    static func generate(steps: Int, pulses: Int, rotation: Int = 0) -> [Bool] {
        // Björklunds algoritm för euclidiska rytmer
    }
}
```

### 7.2 Scale & Chord Support

```swift
struct Scale {
    var root: Int                  // 0-11 (C till B)
    var type: ScaleType
    var notes: [Int]               // Intervall från root
}

enum ScaleType {
    case major, minor, dorian, phrygian, lydian, mixolydian, aeolian, locrian
    case harmonicMinor, melodicMinor
    case pentatonicMajor, pentatonicMinor
    case blues, chromatic
    case custom([Int])
}

struct ChordVoicing {
    var type: ChordType
    var inversion: Int
    var voicing: [Int]             // Intervall för varje röst
}
```

### 7.3 Arpeggiator

```swift
struct Arpeggiator {
    var mode: ArpMode              // .up, .down, .upDown, .random, .order
    var octaves: Int               // 1-4
    var rate: TempoDiv
    var gate: Double
    var hold: Bool
}
```

### 7.4 MIDI Learn

```swift
class MIDILearnManager: ObservableObject {
    @Published var isLearning: Bool = false
    @Published var learningParameter: String?
    
    var mappings: [MIDIMapping] = []
    
    struct MIDIMapping: Codable {
        var sourceChannel: Int
        var sourceCC: Int
        var targetParameter: String
        var min: Double
        var max: Double
    }
    
    func startLearning(for parameter: String)
    func handleIncomingCC(_ channel: Int, _ cc: Int, _ value: Int)
}
```

---

## Fas 8: Persistens & Export

### 8.1 File Formats

```swift
// Projektformat (.snirklon)
struct ProjectFile: Codable {
    var version: String
    var project: Project
    var metadata: FileMetadata
}

// MIDI-export
class MIDIFileExporter {
    func exportToMIDI(_ pattern: Pattern) -> Data
    func exportToMIDI(_ song: Song) -> Data
}

// Import
class MIDIFileImporter {
    func importMIDI(_ data: Data) -> Pattern
}
```

### 8.2 Preset System

```swift
struct Preset<T: Codable>: Codable {
    var name: String
    var category: String
    var data: T
    var isFactory: Bool
}

class PresetManager {
    func savePreset<T>(_ preset: Preset<T>)
    func loadPresets<T>(for type: T.Type) -> [Preset<T>]
}
```

---

## Fas 9: Tester

### 9.1 Unit Tests

```swift
// ClockTests.swift
class ClockTests: XCTestCase {
    func testTempoAccuracy()
    func testClockJitter()
    func testSyncLock()
}

// StepProcessorTests.swift
class StepProcessorTests: XCTestCase {
    func testProbability()
    func testConditions()
    func testRatchets()
    func testMicroTiming()
}

// MIDIEngineTests.swift
class MIDIEngineTests: XCTestCase {
    func testNoteOnOff()
    func testClockOutput()
    func testSysEx()
}
```

### 9.2 Integration Tests

```swift
class IntegrationTests: XCTestCase {
    func testFullPatternPlayback()
    func testLinkSync()
    func testMIDISync()
}
```

---

## Utvecklingsplan - Tidsuppskattning

### Sprint 1 (Vecka 1-2): Grundläggande struktur
- [ ] Projektstruktur och datamodeller
- [ ] Grundläggande MIDI-engine med CoreMIDI
- [ ] Intern klocka med hög precision
- [ ] Enkel step-sequencer logik

### Sprint 2 (Vecka 3-4): Sequencer Engine
- [ ] Full step-processing med alla parametrar
- [ ] Pattern-hantering
- [ ] Polymetriska spår
- [ ] Swing och micro-timing

### Sprint 3 (Vecka 5-6): MIDI & Sync
- [ ] MIDI Clock master/slave
- [ ] Ableton Link integration
- [ ] Transport-synkronisering
- [ ] Song Position Pointer

### Sprint 4 (Vecka 7-8): UI Grund
- [ ] SwiftUI huvudgränssnitt
- [ ] Pattern editor med step-grid
- [ ] Transport-kontroller
- [ ] MIDI-konfiguration

### Sprint 5 (Vecka 9-10): Avancerade funktioner
- [ ] P3-modulering (LFO, envelope, step mod)
- [ ] Parameter locks
- [ ] Euclidean generator
- [ ] Arpeggiator

### Sprint 6 (Vecka 11-12): Song Mode & Polish
- [ ] Song arranger
- [ ] Pattern chaining
- [ ] Preset-system
- [ ] Export/Import

### Sprint 7 (Vecka 13-14): Testning & Dokumentation
- [ ] Unit tests
- [ ] Integration tests
- [ ] Användarmanual
- [ ] Performance-optimering

---

## Beroenden

### Swift Packages

```swift
// Package.swift
dependencies: [
    // Ableton Link (C++ wrapper behövs)
    .package(url: "https://github.com/AbletonLinkKit", from: "1.0.0"),
    
    // För UI-komponenter
    .package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.8.0"),
]
```

### System Frameworks
- CoreMIDI (MIDI I/O)
- AudioToolbox (Högprecisionstimer)
- CoreAudio (Låg-latens timing)
- Combine (Reaktiv programmering)
- SwiftUI (UI)

---

## Cirklon-specifika funktioner att implementera

### Från Cirklon-manualen:

1. **CK Instrument Tracks** - Fullständig not-sekvensering
2. **AUX Tracks** - CC/NRPN-sekvensering
3. **P3 Modulation** - Parameter-sekvensering med LFO/Envelope
4. **Polymetric Tracks** - Individuella spårlängder
5. **Step Conditions** - Villkorlig triggning (Fill, A/B, etc.)
6. **Ratchets/Rolls** - Upprepningar inom steg
7. **Micro-timing** - Sub-step timing
8. **Probability** - Slumpmässig triggning
9. **Pattern Chains** - Kedja patterns
10. **Song Mode** - Arrangera patterns i låtar
11. **Scales & Chords** - Musikteori-hjälp
12. **MIDI Learn** - CC-mappning
13. **Multiple MIDI Ports** - Upp till 5 x 16 kanaler
14. **Swing** - Global och per-spår
15. **Transpose** - Global och per-spår/pattern

---

## Nästa steg

1. **Skapa Swift Package** med grundläggande struktur
2. **Implementera datamodeller** enligt specifikation
3. **Bygga CoreMIDI-wrapper** för MIDI I/O
4. **Implementera intern klocka** med CoreAudio
5. **Skapa minimal UI** för testning

---

*Senast uppdaterad: December 2024*
