# 🛠️ Konkreta Kodförbättringar att Implementera

## Snabba vinster (kan göras direkt)

### 1. Lägg till Codable till modeller för export/import

```swift
// StepModel.swift - lägg till Codable
struct StepModel: Identifiable, Equatable, Codable {
    // ... befintlig kod ...
}

// TrackModel.swift  
struct TrackModel: Identifiable, Equatable, Codable {
    // Obs: Color är inte Codable, lös med:
    var colorHex: String // Spara färg som hex
    
    var color: SwiftUI.Color {
        Color(hex: colorHex)
    }
}

// PatternModel.swift
struct PatternModel: Identifiable, Equatable, Codable {
    // ... redan Codable-kompatibel
}
```

### 2. Förbättra Timer-hantering (undvik minnesläcka)

```swift
// SequencerStore.swift - nuvarande implementation
private func startPlaybackTimer() {
    let interval = 60.0 / Double(bpm) / 4.0
    playbackTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
        Task { @MainActor in
            self?.advanceStep()
        }
    }
}

// FÖRBÄTTRAD: Använd Combine för bättre precision och kontroll
import Combine

private var playbackCancellable: AnyCancellable?

private func startPlaybackTimer() {
    let interval = 60.0 / Double(bpm) / 4.0
    
    playbackCancellable = Timer.publish(every: interval, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
            self?.advanceStep()
        }
}

private func stopPlaybackTimer() {
    playbackCancellable?.cancel()
    playbackCancellable = nil
}
```

### 3. Lägg till validering i StepModel

```swift
// StepModel.swift
struct StepModel: Identifiable, Equatable, Codable {
    // ... befintliga properties ...
    
    // Lägg till computed properties för validerade värden
    var validatedVelocity: Int {
        max(1, min(127, velocity))
    }
    
    var validatedNote: Int {
        max(0, min(127, note))
    }
    
    var validatedLength: Int {
        max(1, min(96, length))
    }
    
    // Lägg till note name helper
    var noteName: String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = (note / 12) - 1
        return "\(notes[note % 12])\(octave)"
    }
    
    // Lägg till velocity description
    var velocityDescription: String {
        switch velocity {
        case 1...31: return "pp"
        case 32...63: return "p"
        case 64...95: return "mf"
        case 96...111: return "f"
        case 112...127: return "ff"
        default: return "-"
        }
    }
}
```

### 4. Extrahera repetitiv store-logik till helpers

```swift
// SequencerStore.swift - lägg till private helpers

// FÖRE: Repetitiv kod i varje funktion
func toggleStep(_ stepID: UUID) {
    guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
          let trackID = selection.selectedTrackID,
          let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
          let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
    
    patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn.toggle()
}

// EFTER: Extrahera till helper
private struct StepLocation {
    let patternIdx: Int
    let trackIdx: Int
    let stepIdx: Int
}

private func findStep(_ stepID: UUID) -> StepLocation? {
    guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
          let trackID = selection.selectedTrackID,
          let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
          let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID })
    else { return nil }
    
    return StepLocation(patternIdx: patternIdx, trackIdx: trackIdx, stepIdx: stepIdx)
}

// Sedan kan alla step-funktioner förenklas:
func toggleStep(_ stepID: UUID) {
    guard let loc = findStep(stepID) else { return }
    patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].isOn.toggle()
}

func adjustVelocity(for stepID: UUID, delta: Int) {
    guard let loc = findStep(stepID) else { return }
    patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].adjustVelocity(by: delta)
}

// Även för tracks:
private func findTrack(_ trackID: UUID) -> (patternIdx: Int, trackIdx: Int)? {
    guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
          let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID })
    else { return nil }
    
    return (patternIdx, trackIdx)
}
```

### 5. Lägg till batch-uppdatering för multi-selection

```swift
// SequencerStore.swift
func toggleSteps(_ stepIDs: Set<UUID>) {
    for stepID in stepIDs {
        guard let loc = findStep(stepID) else { continue }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].isOn.toggle()
    }
}

func setVelocityForSelection(_ velocity: Int) {
    for stepID in selection.selectedStepIDs {
        guard let loc = findStep(stepID) else { continue }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].velocity = max(1, min(127, velocity))
    }
}

func setNoteForSelection(_ note: Int) {
    for stepID in selection.selectedStepIDs {
        guard let loc = findStep(stepID) else { continue }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].note = max(0, min(127, note))
    }
}
```

---

## Nya funktioner att lägga till

### 6. Pattern Copy/Paste

