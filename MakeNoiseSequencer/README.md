# Make Noise Cirklonish Sequencer

A Cirklon-inspired sequencer app with Make Noise-inspired panel aesthetics.

## Design Philosophy

- **Instrument, not app** - No settings flows that take over
- **Immediate feedback** (<100ms response time)
- **Muscle memory** - Same gesture = same function everywhere
- **Panel-style** - Monochrome base + semantic highlights + LED pulse
- **Stable layout** - No layout shifts, no scroll in inspector
- **Constraints** - No free text fields; chips/steppers with min/max/step
- **Touch targets** ≥ 44×44 points
- **Design System tokens only** - No ad-hoc styling

## Project Structure

```
MakeNoiseSequencer/
├── App/
│   ├── MakeNoiseSequencerApp.swift    # App entry point
│   └── AppShellView.swift             # Main navigation shell
├── DesignSystem/
│   ├── DS.swift                       # Design tokens
│   ├── PanelStyles.swift              # Panel styling utilities
│   └── Iconography.swift              # Icons and symbols
├── Models/
│   ├── TrackModel.swift
│   ├── PatternModel.swift
│   ├── StepModel.swift
│   └── SelectionModel.swift
├── Store/
│   └── SequencerStore.swift           # Central state management
└── Features/
    ├── Transport/
    │   ├── TransportBarView.swift
    │   └── TransportControls.swift
    ├── Tracks/
    │   ├── TrackSidebarView.swift
    │   ├── TrackRowView.swift
    │   ├── MuteSoloButtons.swift
    │   └── ColorDot.swift
    ├── Grid/
    │   ├── StepGridView.swift
    │   ├── StepCellView.swift
    │   └── GridRulerView.swift
    ├── Inspector/
    │   ├── InspectorPanelView.swift
    │   ├── InspectorStepSection.swift
    │   ├── InspectorTrackSection.swift
    │   ├── SteppedValueControl.swift
    │   ├── ToggleChip.swift
    │   └── SegmentChips.swift
    ├── Performance/
    │   ├── PerformanceView.swift
    │   ├── PatternLauncherGridView.swift
    │   └── PatternSlotView.swift
    └── Arrange/
        └── ArrangeView.swift          # Placeholder
```

## Building

### Requirements
- Xcode 15+
- iOS 17+ / macOS 14+

### Setup in Xcode

1. Create a new iOS/macOS App project in Xcode
2. Copy the source files into your project
3. Build and run

## Features

### Implemented
- ✅ Step grid with velocity-based luminance
- ✅ Track selection and mute/solo
- ✅ Pattern switching (4 patterns)
- ✅ Transport controls (play/stop/BPM)
- ✅ Inspector panel for step parameters
- ✅ Drag gesture for velocity adjustment
- ✅ Long press to open inspector
- ✅ LED pulse animation for playhead

### Gestures
- **Tap** - Select step + toggle on/off
- **Vertical drag** - Adjust velocity
- **Long press (0.25s)** - Open inspector for selected step

## Design System

### Colors
- Monochrome panel base with subtle gradients
- LED-style highlights for active/playing states
- Muted, industrial color palette for tracks

### Typography
- Monospace fonts throughout
- Short labels (VEL, LEN, PROB, etc.)
- Symbol-first approach

### Animation
- Fast (0.14s) for UI state changes
- Pulse (0.16s) for LED effects
- Blink (0.10s) for quick feedback
