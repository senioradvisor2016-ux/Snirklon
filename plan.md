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
│   │   ├── CV/                     # CV/Gate/ADSR system
│   │   │   ├── CVEngine.swift
│   │   │   ├── CVOutput.swift
│   │   │   ├── CVTrack.swift
│   │   │   ├── ADSREnvelope.swift
│   │   │   ├── ClockOutput.swift
│   │   │   ├── CVLFO.swift
│   │   │   └── CVCalibration.swift
│   │   ├── Drums/                  # Drum Machine System
│   │   │   ├── DrumMachineMap.swift
│   │   │   ├── DrumMachineLibrary.swift
│   │   │   ├── PatternLibrary.swift
│   │   │   ├── PatternGenerator.swift
│   │   │   └── Maps/
│   │   │       ├── TR909Map.swift
│   │   │       ├── AnalogRytmMap.swift
│   │   │       ├── LinnDrumMap.swift
│   │   │       ├── KawaiR100Map.swift
│   │   │       └── VermonaDRM1Map.swift
│   │   └── Sync/
│   ├── Patterns/                   # 128-step Pattern Library
│   │   ├── Darkwave/
│   │   │   ├── cold_wave.json
│   │   │   ├── gothic.json
│   │   │   ├── deathrock.json
│   │   │   └── ...
│   │   ├── Synthpop/
│   │   │   ├── electropop.json
│   │   │   ├── futurepop.json
│   │   │   ├── new_wave.json
│   │   │   └── ...
│   │   ├── EBM/
│   │   │   ├── classic_ebm.json
│   │   │   ├── aggrotech.json
│   │   │   ├── dark_electro.json
│   │   │   └── ...
│   │   └── Techno/
│   │       ├── minimal.json
│   │       ├── detroit.json
│   │       ├── berlin.json
│   │       ├── industrial.json
│   │       └── ...
│   ├── UI/
│   │   ├── Views/
│   │   │   ├── PatternBrowserView.swift
│   │   │   ├── DrumMachineConfigView.swift
│   │   │   └── ...
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

## Fas 7: Drum Machine MIDI Maps & Pattern Library

### 7.1 Översikt

Snirklon inkluderar fördefinierade MIDI-maps för klassiska och moderna trummaskiner samt ett omfattande bibliotek med 128-stegs patterns för olika genrer. Alla patterns är optimerade för respektive trummaskins spårstruktur.

### 7.2 Projektstruktur (Drums)

```
Snirklon/
├── Sources/
│   ├── Core/
│   │   ├── Drums/
│   │   │   ├── DrumMachineMap.swift
│   │   │   ├── DrumMachineLibrary.swift
│   │   │   ├── PatternLibrary.swift
│   │   │   ├── PatternGenerator.swift
│   │   │   └── Maps/
│   │   │       ├── TR909Map.swift
│   │   │       ├── AnalogRytmMap.swift
│   │   │       ├── LinnDrumMap.swift
│   │   │       ├── KawaiR100Map.swift
│   │   │       └── VermonaDRM1Map.swift
│   │   └── Patterns/
│   │       ├── Darkwave/
│   │       ├── Synthpop/
│   │       ├── EBM/
│   │       └── Techno/
```

### 7.3 Drum Machine MIDI Maps

#### DrumMachineMap.swift
```swift
struct DrumMachineMap: Identifiable, Codable {
    var id: UUID
    var name: String
    var manufacturer: String
    var midiChannel: Int                    // Standard MIDI-kanal
    var tracks: [DrumTrack]
    var velocityRange: ClosedRange<Int>     // Min/max velocity
    var supportsAccent: Bool
    var accentThreshold: Int?               // Velocity för accent
    var parameterMaps: [DrumParameterMap]?  // CC-mappningar
}

struct DrumTrack: Identifiable, Codable {
    var id: UUID
    var name: String                        // "Kick", "Snare", etc.
    var shortName: String                   // "BD", "SD", etc.
    var midiNote: Int                       // MIDI-not (0-127)
    var color: String                       // Hex-färgkod för UI
    var category: DrumCategory
    var defaultVelocity: Int
    var tunable: Bool                       // Om pitch kan justeras
    var tuneCC: Int?                        // CC för tune/pitch
    var decayCC: Int?                       // CC för decay
    var toneCC: Int?                        // CC för tone/timbre
}

enum DrumCategory: String, Codable, CaseIterable {
    case kick = "Kick"
    case snare = "Snare"
    case clap = "Clap"
    case hihat = "Hi-Hat"
    case cymbal = "Cymbal"
    case tom = "Tom"
    case percussion = "Percussion"
    case rim = "Rim"
    case cowbell = "Cowbell"
    case fx = "FX"
}

struct DrumParameterMap: Codable {
    var name: String
    var ccNumber: Int
    var min: Int
    var max: Int
    var defaultValue: Int
}
```

