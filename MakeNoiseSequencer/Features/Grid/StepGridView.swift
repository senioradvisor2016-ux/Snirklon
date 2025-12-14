import SwiftUI

struct StepGridView: View {
    @EnvironmentObject var store: SequencerStore
    
    /// Paint mode state
    @State private var isPainting: Bool = false
    @State private var paintState: Bool? = nil  // nil = not painting, true = turn on, false = turn off
    @State private var lastPaintedStep: UUID? = nil
    @State private var showToolbar: Bool = false
    @State private var showActionBar: Bool = false
    @State private var showMiniInspector: Bool = false
    
    /// Grid geometry
    private let stepWidth: CGFloat = DS.Size.minTouch + DS.Space.xxs
    private let stepHeight: CGFloat = DS.Size.minTouch + DS.Space.s
    private let rulerHeight: CGFloat = 24
    
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
                    VStack(alignment: .leading, spacing: DS.Space.s) {
                        // Grid ruler at top
                        GridRulerView(stepCount: stepCount, currentStep: store.currentStep, isPlaying: store.isPlaying)
                            .padding(.leading, DS.Space.xs)
                        
                        // Step grid
                        if let pattern = store.currentPattern {
                            ForEach(pattern.tracks) { track in
                                trackRow(track: track)
                            }
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
            
            // Action bar when step is selected
            if store.selection.hasSelection, let step = store.selectedStep {
                VStack {
                    Spacer()
                    StepActionBar(step: step)
                        .padding(.bottom, DS.Space.l)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: store.selection.selectedStepIDs)
            }
            
            // Mini inspector popover
            if showMiniInspector, let step = store.selectedStep, let track = store.selectedTrack {
                VStack {
                    HStack {
                        Spacer()
                        MiniInspectorView(
                            step: step,
                            trackColor: track.color,
                            onDismiss: { showMiniInspector = false },
                            onOpenFullInspector: {
                                showMiniInspector = false
                                store.openInspector()
                            }
                        )
                        .padding(DS.Space.m)
                    }
                    Spacer()
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3), value: showMiniInspector)
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
        // MARK: - Keyboard Navigation
        .focusable()
        .onKeyPress(.leftArrow) {
            store.selectPreviousStep()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            store.selectNextStep()
            return .handled
        }
        .onKeyPress(.upArrow) {
            store.selectPreviousTrack()
            return .handled
        }
        .onKeyPress(.downArrow) {
            store.selectNextTrack()
            return .handled
        }
        .onKeyPress(.space) {
            store.togglePlayback()
            return .handled
        }
        .onKeyPress(.return) {
            store.toggleSelectedStep()
            return .handled
        }
        .onKeyPress(keys: [.init("i")], modifiers: .command) {
            store.openInspector()
            return .handled
        }
        .onKeyPress(keys: [.init("h")], modifiers: .command) {
            store.humanize()
            return .handled
        }
        .onKeyPress(keys: [.init("e")], modifiers: .command) {
            store.toggleEuclideanGenerator()
            return .handled
        }
        .onKeyPress(keys: [.init("m")], modifiers: .command) {
            if store.selection.hasSelection {
                showMiniInspector.toggle()
            }
            return .handled
        }
        .onKeyPress(.escape) {
            showMiniInspector = false
            store.selection.clearSelection()
            return .handled
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
    
    // MARK: - Track Row
    
    @ViewBuilder
    private func trackRow(track: TrackModel) -> some View {
        HStack(spacing: DS.Space.xxs) {
            ForEach(track.steps) { step in
                StepCellView(
                    step: step,
                    isSelected: store.selection.selectedStepIDs.contains(step.id),
                    isPlaying: store.isPlaying && store.currentStep == step.index && store.selection.selectedTrackID == track.id,
                    trackColor: track.color,
                    onToggle: { store.toggleStep(step.id) },
                    onSelect: {
                        store.selectTrack(track.id)
                        store.selectStep(step.id)
                    },
                    onVelocityDelta: { delta in store.adjustVelocity(for: step.id, delta: delta) },
                    onTimingDelta: { delta in store.adjustTiming(for: step.id, delta: delta) },
                    onOpenInspector: { store.openInspector() }
                )
            }
        }
        .opacity(track.isMuted ? 0.4 : 1.0)
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
