import SwiftUI

/// "What's New" dialog shown after app updates
struct WhatsNewView: View {
    @EnvironmentObject var store: SequencerStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Header
            VStack(spacing: DS.Space.s) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(DS.Color.led)
                
                Text("NYA FUNKTIONER")
                    .font(DS.Font.monoL)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text("Version 1.2")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            // Features list
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.m) {
                    featureItem(
                        icon: "square.grid.2x2",
                        title: "Standard/Advanced-läge",
                        description: "Växla mellan enkelt och avancerat gränssnitt. Tryck ⌘M eller använd knappen i transportfältet."
                    )
                    
                    featureItem(
                        icon: "bell.badge",
                        title: "Toast-notifieringar",
                        description: "Feedback vid alla operationer med möjlighet att ångra destruktiva handlingar."
                    )
                    
                    featureItem(
                        icon: "paintbrush",
                        title: "Drag-to-paint",
                        description: "Måla steg genom att dra över rutnätet (Advanced-läge)."
                    )
                    
                    featureItem(
                        icon: "circle.hexagongrid",
                        title: "Euclidean Generator",
                        description: "Generera rytmiska mönster automatiskt. Tryck ⌘E för att öppna."
                    )
                    
                    featureItem(
                        icon: "wand.and.stars",
                        title: "Humanize",
                        description: "Lägg till mänsklig variation i velocity och timing. Tryck ⌘H."
                    )
                    
                    featureItem(
                        icon: "hand.tap",
                        title: "Haptisk feedback",
                        description: "Känn återkoppling vid alla interaktioner."
                    )
                    
                    featureItem(
                        icon: "keyboard",
                        title: "Fler kortkommandon",
                        description: "30+ nya tangentbordsgenvägar för snabbare arbetsflöde."
                    )
                }
                .padding(DS.Space.m)
            }
            .background(DS.Color.cutout)
            .cornerRadius(DS.Radius.m)
            
            // Close button
            Button(action: { dismiss() }) {
                Text("KOM IGÅNG")
                    .font(DS.Font.monoM)
                    .foregroundStyle(DS.Color.background)
                    .frame(maxWidth: .infinity)
                    .padding(DS.Space.m)
                    .background(DS.Color.led)
                    .cornerRadius(DS.Radius.m)
            }
            .buttonStyle(.plain)
        }
        .padding(DS.Space.l)
        .background(DS.Color.background)
    }
    
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.m) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DS.Color.led)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text(description)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Keyboard shortcuts panel
struct KeyboardShortcutsPanelView: View {
    @EnvironmentObject var store: SequencerStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "keyboard")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Color.led)
                
                Text("KORTKOMMANDON")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DS.Color.textMuted)
                }
                .frame(width: 28, height: 28)
            }
            .padding(DS.Space.m)
            .background(DS.Color.surface)
            
            // Shortcuts list
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.l) {
                    shortcutSection(title: "TRANSPORT") {
                        shortcutRow("Space", "Spela/Stoppa")
                        shortcutRow("Esc", "Stoppa & nollställ")
                    }
                    
                    shortcutSection(title: "REDIGERING") {
                        shortcutRow("⌘C", "Kopiera")
                        shortcutRow("⌘V", "Klistra in")
                        shortcutRow("⌘Z", "Ångra")
                        shortcutRow("⇧⌘Z", "Gör om")
                        shortcutRow("⌘A", "Markera alla")
                        shortcutRow("⌫", "Radera")
                    }
                    
                    shortcutSection(title: "MÖNSTER") {
                        shortcutRow("⌘E", "Euclidean Generator")
                        shortcutRow("⌘H", "Humanize")
                        shortcutRow("←", "Skifta vänster")
                        shortcutRow("→", "Skifta höger")
                        shortcutRow("⌘R", "Vänd mönster")
                        shortcutRow("⌘⌫", "Rensa spår")
                        shortcutRow("⌘F", "Fyll spår")
                    }
                    
                    shortcutSection(title: "NAVIGATION") {
                        shortcutRow("⌘I", "Visa/dölj inspector")
                        shortcutRow("⌘M", "Växla läge (Standard/Advanced)")
                        shortcutRow("⌘,", "Inställningar")
                        shortcutRow("⌘/", "Hjälp")
                        shortcutRow("1-8", "Välj mönster 1-8")
                        shortcutRow("⌥↑/↓", "Byt spår")
                    }
                    
                    shortcutSection(title: "STEG") {
                        shortcutRow("↑↓←→", "Navigera steg")
                        shortcutRow("Return", "Växla steg på/av")
                        shortcutRow("⇧↑/↓", "Oktav upp/ner")
                        shortcutRow("⌥↑/↓", "Not upp/ner")
                        shortcutRow("⌃↑/↓", "Velocity upp/ner")
                    }
                }
                .padding(DS.Space.m)
            }
        }
        .frame(width: 350)
        .background(DS.Color.background)
    }
    
    private func shortcutSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(title)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            VStack(spacing: DS.Space.xs) {
                content()
            }
            .padding(DS.Space.s)
            .background(DS.Color.surface)
            .cornerRadius(DS.Radius.s)
        }
    }
    
    private func shortcutRow(_ shortcut: String, _ description: String) -> some View {
        HStack {
            Text(description)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Spacer()
            
            Text(shortcut)
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
                .padding(.horizontal, DS.Space.s)
                .padding(.vertical, 2)
                .background(DS.Color.cutout)
                .cornerRadius(4)
        }
    }
}

#Preview {
    WhatsNewView()
        .environmentObject(SequencerStore())
}
