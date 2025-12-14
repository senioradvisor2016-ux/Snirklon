import SwiftUI

/// Tooltip modifier för konsekvent tooltip-implementation genom appen
struct TooltipModifier: ViewModifier {
    let text: String
    let shortcut: String?
    let position: TooltipPosition
    
    @State private var isShowing = false
    @State private var hideTask: Task<Void, Never>?
    
    enum TooltipPosition {
        case top, bottom, leading, trailing
        
        var alignment: Alignment {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            case .leading: return .leading
            case .trailing: return .trailing
            }
        }
        
        var offset: CGSize {
            switch self {
            case .top: return CGSize(width: 0, height: -50)
            case .bottom: return CGSize(width: 0, height: 50)
            case .leading: return CGSize(width: -100, height: 0)
            case .trailing: return CGSize(width: 100, height: 0)
            }
        }
    }
    
    init(text: String, shortcut: String? = nil, position: TooltipPosition = .top) {
        self.text = text
        self.shortcut = shortcut
        self.position = position
    }
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 10) {
                showTooltip()
            } onPressingChanged: { isPressing in
                if !isPressing && isShowing {
                    scheduleHide()
                }
            }
            .overlay(alignment: position.alignment) {
                if isShowing {
                    tooltipBubble
                        .offset(position.offset)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1000)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowing)
    }
    
    private var tooltipBubble: some View {
        VStack(spacing: DS.Space.xxs) {
            Text(text)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textPrimary)
                .multilineTextAlignment(.center)
            
            if let shortcut = shortcut {
                HStack(spacing: DS.Space.xxs) {
                    ForEach(shortcut.components(separatedBy: "+"), id: \.self) { key in
                        Text(key.trimmingCharacters(in: .whitespaces))
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.horizontal, DS.Space.xs)
                            .padding(.vertical, 2)
                            .background(DS.Color.surface2)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.horizontal, DS.Space.s)
        .padding(.vertical, DS.Space.xs)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
                .shadow(color: .black.opacity(0.3), radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
        )
        .fixedSize()
    }
    
    private func showTooltip() {
        HapticEngine.light()
        withAnimation {
            isShowing = true
        }
        scheduleHide()
    }
    
    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 sekunder
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Lägg till en tooltip som visas vid long-press
    /// - Parameters:
    ///   - text: Tooltip-texten
    ///   - shortcut: Valfri tangentbordsgenväg (t.ex. "⌘ + H")
    ///   - position: Position relativt till vyn
    func tooltip(_ text: String, shortcut: String? = nil, position: TooltipModifier.TooltipPosition = .top) -> some View {
        modifier(TooltipModifier(text: text, shortcut: shortcut, position: position))
    }
}

// MARK: - Hover Tooltip (macOS/iPad med trackpad)

struct HoverTooltipModifier: ViewModifier {
    let text: String
    let shortcut: String?
    
    @State private var isHovering = false
    @State private var showTask: Task<Void, Never>?
    @State private var isShowing = false
    
    init(text: String, shortcut: String? = nil) {
        self.text = text
        self.shortcut = shortcut
    }
    
    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    scheduleShow()
                } else {
                    showTask?.cancel()
                    withAnimation {
                        isShowing = false
                    }
                }
            }
            .overlay(alignment: .top) {
                if isShowing {
                    tooltipContent
                        .offset(y: -45)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: 0.15), value: isShowing)
    }
    
    private var tooltipContent: some View {
        VStack(spacing: DS.Space.xxs) {
            Text(text)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textPrimary)
            
            if let shortcut = shortcut {
                Text(shortcut)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.accent)
                    .padding(.horizontal, DS.Space.xs)
                    .padding(.vertical, 2)
                    .background(DS.Color.surface2)
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, DS.Space.s)
        .padding(.vertical, DS.Space.xs)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
                .shadow(color: .black.opacity(0.2), radius: 5)
        )
        .fixedSize()
    }
    
    private func scheduleShow() {
        showTask?.cancel()
        showTask = Task {
            try? await Task.sleep(nanoseconds: 700_000_000) // 0.7 sekunder delay
            guard !Task.isCancelled, isHovering else { return }
            await MainActor.run {
                withAnimation {
                    isShowing = true
                }
            }
        }
    }
}

