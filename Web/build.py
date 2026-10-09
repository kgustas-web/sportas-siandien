#!/usr/bin/env python3
"""
Fetch the calendar feeds, clean them, and write site/events.json.

Runs on a schedule so the site never talks to a feed at runtime — which is
what sidesteps CORS entirely. Two of the three feed hosts send no
Access-Control-Allow-Origin header, so a browser could never fetch them
directly. Here they are same-origin by the time the page loads.
"""

import json, re, sys, time, urllib.request, urllib.error
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from pathlib import Path

import sources as S

LOCAL = ZoneInfo(S.TIMEZONE)
OUT = Path(__file__).parent / "site" / "events.json"

# ── ICS parsing ──────────────────────────────────────────────────────────

def unfold(text):
    lines = []
    for raw in text.replace("\r\n", "\n").split("\n"):
        if raw[:1] in (" ", "\t") and lines:
            lines[-1] += raw[1:]
        else:
            lines.append(raw)
    return lines

def unescape(v):
    return (v.replace("\\n", " ").replace("\\,", ",")
             .replace("\;", ";").replace("\\\\", "\\").strip())

def parse_dt(value, params):
    tz = params.get("TZID")
    try:
        if value.endswith("Z"):
            return datetime.strptime(value, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc)
        if len(value) == 8:
            naive = datetime.strptime(value, "%Y%m%d")
        else:
            naive = datetime.strptime(value, "%Y%m%dT%H%M%S")
    except ValueError:
        return None
    try:
        return naive.replace(tzinfo=ZoneInfo(tz) if tz else LOCAL)
    except Exception:
        return naive.replace(tzinfo=LOCAL)

def parse_ics(text):
    out, cur, inside = [], {}, False
    for line in unfold(text):
        if line == "BEGIN:VEVENT":
            inside, cur = True, {}
            continue
        if line == "END:VEVENT":
            if inside and cur.get("summary") and cur.get("start"):
                out.append(cur)
            inside = False
            continue
        if not inside or ":" not in line:
            continue
        lhs, value = line.split(":", 1)
        bits = lhs.split(";")
        name = bits[0].upper()
        params = dict(p.split("=", 1) for p in bits[1:] if "=" in p)
        if name == "SUMMARY":
            cur["summary"] = unescape(value)
        elif name == "CATEGORIES":
            cur["categories"] = unescape(value)
        elif name == "DTSTART":
            cur["start"] = parse_dt(value, params)
        elif name == "DTEND":
            cur["end"] = parse_dt(value, params)
    return out

# ── Cleaning ─────────────────────────────────────────────────────────────
# Feeds are written for scores apps. The Ajax feed titles its events
# "SK Rapid Wien - Ajax [CL] (2-2)". Everything score-shaped is removed
# before it can reach the page, and the stripping fails closed: losing part
# of a title is a nuisance, leaking a result ends the product.

SCORE_PATTERNS = [
    r"\s*[\(\[]\s*\d{1,3}\s*[-–—:]\s*\d{1,3}\s*[\)\]]",
    r"\s*[\(\[]\s*\d{1,3}\s*[-–—:]\s*\d{1,3}\s*[,;][^\)\]]*[\)\]]",
    r"\s+\d{1,3}\s*[-–—:]\s*\d{1,3}\s*$",
    r"\s*[\(\[](?:aet|pens?|ot|after extra time)[\)\]]",
]

def strip_results(text):
    s = text
    for p in SCORE_PATTERNS:
        s = re.sub(p, "", s, flags=re.IGNORECASE)
    return s.strip()

def extract_tag(text):
    m = re.search(r"\s*\[[A-Za-z0-9 .\-]{1,24}\]\s*", text)
    if not m:
        return text.strip(), None
    tag = text[m.start():m.end()].strip().strip("[]")
    return (text[:m.start()] + text[m.end():]).strip(), tag

LEAK = re.compile(r"\d{1,3}\s*[-–—:]\s*\d{1,3}")

# ── Editorial ────────────────────────────────────────────────────────────

def contains_any(text, needles):
    low = text.lower()
    return any(n.lower() in low for n in needles)

def is_followed(title):
    return any(contains_any(title, aliases) for aliases in S.FOLLOWS)

def is_lithuanian(text):
    if contains_any(text, S.LITHUANIAN):
        return True
    return any(a["name"].lower() in text.lower() for a in S.ATHLETES)

def reason_for(title, competition):
    for key, value in S.REASONS.items():
        if key.lower() in title.lower():
            return value
    hay = f"{title} {competition}".lower()
    for a in S.ATHLETES:
        if any(c.lower() in hay for c in a["competitions"]):
            return a["note"]
    return None

def prominence(title, reason):
    """Few rules, all readable. Nothing is ever hidden — only weighted."""
    if is_followed(title):   return 2
    if is_lithuanian(title): return 2
    if reason:               return 2
    big = sum(1 for n in S.NOTABLE if n.lower() in title.lower())
    if big >= 2: return 2
    if big == 1: return 1
    return 0

