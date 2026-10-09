# The Agenda — behaviour specification

Phase 1. **Behaviour only.** No layout, no components, no visual design. Everything here describes what the product *does*, what it says, what it withholds, and what changes when you act.

Fixtures used as examples are illustrative, not verified.

Method: these scenarios came first. The rules in §10 were derived from them, not applied to them.

---

## 1. The three states of an event

Every event is in exactly one state, and the state changes on its own as time passes.

| State | Meaning | Behaviour |
|---|---|---|
| **Ahead** | Has not started. | Plannable. Can be surfaced. Carries a reason once one is safe to assert. |
| **In progress** | Started, still going. | Joinable. Never shows a running score. |
| **Sealed** | Finished, not revealed. | Offers the fidelity ladder. Never shows a result unasked. |

**There is no watched state.** The product does not track what you have seen and never tries to work it out. An event that has finished is *sealed* — which is a claim about the app's own behaviour, not a claim about you. The app makes no claims about you at all.

**Consequence:** the agenda and catch-up are not two features. They are the same list at different times of day. Nothing migrates, nothing is filed — an event simply changes state beneath you. Today's finished events stay on today. Yesterday's become yesterday.

## 2. The shape of a day

Two parts, always in this order:

1. **A verdict.** One or two plain sentences answering "does anything deserve my evening?" This is a sentence, not an item.
2. **The day.** Every admitted event, in chronological order, earliest first.

Surfaced events are not lifted out into a separate section. They stay in chronological place and carry a **reason line**; everything else is bare. Importance is a property of the item, not of where it sits.

There is no third part. Catch-up from previous days is adjacent to this screen, not inside it.

## 3. Scenario — a normal Wednesday, 18:30

Illustrative: Žalgiris play Olympiacos in the EuroLeague at 19:00. Ajax play at 21:00. There is an LKL game at 18:00 that is already underway and that you do not care much about.

**Verdict:** *"Žalgiris at 19:00 — 30 minutes away."*

**The day, in chronological order:**

- **18:00 · LKL fixture** — in progress. Shown as started. No score.
- **19:00 · Žalgiris – Olympiacos, EuroLeague** — surfaced, with its reason: *"A win puts Žalgiris in the top eight."* Where to watch, if known.
- **21:00 · Ajax – Feyenoord, Eredivisie** — listed. Bare. Time, teams, where.

**How many events:** three. Everything relevant, nothing padded.

**In what order:** chronological, always. Never sorted by importance — you read a day forwards, and time is the only ordering a person does not have to learn.

**What information:** what it is, when it starts, where to watch, and — only if surfaced — one sentence on why it matters.

**What is hidden:** scores, standings, form, lineups, odds, predictions, commentary, anything evaluative about an event that has finished.

**Why 18:30 matters:** the verdict is time-aware, not date-aware. At 09:00 it would read *"Žalgiris tonight at 19:00."* At 18:30 it reads *"30 minutes away."* At 19:20 it reads *"Žalgiris is on now."* Same event, same day, three different useful sentences.

## 4. Scenario — an empty day

**Verdict:** *"Nothing tonight."*

Then, and only then, two things that do real work:

- **The next thing that is coming.** *"Next: Žalgiris, Friday 20:00."* This is what turns an empty screen into a planning tool.
- **Anything still unwatched**, if there is any. One line, no results.

Nothing else. No news, no "you might like", no filler, no suggestion to explore. The screen is allowed to be short and it is allowed to end.

**This is a success state, not an empty state.** "Nothing tonight" is a complete answer and the product should sound certain when it says it.

## 5. Scenario — a busy evening

The critical distinction, and the thing that decides the behaviour:

**Sequence** — 19:00 and 21:30. Both watchable. This is not a competition, it is a schedule.
> *"Two tonight: Žalgiris at 19:00, then Lithuania at 21:30."*

Both are surfaced. Both carry reasons. Nothing is demoted, because nothing has to be given up.

**Conflict** — genuinely overlapping. Only here does the product choose.
> *"Žalgiris at 19:00. Lithuania kicks off at the same time — you can watch it back after."*

One is surfaced. The other stays in the day, keeps its reason, and is explicitly marked as still catchable. The product commits, but it never pretends the other thing does not exist.

**This corrects an earlier rule.** "At most one headline per day" was wrong — it was written before these scenarios existed. The real rule is **one per conflict, not one per day**, because the constraint is your time, not the screen's tidiness.

