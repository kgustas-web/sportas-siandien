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

    // ── Biathlon ──────────────────────────────────────────────────────
    //  No feed exists, and a feed would be the wrong shape: a season is
    //  78 races. Eleven rounds is the grain that is useful.

    Event(title: "Kontiolahti", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2026, 11, 24, 14, 0), minutes: 180,
          note: "24–29 November. Race times not listed here."),
    Event(title: "Hochfilzen", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2026, 12, 1, 14, 0), minutes: 180,
          note: "1–6 December. Race times not listed here."),
    Event(title: "Annecy–Le Grand-Bornand", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2026, 12, 8, 14, 0), minutes: 180,
          note: "8–13 December. Race times not listed here."),
    Event(title: "Pokljuka", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2026, 12, 31, 14, 0), minutes: 180,
          note: "31 December – 3 January. Race times not listed here."),
    Event(title: "Ruhpolding", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 1, 5, 14, 0), minutes: 180,
          note: "5–10 January. Race times not listed here."),
    Event(title: "Antholz-Anterselva", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 1, 12, 14, 0), minutes: 180,
          note: "12–17 January. Race times not listed here."),
    Event(title: "Nové Město na Moravě", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 1, 19, 14, 0), minutes: 180,
          note: "19–24 January. Race times not listed here."),
    Event(title: "Otepää", competition: "World Championships", sport: "Biathlon",
          start: d(2027, 2, 8, 14, 0), minutes: 180,
          reason: "World Championships, in neighbouring Estonia.",
          note: "8–21 February. Race times not listed here."),
    Event(title: "Oberhof", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 3, 2, 14, 0), minutes: 180,
          note: "2–7 March. Race times not listed here."),
    Event(title: "Östersund", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 3, 9, 14, 0), minutes: 180,
          note: "9–14 March. Race times not listed here."),
    Event(title: "Oslo Holmenkollen", competition: "Biathlon World Cup", sport: "Biathlon",
          start: d(2027, 3, 16, 14, 0), minutes: 180,
          note: "16–21 March. Race times not listed here."),
]
