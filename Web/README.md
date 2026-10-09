# The web version

Free, permanent, and no expiry. A scheduled job fetches the feeds, cleans them,
and writes `site/events.json`. The page then loads its own JSON from its own
origin, so **no cross-origin request happens at runtime** — which matters,
because two of the three feed hosts send no `Access-Control-Allow-Origin`
header and a browser could never fetch them directly.

## Setup, once

1. Push this repo to GitHub.
2. **Settings → Secrets and variables → Actions → New repository secret**
   Name `EUROLEAGUE_ICS`, value the ECAL subscription URL. It is kept out of the
   code because it is a subscription link that is not ours to publish.
3. **Settings → Pages → Source: GitHub Actions.**
4. **Actions → Refresh schedule → Run workflow** for the first build.
5. Open the Pages URL on the phone, Share → **Add to Home Screen**.

It refreshes four times a day, and on every push.

## Editing

`sources.py` is the whole control panel — the same three lists as the iPhone
app. Feeds, follows, notable clubs, reasons, athletes, channels, and
hand-entered events. Push and it is live on the next build.

Run it locally with:

    cd Web
    EUROLEAGUE_ICS="…" python3 build.py
    python3 -m http.server 8731 --directory site

## Fail closed, twice

`build.py` exits non-zero if anything score-shaped survives cleaning **or** if
any source fails to load. Either way the workflow stops before deploying and
the previous build stays live — yesterday's complete schedule beats today's
partial one, which would quietly lie about what is on.

Feeds get three attempts with backoff first. One transient SSL timeout silently
dropped 373 EuroLeague games from a build, which is how this rule was found.

## Two things worth knowing

**The build fails closed on spoilers.** Anything score-shaped is stripped
before it reaches the JSON, and if something survives, `build.py` exits
non-zero and the workflow fails rather than deploying. Verified against all
599 events in the live Ajax feed: zero leaks.

**The service worker is network-first.** Cache-first would mean every push is
invisible until a version bump gets remembered. Online you always get the
current build; offline you get the last good one.

## What it does not have

Haptics — iOS Safari has no vibration API. Everything else carries over:
prominence, occasion grouping, the Lithuania lens, browse, the fidelity ladder,
and the day-tracking title.
