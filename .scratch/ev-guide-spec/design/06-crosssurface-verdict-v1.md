# Cross-surface verdict — ticket 18, round 3 (final)

Reviewed: `01-carplay-design-v3.md` (1629 lines) and `02-androidauto-design-v3.md` (1238 lines) in full,
against `00-constraint-sheet.md`, `docs/domain-model.md`, `CONTEXT.md`, ADR-0002 / 0003 / 0004 / 0007 /
0008, and tickets 09, 10, 12, 19, 20, 23, 27, 30. Both v2 predecessors were read where a v3 cites them.

This is the cross-surface pass: the defects a single-platform reviewer cannot see. Scope is (1) whether the
two documents specify the **same** pure function for ticket 19, (2) whether the round-2 fatals actually
died, (3) new fatals introduced by the fixes, (4) the consolidated routing list.

**Verdict.** 2 FATAL · 12 MAJOR · 9 MINOR. Both round-2 fatal pairs are genuinely dead. Neither document
can close as written, but every fatal is a bounded edit — one precedence swap on CarPlay, one one-shot timer
on Android — and the real deliverable owed to ticket 19 (one written-down shared function) does not exist in
either document today.

---

## 0. What is sound, stated first

These are not concessions; they are the parts a round-4 reviewer should not reopen.

- **F1 is dead by construction, not by rule.** CarPlay §6.4 deletes v2's third lens row and delegates to
  Grammar G over the lensed subset. A denominator can only appear in Regime 2, where `u_T = 0` and the
  denominator therefore *is* the known set; Regime 3 emits none. `0 of N free` is unreachable for every
  input on both surfaces. Verified against all eight rows of CarPlay §6.4's worked table and Android §3.6's
  ten-row table — no input produces it.
- **F2 is dead.** The Google Maps rung ships behind `googleMapsCarDisplayHandoff`, default OFF, flipped only
  by ticket 27 evidence; §11.4's guideline-3 row claims only that no flow *requires* the iPhone; the two
  undetectable-failure gates (`canOpenURL`, the completion handler `Bool`) are named as unable to see the
  failure that matters. ADR-0004's sentence is honoured rather than quoted around. Android §8.1 goes
  further and is exactly right: *"It guarantees the hand-off… it does not claim that the receiving app
  appears on the car display, and it does not claim that the receiver is Google Maps."*
- **F-A is dead.** Android §3.1's two-stage derivation is the correct shape and the justification is written
  down so it cannot be re-collapsed: occupancy crosses the type boundary because a parked car is physical;
  brokenness must not, because a working gun says nothing about its neighbour. Fixture F-A/1 asserts the
  case under **both lenses and none**, which is what makes it a regression test rather than an example.
- **F-B is dead, and cheaply.** Making action 2's title the constant `Bay alert` moves arm/disarm entirely
  inside the documented `PaneTemplate` refresh clause (*title unchanged and row count and row titles
  unchanged*), so the toggle is free for an **unbounded** number of taps at any ledger value. Proof 2 walks
  an arm-then-disarm at 5/5. R1, the two-unit headroom, compromise 10 and inference 1 all retire — a fix
  that deletes machinery rather than adding it. Ledger arithmetic re-checked step by step: 6 is unreachable
  on every path, and every 5th template emitted is a `PaneTemplate` or a `MessageTemplate`.