---

### 7.4 Roland TR-909 MIDI Map

```swift
let tr909Map = DrumMachineMap(
    id: UUID(),
    name: "Roland TR-909",
    manufacturer: "Roland",
    midiChannel: 10,
    velocityRange: 1...127,
    supportsAccent: true,
    accentThreshold: 110,
    tracks: [
        DrumTrack(name: "Bass Drum",      shortName: "BD",  midiNote: 36, color: "#FF4444", category: .kick,       defaultVelocity: 100, tunable: true,  tuneCC: 20, decayCC: 21),
        DrumTrack(name: "Snare Drum",     shortName: "SD",  midiNote: 38, color: "#44FF44", category: .snare,      defaultVelocity: 100, tunable: true,  tuneCC: 22, decayCC: 23, toneCC: 24),
        DrumTrack(name: "Low Tom",        shortName: "LT",  midiNote: 43, color: "#FF8844", category: .tom,        defaultVelocity: 100, tunable: true,  tuneCC: 25, decayCC: 26),
        DrumTrack(name: "Mid Tom",        shortName: "MT",  midiNote: 47, color: "#FFAA44", category: .tom,        defaultVelocity: 100, tunable: true,  tuneCC: 27, decayCC: 28),
        DrumTrack(name: "Hi Tom",         shortName: "HT",  midiNote: 50, color: "#FFCC44", category: .tom,        defaultVelocity: 100, tunable: true,  tuneCC: 29, decayCC: 30),
        DrumTrack(name: "Rim Shot",       shortName: "RS",  midiNote: 37, color: "#44FFFF", category: .rim,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Hand Clap",      shortName: "CP",  midiNote: 39, color: "#FF44FF", category: .clap,       defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Closed Hi-Hat",  shortName: "CH",  midiNote: 42, color: "#FFFF44", category: .hihat,      defaultVelocity: 100, tunable: false, decayCC: 31),
        DrumTrack(name: "Open Hi-Hat",    shortName: "OH",  midiNote: 46, color: "#FFFF88", category: .hihat,      defaultVelocity: 100, tunable: false, decayCC: 32),
        DrumTrack(name: "Crash Cymbal",   shortName: "CC",  midiNote: 49, color: "#88FFFF", category: .cymbal,     defaultVelocity: 100, tunable: true,  tuneCC: 33),
        DrumTrack(name: "Ride Cymbal",    shortName: "RC",  midiNote: 51, color: "#88CCFF", category: .cymbal,     defaultVelocity: 100, tunable: true,  tuneCC: 34)
    ]
)
```

---

### 7.5 Elektron Analog Rytm MIDI Map

```swift
let analogRytmMap = DrumMachineMap(
    id: UUID(),
    name: "Elektron Analog Rytm",
    manufacturer: "Elektron",
    midiChannel: 10,
    velocityRange: 1...127,
    supportsAccent: true,
    accentThreshold: 100,
    tracks: [
        // Pad 1-8 (Track 1-8)
        DrumTrack(name: "Bass Drum",      shortName: "BD",  midiNote: 36, color: "#FF3366", category: .kick,       defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Snare Drum",     shortName: "SD",  midiNote: 38, color: "#33FF66", category: .snare,      defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Rim Shot",       shortName: "RS",  midiNote: 37, color: "#3366FF", category: .rim,        defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Clap",           shortName: "CP",  midiNote: 39, color: "#FF6633", category: .clap,       defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Closed Hi-Hat",  shortName: "CH",  midiNote: 42, color: "#FFFF33", category: .hihat,      defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Open Hi-Hat",    shortName: "OH",  midiNote: 46, color: "#FFCC33", category: .hihat,      defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Low Tom",        shortName: "LT",  midiNote: 43, color: "#FF9933", category: .tom,        defaultVelocity: 100, tunable: true),
        DrumTrack(name: "High Tom",       shortName: "HT",  midiNote: 50, color: "#FF6600", category: .tom,        defaultVelocity: 100, tunable: true),
        // Pad 9-12 (Track 9-12)
        DrumTrack(name: "Cymbal",         shortName: "CY",  midiNote: 49, color: "#33FFFF", category: .cymbal,     defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Cowbell",        shortName: "CB",  midiNote: 56, color: "#9933FF", category: .cowbell,    defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Perc 1",         shortName: "P1",  midiNote: 60, color: "#FF33FF", category: .percussion, defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Perc 2",         shortName: "P2",  midiNote: 62, color: "#33FFCC", category: .percussion, defaultVelocity: 100, tunable: true)
    ],
    parameterMaps: [
        DrumParameterMap(name: "Track Level",  ccNumber: 95,  min: 0, max: 127, defaultValue: 100),
        DrumParameterMap(name: "Pan",          ccNumber: 10,  min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Delay Send",   ccNumber: 94,  min: 0, max: 127, defaultValue: 0),
        DrumParameterMap(name: "Reverb Send",  ccNumber: 91,  min: 0, max: 127, defaultValue: 0),
        DrumParameterMap(name: "Sample Tune",  ccNumber: 24,  min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Sample Decay", ccNumber: 25,  min: 0, max: 127, defaultValue: 64)
    ]
)
```

