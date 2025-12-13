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

### Fas 3C: Avancerat CV-system (Bitwig-inspirerat)

#### 3C.1 Filosofi: CV = Audio

I Snirklon behandlas **CV som audio** vilket ger:
- Full 32-bit floating point precision
- Sample-accurate timing
- Processbar med alla audio-effekter
- Flexibel routing via audio-bussar

```swift
/// CV-signaler är audio-signaler
/// Range: -1.0 till +1.0 (mappat till ±10V eller 0-10V beroende på kalibrering)
typealias CVSignal = AudioBuffer  // Float32 samples
```

---

#### 3C.2 Projektstruktur (Utökad CV)

```
Snirklon/
├── Sources/
│   ├── Core/
│   │   ├── CV/
│   │   │   ├── Engine/
│   │   │   │   ├── CVEngine.swift
│   │   │   │   ├── CVAudioProcessor.swift
│   │   │   │   └── CVRoutingMatrix.swift
│   │   │   ├── IO/
│   │   │   │   ├── CVInput.swift
│   │   │   │   ├── CVOutput.swift
│   │   │   │   └── CVCalibration.swift
│   │   │   ├── Devices/
│   │   │   │   ├── HWCVInstrument.swift
│   │   │   │   ├── HWCVClock.swift
│   │   │   │   ├── HWCVOut.swift
│   │   │   │   └── HWCVIn.swift
│   │   │   ├── Modulators/
│   │   │   │   ├── CVModulator.swift
│   │   │   │   ├── CVLFO.swift
│   │   │   │   ├── CVEnvelope.swift
│   │   │   │   ├── CVCurves.swift
│   │   │   │   ├── CVRandom.swift
│   │   │   │   ├── CVSteps.swift
│   │   │   │   └── CVSidechain.swift
│   │   │   ├── Processing/
│   │   │   │   ├── CVProcessor.swift
│   │   │   │   ├── CVFilter.swift
│   │   │   │   ├── CVDistortion.swift
│   │   │   │   ├── CVDelay.swift
│   │   │   │   ├── CVQuantizer.swift
│   │   │   │   └── CVSlew.swift
│   │   │   ├── Conversion/
│   │   │   │   ├── MIDItoCVConverter.swift
│   │   │   │   ├── CVtoMIDIConverter.swift
│   │   │   │   └── MPEtoCVConverter.swift
│   │   │   └── Routing/
│   │   │       ├── CVBus.swift
│   │   │       ├── CVPatch.swift
│   │   │       └── CVFeedback.swift
```

---

#### 3C.3 HW CV Devices (Hårdvaru-integration)

##### HWCVInstrument.swift - Komplett instrument-interface
```swift
class HWCVInstrument: ObservableObject {
    var id: UUID
    var name: String
    var audioInterface: AudioDeviceID
    
    // CV Outputs
    @Published var pitchOutput: CVOutput          // 1V/oktav pitch
    @Published var gateOutput: CVOutput           // Gate/Trigger
    @Published var velocityOutput: CVOutput?      // Velocity CV
    @Published var aftertouchOutput: CVOutput?    // Aftertouch/Pressure
    @Published var modWheelOutput: CVOutput?      // Mod wheel CV
    
    // Polyfoni
    @Published var voiceCount: Int = 1            // 1-8 röster
    @Published var voiceAllocation: VoiceAllocation
    
    // Kalibrering per synth
    @Published var calibration: InstrumentCalibration
    
    // Clock/Reset
    @Published var clockOutput: CVOutput?
    @Published var resetOutput: CVOutput?
    @Published var runOutput: CVOutput?
    
    struct InstrumentCalibration: Codable {
        var name: String                          // "Moog Mother-32", "Behringer Neutron"
        var voltageStandard: VoltageStandard     // .oneVoltPerOctave, .hzPerVolt
        var pitchRange: ClosedRange<Double>      // T.ex. -5V...+5V
        var gateVoltage: Double                  // T.ex. 5V eller 10V
        var triggerWidth: Double                 // ms
        var noteOffset: Int                      // MIDI note offset
        var tuningTable: [Int: Double]?          // Custom tuning per note
    }
    
    enum VoltageStandard {
        case oneVoltPerOctave    // Eurorack, Moog, etc.
        case hzPerVolt           // Korg MS-20, etc.
        case octPerVolt          // Buchla
    }
}
```

##### HWCVClock.swift - Analog clock-generator
```swift
class HWCVClock: ObservableObject {
    var id: UUID
    var name: String
    
    // Clock output
    @Published var clockOutput: CVOutput
    @Published var division: ClockDivision
    @Published var multiplication: Int               // 1x, 2x, 4x, 8x
    
    // Stabilitet
    @Published var jitterCompensation: Bool = true
    @Published var analogDrift: Double = 0           // Simulera analog instabilitet
    
    // Transport
    @Published var startOutput: CVOutput?            // Start-puls
    @Published var stopOutput: CVOutput?             // Stop-puls
    @Published var resetOutput: CVOutput?            // Reset-puls
    @Published var runOutput: CVOutput?              // High när playing
    
    // Avancerat
    @Published var swing: Double = 0                 // Swing amount
    @Published var swingSource: SwingSource         // .internal, .groove, .external
    @Published var phaseOffset: Double = 0           // 0-360°
    @Published var pulseWidth: Double = 5            // ms
    
    // Multiple clock outputs
    @Published var additionalClocks: [ClockOutput]   // Extra utgångar med olika divisioner
    
    enum SwingSource {
        case `internal`              // Fast swing-värde
        case groove                  // Från Snirklon groove template
        case external                // CV-styrd swing
    }
}
```

##### HWCVOut.swift - Generisk CV-utgång
```swift
class HWCVOut: ObservableObject {
    var id: UUID
    var name: String
    
    @Published var output: CVOutput
    @Published var source: CVSource                  // Vad som skickas ut
    
    // Range & Kalibrering
    @Published var inputRange: ClosedRange<Double>   // Source range
    @Published var outputRange: ClosedRange<Double>  // CV voltage range
    @Published var curve: TransferCurve              // Linear, log, exp, S-curve
    
    // Slew/Glide
    @Published var slewUp: Double = 0                // Rise time (ms)
    @Published var slewDown: Double = 0              // Fall time (ms)
    @Published var slewShape: SlewShape
    
    enum CVSource {
        case modulator(UUID)         // Intern modulator
        case audio(AudioTrack)       // Audio → CV
        case parameter(String)       // Automationsparameter
        case midi(MIDISource)        // MIDI → CV
        case expression(String)      // MPE expression
        case external(CVInput)       // CV In → CV Out (thru/processing)
    }
    
    enum TransferCurve {
        case linear
        case logarithmic
        case exponential
        case sCurve
        case custom([Double])        // Lookup table
    }
    
    enum SlewShape {
        case linear
        case exponential
        case logarithmic
        case rc                      // RC-filter shape
    }
}
```