def admits(title):
    if is_followed(title):
        return True
    return sum(1 for n in S.NOTABLE if n.lower() in title.lower()) >= 2

# ── Building ─────────────────────────────────────────────────────────────

def fetch(url, attempts=3):
    """Transient blips are common and expensive: one SSL timeout silently
    dropped 373 EuroLeague games from a build. Retry, then give up loudly."""
    last = None
    for i in range(attempts):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "sports-companion/1.0"})
            with urllib.request.urlopen(req, timeout=40) as r:
                return r.read().decode("utf-8", "replace")
        except Exception as exc:
            last = exc
            if i < attempts - 1:
                time.sleep(3 * (i + 1))
    raise last

def convert(raw, src):
    cleaned = strip_results(raw["summary"])
    if not cleaned:
        return None
    if src.get("only_followed") and not admits(cleaned):
        return None

    title = cleaned
    prefix = src.get("strip_prefix")
    if prefix and title.startswith(prefix):
        title = title[len(prefix):]

    competition = src["competition"]
    occasion = None

    if src["layout"] == "versus":
        title, tag = extract_tag(title)
        if tag:
            competition = tag
    elif src["layout"] == "session":
        if " - " in title:
            occasion, title = title.rsplit(" - ", 1)
            competition = occasion
        elif raw.get("categories"):
            competition = raw["categories"]

    if not title or LEAK.search(title):
        return None   # fail closed

    minutes = 120
    if raw.get("end"):
        minutes = max(30, min(int((raw["end"] - raw["start"]).total_seconds() / 60), 300))

    reason = reason_for(title, competition)
    return {
        "title": title,
        "competition": competition,
        "sport": src["sport"],
        "start": raw["start"].astimezone(timezone.utc).isoformat(),
        "minutes": minutes,
        "channel": src.get("channel"),
        "reason": reason,
        "note": None,
        "occasion": occasion if src.get("groups_parts") else None,
        "lithuanian": is_lithuanian(title),
        "prominence": prominence(title, reason),
    }

def manual_events():
    out = []
    for m in S.MANUAL:
        start = datetime(*m["start"], tzinfo=LOCAL)
        reason = m.get("reason") or reason_for(m["title"], m["competition"])
        out.append({
            "title": m["title"], "competition": m["competition"], "sport": m["sport"],
            "start": start.astimezone(timezone.utc).isoformat(),
            "minutes": m.get("minutes", 120), "channel": m.get("channel"),
            "reason": reason, "note": m.get("note"), "occasion": None,
            "lithuanian": is_lithuanian(m["title"]) or is_lithuanian(m["competition"]),
            "prominence": prominence(m["title"], reason),
        })
    return out

def dedupe(events):
    """A team's own feed and its league both carry the same match."""
    seen, out = set(), []
    for e in sorted(events, key=lambda x: x["start"]):
        slot = int(datetime.fromisoformat(e["start"]).timestamp() // 900)
        words = "-".join(sorted(w for w in re.split(r"[^0-9A-Za-zÀ-ž]+", e["title"].lower()) if len(w) >= 3))
        key = f"{slot}|{words}"
        if key not in seen:
            seen.add(key)
            out.append(e)
    return out

def main():
    horizon = datetime.now(timezone.utc) - timedelta(days=21)
    events, problems = manual_events(), []

    for src in S.SOURCES:
        if not src["url"]:
            problems.append(f"{src['competition']}: no URL configured")
            continue
        try:
            text = fetch(src["url"])
        except Exception as exc:
            problems.append(f"{src['competition']}: {exc}")
            continue
        if "BEGIN:VCALENDAR" not in text:
            problems.append(f"{src['competition']}: not a calendar")
            continue
        kept = 0
        for raw in parse_ics(text):
            if raw["start"] < horizon:
                continue
            ev = convert(raw, src)
            if ev:
                events.append(ev)
                kept += 1
        print(f"  {src['competition']:<18} {kept:>5} events", file=sys.stderr)

    events = dedupe(events)
    leaks = [e["title"] for e in events if LEAK.search(e["title"])]

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "generated": datetime.now(timezone.utc).isoformat(),
        "timezone": S.TIMEZONE,
        "channels": S.CHANNELS,
        "events": events,
        "problems": problems,
    }, ensure_ascii=False, indent=None, separators=(",", ":")))

    print(f"\n  {len(events)} events -> {OUT}", file=sys.stderr)
    print(f"  score leaks: {len(leaks)}", file=sys.stderr)
    for p in problems:
        print(f"  ! {p}", file=sys.stderr)

    # Fail closed twice over. A surviving score ends the product; a half
    # fetched schedule quietly lies about what is on. In both cases the
    # previous deploy stays live, which is the better answer.
    if leaks:
        print("  FAILED: score survived cleaning", file=sys.stderr)
        return 1
    if problems:
        print("  FAILED: a source did not load — refusing to publish a partial schedule",
              file=sys.stderr)
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
