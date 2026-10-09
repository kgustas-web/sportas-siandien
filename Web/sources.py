"""
What you follow, and where events come from.

This is the whole control panel — the same three lists as the Swift app.
Edit here, push, and the site updates on the next scheduled build.
"""

# ── Sources ──────────────────────────────────────────────────────────────
# layout: "versus"  -> "A - B [TAG]"        football, basketball, tennis
#         "session" -> "Parent - Part"      race weekends, athletics sessions
#         "plain"   -> the title is the event
#
# The EuroLeague URL is a subscription link that is not ours to publish, so
# it is read from the EUROLEAGUE_ICS environment variable (a repo secret).

import os

SOURCES = [
    {
        "url": os.environ.get("EUROLEAGUE_ICS", ""),
        "layout": "versus", "competition": "EuroLeague", "sport": "Basketball",
        "channel": "Go3", "strip_prefix": "\U0001F3C0 ",
    },
    {
        "url": "https://bmorganqwe98.github.io/racing-2026-calendar/f1.ics",
        "layout": "session", "competition": "Formula 1", "sport": "Formula One",
        "channel": "Go3", "strip_prefix": "F1 ", "groups_parts": True,
    },
    {
        "url": "https://ics.fixtur.es/v2/Ajax.ics",
        "layout": "versus", "competition": "Eredivisie", "sport": "Football",
        "channel": "Go3",
    },
    {
        "url": "https://ics.fixtur.es/v2/zalgiris-vilnius.ics",
        "layout": "versus", "competition": "A Lyga", "sport": "Football",
        "channel": "Go3",
    },
    {
        "url": "https://ics.fixtur.es/v2/fk-kauno-zalgiris.ics",
        "layout": "versus", "competition": "A Lyga", "sport": "Football",
        "channel": "Go3",
    },
    {
        "url": "https://ics.fixtur.es/v2/league/champions-league.ics",
        "layout": "versus", "competition": "Champions League", "sport": "Football",
        "channel": "TV3",
    },
    {
        "url": "https://ics.fixtur.es/v2/league/europa-league.ics",
        "layout": "versus", "competition": "Europa League", "sport": "Football",
        "channel": "TV3", "only_followed": True,
    },
    {
        "url": "https://ics.fixtur.es/v2/league/premier-league.ics",
        "layout": "versus", "competition": "Premier League", "sport": "Football",
        "channel": "Setanta", "only_followed": True,
    },
]

# ── Follows ──────────────────────────────────────────────────────────────
FOLLOWS = [
    ["BC Žalgiris", "Zalgiris Kaunas", "Žalgiris Kaunas"],
    ["Ajax"],
    ["Žalgiris Vilnius", "Zalgiris Vilnius"],
    ["Kauno Žalgiris", "Kauno Zalgiris"],
    ["Lithuania", "Lietuva", "Litouwen", "Litauen", "Lituanie"],
]

# Sports you follow without a feed existing for them. Keeps them top level
# alongside the ones a Source declares, rather than stranded under Lithuania.
FOLLOWED_SPORTS = ["Biathlon"]

LITHUANIAN = ["Zalgiris", "Žalgiris", "Lithuania", "Lietuva",
              "Litouwen", "Litauen", "Lituanie"]

# Clubs whose meetings are worth surfacing even when you follow neither.
# The feeds carry no round information, so knockout stages cannot be detected.
NOTABLE = [
    "Real Madrid", "Barcelona", "Bayern", "Liverpool", "Manchester City",
    "Arsenal", "Inter", "Milan", "Juventus", "Paris", "Chelsea",
    "Manchester United", "Tottenham", "Atlético", "Atletico", "Dortmund",
]

# ── Editorial ────────────────────────────────────────────────────────────
# No feed carries judgement, so the reason line stays yours.
REASONS = {
    # Keep these specific. A line that would fit any fixture is not a reason —
    # a generic "Žalgiris are chasing a playoff place" ended up on every single
    # Žalgiris game, including routine league ones, which is noise wearing the
    # clothes of judgement.
    "PSV": "Ajax away at PSV.",
}

# A curated roster, not a database. Hedged wording on purpose: no feed
# carries an entry list, so the app cannot know who actually entered.
ATHLETES = [
    {"name": "Mykolas Alekna", "sport": "Athletics",
     "note": "Mykolas Alekna holds the discus world record. He usually throws here.",
     "competitions": ["Diamond League", "World Athletics", "European Athletics",
                      "World Championships", "European Championships"]},
    {"name": "Rūta Meilutytė", "sport": "Swimming",
     "note": "Rūta Meilutytė, Olympic champion and world record holder over 50m breaststroke.",
     "competitions": ["World Aquatics", "European Aquatics",
                      "World Championships", "European Championships"]},

    {"name": "Nedas Grikinis", "sport": "Gymnastics",
     "note": "Nedas Grikinis is Lithuania's entry, qualified through the European all-around.",
     "competitions": ["World Championships", "European Championships"]},
]

CHANNELS = {
    "Go3": "https://go3.lt",
    "TV3": "https://tv3play.lt",
    "LRT": "https://www.lrt.lt/mediateka",
    "Setanta": "https://setantasports.com",
    "Telia Play": "https://teliaplay.lt",
}

