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

      // Minimal text only when selected (reveal gradually)
      if isSelected {
        VStack(spacing: 2) {
          Text(Iconography.Sym.selected)
            .font(DS.Font.monoS)
            .foregroundStyle(DS.Color.textSecondary)

          Text("\(step.note)")
            .font(DS.Font.monoS)
            .foregroundStyle(DS.Color.textPrimary)
        }
      }
    }
    .frame(minWidth: DS.Size.minTouch, minHeight: DS.Size.minTouch)
    .contentShape(Rectangle())
    .onTapGesture {
      onSelect()
      onToggle()
    }
    .gesture(velocityDrag)
    .highPriorityGesture(longPress)
    .accessibilityLabel("Step \(step.index)")
  }

  private var velocityOpacity: Double {
    // Clamp 1...127 -> 0.15...0.95
    let v = max(1, min(127, step.velocity))
    let t = Double(v) / 127.0
    return 0.15 + (0.80 * t)
  }

  private var velocityDrag: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        // Vertical drag -> velocity
        let dy = value.translation.height
        let delta = Int((-dy / 4.0).rounded())
        if delta != 0 { onVelocityDelta(delta) }
      }
  }

  private var longPress: some Gesture {
    LongPressGesture(minimumDuration: 0.25)
      .onEnded { _ in
        onSelect()
        onOpenInspector()
      }
  }
}
