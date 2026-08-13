# EV Guide on Android Auto — complete template design

Ticket 18, Android half. Binding inputs: `04-carplay-android-auto-requirements.md` (via the constraint sheet), `/Users/FullTimeStudio/Dev/lab/ev-guide/docs/domain-model.md`, `/Users/FullTimeStudio/Dev/lab/ev-guide/CONTEXT.md`, ADR-0002/0003/0004/0006/0007/0008, tickets 09, 12, 23, 30.

Everything marked **[inferred]** is a derivation, not a documented rule — never quote one to a Play reviewer. **[verify]** items go to ticket 27's DHU session.

---

## 0. The shape of the decision, up front

Android hands a POI app two possible map surfaces. **EV Guide uses `PlaceListMapTemplate` (host-drawn map) and declines `MapWithContentTemplate` (app-drawn surface).** That single choice removes, at once:

- the whole tile pipeline from the car surface (no MapLibre-on-a-`Surface`, no tile fetches, no basemap budget — the host draws Google's map for free),
- `MR-1` (applies only to *apps drawing maps*),
- `AR-1` risk (system bars and cutouts are the host's problem when the host lays out),
- the largest part of the `DR-2`/`DR-3` latency risk (nothing to render, only strings to supply).

The cost: EV Guide's visual identity does not appear on Android Auto beyond one bundled Owner icon per station. That is accepted — it is the same bargain CarPlay forces unconditionally, and taking it on both platforms keeps one design.

**The entire surface has three tap targets:** a station row, `Directions`, and the bay alert. Plus the host's own back and refresh affordances.

---

## 1. Template inventory and Session/Screen structure

### 1.1 Manifest frame

```xml
<service android:name=".car.EvGuideCarAppService" android:exported="true">
  <intent-filter>
    <action   android:name="androidx.car.app.CarAppService" />
    <category android:name="androidx.car.app.category.POI" />   <!-- NOT …CHARGING (deprecated 1.3.0-alpha01) -->
  </intent-filter>
</service>
<meta-data android:name="androidx.car.app.minCarApiLevel" android:value="1" />
<uses-permission android:name="androidx.car.app.MAP_TEMPLATES" />
<!-- deliberately absent: androidx.car.app.NAVIGATION_TEMPLATES -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Library floor `androidx.car.app:1.7.0-rc01` (permission dialogs on Android 14+, no AAOS-15 crash). `minCarApiLevel 1` with **runtime guards** on everything above it, so nothing hard-fails on an old host. Android Automotive OS is a separate artifact and stays out of scope.

### 1.2 Templates used — three, and only three

| Template | Where | Why this one |
|---|---|---|
| **`PlaceListMapTemplate`** | root, "Charging nearby" | POI-exclusive; host draws the map; the only template whose refresh rule has a documented *content-refresh escape hatch* |
| **`PaneTemplate`** | station detail | label/value rows whose **titles are constant**, so every volatile value is a free refresh; and it is a **legal 5th (terminal) template** |
| **`MessageTemplate`** | no-origin / out-of-range only | legal terminal template; the only place a sentence is allowed |

### 1.3 Templates available and deliberately unused

| Template | Verdict |
|---|---|
| `MapWithContentTemplate` | Declined — §0. Would pull in surface rendering, `MR-1`, `AR-1`, tiles. |
| `ListTemplate` / `GridTemplate` / `SectionedItemTemplate` | No map, no `DistanceSpan` mandate to satisfy, nothing the place list doesn't do better. `SectionedItemTemplate` also needs Car API 8. |
| `SearchTemplate` | Not in v1. Browse-by-proximity is the primary access path (car constraint 12); keyboards are frequently unavailable while driving. It is the cheapest future addition (*any* content change counts as a refresh) — revisit when parked-state search is wanted. |
| `TabTemplate` | **Refused.** Its refresh semantics are undocumented, so every tab switch is an unpriced quota risk; and 5 tabs need Car API 9. One task, one root. |
| `SignInTemplate` | **Refused on principle.** No sign-in wall appears on any car screen (ADR-0003 as amended, ticket 23). Also unusable: Google/Apple/magic-link cannot complete on a head unit. |
| `LongMessageTemplate` | Nothing to say at that length while driving. |
| `NavigationTemplate`, `MediaPlaybackTemplate` | Category-locked away from POI. Touching them is a crash. |

### 1.4 Service / Session / Screen

```
EvGuideCarAppService : CarAppService
├─ createHostValidator()      → allowlist from androidx.car.app R.array.hosts_allowlist_sample
│                               (ALLOW_ALL only in debug builds)                         [inferred: standard boilerplate, not in research]
└─ onCreateSession(SessionInfo) → EvGuideSession        (one Session per car connection)

EvGuideSession : Session
├─ onCreateScreen(intent)      → seeds the Screen stack (see §3.5)
├─ onNewIntent(intent)         → re-seeds it — this is the documented quota RESET
├─ onCarConfigurationChanged() → deliberately does NOT invalidate (see §9, TH-1)
└─ owns: CarCacheReader · AvailabilityKt · OriginProvider · WatchClient · TemplateLedger

NearbyScreen  : Screen  → PlaceListMapTemplate  (or MessageTemplate when there is no usable origin)
StationScreen : Screen  → PaneTemplate          (constructed with an opaque stationId)
QuotaGuard    : Screen  → MessageTemplate       (last resort only, §3.6)
```

Supporting native objects (all Kotlin — the car service runs with no React Native runtime attached, see §7.4):

- **`CarCacheReader`** — reads the directory + report snapshot written by the phone app. Non-sensitive directory + availability data only (car constraint 9), plus the two session bits in §6.2.
- **`AvailabilityKt`** — a Kotlin transcription of the ADR-0008 derivation (latest report → decay by source+state → bay propagation), fixture-tested against `packages/domain`'s canonical cases.
- **`OriginProvider`** — last-known coarse location, **never rejecting mock providers** (Play's reviewer-access clause), with a hard budget (§7).
- **`WatchClient`** — the only network write on the surface.
- **`TemplateLedger`** — our own conservative mirror of the host's quota accounting (§3.6).

---

## 2. Every screen, exact rendered text

### 2.0 The worked example

```
Station   name       "Kabisa – SP Remera"          ← Station.name
          nameShort  "SP Remera"                   ← Station.nameShort (the PLACE; operator lives in the marker)
          owner      Kabisa · markerLabel "KAB" · icon @drawable/owner_kabisa (+ -night)
          geo        -1.9556, 30.1044              ← Station.geo (NOT NULL)
Bays      B1  GB/T DC 60 kW  600 RWF/kWh   Free      operator, 14 min ago
          B2  GB/T DC 60 kW  600 RWF/kWh   Occupied  operator, 14 min ago
          B3  Type 2  22 kW  600 RWF/kWh   Free      operator, 14 min ago
          B4  Type 2  22 kW  600 RWF/kWh   Occupied  operator, 14 min ago
Origin    2.4 km away
Projections  baysTotal 4 · baysFree 2 · lastReportedAt now−14 min · source operator
```

### 2.1 S0 — `NearbyScreen` / `PlaceListMapTemplate`

```
┌──────────────────────────────────────────────────────────────┐
│ [icon]  Charging nearby                              ⟳       │  ← header action APP_ICON + content-refresh
├───────────────────────────────┬──────────────────────────────┤
│  2.4 km · SP Remera           │                              │
│  2 of 4 bays free · operator, │        (host-drawn map)      │
│  14 min ago                   │                              │
│  GB/T DC · Type 2             │      [KAB]  [KAB]            │
├───────────────────────────────┤      [EVP]                   │
│  3.1 km · Kisimenti           │                              │
│  All 4 bays busy · driver,    │                              │
│  35 min ago                   │                              │
└───────────────────────────────┴──────────────────────────────┘
```

**Template-level calls**

| Call | Value | Source | Note |
|---|---|---|---|
| `setTitle` | `Charging nearby` | literal | **Constant for the life of the screen** — a title change costs a step |
| `setHeaderAction` | `Action.APP_ICON` | — | root screen |
| `setCurrentLocationEnabled(true)` | — | — | needs `ACCESS_COARSE_LOCATION` |
| `setAnchor(Place(origin))` | driver origin | `OriginProvider` | centres the host map |
| `setOnContentRefreshListener` | re-rank handler | — | `@RequiresCarApi(3)` **[inferred]**, runtime-guarded; the documented free re-rank path |
| `setItemList` | N rows | `stationsNear(origin, N)` | `N = min(getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST), 12)`, **floor 6** |
| ActionStrip | *none* | — | fewer targets while driving |

**Row anatomy** — three slots, and only the first two are load-bearing.

| Slot | API | Rendered (known) | Projection | Rules honoured |
|---|---|---|---|---|
| title | `setTitle(CarText)` with `DistanceSpan` on a placeholder char | `2.4 km · SP Remera` | **two-line**.`nameShort` + computed distance | mandatory `DistanceSpan` (title accepts only Distance/Duration spans); **spans are excluded from the refresh diff → the distance may tick live for free**; single-variant, so the diff is trivially stable |
| text 1 | `addText(CarText+variants)` | `2 of 4 bays free · operator, 14 min ago` | aggregate `baysFree`/`baysTotal` + `lastReportedAt` + `source` | availability **never in a title**; freshness alongside as its own clause |
| text 2 | `addText(CarText+variants)` | `GB/T DC · Type 2` | `Connector.type` set | **expendable** — designed to be dropped by a host that renders one text line |
| metadata | `setMetadata(Metadata(Place(CarLocation, PlaceMarker)))` | pin `KAB` + Kabisa icon | `Owner.markerLabel`, `Owner.icon` | a row may carry a marker **or** an image, never both → no `setImage` anywhere |
| tap | `setOnClickListener { push(StationScreen(id)) }` | — | opaque `stationId` | *"information-only rows not allowed"* |

**`CarText` variants, longest → shortest** (the sanctioned length mechanism; there is no published character budget):

```
text1  "2 of 4 bays free · operator, 14 min ago"
       "2 of 4 free · operator, 14 min"
       "2/4 free · 14 min"
text2  "GB/T DC · Type 2"
       "GB/T · T2"
```

**The availability clause grammar** (all from the derived aggregate; the projection is the only input):

| Situation | text 1 |
|---|---|
| some bays free | `2 of 4 bays free · operator, 14 min ago` |
| none free | `All 4 bays busy · driver, 35 min ago` |
| mixed with OOS | `1 of 4 free · 1 out of service · operator, 14 min` |
| all OOS | `All 4 bays out of service · operator, 3 days ago` |
| **Unknown** | `4 bays · GB/T DC, Type 2` (see §5) |

Source words: `operator` · `driver` · `EV Guide` (admin). Age: `just now` · `14 min ago` · `3 h ago` · `6 days ago`.

### 2.2 S0 — the all-Unknown variant (the majority row)

```
┌───────────────────────────────┐
│  2.4 km · SP Remera           │   title  — unchanged
│  4 bays · GB/T DC, Type 2     │   text1  — capacity replaces availability
│  No recent report             │   text2  — the "we don't know" statement, in the EXPENDABLE slot
└───────────────────────────────┘
```

The row still leads with a fact, still carries its mandatory distance, still opens a complete listing. The word *Unknown* does not appear, nothing is greyed, nothing apologises — and on a host that renders one text line, the "no recent report" line is the thing that falls off, never the capacity.

### 2.3 S1 — `StationScreen` / `PaneTemplate`, known + signed in

```
┌──────────────────────────────────────────────────────────────┐
│ ←   Kabisa – SP Remera                                       │
├──────────────────────────────────────────────┬───────────────┤
│  Availability                                │               │
│  2 of 4 bays free                            │   [ Kabisa ]  │
│  Operator report · 14 min ago                │               │
│                                              │               │
│  Connectors                                  │               │
│  2 × GB/T DC · 60 kW                         │               │
│  2 × Type 2 · 22 kW                          │               │
│                                              │               │
│  Rate                                        │               │
│  600 RWF/kWh · all bays                      │               │
│  Confirmed 12 days ago                       │               │
│                                              │               │
│  Bay alert                                   │               │
│  Not watching                                │               │
│  One alert, next 2 hours                     │               │
├──────────────────────────────────────────────┴───────────────┤
│   [ Directions ]   [ Notify me when a bay frees up ]         │
└──────────────────────────────────────────────────────────────┘
```

| Slot | Rendered | Projection / field | Rule |
|---|---|---|---|
| `setTitle` | `Kabisa – SP Remera` | `Station.name` (full form — there is room here) | constant |
| `setHeaderAction` | `Action.BACK` | — | |
| `Pane.setImage` | Kabisa mark, `CarIcon` `TYPE_RESOURCE` | `Owner.icon` | `IU-1`'s *single static context image*; day/night via `-night` qualifier |
| row 1 title | `Availability` | literal **label** | **stable title ⇒ a fresh report landing while this pane is open is a free refresh** |
| row 1 text1 | `2 of 4 bays free` | derived aggregate | |
| row 1 text2 | `Operator report · 14 min ago` | `source` + `lastReportedAt` | freshness as its own axis |
| row 2 title | `Connectors` | label | |
| row 2 text1/2 | `2 × GB/T DC · 60 kW` / `2 × Type 2 · 22 kW` | `Connector.type`, `.powerKw` | ≥3 types → `2 × GB/T DC · 60 kW` / `+2 more` |
| row 3 title | `Rate` | label | |
| row 3 text1/2 | `600 RWF/kWh · all bays` / `Confirmed 12 days ago` | `ratePerKwhRwf`, `rateConfirmedAt` | two distinct rates fit two lines; three or more → `From 600 RWF/kWh · 3 rates` |
| row 4 title | `Bay alert` | label | **signed-in only** |
| row 4 text1 | `Not watching` → `Watching · until 14:05` | Watch state | changes freely; the row title never does |
| row 4 text2 | `One alert, next 2 hours` | ticket 30 contract | states one-shot + 2 h expiry without a settings screen |
| pane action 1 | `Directions` | — | **anonymous, always, unconditional** |
| pane action 2 | `Notify me when a bay frees up` → `Stop watching` | Watch | signed-in only; label settled by ticket 30; variants `Notify me` / `Alert me` **[inferred: `Action` titles accept `CarText` variants]** |
| ActionStrip | *none* | | |

Row count is capped by `CONTENT_LIMIT_TYPE_PANE` — **floor 4**, which is exactly the signed-in row set. Anonymous drivers get 3 (row 4 is absent, not disabled). Rows are ordered load-bearing-first so a host with a lower limit loses the least.

### 2.4 S1 — the all-Unknown variant, anonymous

```
┌──────────────────────────────────────────────────────────────┐
│ ←   Kabisa – SP Remera                                       │
├──────────────────────────────────────────────┬───────────────┤
│  Availability                                │               │
│  Not reported recently                       │   [ Kabisa ]  │
│  4 bays · GB/T DC, Type 2                    │               │
│                                              │               │
│  Connectors                                  │               │
│  2 × GB/T DC · 60 kW                         │               │
│  2 × Type 2 · 22 kW                          │               │
│                                              │               │
│  Rate                                        │               │
│  No confirmed rate                           │               │
├──────────────────────────────────────────────┴───────────────┤
│   [ Directions ]                                             │
└──────────────────────────────────────────────────────────────┘
```

Three deliberate choices: `Not reported recently` states EV Guide's knowledge, not the operator's failure; the second line answers the question the first raises by showing what *is* known; `No confirmed rate` (not "not published") avoids making a claim about a licensee's RURA Art. 27(2) compliance. A rate past its 90-day window is treated exactly like a decayed availability — the number is not shown at all.

### 2.5 S2 — `MessageTemplate`, the two origin failures

**No usable origin** (root screen renders this instead of the place list):

```
Title    Charging nearby
Message  Location isn't available yet.
         Android Auto asks for location permission on your phone.
         Check it only when it's safe to do so.              ← VI-1, verbatim intent
Actions  [ Show stations in Kigali ]
```

**Origin known, nothing in range** (the US reviewer without mock GPS; a driver in a border district):

```
Title    Charging nearby
Message  No charging stations within 200 km.
Actions  [ Show stations in Kigali ]
```

That single action is also the reviewer's one-tap path to real content, and it is not a hidden demo mode — it is an honest affordance for any driver outside the covered area. Tapping it re-invalidates the same `NearbyScreen`, which then emits the place list.

### 2.6 The bay-watch notification

```
Channel   ev_guide_bay_alerts, IMPORTANCE_HIGH
Title     A bay just freed up
Text      SP Remera · reported by an operator
Tap       PendingIntent → EV Guide car app, station detail for stationId
```

Posted through `CarNotificationManager` with `androidx.car.app.notification.CarAppExtender` **[inferred — the research did not cover the car-notification API surface; verify]**. `IN-1` is satisfied because the driver explicitly asked about this station within the last two hours; `NA-1` is satisfied trivially (nothing to advertise, no payments, ever). One notification per watch — no repeat-fire path exists, so no digest, quiet hours or rate limiter is built. The tap is an intent, and therefore **resets the template quota** (§3.5).

---

## 3. The screen graph against the 5-template quota

### 3.1 Graph

```
        launcher / notification intent  ── resets quota ──┐
                                                          ▼
   ┌──────────────────────────────────────────────  S0  NearbyScreen  ───────────────┐
   │                                              PlaceListMapTemplate                │
   │   ⟳ content refresh (free re-rank)  ↺                                            │
   │   delta sync lands                  ↺                                            │
   │                                                                                  │
   │             row tap ▼ push                        ▲ back / pop                   │
   │                                                                                  │
   │   ┌───────────────────────────  S1  StationScreen  ─────────────────────────┐    │
   │   │                              PaneTemplate                               │    │
   │   │   report lands → row text changes            ↺  free                    │    │
   │   │   arm / disarm watch → row text + action     ↺  free [inferred] or +1   │    │
   │   │                                                                          │    │
   │   │   [ Directions ] ──► startCarApp(ACTION_NAVIGATE) ──► leaves EV Guide     │    │
   │   └──────────────────────────────────────────────────────────────────────────┘    │
   └──────────────────────────────────────────────────────────────────────────────────┘

   S2 MessageTemplate replaces S0's template when there is no usable origin.
```

Maximum depth: **2 screens**, well inside the 5-screen stack cap and `AC-1`. A common task — find a nearby charger and drive to it — is **2 taps** (row, Directions), inside the *SHOULD* of 2–3 steps, not merely the *MUST* of ≤5. No flow ends on a list template.

### 3.2 Cost of every transition

| # | Trigger | What we send | Documented class | Cost |
|---|---|---|---|---|
| 1 | Session start from launcher | `PlaceListMapTemplate` | first template of the task | **+1** (intent resets to 0 first) |
| 2 | Delta sync changes availability | same PLMT — title, row count, row titles all unchanged | **refresh** | **0** |
| 3 | Distance ticks down | same PLMT, only `DistanceSpan` differs | **refresh** — spans excluded | **0** |
| 4 | Driver taps ⟳ | PLMT with a **different row set** | **refresh** — documented `setOnContentRefreshListener` exception | **0** |
| 5 | Row tap | `PaneTemplate` | new template | **+1** |
| 6 | Report lands while on detail | same Pane — title, row count, row titles unchanged | **refresh** | **0** |
| 7 | Arm / disarm watch | same Pane, one row text + one action title changed | refresh **[inferred]**; action diffing is undocumented | **0 or +1** |
| 8 | Back | pop S1 → refund; S0 re-emits PLMT | refund documented; the re-emit is a refresh under a per-screen reading, a step under a global one | **−1, then 0 or +1** |
| 9 | Directions | `startCarApp(Intent(ACTION_NAVIGATE, "geo:…"))` | not our template; task is left | **0** |
| 10 | Notification tap | seed `[S0, S1]`, host requests only the top template | **RESET**, then +1 | **→1** |
| 11 | Relaunch from car home (`EP-2`) | seed `[S0]` or `[S0, S1]` | **RESET**, then +1 | **→1** |
| 12 | Day → night | *nothing* — icons are `TYPE_RESOURCE`, host resolves `-night` | — | **0** |
| 13 | No origin / empty area | `MessageTemplate` | new template | **+1** |

### 3.3 Proof: the required session cannot exhaust the quota

Session: **browse → detail → back → browse → detail → navigate**, counted under the *pessimistic* reading of every undocumented point (every re-emit is a step; a pop refunds exactly one; arming costs a step).

| Step | Action | Ledger |
|---|---|---|
| 1 | launch → PLMT | **1 / 5** |
| 2 | any number of availability updates, distance ticks, ⟳ re-ranks | **1 / 5** |
| 3 | tap row → Pane | **2 / 5** |
| 4 | availability changes on detail | **2 / 5** |
| 5 | back → pop refunds 1 | **1 / 5** |
| 6 | S0 re-emits PLMT | **2 / 5** |
| 7 | tap row → Pane | **3 / 5** |
| 8 | Directions → `startCarApp` | **3 / 5**, app leaves |

**Peak 3 of 5, two in hand.** The optimistic reading peaks at 2.

Worst realistic session — the same walk with a watch armed on *both* detail screens, every inference resolving against us:

| Step | Ledger |
|---|---|
| launch PLMT | 1 |
| Pane | 2 |
| arm watch | 3 |
| back (−1) | 2 |
| PLMT re-emit | 3 |
| Pane | 4 |
| arm watch | **5 / 5** |

Five templates, and **the fifth is a `PaneTemplate` — one of the four classes legally permitted as the terminal template for a POI app.** Directions then leaves the app. The design survives its own worst case exactly, and the two mechanisms in §3.5/§3.6 mean it never has to.

### 3.4 Why the live layer is free

Every volatile value on this surface — availability, freshness, distance, watch state — sits in a slot the refresh rules exclude from the diff:

- **on S0**: distance is a *span* (excluded); availability is *text*, never a title; the row *set* is frozen for the screen's lifetime and changes only through the documented content-refresh path.
- **on S1**: every row title is a constant label (`Availability`, `Connectors`, `Rate`, `Bay alert`); the values are text.

So a report arriving from the operator app repaints both screens at **zero quota cost**, indefinitely. This is the reason the pane rows are label/value rather than the more natural `2 of 4 bays free / Operator, 14 min ago` — the natural form would put a volatile string in a row title and burn a step every time a bay changed hands.

Corollary rule: **only the top screen may call `invalidate()`.** A background `NearbyScreen` buffers changes and applies them on `onResume`, which keeps its row set byte-identical across a down-up round trip and lets the re-emit qualify as a refresh under the per-screen reading.

### 3.5 The two resets, used deliberately

Both documented resets are load-bearing here, not incidental:

- **Notification intent** — a bay-watch firing deep-links to `StationScreen`. `onNewIntent` seeds the stack `[NearbyScreen, StationScreen]` so *back* still works, and because the host only requests the **top** screen's template **[inferred]**, seeding two screens costs one template. Post-reset ledger: **1/5**.
- **Launcher intent** — returning to EV Guide from Google Maps via the car home screen. This is also how `EP-2` is satisfied: the Session remembers the last-viewed `stationId` for the connection and re-seeds `[Nearby, Station]`, so relaunch resumes where the driver was rather than dumping them at a list.

### 3.6 `TemplateLedger` — the safety valve

EV Guide counts its own sends under the pessimistic rules (a send is a step unless it *provably* meets a documented refresh clause). Two rules fire off that count, and both exist only as defence against accounting we cannot observe:

1. **At 4/5, the next `PaneTemplate` omits the watch action** and offers only `Directions` — the action that leaves the app — so nothing on screen can demand a sixth template.
2. **Never emit a `PlaceListMapTemplate` at 4/5.** A place list is *not* a legal 5th template; if a pop's refund does not bring the ledger below 4, `QuotaGuard` emits a `MessageTemplate` (legal 5th) reading `Open EV Guide again from the car screen to keep browsing.` — a head-unit instruction, not a phone instruction, so it stays inside Apple's guideline 2 as well.

**[inferred]** Rule 2 guards a failure mode that only exists if the back-refund is smaller than documented. It should cost nothing in practice; verify on the DHU by walking six push/pop cycles.

`isAppDrivenRefreshEnabled()` is probed but **never depended on** — it returns `false` on host-call failure, is regional and OEM-dependent, and is absent on JAMA-affiliated vehicles. Adaptive task limits, if present, are pure headroom.

---

## 4. Per-connector availability in a row, and "free for me"

### 4.1 The arithmetic that fits

Two visible lines, one already spent on the mandatory distance. Per-connector state cannot be rendered per row — the domain model already settled this: per-connector rows are the **filter dimension**, the aggregate is the **display**.

The aggregate is a *bay* count, which is what bay propagation makes meaningful: a bay is free iff no connector on it is effectively Occupied and at least one is effectively Free. `2 of 4 bays free` is therefore a true statement about parking positions a driver can occupy — not a connector count that double-counts a two-gun pedestal.

### 4.2 "Free for me": qualify, never filter

The driver's connector set can come from three places, in priority order:

1. `EnergyProfile.getEvConnectorTypes()` — Car API 3, mapped at the edge to EV Guide's OCPI enum. **Expect `STATUS_UNIMPLEMENTED` most of the time** on Android Auto, and never persist the platform integer.
2. A **device-local** vehicle profile set in the phone app. **[inferred, routed to 19/12]** ADR-0003 gates profile *sync* behind an account; it does not gate a local profile. This distinction is what lets "free for me" work for an anonymous driver on a car screen.
3. Nothing — the normal case.

The rule, which follows directly from the constraint sheet's *design the car screens so the driver's connector is never assumed*:

> **The profile changes the wording of the row, never its presence and never its order.**

| Profile | text 1 | text 2 |
|---|---|---|
| none | `2 of 4 bays free · operator, 14 min ago` | `GB/T DC · Type 2` |
| GB/T DC | `1 of 2 GB/T bays free · operator, 14 min ago` | `Also 2 Type 2 bays` |
| GB/T DC, station is Type 2 only | `No GB/T bays here` | `2 of 2 Type 2 free · operator, 14 min ago` |

Three properties fall out. A **stale or wrong profile is visible** — the row says *GB/T*, so a driver who changed cars sees why the numbers look odd, instead of silently losing stations. An **incompatible station stays in the list and says so**, which is exactly ticket 09's requirement that a GB/T driver at a Type 2 + CCS2 site sees incompatibility even with a bay standing empty. And the **load-bearing fact occupies the durable slot**: incompatibility is in text 1, detail in the expendable text 2.

**One addition to `stationsNear`, routed to 19:** when a profile exists and none of the first N−1 rows carries a matching connector, the **last slot is reserved for the nearest compatible station**. This never hides, never reorders the top of a distance-first ranking, and fixes the pathological case where all six nearest stations are the wrong plug. It is the smallest rule that keeps distance-first ranking honest under a six-row floor.

### 4.3 On the detail screen

`Connectors` is its own row (types, counts, kW) and the availability row's second line carries the per-type split when the count is small enough:

```
Availability
2 of 4 bays free
1 GB/T DC · 1 Type 2 · operator, 14 min ago
```

Beyond two types the split collapses to the aggregate plus freshness. There is no per-connector screen — it would be a third template for information a driver cannot act on differently while driving.

---

## 5. Unknown and stale — the majority case

There is no *stale* state to render: past its decay window a reading **is** `Unknown` (driver 2 h, operator 6 h, `OutOfService` 30 d), and a source declaring itself offline is `Unknown` immediately regardless of recency. Within the window, age is shown and does the work — `2 of 4 bays free · driver, 1 h ago` is a different sentence from `… driver, 2 min ago` without needing a different state.

**The four rules for `Unknown` on this surface:**

1. **The availability clause is replaced by a capacity clause, not by an apology.** Row text 1 becomes `4 bays · GB/T DC, Type 2`. The listing is complete, not degraded.
2. **The words "we don't know" live in the expendable slot.** Text 2 reads `No recent report`, so a host that renders one text line drops the not-knowing before it drops the knowing. On the detail screen, where there is room, the row reads `Availability / Not reported recently / 4 bays · GB/T DC, Type 2`.
3. **A decayed value is never shown, in any form** — not greyed, not parenthesised, not as "last seen free 3 days ago". The derivation runs at render time on the device, so a stale green is impossible by construction rather than by discipline.
4. **`Unknown` gets no colour, no icon, no marker change, and no motion.** `SA-1` forbids animation outright, and with ~87 % of the country unknown, any distinguishing treatment would render the map as a field of failure — the precise outcome ADR-0002 forbids.

**Consequence for the map marker:** the `PlaceMarker` encodes **Owner only, never availability**. Colour-coding pins would (a) make the common case a sea of grey, (b) put information in colour alone, against `VD-1`'s contrast intent, and (c) add a channel that can disagree with the text. One channel, one truth.

**Freshness for an aggregate** — the projection's `lastReportedAt` is defined here as the **oldest** report backing the displayed aggregate, so the age shown is the age of the stalest fact in it. **[routed to 19 — the domain model names the field without defining min or max.]**

---

## 6. Anonymous directions, and where the watch appears

### 6.1 Directions — ungated everywhere, on every path

`Directions` is a `PaneTemplate` action, present on every station detail, for every driver, signed in or not. No prompt, no sheet, no explanation, no deferred sign-in. ADR-0003's amendment (via ticket 23) removed the gate everywhere, and the car surface is why.

```kotlin
carContext.startCarApp(
  Intent(CarContext.ACTION_NAVIGATE, Uri.parse("geo:-1.9556,30.1044"))
)
```

- Coordinates, **never** a place name — Rwandan station names are not in Google's places index, and ADR-0004 fixes `lat,lng` as the deep-link form.
- **Never name a component** — `startCarApp` throws `SecurityException` if you target an app explicitly. The recipient is the host's default navigation app (= the last navigation app the user launched), which cannot be targeted or predicted. **[open: no Google page guarantees Google Maps is the receiver — ticket 27's DHU test.]**
- No route, maneuver, ETA or polyline is modelled anywhere on this surface. There is no route entity, and drawing one would need the NAVIGATION category.
- `Directions` is never gated on the route preview, which does not exist on the car surface at all (that is a phone screen, ADR-0004).

There is no per-row directions button: `PlaceListMapTemplate` rows use the `FULL_LIST` preset, which permits **zero** row actions. Directions is reached in exactly two taps.

### 6.2 The watch — signed-in only, and silent otherwise

Per ticket 30: arm/disarm on the station detail, label `Notify me when a bay frees up`, plus an armed-state row. Placement: pane action 2 + pane row 4.

Visibility rules:

| Condition | Row 4 | Action 2 |
|---|---|---|
| anonymous | absent | absent |
| signed in, watched set already Free | absent | absent (ticket 30: arming is only offered when the set is not already Free) |
| signed in, 3 watches already armed | present, text `3 alerts already running` | absent |
| signed in, armable | `Not watching` | `Notify me when a bay frees up` |
| signed in, armed | `Watching · until 14:05` | `Stop watching` |

**Anonymous drivers are told nothing about the feature.** No "sign in to get alerts", no disabled control. Apple's guideline 2 forbids instructing phone manipulation and the settled reading is that silent omission is the safe form; carrying it to Android keeps one design, at the cost of a discoverability loss on a platform that would have permitted the message (`VI-1`). **[inferred, and flagged as a compromise.]**

**Arming responds locally and reports asynchronously — with no extra template.** The tap flips row 4's text immediately (`DR-1` satisfied in milliseconds), `WatchClient` POSTs behind it, and the outcome lands as another row-text change: `Watching · until 14:05` or `Couldn't arm the alert`. Because row *titles* are constant, all of that is a free refresh. Nothing is claimed before the server acks, and no `MessageTemplate` is spent on a routine outcome.

### 6.3 The user-scoped data problem — a compromise to route back

Ticket 30 requires the car surface to know two things the settled car cache is not allowed to hold: **whether anyone is signed in**, and **which stations have an armed watch**. Car constraint 9 says the car surface reads only non-sensitive directory + availability data.

Design: the cache gains exactly two fields — `isSignedIn: Boolean` and `armedWatches: [(stationId, expiresAt)]`, at most three entries. No user id, no email, no display name, and **never the push token** (ticket 30 §5 is explicit; on iOS it stays behind `kSecAttrAccessibleWhenUnlocked*` where the car cannot read it). Station ids are public data and the boolean is not identifying.

**This is an extension of car constraint 9 and must be recorded in `docs/domain-model.md` before the schema locks.** Flagged, not smuggled.

---

## 7. `DR-1` / `DR-2` / `DR-3` — what is cached, what may touch the network

The governing rule: **no car screen has a loading state as its normal first paint.**

### 7.1 What is served from cache, always

| Screen | Painted from |
|---|---|
| S0 row set, distances, availability, freshness | `CarCacheReader` + `AvailabilityKt` over the local snapshot |
| S0 map, pins, panning, clustering | the **host** — EV Guide fetches no tiles at all |
| S1 every row and both actions | the same cache; a station detail is fully materialised locally |
| Marker icons, pane image | bundled `TYPE_RESOURCE` drawables — remote URLs cannot be handed to the car in any case |

ADR-0007's **bundled directory snapshot** means even a first run with zero connectivity paints a full list, with every availability honestly `Unknown`. `DR-2` (launch ≤ 10 s) and `DR-3` (content ≤ 10 s) are met by construction, not by a fast network.

### 7.2 What may touch the network — two things

| Call | When | If it never returns |
|---|---|---|
| `changedSince(cursor)` delta sync | after the first template is on screen, behind the browse list | nothing is missing; values simply age and the decay renders them honestly |
| `WatchClient` arm / disarm | on the watch tap only | row 4 says `Couldn't arm the alert`; nothing else on the surface is affected |

Neither is ever awaited by a template build.

### 7.3 The origin budget (`DR-2`)

`OriginProvider` takes the **last known coarse location** with a hard **1.5 s** budget and never requests a fresh fix on the launch path. Ladder: last known fix → origin persisted by the phone app → §2.5's `MessageTemplate`. A guessed origin is never substituted silently, because wrong distances are worse than an absent list. Mock providers are **never rejected** — Play's reviewer-access clause requires a mock GPS app to work, and `stationsNear` takes an arbitrary origin precisely so no code path hardcodes "device location".

### 7.4 The architectural consequence (`DR-2`) — routed to 15/19/05

`CarAppService` starts when the car connects, with **no React Native runtime attached**. Booting Hermes to build the first template would put a JS bundle load on the `DR-2` path and make the surface fragile.

So the car layer is **pure Kotlin over a native-readable projection of the cache** (SQLite/flat file written by the phone app on every sync), and the ADR-0008 derivation exists a **third time** — server, device (TypeScript), and now car (Kotlin). ADR-0008's guarantee is *"run identically on server and device"*; this adds a third implementation that can drift. Mitigation: one shared fixture corpus (decay boundaries, bay propagation, offline-source override, mixed OOS) executed by both `packages/domain`'s suite and the Kotlin suite, with the fixtures owned by `packages/domain`. **This is a real cost and belongs in the ticket 15 / ADR-0006 record, not in a code comment.**

---

## 8. `PlaceMarker` labels — the one hard character limit

```kotlin
val marker = PlaceMarker.Builder()
    .setIcon(CarIcon.Builder(IconCompat.createWithResource(ctx, owner.iconRes)).build(),
             PlaceMarker.TYPE_IMAGE)                       // 72×72 dp; setColor illegal with TYPE_IMAGE
    .apply { owner.markerLabel?.takeIf { it.length in 1..3 }?.let { setLabel(it) } }
    .build()
```

- **`MAX_LABEL_LENGTH = 3`, and `setLabel` throws above it.** A four-character label is not a layout bug, it is a crash on the car screen — the worst failure this product can have. Spans in the label are ignored.
- **The label is authored on `Owner`, never derived.** "Kabisa – SP Remera" has no mechanical three-character abbreviation, and the names that break a derivation are exactly the ones nobody tests ("e-Mobility Rwanda Ltd" → "E-M").
- **Icon and label are redundant encodings of the same fact** (which Owner). If the host renders only one, the driver still learns the brand. This redundancy is what makes the undocumented host choice harmless.
- **Day/night:** `TYPE_RESOURCE` icons with `res/drawable` + `res/drawable-night` variants, resolved from `CarContext`'s own configuration **[inferred]** — which is why a day→night transition costs zero templates (§3.2 #12). Authored ≥ 36 dp effective, contrast-checked against Android Auto's black ground.

### When the label is missing

Defence in depth, three layers, and **no layer ever invents one**:

1. **Schema** — `CHECK (char_length(marker_label) BETWEEN 1 AND 3)`, `NOT NULL`, on `Owner`. An Owner without a label cannot exist, so a Station (which has exactly one Owner, `NOT NULL`) always has one.
2. **Sync payload** — the writer validates; a malformed label is **dropped from the payload**, never clamped into something misleading, and never causes the station to be dropped (a station missing a pin label is still a complete listing).
3. **Runtime** — `takeIf { it.length in 1..3 }`; on failure `setLabel` is simply not called. The documented behaviour of a null label is that **the host picks its own scheme** (typically indices), which is a graceful, useful fallback rather than a blank pin.

**Open tension [verify on the DHU]:** the host's default numeric labels give an unambiguous row↔pin correspondence that `KAB` repeated four times does not. The settled decision puts `Owner.markerLabel` in that slot and this design honours it; if the DHU shows that setting a label *suppresses* the Owner icon, or that correspondence is genuinely lost with six pins on screen, the fallback is to pass `null` and let Owner ride on the icon alone. That is a ticket-27 finding, not a design change to make blind.

---

## 9. Constraint → satisfaction

| Constraint | How this design satisfies it |
|---|---|
| `CHARGING` category deprecated | `androidx.car.app.category.POI` only; `CHARGING` never appears |
| Declare `MAP_TEMPLATES`, not `NAVIGATION_TEMPLATES` | §1.1 manifest; `NavigationTemplate` never constructed |
| Library ≥ `1.7.0-rc01` | pinned; permission dialogs correct on Android 14+ |
| `PlaceListMapTemplate` is POI-only; `NavigationTemplate` forbidden | root uses the POI-exclusive template; no navigation template exists in the code |
| Row ≤ 2 text lines | title + text1 + **expendable** text2; everything load-bearing survives at one text line |
| No `Toggle` in a place-list row | the watch is a `PaneTemplate` action, not a row toggle |
| Row may not have both image and marker | rows carry `Metadata(Place(marker))` and **never** `setImage` |
| `IMAGE_TYPE_LARGE` forbidden in the place list | no row images at all |
| `ItemList` not selectable | rows are click-through to detail; no selection group |
| **Every non-browsable row must carry a `DistanceSpan`** | span on the row **title** (the only slot besides text that accepts it), on every row, always |
| Every row must have an action | every row pushes `StationScreen`; no information-only rows |
| `setCurrentLocationEnabled` needs location permission | `ACCESS_COARSE_LOCATION`; disabled and the screen still works without it (§2.5) |
| `CONTENT_LIMIT_TYPE_PLACE_LIST` floor **6** | queried at runtime, capped at 12, **designed at 6**; the tail is silently dropped by the host and the design assumes it |
| `CONTENT_LIMIT_TYPE_PANE` floor **4** | exactly 4 rows signed-in, 3 anonymous, ordered load-bearing-first |
| `Row.setTitle` accepts only Distance/Duration spans | the only span used anywhere is `DistanceSpan`, in a title |
| ActionStrip titles accept no spans | no ActionStrip anywhere on the surface |
| `PlaceMarker.MAX_LABEL_LENGTH = 3`, throws above | §8's three-layer guard; label authored on `Owner`, never derived |
| `TYPE_ICON` 64 dp / `TYPE_IMAGE` 72 dp; `setColor` illegal with `TYPE_IMAGE` | `TYPE_IMAGE`, contrast baked into the asset, no `setColor` call |
| No documented character limits; use `CarText` variants | variants (longest→shortest) on every row text and every action title; titles kept single-variant so the refresh diff stays stable; authored `nameShort`, never mechanical truncation |
| 120-char glanceability guidance | longest authored string is 43 characters |
| `CarIconConstraints`: no `TYPE_URI` | all icons `TYPE_RESOURCE`, bundled; Owner is a bounded enumerable set, which is why this is possible |
| `IU-1` — no images except one static context image | one Owner mark per station as the pane image; `Photo` never reaches a car surface |
| `SA-1` — no animated elements | nothing animates; no spinner, no pulsing "live" dot, no availability transition |
| `ST-1` — no auto-scrolling text | overlong names are handled by `nameShort` + variants, never by marquee |
| `ActionsConstraints`: `BODY` 2, `ROW` 2 | 2 pane actions max (`Directions`, watch); zero row actions on the place list (`FULL_LIST` permits none) |
| **5-template quota**, host closes the app on exhaustion | §3.3 proof, peak 3/5 in the required session, 5/5 in the adversarial one |
| 5th template must be Pane/Message/SignIn/LongMessage | the deepest template is always a `PaneTemplate`; `TemplateLedger` forbids emitting a place list at 4/5 |
| Refresh rules (title + row count + row titles; spans excluded) | every volatile value lives in a span or in text; row titles are constant labels; the row set is frozen for the screen's lifetime |
| Content-refresh listener exception | the ⟳ affordance is the *only* path that changes the row set, and it is documented free |
| Adaptive task limits unreliable | probed, never depended on; design assumes `false` |
| Throttling, no published interval | no periodic invalidation at all — repaints are event-driven off cache changes |
| 8-second dwell before auto-transition | nothing auto-transitions; every transition is a tap |
| Screen stack cap 5 | maximum depth 2 |
| `PF-1` — meaningful functionality relevant to driving | ranked live availability with freshness · anonymous one-tap directions hand-off · bay-watch alert. The directory is the substrate; these three are the visually primary actions (ticket 23) |
| `PC-1` — no features outside the app type | no saving, no reporting, no settings, no profile, no photos on the car surface |
| `EP-1` — works as listed | the Play listing describes exactly these three functions |
| `EP-2` — restores state on relaunch | Session remembers the last-viewed `stationId` and re-seeds `[Nearby, Station]` |
| `AR-1` — not obstructed by bars/cutouts | host-drawn templates; EV Guide never lays out pixels |
| `AD-1` / `NA-1` — no ads | none, ever; no payments and no monetisation exist in the product |
| `IN-1` — notifications relevant to the driver | one notification type, fired only on a report-driven transition into Free, only for a station the driver asked about in the last 2 h |
| `VI-1` — safety message when the phone is needed | §2.5's *"Check it only when it's safe to do so"* — **and** the flow still completes without the phone (§10) |
| `DR-1` ≤ 2 s | every tap is local: push a cached Pane, fire an Intent, or flip a row's text |
| `DR-2` ≤ 10 s | Kotlin-only car layer, bundled snapshot, 1.5 s origin budget, no JS runtime on the launch path |
| `DR-3` ≤ 10 s | first paint is from cache; delta sync lands behind it as a free refresh |
| `VD-1` — 4.5:1 contrast | host renders all text; Owner assets contrast-checked against Android Auto's black ground, light + `-night` variants |
| `TH-1` — light/dark on 1.9+ | no custom theme is set; assets ship both variants; day↔night costs zero templates |
| `MR-1` — apps drawing maps honour host light/dark | not applicable — EV Guide draws no map (§0) |
| `PA-1` — purchase constraints | no payments, permanently (ADR scope) |
| `AC-1` — tasks in ≤ 5 screens | 2 screens, 2 taps; the flow never ends on a list template |
| Reviewer outside Rwanda / mock GPS obligation | mock providers accepted; `stationsNear` takes an arbitrary origin; `Show stations in Kigali` is a one-tap path to content |
| Car EV APIs usually `STATUS_UNIMPLEMENTED` | `EnergyProfile` is one of three profile sources and the surface is fully functional with none of them; never persist a platform integer |
| `ACTION_NAVIGATE` grammar; `SecurityException` on explicit component | `geo:lat,lng` via `startCarApp`, no component, no package name |
| POI apps SHOULD offer a nav hand-off | `Directions` is the primary action on every station |
| Templated apps cannot be sideloaded | test loop is DHU + Internal App Sharing / Internal track |
| Play form-factor opt-in; blocking review on open/production | Android Auto form factor added; closed track first (non-blocking review) before open/production |
| Addendum kill switch | nothing in the product is load-bearing on the car surface — the phone app is complete without it |

---

## 10. Forced compromises

1. **No identity on screen.** One bundled Owner mark per station is the entire visual surface. EV Guide's design system does not appear on Android Auto. Declining `MapWithContentTemplate` deepens this deliberately, in exchange for §0's four removals.
2. **No reporting from the car.** Settled by ticket 23 (the function set is three), and structurally right: a report is per-Connector, so a one-tap car report would have to invent a station-level write the model does not have, and a connector picker is two more templates of data entry while driving. The cost is real — a driver who arrives to find every bay taken is at the single best reporting moment and cannot act on it. Revisit only if a documented parked-state signal appears.
3. **No saving, no favourites, no profile on the car.** All user-scoped, all outside car constraint 9.
4. **The cache gains two non-directory fields** (`isSignedIn`, `armedWatches`) to satisfy ticket 30. An acknowledged extension of car constraint 9 — §6.3 — that must be written into `docs/domain-model.md`.
5. **A third implementation of the ADR-0008 derivation** (§7.4). Divergence risk, mitigated by shared fixtures, not eliminated.
6. **"Free for me" is a qualified aggregate, never a filter.** Per-connector state cannot fit a two-line row, so the driver's plug changes the *wording* only. A driver whose profile EV Guide does not know sees a station-wide count that may be true for someone else's car.
7. **The marker cannot say which station.** `markerLabel` is on `Owner`, so four Kabisa sites show four `KAB` pins; row↔pin correspondence rests on position and host highlighting.
8. **The list is frozen while the driver looks at it.** A station that frees up 200 m away does not enter the list until the driver taps ⟳. Quota, not preference.
9. **Anonymous drivers never learn the bay alert exists.** Silence is Apple's rule carried across for one design; Android would have permitted a message.
10. **Two rates fit; three do not.** Beyond two distinct connector rates the pane collapses to `From 600 RWF/kWh · 3 rates`.
11. **Android Auto is not available in Rwanda.** This entire surface serves no current EV Guide user. It is built for a market the product does not yet serve, and that reasoning belongs in ticket 24's scope call, not in this design.

## 11. Inferences and open questions

**Inferences carried in this design** — none is a documented rule:

| # | Inference | Where it bites |
|---|---|---|
| 1 | An action-title change inside an otherwise-identical template is still a refresh | §3.2 #7; costed as +1 in the proof anyway |
| 2 | The refresh diff is per-screen, not per-host-session | §3.2 #8; costed as +1 in the proof anyway |
| 3 | A pop refunds ≥ 1 template | §3.3; the *only* inference the proof actually leans on |
| 4 | `ScreenManager` requests only the top screen's template when a stack is seeded | §3.5 — otherwise a notification deep link costs 2, not 1 |
| 5 | `setOnContentRefreshListener` is `@RequiresCarApi(3)` | runtime-guarded; without it, re-ranking needs a quota reset |
| 6 | A `PlaceMarker` may carry icon **and** label, host chooses | made harmless by redundant encoding |
| 7 | `Action` titles accept `CarText` variants | falls back to one authored short string |
| 8 | `-night` resource qualifiers resolve from `CarContext` | otherwise day/night costs a template |
| 9 | `CarAppExtender` / `CarNotificationManager` is the car-notification mechanism | not covered by research 04 |
| 10 | A device-local vehicle profile needs no account (ADR-0003 gates *sync*) | the whole anonymous "free for me" story |
| 11 | 200 km empty-state radius; Kigali fallback origin | design calls, routed to 19 |
| 12 | `HostValidator` allowlist boilerplate | standard, unverified against the research |

**Open questions for ticket 27's DHU session**, in priority order:

1. Does `ACTION_NAVIGATE` actually reach Google Maps on a real host? (Critical path — Apple Maps cannot navigate in Rwanda, so this is the whole directions story on both platforms.)
2. Does the back-refund equal the templates popped, or one? Walk six push/pop cycles and watch for the close.
3. Is the refresh diff per-screen? Push detail, pop, and check whether the identical re-emitted place list consumes a step.
4. Does an action-title change (`Notify me` → `Stop watching`) consume a step?
5. Does `PlaceListMapTemplate` render two text lines while driving, or one?
6. Does setting a `PlaceMarker` label suppress the Owner icon? Is row↔pin correspondence usable with six same-Owner pins?
7. Real `CONTENT_LIMIT_TYPE_PLACE_LIST` and `…PANE` values on the DHU and on any reachable head unit.
8. `PlaceListMapTemplate`'s ActionStrip constraint — `SIMPLE` (2) or `MAP` (4)? Currently unused, so this is headroom, not a blocker.

**Routed back to ticket 19 / `docs/domain-model.md` before the schema locks:**

- The **two-line** projection needs Android slot typing: `rowTitle` (nameShort + distance span), `rowPrimaryText` (availability + freshness, or capacity when Unknown), `rowSecondaryText` (droppable).
- A new fixed **pane-rows** projection (label/value pairs) — Android's detail screen has no projection today; `card-triple` is CarPlay's.
- The two-line projection takes an optional `viewerConnectorTypes` parameter (§4.2 wording rules).
- `stationsNear` reserves its last slot for the nearest compatible station when a profile exists (§4.2).
- `lastReportedAt` on the aggregate is defined as the **oldest** contributing report (§5).
- The car cache carries `isSignedIn` + `armedWatches` (§6.3) — an amendment to car constraint 9.
- The car layer re-implements the ADR-0008 derivation in Kotlin against a shared fixture corpus (§7.4) — also touches ADR-0006 / ticket 15.