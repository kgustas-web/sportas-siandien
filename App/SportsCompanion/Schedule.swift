import Foundation

/// Fetches the feeds, cleans them, and hands back events.
/// Cached to disk so a launch with no network still shows the day.
@Observable
final class Schedule {
    private(set) var events: [Event] = []
    private(set) var lastRefresh: Date?

    private let cacheDir = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("feeds", isDirectory: true)

    init() {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        events = build(from: cachedTexts())   // instant, from disk
    }

    /// Never blocks the first paint. The cache is already on screen.
    func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            for feed in sources {
                group.addTask { [weak self] in await self?.download(feed) }
            }
        }
        let rebuilt = build(from: cachedTexts())
        await MainActor.run {
            if !rebuilt.isEmpty { self.events = rebuilt }
            self.lastRefresh = Date()
        }
    }

    // MARK: Fetching

    private func file(for feed: Source) -> URL {
        cacheDir.appendingPathComponent(String(feed.url.hashValue.magnitude) + ".ics")
    }

    private func download(_ feed: Source) async {
        guard !feed.url.isEmpty, let url = URL(string: feed.url) else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let text = String(data: data, encoding: .utf8),
              text.contains("BEGIN:VCALENDAR")
        else { return }
        try? text.write(to: file(for: feed), atomically: true, encoding: .utf8)
    }

    private func cachedTexts() -> [(Source, String)] {
        sources.compactMap { feed in
            (try? String(contentsOf: file(for: feed), encoding: .utf8)).map { (feed, $0) }
        }
    }

    // MARK: Building

    private func build(from cached: [(Source, String)]) -> [Event] {
        let horizon = Date().addingTimeInterval(-60 * 60 * 24 * 21)

        // Hand-entered events go through the same reason lookup as feed ones.
        // Athletics lives here, and athletics is where the athletes are.
        var out = manualEvents.map { event -> Event in
            var e = event
            if e.reason == nil {
                e.reason = reason(for: e.title, competition: e.competition, sport: e.sport)
            }
            if !e.lithuanian {
                e.lithuanian = isLithuanian(e.title) || isLithuanian(e.competition)
            }
            e.prominence = prominence(title: e.title, reason: e.reason)
            return e
        }

        for (feed, text) in cached {
            for raw in ICS.parse(text) where raw.start > horizon {
                if let event = convert(raw, feed: feed) { out.append(event) }
            }
        }
        return dedupe(out).sorted { $0.start < $1.start }
    }

    /// Two sources can describe the same event — a team's own feed and the
    /// league it plays in. Match on when it starts and which words are in it,
    /// so "Ajax - PSV" and "PSV @ Ajax" collapse too. First source wins,
    /// which is why the narrower ones are listed first.
    private func dedupe(_ events: [Event]) -> [Event] {
        var seen = Set<String>()
        var out: [Event] = []
        for e in events {
            let slot = Int(e.start.timeIntervalSince1970 / 900)   // 15 minutes
            let words = e.title
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count >= 3 }
                .sorted()
                .joined(separator: "-")
            let key = "\(slot)|\(words)"
            if seen.insert(key).inserted { out.append(e) }
        }
        return out
    }

    private func convert(_ raw: ICS.Raw, feed: Source) -> Event? {
        // Clean first, always, before anything reaches a view.
        let cleaned = ICS.stripResults(raw.summary)
        guard !cleaned.isEmpty else { return nil }

        if feed.onlyFollowed, !admits(cleaned) { return nil }

        var title = cleaned
        if let prefix = feed.stripPrefix, title.hasPrefix(prefix) {
            title.removeFirst(prefix.count)
        }

        var competition = feed.competition
        var occasion: String?

        switch feed.layout {
        case .versus:
            // A trailing [TAG] names the competition better than the feed does.
            let (stripped, tag) = ICS.extractTag(title)
            title = stripped
            if let tag { competition = tag }

        case .session:
            // "Parent - Part" splits into an occasion and the part itself.
            if let dash = title.range(of: " - ", options: .backwards) {
                occasion = String(title[title.startIndex..<dash.lowerBound])
                title = String(title[dash.upperBound...])
                competition = occasion ?? competition
            } else if let categories = raw.categories, !categories.isEmpty {
                competition = categories
            }

        case .plain:
            break
        }

        let minutes = raw.end.map { Int($0.timeIntervalSince(raw.start) / 60) } ?? 120

        return Event(
            title: title,
            competition: competition,
            sport: feed.sport,
            lithuanian: isLithuanian(title),
            prominence: prominence(title: title,
                                   reason: reason(for: title, competition: competition, sport: feed.sport)),
            start: raw.start,
            minutes: max(30, min(minutes, 300)),
            channel: feed.channel,
            reason: reason(for: title, competition: competition, sport: feed.sport),
            occasion: feed.groupsParts ? occasion : nil
        )
    }

    /// What earns a stronger row. Deliberately few rules, all readable:
    /// something you follow, your country, a line worth reading, or two
    /// notable clubs meeting. Everything else stays, quietly.
    private func prominence(title: String, reason: String?) -> Prominence {
        if follows.contains(where: { $0.matches(title) }) { return .surfaced }
        if isLithuanian(title) { return .surfaced }
        if reason != nil { return .surfaced }

        let big = notableClubs.filter { title.localizedCaseInsensitiveContains($0) }.count
        if big >= 2 { return .surfaced }
        if big == 1 { return .normal }
        return .quiet
    }

    /// The Lithuania lens: any event carrying a Lithuanian club, the country,
    /// or a name from the athlete roster.
    private func isLithuanian(_ title: String) -> Bool {
        if lithuanianFollows.contains(where: { title.localizedCaseInsensitiveContains($0) }) {
            return true
        }
        return athletes.contains { title.localizedCaseInsensitiveContains($0.name) }
    }

    /// A broad competition admits a match involving something you follow, or a
    /// meeting between two notable clubs. Everything else in it is noise.
    private func admits(_ title: String) -> Bool {
        if follows.contains(where: { $0.matches(title) }) { return true }
        let big = notableClubs.filter { title.localizedCaseInsensitiveContains($0) }
        return big.count >= 2
    }

    /// Your own line first. Failing that, an athlete who competes here —
    /// which is how an unfamiliar name arrives with an explanation attached.
    private func reason(for title: String, competition: String, sport: String) -> String? {
        if let mine = reasons.first(where: { title.localizedCaseInsensitiveContains($0.key) }) {
            return mine.value
        }
        let haystack = title + " " + competition
        return athletes.first { athlete in
            athlete.sport == sport &&
            athlete.competitions.contains { haystack.localizedCaseInsensitiveContains($0) }
        }?.note
    }
}
