import SwiftUI

enum PanelStyles {

  static func panelBackground() -> some View {
    ZStack {
      DS.Color.background

      RadialGradient(
        gradient: Gradient(colors: [
          SwiftUI.Color.white.opacity(0.06),
          SwiftUI.Color.black.opacity(0.40)
        ]),
        center: .center,
        startRadius: 40,
        endRadius: 540
      )
      .blendMode(.overlay)
      .opacity(0.35)

      LinearGradient(
        gradient: Gradient(colors: [
          SwiftUI.Color.white.opacity(0.015),
          SwiftUI.Color.clear,
          SwiftUI.Color.white.opacity(0.010),
          SwiftUI.Color.clear
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .blendMode(.overlay)
      .opacity(0.55)
    }
    .ignoresSafeArea()
  }

  static func etchedGrid(spacing: CGFloat = 24) -> some View {
    GeometryReader { _ in
      Canvas { context, size in
        var path = Path()

        var x: CGFloat = 0
        while x <= size.width {
          path.move(to: CGPoint(x: x, y: 0))
          path.addLine(to: CGPoint(x: x, y: size.height))
          x += spacing
        }

        var y: CGFloat = 0
        while y <= size.height {
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: size.width, y: y))
          y += spacing
        }

        context.stroke(path,
                       with: .color(DS.Color.etchedLineSoft),
                       lineWidth: DS.Stroke.hairline)
      }
      .opacity(0.35)
    }
    .allowsHitTesting(false)
  }

  static func cutoutBackground(cornerRadius: CGFloat = DS.Radius.s) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(DS.Color.cutout)
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(DS.Color.etchedLineSoft, lineWidth: DS.Stroke.hairline)
      )
      .shadow(color: SwiftUI.Color.black.opacity(0.65), radius: 3, x: 0, y: 1)
  }

  static func ledGlow(color: SwiftUI.Color = DS.Color.led, intensity: CGFloat = 1.0) -> some View {
    Circle()
      .fill(color.opacity(0.85))
      .blur(radius: 8 * intensity)
      .opacity(0.55 * intensity)
      .allowsHitTesting(false)
  }

  static func ledRing(cornerRadius: CGFloat = DS.Radius.s,
                      color: SwiftUI.Color = DS.Color.led,
                      lineWidth: CGFloat = DS.Stroke.thick,
                      glow: CGFloat = 1.0) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .stroke(color.opacity(0.90), lineWidth: lineWidth)
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(color.opacity(0.55), lineWidth: lineWidth)
          .blur(radius: 6 * glow)
          .opacity(0.55)
      )
      .allowsHitTesting(false)
  }

  static func panelButtonModifier(isOn: Bool) -> some ViewModifier {
    PanelButtonModifier(isOn: isOn)
  }

  private struct PanelButtonModifier: ViewModifier {
    let isOn: Bool
    func body(content: Content) -> some View {
      content
        .font(DS.Font.monoM)
        .padding(.horizontal, DS.Space.m)
        .padding(.vertical, DS.Space.s)
        .frame(minHeight: DS.Size.minTouch)
        .background(
          RoundedRectangle(cornerRadius: DS.Radius.s)
            .fill(isOn ? DS.Color.surface2 : DS.Color.surface)
            .overlay(
              RoundedRectangle(cornerRadius: DS.Radius.s)
                .stroke(isOn ? DS.Color.selectedStroke : DS.Color.etchedLineSoft,
                        lineWidth: DS.Stroke.hairline)
            )
        )
    }
  }
}
