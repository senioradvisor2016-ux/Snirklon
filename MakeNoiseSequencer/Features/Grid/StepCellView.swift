import SwiftUI

// MAKE NOISE RULES:
// - panel feel, monokrom bas, etched lines, LED feedback
// - stable layout, no modal editing, immediate feedback
// - DS tokens only (no ad-hoc styling)

struct StepCellView: View {
    let step: StepModel
    let isSelected: Bool
    let isPlaying: Bool
    let trackColor: Color
    
    let onToggle: () -> Void
    let onSelect: () -> Void
    let onVelocityDelta: (Int) -> Void
    let onTimingDelta: (Int) -> Void
    let onOpenInspector: () -> Void
    
    @State private var pulseOn: Bool = false
    @State private var lastVelocityDelta: Int = 0
    
    var body: some View {
        ZStack {
            // Panel cutout base
            PanelStyles.cutoutBackground(cornerRadius: DS.Radius.s)
            
            // On-state fill (velocity -> luminans)
            if step.isOn {
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(trackColor.opacity(velocityOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                            .opacity(0.35)
                    )
            }
            
            // Selected etched stroke + subtle glow (not neon)
            if isSelected {
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .stroke(DS.Color.selectedStroke, lineWidth: DS.Stroke.thin)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .stroke(DS.Color.selectedStroke.opacity(0.55), lineWidth: DS.Stroke.thin)
                            .blur(radius: 4)
                            .opacity(0.35)
                    )
            }
            
            // Playing LED ring + pulse
            if isPlaying {
                PanelStyles.ledRing(cornerRadius: DS.Radius.s,
                                    color: DS.Color.led,
                                    lineWidth: DS.Stroke.thick,
                                    glow: 1.0)
                .opacity(pulseOn ? 1.0 : 0.72)
                .animation(DS.Anim.pulse, value: pulseOn)
                .onAppear { pulseOn = true }
                .onChange(of: isPlaying) { _, newValue in
                    if newValue { pulseOn.toggle() }
                }
            }
            
            // Step indicators
            stepIndicators
            
            // Minimal text only when selected (reveal gradually)
            if isSelected {
                VStack(spacing: 2) {
                    Text(Iconography.Sym.selected)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textSecondary)
                    
                    Text(step.noteName)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textPrimary)
                }
            }
        }
        .frame(minWidth: DS.Size.minTouch, minHeight: DS.Size.minTouch)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticEngine.light()
            onSelect()
            onToggle()
        }
        .gesture(velocityDrag)
        .highPriorityGesture(longPress)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Dubbelklicka för att växla. Dra vertikalt för velocity.")
        .accessibilityAddTraits(step.isOn ? .isSelected : [])
    }
    
    // MARK: - Step Indicators
    
    @ViewBuilder
    private var stepIndicators: some View {
        if step.isOn && !isSelected {
            VStack {
                HStack {
                    // Probability indicator (if < 100%)
                    if step.hasProbability {
                        Text("P")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                    
                    Spacer()
                    
                    // Ratchet indicator
                    if step.hasRatchet {
                        Text("R\(step.repeat_)")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
                .padding(.horizontal, 3)
                .padding(.top, 3)
                
                Spacer()
                
                // Timing offset indicator
                if step.hasTimingOffset {
                    Text(step.timingDescription)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .padding(.bottom, 3)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var velocityOpacity: Double {
        // Clamp 1...127 -> 0.15...0.95
        let v = max(1, min(127, step.velocity))
        let t = Double(v) / 127.0
        return 0.15 + (0.80 * t)
    }
    
    private var accessibilityLabel: String {
        "Steg \(step.index + 1), \(step.isOn ? "aktivt" : "inaktivt")"
    }
    
    private var accessibilityValue: String {
        if step.isOn {
            var parts = ["Velocity \(step.velocity)", "Not \(step.noteName)"]
            if step.hasProbability {
                parts.append("Sannolikhet \(step.probability)%")
            }
            if step.hasRatchet {
                parts.append("\(step.repeat_) upprepningar")
            }
            return parts.joined(separator: ", ")
        }
        return "Tom"
    }
    
    // MARK: - Gestures
    
    private var velocityDrag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                // Vertical drag -> velocity
                let dy = value.translation.height
                let delta = Int((-dy / 6.0).rounded())
                
                // Only trigger haptic when crossing thresholds
                if delta != lastVelocityDelta && delta != 0 {
                    if abs(delta) > abs(lastVelocityDelta) {
                        HapticEngine.selection()
                    }
                    lastVelocityDelta = delta
                    onVelocityDelta(delta > 0 ? 1 : -1)
                }
            }
            .onEnded { _ in
                lastVelocityDelta = 0
            }
    }
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                HapticEngine.medium()
                onSelect()
                onOpenInspector()
            }
    }
}

// MARK: - Step Cell Variants

/// Compact step cell for mini-views
struct StepCellCompactView: View {
    let step: StepModel
    let trackColor: Color
    let isPlaying: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(step.isOn ? trackColor.opacity(velocityOpacity) : DS.Color.cutout)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isPlaying ? DS.Color.led : DS.Color.etchedLine, lineWidth: isPlaying ? 1 : 0.5)
            )
            .frame(width: 8, height: 16)
    }
    
    private var velocityOpacity: Double {
        let v = max(1, min(127, step.velocity))
        return 0.3 + (0.7 * Double(v) / 127.0)
    }
}

/// Read-only step display for pattern preview
struct StepPreviewView: View {
    let isOn: Bool
    let velocity: Int
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isOn ? color.opacity(velocityOpacity) : DS.Color.cutout)
            .frame(width: 6, height: 12)
    }
    
    private var velocityOpacity: Double {
        let v = max(1, min(127, velocity))
        return 0.3 + (0.7 * Double(v) / 127.0)
    }
}
