# EV Guide on Android Auto — complete template design (v2)

Ticket 18, Android half. Supersedes `02-androidauto-design-v1.md` in full; this is a standalone document, not a diff. Written against the adversarial verdict `04-androidauto-verdict-v1.md` ("does not ship as-is": 2 fatal, 11 major, 10 minor). Every defect is answered in §15; §16 summarises what moved.

Binding inputs: `00-constraint-sheet.md` (which stands in for research 04 in full), `/Users/FullTimeStudio/Dev/lab/ev-guide/docs/domain-model.md`, `/Users/FullTimeStudio/Dev/lab/ev-guide/CONTEXT.md`, ADR-0002 / 0003 (as amended) / 0004 / 0006 / 0007 / 0008, and tickets 09, 12, 19, 20, 23, 27, 30.

Marking: **[hard]** = a documented platform rule. **[inferred]** = a derivation — never quote one to a Play reviewer. **[verify]** = goes to ticket 27's DHU session. **[blocking]** = ticket 27 must answer it before ticket 20 files anything.

---

## 0. The shape of the decision, up front

Android hands a POI app two possible map surfaces. **EV Guide uses `PlaceListMapTemplate` (host-drawn map) and declines `MapWithContentTemplate` (app-drawn surface).** That single choice removes, at once:

- the whole tile pipeline from the car surface (no MapLibre on a `Surface`, no tile fetches, no basemap budget — the host draws Google's map for free),
- `MR-1` (it applies only to *apps drawing maps*),
- `AR-1` risk (system bars and cutouts are the host's problem when the host lays out),
- the largest part of the `DR-2`/`DR-3` latency risk (nothing to render, only strings to supply).

The cost: EV Guide's visual identity does not appear on Android Auto beyond one bundled Owner mark on the detail pane. That is accepted — it is the same bargain CarPlay forces unconditionally, and taking it on both platforms keeps one design.

**The entire surface has three tap targets:** a station row, `Directions`, and the bay alert. Plus the host's own back and content-refresh affordances.

**Contingency [verify — m23]:** Google deprecated `CHARGING`, `MapTemplate`, `PlaceListNavigationTemplate` and `RoutePreviewNavigationTemplate` quietly, and now positions `SectionedItemTemplate` as the successor to List and Grid. Before this design is called final, grep the pinned artifact for a `@Deprecated` annotation on `PlaceListMapTemplate`:

```
unzip -p ~/.gradle/.../androidx.car.app/app/1.7.0-rc01/app-1.7.0-rc01.aar classes.jar > /tmp/car.jar \
  && javap -cp /tmp/car.jar androidx.car.app.model.PlaceListMapTemplate | head -5
```

A deprecation would not break this design (a deprecated template still renders), but it would reopen §0's calculus about declining `MapWithContentTemplate`, and it would move the whole design onto a template Google intends to retire. That is a decision, not a lint warning.

---

## 1. The two invariants

Everything structural in this document exists to hold these two lines. They are stated first because v1 failed both.

> **INVARIANT A — count stability.** No template's **row count** or **action count** may vary with availability, freshness, watch state, rate coverage, connector count, or the driver's profile. They may vary only with facts that are **latched for the life of the template instance**: sign-in state, notification permission, host content limits, and the ledger headroom at construction. Only row **text** and action **titles** vary at runtime.
>
> **INVARIANT B — grammar totality.** Every string that describes availability, rate or freshness is emitted by a **total** function over the domain state. There is no state of the world for which the grammar falls through to a neighbouring clause. In particular: the denominator of any availability fraction is the **known** set, the word *busy* is never applied to a bay whose state is `Unknown`, and `OutOfService` is never folded into `Occupied` at any count.

Invariant A is the fix for F1 (a varying row count is a *new template*, not a refresh; at 4/5 the host closes the app mid-drive). Invariant B is the fix for F2 (v1's five-clause table had no case for mixed known-and-`Unknown`, which is the steady state, and it rendered both `Unknown` and `OutOfService` bays as "busy").

**How the latches work.** Facts that Invariant A permits to vary the shape are read **once** and held:

| Latched fact | Read when | Can it change mid-connection? |
|---|---|---|
| `isSignedIn` | `onCreateSession`, re-read only on `onNewIntent` | The phone can sign out mid-drive; the car surface deliberately does not observe it. Next intent (which **resets the quota**) picks it up. |
| `notificationsPermitted` (`POST_NOTIFICATIONS`, Android 13+) | same | same |
| `contentLimit(PLACE_LIST)`, `contentLimit(PANE)` | Screen construction | host-constant for a connection |
| `origin` | Screen construction; may **improve once**, never revert | §9.3's ladder always yields an origin, so it never goes absent |
| ledger headroom | Screen construction | §5.4's rules read it only at construction |

A Screen instance therefore knows its own shape before it emits its first template, and that shape never changes under the driver's hands.

---

## 2. Template inventory and Session / Screen structure

### 2.1 Manifest frame

```xml
<service android:name=".car.EvGuideCarAppService"
         android:exported="true"
         android:process=":car">                                <!-- M12: no RN runtime in this process -->
  <intent-filter>
    <action   android:name="androidx.car.app.CarAppService" />
    <category android:name="androidx.car.app.category.POI" />   <!-- NOT …CHARGING (deprecated 1.3.0-alpha01) -->
  </intent-filter>
</service>
<meta-data android:name="androidx.car.app.minCarApiLevel" android:value="1" />
<uses-permission android:name="androidx.car.app.MAP_TEMPLATES" />
<!-- deliberately absent: androidx.car.app.NAVIGATION_TEMPLATES -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Library floor `androidx.car.app:1.7.0-rc01` (permission dialogs correct on Android 14+, no AAOS-15 crash). `minCarApiLevel 1` with **runtime guards** on everything above it, so nothing hard-fails on an old host. Android Automotive OS is a separate artifact and stays out of scope.

**The car layer never requests a runtime permission.** Both permissions above are requested by the phone app, in its own onboarding, on the phone. This is what makes `VI-1` ("if the user must go to the phone, display a message telling them to look at it only when safe") vacuous here rather than a string we have to author: the car surface never requires the driver to go to the phone for anything, because §9.3's origin ladder always yields a usable origin and §8.2's watch affordance is simply absent when its preconditions are not already true.

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

**Voice [m20].** `VC-1` (Gemini + Assistant commands) applies to Media and Navigation only — **voice is not required of a POI app**, and EV Guide ships none in v1. Three reasons, recorded so this is a decision rather than an omission: (i) the POI guide's demonstration (*"Hey Google, find nearby charging stations on ExampleApp"*) needs App Actions / BII plumbing and a `shortcuts.xml` on the **phone** app, which is work outside the car package; (ii) Assistant's Rwanda-English coverage is unestablished and untestable from here, so the feature could not be verified before submission; (iii) CarPlay forbids voice *recording* to a charging app entirely, so a voice-first design could not be symmetric and would break the one-design rule. Revisit when the phone app ships App Actions for its own sake.

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

- **`CarCacheReader`** — reads the read-only snapshot written by the phone process. Schema in §9.1. Holds **raw per-Connector latest reports**, never a materialised aggregate (M8).
- **`AvailabilityKt`** — a Kotlin transcription of the ADR-0008 derivation (latest report → offline override → decay by source+state → bay propagation), fixture-tested against `packages/domain`'s canonical cases.
- **`GrammarKt`** — a Kotlin transcription of the **total** availability / rate / freshness grammar (§3). Also owned by `packages/domain` and fixture-shared. This is deliberately *not* a scattering of format strings at the call sites.
- **`OriginProvider`** — §9.3's ladder. Synchronous, non-blocking, never rejects mock providers.
- **`WatchOpWriter`** — appends watch intents to the op file. **Performs no network I/O and holds no credential** (M7).
- **`TemplateLedger`** — our own pessimistic mirror of the host's quota accounting (§5.4).

---

## 3. The availability, rate and freshness grammar — total by construction

This section is the F2 fix. It is written as a specification of a pure function so it can live in `packages/domain` and be transcribed once into Kotlin, rather than reinvented at three call sites.

### 3.1 From connectors to bay states

`AvailabilityKt` runs ADR-0008 per Connector: latest Report by `capturedAt` → any source declaring itself offline yields `Unknown` immediately → decay by `window(source, state)` (driver 2 h, operator 6 h, `OutOfService` 30 d) → bay propagation (a `Free` connector degrades to `Occupied` while any sibling on its Bay is effectively `Occupied`).

A **bay state** is then rolled up from its connectors, in this order:

| Test (first match wins) | Bay state |
|---|---|
| any connector effectively `Occupied` | **Occupied** — the parking position is taken |
| any connector effectively `Free` | **Free** |
| every connector `OutOfService` | **OutOfService** |
| otherwise (no Free, no Occupied, ≥1 `Unknown`) | **Unknown** |

Counts for a station: `n` bays total, of which `f` Free, `o` Occupied, `x` OutOfService, `u` Unknown; the **known set** is `k = f + o + x`. `f + o + x + u = n` always. Note that after propagation the third row can only be reached when *every* gun on the bay is declared broken, which is the honest reading of "this position is out of service".

### 3.2 Grammar G — the availability clause

`G(n, f, o, x, u)` returns an ordered list of variants, longest first. There are exactly three regimes and they partition the space:

**Regime 1 — `u = n` (nothing known). The majority case.**

No availability clause is emitted at all. The slot carries a **capacity clause** instead:

```
4 bays · up to 60 kW
4 bays                       (short variant)
```

This is ADR-0002's own instruction, verbatim: *"Availability appears as an additive badge when present and is simply absent when not."* The listing stays complete — capacity and peak power are facts, and peak power is decision-relevant while driving in a way rate (forbidden on a row) is not.

**Regime 2 — `u = 0` (everything known).** A total is legitimate, because the denominator is fully known.

| Condition | Clause |
|---|---|
| `f > 0, x = 0` | `2 of 4 bays free` |
| `f > 0, x > 0` | `1 of 4 bays free · 1 out of service` |
| `f = 0, o > 0, x = 0` | `All 4 bays busy` |
| `f = 0, o > 0, x > 0` | `No free bays · 1 out of service` |
| `f = 0, o = 0, x = n` | `All 4 bays out of service` |

Note row 4: when any bay is broken the word *all* never appears with *busy*, because "all busy" tells a driver to wait and a broken bay will never free — the exact failure ADR-0002's fourth state exists to prevent.

**Regime 3 — `0 < u < n` (mixed). The steady state, and v1's fatal gap.**

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

Two rules, both routed to ticket 19 because the domain model names `lastReportedAt` without defining an extremum and does not define `source` for an aggregate at all (M3):

1. **Contributors are the reports backing `Free` and `Occupied` bays only.** `OutOfService` is excluded. ADR-0002's own justification: *"an operator marking a bay out of service asserts a durable fact; a driver reporting a bay busy describes a moment."* A 30-day window and a 2-hour window cannot share one age word, and letting a 3-day-old declaration set the clause would make a 14-minute-old `Free` read as stale. When there is room, `OutOfService` carries its own age inline on the pane (`out of service 3 days`); on a list row it does not.
2. **`source` is the single source when contributors agree, and `mixed` when they differ. `age` is the *oldest* contributing `capturedAt`.** Where a variant must collapse `mixed` to one word it collapses to the **weakest** contributor (`driver < operator < admin`) — understating provenance is the safe direction. Showing `operator` over three operator reports and one driver report, as v1 did, promotes a driver claim to operator provenance, and provenance is the entire confidence axis.

Source words: `operator` · `driver` · `EV Guide` (admin) · `mixed`.
Age words: `just now` · `14 min ago` · `3 h ago` · `6 days ago`.

### 3.4 The variant ladder, and what must never be dropped

`CarText` variants are the sanctioned length mechanism (no character budget is published anywhere). The drop order is fixed, and it is chosen so the two things a driver acts on survive to the last variant:

1. drop the age *words* (`ago`) → 2. drop the source word → 3. drop the `busy` clause → 4. drop the plural nouns.
**`free`, `out of service` and `unknown` counts are never dropped.** A `busy` bay is neither actionable-positive nor a hazard; a broken bay is a hazard, and an unknown bay is the honesty guarantee.

Worked ladder for `(4,1,1,1,1)`, operator, 14 min:

```
1 bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago     (73)
1 free · 1 busy · 1 out of service · 1 unknown · operator, 14 min             (65)
1 free · 1 out of service · 1 unknown · 14 min                                (46)
1 free · 1 out of service · 1 unknown                                         (37)
```

### 3.5 Grammar R — the rate clause

Rate lives on the **Connector**, has its own `Unknown`, and its own 90-day decay (`rateConfirmedAt`). It never appears on a list row; it is a pane row only. Partition the station's `m` connectors into `c` with a confirmed, in-window rate and `m − c` without (m15).

| Condition | text 1 | text 2 |
|---|---|---|
| `c = 0` | `No confirmed rate` | `0 of 5 plugs confirmed` |
| one distinct rate among the confirmed | `600 RWF/kWh` | `All 5 plugs · confirmed 12 days ago` **or** `3 of 5 plugs · 2 unknown · 12 days ago` |
| two distinct rates | `600 RWF/kWh GB/T · 400 RWF/kWh Type 2` | as above |
| ≥3 distinct rates | `From 400 RWF/kWh · 3 rates` | as above |

Three deliberate choices. **`No confirmed rate`, not "no published rate"** — the first states EV Guide's knowledge, the second would assert a licensee is out of compliance with RURA Art. 27(2). **The denominator is plugs, not bays** — a dual-gun bay can carry two different rates, so a bay denominator would be a category error. **`From` asserts a floor over the confirmed set only**, and the unknown remainder is stated in the same breath, so the floor is never presented as a floor over everything.

An optional `sessionFeeRwf` appends to text 1 when present and the string still fits: `600 RWF/kWh + 500 RWF session`.

### 3.6 Grammar Q — the "free for me" lens (M4: non-additive by construction)

When a device-local vehicle profile exists (§7.2), the grammar is applied to the **subset of bays that offer one of the driver's types**, and the remainder is described **without a per-type count**.

A Bay carries 1..N Connectors. Per-type bay counts therefore **do not sum to `n`** if you name two types — v1's `1 of 2 GB/T bays free · Also 2 Type 2 bays` invents parking positions at a dual-gun site. The fix is structural, not a wording tweak:

> **Name exactly one side of a binary partition.** `offers-T` and `does-not-offer-T` partition the bays. Name the driver's side by type and count; name the other side as `other bays` with its types listed but **never counted by type**.

| Situation | text 1 | text 2 |
|---|---|---|
| no profile | grammar G over all `n` bays | `GB/T DC · Type 2` |
| profile GB/T; 2 of 4 bays offer it (`f=1,o=1`) | `1 of 2 GB/T bays free · operator, 14 min ago` | `2 other bays · Type 2 only` |
| profile GB/T; 3 offer it, one broken | `1 of 3 GB/T bays free · 1 out of service · operator, 14 min` | `1 other bay · Type 2 only` |
| profile GB/T; station has none | `No GB/T bay here` | `4 bays · Type 2, CCS2` |
| profile GB/T; all GB/T bays unknown | `2 GB/T bays · up to 60 kW` | `2 other bays · Type 2 only` |

`3 GB/T bays` + `1 other bay` = `4`, always, because the partition is on *offers this type*, not on *is this type*. A dual-gun GB/T + Type 2 bay is counted once, on the driver's side, and never again.

Three properties fall out, and they are the reason the lens exists at all. A **stale or wrong profile is visible** — the row says *GB/T*, so a driver who changed cars sees why the numbers look odd instead of silently losing stations. An **incompatible station stays in the list and says so**, which is ticket 09's requirement that a GB/T driver at a Type 2 + CCS2 site sees incompatibility even with a bay standing empty. And the **load-bearing fact occupies the durable slot** — incompatibility is in text 1, detail in the expendable text 2.

### 3.7 What this grammar never says

- No string on any car screen says *no recent report*, *not reported*, *unavailable*, *offline*, or *unknown data*. In Regime 1 the availability clause is **absent**, per ADR-0002. The one exception is the pane's second line (§4.3) where there is room and the driver is committing to a 20-minute drive.
- No decayed value is ever rendered, in any form — not greyed, not parenthesised, not as "last seen free 3 days ago". The derivation runs at render time on the device over raw reports (§9.1), so a stale green is **unrepresentable**, not merely discouraged.
- No colour, icon, marker change or motion encodes availability anywhere. `SA-1` forbids animation outright, and with ~87 % of the country `Unknown`, any distinguishing treatment renders the map as a field of failure — the outcome ADR-0002 forbids by name.

---

## 4. Every screen, exact rendered text

### 4.0 The worked example

Deliberately chosen to exercise a dual-gun bay, a propagated occupancy, an out-of-service bay, an unknown bay, and two distinct rates — the five things v1's four-single-connector example hid.

```
Station   name       "Kabisa – SP Remera"        ← Station.name
          nameShort  "SP Remera"                 ← Station.nameShort (the PLACE; operator rides the marker)
          owner      Kabisa · markerLabel "KAB"
          geo        -1.9556, 30.1044            ← Station.geo (NOT NULL)

Bays      B1  ├ C1  GB/T DC 60 kW   600 RWF/kWh   Occupied      operator, 14 min ago
              └ C2  Type 2  22 kW   400 RWF/kWh   Free          operator, 14 min ago   → propagates to Occupied
          B2  └ C3  GB/T DC 60 kW   600 RWF/kWh   Free          operator, 14 min ago
          B3  └ C4  Type 2  22 kW   400 RWF/kWh   OutOfService  operator, 3 days ago
          B4  └ C5  Type 2  22 kW   rate unknown  no report                            → Unknown

Derived   n=4  f=1  o=1  x=1  u=1   ·  plugs m=5, confirmed rates c=4
          bay states        B1 Occupied · B2 Free · B3 OutOfService · B4 Unknown
          contributors      C1 (operator, 14 min), C3 (operator, 14 min)   [C4 excluded: OutOfService]
          freshness clause  "operator, 14 min ago"
          availability      Regime 3 → "1 bay free · 1 busy · 1 out of service · 1 unknown"
```

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
| `setTitle` | `Charging nearby` **or** `Charging in Kigali` | §9.3's origin latch | **Constant for the life of the screen instance.** The title is how the surface states its frame of reference — and because the origin is latched, the title cannot change under the driver. |
| `setHeaderAction` | `Action.APP_ICON` | — | root screen |
| `setCurrentLocationEnabled(…)` | **guarded**: `true` only when `ACCESS_COARSE_LOCATION` or `ACCESS_FINE_LOCATION` is already granted (M10) | `checkSelfPermission`, latched at construction | never requests the permission |
| `setAnchor(Place(origin))` | latched origin | `OriginProvider` | latched with the origin; never re-anchored mid-instance |
| `setOnContentRefreshListener` | re-rank handler | — | runtime-guarded; the documented free re-rank path. Real API level **[verify — m18]** |
| `setItemList` | exactly **N** rows | `stationsNear(origin, N)` | `N = min(getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST), 12, directorySize)`, **floor 6**, latched |
| ActionStrip | *none* | — | fewer targets while driving; also avoids an unpriced re-rank path (§13, m18) |

**N never changes.** The radius widens until N stations are found rather than the row count shrinking. Only if the entire directory holds fewer than N stations is N smaller, and that is latched at construction. This is Invariant A applied to the place list.

**Row anatomy** — a title and two texts; only the first two are load-bearing.

| Slot | API | Rendered (worked example) | Rules honoured |
|---|---|---|---|
| title | `setTitle(CarText)` with a `DistanceSpan` on a leading placeholder char | `2.4 km · SP Remera` | mandatory `DistanceSpan` on every non-browsable row; `Row.setTitle` accepts only Distance/Duration spans; **spans are excluded from the refresh diff, so the distance ticks live for free**; the literal residue (`· SP Remera`) is `nameShort`, authored, constant |
| text 1 | `addText(CarText + variants)` | `1 bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago` | grammar G + freshness (§3.2–3.4), or grammar Q under a profile; availability **never in a title** |
| text 2 | `addText(CarText + variants)` | `GB/T DC · Type 2` | connector types, always present, always **expendable** — designed to be the thing a one-text-line host drops |
| metadata | `setMetadata(Metadata(Place(CarLocation, PlaceMarker)))` | pin `KAB`, **label only, no image** (§10) | a row may carry a marker **or** an image, never both → `setImage` appears nowhere |
| tap | `setOnClickListener { push(StationScreen(id)) }` | opaque `stationId` | *"information-only rows not allowed"* |

**Text 2 is always emitted**, in every regime, so the number of texts per row is as stable as the number of rows. (Text count is not named in the documented refresh diff; keeping it constant costs nothing and removes the question.)

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
│  operator, 14 min ago · out of service 3 d   │               │
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
├──────────────────────────────────────────────┴───────────────┤
│   [ Directions ]   [ Notify me when a bay frees up ]         │
└──────────────────────────────────────────────────────────────┘
```

| Slot | Rendered | Source | Rule |
|---|---|---|---|
| `setTitle` | `Kabisa – SP Remera` | `Station.name` (full form — there is room here) | constant |
| `setHeaderAction` | `Action.BACK` | — | |
| `Pane.setImage` | Kabisa mark, `CarIcon` `TYPE_RESOURCE`, one monochrome light-on-black asset | `Owner.icon` | `IU-1`'s **single static context image** — and the only image on the whole surface (§10) |
| row 1 title | `Availability` | literal **label** | constant ⇒ a report landing while this pane is open is a **free refresh** |
| row 1 text 1 | grammar G / Q | §3.2, §3.6 | |
| row 1 text 2 | `operator, 14 min ago · out of service 3 d` | §3.3 | freshness as its own axis; `OutOfService` gets its own age here because there is room |
| row 2 title | `Connectors` | label | |
| row 2 text 1 | `GB/T DC 60 kW · Type 2 22 kW` | `Connector.type`, `.powerKw` | ≥3 types → `GB/T DC 60 kW · Type 2 22 kW · +1 more` |
| row 2 text 2 | **`4 bays · 5 plugs`** | `n`, `m` | the line that makes the multi-gun reality explicit and stops a driver adding per-type counts together |
| row 3 title | `Rate` | label | |
| row 3 text 1/2 | grammar R | §3.5 | |
| row 4 title | `Bay alert` | label | present iff `canWatch` (latched); **never varies with availability or watch state** |
| row 4 text 1/2 | §8.2's ladder | Watch state | text only |
| action 1 | `Directions` | — | **anonymous, always, unconditional** |
| action 2 | `Notify me when a bay frees up` ⇄ `Stop watching` | Watch | present iff `canWatch` **and** ledger ≤ 2 at construction (§5.4 R1) |
| ActionStrip | *none* | | |

**Row count: 4 signed-in, 3 anonymous. Action count: 2 signed-in, 1 anonymous.** Both are latched (§1) and neither varies with anything else, ever. `CONTENT_LIMIT_TYPE_PANE`'s floor is 4, which the signed-in set meets exactly; rows are ordered load-bearing-first so a host reporting 3 loses only the alert row — and the alert *action* survives that loss, so the function does not disappear with the row.

### 4.4 S1 — Regime 1, anonymous

```
┌──────────────────────────────────────────────────────────────┐
│ ←   Kabisa – SP Remera                                       │
├──────────────────────────────────────────────┬───────────────┤
│  Availability                                │               │
│  4 bays · up to 60 kW                        │   [ Kabisa ]  │
│  No recent bay report                        │               │
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

**The one place the surface names its own ignorance**, and the reasoning for the asymmetry with §4.2 is deliberate: on a list row, a driver is scanning and ADR-0002's "simply absent" is right; on the detail pane a driver is deciding whether to commit to a 20-minute drive, and the difference between *nobody is free* and *nobody has said* is the decision. `No recent bay report` states a fact about EV Guide's data, sits in the second (expendable) line after a complete first line, and names no window it cannot substantiate. It is not greyed, not an error, and not an apology for the operator.

### 4.5 The bay-watch notification

```
Channel   ev_guide_bay_alerts          (phone channel, IMPORTANCE_HIGH — the errand expires in 2 h)
Title     A bay just freed up
Text      SP Remera · operator report
Tap       PendingIntent → EvGuideCarAppService intent, station detail for stationId
```

Posted through `CarNotificationManager` with `androidx.car.app.notification.CarAppExtender` **[inferred — and the whole delivery path is ticket 27's #1 blocking item, M6/§13]**. `IN-1` is satisfied because the driver explicitly asked about this station within the last two hours; `NA-1` trivially (nothing to advertise, no payments, ever). One notification per watch — no repeat-fire path exists, so no digest, quiet hours or rate limiter is built. The tap is an intent and therefore **resets the template quota** (§5.3).

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
   │   │   arm / disarm  → row text + action title    ↺  free [inferred] or +1  │    │
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
| 4 | Driver taps the host's ⟳ | PLMT with a re-ranked row set | **refresh** — documented `setOnContentRefreshListener` exception | **0** |
| 5 | Row tap | `PaneTemplate` | new template | **+1** |
| 6 | Report lands while on detail (row count now invariant — F1) | same Pane — title, row count, row titles unchanged | **refresh** | **0** |
| 7 | Arm / disarm watch | same Pane, one row text + one action title changed | refresh **[inferred]**; action-title diffing is undocumented | **0 or +1** |
| 8 | Back | pop S1 → refund; S0 re-emits PLMT | refund **documented** ("by the number of templates popped"); the re-emit is a refresh under a per-screen reading, a step under a global one | **−1, then 0 or +1** |
| 9 | Directions | `startCarApp(Intent(ACTION_NAVIGATE, "geo:…"))` | not our template; the task is left | **0** |
| 10 | Notification tap | seed `[S0, S1]`; host requests only the top template **[inferred]** | **RESET**, then +1 | **→ 1** |
| 11 | Relaunch from car home (`EP-2`) | seed `[S0]` or `[S0, S1]` | **RESET**, then +1 | **→ 1** |
| 12 | Day ⇄ night | *nothing* — one monochrome asset serves both (§10) | — | **0** |
| 13 | `QuotaGuard` fires (§5.4 R2) | `MessageTemplate` | new template, legal 5th | **+1** |

**There is no origin-failure transition and no empty-state transition.** v1 had both (a `MessageTemplate` first paint, and a `MessageTemplate → PLMT` swap when permission or a fix arrived, which M10 correctly priced at +1 and unbounded). §9.3's ladder deletes them: the first paint is always a place list.

### 5.3 The two resets, used deliberately

Both documented resets are load-bearing here, not incidental:

- **Notification intent** — a bay-watch firing deep-links to `StationScreen`. `onNewIntent` seeds the stack `[NearbyScreen, StationScreen]` so *back* still works, and because the host only requests the **top** screen's template **[inferred]**, seeding two screens costs one template. Post-reset ledger **1/5**.
- **Launcher intent** — returning to EV Guide from Google Maps via the car home screen. This is also how `EP-2` is satisfied: the Session remembers the last-viewed `stationId` for the connection and re-seeds `[Nearby, Station]`, so a relaunch resumes where the driver was rather than dumping them at a list. It is also the surface's **only re-rank path on a host without the content-refresh listener** (§13, m18).

### 5.4 `TemplateLedger` — the safety valve

The ledger counts our own sends **pessimistically**: a send is a step unless it *provably* satisfies a documented refresh clause (title + row count + row titles unchanged, spans excluded) or is the response to `setOnContentRefreshListener`. Four rules fire off that count. All four are defence against accounting we cannot observe; under the likely reading none of them ever fires.

- **R1 — the watch action needs two units of headroom.** A `PaneTemplate` is constructed carrying the watch action only if `ledger ≤ 2` at construction. Two, not one, because an arm and a later disarm must *both* fit: at ledger 3, an arm would reach 5 (legal — a Pane is a legal terminal template) but the following disarm would reach 6 and close the app. A button whose second press is fatal is worse than a button that is absent.
- **R2 — never emit a `PlaceListMapTemplate` at ledger ≥ 4.** A place list is **not** a legal 5th template. If a pop's refund does not bring the ledger below 4, `NearbyScreen` emits `QuotaGuard` — a `MessageTemplate` (legal 5th) — instead:
  ```
  Title    Charging nearby
  Message  Open EV Guide from the car screen to keep browsing.
  Actions  [ Directions to SP Remera ]
  ```
  That single action is the one affordance that leaves the app usefully, so the branch is not a dead end (m17). The message is a **head-unit** instruction, not a phone instruction, so it also stays inside CarPlay guideline 2 when the twin design reuses the wording.
- **R3 — construction-time only.** A Screen latches its ledger-derived shape at construction and never re-derives it. This is what keeps R1 compatible with Invariant A: the action set of a Pane already on screen cannot change, because the only thing that could change the ledger while it is on screen is a tap on the very action R1 removed.
- **R4 — the ledger never trusts an inference in its own favour.** Every entry in §5.2 marked "0 or +1" is counted as +1.

`isAppDrivenRefreshEnabled()` is probed but **never depended on** — it returns `false` on host-call failure, is regional and OEM-dependent, and is absent on JAMA-affiliated vehicles. Adaptive task limits, if present, are pure headroom.

### 5.5 Why the live layer is free

Every volatile value on this surface sits in a slot the documented refresh diff excludes:

- **on S0** — distance is a **span** (explicitly excluded); availability, freshness and plug types are **text**, never a title; the row **set** and **count** are frozen for the screen instance's lifetime and change only through the documented content-refresh path.
- **on S1** — every row title is a constant label (`Availability`, `Connectors`, `Rate`, `Bay alert`); every value is text; the row count and action count are latched.

So a report arriving from the operator app repaints both screens at **zero quota cost, indefinitely** — and unlike v1, that sentence is now true, because §4.3's row 4 no longer appears and disappears with availability.

Corollary rule: **only the top screen may call `invalidate()`.** A background `NearbyScreen` buffers changes and applies them on `onResume`, which keeps its row set byte-identical across a down-up round trip and lets the re-emit qualify as a refresh under the per-screen reading.

### 5.6 The proof, re-run against the corrected design

Counted under R4 — every undocumented point resolved **against** us.

**Proof 1 — the required session** (the walk ticket 20's demo script performs): browse → detail → back → browse → detail → navigate.

| Step | Action | Class | Ledger |
|---|---|---|---|
| 1 | launcher intent → reset → PLMT | new | **1 / 5** |
| 2 | any number of delta syncs, distance ticks, ⟳ re-ranks | refresh ×n | **1 / 5** |
| 3 | tap row → Pane (ledger 1 ≤ 2 → watch action present) | new | **2 / 5** |
| 4 | report lands, availability changes on the open pane | refresh (F1 fix) | **2 / 5** |
| 5 | back → pop refunds 1 | refund | **1 / 5** |
| 6 | S0 re-emits PLMT | +1 pessimistic | **2 / 5** |
| 7 | tap row → Pane | new | **3 / 5** |
| 8 | `Directions` → `startCarApp` | leaves the task | **3 / 5** |

**Peak 3 of 5, two units in hand.** Under the optimistic reading (step 6 is a refresh) the peak is **2 of 5**.

**Proof 2 — the adversarial session**, with a watch armed on every detail visit and every inference resolving against us:

| Step | Action | Ledger | Note |
|---|---|---|---|
| 1 | launcher intent → PLMT | **1** | |
| 2 | tap row → Pane | **2** | ledger 1 ≤ 2 → watch action present (R1) |
| 3 | arm watch | **3** | action-title change costed as a step |
| 4 | back (−1) | **2** | |
| 5 | S0 re-emits PLMT | **3** | R2 permits: ledger 2 < 4 |
| 6 | tap row → Pane | **4** | ledger 3 > 2 → **watch action absent** (R1); pane carries `Directions` alone |
| 7 | `Directions` | **4** | leaves the task |

Or, if the driver goes back again instead:

| Step | Action | Ledger | Note |
|---|---|---|---|
| 7′ | back (−1) | **3** | |
| 8′ | S0 re-emits PLMT | **4** | R2 permits: ledger 3 < 4 |
| 9′ | tap row → Pane | **5 / 5** | **legal terminal template**; watch action absent (R1); `Directions` leaves |
| 10′ | back (−1) | **4** | |
| 11′ | S0 would emit a PLMT at ledger 4 → **R2 blocks** → `QuotaGuard` `MessageTemplate` | **5 / 5** | legal 5th, one useful action (`Directions to …`) |
| 12′ | back | — | root pop: the app closes normally, by the driver's own act |

**Peak 5 of 5, and every 5th template emitted is `PaneTemplate` or `MessageTemplate` — both on the four-class legal list for a POI app (`PaneTemplate`, `MessageTemplate`, `SignInTemplate`, `LongMessageTemplate`).** No place list is ever the 5th. No path reaches 6. The host never closes the app.

**Proof 3 — the escape hatches, unconditionally available.** A notification tap or a launcher relaunch resets the ledger to 0 and re-seeds at 1/5, *"even if the app is already in the foreground"*. So the 11′ state is not a trap: the driver's bay alert fires, or they reopen EV Guide from the car home screen, and the surface is fresh — with a re-ranked list, which is also the documented answer to m18.

**What Proof 2 costs.** In steps 6 and 9′ the watch action is absent although the driver saw it a moment earlier. This is the only surprise the design still contains, and it is deliberate: the alternative to removing the button is exceeding the quota, which closes the app while the driver is driving. Two mitigations. Under the optimistic (and likely) reading of step 3, the ledger never rises past 2 at a Pane construction and R1 never fires at all. And if ticket 27 finds that an action-title change **does** consume a step, the pre-decided remedy is §8.3's constant-title fallback, which makes arm/disarm **provably** free and retires R1 entirely.

---

## 6. Rank, and what the driver's profile may and may not do

`stationsNear(origin, limit)` is ranked **distance-first, then availability** (domain model). This design **does not change the ranking and reserves no slots** (M9).

v1 reserved the last row for the nearest compatible station when a profile existed. That contradicted its own rule in the same section — *"the profile changes the wording of the row, never its presence and never its order"* — and it broke a total order at exactly the point where the six-row floor bites. One of the two sentences had to go, and it is the reservation:

> **The profile changes the wording of a row. It never changes which rows appear, and never changes their order.** — §3.6

The incompatibility wording already does the work. A GB/T driver whose six nearest stations are all Type 2 reads `No GB/T bay here` on all six, which is a true and immediately actionable statement, and they still have distance, plugs and `Directions` on every one of them. Hiding or reordering would have made a complete listing incomplete for a fact the driver can read in one glance.

If the founder later wants compatible-first, it must become a **named second ranking key in ticket 19** and the "never its presence" sentence must be deleted. Not both.

---

## 7. "Free for me" without knowing the car

### 7.1 Where the driver's connector set can come from

1. **`EnergyProfile.getEvConnectorTypes()`** — Car API 3, mapped at the edge to EV Guide's OCPI enum. **Expect `STATUS_UNIMPLEMENTED` most of the time** on Android Auto (a phone projecting to an arbitrary head unit), and **never persist the platform integer** — the two Android taxonomies disagree with each other (CHAdeMO is 3 in `EnergyProfile`, 4 in `EvChargingConnectorType`).
2. **A device-local vehicle profile** set in the phone app. **[inferred, and see m22 below]** ADR-0003 gates profile *sync* behind an account; it does not gate a local profile. That distinction is what lets "free for me" work for an anonymous driver on a car screen.
3. **Nothing** — the normal case, and the one the base grammar is written for.

**[m22 — must be settled before ticket 19 locks]** Ticket 12's *answer* lists "sync the vehicle profile that powers 'free for me'" as account-gated; its *question* lists "setting your own connector type" among the things requiring sign-in. Those readings differ. Get the one-line ruling. **Fallback if profiles turn out to be account-gated:** grammar Q applies only to signed-in drivers, anonymous drivers get grammar G, and nothing else in this design moves — G is complete on its own and is what a reviewer sees regardless.

### 7.2 The rule

> **The profile changes the wording of the row, never its presence and never its order** (§6), and per-type counts are stated **non-additively** (§3.6).

Per-connector state is never rendered per row: two visible lines, one already spent on the mandatory distance. The domain model settled this — per-Connector rows are the **filter** dimension, the aggregate is the **display**. What the aggregate counts is **bays**, which is what bay propagation makes meaningful: `1 of 2 GB/T bays free` is a true statement about parking positions a GB/T driver can occupy, not a plug count that double-counts a dual-gun pedestal.

### 7.3 On the detail pane

`Connectors` is its own row (types, power) with `4 bays · 5 plugs` beneath it, and the `Availability` row applies grammar Q exactly as the list row does. There is no per-connector screen — it would be a third template for information a driver cannot act on differently while driving.

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
- **Never name a component** — `startCarApp` throws `SecurityException` if you target an app explicitly. The recipient is the host's default navigation app (= the last navigation app the user launched), which cannot be targeted or predicted. **[blocking-adjacent: no Google page names Google Maps as a guaranteed receiver — ticket 27.]**
- **No route, maneuver, ETA or polyline** is modelled anywhere on this surface. There is no route entity, and drawing one would require the NAVIGATION category.
- **The destination name [m19].** v1 sent a bare `geo:lat,lng`, so Google Maps shows an unnamed pin. The javadoc documents exactly three URI forms and the labelled form `geo:0,0?q=<lat>,<lng>(<nameShort>)` is not among them, so **v1 of the code ships the bare, documented form** — an undocumented URI shape handed to `startCarApp` is a crash risk on the car screen, which is the worst failure this product can have. The labelled form is a **ticket 27 experiment**; if the host accepts it, adopt it. Recorded mitigation in the meantime: the driver confirmed the station by name on the pane one tap earlier, so the unnamed pin follows an explicit confirmation rather than replacing one.

There is no per-row directions button: `PlaceListMapTemplate` rows use the `FULL_LIST` preset, which permits **zero** row actions. Directions is reached in exactly two taps.

### 8.2 The bay alert — always the same shape, only the words change

Per ticket 30: arm/disarm on the station detail, label `Notify me when a bay frees up`, plus an armed-state row. Placement: pane row 4 + pane action 2.

**Presence is latched, never derived from availability** (F1):

```
canWatch = isSignedIn && notificationsPermitted        ← latched at Session creation (§1)
row 4    present iff canWatch
action 2 present iff canWatch && ledger ≤ 2 at Pane construction   (§5.4 R1)
```

`notificationsPermitted` is in the gate because a watch the driver will never be told about is exactly the "promise the system cannot keep" failure the CarPlay verdict found in the twin design — and the car screen can neither ask for the permission nor explain its absence. Silent omission is the same rule already settled for the signed-out case.

**Every watch outcome is a row-4 text change and nothing else.** No alert, no message template, no extra screen, no template cost:

| State | text 1 | text 2 |
|---|---|---|
| idle, armable | `Not watching` | `One alert, next 2 hours · any plug` |
| op written, unconfirmed | `Alert requested` | `Waiting for confirmation` |
| server confirmed | `Watching · until 14:05` | `One alert, then it ends` |
| refused — a bay is already free | `A bay is free now` | `No alert needed yet` |
| refused — 3 already armed | `3 alerts already running` | `Stop one to add another` |
| write failing | `Couldn't set the alert` | `Retrying · expires in 2 hours` |
| fired while the pane is open | `Alert sent · a bay is free` | `One alert, next 2 hours · any plug` |

Two of those rows are **refusals with a reason**, and they are the deliberate, narrow amendment this design asks of ticket 30. Ticket 30 §3 says *"arming is only offered when the watched set is not already Free"*; honouring that as a rule about the affordance's **presence** would make the action appear and disappear as reports land, which is F1. So it is honoured as a rule about the **outcome**: the affordance is always offered to a `canWatch` driver, and the arm is refused, locally and instantly, with the reason in row 4. **Routed to ticket 30 as a one-line amendment.**

**What the arm sends [m16].** The op record carries the device-local profile's connector types when a profile exists, and an empty list (= all types, ticket 30's default) otherwise. Row 4's text 2 says which — `· any plug` or `· GB/T only` — so the driver can see what will wake them. Changing the local profile afterwards does **not** change an already-armed watch: the server holds what was sent, and silently re-scoping a live errand would be worse than the inconsistency.

**Anonymous drivers are told nothing about the feature.** No "sign in to get alerts", no disabled control. CarPlay guideline 2 forbids instructing phone manipulation and the settled reading is that silent omission is the safe form; carrying it to Android keeps one design at the cost of a discoverability loss on a platform that would have permitted the message (`VI-1`). **[inferred, and flagged as a compromise — §12.]** It is also why ticket 20's reviewer walkthrough must arrive **signed in** (§13, M5).

### 8.3 The pre-decided fallback if an action-title change costs a step

If ticket 27 finds that changing an `Action`'s title inside an otherwise-identical template consumes a template step, the remedy is decided now rather than improvised later: **action 2's title collapses to the constant `Bay alert`**, and arm/disarm becomes a pure row-text change — which is **provably** a refresh under the documented `PaneTemplate` rule (title + row count + row titles unchanged). Row 4 already states the current state and the button becomes an unambiguous toggle against it. Cost: ticket 30's authored label leaves the button and survives only on the phone. Benefit: R1 is retired, the quota model loses its last inference, and Proof 2 peaks at 4/5. Routed to ticket 30 as a conditional amendment.

### 8.4 The write path — the car layer holds no credential (M7)

Arming a watch is a user-scoped, authenticated write, and car constraint 9 says the car surface reads only non-sensitive directory + availability data. v1 put a `WatchClient` POST on the car surface and never said where the token lived. It does not live there:

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
- **Single writer per file.** The car process only ever appends to `car-ops.jsonl`; the phone process only ever writes `car-snapshot.db`. There is no shared-write contention and therefore **no SQLite WAL across processes** (Android does not support WAL for multi-process access). The snapshot is replaced by writing a new file and `rename()`-ing it over — atomic, and the car process simply opens the path on each read.
- **Nothing is claimed before the ack.** Row 4 reads `Alert requested` until the confirmed set lands in a snapshot. An unsynced watch is *not* `Watching`.
- **A queued op expires client-side after 2 hours**, mirroring ADR-0007's rule for stale reports. A watch delivered three hours late would arm a two-hour errand the driver abandoned.
- **The drain must be woken.** The car process broadcasts to the main process on append; the main process drains on that broadcast, on app foreground, and on its normal sync tick. The car layer **never blocks on any of it** (`DR-1` is satisfied by the immediate `Alert requested` text). The exact wake mechanism is implementation, routed to ticket 15.

**If `android:process=":car"` proves impractical** (§9.4's fallback), the op-file hand-off survives unchanged and remains the right shape — it is what keeps the credential out of the car code path even inside one process, and it is what makes the iOS twin's design identical.

---

## 9. Cache, latency, and the process boundary

The governing rule: **no car screen has a loading state as its normal first paint.**

### 9.1 The car cache schema — raw reports, never a materialised aggregate (M8)

v1 said `AvailabilityKt` derives "over the local snapshot" without ever saying what the snapshot held. If it held the materialised `baysFree` / `lastReportedAt` that the domain model says is written into sync payloads, the Kotlin layer could not re-apply decay (no `capturedAt` per connector), could not re-run bay propagation (no sibling grouping), and could not produce §3.6's per-type wording — and a `baysFree: 2` written at sync time would render confidently hours later. That is the one place v1's central safety claim was unbacked.

```
station    { id, name, nameShort, ownerId, lat, lng, updatedAt }
owner      { id, displayName, markerLabel, iconRes }
bay        { id, stationId }
connector  { id, bayId, type, powerKw, voltage,
             ratePerKwhRwf, sessionFeeRwf, rateConfirmedAt }
report     { connectorId, state, source, capturedAt, sourceOnline }   -- LATEST per connector only
```

- **`report` is the render input.** One row per Connector — the derivation needs only the latest. `sourceOnline = false` yields `Unknown` immediately regardless of recency (ADR-0002's observed failure: an `OFFLINE` pedestal still publishing a full gun-status array).
- The materialised aggregate may ride along in the sync payload as a **server-side convenience for the phone's list**, but it is **never** the car's render input. **Routed to ticket 19: the car sync payload must carry per-Connector latest reports.**
- Size: tens of stations × a few bays × a few connectors — a few hundred rows, kilobytes. ADR-0007 already establishes the dataset is small enough that full caching is free.
- **Two non-directory fields** ride alongside, and they are an acknowledged extension of car constraint 9: `isSignedIn: Boolean`, `notificationsPermitted: Boolean`, and `armedWatches: [(stationId, expiresAt)]`, at most three entries. **No user id, no email, no display name, and never the push token** (ticket 30 §5 is explicit). Station ids are public data and the booleans are not identifying. **Flagged, not smuggled — routed to ticket 19.**
- **Fixture obligations** on the shared corpus (§9.4): a **dual-gun bay** whose per-type counts would double-count if summed (M4); a case whose **materialised aggregate and device-derived aggregate deliberately disagree** (M8); every regime boundary of §3.2, including `0 < u < n` with and without `OutOfService` (F2); an offline-source override; each decay boundary at ±1 minute.

### 9.2 What is served from cache, and what may touch the network

| Screen | Painted from |
|---|---|
| S0 row set, distances, availability, freshness | `CarCacheReader` + `AvailabilityKt` + `GrammarKt` over the local snapshot |
| S0 map, pins, panning, clustering | the **host** — EV Guide fetches no tiles at all |
| S1 every row and both actions | the same cache; a station detail is fully materialised locally |
| Marker labels, pane image | authored text and a bundled `TYPE_RESOURCE` drawable — remote URLs cannot be handed to the car in any case |

ADR-0007's **bundled directory snapshot** means even a first run with zero connectivity paints a full list, with every availability honestly in Regime 1. `DR-2` (launch ≤ 10 s) and `DR-3` (content ≤ 10 s) are met by construction, not by a fast network.

The car process performs **no network I/O at all**. `changedSince(cursor)` delta sync runs in the main process and lands as a new snapshot; the watch write is the op file. If either never completes, nothing on the surface is missing — values simply age and the decay renders them honestly.

### 9.3 The origin ladder — synchronous, and it always yields an origin (M13, M10)

v1 gave `OriginProvider` a "hard 1.5 s budget". `Screen.onGetTemplate()` is a synchronous main-thread call; `getLastKnownLocation` either returns immediately or returns null, so there was nothing to wait for except a fresh fix, which the same section forbade. **The budget is deleted.** `onGetTemplate` reads last-known synchronously and returns on the same tick.

```
1.  Last known coarse fix        — only if the permission is already granted
                                   AND the fix is within 200 km of any station
2.  The origin persisted by the phone app  — its last known good position
3.  Kigali centroid                        — the unconditional floor
```

Rung 3 is why there is **no origin-failure screen, no empty-state screen, and no template swap**. It does four jobs at once: it handles a driver who never granted location (the car layer never asks); a driver in Kampala; **Google's reviewer in the US, who now sees a populated list without needing a mock GPS app at all**; and a cold first launch before any fix exists.

The frame of reference is stated where it belongs — in the **template title**, which is latched with the origin and therefore constant: `Charging nearby` on rungs 1–2, **`Charging in Kigali`** on rung 3. No sentence about permissions, no instruction to touch the phone, and `VI-1` never bites because the driver is never required to.

Two supporting rules: **mock providers are never rejected** (Play's reviewer-access clause requires a mock GPS app to work, and `stationsNear` takes an arbitrary origin precisely so no code path hardcodes "device location"); and **the origin may improve once and never reverts** — a fix arriving after first paint re-ranks the list through the content-refresh path, and a lost fix keeps the last-known origin rather than reverting to Kigali and silently changing every distance.

### 9.4 The process boundary (`DR-2`) — routed to 15 / ADR-0006 (M12)

v1 asserted the car layer runs "with no React Native runtime attached". That was a claim about the **codebase**, not about the car layer, and it is false by default: `CarAppService` starts in the app's normal process, and every Expo/RN template initialises the RN host in `MainApplication.onCreate()`. On a cold connect on a mid-range Android phone, `onGetTemplate` would return only after Hermes and the JS bundle had loaded — squarely against `DR-2`'s 10 seconds.

**The service declares `android:process=":car"`** (§2.1). Consequences, all of which belong in the ticket 15 / ADR-0006 record:

- The `:car` process never touches RN. Belt and braces: `MainApplication.onCreate()` must **branch on the process name** and skip RN initialisation for `:car`, because a future library could pull it in transitively.
- The car layer is **pure Kotlin over a native-readable projection of the cache** (§9.1), which means the ADR-0008 derivation exists a **third time** — server (TypeScript), device (TypeScript), and now car (Kotlin). ADR-0008's guarantee is *"run identically on server and device"*; this adds an implementation that can drift.
- **Mitigation, not elimination:** one shared fixture corpus (§9.1's obligations) owned by `packages/domain` and executed by both the TypeScript suite and the Kotlin suite. Same for `GrammarKt` — the total grammar of §3 is a pure function of `(n, f, o, x, u, source, age, lens)` and is fixture-shared identically. **This is a real cost and belongs in the ticket 15 / ADR-0006 record, not in a code comment.**
- **Fallback if `:car` proves impractical** (some host callbacks or content providers can be awkward across a process boundary): gate RN initialisation on a non-car entry point in the same process. §8.4's op-file write survives unchanged either way, so M7's credential isolation does not depend on this choice.

---

## 10. Markers, images, and `IU-1` (M11)

`IU-1` permits **no images except** a single static context image, navigation-drawer icons, images that aid driving decisions, and lane/junction guidance. v1 put an Owner `TYPE_IMAGE` logo on **every marker** (up to six) *and* on the pane, then claimed `IU-1` was satisfied by "one Owner mark per station as the pane image" — quietly omitting the six. Choosing `TYPE_IMAGE` also forecloses `setColor`, which is why v1 then needed a `-night` resource-resolution inference to survive `VD-1` / `TH-1` at all.

**The surface now carries exactly one image, and it is on the pane.**

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

- **`PlaceMarker.MAX_LABEL_LENGTH = 3`, and `setLabel` throws above it.** A four-character label is not a layout bug, it is a **crash on the car screen** — the worst failure this product can have. Spans in the label are ignored.
- **The label is authored on `Owner`, never derived.** "Kabisa – SP Remera" has no mechanical three-character abbreviation, and the names that break a derivation are exactly the ones nobody tests ("e-Mobility Rwanda Ltd" → "E-M").
- **No `setColor` anywhere.** Colour on a marker is a channel that can disagree with the text, and six differently-coloured pins invite reading colour as state. Host default styling only.
- **One asset, both modes — and inference 8 is deleted.** Android Auto uses a **black background across day and night**; a single light-on-black monochrome mark is correct in both, so no `-night` qualifier and no assumption about how `CarContext` resolves resources is needed. Day ⇄ night costs zero templates because nothing is re-emitted (§5.2 #12). Authored ≥ 36 dp effective (the UX minimum for map imagery), contrast-checked at 4.5:1 against black (`VD-1`). **[verify: confirm the ground is black in day mode on the test head unit — it is the one thing this simplification rests on.]**

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
| Declare `MAP_TEMPLATES`, not `NAVIGATION_TEMPLATES` | §2.1 manifest; `NavigationTemplate` never constructed |
| Library ≥ `1.7.0-rc01` | pinned; permission dialogs correct on Android 14+ |
| `PlaceListMapTemplate` is POI-only; `NavigationTemplate` forbidden to POI | root uses the POI-exclusive template; no navigation template exists in the code |
| Row ≤ 2 text lines | title + text 1 + **expendable** text 2; everything load-bearing survives at one text line |
| No `Toggle` in a place-list row | the alert is a `PaneTemplate` action, not a row toggle |
| Row may not have both an image and a marker | rows carry `Metadata(Place(marker))` and **never** `setImage` |
| `IMAGE_TYPE_LARGE` forbidden in the place list | no row images at all |
| `ItemList` not selectable | rows are click-through to detail; no selection group |
| **Every non-browsable row must carry a `DistanceSpan`** | span on the row **title**, on every row, always |
| Every row must have an action | every row pushes `StationScreen`; no information-only rows |
| `setCurrentLocationEnabled` needs location permission | **guarded** on `checkSelfPermission`, latched (M10); the screen is fully functional without it (§9.3) |
| `CONTENT_LIMIT_TYPE_PLACE_LIST` floor **6** | queried at runtime, capped at 12, **designed at 6**; N is latched and the radius widens rather than the count shrinking |
| `CONTENT_LIMIT_TYPE_PANE` floor **4** | exactly 4 rows signed-in, 3 anonymous, latched, ordered load-bearing-first |
| `Row.setTitle` accepts only Distance/Duration spans | the only span used anywhere is `DistanceSpan`, in a title |
| ActionStrip titles accept no spans | no ActionStrip anywhere on the surface |
| `PlaceMarker.MAX_LABEL_LENGTH = 3`, throws above | §10.1's three-layer guard; label authored on `Owner`, never derived |
| `setColor` illegal with `TYPE_IMAGE`; marker sizes 64/72 dp | markers are **label-only** — no icon, no image, no `setColor` (M11) |
| No documented character limits; use `CarText` variants | variants (longest → shortest) on every row text; titles single-variant so the refresh diff stays stable; authored `nameShort`, never mechanical truncation |
| 120-char glanceability guidance | **longest authored string on the surface is 73 characters** (the `(4,1,1,1,1)` availability clause, §3.4), whose shortest variant is 37; the longest fixed string is `QuotaGuard`'s 51-character message. Recount performed against v1's false "43" claim (m14). |
| `CarIconConstraints`: no `TYPE_URI` | the one icon is `TYPE_RESOURCE`, bundled; Owner is a bounded enumerable set, which is why this is possible |
| `IU-1` — no images except one static context image | **exactly one image on the entire surface**: the Owner mark on the pane. Markers carry text only. `Photo` never reaches a car surface. |
| `SA-1` — no animated elements | nothing animates; no spinner, no pulsing "live" dot, no availability transition |
| `ST-1` — no auto-scrolling text | overlong names are handled by `nameShort` + variants, never by marquee |
| `ActionsConstraints`: `BODY` 2, `ROW` 2 | 2 pane actions max (`Directions`, alert); zero row actions on the place list (`FULL_LIST` permits none) |
| `MessageTemplate` ActionStrip max 2, one titled | `QuotaGuard` carries one body action and no ActionStrip |
| **5-template quota**, host closes the app on exhaustion | §5.6: peak **3/5** in the required session, **5/5** in the adversarial one, never 6 |
| 5th template must be Pane/Message/SignIn/LongMessage | every 5th template emitted is a `PaneTemplate` or `QuotaGuard`'s `MessageTemplate`; **R2 forbids emitting a place list at ledger ≥ 4** |
| Refresh rules (title + row count + row titles; spans excluded) | **Invariant A** (§1): no row or action count varies with runtime state; every row title is a constant label or an authored `nameShort`; volatile values live in spans and text |
| Content-refresh listener exception | the host's ⟳ is the only path that re-ranks the row set, and it is documented free |
| Adaptive task limits unreliable | probed, never depended on; the design assumes `false` |
| Throttling, no published interval | no periodic invalidation at all — repaints are event-driven off cache changes |
| 8-second dwell before auto-transition | nothing auto-transitions; every transition is a tap or an intent |
| Screen stack cap 5 | maximum depth 2 |
| Task flow ≤5 steps, SHOULD 2–3, ≤3 taps, must not end on a list | 2 taps to directions; the deepest template is always a Pane or a Message |
| `PF-1` — meaningful functionality relevant to driving | ranked live availability with source and freshness · anonymous one-tap directions hand-off · bay-watch alert. **And all three are visible to a reviewer** — §13's M5 items make it so. |
| `PC-1` — no features outside the app type | no saving, no reporting, no settings, no profile editing, no photos on the car surface |
| `EP-1` — works as listed | the Play listing describes exactly these three functions |
| `EP-2` — restores state on relaunch | the Session remembers the last-viewed `stationId` and re-seeds `[Nearby, Station]` |
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
| POI apps SHOULD offer a nav hand-off | `Directions` is the primary action on every station |
| Templated apps cannot be sideloaded | test loop is DHU + Internal App Sharing / Internal track |
| Play form-factor opt-in; blocking review on open/production | Android Auto form factor added; closed track first (non-blocking review) before open/production |
| Addendum kill switch | nothing in the product is load-bearing on the car surface — the phone app is complete without it |

---

## 12. Forced compromises

1. **No identity on screen.** One bundled Owner mark on the detail pane is the entire visual surface, and it is now the *only* image on it (M11). EV Guide's design system does not appear on Android Auto. Declining `MapWithContentTemplate` deepens this deliberately in exchange for §0's four removals.
2. **No reporting from the car.** Settled by ticket 23 (the function set is three), and structurally right: a report is per-Connector, so a one-tap car report would have to invent a station-level write the model does not have, and a connector picker is two more templates of data entry while driving. The cost is real — a driver who arrives to find every bay taken is at the single best reporting moment and cannot act on it. Revisit only if a documented parked-state signal appears.
3. **No saving, no favourites, no profile editing on the car.** All user-scoped, all outside car constraint 9.
4. **The cache gains three non-directory fields** (`isSignedIn`, `notificationsPermitted`, `armedWatches`) to satisfy ticket 30. An acknowledged extension of car constraint 9 (§9.1). The credential is **not** among them (§8.4), which is the one thing v1 got wrong here.
5. **A third implementation of the ADR-0008 derivation, plus a second of the grammar** (§9.4). Divergence risk, mitigated by shared fixtures, not eliminated.
6. **"Free for me" is a qualified aggregate, never a filter.** Per-connector state cannot fit a two-line row, so the driver's plug changes the *wording* only, and only one side of the partition is ever counted (§3.6). A driver whose profile EV Guide does not know sees a station-wide count that may be true for someone else's car.
7. **The marker cannot say which station.** `markerLabel` is on `Owner`, so four Kabisa sites show four `KAB` pins; row↔pin correspondence rests on position and host highlighting.
8. **The list is frozen while the driver looks at it, and on a host without the content-refresh listener it is frozen for the whole connection.** A station that frees up 200 m away does not enter the list until the driver taps ⟳, or reopens EV Guide from the car home screen (a documented quota reset that re-ranks). Quota, not preference (m18, §13).
9. **Anonymous drivers never learn the bay alert exists.** Silence is Apple's rule carried across for one design; Android would have permitted a message.
10. **The bay-alert button can be absent on a deep visit.** `TemplateLedger` R1 removes it when there is not room for both an arm and a disarm (§5.4). Under the likely refresh reading it never fires; §8.3's constant-title fallback retires it entirely if the DHU says otherwise. The alternative is closing the app mid-drive.
11. **Two distinct rates fit the pane; three collapse** to `From 400 RWF/kWh · 3 rates` with the unknown remainder stated (§3.5).
12. **Android Auto is not available in Rwanda.** This entire surface serves no current EV Guide user. It is built for a market the product does not yet serve, and that reasoning belongs in ticket 24's scope call, not in this design.

---

## 13. Inferences, and the open questions in priority order

**Inferences carried in this design** — none is a documented rule, and none may be quoted to a reviewer:

| # | Inference | Where it bites | If it is wrong |
|---|---|---|---|
| 1 | An action-title change inside an otherwise-identical template is still a refresh | §5.2 #7 — costed as +1 in both proofs anyway | §8.3's constant-title fallback fires; R1 retires |
| 2 | The refresh diff is per-screen, not per-host-session | §5.2 #8 — costed as +1 in both proofs anyway | nothing; the proofs already assume it |
| 3 | `ScreenManager` requests only the top screen's template when a stack is seeded | §5.3 — otherwise a notification deep link costs 2, not 1 | post-reset ledger is 2/5 instead of 1/5; still fine |
| 4 | `setOnContentRefreshListener`'s real `@RequiresCarApi` level | §4.1's guard; the free re-rank path | compromise 8 deepens: the list is frozen for the connection, relaunch is the re-rank |
| 5 | `CarAppExtender` / `CarNotificationManager` is the car-notification mechanism, and a POI app's notification is surfaced in the car at all | §4.5 — **and ticket 23's three-function answer** | **blocking — see below** |
| 6 | A device-local vehicle profile needs no account (ADR-0003 gates *sync*) | §7.1's anonymous "free for me" | grammar Q becomes signed-in-only; grammar G is complete without it |
| 7 | `HostValidator` allowlist boilerplate | §2.4 | standard, unverified against the research |
| 8 | 200 km reachability threshold on origin rung 1 | §9.3 | a design call, routed to 19 |

Note that v1's inference *"a pop refunds ≥1 template"* is **not** an inference: *"Going back refunds the quota, by the number of templates popped"* is documented **[hard]**. The residual is whether "templates popped" counts a screen that emitted several — which our screens never do on the counted path. And v1's inference 8 (`-night` resolution from `CarContext`) is **deleted** by §10's single-asset decision.

**Ticket 27's DHU session, in priority order:**

| # | Question | Status |
|---|---|---|
| **1** | **Are a POI app's notifications surfaced on the Android Auto screen at all?** Does `CarAppExtender` + `CarNotificationManager` deliver, and is `IMPORTANCE_HIGH` heads-up permitted for a POI category (historically reserved to messaging and navigation)? | **BLOCKING.** It decides whether ticket 23's three-function `PF-1` answer holds on Android. If POI notifications are filtered, the Android case reduces to two functions and **ticket 23's resolution must be revisited — before ticket 20 files, not at submission.** |
| **2** | Does `ACTION_NAVIGATE` actually reach Google Maps on a real host? | Critical path — Apple Maps cannot navigate in Rwanda, so this is the whole directions story on both platforms |
| 3 | Does an action-title change (`Notify me` → `Stop watching`) consume a template step? | Decides §8.3's fallback and R1's fate |
| 4 | Is the refresh diff per-screen? Push detail, pop, and check whether the identical re-emitted place list consumes a step | Decides whether Proof 1 peaks at 2 or 3 |
| 5 | Does the back-refund equal the templates popped? Walk six push/pop cycles and confirm the 11′ `QuotaGuard` branch is unreachable | Confirms R2 is dead code in practice |
| 6 | Real `@RequiresCarApi` level of `setOnContentRefreshListener`; and does the host draw the ⟳ affordance? | Decides compromise 8's depth |
| 7 | Does `PlaceListMapTemplate` render two text lines while driving, or one? | Decides whether text 2 is ever seen |
| 8 | Does `startCarApp` accept `geo:0,0?q=<lat>,<lng>(<name>)`? | m19 — adopt if yes, keep bare coordinates and record why if no |
| 9 | Real `CONTENT_LIMIT_TYPE_PLACE_LIST` and `…PANE` values on the DHU and on any reachable head unit | Confirms the 6 / 4 floors |
| 10 | Is the ground black in **day** mode on the test head unit? | The one thing §10's single-asset simplification rests on |
| 11 | Is row↔pin correspondence usable with six same-Owner `KAB` labels? | §10.1's fallback to `null` labels |
| 12 | `PlaceListMapTemplate`'s ActionStrip constraint — `SIMPLE` (2) or `MAP` (4)? | Headroom only; the design uses none |

**Pre-submission tasks that are not DHU questions:**

- **[m23]** Grep the pinned `androidx.car.app:1.7.0-rc01` artifact for a `@Deprecated` annotation on `PlaceListMapTemplate` (§0). One command, before this design is called final.
- **[M5, routed to ticket 20 as a hard submission dependency]** (a) Supply a **signed-in demo account** in Play Console → App access and in Apple's review notes, with a script that signs in **on the phone** before connecting — the car screen still never shows a wall; the state is simply already true, so the reviewer sees row 4 and the alert action. (b) **Seed the demo path with reports** so the availability layer is *populated* rather than uniformly Regime 1 when reviewed from outside Rwanda. Without both, a reviewer applying `PF-1` sees a static map, six rows of name + distance + capacity, and one `Directions` button — precisely *"a list of EV chargers"*, the shape both platforms' clauses name. The Kigali origin rung (§9.3) already removes the mock-GPS dependency; these two remove the "two of three functions are invisible" problem.

**Routed back to ticket 19 / `docs/domain-model.md` before the schema locks:**

- **The total grammar** (§3) belongs in `packages/domain` as pure functions — `G(n,f,o,x,u)`, `R(rates)`, `Q(lens)`, and the freshness clause — each returning an ordered variant list. Not three call sites improvising format strings.
- **Android slot typing** for the two-line projection: `rowTitle` (`nameShort` + distance span), `rowPrimaryText` (grammar G/Q + freshness, or capacity in Regime 1), `rowSecondaryText` (droppable).
- **A fixed pane-rows projection** (label/value pairs). Android's detail screen has no projection today; `card-triple` is CarPlay's.
- **The aggregate's `source`** = the single contributing source, or `mixed`; collapsing to the **weakest** (`driver < operator < admin`). **`lastReportedAt`** = the **oldest** contributing `capturedAt`. **Contributors exclude `OutOfService`** (§3.3).
- **Bay-state roll-up** (§3.1) as a named derivation beside decay and propagation.
- **Per-type projections stated non-additively**: `baysOffering(T)` and `freeBaysOffering(T)`, with the documented rule that only one side of the partition is ever counted (§3.6).
- **The car cache schema** carries per-Connector latest reports, never a materialised aggregate (§9.1) — and the car sync payload must too.
- **The car cache carries `isSignedIn`, `notificationsPermitted`, `armedWatches`** — an amendment to car constraint 9, and explicitly **not** a credential.
- The two-line projection takes an optional `viewerConnectorTypes` parameter (§3.6).
- **No reserved compatibility slot** in `stationsNear`; ranking stays total (§6).
- **[m22]** The one-line ruling from ticket 12 on whether a *local* vehicle profile is account-gated.

**Routed to ticket 30:** the arm affordance is always offered to a `canWatch` driver, and "already Free" / "3 already armed" are **refusals with a reason in row 4**, not absences of the button (§8.2) — one-line amendment. Plus §8.3's conditional label amendment. Plus `notificationsPermitted` joins `isSignedIn` in the gate.

**Routed to ticket 15 / ADR-0006:** `android:process=":car"`, the RN-initialisation branch, the op-file / snapshot-swap seam, and the third implementation of the derivation with its shared fixture corpus (§8.4, §9.4).

**Routed to ticket 20:** M5's two submission dependencies above; the demo script arms the watch on the **first** detail visit (before R1 could ever bite).

---

## 14. Answers to the verdict

Every defect, with what changed or why it is rebutted.

### Fatal

**F1 — row count varying with availability / watch state.** **Accepted in full, and generalised.** §1's **Invariant A** now governs the whole document: no template's row *or action* count may vary with availability, freshness, watch state, rate coverage, connector count or profile — only with facts latched for the life of the template instance (sign-in, notification permission, host content limits, ledger headroom at construction). Row 4 is present for every `canWatch` driver and only its *text* varies (§8.2's seven-state ladder). Ticket 30's "arming is only offered when the set is not already Free" is honoured as a rule about the **outcome** (a local refusal with a reason in row 4), not the affordance's presence — routed back to 30 as a one-line amendment. The audit the verdict asked for was run across the whole surface: the Rate row is one row in every regime (§3.5), the Connectors row is one row for any number of types, the place list emits exactly N rows with the radius widening rather than the count shrinking, and the sign-in split is legal because sign-in is latched at Session creation and re-read only on an intent (which resets the quota anyway).

**F2 — the grammar is not total.** **Accepted in full.** §3 replaces v1's five-row table with a specified pure function over three regimes that partition the space: `u = n` (capacity clause, no availability claim), `u = 0` (a total is legitimate), `0 < u < n` (counts only, no total, no *all*). The verdict's three named failures are now impossible: `2 Occupied + 2 Unknown` renders `2 busy · 2 unknown`; `2 Occupied + 2 OutOfService` renders `No free bays · 2 out of service`; `2 Free + 2 Unknown` renders `2 bays free · 2 unknown`. The word *busy* never touches an `Unknown` bay, `OutOfService` is distinct at every count and survives to the shortest variant (§3.4's drop order), and the same discipline is applied to rate (§3.5, m15). The grammar goes to `packages/domain` as a fixture-tested pure function so it is total in code, not only on paper.

### Major

**M3 — aggregate source word.** Accepted, with one refinement. §3.3: `source` is the single contributing source or `mixed`; any variant that must collapse `mixed` collapses to the **weakest** (`driver < operator < admin`); `age` is the **oldest** contributing `capturedAt`. The refinement is that **contributors exclude `OutOfService`** — ADR-0002's own reasoning is that a 30-day declaration and a 2-hour observation are different kinds of claim, and letting a 3-day-old `OutOfService` set the clause would make a 14-minute-old `Free` read as stale. `OutOfService` carries its own age inline on the pane where there is room.

**M4 — multi-gun double counting.** Accepted, and fixed structurally rather than by wording. §3.6: **name exactly one side of a binary partition** — the driver's type by count, the remainder as `other bays` with types listed but never counted by type. `3 GB/T bays` + `1 other bay` = `4` always, because the partition is on *offers this type*. §4.0's worked example now has a dual-gun bay with a propagated occupancy, and §4.3's pane carries `4 bays · 5 plugs` as an explicit line so the two numbers are never conflated. A dual-gun fixture is added to the shared corpus (§9.1).

**M5 — two of three `PF-1` functions invisible to a reviewer.** Accepted, with an extra move. Both of the verdict's fixes are routed to ticket 20 as **hard submission dependencies** (§13): a signed-in demo account signed in *on the phone*, and a seeded demo path with real reports. Beyond that, §9.3's Kigali origin rung means the reviewer no longer needs a mock GPS app or a tap to reach content — the app **opens** on a populated Kigali list, which also removes v1's `Show stations in Kigali` action and the MessageTemplate that hosted it.

**M6 — Android notification eligibility unestablished.** Accepted and promoted. It is now ticket 27's **#1 blocking item**, above `ACTION_NAVIGATE`, with the consequence written down: if POI notifications are not surfaced in the car, Android's `PF-1` case reduces to two functions and **ticket 23's resolution must be revisited before ticket 20 files**. §4.5 also states explicitly that nothing on the surface depends on car delivery — the alert still fires on the phone — so the failure is a review-argument failure, not a functional one.

**M7 — credential for the authenticated write.** Accepted, taking the verdict's preferred option (a) and specifying it. §8.4: the car layer performs **no network I/O and holds no credential**. It appends to a single-writer `car-ops.jsonl`; the main process drains it, POSTs with the token it already holds, and writes the confirmed set back through an atomic snapshot swap. Car constraint 9 is left **intact** rather than amended. Row 4 reads `Alert requested` until the ack lands — an unsynced watch is not `Watching` — and a queued op expires client-side after 2 h, mirroring ADR-0007's rule for stale reports. The iOS twin inherits the same shape, so the Keychain token is never touched by car code either.

**M8 — the car cache must hold raw per-Connector reports.** Accepted. §9.1 specifies the schema: `station / owner / bay / connector / report`, with `report` holding the **latest report per Connector** including `state`, `source`, `capturedAt` and `sourceOnline`. The materialised aggregate may ride along for the phone's own list but is **never the car's render input**, and the car sync payload is routed to ticket 19 accordingly. A fixture whose materialised and device-derived aggregates deliberately disagree is added to the corpus.

**M9 — ranking contradiction.** Accepted; the reservation is **deleted**. §6 keeps `stationsNear` total (distance-first, then availability) and keeps the "never its presence, never its order" rule as the single governing sentence. If compatible-first is wanted later it must become a named second ranking key in ticket 19 **and** the rule sentence must go — not both.

**M10 — unguarded `setCurrentLocationEnabled`.** Accepted, and the underlying problem removed rather than priced. The call is guarded on `checkSelfPermission` and latched (§4.1). More importantly, §9.3's origin ladder always yields an origin, so **the `MessageTemplate → PlaceListMapTemplate` swap the verdict asked us to price and cap no longer exists** — there is no origin-failure screen to swap away from. The car layer never requests a permission, so the toggle-repeatedly failure mode is gone too, and `VI-1` becomes vacuous instead of a string we have to get right.

**M11 — six brand logos vs `IU-1`.** Accepted, and taken further than the verdict proposed. Rather than `TYPE_ICON` markers, markers are **label-only** — no icon, no image, no `setColor` (§10). The surface now carries **exactly one image**, the Owner mark on the detail pane, which is defensibly `IU-1`'s single static context image. Inference 8 is **deleted**: Android Auto's ground is black in day and night, so one light-on-black monochrome asset is correct in both and no `-night` qualifier or host-resolution assumption is needed. The one thing this rests on — that the ground really is black in day mode — is DHU item 10.

**M12 — `DR-2` vs the RN process.** Accepted. §2.1 declares `android:process=":car"`; §9.4 adds the belt-and-braces requirement that `MainApplication.onCreate()` branch on process name, states the cross-process data rules (single writer per file, atomic rename, **no WAL** — Android does not support it across processes), and routes the whole thing to ticket 15 / ADR-0006 as a build-shape constraint. The fallback (gate RN init on a non-car entry point) is named, and §8.4's op-file design means M7's isolation survives either choice.

**M13 — the synchronous `onGetTemplate` "budget".** Accepted; the budget is **deleted**. §9.3: `onGetTemplate` reads last-known synchronously and returns on the same tick. A later fix applies through the content-refresh path, and because the origin ladder never yields "no origin", there is no template swap to price (see M10).

### Minor

**m14 — false character count.** Accepted, recounted. The longest authored string on the surface is **73 characters** — `1 bay free · 1 busy · 1 out of service · 1 unknown · operator, 14 min ago` — with a 37-character shortest variant; the longest *fixed* string is `QuotaGuard`'s 51-character message. v1's "43" was wrong. The ~125-character `VI-1` body is **deleted entirely** rather than split, because §9.3 removes the screen that carried it.

**m15 — rate strings assert coverage they may not have.** Accepted. §3.5's grammar R applies F2's discipline to rate: the denominator is the **confirmed** set of plugs, `From` asserts a floor over the confirmed set with the unknown remainder stated in the same breath, and the denominator is **plugs, not bays**, because a dual-gun bay can carry two rates.

**m16 — the arm never says what `connectorTypes[]` it sends.** Accepted. §8.2: the op carries the local profile's types when one exists, empty (= all) otherwise, and row 4's text 2 says which (`· any plug` / `· GB/T only`). Changing the profile later does not re-scope a live watch.

**m17 — `QuotaGuard` is a dead end.** Accepted. §5.4 R2 gives it one action, `Directions to <last-viewed station>` — the one affordance that leaves the app usefully — and DHU item 5 confirms the branch is unreachable.

**m18 — no re-rank path below the content-refresh API.** Accepted as a defect; **the verdict's second remedy is declined with reasons.** Adding an ActionStrip `Refresh` action would create an **unpriced** quota path: an ActionStrip-driven row-set change is *not* covered by any documented refresh clause, so each tap costs a step, and at ledger 4 the tap would try to put an illegal place list in the 5th slot — a button that must sometimes refuse. The chosen remedy is the verdict's first: **seed the row set from a wider radius, and rely on the launcher relaunch — a documented full quota reset that re-ranks — as the re-rank path.** That is stated as compromise 8 rather than hidden, and the real `@RequiresCarApi` level is DHU item 6 rather than a guessed number.

**m19 — the `geo:` hand-off drops the destination name.** Accepted, with the ordering inverted. §8.1 ships the **bare, documented** `geo:lat,lng` in v1 of the code, because handing `startCarApp` an undocumented URI shape risks a crash on the car screen. The labelled form `geo:0,0?q=<lat>,<lng>(<nameShort>)` is DHU item 8; adopt it if the host accepts it. The mitigation is recorded: the driver confirmed the station by name on the pane one tap earlier.

**m20 — voice is unaddressed.** Accepted. §2.3 carries the decision beside the `SearchTemplate` refusal: out of v1, three reasons (App Actions plumbing lives in the phone app; Assistant's Rwanda coverage is untestable from here; CarPlay forbids voice recording to a charging app, so a voice-first design could not be symmetric).

**m21 — `CONTEXT.md` still gates directions. → REBUTTED.** It does not. The current file reads, verbatim at lines 43–46:

> *"Reads the whole product anonymously, **and gets directions anonymously**; needs an account to save, report, watch, or sync a profile (ADR-0003 as amended by ticket 23 — directions were ungated over an App Store 5.1.1(v) risk)."*

The sentence the verdict quotes ("needs an account to act — directions, saving, reporting, profile sync") is not in the file. The glossary was already updated by ticket 19. Nothing is routed.

**m22 — the anonymous "free for me" story rests on reading ticket 12 narrowly.** Accepted, and the consequence is now stated rather than left implicit. §7.1 names both readings, routes the one-line ruling to ticket 12 before 19 locks, and **states the fallback**: grammar Q becomes signed-in-only, anonymous drivers get grammar G, and nothing else moves — G is complete on its own and is what a reviewer sees either way.

**m23 — verify `PlaceListMapTemplate` is not itself deprecated.** Accepted. §0 carries the exact command and the consequence: a deprecation would not break the design but would reopen §0's calculus about declining `MapWithContentTemplate`.

### Carried over from the CarPlay verdict, not raised here

The twin document's verdict found that the CarPlay design gated the watch affordance on `isSignedIn` alone, so a driver who never granted notification permission could arm a watch that could never be delivered. The same defect was present here and is fixed by the same rule: **`canWatch = isSignedIn && notificationsPermitted`**, latched, silently omitted when false (§8.2). Its sibling — an optimistically-armed row surviving a permanently failing write — is fixed by §8.4's `Alert requested` state and the 2-hour client-side expiry.

---

## 15. The 5-template quota proof, in one place

Restated here so a reviewer of this document does not have to reconstruct it from §5.

**Rules used.** Max 5 templates per task; it counts templates *sent*, not `Screen` instances. The 5th must be `PaneTemplate`, `MessageTemplate`, `SignInTemplate` or `LongMessageTemplate` for a POI app. Exceeding it: *"the host displays an error message and closes the app."* Going back refunds by the number of templates popped. A notification or launcher intent is a **full reset**, even in the foreground. A `PlaceListMapTemplate` is a *refresh* when title, row count and row titles are unchanged (spans excluded) **or** when responding to `setOnContentRefreshListener`; a `PaneTemplate` is a refresh when title, row count and row titles are unchanged.

**What makes the counting work.** Invariant A: the only things that vary at runtime are row **texts**, action **titles**, and `DistanceSpan` values — none of which appear in either documented diff.

| | Required session | Adversarial session |
|---|---|---|
| launch (post-reset) | PLMT **1** | PLMT **1** |
| updates, ticks, ⟳ | refresh **1** | refresh **1** |
| detail | Pane **2** | Pane **2** |
| report lands on detail | refresh **2** | refresh **2** |
| arm watch | — | +1 **3** |
| back | −1 **1** | −1 **2** |
| list re-emit | +1 **2** | +1 **3** |
| detail | Pane **3** | Pane **4** (R1: no watch action) |
| back | — | −1 **3** |
| list re-emit | — | +1 **4** |
| detail | — | Pane **5 / 5** — legal terminal |
| back | — | −1 **4** |
| list would be the 5th | — | **R2 blocks** → `QuotaGuard` Message **5 / 5** — legal terminal |
| directions | leaves at **3 / 5** | leaves at **5 / 5** |

**Peak 3/5 required, 5/5 adversarial, 6 unreachable, every 5th template legal.** Optimistic reading: 2/5 and 4/5. Escape hatch available at every point: a notification tap or a launcher relaunch resets to 1/5.

---

## 16. What changed from v1, and why

| # | Change | Driver |
|---|---|---|
| 1 | **Invariant A** written as a governing rule: no row or action count varies with anything not latched for the template instance's life | F1 — a varying row count is a new template; at 4/5 the host closes the app mid-drive |
| 2 | Row 4 (`Bay alert`) is present for every `canWatch` driver; ticket 30's "only offered when not already Free" becomes a **refusal with a reason in row 4** | F1 |
| 3 | **Invariant B** and §3's total grammar replace v1's five-clause table — three regimes partitioning the space, known-set denominators, `OutOfService` distinct at every count and never dropped from a variant | F2 |
| 4 | Aggregate `source` = single or `mixed`, collapsing to the **weakest**; age = **oldest contributing**; **`OutOfService` excluded from contributors** | M3, plus ADR-0002's own reasoning about declarations vs observations |
| 5 | Per-type counts name **one side of a binary partition**; `4 bays · 5 plugs` on the pane; a dual-gun bay in the worked example and in the fixtures | M4 |
| 6 | Signed-in demo account + seeded demo reports routed to ticket 20 as **hard submission dependencies** | M5 |
| 7 | Android notification eligibility promoted to ticket 27's **#1 blocking** item, with ticket 23's dependency written down | M6 |
| 8 | The car layer performs **no network I/O and holds no credential**; watch writes go through a single-writer op file drained by the main process | M7 — car constraint 9 stays intact |
| 9 | Car cache schema specified: **raw per-Connector latest reports**, never a materialised aggregate | M8 — this is what makes "a stale green is unrepresentable" actually true on the car |
| 10 | The reserved compatibility slot in `stationsNear` is **deleted**; ranking stays total | M9 |
| 11 | `setCurrentLocationEnabled` guarded and latched; **the origin-failure screen and its template swap are deleted** by the Kigali origin rung | M10, M13 — and it removes a template class, a swap, a `VI-1` string, and the reviewer's mock-GPS dependency |
| 12 | Markers are **label-only**; the surface carries exactly one image, on the pane; inference 8 deleted | M11 |
| 13 | `android:process=":car"`, RN-init branch, cross-process data rules, routed to ticket 15 / ADR-0006 | M12 |
| 14 | The 1.5 s origin "budget" is **deleted**; `onGetTemplate` returns on the same tick | M13 |
| 15 | Character counts recounted honestly (73, not 43); the ~125-char `VI-1` body deleted with its screen | m14 |
| 16 | Grammar R gives rate the same totality discipline, denominated in **plugs** | m15 |
| 17 | The arm states its `connectorTypes[]` in row 4 (`· any plug` / `· GB/T only`) | m16 |
| 18 | `QuotaGuard` gains one useful action | m17 |
| 19 | m18's ActionStrip remedy **declined with reasons**; the widened-radius + documented-relaunch remedy chosen and stated as compromise 8 | m18 |
| 20 | Bare `geo:` ships; the labelled form becomes a DHU experiment with the mitigation recorded | m19 |
| 21 | Voice decided out of v1, with three reasons, beside the `SearchTemplate` refusal | m20 |
| 22 | m21 **rebutted** — `CONTEXT.md` already says directions are anonymous | evidence quoted in §14 |
| 23 | m22's fallback wording stated, and the ticket-12 ruling routed before 19 locks | m22 |
| 24 | m23's deprecation grep written as a pre-final command with its consequence | m23 |
| 25 | `notificationsPermitted` joins `isSignedIn` in the watch gate; `Alert requested` is a distinct state from `Watching`; queued ops expire at 2 h | carried across from the CarPlay verdict's D1, which is the same defect in the twin |
| 26 | `TemplateLedger` rewritten as four named rules (R1–R4) with a construction-time latch, and the proof re-run in two readings | F1's interaction with the ledger; §5.6 and §15 |
| 27 | The grammar itself moves into `packages/domain` as fixture-shared pure functions, transcribed once into Kotlin | F2 in code rather than on paper; §9.4's divergence risk |