---

### 7.6 LinnDrum MIDI Map

```swift
let linnDrumMap = DrumMachineMap(
    id: UUID(),
    name: "LinnDrum / LM-1 / LM-2",
    manufacturer: "Linn Electronics",
    midiChannel: 10,
    velocityRange: 1...127,
    supportsAccent: true,
    accentThreshold: 100,
    tracks: [
        DrumTrack(name: "Kick",           shortName: "KK",  midiNote: 36, color: "#E63946", category: .kick,       defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Snare",          shortName: "SN",  midiNote: 38, color: "#2A9D8F", category: .snare,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Sidestick",      shortName: "SS",  midiNote: 37, color: "#264653", category: .rim,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Hi-Hat",         shortName: "HH",  midiNote: 42, color: "#E9C46A", category: .hihat,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Open Hi-Hat",    shortName: "OH",  midiNote: 46, color: "#F4A261", category: .hihat,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tom 1",          shortName: "T1",  midiNote: 48, color: "#E76F51", category: .tom,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tom 2",          shortName: "T2",  midiNote: 45, color: "#D62828", category: .tom,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tom 3",          shortName: "T3",  midiNote: 43, color: "#9D0208", category: .tom,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Crash",          shortName: "CR",  midiNote: 49, color: "#457B9D", category: .cymbal,     defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Ride",           shortName: "RD",  midiNote: 51, color: "#1D3557", category: .cymbal,     defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Claps",          shortName: "CP",  midiNote: 39, color: "#A8DADC", category: .clap,       defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Cabasa",         shortName: "CB",  midiNote: 69, color: "#F1FAEE", category: .percussion, defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tambourine",     shortName: "TB",  midiNote: 54, color: "#FCBF49", category: .percussion, defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Cowbell",        shortName: "CW",  midiNote: 56, color: "#F77F00", category: .cowbell,    defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Conga Hi",       shortName: "CH",  midiNote: 62, color: "#D62828", category: .percussion, defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Conga Lo",       shortName: "CL",  midiNote: 63, color: "#9D0208", category: .percussion, defaultVelocity: 100, tunable: false)
    ]
)
```

---

### 7.7 Kawai R-100 MIDI Map

```swift
let kawaiR100Map = DrumMachineMap(
    id: UUID(),
    name: "Kawai R-100",
    manufacturer: "Kawai",
    midiChannel: 10,
    velocityRange: 1...127,
    supportsAccent: true,
    accentThreshold: 100,
    tracks: [
        DrumTrack(name: "Bass Drum 1",    shortName: "B1",  midiNote: 36, color: "#FF5733", category: .kick,       defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Bass Drum 2",    shortName: "B2",  midiNote: 35, color: "#C70039", category: .kick,       defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Snare 1",        shortName: "S1",  midiNote: 38, color: "#33FF57", category: .snare,      defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Snare 2",        shortName: "S2",  midiNote: 40, color: "#00C739", category: .snare,      defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Rimshot",        shortName: "RM",  midiNote: 37, color: "#3357FF", category: .rim,        defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Handclap",       shortName: "HC",  midiNote: 39, color: "#FF33A8", category: .clap,       defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Closed HH",      shortName: "CH",  midiNote: 42, color: "#FFFF33", category: .hihat,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Open HH",        shortName: "OH",  midiNote: 46, color: "#FFD700", category: .hihat,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Pedal HH",       shortName: "PH",  midiNote: 44, color: "#CCAA00", category: .hihat,      defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tom Low",        shortName: "TL",  midiNote: 41, color: "#FF8C00", category: .tom,        defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Tom Mid",        shortName: "TM",  midiNote: 45, color: "#FFA500", category: .tom,        defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Tom Hi",         shortName: "TH",  midiNote: 48, color: "#FFB347", category: .tom,        defaultVelocity: 100, tunable: true),
        DrumTrack(name: "Crash",          shortName: "CR",  midiNote: 49, color: "#00CED1", category: .cymbal,     defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Ride",           shortName: "RD",  midiNote: 51, color: "#20B2AA", category: .cymbal,     defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Cowbell",        shortName: "CB",  midiNote: 56, color: "#9370DB", category: .cowbell,    defaultVelocity: 100, tunable: false),
        DrumTrack(name: "Tambourine",     shortName: "TB",  midiNote: 54, color: "#BA55D3", category: .percussion, defaultVelocity: 100, tunable: false)
    ]
)
```

