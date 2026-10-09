import SwiftUI

/// Where each day's block currently sits, so the bar can name the one you
/// are reading. Reported per block rather than per header: a header scrolls
/// away and stops existing, but the block spanning the top of the screen is
/// always on screen by definition.
struct DayAnchor: Equatable {
    let label: String
    let top: CGFloat
    let bottom: CGFloat
}

struct DayHeaderKey: PreferenceKey {
    static let defaultValue: [DayAnchor] = []
    static func reduce(value: inout [DayAnchor], nextValue: () -> [DayAnchor]) {
        value.append(contentsOf: nextValue())
    }
}

/// One header treatment for every day. Today is not a different size,
/// only a different word.
struct DayMarker: View {
    let text: String
    /// The first header sits tighter to the top than the ones between days.
    var first: Bool = false

    var body: some View {
        Text(text)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, first ? 4 : 34)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A hairline that lines up with the text, not the screen edge.
struct RowSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(uiColor: .separator))
            .frame(height: 0.5)
            .padding(.leading, 20)
    }
}

/// The press state a List gives a row for free, rebuilt for a plain stack.
struct TimelineRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(configuration.isPressed
                        ? Color(uiColor: .systemGray5)
                        : Color.clear)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
