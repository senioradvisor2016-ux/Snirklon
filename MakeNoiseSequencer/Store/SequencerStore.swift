import SwiftUI
import Combine

@MainActor
class SequencerStore: ObservableObject {
    // MARK: - Transport State
    @Published var isPlaying: Bool = false
    @Published var bpm: Int = 120
    @Published var swing: Int = 50  // 50 = no swing, 0-100 range
    @Published var currentStep: Int = 0
    
    // MARK: - Pattern State
    @Published var patterns: [PatternModel] = []
    @Published var currentPatternIndex: Int = 0
    
    // MARK: - Selection State
    @Published var selection: SelectionModel = SelectionModel()
    
    // MARK: - Audio Interface / CV Output State
    @Published var selectedInterface: AudioInterfaceModel = .es9
    @Published var cvOutputConfigs: [CVOutputConfig] = []
    @Published var cvTracks: [CVTrack] = []
    @Published var selectedCVTrackID: UUID? = nil
    @Published var showSettings: Bool = false
    
    // MARK: - Help & Onboarding State
    @Published var showHelp: Bool = false
    @Published var showOnboarding: Bool = false
    @Published var hasSeenOnboarding: Bool = false
    @Published var tooltipsEnabled: Bool = true
    
    // MARK: - Additional Panels
    @Published var showExportDialog: Bool = false
    @Published var showPresetBrowser: Bool = false
    @Published var showMIDILearn: Bool = false
    @Published var showTutorials: Bool = false
    @Published var showEuclideanGenerator: Bool = false
    @Published var showWhatsNew: Bool = false
    @Published var showKeyboardShortcuts: Bool = false
    
    // MARK: - Status Indicators
    @Published var isSaving: Bool = false
    @Published var lastSaveTime: Date?
    @Published var hasUnsavedChanges: Bool = false
    
    // MARK: - Clipboard
    @Published var copiedPattern: PatternModel?
    @Published var copiedTrack: TrackModel?
    @Published var copiedSteps: [StepModel] = []
    
    // MARK: - Managers
    let undoManager = UndoManager()
    let presetManager = PresetManager()
    let midiLearnManager = MIDILearnManager()
    let themeManager = ThemeManager()
    let accessibilityManager = AccessibilityManager()
    let tutorialManager = TutorialManager()
    let exportManager = ExportManager()
    let cloudSyncManager = CloudSyncManager()
    let modeManager = UserModeManager()
    let toastManager = ToastManager()
    let confirmationManager = ConfirmationManager()
    let errorManager = ErrorManager()
    
    // MARK: - Mode Convenience
    
    /// Current feature visibility based on mode
    var features: ModeFeatures {
        modeManager.features
    }
    
    /// Whether in advanced mode
    var isAdvancedMode: Bool {
        modeManager.isAdvanced
    }
    
    // MARK: - Playback Engine
    private var playbackCancellable: AnyCancellable?
    private var playbackTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var autoSaveDebouncer: Debouncer?
    
    // MARK: - Haptic Settings
    var hapticsEnabled: Bool = true
    
    init() {
        setupInitialPatterns()
        checkFirstLaunch()
        setupAutoSave()
    }
    
    private func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            showOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    private func setupAutoSave() {
        autoSaveDebouncer = Debouncer(delay: 2.0) { [weak self] in
            self?.saveState()
        }
    }
    
    // MARK: - Setup
    
    private func setupInitialPatterns() {
        // Create 4 patterns with default content
        patterns = (0..<4).map { PatternModel.createDefault(index: $0) }
        
        // Select first track by default
        if let firstTrack = currentPattern?.tracks.first {
            selection.selectedTrackID = firstTrack.id
        }
    }
    
    // MARK: - Computed Properties
    
    var currentPattern: PatternModel? {
        guard currentPatternIndex < patterns.count else { return nil }
        return patterns[currentPatternIndex]
    }
    
    var selectedTrack: TrackModel? {
        guard let trackID = selection.selectedTrackID,
              let pattern = currentPattern else { return nil }
        return pattern.tracks.first { $0.id == trackID }
    }
    
