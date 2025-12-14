import SwiftUI

enum DS {

  enum Space {
    static let xxs: CGFloat = 4
    static let xs: CGFloat  = 6
    static let s: CGFloat   = 10
    static let m: CGFloat   = 14
    static let l: CGFloat   = 18
    static let xl: CGFloat  = 24
  }

  enum Radius {
    static let s: CGFloat = 6
    static let m: CGFloat = 10
  }

  enum Stroke {
    static let hairline: CGFloat = 1
    static let thin: CGFloat = 1.5
    static let thick: CGFloat = 2.5
  }

  enum Anim {
    static let fast  = Animation.easeOut(duration: 0.14)
    static let pulse = Animation.easeInOut(duration: 0.16)
    static let blink = Animation.easeInOut(duration: 0.10)
  }

  enum Font {
    static let title   = SwiftUI.Font.system(.headline, design: .default)
    static let label   = SwiftUI.Font.system(.subheadline, design: .default)
    static let caption = SwiftUI.Font.system(.caption, design: .default)

    static let monoXS = SwiftUI.Font.system(.caption2, design: .monospaced)
    static let monoS = SwiftUI.Font.system(.caption, design: .monospaced)
    static let monoM = SwiftUI.Font.system(.body, design: .monospaced)
    static let monoL = SwiftUI.Font.system(.headline, design: .monospaced)
  }

  enum Color {
    static let background = SwiftUI.Color.black.opacity(0.96)
    static let surface    = SwiftUI.Color.white.opacity(0.06)
    static let surface2   = SwiftUI.Color.white.opacity(0.08)
    static let cutout     = SwiftUI.Color.white.opacity(0.04)

    static let etchedLine = SwiftUI.Color.white.opacity(0.10)
    static let etchedLineSoft = SwiftUI.Color.white.opacity(0.06)

    static let textPrimary   = SwiftUI.Color.white
    static let textSecondary = SwiftUI.Color.white.opacity(0.62)
    static let textMuted     = SwiftUI.Color.white.opacity(0.40)

    static let selectedFill   = SwiftUI.Color.white.opacity(0.10)
    static let selectedStroke = SwiftUI.Color.white.opacity(0.65)

    static let led     = SwiftUI.Color.white.opacity(0.92)
    static let ledSoft = SwiftUI.Color.white.opacity(0.55)

    static let accent = SwiftUI.Color(red: 0.82, green: 0.86, blue: 0.92) // cold off-white
  }

  enum Size {
    static let minTouch: CGFloat = 44
    static let inspectorWidth: CGFloat = 320
    static let transportHeight: CGFloat = 56
  }
}