- **Regime 3 is byte-identical across the two documents** — no total, no fraction, never *all*, non-zero
  counts in the fixed order `free · busy · out of service · unknown`, zeroes omitted. So is the
  non-additive partition rule (`n_T + (n − n_T) = n`, a dual-gun bay counted once on the driver's side).
  These are the two hardest parts of the grammar and they already agree.
- **The distance ordering agrees** where it matters: CarPlay's `~2.4 km · SP Remera` and Android's
  `2.4 km · SP Remera` both lead with the number, for different reasons (CarPlay to make a mid-digit
  truncation unreachable, Android because the span must sit in the title). One row anatomy, two derivations.
- **Both cache raw per-Connector reports and refuse the materialised aggregate.** This is the single
  load-bearing schema decision on the car surface and both documents reach it independently, with the same
  argument, and both route it to 19.
- **Neither surface presents a sign-in wall anywhere**, and both silently omit account-gated affordances
  rather than explaining them. CarPlay's string-by-string guideline-2 audit is the right instrument.

---

## 1. FATAL

### FATAL-1 — CarPlay `bayState_T` folds `OutOfService` into `Occupied` under a lens

`01-carplay-design-v3.md` §6.2, step 1:

```
bayState_T(bay, now), T = the driver's connector types
  1. if bayState(bay, now) = Occupied  → Occupied   ← a vehicle holds the position; no gun on
                                                      it is usable, whatever its type
```

Step 1 fires **before `s_T` is computed**. Take a dual-gun pedestal: the GB/T gun is `Occupied` (operator,
14 min) and the Type 2 gun is `OutOfService` (operator, 3 days). `bayState(bay)` = Occupied, so a Type 2
driver's lensed state is **Occupied** and the row reads `1 Type 2 bay busy`.

The rule broken is ADR-0002's founding rationale, verbatim: *"occupied means wait, broken means go
elsewhere. Collapsing it into `Occupied` sends drivers to wait at a charger that will never free."* It is
also disproved by a table in the same document — §5.3 property 3: *"`OutOfService` never folds into
occupancy at any count."* §5.3 says the fold is unrepresentable; §6.2 performs it.

This is **new in v3** — `bayState_T` is the F-A/F1 fix — and it is the exact mirror of the fatal it was
written to kill: F-A sent a driver to a broken gun by inheriting a state; this sends a driver to *wait* at a
broken gun by overriding one. The corpus cannot catch it: S4/B3 is `OutOfService + Free` with no occupancy,
so no fixture in either document has `Occupied` and `OutOfService` on one bay.

Android is correct here (stage 1 degrades only `Free`, so `S = {OutOfService}` → `OutOfService`), which is
why this is a cross-surface finding rather than a CarPlay one: the same input yields `busy` on one surface
and `out of service` on the other.

**Fix — one precedence swap, and it unifies the two documents' functions (see MAJOR-1):**

```
bayStateUnder(bay, T?, now):
  s_T ← { effective(c, now) : c ∈ bay.connectors, T = ∅ or type(c) ∈ T }   -- ∅ ⇒ bay not in the offers-T set
  1. if s_T ⊆ {OutOfService}                       → OutOfService   -- brokenness wins; go elsewhere
  2. if any c ∈ bay.connectors is Occupied         → Occupied       -- physical, crosses the type boundary
  3. if Free ∈ s_T                                 → Free
  4. otherwise                                     → Unknown
```

Checked against every case in both corpora: it reproduces CarPlay §5.2 unlensed (where `{Occupied,
OutOfService}` → Occupied is correct — a driver of any plug can wait for the occupied gun), reproduces
S4/B1–B3 and F-A/1 under both lenses, and closes MAJOR-1's divergence in the same stroke.

### FATAL-2 — Android renders decayed availability indefinitely: there is no decay clock

`02-androidauto-design-v3.md` §11: *"Throttling, no published interval | **no periodic invalidation at
all** — repaints are event-driven off cache changes."* §5.5 says the same: repaints happen when a report
arrives, when a sync lands, when the driver taps ⟳.

Decay runs at render (ADR-0008) — but only if a render happens. A driver opens a station pane on a
**driver-sourced `Free` captured 1 h 58 m ago**. The 2-hour window closes two minutes later. Nothing
invalidates, because nothing changed in the cache. The pane keeps rendering `1 bay free · driver, 1 h ago`
for as long as it is on screen — and in the offline case ADR-0007 exists for, no snapshot swap will ever
arrive to correct it. The age word is stale on the same path: `operator, 14 min ago` sits unchanged for
hours.

The rule broken is the document's own §3.7: *"No decayed value is ever rendered, in any form… the
derivation runs at render time on the device over raw reports, so a stale green is **unrepresentable**, not
merely discouraged."* On the shipping refresh model that sentence is false. It is also the product's
central safety claim (ADR-0008's *"deriving on read makes a stale green unrepresentable"*), and the car
screen is where it is most load-bearing.

CarPlay raised and fixed exactly this in round 2 (M1 → §7.2 `nextDecayDeadline`, a one-shot timer over
availability **and** the age-word boundary, bucketed 60 s / 10 s, plus *scene became active* as a recompose
trigger). Android was never asked and has no equivalent — a defect visible only from the cross-surface
seat, since each single-platform reviewer saw only their own document.

**Fix.** Port `nextDecayDeadline` verbatim. It is free under the quota: a recomposition whose title, row
count and row titles are unchanged is a documented refresh, which is precisely what a decay repaint is
(only row texts change). Add the `onResume`/reconnect case — a deadline missed while the screen was
backgrounded must fire immediately, which CarPlay's minor 4 already establishes. The one Android-specific
constraint is `Screen.onGetTemplate()` throttling, which cannot make the repaint *earlier* but never
suppresses it.

---

## 2. MAJOR

### MAJOR-1 — The two documents specify different lensed roll-ups, on a fixture both route to 19

The reviewer's first question, answered concretely. Take **CarPlay's own S4/B1**: GB/T `Occupied`
(operator, −20 min), Type 2 **never reported**. Lens = Type 2.

| Document | Derivation | Result |
|---|---|---|
| CarPlay §6.2 | step 1: `bayState(B1)` = Occupied → return Occupied | **Occupied** |
| Android §3.1 | stage 1 degrades only a **Free** sibling; the Type 2 gun is `Unknown`, so it stays `Unknown`. `S = {Unknown}` → | **Unknown** |

Propagated to the clause, CarPlay §6.4 emits `1 Type 2 bay free · 1 busy · 1 unknown` for S4 and Android
emits `1 Type 2 bay free · 2 unknown`. Two strings, one input, one "shared pure function". CarPlay routes
S4 to 19 as a required fixture (§15.1 item 8); Android routes F-A/1 (§9.1). Neither corpus contains the
other's discriminating case, so both suites pass and the divergence survives to code.

Android is also self-contradicting here: §3.1's justification says *"a parked car blocks every gun on the
position, so occupancy must cross the type boundary"*, but its stage-1 mechanics only degrade `Free`, so
occupancy does **not** cross to an `Unknown` gun.

**Recommendation:** FATAL-1's four-line precedence. It is CarPlay's physical rule with Android's brokenness
carve-out, and it is the only formulation that satisfies both documents' stated justifications.

### MAJOR-2 — The freshness function is two different functions, and Android's is not total

| | CarPlay §5.4 | Android §3.3 |
|---|---|---|
| Contributors | reports behind the bays in **the leading clause's state**, ∩ lens | reports behind **`Free` and `Occupied`** bays, `OutOfService` always excluded |
| Source word | weakest always; `mixed` **refused** | single source if they agree, else **`mixed`**; weakest only when a variant collapses |
| Age | oldest contributor | oldest contributor |

Worked on CarPlay's S3 `(4,1,1,1,1)` — B1 Free (operator, 25 min), B3 Occupied (driver, 40 min), B4 OOS
(operator, 6 days): CarPlay emits **`Operator, 25 min ago`**; Android emits **`driver, 40 min ago`** (or
`mixed`). Same station, same reports, different provenance and different age — and provenance is what both
documents call the entire confidence axis.

Worse, **Android's rule is not total**, which breaks its own Invariant B. For `(n=3, f=0, o=0, x=1, u=2)`
or Regime 2 row 6 (`All 4 bays out of service`), the contributor set is empty and §3.3 — which says the
freshness clause *"is appended to a Regime 2 or 3 availability clause"* — defines no behaviour. CarPlay's
rule is total: when `f = o = 0` the leading state is `out of service` and its own reports set the head.

Android §3.9 item 12 asserts *"CarPlay already excludes `OutOfService` from the age; with that rule its row
ages are bounded the same way."* **False of CarPlay v3** — its §2.4 protected head is sized for
`EV Guide, 30 days ago` (21 chars), reachable precisely when the leading clause is `out of service`. So
Android's bound (*"a contributing report is never more than 6 hours old"*, §3.3) does not hold across the
pair, and its `days`-only-on-the-pane vocabulary rule (§3.8) is violated by its twin's rows.

**Recommendation:** adopt CarPlay's leading-clause scope (it is total and it subsumes the `OutOfService`
exclusion); return `(contributingSources: Set, oldestContributingCapturedAt)` and **no word**, per Android
§3.9 item 5, letting each surface render `mixed` or collapse to weakest. CarPlay §15.9 asks for exactly
this; Android has not moved yet. Ticket 19 arbitrates, once.

### MAJOR-3 — Both final documents cite the other's superseded v2 as the normative specification

CarPlay v3 cites `02-androidauto-design-v2.md` nine times, including *"§3.2 **is the specification**"*,
*"§3.5 is the specification"*, *"§3.6 is the specification"*, and routes ticket 19 to
*"`02-androidauto-design-v2.md` §3.2 / §3.6"* (§15.1 item 4). Android v3's §3.9 — the instrument that
exists to stop 19 receiving two specs — is written against *"the twin document
(`01-carplay-design-v2.md`)"*. **Neither final document cites the other final document.**

This is not bookkeeping. Two consequences bite:

1. **CarPlay's Grammar G is Android v2's, which is missing two rows.** Android v3 §3.2 added `f = n` →
   `All 4 bays free` and the entire **`n = 1` singular rule** (`The bay is free`; no `All`; no `1 of 1`),
   calling one-bay sites *"a common case, not an edge"* in Rwanda. CarPlay v3 §5.3's Regime 2 table is v2's
   five rows verbatim, with neither. So on the same input CarPlay emits **`1 of 1 bays free`** and
   **`All 1 bays busy`** where Android emits `The bay is free` / `The bay is busy`. No CarPlay fixture has a
   one-bay station (S1–S5 have 4, 3, 4, 3, 2), so its corpus cannot expose it.
2. **Android's §3.9 divergence table is stale in 5 of 12 rows.** Items 3 (`unreported`), 4 (`in use`), 6
   (rate denominated in bays), 8 (`unpriced`) and 11 were all resolved by CarPlay v3 — which adopted
   Android's vocabulary and the plug denominator wholesale. A ticket-19 reader working from §3.9 will
   "reconcile" changes that already landed and miss the ones that did not (items 2, 5, 9, 10, 12).

### MAJOR-4 — CarPlay's notification hardcodes `operator report` (the m-K defect, unfixed)

CarPlay §3.5: Body = **`A bay just freed up · operator report`**. A watch fires on a report-driven
transition into `Free` from **any** source, and ticket 30's own framing plus the market reality (no operator
app adoption yet) makes a **driver** report the common case. Android fixed exactly this as m-K and now
renders `{nameShort} · {source} report` from the closed source set. CarPlay states a provenance it does not
know, on the one string that arrives while the driver is moving.