##### HWCVIn.swift - CV-ingång
```swift
class HWCVIn: ObservableObject {
    var id: UUID
    var name: String
    
    @Published var input: CVInput
    @Published var destination: CVDestination        // Vart CV:n ska
    
    // Signal conditioning
    @Published var inputRange: ClosedRange<Double>   // Förväntad spänning
    @Published var offset: Double = 0                // DC offset korrigering
    @Published var gain: Double = 1.0                // Förstärkning
    @Published var invert: Bool = false              // Invertera signal
    
    // Noise gate
    @Published var noiseGate: Double = 0             // Threshold
    @Published var hysteresis: Double = 0.1          // Gate hysteresis
    
    // Quantization
    @Published var quantizeToNotes: Bool = false     // CV → noter
    @Published var scale: Scale?                     // Skala för kvantisering
    
    enum CVDestination {
        case modulation(target: String)              // Modulera parameter
        case notes                                   // CV → MIDI noter
        case automation(parameter: String)           // CV → automation
        case audio                                   // CV som audio
        case clock                                   // CV → clock
        case gate                                    // CV → gate/trigger
    }
}

struct CVInput: Identifiable {
    var id: UUID
    var name: String
    var audioChannel: Int                            // Fysisk ingångskanal
    var calibration: CVCalibration
    var currentVoltage: Double = 0.0
    
    // Monitoring
    var peakVoltage: Double = 0.0
    var averageVoltage: Double = 0.0
}
```

---

#### 3C.4 CV Processing (CV som Audio)

##### CVProcessor.swift - Base processor
```swift
protocol CVProcessor: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var isEnabled: Bool { get set }
    
    /// Processa CV-buffer (sample-by-sample)
    func process(_ input: CVSignal, sampleRate: Double) -> CVSignal
    
    /// Bypass-stöd
    var bypass: Bool { get set }
    
    /// Wet/Dry mix
    var mix: Double { get set }
}
```

##### CVFilter.swift
```swift
class CVFilter: CVProcessor {
    @Published var filterType: FilterType
    @Published var frequency: Double                 // Hz eller modulerad
    @Published var resonance: Double                 // 0-1
    @Published var drive: Double                     // Pre-filter saturation
    
    // Modulering av filter
    @Published var frequencyModSource: CVSource?
    @Published var frequencyModAmount: Double = 0
    
    enum FilterType {
        case lowpass(slope: Slope)
        case highpass(slope: Slope)
        case bandpass
        case notch
        case allpass
        case comb(feedback: Double)
        case formant(vowel: Vowel)
    }
    
    enum Slope { case db6, db12, db24, db48 }
    enum Vowel { case a, e, i, o, u }
    
    /// Användning: Jämna ut ojämna CV-signaler, ta bort brus
}
```

##### CVDistortion.swift
```swift
class CVDistortion: CVProcessor {
    @Published var distortionType: DistortionType
    @Published var drive: Double                     // 0-1
    @Published var tone: Double                      // Post-distortion filter
    @Published var symmetry: Double                  // -1 till +1 (asymmetric)
    
    enum DistortionType {
        case softClip
        case hardClip
        case foldback(threshold: Double)
        case waveshaper(table: [Double])
        case bitcrush(bits: Int, sampleRate: Double)
        case rectify(type: RectifyType)
    }
    
    enum RectifyType {
        case fullWave       // |x|
        case halfWavePos    // max(0, x)
        case halfWaveNeg    // min(0, x)
    }
    
    /// Användning: Transformera LFO-former, skapa komplexa modulations-signaler
}
```

##### CVDelay.swift
```swift
class CVDelay: CVProcessor {
    @Published var delayTime: Double                 // ms eller synkad
    @Published var syncToTempo: Bool
    @Published var tempoDiv: ClockDivision
    @Published var feedback: Double                  // 0-1 (>1 för oscillation)
    @Published var damping: Double                   // High-frequency damping
    
    // Modulation
    @Published var timeModSource: CVSource?
    @Published var timeModAmount: Double = 0
    
    /// Användning: Skapa fördröjda modulationer, echo-effekter på CV
}
```

##### CVQuantizer.swift
```swift
class CVQuantizer: CVProcessor {
    @Published var scale: Scale                      // Musikalisk skala
    @Published var rootNote: Int                     // 0-11 (C till B)
    @Published var octaveRange: Int                  // Antal oktaver
    
    // Trigger mode
    @Published var triggerMode: TriggerMode
    @Published var triggerInput: CVInput?            // Extern trigger
    
    // Glide
    @Published var glideEnabled: Bool
    @Published var glideTime: Double                 // ms
    
    enum TriggerMode {
        case continuous      // Kvantisera varje sample
        case triggered       // Kvantisera vid trigger
        case gated           // Kvantisera medan gate är hög
    }
    
    /// Användning: Konvertera fri CV till noter, skalbaserad modulation
}
```

##### CVSlew.swift
```swift
class CVSlew: CVProcessor {
    @Published var riseTime: Double                  // ms (0 = instant)
    @Published var fallTime: Double                  // ms
    @Published var shape: SlewShape                  // Linear, exp, log
    @Published var linked: Bool                      // Rise = Fall
    
    // Track & Hold
    @Published var trackAndHold: Bool
    @Published var holdTrigger: CVInput?
    
    enum SlewShape {
        case linear
        case exponential
        case logarithmic
        case rc(time: Double)
    }
    
    /// Användning: Portamento, envelope-formning, anti-click
}
```

---

#### 3C.5 Modulators (CV Powerhouse)

##### CVModulator.swift - Base modulator
```swift
protocol CVModulator: AnyObject {
    var id: UUID { get }
    var name: String { get }
    
    /// Generera CV-signal
    func generate(sampleCount: Int, sampleRate: Double) -> CVSignal
    
    /// Reset/retrigger
    func reset()
    func trigger()
    func release()
    
    /// Output routing
    var destinations: [ModulationDestination] { get set }
    var amount: Double { get set }  // 0-1
    var bipolar: Bool { get set }   // +/- eller 0-1
}

struct ModulationDestination {
    var target: String              // Parameter path
    var amount: Double              // Modulation depth
    var curve: TransferCurve        // Response curve
}
```

##### CVLFO.swift (Utökad)
```swift
class CVLFO: CVModulator {
    // Grundläggande
    @Published var shape: LFOShape
    @Published var rate: Double                      // Hz (fri) eller division (synkad)
    @Published var syncToTempo: Bool
    @Published var tempoDiv: ClockDivision
    
    // Form
    @Published var phase: Double                     // 0-360° startfas
    @Published var pulseWidth: Double               // PWM för square (0-1)
    @Published var skew: Double                     // Symmetri (-1 till +1)
    @Published var smooth: Double                   // Corners rounding
    
    // Avancerat
    @Published var retrigger: Bool                  // Reset vid gate
    @Published var oneShot: Bool                    // Stoppa efter en cykel
    @Published var fadeIn: Double                   // Fade-in tid (ms)
    @Published var fadeOut: Double                  // Fade-out tid (ms)
    
    // Rate modulation
    @Published var rateModSource: CVSource?
    @Published var rateModAmount: Double = 0
    
    // Shape morphing
    @Published var morphTarget: LFOShape?
    @Published var morphAmount: Double = 0
    
    enum LFOShape: CaseIterable {
        case sine
        case triangle
        case saw
        case ramp
        case square
        case pulse(width: Double)
        case random                                 // S&H
        case smoothRandom                           // Interpolated random
        case chaos                                  // Lorenz attractor
        case custom([Double])                       // Wavetable
    }
}
```

