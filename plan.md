# Snirklon - Implementation Plan

## Overview

Snirklon is a professional MIDI/CV sequencer for macOS/iOS inspired by Sequentix Cirklon, with integrated Claude AI for generative music capabilities.

---

## Part 1: Make Noise Cirklonish Sequencer (SwiftUI)

### Status: ✅ Complete (29 Swift files created)

### Absoluta regler
- Instrument, inte app. Inga settings-flöden som tar över.
- Immediate feedback (<100ms).
- Muscle memory: samma gest = samma funktion överallt.
- Panel-stil: monokrom bas + semantiska highlights + LED-pulse.
- Stabil layout: inga layout shifts, ingen scroll i inspector.
- Constraints: inga fria textfält; chips/steppers med min/max/step.
- Touch targets ≥ 44×44.
- DS tokens only: ingen ad-hoc styling.

### Projektstruktur

#### App
- [x] App/MakeNoiseSequencerApp.swift
- [x] App/AppShellView.swift

#### Design System
- [x] DesignSystem/DS.swift ✅ (exakt kodblob)
- [x] DesignSystem/PanelStyles.swift ✅ (exakt kodblob)
- [x] DesignSystem/Iconography.swift ✅ (exakt kodblob)

#### Models
- [x] Models/TrackModel.swift
- [x] Models/PatternModel.swift
- [x] Models/StepModel.swift
- [x] Models/SelectionModel.swift

#### Store
- [x] Store/SequencerStore.swift

#### Features: Transport
- [x] Features/Transport/TransportBarView.swift
- [x] Features/Transport/TransportControls.swift

#### Features: Tracks
- [x] Features/Tracks/TrackSidebarView.swift
- [x] Features/Tracks/TrackRowView.swift
- [x] Features/Tracks/MuteSoloButtons.swift
- [x] Features/Tracks/ColorDot.swift

#### Features: Grid
- [x] Features/Grid/StepGridView.swift
- [x] Features/Grid/StepCellView.swift ✅ (exakt kodblob)
- [x] Features/Grid/GridRulerView.swift

#### Features: Inspector
- [x] Features/Inspector/InspectorPanelView.swift
- [x] Features/Inspector/InspectorStepSection.swift
- [x] Features/Inspector/InspectorTrackSection.swift
- [x] Features/Inspector/SteppedValueControl.swift
- [x] Features/Inspector/ToggleChip.swift
- [x] Features/Inspector/SegmentChips.swift

#### Features: Performance
- [x] Features/Performance/PerformanceView.swift
- [x] Features/Performance/PatternLauncherGridView.swift
- [x] Features/Performance/PatternSlotView.swift

#### Features: Arrange
- [x] Features/Arrange/ArrangeView.swift (placeholder)

### Validering (kräver Xcode 15+ / iOS 17+ / macOS 14+)
- [ ] Bygger utan errors
- [ ] Track select funkar
- [ ] Step toggle funkar
- [ ] Drag velocity funkar + syns direkt
- [ ] Long press öppnar inspector med step-parametrar
- [ ] Play/stop visar playhead LED-pulse i grid
- [ ] DS tokens används överallt

---

## Part 2: Cirklon-inspirerad Sequencer - Full Architecture

### Projektöversikt

Snirklon är en professionell MIDI-sequencer inspirerad av Sequentix Cirklon, byggd i Swift för macOS/iOS. Projektet implementerar alla kärnfunktioner från Cirklon tillsammans med modern MIDI-utmatning, MIDI-synkronisering och Ableton Link-integration.

---

### Fas 1: Grundläggande Arkitektur & Datamodeller

#### 1.1 Projektstruktur

```
Snirklon/
├── Sources/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Engine/
│   │   ├── MIDI/
│   │   ├── CV/              # CV/Gate/ADSR system
│   │   │   ├── CVEngine.swift
│   │   │   ├── CVOutput.swift
│   │   │   ├── CVTrack.swift
│   │   │   ├── ADSREnvelope.swift
│   │   │   ├── ClockOutput.swift
│   │   │   ├── CVLFO.swift
│   │   │   └── CVCalibration.swift
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

#### 1.2 Datamodeller (Core/Models/)

##### Project.swift
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

##### Pattern.swift
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

##### Track.swift
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

##### Step.swift
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

##### Instrument.swift
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

#### 1.3 Tidssystem

##### TimeSignature.swift
```swift
struct TimeSignature {
    var numerator: Int             // 1-32
    var denominator: Int           // 1, 2, 4, 8, 16, 32
}
```

##### Clock.swift
```swift
struct ClockPosition {
    var bar: Int
    var beat: Int
    var tick: Int                  // 96 PPQN (Pulses Per Quarter Note)
}
```

---

### Fas 2: Sequencer Engine

#### 2.1 Huvudmotor (Core/Engine/)

##### SequencerEngine.swift
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

##### ClockSource.swift
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

#### 2.2 Step Processing

##### StepProcessor.swift
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

#### 2.3 Pattern Chaining & Song Mode

##### PatternChain.swift
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

##### Song.swift
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

### Fas 3: MIDI-system

#### 3.1 MIDI Engine (Core/MIDI/)

##### MIDIEngine.swift
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

##### MIDIEvent.swift
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

#### 3.2 MIDI Sync (Core/Sync/)

##### MIDISyncManager.swift
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

### Fas 3B: CV/Gate/ADSR Output & Analog Clock

#### 3B.1 Översikt - CV Output System

CV-utmatning sker via DC-kopplade ljudgränssnitt (t.ex. Expert Sleepers, MOTU, RME) som kan mata ut kontrollspänningar istället för ljudsignaler.

##### Stödda Gränssnitt
- **Expert Sleepers ES-8/ES-9** - 8+ CV-utgångar via USB
- **MOTU UltraLite/828** - DC-kopplad utgång
- **RME Fireface** - DC-kopplad utgång
- **iConnectivity mio** - MIDI till CV
- **Virtuella CV** - För mjukvarumodulärer (VCV Rack, etc.)

#### 3B.2 CV Engine (Core/CV/)

##### CVEngine.swift
```swift
import CoreAudio
import AVFoundation

