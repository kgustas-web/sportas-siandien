import SwiftUI

/// A live row goes straight to the broadcaster. No screen in between,
/// because there is only one thing to do.
struct WatchNowButton<Label: View>: View {
    let event: Event
    @ViewBuilder var label: Label

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            guard let channel = event.channel,
                  let string = channelURLs[channel],
                  let url = URL(string: string) else { return }
            Haptics.light()
            openURL(url)
        } label: {
            label
        }
        .buttonStyle(RowButtonStyle())
        .accessibilityHint(event.channel.map { "Opens \($0)" } ?? "")
    }
}

/// List gives NavigationLink a pressed state for free. A plain Button does not,
/// so a live row would feel dead without this. The negative padding lets the
/// highlight bleed to the row edges the way a real list cell does.
struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background {
                (configuration.isPressed ? Color(uiColor: .systemGray5) : Color.clear)
                    .padding(.horizontal, -20)
                    .padding(.vertical, -9)
            }
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
