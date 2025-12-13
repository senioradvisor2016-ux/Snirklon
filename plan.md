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

## Fas 3B: CV/Gate/ADSR Output & Analog Clock

### 3B.1 Översikt - CV Output System

CV-utmatning sker via DC-kopplade ljudgränssnitt (t.ex. Expert Sleepers, MOTU, RME) som kan mata ut kontrollspänningar istället för ljudsignaler.

#### Stödda Gränssnitt
- **Expert Sleepers ES-8/ES-9** - 8+ CV-utgångar via USB
- **MOTU UltraLite/828** - DC-kopplad utgång
- **RME Fireface** - DC-kopplad utgång
- **iConnectivity mio** - MIDI till CV
- **Virtuella CV** - För mjukvarumodulärer (VCV Rack, etc.)

### 3B.2 CV Engine (Core/CV/)

#### CVEngine.swift
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

#### CVOutput.swift
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

### 3B.3 CV Track Model

#### CVTrack.swift
```swift
struct CVTrack {
    var id: UUID
    var name: String
    var steps: [CVStep]
    var length: Int
    
    // Output-tilldelning
    var pitchOutput: CVOutput?
    var gateOutput: CVOutput?
    var velocityOutput: CVOutput?
    var modOutputs: [CVOutput]         // Ytterligare mod-utgångar
    
    // Spårinställningar
    var transpose: Int                  // Halvtoner
    var portamento: Double              // Glide-tid i ms
    var portamentoMode: PortamentoMode  // .always, .legato, .off
    var gateMode: GateMode
    var octaveRange: Int                // 1-10 oktaver
    
    // Kvantisering
    var quantizeToScale: Bool
    var scale: Scale?
}

enum GateMode {
    case trigger                        // Kort puls
    case gate                           // Full gate-längd
    case hold                           // Håll tills nästa not
}

enum PortamentoMode {
    case off
    case always                         // Alltid glide
    case legato                         // Endast vid överlappande noter
}
```

#### CVStep.swift
```swift
struct CVStep {
    var enabled: Bool
    var pitch: Double?                  // Volt (-5 till +5)
    var pitchNote: Int?                 // MIDI not (0-127), konverteras till CV
    var gate: Bool
    var gateTime: Double                // 0-100% av steg
    var velocity: Double?               // 0-1.0 (mappat till CV)
    var slide: Bool                     // Portamento till detta steg
    var accent: Bool
    
    // Extra CV-värden per steg
    var modValues: [UUID: Double]       // Mod output ID -> värde
    
    // Timing
    var microTiming: Int                // -96 till +96 ticks
    var probability: Int                // 0-100%
    var condition: StepCondition
    var ratchet: Ratchet?
}
```

### 3B.4 ADSR Envelope Generator

#### ADSREnvelope.swift
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

#### ADSRBank.swift
```swift
class ADSRBank: ObservableObject {
    // Multipla ADSR-generatorer (upp till 8)
    @Published var envelopes: [ADSREnvelope] = []
    
    // Globala inställningar
    @Published var masterTimeScale: Double = 1.0  // Skala alla tider
    
    // Polyfoni-hantering
    var voiceAllocation: VoiceAllocation = .roundRobin
    
    func addEnvelope() -> ADSREnvelope
    func removeEnvelope(_ id: UUID)
    
    // Trigger alla eller specifik
    func triggerAll(velocity: Double, note: Int)
    func trigger(_ id: UUID, velocity: Double, note: Int)
    func releaseAll()
    
    // Process all envelopes
    func process(sampleRate: Double) -> [UUID: Double]
}

enum VoiceAllocation {
    case roundRobin
    case lowestNote
    case highestNote
    case lastPlayed
}
```

### 3B.5 Clock Output System

#### ClockOutput.swift
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

#### ClockOutputBank.swift
```swift
class ClockOutputBank: ObservableObject {
    // Multipla klockutgångar (upp till 8)
    @Published var clockOutputs: [ClockOutput] = []
    
    // Reset-utgång
    @Published var resetOutput: CVOutput?
    @Published var resetOnPatternStart: Bool = true
    @Published var resetPulseWidth: Double = 10  // ms
    
    // Run/Stop-utgång
    @Published var runOutput: CVOutput?
    
    // Master clock
    var isRunning: Bool = false
    var currentTick: Int = 0
    
    func addClockOutput() -> ClockOutput
    func removeClockOutput(_ id: UUID)
    
    // Process all clocks
    func process(tick: Int, sampleRate: Double) -> [UUID: Double]
    
    // Transport
    func start()
    func stop()
    func reset()
}
```