---

### 7.8 Vermona DRM1 MIDI Map

```swift
let vermonaDRM1Map = DrumMachineMap(
    id: UUID(),
    name: "Vermona DRM1 MKIII",
    manufacturer: "Vermona",
    midiChannel: 10,
    velocityRange: 1...127,
    supportsAccent: false,
    tracks: [
        DrumTrack(name: "Kick 1",         shortName: "K1",  midiNote: 36, color: "#DC143C", category: .kick,       defaultVelocity: 100, tunable: true,  tuneCC: 16),
        DrumTrack(name: "Kick 2",         shortName: "K2",  midiNote: 35, color: "#B22222", category: .kick,       defaultVelocity: 100, tunable: true,  tuneCC: 17),
        DrumTrack(name: "Snare",          shortName: "SN",  midiNote: 38, color: "#228B22", category: .snare,      defaultVelocity: 100, tunable: true,  tuneCC: 18),
        DrumTrack(name: "Multi 1",        shortName: "M1",  midiNote: 40, color: "#4169E1", category: .percussion, defaultVelocity: 100, tunable: true,  tuneCC: 19),
        DrumTrack(name: "Multi 2",        shortName: "M2",  midiNote: 41, color: "#6495ED", category: .percussion, defaultVelocity: 100, tunable: true,  tuneCC: 20),
        DrumTrack(name: "Hi-Hat",         shortName: "HH",  midiNote: 42, color: "#FFD700", category: .hihat,      defaultVelocity: 100, tunable: true,  tuneCC: 21),
        DrumTrack(name: "Tom Hi",         shortName: "TH",  midiNote: 48, color: "#FF8C00", category: .tom,        defaultVelocity: 100, tunable: true,  tuneCC: 22),
        DrumTrack(name: "Tom Lo",         shortName: "TL",  midiNote: 43, color: "#FF6347", category: .tom,        defaultVelocity: 100, tunable: true,  tuneCC: 23)
    ],
    parameterMaps: [
        DrumParameterMap(name: "Kick 1 Tune",    ccNumber: 16, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Kick 1 Decay",   ccNumber: 24, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Kick 1 Attack",  ccNumber: 32, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Snare Tune",     ccNumber: 18, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "Snare Snappy",   ccNumber: 26, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "HiHat Tune",     ccNumber: 21, min: 0, max: 127, defaultValue: 64),
        DrumParameterMap(name: "HiHat Decay",    ccNumber: 29, min: 0, max: 127, defaultValue: 64)
    ]
)
```

---

### 7.9 Pattern Library System

