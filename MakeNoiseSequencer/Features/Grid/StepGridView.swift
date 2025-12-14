import SwiftUI

struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    
    /// Paint mode state
    @State private var isPainting: Bool = false
    @State private var paintState: Bool? = nil  // nil = not painting, true = turn on, false = turn off
    @State private var lastPaintedStep: UUID? = nil
    @State private var showToolbar: Bool = false
    
    /// Grid geometry (using pre-computed values for performance)
    private let stepWidth: CGFloat = DS.Grid.stepWidth
    private let stepHeight: CGFloat = DS.Grid.stepHeight
    private let rulerHeight: CGFloat = DS.Grid.rulerHeight
    
    /// Maximum steps to display based on mode
    private var stepCount: Int {
        let trackLength = store.currentPattern?.tracks.first?.length ?? 64
        return min(trackLength, store.features.maxTrackLength)
    }
    
    /// Whether paint mode is enabled (Advanced only)
    private var paintEnabled: Bool {
        store.features.enablePaintMode
    }
    
    var body: some View {
        ZStack {
            // Etched grid background
            PanelStyles.etchedGrid(spacing: DS.Size.minTouch + DS.Space.xxs)
            
            VStack(spacing: 0) {
                // Toolbar (Advanced mode only)
                if showToolbar && store.features.showGridToolbar {
                    gridToolbar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main grid with optional paint gesture
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: DS.Space.s, pinnedViews: [.sectionHeaders]) {
                        // Grid ruler at top (pinned)
                        Section {
                            // Step grid - use LazyVStack for rows
                            if let pattern = store.currentPattern {
                                ForEach(pattern.tracks) { track in
                                    TrackRowContainer(
                                        track: track,
                                        selectedStepIDs: store.selection.selectedStepIDs,
                                        selectedTrackID: store.selection.selectedTrackID,
                                        isPlaying: store.isPlaying,
                                        currentStep: store.currentStep,
                                        showIndicators: store.features.showStepIndicators,
                                        onToggleStep: store.toggleStep,
                                        onSelectTrack: store.selectTrack,
                                        onSelectStep: store.selectStep,
                                        onAdjustVelocity: store.adjustVelocity,
                                        onAdjustTiming: store.adjustTiming,
                                        onOpenInspector: store.openInspector
                                    )
                                }
                            }
                        } header: {
                            GridRulerView(stepCount: stepCount, currentStep: store.currentStep, isPlaying: store.isPlaying)
                                .padding(.leading, DS.Space.xs)
                                .background(DS.Color.background)
                        }
                    }
                    .padding(DS.Space.m)
                    .contentShape(Rectangle())
                    .gesture(paintEnabled ? paintGesture : nil)
                }
            }
            
            // Paint mode indicator (Advanced only)
            if isPainting && paintEnabled {
                VStack {
                    HStack {
                        Spacer()
                        paintModeIndicator
                            .padding(DS.Space.m)
                    }
                    Spacer()
                }
            }
        }
        .toolbar {
            // Toolbar toggle (Advanced mode only)
            if store.features.showGridToolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { withAnimation(DS.Anim.fast) { showToolbar.toggle() } }) {
                        Image(systemName: showToolbar ? "chevron.up" : "slider.horizontal.3")
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Grid Toolbar
    
    private var gridToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.s) {
                // Pattern operations
                toolbarButton(icon: "arrow.left", label: "Shift L") {
                    store.shiftTrackLeft()
                }
                
                toolbarButton(icon: "arrow.right", label: "Shift R") {
                    store.shiftTrackRight()
                }
                
                toolbarButton(icon: "arrow.left.arrow.right", label: "Reverse") {
                    store.reverseTrack()
                }
                
                Divider()
                    .frame(height: 24)
                
                toolbarButton(icon: "wand.and.stars", label: "Humanize") {
                    store.humanize()
                }
                
                toolbarButton(icon: "circle.hexagongrid", label: "Euclidean") {
                    store.toggleEuclideanGenerator()
                }
                
                Divider()
                    .frame(height: 24)
                
                toolbarButton(icon: "doc.on.doc", label: "Copy") {
                    store.copySelectedSteps()
                }
                
                toolbarButton(icon: "doc.on.clipboard", label: "Paste") {
                    if let firstSelected = store.selection.selectedStepIDs.first,
                       let step = store.selectedTrack?.steps.first(where: { $0.id == firstSelected }) {
                        store.pasteSteps(startingAt: step.index)
                    }
                }
                
                Divider()
                    .frame(height: 24)
                
                toolbarButton(icon: "trash", label: "Clear") {
                    store.clearTrack()
                }
                
                toolbarButton(icon: "square.fill", label: "Fill") {
                    store.fillTrack()
                }
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
        }
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    private func toolbarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(DS.Color.textSecondary)
            .frame(minWidth: 50)
            .padding(.vertical, DS.Space.xxs)
            .padding(.horizontal, DS.Space.xs)
            .background(DS.Color.surface2)
            .cornerRadius(DS.Radius.s)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Paint Mode Indicator
    
    private var paintModeIndicator: some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: paintState == true ? "paintbrush.fill" : "eraser.fill")
            Text(paintState == true ? "PAINT" : "ERASE")
                .font(DS.Font.monoS)
        }
        .foregroundStyle(paintState == true ? DS.Color.led : DS.Color.textSecondary)
        .padding(.horizontal, DS.Space.s)
        .padding(.vertical, DS.Space.xs)
        .background(DS.Color.surface.opacity(0.9))
        .cornerRadius(DS.Radius.s)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .stroke(paintState == true ? DS.Color.led : DS.Color.etchedLine, lineWidth: DS.Stroke.thin)
        )
    }
    
    // MARK: - Paint Gesture
    
    private var paintGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                handlePaintGesture(at: value.location, startLocation: value.startLocation)
            }
            .onEnded { _ in
                endPaintMode()
            }
    }
    
    private func handlePaintGesture(at location: CGPoint, startLocation: CGPoint) {
        guard let pattern = store.currentPattern else { return }
        
        // Calculate grid position
        // Account for padding and ruler
        let adjustedY = location.y - rulerHeight - DS.Space.m - DS.Space.s
        let adjustedX = location.x - DS.Space.m - DS.Space.xs
        
        guard adjustedY >= 0 && adjustedX >= 0 else { return }
        
        let stepX = Int(adjustedX / stepWidth)
        let trackY = Int(adjustedY / stepHeight)
        
        guard trackY >= 0 && trackY < pattern.tracks.count else { return }
        
        let track = pattern.tracks[trackY]
        guard stepX >= 0 && stepX < track.steps.count else { return }
        
        let step = track.steps[stepX]
        
        // Initialize paint mode on first contact
        if !isPainting {
            isPainting = true
            paintState = !step.isOn  // If step is off, we paint on; if on, we erase
            HapticEngine.selection()
        }
        
        // Avoid repainting the same step
        guard step.id != lastPaintedStep else { return }
        lastPaintedStep = step.id
        
        // Select track if different
        if store.selection.selectedTrackID != track.id {
            store.selectTrack(track.id)
        }
        
        // Apply paint if needed
        if step.isOn != paintState {
            store.setStepState(step.id, isOn: paintState ?? false)
            HapticEngine.selection()
        }
    }
    
    private func endPaintMode() {
        isPainting = false
        paintState = nil
        lastPaintedStep = nil
    }
}

