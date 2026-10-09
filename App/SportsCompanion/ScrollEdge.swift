import SwiftUI

extension View {
    /// A translucent bar with nothing behind it lets a row's text collide with
    /// the title. The harder edge treatment keeps the title legible while the
    /// list runs under it.
    @ViewBuilder
    func scrollEdgeBackground() -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(.hard, for: .top)
        } else {
            self
        }
    }
}