### MAJOR-5 — CarPlay's `Not reported recently` is the M-D defect, unfixed and self-falsifying

CarPlay §3.3 (S2) and §7.1 render `Last report → **Not reported recently**`. Android killed this string in
round 2 (M-D) and generalised it into vocabulary rule V1: *a word may state EV Guide's knowledge; no word
may state report history* — because ADR-0002's **offline-source override** yields `Unknown` the instant a
source declares itself offline, *however fresh its report is*. CarPlay carries that override itself (§5.1:
*"any source declaring itself offline → Unknown immediately"*), so the string is disproved by another
section of its own document: a pedestal that reported thirty seconds ago is described as not having
reported recently.

It is also the third breach of CarPlay §2.1's claim that the surface *"owns no words of its own"* — the
string appears nowhere in the vocabulary table it says it adopted unchanged. Android's replacement,
**`No confirmed bay status`**, is correct, is already routed as §3.9 item 3, and fits CarPlay's slot.

Direction of harm is toward *less* confidence, not more, which is why this is MAJOR and not FATAL. But it
is the last live instance of a defect the twin killed, and closing 18 with it in place hands 19 two
vocabularies after both documents declared the vocabulary settled.

### MAJOR-6 — The session fee has no home in either grammar's routed signature

`docs/domain-model.md` and ticket 10 make Rate = `ratePerKwhRwf` **plus an optional `sessionFeeRwf`**.
Android §3.5 renders it (`600 RWF/kWh + 500 RWF session`). **CarPlay's Grammar R has no session-fee case
at all** in any of its five rows or its assembly ladder, though `sessionFeeRwf` sits in its own cache schema
(§10.2). A station with a connection fee therefore renders a price on CarPlay that is not the price.