##### CVCurves.swift - Freeform kurvor
```swift
class CVCurves: CVModulator {
    @Published var points: [CurvePoint]             // Kurv-punkter
    @Published var loop: Bool
    @Published var loopStart: Int
    @Published var loopEnd: Int
    @Published var duration: Double                 // Total tid (ms eller beats)
    @Published var syncToTempo: Bool
    
    struct CurvePoint {
        var time: Double                            // 0-1 (relativ position)
        var value: Double                           // -1 till +1
        var curve: CurveType                        // Kurva TILL denna punkt
        var tension: Double                         // Kurv-tension
    }
    
    enum CurveType {
        case linear
        case exponential
        case logarithmic
        case sCurve
        case step
        case hold
    }
}
```

##### CVRandom.swift
```swift
class CVRandom: CVModulator {
    @Published var mode: RandomMode
    @Published var rate: Double                     // Hz eller synkad
    @Published var syncToTempo: Bool
    @Published var tempoDiv: ClockDivision
    
    // Range
    @Published var min: Double                      // Min output
    @Published var max: Double                      // Max output
    @Published var quantize: Bool                   // Kvantisera till steg
    @Published var steps: Int                       // Antal steg (om kvantiserad)
    
    // Probability
    @Published var density: Double                  // Sannolikhet för förändring (0-1)
    @Published var inertia: Double                  // Motstånd mot förändring
    
    // Slew
    @Published var slew: Double                     // Interpoleringstid (ms)
    
    enum RandomMode {
        case sampleAndHold      // Slumpa vid trigger
        case smoothRandom       // Interpolerad random
        case walk               // Random walk (brownian)
        case probability        // Bernoulli trials
        case lorentz            // Chaos attractor
        case turing             // Turing machine pattern
    }
}
```

##### CVSteps.swift - Step sequencer modulator
```swift
class CVSteps: CVModulator {
    @Published var steps: [StepValue]               // Steg-värden
    @Published var length: Int                      // Aktiva steg (1-128)
    @Published var rate: Double                     // Hz eller synkad
    @Published var syncToTempo: Bool
    @Published var tempoDiv: ClockDivision
    
    // Interpolation
    @Published var interpolation: Interpolation     // .step, .linear, .smooth
    @Published var glide: Double                    // Glide-tid per steg (ms)
    
    // Avancerat
    @Published var direction: PlayDirection         // Forward, reverse, pingpong, random
    @Published var probability: [Double]            // Probability per steg
    
    struct StepValue {
        var value: Double                           // -1 till +1
        var enabled: Bool
        var probability: Double                     // 0-100%
        var glide: Bool                             // Glide TILL detta steg
    }
    
    enum Interpolation {
        case step           // Hårt steg
        case linear         // Linjär interpolation
        case smooth         // Smoothstep
        case exponential
        case logarithmic
    }
    
    enum PlayDirection {
        case forward
        case reverse
        case pingPong
        case random
    }
}
```

##### CVSidechain.swift - Audio → CV
```swift
class CVSidechain: CVModulator {
    @Published var audioSource: AudioSource         // Input
    @Published var mode: SidechainMode
    
    // Envelope follower
    @Published var attack: Double                   // ms
    @Published var release: Double                  // ms
    @Published var sensitivity: Double              // Gain
    
    // Frequency detection
    @Published var lowFreq: Double                  // Hz (bandpass)
    @Published var highFreq: Double                 // Hz
    
    // Pitch detection
    @Published var pitchTrackingEnabled: Bool
    @Published var pitchRange: ClosedRange<Int>     // MIDI notes
    
    enum AudioSource {
        case track(UUID)        // Spår-audio
        case input(Int)         // Hardware input
        case sidechain(UUID)    // Sidechain-ingång
    }
    
    enum SidechainMode {
        case envelopeFollower   // Amplitude → CV
        case pitchTracker       // Pitch → CV (1V/oct)
        case gateDetector       // Threshold → gate
        case transientDetector  // Transienter → trigger
        case spectral(band: Int) // Spektral-band → CV
    }
}
```

---

#### 3C.6 MIDI ↔ CV Konvertering

##### MIDItoCVConverter.swift
```swift
class MIDItoCVConverter: ObservableObject {
    @Published var midiInput: MIDIInput
    
    // Outputs
    var pitchCV: CVOutput?          // Note → 1V/oct
    var gateCV: CVOutput?           // Note on/off → gate
    var velocityCV: CVOutput?       // Velocity → CV
    var aftertouchCV: CVOutput?     // Aftertouch → CV
    var modWheelCV: CVOutput?       // CC1 → CV
    var pitchBendCV: CVOutput?      // Pitch bend → CV
    
    // CC mapping
    @Published var ccMappings: [CCtoCV]
    
    // MPE support
    @Published var mpeEnabled: Bool
    @Published var mpeChannels: ClosedRange<Int>    // MPE zone
    var mpeOutputs: [MPEVoiceCV]                    // Per-voice CV
    
    struct CCtoCV {
        var ccNumber: Int
        var output: CVOutput
        var range: ClosedRange<Double>              // Output voltage range
        var curve: TransferCurve
    }
    
    struct MPEVoiceCV {
        var pitchCV: CVOutput
        var gateCV: CVOutput
        var pressureCV: CVOutput                    // Channel pressure
        var slideCV: CVOutput                       // CC74 (MPE slide)
        var pitchBendCV: CVOutput                   // Per-note pitch bend
    }
}
```

##### CVtoMIDIConverter.swift
```swift
class CVtoMIDIConverter: ObservableObject {
    // CV Inputs
    var pitchCV: CVInput?           // CV → Note pitch
    var gateCV: CVInput?            // CV → Note on/off
    var velocityCV: CVInput?        // CV → Velocity
    var channelPressureCV: CVInput? // CV → Aftertouch
    
    // Output
    @Published var midiOutput: MIDIOutput
    @Published var midiChannel: Int
    
    // Quantization
    @Published var quantizeToScale: Bool
    @Published var scale: Scale?
    
    // CC outputs
    @Published var cvToCCMappings: [CVtoCC]
    
    struct CVtoCC {
        var input: CVInput
        var ccNumber: Int
        var range: ClosedRange<Int>                 // 0-127 range mapping
        var curve: TransferCurve
    }
    
    // Trigger mode
    @Published var triggerMode: TriggerMode
    
    enum TriggerMode {
        case gateToNote         // Gate hög = note on, låg = note off
        case triggerToNote      // Trigger = note with fixed duration
        case legato             // Monofon med legato
    }
}
```

##### MPEtoCVConverter.swift
```swift
class MPEtoCVConverter: ObservableObject {
    @Published var mpeInput: MIDIInput
    @Published var voiceCount: Int = 4              // Polyfoni (1-8)
    
    // Per voice outputs (upp till 8 voices)
    var voices: [MPEVoiceOutputs]
    
    struct MPEVoiceOutputs {
        var pitchCV: CVOutput                       // Note pitch + pitch bend
        var gateCV: CVOutput                        // Gate
        var pressureCV: CVOutput                    // Z-axis / pressure
        var slideCV: CVOutput                       // Y-axis / slide (CC74)
        var strikeCV: CVOutput                      // Initial velocity
    }
    
    // Voice allocation
    @Published var voiceAllocation: VoiceAllocation
    @Published var pitchBendRange: Int = 48         // Semitones (MPE default)
    
    // Glide
    @Published var glideMode: GlideMode
    @Published var glideTime: Double                // ms
    
    enum GlideMode {
        case off
        case legato              // Endast vid överlappande noter
        case always
        case rate(Double)        // Konstant hastighet (V/s)
    }
}
```