// MARK: - Euclidean Generator Sheet

struct EuclideanGeneratorSheet: View {
    @EnvironmentObject var store: SequencerStore
    @State private var steps: Double = 16
    @State private var pulses: Double = 4
    @State private var rotation: Double = 0
    @State private var accentEvery: Double = 4
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Header
            HStack {
                Text("EUCLIDEAN GENERATOR")
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.textPrimary)
                Spacer()
                Button(action: { store.showEuclideanGenerator = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            // Preview
            patternPreview
            
            // Controls
            VStack(spacing: DS.Space.m) {
                parameterSlider(title: "STEPS", value: $steps, range: 4...64, step: 1)
                parameterSlider(title: "PULSES", value: $pulses, range: 1...Double(steps), step: 1)
                parameterSlider(title: "ROTATION", value: $rotation, range: 0...Double(steps - 1), step: 1)
                parameterSlider(title: "ACCENT EVERY", value: $accentEvery, range: 1...8, step: 1)
            }
            
            // Presets
            presetButtons
            
            // Apply button
            Button(action: applyPattern) {
                Text("APPLY TO TRACK")
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.background)
                    .frame(maxWidth: .infinity)
                    .padding(DS.Space.m)
                    .background(DS.Color.textPrimary)
                    .cornerRadius(DS.Radius.m)
            }
        }
        .padding(DS.Space.l)
        .background(DS.Color.background)
    }
    
    private var patternPreview: some View {
        let pattern = EuclideanGenerator.generate(
            steps: Int(steps),
            pulses: Int(pulses),
            rotation: Int(rotation)
        )
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(0..<pattern.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(pattern[index] ? DS.Color.led : DS.Color.surface)
                        .frame(width: 12, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(DS.Color.etchedLine, lineWidth: 0.5)
                        )
                }
            }
            .padding(DS.Space.s)
        }
        .background(DS.Color.cutout)
        .cornerRadius(DS.Radius.s)
    }
    
    private func parameterSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Text(title)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.textPrimary)
            }
            
            Slider(value: value, in: range, step: step)
                .tint(DS.Color.accent)
        }
    }
    
    private var presetButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.xs) {
                ForEach(EuclideanGenerator.presets, id: \.name) { preset in
                    Button(action: {
                        steps = Double(preset.steps)
                        pulses = Double(preset.pulses)
                        rotation = 0
                    }) {
                        Text(preset.name)
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.horizontal, DS.Space.s)
                            .padding(.vertical, DS.Space.xs)
                            .background(DS.Color.surface)
                            .cornerRadius(DS.Radius.s)
                    }
                }
            }
        }
    }
    
    private func applyPattern() {
        store.applyEuclideanWithVelocity(
            steps: Int(steps),
            pulses: Int(pulses),
            rotation: Int(rotation),
            accentEvery: Int(accentEvery)
        )
        store.showEuclideanGenerator = false
    }
}