And the routed signature cannot express it either: Android §13 routes
`rateCoverage(station) = (confirmedPlugs, totalPlugs, distinctRates[], oldestConfirmedAt)` — no session-fee
term, so Android's own string is not producible from the function it is routing. Under RURA Art. 27(2)
framing (a tariff is a regulated public disclosure), the omission is not cosmetic.

### MAJOR-7 — The two ladders disagree on whether the broken count may be dropped, and on the return type

Android §3.4: *"**`free`, `out of service` and `unknown` counts are never dropped.** A `busy` bay is neither
actionable-positive nor a hazard; **a broken bay is a hazard**."* CarPlay §5.4 step 3 **drops the `broken`
count** whenever `f > 0`, and its own worked row does it: S4 GB/T lens `(3,1,1,1,0)` →
`Operator, 20 min ago · 1 of 3 GB/T DC bays free`, with the out-of-service bay silently inside the
denominator.

Underneath sits a signature divergence: Android §3.2 says *"`G(n, f, o, x, u)` returns an ordered list of
variants, longest first"* and routes that to 19; CarPlay §5.1 says the shared function returns **clauses**
and *"each surface orders and ladders them"*, resolving against a 52-character budget. Ticket 19 cannot
implement both return types.

**Recommendation:** the function returns clauses **plus a fixed drop order** (one ordered list, both
surfaces); Android renders it as `CarText` variants, CarPlay resolves it against a budget. Then settle the
one substantive question — may `out of service` be dropped when `f > 0`? — in one place.

### MAJOR-8 — Grammar Q is undefined for a driver with more than one connector type

`T` is a **set** everywhere in the model: `vehicleConnectorTypes[]`, `EnergyProfile.getEvConnectorTypes()`
(plural), `watch(stationId, connectorTypes[])`. Every worked string in both documents names exactly one
type (`1 of 3 GB/T DC bays free`, `No GB/T bay here`, `2 Type 2 bays · up to 22 kW`). Neither document says
what is printed when `|T| ≥ 2` — a Type 2 + CCS2 car is ordinary — nor how `<k> other bays` is worded when
the driver's side is multi-typed. Android's Invariant B claims the grammar is **total**; it is not. No
fixture in either corpus has `|T| ≥ 2`.

### MAJOR-9 — Android's car snapshot has no field for the profile its lens requires (m-F, again)

§9.1: *"**Three** non-directory fields ride alongside — the count is three, not two as v2's prose said
(m-F): `isSignedIn`, `notificationsPermitted`, `armedWatches`."* But Grammar Q needs the device-local
vehicle profile (§7.1 source 2) inside the `:car` process, and the snapshot is the only channel across the
process boundary. It is a **fourth** field. The correction that fixed a miscount reintroduced one.

CarPlay names it explicitly (`vehicleConnectorTypes[]` in Store B, §10.3), which is how the omission
becomes visible from here and not from inside the Android document.

### MAJOR-10 — Ticket 19 receives two incompatible car-cache contracts, and two security decisions

| | CarPlay §10.3 / §15.1 item 9 | Android §9.1 / §13 |
|---|---|---|
| Fields | `canWatch`, `armedWatches[{stationId, connectorTypes[], armedAt, expiresAt, confirmed}]`, `pendingIntents[]`, **`savedStationIds[]`**, `vehicleConnectorTypes[]`, `googleMapsCarDisplayHandoff` | `isSignedIn`, `notificationsPermitted`, `armedWatches[{stationId, expiresAt}]` |
| Saved stations on the car | **a whole `Saved` tab** (§8.4) | **refused** — compromise 3, *"no saving, no favourites… all user-scoped, all outside car constraint 9"* |
| Watch record | gains `armedAt` + `confirmed` (§15.1 item 11) | `(stationId, expiresAt)` |

Car constraint 9 (*the car surface reads only non-sensitive directory + availability data*) is a **security
decision** that both documents ask 19 to ratify — and they ask it about different data. CarPlay's own §14
inference 8 says so: *"This is a security decision, not a derivation, and ticket 19 must ratify or reject
it."* It cannot ratify two lists. Note also that a `Saved` tab makes the car surface reflect a user's
bookmark set from a file that deliberately holds no user identifier — worth 19 deciding explicitly rather
than inheriting from whichever document it reads second.

### MAJOR-11 — CarPlay's shipped directions rung rests on "Apple Maps is always installed", which is false

§8.1 / §11.4 / §12.5 turn on: *"Apple Maps is always installed and **is** a CarPlay app, so the launch never
requires the iPhone."* Apple Maps has been user-deletable since iOS 12. With it deleted,
`http://maps.apple.com/?daddr=…` resolves to **Safari**, which has no car screen — the scene `open`
completion handler returns `true`, rung 3 (alert A2) never fires, and the app has silently pushed content
onto the phone the driver must not touch, undetectably.

That is F2's exact failure mode on the *shipped* rung, and the document already knows the mechanism: §15.2
routes to ADR-0004 precisely because *"on CarPlay a universal link lands in Safari, which has no car
screen."* The reasoning was applied to rung 1 and not to rung 2.

