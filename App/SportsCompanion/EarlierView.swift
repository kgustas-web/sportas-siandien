import SwiftUI

/// One question: what can I still watch?
/// Holds only what can still be acted on, so it has no empty state —
/// with nothing watchable, the row that leads here does not exist.
struct EarlierView: View {
    var events: [Event]
    var now: Date

    private var days: [Day] { Agenda.earlier(from: events, now: now) }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(days) { day in
                    DayMarker(text: day.label, first: day.id == days.first?.id)
                    ForEach(Array(day.items.enumerated()), id: \.element.id) { index, item in
                        if case .event(let event) = item {
                            NavigationLink {
                                WatchView(event: event, now: now)
                            } label: {
                                HStack(spacing: 10) {
                                    EventRow(event: event, now: now)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 9)
                            }
                            .buttonStyle(TimelineRowStyle())
                            if index < day.items.count - 1 { RowSeparator() }
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .scrollEdgeBackground()
        .navigationTitle("Earlier")
        .navigationBarTitleDisplayMode(.inline)
    }
}
