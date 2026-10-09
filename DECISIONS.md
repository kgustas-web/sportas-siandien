# Decisions

Append-only. Newest last. Format: date · decision · alternatives · reason · decided by.

---

## 2026-09-07 · Phase 0 gate passed, vision accepted
- **Alternatives:** rework the vision first.
- **Reason:** the four questions and the n=1 framing hold up. Detail belongs in phase 1.
- **Decided by:** Gustas.

## 2026-09-07 · Coverage is a four-tier model, and tier is a product mechanism
- **Decision:** tiers 1–4 as recorded in PRODUCT.md §4. Tier drives prominence, ordering and protection — it is not just a preference list.
- **Alternatives:** flat list of teams; per-competition toggles.
- **Reason:** the user's interests are genuinely uneven. A flat list would rank a Premier League match alongside a Žalgiris EuroLeague game, which is wrong for this user.
- **Decided by:** Gustas (tiers), Claude (mechanism reading).

## 2026-09-07 · Live is the default; fallback is an ordered fidelity ladder
- **Decision:** live → full replay → extended highlights → result. Catch-up presents the highest rung still available; a result is the last resort and must feel like one.
- **Alternatives:** catch-up as a list of scores; catch-up as highlights-only.
- **Reason:** the user watches live and treats a bare result as failure. The product's job is to protect the option to still watch properly.
- **Decided by:** Gustas (behaviour), Claude (ladder as mechanism).

## 2026-09-07 · Spoiler safety is absolute inside the app, and the app cannot control outside it
- **Decision:** zero tolerance for in-app leaks. Strategy against external leaks is to be opened first, not to filter the world.
- **Alternatives:** attempt to intercept or filter external sources.
- **Reason:** every named leak source (WhatsApp, Reddit, Instagram, X, news, YouTube, Google Discover, friends) is outside the product's reach.
- **Decided by:** Claude, from the user's answers. Not yet challenged.

## 2026-09-07 · Revised: notifications are bounded by event start, not banned
- **Decision:** supersedes the v0.1 "zero notifications" rule. Pre-event alerts are permissible in principle because they cannot spoil. Post-event alerts are permanently prohibited.
- **Alternatives:** keep the blanket ban.
- **Reason:** a pull-only product cannot deliver Tier 1's "never want to miss". The blanket ban conflated two surfaces with opposite risk profiles.
- **Decided by:** Claude. **Whether to actually use pre-event alerts remains open** — see PRODUCT.md §11.

## 2026-09-07 · The primary unit is the session, grouped into an occasion
- **Decision:** session = one watchable thing with a start time. Occasion = weekend, matchday, tournament day. Spoiler state tracked per session.
- **Alternatives:** the match as the atomic unit.
- **Reason:** F1 weekends contain four separately watchable sessions with their own spoiler chains. Tournament days and two-legged ties share the shape.
- **Decided by:** Claude, from the F1 answer. Open to challenge.

---

## Open, recorded here so they are not lost
- Is the product a place you go, or a thing that reaches you? (PRODUCT.md §11 — the next decision)
- Does following a team include its domestic league? (§9.5)
- How does the product learn that something has been watched?

## 2026-09-07 · Vision reframed from speed to judgement
- **Decision:** the vision is "the single place I trust to know what sport deserves my attention today." Supersedes "the first safe place I check before opening anything else."
- **Alternatives:** keep the speed framing; combine both.
- **Reason:** the goal is reducing uncertainty and planning time, not replacing other sports apps or winning a race against WhatsApp. Trust, not latency, is the metric.
- **Consequence:** spoiler safety drops from strategy to hygiene. The judgement engine becomes the core product.
- **Decided by:** Gustas.