class CVEngine: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var outputNode: AVAudioSourceNode?
    
    // Konfiguration
    @Published var sampleRate: Double = 48000
    @Published var bufferSize: Int = 64          // Låg latens
    @Published var outputDevice: AudioDeviceID?
    @Published var channelMapping: [CVChannel] = []
    
    // CV-utgångar (upp till 16 kanaler)
    var cvOutputs: [CVOutput] = []
    
    func setup() throws
    func start()
    func stop()
    
    // Render callback
    func renderCV(frameCount: Int, outputBuffer: UnsafeMutablePointer<Float>)
}
```

##### CVOutput.swift
```swift
struct CVOutput: Identifiable {
    var id: UUID
    var name: String
    var audioChannel: Int              // Fysisk utgångskanal (0-15)
    var type: CVOutputType
    var calibration: CVCalibration
    
    // Nuvarande värde
    var currentVoltage: Double = 0.0   // -10V till +10V (mappat till -1.0 till +1.0)
}

enum CVOutputType {
    case pitch                          // 1V/oktav pitch CV
    case gate                           // Gate/Trigger
    case velocity                       // Velocity CV
    case modulation                     // Modulerings-CV
    case envelope                       // ADSR envelope
    case clock                          // Klock-pulser
    case lfo                            // LFO-utgång
}

struct CVCalibration: Codable {
    var voltageRange: ClosedRange<Double>  // T.ex. -5...+5V eller 0...+10V
    var octaveScaling: Double              // 1.0 = 1V/okt standard
    var offset: Double                     // Kalibrerings-offset
    var c0Voltage: Double                  // Spänning för C0 (MIDI not 24)
}
```

#### 3B.3 ADSR Envelope Generator

##### ADSREnvelope.swift
```swift
class ADSREnvelope: ObservableObject {
    var id: UUID
    var name: String
    
    // ADSR-parametrar
    @Published var attack: Double       // 0.001 - 10 sekunder
    @Published var decay: Double        // 0.001 - 10 sekunder
    @Published var sustain: Double      // 0 - 1.0 (nivå)
    @Published var release: Double      // 0.001 - 20 sekunder
    
    // Kurvformer
    @Published var attackCurve: EnvelopeCurve
    @Published var decayCurve: EnvelopeCurve
    @Published var releaseCurve: EnvelopeCurve
    
    // Avancerade parametrar
    @Published var hold: Double         // Hold-tid efter attack
    @Published var delay: Double        // Fördröjning innan attack
    @Published var velocitySensitivity: Double  // 0-1.0
    @Published var keyTracking: Double  // Hur pitch påverkar tider
    
    // Tillstånd
    private var currentStage: EnvelopeStage = .idle
    private var currentValue: Double = 0.0
    private var stageProgress: Double = 0.0
    
    // Output
    var cvOutput: CVOutput?
    
    // Trigger
    func trigger(velocity: Double = 1.0, note: Int = 60)
    func release()
    func forceRelease()                 // Omedelbar release
    
    // Beräkna nästa sample
    func process(sampleRate: Double) -> Double
}

enum EnvelopeStage {
    case idle
    case delay
    case attack
    case hold
    case decay
    case sustain
    case release
}

enum EnvelopeCurve {
    case linear
    case exponential
    case logarithmic
    case sCurve
    case custom([Double])              // Lookup-tabell
}
```

#### 3B.4 Clock Output System

##### ClockOutput.swift
```swift
class ClockOutput: ObservableObject {
    var id: UUID
    var name: String
    
    // Clock-inställningar
    @Published var division: ClockDivision    // 1/1, 1/2, 1/4, 1/8, etc.
    @Published var multiplication: Int        // 1x, 2x, 4x
    @Published var pulseWidth: Double         // Pulsbredd i ms (1-50ms)
    @Published var swing: Double              // 0-100%
    @Published var phase: Double              // Fasförskjutning 0-360°
    
