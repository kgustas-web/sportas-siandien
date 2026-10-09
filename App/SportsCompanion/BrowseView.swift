import SwiftUI

/// The second mode. Today answers "what deserves my evening"; Browse answers
/// "show me the F1 season" or "when does Žalgiris next play". Different
/// question, so it gets its own place rather than another filter.
///
/// Forward-looking only. The past has its own door.
struct BrowseView: View {
    var events: [Event]
    var now: Date

    private var upcoming: [Event] {
        events.filter { $0.start >= Calendar.current.startOfDay(for: now) }
    }

    private var sports: [(name: String, count: Int)] {
        Dictionary(grouping: upcoming, by: \.sport)
            .map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(sports.enumerated()), id: \.element.name) { index, sport in
                    NavigationLink {
                        CompetitionsView(sport: sport.name, events: upcoming, now: now)
                    } label: {
                        IndexRow(title: sport.name, count: sport.count)
                    }
                    .buttonStyle(TimelineRowStyle())
                    if index < sports.count - 1 { RowSeparator() }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollEdgeBackground()
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Inside one sport: its competitions. For Formula One these are the Grands
/// Prix themselves, which is the right grain for browsing a season.
struct CompetitionsView: View {
    let sport: String
    var events: [Event]
    var now: Date

    private var competitions: [(name: String, count: Int, next: Date)] {
        Dictionary(grouping: events.filter { $0.sport == sport }, by: \.competition)
            .map { (name: $0.key,
                    count: $0.value.count,
                    next: $0.value.map(\.start).min() ?? .distantFuture) }
            .sorted { $0.next < $1.next }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(competitions.enumerated()), id: \.element.name) { index, comp in
                    NavigationLink {
                        FixturesView(title: comp.name,
                                     events: events.filter { $0.competition == comp.name },
                                     now: now)
                    } label: {
                        IndexRow(title: comp.name,
                                 subtitle: Fmt.dayWithDate.string(from: comp.next),
                                 count: comp.count)
                    }
                    .buttonStyle(TimelineRowStyle())
                    if index < competitions.count - 1 { RowSeparator() }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollEdgeBackground()
        .navigationTitle(sport)
        .navigationBarTitleDisplayMode(.large)
    }
}

/// The fixtures themselves, in the same shape as the timeline — same rows,
/// same day headers, same prominence. Browsing and deciding should not feel
/// like two different apps.
struct FixturesView: View {
    let title: String
    var events: [Event]
    var now: Date

    private var days: [Day] { Agenda.forward(from: events, now: now) }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(days) { day in
                    DayMarker(text: day.label, first: day.id == days.first?.id)
                    ForEach(Array(day.items.enumerated()), id: \.element.id) { index, item in
                        fixtureRow(item)
                        if index < day.items.count - 1 { RowSeparator() }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .scrollEdgeBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func fixtureRow(_ item: AgendaItem) -> some View {
        switch item {
        case .occasion(let name, let sessions):
            OccasionRow(name: name, sessions: sessions, now: now)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)

        case .event(let event):
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
        }
    }
}

/// A plain index row. Count sits before the chevron the way iOS puts a
/// secondary value there.
struct IndexRow: View {
    let title: String
    var subtitle: String?
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body)
                if let subtitle {
                    Text(subtitle).font(.footnote).foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 8)
            Text("\(count)")
                .font(.body)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(count) upcoming")
    }
}
