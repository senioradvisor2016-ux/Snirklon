import SwiftUI

/// Theme system for dark/light mode and custom themes
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    @Published var systemAppearance: ColorScheme?
    
    init() {
        self.currentTheme = ThemeManager.loadTheme()
    }
    
    // MARK: - Theme Switching
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    func toggleDarkMode() {
        switch currentTheme.mode {
        case .dark:
            currentTheme = AppTheme.light
        case .light:
            currentTheme = AppTheme.dark
        case .system:
            currentTheme = AppTheme.dark
        }
    }
    
    func useSystemAppearance() {
        currentTheme = AppTheme.system
    }
    
    // MARK: - Persistence
    
    private func saveTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(data, forKey: "AppTheme")
        }
    }
    
    private static func loadTheme() -> AppTheme {
        if let data = UserDefaults.standard.data(forKey: "AppTheme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            return theme
        }
        return .dark // Default
    }
    
    // MARK: - Color Resolution
    
    func resolvedColor(_ keyPath: KeyPath<ThemeColors, Color>) -> Color {
        currentTheme.colors[keyPath: keyPath]
    }
}

// MARK: - Theme Definition

struct AppTheme: Codable, Equatable {
    let id: String
    let name: String
    let mode: ThemeMode
    let colors: ThemeColors
    
    static let dark = AppTheme(
        id: "dark",
        name: "Mörkt",
        mode: .dark,
        colors: ThemeColors.dark
    )
    
    static let light = AppTheme(
        id: "light",
        name: "Ljust",
        mode: .light,
        colors: ThemeColors.light
    )
    
    static let system = AppTheme(
        id: "system",
        name: "System",
        mode: .system,
        colors: ThemeColors.dark // Will be resolved at runtime
    )
    
    static let highContrast = AppTheme(
        id: "highContrast",
        name: "Hög kontrast",
        mode: .dark,
        colors: ThemeColors.highContrast
    )
    
    static let makeNoise = AppTheme(
        id: "makeNoise",
        name: "Make Noise",
        mode: .dark,
        colors: ThemeColors.makeNoise
    )
    
    static let allThemes: [AppTheme] = [.dark, .light, .system, .highContrast, .makeNoise]
}

enum ThemeMode: String, Codable {
    case dark
    case light
    case system
}

struct ThemeColors: Codable, Equatable {
    // Backgrounds
    let background: CodableColor
    let surface: CodableColor
    let surface2: CodableColor
    let cutout: CodableColor
    
    // Lines
    let etchedLine: CodableColor
    let etchedLineSoft: CodableColor
    
    // Text
    let textPrimary: CodableColor
    let textSecondary: CodableColor
    let textMuted: CodableColor
    
    // Interactive
    let selectedFill: CodableColor
    let selectedStroke: CodableColor
    
    // LED
    let led: CodableColor
    let ledSoft: CodableColor
    
    // Accent
    let accent: CodableColor
    
    // MARK: - Presets
    
    static let dark = ThemeColors(
        background: CodableColor(Color.black.opacity(0.96)),
        surface: CodableColor(Color.white.opacity(0.06)),
        surface2: CodableColor(Color.white.opacity(0.08)),
        cutout: CodableColor(Color.white.opacity(0.04)),
        etchedLine: CodableColor(Color.white.opacity(0.10)),
        etchedLineSoft: CodableColor(Color.white.opacity(0.06)),
        textPrimary: CodableColor(Color.white),
        textSecondary: CodableColor(Color.white.opacity(0.62)),
        textMuted: CodableColor(Color.white.opacity(0.40)),
        selectedFill: CodableColor(Color.white.opacity(0.10)),
        selectedStroke: CodableColor(Color.white.opacity(0.65)),
        led: CodableColor(Color.white.opacity(0.92)),
        ledSoft: CodableColor(Color.white.opacity(0.55)),
        accent: CodableColor(Color(red: 0.82, green: 0.86, blue: 0.92))
    )
    