**Fix:** the shipped rung must be `MKMapItem.openInMaps` (which targets Maps by identity, at the cost of
Apple's documented blocking-call warning) or an explicit installed-check ahead of the `http` URL, with A2 as
the miss. Either way the claim needs restating: *always installed* → *installed unless the driver removed
it, in which case A2 fires.*

### MAJOR-12 — The unlensed aggregate hides a known-broken gun, for the driver both documents call normal

F-A was fixed **under the lens**. Both documents also say the lens is usually absent: CarPlay has no
`EnergyProfile` equivalent at all and no permitted screen on which to ask (§6.1); Android expects
`STATUS_UNIMPLEMENTED` *"most of the time"* (§7.1); ticket 12's ruling may gate the profile behind an
account entirely.

For that driver, Android's own fixture F-A/1 asserts `G(unlensed) → "All 2 bays free"` at a site where a
Type 2 gun is **known `OutOfService`**, and CarPlay's S4 renders `2 of 3 bays free` with B3's GB/T gun dead.
The `Connectors` item/row lists `GB/T DC 60 kW · Type 2 22 kW` and says nothing about the broken one. A
driver with no profile reads *all free*, sees their plug listed, drives there, and finds it broken — the
F-A failure, delivered on the majority path.

This is inherent to bay-denominated availability and is *not untrue* at bay granularity, which is why it is
MAJOR and not FATAL. But neither document lists it as a compromise, and the fix is cheap and belongs to 19:
carry per-Connector state into the **detail** projection (`detail-pairs` / pane row 2) so `Connectors` can
mark a gun `out of service`. The detail screen is where the driver commits; it has the room; and both
documents already argue that the structural answer to "free for me" is *"the driver does the matching by
reading"* — which only works if what they read includes the broken gun.

---

## 3. MINOR

1. **The watch vocabulary diverges after CarPlay declared it adopted unchanged.** `one alert, next 2 h`
   (CarPlay §2.1) vs `One alert, next 2 hours` (Android §3.8); `not confirmed yet` vs
   `Waiting for confirmation`; `Watching until 15:12` vs `Watching · until 14:05`. Android §3.8 declares its
   set **closed** (*"a string not derivable from this table is a defect"*), so these are defects by the rule
   CarPlay says it adopted.
2. **Other CarPlay-only words and marks**: `and` as a joiner (`CCS2 and Type 2`), `×` (`2 × GB/T DC 60 kW`),
   commas outside the freshness clause (`4 bays, Type 2 and CCS2`) — all outside Android's V5 and its
   connective list. Android §3.9 item 11 pre-authorises the joiner; the rest are unaccounted for.
3. **Android prints `GB/T` bare** (`No GB/T bay here`, `1 of 2 GB/T bays free`) while its own §3.8 type-word
   set is `GB/T AC` / `GB/T DC`. Its §4.0 derivations use `GB/T DC`. The routed type-word projection must
   say which is legal.
4. **Availability on the map pin is an undeclared divergence.** CarPlay composites a free-bay numeral badge
   onto the pin (§3.1); Android §3.7 forbids it categorically — *"No colour, icon, marker change or motion
   encodes availability anywhere."* Both are defensible (ADR-0002 sanctions an additive badge; Android's
   `PlaceMarker` is label-only and `setColor` is illegal with `TYPE_IMAGE`), but it appears in neither
   divergence table, and ticket 20's screenshots will show it.
5. **CarPlay §15.7's first bullet is already done.** `CONTEXT.md` line 45 now reads *"Reads the whole
   product anonymously, **and gets directions anonymously**"*. Drop it from the routing list.
6. **Three names for two per-type projections**: `baysOffering(T)` (both), `knownBaysOffering(T)` (CarPlay
   §6.2, defined and then never used — Grammar G consumes the tuple), `freeBaysOffering(T)` (Android §13).
7. **The ≥10-bay station has no defined render.** CarPlay §2.2 asserts every count is ≤ 9 and *"the
   assertion fires rather than rendering"*; §15.1 item 15 leaves the render to 19. Until 19 rules, the
   specified behaviour on a car screen is a crash in debug and a possibly-truncated two-digit numeral in
   release — the M4 failure the assertion exists to prevent. A fleet depot creates this data any day.
8. **`Owner.shortName` has no routed length bound**, though CarPlay's POI `subtitle` budget (28 = 8 + 3 +
   17) assumes one. `nameShort ≤ 18`, `name ≤ 28`, `markerLabel` 1–3 are routed; this one is not.
9. **Contradictory sibling reports have no arbitration at the bay level.** Ticket 11's most-recent-wins is
   per-Connector; ADR-0008's propagation is unconditional, so a `Free` captured at 14:10 is suppressed by an
   `Occupied` captured at 14:00 that is still in window. Conservative, and probably right — but it is
   undocumented in both designs and a fixture will eventually assert it either way.

---

## 4. Consolidated routing, de-duplicated across both platforms

### 4.1 To ticket 19 / `docs/domain-model.md` — blocking, before the schema locks

**A. One derivation.**

1. **`bayStateUnder(bay, T?, now)`**, single function, unlensed = `T = ∅`, with FATAL-1's precedence
   (`all-T-guns-broken` → `OutOfService` **before** occupancy → `Occupied` **before** `Free` → else
   `Unknown`). Replaces CarPlay's `bayState` + `bayState_T` pair and Android's stage-1/stage-2 split as two
   entry points. The rule *occupancy crosses the type boundary, brokenness does not, and a free sibling
   never vouches for an unreported gun* must be a **test**, not a comment.
