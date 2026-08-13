## Scope note (material to the verdict)

I was handed the design from **§8.4 onward only** — §1–§8.3 (the character budgets, the six POI slots, the tab/stack diagram, the detail-item list, the alert copy, the empty-state variants) were truncated out of the prompt. Everything below is grounded in §8.4–§12, the §9 self-audit's own claims, and the settled record in `/Users/FullTimeStudio/Dev/lab/ev-guide/docs/adr/`, `/Users/FullTimeStudio/Dev/lab/ev-guide/docs/domain-model.md`, `/Users/FullTimeStudio/Dev/lab/ev-guide/CONTEXT.md`, and tickets 11/12/23/30. Where a defect depends on a section I could not see, I say so.

---

## FATAL

**D1 — The armed-watch row promises something the system has not been shown able to deliver.**
Rule broken: ADR-0002 / ADR-0008 honesty rule ("a stale green is impossible by construction"); constraint sheet A15 [hard] *"Requires `UNAuthorizationOptions.carPlay` **and** a category with `allowInCarPlay`. Both are required; either alone is insufficient"* + *"Users can switch CarPlay notifications off per app… the feature must degrade gracefully."*
Three independent holes converge on one row:
- §8.7's facet gate is `isSignedIn` only. **Nothing checks notification authorization.** A signed-in driver who never granted notifications (or who switched CarPlay notifications off in Settings) gets the arm button, taps it, sees the armed row, and will never be told. The car screen cannot ask, and guideline 2 forbids saying so.
- §8.7's *optimistic arm, silent reconciliation* survives a **permanently** failing POST. In the rural-Rwanda case ADR-0007 exists for, the POST never resolves, so the row never disappears — it just sits there asserting a live watch for two hours.
- §8.7 queues the arm and retries, but specifies **no capture-time expiry**, while ADR-0007 gives exactly that rule to reports ("expires unsent after its own decay window"). A watch delivered 3 h after the tap arms a 2 h errand the driver abandoned.
This lands on the one function that clears Apple's EV-1 bar, and it is the only forward-looking promise on the whole surface.
Fix: gate the action on `canWatch = isSignedIn && notificationsAuthorized` (silent omission, same rule as signed-out). Make the armed row carry its own confirmation state — an unsynced watch is **Unknown, not Armed** — and drop a queued arm whose `armedAt` is older than 2 h client-side, exactly as ADR-0007 drops stale reports.

**D2 — `Directions` can dead-end on the car screen, and §9.4 claims guideline-3 compliance it does not deliver.**
Rule broken: CarPlay review guideline 3 [hard] — *"All CarPlay flows must be possible without interacting with iPhone."*
§9.5's ladder is `comgooglemaps://` → Google Maps universal link → alert A2. With Google Maps absent, step 1 fails, step 2 resolves to Safari — **not a CarPlay app**, so it lands on the phone the driver must not touch (silently pushing content there is itself a guideline-3 hazard), and step 3 is an alert with no remedy. The primary action of the primary category terminates in a dead end. §10.10 names only the *"lands on the phone"* variant of this and misses the *not-installed* variant entirely, while §9.4 asserts "Every CarPlay flow… completes on the car screen."
Fix: reinstate Apple Maps as the terminal rung — `http://maps.apple.com/?daddr=<lat>,<lng>&dirflg=d`. It is guaranteed present, it *is* a CarPlay nav app, and in Rwanda it degrades to showing the destination rather than dead-ending. ADR-0004's "Apple Maps has no directions in Rwanda" is a reason not to make it *primary*; it is not a reason to prefer a dead end. Either that, or §9.4 must stop claiming guideline 3 is satisfied and §10 must carry it as the top review risk.

---

## MAJOR