    // Output
    var cvOutput: CVOutput?
    
    // Tillstånd
    private var isHigh: Bool = false
    private var samplesUntilChange: Int = 0
    
    // Generera klockpulser
    func process(currentTick: Int, sampleRate: Double) -> Double
    func reset()
}

enum ClockDivision: CaseIterable {
    case whole          // 1/1 - Heltakt
    case half           // 1/2 - Halvtakt
    case quarter        // 1/4 - Fjärdedel
    case eighth         // 1/8 - Åttondel
    case sixteenth      // 1/16 - Sextondel
    case thirtySecond   // 1/32 - Trettiotvåondel
    
    // Trioler
    case quarterTriplet
    case eighthTriplet
    case sixteenthTriplet
    
    // Punkterade
    case dottedQuarter
    case dottedEighth
    case dottedSixteenth
    
    var ticksPerPulse: Int {
        switch self {
        case .whole: return 384
        case .half: return 192
        case .quarter: return 96
        case .eighth: return 48
        case .sixteenth: return 24
        case .thirtySecond: return 12
        case .quarterTriplet: return 64
        case .eighthTriplet: return 32
        case .sixteenthTriplet: return 16
        case .dottedQuarter: return 144
        case .dottedEighth: return 72
        case .dottedSixteenth: return 36
        }
    }
}
```

---

### Fas 4: Ableton Link Integration

#### 4.1 Link Session (Core/Sync/)

##### LinkSession.swift
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

---

### Fas 5: P3-modulering (Parameter Sequencing)

#### 5.1 P3 Modulator

##### P3Modulator.swift
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

#### 5.2 Parameter Locks

##### ParameterLock.swift
```swift
struct ParameterLock {
    var parameterId: UUID
    var value: Int
    var interpolation: Interpolation?  // Valfri glide till nästa lock
}
```

---

### Fas 6: Användargränssnitt (SwiftUI)

#### 6.1 Huvudvyer

##### MainView.swift
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

### Sprint 4 (Vecka 7-8): CV/Gate/ADSR System
- [ ] CV Engine med CoreAudio
- [ ] Pitch CV (1V/okt) med kalibrering
- [ ] Gate/Trigger-generering
- [ ] ADSR Envelope Generator
- [ ] CV Clock Output med divisioner
- [ ] CV LFO-modulatorer
- [ ] Portamento/Glide
- [ ] Multi-kanal CV output

### Sprint 5 (Vecka 9-10): UI Grund
- [ ] SwiftUI huvudgränssnitt
- [ ] Pattern editor med step-grid
- [ ] Transport-kontroller
- [ ] MIDI-konfiguration
- [ ] CV-konfiguration och kalibrerings-UI
- [ ] ADSR-editor

### Sprint 6 (Vecka 11-12): Avancerade funktioner
- [ ] P3-modulering (LFO, envelope, step mod)
- [ ] Parameter locks
- [ ] Euclidean generator
- [ ] Arpeggiator
- [ ] CV Sequencing per steg

### Sprint 7 (Vecka 13-14): Song Mode & Polish
- [ ] Song arranger
- [ ] Pattern chaining
- [ ] Preset-system
- [ ] Export/Import

### Sprint 8 (Vecka 15-16): Testning & Dokumentation
- [ ] Unit tests (MIDI, CV, ADSR, Clock)
- [ ] Integration tests
- [ ] Hardware-testning med olika CV-gränssnitt
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
- CoreAudio (Låg-latens timing, CV output via DC-kopplade interface)
- AVFoundation (Audio engine för CV)
- Combine (Reaktiv programmering)
- SwiftUI (UI)

### CV/Gate Hardware-beroenden
- DC-kopplat ljudgränssnitt (Expert Sleepers, MOTU, RME, etc.)
- Kalibreringsverktyg (oscilloskop eller stämapparat för 1V/okt)

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

### CV/Gate/Clock-funktioner (utökad):

16. **CV Pitch Output** - 1V/oktav med kalibrering
17. **Gate Output** - Gate/Trigger per steg
18. **Velocity CV** - Velocity som CV
19. **ADSR Envelopes** - Multipla envelope-generatorer med CV-ut
20. **CV Clock Output** - Modulär clock med divisioner och multiplikationer
21. **Reset/Run Output** - Transport-signaler för modulärer
22. **CV LFO** - LFO-utgångar synkade till tempo
23. **Portamento/Glide** - Legato och always-läge
24. **Multi-channel CV** - Upp till 16 CV-kanaler
25. **CV Calibration** - 1V/okt kalibrering per utgång

---

## Nästa steg

1. **Skapa Swift Package** med grundläggande struktur
2. **Implementera datamodeller** enligt specifikation
3. **Bygga CoreMIDI-wrapper** för MIDI I/O
4. **Implementera intern klocka** med CoreAudio
5. **Skapa minimal UI** för testning

---

*Senast uppdaterad: December 2024*