#### DrumPattern.swift
```swift
struct DrumPattern: Identifiable, Codable {
    var id: UUID
    var name: String
    var genre: PatternGenre
    var subGenre: String?
    var tempo: ClosedRange<Int>             // Rekommenderat BPM-intervall
    var length: Int                          // Antal steg (16, 32, 64, 128)
    var timeSignature: TimeSignature
    var swing: Double                        // 0-100%
    var intensity: PatternIntensity
    var tags: [String]
    var tracks: [PatternTrack]
    var variations: [PatternVariation]?
    var fills: [PatternFill]?
    var compatibleMachines: [String]        // ["TR-909", "Analog Rytm", etc.]
}

enum PatternGenre: String, Codable, CaseIterable {
    case darkwave = "Darkwave"
    case synthpop = "Synthpop"
    case ebm = "EBM"
    case techno = "Techno"
}

enum PatternIntensity: String, Codable, CaseIterable {
    case minimal = "Minimal"
    case medium = "Medium"
    case intense = "Intense"
    case climax = "Climax"
}

struct PatternTrack: Codable {
    var drumCategory: DrumCategory          // Vilket trumsljud
    var steps: [PatternStep]                // 128 steg max
}

struct PatternStep: Codable {
    var enabled: Bool
    var velocity: Int                        // 1-127
    var microTiming: Int                     // -96 till +96
    var probability: Int                     // 0-100%
    var condition: StepCondition
    var ratchet: Ratchet?
    var accent: Bool
}

struct PatternVariation: Identifiable, Codable {
    var id: UUID
    var name: String                        // "A", "B", "Breakdown", etc.
    var tracks: [PatternTrack]
}

struct PatternFill: Identifiable, Codable {
    var id: UUID
    var name: String                        // "Buildup", "Drop", etc.
    var length: Int                         // 4, 8, 16 steg
    var tracks: [PatternTrack]
}
```

---

### 7.10 Pattern Library - Genre Collections

#### DARKWAVE (100+ patterns)

| ID | Namn | Steg | Tempo | Intensitet | Beskrivning |
|----|------|------|-------|------------|-------------|
| DW001 | Cold Wave Basic | 128 | 100-120 | Minimal | Klassisk coldwave grund med sparsam hihat |
| DW002 | Gothic March | 128 | 110-125 | Medium | Marscherande beat med tung kick |
| DW003 | Deathrock Pulse | 128 | 115-130 | Medium | Pulsdriven med offbeat snare |
| DW004 | Batcave Groove | 128 | 105-120 | Minimal | Dansant darkwave med swing |
| DW005 | Post-Punk Drive | 128 | 120-135 | Medium | Driving beat med rimshot accent |
| DW006 | Ethereal Minimal | 128 | 90-110 | Minimal | Sparsam atmosfärisk grund |
| DW007 | Shadow Dance | 128 | 115-125 | Medium | Melodisk darkwave grund |
| DW008 | Obsidian Ritual | 128 | 100-115 | Intense | Ritualistisk med toms |
| DW009 | Midnight Synth | 128 | 110-120 | Medium | Synthwave-influerad darkwave |
| DW010 | Velvet Darkness | 128 | 95-110 | Minimal | Mjuk, atmosfärisk |
| ... | ... | ... | ... | ... | ... |
| DW100 | Cathedral Echo | 128 | 85-100 | Minimal | Reverberat, kyrklig atmosfär |

```swift
// Exempel: DW001 - Cold Wave Basic (128 steg)
let coldWaveBasic = DrumPattern(
    id: UUID(),
    name: "Cold Wave Basic",
    genre: .darkwave,
    subGenre: "Cold Wave",
    tempo: 100...120,
    length: 128,
    timeSignature: TimeSignature(numerator: 4, denominator: 4),
    swing: 0,
    intensity: .minimal,
    tags: ["cold wave", "minimal", "classic", "80s"],
    tracks: [
        PatternTrack(drumCategory: .kick, steps: [
            // Kick på 1, 5, 9, 13 varje 16 steg - 8 takter
            // Steg 1, 5, 9, 13, 17, 21, 25, 29, 33, 37...
        ]),
        PatternTrack(drumCategory: .snare, steps: [
            // Snare på 5, 13 varje 16 steg (backbeat)
        ]),
        PatternTrack(drumCategory: .hihat, steps: [
            // Sparsam hihat - varannan 8-del
        ])
    ],
    compatibleMachines: ["TR-909", "LinnDrum", "Analog Rytm"]
)
```

#### SYNTHPOP (100+ patterns)

| ID | Namn | Steg | Tempo | Intensitet | Beskrivning |
|----|------|------|-------|------------|-------------|
| SP001 | Electropop Basic | 128 | 115-130 | Medium | Klassisk synthpop grund |
| SP002 | New Wave Bounce | 128 | 120-135 | Medium | Studsig, dansant |
| SP003 | Futurepop Drive | 128 | 125-140 | Intense | Driving futurepop |
| SP004 | Minimal Synth | 128 | 110-125 | Minimal | Minimalistisk synthgrund |
| SP005 | 80s Anthem | 128 | 118-128 | Medium | Episk anthemic beat |
| SP006 | Digital Love | 128 | 120-130 | Medium | Romantisk synthpop |
| SP007 | Neon Nights | 128 | 125-135 | Intense | Energisk nattklubb |
| SP008 | Synth Ballad | 128 | 85-100 | Minimal | Långsam balladgrund |
| SP009 | Electro Swing | 128 | 115-125 | Medium | Swinginfluerad synth |
| SP010 | Chrome Dreams | 128 | 120-130 | Medium | Retrofuturistisk |
| ... | ... | ... | ... | ... | ... |
| SP100 | Starlight Express | 128 | 130-145 | Intense | High-energy finale |