**D3 — Blank car surface before first unlock, with no permitted string to explain it.**
Rule broken: A14 [hard] locked-phone data classes; §9.5's own claim that stores A and B sit at `NSFileProtectionCompleteUntilFirstUserAuthentication`.
That class is unreadable **before the first unlock since boot**. Driver reboots the phone, gets in the car, opens EV Guide: empty map, empty list. Guideline 2 forbids saying why. The design has empty-state variants for *zero results*, which is a different condition and will say the wrong thing.
Fix: ADR-0007 already ships a **bundled release-time directory snapshot inside the app binary** — bundle resources are readable at any lock state. Specify it as the car surface's floor: cache unreadable → paint from the bundled snapshot with all availability `Unknown`. Costs nothing, uses a settled asset, and makes the surface unconditionally paintable.

**D4 — The detail template has no re-render trigger, so a value can decay past its window while on screen.**
Rule broken: ADR-0008 — the guarantee is that decay runs *at render*; §8.7 says "Every render: re-run decay" but never says what makes the Information template render again. Its only candidate is the *"any other periodic update ≤ once / 10 s"* ceiling, which is a cap, not a commitment, and a 10 s poll on a static detail screen is exactly the churn Apple's p.5 numbers discourage.
Failure: driver opens detail on a 1 h 57 m-old driver report showing `Free · 2h ago`; three minutes later the window closes and the screen still reads `Free`. This is the screen the driver commits on.
Fix: schedule a one-shot timer at `min(decay deadline of every displayed value)` and re-render there. Deterministic, no polling, no I/O.

**D5 — `No recent report` renders Unknown as an absence.**
Rule broken: `CONTEXT.md`, **Unknown** — *"The normal case, not a failure… **Not to be rendered as an error or an absence**."* ADR-0002: *"an interface that greys out or apologises for unknown availability renders the whole map as broken."*
§10.12 confirms this is the string a reviewer (and most drivers, most of the time) will see on nearly every row. It is literally a sentence about missing data.
Fix: when availability is Unknown, spend the slot on what the listing *does* know — `4 bays · Type 2, CCS2` — so an Unknown station reads as a complete listing rather than an apology. That is the ADR's stated intent, and it is strictly more useful in the car.

**D6 — Pins carry Owner identity only, contradicting ADR-0002's own consequence clause.**
Rule broken: ADR-0002 — *"Stations with unknown availability show as complete, confident listings… **with availability as an additive badge when it exists**."* §10.2 removes the badge entirely.
The stated reason ("a coloured pin is a state claim with nowhere to put its age") does not hold for a badge drawn **only while the value is fresh**: such a badge encodes its own age by existing, and decays out by construction — the same mechanism the whole model rests on. Rejecting it costs the map its only glanceable signal and weakens the EV-1 story exactly where the reviewer looks first.
Fix: composite a fresh-only free-bay badge onto `pinImage`/`selectedPinImage` (iOS 16+). No stale-green risk is introducible; grey is never *drawn*, it is simply the absence of a badge.

**D7 — Source is dropped from the list row, and the drop is avoidable.**
Rule broken: ticket 11 — *"most recent wins, regardless of source, **with the source always shown**"*; ADR-0002 — *"Confidence as source plus age, not a score."*
§10.3 defends the drop on the grounds that "no conflicting claim is ever *resolved* on a row." That misreads the rule: it is a **confidence-expression** rule, not a conflict-resolution rule. `20 min ago` without a source is precisely the half-statement ADR-0002 rejects — an operator reading and a passing stranger's guess render identically.
Fix: it fits. `op·20m` is *shorter* than `20 min ago`. Use a 2–3 char source token. If the founder still wants the drop, it needs an ADR amendment, not a §10 flag.

**D8 — Freshness sits at the tail of the second slot, where truncation kills it — turning an honest string into a confident live claim.**
Rule broken: constraint sheet B4 [hard] *"put the driving-relevant substring first, because the tail is what gets cut"*; A11 [hard] `CPListItem` takes plain `String`, **no truncation control**.
`4.2 km · 2 of 4 free · 20 min ago` truncates to `4.2 km · 2 of 4 free` on a narrow head unit. The casualty is the freshness axis, and the survivor reads as live. This is the single worst truncation outcome available on the surface and the current ordering selects for it.
Fix: make state+age one unsplittable token and demote distance. On CarPlay distance need not be on the row at all (it can ride `summary`/`detailSubtitle`). On Android the corollary is stronger and free: **B6 [hard] — `Row.setTitle()` accepts `DistanceSpan`**, and **B9.1 [hard] — the refresh comparison excludes spans** — so distance belongs in the *title* as a live-updating span, freeing the entire second line for `source · age · state`. That single move satisfies the Android distance mandate, keeps distance ticking without burning quota, **and** recovers D7. Route the reordered projection to ticket 19, since `docs/domain-model.md` currently fixes two-line as `nameShort / distance · availability`.

