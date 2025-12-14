import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Provides haptic feedback for touch interactions
/// Make Noise philosophy: immediate, tactile feedback
enum HapticEngine {
    
    /// Light impact - step selection, minor interactions
    static func light() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    /// Medium impact - step toggle, value changes
    static func medium() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    /// Heavy impact - pattern change, major actions
    static func heavy() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    /// Soft impact - subtle feedback
    static func soft() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }
    
    /// Rigid impact - precise feedback
    static func rigid() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        #endif
    }
    
    /// Success notification - save complete, export done
    static func success() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// Warning notification - approaching limit
    static func warning() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    /// Error notification - action failed
    static func error() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    /// Selection changed - scrolling through items
    static func selection() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
    
    /// Custom impact with intensity (0.0 - 1.0)
    static func impact(intensity: CGFloat) {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: intensity)
        #endif
    }
    
    /// Playback tick - for step advancement (very light)
    static func tick() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.3)
        #endif
    }
    
    /// Beat emphasis - stronger tick on beat
    static func beat() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 0.6)
        #endif
    }
    
    /// Downbeat emphasis - strongest tick on bar start
    static func downbeat() {
        #if canImport(UIKit) && !os(watchOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 0.8)
        #endif
    }
}

// MARK: - Conditional Haptics based on settings

extension HapticEngine {
    /// Check if haptics are enabled in accessibility settings
    static var isEnabled: Bool {
        // Could check UserDefaults or AccessibilityManager here
        return true
    }
    
    /// Conditionally trigger haptic if enabled
    static func conditionalLight() {
        guard isEnabled else { return }
        light()
    }
    
    static func conditionalMedium() {
        guard isEnabled else { return }
        medium()
    }
    
    static func conditionalSelection() {
        guard isEnabled else { return }
        selection()
    }
}
