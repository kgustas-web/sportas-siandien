import UIKit

// Small, deliberate, and only where the phone should answer back.
enum Haptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    /// Revealing a result spends something. It should feel like a decision.
    static func spend() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
    }
}