## 6. Scenario — an F1 weekend

The weekend is **one occasion** occupying one place in the day, not five events.

- **Wednesday:** nothing on the day. Forward horizon only: *"Race weekend starts Friday."*
- **Friday:** practice, listed inside the weekend, not surfaced. You would not be disappointed to miss FP1.
- **Saturday:** qualifying. Listed, or surfaced if something is genuinely at stake.
- **Sunday:** the race. Surfaced.

Expanding the occasion reveals the sessions. Collapsed by default.

**Sessions hold spoiler state independently, and this has teeth:** if you have not watched qualifying, the race entry must not show the grid. Starting positions are a result. This is the sharpest test of whether the spoiler model actually works, because the leak here is structural rather than textual — it hides in data that does not look like a score.

## 7. Scenario — the Olympics, and the fifteen-event day

Fifteen relevant things happen. The product must not present fifteen things.

**Grouping does the work.** The Olympics is one occasion for two weeks. Within it, a day is one entry — *"Olympics, day six"* — that expands. The same mechanism that collapses an F1 weekend collapses an Olympic day. **You never experience fifteen items, because occasions absorb volume.** This is why the fifteen case behaves like the three case, and it is the answer to "what if there are fifteen."

**What surfaces from inside an occasion:** only Tier 1 sport, which is automatic, and anything pinned. Everything else is listed within the group.

**The known gap:** you will not be disappointed to miss a Lithuanian in an athletics final if you never knew they had qualified. The disappointment principle cannot reach what you are unaware of. Manual pinning is the current answer, and it only works if you already know. Whether the product should actively invite pinning at the start of a major event is an open question — it would help, but it is also the first thing in this design that asks something of you rather than giving you something.

## 8. Scenario — yesterday

Thursday morning. Last night Žalgiris played at 19:00 and Ajax at 21:00. The product does not know whether you watched either, and it never asks itself the question.

**Both are sealed.** You see what they were, when they were, and that each can still be watched. No score. No result. No hint that anything notable happened, because *notable* is itself a spoiler.

One question, asked once, about you rather than about the events:

> *"Still avoiding spoilers?"*

Not per event. Not a checklist. One line, dismissible, never blocking. Answering no unseals yesterday in a single gesture. Ignoring it changes nothing, because the default is protection and the default costs you nothing.

**Why sealing beats tracking:** the failure costs are asymmetric. A watched-state system that guesses wrong spoils you — unrecoverable, and it ends the product. A sealed-by-default system that guesses wrong shows you a sealed event you have already seen — mildly redundant, one tap to clear. When one side's worst day is catastrophic and the other's is boring, you build the boring one.

**The past expires; it is never cleared.** Nothing accumulates, because events stop being offered when they stop being realistically watchable — a full replay has a life of days, not months. The app does not decide that you watched something. It decides that something is no longer worth offering, which is a claim it can actually justify. Old events never unseal on their own. They just go quiet.

**What state does exist:** only what you did. If you reveal a result, that is recorded, because you did it and un-revealing it would be absurd. The rule is not *no state* — it is **the app records actions, never assumptions.**

## 9. Scenario — planning ahead

Wednesday. Nothing tonight. You want to know whether to keep Saturday free.

**Verdict:** *"Nothing tonight. Next: Žalgiris, Friday 20:00."*

The forward view is not a calendar and it has no fixed length. **It reaches as far as the next decision, not a set number of days.** On a dead week in July that might be three weeks out. In March it might be tomorrow.

**Discovery: a reason has a shelf life forwards as well as backwards.**

*"A win puts Žalgiris in the top eight"* is true on the morning of the match. Three days out it may not be, because two other results land first. A reason asserted too early can be false by the time you read it — and a wrong reason is worse than no reason, because the reason line *is* the product's credibility.

So the reason line is bounded at both ends of time:

- **It appears only when it is safe to assert.** Attachment and rarity are stable and can be stated at any distance — *"Lithuania play for the first time since June."* Consequence is volatile and appears late, often only on the day.
- **It matures as certainty increases, and degrades to silence rather than to a correction** (§12).

A distant event is therefore listed with only what is certain — who, and when. **The day fills in as it approaches**, which is also how people actually think about their week.

## 10. Scenario — the first sixty seconds

You download the app. You open it. You know nothing about it. Nobody has explained anything.

