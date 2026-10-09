import SwiftUI

/// One question: how do I watch this?
/// Revealing a result is the exit from that question, not a second one —
/// which is why it sits alone at the bottom of the screen.
struct WatchView: View {
    let event: Event
    var now: Date

    @Environment(\.openURL) private var openURL
    @State private var revealed = false

    private var state: EventState { event.state(at: now) }
    private var hasReplay: Bool { event.availability(at: now) == "Full replay" }
    private var link: URL? {
        guard let c = event.channel, let s = channelURLs[c] else { return nil }
        return URL(string: s)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(event.title)
                    .font(.largeTitle.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(whenLabel)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                if state == .live {
                    HStack(spacing: 7) {
                        Circle().fill(.tint).frame(width: 7, height: 7)
                        Text("On now").font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)
                }

                if let reason = event.reason {
                    Text(reason)
                        .font(.body)
                        .padding(.top, 22)
                        .fixedSize(horizontal: false, vertical: true)
                }

                actions.padding(.top, 30)

                if let expiry = event.expiryNote(at: now) {
                    Text("Available \(expiry).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }

                if state == .sealed {
                    Spacer(minLength: 56)
                    revealSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .containerRelativeFrame(.vertical, alignment: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: What you can do about it

    @ViewBuilder
    private var actions: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch state {
            case .live:
                if let channel = event.channel {
                    primary("Watch on \(channel)")
                }

            case .sealed:
                primary(hasReplay ? "Watch full replay" : "Extended highlights")
                if hasReplay { secondary("Extended highlights") }

            case .ahead:
                if let channel = event.channel {
                    secondary("Open \(channel)")
                    Text("Starts \(countdown).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                } else {
                    Text("No broadcaster listed yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

            case .gone:
                Text("No longer available to watch.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func primary(_ title: String) -> some View {
        Button {
            Haptics.light()
            if let link { openURL(link) }
        } label: {
            Text(title).fontWeight(.semibold).frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(link == nil)
    }

    private func secondary(_ title: String) -> some View {
        Button {
            Haptics.light()
            if let link { openURL(link) }
        } label: {
            Text(title).frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(link == nil)
    }

    /// The exit from the question. Apart from everything else, and never in passing.
    private var revealSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            if revealed {
                Text("Opened in Safari.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 14)
                    .transition(.opacity)
            } else {
                Button("Show result") {
                    Haptics.spend()
                    withAnimation(.easeOut(duration: 0.2)) { revealed = true }
                    openSearch()
                }
                .font(.subheadline)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(.vertical, 14)
                .accessibilityHint("Opens a web search. This will show you the result.")
            }
        }
    }

    // MARK: Wording

    private var whenLabel: String {
        let cal = Calendar.current
        let day: String
        if cal.isDateInYesterday(event.start) { day = "Yesterday" }
        else if cal.isDateInToday(event.start) { day = "Today" }
        else if cal.isDateInTomorrow(event.start) { day = "Tomorrow" }
        else if abs(event.start.timeIntervalSince(now)) < 60 * 60 * 24 * 6 {
            day = Fmt.dayInWeek.string(from: event.start)
        } else {
            day = Fmt.dayWithDate.string(from: event.start)
        }
        return "\(day) at \(event.timeLabel) · \(event.competition)"
    }

    private var countdown: String {
        let mins = Int(event.start.timeIntervalSince(now) / 60)
        if mins < 60 { return "in \(max(mins, 1)) minutes" }
        if mins < 60 * 24 { return "in \(mins / 60) hours" }
        return "in \(mins / (60 * 24)) days"
    }

    /// The app never stores a result. Revealing simply stops protecting you.
    private func openSearch() {
        let q = "\(event.title) \(event.competition) result"
        guard let e = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let u = URL(string: "https://duckduckgo.com/?q=\(e)") else { return }
        openURL(u)
    }
}