```swift
// SequencerStore.swift
@Published var copiedPattern: PatternModel?
@Published var copiedTrack: TrackModel?
@Published var copiedSteps: [StepModel] = []

func copyPattern() {
    copiedPattern = currentPattern
}

func pastePattern(to index: Int) {
    guard let pattern = copiedPattern, index < patterns.count else { return }
    var newPattern = pattern
    newPattern.id = UUID()
    newPattern.index = index
    newPattern.name = "P\(index + 1)"
    patterns[index] = newPattern
}

func copySelectedSteps() {
    guard let trackID = selection.selectedTrackID,
          let track = selectedTrack else { return }
    
    copiedSteps = selection.selectedStepIDs.compactMap { stepID in
        track.steps.first { $0.id == stepID }
    }
}

func pasteSteps(startingAt index: Int) {
    guard let loc = findTrack(selection.selectedTrackID ?? UUID()),
          !copiedSteps.isEmpty else { return }
    
    for (offset, step) in copiedSteps.enumerated() {
        let targetIndex = index + offset
        guard targetIndex < patterns[loc.patternIdx].tracks[loc.trackIdx].steps.count else { break }
        
        var newStep = step
        newStep.id = UUID()
        newStep.index = targetIndex
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[targetIndex] = newStep
    }
}
```

### 7. Euclidean Pattern Generator

```swift
// Lägg till i ny fil: Utils/EuclideanGenerator.swift
struct EuclideanGenerator {
    /// Genererar ett euclidean rhythm mönster
    /// - Parameters:
    ///   - steps: Totalt antal steg
    ///   - pulses: Antal aktiva steg
    ///   - rotation: Rotation offset
    /// - Returns: Array av booleans där true = aktiv
    static func generate(steps: Int, pulses: Int, rotation: Int = 0) -> [Bool] {
        guard steps > 0, pulses > 0, pulses <= steps else {
            return Array(repeating: false, count: max(0, steps))
        }
        
        var pattern: [Bool] = []
        var bucket = 0
        
        for _ in 0..<steps {
            bucket += pulses
            if bucket >= steps {
                bucket -= steps
                pattern.append(true)
            } else {
                pattern.append(false)
            }
        }
        
        // Applicera rotation
        let rot = rotation % steps
        if rot != 0 {
            let rotated = Array(pattern.suffix(from: rot)) + Array(pattern.prefix(rot))
            return rotated
        }
        
        return pattern
    }
}

// SequencerStore.swift
func applyEuclidean(steps: Int, pulses: Int, rotation: Int = 0) {
    guard let loc = findTrack(selection.selectedTrackID ?? UUID()) else { return }
    
    let pattern = EuclideanGenerator.generate(steps: steps, pulses: pulses, rotation: rotation)
    
    for (index, isOn) in pattern.enumerated() {
        guard index < patterns[loc.patternIdx].tracks[loc.trackIdx].steps.count else { break }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[index].isOn = isOn
    }
}
```

### 8. Humanize Function

```swift
// SequencerStore.swift
func humanize(velocityRange: Int = 20, timingRange: Int = 10) {
    guard let loc = findTrack(selection.selectedTrackID ?? UUID()) else { return }
    
    for i in 0..<patterns[loc.patternIdx].tracks[loc.trackIdx].steps.count {
        guard patterns[loc.patternIdx].tracks[loc.trackIdx].steps[i].isOn else { continue }
        
        // Randomize velocity
        let velocityDelta = Int.random(in: -velocityRange...velocityRange)
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[i].adjustVelocity(by: velocityDelta)
        
        // Randomize timing
        let timingDelta = Int.random(in: -timingRange...timingRange)
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[i].adjustTiming(by: timingDelta)
    }
}
```

### 9. Step Probability och Ratchet Implementation

```swift
// SequencerStore.swift - utöka advanceStep
private func advanceStep() {
    guard let pattern = currentPattern else { return }
    
    // Process each track
    for (trackIndex, track) in pattern.tracks.enumerated() {
        guard !track.isMuted else { continue }
        
        let step = track.steps[currentStep % track.length]
        guard step.isOn else { continue }
        
        // Check probability
        if step.probability < 100 {
            let roll = Int.random(in: 0...100)
            guard roll <= step.probability else { continue }
        }
        
        // Trigger note (would connect to audio engine)
        triggerNote(
            note: step.note,
            velocity: step.velocity,
            channel: track.midiChannel,
            length: step.length
        )
        
        // Handle ratchet/repeat
        if step.repeat_ > 0 {
            scheduleRatchets(step: step, track: track, count: step.repeat_)
        }
    }
    
    // Advance position
    if let track = selectedTrack {
        currentStep = (currentStep + 1) % track.length
    }
}

private func triggerNote(note: Int, velocity: Int, channel: Int, length: Int) {
    // TODO: Connect to AudioEngine/MIDI
    print("🎵 Note: \(note), Vel: \(velocity), Ch: \(channel)")
}

private func scheduleRatchets(step: StepModel, track: TrackModel, count: Int) {
    let baseInterval = 60.0 / Double(bpm) / 4.0
    let ratchetInterval = baseInterval / Double(count + 1)
    
    for i in 1...count {
        DispatchQueue.main.asyncAfter(deadline: .now() + ratchetInterval * Double(i)) { [weak self] in
            self?.triggerNote(
                note: step.note,
                velocity: Int(Double(step.velocity) * 0.8), // Slightly quieter
                channel: track.midiChannel,
                length: step.length / (count + 1)
            )
        }
    }
}
```

