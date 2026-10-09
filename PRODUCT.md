# Sports Companion — Product Vision

Status: **draft v0.7** — phase 1, definition. Principles now derived from scenario work in AGENDA.md.

Changelog: v0.7 names the defining insight — a result is a cost, not a payload — and restores spoiler safety to the centre of the product after the week-in-the-life exercise. Behaviour and scenarios live in AGENDA.md.

---

## 1. The problem

A person who follows a specific, scattered set of teams across basketball, football and motorsport faces a recurring question that no app answers: **out of everything on tonight, does any of it actually deserve my evening?**

Fixtures are spread across leagues, competitions and time zones. Rights are fragmented, so *where* is a separate lookup from *when*. Results leak from everywhere — WhatsApp, Reddit, Instagram, X, news sites, YouTube thumbnails, friends — so watching later is a minefield.

Existing apps answer "everything." A fixture list is not an answer, it is the raw material for one.

## 2. The product

A quiet, personal companion for iPhone.

> **"The single place I trust to know what sport deserves my attention today."**

The goal is reducing uncertainty and planning time, not replacing every other sports app. Stats, tables, commentary and news live elsewhere.

**A quiet evening is valuable information.**

This is the idea the product is built around. If nothing deserves your attention tonight, the app says so — plainly, confidently, without apology and without manufacturing something to fill the space. Every other sports app is trying to take your evening. This one sometimes hands it back.

That is also the trust mechanism. An app that finds something important every single day cannot be believed on the day it matters.

*Short form, if it helps: it tells you what is worth your evening, including when nothing is.*

### The insight

> **Every other sports app treats a result as the product. This one treats a result as a cost.**

For a person who watches sport, information about the outcome has **negative value until they choose to spend it.** Flashscore exists to deliver a number as fast as possible; for someone who intended to watch, that number destroys the thing they wanted.

Everything in this document follows from that inversion — the quiet, the sealing, the refusal to predict quality, "nothing tonight" as an answer rather than an error, a tap revealing only what was tapped. None of those are style choices.

It also places the agenda correctly: **the agenda is not the product. It is how the product knows what to protect.** You cannot preserve someone's option to watch something properly unless you know they wanted to watch it.

## 3. The person

**Primary user: Gustas.** One person, built to fit one life. An n=1 product can make sharp choices a consumer product cannot, and sharp choices are what this category lacks.

- Based in **Lithuania**. Local time is the spine.
- **Watches live** wherever possible.
- **Avoids spoilers aggressively.**
- Follows a specific, uneven set of interests — §4.

## 4. What he follows

**Tier 1 — never wants to miss.** Basketball: Žalgiris Kaunas, Lithuania national team, EuroLeague, EuroBasket, Olympic basketball, FIBA World Cup.

**Tier 2 — usually watches.** Football: Lithuania national team, Ajax, Žalgiris Vilnius, Champions League, European Championship, FIFA World Cup, Premier League (selected matches — see §5.4).

**Tier 3 — follows consistently.** Formula 1: every session of every race weekend.

**Tier 4 — major events only.** Olympics, World and European Athletics Championships, major Lithuanian athlete participation, tennis Grand Slam finals, other exceptional events.

Tiers 1–3 have published calendars and can be built mechanically. Tier 4 cannot — see §10.2.

**Volume is bursty.** Estimate to verify: F1 alone is roughly 100 sessions a year. Club basketball and football add a few hundred more, September to May, plus dense summer tournament blocks. Most evenings have nothing or one thing. A minority have several.

## 5. What gets surfaced

One principle decides it:

> **The app surfaces what I would personally be disappointed to miss.**

Not what is objectively significant. Not what a general audience would rate. What *this person* would regret missing. It is a test a human can apply in a second, and it is falsifiable in real use — you either were disappointed or you were not.

### 5.1 Two levels, no vocabulary

- **Surfaced** — the app is telling you about this. Rare. Often nothing.
- **Listed** — the app is not hiding it from you. Quiet, plain, unemphasised.

Everything else is simply not in the product.

You never see these words. There is no "importance" label, no tier badge, no section called Ambient. There is an answer at the top of the day and the rest of the day beneath it. **If the model needs explaining, it is wrong.**

### 5.2 The reason is the feature

Nothing is surfaced without a plain-language line saying why.