### 3B.6 CV/Gate Processor

#### CVGateProcessor.swift
```swift
class CVGateProcessor {
    // Pitch CV-konvertering
    func noteToPitchCV(_ midiNote: Int, calibration: CVCalibration) -> Double {
        // 1V/oktav standard
        // C0 (MIDI 24) = 0V typiskt
        let octavesFromC0 = Double(midiNote - 24) / 12.0
        return calibration.c0Voltage + (octavesFromC0 * calibration.octaveScaling)
    }
    
    // Portamento/Glide
    func calculateGlide(
        from: Double,
        to: Double,
        progress: Double,
        curve: GlideCurve
    ) -> Double
    
    // Gate-generering
    func generateGate(
        gateOn: Bool,
        gateTime: Double,
        stepDuration: Double,
        sampleRate: Double
    ) -> [Double]
    
    // Trigger-generering (kort puls)
    func generateTrigger(pulseWidth: Double, sampleRate: Double) -> [Double]
}

enum GlideCurve {
    case linear
    case exponential
    case logarithmic
    case constant               // Konstant tid oberoende av intervall
    case proportional           // Tid proportionell mot intervall
}
```

### 3B.7 LFO för CV

#### CVLFO.swift
```swift
class CVLFO: ObservableObject {
    var id: UUID
    var name: String
    
    // LFO-parametrar
    @Published var shape: LFOShape
    @Published var rate: Double              // Hz (0.01 - 100 Hz)
    @Published var syncToTempo: Bool
    @Published var tempoDiv: ClockDivision
    @Published var depth: Double             // 0-100%
    @Published var offset: Double            // DC offset -5V till +5V
    @Published var bipolar: Bool             // +/- eller endast +
    @Published var phase: Double             // 0-360°
    @Published var retrigger: Bool           // Retrigga vid gate
    
    // Output
    var cvOutput: CVOutput?
    
    // Tillstånd
    private var currentPhase: Double = 0.0
    
    // Process
    func process(sampleRate: Double) -> Double
    func trigger()
    func reset()
}

enum LFOShape {
    case sine
    case triangle
    case saw
    case ramp
    case square
    case pulse(width: Double)    // PWM 1-99%
    case random                  // Sample & Hold
    case smoothRandom            // Slumpmässig med interpolering
    case custom([Double])        // Wavetable
}
```

### 3B.8 CV Output Configuration UI

#### CVConfigView.swift
```swift
struct CVConfigView: View {
    @ObservedObject var cvEngine: CVEngine
    
    var body: some View {
        Form {
            Section("Audio Interface") {
                Picker("Output Device", selection: $cvEngine.outputDevice) {
                    ForEach(availableDevices) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                
                Picker("Sample Rate", selection: $cvEngine.sampleRate) {
                    Text("44.1 kHz").tag(44100.0)
                    Text("48 kHz").tag(48000.0)
                    Text("96 kHz").tag(96000.0)
                }
                
                Picker("Buffer Size", selection: $cvEngine.bufferSize) {
                    Text("32 samples").tag(32)
                    Text("64 samples").tag(64)
                    Text("128 samples").tag(128)
                    Text("256 samples").tag(256)
                }
            }
            
            Section("CV Outputs") {
                ForEach($cvEngine.cvOutputs) { $output in
                    CVOutputRow(output: $output)
                }
                
                Button("Add CV Output") {
                    cvEngine.addOutput()
                }
            }
            
            Section("Calibration") {
                NavigationLink("Calibrate Outputs") {
                    CVCalibrationView(cvEngine: cvEngine)
                }
            }
        }
    }
}
```