# ── Hand-entered events ──────────────────────────────────────────────────
# For anything no feed covers. Only dates that could be verified.
# (year, month, day, hour, minute)
MANUAL = [
    # ── LKL ───────────────────────────────────────────────────────────
    # Dates, tip-off times and venues from the league's own schedule at
    # lkl.lt/tvarkarastis. sportas.lt disagreed on the 18 October time
    # (18:50); the league's page says 19:00 and wins.
    # zalgiris.lt blocks automated requests, so only the fixtures visible
    # on the league page are here — this is not the full season.
    {"title": "Nevėžis vs Žalgiris", "competition": "LKL", "sport": "Basketball",
     "start": (2026, 10, 11, 17, 0), "minutes": 110, "channel": "Telia Play"},
    {"title": "Žalgiris vs Tauragė", "competition": "LKL", "sport": "Basketball",
     "start": (2026, 10, 18, 19, 0), "minutes": 110, "channel": "Telia Play"},

    # ── Lithuania, football ───────────────────────────────────────────
    # UEFA Nations League, Division D. Schedule confirmed by the Lithuanian
    # Football Federation. No broadcaster published, so none is claimed.
    {"title": "Lietuva vs Lichtenšteinas", "competition": "Nations League",
     "sport": "Football", "start": (2026, 11, 16, 19, 0), "minutes": 115,
     "reason": "Last game of the Nations League cycle."},

    # ── Lithuania, basketball ─────────────────────────────────────────
    # FIBA World Cup 2027 European Qualifiers, Group J. Date and opponent
    # confirmed; the tip-off time is single-sourced and FIBA still lists it
    # as TBD, so the row says so rather than pretending.
    #
    # Bosnia vs Lietuva on 29 November is also confirmed, but no time has
    # been published anywhere. Add it when FIBA announces one.
    {"title": "Lietuva vs Serbija", "competition": "World Cup qualifiers",
     "sport": "Basketball", "start": (2026, 11, 26, 18, 0), "minutes": 115,
     "note": "Tip-off time not yet confirmed."},

    # ── Major international events ────────────────────────────────────
    # The Tier 4 case: worth knowing it is on, even without a session
    # timetable. Entered on its opening day with the range in the note,
    # because for a nine-day championship the useful fact is that it
    # starts, not what time a given rotation begins.
    #
    # Not marked Lithuanian: entry lists are not out, and claiming a
    # Lithuanian is competing when that is unknown is the kind of wrong
    # the reason line exists to prevent.
    # Marked Lithuanian on evidence, not on hope: Nedas Grikinis qualified
    # through the top 24 all-around at the European Championships. His line
    # in ATHLETES attaches itself as the reason.
    {"title": "World Artistic Gymnastics Championships",
     "competition": "World Championships", "sport": "Gymnastics",
     "start": (2026, 10, 17, 10, 0), "minutes": 480, "lithuanian": True,
     "note": "Rotterdam, 17–25 October. Daily session times not published."},

    # An Olympic qualifier, so it matters more than a normal worlds. Not
    # marked Lithuanian — the entry list is not out, and the same rule
    # applies here as applied to gymnastics before Grikinis was confirmed.
    {"title": "World Weightlifting Championships",
     "competition": "World Championships", "sport": "Weightlifting",
     "start": (2026, 10, 27, 10, 0), "minutes": 480,
     "note": "Ningbo, 27 October – 8 November. An Olympic qualifier. "
             "Lithuania sent six lifters to the 2025 worlds; the 2026 entry "
             "list is not published yet."},

    # ── Biathlon ──────────────────────────────────────────────────────
    # No feed exists: the IBU publishes no iCalendar and the third-party
    # ones resolve to an app, not a file. A feed would be the wrong shape
    # anyway — a season is 78 individual races, which would flood the
    # timeline the way an ungrouped F1 weekend did. Eleven rounds is the
    # grain that is actually useful. Calendar from the published IBU
    # schedule; per-race times are not entered because they are not
    # published as a set.

    {"title": "Kontiolahti", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2026, 11, 24, 14, 0), "minutes": 180,
     "note": "24–29 November. Race times not listed here."},
    {"title": "Hochfilzen", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2026, 12, 1, 14, 0), "minutes": 180,
     "note": "1–6 December. Race times not listed here."},
    {"title": "Annecy–Le Grand-Bornand", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2026, 12, 8, 14, 0), "minutes": 180,
     "note": "8–13 December. Race times not listed here."},
    {"title": "Pokljuka", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2026, 12, 31, 14, 0), "minutes": 180,
     "note": "31 December – 3 January. Race times not listed here."},
    {"title": "Ruhpolding", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 1, 5, 14, 0), "minutes": 180,
     "note": "5–10 January. Race times not listed here."},
    {"title": "Antholz-Anterselva", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 1, 12, 14, 0), "minutes": 180,
     "note": "12–17 January. Race times not listed here."},
    {"title": "Nové Město na Moravě", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 1, 19, 14, 0), "minutes": 180,
     "note": "19–24 January. Race times not listed here."},
    {"title": "Otepää", "competition": "World Championships", "sport": "Biathlon",
     "start": (2027, 2, 8, 14, 0), "minutes": 180,
     "reason": "World Championships, in neighbouring Estonia.",
     "note": "8–21 February. Race times not listed here."},
    {"title": "Oberhof", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 3, 2, 14, 0), "minutes": 180,
     "note": "2–7 March. Race times not listed here."},
    {"title": "Östersund", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 3, 9, 14, 0), "minutes": 180,
     "note": "9–14 March. Race times not listed here."},
    {"title": "Oslo Holmenkollen", "competition": "Biathlon World Cup", "sport": "Biathlon",
     "start": (2027, 3, 16, 14, 0), "minutes": 180,
     "note": "16–21 March. Race times not listed here."},
]

TIMEZONE = "Europe/Vilnius"