---

#### 3C.7 CV Routing & Patching

##### CVRoutingMatrix.swift
```swift
class CVRoutingMatrix: ObservableObject {
    @Published var patches: [CVPatch]
    @Published var busses: [CVBus]
    
    // Alla tillgängliga källor och destinations
    var availableSources: [CVSource]
    var availableDestinations: [CVDestination]
    
    /// Skapa ny patch
    func connect(source: CVSource, destination: CVDestination, amount: Double)
    
    /// Ta bort patch
    func disconnect(patchId: UUID)
    
    /// Feedback-detection
    func detectFeedbackLoops() -> [FeedbackLoop]
    
    /// Route CV genom processors
    func insertProcessor(_ processor: CVProcessor, in patch: CVPatch)
}

struct CVPatch: Identifiable {
    var id: UUID
    var source: CVSource
    var destination: CVDestination
    var amount: Double                              // -1 till +1
    var processors: [CVProcessor]                   // Processing chain
    var enabled: Bool
}

struct CVBus: Identifiable {
    var id: UUID
    var name: String
    var sources: [CVSource]                         // Multiple sources (mixed)
    var destinations: [CVDestination]               // Multiple destinations
    var mixMode: MixMode
    
    enum MixMode {
        case sum            // Addera alla sources
        case average        // Medelvärde
        case max            // Maxvärde
        case min            // Minvärde
        case multiply       // Multiplicera (ring mod)
    }
}
```

##### CVFeedback.swift
```swift
class CVFeedback: ObservableObject {
    @Published var enabled: Bool
    @Published var source: CVSource
    @Published var destination: CVDestination
    @Published var amount: Double                   // Feedback-mängd (0-1, eller >1)
    @Published var delay: Double                    // Fördröjning (samples)
    @Published var damping: Double                  // High-frequency damping
    
    // Säkerhet
    @Published var softLimit: Bool                  // Soft-clip feedback
    @Published var dcBlock: Bool                    // Blockera DC-drift
    
    /// CV feedback loops - kraftfullt men potentiellt instabilt!
    /// Kräver delay för att undvika infinite loop
}
```

---

#### 3C.8 CV Clock & Sync

##### CVClockSystem.swift
```swift
class CVClockSystem: ObservableObject {
    // Master clock
    @Published var masterTempo: Double              // BPM
    @Published var isRunning: Bool
    
    // Clock outputs
    @Published var clockOutputs: [CVClockOutput]
    
    // Clock inputs
    @Published var clockInputs: [CVClockInput]
    
    // Transport outputs
    @Published var startOutput: CVOutput?           // Start trigger
    @Published var stopOutput: CVOutput?            // Stop trigger
    @Published var resetOutput: CVOutput?           // Reset trigger
    @Published var runOutput: CVOutput?             // Gate (hög = playing)
    
    // Sync settings
    @Published var syncSource: SyncSource
    @Published var syncDestination: SyncDestination
    
    enum SyncSource {
        case `internal`          // Snirklon master
        case midiClock           // MIDI clock in
        case cvClock(CVInput)    // CV clock in
        case abletonLink         // Ableton Link
    }
    
    enum SyncDestination {
        case `internal`          // Endast internt
        case midiClock           // Skicka MIDI clock
        case cvClock             // Skicka CV clock
        case both                // MIDI + CV
        case all                 // MIDI + CV + Link
    }
}

struct CVClockOutput: Identifiable {
    var id: UUID
    var name: String
    var output: CVOutput
    var division: ClockDivision
    var multiplication: Int
    var pulseWidth: Double                          // ms
    var swing: Double                               // %
    var phase: Double                               // ° offset
}

struct CVClockInput: Identifiable {
    var id: UUID
    var name: String
    var input: CVInput
    var threshold: Double                           // Trigger threshold
    var division: ClockDivision                     // Input division
    var ppqn: Int                                   // Pulses per quarter note
}
```

---

#### 3C.9 Avancerade Use Cases

##### Polyfonisk CV (via MPE)
```swift
/// MPE → Multi-channel CV
/// 4-8 röster med individuell pitch, gate, pressure, slide
let mpeCV = MPEtoCVConverter()
mpeCV.voiceCount = 4
// Kräver 4x4 = 16 CV-utgångar för full MPE-support
```

##### CV-driven FX Routing
```swift
/// CV → Audio routing
/// Exempel: CV styr wet/dry mix eller FX-kedjning
let routeCV = HWCVIn()
routeCV.destination = .automation(parameter: "effects.delay.mix")
```

##### Hybrid Modular + DAW
```swift
/// Eurorack LFO → DAW automation
let lfoIn = HWCVIn()
lfoIn.destination = .modulation(target: "synth.filter.cutoff")

/// DAW envelope → Eurorack VCA
let envOut = HWCVOut()
envOut.source = .modulator(adsrEnvelope.id)
```

##### CV-baserad Generativ Musik
```swift
/// Chaos-baserad sequencing
let chaosLFO = CVLFO()
chaosLFO.shape = .chaos  // Lorenz attractor
chaosLFO.destinations = [
    ModulationDestination(target: "sequencer.pitch", amount: 0.5),
    ModulationDestination(target: "sequencer.gate", amount: 0.3)
]

/// Turing Machine-pattern
let turing = CVRandom()
turing.mode = .turing
turing.destinations = [
    ModulationDestination(target: "track1.pitch", amount: 1.0)
]
```

##### CV Feedback Loops
```swift
/// Självmodulerande system
let feedback = CVFeedback()
feedback.source = .modulator(lfo.id)
feedback.destination = .modulator(lfo.id)  // LFO rate
feedback.amount = 0.3
feedback.delay = 10  // samples delay för stabilitet
```

---

#### 3C.10 Expert Sleepers ES-9 Integration (Primary Support)

##### ES-9 Översikt

Expert Sleepers ES-9 är det primära CV-gränssnittet för Snirklon med full integration:

| Specifikation | Värde |
|---------------|-------|
| **CV Outputs** | 8 (DC-kopplade, ±10V) |
| **CV Inputs** | 4 (DC-kopplade, ±10V) |
| **Headphone Output** | 1 (stereo, AC-kopplad) |
| **Line Inputs** | 2 (AC-kopplade) |
| **ADAT In** | 8 kanaler (expanderbar) |
| **ADAT Out** | 8 kanaler (expanderbar) |
| **Sample Rates** | 44.1, 48, 88.2, 96 kHz |
| **Bit Depth** | 24-bit |
| **USB** | USB 2.0 Class Compliant |
| **Latency** | <1ms (64 samples @ 48kHz) |
| **Format** | 14HP Eurorack |