    var selectedStep: StepModel? {
        guard selection.singleStepSelected,
              let stepID = selection.selectedStepIDs.first,
              let track = selectedTrack else { return nil }
        return track.steps.first { $0.id == stepID }
    }
    
    var playingStepID: UUID? {
        guard isPlaying,
              let track = selectedTrack,
              currentStep < track.steps.count else { return nil }
        return track.steps[currentStep].id
    }
    
    /// Swing offset in seconds for the current step
    var swingOffset: TimeInterval {
        guard currentStep % 2 == 1 else { return 0 }
        let swingAmount = Double(swing - 50) / 100.0  // -0.5 to 0.5
        let stepDuration = 60.0 / Double(bpm) / 4.0
        return stepDuration * swingAmount * 0.5
    }
    
    // MARK: - Location Helpers (Reduce Code Duplication)
    
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
    
    private func findStepInTrack(_ stepID: UUID, trackID: UUID) -> StepLocation? {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID })
        else { return nil }
        
        return StepLocation(patternIdx: patternIdx, trackIdx: trackIdx, stepIdx: stepIdx)
    }
    
    private func findTrack(_ trackID: UUID) -> (patternIdx: Int, trackIdx: Int)? {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID })
        else { return nil }
        
        return (patternIdx, trackIdx)
    }
    
    // MARK: - Transport Actions
    
    func play() {
        isPlaying = true
        startPlaybackTimer()
        triggerHaptic(.medium)
    }
    
    func stop() {
        isPlaying = false
        stopPlaybackTimer()
        cancelRatchets()
        currentStep = 0
        triggerHaptic(.medium)
    }
    
    func togglePlayback() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }
    
    func setBPM(_ newBPM: Int) {
        bpm = max(20, min(300, newBPM))
        if isPlaying {
            restartPlaybackTimer()
        }
        scheduleAutoSave()
    }
    
    func setSwing(_ newSwing: Int) {
        swing = max(0, min(100, newSwing))
        scheduleAutoSave()
    }
    
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        
        playbackTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                
                let interval = 60.0 / Double(self.bpm) / 4.0  // 16th notes
                let nanoseconds = UInt64(interval * 1_000_000_000)
                
                try? await Task.sleep(nanoseconds: nanoseconds)
                
                guard !Task.isCancelled else { break }
                
                await MainActor.run { [weak self] in
                    self?.advanceStep()
                }
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTask?.cancel()
        playbackTask = nil
        playbackCancellable?.cancel()
        playbackCancellable = nil
    }
    
    private func restartPlaybackTimer() {
        stopPlaybackTimer()
        if isPlaying {
            startPlaybackTimer()
        }
    }
    
    private func advanceStep() {
        guard let pattern = currentPattern else { return }
        
        // Process each track for note triggers
        for (trackIndex, track) in pattern.tracks.enumerated() {
            guard !track.isMuted else { continue }
            
            let stepIndex = currentStep % track.length
            let step = track.steps[stepIndex]
            
            guard step.isOn else { continue }
            
            // Check probability
            if step.probability < 100 {
                let roll = Int.random(in: 0...100)
                guard roll <= step.probability else { continue }
            }
            
            // Trigger note
            triggerNote(
                note: step.note,
                velocity: step.velocity,
                channel: track.midiChannel,
                length: step.length
            )
            
            // Handle ratchet/repeat
            if step.repeat_ > 0 {
                scheduleRatchets(step: step, track: track)
            }
        }
        
        // Provide haptic feedback on beats
        if currentStep % 4 == 0 {
            if currentStep % 16 == 0 {
                triggerHaptic(.downbeat)
            } else {
                triggerHaptic(.beat)
            }
        }
        
        // Advance position
        if let track = selectedTrack {
            currentStep = (currentStep + 1) % track.length
        }
    }
    
    private func triggerNote(note: Int, velocity: Int, channel: Int, length: Int) {
        // TODO: Connect to AudioEngine/MIDI output
        // For now, just log
        #if DEBUG
        print("🎵 Note: \(note), Vel: \(velocity), Ch: \(channel), Len: \(length)")
        #endif
    }
    
    private var ratchetTasks: [Task<Void, Never>] = []
    
    private func scheduleRatchets(step: StepModel, track: TrackModel) {
        let baseInterval = 60.0 / Double(bpm) / 4.0
        let ratchetInterval = baseInterval / Double(step.repeat_ + 1)
        
        for i in 1...step.repeat_ {
            let task = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(ratchetInterval * Double(i) * 1_000_000_000))
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run { [weak self] in
                    guard let self = self, self.isPlaying else { return }
                    self.triggerNote(
                        note: step.note,
                        velocity: Int(Double(step.velocity) * 0.8),
                        channel: track.midiChannel,
                        length: step.length / (step.repeat_ + 1)
                    )
                }
            }
            ratchetTasks.append(task)
        }
    }
    
    private func cancelRatchets() {
        ratchetTasks.forEach { $0.cancel() }
        ratchetTasks.removeAll()
    }
    
    // MARK: - Track Actions
    
    func selectTrack(_ trackID: UUID) {
        selection.selectedTrackID = trackID
        selection.clearSelection()
        triggerHaptic(.selection)
    }
    
    func toggleMute(for trackID: UUID) {
        guard let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        patterns[patternIdx].tracks[trackIdx].isMuted.toggle()
        triggerHaptic(.light)
        scheduleAutoSave()
    }
    
    func toggleSolo(for trackID: UUID) {
        guard let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        patterns[patternIdx].tracks[trackIdx].isSolo.toggle()
        triggerHaptic(.light)
        scheduleAutoSave()
    }
    
    // MARK: - Step Actions
    
    func selectStep(_ stepID: UUID) {
        selection.selectStep(stepID)
        triggerHaptic(.selection)
    }
    
    func toggleStep(_ stepID: UUID) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].isOn.toggle()
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    /// Toggle step at specific index in selected track
    func toggleStepAtIndex(_ index: Int) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID),
              index < patterns[patternIdx].tracks[trackIdx].steps.count else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[index].isOn.toggle()
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    /// Batch toggle multiple steps
    func toggleSteps(_ stepIDs: Set<UUID>) {
        for stepID in stepIDs {
            guard let loc = findStep(stepID) else { continue }
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].isOn.toggle()
        }
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    /// Set step on/off state directly (for paint mode)
    func setStepState(_ stepID: UUID, isOn: Bool) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].isOn = isOn
        scheduleAutoSave()
    }
    
    func adjustVelocity(for stepID: UUID, delta: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].adjustVelocity(by: delta)
        scheduleAutoSave()
    }
    
    func adjustTiming(for stepID: UUID, delta: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].adjustTiming(by: delta)
        scheduleAutoSave()
    }
    
    func setStepNote(_ stepID: UUID, note: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].note = max(0, min(127, note))
        scheduleAutoSave()
    }
    
    func setStepVelocity(_ stepID: UUID, velocity: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].velocity = max(1, min(127, velocity))
        scheduleAutoSave()
    }
    
    func setStepLength(_ stepID: UUID, length: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].length = max(1, min(96, length))
        scheduleAutoSave()
    }
    
    func setStepProbability(_ stepID: UUID, probability: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].probability = max(0, min(100, probability))
        scheduleAutoSave()
    }
    
    func setStepRepeat(_ stepID: UUID, repeatCount: Int) {
        guard let loc = findStep(stepID) else { return }
        patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].repeat_ = max(0, min(8, repeatCount))
        scheduleAutoSave()
    }
    
    // MARK: - Batch Step Operations
    
    func setVelocityForSelection(_ velocity: Int) {
        for stepID in selection.selectedStepIDs {
            guard let loc = findStep(stepID) else { continue }
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].velocity = max(1, min(127, velocity))
        }
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    func setNoteForSelection(_ note: Int) {
        for stepID in selection.selectedStepIDs {
            guard let loc = findStep(stepID) else { continue }
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].note = max(0, min(127, note))
        }
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    func setProbabilityForSelection(_ probability: Int) {
        for stepID in selection.selectedStepIDs {
            guard let loc = findStep(stepID) else { continue }
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].probability = max(0, min(100, probability))
        }
        scheduleAutoSave()
    }
    
    // MARK: - Humanize
    
    func humanize(velocityRange: Int = 20, timingRange: Int = 10) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        
        // Store for undo
        let previousSteps = patterns[patternIdx].tracks[trackIdx].steps
        let trackName = patterns[patternIdx].tracks[trackIdx].name
        var affectedCount = 0
        
        for i in 0..<patterns[patternIdx].tracks[trackIdx].steps.count {
            guard patterns[patternIdx].tracks[trackIdx].steps[i].isOn else { continue }
            
            // Randomize velocity
            let velocityDelta = Int.random(in: -velocityRange...velocityRange)
            patterns[patternIdx].tracks[trackIdx].steps[i].adjustVelocity(by: velocityDelta)
            
            // Randomize timing
            let timingDelta = Int.random(in: -timingRange...timingRange)
            patterns[patternIdx].tracks[trackIdx].steps[i].adjustTiming(by: timingDelta)
            affectedCount += 1
        }
        
        triggerHaptic(.success)
        scheduleAutoSave()
        
        toastManager.undo("Humaniserade \(affectedCount) steg") { [weak self] in
            guard let self = self,
                  let (pIdx, tIdx) = self.findTrack(trackID) else { return }
            self.patterns[pIdx].tracks[tIdx].steps = previousSteps
            self.toastManager.success("Ångrade humanisering")
        }
    }
    
    func humanizeSelection(velocityRange: Int = 20, timingRange: Int = 10) {
        for stepID in selection.selectedStepIDs {
            guard let loc = findStep(stepID) else { continue }
            
            let velocityDelta = Int.random(in: -velocityRange...velocityRange)
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].adjustVelocity(by: velocityDelta)
            
            let timingDelta = Int.random(in: -timingRange...timingRange)
            patterns[loc.patternIdx].tracks[loc.trackIdx].steps[loc.stepIdx].adjustTiming(by: timingDelta)
        }
        
        triggerHaptic(.success)
        scheduleAutoSave()
    }
    
    // MARK: - Euclidean Generator
    
    func applyEuclidean(steps: Int, pulses: Int, rotation: Int = 0) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        
        let pattern = EuclideanGenerator.generate(steps: steps, pulses: pulses, rotation: rotation)
        
        for (index, isOn) in pattern.enumerated() {
            guard index < patterns[patternIdx].tracks[trackIdx].steps.count else { break }
            patterns[patternIdx].tracks[trackIdx].steps[index].isOn = isOn
            if isOn {
                // Add accent on first pulse
                patterns[patternIdx].tracks[trackIdx].steps[index].velocity = index == 0 ? 120 : 100
            }
        }
        
        triggerHaptic(.success)
        scheduleAutoSave()
    }
    
    func applyEuclideanWithVelocity(steps: Int, pulses: Int, rotation: Int = 0, accentEvery: Int = 4) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        
        let velocities = EuclideanGenerator.generateWithVelocity(
            steps: steps,
            pulses: pulses,
            rotation: rotation,
            accentEvery: accentEvery
        )
        
        for (index, velocity) in velocities.enumerated() {
            guard index < patterns[patternIdx].tracks[trackIdx].steps.count else { break }
            if let vel = velocity {
                patterns[patternIdx].tracks[trackIdx].steps[index].isOn = true
                patterns[patternIdx].tracks[trackIdx].steps[index].velocity = vel
            } else {
                patterns[patternIdx].tracks[trackIdx].steps[index].isOn = false
            }
        }
        
        triggerHaptic(.success)
        scheduleAutoSave()
    }
    
    // MARK: - Track Pattern Transformations
    
    func shiftTrackLeft() {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        patterns[patternIdx].tracks[trackIdx].shiftLeft()
        triggerHaptic(.light)
        scheduleAutoSave()
    }
    
    func shiftTrackRight() {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        patterns[patternIdx].tracks[trackIdx].shiftRight()
        triggerHaptic(.light)
        scheduleAutoSave()
    }
    
    func reverseTrack() {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        patterns[patternIdx].tracks[trackIdx].reverse()
        triggerHaptic(.medium)
        scheduleAutoSave()
    }
    
    func clearTrack() {
        confirmationManager.confirmClearTrack { [weak self] in
            self?.performClearTrack()
        }
    }
    
    private func performClearTrack() {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        
        // Store for undo
        let previousSteps = patterns[patternIdx].tracks[trackIdx].steps
        let trackName = patterns[patternIdx].tracks[trackIdx].name
        
        patterns[patternIdx].tracks[trackIdx].clearAllSteps()
        triggerHaptic(.medium)
        scheduleAutoSave()
        
        // Show toast with undo
        toastManager.undo("Spår \(trackName) rensat") { [weak self] in
            guard let self = self,
                  let (pIdx, tIdx) = self.findTrack(trackID) else { return }
            self.patterns[pIdx].tracks[tIdx].steps = previousSteps
            self.toastManager.success("Ångrade rensning")
        }
    }
    
    func fillTrack(velocity: Int = 100) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID) else { return }
        
        let trackName = patterns[patternIdx].tracks[trackIdx].name
        patterns[patternIdx].tracks[trackIdx].fillAllSteps(velocity: velocity)
        triggerHaptic(.medium)
        scheduleAutoSave()
        
        toastManager.success("Spår \(trackName) fyllt")
    }
    
    // MARK: - Copy/Paste
    
    func copyPattern() {
        copiedPattern = currentPattern?.copy()
        triggerHaptic(.success)
        toastManager.success("Mönster kopierat")
    }
    
    func pastePattern(to index: Int) {
        guard let pattern = copiedPattern, index < patterns.count else {
            toastManager.warning("Inget mönster att klistra in")
            return
        }
        var newPattern = pattern.copy()
        newPattern.index = index
        newPattern.name = "P\(index + 1)"
        patterns[index] = newPattern
        triggerHaptic(.success)
        scheduleAutoSave()
        toastManager.success("Mönster inklistrat")
    }
    
    func copyTrack() {
        guard let track = selectedTrack else {
            toastManager.warning("Inget spår valt")
            return
        }
        copiedTrack = track.copy()
        triggerHaptic(.success)
        toastManager.success("Spår \(track.name) kopierat")
    }
    
    func pasteTrack(to trackIndex: Int) {
        guard let track = copiedTrack,
              let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              trackIndex < patterns[patternIdx].tracks.count else {
            toastManager.warning("Inget spår att klistra in")
            return
        }
        
        var newTrack = track.copy()
        newTrack.midiChannel = patterns[patternIdx].tracks[trackIndex].midiChannel
        patterns[patternIdx].tracks[trackIndex] = newTrack
        
        triggerHaptic(.success)
        scheduleAutoSave()
        toastManager.success("Spår inklistrat")
    }
    
    func copySelectedSteps() {
        guard let track = selectedTrack else { return }
        
        copiedSteps = selection.selectedStepIDs.compactMap { stepID in
            track.steps.first { $0.id == stepID }?.copy()
        }.sorted { $0.index < $1.index }
        
        if copiedSteps.isEmpty {
            toastManager.warning("Inga steg valda")
        } else {
            triggerHaptic(.success)
            toastManager.success("\(copiedSteps.count) steg kopierade")
        }
    }
    
    func pasteSteps(startingAt index: Int) {
        guard let trackID = selection.selectedTrackID,
              let (patternIdx, trackIdx) = findTrack(trackID),
              !copiedSteps.isEmpty else {
            toastManager.warning("Inga steg att klistra in")
            return
        }
        
        var pastedCount = 0
        for (offset, step) in copiedSteps.enumerated() {
            let targetIndex = index + offset
            guard targetIndex < patterns[patternIdx].tracks[trackIdx].steps.count else { break }
            
            var newStep = step.copy()
            newStep.index = targetIndex
            patterns[patternIdx].tracks[trackIdx].steps[targetIndex] = newStep
            pastedCount += 1
        }
        
        triggerHaptic(.success)
        scheduleAutoSave()
        toastManager.success("\(pastedCount) steg inklistrade")
    }
    
    // MARK: - Inspector
    
    func openInspector() {
        selection.showInspector = true
    }
    
    func closeInspector() {
        selection.showInspector = false
    }
    
    func toggleInspector() {
        selection.showInspector.toggle()
    }
    
    // MARK: - Pattern Actions
    
    func selectPattern(_ index: Int) {
        guard index >= 0 && index < patterns.count else { return }
        
        // Cache current pattern before switching
        PatternCache.shared.cache(patterns[currentPatternIndex], at: currentPatternIndex)
        
        currentPatternIndex = index
        
        // Preload adjacent patterns in background
        PatternCache.shared.preload(currentIndex: index, patterns: patterns)
        
        // Maintain track selection if possible
        if let trackID = selection.selectedTrackID,
           currentPattern?.tracks.contains(where: { $0.id == trackID }) != true,
           let firstTrack = currentPattern?.tracks.first {
            selection.selectedTrackID = firstTrack.id
        }
        
        selection.clearSelection()
        triggerHaptic(.medium)
    }
    
    func clearPattern() {
        confirmationManager.confirmClearPattern { [weak self] in
            self?.performClearPattern()
        }
    }
    
    private func performClearPattern() {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }) else { return }
        
        // Store for undo
        let previousPattern = patterns[patternIdx]
        let patternName = previousPattern.name
        
        patterns[patternIdx].clearAll()
        triggerHaptic(.heavy)
        scheduleAutoSave()
        
        // Show toast with undo
        toastManager.undo("Mönster \(patternName) rensat") { [weak self] in
            guard let self = self else { return }
            self.patterns[patternIdx] = previousPattern
            self.toastManager.success("Ångrade rensning")
        }
    }
    
    // MARK: - Audio Interface Actions
    
    func selectAudioInterface(_ interface: AudioInterfaceModel) {
        selectedInterface = interface
        setupDefaultCVConfigs()
        scheduleAutoSave()
    }
    
    func toggleSettings() {
        showSettings.toggle()
    }
    
    private func setupDefaultCVConfigs() {
        guard selectedInterface.isDCCoupled else {
            cvOutputConfigs = []
            return
        }
        
        var configs: [CVOutputConfig] = []
        
        if let pattern = currentPattern {
            for (index, track) in pattern.tracks.enumerated() {
                let channelBase = index * 2
                
                if channelBase < selectedInterface.outputCount {
                    configs.append(CVOutputConfig(
                        outputChannel: channelBase + 1,
                        outputType: .pitch,
                        trackID: track.id
                    ))
                }
                
                if channelBase + 1 < selectedInterface.outputCount {
                    configs.append(CVOutputConfig(
                        outputChannel: channelBase + 2,
                        outputType: .gate,
                        trackID: track.id
                    ))
                }
            }
        }
        
        cvOutputConfigs = configs
    }
    
    func updateCVConfig(_ config: CVOutputConfig) {
        if let index = cvOutputConfigs.firstIndex(where: { $0.id == config.id }) {
            cvOutputConfigs[index] = config
        }
        scheduleAutoSave()
    }
    
    func addCVConfig() {
        let nextChannel = (cvOutputConfigs.map { $0.outputChannel }.max() ?? 0) + 1
        guard nextChannel <= selectedInterface.outputCount else { return }
        cvOutputConfigs.append(CVOutputConfig(outputChannel: nextChannel))
        scheduleAutoSave()
    }
    
    func removeCVConfig(_ id: UUID) {
        cvOutputConfigs.removeAll { $0.id == id }
        scheduleAutoSave()
    }
    
    // MARK: - CV Track Actions
    
    func addCVTrack() {
        let nextChannel = (cvTracks.map { $0.outputChannel }.max() ?? 0) + 1
        guard nextChannel <= selectedInterface.outputCount else { return }
        
        let trackNumber = cvTracks.count + 1
        let newTrack = CVTrack(
            name: "ENV \(trackNumber)",
            outputChannel: nextChannel,
            envelope: .percussion,
            sourceTrackID: currentPattern?.tracks.first?.id
        )
        cvTracks.append(newTrack)
        selectedCVTrackID = newTrack.id
        scheduleAutoSave()
    }
    
    func removeCVTrack(_ id: UUID) {
        cvTracks.removeAll { $0.id == id }
        if selectedCVTrackID == id {
            selectedCVTrackID = cvTracks.first?.id
        }
        scheduleAutoSave()
    }
    
    func selectCVTrack(_ id: UUID) {
        selectedCVTrackID = id
    }
    
    var selectedCVTrack: CVTrack? {
        guard let id = selectedCVTrackID else { return nil }
        return cvTracks.first { $0.id == id }
    }
    
    func updateCVTrack(_ track: CVTrack) {
        if let index = cvTracks.firstIndex(where: { $0.id == track.id }) {
            cvTracks[index] = track
        }
        scheduleAutoSave()
    }
    
    func updateCVTrackEnvelope(_ trackID: UUID, envelope: ADSREnvelope) {
        if let index = cvTracks.firstIndex(where: { $0.id == trackID }) {
            cvTracks[index].envelope = envelope
        }
        scheduleAutoSave()
    }
    
    func setCVTrackSource(_ trackID: UUID, sourceTrackID: UUID?) {
        if let index = cvTracks.firstIndex(where: { $0.id == trackID }) {
            cvTracks[index].sourceTrackID = sourceTrackID
        }
        scheduleAutoSave()
    }
    
    func setCVTrackDestination(_ trackID: UUID, destination: ModulationDestination) {
        if let index = cvTracks.firstIndex(where: { $0.id == trackID }) {
            cvTracks[index].modulationDestination = destination
        }
        scheduleAutoSave()
    }
    
    func toggleCVTrackEnabled(_ trackID: UUID) {
        if let index = cvTracks.firstIndex(where: { $0.id == trackID }) {
            cvTracks[index].isEnabled.toggle()
        }
        scheduleAutoSave()
    }
    
    // MARK: - Help Actions
    
    func toggleHelp() {
        showHelp.toggle()
        if showHelp {
            showSettings = false
        }
    }
    
    func showOnboardingGuide() {
        showOnboarding = true
    }
    
    func completeOnboarding() {
        hasSeenOnboarding = true
        showOnboarding = false
    }
    
    func toggleTooltips() {
        tooltipsEnabled.toggle()
    }
    
    func toggleEuclideanGenerator() {
        showEuclideanGenerator.toggle()
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHaptic(_ type: HapticType) {
        guard hapticsEnabled else { return }
        
        switch type {
        case .light: HapticEngine.light()
        case .medium: HapticEngine.medium()
        case .heavy: HapticEngine.heavy()
        case .success: HapticEngine.success()
        case .warning: HapticEngine.warning()
        case .error: HapticEngine.error()
        case .selection: HapticEngine.selection()
        case .tick: HapticEngine.tick()
        case .beat: HapticEngine.beat()
        case .downbeat: HapticEngine.downbeat()
        }
    }
    
    private enum HapticType {
        case light, medium, heavy
        case success, warning, error
        case selection
        case tick, beat, downbeat
    }
    
    // MARK: - Persistence
    
    private func scheduleAutoSave() {
        hasUnsavedChanges = true
        autoSaveDebouncer?.call()
    }
    
    private func saveState() {
        isSaving = true
        
        // TODO: Implement actual persistence
        #if DEBUG
        print("💾 Auto-saving state...")
        #endif
        
        // Simulate save delay
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            await MainActor.run {
                isSaving = false
                hasUnsavedChanges = false
                lastSaveTime = Date()
            }
        }
    }
    
    func toggleKeyboardShortcuts() {
        showKeyboardShortcuts.toggle()
    }
    
    func toggleWhatsNew() {
        showWhatsNew.toggle()
    }
    
    private func setupDefaultCVTracks() {
        guard selectedInterface.isDCCoupled, let pattern = currentPattern else {
            cvTracks = []
            return
        }
        
        var tracks: [CVTrack] = []
        
        for (index, seqTrack) in pattern.tracks.prefix(4).enumerated() {
            let channel = index + 1
            guard channel <= selectedInterface.outputCount else { break }
            
            tracks.append(CVTrack(
                name: "ENV \(channel)",
                outputChannel: channel,
                envelope: index == 0 ? .kick : (index == 1 ? .snare : .percussion),
                sourceTrackID: seqTrack.id,
                modulationDestination: .vca
            ))
        }
        
        cvTracks = tracks
        selectedCVTrackID = tracks.first?.id
    }
}
