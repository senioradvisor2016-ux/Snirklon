import SwiftUI

/// Keyboard shortcuts reference and configuration
enum KeyboardShortcuts {
    
    // MARK: - Transport
    
    static let play = KeyboardShortcut(.space)
    static let stop = KeyboardShortcut(.escape)
    
    // MARK: - Editing
    
    static let copy = KeyboardShortcut("c", modifiers: .command)
    static let paste = KeyboardShortcut("v", modifiers: .command)
    static let cut = KeyboardShortcut("x", modifiers: .command)
    static let undo = KeyboardShortcut("z", modifiers: .command)
    static let redo = KeyboardShortcut("z", modifiers: [.command, .shift])
    static let selectAll = KeyboardShortcut("a", modifiers: .command)
    static let delete = KeyboardShortcut(.delete)
    
    // MARK: - Pattern Operations
    
    static let euclidean = KeyboardShortcut("e", modifiers: .command)
    static let humanize = KeyboardShortcut("h", modifiers: .command)
    static let shiftLeft = KeyboardShortcut(.leftArrow, modifiers: .command)
    static let shiftRight = KeyboardShortcut(.rightArrow, modifiers: .command)
    static let reverse = KeyboardShortcut("r", modifiers: .command)
    static let clear = KeyboardShortcut(.delete, modifiers: .command)
    static let fill = KeyboardShortcut("f", modifiers: .command)
    
    // MARK: - Navigation
    
    static let inspector = KeyboardShortcut("i", modifiers: .command)
    static let settings = KeyboardShortcut(",", modifiers: .command)
    static let help = KeyboardShortcut("/", modifiers: .command)
    
    static let nextPattern = KeyboardShortcut(.rightArrow, modifiers: .option)
    static let prevPattern = KeyboardShortcut(.leftArrow, modifiers: .option)
    static let nextTrack = KeyboardShortcut(.downArrow, modifiers: .option)
    static let prevTrack = KeyboardShortcut(.upArrow, modifiers: .option)
    
    // MARK: - Step Navigation
    
    static let stepLeft = KeyboardShortcut(.leftArrow)
    static let stepRight = KeyboardShortcut(.rightArrow)
    static let stepUp = KeyboardShortcut(.upArrow)
    static let stepDown = KeyboardShortcut(.downArrow)
    static let toggleStep = KeyboardShortcut(.return)
    
    // MARK: - Value Adjustments
    
    static let octaveUp = KeyboardShortcut(.upArrow, modifiers: .shift)
    static let octaveDown = KeyboardShortcut(.downArrow, modifiers: .shift)
    static let noteUp = KeyboardShortcut(.upArrow, modifiers: .option)
    static let noteDown = KeyboardShortcut(.downArrow, modifiers: .option)
    static let velocityUp = KeyboardShortcut(.upArrow, modifiers: .control)
    static let velocityDown = KeyboardShortcut(.downArrow, modifiers: .control)
    
    // MARK: - Pattern Slots (1-8)
    
    static func patternSlot(_ number: Int) -> KeyboardShortcut {
        KeyboardShortcut(KeyEquivalent(Character("\(number)")))
    }
}

// MARK: - Shortcut Display

struct ShortcutDisplay: View {
    let shortcut: String
    let label: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            Spacer()
            Text(shortcut)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textMuted)
                .padding(.horizontal, DS.Space.xs)
                .padding(.vertical, 2)
                .background(DS.Color.surface)
                .cornerRadius(4)
        }
    }
}

// MARK: - All Shortcuts Panel

struct KeyboardShortcutsPanel: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                shortcutSection(title: "Transport") {
                    ShortcutDisplay(shortcut: "Space", label: "Play/Stop")
                    ShortcutDisplay(shortcut: "Esc", label: "Stop & Reset")
                }
                
                shortcutSection(title: "Editing") {
                    ShortcutDisplay(shortcut: "⌘C", label: "Copy")
                    ShortcutDisplay(shortcut: "⌘V", label: "Paste")
                    ShortcutDisplay(shortcut: "⌘Z", label: "Undo")
                    ShortcutDisplay(shortcut: "⇧⌘Z", label: "Redo")
                    ShortcutDisplay(shortcut: "⌘A", label: "Select All")
                    ShortcutDisplay(shortcut: "⌫", label: "Delete")
                }
                
                shortcutSection(title: "Pattern Operations") {
                    ShortcutDisplay(shortcut: "⌘E", label: "Euclidean Generator")
                    ShortcutDisplay(shortcut: "⌘H", label: "Humanize")
                    ShortcutDisplay(shortcut: "⌘←", label: "Shift Left")
                    ShortcutDisplay(shortcut: "⌘→", label: "Shift Right")
                    ShortcutDisplay(shortcut: "⌘R", label: "Reverse")
                    ShortcutDisplay(shortcut: "⌘⌫", label: "Clear Track")
                    ShortcutDisplay(shortcut: "⌘F", label: "Fill Track")
                }
                
                shortcutSection(title: "Navigation") {
                    ShortcutDisplay(shortcut: "⌘I", label: "Toggle Inspector")
                    ShortcutDisplay(shortcut: "⌘,", label: "Settings")
                    ShortcutDisplay(shortcut: "⌘/", label: "Help")
                    ShortcutDisplay(shortcut: "⌥←", label: "Previous Pattern")
                    ShortcutDisplay(shortcut: "⌥→", label: "Next Pattern")
                    ShortcutDisplay(shortcut: "⌥↑", label: "Previous Track")
                    ShortcutDisplay(shortcut: "⌥↓", label: "Next Track")
                }
                
                shortcutSection(title: "Step Editing") {
                    ShortcutDisplay(shortcut: "←→↑↓", label: "Navigate Steps")
                    ShortcutDisplay(shortcut: "Return", label: "Toggle Step")
                    ShortcutDisplay(shortcut: "⇧↑/↓", label: "Octave Up/Down")
                    ShortcutDisplay(shortcut: "⌥↑/↓", label: "Note Up/Down")
                    ShortcutDisplay(shortcut: "⌃↑/↓", label: "Velocity Up/Down")
                }
                
                shortcutSection(title: "Pattern Slots") {
                    ShortcutDisplay(shortcut: "1-8", label: "Select Pattern 1-8")
                }
            }
            .padding(DS.Space.l)
        }
    }
    
    private func shortcutSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(title.uppercased())
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
            
            VStack(spacing: DS.Space.xs) {
                content()
            }
            .padding(DS.Space.m)
            .background(DS.Color.cutout)
            .cornerRadius(DS.Radius.m)
        }
    }
}

// MARK: - ViewModifier for common shortcuts

struct CommonKeyboardShortcuts: ViewModifier {
    @EnvironmentObject var store: SequencerStore
    
    func body(content: Content) -> some View {
        content
            // These would be applied at a higher level
            .keyboardShortcut(KeyboardShortcuts.play)
    }
}
