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

    // ── LKL ───────────────────────────────────────────────────────────
    //  From the league's own schedule at lkl.lt/tvarkarastis. sportas.lt
    //  disagreed on the 18 October time (18:50); the league page says 19:00.
    //  zalgiris.lt blocks automated requests, so this is not a full season.

    Event(title: "Nevėžis vs Žalgiris", competition: "LKL", sport: "Basketball",
          start: d(2026, 10, 11, 17, 0), minutes: 110, channel: "Telia Play"),

    Event(title: "Žalgiris vs Tauragė", competition: "LKL", sport: "Basketball",
          start: d(2026, 10, 18, 19, 0), minutes: 110, channel: "Telia Play"),

    // ── Lithuania, football ───────────────────────────────────────────
    //  Nations League Division D, confirmed by the Lithuanian Football
    //  Federation. No broadcaster published, so none is claimed.

    Event(title: "Lietuva vs Lichtenšteinas", competition: "Nations League",
          sport: "Football", start: d(2026, 11, 16, 19, 0), minutes: 115,
          reason: "Last game of the Nations League cycle."),

    // ── Lithuania, basketball ─────────────────────────────────────────
    //  World Cup 2027 European Qualifiers, Group J. Date and opponent are
    //  confirmed; the tip-off is single-sourced and FIBA still says TBD.
    //  Bosnia vs Lietuva on 29 November is confirmed too, but no time has
    //  been published anywhere — add it when FIBA announces one.

    Event(title: "Lietuva vs Serbija", competition: "World Cup qualifiers",
          sport: "Basketball", start: d(2026, 11, 26, 18, 0), minutes: 115,
          note: "Tip-off time not yet confirmed."),

    // ── Major international events ────────────────────────────────────
    //  The Tier 4 case: worth knowing it is on, even without a session
    //  timetable. Not marked Lithuanian — entry lists are not out.

    //  Marked Lithuanian on evidence: Nedas Grikinis qualified through the
    //  top 24 all-around at the European Championships.
    Event(title: "World Artistic Gymnastics Championships",
          competition: "World Championships", sport: "Gymnastics",
          lithuanian: true,
          start: d(2026, 10, 17, 10, 0), minutes: 480,
          note: "Rotterdam, 17–25 October. Daily session times not published."),

    //  An Olympic qualifier. Not marked Lithuanian — the entry list is not out.
    Event(title: "World Weightlifting Championships",
          competition: "World Championships", sport: "Weightlifting",
          start: d(2026, 10, 27, 10, 0), minutes: 480,
          note: "Ningbo, 27 October – 8 November. Also an Olympic qualifier."),
]
