# Running it

1. Open `SportsCompanion.xcodeproj`.
2. Target → **Signing & Capabilities** → *Automatically manage signing*, pick your
   personal team (Xcode → Settings → Accounts).
3. Plug in the iPhone, select it, ⌘R.
4. On the phone: Settings → General → VPN & Device Management → trust the developer.

Free personal signing expires after **7 days**. Re-run ⌘R when it stops opening.

# The model

    Source × Follow → Events

Two concepts, neither of which knows what a sport is.

A **Source** is where events come from. Narrow sources (one team's feed) are
taken whole. Broad ones (a league, the Olympics) are cut down by your Follows.

A **Follow** is a story — a team, a country, an athlete, a tournament. The app
does not care which. It is a name plus the spellings that appear in titles.

Sport-specific logic lives in the *shape of the contest*, and there are three:

| Layout | Title | Used by |
|---|---|---|
| `.versus` | "A - B", "A @ B" | football, basketball, tennis |
| `.session` | "Parent - Part" | race weekends, athletics sessions, Olympic days |
| `.plain` | the title is the event | one-day races, finals, stages |

Adding a sport means adding a URL, not adding code.

# Where the data comes from

`SportsCompanion/Sources.swift` is the control panel. Three lists:

**`feeds`** — iCalendar URLs, fetched on launch and on every return to the app,
cached to disk so a cold launch with no network still shows the day.

| Feed | Pattern |
|---|---|
| Football team | `https://ics.fixtur.es/v2/<slug>.ics` — `Ajax`, `zalgiris-vilnius`, `fk-kauno-zalgiris` |
| Football league | `https://ics.fixtur.es/v2/league/<slug>.ics` — `champions-league`, `europa-league`, `premier-league`, `eredivisie` |
| EuroLeague | an ECAL subscription URL — kept in the gitignored `Secrets.swift`, full season, 380 games |
| Formula 1 | `https://bmorganqwe98.github.io/racing-2026-calendar/f1.ics` — every session of every weekend |

Finding the EuroLeague feed took a detour: the official calendar at
`euroleaguebasketball.ecal.com` is a JavaScript shell that issues per-user
subscription URLs. sync2cal's EuroLeague page embeds real ECAL feed URLs, one per
club plus one for the whole competition — that last one is the 380-game feed used
here. Per-club feeds exist at the same address with different ids if you ever want
only Žalgiris.

**`sport`** on a Source is presentation only. It drives the filter menu and
nothing else — no logic anywhere branches on it, and the model stays
Source → Follow → Event.

**`follows`** — the stories you would be disappointed to miss. Broad sources are
cut down to these; narrow ones are not.

**A team's own feed is complete.** Ajax's feed carries their league, cup and
European games, so subscribing to the Eredivisie as well produced every fixture
twice. Duplicates are now collapsed on start time and title words, but the real
lesson is that league feeds only earn their place for teams you *don't* follow.

**`reasons`** — no feed carries judgement, so the reason line stays yours. Key is
matched against the event title.

**`manualEvents`** in `Fixtures.swift` — anything no feed covers. Tier 4 pins,
friendlies, a Lithuanian in an Olympic final you heard about.

# Two modes

**Today** answers "what deserves my evening". **Browse** answers "show me the F1
season" or "when does Žalgiris next play". Different questions, so Browse gets
its own place rather than another filter on the timeline.

It is a pushed destination, not a tab — the app stays single-screen at rest, and
Browse is somewhere you go on purpose. Three levels: sport → competition →
fixtures. Forward-looking only; the past has its own door.

The fixture level reuses the timeline's own rows, day headers and prominence, so
browsing and deciding do not feel like two different apps.

**The spoiler question is gone.** "Still avoiding spoilers?" was designed to
unseal yesterday in one gesture, for a version of the app that stored results.
This one stores none — "Show result" opens a web search — so there was nothing
for "no" to unlock, and the only possible response was to make it go away.

# Prominence

`Prominence.swift` — three levels, carried by type alone. No badges, no colour,
no icons, and **nothing is ever hidden**: everything you follow stays in the
timeline and stays tappable.

| Level | Treatment | Earned by |
|---|---|---|
| Surfaced | 17 semibold | a Follow, Lithuania, a reason line, two notable clubs, or live now |
| Normal | 17 regular | one notable club |
| Quiet | 15 regular, secondary | everything else |

Live always surfaces regardless of what it is, because something happening now
is the one thing that cannot wait.

The rules live in one function in `Schedule.swift` and are deliberately few
enough to read in full. If prominence ever needs a paragraph to explain, it has
grown past what the reason line can justify.

# Editorial judgement

**`notableClubs`** — the feeds carry no round information, so knockout stages
cannot be detected at all. Instead, a broad competition admits a match when a
Follow is in it, or when two notable clubs meet. That is the honest stand-in for
"the biggest matches", and it works: the Premier League source went from
returning nothing to returning the Manchester derby.

**The Champions League is followed in its own right**, not through a team. It is
not filtered: coverage comes first, and which fixtures deserve prominence is a
separate question the feed cannot answer anyway, since it carries no round
information.

**`athletes`** — a curated Lithuanian roster. Each name carries a sport, an
educational line, and the competitions they contest. When an event in one of
those competitions appears, the line is attached as its reason, so an unfamiliar
name arrives with an explanation rather than as trivia.

The wording is hedged on purpose. No calendar feed carries an entry list, so the
app cannot know whether someone entered a given meeting. *"He usually throws
here"* is true and safe. *"He will throw here"* would be a guess, and a wrong
reason costs more than no reason.

# Volume decides the source, not the sport

Feeds handle the mechanical, high-volume things — football, F1 and the like, hundreds of
events a season. `manualEvents` handles the low-volume, high-judgement ones: the
Diamond League is fourteen meetings a year, the Grand Slams are four, the Grand
Tours are three. That is twenty lines of typing a season, and it is the part that
wants judgement anyway — a final, not every heat.

# The gaps

**Still no feed anywhere for:** LKL, EuroBasket, the FIBA World Cup, either
Lithuania national team, the Conference League, the football World Cup or Euro,
athletics, cycling, tennis, or any winter sport. Every one of these was searched
for. They go in `manualEvents`, with real dates only.

**The Lithuania lens** cuts across every sport rather than being one. It matches
Lithuanian clubs, the country, and names from the athlete roster, so a Žalgiris
EuroLeague game and a national-team football match land in the same view.

**Athlete discovery is not automatic, and cannot be.** The roster is a hand-written
list. Nothing in it updates itself, and no available data source names who has
entered a meeting. An athlete "naturally starting to appear" means somebody added
them — so the roster has to be refreshed by a person who follows Lithuanian sport,
periodically. Two names are seeded; the rest is research, not code.

**Athletics, tennis, cycling and winter sport have no feeds.** Only Diamond League
Brussels is entered, because it was the only date that could be verified. Add the
rest as they are confirmed rather than guessing — a wrong time is worse than a
missing one in a product whose whole value is trust.

# Feeds are hostile

They are built for scores apps. The Ajax feed titles its events
`SK Rapid Wien - Ajax [CL] (2-2)`. Everything is stripped at ingest in `ICS.swift`
before it can reach a view, and the stripping fails closed — losing part of a title
is a nuisance, leaking a result ends the product. Verified against all 599 events
in the live Ajax feed: zero leaks. If you add a feed, spot-check `Earlier` once.

# What is deliberately missing

- **No stored results.** "Show result" opens a web search. The app never holds a score.
- **No app icon.** Drop a 1024px PNG into `AppIcon` in Xcode if the blank square annoys you.
- **No notifications, no settings screen, no following UI.** All deferred.