##### ES9Device.swift
```swift
class ES9Device: ObservableObject {
    static let vendorID: UInt16 = 0x0483   // Expert Sleepers
    static let productID: UInt16 = 0xA2D9  // ES-9
    
    // Device state
    @Published var isConnected: Bool = false
    @Published var sampleRate: ES9SampleRate = .rate48k
    @Published var bufferSize: ES9BufferSize = .samples64
    @Published var firmwareVersion: String = ""
    
    // Channel configuration (8+8 outputs, 4+2 inputs via main, +8+8 via ADAT)
    @Published var outputChannels: [ES9OutputChannel] = []
    @Published var inputChannels: [ES9InputChannel] = []
    
    // ADAT expansion
    @Published var adatInputEnabled: Bool = false
    @Published var adatOutputEnabled: Bool = false
    @Published var adatDevice: String?  // ES-3, ES-6, etc.
    
    // Calibration
    @Published var calibration: ES9Calibration
    
    // iOS/macOS compatibility
    @Published var hostMode: ES9HostMode
    
    enum ES9SampleRate: Int, CaseIterable {
        case rate44_1k = 44100
        case rate48k = 48000
        case rate88_2k = 88200
        case rate96k = 96000
        
        var adatChannels: Int {
            switch self {
            case .rate44_1k, .rate48k: return 8
            case .rate88_2k, .rate96k: return 4  // SMUX
            }
        }
    }
    
    enum ES9BufferSize: Int, CaseIterable {
        case samples32 = 32
        case samples64 = 64
        case samples128 = 128
        case samples256 = 256
        case samples512 = 512
        
        func latencyMs(at sampleRate: ES9SampleRate) -> Double {
            return Double(self.rawValue) / Double(sampleRate.rawValue) * 1000.0
        }
    }
    
    enum ES9HostMode {
        case macOS              // Full CoreAudio support
        case iOS                // iOS/iPadOS support
        case classCompliant     // Generic USB audio
    }
}
```

##### ES-9 Channel Mapping
```swift
struct ES9OutputChannel: Identifiable {
    var id: Int                          // 1-16 (8 main + 8 ADAT)
    var name: String
    var type: ES9ChannelType
    var jackNumber: Int?                 // Physical jack (1-8 for main)
    var adatChannel: Int?                // ADAT channel (1-8)
    
    // CV configuration
    var cvType: CVOutputType
    var calibration: CVCalibration
    var currentVoltage: Double = 0.0
    
    enum ES9ChannelType {
        case mainDC              // Outputs 1-8: DC-coupled CV
        case headphone           // Output 9-10: AC-coupled headphone
        case adatOut             // ADAT outputs 1-8
    }
}

struct ES9InputChannel: Identifiable {
    var id: Int                          // 1-14 (4 CV + 2 line + 8 ADAT)
    var name: String
    var type: ES9InputType
    var jackNumber: Int?                 // Physical jack
    var adatChannel: Int?                // ADAT channel
    
    // CV configuration
    var cvType: CVInputType?
    var calibration: CVCalibration?
    
    enum ES9InputType {
        case cvDC                // Inputs 1-4: DC-coupled CV
        case lineAC              // Inputs 5-6: AC-coupled line
        case adatIn              // ADAT inputs 1-8
    }
}

// ES-9 Default Channel Layout
let es9DefaultChannels = ES9ChannelLayout(
    outputs: [
        // Main DC-coupled outputs (±10V capable)
        ES9OutputChannel(id: 1, name: "CV Out 1", type: .mainDC, jackNumber: 1, cvType: .pitch),
        ES9OutputChannel(id: 2, name: "CV Out 2", type: .mainDC, jackNumber: 2, cvType: .gate),
        ES9OutputChannel(id: 3, name: "CV Out 3", type: .mainDC, jackNumber: 3, cvType: .velocity),
        ES9OutputChannel(id: 4, name: "CV Out 4", type: .mainDC, jackNumber: 4, cvType: .modulation),
        ES9OutputChannel(id: 5, name: "CV Out 5", type: .mainDC, jackNumber: 5, cvType: .envelope),
        ES9OutputChannel(id: 6, name: "CV Out 6", type: .mainDC, jackNumber: 6, cvType: .lfo),
        ES9OutputChannel(id: 7, name: "CV Out 7", type: .mainDC, jackNumber: 7, cvType: .clock),
        ES9OutputChannel(id: 8, name: "CV Out 8", type: .mainDC, jackNumber: 8, cvType: .modulation),
        // Headphone (AC-coupled, not for CV)
        ES9OutputChannel(id: 9, name: "Headphone L", type: .headphone, cvType: .audio),
        ES9OutputChannel(id: 10, name: "Headphone R", type: .headphone, cvType: .audio),
        // ADAT outputs (optional, for ES-3 expansion)
        ES9OutputChannel(id: 11, name: "ADAT 1", type: .adatOut, adatChannel: 1, cvType: .pitch),
        ES9OutputChannel(id: 12, name: "ADAT 2", type: .adatOut, adatChannel: 2, cvType: .gate),
        ES9OutputChannel(id: 13, name: "ADAT 3", type: .adatOut, adatChannel: 3, cvType: .modulation),
        ES9OutputChannel(id: 14, name: "ADAT 4", type: .adatOut, adatChannel: 4, cvType: .modulation),
        ES9OutputChannel(id: 15, name: "ADAT 5", type: .adatOut, adatChannel: 5, cvType: .modulation),
        ES9OutputChannel(id: 16, name: "ADAT 6", type: .adatOut, adatChannel: 6, cvType: .modulation),
        ES9OutputChannel(id: 17, name: "ADAT 7", type: .adatOut, adatChannel: 7, cvType: .modulation),
        ES9OutputChannel(id: 18, name: "ADAT 8", type: .adatOut, adatChannel: 8, cvType: .modulation),
    ],
    inputs: [
        // DC-coupled CV inputs (±10V)
        ES9InputChannel(id: 1, name: "CV In 1", type: .cvDC, jackNumber: 1),
        ES9InputChannel(id: 2, name: "CV In 2", type: .cvDC, jackNumber: 2),
        ES9InputChannel(id: 3, name: "CV In 3", type: .cvDC, jackNumber: 3),
        ES9InputChannel(id: 4, name: "CV In 4", type: .cvDC, jackNumber: 4),
        // AC-coupled line inputs
        ES9InputChannel(id: 5, name: "Line In L", type: .lineAC, jackNumber: 5),
        ES9InputChannel(id: 6, name: "Line In R", type: .lineAC, jackNumber: 6),
        // ADAT inputs (for ES-6 expansion)
        ES9InputChannel(id: 7, name: "ADAT In 1", type: .adatIn, adatChannel: 1),
        ES9InputChannel(id: 8, name: "ADAT In 2", type: .adatIn, adatChannel: 2),
        ES9InputChannel(id: 9, name: "ADAT In 3", type: .adatIn, adatChannel: 3),
        ES9InputChannel(id: 10, name: "ADAT In 4", type: .adatIn, adatChannel: 4),
        ES9InputChannel(id: 11, name: "ADAT In 5", type: .adatIn, adatChannel: 5),
        ES9InputChannel(id: 12, name: "ADAT In 6", type: .adatIn, adatChannel: 6),
        ES9InputChannel(id: 13, name: "ADAT In 7", type: .adatIn, adatChannel: 7),
        ES9InputChannel(id: 14, name: "ADAT In 8", type: .adatIn, adatChannel: 8),
    ]
)
```

