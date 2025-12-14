# Make Noise Cirklonish Sequencer

A Cirklon-inspired 64-step sequencer app with Make Noise-inspired panel aesthetics, designed for controlling modular synthesizers via CV/Gate outputs.

## Design Philosophy

- **Instrument, not app** - No settings flows that take over
- **Immediate feedback** (<100ms response time)
- **Muscle memory** - Same gesture = same function everywhere
- **Panel-style** - Monochrome base + semantic highlights + LED pulse
- **Stable layout** - No layout shifts, no scroll in inspector
- **Constraints** - No free text fields; chips/steppers with min/max/step
- **Touch targets** ≥ 44×44 points
- **Design System tokens only** - No ad-hoc styling
- **Contextual help** - Help always one click away

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
│   ├── SelectionModel.swift
│   ├── AudioInterfaceModel.swift      # DC-coupled audio interfaces
│   ├── ADSRModel.swift                # ADSR envelope generator
│   └── HelpModel.swift                # Help content database
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
    │   ├── StepGridView.swift         # 64-step grid
    │   ├── StepCellView.swift
    │   └── GridRulerView.swift        # Bar/beat markers
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
    ├── Settings/
    │   └── AudioInterfaceSettingsView.swift  # CV/Audio config
    ├── ADSR/
    │   └── ADSREditorView.swift       # Visual ADSR editor
    ├── Help/
    │   ├── HelpChatView.swift         # Interactive help chat
    │   ├── OnboardingOverlay.swift    # First-time user guide
    │   ├── TooltipView.swift          # Contextual tooltips
    │   └── FeedbackComponents.swift   # Visual feedback
    └── Arrange/
        └── ArrangeView.swift
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

### Core Sequencing
- ✅ **64-step grid** with velocity-based luminance (4 bars × 16 steps)
- ✅ Track selection and mute/solo
- ✅ Pattern switching (4 patterns)
- ✅ Transport controls (play/stop/BPM/swing)
- ✅ Inspector panel for step parameters
- ✅ Drag gesture for velocity adjustment
- ✅ Long press to open inspector
- ✅ LED pulse animation for playhead
- ✅ Bar and beat markers

### CV/Gate Output
- ✅ **DC-coupled audio interface support**
  - Expert Sleepers ES-9, ES-8, ES-3
  - MOTU UltraLite mk5, 828es
  - RME Fireface UCX II
- ✅ CV output routing (Pitch, Gate, Velocity, Modulation)
- ✅ Configurable voltage ranges (±10V, ±5V)

### ADSR Envelope Generator
- ✅ **Visual ADSR editor** with real-time curve display
- ✅ Preset envelopes (PERC, PLUCK, PAD, KICK, SNARE, etc.)
- ✅ Curve types (Linear, Exponential, Logarithmic, S-Curve)
- ✅ Retrigger modes (Reset, Legato, None)
- ✅ Velocity sensitivity
- ✅ CV track routing to sequencer tracks

### Help & Usability
- ✅ **Interactive help chat** with contextual answers
- ✅ **Onboarding guide** for first-time users
- ✅ **Tooltips** with keyboard shortcuts
- ✅ Comprehensive topic browser
- ✅ Quick action suggestions
- ✅ Visual feedback components

### Gestures
| Gesture | Function |
|---------|----------|
| **Tap** | Toggle step on/off |
| **Vertical drag** | Adjust velocity |
| **Long press (0.25s)** | Open inspector |
| **Shift + tap** | Multi-select steps |

### Keyboard Shortcuts
| Shortcut | Function |
|----------|----------|
| `Space` | Play/Stop |
| `↑` `↓` | Change track |
| `←` `→` | Navigate grid |
| `1-4` | Switch pattern |
| `Tab` | Toggle inspector |
| `?` | Open help |

## CV/Audio Setup

### Supported DC-Coupled Interfaces

| Interface | Outputs | Voltage | Recommended |
|-----------|---------|---------|-------------|
| Expert Sleepers ES-9 | 16 | ±10V | ⭐ Best |
| Expert Sleepers ES-8 | 8 | ±10V | ⭐ Great |
| MOTU UltraLite mk5 | 10 | ±5V | Good |
| RME Fireface UCX II | 20 | ±5V | Good |

### Signal Types
- **Pitch CV** - 1V/octave for VCO control
- **Gate** - Trigger signal for envelopes
- **Velocity CV** - Dynamics control
- **Envelope CV** - ADSR output for VCA/VCF

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

## Documentation

- **USER_GUIDE.md** - Complete user manual in Swedish
- **In-app help** - Press ? for interactive assistance

## License

MIT License