**Second zero.** It opens on today. No splash screen, no logo animation, no welcome, no "let's get you set up." The first thing on screen is never a loading state — if the day is not ready, the date is there and the day fills in beneath it.

**Seconds three to fifteen — you see a real day, already populated.** Actual events, actual times, in your time zone. Not a demo, not placeholder content, not an empty state asking you to choose something. The product is already doing its job before it has asked you for anything.

**Where the content comes from:** the device already knows where it is. From locale alone the app assumes the national teams, the biggest local club, and events that are major for everyone — Olympics, World Cup, Champions League. That is a defensible default, not a claim of knowledge, and for this user it is most of the list without a single question.

Deliberately **not** assumed: Formula 1, Ajax, the Premier League. Those are genuine personal interests that locale cannot imply. Guessing them would be presumptuous and probably wrong.

So the shape is: **useful at second five, correct at minute three.** Far better than useless until configured.

**Seconds fifteen to forty — you understand the product without being told.** Because one event carries *"A win puts Žalgiris in the top eight"* and the one below it is bare, you learn the entire model at a glance: some things matter, most things do not, and the app will tell you which and why.

**The reason line is also the onboarding.** No tour, no coach marks, no tooltips, no explanatory first-run card. The defining feature teaches the product by existing.

**Seconds forty to sixty — nothing happens.** The app asks for nothing. This is the most important behaviour in the scenario.

### What is deliberately removed

| Removed | Why |
|---|---|
| Account or sign-in | Nothing here needs one. Sync is not in v1. |
| Notification permission | There is nothing to notify about yet, and asking before earning it is exactly what "earned" means. Reach is deferred anyway. |
| Sport / league / team pickers | A form is not a product. Locale covers most of it; the rest is a small, pleasant task the user chooses to do. |
| Tour, coach marks, tooltips | If the product needs explaining, the product is wrong. |
| Paywall or trial prompt | Not in the first sixty seconds of anything. |
| An empty state with a call to action | The forward line already does that work honestly. |

Six removals, no additions. Every one of them is a step that other sports apps take and that this product does not need.

### The correction path is a permanent feature, not a first-run step

The defaults will be somewhat wrong — no F1, no Ajax. There has to be a way to say so.

That way exists permanently, is findable when wanted, and **never nags.** It is not a first-run event, which means there is no onboarding to skip, resume, or get stuck in. Minute three is *"add F1 and Ajax"* — a small deliberate act, not a gate you must pass before the product will work.

**The app does not learn your interests from what you tap.** Inferring preference from behaviour is the engagement machinery this product rejects, and it is the same category as inferring watched state. You tell it, or it guesses from locale. It never watches you.

### The uncertainty worth naming

**If the first day is empty, the first thing a new user sees is "Nothing tonight."**

That is either the strongest possible statement of what this product is, or it reads as broken.

The existing forward rule already softens it — *"Nothing tonight. Next: Žalgiris, Friday 20:00"* is an answer plus a plan, not an empty screen. I would ship that with no special case, because a first-run exception is exactly the kind of thing that stops a product feeling inevitable.

But it is a real risk and it is testable. If we find ourselves wanting to special-case the first open, the honest reading is that the empty day is not strong enough *generally*, and that is worth knowing before it is papered over.

## 11. What happens when you tap

**An event that is ahead:** when it starts, where to watch, its reason if it has one, and how long until it begins. Nothing about form, standings, lineups or predictions.

**An event in progress:** that it is on, where, and how long it has been running. **No score.** Joining live is one action.

**A sealed event:** the fidelity ladder from §6 of PRODUCT.md, highest rung first. *Full replay* is offered before *extended highlights*, which is offered before *the result*.

**The result is never one tap away.** It requires a deliberate, separately labelled action — you are asking to give up, and it should feel like a decision rather than a slip. It is never rendered in passing, never in a preview, never as a number attached to something else.

**Tapping never reveals more than the thing you tapped.** Opening a finished Ajax match must not expose the Champions League table, because a table is a result wearing a different shape.

## 12. How the product explains itself

**The reason line is one plain sentence, and it is the only justification that exists.** No stars, no scores, no icons, no hidden weighting.

Three forms cover almost everything:

- **Consequence** — *"A win puts Žalgiris in the top eight."*
- **Rarity** — *"First Lithuania–Serbia meeting since 2022."*
- **Attachment** — *"Ajax away at PSV."*

