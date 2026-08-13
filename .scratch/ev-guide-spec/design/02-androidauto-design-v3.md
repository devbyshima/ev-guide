# EV Guide on Android Auto — complete template design (v3)

Ticket 18, Android half. Supersedes `02-androidauto-design-v2.md` in full; this is a standalone document, not a diff. Written against the round-2 adversarial verdict (2 fatal — **F-A**, **F-B**; 3 major — **M-C**, **M-D**, **M-E**; 9 minor — **m-F**…**m-N**). Every defect is answered in **§14**; **§16** summarises what moved.

Binding inputs: `00-constraint-sheet.md` (which stands in for research 04 in full), `/Users/FullTimeStudio/Dev/lab/ev-guide/docs/domain-model.md`, `/Users/FullTimeStudio/Dev/lab/ev-guide/CONTEXT.md`, ADR-0002 / 0003 (as amended) / 0004 / 0006 / 0007 / 0008, and tickets 09, 12, 19, 20, 23, 27, 30.

Marking: **[hard]** = a documented platform rule. **[inferred]** = a derivation — never quote one to a Play reviewer. **[verify]** = goes to ticket 27's DHU session. **[blocking]** = ticket 27 must answer it before ticket 20 files anything.

**On ADR-0004, which v2 overreached.** The ADR's words are binding: *"Launching Google Maps onto the CarPlay/Android Auto display is undocumented and unverified; it is an enhancement pending ticket 27's device test, and ticket 18 designs without assuming it."* **The phone hand-off is the guarantee this design makes.** `startCarApp(ACTION_NAVIGATE)` is the documented mechanism **[hard]**; *which* app receives it, and whether that app appears on the car display rather than the phone, is undocumented **[UNKNOWN]** and is ticket 27's #2 item. Nothing in this design depends on the car-display outcome, and no sentence in it claims one.

**On the verdict text.** The round-2 verdict is not on disk in this workspace; it was transmitted as findings and reconstructed against v2's own sections. Each defect below is therefore stated as **the concrete thing in v2 that is wrong**, not as a label, so the mapping is unambiguous even where my letter differs from the reviewer's.

---

## 0. The shape of the decision, up front

Android hands a POI app two possible map surfaces. **EV Guide uses `PlaceListMapTemplate` (host-drawn map) and declines `MapWithContentTemplate` (app-drawn surface).** That single choice removes, at once:

