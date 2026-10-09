import Foundation

struct Event: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var competition: String
    /// Presentation only — drives the filter. Nothing in the model branches on it.
    var sport: String = "Other"
    /// Part of the Lithuania lens. Also presentation only.
    var lithuanian: Bool = false
    /// How much weight the row carries. Never affects whether it appears.
    var prominence: Prominence = .normal
    var start: Date
    var minutes: Int = 120
    var channel: String?
    var reason: String?
    var note: String?

    /// Sessions sharing an occasion collapse into one row. Set it on a race weekend.
    var occasion: String?

    var watchableFor: TimeInterval = 60 * 60 * 24 * 7

    var end: Date { start.addingTimeInterval(TimeInterval(minutes * 60)) }
    var expiresAt: Date { end.addingTimeInterval(watchableFor) }
}

enum EventState { case ahead, live, sealed, gone }

extension Event {
    func state(at now: Date) -> EventState {
        if now < start { return .ahead }
        if now < end { return .live }
        if now < expiresAt { return .sealed }
        return .gone
    }

    func availability(at now: Date) -> String? {
        guard state(at: now) == .sealed else { return nil }
        return now.timeIntervalSince(end) < watchableFor / 2 ? "Full replay" : "Highlights"
    }

    /// Only surfaced when the deadline is close enough to change a decision.
    func expiryNote(at now: Date) -> String? {
        guard state(at: now) == .sealed else { return nil }
        let left = expiresAt.timeIntervalSince(now)
        guard left < 60 * 60 * 48 else { return nil }
        return left < 60 * 60 * 12
            ? "until \(Fmt.time.string(from: expiresAt))"
            : "until \(Fmt.weekday.string(from: expiresAt))"
    }

    var timeLabel: String { Fmt.time.string(from: start) }
    var weekdayShort: String { Fmt.weekdayShort.string(from: start) }
}

// MARK: - Formatters, made once

enum Fmt {
    static let time: DateFormatter = f("HH:mm")
    static let weekday: DateFormatter = f("EEEE")
    static let weekdayShort: DateFormatter = f("EEE")
    static let dayInWeek: DateFormatter = f("EEEE")
    static let dayWithDate: DateFormatter = f("EEE d MMMM")

    private static func f(_ format: String) -> DateFormatter {
        let d = DateFormatter()
        d.locale = .current
        d.setLocalizedDateFormatFromTemplate(format)
        d.dateFormat = format
        return d
    }
}

// MARK: - A day is a list of items; an item is one event or one occasion

enum AgendaItem: Identifiable {
    case event(Event)
    case occasion(name: String, sessions: [Event])

    var id: String {
        switch self {
        case .event(let e):        return e.id.uuidString
        case .occasion(let n, let s): return n + (s.first?.id.uuidString ?? "")
        }
    }
    var sortDate: Date {
        switch self {
        case .event(let e):     return e.start
        case .occasion(_, let s): return s.first?.start ?? .distantFuture
        }
    }
}

struct Day: Identifiable {
    let id: Date
    var date: Date
    var items: [AgendaItem]

    var label: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInTomorrow(date) { return "Tomorrow" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let withinWeek = abs(date.timeIntervalSinceNow) < 60 * 60 * 24 * 6
        return (withinWeek ? Fmt.dayInWeek : Fmt.dayWithDate).string(from: date)
    }
}

enum Agenda {
    /// Today first, then ahead. An occasion sits on the day of its first session.
    static func forward(from all: [Event], now: Date) -> [Day] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        let live = all.filter { $0.state(at: now) != .gone }

        // An occasion sits on the day of its first session that has not finished,
        // so a race weekend moves with you rather than vanishing on Friday night.
        var claimed = Set<UUID>()
        var items: [(Date, AgendaItem)] = []

        for name in orderedOccasions(in: live) {
            let remaining = live
                .filter { $0.occasion == name }
                .filter { cal.startOfDay(for: $0.start) >= today }
                .sorted { $0.start < $1.start }
            guard let first = remaining.first, remaining.count > 1 else { continue }
            remaining.forEach { claimed.insert($0.id) }
            items.append((cal.startOfDay(for: first.start),
                          .occasion(name: name, sessions: remaining)))
        }

        for e in live where !claimed.contains(e.id) {
            let day = cal.startOfDay(for: e.start)
            guard day >= today else { continue }
            items.append((day, .event(e)))
        }

        return group(items)
    }

    /// Only what can still be acted on. Reverse chronological. Not an archive.
    static func earlier(from all: [Event], now: Date) -> [Day] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        let past = all.filter {
            $0.state(at: now) == .sealed && cal.startOfDay(for: $0.start) < today
        }
        let items = past.map { (cal.startOfDay(for: $0.start), AgendaItem.event($0)) }
        return group(items).reversed().map {
            Day(id: $0.id, date: $0.date, items: $0.items.reversed())
        }
    }

    static func next(from all: [Event], now: Date) -> Event? {
        all.filter { $0.start > now }.min { $0.start < $1.start }
    }

    static func earlierCount(from all: [Event], now: Date) -> Int {
        earlier(from: all, now: now).reduce(0) { $0 + $1.items.count }
    }

    private static func orderedOccasions(in events: [Event]) -> [String] {
        var seen: [String] = []
        for e in events.sorted(by: { $0.start < $1.start }) {
            if let o = e.occasion, !seen.contains(o) { seen.append(o) }
        }
        return seen
    }

    private static func group(_ items: [(Date, AgendaItem)]) -> [Day] {
        Dictionary(grouping: items, by: { $0.0 })
            .map { key, value in
                Day(id: key, date: key,
                    items: value.map(\.1).sorted { $0.sortDate < $1.sortDate })
            }
            .sorted { $0.date < $1.date }
    }
}
