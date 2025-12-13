# Make Noise Cirklonish Sequencer - Implementation Plan

## Status: ✅ Complete (29 Swift files created)

## Absoluta regler
- Instrument, inte app. Inga settings-flöden som tar över.
- Immediate feedback (<100ms).
- Muscle memory: samma gest = samma funktion överallt.
- Panel-stil: monokrom bas + semantiska highlights + LED-pulse.
- Stabil layout: inga layout shifts, ingen scroll i inspector.
- Constraints: inga fria textfält; chips/steppers med min/max/step.
- Touch targets ≥ 44×44.
- DS tokens only: ingen ad-hoc styling.

## Projektstruktur

### App
- [x] App/MakeNoiseSequencerApp.swift
- [x] App/AppShellView.swift

### Design System
- [x] DesignSystem/DS.swift ✅ (exakt kodblob)
- [x] DesignSystem/PanelStyles.swift ✅ (exakt kodblob)
- [x] DesignSystem/Iconography.swift ✅ (exakt kodblob)

### Models
- [x] Models/TrackModel.swift
- [x] Models/PatternModel.swift
- [x] Models/StepModel.swift
- [x] Models/SelectionModel.swift

### Store
- [x] Store/SequencerStore.swift

### Features: Transport
- [x] Features/Transport/TransportBarView.swift
- [x] Features/Transport/TransportControls.swift

### Features: Tracks
- [x] Features/Tracks/TrackSidebarView.swift
- [x] Features/Tracks/TrackRowView.swift
- [x] Features/Tracks/MuteSoloButtons.swift
- [x] Features/Tracks/ColorDot.swift

### Features: Grid
- [x] Features/Grid/StepGridView.swift
- [x] Features/Grid/StepCellView.swift ✅ (exakt kodblob)
- [x] Features/Grid/GridRulerView.swift

### Features: Inspector
- [x] Features/Inspector/InspectorPanelView.swift
- [x] Features/Inspector/InspectorStepSection.swift
- [x] Features/Inspector/InspectorTrackSection.swift
- [x] Features/Inspector/SteppedValueControl.swift
- [x] Features/Inspector/ToggleChip.swift
- [x] Features/Inspector/SegmentChips.swift

### Features: Performance
- [x] Features/Performance/PerformanceView.swift
- [x] Features/Performance/PatternLauncherGridView.swift
- [x] Features/Performance/PatternSlotView.swift

### Features: Arrange
- [x] Features/Arrange/ArrangeView.swift (placeholder)

## Validering (kräver Xcode 15+ / iOS 17+ / macOS 14+)
- [ ] Bygger utan errors
- [ ] Track select funkar
- [ ] Step toggle funkar
- [ ] Drag velocity funkar + syns direkt
- [ ] Long press öppnar inspector med step-parametrar
- [ ] Play/stop visar playhead LED-pulse i grid
- [ ] DS tokens används överallt

## Implementerade filer (29 st)

### Design System (exakta kodblobs från prompt)
- DesignSystem/DS.swift ✅
- DesignSystem/PanelStyles.swift ✅
- DesignSystem/Iconography.swift ✅

### Grid (StepCellView exakt kodblob från prompt)
- Features/Grid/StepCellView.swift ✅
- Features/Grid/StepGridView.swift ✅
- Features/Grid/GridRulerView.swift ✅

### Övriga filer
Se README.md för komplett filstruktur.

## Nästa steg
1. Öppna i Xcode 15+
2. Skapa nytt iOS/macOS App-projekt
3. Kopiera in källfilerna
4. Bygg och testa