##### ES-9 Calibration System
```swift
struct ES9Calibration: Codable {
    var deviceSerial: String             // Unikt per ES-9 enhet
    var calibrationDate: Date
    
    // Per-output calibration
    var outputCalibrations: [Int: ES9OutputCalibration]
    
    // Per-input calibration
    var inputCalibrations: [Int: ES9InputCalibration]
    
    // Global offset (kompensera för DC drift)
    var globalOffset: Double = 0.0
}

struct ES9OutputCalibration: Codable {
    var channelId: Int
    
    // Voltage range (ES-9 stödjer ±10V)
    var minVoltage: Double = -10.0
    var maxVoltage: Double = +10.0
    
    // 1V/oct calibration
    var octaveScale: Double = 1.0        // 1.0 = perfekt 1V/oct
    var c0Voltage: Double = 0.0          // Spänning för C0 (MIDI 24)
    
    // Fine tuning per oktav (för extremt precis kalibrering)
    var octaveOffsets: [Int: Double]?    // Oktav → offset i volt
    
    // DC offset kompensation
    var dcOffset: Double = 0.0
    
    // Slew rate (ES-9 har hög slew rate, men kan behöva kompenseras)
    var slewCompensation: Double = 0.0
}

struct ES9InputCalibration: Codable {
    var channelId: Int
    
    // Input range (ES-9 hanterar ±10V)
    var minVoltage: Double = -10.0
    var maxVoltage: Double = +10.0
    
    // Gain/offset
    var gain: Double = 1.0
    var offset: Double = 0.0
    
    // Noise gate threshold
    var noiseFloor: Double = 0.001       // Volt
}
```

##### ES-9 Integration med CVEngine
```swift
extension CVEngine {
    /// Konfigurera för ES-9
    func configureForES9() throws {
        guard let es9 = findES9Device() else {
            throw CVEngineError.deviceNotFound("Expert Sleepers ES-9")
        }
        
        // Sätt som primärt CV-gränssnitt
        self.primaryDevice = es9
        
        // Konfigurera sample rate (48kHz rekommenderat för låg latens)
        self.sampleRate = 48000
        self.bufferSize = 64  // ~1.3ms latens
        
        // Mappa ES-9 kanaler till CV-system
        for output in es9.outputChannels where output.type == .mainDC {
            let cvOutput = CVOutput(
                id: UUID(),
                name: output.name,
                audioChannel: output.id - 1,  // 0-indexed
                type: output.cvType,
                calibration: es9.calibration.outputCalibrations[output.id] ?? .default
            )
            self.cvOutputs.append(cvOutput)
        }
        
        for input in es9.inputChannels where input.type == .cvDC {
            let cvInput = CVInput(
                id: UUID(),
                name: input.name,
                audioChannel: input.id - 1,
                calibration: es9.calibration.inputCalibrations[input.id] ?? .default
            )
            self.cvInputs.append(cvInput)
        }
    }
    
    /// Auto-detect ES-9
    func findES9Device() -> ES9Device? {
        // Använd CoreAudio för att hitta ES-9
        let devices = AudioDeviceManager.shared.availableDevices
        return devices.first { device in
            device.name.contains("ES-9") || 
            (device.vendorID == ES9Device.vendorID && device.productID == ES9Device.productID)
        }.map { ES9Device(from: $0) }
    }
}
```

##### ES-9 Presets (Vanliga Konfigurationer)
```swift
enum ES9Preset: String, CaseIterable {
    case monoSynth = "Mono Synth"
    case polySynth4Voice = "4-Voice Poly"
    case drumMachine = "Drum Machine"
    case modularSequencer = "Modular Sequencer"
    case hybridDAW = "Hybrid DAW"
    case mpeController = "MPE Controller"
    
    var channelAssignments: [ES9ChannelAssignment] {
        switch self {
        case .monoSynth:
            return [
                ES9ChannelAssignment(channel: 1, role: .pitch, description: "1V/oct Pitch"),
                ES9ChannelAssignment(channel: 2, role: .gate, description: "Gate"),
                ES9ChannelAssignment(channel: 3, role: .velocity, description: "Velocity"),
                ES9ChannelAssignment(channel: 4, role: .modWheel, description: "Mod Wheel"),
                ES9ChannelAssignment(channel: 5, role: .envelope, description: "Filter Env"),
                ES9ChannelAssignment(channel: 6, role: .lfo, description: "LFO"),
                ES9ChannelAssignment(channel: 7, role: .clock, description: "Clock"),
                ES9ChannelAssignment(channel: 8, role: .reset, description: "Reset"),
            ]
            
        case .polySynth4Voice:
            return [
                // Voice 1
                ES9ChannelAssignment(channel: 1, role: .pitch, description: "Voice 1 Pitch"),
                ES9ChannelAssignment(channel: 2, role: .gate, description: "Voice 1 Gate"),
                // Voice 2
                ES9ChannelAssignment(channel: 3, role: .pitch, description: "Voice 2 Pitch"),
                ES9ChannelAssignment(channel: 4, role: .gate, description: "Voice 2 Gate"),
                // Voice 3
                ES9ChannelAssignment(channel: 5, role: .pitch, description: "Voice 3 Pitch"),
                ES9ChannelAssignment(channel: 6, role: .gate, description: "Voice 3 Gate"),
                // Voice 4
                ES9ChannelAssignment(channel: 7, role: .pitch, description: "Voice 4 Pitch"),
                ES9ChannelAssignment(channel: 8, role: .gate, description: "Voice 4 Gate"),
            ]
            
        case .drumMachine:
            return [
                ES9ChannelAssignment(channel: 1, role: .trigger, description: "Kick"),
                ES9ChannelAssignment(channel: 2, role: .trigger, description: "Snare"),
                ES9ChannelAssignment(channel: 3, role: .trigger, description: "Hi-Hat"),
                ES9ChannelAssignment(channel: 4, role: .trigger, description: "Clap"),
                ES9ChannelAssignment(channel: 5, role: .trigger, description: "Tom 1"),
                ES9ChannelAssignment(channel: 6, role: .trigger, description: "Tom 2"),
                ES9ChannelAssignment(channel: 7, role: .clock, description: "Clock"),
                ES9ChannelAssignment(channel: 8, role: .accent, description: "Accent"),
            ]
            
        case .modularSequencer:
            return [
                ES9ChannelAssignment(channel: 1, role: .pitch, description: "Seq Pitch"),
                ES9ChannelAssignment(channel: 2, role: .gate, description: "Seq Gate"),
                ES9ChannelAssignment(channel: 3, role: .modulation, description: "Mod 1 (steps)"),
                ES9ChannelAssignment(channel: 4, role: .modulation, description: "Mod 2 (LFO)"),
                ES9ChannelAssignment(channel: 5, role: .modulation, description: "Mod 3 (env)"),
                ES9ChannelAssignment(channel: 6, role: .modulation, description: "Mod 4 (random)"),
                ES9ChannelAssignment(channel: 7, role: .clock, description: "Clock Out"),
                ES9ChannelAssignment(channel: 8, role: .reset, description: "Reset Out"),
            ]
            
        case .hybridDAW:
            return [
                ES9ChannelAssignment(channel: 1, role: .pitch, description: "To Eurorack"),
                ES9ChannelAssignment(channel: 2, role: .gate, description: "To Eurorack"),
                ES9ChannelAssignment(channel: 3, role: .modulation, description: "LFO Out"),
                ES9ChannelAssignment(channel: 4, role: .modulation, description: "Env Out"),
                ES9ChannelAssignment(channel: 5, role: .clock, description: "Clock to Modular"),
                ES9ChannelAssignment(channel: 6, role: .reset, description: "Reset to Modular"),
                ES9ChannelAssignment(channel: 7, role: .modulation, description: "Automation CV"),
                ES9ChannelAssignment(channel: 8, role: .modulation, description: "Sidechain CV"),
            ]
            
        case .mpeController:
            return [
                // 4-voice MPE
                ES9ChannelAssignment(channel: 1, role: .pitch, description: "MPE V1 Pitch"),
                ES9ChannelAssignment(channel: 2, role: .pressure, description: "MPE V1 Pressure"),
                ES9ChannelAssignment(channel: 3, role: .pitch, description: "MPE V2 Pitch"),
                ES9ChannelAssignment(channel: 4, role: .pressure, description: "MPE V2 Pressure"),
                ES9ChannelAssignment(channel: 5, role: .pitch, description: "MPE V3 Pitch"),
                ES9ChannelAssignment(channel: 6, role: .pressure, description: "MPE V3 Pressure"),
                ES9ChannelAssignment(channel: 7, role: .pitch, description: "MPE V4 Pitch"),
                ES9ChannelAssignment(channel: 8, role: .pressure, description: "MPE V4 Pressure"),
            ]
        }
    }
}

struct ES9ChannelAssignment {
    var channel: Int
    var role: ChannelRole
    var description: String
    
    enum ChannelRole {
        case pitch, gate, velocity, modWheel, envelope, lfo
        case clock, reset, trigger, accent, modulation
        case pressure, slide
    }
}
```