**D9 — The Kigali-centroid fallback renders distances that are false for the user, as bare numbers.**
Rule broken: the honesty rule generally; and on Android, B2 [hard] *"Every non-browsable row MUST carry a `DistanceSpan`"* removes suppression as an option.
§8.6 substitutes the origin silently. A driver in Kampala — or Apple's reviewer in Cupertino — reads `3.2 km` for a station 1,500 km away. Nothing on the row can say the origin was substituted, and the two-slot budget offers no room.
Fix: the origin belongs in the **template title**, which is free of the row budget on both platforms — `Chargers near Kigali` when the origin is a fallback, `Chargers nearby` when it is real. One string, no row cost, and it disarms the reviewer case at the same time.

**D10 — Great-circle distance is rendered unlabelled on the car while ADR-0007 requires the opposite.**
Rule broken: ADR-0007 — *"the Valhalla preview falls back to straight-line distance from cached coordinates, **labeled as such**."*
§8.5's four reasons for great-circle on the car are all correct; the omission of the label is not addressed anywhere, and §10.4 discusses only car↔phone divergence. In a country whose road distance routinely runs 2–3× crow-flies, a driver picking on 6 km of remaining range picks wrong.
Fix: use a form that reads as crow-flies without a label sentence (`4.2 km direct`, or a `~` prefix), or amend ADR-0007 explicitly. Do not leave the car as a silent exception to a settled labelling rule.

**D11 — `Other free bays` asserts availability it cannot know.**
Rule broken: ADR-0002 / CONTEXT.md Unknown-is-normal; the design's own §11.14 rule against unproven claims (which covers negatives but not this positive).
At ~87% Unknown the button will overwhelmingly lead to a screen of stations with no known free bay. The title makes a claim the payload cannot support, and it is drawn as a `CPTextButton` — plain `String`, no variants, so it can also truncate to `Other free b…`.
Fix: rename to something the data can always support (`Nearby chargers`), **or** show the action only when ≥1 other station has a *fresh* Free bay and omit it otherwise. §11.13 already calls it cuttable — given D12 below, cutting is the cheapest resolution.

**D12 — The Grid "plug lens" tab configures a preference, navigates nowhere, and produces no visible feedback.**
Rules broken: CarPlay guideline 4 [hard] — *"Don't include features in CarPlay that aren't related to the primary task (e.g. unrelated settings…)"*; guideline 7 [hard] — *"Use templates for their intended purpose."*
Per §7.5 selecting a plug does not navigate, and per §10.11 the lens "relabels but does not filter or reorder." So one of ≤5 scarce tabs exists solely to set a preference, and tapping it changes nothing the driver can see on the screen they are looking at. A reviewer reads that as a settings tab, which is the one thing guideline 4 names by example. A control with no visible response also reads as broken while driving.
Fix: delete the tab. Put the lens on the Nearby/List screens where its effect is visible, or make selecting a plug *do* something (push the lens-applied list) so the grid is a menu, which is what a grid is for. §9.4's claim of "no settings" is not currently true.

**D13 — `Notify me when a bay frees up` will truncate, and deferring to hardware is not a plan.**
Rule broken: A11 [hard] — `CPTextButton` takes a plain `String`, no variants, no truncation control; A5 [hard] — up to three actions **share one row**.
§10.7 treats this as a risk for ticket 27 to measure. With three actions present, each gets roughly a third of the width; a 29-character title in a third of a small head unit is not a risk, it is an outcome.
Fix: author the short form (`Notify when free`) as the shipped label now and let ticket 27 *upgrade* it if hardware allows, not the reverse. Ticket 30's label is a phone label; note the divergence back to 30.