    static let light = ThemeColors(
        background: CodableColor(Color(white: 0.95)),
        surface: CodableColor(Color.black.opacity(0.04)),
        surface2: CodableColor(Color.black.opacity(0.06)),
        cutout: CodableColor(Color.black.opacity(0.02)),
        etchedLine: CodableColor(Color.black.opacity(0.10)),
        etchedLineSoft: CodableColor(Color.black.opacity(0.06)),
        textPrimary: CodableColor(Color.black),
        textSecondary: CodableColor(Color.black.opacity(0.62)),
        textMuted: CodableColor(Color.black.opacity(0.40)),
        selectedFill: CodableColor(Color.black.opacity(0.08)),
        selectedStroke: CodableColor(Color.black.opacity(0.50)),
        led: CodableColor(Color.blue),
        ledSoft: CodableColor(Color.blue.opacity(0.55)),
        accent: CodableColor(Color.blue)
    )
    
    static let highContrast = ThemeColors(
        background: CodableColor(Color.black),
        surface: CodableColor(Color.white.opacity(0.10)),
        surface2: CodableColor(Color.white.opacity(0.15)),
        cutout: CodableColor(Color.white.opacity(0.05)),
        etchedLine: CodableColor(Color.white.opacity(0.30)),
        etchedLineSoft: CodableColor(Color.white.opacity(0.20)),
        textPrimary: CodableColor(Color.white),
        textSecondary: CodableColor(Color.white.opacity(0.85)),
        textMuted: CodableColor(Color.white.opacity(0.60)),
        selectedFill: CodableColor(Color.yellow.opacity(0.20)),
        selectedStroke: CodableColor(Color.yellow),
        led: CodableColor(Color.yellow),
        ledSoft: CodableColor(Color.yellow.opacity(0.70)),
        accent: CodableColor(Color.yellow)
    )
    
    static let makeNoise = ThemeColors(
        background: CodableColor(Color(red: 0.12, green: 0.12, blue: 0.11)),
        surface: CodableColor(Color(red: 0.18, green: 0.18, blue: 0.16)),
        surface2: CodableColor(Color(red: 0.22, green: 0.22, blue: 0.20)),
        cutout: CodableColor(Color(red: 0.10, green: 0.10, blue: 0.09)),
        etchedLine: CodableColor(Color(red: 0.30, green: 0.30, blue: 0.28)),
        etchedLineSoft: CodableColor(Color(red: 0.25, green: 0.25, blue: 0.23)),
        textPrimary: CodableColor(Color(red: 0.95, green: 0.93, blue: 0.88)),
        textSecondary: CodableColor(Color(red: 0.75, green: 0.73, blue: 0.68)),
        textMuted: CodableColor(Color(red: 0.55, green: 0.53, blue: 0.48)),
        selectedFill: CodableColor(Color(red: 0.85, green: 0.65, blue: 0.45).opacity(0.20)),
        selectedStroke: CodableColor(Color(red: 0.85, green: 0.65, blue: 0.45)),
        led: CodableColor(Color(red: 1.0, green: 0.85, blue: 0.60)),
        ledSoft: CodableColor(Color(red: 1.0, green: 0.85, blue: 0.60).opacity(0.60)),
        accent: CodableColor(Color(red: 0.85, green: 0.65, blue: 0.45))
    )
}

// MARK: - Codable Color Wrapper

struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(_ color: Color) {
        // Convert to UIColor/NSColor to extract components
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
        #else
        self.red = 0
        self.green = 0
        self.blue = 0
        self.opacity = 1
        #endif
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Theme Selector View

struct ThemeSelectorView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            Text("TEMA")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            ForEach(AppTheme.allThemes, id: \.id) { theme in
                themeRow(theme)
            }
        }
    }
    
    private func themeRow(_ theme: AppTheme) -> some View {
        Button(action: { themeManager.setTheme(theme) }) {
            HStack {
                // Preview circles
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.colors.background.color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(theme.colors.etchedLine.color, lineWidth: 1)
                        )
                    Circle()
                        .fill(theme.colors.led.color)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(theme.colors.accent.color)
                        .frame(width: 20, height: 20)
                }
                
                Text(theme.name)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Spacer()
                
                if themeManager.currentTheme.id == theme.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(DS.Color.led)
                }
            }
            .padding(DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(themeManager.currentTheme.id == theme.id ? DS.Color.surface2 : DS.Color.surface)
            )
        }
        .buttonStyle(.plain)
    }
}
