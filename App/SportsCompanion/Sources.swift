import Foundation

// ─────────────────────────────────────────────────────────────
//  Two concepts, neither of which knows what a sport is.
//
//    Source × Follow → Events
//
//  A Source is where events come from. A Follow is a story you care about:
//  a team, a country, an athlete, a tournament. Broad sources are cut down
//  by your Follows. Narrow ones are not.
// ─────────────────────────────────────────────────────────────

/// The shape of a contest, not the sport it belongs to. There are only three.
enum Layout {
    /// "Home - Away [TAG]" — football, basketball, tennis, Davis Cup.
    case versus
    /// "Parent - Part" — race weekends, athletics sessions, Olympic days.
    case session
    /// The title is the whole event — a one-day race, a final, a stage.
    case plain
}

struct Source {
    var url: String
    var layout: Layout
    /// Used when the feed does not name the competition itself.
    var competition: String
    /// Presentation only. Drives the filter; the model does not branch on it.
    var sport: String
    var channel: String?

    /// Dropped from the front of every title. Feeds like to prefix themselves.
    var stripPrefix: String?

    /// Parts of one occasion collapse into a single row. Only turn this on
    /// where a source genuinely emits parts of one thing.
    var groupsParts: Bool = false

    /// A whole-competition source carries everything in it. Following a
    /// competition is not the same as wanting all of it.
    var onlyFollowed: Bool = false
}

/// A story. The app does not care which kind it is.
struct Follow {
    var name: String
    /// Spellings that appear in event titles.
    var aliases: [String]

    init(_ name: String, _ aliases: String...) {
        self.name = name
        self.aliases = aliases.isEmpty ? [name] : aliases + [name]
    }

    func matches(_ title: String) -> Bool {
        aliases.contains { title.localizedCaseInsensitiveContains($0) }
    }
}

// MARK: - What you follow

let follows: [Follow] = [
    // Basketball — the EuroLeague feed spells it "Zalgiris Kaunas"
    Follow("BC Žalgiris", "Zalgiris Kaunas", "Žalgiris Kaunas"),

    // Football
    Follow("Ajax"),
    Follow("Žalgiris Vilnius", "Zalgiris Vilnius"),
    Follow("Kauno Žalgiris", "Kauno Zalgiris"),

    // Country — covers national teams and international championships
    Follow("Lithuania", "Lietuva", "Litouwen", "Litauen", "Lituanie"),
]

/// Follows that make an event part of the Lithuania view. The lens cuts across
/// every sport, which is the point: following a country is a story, not a sport.
let lithuanianFollows: [String] = [
    "Zalgiris", "Žalgiris", "Lithuania", "Lietuva", "Litouwen", "Litauen", "Lituanie",
]

/// Clubs whose meetings are worth surfacing even when you follow neither.
/// A broad competition admits a match when a Follow is in it, or when two of
/// these meet. This is the honest stand-in for "the biggest matches": the feeds
/// carry no round information, so knockout stages cannot be detected at all.
let notableClubs: [String] = [
    "Real Madrid", "Barcelona", "Bayern", "Liverpool", "Manchester City",
    "Arsenal", "Inter", "Milan", "Juventus", "Paris", "Chelsea",
    "Manchester United", "Tottenham", "Atlético", "Atletico", "Dortmund",
]

// MARK: - Where events come from

let sources: [Source] = [

    // ── Basketball ────────────────────────────────────────────────────
    // The full EuroLeague season, Žalgiris included. Not filtered: the
    // competition is followed in its own right. Titles carry a 🏀 prefix.
    Source(url: euroleagueICS,
           layout: .versus, competition: "EuroLeague", sport: "Basketball",
           channel: "Go3", stripPrefix: "🏀 "),

    // ── Formula One ───────────────────────────────────────────────────
    Source(url: "https://bmorganqwe98.github.io/racing-2026-calendar/f1.ics",
           layout: .session, competition: "Formula 1", sport: "Formula One",
           channel: "Go3", stripPrefix: "F1 ", groupsParts: true),

    // ── Football: teams ───────────────────────────────────────────────
    // A team's own feed is complete — league, cup and European ties, the
    // last of these tagged [CL] or [EL], which overrides `competition`.
    Source(url: "https://ics.fixtur.es/v2/Ajax.ics",
           layout: .versus, competition: "Eredivisie", sport: "Football",
           channel: "Go3"),

    Source(url: "https://ics.fixtur.es/v2/zalgiris-vilnius.ics",
           layout: .versus, competition: "A Lyga", sport: "Football",
           channel: "Go3"),

    Source(url: "https://ics.fixtur.es/v2/fk-kauno-zalgiris.ics",
           layout: .versus, competition: "A Lyga", sport: "Football",
           channel: "Go3"),

    // ── Football: competitions ────────────────────────────────────────
    // Champions League is followed in its own right, so it is not filtered.
    Source(url: "https://ics.fixtur.es/v2/league/champions-league.ics",
           layout: .versus, competition: "Champions League", sport: "Football",
           channel: "TV3"),

    // Europa League is here for when one of your clubs is in it. Unfiltered it
    // would add three and a half thousand matches between teams you do not
    // follow, which is noise, not coverage.
    Source(url: "https://ics.fixtur.es/v2/league/europa-league.ics",
           layout: .versus, competition: "Europa League", sport: "Football",
           channel: "TV3", onlyFollowed: true),

    // Cut down to a Follow, or two notable clubs meeting.
    Source(url: "https://ics.fixtur.es/v2/league/premier-league.ics",
           layout: .versus, competition: "Premier League", sport: "Football",
           channel: "Setanta", onlyFollowed: true),
]

// MARK: - Lithuanian athletes
//
//  A curated editorial layer, not a database. These names attach a reason line
//  to events in the competitions they contest, so an unfamiliar name arrives
//  with an explanation rather than as trivia.
//
//  The wording is deliberately hedged. No calendar feed carries an entry list,
//  so the app cannot know whether someone actually entered a given meeting.
//  "Usually competes here" is true and safe; "will compete" would be a guess,
//  and a wrong reason costs more than no reason.
//
//  Extending this list is research, not code. Only two names are seeded here —
//  the ones that could be stated with confidence.

struct Athlete {
    var name: String
    var sport: String
    /// The educational line. Assume the reader has never heard of them.
    var note: String
    /// Matched against an event's competition or title.
    var competitions: [String]
}

let athletes: [Athlete] = [
    Athlete(name: "Mykolas Alekna", sport: "Discus",
            note: "Mykolas Alekna holds the discus world record. He usually throws here.",
            competitions: ["Diamond League", "World Athletics", "European Athletics",
                           "Olympic Athletics"]),

    Athlete(name: "Rūta Meilutytė", sport: "Swimming",
            note: "Rūta Meilutytė, Olympic champion and world record holder over 50m breaststroke.",
            competitions: ["World Aquatics", "European Aquatics", "Olympic Swimming"]),
]

// No feed carries judgement, so the reason line stays yours.
// Key is matched case-insensitively against the event title.
let reasons: [String: String] = [
    "Žalgiris": "Žalgiris are chasing a playoff place.",
    "PSV":      "Ajax away at PSV.",
]

// Where each competition actually plays, in this country.
let channelURLs: [String: String] = [
    "Go3":     "https://go3.lt",
    "TV3":     "https://tv3play.lt",
    "LRT":     "https://www.lrt.lt/mediateka",
    "Setanta": "https://setantasports.com",
    "Telia Play": "https://teliaplay.lt",
]