extension View {
    /// Lägg till en hover-tooltip (för macOS/iPad med trackpad)
    func hoverTooltip(_ text: String, shortcut: String? = nil) -> some View {
        modifier(HoverTooltipModifier(text: text, shortcut: shortcut))
    }
}

// MARK: - Feature Tip

/// En engångs-tip som visas vid första användning av en funktion
struct FeatureTip: Identifiable {
    let id: String
    let title: String
    let message: String
    let icon: String
    
    static let euclidean = FeatureTip(
        id: "euclidean_tip",
        title: "Euclidean Generator",
        message: "Generera matematiskt perfekta rytmiska mönster med ett klick.",
        icon: "circle.hexagongrid"
    )
    
    static let paintMode = FeatureTip(
        id: "paint_mode_tip",
        title: "Paint Mode",
        message: "Dra horisontellt för att rita flera steg på en gång.",
        icon: "paintbrush"
    )
    
    static let humanize = FeatureTip(
        id: "humanize_tip",
        title: "Humanize",
        message: "Lägg till naturlig variation i velocity och timing.",
        icon: "wand.and.stars"
    )
    
    static let advancedMode = FeatureTip(
        id: "advanced_mode_tip",
        title: "Avancerat läge",
        message: "Lås upp fler funktioner som probability, ratchet och CV-utgångar.",
        icon: "slider.horizontal.3"
    )
}

/// Manager för feature tips
@MainActor
class FeatureTipManager: ObservableObject {
    @Published var currentTip: FeatureTip?
    
    private let userDefaults = UserDefaults.standard
    
    func showTipIfNeeded(_ tip: FeatureTip) {
        let key = "hasSeenTip_\(tip.id)"
        guard !userDefaults.bool(forKey: key) else { return }
        
        currentTip = tip
        userDefaults.set(true, forKey: key)
    }
    
    func dismissTip() {
        withAnimation {
            currentTip = nil
        }
    }
    
    func resetAllTips() {
        // För debugging/testing
        let tips: [FeatureTip] = [.euclidean, .paintMode, .humanize, .advancedMode]
        for tip in tips {
            userDefaults.removeObject(forKey: "hasSeenTip_\(tip.id)")
        }
    }
}

/// View för att visa feature tip
struct FeatureTipView: View {
    let tip: FeatureTip
    let onDismiss: () -> Void
    let onLearnMore: (() -> Void)?
    
    var body: some View {
        HStack(spacing: DS.Space.m) {
            // Icon
            Image(systemName: tip.icon)
                .font(.system(size: 24))
                .foregroundStyle(DS.Color.led)
                .frame(width: 40)
            
            // Content
            VStack(alignment: .leading, spacing: DS.Space.xxs) {
                Text("💡 " + tip.title)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text(tip.message)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: DS.Space.xs) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Color.textMuted)
                }
                
                if let learnMore = onLearnMore {
                    Button(action: learnMore) {
                        Text("Mer")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.accent)
                    }
                }
            }
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .stroke(DS.Color.led.opacity(0.3), lineWidth: DS.Stroke.thin)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

/// Container modifier för feature tips
struct FeatureTipContainerModifier: ViewModifier {
    @ObservedObject var tipManager: FeatureTipManager
    var onLearnMore: ((FeatureTip) -> Void)?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let tip = tipManager.currentTip {
                FeatureTipView(
                    tip: tip,
                    onDismiss: { tipManager.dismissTip() },
                    onLearnMore: onLearnMore != nil ? { onLearnMore?(tip) } : nil
                )
                .padding(.horizontal, DS.Space.l)
                .padding(.top, DS.Space.xl)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: tipManager.currentTip?.id)
    }
}

extension View {
    func featureTips(_ tipManager: FeatureTipManager, onLearnMore: ((FeatureTip) -> Void)? = nil) -> some View {
        modifier(FeatureTipContainerModifier(tipManager: tipManager, onLearnMore: onLearnMore))
    }
}