## 2026-09-07 · The next decision is the agenda rules, not reach
- **Decision:** "What deserves to appear in my agenda?" is settled before any question about surfaces, widgets or notifications.
- **Alternatives:** decide reach first (Claude's v0.2 recommendation).
- **Reason:** admission and prominence rules define the product; how it reaches you is downstream and cheaper to change.
- **Decided by:** Gustas. Claude's v0.2 recommendation withdrawn.

## 2026-09-07 · Reversed: "worth watching" is the core, not a sort order
- **Decision:** supersedes the v0.2 recommendation to demote it.
- **Reason:** the volume argument (few nights have collisions) was correct but led to the wrong conclusion. Judgement also runs on quiet nights, where "nothing tonight" is a valuable output. Under the new vision, judgement is the product.
- **Decided by:** Claude, prompted by Gustas's reframe.

## 2026-09-07 · Admission and prominence are separate decisions
- **Decision:** wide admission net, strict prominence ladder. Four placements: Headline (max one, often zero), Agenda, Ambient, Excluded. PRODUCT.md §5.
- **Alternatives:** a single in/out filter.
- **Reason:** a binary filter either drowns the user or hides things. Separating the two lets almost everything be knowable while very little is loud.
- **Decided by:** Claude. Proposed, awaiting confirmation.

## 2026-09-07 · Five factors, ranked; the stated-reason and commitment rules
- **Decision:** placement decided by attachment → consequence → rarity → tier, gated by availability. Nothing promotes above Ambient without a one-line plain-language reason. At most one headline.
- **Reason:** named factors with stated reasons are auditable and correctable; an opaque score is not. Committing to one headline is what distinguishes the product from a fixture table.
- **Decided by:** Claude. Proposed, awaiting confirmation. **Open: does attachment really beat tier?**

## 2026-09-07 · The product may never predict quality
- **Decision:** it may say an event matters. It may never say an event will be good.
- **Reason:** stakes, rarity and attachment are knowable in advance; entertainment is not. Predicting quality guarantees frequent wrongness, which is fatal to a trust product. It also keeps pre-event copy spoiler-clean.
- **Decided by:** Claude. Not yet challenged.

## 2026-09-07 · No ranking engine in v1; one principle instead
- **Decision:** "The app surfaces what I would personally be disappointed to miss." The v0.3 five-factor model is withdrawn as a mechanism.
- **Alternatives:** keep attachment/consequence/rarity/tier as weighted rules.
- **Reason:** one user, no usage data. Inventing a weighting today means inventing it from nothing. The factors survive as observations about why answers come out as they do, not as rules. Real logic gets derived from evidence after months of use.
- **Decided by:** Gustas.

## 2026-09-07 · Four placements cut to two
- **Decision:** Surfaced and Listed. "Excluded" was a category error — it is the absence of admission, not a placement. "Ambient" was vocabulary the user would have had to learn.
- **Reason:** the model needed a table to explain itself, which failed the obviousness test. The UI communicates importance; the user never sees the terms.
- **Decided by:** Gustas.

## 2026-09-07 · "The reason is the feature" is a complexity governor
- **Decision:** kept, and reframed. Logic that cannot be stated in one plain sentence cannot ship.
- **Reason:** it is not only a UI rule. It is the mechanism that prevents the surfacing logic from growing back into an algorithm.
- **Decided by:** Claude, from Gustas's two requirements.

## 2026-09-07 · A quiet evening is part of the vision
- **Decision:** "If nothing deserves your attention tonight, the product says so." Promoted from a §5 detail to a core idea in §2.
- **Reason:** it is the most differentiating thing the product does, and it is the trust mechanism — an app that finds something every day cannot be believed on the day it matters.
- **Decided by:** Gustas.

## 2026-09-07 · Simplicity is a gate, not a preference
- **Decision:** the product philosophy must feel obvious rather than clever. Concrete test: the surfacing rules must fit on one screen and let a person predict the app's behaviour.
- **Reason:** the target is a product that feels inevitable — as if Apple had built a sports companion.
- **Decided by:** Gustas.

## 2026-09-07 · Rules are derived from scenarios, not written in advance
- **Decision:** the "five rules" exercise is dropped. Behaviour is specified through concrete situations (AGENDA.md) and rules are extracted from them.
- **Alternatives:** write the surfacing rules abstractly, then test them.
- **Reason:** the product does not exist yet and there is no usage evidence. Rules written in the abstract are guesses.
- **Decided by:** Gustas.

## 2026-09-07 · An event has three states, and they change with time
- **Decision:** ahead → in progress → unwatched. Watched events leave the product.
- **Consequence:** the agenda and catch-up are the same list at different times of day. Today's finished events stay on today; yesterday's move to catch-up.
- **Decided by:** Claude, derived from the Wednesday 18:30 scenario.

## 2026-09-07 · Corrected: one surfaced event per conflict, not per day
- **Decision:** supersedes the v0.3 commitment rule.
- **Reason:** the sequence-vs-conflict scenario broke it. Two events at 19:00 and 21:30 can both be watched, so demoting one is arbitrary. The constraint is the user's time, not the screen's tidiness.
- **Decided by:** Claude, from the busy-evening scenario.

## 2026-09-07 · The reason never changes tense
- **Decision:** a surfaced event's reason line is frozen at its pre-event wording and never rewritten.
- **Reason:** "Žalgiris can clinch a playoff spot" is safe forever; "Žalgiris clinched a playoff spot" is a spoiler. Freezing the tense eliminates an entire class of leak without needing a filter.
- **Decided by:** Claude, from the spoiler scenarios. **Strong candidate for the most important rule in the product.**

## 2026-09-07 · Occasions absorb volume
- **Decision:** F1 weekends, Olympic days and tournament days are single expandable entries. Sessions inside hold spoiler state independently.
- **Reason:** it is the mechanism that makes a fifteen-event day behave like a three-event day. Also: an F1 starting grid is a qualifying result, so structural leaks matter as much as textual ones.
- **Decided by:** Claude, from the F1 and Olympics scenarios.

## 2026-09-07 · Chronological order, always
- **Decision:** the day is ordered by time. Surfaced events are not lifted into a separate section; they stay in place and carry a reason line.
- **Reason:** importance becomes a property of the item rather than of its position, which removes a layer of structure the user would otherwise have to learn.
- **Decided by:** Claude, from the Wednesday scenario.

## 2026-09-07 · No watched state; events are sealed until explicitly revealed
- **Decision:** the product never tracks or infers what has been seen. Finished events are *sealed* — a claim about the app's behaviour, not about the user. One dismissible question, "Still avoiding spoilers?", unseals a day in one gesture.
- **Alternatives:** manual watched marks; inferred watched state from timing.
- **Reason:** failure costs are asymmetric. Wrongly assuming watched spoils the user and ends the product; wrongly sealing shows a redundant entry and costs one tap. Also removes all bookkeeping, which a quiet companion cannot demand.
- **Decided by:** Gustas.

## 2026-09-07 · The app records actions, never assumptions
- **Decision:** state created by an explicit user action (revealing a result, pinning an event) is kept. State the app infers about the user is not.
- **Reason:** the general form of the sealing decision. It is the line between memory and bookkeeping.
- **Decided by:** Claude, generalising Gustas's challenge.

## 2026-09-07 · The past expires rather than being cleared
- **Decision:** events stop being offered when they stop being realistically watchable. They never unseal on their own.
- **Reason:** answers the accumulation problem without reintroducing watched state. "No longer worth offering" is a claim the app can justify; "you have seen this" is not.
- **Decided by:** Claude, from the yesterday scenario.

## 2026-09-07 · Three discoveries promoted to defining principles
- **Decision:** (1) the reason is the feature; (2) a tap reveals only what was tapped, as a navigation rule; (3) chronological order is never broken, importance decorates the timeline.
- **Reason:** all three emerged from scenario work rather than abstraction, and all three constrain the product in useful ways beyond their original purpose.
- **Decided by:** Gustas.

## 2026-09-07 · A reason has a shelf life at both ends
- **Decision:** a reason appears only when it is safe to assert, and never changes once written.
- **Reason:** consequence is volatile — "a win puts them top eight" can be false three days out. A wrong reason is worse than no reason, because the reason line is the product's credibility. Combined with the tense freeze, the reason line is bounded by time on both sides.
- **Decided by:** Claude, from the planning-ahead scenario.

## 2026-09-07 · Superseded: the maturity rule replaces the frozen reason
- **Decision:** "The app becomes more informative as time moves forward, never more revealing." Supersedes "the reason never changes tense."
- **Reason:** freezing the wording was a proxy for safety, not the actual invariant. It banned obviously safe and useful updates ("starts in 30 minutes"). The real axis is informative vs revealing, not early vs late.
- **Decided by:** Gustas.

## 2026-09-07 · Three clauses the maturity rule needs
- **Decision:** (1) when a reason can no longer be stated safely it degrades to silence, never to a correction — correcting it would reveal the result that made it false; (2) maturity means precision, not volume — the sentence never becomes a paragraph; (3) after scheduled end, status must not distinguish "still running" from "finished", because that reveals overtime or added time.
- **Reason:** without (1) the rule can be followed honestly and still spoil. (2) prevents drift toward a database. (3) is the same class of structural leak as the F1 grid.
- **Decided by:** Claude, challenging Gustas's formulation. Accepted as refinements.

## 2026-09-07 · Status and reason are separate channels
- **Decision:** timing does not consume the reason line as an event approaches.
- **Reason:** the moment the user is deciding whether to sit down is the worst moment for the app to stop saying why it matters.
- **Decided by:** Claude. Open to challenge.

## 2026-09-07 · The product asks for nothing on first open
- **Decision:** no account, no notification prompt, no pickers, no tour, no paywall, no empty-state call to action. The app opens populated from device locale — national teams, biggest local club, globally major events — and is transparent that these are defaults.
- **Alternatives:** a one-question setup; a conventional onboarding flow.
- **Reason:** the phone already knows where it is, and asking a question you know the answer to is what makes software feel bureaucratic. Locale covers most of this user's list. Useful at second five, correct at minute three, beats useless until configured.
- **Decided by:** Claude, from the first-sixty-seconds scenario. Awaiting confirmation.

## 2026-09-07 · The correction path is a permanent feature, not a first-run step
- **Decision:** the way to say "this is not quite me" exists permanently and never nags. There is no onboarding to skip, resume or get stuck in.
- **Reason:** removes the first-run special case entirely. Adding F1 and Ajax becomes a small deliberate act rather than a gate.
- **Decided by:** Claude.

## 2026-09-07 · The app never learns interests from behaviour
- **Decision:** no inference of preference from taps or opens. You tell it, or it guesses from locale.
- **Reason:** same category as inferred watched state. Learning from behaviour is the engagement machinery this product rejects.
- **Decided by:** Claude, extending the "records actions, never assumptions" rule.

## 2026-09-07 · The defining insight: a result is a cost, not a payload
- **Decision:** "Every other sports app treats a result as the product. This one treats a result as a cost." For someone who watches, outcome information has negative value until they choose to spend it.
- **Reason:** it is the single claim that generates every other design decision — the quiet, the sealing, the refusal to predict quality, "nothing tonight" as an answer, tap-reveals-only-what-was-tapped. Found by writing an ordinary week and asking which parts a calendar could imitate.
- **Decided by:** Claude, from the week-in-the-life exercise. Confirmed as the product's reason to exist.

## 2026-09-07 · Reversed: sealing is the product, not its hygiene
- **Decision:** supersedes the v0.3 demotion of spoiler safety from strategy to hygiene.
- **Reason:** the v0.3 demotion was an over-correction. "Be faster than WhatsApp" deserved to die; spoiler safety went with it by mistake. The week test is decisive — delete the agenda and keep sealing, something survives; delete sealing and keep the agenda, it is a calendar with opinions. Three days of an ordinary week are calendar-replaceable; the two that are not are both sealing days.
- **Consequence:** the agenda is reframed as the mechanism by which the product knows what to protect, not as the product itself.
- **Decided by:** Claude, from the week-in-the-life exercise.

## 2026-09-07 · The fidelity ladder is the existential risk
- **Decision:** promoted from an open question to the risk that decides whether the product is worth building. May need answering before phase 4.
- **Reason:** if the app can only name a replay rather than reach it, the two days that justify the product collapse. Everything now rests on this and it is unverified.
- **Decided by:** Claude.

## 2026-09-07 · The four maturity clauses are core principles
- **Decision:** (1) more informative over time, never more revealing; (2) a reason that cannot be updated safely disappears rather than being corrected; (3) precision may increase, density may not; (4) status and reason are separate channels.
- **Decided by:** Gustas.

## 2026-09-07 · A row does only what it can; the detail screen is a decision screen
- **Decision:** upcoming rows are inert and carry no tap affordance. Live rows hand off to the broadcaster. Only sealed rows push to a screen.
- **Reason:** for an upcoming event the screen answered no question the row had not — and opening a broadcaster for something that has not started is worse than nothing. Only a sealed event carries a decision (which rung, or spend the result instead).
- **Consequence:** it is not an "Event Details" screen. Nothing on it is detail.
- **Decided by:** Gustas (challenge), Claude (rule).

## 2026-09-07 · Earlier holds only what can still be acted on
- **Decision:** an event leaves when its last rung expires. Reverse chronological. Availability and near expiry are stated on the row; expiry never re-sorts the list.
- **Consequence:** Earlier has no empty state — if nothing is watchable, the entry point on Today does not exist. And a result from three weeks ago is unfindable in the app.
- **Decided by:** Claude, from the Earlier design.

## 2026-09-07 · v1 stores no results at all
- **Decision:** "Show result" opens a web search rather than displaying a stored score.
- **Reason:** removes the entire result-data problem from v1, and is consistent with treating a result as a cost the product never holds. The app stops protecting you; it does not inform you.
- **Decided by:** Claude, during implementation. Revisit if it feels wrong in use.

## 2026-09-07 · Phase 5 — build. Native SwiftUI, hardcoded fixtures
- **Decision:** real iPhone app, SwiftUI, no dependencies, fixtures as Swift literals in one file. Architecture is explicitly not a priority.
- **Reason:** the biggest unknown is no longer the design, it is whether the app gets used daily. A month of real use outweighs further discussion.
- **Decided by:** Gustas.

## 2026-10-09 · The lens is navigation, what sits under it is a filter, and they look different
- **Decision:** the lens (All, Lithuania, a sport) is set as words in the bar at every width. Its parts are a row of small pills in the page: Lithuania divides by sport, a sport by competition. All has no second row.
- **Alternatives:** two rows of pills (what shipped — nothing said which row was in charge); one row that drills in, the parent collapsing to a single pill (costs two taps to change lens).
- **Reason:** on a phone both levels were identical pills under an empty 44px bar. The lens now is the bar.
- **Cost, named:** the bar no longer shows which day you have scrolled to. The wide layout never did.
- **Decided by:** Gustas (problem), Claude (shape). Confirmed by Gustas.

## 2026-10-09 · Browse is removed; its counts move onto the pills
- **Decision:** no Browse screen. Lens plus pill reaches the same sport → competition → fixtures list in place, and each pill carries how many fixtures are still to come.
- **Reason:** subtract before adding. Browse answered the same question three screens away and cost a permanent row above Today.
- **Exception:** a sport whose parts are already single rows in the timeline (Formula 1 weekends) gets no pills — they would be a second copy of the list.
- **Decided by:** Gustas.

## 2026-10-09 · Earlier follows the lens
- **Decision:** the "from earlier" count and list are scoped to the current lens and pill.
- **Reason:** it said "13 from earlier" inside Lithuania when none of the 13 were Lithuanian. A lens is a scope; a number that ignores it is wrong.
- **Decided by:** Claude. Confirmed by Gustas.

## 2026-10-09 · Feed competition codes are spelled out
- **Decision:** `[CL]`, `[EL]`, `[Conf]` become Champions League, Europa League, Conference League (`TAGS` in `Web/sources.py`, `competitionTags` in the app). Unknown codes pass through unchanged.
- **Reason:** the competition name is now read on its own as a pill, not only as small print.
- **Decided by:** Claude. Confirmed by Gustas.

## 2026-10-09 · Counts stay on the Lithuania pills only
- **Decision:** a pill shows a count inside Lithuania and nowhere else.
- **Alternatives:** counts on every pill (first build); no counts.
- **Reason:** "Gymnastics 1" says there is one thing and not to miss it. "EuroLeague 373" is the size of a feed, not a judgement about any evening.
- **Decided by:** Gustas, on Claude's challenge.