2. **Per-type projections defined from it**: `baysOffering(T)` = bays carrying ≥1 Connector of a type in
   `T`; `freeBaysOffering(T) = #{b : bayStateUnder(b, T) = Free}`. Retire `knownBaysOffering(T)`. The
   correct caveat: each individual per-type denominator is **≤ n**; only the **sum across types** may
   exceed it.
3. **`nextDecayDeadline(displayed, now)`** — availability window, **age-word boundary**, rate 90 d, watch
   2 h — as a domain function, so the phone, the Swift car layer and the Kotlin car layer schedule
   identically (FATAL-2).

**B. One grammar, one signature.**

4. **`G(n, f, o, x, u, verbosity, lens)`** returning clauses **plus one fixed drop order** (MAJOR-7), with
   Android v3 §3.2's `f = n` row and the **`n = 1` singular rule** (MAJOR-3), and these as tests: `0 of N`
   never emitted for any input; a denominator only when `u = 0`; `busy` quantifies `o` only; `OutOfService`
   never folds into occupancy; *all* never beside *busy* when `x > 0`; no `1 of 1` and no `All 1`.
5. **Grammar Q**, the one-named-side partition, **defined for `|T| ≥ 2`** (MAJOR-8).
6. **Freshness returns structure, not a word**: `(contributingSources: Set, oldestContributingCapturedAt)`,
   contributors scoped to **the leading clause's state ∩ the lens** (total; supersedes both current rules —
   MAJOR-2). `mixed` vs weakest-collapse is per-surface rendering.
7. **`rateCoverage(station)` denominated in plugs and carrying the session fee**:
   `(confirmedPlugs, totalPlugs, distinctRates[], oldestConfirmedAt, sessionFeeRwf?)` (MAJOR-6).
8. **The connector type-word mapping** as one projection (`IEC_62196_T2` → `Type 2`, `IEC_62196_T2_COMBO` →
   `CCS2`, `GBT_AC`/`GBT_DC` → `GB/T AC`/`GB/T DC`, `OTHER`/`UNKNOWN` → `Other plug`), settling whether bare
   `GB/T` is legal (MINOR-3).
9. **The closed vocabulary as data** (Android §3.8 + its five generating rules), in `packages/domain`, so
   neither the Kotlin nor the Swift transcription invents a word — including the watch strings, the
   notification strings and `No confirmed bay status` (MAJOR-5, MINOR-1/2).

**C. Projections.**

10. **`place-line` / `rowTitle` must return structure**, not a formatted string: CarPlay authors
    `~2.4 km · <nameShort>`, Android must hand the host a `DistanceSpan` and can author no distance literal.
    One projection returning `(distanceMeters, nameShort)` + per-surface formatting.
11. **`availability-line`** (head-first on CarPlay, ladder-resolved), **`detail-pairs`** (CarPlay ≤6 items,
    ordered `Availability · Last report · Rate · Distance · Connectors · Bay alert`), **`pane-rows`**
    (Android 4 rows, `Availability · Connectors · Rate · Bay alert`), **`push-line`**.
12. **Per-Connector state in the detail projection** so a known-broken gun is visible to a profile-less
    driver (MAJOR-12).
13. **Authored length bounds enforced in the admin**: `nameShort ≤ 18`, `name ≤ 28`, `markerLabel` 1–3
    `NOT NULL` with a `CHECK`, **`shortName ≤ 17`** (MINOR-8). Plus what a ≥10-bay station renders
    (MINOR-7). `Owner.icon` must be a **vector** (CarPlay pin sizes are runtime values).

**D. The car cache — one contract.**

14. **Per-Connector raw latest reports, never a materialised aggregate**, including **`sourceOnline`**
    (the field that makes the offline override renderable — and makes `Not reported recently` false). Named
    `CachedReport` projection excluding `reporterId` and `capturedLocation`. The car **sync payload** must
    carry them too.
15. **One non-directory field list**, resolving MAJOR-9 and MAJOR-10: `isSignedIn`/`canWatch`,
    `notificationsPermitted`, `armedWatches[{stationId, connectorTypes[], armedAt, expiresAt, confirmed}]`,
    `pendingIntents[]`, **`vehicleConnectorTypes[]`**, and a ruling on `savedStationIds[]` (CarPlay ships a
    Saved tab; Android refuses saving). Explicitly **not** a credential, a user id, or a push token. This is
    an amendment to car constraint 9 and a security decision, not a derivation.
16. **The credential's single home**: Keychain `kSecAttrAccessibleAfterFirstUnlock` / Android Keystore, read
    only by the drain (`WatchSyncQueue` / `OpDrainer`); the car layer never authenticates.
17. **Watch record** gains `armedAt` + `confirmed`; client-side drop of a queued arm past `armedAt + 2 h`;
    **max-3 evaluated on-device before the request**.
18. **No reserved compatibility slot** in `stationsNear`; ranking stays total, distance-first then
    availability. If compatible-first is ever wanted it becomes a named second key, and the "never its
    presence" sentence is deleted — not both.
19. **The negative of car constraint 13**: ETA, duration and any "minutes away" string are **forbidden** on
    a car surface, not merely unmodelled — on CarPlay it is a `carplay-maps` trigger.