**D14 — Rate is a mandatory disclosure competing for an undocumented, unqueryable item cap.**
Rule broken: A5 [UNKNOWN] — `CPInformationTemplate` has no documented or queryable item cap; `domain-model.md` — *"RURA Art. 27(2) makes tariffs a regulated public disclosure — rate is first-class and always present."*
Rate is per-**Connector**. A three-connector-type station wants three rate pairs plus availability, connectors, bay count and distance — past the ≤6 the design self-imposes, and §11.4's "the tail is expendable" makes rate the expendable thing.
Fix: collapse rate to **one** item — `Rate · 250–400 RWF/kWh · 3 wks ago`, with an explicit Unknown marker when any connector's rate is unknown — and pin it at position 2 or 3 so it can never be the tail. Route the collapsed rate projection to ticket 19 alongside the other eight items in §12.

**D15 — The car-visible account facet contradicts the settled cache rule, and the design proceeds as if the routing resolved it.**
Rule broken: the settled decision as written — *"The car surface reads only non-sensitive directory+availability data from an on-device cache readable while the phone is locked"* (ticket 18's routed constraint from 19; `domain-model.md` car constraint 9).
§8.3/§11.7 put `armedWatches{stationId, connectorTypes[], expiresAt}` and mirrored `vehiclePlugs[]` into a locked-readable store. Which stations a person is watching, and what car they drive, are user-scoped facts; a locked phone in a parked car now discloses them. §12.6 correctly routes this to 19 — but §9 audits the whole design as compliant, and §10.5 then refuses a Saved tab *citing the very rule §8.3 breaks*. That inconsistency will not survive contact with 19.
Fix: the design cannot both take the carve-out and use it to deny Saved. Either 19 admits the facet with an explicit exclusion list (push token, email, name, avatar, report history, credentials) — in which case saved-station IDs are admissible on the same terms and §10.5 collapses — or the watch's car face reduces to disarm-from-notification and the armed row goes.

**D16 — `Other free bays` puts a cycle in the template stack, guarded only by an invariant whose enforcement API is unverified.**
Rule broken: A2 [hard] — 5 templates including root.
Path: TabBar(1) → POI or List(2) → Information detail(3) → Other free bays list(4) → Information detail(5) → and that detail offers `Other free bays` again(6). §9.1's "depth ≤ 3 invariant plus a push wrapper" is the only thing standing between the design and a refused push, and §11 admits *"the exact `CPInterfaceController` property exposing the live template stack, for the push wrapper's assertion"* is **not yet known**. A refused push is a button that does nothing while driving — the same failure mode as D12, on a deeper screen.
Fix: prove the depth with an explicit per-tab table in §3 (including the Grid tab's path, which I could not see), and make the invariant structural rather than assertive — the second-level detail is a *different composition* that never carries the action. Given D11, cutting `Other free bays` removes this defect entirely.

---

## MINOR

**D17 — Wrong hard number.** §9.3 states "Tab icon 24×24 pt / 48 / 96". Constraint sheet A12 [hard]: 24×24 pt = **48×48 @2×, 72×72 @3×**. The grid line (40/80/120) is correct; the tab line is not. Fix: 24 / 48 / 72.

**D18 — Projection wording will be implemented literally.** §9.3: "`text` = `nameShort`; `detailText` = **the whole two-line projection**." The two-line projection *is* `nameShort / distance · availability` — so `nameShort` renders twice. Fix: say "the projection's second line", and define that line as a named projection in `packages/domain` (§12 already asks for two new ones; make it three).

**D19 — §12.3's caveat to ticket 19 is wrong and will mislead the schema.** It says per-type denominators "may exceed the bay count." For `baysOffering(T)` a bay is counted once *per type*, so each individual per-type denominator is ≤ bay count; only the **sum across types** exceeds it. As written, 19 will build a guard against a condition that cannot occur and miss the one that can (`Σ baysOffering(T) > baysTotal` looking like an error to a reader).

**D20 — Alert A2 needs an ADR amendment, not a §11 footnote.** ADR-0004 says plainly: *"Not-installed falls back to the platform's universal-link handling; **no custom fallback UI**."* §11.16 flags the extension; it should be routed as an amendment the way ADR-0003 was amended by ticket 23. (D2 may moot A2 entirely.)

**D21 — Ticket 30 clause 3 is not shown to be honoured.** *"Arming is only offered when the watched set is not already Free."* Nothing in §8.4–§9.5 confirms the action is suppressed on a station currently showing free bays. Since that suppression changes the action **count** between renders, it also interacts with §11's open question about `CPInformationTemplate.actions` mutability. State it explicitly.

**D22 — §10.6's arithmetic is off.** It says dropping in-car reporting "removes one of the four candidate answers to guideline 1." Ticket 23 settled on **three** functions and reporting was not among them; nothing is removed. The loss described is real, the framing overstates it.

**D23 — Unstated: does `markerLabel` reach the CarPlay pin?** Ticket 18's routed constraint from 19 reads *"Marker = Owner icon + ≤3-char markerLabel."* §9.2 and §12.7 discuss only `Owner.icon` as a runtime-sized vector. If the label is not composited into `pinImage`, `Owner.markerLabel` exists for Android alone and half a routed constraint is silently dropped — and twelve pins from three Owners become mutually indistinguishable on the map. Say which it is.

**D24 — Optional recovery of a fourth bar-clearing function.** §10.6 cuts reporting because a car report would fabricate a connector-level claim. True for multi-connector sites; **not** true for a Station with exactly one Bay carrying exactly one Connector, where the claim is unambiguous. A report action offered only in that case costs no honesty and recovers a function against EV-1. Optional — it competes for the ≤3 action slots, which is another reason to cut `Other free bays` (D11).

---

## What is genuinely sound

Not everything here is broken, and these should not be relitigated:

- **Template selection is clean.** No forbidden template is referenced; `CPMapTemplate`/`CPContactTemplate`/`CPNowPlayingTemplate` are excluded at build time; `CPChargingStationConnection` is correctly never reached for; tab bar is root-only; modals are `presentTemplate`. The runtime-exception hazard in A0 is fully avoided.
- **Every documented numeric cap is respected**: ≤12 POIs, ≤8 grid buttons (5 used), ≤5 tabs (3 used), ≤3 Information actions, exactly 2 POI card buttons, runtime values queried rather than assumed.
- **No sign-in wall exists anywhere on the surface**, directions are anonymous, and account-gated affordances are silently omitted rather than explained. This is the correct reading of guideline 2 + 5.1.1(v) and it matches ADR-0003 as amended. §9.4's guideline-2 string audit is the right discipline (D2 aside, its guideline-3 claim is the one that fails).
- **The paint path carries zero network I/O**, no screen is designed around a spinner, delta sync is background-and-silent, and arm/disarm never blocks. The latency posture is right (its honesty posture, D1, is not).
- **Stripping `reporterId` and `capturedLocation` from the cached Report** (§11.8) is a correct derivation the constraint sheet does not demand, and it is the kind of thing that gets missed.
- **§12's routing to ticket 19 is the strongest part of the document.** `bayState(bay, now)` as a named domain function, the `detail-pairs` and `push-line` projections, and the vector-`Owner.icon` requirement are all real gaps caught before the schema locks. Items 2, 5 and 7 in particular would each have become a bug.
- **§11's inference ledger is honest** and — apart from the missing notification-authorization assumption behind D1 — reasonably complete.

---

**Verdict: does not ship as-is** — two fatal defects (an armed-watch row that promises what the system has not been shown able to deliver; a primary `Directions` action that can dead-end on the car screen while §9.4 claims guideline-3 compliance), plus fourteen major ones of which D7, D8 and D9 are free to fix and materially improve the row, and D15 must be resolved with ticket 19 before the schema locks rather than after.