#### EBM (100+ patterns)

| ID | Namn | Steg | Tempo | Intensitet | Beskrivning |
|----|------|------|-------|------------|-------------|
| EB001 | Classic EBM | 128 | 120-135 | Medium | Traditionell EBM grund |
| EB002 | Body Music | 128 | 125-140 | Intense | Hård, fysisk beat |
| EB003 | Industrial March | 128 | 115-130 | Intense | Marscherande industrial |
| EB004 | Aggrotech Stomp | 128 | 130-150 | Climax | Aggressiv dansgolv |
| EB005 | Old School DAF | 128 | 120-130 | Medium | DAF-inspirerad |
| EB006 | Belgian New Beat | 128 | 95-115 | Medium | Slowmo new beat |
| EB007 | Front 242 Style | 128 | 125-135 | Intense | Klassisk belgisk EBM |
| EB008 | Nitzer Ebb Pulse | 128 | 130-145 | Intense | Driving, hypnotisk |
| EB009 | Dark Electro | 128 | 125-140 | Intense | Mörk, tung |
| EB010 | Militant Beat | 128 | 120-130 | Medium | Militaristisk |
| ... | ... | ... | ... | ... | ... |
| EB100 | Final Command | 128 | 145-160 | Climax | Extrem intensitet |

```swift
// Exempel: EB001 - Classic EBM (128 steg)
let classicEBM = DrumPattern(
    id: UUID(),
    name: "Classic EBM",
    genre: .ebm,
    subGenre: "Traditional EBM",
    tempo: 120...135,
    length: 128,
    timeSignature: TimeSignature(numerator: 4, denominator: 4),
    swing: 0,
    intensity: .intense,
    tags: ["ebm", "classic", "body music", "industrial"],
    tracks: [
        PatternTrack(drumCategory: .kick, steps: [
            // 4/4 kick med accent
            // Steg: 1(acc), 5, 9, 13, 17(acc), 21, 25, 29...
        ]),
        PatternTrack(drumCategory: .snare, steps: [
            // Aggressiv snare på 5, 13
            // Med ratchets på fills
        ]),
        PatternTrack(drumCategory: .hihat, steps: [
            // 16-dels hihat med velocity variation
        ]),
        PatternTrack(drumCategory: .clap, steps: [
            // Clap layered med snare
        ])
    ],
    variations: [
        PatternVariation(id: UUID(), name: "Breakdown", tracks: [...]),
        PatternVariation(id: UUID(), name: "Buildup", tracks: [...])
    ],
    fills: [
        PatternFill(id: UUID(), name: "Tom Roll", length: 8, tracks: [...]),
        PatternFill(id: UUID(), name: "Snare Build", length: 16, tracks: [...])
    ],
    compatibleMachines: ["TR-909", "Analog Rytm", "Vermona DRM1"]
)
```

#### TECHNO (100+ patterns)

| ID | Namn | Steg | Tempo | Intensitet | Beskrivning |
|----|------|------|-------|------------|-------------|
| TE001 | Berlin Minimal | 128 | 125-135 | Minimal | Hypnotisk minimal techno |
| TE002 | Detroit Classic | 128 | 125-135 | Medium | Klassisk Detroit grund |
| TE003 | Hard Techno | 128 | 140-150 | Intense | Hård, drivande |
| TE004 | Acid Techno | 128 | 130-145 | Intense | 303-vänlig acid |
| TE005 | Dub Techno | 128 | 120-130 | Minimal | Dubby, atmosfärisk |
| TE006 | Industrial Techno | 128 | 135-150 | Climax | Rå, industriell |
| TE007 | Peak Time | 128 | 135-145 | Climax | Main room peak hour |
| TE008 | Warehouse | 128 | 128-138 | Medium | Raw warehouse sound |
| TE009 | Melodic Techno | 128 | 122-132 | Medium | Melodisk, progressiv |
| TE010 | Hypnotic Loop | 128 | 130-140 | Medium | Tranceliknande loop |
| ... | ... | ... | ... | ... | ... |
| TE100 | Rave Anthem | 128 | 145-155 | Climax | 90-tals rave |

