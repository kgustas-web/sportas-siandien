import Foundation

// ─────────────────────────────────────────────────────────────
//  Events you add by hand. Feeds cover the rest — see Sources.swift.
//
//  Use this for anything no feed carries: a Tier 4 pin, a friendly,
//  a Lithuanian in an Olympic final you heard about.
//
//  d(year, month, day, hour, minute)
//  `sport` is presentation only — it drives the filter.
//  Leave `reason` out and the event stays quiet.
// ─────────────────────────────────────────────────────────────

func d(_ y: Int, _ mo: Int, _ dd: Int, _ h: Int, _ mi: Int) -> Date {
    var c = DateComponents()
    c.year = y; c.month = mo; c.day = dd; c.hour = h; c.minute = mi
    return Calendar.current.date(from: c) ?? Date()
}

let manualEvents: [Event] = [

    // ── LKL 2026/27 ───────────────────────────────────────────────────
    //  Dates and tip-off times from the league schedule on basketnews.lt.
    //  Broadcast on BTV and Telia Play.
    //
    //  Two more Žalgiris–Rytas derbies are known — 2 November in Vilnius and
    //  6 December in Kaunas — but no tip-off time was published for either,
    //  so they are left out rather than guessed.

    Event(title: "Gargždai vs Žalgiris", competition: "LKL",
          sport: "Basketball",
          start: d(2026, 9, 17, 18, 50), minutes: 110, channel: "Telia Play"),

    Event(title: "Neptūnas vs Žalgiris", competition: "LKL",
          sport: "Basketball",
          start: d(2026, 9, 20, 16, 50), minutes: 110, channel: "Telia Play"),

    Event(title: "Žalgiris vs Šiauliai", competition: "LKL",
          sport: "Basketball",
          start: d(2026, 9, 27, 16, 50), minutes: 110, channel: "Telia Play",
          reason: "First home game of the season."),

    // ── Athletics, tennis, cycling, winter ────────────────────────────
    //
    //  No calendar feed exists for these. That is fine: the Diamond League is
    //  fourteen meetings a year, the Grand Slams are four, the Grand Tours are
    //  three. This is twenty lines of typing a season, and it is the part that
    //  wants judgement anyway — a final, not every heat.
    //
    //  `sport` is presentation only — it drives the filter.
//  Leave `reason` out and the event stays quiet. If a competition here
    //  matches an athlete in Sources.swift, their line is attached automatically.
    //
    //  Only dates that could be verified are entered. Add the rest as they are
    //  confirmed rather than guessing — a wrong time is worse than a missing one.

    Event(title: "Brussels", competition: "Diamond League",
          sport: "Athletics",
          start: d(2026, 9, 4, 20, 0), minutes: 150, channel: "Go3"),
]