##### ES-9 + ADAT Expansion
```swift
struct ES9Expansion {
    /// ES-3 via ADAT Out (8 extra CV outputs)
    struct ES3Expansion {
        var enabled: Bool = false
        var adatOutputs: [ES9OutputChannel] = []  // 8 DC-coupled outputs
        
        // ES-3 kräver ADAT från ES-9
        // Vid 96kHz: 4 kanaler (SMUX)
        // Vid 48kHz: 8 kanaler
    }
    
    /// ES-6 via ADAT In (8 extra CV inputs)
    struct ES6Expansion {
        var enabled: Bool = false
        var adatInputs: [ES9InputChannel] = []  // 8 DC-coupled inputs
        
        // ES-6 skickar ADAT till ES-9
        // Ger totalt 4+8 = 12 CV inputs
    }
    
    /// ES-5 (SPDIF expansion för extra channels)
    struct ES5Expansion {
        var enabled: Bool = false
        // ES-5 behöver ES-3 för att fungera (daisy chain)
    }
}

// Med full ES-9 + ES-3 + ES-6 expansion:
// CV Outputs: 8 (ES-9) + 8 (ES-3 via ADAT) = 16 CV outputs
// CV Inputs:  4 (ES-9) + 8 (ES-6 via ADAT) = 12 CV inputs
```

##### ES-9 UI Configuration
```swift
struct ES9ConfigView: View {
    @ObservedObject var es9: ES9Device
    @ObservedObject var cvEngine: CVEngine
    
    var body: some View {
        Form {
            Section("Device Status") {
                HStack {
                    Circle()
                        .fill(es9.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(es9.isConnected ? "ES-9 Connected" : "ES-9 Not Found")
                }
                
                if es9.isConnected {
                    Text("Firmware: \(es9.firmwareVersion)")
                    Text("Serial: \(es9.calibration.deviceSerial)")
                }
            }
            
            Section("Audio Settings") {
                Picker("Sample Rate", selection: $es9.sampleRate) {
                    ForEach(ES9Device.ES9SampleRate.allCases, id: \.self) { rate in
                        Text("\(rate.rawValue / 1000) kHz").tag(rate)
                    }
                }
                
                Picker("Buffer Size", selection: $es9.bufferSize) {
                    ForEach(ES9Device.ES9BufferSize.allCases, id: \.self) { size in
                        let latency = size.latencyMs(at: es9.sampleRate)
                        Text("\(size.rawValue) samples (\(String(format: "%.1f", latency))ms)")
                            .tag(size)
                    }
                }
            }
            
            Section("Preset") {
                Picker("Configuration", selection: $selectedPreset) {
                    ForEach(ES9Preset.allCases, id: \.self) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                
                Button("Apply Preset") {
                    applyPreset(selectedPreset)
                }
            }
            
            Section("CV Outputs (1-8)") {
                ForEach(es9.outputChannels.filter { $0.type == .mainDC }) { channel in
                    ES9ChannelRow(channel: channel)
                }
            }
            
            Section("CV Inputs (1-4)") {
                ForEach(es9.inputChannels.filter { $0.type == .cvDC }) { channel in
                    ES9InputRow(channel: channel)
                }
            }
            
            Section("ADAT Expansion") {
                Toggle("Enable ADAT Output (ES-3)", isOn: $es9.adatOutputEnabled)
                Toggle("Enable ADAT Input (ES-6)", isOn: $es9.adatInputEnabled)
                
                if es9.adatOutputEnabled {
                    Text("ADAT channels at \(es9.sampleRate.adatChannels) ch")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Calibration") {
                NavigationLink("Calibrate Outputs") {
                    ES9CalibrationView(es9: es9, mode: .output)
                }
                NavigationLink("Calibrate Inputs") {
                    ES9CalibrationView(es9: es9, mode: .input)
                }
                
                Button("Reset to Factory Calibration") {
                    es9.calibration = .factory
                }
            }
        }
        .navigationTitle("Expert Sleepers ES-9")
    }
}
```

---

#### 3C.11 Stödda Hardware (Komplett)

| Gränssnitt | CV Out | CV In | ADAT | Protokoll | Latens | Primärt Stöd |
|------------|--------|-------|------|-----------|--------|--------------|
| **Expert Sleepers ES-9** | **8** | **4** | **8+8** | **USB** | **<1ms** | **✅ Full** |
| Expert Sleepers ES-8 | 8 | 4 | - | USB | <1ms | ✅ |
| Expert Sleepers ES-3 | 8 | - | ADAT | ADAT | <2ms | ✅ (via ES-9) |
| Expert Sleepers ES-6 | - | 8 | ADAT | ADAT | <2ms | ✅ (via ES-9) |
| MOTU UltraLite mk5 | 10 | 2 | - | USB | <1ms | ⚠️ |
| MOTU 828es | 28 | 28 | 16 | USB/TB | <1ms | ⚠️ |
| RME Fireface UCX II | 8 | 8 | 8 | USB | <1ms | ⚠️ |
| Befaco VCMC | 8 | - | - | USB MIDI | <3ms | ⚠️ |
| Endorphin.es Shuttle Control | 16 | - | - | USB | <1ms | ⚠️ |
| Intellijel Audio Interface II | 4 | 4 | - | USB | <1ms | ⚠️ |

**Legenda:** ✅ Full integration | ⚠️ Basic support

---

#### 3C.11 Snirklon vs Bitwig vs Ableton (CV-jämförelse)

| Funktion | Snirklon | Bitwig | Ableton |
|----------|----------|--------|---------|
| CV som Audio | ✅ | ✅ | ❌ |
| Sample-accurate CV | ✅ | ✅ | ❌ |
| CV In | ✅ | ✅ | ⚠️ (Max) |
| CV Out | ✅ | ✅ | ⚠️ (Max) |
| HW CV Devices | ✅ | ✅ | ❌ |
| CV Processing (FX) | ✅ | ✅ | ❌ |
| CV Feedback | ✅ | ✅ | ❌ |
| MPE → CV | ✅ | ✅ | ❌ |
| Per-synth Calibration | ✅ | ✅ | ❌ |
| CV Clock | ✅ | ✅ | ❌ |
| Modular Modulators | ✅ | ✅ | ⚠️ |
| CV Routing Matrix | ✅ | ✅ | ❌ |

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