```swift
// Exempel: TE001 - Berlin Minimal (128 steg)
let berlinMinimal = DrumPattern(
    id: UUID(),
    name: "Berlin Minimal",
    genre: .techno,
    subGenre: "Minimal Techno",
    tempo: 125...135,
    length: 128,
    timeSignature: TimeSignature(numerator: 4, denominator: 4),
    swing: 5,  // Lätt shuffle
    intensity: .minimal,
    tags: ["minimal", "berlin", "hypnotic", "loop"],
    tracks: [
        PatternTrack(drumCategory: .kick, steps: [
            // Four-on-the-floor
            // Med subtila velocity-variationer
        ]),
        PatternTrack(drumCategory: .hihat, steps: [
            // Offbeat hi-hat
            // Med probability på vissa steg
        ]),
        PatternTrack(drumCategory: .percussion, steps: [
            // Polymetrisk percussion (t.ex. 7/16)
        ])
    ],
    compatibleMachines: ["TR-909", "Analog Rytm", "Vermona DRM1", "Kawai R-100"]
)
```

---

### 7.11 Pattern Generator AI Integration

```swift
class DrumPatternGenerator {
    private var claudeClient: SnirklonClaudeClient
    
    /// Generera pattern baserat på beskrivning
    func generatePattern(
        prompt: String,
        genre: PatternGenre,
        targetMachine: DrumMachineMap,
        length: Int = 128,
        tempo: Int = 120
    ) async throws -> DrumPattern
    
    /// Skapa variation av existerande pattern
    func createVariation(
        from pattern: DrumPattern,
        variationType: VariationType  // .breakdown, .buildup, .minimal, .intense
    ) async throws -> PatternVariation
    
    /// Generera fill som passar pattern
    func generateFill(
        for pattern: DrumPattern,
        fillType: FillType,  // .tomRoll, .snareBuild, .breakdown, .drop
        length: Int = 8
    ) async throws -> PatternFill
    
    /// Analysera och tagga pattern
    func analyzePattern(_ pattern: DrumPattern) -> [String]
    
    /// Föreslå liknande patterns
    func suggestSimilar(to pattern: DrumPattern, limit: Int = 10) -> [DrumPattern]
}

enum VariationType: String, CaseIterable {
    case breakdown = "Breakdown"
    case buildup = "Buildup"
    case minimal = "Minimal"
    case intense = "Intense"
    case polymetric = "Polymetric"
    case half_time = "Half-time"
    case double_time = "Double-time"
}

enum FillType: String, CaseIterable {
    case tomRoll = "Tom Roll"
    case snareBuild = "Snare Build"
    case kickRoll = "Kick Roll"
    case breakdown = "Breakdown"
    case drop = "Drop"
    case crash = "Crash Hit"
    case silence = "Silence"
}
```

---

### 7.12 Pattern Library Statistics

| Genre | Antal Patterns | Subgenrer | Variationer | Fills |
|-------|----------------|-----------|-------------|-------|
| **Darkwave** | 100+ | Cold Wave, Gothic, Deathrock, Post-Punk, Ethereal | 200+ | 150+ |
| **Synthpop** | 100+ | Electropop, Futurepop, New Wave, Minimal Synth | 200+ | 150+ |
| **EBM** | 100+ | Classic EBM, Aggrotech, Dark Electro, New Beat | 200+ | 150+ |
| **Techno** | 100+ | Minimal, Detroit, Berlin, Industrial, Acid | 200+ | 150+ |
| **Totalt** | **400+** | 20+ | 800+ | 600+ |

### 7.13 UI för Pattern Browser