#### CVCalibrationView.swift
```swift
struct CVCalibrationView: View {
    @ObservedObject var cvEngine: CVEngine
    @State var selectedOutput: CVOutput?
    @State var testVoltage: Double = 0.0
    
    var body: some View {
        VStack {
            // Output-val
            Picker("Output", selection: $selectedOutput) {
                ForEach(cvEngine.cvOutputs) { output in
                    Text(output.name).tag(output as CVOutput?)
                }
            }
            
            if let output = selectedOutput {
                // Kalibreringsverktyg
                Section("Test Output") {
                    Slider(value: $testVoltage, in: -5...5, step: 0.01) {
                        Text("Test Voltage: \(testVoltage, specifier: "%.2f")V")
                    }
                    
                    Button("Send Test Voltage") {
                        cvEngine.sendTestVoltage(output.id, voltage: testVoltage)
                    }
                }
                
                Section("1V/Oct Calibration") {
                    VStack(alignment: .leading) {
                        Text("1. Set your tuner/oscillator to C2")
                        Button("Calibrate C2 (0V)") {
                            calibrateNote(note: 36, expectedVoltage: 0)
                        }
                        
                        Text("2. Check C3 (should be +1V)")
                        Button("Calibrate C3 (+1V)") {
                            calibrateNote(note: 48, expectedVoltage: 1)
                        }
                        
                        Text("3. Check C4 (should be +2V)")
                        Button("Calibrate C4 (+2V)") {
                            calibrateNote(note: 60, expectedVoltage: 2)
                        }
                    }
                }
                
                Section("Offset & Scale") {
                    HStack {
                        Text("Offset")
                        Slider(value: Binding(
                            get: { output.calibration.offset },
                            set: { updateCalibration(offset: $0) }
                        ), in: -1...1)
                    }
                    
                    HStack {
                        Text("Scale")
                        Slider(value: Binding(
                            get: { output.calibration.octaveScaling },
                            set: { updateCalibration(scale: $0) }
                        ), in: 0.9...1.1)
                    }
                }
            }
        }
    }
}
```

### 3B.9 CV Track Editor

#### CVTrackEditorView.swift
```swift
struct CVTrackEditorView: View {
    @Binding var track: CVTrack
    @ObservedObject var cvEngine: CVEngine
    
    var body: some View {
        VStack {
            // Output Assignment
            Section("Outputs") {
                Picker("Pitch CV", selection: $track.pitchOutput) {
                    Text("None").tag(nil as CVOutput?)
                    ForEach(cvEngine.cvOutputs.filter { $0.type == .pitch }) { output in
                        Text(output.name).tag(output as CVOutput?)
                    }
                }
                
                Picker("Gate", selection: $track.gateOutput) {
                    Text("None").tag(nil as CVOutput?)
                    ForEach(cvEngine.cvOutputs.filter { $0.type == .gate }) { output in
                        Text(output.name).tag(output as CVOutput?)
                    }
                }
                
                Picker("Velocity CV", selection: $track.velocityOutput) {
                    Text("None").tag(nil as CVOutput?)
                    ForEach(cvEngine.cvOutputs.filter { $0.type == .velocity }) { output in
                        Text(output.name).tag(output as CVOutput?)
                    }
                }
            }
            
            // Track Settings
            Section("Settings") {
                Stepper("Transpose: \(track.transpose)", value: $track.transpose, in: -48...48)
                
                HStack {
                    Text("Portamento")
                    Slider(value: $track.portamento, in: 0...2000) // ms
                    Text("\(Int(track.portamento))ms")
                }
                
                Picker("Portamento Mode", selection: $track.portamentoMode) {
                    Text("Off").tag(PortamentoMode.off)
                    Text("Always").tag(PortamentoMode.always)
                    Text("Legato").tag(PortamentoMode.legato)
                }
                
                Picker("Gate Mode", selection: $track.gateMode) {
                    Text("Trigger").tag(GateMode.trigger)
                    Text("Gate").tag(GateMode.gate)
                    Text("Hold").tag(GateMode.hold)
                }
            }
            
            // Step Grid
            CVStepGridView(track: $track)
        }
    }
}
```

### 3B.10 Komplett CV Output Processor

