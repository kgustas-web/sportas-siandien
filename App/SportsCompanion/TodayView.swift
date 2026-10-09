import SwiftUI

struct TodayView: View {
    @State private var schedule = Schedule()
    @State private var now = Date()
    @State private var lens: Lens = .all
    @State private var barDay: String?
    @Environment(\.scenePhase) private var phase

    private let tick = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if earlierCount > 0 { earlierRow }
                    browseRow
                    if todayIsEmpty { nothingBlock }

                    ForEach(days) { day in
                        daySection(day)
                    }
                }
                .padding(.bottom, 40)
            }
            .coordinateSpace(name: "agenda")
            .onPreferenceChange(DayHeaderKey.self) { anchors in
                // The block straddling the top of the screen is the day you
                // are reading. Nothing above it is left to guess from.
                let current = anchors.first { $0.top <= 8 && $0.bottom > 8 }
                    ?? anchors.filter { $0.bottom <= 8 }.max { $0.bottom < $1.bottom }
                if current?.label != barDay {
                    withAnimation(.easeOut(duration: 0.18)) { barDay = current?.label }
                }
            }
            .navigationTitle(barDay ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .scrollEdgeBackground()
            .toolbar {
                if availableSports.count > 1 || hasLithuanian {
                    ToolbarItem(placement: .topBarTrailing) { filterMenu }
                }
            }
        }
        .onReceive(tick) { now = $0 }
        .task { await schedule.refresh() }
        .onChange(of: phase) { _, new in
            // Coming back to the app is the only refresh trigger. A day's
            // fixtures do not change while you are looking at them.
            if new == .active { Task { await schedule.refresh() } }
        }
    }

    // MARK: Sections

    private func daySection(_ day: Day) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DayMarker(text: day.label,
                      first: day.id == days.first?.id && !hasUtilityRows)
            ForEach(Array(day.items.enumerated()), id: \.element.id) { index, item in
                row(for: item)
                if index < day.items.count - 1 { RowSeparator() }
            }
        }
        .background(
            GeometryReader { geo in
                let f = geo.frame(in: .named("agenda"))
                Color.clear.preference(key: DayHeaderKey.self,
                                       value: [DayAnchor(label: day.label,
                                                         top: f.minY, bottom: f.maxY)])
            }
        )
    }

    @ViewBuilder
    private func row(for item: AgendaItem) -> some View {
        switch item {
        case .occasion(let name, let sessions):
            OccasionRow(name: name, sessions: sessions, now: now)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)

        case .event(let event):
            // Every row opens its event. An inert row reads as broken, and
            // "where do I watch this" is worth a tap even before it starts.
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

    // MARK: Utility rows

    private var earlierRow: some View {
        VStack(spacing: 0) {
            NavigationLink {
                EarlierView(events: schedule.events, now: now)
            } label: {
                HStack {
                    Text(earlierCount == 1 ? "1 from earlier" : "\(earlierCount) from earlier")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(TimelineRowStyle())
            RowSeparator()
        }
    }

    /// Browse is a place you go on purpose, not a permanent half of the UI.
    private var browseRow: some View {
        VStack(spacing: 0) {
            NavigationLink {
                BrowseView(events: schedule.events, now: now)
            } label: {
                HStack {
                    Text("Browse")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(TimelineRowStyle())
            RowSeparator()
        }
    }

    private var nothingBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(nothingLine).font(.title2)
            if let next = Agenda.next(from: visible, now: now) {
                Text("Next: \(next.title), \(nextLabel(next)).")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 6)
        .accessibilityElement(children: .combine)
    }

    /// A menu rather than a segmented control or a row of chips: it costs no
    /// vertical space, it is a standard iOS control, and on a quiet day it is
    /// a single glyph. The filled variant is the system's way of saying a
    /// filter is on.
    private var filterMenu: some View {
        Menu {
            Picker("View", selection: $lens) {
                Text("All").tag(Lens.all)
                // Lithuania cuts across every sport, so it sits on its own.
                if hasLithuanian { Text("Lithuania").tag(Lens.lithuania) }
                ForEach(availableSports, id: \.self) { name in
                    Text(name).tag(Lens.sport(name))
                }
            }
        } label: {
            Image(systemName: lens == .all
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .onChange(of: lens) { Haptics.selection() }
        .accessibilityLabel(lens.label.map { "View: \($0)" } ?? "Change view")
    }

    // MARK: Derived

    /// The filter is a view over the same timeline. It narrows which events are
    /// grouped, and nothing below it knows the filter exists.
    private var visible: [Event] {
        switch lens {
        case .all:             return schedule.events
        case .lithuania:       return schedule.events.filter(\.lithuanian)
        case .sport(let name): return schedule.events.filter { $0.sport == name }
        }
    }

    private var days: [Day] { Agenda.forward(from: visible, now: now) }
    private var earlierCount: Int { Agenda.earlierCount(from: schedule.events, now: now) }
    private var hasUtilityRows: Bool { true }   // Browse is always there

    private var upcomingEvents: [Event] {
        Agenda.forward(from: schedule.events, now: now)
            .flatMap(\.items)
            .flatMap { item -> [Event] in
                switch item {
                case .event(let e):       return [e]
                case .occasion(_, let s): return s
                }
            }
    }

    private var availableSports: [String] { Set(upcomingEvents.map(\.sport)).sorted() }
    private var hasLithuanian: Bool { upcomingEvents.contains(where: \.lithuanian) }

    private var todayIsEmpty: Bool {
        !days.contains { Calendar.current.isDateInToday($0.date) }
    }

    private var nothingLine: String {
        Calendar.current.component(.hour, from: now) < 12 ? "Nothing today." : "Nothing tonight."
    }

    private func nextLabel(_ e: Event) -> String {
        let withinWeek = e.start.timeIntervalSince(now) < 60 * 60 * 24 * 6
        let day = withinWeek ? Fmt.dayInWeek.string(from: e.start)
                             : Fmt.dayWithDate.string(from: e.start)
        return "\(day) \(e.timeLabel)"
    }

}