### Sprint 4 (Vecka 7-8): CV/Gate/ADSR System (Grundläggande)
- [ ] CV Engine med CoreAudio (sample-accurate)
- [ ] CV som Audio arkitektur (32-bit float)
- [ ] Pitch CV (1V/okt) med kalibrering
- [ ] Gate/Trigger-generering
- [ ] ADSR Envelope Generator
- [ ] CV Clock Output med divisioner
- [ ] CV LFO-modulatorer (basic)
- [ ] Portamento/Glide
- [ ] Multi-kanal CV output (upp till 16)

### Sprint 4B (Vecka 8-9): HW CV Devices & ES-9 Integration
- [ ] **ES-9 Device Driver** - Auto-detect, USB communication
- [ ] **ES-9 Channel Mapping** - 8 outputs, 4 inputs, ADAT expansion
- [ ] **ES-9 Calibration System** - Per-kanal 1V/oct kalibrering
- [ ] **ES-9 Presets** - Mono Synth, 4-Voice, Drum Machine, Sequencer, MPE
- [ ] **ES-9 ADAT Support** - ES-3 output expansion, ES-6 input expansion
- [ ] **ES-9 Configuration UI** - Sample rate, buffer, channel assignment
- [ ] HWCVInstrument - komplett instrument-interface
- [ ] HWCVClock - analog clock med divisioner/multipliers
- [ ] HWCVOut - generisk CV-utgång med routing
- [ ] HWCVIn - CV-ingång med signal conditioning
- [ ] Per-synth kalibrering (Moog, Behringer, Eurorack)
- [ ] Voltage standard support (V/oct, Hz/V, Oct/V)
- [ ] MPE → CV konvertering (polyfonisk CV)

### Sprint 4C (Vecka 9-10): CV Processing & Modulators
- [ ] CVProcessor base class
- [ ] CVFilter (LP, HP, BP, comb, formant)
- [ ] CVDistortion (soft/hard clip, foldback, waveshaper)
- [ ] CVDelay (tempo-synkad, feedback)
- [ ] CVQuantizer (skala-kvantisering, trigger modes)
- [ ] CVSlew (portamento, anti-click)
- [ ] Utökad CVLFO (chaos, morphing, S&H)
- [ ] CVCurves (freeform, loop, spline)
- [ ] CVRandom (S&H, walk, turing, lorentz)
- [ ] CVSteps (step sequencer modulator)
- [ ] CVSidechain (audio → CV, pitch tracking)

### Sprint 4D (Vecka 10-11): CV Routing & MIDI↔CV
- [ ] CVRoutingMatrix (flexibel patching)
- [ ] CVBus (multiple sources/destinations)
- [ ] CVFeedback (kontrollerade feedback loops)
- [ ] MIDItoCVConverter (note, gate, velocity, CC, pitch bend)
- [ ] CVtoMIDIConverter (CV → MIDI notes, CC)
- [ ] MPEtoCVConverter (full MPE polyfonisk CV)
- [ ] CVClockSystem (master/slave, divisions)
- [ ] Transport CV (start, stop, reset, run)

### Sprint 5 (Vecka 11-12): UI Grund
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

### CV/Gate/Clock-funktioner (grundläggande):

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

### Avancerat CV-system (Bitwig-inspirerat):

26. **CV = Audio** - Sample-accurate 32-bit CV som audio-signaler
27. **HW CV Instrument** - Komplett instrument-interface (pitch, gate, velocity, aftertouch, mod)
28. **HW CV Clock** - Analog clock med divisions, multipliers, swing, transport
29. **HW CV Out** - Generisk CV-utgång med source routing och slew
30. **HW CV In** - CV-ingång med conditioning, quantization, destination routing
31. **Per-synth Calibration** - Kalibreringsprofiler för Moog, Behringer, Eurorack, etc.
32. **Voltage Standards** - 1V/oct, Hz/V, Oct/V support

### CV Processing (CV som Audio):

33. **CV Filter** - LP, HP, BP, notch, comb, formant filter på CV
34. **CV Distortion** - Soft/hard clip, foldback, waveshaper, bitcrush på CV
35. **CV Delay** - Tempo-synkad delay med feedback på CV-signaler
36. **CV Quantizer** - Skala-kvantisering med trigger modes och glide
37. **CV Slew** - Rise/fall slew limiter, track & hold
38. **Audio → CV Processing** - Distortera LFO, komprimera envelope, delay pitch-CV

### CV Modulators (Powerhouse):

39. **Advanced LFO** - Chaos (Lorenz), morphing, custom wavetable, rate mod
40. **CV Curves** - Freeform kurvor med loop, spline interpolation
41. **CV Random** - S&H, smooth random, walk, turing machine, probability
42. **CV Steps** - Step sequencer som modulator med interpolation
43. **CV Sidechain** - Audio → CV envelope follower, pitch tracker, transient detector
44. **Modulation Matrix** - Flexibel routing med depth och curve per destination

### MIDI ↔ CV Konvertering:

45. **MIDI → CV** - Note, velocity, aftertouch, CC, pitch bend till CV
46. **CV → MIDI** - CV pitch/gate/velocity till MIDI notes och CC
47. **MPE → CV** - Full MPE polyfonisk CV (pitch, gate, pressure, slide per röst)
48. **CC Mapping** - Valfri CC till/från CV med curve och range

### CV Routing & Patching:

49. **CV Routing Matrix** - Flexibel source → destination patching
50. **CV Busses** - Multiple sources/destinations med mix modes (sum, max, multiply)
51. **CV Feedback** - Kontrollerade feedback loops med delay och damping
52. **CV-driven FX** - CV styr automation, wet/dry, routing
53. **CV Performance** - CV-baserad live performance automation

### CV Clock & Transport:

54. **CV Clock System** - Master/slave med multiple outputs
55. **Clock Divisions** - Oberoende division per utgång
56. **Transport CV** - Start, stop, reset, run som CV-signaler
57. **Swing via CV** - CV-styrd swing amount
58. **External Clock Sync** - CV clock input med threshold och PPQN

### Avancerade CV Use Cases:

59. **Polyfonisk CV** - MPE → 4-8 röster med individuell CV per röst
60. **Hybrid Modular+DAW** - Eurorack LFO → DAW automation, DAW env → Eurorack
61. **CV Generativ Musik** - Chaos-baserad sequencing, Turing patterns
62. **CV Feedback Loops** - Självmodulerande system, complex oscillation

### Expert Sleepers ES-9 Integration (Primärt stöd):

63. **ES-9 Auto-detect** - Automatisk identifiering av ES-9 via USB
64. **ES-9 8 CV Outputs** - Full DC-kopplade ±10V utgångar
65. **ES-9 4 CV Inputs** - DC-kopplade ingångar med signal conditioning
66. **ES-9 ADAT Expansion** - Stöd för ES-3 (8 ut) och ES-6 (8 in) via ADAT
67. **ES-9 Calibration** - Per-kanal kalibrering med 1V/oct precision
68. **ES-9 Presets** - Mono Synth, 4-Voice Poly, Drum Machine, Modular Sequencer, MPE
69. **ES-9 Low Latency** - 64 samples @ 48kHz = ~1.3ms latens
70. **ES-9 iOS/macOS** - Full Class Compliant USB-stöd för båda plattformar

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
