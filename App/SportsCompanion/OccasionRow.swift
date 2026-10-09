import SwiftUI

/// A race weekend is one row until you ask for more. This is what keeps
/// a fifteen-event day behaving like a three-event day.
struct OccasionRow: View {
    let name: String
    let sessions: [Event]
    var now: Date

    @State private var expanded = false
    @ScaledMetric(relativeTo: .subheadline) private var timeWidth: CGFloat = 52
    @ScaledMetric(relativeTo: .subheadline) private var gutter: CGFloat = 16
    @Environment(\.dynamicTypeSize) private var typeSize

    private var stacked: Bool { typeSize >= .accessibility1 }

    /// An occasion has no single start time, so the leading column stays empty
    /// and the span moves into the subtitle where it cannot wrap.
    private var subtitle: String {
        let count = "\(sessions.count) sessions"
        guard let first = sessions.first, let last = sessions.last else { return count }
        let a = first.weekdayShort, b = last.weekdayShort
        return a == b ? count : "\(a)–\(b) · \(count)"
    }

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            ForEach(sessions) { session in
                sessionRow(session)
            }
            .padding(.leading, stacked ? 0 : timeWidth + gutter)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: gutter) {
                if !stacked { Color.clear.frame(width: timeWidth, height: 1) }
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 5)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(name), \(subtitle)")
        }
        .tint(.secondary)
        .onChange(of: expanded) { Haptics.light() }
    }

    @ViewBuilder
    private func sessionRow(_ session: Event) -> some View {
        switch session.state(at: now) {
        case .sealed:
            NavigationLink { WatchView(event: session, now: now) }
                label: { EventRow(event: session, now: now, compact: true) }
        case .live:
            WatchNowButton(event: session) {
                EventRow(event: session, now: now, compact: true)
            }
        case .ahead, .gone:
            EventRow(event: session, now: now, compact: true)
        }
    }
}