- the whole tile pipeline from the car surface (no MapLibre on a `Surface`, no tile fetches, no basemap budget — the host draws Google's map for free),
- `MR-1` (it applies only to *apps drawing maps*),
- `AR-1` risk (system bars and cutouts are the host's problem when the host lays out),
- the largest part of the `DR-2`/`DR-3` latency risk (nothing to render, only strings to supply).

The cost: EV Guide's visual identity does not appear on Android Auto beyond one bundled Owner mark on the detail pane. That is accepted — it is the same bargain CarPlay forces unconditionally, and taking it on both platforms keeps one design.

**The entire surface has three tap targets:** a station row, `Directions`, and `Bay alert`. Plus the host's own back and content-refresh affordances.

**Contingency [verify — m23 of round 1, still open]:** Google deprecated `CHARGING`, `MapTemplate`, `PlaceListNavigationTemplate` and `RoutePreviewNavigationTemplate` quietly, and now positions `SectionedItemTemplate` as the successor to List and Grid. Before this design is called final, grep the pinned artifact for a `@Deprecated` annotation on `PlaceListMapTemplate`:

```
unzip -p ~/.gradle/.../androidx.car.app/app/1.7.0-rc01/app-1.7.0-rc01.aar classes.jar > /tmp/car.jar \
  && javap -cp /tmp/car.jar androidx.car.app.model.PlaceListMapTemplate | head -5
```

A deprecation would not break this design (a deprecated template still renders), but it would reopen §0's calculus about declining `MapWithContentTemplate`, and it would move the whole design onto a template Google intends to retire. That is a decision, not a lint warning.

---

## 1. The two invariants

Everything structural in this document exists to hold these two lines.

> **INVARIANT A — count stability.** No template's **row count** or **action count** may vary with availability, freshness, watch state, rate coverage, connector count, or the driver's profile. They may vary only with facts that are **latched for the life of the template instance**: sign-in state, notification permission, and host content limits. Only row **text** and `DistanceSpan` values vary at runtime. **Action titles are constant too** (§8.2) — v3 removes the last varying one.
>
> **INVARIANT B — grammar totality.** Every string that describes availability, rate or freshness is emitted by a **total** function over the domain state. There is no state of the world for which the grammar falls through to a neighbouring clause. In particular: the denominator of any availability fraction is the **known** set; the word *busy* is never applied to a bay whose state is `Unknown`; `OutOfService` is never folded into `Occupied` at any count; and **under a lens the counts are re-derived, never inherited** (§3.1).

**How the latches work.** Facts that Invariant A permits to vary the shape are read **once** and held:

| Latched fact | Read when | Can it change mid-connection? |
|---|---|---|
| `isSignedIn` | `onCreateSession`, re-read only on `onNewIntent` | The phone can sign out mid-drive; the car surface deliberately does not observe it. The next intent (which **resets the quota**) picks it up. |
| `notificationsPermitted` (`POST_NOTIFICATIONS`, Android 13+) | same | same |
| `contentLimit(PLACE_LIST)`, `contentLimit(PANE)` | Screen construction | host-constant for a connection |
| **`origin`** | **Screen construction — and then constant for the life of that Screen instance. It never improves, never reverts, never moves.** (M-C) | **No.** A fix that lands later is picked up at the next Screen construction, which happens on any intent — and every intent is a documented quota reset (§5.3, §9.3). |

A Screen instance therefore knows its own shape **and its own frame of reference** before it emits its first template, and neither changes under the driver's hands.

**What is no longer latched.** v2 latched *"ledger headroom at construction"* and used it to decide whether the bay-alert action existed. That is gone: §8.2's action is now unconditional on the ledger, because §8.2's toggle is provably free (F-B). **No template's shape is derived from the ledger anywhere in this design** — §5.4 R3 states that as a standing prohibition rather than a construction-time trick.

---

## 2. Template inventory and Session / Screen structure

### 2.1 Manifest frame

Each line is annotated with the element it must sit under — v2's fragment left that to the reader (m-L), and `uses-permission` under `<application>` is a build failure, not a style problem.

```xml
<manifest …>

  <!-- direct children of <manifest> -->
  <uses-permission android:name="androidx.car.app.MAP_TEMPLATES" />
  <!-- deliberately absent: androidx.car.app.NAVIGATION_TEMPLATES (navigation apps only) -->
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

  <application …>

    <!-- direct child of <application> -->
    <meta-data android:name="androidx.car.app.minCarApiLevel" android:value="1" />

    <service android:name=".car.EvGuideCarAppService"
             android:exported="true"
             android:process=":car">                              <!-- M12: no RN runtime in this process -->
      <intent-filter>
        <action   android:name="androidx.car.app.CarAppService" />
        <category android:name="androidx.car.app.category.POI" /> <!-- NOT …CHARGING (deprecated 1.3.0-alpha01) -->
      </intent-filter>
    </service>

  </application>
</manifest>
```

Library floor `androidx.car.app:1.7.0-rc01` (permission dialogs correct on Android 14+, no AAOS-15 crash). `minCarApiLevel 1` with **runtime guards** on everything above it, so nothing hard-fails on an old host. Android Automotive OS is a separate artifact and stays out of scope.

**The car layer never requests a runtime permission.** Both permissions above are requested by the phone app, in its own onboarding, on the phone. This is what makes `VI-1` (*"if the user must go to the phone, display a message telling them to look at it only when safe"*) vacuous here rather than a string we have to author: the car surface never requires the driver to go to the phone for anything, because §9.3's origin ladder always yields a usable origin and §8.2's watch affordance is simply absent when its preconditions are not already true.

**The consequence of that, stated once and routed:** a reviewer who never granted `POST_NOTIFICATIONS` on the phone sees **no bay-alert row and no bay-alert button**, and one of ticket 23's three `PF-1` functions is invisible. That is why granting the permission is an **explicit step of ticket 20's demo script** (M-E, §13).

### 2.2 Templates used — three, and only three

| Template | Where | Why this one |
|---|---|---|
| **`PlaceListMapTemplate`** | root, the nearby list | POI-exclusive; host draws the map; the only template whose refresh rule carries a documented *content-refresh escape hatch* |
| **`PaneTemplate`** | station detail | label/value rows whose **titles are constant**, so every volatile value is a free refresh; and it is a **legal 5th (terminal) template** for a POI app |
| **`MessageTemplate`** | `QuotaGuard` only (§5.4) | legal terminal template; the surface's single safety valve, never on a normal path |

**The first paint is always a populated place list.** There is no loading state, no empty state, and no message on the launch path — see §9.3.

### 2.3 Templates available and deliberately unused

| Template | Verdict |
|---|---|
| `MapWithContentTemplate` | Declined — §0. Would pull in surface rendering, `MR-1`, `AR-1`, tiles. |
| `ListTemplate` / `GridTemplate` / `SectionedItemTemplate` | No map, no `DistanceSpan` mandate to satisfy, nothing the place list doesn't do better. `SectionedItemTemplate` also needs Car API 8. |
| `SearchTemplate` | Not in v1. Browse-by-proximity is the primary access path (car constraint 12); keyboards are frequently unavailable while driving. Cheapest future addition (*any* content change counts as a refresh) — revisit when parked-state search is wanted. |
| `TabTemplate` | **Refused.** Its refresh semantics are undocumented, so every tab switch is an unpriced quota risk; and 5 tabs need Car API 9. One task, one root. |
| `SignInTemplate` | **Refused on principle.** No sign-in wall appears on any car screen (ADR-0003 as amended, ticket 23). Also unusable: Google / Apple / magic-link cannot complete on a head unit. |
| `LongMessageTemplate` | Nothing to say at that length while driving. |
| `NavigationTemplate`, `MediaPlaybackTemplate` | Category-locked away from POI. Touching them is a runtime failure. |

**Voice.** `VC-1` (Gemini + Assistant commands) applies to Media and Navigation only — **voice is not required of a POI app**, and EV Guide ships none in v1. Three reasons, recorded so this is a decision rather than an omission: (i) the POI guide's demonstration (*"Hey Google, find nearby charging stations on ExampleApp"*) needs App Actions / BII plumbing and a `shortcuts.xml` on the **phone** app, which is work outside the car package; (ii) Assistant's Rwanda-English coverage is unestablished and untestable from here, so the feature could not be verified before submission; (iii) CarPlay forbids voice *recording* to a charging app entirely, so a voice-first design could not be symmetric and would break the one-design rule. Revisit when the phone app ships App Actions for its own sake.

### 2.4 Service / Session / Screen

```
EvGuideCarAppService : CarAppService                     [runs in process ":car" — no React Native host]
├─ createHostValidator()       → allowlist from androidx.car.app R.array.hosts_allowlist_sample
│                                (ALLOW_ALL only in debug builds)          [inferred: standard boilerplate]
└─ onCreateSession(SessionInfo) → EvGuideSession          (one Session per car connection)

EvGuideSession : Session
├─ latches isSignedIn · notificationsPermitted            (§1, re-latched only on onNewIntent)
├─ onCreateScreen(intent)       → seeds the Screen stack (§5.3)
├─ onNewIntent(intent)          → re-seeds it — the documented quota RESET
├─ onCarConfigurationChanged()  → deliberately does NOT invalidate (§10, TH-1)
└─ owns: CarCacheReader · AvailabilityKt · GrammarKt · OriginProvider · WatchOpWriter · TemplateLedger

NearbyScreen  : Screen  → PlaceListMapTemplate            (always; §9.3 guarantees an origin)
StationScreen : Screen  → PaneTemplate                    (constructed with an opaque stationId)
QuotaGuard             → MessageTemplate                  (emitted BY NearbyScreen, never pushed; §5.4)
```

Supporting native objects, all Kotlin (§9.4):

- **`CarCacheReader`** — reads the read-only snapshot written by the phone process. Schema in §9.1. Holds **raw per-Connector latest reports**, never a materialised aggregate.
- **`AvailabilityKt`** — a Kotlin transcription of the ADR-0008 derivation (latest report → offline override → decay by source+state → **stage 1** occupancy propagation → **stage 2** lensed bay roll-up), fixture-tested against `packages/domain`'s canonical cases.
- **`GrammarKt`** — a Kotlin transcription of the **total** availability / rate / freshness grammar (§3), and of the closed vocabulary (§3.8). Also owned by `packages/domain` and fixture-shared. Deliberately *not* a scattering of format strings at the call sites.
- **`OriginProvider`** — §9.3's ladder. Synchronous, non-blocking, never rejects mock providers.
- **`WatchOpWriter`** — appends watch intents to the op file. **Performs no network I/O and holds no credential.** Also owns the one-line `car-last.json` that satisfies `EP-2` across process death (m-J, §9.1).
- **`TemplateLedger`** — our own pessimistic mirror of the host's quota accounting (§5.4).

---

## 3. The availability, rate and freshness grammar — total by construction

Written as a specification of pure functions so it can live in `packages/domain` and be transcribed once into Kotlin, rather than reinvented at three call sites.

### 3.1 From connectors to bay states — the two-stage derivation (F-A)

**The defect this replaces.** v2 rolled a bay up over **all** its connectors, and §3.6 then *filtered* stations and bays by the driver's type. The filter selected a bay but never re-derived its state, so a dual-gun bay whose GB/T gun is `Free` and whose Type 2 gun is `OutOfService` was counted as a **free bay for a Type 2 driver**. A driver diverts, arrives, and finds the only gun they can use is broken — the exact failure ADR-0002's fourth state exists to prevent, delivered by the feature that exists to prevent it.

**The fix is structural: the roll-up takes the lens as a parameter, so a lensed count is never inherited from an unlensed one.**

```
stage 0  effective(c, now)          ADR-0002: latest Report by capturedAt → offline-source override
                                    → decay by window(source, state): driver 2 h · operator 6 h
                                      · OutOfService 30 d.  Result ∈ {Free, Occupied, OutOfService, Unknown}

stage 1  occupancyAdjusted(c, now)  ADR-0008 propagation, PHYSICAL and LENS-INDEPENDENT:
                                    if any connector on the same Bay is effectively Occupied,
                                    a Free sibling degrades to Occupied.   ← unchanged from v2

stage 2  bayStateUnder(bay, T?, now)   the roll-up, over ONLY the bay's T-offering connectors
                                       (T absent ⇒ every connector on the bay)
```

**Stage 2, precedence, first match wins.** Let `S = { occupancyAdjusted(c) : c ∈ bay.connectors, T = ∅ or c.type ∈ T }`. `bayStateUnder` is **defined exactly when `S ≠ ∅`**, i.e. when the bay offers `T`; bays that do not offer `T` are the other side of §3.6's partition and are never given a lensed state.

| Test, in order | Result | Why |
|---|---|---|
| `Occupied ∈ S` | **Occupied** | one vehicle occupies the position |
| `Free ∈ S` | **Free** | a working gun of the driver's kind on a free position |
| `S ⊆ {OutOfService}` | **OutOfService** | every gun *of this kind* on the position is known broken |
| otherwise (no Free, no Occupied, ≥1 `Unknown`) | **Unknown** | |

**Why the two stages are not one.** Occupancy crosses the type boundary because a parked car blocks every gun on the position — that is a physical fact about the bay. Brokenness does **not** cross it: a broken Type 2 gun says nothing about the GB/T gun beside it, and a working GB/T gun says nothing about the Type 2 gun beside it. **v2 collapsed both facts into one roll-up and therefore let a working gun vouch for a broken one.** Stage 1 is about the position; stage 2 is about the plug.

**The unlensed bay state is `bayStateUnder(bay, ∅)`** — one function, two call sites, and the table above is v2's §3.1 table as the `T = ∅` case. Ticket 19 receives **one** function, not two (§3.9, §13).

**Counts.** For a station under a lens `T`: `n_T = baysOffering(T)` bays, of which `f` Free, `o` Occupied, `x` OutOfService, `u` Unknown; the **known set** is `k = f + o + x`, and `f + o + x + u = n_T` always. Unlensed, `n_∅ = n` = every bay. Every count in every clause in this document is produced by `bayStateUnder` at the same lens as the clause.

### 3.2 Grammar G — the availability clause

`G(n, f, o, x, u)` returns an ordered list of variants, longest first. Three regimes partition the space.

**Pluralisation and the `n = 1` rule (exposed by fixture F-A/1, §9.1).** Rwanda's directory is full of one-bay and one-plug-per-type sites, so `n = 1` is a common case, not an edge. Two rules, applied everywhere in this section:

- `1 bay` / `2 bays`, `1 plug` / `2 plugs` — the noun agrees with its own count.
- **When the total is 1, the word `All` never appears and the clause is written in the singular with `The`:** `The bay is free` · `The bay is busy` · `The bay is out of service`. v2 would have rendered `All 1 bays busy` and `1 of 1 bays free`; both are in the grammar's output space and both are wrong English on a screen a driver reads at 60 km/h.

**Regime 1 — `u = n` (nothing known). The majority case.**

No availability clause is emitted at all. The slot carries a **capacity clause** instead:

```
4 bays · up to 60 kW
4 bays                       (short variant)
1 bay · up to 60 kW          (n = 1)
```

This is ADR-0002's own instruction, verbatim: *"Availability appears as an additive badge when present and is simply absent when not."* The listing stays complete — capacity and peak power are facts, and peak power is decision-relevant while driving in a way rate (forbidden on a row) is not.

**Regime 2 — `u = 0` (everything known).** A total is legitimate, because the denominator is fully known.

| Condition | Clause | `n = 1` form |
|---|---|---|
| `f = n` | `All 4 bays free` | `The bay is free` |
| `f > 0, x = 0` (and `f < n`) | `2 of 4 bays free` | — |
| `f > 0, x > 0` | `1 of 4 bays free · 1 out of service` | — |
| `f = 0, o > 0, x = 0` | `All 4 bays busy` | `The bay is busy` |
| `f = 0, o > 0, x > 0` | `No free bays · 1 out of service` | — |
| `f = 0, o = 0, x = n` | `All 4 bays out of service` | `The bay is out of service` |

Note row 5: when any bay is broken the word *all* never appears with *busy*, because "all busy" tells a driver to wait and a broken bay will never free — the exact failure ADR-0002's fourth state exists to prevent.

**Regime 3 — `0 < u < n` (mixed). The steady state, and v1's fatal gap.** (`n ≥ 2` automatically.)

No total, no fraction, and never the word *all*. The clause is the non-zero counts, in a fixed order, joined by ` · `:

```
{f} bay(s) free  ·  {o} busy  ·  {x} out of service  ·  {u} unknown
```

Zero counts are omitted. Examples across the space:

| `(n,f,o,x,u)` | Clause |
|---|---|
| `(4,2,0,0,2)` | `2 bays free · 2 unknown` |
| `(4,2,1,0,1)` | `2 bays free · 1 busy · 1 unknown` |
| `(4,0,2,0,2)` | `2 busy · 2 unknown` — **never** "all busy" |
| `(4,0,2,1,1)` | `2 busy · 1 out of service · 1 unknown` |
| `(4,0,0,1,3)` | `1 out of service · 3 unknown` |
| `(4,1,1,1,1)` | `1 bay free · 1 busy · 1 out of service · 1 unknown` |

**The distinguishing rule, learnable in one glance:** an availability clause always contains a **state word** (`free` / `busy` / `out of service` / `unknown`); a capacity clause never does. `4 bays · up to 60 kW` cannot be misread as `4 bays free`.

### 3.3 The freshness clause, and what "source" means for an aggregate

The freshness clause is appended to a Regime 2 or 3 availability clause (never to a capacity clause — freshness qualifies a state, and Regime 1 asserts no state):

```
· {source}, {age} ago
```

Two rules, both routed to ticket 19 because the domain model names `lastReportedAt` without defining an extremum and does not define `source` for an aggregate at all:

1. **Contributors are the reports backing `Free` and `Occupied` bays only.** `OutOfService` is excluded. ADR-0002's own justification: *"an operator marking a bay out of service asserts a durable fact; a driver reporting a bay busy describes a moment."* A 30-day window and a 2-hour window cannot share one age word, and letting a 3-day-old declaration set the clause would make a 14-minute-old `Free` read as stale. Where there is room, `OutOfService` carries its own age inline on the pane (`out of service 3 days`); on a list row it does not.
2. **`source` is the single source when contributors agree, and `mixed` when they differ. `age` is the *oldest* contributing `capturedAt`.** Where a variant must collapse `mixed` to one word it collapses to the **weakest** contributor (`driver < operator < admin`) — understating provenance is the safe direction. Showing `operator` over three operator reports and one driver report would promote a driver claim to operator provenance, and provenance is the entire confidence axis.

**A bound worth stating:** because contributors exclude `OutOfService`, and driver/operator `Free`/`Occupied` decay at 2 h and 6 h, **a contributing report is never more than 6 hours old**. The age word on a list row is therefore always `just now`, `{n} min ago` or `{n} h ago`; `days` appears only on the pane's inline `out of service` age. This is what keeps the freshness clause short enough to survive the variant ladder.

### 3.4 The variant ladder, and what must never be dropped

`CarText` variants are the sanctioned length mechanism (no character budget is published anywhere). The drop order is fixed, and it is chosen so the two things a driver acts on survive to the last variant:

1. drop the age *word* (`ago`) → 2. drop the source word → 3. drop the `busy` clause → 4. drop the plural nouns.
**`free`, `out of service` and `unknown` counts are never dropped.** A `busy` bay is neither actionable-positive nor a hazard; a broken bay is a hazard, and an unknown bay is the honesty guarantee.

Worked ladder for `(4,1,1,1,1)`, operator, 14 min:

```
1 bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago     (73)
1 free · 1 busy · 1 out of service · 1 unknown · operator, 14 min             (65)
1 free · 1 out of service · 1 unknown · 14 min                                (46)
1 free · 1 out of service · 1 unknown                                         (37)
```

Under a lens the type word rides in the first clause and the ladder is one rung longer, dropping the type word last of all (§3.6).

### 3.5 Grammar R — the rate clause

Rate lives on the **Connector**, has its own `Unknown`, and its own 90-day decay (`rateConfirmedAt`). It never appears on a list row; it is a pane row only. Partition the station's `m` connectors into `c` with a confirmed, in-window rate and `m − c` without.

| Condition | text 1 | text 2 |
|---|---|---|
| `c = 0` | `No confirmed rate` | `0 of 5 plugs confirmed` |
| one distinct rate among the confirmed | `600 RWF/kWh` | `All 5 plugs · confirmed 12 days ago` **or** `3 of 5 plugs · 2 unknown · 12 days ago` |
| two distinct rates | `600 RWF/kWh GB/T · 400 RWF/kWh Type 2` | as above |
| ≥3 distinct rates | `From 400 RWF/kWh · 3 rates` | as above |

Three deliberate choices. **`No confirmed rate`, not "no published rate"** — the first states EV Guide's knowledge, the second would assert a licensee is out of compliance with RURA Art. 27(2). **The denominator is plugs, not bays** — a dual-gun bay can carry two different rates, so a bay denominator is a category error (this is a **domain-layer** divergence from the CarPlay design; see §3.9). **`From` asserts a floor over the confirmed set only**, and the unknown remainder is stated in the same breath, so the floor is never presented as a floor over everything.

An optional `sessionFeeRwf` appends to text 1 when present and the string still fits: `600 RWF/kWh + 500 RWF session`.

### 3.6 Grammar Q — the "free for me" lens, re-derived under the lens (F-A)

When a device-local vehicle profile exists (§7.2), the grammar is applied to the **subset of bays that offer one of the driver's types**, and the remainder is described **without a per-type count**. Two rules, and the first is the F-A fix:

> **1. Counts under a lens come from `bayStateUnder(bay, T)`, never from the unlensed roll-up.** The lens selects which connectors the roll-up runs over. It never selects a bay whose state was rolled up over connectors the driver cannot use.
>
> **2. Name exactly one side of a binary partition.** `offers-T` and `does-not-offer-T` partition the bays. Name the driver's side by type and count; name the other side as `other bays` with its types listed but **never counted by type**. (A Bay carries 1..N Connectors, so per-type bay counts do not sum to `n`; v1's `1 of 2 GB/T bays free · Also 2 Type 2 bays` invented parking positions at a dual-gun site.)

**All three regimes apply under the lens**, with `n_T` as the total and `k_T = f+o+x` as the known set. This is the second half of the F-A fix: v2's §3.6 table had no mixed-lens row at all, so a driver whose GB/T bays were half-known fell through to the unlensed clause.

| Situation | text 1 | text 2 |
|---|---|---|
| no profile | grammar G over all `n` bays | `GB/T DC · Type 2` |
| `n_T = 0` — station offers nothing the driver can use | `No GB/T bay here` | `4 bays · Type 2, CCS2` |
| lensed Regime 1 (`u = n_T`) | `2 GB/T bays · up to 60 kW` | `2 other bays · Type 2 only` |
| lensed Regime 2, `f = n_T` | `All 3 GB/T bays free · operator, 14 min ago` | `1 other bay · Type 2 only` |
| lensed Regime 2, `f>0, x=0` | `1 of 2 GB/T bays free · operator, 14 min ago` | `2 other bays · Type 2 only` |
| lensed Regime 2, `f>0, x>0` | `1 of 3 GB/T bays free · 1 out of service · operator, 14 min` | `1 other bay · Type 2 only` |
| lensed Regime 2, `f=0, o>0, x=0` | `All 2 GB/T bays busy · driver, 40 min ago` | `2 other bays · Type 2 only` |
| lensed Regime 2, `f=0, x=n_T` | `All 2 GB/T bays out of service` | `2 other bays · Type 2 only` |
| lensed Regime 2, `n_T = 1` | `The GB/T bay is free · operator, 14 min ago` | `3 other bays · Type 2 only` |
| **lensed Regime 3** (`0 < u < n_T`) | `1 GB/T bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago` | `1 other bay · Type 2 only` |

`3 GB/T bays` + `1 other bay` = `4`, always, because the partition is on *offers this type*, not on *is this type*. A dual-gun GB/T + Type 2 bay is counted once, on the driver's side, and never again.

**The lensed variant ladder** adds one rung to §3.4 and it is the *last* to fire: the type word (`GB/T`) is dropped only after the source word and the `busy` clause, because a lensed count read as an unlensed one is a lie about the whole station. Longest lensed string: **81 characters** (§11).

Three properties fall out, and they are the reason the lens exists at all. A **stale or wrong profile is visible** — the row says *GB/T*, so a driver who changed cars sees why the numbers look odd instead of silently losing stations. An **incompatible station stays in the list and says so**, which is ticket 09's requirement that a GB/T driver at a Type 2 + CCS2 site sees incompatibility even with a bay standing empty. And the **load-bearing fact occupies the durable slot** — incompatibility is in text 1, detail in the expendable text 2.

### 3.7 What this grammar never says

- **No string on any car screen states report *history*.** Not *no recent report*, not *not reported*, not *unreported*, not *no recent bay report*. The reason is structural and it is the M-D defect: under ADR-0002's **offline-source override**, a report that arrived **thirty seconds ago** from a pedestal declaring itself offline yields `Unknown` immediately. "No recent report" would then be **false** — a report exists and it is recent; what does not exist is confirmation. The permitted form states EV Guide's knowledge: **`No confirmed bay status`** (pane only, §4.4). The same rule retires *unreported* as a count word (§3.9 item 3).
- No string says *unavailable*, *offline*, *error*, or *unknown data*. In Regime 1 the availability clause is **absent**, per ADR-0002. The one exception is the pane's second line (**§4.4**), where there is room and the driver is committing to a 20-minute drive.
- No decayed value is ever rendered, in any form — not greyed, not parenthesised, not as "last seen free 3 days ago". The derivation runs at render time on the device over raw reports (§9.1), so a stale green is **unrepresentable**, not merely discouraged.
- No colour, icon, marker change or motion encodes availability anywhere. `SA-1` forbids animation outright, and with ~87 % of the country `Unknown`, any distinguishing treatment renders the map as a field of failure — the outcome ADR-0002 forbids by name.

### 3.8 The complete vocabulary — every word this surface may print

This is the whole closed set. `GrammarKt` and `packages/domain` emit from it and nothing else; a string not derivable from this table is a defect, not a copy choice. It is stated in full here so the CarPlay/Android crosscheck has one place to reconcile against (§3.9).

**Five rules that generate the table.**

- **V1 — a word may state EV Guide's *knowledge*; no word may state *report history*.** (`unknown` names the model state and is legal; `unreported` / `no recent report` name the absence of a report and are false under the offline override — §3.7.)
- **V2 — no word renders `Unknown` as an error, an absence, or an apology.** It is a count beside other counts, or nothing at all.
- **V3 — `busy` quantifies `o` and nothing else;** `out of service` never folds into it at any count; `All` never appears with `busy` when `x > 0`.
- **V4 — when a total is 1, no `All`, singular noun, `The …` form** (§3.2).
- **V5 — one separator, ` · ` (space, U+00B7, space).** The only comma on the surface is inside the freshness clause (`operator, 14 min ago`). No semicolons, no parentheses, no ellipses.

| Class | The complete set |
|---|---|
| Bay-state words | `free` · `busy` · `out of service` · `unknown` |
| Quantifiers / connectives | `All` · `The … is` · `No` · `of` · `other` · `up to` · `From` |
| Nouns | `bay` / `bays` · `plug` / `plugs` · `rate` / `rates` |
| Source words | `operator` · `driver` · `EV Guide` (= admin) · `mixed` |
| Age words | `just now` · `{n} min ago` · `{n} h ago` · `{n} days ago` (days only on the pane's inline `out of service {age}`) |
| Connector type words | `Type 2` (`IEC_62196_T2`) · `CCS2` (`IEC_62196_T2_COMBO`) · `GB/T AC` · `GB/T DC` · `Other plug` (`OTHER`/`UNKNOWN`) |
| Power | `60 kW` · `up to 60 kW` |
| Rate | `600 RWF/kWh` · `+ 500 RWF session` · `From 400 RWF/kWh` · `3 rates` · `No confirmed rate` · `{c} of {m} plugs` · `{u} unknown` · `confirmed {age}` |
| Availability absence (pane only) | **`No confirmed bay status`** |
| Pane row titles (constant labels) | `Availability` · `Connectors` · `Rate` · `Bay alert` |
| Actions | `Directions` · **`Bay alert`** (constant, §8.2) · `Directions to {nameShort}` (QuotaGuard only) |
| Template titles | `Charging nearby` · `Charging in Kigali` · `{Station.name}` (pane) |
| Watch states (row 4 texts) | `Not watching` · `Alert requested` · `Waiting for confirmation` · `Watching · until 14:05` · `One alert, then it ends` · `Bay alert stops it` · `One alert, next 2 hours` · `any plug` · `{type} only` · `A bay is free now` · `No alert needed yet` · `3 alerts already running` · `Stop one to add another` · `Couldn't set the alert` · `Retrying · expires in 2 hours` · `Alert sent · a bay is free` |
| QuotaGuard | title `Charging nearby` · message `Open EV Guide from the car screen to keep browsing.` |
| Notification | title `A bay just freed up` · text `{nameShort} · {source} report` |
| Marker | `{Owner.markerLabel}`, 1–3 authored characters, nothing else |
| Distance | **none.** EV Guide prints no distance literal anywhere on Android: the value is a `DistanceSpan` and the **host** renders it, unit and all. |
| Station names | `{Station.nameShort}` on rows, `{Station.name}` on the pane — authored, never mechanically truncated |

### 3.9 Divergences from the CarPlay design, and the reconciliation ticket 19 needs

The twin document (`01-carplay-design-v2.md`) uses a different availability vocabulary and, in two places, a different *function*. **Ticket 19 must not receive two contradictory specs of one pure function**, so every divergence is classified here as either **domain-layer** (one answer, must be reconciled before the schema locks) or **rendering-layer** (each surface may differ, because the platforms differ).

| # | Thing | CarPlay v2 | This document | Layer | Reconciliation I propose |
|---|---|---|---|---|---|
| 1 | Bay roll-up precedence | §5.2 `Occupied > Free > all-OOS > Unknown` | §3.1 stage 2, identical | domain | **They already agree.** Ship one `bayStateUnder(bay, T?, now)`; CarPlay's `bayState(bay, now)` is its `T = ∅` case. |
| 2 | **Lensed free count** | `freeBaysOffering(T)` = bays where the **unlensed** state is `Free` **and** ∃ a `T` connector not `OutOfService` (*"Unknown counts as usable"*) | `bayStateUnder(bay, T)`, then `freeBaysOffering(T) = #{b : bayStateUnder(b,T) = Free}` | **domain — must not diverge** | **Adopt the two-stage roll-up.** Both rules reject the F-A fixture (a `Free` bay whose only `T` gun is broken). They differ where the `T` gun is `Unknown` on an unoccupied position: CarPlay calls it **free for me** on the strength of a report about a *different* gun; this document calls it **unknown**. Asserting an unproven **positive** is the failure ADR-0002/0008 exist to make unrepresentable; `Unknown` asserts nothing and still satisfies the CarPlay verdict's own F1 rule (never assert an unproven negative), because a lens whose bays are all `Unknown` emits a capacity clause, never `0 of N free`. |
| 3 | `Unknown` count word | `unreported` | `unknown` | rendering — **but `unreported` breaks rule V1** | Change CarPlay's `unreported` → `unknown`. Under the offline override a bay can be `Unknown` while carrying a 30-second-old report, so `unreported` is false in exactly the case M-D identifies on this side. |
| 4 | `Occupied` count word | `in use` | `busy` | rendering | Either is honest. One product should pick one; I have no platform reason to prefer mine and will take `in use` if the crosscheck wants it — the *rule* (V3: it quantifies `o` only) is what matters and both docs already hold it. |
| 5 | Freshness collapse | weakest source always; the word `mixed` is refused | structured; `mixed` in long variants, weakest when a variant must collapse | domain returns structure, word is rendering | Ticket 19 returns `(contributingSources: Set, oldestContributingCapturedAt)` and **no word**. CarPlay renders the weakest (no variants, 44-char budget); Android renders `mixed` in the long variant and collapses to weakest (`CarText` variants exist). Both derive from one function; neither owns a string the other must use. |
| 6 | **Rate denominator** | **bays** (`600 RWF/kWh · 3 of 4 bays · 1 unpriced`) | **plugs** (`3 of 5 plugs · 2 unknown`) | **domain — must not diverge** | **Plugs.** Rate lives on the Connector; a dual-gun bay can carry two different rates, so a bay denominator cannot represent the data. CarPlay's clause needs the one-word change. |
| 7 | Rate multi-rate form | range `350–450 RWF/kWh` | `From 400 RWF/kWh · 3 rates` | rendering | Either. The function is one: `rateCoverage(station) = (confirmedPlugs, totalPlugs, distinctRates[], oldestConfirmedAt)`. |
| 8 | Rate `Unknown` word | `unpriced` | `unknown` | rendering | Prefer `unknown`, so the availability and rate vocabularies use one word for one idea. |
| 9 | Distance | `~2.4 km` / `~2.4 km straight line`, app-authored | `DistanceSpan`, **host-rendered**, no qualifier possible | platform-forced | Not reconcilable and does not need to be: `Row.setTitle` accepts only Distance/Duration spans and the literal residue must stay constant for the refresh diff, so Android cannot carry the straight-line qualifier on a row. It is not carried on the pane either (the PANE floor is 4 rows and all four are spent). **Stated as compromise 9.** |
| 10 | Watch button label | `Notify when free` (16-char budget) | constant **`Bay alert`** (quota, §8.2) | rendering — **but ticket 30 must get ONE amendment** | Propose **`Bay alert` on both car surfaces** (9 chars, inside CarPlay's 16-char budget, and it makes the row above it the state display on both). Ticket 30's `Notify me when a bay frees up` survives on the phone. One amendment naming three surfaces, not two contradictory ones. |
| 11 | Capacity clause | `4 bays · GB/T DC and Type 2` (types, joined with *and*) | `4 bays · up to 60 kW` (types ride in text 2) | rendering | Slot counts differ, so the content legitimately differs. The **type-word mapping** (row 6 of §3.8) must be one projection in `packages/domain`, and `and` vs ` · ` is a per-surface joiner. |
| 12 | Age words | `2 days ago`, `21 days ago` on rows | bounded to ≤ 6 h on rows by §3.3's contributor rule | consistent, if CarPlay adopts the contributor bound | CarPlay already excludes `OutOfService` from the age; with that rule its row ages are bounded the same way. Worth stating in both docs so a `21 days ago` row is recognised as a bug. |

Items **2** and **6** are the ones that block: they are single pure functions with two definitions. Items 3, 8, 10 are one-word changes I recommend but do not own. Everything else may differ.

---

## 4. Every screen, exact rendered text

### 4.0 The worked example

Chosen to exercise a dual-gun bay, a propagated occupancy, an out-of-service bay, an unknown bay, and two distinct rates.

```
Station   name       "Kabisa – SP Remera"        ← Station.name
          nameShort  "SP Remera"                 ← Station.nameShort (the PLACE; operator rides the marker)
          owner      Kabisa · markerLabel "KAB"
          geo        -1.9556, 30.1044            ← Station.geo (NOT NULL)

Bays      B1  ├ C1  GB/T DC 60 kW   600 RWF/kWh   Occupied      operator, 14 min ago
              └ C2  Type 2  22 kW   400 RWF/kWh   Free          operator, 14 min ago   → stage 1: Occupied
          B2  └ C3  GB/T DC 60 kW   600 RWF/kWh   Free          operator, 14 min ago
          B3  └ C4  Type 2  22 kW   400 RWF/kWh   OutOfService  operator, 3 days ago
          B4  └ C5  Type 2  22 kW   rate unknown  no report                            → Unknown

Derived   unlensed (T = ∅)   n=4  f=1  o=1  x=1  u=1     B1 Occupied · B2 Free · B3 OOS · B4 Unknown
          lens GB/T DC       n_T=2 (B1,B2)  f=1 o=1      B1→Occupied {C1} · B2→Free {C3}
          lens Type 2        n_T=3 (B1,B3,B4)  o=1 x=1 u=1   B1→Occupied {C2} · B3→OOS {C4} · B4→Unknown {C5}
          plugs m=5, confirmed rates c=4
          contributors      C1 (operator, 14 min), C3 (operator, 14 min)   [C4 excluded: OutOfService]
          freshness clause  "operator, 14 min ago"
          availability      unlensed Regime 3 → "1 bay free · 1 busy · 1 out of service · 1 unknown"
                            GB/T lens Regime 2 → "1 of 2 GB/T bays free"
                            Type 2 lens Regime 3 → "1 busy · 1 out of service · 1 unknown"
```

Note the Type 2 lens: **it contains no `free` count at all**, because the only Type 2 gun on a free position (C2) is blocked by the car on C1, and the other two Type 2 guns are broken and unknown. v2 would have reported a free bay to that driver via B2, which offers no Type 2 gun whatsoever.

### 4.1 S0 — `NearbyScreen` / `PlaceListMapTemplate`

```
┌──────────────────────────────────────────────────────────────┐
│ [icon]  Charging nearby                              ⟳       │  header action APP_ICON + host content-refresh
├───────────────────────────────┬──────────────────────────────┤
│  2.4 km · SP Remera           │                              │
│  1 bay free · 1 busy · 1 out  │        (host-drawn map)      │
│  of service · 1 unknown ·     │                              │
│  operator, 14 min ago         │        [KAB]  [KAB]          │
│  GB/T DC · Type 2             │        [EVP]                 │
├───────────────────────────────┤                              │
│  3.1 km · Kisimenti           │                              │
│  4 bays · up to 60 kW         │                              │
│  GB/T DC · Type 2             │                              │
└───────────────────────────────┴──────────────────────────────┘
```

**Template-level calls**

| Call | Value | Source | Note |
|---|---|---|---|
| `setTitle` | `Charging nearby` **or** `Charging in Kigali` | §9.3's origin latch | **Constant for the life of the screen instance**, because the origin is (M-C). The title is how the surface states its frame of reference; a title change is a *new template*, so a moving origin and a stable title cannot both exist. |
| `setHeaderAction` | `Action.APP_ICON` | — | root screen |
| `setCurrentLocationEnabled(…)` | **guarded**: `true` only when `ACCESS_COARSE_LOCATION` or `ACCESS_FINE_LOCATION` is already granted | `checkSelfPermission`, latched at construction | never requests the permission |
| `setAnchor(Place(origin))` | the latched origin | `OriginProvider` | anchored once; never re-anchored, because the origin never moves |
| `setOnContentRefreshListener` | re-rank handler | — | runtime-guarded; the documented free re-rank path. Re-ranks against the **same** origin with fresher data. Real API level **[verify]** |
| `setItemList` | exactly **N** rows | `stationsNear(origin, N)` | `N = min(getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST), 12, directorySize)`, **floor 6**, latched |
| ActionStrip | *none* | — | fewer targets while driving; also avoids an unpriced re-rank path (§13) |

**N never changes.** The radius widens until N stations are found rather than the row count shrinking. Only if the entire directory holds fewer than N stations is N smaller, and that is latched at construction.

**Row anatomy** — a title and two texts; only the first two are load-bearing.

| Slot | API | Rendered (worked example) | Rules honoured |
|---|---|---|---|
| title | `setTitle(CarText)` with a `DistanceSpan` on a leading placeholder char | `2.4 km · SP Remera` | mandatory `DistanceSpan` on every non-browsable row; `Row.setTitle` accepts only Distance/Duration spans; **spans are excluded from the refresh diff, so the distance ticks live for free**; the literal residue (`· SP Remera`) is `nameShort`, authored, constant |
| text 1 | `addText(CarText + variants)` | `1 bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago` | grammar G + freshness (§3.2–3.4), or grammar Q under a profile; availability **never in a title** |
| text 2 | `addText(CarText + variants)` | `GB/T DC · Type 2` | connector types, always present, always **expendable** — designed to be the thing a one-text-line host drops |
| metadata | `setMetadata(Metadata(Place(CarLocation, PlaceMarker)))` | pin `KAB`, **label only, no image** (§10) | a row may carry a marker **or** an image, never both → `setImage` appears nowhere |
| tap | `setOnClickListener { push(StationScreen(id)) }` | opaque `stationId` | *"information-only rows not allowed"* |

**Text 2 is always emitted**, in every regime, so the number of texts per row is as stable as the number of rows.

### 4.2 S0 — the Regime 1 row (the majority row)

```
┌───────────────────────────────┐
│  3.1 km · Kisimenti           │   title  — unchanged, distance is a span
│  4 bays · up to 60 kW         │   text1  — capacity clause; no state word, no apology, no absence
│  GB/T DC · Type 2             │   text2  — expendable
└───────────────────────────────┘
```

The row leads with a fact, carries its mandatory distance, opens a complete listing, and contains **no sentence about not knowing**. Nothing is greyed and nothing apologises. On a host that renders one text line, the plug list is what falls off — never the capacity.

### 4.3 S1 — `StationScreen` / `PaneTemplate`, signed in

```
┌──────────────────────────────────────────────────────────────┐
│ ←   Kabisa – SP Remera                                       │
├──────────────────────────────────────────────┬───────────────┤
│  Availability                                │               │
│  1 bay free · 1 busy · 1 out of service ·    │   [ Kabisa ]  │
│  1 unknown                                   │               │
│  operator, 14 min ago ·                      │               │
│  out of service 3 days                       │               │
│                                              │               │
│  Connectors                                  │               │
│  GB/T DC 60 kW · Type 2 22 kW                │               │
│  4 bays · 5 plugs                            │               │
│                                              │               │
│  Rate                                        │               │
│  600 RWF/kWh GB/T · 400 RWF/kWh Type 2       │               │
│  4 of 5 plugs · 1 unknown · 12 days ago      │               │
│                                              │               │
│  Bay alert                                   │               │
│  Not watching                                │               │
│  One alert, next 2 hours · any plug          │               │
├──────────────────────────────┬───────────────┴───────────────┤
│   [ Directions ]             │   [ Bay alert ]               │
└──────────────────────────────┴───────────────────────────────┘
```

| Slot | Rendered | Source | Rule |
|---|---|---|---|
| `setTitle` | `Kabisa – SP Remera` | `Station.name` (full form — there is room here) | constant |
| `setHeaderAction` | `Action.BACK` | — | |
| `Pane.setImage` | Kabisa mark, `CarIcon` `TYPE_RESOURCE`, one monochrome light-on-black asset | `Owner.icon` | `IU-1`'s **single static context image** — and the only image on the whole surface (§10) |
| row 1 title | `Availability` | literal **label** | constant ⇒ a report landing while this pane is open is a **free refresh** |
| row 1 text 1 | grammar G / Q | §3.2, §3.6 | |
| row 1 text 2 | `operator, 14 min ago · out of service 3 days` | §3.3 | freshness as its own axis; `OutOfService` gets its own age **in full age words** here because there is room (m-H) |
| row 2 title | `Connectors` | label | |
| row 2 text 1 | `GB/T DC 60 kW · Type 2 22 kW` | `Connector.type`, `.powerKw` | ≥3 types → `GB/T DC 60 kW · Type 2 22 kW · +1 more` |
| row 2 text 2 | **`4 bays · 5 plugs`** | `n`, `m` | the line that makes the multi-gun reality explicit and stops a driver adding per-type counts together |
| row 3 title | `Rate` | label | |
| row 3 text 1/2 | grammar R | §3.5 | |
| row 4 title | `Bay alert` | label | present iff `canWatch` (latched); **never varies with availability or watch state** |
| row 4 text 1/2 | §8.2's ladder | Watch state | text only — the whole toggle lives here |
| action 1 | `Directions` | — | **anonymous, always, unconditional** |
| action 2 | **`Bay alert` — a constant title** | — | present iff `canWatch`. **No ledger condition** (F-B). |
| ActionStrip | *none* | | |

**Row count: 4 signed-in, 3 anonymous. Action count: 2 signed-in, 1 anonymous.** Both are latched (§1) and neither varies with anything else, ever.

**Rows are sent, never truncated by the host (m-I).** The pane emits `min(contentLimit(CONTENT_LIMIT_TYPE_PANE), 4)` rows, latched at construction, ordered load-bearing-first (`Availability`, `Connectors`, `Rate`, `Bay alert`). v2 sent 4 unconditionally and relied on the host silently dropping the tail — *"items beyond the limit are silently ignored"* is a documented behaviour, not a design. And because the alert row is the **only** state display for a constant-titled button, `canWatch` now includes the pane limit:

```
canWatch = isSignedIn && notificationsPermitted && contentLimit(PANE) >= 4
```

so the button and the row it describes live and die together. The documented floor is 4, so on any conforming host this term is always true; it exists so that a below-floor host loses the *function* rather than gaining a mystery toggle.

### 4.4 S1 — Regime 1, anonymous

```
┌──────────────────────────────────────────────────────────────┐
│ ←   Kabisa – SP Remera                                       │
├──────────────────────────────────────────────┬───────────────┤
│  Availability                                │               │
│  4 bays · up to 60 kW                        │   [ Kabisa ]  │
│  No confirmed bay status                     │               │
│                                              │               │
│  Connectors                                  │               │
│  GB/T DC 60 kW · Type 2 22 kW                │               │
│  4 bays · 5 plugs                            │               │
│                                              │               │
│  Rate                                        │               │
│  No confirmed rate                           │               │
│  0 of 5 plugs confirmed                      │               │
├──────────────────────────────────────────────┴───────────────┤
│   [ Directions ]                                             │
└──────────────────────────────────────────────────────────────┘
```

**The one place the surface names its own ignorance**, and the asymmetry with §4.2 is deliberate: on a list row a driver is scanning and ADR-0002's *"simply absent"* is right; on the detail pane a driver is deciding whether to commit to a 20-minute drive, and the difference between *nobody is free* and *nobody has confirmed* is the decision.

**`No confirmed bay status`, not `No recent bay report` (M-D).** The v2 string asserted something about report *history* that the model can falsify: the offline-source override yields `Unknown` the instant a source declares itself offline, **however fresh its report is**. A pedestal that reported thirty seconds ago and marked itself offline would have been described as having produced no recent report. The replacement states EV Guide's knowledge, matches `No confirmed rate` one row below it, and is the same word the vocabulary already uses for the rate case (§3.8, rule V1). It is not greyed, not an error, and not an apology for the operator.

### 4.5 The bay-watch notification

```
Channel   ev_guide_bay_alerts          (phone channel, IMPORTANCE_HIGH — the errand expires in 2 h)
Title     A bay just freed up
Text      {nameShort} · {source} report          e.g. "SP Remera · driver report"
Tap       PendingIntent → EvGuideCarAppService intent, station detail for stationId
```

The source word is rendered from §3.8's closed set at fire time — v2 hardcoded `operator report` in the template, which is wrong whenever a driver's report is what fired the watch (m-K), and provenance is the entire confidence axis.

Posted through `CarNotificationManager` with `androidx.car.app.notification.CarAppExtender` **[inferred — and the whole delivery path is ticket 27's #1 blocking item, §13]**. `IN-1` is satisfied because the driver explicitly asked about this station within the last two hours; `NA-1` trivially (nothing to advertise, no payments, ever). One notification per watch — no repeat-fire path exists, so no digest, quiet hours or rate limiter is built. The tap is an intent and therefore **resets the template quota** (§5.3).

**Nothing on the surface depends on car delivery.** If the host filters POI notifications, the alert still fires on the phone; the armed row still clears; and the design is unchanged. What *does* depend on it is ticket 23's claim that Android's `PF-1` case rests on three functions — see §13.

---

## 5. The screen graph and the 5-template quota

### 5.1 Graph

```
        launcher / notification intent  ── RESETS quota ──┐
                                                          ▼
   ┌─────────────────────────────────────────────  S0  NearbyScreen  ───────────────┐
   │                                             PlaceListMapTemplate                │
   │   ⟳ host content refresh (free re-rank)  ↺                                      │
   │   delta sync lands                       ↺                                      │
   │   distance ticks (span)                  ↺                                      │
   │                                                                                 │
   │             row tap ▼ push                       ▲ back / pop                   │
   │                                                                                 │
   │   ┌──────────────────────────  S1  StationScreen  ─────────────────────────┐    │
   │   │                             PaneTemplate                               │    │
   │   │   report lands → row text changes            ↺  free                   │    │
   │   │   arm / disarm  → row-4 text changes         ↺  free  [hard]           │    │
   │   │                                                                         │    │
   │   │   [ Directions ] ──► startCarApp(ACTION_NAVIGATE) ──► leaves EV Guide    │    │
   │   └─────────────────────────────────────────────────────────────────────────┘    │
   │                                                                                 │
   │   QuotaGuard: S0 emits a MessageTemplate instead of a PLMT when the ledger      │
   │   would otherwise put an illegal place list in the 5th slot (§5.4 R2)           │
   └─────────────────────────────────────────────────────────────────────────────────┘
```

Maximum depth **2 screens**, inside the 5-screen stack cap and `AC-1`. The common task — find a nearby charger and drive to it — is **2 taps** (row, `Directions`), inside the *SHOULD* of 2–3 steps rather than merely the *MUST* of ≤5. **No flow ends on a list template.**

### 5.2 Cost of every transition

| # | Trigger | What we send | Documented class | Cost |
|---|---|---|---|---|
| 1 | Session start from launcher | `PlaceListMapTemplate` | first template of the task | **+1** (intent resets to 0 first) |
| 2 | Delta sync changes availability | same PLMT — title, row count, row titles unchanged | **refresh** | **0** |
| 3 | Distance ticks down | same PLMT, only `DistanceSpan` differs | **refresh** — spans excluded | **0** |
| 4 | Driver taps the host's ⟳ | PLMT with a re-ranked row set, same origin | **refresh** — documented `setOnContentRefreshListener` exception | **0** |
| 5 | Row tap | `PaneTemplate` | new template | **+1** |
| 6 | Report lands while on detail | same Pane — title, row count, row titles unchanged | **refresh** | **0** |
| 7 | **Arm / disarm watch** | **same Pane, one row's *texts* changed; title, row count, row titles and both action titles identical** | **refresh — [hard]**, the `PaneTemplate` clause verbatim | **0** |
| 8 | Back | pop S1 → refund; S0 re-emits PLMT | refund **documented**; the re-emit is a refresh under a per-screen reading, a step under a global one | **−1, then 0 or +1** |
| 9 | Directions | `startCarApp(Intent(ACTION_NAVIGATE, "geo:…"))` | not our template; the task is left | **0** |
| 10 | Notification tap | seed `[S0, S1]`; host requests only the top template **[inferred]** | **RESET**, then +1 | **→ 1** |
| 11 | Relaunch from car home (`EP-2`) | seed `[S0]` or `[S0, S1]` | **RESET**, then +1 | **→ 1** |
| 12 | Day ⇄ night | *nothing* — one monochrome asset serves both (§10) | — | **0** |
| 13 | `QuotaGuard` fires (§5.4 R2) | `MessageTemplate` | new template, legal 5th | **+1** |

**Row 7 is the F-B fix and it is the only row that moved.** v2 sent `Notify me when a bay frees up` ⇄ `Stop watching` as the action title, which is a diff the documented refresh clause does not mention — so it was priced *"0 or +1"* and carried as inference 1. The documented `PaneTemplate` clause is exactly: *title unchanged **and** row count and row titles unchanged*. With action 2's title constant (`Bay alert`), an arm or a disarm changes **nothing outside that clause** — only row 4's two texts. No inference is required, and the cost is 0 **for an unbounded number of toggles**.

**There is no origin-change transition** (M-C): the origin is fixed for the Screen instance, so no title change, no re-anchor, and no re-rank on a late fix. There is also no origin-failure transition and no empty-state transition — §9.3's ladder deletes them; the first paint is always a place list.

### 5.3 The two resets, used deliberately

Both documented resets are load-bearing here, not incidental:

- **Notification intent** — a bay-watch firing deep-links to `StationScreen`. `onNewIntent` seeds the stack `[NearbyScreen, StationScreen]` so *back* still works, and because the host only requests the **top** screen's template **[inferred]**, seeding two screens costs one template. Post-reset ledger **1/5**.
- **Launcher intent** — returning to EV Guide from the navigation app via the car home screen. This is also how `EP-2` is satisfied, how a **later location fix reaches the surface** (M-C), and the surface's **only re-rank path on a host without the content-refresh listener**.

### 5.4 `TemplateLedger` — the safety valve

The ledger counts our own sends **pessimistically**: a send is a step unless it *provably* satisfies a documented refresh clause (title + row count + row titles unchanged, spans excluded) or is the response to `setOnContentRefreshListener`. **R1 is retired** (F-B); R2–R4 keep their numbers so references from the verdict still land.

- ~~**R1 — the watch action needs two units of headroom.**~~ **Retired.** It existed because an arm and a disarm were each priced as a possible step, so the action had to be withheld unless two units were free. Arm and disarm are now provably free (§5.2 #7), so there is nothing to budget. **This is the F-B fix**: v2 bounded the *headroom* but never bounded the *number of toggles*, and three taps on an always-present button emitted a 6th template. See the failure walk below.
- **R2 — never emit a `PlaceListMapTemplate` at ledger ≥ 4.** A place list is **not** a legal 5th template. If a pop's refund does not bring the ledger below 4, `NearbyScreen` emits `QuotaGuard` — a `MessageTemplate` (legal 5th) — instead:
  ```
  Title    Charging nearby
  Message  Open EV Guide from the car screen to keep browsing.
  Actions  [ Directions to SP Remera ]
  ```
  That single action is the one affordance that leaves the app usefully, so the branch is not a dead end. **The station it names always exists** (m-M): reaching ledger ≥ 4 requires at least two detail pushes, so `car-last.json`'s last-viewed station is necessarily populated before `QuotaGuard` can fire; the action is nonetheless constructed from that file, not from an in-memory field, so it survives process death too. The message is a **head-unit** instruction, not a phone instruction, so it also stays inside CarPlay guideline 2 when the twin design reuses the wording.
- **R3 — the ledger may never shape a template.** Stated now as a standing prohibition rather than v2's construction-time latch: no row count, no action count, and no row or action *presence* anywhere in this design is derived from the ledger. The ledger's only power is R2's choice of *which template class* `NearbyScreen` emits. This is what keeps the ledger compatible with Invariant A by construction instead of by care.
- **R4 — the ledger never trusts an inference in its own favour.** Every entry in §5.2 still marked "0 or +1" is counted as +1.

`isAppDrivenRefreshEnabled()` is probed but **never depended on** — it returns `false` on host-call failure, is regional and OEM-dependent, and is absent on JAMA-affiliated vehicles. Adaptive task limits, if present, are pure headroom.

**The v2 failure this retires, walked once so it is not reintroduced.** Under v2's R1 + R4: a Pane constructed at pre-send ledger 2 (R1's permitted maximum) leaves the ledger at 3. `arm` → 4. `disarm` → 5. `arm` → **6 → the host displays an error and closes the app, mid-drive, on the third tap of a button the design put on the screen unconditionally.** R1 bounded the headroom; nothing bounded the taps.

### 5.5 Why the live layer is free

Every volatile value on this surface sits in a slot the documented refresh diff excludes:

- **on S0** — distance is a **span** (explicitly excluded); availability, freshness and plug types are **text**, never a title; the row **set** and **count** are frozen for the screen instance's lifetime and change only through the documented content-refresh path; the title is frozen with the origin.
- **on S1** — every row title is a constant label (`Availability`, `Connectors`, `Rate`, `Bay alert`); **both action titles are constants** (`Directions`, `Bay alert`); every value is text; the row count and action count are latched.

So a report arriving from the operator app repaints both screens at **zero quota cost, indefinitely**, and so does every arm and disarm the driver performs.

Corollary rule: **only the top screen may call `invalidate()`.** A background `NearbyScreen` buffers changes and applies them on `onResume`, which keeps its row set byte-identical across a down-up round trip and lets the re-emit qualify as a refresh under the per-screen reading.

### 5.6 The proof, re-run against the corrected design

Counted under R4 — every undocumented point resolved **against** us. **Both proofs model a disarm**, which no proof in v1 or v2 did.

**Proof 1 — the required session** (the walk ticket 20's demo script performs): browse → detail → **arm** → **disarm** → back → browse → detail → navigate.

| Step | Action | Class | Ledger |
|---|---|---|---|
| 1 | launcher intent → reset → PLMT | new | **1 / 5** |
| 2 | any number of delta syncs, distance ticks, ⟳ re-ranks | refresh ×n | **1 / 5** |
| 3 | tap row → Pane (4 rows, 2 constant-titled actions) | new | **2 / 5** |
| 4 | report lands, availability changes on the open pane | refresh | **2 / 5** |
| 5 | tap `Bay alert` → **arm**; row 4 → `Alert requested` | **refresh [hard]** | **2 / 5** |
| 6 | ack lands in the snapshot; row 4 → `Watching · until 14:05` | refresh | **2 / 5** |
| 7 | tap `Bay alert` → **disarm**; row 4 → `Not watching` | **refresh [hard]** | **2 / 5** |
| 8 | back → pop refunds 1 | refund | **1 / 5** |
| 9 | S0 re-emits PLMT | +1 pessimistic | **2 / 5** |
| 10 | tap row → Pane | new | **3 / 5** |
| 11 | `Directions` → `startCarApp` | leaves the task | **3 / 5** |

**Peak 3 of 5, two units in hand** — and steps 5–7 are unbounded: a driver may arm and disarm any number of times at any depth without moving the ledger. Under the optimistic reading (step 9 is a refresh) the peak is **2 of 5**.

**Proof 2 — the adversarial session**: maximum depth, and the watch toggled at every level including at the ceiling.

| Step | Action | Ledger | Note |
|---|---|---|---|
| 1 | launcher intent → PLMT | **1** | |
| 2 | tap row → Pane | **2** | watch action present — no ledger condition exists |
| 3 | arm · disarm · arm (×k, any k) | **2** | each is a documented `PaneTemplate` refresh |
| 4 | back (−1) | **1** | |
| 5 | S0 re-emits PLMT | **2** | R2 permits: ledger 1 < 4 |
| 6 | tap row → Pane | **3** | watch action present |
| 7 | arm · disarm (×k) | **3** | free |
| 8 | back (−1) | **2** | |
| 9 | S0 re-emits PLMT | **3** | R2 permits |
| 10 | tap row → Pane | **4** | watch action present |
| 11 | **disarm** (×k) | **4** | free |
| 12 | back (−1) | **3** | |
| 13 | S0 re-emits PLMT | **4** | R2 permits: ledger 3 < 4 |
| 14 | tap row → Pane | **5 / 5** | **legal terminal template**; watch action still present |
| 15 | **arm, then disarm, at the ceiling** | **5 / 5** | **the sentence F-B exists to make true:** at 5/5 the button still works, because a refresh is not a send |
| 16 | back (−1) | **4** | |
| 17 | S0 would emit a PLMT at ledger 4 → **R2 blocks** → `QuotaGuard` `MessageTemplate` | **5 / 5** | legal 5th, one useful action (`Directions to …`) |
| 18 | back | — | root pop: the app closes normally, by the driver's own act |

**Peak 5 of 5. Six is unreachable on every path, for any number of watch taps.** Every 5th template emitted is a `PaneTemplate` or a `MessageTemplate` — both on the four-class legal list for a POI app. No place list is ever the 5th. The host never closes the app.

**Proof 3 — the escape hatches, unconditionally available.** A notification tap or a launcher relaunch resets the ledger to 0 and re-seeds at 1/5, *"even if the app is already in the foreground"*. So step 17's state is not a trap: the driver's bay alert fires, or they reopen EV Guide from the car home screen, and the surface is fresh — with a re-ranked list **and a re-latched origin** (§9.3).

**What Proof 2 costs now.** Nothing the driver can see. v2's cost — *"the bay-alert button is absent although the driver saw it a moment earlier"* — is gone with R1, and with it v2's own admission that this was *"the only surprise the design still contains"*.

---

## 6. Rank, and what the driver's profile may and may not do

`stationsNear(origin, limit)` is ranked **distance-first, then availability** (domain model). This design **does not change the ranking and reserves no slots**.

> **The profile changes the wording of a row. It never changes which rows appear, and never changes their order.** — §3.6

The incompatibility wording already does the work. A GB/T driver whose six nearest stations are all Type 2 reads `No GB/T bay here` on all six, which is a true and immediately actionable statement, and they still have distance, plugs and `Directions` on every one of them. Hiding or reordering would have made a complete listing incomplete for a fact the driver can read in one glance.

If the founder later wants compatible-first, it must become a **named second ranking key in ticket 19** and the "never its presence" sentence must be deleted. Not both.

---

## 7. "Free for me" without knowing the car

### 7.1 Where the driver's connector set can come from

1. **`EnergyProfile.getEvConnectorTypes()`** — Car API 3, mapped at the edge to EV Guide's OCPI enum. **Expect `STATUS_UNIMPLEMENTED` most of the time** on Android Auto (a phone projecting to an arbitrary head unit), and **never persist the platform integer** — the two Android taxonomies disagree with each other (CHAdeMO is 3 in `EnergyProfile`, 4 in `EvChargingConnectorType`).
2. **A device-local vehicle profile** set in the phone app. **[inferred]** ADR-0003 gates profile *sync* behind an account; it does not gate a local profile. That distinction is what lets "free for me" work for an anonymous driver on a car screen.
3. **Nothing** — the normal case, and the one the base grammar is written for.

**[must be settled before ticket 19 locks]** Ticket 12's *answer* lists "sync the vehicle profile that powers 'free for me'" as account-gated; its *question* lists "setting your own connector type" among the things requiring sign-in. Those readings differ. Get the one-line ruling. **Fallback if profiles turn out to be account-gated:** grammar Q applies only to signed-in drivers, anonymous drivers get grammar G, and nothing else in this design moves — G is complete on its own and is what a reviewer sees regardless.

### 7.2 The rule

> **The profile changes the wording of the row, never its presence and never its order** (§6); per-type counts are stated **non-additively**, and **re-derived under the lens** (§3.1, §3.6).

Per-connector state is never rendered per row: two visible lines, one already spent on the mandatory distance. The domain model settled this — per-Connector rows are the **filter** dimension, the aggregate is the **display**. What the aggregate counts is **bays**, which is what stage 1 makes meaningful: `1 of 2 GB/T bays free` is a true statement about parking positions a GB/T driver can occupy — true because stage 2 asked only the GB/T guns.

### 7.3 On the detail pane

`Connectors` is its own row (types, power) with `4 bays · 5 plugs` beneath it, and the `Availability` row applies grammar Q exactly as the list row does — at the same lens, from the same `bayStateUnder` call. There is no per-connector screen: it would be a third template for information a driver cannot act on differently while driving.

---

## 8. Directions and the bay alert

### 8.1 Directions — ungated everywhere, on every path

`Directions` is a `PaneTemplate` action, present on every station detail, for every driver, signed in or not. No prompt, no sheet, no explanation, no deferred sign-in. ADR-0003's amendment (via ticket 23) removed the gate everywhere, and the car surface is why.

```kotlin
carContext.startCarApp(
  Intent(CarContext.ACTION_NAVIGATE, Uri.parse("geo:-1.9556,30.1044"))
)
```

- **Coordinates, never a place name** — Rwandan station names are not in Google's places index, and ADR-0004 fixes `lat,lng` as the deep-link form.
- **Never name a component** — `startCarApp` throws `SecurityException` if you target an app explicitly. The recipient is the host's default navigation app (= the last navigation app the user launched), which cannot be targeted or predicted.
- **What this design guarantees, exactly.** It guarantees the **hand-off**: EV Guide fires the documented intent and leaves the task. **It does not claim that the receiving app appears on the car display, and it does not claim that the receiver is Google Maps.** No Google page names Google Maps as a guaranteed `ACTION_NAVIGATE` receiver, and ADR-0004 states plainly that launching Google Maps onto the car display is *"undocumented and unverified… ticket 18 designs without assuming it."* Both questions are ticket 27's (#2). If the answer is that the driver completes the hand-off on the phone, this design is unchanged: no screen, no string and no flow here depends on the car-display outcome, and nothing on the car surface ever instructs the driver to touch the phone.
- **No route, maneuver, ETA or polyline** is modelled anywhere on this surface. There is no route entity, and drawing one would require the NAVIGATION category.
- **The destination name.** A bare `geo:lat,lng` gives Google Maps an unnamed pin. The javadoc documents exactly three URI forms and the labelled form `geo:0,0?q=<lat>,<lng>(<nameShort>)` is not among them, so **v1 of the code ships the bare, documented form** — an undocumented URI shape handed to `startCarApp` is a crash risk on the car screen, which is the worst failure this product can have. The labelled form is a **ticket 27 experiment**; if the host accepts it, adopt it. Recorded mitigation: the driver confirmed the station by name on the pane one tap earlier, so the unnamed pin follows an explicit confirmation rather than replacing one.

There is no per-row directions button: `PlaceListMapTemplate` rows use the `FULL_LIST` preset, which permits **zero** row actions. Directions is reached in exactly two taps.

### 8.2 The bay alert — one constant-titled button, and a row that says everything

Per ticket 30: arm/disarm on the station detail plus an armed-state row. Placement: pane row 4 + pane action 2.

**Presence is latched, never derived from availability, and never from the ledger:**

```
canWatch = isSignedIn && notificationsPermitted && contentLimit(PANE) >= 4    ← latched at construction
row 4    present iff canWatch
action 2 present iff canWatch                        ← no ledger term (F-B); no availability term (F1)
```

`notificationsPermitted` is in the gate because a watch the driver will never be told about is exactly the "promise the system cannot keep" failure, and the car screen can neither ask for the permission nor explain its absence. Silent omission is the same rule already settled for the signed-out case — and it is precisely why granting the permission is an explicit step of ticket 20's demo script (M-E, §13).

**The button's title is the constant `Bay alert`, in v1, by default.** This was v2's §8.3 contingency, held in reserve against a ticket 27 finding. It is promoted to the default because the contingency was the only thing that made the toggle *provably* free, and F-B showed that "probably free, bounded by headroom" is not a bound at all. The consequences are all subtractive: **R1 retires, the two-unit headroom retires, compromise 10 retires, and inference 1 retires.** The design now carries no inference about how the host diffs actions, because it never changes one.

**Why a noun on the button, and how a driver reads it.** `Bay alert` sits beside `Directions` — both are nouns naming the thing the button is about, which is already this surface's idiom. Row 4, directly above, is titled `Bay alert` too and states the current state; the button acts on the row it is named after. Only the *watching* state spells out the reverse direction, because it is the only state where the next press destroys something the driver asked for.

**Every watch outcome is a row-4 text change and nothing else.** No alert, no message template, no extra screen, no template cost:

| State | text 1 | text 2 |
|---|---|---|
| idle, armable | `Not watching` | `One alert, next 2 hours · any plug` |
| op written, unconfirmed | `Alert requested` | `Waiting for confirmation` |
| server confirmed | `Watching · until 14:05` | `One alert, then it ends · Bay alert stops it` |
| refused — a bay is already free | `A bay is free now` | `No alert needed yet` |
| refused — 3 already armed | `3 alerts already running` | `Stop one to add another` |
| write failing | `Couldn't set the alert` | `Retrying · expires in 2 hours` |
| fired while the pane is open | `Alert sent · a bay is free` | `One alert, next 2 hours · any plug` |

Two of those rows are **refusals with a reason**, and they are the deliberate, narrow amendment this design asks of ticket 30. Ticket 30 §3 says *"arming is only offered when the watched set is not already Free"*; honouring that as a rule about the affordance's **presence** would make the action appear and disappear as reports land, which is F1. So it is honoured as a rule about the **outcome**: the affordance is always offered to a `canWatch` driver, and the arm is refused, locally and instantly, with the reason in row 4. **Routed to ticket 30 as a one-line amendment.**

**What the arm sends.** The op record carries the device-local profile's connector types when a profile exists, and an empty list (= all types, ticket 30's default) otherwise. Row 4's text 2 says which — `· any plug` or `· GB/T only` — so the driver can see what will wake them. Changing the local profile afterwards does **not** change an already-armed watch: the server holds what was sent, and silently re-scoping a live errand would be worse than the inconsistency.

**Anonymous drivers are told nothing about the feature.** No "sign in to get alerts", no disabled control. CarPlay guideline 2 forbids instructing phone manipulation and the settled reading is that silent omission is the safe form; carrying it to Android keeps one design at the cost of a discoverability loss on a platform that would have permitted the message (`VI-1`). **[inferred, and flagged as a compromise — §12.]**

### 8.3 What the constant title costs, and what it buys

Recorded as a trade rather than a footnote, because it reverses v2's default:

- **Cost.** Ticket 30's authored label `Notify me when a bay frees up` never reaches the Android car screen; it survives on the phone. A driver who has never used the feature learns what the button does from row 4 rather than from the button. On a host that renders one text line per pane row, `· Bay alert stops it` is the tail that drops, so the reverse direction can be invisible — the state (`Watching · until 14:05`) never is.
- **Buys.** The only unbounded interaction on the surface becomes provably free under a documented clause; R1, the headroom rule, compromise 10 and inference 1 all disappear; Proof 2's peak stops depending on how many times the driver presses anything; and the CarPlay twin can adopt the same 9-character label inside its own 16-character budget, which is the reconciliation §3.9 item 10 proposes to ticket 30.

**If ticket 27 finds that an action-title change is free after all**, nothing here changes. A verified-free toggle would buy back the authored label and nothing else, and the design would still refuse to make an unbounded interaction depend on an undocumented diff. This is no longer a conditional.

### 8.4 The write path — the car layer holds no credential

Arming a watch is a user-scoped, authenticated write, and car constraint 9 says the car surface reads only non-sensitive directory + availability data.

```
   :car process                              main process
   ─────────────                             ────────────
   WatchOpWriter.append(op)  ──► car-ops.jsonl ──►  OpDrainer
     {opId, stationId, types[], op, armedAt}         reads, POSTs with the session token,
     append-only, single writer                      truncates on success,
                                                     writes the confirmed set into the
   CarCacheReader.read()  ◄──  car-snapshot.db ◄──   next snapshot swap
     read-only, opened by path                       (atomic rename)
```

- **No credential ever crosses into the car process.** The token stays where the phone app already keeps it (Android Keystore / `EncryptedSharedPreferences`; on the iOS twin, Keychain at `kSecAttrAccessibleAfterFirstUnlock`). Car constraint 9 is left **intact**, not amended.
- **Single writer per file.** The car process only ever appends to `car-ops.jsonl` (and writes its own `car-last.json`); the phone process only ever writes `car-snapshot.db`. There is no shared-write contention and therefore **no SQLite WAL across processes** (Android does not support WAL for multi-process access). The snapshot is replaced by writing a new file and `rename()`-ing it over — atomic, and the car process simply opens the path on each read.
- **Nothing is claimed before the ack.** Row 4 reads `Alert requested` until the confirmed set lands in a snapshot. An unsynced watch is *not* `Watching`.
- **A queued op expires client-side after 2 hours**, mirroring ADR-0007's rule for stale reports. A watch delivered three hours late would arm a two-hour errand the driver abandoned.
- **The drain must be woken.** The car process broadcasts to the main process on append; the main process drains on that broadcast, on app foreground, and on its normal sync tick. The car layer **never blocks on any of it** (`DR-1` is satisfied by the immediate `Alert requested` text). The exact wake mechanism is implementation, routed to ticket 15.

**If `android:process=":car"` proves impractical** (§9.4's fallback), the op-file hand-off survives unchanged and remains the right shape — it is what keeps the credential out of the car code path even inside one process, and it is what makes the iOS twin's design identical.

---

## 9. Cache, latency, and the process boundary

The governing rule: **no car screen has a loading state as its normal first paint.**

### 9.1 The car cache schema — raw reports, never a materialised aggregate

If the snapshot held the materialised `baysFree` / `lastReportedAt` that the domain model writes into sync payloads, the Kotlin layer could not re-apply decay (no `capturedAt` per connector), could not run stage 1 (no sibling grouping), could not run stage 2 at all (no per-connector types), and a `baysFree: 2` written at sync time would render confidently hours later.

```
station    { id, name, nameShort, ownerId, lat, lng, updatedAt }
owner      { id, displayName, markerLabel, iconRes }
bay        { id, stationId }
connector  { id, bayId, type, powerKw, voltage,
             ratePerKwhRwf, sessionFeeRwf, rateConfirmedAt }
report     { connectorId, state, source, capturedAt, sourceOnline }   -- LATEST per connector only
```

- **`report` is the render input.** One row per Connector — the derivation needs only the latest. `sourceOnline = false` yields `Unknown` immediately regardless of recency (ADR-0002's observed failure: an `OFFLINE` pedestal still publishing a full gun-status array). **This is the field that makes `No recent bay report` a lie and `No confirmed bay status` the truth** (M-D).
- The materialised aggregate may ride along in the sync payload as a **server-side convenience for the phone's list**, but it is **never** the car's render input. **Routed to ticket 19: the car sync payload must carry per-Connector latest reports.**
- Size: tens of stations × a few bays × a few connectors — a few hundred rows, kilobytes.
- **Three non-directory fields** ride alongside — the count is three, not two as v2's prose said (m-F): `isSignedIn: Boolean`, `notificationsPermitted: Boolean`, and `armedWatches: [(stationId, expiresAt)]`, at most three entries. **No user id, no email, no display name, and never the push token** (ticket 30 §5 is explicit). Station ids are public data and the booleans are not identifying. **Flagged, not smuggled — routed to ticket 19.**
- **`car-last.json`** — one line, `{ stationId, viewedAt }`, written by the `:car` process on every detail push. This is what satisfies `EP-2` (m-J): v2 held the last-viewed station in the `Session` object, which does not survive the host closing the app, so a relaunch from the car home screen — the exact scenario `EP-2` names — would have dumped the driver at the list. It is also `QuotaGuard`'s source for `Directions to <station>` (R2).

**Fixture obligations** on the shared corpus (§9.4), owned by `packages/domain`:

- **F-A/1 — the two-stage fixture, and the one v2 was missing.** A dual-gun bay with one broken gun and one free gun, asserted under **both lenses and none**:

  ```
  B1  ├ C1  GB/T DC  Free          operator, 10 min ago
      └ C2  Type 2   OutOfService  operator,  2 days ago
  B2  └ C3  Type 2   Free          operator, 10 min ago

  stage 1   no connector on B1 or B2 is Occupied → nothing propagates
  assert    bayStateUnder(B1, ∅)        = Free            (a working gun on a free position)
  assert    bayStateUnder(B1, {GB/T DC}) = Free
  assert    bayStateUnder(B1, {Type 2})  = OutOfService    ← v2 returned Free here
  assert    bayStateUnder(B2, {Type 2})  = Free
  assert    G(unlensed)        n=2 f=2         → "All 2 bays free · operator, 10 min ago"
  assert    Q(lens GB/T DC)    n_T=1 f=1       → "The GB/T bay is free · operator, 10 min ago"
                                               + "1 other bay · Type 2 only"
  assert    Q(lens Type 2)     n_T=2 f=1 x=1   → "1 of 2 Type 2 bays free · 1 out of service
                                                  · operator, 10 min ago"
  assert    no lens ever emits a `free` count backed by a connector of another type
  ```

  The `n = 1` assertions in that block are why §3.2 carries the singular rule: v2's grammar would have emitted `1 of 1 GB/T bays free`.
- a dual-gun bay whose per-type counts would double-count if summed;
- a case whose **materialised aggregate and device-derived aggregate deliberately disagree**;
- every regime boundary of §3.2 **at every lens**, including `0 < u < n_T` with and without `OutOfService` — the lensed Regime 3 that v2's §3.6 table had no row for;
- an **offline-source override with a 30-second-old report**, asserting `Unknown` *and* asserting that no emitted string mentions report recency (M-D, rule V1);
- each decay boundary at ±1 minute.

### 9.2 What is served from cache, and what may touch the network

| Screen | Painted from |
|---|---|
| S0 row set, distances, availability, freshness | `CarCacheReader` + `AvailabilityKt` + `GrammarKt` over the local snapshot |
| S0 map, pins, panning, clustering | the **host** — EV Guide fetches no tiles at all |
| S1 every row and both actions | the same cache; a station detail is fully materialised locally |
| Marker labels, pane image | authored text and a bundled `TYPE_RESOURCE` drawable — remote URLs cannot be handed to the car in any case |

ADR-0007's **bundled directory snapshot** means even a first run with zero connectivity paints a full list, with every availability honestly in Regime 1. `DR-2` (launch ≤ 10 s) and `DR-3` (content ≤ 10 s) are met by construction, not by a fast network.

The car process performs **no network I/O at all**. `changedSince(cursor)` delta sync runs in the main process and lands as a new snapshot; the watch write is the op file. If either never completes, nothing on the surface is missing — values simply age and the decay renders them honestly.

### 9.3 The origin ladder — synchronous, total, and latched once (M-C)

`Screen.onGetTemplate()` is a synchronous main-thread call; `getLastKnownLocation` either returns immediately or returns null, so there is nothing to wait for except a fresh fix, which this design does not wait for. `onGetTemplate` reads last-known synchronously and returns on the same tick.

```
1.  Last known coarse fix        — only if the permission is already granted
                                   AND the fix is within 200 km of any station
2.  The origin persisted by the phone app  — its last known good position
3.  Kigali centroid                        — the unconditional floor
```

Rung 3 is why there is **no origin-failure screen, no empty-state screen, and no template swap**. It does four jobs at once: it handles a driver who never granted location (the car layer never asks); a driver in Kampala; **Google's reviewer in the US, who sees a populated list without needing a mock GPS app at all**; and a cold first launch before any fix exists.

**One direction, stated once and everywhere (M-C).** v2 said in §1 and §9.3 that the origin *"may improve once, never revert"*, and said in §4.1 that the title and the map anchor were latched and *"cannot change under the driver"*. Both cannot be true: the title names the origin's rung (`Charging nearby` vs `Charging in Kigali`), and **a title change is a new template, not a refresh** — so an improving origin would either silently contradict its own title or spend a quota step to restate it, and it would re-anchor a map the same section promised never to re-anchor.

> **The origin is resolved once, at Screen construction, and is constant for the life of that Screen instance. It never improves, never reverts, and never moves. The title and the anchor are constant because it is.**

A fix that arrives afterwards is not discarded — it is picked up at the **next Screen construction**, which happens on every launcher relaunch and every notification tap. Both are documented full quota resets that this design already relies on (§5.3), so the re-latch costs nothing and needs no new mechanism. The ⟳ content-refresh path re-ranks with fresher *availability* against the *same* origin.

The frame of reference is stated where it belongs — in the **template title**: `Charging nearby` on rungs 1–2, **`Charging in Kigali`** on rung 3. No sentence about permissions, no instruction to touch the phone, and `VI-1` never bites because the driver is never required to.

Two supporting rules survive: **mock providers are never rejected** (Play's reviewer-access clause requires a mock GPS app to work, and `stationsNear` takes an arbitrary origin precisely so no code path hardcodes "device location"); and rung 2 is what keeps the frozen origin from biting a real driver, since the phone app's last good position is almost always within a few kilometres of where the car connection starts.

The cost is named as compromise 8.

### 9.4 The process boundary (`DR-2`) — routed to 15 / ADR-0006

`CarAppService` starts in the app's normal process, and every Expo/RN template initialises the RN host in `MainApplication.onCreate()`. On a cold connect on a mid-range Android phone, `onGetTemplate` would return only after Hermes and the JS bundle had loaded — squarely against `DR-2`'s 10 seconds.

**The service declares `android:process=":car"`** (§2.1). Consequences, all of which belong in the ticket 15 / ADR-0006 record:

- The `:car` process never touches RN. Belt and braces: `MainApplication.onCreate()` must **branch on the process name** and skip RN initialisation for `:car`, because a future library could pull it in transitively.
- The car layer is **pure Kotlin over a native-readable projection of the cache** (§9.1), which means the ADR-0008 derivation exists a **third time** — server (TypeScript), device (TypeScript), and now car (Kotlin). ADR-0008's guarantee is *"run identically on server and device"*; this adds an implementation that can drift.
- **Mitigation, not elimination:** one shared fixture corpus (§9.1's obligations) owned by `packages/domain` and executed by both the TypeScript suite and the Kotlin suite. Same for `GrammarKt` — the total grammar of §3 is a pure function of `(n, f, o, x, u, source, age, lens)` and is fixture-shared identically, and §3.8's vocabulary is a table in the same package rather than string literals in Kotlin. **This is a real cost and belongs in the ticket 15 / ADR-0006 record, not in a code comment.**
- **Fallback if `:car` proves impractical:** gate RN initialisation on a non-car entry point in the same process. §8.4's op-file write survives unchanged either way.

---

## 10. Markers, images, and `IU-1`

`IU-1` permits **no images except** a single static context image, navigation-drawer icons, images that aid driving decisions, and lane/junction guidance.

**The surface carries exactly one image, and it is on the pane.**

```kotlin
// map marker — label only, no icon, no colour
val marker = PlaceMarker.Builder()
    .apply { owner.markerLabel?.takeIf { it.length in 1..3 }?.let { setLabel(it) } }
    .build()

// the single static context image, on the detail pane only
Pane.Builder()
    .setImage(CarIcon.Builder(
        IconCompat.createWithResource(ctx, owner.iconRes)).build())   // TYPE_RESOURCE, monochrome
```

- **`PlaceMarker.MAX_LABEL_LENGTH = 3`, and `setLabel` throws above it.** A four-character label is not a layout bug, it is a **crash on the car screen**. Spans in the label are ignored.
- **The label is authored on `Owner`, never derived.** "Kabisa – SP Remera" has no mechanical three-character abbreviation, and the names that break a derivation are exactly the ones nobody tests ("e-Mobility Rwanda Ltd" → "E-M").
- **No `setColor` anywhere.** Colour on a marker is a channel that can disagree with the text, and six differently-coloured pins invite reading colour as state. Host default styling only.
- **One asset, both modes.** Android Auto uses a **black background across day and night**; a single light-on-black monochrome mark is correct in both, so no `-night` qualifier and no assumption about how `CarContext` resolves resources is needed. Day ⇄ night costs zero templates because nothing is re-emitted (§5.2 #12). Authored ≥ 36 dp effective (the UX minimum for map imagery), contrast-checked at 4.5:1 against black (`VD-1`). **[verify: confirm the ground is black in day mode on the test head unit — it is the one thing this simplification rests on.]**

### 10.1 When the label is missing

Defence in depth, three layers, and **no layer ever invents one**:

1. **Schema** — `CHECK (char_length(marker_label) BETWEEN 1 AND 3)`, `NOT NULL`, on `Owner`. An Owner without a label cannot exist, so a Station (exactly one Owner, `NOT NULL`) always has one.
2. **Sync payload** — the writer validates; a malformed label is **dropped from the payload**, never clamped into something misleading, and never causes the station to be dropped (a station missing a pin label is still a complete listing).
3. **Runtime** — `takeIf { it.length in 1..3 }`; on failure `setLabel` is simply not called. The documented behaviour of a null label is that **the host picks its own scheme** (typically indices), which is a graceful and genuinely useful fallback.

**Open tension [verify]:** host default numeric labels give an unambiguous row↔pin correspondence that `KAB` repeated four times does not. The settled decision puts `Owner.markerLabel` in that slot and this design honours it; if the DHU shows correspondence is genuinely lost with six same-Owner pins on screen, the fallback is to pass `null` and let Owner ride on the pane image alone. That is a ticket-27 finding, not a change to make blind.

---

## 11. Constraint → satisfaction

| Constraint | How this design satisfies it |
|---|---|
| `CHARGING` category deprecated | `androidx.car.app.category.POI` only; `CHARGING` never appears |
| Declare `MAP_TEMPLATES`, not `NAVIGATION_TEMPLATES` | §2.1 manifest, with each element under its correct parent; `NavigationTemplate` never constructed |
| Library ≥ `1.7.0-rc01` | pinned; permission dialogs correct on Android 14+ |
| `PlaceListMapTemplate` is POI-only; `NavigationTemplate` forbidden to POI | root uses the POI-exclusive template; no navigation template exists in the code |
| Row ≤ 2 text lines | title + text 1 + **expendable** text 2; everything load-bearing survives at one text line |
| No `Toggle` in a place-list row | the alert is a `PaneTemplate` action, not a row toggle |
| Row may not have both an image and a marker | rows carry `Metadata(Place(marker))` and **never** `setImage` |
| `IMAGE_TYPE_LARGE` forbidden in the place list | no row images at all |
| `ItemList` not selectable | rows are click-through to detail; no selection group |
| **Every non-browsable row must carry a `DistanceSpan`** | span on the row **title**, on every row, always |
| Every row must have an action | every row pushes `StationScreen`; no information-only rows |
| `setCurrentLocationEnabled` needs location permission | **guarded** on `checkSelfPermission`, latched; the screen is fully functional without it (§9.3) |
| `CONTENT_LIMIT_TYPE_PLACE_LIST` floor **6** | queried at runtime, capped at 12, **designed at 6**; N is latched and the radius widens rather than the count shrinking |
| `CONTENT_LIMIT_TYPE_PANE` floor **4** | `min(limit, 4)` rows emitted, latched, ordered load-bearing-first; below the floor the alert row **and its button** are both absent (§4.3) |
| Items past a content limit are silently ignored | never relied on — the pane sends what the host will render (m-I) |
| `Row.setTitle` accepts only Distance/Duration spans | the only span used anywhere is `DistanceSpan`, in a title |
| ActionStrip titles accept no spans | no ActionStrip anywhere on the surface |
| `PlaceMarker.MAX_LABEL_LENGTH = 3`, throws above | §10.1's three-layer guard; label authored on `Owner`, never derived |
| `setColor` illegal with `TYPE_IMAGE`; marker sizes 64/72 dp | markers are **label-only** — no icon, no image, no `setColor` |
| No documented character limits; use `CarText` variants | variants (longest → shortest) on every row text; titles single-variant so the refresh diff stays stable; authored `nameShort`, never mechanical truncation |
| 120-char glanceability guidance | **longest authored string on the surface is 81 characters** — the lensed Regime 3 clause `1 GB/T DC bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago`, whose shortest variant is 37. The longest **unlensed** string is 73; the longest **fixed** string is `QuotaGuard`'s 51-character message. (v2 claimed 73 as the maximum, which was true only because its lens grammar had no Regime 3 row — the F-A fix adds the case and the honest recount adds 8 characters.) |
| `CarIconConstraints`: no `TYPE_URI` | the one icon is `TYPE_RESOURCE`, bundled; Owner is a bounded enumerable set, which is why this is possible |
| `IU-1` — no images except one static context image | **exactly one image on the entire surface**: the Owner mark on the pane. Markers carry text only. `Photo` never reaches a car surface. |
| `SA-1` — no animated elements | nothing animates; no spinner, no pulsing "live" dot, no availability transition |
| `ST-1` — no auto-scrolling text | overlong names are handled by `nameShort` + variants, never by marquee |
| `ActionsConstraints`: `BODY` 2, `ROW` 2 | 2 pane actions max (`Directions`, `Bay alert`); zero row actions on the place list |
| `MessageTemplate` ActionStrip max 2, one titled | `QuotaGuard` carries one body action and no ActionStrip |
| **5-template quota**, host closes the app on exhaustion | §5.6: peak **3/5** required, **5/5** adversarial, **6 unreachable for any number of watch taps** (F-B) |
| 5th template must be Pane/Message/SignIn/LongMessage | every 5th template emitted is a `PaneTemplate` or `QuotaGuard`'s `MessageTemplate`; **R2 forbids emitting a place list at ledger ≥ 4** |
| Refresh rules (title + row count + row titles; spans excluded) | **Invariant A**: no row or action count varies with runtime state; every row title and **both action titles** are constants; volatile values live in spans and text only |
| Content-refresh listener exception | the host's ⟳ is the only path that re-ranks the row set, and it is documented free |
| Adaptive task limits unreliable | probed, never depended on; the design assumes `false` |
| Throttling, no published interval | no periodic invalidation at all — repaints are event-driven off cache changes |
| 8-second dwell before auto-transition | nothing auto-transitions; every transition is a tap or an intent |
| Screen stack cap 5 | maximum depth 2 |
| Task flow ≤5 steps, SHOULD 2–3, ≤3 taps, must not end on a list | 2 taps to directions; the deepest template is always a Pane or a Message |
| `PF-1` — meaningful functionality relevant to driving | ranked live availability with source and freshness · anonymous one-tap directions hand-off · bay-watch alert. **All three are visible to a reviewer only if ticket 20's demo script signs in *and* grants notification permission on the phone** (M-E, §13) |
| `PC-1` — no features outside the app type | no saving, no reporting, no settings, no profile editing, no photos on the car surface |
| `EP-1` — works as listed | the Play listing describes exactly these three functions |
| `EP-2` — restores state on relaunch | the last-viewed `stationId` is persisted in `car-last.json` by the `:car` process and survives process death; relaunch re-seeds `[Nearby, Station]` (m-J) |
| `AR-1` — not obstructed by bars/cutouts | host-drawn templates; EV Guide never lays out pixels |
| `AD-1` / `NA-1` — no ads | none, ever; no payments and no monetisation exist in the product |
| `IN-1` — notifications relevant to the driver | one notification type, fired only on a report-driven transition into `Free`, only for a station the driver asked about within 2 h |
| `VI-1` — safety message when the phone is needed | **vacuous by design**: the car layer never requests a permission and never requires the phone (§2.1, §9.3). No such string exists to get wrong. |
| `DR-1` ≤ 2 s | every tap is local: push a cached Pane, fire an Intent, or append an op line and flip a row's text |
| `DR-2` ≤ 10 s | `:car` process with no RN host (§9.4), bundled snapshot, **synchronous** origin read (§9.3), no network on the paint path |
| `DR-3` ≤ 10 s | first paint is from cache and is always a populated list; delta sync lands behind it as a free refresh |
| `VD-1` — 4.5:1 contrast | the host renders all text; the single Owner asset is contrast-checked against Android Auto's black ground |
| `TH-1` — light/dark on 1.9+ | no custom theme is set; the single monochrome asset serves both modes |
| `MR-1` — apps drawing maps honour host light/dark | not applicable — EV Guide draws no map (§0) |
| `PA-1` — purchase constraints | no payments, permanently |
| `AC-1` — tasks in ≤ 5 screens | 2 screens, 2 taps |
| Reviewer outside Rwanda / mock GPS obligation | mock providers accepted; `stationsNear` takes an arbitrary origin; **and the Kigali rung means the reviewer sees a populated list with no mock GPS at all** |
| Car EV APIs usually `STATUS_UNIMPLEMENTED` | `EnergyProfile` is one of three profile sources and the surface is fully functional with none of them; never persist a platform integer |
| `ACTION_NAVIGATE` grammar; `SecurityException` on explicit component | `geo:lat,lng` via `startCarApp`, no component, no package name |
| POI apps SHOULD offer a nav hand-off | `Directions` is the primary action on every station. **The hand-off is the guarantee; the receiver's identity and whether it appears on the car display are ticket 27's, and nothing here assumes them** (ADR-0004, §8.1) |
| Templated apps cannot be sideloaded | test loop is DHU + Internal App Sharing / Internal track |
| Play form-factor opt-in; blocking review on open/production | Android Auto form factor added; closed track first (non-blocking review) before open/production |
| Addendum kill switch | nothing in the product is load-bearing on the car surface — the phone app is complete without it |

---

## 12. Forced compromises

1. **No identity on screen.** One bundled Owner mark on the detail pane is the entire visual surface. EV Guide's design system does not appear on Android Auto. Declining `MapWithContentTemplate` deepens this deliberately in exchange for §0's four removals.
2. **No reporting from the car.** Settled by ticket 23, and structurally right: a report is per-Connector, so a one-tap car report would have to invent a station-level write the model does not have, and a connector picker is two more templates of data entry while driving. The cost is real — a driver who arrives to find every bay taken is at the single best reporting moment and cannot act on it.
3. **No saving, no favourites, no profile editing on the car.** All user-scoped, all outside car constraint 9.
4. **The cache gains three non-directory fields** (`isSignedIn`, `notificationsPermitted`, `armedWatches`) plus `car-last.json`. An acknowledged extension of car constraint 9 (§9.1). The credential is **not** among them (§8.4).
5. **A third implementation of the ADR-0008 derivation, plus a second of the grammar and the vocabulary** (§9.4). Divergence risk, mitigated by shared fixtures, not eliminated.
6. **"Free for me" is a qualified aggregate, never a filter.** Per-connector state cannot fit a two-line row, so the driver's plug changes the *wording* only, and only one side of the partition is ever counted (§3.6). A driver whose profile EV Guide does not know sees a station-wide count that may be true for someone else's car.
7. **The marker cannot say which station.** `markerLabel` is on `Owner`, so four Kabisa sites show four `KAB` pins; row↔pin correspondence rests on position and host highlighting.
8. **The list *and its origin* are frozen for the Screen instance** (M-C). A station that frees up 200 m away does not enter the list until the driver taps ⟳; and a location fix that arrives after first paint does not move the frame of reference at all until the next intent — so a driver who connects the car before the phone has a fix may browse a Kigali-anchored list for the rest of that screen's life. Quota, not preference: a moving origin means a moving title, and a title change is a new template. Rung 2 keeps this rare, and the documented reset (relaunch from the car home screen, or a bay alert firing) is the fix.
9. **Distance is unlabelled on Android.** CarPlay says `~2.4 km straight line`; Android hands the host a `Distance` and the host renders it bare. `Row.setTitle` takes only Distance/Duration spans and the literal residue must stay constant for the refresh diff, so the qualifier cannot ride there — and the pane's four rows are all spent, so it cannot ride there either. The number is straight-line on both platforms; only one of them can say so (§3.9 item 9).
10. **~~The bay-alert button can be absent on a deep visit.~~ Retired by F-B.** The button is present for every `canWatch` driver at every ledger value, including 5/5, because the toggle is a documented refresh.
11. **Two distinct rates fit the pane; three collapse** to `From 400 RWF/kWh · 3 rates` with the unknown remainder stated (§3.5).
12. **Ticket 30's authored button label does not reach the Android car screen** (§8.3). `Bay alert` is what the driver reads; the sentence label survives on the phone.
13. **Anonymous drivers never learn the bay alert exists.** Silence is Apple's rule carried across for one design; Android would have permitted a message.
14. **Android Auto is not available in Rwanda.** This entire surface serves no current EV Guide user. It is built for a market the product does not yet serve, and that reasoning belongs in ticket 24's scope call, not in this design.

---

## 13. Inferences, and the open questions in priority order

**Inferences carried in this design** — none is a documented rule, and none may be quoted to a reviewer:

| # | Inference | Where it bites | If it is wrong |
|---|---|---|---|
| 1 | ~~An action-title change inside an otherwise-identical template is still a refresh~~ | **RETIRED (F-B).** No action title ever changes; §5.2 #7 is a documented refresh, not an inference | — |
| 2 | The refresh diff is per-screen, not per-host-session | §5.2 #8 — costed as +1 in both proofs anyway | nothing; the proofs already assume it |
| 3 | `ScreenManager` requests only the top screen's template when a stack is seeded | §5.3 — otherwise a notification deep link costs 2, not 1 | post-reset ledger is 2/5 instead of 1/5; still fine |
| 4 | `setOnContentRefreshListener`'s real `@RequiresCarApi` level | §4.1's guard; the free re-rank path | compromise 8 deepens: the list is frozen for the connection, relaunch is the re-rank |
| 5 | `CarAppExtender` / `CarNotificationManager` is the car-notification mechanism, and a POI app's notification is surfaced in the car at all | §4.5 — **and ticket 23's three-function answer** | **blocking — see below** |
| 6 | A device-local vehicle profile needs no account (ADR-0003 gates *sync*) | §7.1's anonymous "free for me" | grammar Q becomes signed-in-only; grammar G is complete without it |
| 7 | `HostValidator` allowlist boilerplate | §2.4 | standard, unverified against the research |
| 8 | 200 km reachability threshold on origin rung 1 | §9.3 | a design call, routed to 19 |

*"Going back refunds the quota, by the number of templates popped"* is documented **[hard]**, not an inference; the residual is whether "templates popped" counts a screen that emitted several — which our screens never do on the counted path.

**Ticket 27's DHU session, in priority order** (v2's item 3 — *"does an action-title change consume a template step?"* — is **struck**, because no action title changes any more; the list is renumbered, m-N):

| # | Question | Status |
|---|---|---|
| **1** | **Are a POI app's notifications surfaced on the Android Auto screen at all?** Does `CarAppExtender` + `CarNotificationManager` deliver, and is `IMPORTANCE_HIGH` heads-up permitted for a POI category (historically reserved to messaging and navigation)? | **BLOCKING.** It decides whether ticket 23's three-function `PF-1` answer holds on Android. If POI notifications are filtered, the Android case reduces to two functions and **ticket 23's resolution must be revisited — before ticket 20 files, not at submission.** |
| **2** | Does `ACTION_NAVIGATE` reach a navigation app on a real host, is that app Google Maps, and does it appear **on the car display** or on the phone? | Critical path. ADR-0004 forbids assuming any of the three; the design guarantees only the hand-off (§8.1) |
| 3 | Confirm a `PaneTemplate` whose **row texts alone** change is treated as a refresh, by arming and disarming the watch ten times at a known ledger depth and checking the app is not closed | Confirms F-B's fix against the host rather than against the javadoc. **Cheap, and it is now the single most load-bearing check on the quota model** |
| 4 | Is the refresh diff per-screen? Push detail, pop, and check whether the identical re-emitted place list consumes a step | Decides whether Proof 1 peaks at 2 or 3 |
| 5 | Does the back-refund equal the templates popped? Walk six push/pop cycles and confirm the `QuotaGuard` branch is unreachable | Confirms R2 is dead code in practice |
| 6 | Real `@RequiresCarApi` level of `setOnContentRefreshListener`; and does the host draw the ⟳ affordance? | Decides compromise 8's depth |
| 7 | Does `PlaceListMapTemplate` render two text lines while driving, or one? | Decides whether text 2 is ever seen |
| 8 | Does `startCarApp` accept `geo:0,0?q=<lat>,<lng>(<name>)`? | Adopt if yes, keep bare coordinates and record why if no |
| 9 | Real `CONTENT_LIMIT_TYPE_PLACE_LIST` and `…PANE` values on the DHU and on any reachable head unit | Confirms the 6 / 4 floors — and §4.3's `contentLimit(PANE) >= 4` term |
| 10 | Is the ground black in **day** mode on the test head unit? | The one thing §10's single-asset simplification rests on |
| 11 | Is row↔pin correspondence usable with six same-Owner `KAB` labels? | §10.1's fallback to `null` labels |
| 12 | `PlaceListMapTemplate`'s ActionStrip constraint — `SIMPLE` (2) or `MAP` (4)? | Headroom only; the design uses none |

**Pre-submission tasks that are not DHU questions:**

- Grep the pinned `androidx.car.app:1.7.0-rc01` artifact for a `@Deprecated` annotation on `PlaceListMapTemplate` (§0). One command, before this design is called final.
- **Routed to ticket 20 as hard submission dependencies — three steps, in this order, and the third is new (M-E):**
  1. **Sign in on the phone**, before connecting to the head unit. Supply the demo account in Play Console → App access and in Apple's review notes. The car screen still never shows a wall; the state is simply already true.
  2. **Grant the notification permission on the phone** — `POST_NOTIFICATIONS` on Android 13+, and confirm the `ev_guide_bay_alerts` channel is enabled — **before connecting.** `canWatch` includes `notificationsPermitted` (§8.2) and the car surface *silently omits* the affordance when it is false, by design. A reviewer who skips this step sees **no bay-alert row and no bay-alert button**, and the third `PF-1` function is invisible with no explanation anywhere on the surface — the failure mode is indistinguishable from the feature not existing. This step must be written into the demo script as its own numbered line, not folded into "sign in".
  3. **Seed the demo path with reports**, including one scheduled to flip a watched connector into `Free` while the reviewer is on the station pane, so the availability layer is *populated* rather than uniformly Regime 1 and the alert is *seen to fire*. Without it, a reviewer applying `PF-1` sees a static map, six rows of name + distance + capacity, and one `Directions` button — precisely *"a list of EV chargers"*.

  The Kigali origin rung already removes the mock-GPS dependency; these three remove the "two of three functions are invisible" problem.

**Routed back to ticket 19 / `docs/domain-model.md` before the schema locks:**

- **One derivation, two stages, one lens parameter** (§3.1): `effective(connector, now)` → `occupancyAdjusted(connector, now)` (ADR-0008 propagation, lens-independent) → **`bayStateUnder(bay, T?, now)`**, whose `T = ∅` case *is* the unlensed bay state. Named beside decay and propagation. **This supersedes both v2's unlensed `bayState` roll-up and the CarPlay design's separate `freeBaysOffering(T)` rule** — see the next item.
- **The per-type projections, defined *from* that function, non-additively:** `baysOffering(T)` (bays carrying ≥1 Connector of type `T`), and **`freeBaysOffering(T) = #{ b : bayStateUnder(b, T, now) = Free }`**. The CarPlay design's definition (unlensed `Free` **and** ∃ a `T` connector not `OutOfService`) must not also ship: it asserts *free for me* from a report about a different gun. **Two contradictory specs of one pure function is exactly what this routing exists to prevent** (§3.9 item 2).
- **The total grammar** (§3) belongs in `packages/domain` as pure functions — `G(n,f,o,x,u)`, `R(rates)`, `Q(lens)`, and the freshness clause — each returning an ordered variant list, plus §3.8's **closed vocabulary as data**, so neither the Kotlin nor the Swift transcription invents a word.
- **The freshness function returns structure, not a word**: `(contributingSources: Set, oldestContributingCapturedAt)`, contributors excluding `OutOfService`. `mixed`/weakest-collapse is a rendering decision per surface (§3.9 item 5).
- **Rate coverage is denominated in plugs**: `rateCoverage(station) = (confirmedPlugs, totalPlugs, distinctRates[], oldestConfirmedAt)`. The CarPlay design's bay denominator is a category error and must change (§3.9 item 6).
- **Android slot typing** for the two-line projection: `rowTitle` (`nameShort` + distance span), `rowPrimaryText` (grammar G/Q + freshness, or capacity in Regime 1), `rowSecondaryText` (droppable); and the two-line projection takes an optional `viewerConnectorTypes` parameter.
- **A fixed pane-rows projection** (label/value pairs). Android's detail screen has no projection today; `card-triple` is CarPlay's.
- **The connector type-word mapping** (`IEC_62196_T2` → `Type 2`, `IEC_62196_T2_COMBO` → `CCS2`, `GBT_AC`/`GBT_DC` → `GB/T AC`/`GB/T DC`, `OTHER`/`UNKNOWN` → `Other plug`) as one projection both car surfaces read.
- **The car cache schema** carries per-Connector latest reports, never a materialised aggregate (§9.1) — and the car sync payload must too.
- **The car cache carries `isSignedIn`, `notificationsPermitted`, `armedWatches`** — three fields, an amendment to car constraint 9, and explicitly **not** a credential.
- **No reserved compatibility slot** in `stationsNear`; ranking stays total (§6).
- The one-line ruling from ticket 12 on whether a *local* vehicle profile is account-gated.
- The 200 km reachability threshold on origin rung 1 (inference 8) is a design call to confirm or set.

**Routed to ticket 30:** the arm affordance is always offered to a `canWatch` driver, and "already Free" / "3 already armed" are **refusals with a reason in row 4**, not absences of the button (§8.2). Plus `notificationsPermitted` joins `isSignedIn` in the gate. Plus **one label amendment naming three surfaces, not two**: phone keeps `Notify me when a bay frees up`; Android Auto ships the constant `Bay alert` (§8.3); CarPlay ships `Notify when free` today and **should adopt `Bay alert` too** (9 characters, inside its 16-character budget) so one product does not carry three names for one button (§3.9 item 10).

**Routed to ticket 15 / ADR-0006:** `android:process=":car"`, the RN-initialisation branch, the op-file / snapshot-swap seam, `car-last.json`, and the third implementation of the derivation with its shared fixture corpus (§8.4, §9.4).

**Routed to ticket 20:** the three-step demo script above; the script arms **and disarms** the watch on the first detail visit, which is now safe at any depth.

**Routed to the CarPlay/Android crosscheck:** §3.9 in full. Items 2 and 6 are domain-layer and block ticket 19; items 3, 8 and 10 are one-word changes recommended to the twin; the rest may differ per platform.

---

## 14. Answers to the round-2 verdict

### Fatal

**F-A — grammar Q asserts a bay is free for the driver's plug when that bay's gun of that type is `OutOfService`.** **Accepted in full; fixed structurally, not by wording.** §3.1 now specifies a **two-stage derivation**: stage 1 propagates occupancy across all sibling connectors (physical, lens-independent, unchanged from ADR-0008); stage 2, **`bayStateUnder(bay, T?, now)`**, rolls the bay up over **only the bay's `T`-offering connectors**. The unlensed state is the `T = ∅` case of the same function, so there is one roll-up, not two, and a lensed count can never be inherited from an unlensed one. §3.6 is rewritten on top of it: all three regimes apply *under the lens* with `n_T` as the total (v2 had no lensed Regime 3 row at all, so a driver with half-known bays fell through to the station-wide clause). The justification is written down so the two stages are not collapsed again by a future editor: **a parked car blocks every gun on the position, so occupancy must cross the type boundary; a broken gun says nothing about its neighbour, so brokenness must not.** The missing fixture is added as **F-A/1** (§9.1) — dual-gun bay, one gun `OutOfService`, one gun `Free`, asserted under **both lenses and none**, plus the `n = 1` strings that fixture exposed (§3.2's singular rule replaces `1 of 1 bays free` and `All 1 bays busy`). The lensed roll-up is routed to ticket 19 **beside `baysOffering(T)`**, with `freeBaysOffering(T)` redefined in terms of it and the CarPlay design's competing definition explicitly superseded (§3.9 item 2, §13).

**F-B — nothing bounds arm/disarm toggles.** **Accepted in full.** v2's R4 priced each toggle at +1, R1 budgeted exactly two units of headroom, and nothing at all bounded the number of taps: from a Pane constructed at R1's permitted maximum, `arm → disarm → arm` emitted a **6th template** and the host closed the app mid-drive, on the third press of a button the design placed on screen unconditionally. **§8.3 is promoted from contingency to the v1 default:** action 2's title is the constant **`Bay alert`**, and arm/disarm is a **pure row-4 text change**. The documented `PaneTemplate` refresh clause is *title unchanged and row count and row titles unchanged*; with the action titles constant, an arm or a disarm changes nothing outside that clause, so it is a **documented refresh [hard]**, free, and free for an **unbounded** number of taps at any ledger value. Consequently **R1 retires, the two-unit headroom retires, compromise 10 retires, and inference 1 retires** (§5.4, §12, §13). The proofs are re-run in §5.6 and §15, and — for the first time in any version — **both model a disarm**, including an arm-then-disarm at the 5/5 ceiling, which is the exact sentence the fix exists to make true. Ticket 27 gains a cheap confirmation item (DHU #3) that replaces v2's blocking one.

### Major

**M-C — the origin's "may improve once" contradicts the latched title and map anchor.** **Accepted; one direction chosen and applied everywhere.** The direction is: **the origin is resolved once at Screen construction and is constant for the life of that Screen instance — it never improves, never reverts, never moves.** A moving origin would move the title (`Charging nearby` ⇄ `Charging in Kigali`), and a title change is a *new template*, not a refresh; it would also re-anchor a map §4.1 promised never to re-anchor. Changed in §1's latch table, §4.1's `setTitle` and `setAnchor` rows, §5.2 (no origin transition exists), §9.3 (the rule stated in full with its reasoning), and §12 compromise 8 (which now names the frozen origin as well as the frozen list). A late fix is not discarded: it is picked up at the next Screen construction, which happens on every launcher relaunch and every notification tap — both already load-bearing documented quota resets, so the re-latch needs no new mechanism.

**M-D — `No recent bay report` is false under the offline-source override.** **Accepted.** ADR-0002's override yields `Unknown` the instant a source declares itself offline, **however fresh its report is** — the observed failure was an `OFFLINE` pedestal still publishing a full gun-status array. A thirty-second-old report therefore renders as `Unknown`, and a string claiming no recent report was a false statement about EV Guide's own data. Replaced with **`No confirmed bay status`** (§4.4), which states knowledge rather than report history and matches `No confirmed rate` one row below it. Generalised into **vocabulary rule V1** (§3.8): *a word may state EV Guide's knowledge; no word may state report history.* That rule also strikes `not reported`, `unreported` and `no recent report` from the surface permanently, adds a fixture asserting it (§9.1: offline override with a 30-second-old report), and — because the CarPlay design uses `unreported` as its count word for `u` — is routed to the crosscheck as §3.9 item 3.

**M-E — the notification-permission prompt is invisible in ticket 20's demo script.** **Accepted.** `canWatch = isSignedIn && notificationsPermitted && contentLimit(PANE) >= 4`, and when it is false the car surface **silently omits** the row and the button — deliberately, because the car screen may neither request the permission nor explain its absence. The consequence is that a reviewer who signs in but never granted `POST_NOTIFICATIONS` sees a surface on which one of ticket 23's three `PF-1` functions does not exist, with nothing on screen to say why. It is now an **explicit, separately numbered step of ticket 20's demo script** (§13): (1) sign in on the phone, (2) **grant the notification permission and confirm the `ev_guide_bay_alerts` channel is enabled**, (3) seed the demo path with reports including one that flips a watched connector to `Free` while the reviewer is on the pane. Stated a second time in §2.1, where the "the car layer never requests a runtime permission" rule creates the exposure.

### Minor

**m-F — miscount in §9.1.** v2's prose said *"Two non-directory fields ride alongside"* and then listed **three** (`isSignedIn`, `notificationsPermitted`, `armedWatches`); §12 said three. Corrected to three in §9.1, and the routing to ticket 19 says three.

**m-G — cross-reference errors.** v2's header said *"Every defect is answered in §15; §16 summarises what moved"*, but the answers were in §14 and §15 was the quota proof; and §3.7's exception pointed at §4.3 for a string that lives in §4.4. Both corrected here, and §14/§15/§16 keep the roles v2's body actually used.

**m-H — an age form outside the age vocabulary.** §4.3's pane rendered `out of service 3 d`, while §3.3's age words are `just now / {n} min ago / {n} h ago / {n} days ago`. `3 d` appears nowhere else on the surface and is a two-character saving on the one line with room. Now `out of service 3 days`, and §3.8 pins the age set.

**m-I — the pane relied on silent host truncation.** v2 sent 4 rows unconditionally and observed that a host reporting 3 *"loses only the alert row"*. *Items past a content limit are silently ignored* is a documented host behaviour, not a design. The pane now emits `min(contentLimit(PANE), 4)` rows, latched. And because row 4 is the **only** state display for a constant-titled button (F-B), the button would otherwise have survived its own explanation — so `contentLimit(PANE) >= 4` joins `canWatch` and the two live and die together (§4.3, §8.2).

**m-J — `EP-2` held its state where the state does not survive.** v2 said *"the Session remembers the last-viewed `stationId` for the connection"*. `EP-2` is about **relaunch from the car home screen**, which is precisely the case where the host has torn the app down and the `Session` object is gone — so the guideline's own scenario would have dumped the driver at the list. The id is now persisted in a one-line `car-last.json` written by the `:car` process on every detail push (§9.1), which also gives `QuotaGuard`'s action a source that survives process death.

**m-K — the notification hardcoded its provenance.** v2's template read `SP Remera · operator report`, but a watch fires on a **report-driven** transition from any source, and a driver report is the common case in a market with no operator app adoption yet. Provenance is the whole confidence axis, so the body now renders `{nameShort} · {source} report` from §3.8's closed source set (§4.5).

**m-L — the manifest fragment did not say what goes where.** `<uses-permission>` is a direct child of `<manifest>` and the `minCarApiLevel` meta-data a direct child of `<application>`; v2's fragment listed both loose beside the `<service>`, which is a build failure for a reader who copies it. §2.1 is now annotated with the parent element of every line.

**m-M — `QuotaGuard`'s action presumed a station without establishing one.** Its single action is `Directions to <last-viewed station>`. §5.4 R2 now states why one always exists (reaching ledger ≥ 4 requires at least two detail pushes, so a last-viewed station is necessarily recorded first) and sources it from `car-last.json` rather than memory, so the branch cannot construct a titleless action even after a process restart.

**m-N — the ticket-27 list and the inference table outlived their fix.** v2's DHU item 3 asked *"does an action-title change consume a template step?"* and inference 1 carried the answer's risk; both are dead once F-B makes the action title constant. Item 3 is **struck** and the list renumbered; inference 1 is struck from §13's table with a line saying so; and a new, cheaper DHU item takes the slot — arm and disarm ten times at a known ledger depth and confirm the app is not closed, which tests the fix against the host rather than against the javadoc.

### Carried forward from round 1, unchanged and not relitigated

Invariant A and Invariant B; the three-regime grammar; contributors excluding `OutOfService` and the weakest-source collapse; the non-additive partition; raw per-Connector reports in the car cache; the credential-free op-file write path; `android:process=":car"`; label-only markers and the single pane image; the deleted origin-failure screen and its `VI-1` string; the deleted ranking reservation; the declined ActionStrip refresh remedy; bare `geo:` in v1 of the code; voice out of v1.

---

## 15. The 5-template quota proof, in one place

Restated so a reviewer of this document does not have to reconstruct it from §5.

**Rules used.** Max 5 templates per task; it counts templates *sent*, not `Screen` instances. The 5th must be `PaneTemplate`, `MessageTemplate`, `SignInTemplate` or `LongMessageTemplate` for a POI app. Exceeding it: *"the host displays an error message and closes the app."* Going back refunds by the number of templates popped. A notification or launcher intent is a **full reset**, even in the foreground. A `PlaceListMapTemplate` is a *refresh* when title, row count and row titles are unchanged (spans excluded) **or** when responding to `setOnContentRefreshListener`; a **`PaneTemplate` is a refresh when title, row count and row titles are unchanged** — which is the whole of the F-B fix, because row *texts* are not in that list.

**What makes the counting work.** Invariant A: the only things that vary at runtime are row **texts** and `DistanceSpan` values — and after F-B, **no action title varies either**. Neither appears in either documented diff.

| | Required session | Adversarial session |
|---|---|---|
| launch (post-reset) | PLMT **1** | PLMT **1** |
| updates, ticks, ⟳ | refresh **1** | refresh **1** |
| detail | Pane **2** | Pane **2** |
| report lands on detail | refresh **2** | refresh **2** |
| **arm watch** | **refresh 2** | **refresh 2** |
| **disarm watch** | **refresh 2** | **refresh 2** |
| **re-arm, ×k, any k** | **refresh 2** | **refresh 2** |
| back | −1 **1** | −1 **1** |
| list re-emit | +1 **2** | +1 **2** |
| detail | Pane **3** | Pane **3** |
| arm / disarm ×k | — | refresh **3** |
| back · list re-emit · detail | — | −1 **2** · +1 **3** · Pane **4** |
| arm / disarm ×k | — | refresh **4** |
| back · list re-emit · detail | — | −1 **3** · +1 **4** · Pane **5 / 5** — legal terminal |
| **arm, then disarm, at 5 / 5** | — | **refresh 5 / 5** — the ceiling is not a trap |
| back | — | −1 **4** |
| list would be the 5th | — | **R2 blocks** → `QuotaGuard` Message **5 / 5** — legal terminal |
| directions | leaves at **3 / 5** | leaves at **5 / 5** |

**Peak 3/5 required, 5/5 adversarial, 6 unreachable for any number of watch taps, every 5th template legal.** Optimistic reading (the list re-emit is a refresh): 2/5 and 4/5. Escape hatch available at every point: a notification tap or a launcher relaunch resets to 1/5 — and re-latches the origin (§9.3).

---

## 16. What changed from v2, and why

| # | Change | Driver |
|---|---|---|
| 1 | **The bay roll-up takes the lens as a parameter**: stage 1 propagates occupancy across all siblings (physical); stage 2 `bayStateUnder(bay, T?)` rolls up over **only the `T`-offering connectors**. The unlensed state is the `T = ∅` case of the same function | **F-A** — v2 rolled up over all connectors and let §3.6's type filter select a bay without re-deriving it, telling a Type 2 driver a bay was free when its only Type 2 gun was broken |
| 2 | §3.6 rewritten: all three regimes apply **under the lens** with `n_T` as the total, including the **lensed Regime 3** v2's table had no row for; the type word is the last thing the variant ladder drops | F-A |
| 3 | **Fixture F-A/1** added — dual-gun bay, one gun `OutOfService`, one gun `Free`, asserted under **both lenses and none** — plus lensed regime boundaries in the shared corpus | F-A |
| 4 | §3.2 gains the **singular rule** (`The bay is free`, no `All` at `n = 1`) and an `All N bays free` shorthand | exposed by F-A/1; v2 emitted `1 of 1 bays free` and could emit `All 1 bays busy` |
| 5 | **`bayStateUnder` is routed to ticket 19 beside `baysOffering(T)`**, with `freeBaysOffering(T)` redefined in terms of it and the CarPlay design's competing definition explicitly superseded | F-A + the cross-doc rule that ticket 19 gets one spec per pure function |
| 6 | **The bay-alert action's title is the constant `Bay alert`** and arm/disarm is a pure row-4 text change — a documented `PaneTemplate` refresh, free and unbounded. v2's §8.3 contingency becomes the v1 default | **F-B** — v2 priced each toggle at +1 and bounded only the headroom, so three taps emitted a 6th template and the host closed the app mid-drive |
| 7 | **R1 and the two-unit headroom retire; compromise 10 retires; inference 1 retires; DHU item 3 is struck and replaced** by a ten-toggle confirmation | F-B |
| 8 | Both quota proofs re-run, and **both model a disarm** — including arm-then-disarm at the 5/5 ceiling | F-B; no previous proof modelled one |
| 9 | R3 is restated as a standing prohibition: **the ledger may never shape a template**, only choose R2's template class | F-B's removal of the last ledger-derived shape |
| 10 | **The origin is latched once at Screen construction and never moves** — no improve-once. Title, anchor, §1's latch table, §5.2's transitions and compromise 8 all say only that; a late fix arrives at the next intent | **M-C** — v2 said "may improve once" in §1/§9.3 and "cannot change under the driver" in §4.1 |
| 11 | **`No recent bay report` → `No confirmed bay status`**, generalised into vocabulary rule V1 (knowledge, never report history), with a 30-second-old offline-override fixture | **M-D** — the offline override makes a fresh report render `Unknown`, so the old string was false |
| 12 | Ticket 20's demo script gains **granting the notification permission as its own numbered step**, plus a seeded report that fires the alert while the reviewer watches | **M-E** — `canWatch` includes `notificationsPermitted` and the surface omits the affordance silently, so the third `PF-1` function is otherwise invisible |
| 13 | **§3.8 — the complete closed vocabulary in one section**, with the five rules that generate it | cross-doc: the crosscheck needs one place to reconcile against |
| 14 | **§3.9 — divergences from the CarPlay design**, each classified domain-layer (must reconcile: the lensed free count, the rate denominator) or rendering-layer (may differ) | cross-doc: ticket 19 must not receive two specs of one function |
| 15 | ADR-0004 discipline restated at the top and in §8.1/§11: the **hand-off** is the guarantee; the receiver's identity and the car-display outcome are ticket 27's and are assumed nowhere | the ADR's own words, overreached in round 2 |
| 16 | §9.1 says **three** non-directory fields, not two | m-F |
| 17 | Header and §3.7 cross-references corrected | m-G |
| 18 | `out of service 3 d` → `out of service 3 days` | m-H |
| 19 | The pane emits `min(contentLimit(PANE), 4)` rows; `canWatch` gains the `>= 4` term so the button never outlives its state row | m-I |
| 20 | `EP-2`'s last-viewed station moves from the `Session` object to `car-last.json` in the `:car` process | m-J |
| 21 | The notification body renders `{source}` from the closed set instead of hardcoding `operator` | m-K |
| 22 | The manifest fragment is annotated with each line's parent element | m-L |
| 23 | `QuotaGuard`'s `Directions to …` action is sourced from `car-last.json`, with the argument that a station always exists | m-M |
| 24 | DHU list renumbered and the inference table re-cut after F-B | m-N |
| 25 | Longest authored string recounted honestly: **81**, not 73 — the lensed Regime 3 clause the F-A fix introduced | F-A's knock-on to §11's glanceability row |