20. **The 200 km reachability threshold** on origin rung 1 — a design call to confirm or set.

**E. Shared fixtures** (one corpus, executed by the TypeScript, Swift and Kotlin suites):

21. Dual-gun bay with **`Occupied` + `OutOfService`** on one bay, asserted under both lenses (FATAL-1 —
    exists in neither corpus).
22. Dual-gun bay with **`Occupied` + never-reported**, both lenses (MAJOR-1's S4/B1 divergence).
23. Dual-gun bay, one gun `OutOfService`, one `Free`, both lenses and none (Android F-A/1 — keep).
24. Dual-gun bay carrying **two distinct rates**, plus one with a **session fee** (MAJOR-6).
25. **One-bay and one-plug-per-type stations** (`n = 1`), all regimes (MAJOR-3).
26. A station where **`f = o = 0`** and `x > 0` — the empty-contributor freshness case (MAJOR-2).
27. **`|T| ≥ 2`** lens (MAJOR-8).
28. **Offline-source override with a 30-second-old report**, asserting `Unknown` *and* that no emitted
    string mentions report recency.
29. Each **decay boundary at ±1 minute**, and a **render across a decay boundary with no cache change**
    (FATAL-2).
30. A case whose **materialised aggregate and device-derived aggregate deliberately disagree**.

### 4.2 To ticket 27 — device test, in priority order (merged)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | **Are a POI app's notifications surfaced on the Android Auto screen at all?** (`CarAppExtender` + `CarNotificationManager`; `IMPORTANCE_HIGH` heads-up historically reserved to messaging/navigation) | Android | **BLOCKING** — decides whether ticket 23's three-function `PF-1` answer holds on Android |
| 2 | **What Apple Maps renders on the CarPlay screen for a Rwandan `daddr` it cannot route** — pin, error sheet, or nothing | CarPlay | **BLOCKING** — the shipped directions path is this |
| 3 | **Does `comgooglemaps://` via the scene `open` land on the car screen or the phone?** | CarPlay | **BLOCKING** — decides whether `googleMapsCarDisplayHandoff` is ever enabled or the rung is deleted |
| 4 | Does `ACTION_NAVIGATE` reach a nav app, is it Google Maps, and does it appear on the car display? | Android | critical path (ADR-0004 forbids assuming any of the three) |
| 5 | **Add: does the shipped CarPlay rung still work with Apple Maps deleted?** | CarPlay | new — MAJOR-11 |
| 6 | Confirm a `PaneTemplate` whose **row texts alone** change is a refresh — arm/disarm ×10 at a known ledger depth | Android | cheap; the most load-bearing check on the quota model |
| 7 | Is the refresh diff per-screen? Does the back-refund equal templates popped? Is `QuotaGuard` reachable? | Android | decides Proof 1's peak; confirms R2 is dead code |
| 8 | Real `@RequiresCarApi` of `setOnContentRefreshListener`; does the host draw ⟳? | Android | decides compromise 8's depth |
| 9 | Two text lines on `PlaceListMapTemplate` while driving, or one? | Android | decides whether text 2 is ever seen |
| 10 | Runtime values: `CONTENT_LIMIT_TYPE_PLACE_LIST` / `…PANE`; `maximumItemCount`, `maximumSectionCount`, `maximumTabCount`, `maximumActionCount`, `pinImageSize`, `selectedPinImageSize`, `maximumImageSize` | both | confirms the 6 / 4 / 12 floors and §4.3's `contentLimit(PANE) >= 4` term |
| 11 | `CPInformationTemplate.items`/`.actions` mutability; programmatic tab selection at the iOS floor; `UNNotificationSettings.carPlaySetting` at the deployment floor | CarPlay | decides whether decay repaints are in-place or pop-then-push |
| 12 | Does `startCarApp` accept `geo:0,0?q=<lat>,<lng>(<name>)`? | Android | adopt if yes; keep bare coordinates and record why if no |
| 13 | Is the ground black in **day** mode? Is row↔pin correspondence usable with six same-Owner `KAB` labels? Badge legibility at the smallest `pinImageSize`; rendered width of the watch button beside `Directions` | both | one-asset simplification; marker fallback to `null` |
| 14 | Does CarPlay / Android Auto activate at all on Rwandan-region devices | both | ticket 22's question; changes who sees these screens, not what they say |

Plus, not a DHU item: **grep the pinned `androidx.car.app:1.7.0-rc01` artifact for `@Deprecated` on
`PlaceListMapTemplate`** before this design is called final.

### 4.3 To ticket 30 — one amendment naming three surfaces

- **Label**: phone keeps `Notify me when a bay frees up`; Android Auto ships the constant **`Bay alert`**
  (quota-load-bearing, §8.2/§8.3); CarPlay currently ships `Notify when free` (16 chars) and Android
  proposes it adopt `Bay alert` too (9 chars, inside CarPlay's budget). **The two documents route different
  amendments — 30 must receive one.** Recommendation: `Bay alert` on both car surfaces, since it makes the
  row above the button the state display on both.
- **Clause 3 ("arming is only offered when the watched set is not already Free")** is honoured as a rule
  about the **outcome**, never the affordance's presence — presence must not vary with availability.
  CarPlay expresses the refusal as modal alert **A1**; Android as a row-4 text (`A bay is free now` /
  `No alert needed yet`). Both are correct for their platform; 30 should record both.
- **Max-3 is enforced on-device before the request** — CarPlay alert **A3**, Android row-4
  `3 alerts already running · Stop one to add another`.
- **The gate is `isSignedIn && notificationsPermitted` (`.authorized` only — `.provisional` does not
  qualify)**, plus Android's `contentLimit(PANE) >= 4`.
- **The armed state has three values, not two**: the middle one is *requested, not confirmed*. A queued arm
  expires client-side at `armedAt + 2 h`.
- **The POST carries `connectorTypes[]`** from the profile when one exists, `[]` otherwise, and the armed
  row says which. Changing the profile afterwards does not re-scope a live watch.
- **The notification renders `{source}` from the closed set** — never hardcoded (MAJOR-4).

### 4.4 To ticket 20 — submission dependencies

1. **Sign in on the phone before connecting** (demo account in Play Console → App access and in Apple's
   review notes). The car screen never shows a wall; the state is simply already true.
2. **Grant the notification permission on the phone before connecting** — `POST_NOTIFICATIONS` on
   Android 13+, `ev_guide_bay_alerts` channel enabled; on iOS `.authorized`, not `.provisional`. Its own
   numbered step: a reviewer who skips it sees **no bay-alert row and no button**, and the third `PF-1` /
   EV-1 function is invisible with nothing on screen to explain it.
3. **Seed the demo path with reports**, including one scheduled to flip a watched connector into `Free`
   while the reviewer is on the station detail — so the availability layer is populated rather than
   uniformly Regime 1 and the alert is *seen to fire*. Without it a reviewer sees six rows of name +
   distance + capacity and one `Directions` button: precisely *"a list of EV chargers"*.
4. **Do not claim a Google Maps hand-off onto the car display** in either submission. It ships off on
   CarPlay and is unassumed on Android.
5. The Kigali origin rung already removes the mock-GPS dependency on both platforms — say so in the notes
   rather than relying on the reviewer to configure one.
6. **If ticket 27 item 1 comes back negative**, Android's `PF-1` case reduces to two functions and ticket
   23's resolution must be revisited **before** filing, not at submission.

### 4.5 To ADR-0004, ADR-0007, ticket 12, ticket 15, `CONTEXT.md`

- **ADR-0004 (amendment, as ticket 23 amended ADR-0003):** the CarPlay ladder terminates in **Apple Maps**
  and then in alert **A2**, because a universal link lands in Safari, which has no car screen — so
  *"no custom fallback UI"* cannot be applied literally on a car surface. The Google Maps rung ships
  **behind a flag defaulting off**. Add MAJOR-11: Apple Maps is deletable, so the fallback is reachable and
  the launch must be identity-targeted or installation-checked.
- **ADR-0007 (amendment):** straight-line distance is labelled on CarPlay by the `~` prefix, by
  `straight line` at the head of the POI card's `detailSummary`, and by the `Distance` item; **the phone
  renders Valhalla driving distance without `~`**, which is what makes the prefix a convention. **Android
  cannot label it at all** (`Row.setTitle` takes only Distance/Duration spans; the pane's four rows are
  spent) — record the asymmetry rather than leaving it as a compromise in one document. **There is no
  offline indicator on either car surface.**
- **Ticket 12 — one-line ruling, blocking 19:** is *setting your own connector type* account-gated (the
  ticket's question) or a device-local preference (its answer gates only *syncing* the profile)? If gated,
  Grammar Q only ever appears for signed-in drivers and every reviewer sees the unlensed aggregate — which
  makes MAJOR-12 the normal case, not an edge.
- **Ticket 15 / ADR-0006:** `android:process=":car"` with the RN-initialisation branch; the op-file /
  snapshot-swap seam; `car-last.json`; and the fact that the ADR-0008 derivation now exists **three** times
  (server TS, device TS, car Kotlin) plus twice for the grammar — mitigated by the shared fixture corpus,
  not eliminated. ADR-0008 says *"run identically on server and device"*; that sentence needs widening.
- **`CONTEXT.md`:** add the shared display vocabulary as a glossary entry so neither car design declares its
  own closed set. (CarPlay §15.7's line-44 item is already done — drop it.)

---

## 5. Can ticket 18 close?

**CarPlay — not yet.** The template selection, the depth-3 structural proof, the count-invariance
discipline, the origin separation and the F1/F2 fixes are sound and should not be reopened. But FATAL-1 is a
live safety inversion in the function this round was written to fix, and MAJOR-4 and MAJOR-5 are two strings
the twin banned in round 2 and this document kept while claiming to have adopted the twin's vocabulary
unchanged. One precedence swap, two string replacements, one notification-body parameter, and a re-pointed
set of citations.

**Android — not yet.** F-A and F-B are properly, structurally dead, and the F-B fix is the best work in
either document: it deletes a rule, a budget, a compromise and an inference at once. But FATAL-2 means the
surface renders decayed availability indefinitely on the exact path the product's central claim covers, and
the grammar it routes to 19 is not the grammar CarPlay routes. One one-shot timer, one contributor-scope
change, one extra cache field.

**The ticket itself — not until the shared function is written down once.** Ticket 18's own closing
instruction is *"feed anything this forces back into 19 before the schema locks."* Today 19 would receive
two roll-ups, two freshness rules, two return types, two rate signatures and two cache contracts, mediated
by two divergence tables each written against the other document's superseded draft. The cheapest close is a
short third artifact — the shared grammar and derivation as one spec, owned by neither surface — with both
designs reduced to citing it. That artifact is what §4.1 above enumerates, and it is roughly two pages.