- "Žalgiris can clinch a playoff spot."
- "First Lithuania–Serbia meeting since 2022."
- "Ajax away at PSV."

No stars, no scores, no flame icons, no hidden weighting. Three things follow from this rule, and the third is the important one:

1. You can tell at a glance whether the app's judgement is any good.
2. You can disagree with it specifically rather than vaguely.
3. **It caps the complexity of the system.** Logic that cannot be stated in one sentence cannot ship, because there would be nothing to write on the card. The reason rule is what keeps §5 from growing back into an algorithm.

### 5.3 Why there is no ranking engine

The v0.3 factors — attachment, consequence, rarity, tier — were an attempt to compute the disappointment test. They were not wrong, but they were premature, and inventing a weighting today would mean inventing it from nothing.

They survive as **observations, not rules** — notes on why the answer usually comes out the way it does:

- Your teams and your country matter more than anything else.
- Events that decide something matter more than events that do not.
- Rare occasions matter more than frequent ones.
- If you cannot watch it, it is not a plan.

Real ranking logic is a question for after months of use, derived from evidence rather than guessed at now. Until then the rules stay few and legible enough to read in full on one screen.

### 5.4 The principle applied

- **Žalgiris domestic matches:** listed by default, surfaced when the game decides something. You are not disappointed to miss a Tuesday in November; you are disappointed to miss a playoff game. Same rule for Ajax in the Eredivisie.
- **Friendlies:** club pre-season is out entirely. National team friendlies are listed — Lithuania plays rarely enough to be worth knowing about. Pre-tournament warm-ups are surfaced. *"Friendly" is not a category the product reasons about.*
- **Premier League:** unresolved, and the weakest entry on the list. It is the only thing you follow with no team you support and no scarcity behind it, which leaves the app judging pure quality — the one thing it is worst at. **Recommendation: cut it from v1.** If kept, the honest version is a hard rule (top-six meetings, or deciders in the closing rounds) plus manual pinning, not a judgement.
- **Formula 1:** one row per race weekend, expandable. Practice is listed, qualifying and race can surface. A weekend is one occasion containing several sessions; spoiler state is tracked per session, because qualifying spoils the grid but not the race.

## 6. Catching up

Live is the default. When live is impossible the fallback is ordered:

**Live → full replay → extended highlights → result.**

For each unseen event the product offers the highest rung still available, and you choose how far down to step. A result is what you get when you give up, and it should feel that way: deliberate, one tap deeper, never the default.

The value here is not telling you what happened. It is **protecting your option to still watch it properly.**

## 7. Spoilers

Every leak source you named is outside this product's control. It cannot promise a spoiler-free life. It guarantees one thing absolutely:

**The app never reveals a result you have not asked for.** Not in a list, header, preview, thumbnail, badge or notification. One leak and trust is gone.

**This is the product, not its hygiene.** v0.3 demoted spoiler safety to a requirement. That was an over-correction to a weak strategy — "be faster than WhatsApp" deserved to die, but it took the wrong thing with it.

The week-in-the-life exercise settled it. On an ordinary Monday, Wednesday and Friday this product is a quieter fixture calendar that Apple Calendar could imitate. On Saturday and Sunday — the days you missed something and watched it properly anyway — it is something nothing else can be. Delete the agenda and keep sealing, and something survives. Delete sealing and keep the agenda, and you have a calendar with opinions.

**Sealing is the load-bearing wall.**

Note the asymmetry: Tier 1 events are both the ones you most want to watch properly and the ones most likely to be spoiled, because Lithuanian friends and media discuss Žalgiris immediately. Protection must be strongest exactly where it is hardest.

## 8. Principles

The first three are the product's defining commitments. They came out of scenario work, not from a whiteboard.

1. **The reason is the feature.** Every surfaced event justifies itself in one short, plain sentence. An explanation is worth more than any badge, star or hidden ranking — it is the only thing that lets you judge whether the product's judgement is any good.
2. **A tap reveals only what was tapped.** A navigation principle, not only a spoiler rule. The product never discloses adjacent information you did not ask for: no related events, no standings behind a match, no lateral browsing. It is shallow on purpose.
3. **Chronological order is never broken.** People understand time without being taught. Importance decorates the timeline; it never replaces it.

Then:

