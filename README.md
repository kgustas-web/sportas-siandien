# Sports Companion

A personal sports companion for iPhone.

It answers four questions and nothing else: **what is happening today, what is happening next, what is worth watching, and what did I miss.** It is not a scores app or a stats database. It is a quiet tool for deciding how to spend an evening, built so that catching up late never spoils a result you have not seen yet.

Built for one person first, following Apple's Human Interface Guidelines, with simplicity treated as the feature.

## Status

**Phase 5 — build.** A native SwiftUI iPhone app with hardcoded fixtures lives in `App/`. The goal is a month of daily real use.

## Two builds

| | |
|---|---|
| **[Web/](Web/)** | The one to use. Free, permanent, no expiry. A scheduled job bakes the feeds into `events.json`; GitHub Pages serves it; Add to Home Screen. See [Web/README.md](Web/README.md). |
| **[App/](App/)** | Native SwiftUI. Better feel, but free signing expires every 7 days and TestFlight costs $99/yr. Waiting for the day the web version proves the habit. |

Both share the same model — Source × Follow → Event — and the same editorial
layer. `Web/sources.py` and `App/SportsCompanion/Sources.swift` are the same
three lists in two languages.

## The one secret

The EuroLeague feed is an ECAL subscription URL that is not ours to publish,
and this repository is public so GitHub Pages can serve the site for free.

- **Web:** repository secret `EUROLEAGUE_ICS` (Settings → Secrets → Actions).
- **App:** `cp App/SportsCompanion/Secrets.example.swift App/SportsCompanion/Secrets.swift`
  and paste it in. That file is gitignored, so a fresh clone needs this once
  before the Xcode project will build.

## Documents

- [PRODUCT.md](PRODUCT.md) — the product vision, scope, challenged assumptions and open questions.
- [AGENDA.md](AGENDA.md) — behaviour specification for the agenda, derived from real scenarios.
- [DECISIONS.md](DECISIONS.md) — append-only log of what was decided and why.
- [App/README.md](App/README.md) — how to run it on the phone and how to add fixtures.
- [CLAUDE.md](CLAUDE.md) — how work is done on this project: phase gates, design principles, working rules.

## Next step

Push to GitHub, turn on Pages, add to the home screen, use it for a month.