// MARK: - Optimized Track Row Container

/// Isolated container for track rows to prevent unnecessary re-renders
/// Only updates when the specific track data changes
struct TrackRowContainer: View, Equatable {
    let track: TrackModel
    let selectedStepIDs: Set<UUID>
    let selectedTrackID: UUID?
    let isPlaying: Bool
    let currentStep: Int
    let showIndicators: Bool
    
    // Callbacks (excluded from equality check)
    let onToggleStep: (UUID) -> Void
    let onSelectTrack: (UUID) -> Void
    let onSelectStep: (UUID) -> Void
    let onAdjustVelocity: (UUID, Int) -> Void
    let onAdjustTiming: (UUID, Int) -> Void
    let onOpenInspector: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.xxs) {
            ForEach(track.steps) { step in
                StepCellView(
                    step: step,
                    isSelected: selectedStepIDs.contains(step.id),
                    isPlaying: isPlaying && currentStep == step.index && selectedTrackID == track.id,
                    trackColor: track.color,
                    showIndicators: showIndicators,
                    onToggle: { onToggleStep(step.id) },
                    onSelect: {
                        onSelectTrack(track.id)
                        onSelectStep(step.id)
                    },
                    onVelocityDelta: { delta in onAdjustVelocity(step.id, delta) },
                    onTimingDelta: { delta in onAdjustTiming(step.id, delta) },
                    onOpenInspector: onOpenInspector
                )
            }
        }
        .opacity(track.isMuted ? 0.4 : 1.0)
    }
    
    // Custom equality check - only compare data, not callbacks
    static func == (lhs: TrackRowContainer, rhs: TrackRowContainer) -> Bool {
        lhs.track == rhs.track &&
        lhs.selectedStepIDs == rhs.selectedStepIDs &&
        lhs.selectedTrackID == rhs.selectedTrackID &&
        lhs.isPlaying == rhs.isPlaying &&
        lhs.currentStep == rhs.currentStep &&
        lhs.showIndicators == rhs.showIndicators
    }
}

// MARK: - Optimized Step Cell Wrapper

/// Wrapper that uses EquatableView for efficient re-rendering
struct OptimizedStepCell: View, Equatable {
    let step: StepModel
    let isSelected: Bool
    let isPlaying: Bool
    let trackColor: Color
    let showIndicators: Bool
    
    var body: some View {
        StepCellView(
            step: step,
            isSelected: isSelected,
            isPlaying: isPlaying,
            trackColor: trackColor,
            showIndicators: showIndicators,
            onToggle: {},
            onSelect: {},
            onVelocityDelta: { _ in },
            onTimingDelta: { _ in },
            onOpenInspector: {}
        )
    }
    
    static func == (lhs: OptimizedStepCell, rhs: OptimizedStepCell) -> Bool {
        lhs.step == rhs.step &&
        lhs.isSelected == rhs.isSelected &&
        lhs.isPlaying == rhs.isPlaying &&
        lhs.trackColor == rhs.trackColor &&
        lhs.showIndicators == rhs.showIndicators
    }
}