4. **Surface what he would be disappointed to miss.** Everything else is quiet.
5. **A quiet evening is an answer.** Never manufacture a headline.
6. **Explain, never predict.** Significance is knowable in advance; quality is not.
7. **More informative over time, never more revealing.** Explanations mature as certainty increases. When a reason can no longer be stated safely, it degrades to silence rather than to a correction. Precision may increase; density may not — the sentence never becomes a paragraph. Status and reason stay separate channels.
8. **Never spoil, and never track.** Results on request only. The app records what you did, never what it assumes about you.
9. **Finite.** The day ends. So does the screen.
10. **Native and obvious.** It should feel like it shipped with the phone.

## 9. Scope

**In v1 (proposed):** today's agenda with reasons · a forward horizon far enough ahead to keep an evening free · catch-up on the fidelity ladder · manual pinning as the escape hatch · one-time setup of teams and competitions.

**Not in v1:** live scores · tables, stats, lineups · post-event notifications · social features · betting and fantasy · news aggregation · accounts and sync · any sport not in §4.

**Never:** engagement mechanics — streaks, badges, red dots, filler. Predicted quality. Anything that spoils.

## 10. Open challenges

Settled arguments have moved to DECISIONS.md. These are still live.

### 10.1 "Manually curated" hides a fork, and it matters

If v1 feels hand-curated, something has to do the curating. There are only two honest answers, and they are different products:

- **You curate.** You pin what matters, and the app is a well-mannered personal calendar that remembers. Useful — but then the app does not know what deserves your attention, you do, and the vision sentence is false.
- **Simple rules curate.** Few enough to read on one screen, but the app still takes the position.

*Recommendation: the second.* Something on the order of five rules — your teams' decisive games surface, all national team games surface, everything else is listed — with pinning as the escape hatch rather than the mechanism. That keeps the hand-made feel without quietly making you the product's brain.

The risk of leaving this unstated is drifting into the first by default.

### 10.2 The disappointment principle has one blind spot

You can only be disappointed to miss something you knew was possible. The principle is backward-looking, so it covers tiers 1–3 well and cannot reach Tier 4 at all — you will not miss a Lithuanian in an Olympic final if you never knew they qualified.

Manual pinning remains the answer for now. Worth naming rather than letting the principle paper over it.

### 10.3 Refinement needs evidence, and the product may already have it

"Refine after months of real usage" only works if something records those months. But a logging mechanism is exactly the machinery that would make this feel less inevitable.

The elegant answer may already be built in: **catch-up is the signal.** If you repeatedly step down the fidelity ladder for something the app never surfaced, that is the app being wrong, recorded by a feature that exists anyway. No dashboard, no new concept.

### 10.4 "Deserves my attention" is a function of the evening, not the event

The app knows the event perfectly and knows nothing about whether you are free. So the honest promise is *here is what matters, and why* — not *here is what you should do tonight*. For v1 the app ranks significance and leaves fit to you. Reading your calendar is a much larger product and a privacy decision besides.

### 10.5 "Today" is too short a horizon

Qualifying is Saturday; the decision to keep Saturday free happens Wednesday. "Today" must quietly mean *today, plus anything soon that needs a decision now*, or the product cannot help you plan time — half its purpose.

## 11. Open questions

- Premier League: cut, hard-rule, or manual? (§5.4)
- What are the five rules in §10.1, written out?
- Where is the line between surfaced and listed for a Žalgiris domestic game? "Decides something" needs one worked example.
**The risk that decides whether this is worth building:** do full replays and extended highlights actually exist, and can the app get you to them, for these competitions in this country? If the app can only *name* a replay rather than reach it, the fidelity ladder is decorative — and both of the two days that justify the product collapse with it. Everything rests on this and it is unverified. It is a phase 4 question that may need answering early.
- How far does the forward horizon reach?

**Deferred deliberately:** whether the product may reach you before an event starts. The constraint that makes it safe either way — nothing reaches you after an event has started.

**Phase 4:** fixture, result and rights data for Lithuania — source, cost, licence.

## 12. The next decision

Write out the rules from §10.1 — five or so, in plain language, that a person could read on one screen and predict the app's behaviour from.

If they fit on a card, the product is ready for information architecture. If they do not, the model is still too clever.

## 13. Success

Not daily active use. Not session length. Not completeness.

**Fewer missed events that mattered, fewer evenings spent on ones that did not, and less time deciding.**

The product succeeds when "it did not flag anything tonight" is enough to make other plans without checking.