#### CVOutputProcessor.swift
```swift
class CVOutputProcessor {
    private var cvEngine: CVEngine
    private var adsrBank: ADSRBank
    private var lfoBank: [CVLFO]
    private var clockBank: ClockOutputBank
    
    // Audio buffer
    private var outputBuffer: [[Float]] = []  // Per kanal
    
    // Process alla CV-källor och rendera till audio buffer
    func process(
        tracks: [CVTrack],
        currentTick: Int,
        samplesPerTick: Int,
        sampleRate: Double
    ) {
        // Rensa buffer
        clearBuffer()
        
        // Process varje spår
        for track in tracks {
            processCVTrack(track, tick: currentTick, samplesPerTick: samplesPerTick)
        }
        
        // Process ADSR-envelopes
        let envelopeValues = adsrBank.process(sampleRate: sampleRate)
        for (id, value) in envelopeValues {
            if let output = findOutputForEnvelope(id) {
                addToBuffer(channel: output.audioChannel, value: Float(value))
            }
        }
        
        // Process LFOs
        for lfo in lfoBank {
            if let output = lfo.cvOutput {
                let value = lfo.process(sampleRate: sampleRate)
                addToBuffer(channel: output.audioChannel, value: Float(value))
            }
        }
        
        // Process klockutgångar
        let clockValues = clockBank.process(tick: currentTick, sampleRate: sampleRate)
        for (id, value) in clockValues {
            if let output = findOutputForClock(id) {
                addToBuffer(channel: output.audioChannel, value: Float(value))
            }
        }
    }
    
    private func processCVTrack(_ track: CVTrack, tick: Int, samplesPerTick: Int) {
        // Beräkna aktuellt steg
        let stepIndex = (tick / 24) % track.length  // 24 ticks per 16th note
        let step = track.steps[stepIndex]
        
        guard step.enabled else { return }
        
        // Pitch CV
        if let pitchOutput = track.pitchOutput, let note = step.pitchNote {
            var pitchCV = noteToPitchCV(note + track.transpose, calibration: pitchOutput.calibration)
            
            // Portamento
            if step.slide && track.portamento > 0 {
                pitchCV = applyPortamento(from: previousPitch, to: pitchCV, time: track.portamento)
            }
            
            addToBuffer(channel: pitchOutput.audioChannel, value: Float(pitchCV))
        }
        
        // Gate
        if let gateOutput = track.gateOutput, step.gate {
            let gateValue = generateGateSignal(
                gateTime: step.gateTime,
                mode: track.gateMode,
                samplesPerTick: samplesPerTick
            )
            addToBuffer(channel: gateOutput.audioChannel, value: Float(gateValue))
        }
        
        // Velocity CV
        if let velocityOutput = track.velocityOutput, let velocity = step.velocity {
            addToBuffer(channel: velocityOutput.audioChannel, value: Float(velocity))
        }
    }
}
```

### 3B.11 Supported Hardware Matrix

| Gränssnitt | CV-utgångar | Gate | Clock | ADSR | Anslutning |
|------------|-------------|------|-------|------|------------|
| Expert Sleepers ES-8 | 8 | ✓ | ✓ | ✓ | USB |
| Expert Sleepers ES-9 | 16 | ✓ | ✓ | ✓ | USB |
| Expert Sleepers ES-3 | 8 | ✓ | ✓ | ✓ | ADAT |
| MOTU UltraLite mk5 | 10 | ✓ | ✓ | ✓ | USB |
| MOTU 828es | 28 | ✓ | ✓ | ✓ | USB/TB |
| RME Fireface UCX II | 8 | ✓ | ✓ | ✓ | USB |
| Befaco VCMC | 8 | ✓ | ✓ | - | USB MIDI |
| Endorphin.es Shuttle Control | 16 | ✓ | ✓ | - | USB |

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

// CVEngineTests.swift
class CVEngineTests: XCTestCase {
    func testPitchCVConversion()
    func testGateGeneration()
    func testPortamento()
    func testClockDivisions()
    func testCalibration()
}

// ADSRTests.swift
class ADSRTests: XCTestCase {
    func testAttackPhase()
    func testDecayPhase()
    func testSustainLevel()
    func testReleasePhase()
    func testRetrigger()
    func testVelocitySensitivity()
    func testEnvelopeCurves()
}

// ClockOutputTests.swift
class ClockOutputTests: XCTestCase {
    func testClockDivisions()
    func testClockMultiplication()
    func testSwing()
    func testPhaseOffset()
    func testResetPulse()
}

// CVLFOTests.swift
class CVLFOTests: XCTestCase {
    func testLFOShapes()
    func testTempoSync()
    func testRetrigger()
    func testBipolarUnipolar()
}
```

### 9.2 Integration Tests

```swift
class IntegrationTests: XCTestCase {
    func testFullPatternPlayback()
    func testLinkSync()
    func testMIDISync()
    func testCVSync()
    func testMIDIAndCVTogether()
    func testADSRWithSequencer()
    func testClockOutputSync()
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
