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
    "Žalgiris": "Žalgiris are chasing a playoff place.",
    "PSV": "Ajax away at PSV.",
}

# A curated roster, not a database. Hedged wording on purpose: no feed
# carries an entry list, so the app cannot know who actually entered.
ATHLETES = [
    {"name": "Mykolas Alekna",
     "note": "Mykolas Alekna holds the discus world record. He usually throws here.",
     "competitions": ["Diamond League", "World Athletics", "European Athletics",
                      "Olympic Athletics"]},
    {"name": "Rūta Meilutytė",
     "note": "Rūta Meilutytė, Olympic champion and world record holder over 50m breaststroke.",
     "competitions": ["World Aquatics", "European Aquatics", "Olympic Swimming"]},
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
    {"title": "Gargždai vs Žalgiris", "competition": "LKL", "sport": "Basketball",
     "start": (2026, 9, 17, 18, 50), "minutes": 110, "channel": "Telia Play"},
    {"title": "Neptūnas vs Žalgiris", "competition": "LKL", "sport": "Basketball",
     "start": (2026, 9, 20, 16, 50), "minutes": 110, "channel": "Telia Play"},
    {"title": "Žalgiris vs Šiauliai", "competition": "LKL", "sport": "Basketball",
     "start": (2026, 9, 27, 16, 50), "minutes": 110, "channel": "Telia Play",
     "reason": "First home game of the season."},
    {"title": "Brussels", "competition": "Diamond League", "sport": "Athletics",
     "start": (2026, 9, 4, 20, 0), "minutes": 150, "channel": "Go3"},
]

TIMEZONE = "Europe/Vilnius"