### The maturity rule

**The app becomes more informative as time moves forward, never more revealing.**

An explanation matures as certainty increases. It is not frozen — it sharpens.

| When | Reason |
|---|---|
| Wednesday | *"Potential playoff implications."* |
| Friday morning | *"Žalgiris can secure a playoff place."* |
| 30 minutes out | *"Starts in 30 minutes."* (status, alongside the reason) |
| Finished | Sealed. Nothing added. |

None of those contradict each other and none reveal a result. Three constraints keep it honest:

1. **Maturity means precision, not volume.** The sentence becomes more certain. It never becomes a paragraph, and it never grows into lineups, form, weather or news.
2. **When a reason can no longer be stated safely, it degrades to silence — never to a correction.** If a result elsewhere makes *"potential playoff implications"* false, saying so would reveal that result. The line falls back to a stable reason or disappears. **Silence is always safe.**
3. **Status and reason are two channels.** Timing becomes prominent as an event nears, but it does not consume the reason. The moment you are deciding whether to sit down is the worst possible moment for the app to stop saying why it matters.

**After scheduled end, the app must not distinguish "still running" from "finished."** A basketball game still on at +10 minutes means overtime; a football match still on at 21:15 means added time. Both are results. Status goes neutral at the scheduled end and stays there until you reveal.

If no sentence can be written, the event is not surfaced. There is no unexplained emphasis anywhere in the product.

## 13. Rules discovered

Derived from the scenarios above, not invented beforehand.

1. **State is a function of time, and changes on its own.** Ahead, in progress, unwatched. The agenda and catch-up are one list.
2. **Chronological order, always.** Importance is carried by the reason line, never by position.
3. **The verdict is time-aware.** The same day reads differently at 09:00, 18:30 and 19:20.
4. **One surfaced event per conflict, not per day.** The constraint is your time, not the screen's.
5. **Occasions absorb volume.** Fifteen events become one expandable entry. This is what makes the Olympics survivable.
6. **Sessions hold spoiler state independently.** Qualifying spoils the grid, so the grid is a result.
7. **The reason never changes tense.** Frozen at pre-event wording, forever.
8. **The result is at least two deliberate actions away**, and always labelled as itself.
9. **A tap reveals only what was tapped.** Tables, standings and grids are results in disguise.
10. **An empty day is a complete answer**, and it still shows what is next.
11. **Sealed, not watched.** The app describes its own behaviour, never your history.
12. **The app records actions, never assumptions.** State the user creates is fine; state the app infers is bookkeeping.
13. **The past expires rather than being cleared.** Things stop being offered when they stop being watchable.
14. **More informative over time, never more revealing.** Explanations mature as certainty increases; they degrade to silence rather than to a correction.
15. **A tap reveals only what was tapped.** This is a navigation rule, not only a spoiler rule.
16. **After scheduled end, status goes neutral.** "Still running" reveals overtime.
17. **The product asks for nothing on first open.** It is populated from locale, correct within minutes, and it never learns your interests by watching you.
18. **The reason line is also the onboarding.** If the product needs explaining, the product is wrong.

## 14. Still open

- Should the product invite pinning at the start of a major event, or wait to be asked? (§7)
- When an occasion contains one surfaced session and six listed ones, is it collapsed or expanded on arrival?
- Does an in-progress event you do not care about need to appear at all?
- How is *"still avoiding spoilers?"* triggered — every morning, only when something is sealed, or only after a gap?
- What is the actual expiry window, and does it differ by rung of the ladder? A replay dies faster than highlights.
- Where does the tension in §15 get resolved?
- Should the first open be special-cased if today is empty? (§10 — recommendation is no.)
- Where does the correction path live, given that a tap may only reveal what was tapped?

## 15. A tension worth naming

**"A tap reveals only what was tapped"** and **"surface things I would not have known about"** pull against each other.

The first makes the product shallow by design — no adjacent information, no related events, no lateral browsing. That is correct, and it is what stops this becoming a sports database.

But it also means discovery can never come from digging, which leaves the Tier 4 blind spot (§7) with only one exit: **the product volunteers on the timeline, or it does not happen at all.** Nothing is found by exploring, because there is nothing to explore.

That is a clean division and probably the right one. It does mean the timeline carries the entire burden of discovery, and pinning stays the only manual escape.