```swift
struct PatternBrowserView: View {
    @ObservedObject var patternLibrary: PatternLibrary
    @State var selectedGenre: PatternGenre?
    @State var selectedMachine: DrumMachineMap?
    @State var searchText: String = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidopanel: Genre & maskinfilter
            List {
                Section("Genre") {
                    ForEach(PatternGenre.allCases, id: \.self) { genre in
                        Button(genre.rawValue) { selectedGenre = genre }
                    }
                }
                Section("Trummaskin") {
                    ForEach(DrumMachineLibrary.allMachines) { machine in
                        Button(machine.name) { selectedMachine = machine }
                    }
                }
            }
        } content: {
            // Pattern-lista
            List(filteredPatterns) { pattern in
                PatternRowView(pattern: pattern)
            }
            .searchable(text: $searchText)
        } detail: {
            // Pattern-förhandsvisning med step-grid
            if let selectedPattern = selectedPattern {
                PatternDetailView(pattern: selectedPattern)
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

### Sprint 7 (Vecka 13-14): Drum Machine MIDI Maps
- [ ] DrumMachineMap datamodell och struktur
- [ ] TR-909 MIDI map med alla spår och CC-mappningar
- [ ] Elektron Analog Rytm MIDI map med parameter control
- [ ] LinnDrum MIDI map (LM-1/LM-2 kompatibel)
- [ ] Kawai R-100 MIDI map
- [ ] Vermona DRM1 MKIII MIDI map med tune/decay CC
- [ ] DrumMachineLibrary med alla maps
- [ ] UI för val av trummaskin och spårmappning
- [ ] Auto-detect av anslutna MIDI-enheter

### Sprint 8 (Vecka 15-16): Pattern Library - Darkwave & Synthpop
- [ ] DrumPattern datamodell med 128-stegs stöd
- [ ] PatternLibrary med sök och filter
- [ ] 100+ Darkwave patterns (Cold Wave, Gothic, Deathrock, Post-Punk)
- [ ] 100+ Synthpop patterns (Electropop, Futurepop, New Wave)
- [ ] Variations-system (A/B, Breakdown, Buildup)
- [ ] Fill-system (Tom Roll, Snare Build, Drop)
- [ ] Pattern Browser UI med förhandsvisning
- [ ] Import/Export av patterns (JSON/MIDI)

### Sprint 9 (Vecka 17-18): Pattern Library - EBM & Techno
- [ ] 100+ EBM patterns (Classic, Aggrotech, Dark Electro, New Beat)
- [ ] 100+ Techno patterns (Minimal, Detroit, Berlin, Industrial, Acid)
- [ ] AI-integration för pattern-generering med Claude
- [ ] Automatisk variation-generering
- [ ] Fill-generering baserat på pattern-analys
- [ ] Pattern similarity och recommendation
- [ ] Tags och kategorisering

### Sprint 10 (Vecka 19-20): Song Mode & Polish
- [ ] Song arranger
- [ ] Pattern chaining med drum patterns
- [ ] Preset-system för trummaskiner
- [ ] Pattern-to-machine mapping
- [ ] Live performance mode med pattern switching
- [ ] Export/Import

### Sprint 11 (Vecka 21-22): Testning & Dokumentation
- [ ] Unit tests (MIDI, CV, ADSR, Clock, Drum Maps)
- [ ] Integration tests med trummaskiner
- [ ] Hardware-testning med TR-909, Analog Rytm, DRM1
- [ ] Pattern validation tests
- [ ] Användarmanual
- [ ] Performance-optimering
- [ ] Pattern library documentation

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

### Drum Machine MIDI Maps:

26. **Roland TR-909** - Komplett MIDI-map med tune/decay CC per spår
27. **Elektron Analog Rytm** - 12 spår med full parameter control
28. **LinnDrum** - LM-1/LM-2 kompatibel med alla klassiska ljud
29. **Kawai R-100** - Full mappning med alla PCM-ljud
30. **Vermona DRM1 MKIII** - Analog trummaskin med CC för tune/decay

### 128-stegs Pattern Library:

31. **Darkwave Patterns (100+)** - Cold Wave, Gothic, Deathrock, Post-Punk, Ethereal
32. **Synthpop Patterns (100+)** - Electropop, Futurepop, New Wave, Minimal Synth
33. **EBM Patterns (100+)** - Classic EBM, Aggrotech, Dark Electro, Belgian New Beat
34. **Techno Patterns (100+)** - Minimal, Detroit, Berlin, Industrial, Acid
35. **Pattern Variations** - A/B variationer, Breakdowns, Buildups per pattern
36. **Fill Library (600+)** - Tom Rolls, Snare Builds, Drops, Crashes
37. **AI Pattern Generation** - Claude-integration för nya patterns
38. **Pattern Browser** - Sök, filter, förhandsvisning, favoriter
39. **Machine Mapping** - Automatisk mappning av patterns till trummaskiner
40. **Pattern Import/Export** - JSON och MIDI-format stöd

---

## Nästa steg

1. **Skapa Swift Package** med grundläggande struktur
2. **Implementera datamodeller** enligt specifikation
3. **Bygga CoreMIDI-wrapper** för MIDI I/O
4. **Implementera intern klocka** med CoreAudio
5. **Skapa minimal UI** för testning

---

*Senast uppdaterad: December 2024*
