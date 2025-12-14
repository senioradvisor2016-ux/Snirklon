import SwiftUI

/// Tooltip component for contextual help
struct Tooltip: ViewModifier {
    let text: String
    let shortcut: String?
    @State private var isVisible: Bool = false
    @EnvironmentObject var store: SequencerStore
    
    init(_ text: String, shortcut: String? = nil) {
        self.text = text
        self.shortcut = shortcut
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isVisible && store.tooltipsEnabled {
                    tooltipContent
                        .offset(y: -40)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .onHover { hovering in
                withAnimation(DS.Anim.fast) {
                    isVisible = hovering
                }
            }
    }
    
    private var tooltipContent: some View {
        VStack(spacing: 2) {
            Text(text)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textPrimary)
            
            if let shortcut = shortcut {
                Text(shortcut)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
        .padding(.horizontal, DS.Space.s)
        .padding(.vertical, DS.Space.xs)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(DS.Color.surface2)
                .shadow(color: .black.opacity(0.2), radius: 4)
        )
        .fixedSize()
    }
}

extension View {
    func tooltip(_ text: String, shortcut: String? = nil) -> some View {
        modifier(Tooltip(text, shortcut: shortcut))
    }
}

/// Info badge for inline help
struct InfoBadge: View {
    let text: String
    @State private var showPopover: Bool = false
    
    var body: some View {
        Button(action: { showPopover.toggle() }) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundStyle(DS.Color.textMuted)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover, arrowEdge: .bottom) {
            Text(text)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textPrimary)
                .padding(DS.Space.m)
                .frame(maxWidth: 200)
                .background(DS.Color.surface)
        }
    }
}

/// Contextual help indicator
struct ContextualHelp: View {
    let title: String
    let description: String
    let tip: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.yellow)
                
                Text(title)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
            }
            
            Text(description)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textSecondary)
            
            if let tip = tip {
                HStack(spacing: 4) {
                    Text("💡")
                    Text(tip)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .italic()
                }
            }
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.s)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: DS.Stroke.hairline)
                )
        )
    }
}

/// Empty state view with guidance
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DS.Space.m) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(DS.Color.textMuted)
            
            Text(title)
                .font(DS.Font.monoM)
                .foregroundStyle(DS.Color.textSecondary)
            
            Text(description)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .padding(.horizontal, DS.Space.l)
                        .padding(.vertical, DS.Space.s)
                        .background(
                            Capsule()
                                .fill(DS.Color.surface2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DS.Space.xl)
    }
}

/// Keyboard shortcut hint
struct ShortcutHint: View {
    let keys: [String]
    let description: String
    
    var body: some View {
        HStack(spacing: DS.Space.s) {
            HStack(spacing: 2) {
                ForEach(keys, id: \.self) { key in
                    Text(key)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DS.Color.surface2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(DS.Color.etchedLine, lineWidth: 0.5)
                                )
                        )
                    
                    if key != keys.last {
                        Text("+")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
            }
            
            Text(description)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            Spacer()
        }
    }
}

/// Keyboard shortcuts panel
struct KeyboardShortcutsPanel: View {
    let shortcuts: [(keys: [String], description: String, category: String)] = [
        // Transport
        (["Space"], "Play/Stop", "Transport"),
        (["Enter"], "Play från början", "Transport"),
        (["Esc"], "Stop och återställ", "Transport"),
        
        // Navigation
        (["↑", "↓"], "Byt spår", "Navigation"),
        (["←", "→"], "Flytta i rutnätet", "Navigation"),
        (["1", "2", "3", "4"], "Byt mönster", "Navigation"),
        (["Tab"], "Växla inspektör", "Navigation"),
        
        // Editing
        (["⌘", "C"], "Kopiera", "Redigering"),
        (["⌘", "V"], "Klistra in", "Redigering"),
        (["⌘", "Z"], "Ångra", "Redigering"),
        (["⌘", "A"], "Markera alla", "Redigering"),
        (["Delete"], "Ta bort markerat", "Redigering"),
        
        // Help
        (["?"], "Visa hjälp", "Övrigt"),
        (["⌘", ","], "Inställningar", "Övrigt")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            Text("TANGENTBORDSGENVÄGAR")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            let categories = Array(Set(shortcuts.map { $0.category })).sorted()
            
            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(category.uppercased())
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .padding(.top, DS.Space.s)
                    
                    ForEach(shortcuts.filter { $0.category == category }, id: \.description) { shortcut in
                        ShortcutHint(keys: shortcut.keys, description: shortcut.description)
                    }
                }
            }
        }
        .padding(DS.Space.m)
    }
}

#Preview {
    VStack(spacing: 20) {
        ContextualHelp(
            title: "Velocity",
            description: "Dra vertikalt på ett steg för att justera velocity (styrka).",
            tip: "Håll Shift för finare kontroll"
        )
        
        EmptyStateView(
            icon: "waveform.path",
            title: "Inga enveloper",
            description: "Lägg till en ADSR-envelop för att skapa CV-signaler.",
            actionTitle: "Lägg till",
            action: {}
        )
        
        ShortcutHint(keys: ["⌘", "C"], description: "Kopiera")
    }
    .padding()
    .background(DS.Color.background)
}