---

## UI-förbättringar

### 10. Lägg till haptic feedback

```swift
// Utils/HapticEngine.swift
import UIKit

enum HapticEngine {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// Användning i StepCellView
.onTapGesture {
    HapticEngine.light()
    onSelect()
    onToggle()
}
```

### 11. Drag-to-paint steps

```swift
// StepGridView.swift
struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    @GestureState private var isDragging = false
    @State private var paintMode: Bool? = nil // nil = not painting, true = turn on, false = turn off
    
    var body: some View {
        // ... existing grid ...
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    handlePaintGesture(at: value.location)
                }
                .onEnded { _ in
                    paintMode = nil
                }
        )
    }
    
    private func handlePaintGesture(at location: CGPoint) {
        // Calculate which step is at this location
        let stepWidth = DS.Size.minTouch + DS.Space.xxs
        let stepHeight = DS.Size.minTouch + DS.Space.s
        
        let stepX = Int(location.x / stepWidth)
        let trackY = Int(location.y / stepHeight)
        
        guard let pattern = store.currentPattern,
              trackY < pattern.tracks.count,
              stepX < pattern.tracks[trackY].steps.count else { return }
        
        let step = pattern.tracks[trackY].steps[stepX]
        
        // Set paint mode on first contact
        if paintMode == nil {
            paintMode = !step.isOn
        }
        
        // Only change if needed
        if step.isOn != paintMode {
            store.toggleStep(step.id)
            HapticEngine.selection()
        }
    }
}
```

---

## Prestanda

### 12. Memoization för computed properties

```swift
// SequencerStore.swift
// Cache för ofta använda computed properties

private var _cachedSelectedTrack: (id: UUID?, track: TrackModel?)?

var selectedTrack: TrackModel? {
    let trackID = selection.selectedTrackID
    
    // Return cached if valid
    if let cached = _cachedSelectedTrack, cached.id == trackID {
        return cached.track
    }
    
    // Compute and cache
    guard let trackID = trackID,
          let pattern = currentPattern else {
        _cachedSelectedTrack = (nil, nil)
        return nil
    }
    
    let track = pattern.tracks.first { $0.id == trackID }
    _cachedSelectedTrack = (trackID, track)
    return track
}

// Invalidera cache vid ändringar
func selectTrack(_ trackID: UUID) {
    _cachedSelectedTrack = nil  // Invalidera
    selection.selectedTrackID = trackID
    selection.clearSelection()
}
```

### 13. Debounce för snabba uppdateringar

```swift
// Utils/Debouncer.swift
import Combine

class Debouncer {
    private var subject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    
    init(delay: TimeInterval, action: @escaping () -> Void) {
        cancellable = subject
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { _ in action() }
    }
    
    func call() {
        subject.send()
    }
}

// Användning för att undvika för många sparningar
class SequencerStore {
    private lazy var autoSaveDebouncer = Debouncer(delay: 1.0) { [weak self] in
        self?.saveToStorage()
    }
    
    func toggleStep(_ stepID: UUID) {
        // ... toggle logic ...
        autoSaveDebouncer.call() // Sparar max 1 gång per sekund
    }
}
```

---

## Prioriterad implementationsordning

1. **Helper-funktioner** (#4) - Minskar kod-duplicering direkt
2. **Timer-fix** (#2) - Fixar potentiell minnesläcka
3. **Codable** (#1) - Möjliggör export/import
4. **Copy/Paste** (#6) - Efterfrågad användarfunktion
5. **Euclidean** (#7) - Kreativ funktionalitet
6. **Drag-to-paint** (#11) - Förbättrad workflow
7. **Haptics** (#10) - Bättre feedback
8. **Humanize** (#8) - Kreativ funktion
9. **Ratchet** (#9) - Avancerad funktion
10. **Prestanda** (#12, #13) - När appen växer
