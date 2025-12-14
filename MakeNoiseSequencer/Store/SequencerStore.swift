import SwiftUI
import Combine

@MainActor
class SequencerStore: ObservableObject {
    // Transport state
    @Published var isPlaying: Bool = false
    @Published var bpm: Int = 120
    @Published var swing: Int = 50  // 50 = no swing, 0-100 range
    @Published var currentStep: Int = 0
    
    // Pattern state
    @Published var patterns: [PatternModel] = []
    @Published var currentPatternIndex: Int = 0
    
    // Selection state
    @Published var selection: SelectionModel = SelectionModel()
    
    // Audio Interface / CV Output state
    @Published var selectedInterface: AudioInterfaceModel = .es9
    @Published var cvOutputConfigs: [CVOutputConfig] = []
    @Published var showSettings: Bool = false
    
    // Timer for playback
    private var playbackTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupInitialPatterns()
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
    
    // MARK: - Transport Actions
    
    func play() {
        isPlaying = true
        startPlaybackTimer()
    }
    
    func stop() {
        isPlaying = false
        stopPlaybackTimer()
        currentStep = 0
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
    }
    
    func setSwing(_ newSwing: Int) {
        swing = max(0, min(100, newSwing))
    }
    
    private func startPlaybackTimer() {
        let interval = 60.0 / Double(bpm) / 4.0  // 16th notes
        playbackTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceStep()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func restartPlaybackTimer() {
        stopPlaybackTimer()
        startPlaybackTimer()
    }
    
    private func advanceStep() {
        guard let track = selectedTrack else { return }
        currentStep = (currentStep + 1) % track.length
    }
    
    // MARK: - Track Actions
    
    func selectTrack(_ trackID: UUID) {
        selection.selectedTrackID = trackID
        selection.clearSelection()
    }
    
    func toggleMute(for trackID: UUID) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }) else { return }
        patterns[patternIdx].tracks[trackIdx].isMuted.toggle()
    }
    
    func toggleSolo(for trackID: UUID) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }) else { return }
        patterns[patternIdx].tracks[trackIdx].isSolo.toggle()
    }
    
    // MARK: - Step Actions
    
    func selectStep(_ stepID: UUID) {
        selection.selectStep(stepID)
    }
    
    func toggleStep(_ stepID: UUID) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].isOn.toggle()
    }
    
    func adjustVelocity(for stepID: UUID, delta: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].adjustVelocity(by: delta)
    }
    
    func adjustTiming(for stepID: UUID, delta: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].adjustTiming(by: delta)
    }
    
    func setStepNote(_ stepID: UUID, note: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].note = max(0, min(127, note))
    }
    
    func setStepVelocity(_ stepID: UUID, velocity: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].velocity = max(1, min(127, velocity))
    }
    
    func setStepLength(_ stepID: UUID, length: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].length = max(1, min(96, length))
    }
    
    func setStepProbability(_ stepID: UUID, probability: Int) {
        guard let patternIdx = patterns.firstIndex(where: { $0.id == currentPattern?.id }),
              let trackID = selection.selectedTrackID,
              let trackIdx = patterns[patternIdx].tracks.firstIndex(where: { $0.id == trackID }),
              let stepIdx = patterns[patternIdx].tracks[trackIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        
        patterns[patternIdx].tracks[trackIdx].steps[stepIdx].probability = max(0, min(100, probability))
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
        currentPatternIndex = index
        
        // Maintain track selection if possible
        if let trackID = selection.selectedTrackID,
           currentPattern?.tracks.contains(where: { $0.id == trackID }) != true,
           let firstTrack = currentPattern?.tracks.first {
            selection.selectedTrackID = firstTrack.id
        }
        
        selection.clearSelection()
    }
    
    // MARK: - Audio Interface Actions
    
    func selectAudioInterface(_ interface: AudioInterfaceModel) {
        selectedInterface = interface
        // Reset CV configs when interface changes
        setupDefaultCVConfigs()
    }
    
    func toggleSettings() {
        showSettings.toggle()
    }
    
    private func setupDefaultCVConfigs() {
        guard selectedInterface.isDCCoupled else {
            cvOutputConfigs = []
            return
        }
        
        // Create default CV output configs based on interface and tracks
        var configs: [CVOutputConfig] = []
        
        if let pattern = currentPattern {
            for (index, track) in pattern.tracks.enumerated() {
                let channelBase = index * 2
                
                // Pitch CV
                if channelBase < selectedInterface.outputCount {
                    configs.append(CVOutputConfig(
                        outputChannel: channelBase + 1,
                        outputType: .pitch,
                        trackID: track.id
                    ))
                }
                
                // Gate CV
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
    }
    
    func addCVConfig() {
        let nextChannel = (cvOutputConfigs.map { $0.outputChannel }.max() ?? 0) + 1
        guard nextChannel <= selectedInterface.outputCount else { return }
        
        cvOutputConfigs.append(CVOutputConfig(outputChannel: nextChannel))
    }
    
    func removeCVConfig(_ id: UUID) {
        cvOutputConfigs.removeAll { $0.id == id }
    }
}
