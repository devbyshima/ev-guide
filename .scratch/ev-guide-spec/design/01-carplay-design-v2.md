# EV Guide on CarPlay — complete template design (v2)

Ticket 18 · 2026-08-13 · supersedes `01-carplay-design-v1.md` (lost to truncation; §8.4–§12 survived
and are carried forward here, revised where the verdict broke them).

Reviewed against `03-carplay-verdict-v1.md` (2 FATAL, 14 MAJOR, 8 MINOR) and the cross-platform half of
`04-androidauto-verdict-v1.md` (F1, F2, M3, M4, M7, M8, M9, m16, m21, m22). Every defect is answered in
**§13**; the ones I disagree with are named there with reasons.

Sources obeyed: `design/00-constraint-sheet.md` (the authority — `[hard]` / `[inferred]` / `[runtime]`
marks are its), `docs/domain-model.md`, `CONTEXT.md`, ADR-0002/0003(as amended)/0004/0006/0007/0008,
tickets 18, 23, 30.

---

## 0. The five decisions that shape everything below

1. **No drawing surface exists.** A `carplay-charging` app gets no `CPWindow` `[hard]`. EV Guide supplies
   strings, images and IDs; Apple draws every pixel. The reference designs are not forced, as ticket 18
   instructs.
2. **Five template classes, one push edge.** `CPTabBarTemplate` (root) · `CPPointOfInterestTemplate` ·
   `CPListTemplate` · `CPInformationTemplate` · `CPAlertTemplate`. The station detail has **zero** push
   edges, so the 5-template ceiling `[hard]` is a property of the graph, not of a runtime assertion (§4).
3. **The car never assumes the driver's plug.** CarPlay has no `EnergyProfile` equivalent
   `[hard]`; a mirrored profile is an optional *lens on wording*, never on presence, order or ranking (§6).
4. **Availability is derived at render from per-Connector raw reports held on device** — never from a
   materialised aggregate. This is the only construction under which "a stale green is impossible"
   (ADR-0008) is true *on the car* (§10.2).
5. **Count invariance.** No template's item count, action count, row count or tab count may vary with
   availability, freshness, watch state, distance, or the network. Counts vary only with `canWatch` and
   `hasSaved`, both snapshotted at compose time and immutable while the template is on screen. This is
   Android's F1 lesson imported as a CarPlay discipline: on CarPlay it costs no quota, but a control that
   appears or vanishes under a driver's finger is the same hazard on both platforms.

---

## 1. Template inventory and root/tab structure

### 1.1 Entitlement frame

| Item | Value |
|---|---|
| Entitlement | `com.apple.developer.carplay-charging` **only** `[hard]` |
| Deployment floor | iOS 14 `[hard]` |
| Combined entitlements | none (no fueling, no `carplay-maps`) |
| Scene | `CPTemplateApplicationScene`, interface controller only `[hard]` |

### 1.2 Templates used — five

| Template | Role | Depth | Installed by |
|---|---|---|---|
| `CPTabBarTemplate` | root container | 1 | `setRootTemplate` `[hard]` |
| `CPPointOfInterestTemplate` | **Map** tab — ≤12 chargers on MapKit's map | 2 | tab array |
| `CPListTemplate` | **Nearby** tab — ranked list from the driver's origin | 2 | tab array |
| `CPListTemplate` | **Saved** tab — conditional (§8.4) | 2 | tab array |
| `CPInformationTemplate` | station detail — Apple's own named example for a *"charging location"* `[hard]` | 3 | `pushTemplate` |
| `CPAlertTemplate` | two conditions, A1 and A2 | modal | `presentTemplate` `[hard]` |

### 1.3 Templates permitted and deliberately unused

| Template | Why not |
|---|---|
| `CPGridTemplate` | **Cut in v2.** v1 spent a tab on a plug-lens grid that set a preference, navigated nowhere, and produced no visible change — a settings tab, which guideline 4 names by example, and a control with no response, which reads as broken while driving. The lens moved to wording (§6). |
| `CPActionSheetTemplate` | Nothing on this surface needs a two-or-more-choice modal. `CPAlertTemplate` covers both conditions. |
| `CPSearchTemplate` | iOS 27+ for this category `[hard]`, so it excludes the entire iOS 14–26 base; keyboards are unavailable while driving in many cars `[hard]`; Apple says it must *"never be the primary way"* `[hard]`. With tens of stations, proximity ranking carries the whole access path. **Out of v1**; a deferred enhancement, not a compromise the design leans on. |
| `CPVoiceControlTemplate` | iOS 27+ `[hard]`, and voice *recording* is navigation-only `[hard]`. See §9.3. |

### 1.4 Templates forbidden — never referenced in the binary

`CPMapTemplate`, `CPContactTemplate`, `CPNowPlayingTemplate`, `CPNavigationSession`, `CPTrip`,
`CPRouteChoice`, `CPManeuver`, `CPTravelEstimates`, `CPRouteDetail`, map panels, the panning interface,
dashboard and cluster scenes, and **`CPChargingStationConnection`**. A forbidden template is a *runtime
exception*, not a rejection `[hard]` — so this is enforced by a build-time source check over the target,
not by review discipline.

### 1.5 Tabs

| Tab | Title | Icon (SF Symbol, 24×24 pt / 48 px @2× / 72 px @3× `[hard]`) | Root template |
|---|---|---|---|
| A | `Map` | `map` | `CPPointOfInterestTemplate` |
| B | `Nearby` | `list.bullet` | `CPListTemplate` |
| C | `Saved` | `heart` | `CPListTemplate` — present only when the car facet holds ≥1 saved station at scene connect |

Selected tab at scene connect is always **A**. Deterministic, zero-tap, and a populated charger map is the
launch state guideline 1 asks for.

**Degradation against `CPTabBarTemplate.maximumTabCount` `[runtime]`** — Apple states 5 for non-audio
categories but warns against relying on it `[hard]`:

| Reported max | Structure |
|---|---|
| ≥3 | A · B · C (C only if non-empty) |
| 2 | A · B — Saved dropped |
| 1, or tab bar unavailable | root = `CPPointOfInterestTemplate` directly; detail moves to depth 2; the list is dropped |

---

## 2. Character budgets and the string vocabulary

CarPlay publishes **no character counts anywhere** `[hard]`, and `CPListItem`, `CPPointOfInterest` and
`CPInformationItem` take plain `String` — **no variants, no truncation control** `[hard]`. Authoring short
is the only lever, so a budget is the only enforceable form that lever can take. Budgets are mine
`[inferred]`.

| Slot | Budget | Protected head |
|---|---|---|
| `CPListItem.text` | 26 | — |
| `CPListItem.detailText` | 44 | **first 20 chars = source + age** |
| `CPPointOfInterest.title` | 18 (`nameShort`) | — |
| `CPPointOfInterest.subtitle` | 28 | — |
| `CPPointOfInterest.summary` | 44 | first 20 |
| `CPPointOfInterest.detailTitle` | 28 (`name`) | — |
| `CPPointOfInterest.detailSubtitle` | 44 | first 20 |
| `CPPointOfInterest.detailSummary` | 90 | — |
| `CPInformationItem.title` | 12 | — |
| `CPInformationItem.detail` | 52 | — |
| `CPTextButton.title` | **16** | — |
| Template title | 24 | — |
| Tab title | 8 | — |
| Notification title / body | 28 / 40 | — |

The 16-character button budget is why the watch action ships as **`Notify when free`** (exactly 16) and not
ticket 30's phone label `Notify me when a bay frees up` (29). With up to three actions sharing one row and
no variants, 29 characters in a third of a small head unit is not a risk to measure — it is an outcome.
Ticket 27 may *upgrade* the label if hardware allows; it may not be relied on to rescue it. Divergence
routed to 30 (§15).

### 2.1 Vocabulary — fixed, closed, and the only words on the surface

| Concept | Words |
|---|---|
| Source | `Operator` · `Driver` · `EV Guide` |
| Age | `just now` · `14 min ago` · `3 h ago` · `2 days ago` · `21 days ago` |
| Bay states in counts | `free` · `in use` · `out of service` · `unreported` |
| Distance | `~2.4 km` (row/picker) · `~2.4 km straight line` (detail) |
| Rate | `600 RWF/kWh` · `350–450 RWF/kWh` · `No confirmed rate` · `unpriced` |
| Watch | `Not watching` · `Alert requested` · `Watching until 15:12` · `one alert, next 2 h` |

**The word `busy` does not exist on this surface** — it is the word that folded `Unknown` and
`OutOfService` into occupancy in v1. `in use` quantifies `o` and nothing else. **The word `Unknown` does
not appear either**: it is a model state, not a display string, and CONTEXT.md forbids rendering it as an
error or an absence.

---

## 3. The worked corpus — four stations, exact strings in every slot

### 3.0 Fixture

```
S1  Kabisa – SP Remera        nameShort "SP Remera"   Owner Kabisa · KAB   geo −1.9556, 30.1044   2.4 km
    B1  GB/T DC 60 kW  600 RWF/kWh (12 d)   report  Free      operator  −14 min
    B2  GB/T DC 60 kW  600 RWF/kWh (12 d)   report  Occupied  operator  −14 min
    B3  Type 2  22 kW  600 RWF/kWh (12 d)   report  Free      operator  −14 min
    B4  Type 2  22 kW  600 RWF/kWh (12 d)   report  Occupied  operator  −14 min
    → f=2 o=2 x=0 u=0  total=4  known=4                       ← the ticket's required example

S2  Numa – Kisimenti          nameShort "Kisimenti"   Owner Numa   · NUM                          3.1 km
    B1  CCS2   50 kW  rate unknown            no report
    B2  Type 2 22 kW  rate unknown            no report
    B3  Type 2 22 kW  rate unknown            no report
    → f=0 o=0 x=0 u=3  total=3  known=0                       ← the all-Unknown variant

S3  EVP – Kimironko           nameShort "Kimironko"   Owner EVP    · EVP                          5.6 km
    B1  GB/T DC 60 kW  450 RWF/kWh (21 d)  operator  Free          −25 min   → Free
    B2  GB/T DC 60 kW  450 RWF/kWh (21 d)  driver    Occupied      −3 h 10   → decayed → Unknown
    B3  Type 2  22 kW  350 RWF/kWh (21 d)  driver    Occupied      −40 min   → Occupied
    B4  Type 2  22 kW  350 RWF/kWh (21 d)  operator  OutOfService  −6 days   → OutOfService
    → f=1 o=1 x=1 u=1  total=4  known=3                       ← the mixed known+Unknown variant

S4  Kabisa – Nyabugogo        nameShort "Nyabugogo"   Owner Kabisa · KAB                          7.3 km
    B1  [GB/T DC 60 kW + Type 2 22 kW on one pedestal]  600 RWF/kWh (5 d)
        GB/T DC  operator Occupied −20 min · Type 2 no report  → bay Occupied (propagation)
    B2  [GB/T DC 60 kW + Type 2 22 kW on one pedestal]  600 RWF/kWh (5 d)
        GB/T DC  operator Free −20 min · Type 2 no report      → bay Free
    → f=1 o=1 x=0 u=0  total=2  known=2                       ← the dual-gun counting case (M4)
```

S4 exists because the required example has four single-connector bays, which is exactly the shape in which
the double-counting defect is invisible.

### 3.1 Map tab — `CPPointOfInterestTemplate`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Chargers nearby                                                     │  ← template title (§7.3)
│                                                                      │
│              [KAB]②        [NUM]                                     │  ← pin = Owner icon + markerLabel
│                                    [EVP]①                            │     badge = fresh free-bay count
│                        [KAB]①                                        │
│                          (MapKit draws all of this)                  │
├──────────────────────────────────────────────────────────────────────┤
│  SP Remera                                                           │  title
│  ~2.4 km · Kabisa                                                    │  subtitle
│  Operator · 14 min ago · 2 of 4 bays free                            │  summary
└──────────────────────────────────────────────────────────────────────┘
```

**Picker triple, all four stations, exact:**

| # | `title` | `subtitle` | `summary` |
|---|---|---|---|
| S1 | `SP Remera` | `~2.4 km · Kabisa` | `Operator · 14 min ago · 2 of 4 bays free` |
| S2 | `Kisimenti` | `~3.1 km · Numa` | `3 bays · CCS2 and Type 2` |
| S3 | `Kimironko` | `~5.6 km · EVP` | `Driver · 40 min ago · 1 free · 1 unreported` |
| S4 | `Nyabugogo` | `~7.3 km · Kabisa` | `Operator · 20 min ago · 1 of 2 bays free` |

S2's summary carries **no source-and-age head** — there is nothing to date. The capacity clause replaces
the availability clause rather than apologising for it (§7.1).

**Card triple + the two buttons, exact:**

| # | `detailTitle` | `detailSubtitle` | `detailSummary` |
|---|---|---|---|
| S1 | `Kabisa – SP Remera` | `Operator · 14 min ago · 2 of 4 bays free` | `2 × GB/T DC 60 kW · 2 × Type 2 22 kW · 600 RWF/kWh · ~2.4 km straight line` |
| S2 | `Numa – Kisimenti` | `3 bays · CCS2 and Type 2` | `1 × CCS2 50 kW · 2 × Type 2 22 kW · No confirmed rate · ~3.1 km straight line` |
| S3 | `EVP – Kimironko` | `Driver · 40 min ago · 1 free · 1 unreported` | `2 × GB/T DC 60 kW · 2 × Type 2 22 kW · 350–450 RWF/kWh · ~5.6 km straight line` |
| S4 | `Kabisa – Nyabugogo` | `Operator · 20 min ago · 1 of 2 bays free` | `2 bays, each GB/T DC 60 kW + Type 2 22 kW · 600 RWF/kWh · ~7.3 km straight line` |

`primaryButton` = **`Directions`** · `secondaryButton` = **`Details`**. There is no third `[hard]`.

**Template-level calls**

| Call | Value |
|---|---|
| `title` | `Chargers nearby` \| `Chargers near Kigali` \| `Chargers in view` — §7.3 |
| `setPointsOfInterest(_:selectedIndex:)` | `min(12, ranked)` `[hard]`, re-supplied on every `didChangeMapRegion` `[hard]` |
| delegate | mandatory `[hard]`; region-delta threshold (250 m or a zoom step) guards the re-supply loop |

**Pins.** `pinImage` / `selectedPinImage` are composited at runtime from `Owner.icon` (vector) +
`Owner.markerLabel` (≤3 chars, authored) at `CPPointOfInterest.pinImageSize` /
`.selectedPinImageSize` `[runtime]` and `carTraitCollection.displayScale`, in both `contentStyle`
variants. **The `markerLabel` is composited into the CarPlay pin** — the routed constraint from 19
("Marker = Owner icon + ≤3-char markerLabel") is honoured on both platforms, and twelve pins from three
Owners stay distinguishable.

**The free-bay badge.** A small filled numeral badge carrying `f` is composited top-right of the pin
**only when `f > 0` at render time**. Because `f` is derived under decay, the badge's existence *is* its
freshness claim: it decays out by construction and can never be drawn stale. Grey is never drawn — an
Unknown station's pin is simply the Owner mark, which is a complete listing, not an apology (ADR-0002:
*"availability as an additive badge when it exists"*). S1 → `②`, S2 → no badge, S3 → `①`, S4 → `①`.

### 3.2 Nearby tab — `CPListTemplate`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Chargers nearby                                                     │
├──────────────────────────────────────────────────────────────────────┤
│ [KAB]  SP Remera · ~2.4 km                                        ›  │
│        Operator · 14 min ago · 2 of 4 bays free                      │
├──────────────────────────────────────────────────────────────────────┤
│ [NUM]  Kisimenti · ~3.1 km                                        ›  │
│        3 bays · CCS2 and Type 2                                      │
├──────────────────────────────────────────────────────────────────────┤
│ [EVP]  Kimironko · ~5.6 km                                        ›  │
│        Driver · 40 min ago · 1 free · 1 unreported                   │
├──────────────────────────────────────────────────────────────────────┤
│ [KAB]  Nyabugogo · ~7.3 km                                        ›  │
│        Operator · 20 min ago · 1 of 2 bays free                      │
└──────────────────────────────────────────────────────────────────────┘
```

| Slot | API | Value | Rule honoured |
|---|---|---|---|
| primary | `text` | `place-line` = `<nameShort> · ~<distance>` | two text slots only `[hard]`; availability never in a title (settled Part C rule 1) |
| secondary | `detailText` | `availability-line(.row)` = `<source> · <age> · <state clause>` | **source-and-age lead**, so truncation removes information instead of manufacturing a live claim (§5.4) |
| image | `image` | Owner glyph at `CPListItem.maximumImageSize` `[runtime]`, light + dark | one small static mark per station |
| accessory | `accessoryType` | `.disclosureIndicator` | |
| id | `userInfo` | opaque `Station.id` — the sanctioned carrier `[hard]` | |

Row count = `min(CPListTemplate.maximumItemCount ?? 12, 12)` `[hard/runtime]`. Rows are independent and
distance-ranked, so a car that cuts the list to 12 — or `limitedUserInterfaces` containing `.lists`,
which iOS applies whether the app handles it or not `[hard]` — costs only the tail.

**Empty-state variants** (`CPListTemplate` is the only template with length variants on this surface
`[hard]`), longest → shortest:

```
emptyViewTitleVariants     ["No chargers within 200 km", "No chargers nearby", "None nearby"]
emptyViewSubtitleVariants  ["EV Guide covers Rwanda — switch to Map to browse",
                            "EV Guide covers Rwanda", "Rwanda only"]
```

Reachable only by a mid-session directory sync that empties the region; the origin fallback (§7.3) and the
bundled snapshot floor (§10.1) make the ordinary paths unreachable. Kept as the net, said out loud so
nobody mistakes it for the Unknown case.

### 3.3 Station detail — `CPInformationTemplate`, layout `.leading`

Apple's own worked example for this template is *"an EV charging app may display information about a
charging station such as availability"* `[hard]`. `CPInformationItem` is a `title` + `detail` pair and
nothing else `[hard]`; there is **no documented and no queryable item cap** `[UNKNOWN]`, so the design
holds to **six**, ordered by decision value, with the load-bearing pairs first.

**S1 — signed in, notifications authorised, no vehicle profile:**

```
┌──────────────────────────────────────────────────────────────────────┐
│ ‹   Kabisa – SP Remera                                               │
├──────────────────────────────────────────────────────────────────────┤
│  Availability    2 of 4 bays free                                    │
│  Last report     Operator · 14 min ago                               │
│  Rate            600 RWF/kWh · all 4 bays · 12 days ago              │
│  Connectors      2 × GB/T DC 60 kW · 2 × Type 2 22 kW                │
│  Bay alert       Not watching · one alert, next 2 h                  │
│  Distance        ~2.4 km straight line                               │
├──────────────────────────────────────────────────────────────────────┤
│         [ Directions ]        [ Notify when free ]                   │
└──────────────────────────────────────────────────────────────────────┘
```

**S2 — all Unknown, anonymous (5 items; `Bay alert` absent, not disabled):**

```
│  Availability    3 bays · CCS2 and Type 2                            │
│  Last report     Not reported recently                               │
│  Rate            No confirmed rate                                   │
│  Connectors      1 × CCS2 50 kW · 2 × Type 2 22 kW                   │
│  Distance        ~3.1 km straight line                               │
├──────────────────────────────────────────────────────────────────────┤
│         [ Directions ]                                               │
```

**S3 — mixed known+Unknown, signed in, no profile:**

```
│  Availability    1 free · 1 in use · 1 out of service · 1 unreported │
│  Last report     Driver · 40 min ago                                 │
│  Rate            350–450 RWF/kWh · 4 bays · 21 days ago              │
│  Connectors      2 × GB/T DC 60 kW · 2 × Type 2 22 kW                │
│  Bay alert       Not watching · one alert, next 2 h                  │
│  Distance        ~5.6 km straight line                               │
├──────────────────────────────────────────────────────────────────────┤
│         [ Directions ]        [ Notify when free ]                   │
```

**S4 — dual-gun, signed in:**

```
│  Availability    1 of 2 bays free                                    │
│  Last report     Operator · 20 min ago                               │
│  Rate            600 RWF/kWh · all 2 bays · 5 days ago               │
│  Connectors      2 bays, each GB/T DC 60 kW + Type 2 22 kW           │
│  Bay alert       Not watching · one alert, next 2 h                  │
│  Distance        ~7.3 km straight line                               │
```

Note S4's `Connectors` value. It never says *"2 × GB/T DC · 2 × Type 2"*, which would invent two parking
positions that do not exist (M4).

**Item order and the invariance rule.** `Rate` is pinned at position 3 and can never be the tail: RURA
Art. 27(2) makes a tariff a regulated public disclosure, and the item cap is undocumented and unqueryable,
so the tail is the expendable position by construction. Collapsed to **one** item regardless of how many
distinct per-Connector rates exist (§5.5). `Distance` is deliberately last. **The item count varies only
with `canWatch`** (§8.2), which is snapshotted when the template is composed.

**Actions** — `CPTextButton`, ≤3 `[hard]`, this design uses ≤2:

| Condition | Action 1 | Action 2 |
|---|---|---|
| any driver | `Directions` (`.confirm` style) | — |
| `canWatch`, not armed | `Directions` | `Notify when free` |
| `canWatch`, armed | `Directions` | `Stop alert` |

`Directions` is unconditional and anonymous on every path (ADR-0003 as amended). No car screen presents a
sign-in wall of any kind.

### 3.4 The two alerts — `CPAlertTemplate`, presented, never pushed `[hard]`

| | A1 | A2 |
|---|---|---|
| trigger | `Notify when free` tapped while the watched set is already effectively Free | the directions ladder (§8.1) exhausts both rungs |
| `titleVariants` | `["Bays are free right now", "Bays are free now", "Free now"]` | `["Directions aren't available right now", "Directions aren't available", "No directions"]` |
| actions | `OK` | `OK` |

Both **state a condition without instructing anyone to touch a phone** — the exact latitude guideline 2
permits `[hard]`. `CPAlertTemplate.maximumActionCount` is undocumented `[runtime]`; both alerts are
authored at one action, so no ceiling can bite.

### 3.5 The bay-watch notification

| Field | Value |
|---|---|
| Authorisation | `UNAuthorizationOptions [.alert, .sound, .carPlay]` `[hard]` |
| Category | `EV_GUIDE_BAY_FREE`, created with `.allowInCarPlay` `[hard]` — both are required, either alone is insufficient |
| Title | `SP Remera · a bay is free` |
| Body | `Operator report, just now` |
| Tap | deep link → station detail for `stationId` |

Written to be **read, not heard** — notifications are generally not read aloud in CarPlay `[hard]` — so
the station is front-loaded in the title and the body is one clause. One event type, total. Fires only on
a **report-driven** transition into `Free`; decay never fires it (ticket 30). One-shot, max 3 armed, 2 h
expiry, so no repeat-fire path exists and no digest, quiet-hours or rate-limiter machinery is built.
Users can switch CarPlay notifications off per app `[hard]`: nothing on the surface depends on car
delivery — the watch still fires on the phone, and the armed item clears on completion either way.

**The deep link's stack effect.** The intent pushes the detail template onto the active tab's stack. If a
detail template is already on top, its content is replaced in place instead of pushed. Max depth stays 3.

---

## 4. Navigation graph, with depth at every node

```
                       ┌───────────────────────────────────────────┐
                       │  R  CPTabBarTemplate            depth 1   │  setRootTemplate — never
                       │     (root, never pushed, never presented) │  pushed, never nested [hard]
                       └───────────┬───────────┬───────────┬───────┘
              tab select (not a push, no depth cost)
                       ┌───────────┴──┐  ┌─────┴──────┐  ┌─┴──────────────┐
                       │ A  POI       │  │ B  List    │  │ C  List        │
                       │    depth 2   │  │    depth 2 │  │  Saved depth 2 │
                       └───────┬──────┘  └─────┬──────┘  └─────┬──────────┘
                               │ push          │ push          │ push
                               └───────────────┼───────────────┘
                                       ┌───────┴──────────────────────┐
                                       │ D  CPInformationTemplate     │
                                       │    station detail   depth 3  │
                                       │    OUT-EDGES: none           │
                                       └───────┬──────────────────────┘
                                               │ presentTemplate (modal, not a push)
                                       ┌───────┴──────────┐
                                       │ A1 / A2  Alert   │
                                       └──────────────────┘
```

| Node | Template | Depth | Push out-edges |
|---|---|---|---|
| R | `CPTabBarTemplate` | **1** | none (tab selection is not a push) |
| A | `CPPointOfInterestTemplate` | **2** | → D |
| B | `CPListTemplate` (Nearby) | **2** | → D |
| C | `CPListTemplate` (Saved) | **2** | → D |
| D | `CPInformationTemplate` | **3** | **none** |
| A1, A2 | `CPAlertTemplate` | modal | none |

**Proof that 5 holds `[hard]`.** The graph has exactly three push edges, all of the form
*(tab root at 2) → (detail at 3)*, and D is a sink. The maximum reachable push depth is therefore **3**,
under the conservative reading that the tab bar occupies level 1. Two levels of headroom remain unused.
No invariant is asserted at runtime and no push wrapper is needed — v1 needed both because it carried an
`Other free bays` list that pushed a *second* detail, putting a cycle in the stack guarded only by an
assertion whose enforcement API was unverified. That action is cut (§13, D11/D16), and with it the cycle,
the assertion, and the unverified API.

Every function is reachable in ≤3 taps: Directions in **2** (select pin → `Directions`), the watch in
**3** (select pin → `Details` → `Notify when free`), a station detail in **2**.

---

## 5. How per-Connector availability collapses — the pipeline, not prose

### 5.1 The chain

```
Report(connector)                  latest per Connector, by capturedAt (most-recent-wins, ticket 11)
   │  ADR-0002 decay: window(source, state) — driver 2 h · operator 6 h · OutOfService 30 d
   ▼
effective(connector, now) ∈ {Free, Occupied, OutOfService, Unknown}
   │  ADR-0008 bay propagation
   ▼
bayState(bay, now)                 ← NEW named domain function, routed to 19 (§15.2)
   │  count
   ▼
(f, o, x, u, total)                f+o+x+u = total ; known = f+o+x = total − u
   │  availabilityClause(f, o, x, u, total, verbosity, lens)
   ▼
one string                         no branch in the CarPlay layer
```

### 5.2 `bayState(bay, now)` — precedence, total

Let `s = { effective(c, now) : c ∈ bay.connectors }`.

| Test, in order | Result | Why |
|---|---|---|
| `Occupied ∈ s` | **Occupied** | one vehicle occupies the position (ADR-0008 propagation) |
| `Free ∈ s` | **Free** | a working gun on a free position |
| `s ⊆ {OutOfService}` and `s ≠ ∅` | **OutOfService** | every gun on the position is known broken |
| otherwise | **Unknown** | at least one gun is Unknown and none is Free or Occupied |

Worked: S4/B1 `s = {Occupied, Unknown}` → Occupied. S4/B2 `s = {Free, Unknown}` → Free. S3/B2
`s = {Unknown}` (the driver Occupied report is 3 h 10 old, past the 2 h driver window) → Unknown.

### 5.3 The availability clause — total over the whole `(f, o, x, u)` space

**Three laws the grammar enforces.**

1. **The denominator is the *known* set, never `baysTotal`.** The `N of M` shorthand is emitted only when
   `u = 0`, where the two coincide.
2. **`in use` may only quantify `o`.** It is never spoken over a bay counted in `u` or `x`.
3. **`OutOfService` never folds into occupancy** at any count — occupied means wait, broken means go
   elsewhere (ADR-0002).

**Row form** (`CPListItem.detailText`, `POI.summary`, `POI.detailSubtitle` — budget 44 with a 20-char
protected head):

| f | o | x | u | clause |
|---|---|---|---|---|
| >0 | — | 0 | 0 | `2 of 4 bays free` |
| >0 | — | >0 | 0 | `2 of 4 free · 1 out of service` |
| >0 | — | — | >0 | `1 free · 1 unreported` |
| 0 | >0 | 0 | 0 | `All 4 bays in use` |
| 0 | >0 | >0 | 0 | `3 in use · 1 out of service` |
| 0 | 0 | =total | 0 | `All 4 bays out of service` |
| 0 | >0 | 0 | >0 | `2 in use · 2 unreported` |
| 0 | >0 | >0 | >0 | `1 in use · 1 out of service · 2 unreported` |
| 0 | 0 | >0 | >0 | `1 out of service · 3 unreported` |
| 0 | 0 | 0 | =total | **capacity clause** — `4 bays · GB/T DC and Type 2` (no source/age head) |

**Detail form** (`CPInformationItem.detail`, budget 52): join every non-zero count in the fixed order
`<f> free · <o> in use · <x> out of service · <u> unreported`, with three shorthands when `u = 0`:
`2 of 4 bays free` (x = 0, f > 0) · `All 4 bays in use` (f = x = 0) · `All 4 bays out of service`
(x = total). When `known = 0`, the capacity clause, same as the row.

Worked: S1 → `2 of 4 bays free` (both forms). S3 → row `1 free · 1 unreported`;
detail `1 free · 1 in use · 1 out of service · 1 unreported`. S2 → `3 bays · CCS2 and Type 2` (both).
S4 → `1 of 2 bays free` (both).

**The row form drops `x` when `f > 0` and `u > 0`.** That is incompleteness under a 44-character budget,
not a false assertion — nothing untrue is said, the driver's go/no-go fact (`f`) leads, and the detail
screen one tap away carries all four counts. `x` is retained on the row whenever `f = 0`, because there it
changes the decision from *wait* to *go elsewhere*.

### 5.4 The freshness head — source and age

Computed over the **contributing reports**: the latest report per Connector that is inside its decay
window and belongs to a bay counted in `known`.

| Field | Rule |
|---|---|
| Source word | the **weakest** contributing source, ordered `driver < operator < admin` |
| Age | the **oldest** contributing `capturedAt` **among non-`OutOfService` reports**; if every contributing report is `OutOfService`, the oldest of those |
| Emitted at all? | only when `known > 0` |

Worked, S3: contributing sources are operator (B1), driver (B3), operator (B4/OOS) → weakest is
**`Driver`**. Non-OOS ages are 25 min and 40 min → oldest is **`40 min ago`**. The B4 report is 6 days old
and still valid under the 30-day `OutOfService` window; folding it into the age would have rendered a
25-minute-old free bay as `6 days ago`, which understates confidence as badly as `mixed` overstates it.

Weakest-source never promotes a driver's guess to operator provenance, and (weakest source, oldest age) is
a consistent lower bound on confidence — one axis, read one way. `mixed` was the alternative and is
rejected: it is a fourth word in a three-word vocabulary, it is not a source, and it tells the driver
strictly less than the bound does.

**Why the head leads the string.** `CPListItem` takes a plain `String` with no truncation control
`[hard]`, and the platform guidance is to put the driving-relevant substring first because the tail is
what gets cut `[hard]`. Of the two truncation outcomes available:

| Ordering | Truncates to | Reading |
|---|---|---|
| `2 of 4 bays free · Operator · 14 min ago` | `2 of 4 bays free` | **a live claim** — the confident-stale failure ADR-0002 and ADR-0008 exist to make unrepresentable |
| `Operator · 14 min ago · 2 of 4 bays free` | `Operator · 14 min ago` | uninformative, still honest, row still tappable |

Honesty is structural in this product, not disciplinary. The head leads. Losing informativeness to a narrow
head unit is a real cost and is carried as compromise §12.2.

### 5.5 The rate clause — one item, four cases

Rate is per-**Connector** `[settled]`. A three-type station would otherwise want three pairs and push
`Rate` past the undocumented item cap into the expendable tail.

| Condition | `Rate` value |
|---|---|
| one rate, every connector fresh | `600 RWF/kWh · all 4 bays · 12 days ago` |
| several rates, all fresh | `350–450 RWF/kWh · 4 bays · 21 days ago` |
| some unknown or past the 90-day window | `600 RWF/kWh · 3 of 4 bays · 1 unpriced` |
| all unknown or decayed | `No confirmed rate` |

`No confirmed rate` — never *"not published"*, which would assert something about a licensee's RURA
Art. 27(2) compliance that EV Guide cannot know. A rate past its 90-day window is treated exactly like a
decayed availability: the number is not shown at all.

**Rate never appears on a row** `[settled]` — two slots, and both are spent.

---

## 6. "Free for me" when the car does not know the driver's connector

### 6.1 The default is not knowing

CarPlay has **no `CPChargingStationConnection`** for a charging app and **no `EnergyProfile` equivalent
at all** `[hard]`. There is no car-side source for the driver's plug and no permitted screen on which to
ask for one — a plug picker is a settings screen, which guideline 4 names by example. So the design's
primary answer is structural, not personalised:

> **Every surface states the connector types plainly, at every level, and the driver does the matching by
> reading.** Picker `summary` and row `detailText` carry the types whenever availability is Unknown; the
> POI card's `detailSummary` always carries them with power; the detail screen's `Connectors` item always
> carries them with counts and power. "Free for me" is answered by *reading*, never by the list's shape.

### 6.2 The lens, when a profile exists

`vehicleConnectorTypes` may be mirrored into the car facet from the phone profile (§10.3). When present it
is a **lens on wording only**:

- It changes the wording of the `Availability` item and the row's state clause.
- It **never** changes presence, count, order, or ranking. `stationsNear` stays distance-first then
  availability, total, with **no reserved slot** for a nearest-compatible station — a reserved slot is a
  presence change driven by the profile, and it breaks a total order exactly where the six-row floor bites.
- Incompatible stations are never hidden and never demoted. Filtering would empty the map in a market
  where multi-standard sites are the legal norm.

### 6.3 Per-type arithmetic that cannot double-count

| Function | Definition |
|---|---|
| `baysOffering(T)` | # bays carrying ≥1 Connector of type `T` — a bay is counted **once per type**, so each individual denominator is ≤ `baysTotal`; only the **sum across types** may exceed it |
| `freeBaysOffering(T)` | # bays where `bayState = Free` **and** ∃ `c` of type `T` with `effective(c) ≠ OutOfService` (Unknown counts as usable — never assert an unproven negative) |

S4 (dual-gun, 2 bays): `baysOffering(GBT_DC) = 2`, `baysOffering(T2) = 2`, sum 4 > `baysTotal` 2.
`freeBaysOffering(GBT_DC) = 1`, `freeBaysOffering(T2) = 1` — and the wording must never let those two 1s
read as two parking positions.

### 6.4 The lens grammar — total

| Condition | `Availability` value |
|---|---|
| `baysOffering(T) = 0` | `No GB/T DC here · 4 bays, Type 2 and CCS2` |
| every bay offering `T` is Unknown | `2 Type 2 bays · not reported recently` |
| otherwise | `1 of 2 GB/T DC bays free` + `· 2 more, Type 2 only` when `total − baysOffering(T) > 0` |

Worked:

| Station | Lens | `Availability` value |
|---|---|---|
| S3 | GB/T DC | `1 of 2 GB/T DC bays free · 2 more, Type 2 only` |
| S3 | Type 2 | `0 of 2 Type 2 bays free · 2 more, GB/T DC only` |
| S3 | CCS2 | `No CCS2 here · 4 bays, GB/T DC and Type 2` |
| S2 | Type 2 | `2 Type 2 bays · not reported recently` — **never** `0 of 2 free`; the bays are Unknown, not empty |
| S4 | GB/T DC | `1 of 2 GB/T DC bays free` — the "N more" clause is 0 and is omitted, so no phantom capacity |

Row form with a lens, S3/GB-T DC: `Driver · 40 min ago · 1 of 2 GB/T DC free` (40 chars, within budget).

### 6.5 What the watch sends

`watch(stationId, connectorTypes[])` carries the mirrored profile's types when one exists and `[]`
(= all types) otherwise, and the `Bay alert` item says which:
`Not watching · one alert, next 2 h` becomes `Not watching · GB/T DC only, next 2 h` under a lens. Without
this the same tap means different things to a driver who changed cars.

---

## 7. Unknown, stale, and the origin

### 7.1 Unknown is a complete listing, never an absence

`Unknown` is the **normal case** — 67 of 77 Rwandan charge points reported nothing in the only real
dataset examined. The rules:

| Rule | Effect |
|---|---|
| The word `Unknown` never appears on the surface | it is a model state, not a string |
| When `known = 0`, the availability slot carries **capacity + types** | `3 bays · CCS2 and Type 2` — what the listing *does* know |
| No greying, no dimming, no apology, no "no data" phrasing | v1's `No recent report` is deleted; it spent the scarcest slot on an absence |
| No pin badge is drawn | absence of a badge, never a grey badge |
| Nothing animates, pulses, or spins | `[hard]` on both platforms |

Only the detail screen's `Last report` item states the negative directly — `Not reported recently` — and it
does so on a screen where four other items are carrying complete, confident facts.

### 7.2 Stale is impossible, and the screen must prove it while sitting still

Decay runs **at render** (ADR-0008). A template that is composed once and never recomposed will therefore
show a value past its window — a driver opening the detail on a 1 h 57 m-old driver report sees
`Driver · 1 h 57 min ago · 2 of 4 bays free`, and three minutes later the window closes while the screen
still reads `free`. That is the screen the driver commits on.

**Fix — a one-shot decay timer, no polling.**

```
nextDecayDeadline(displayed, now) = min over every displayed value of
    availability :  capturedAt + window(source, state)
    rate         :  rateConfirmedAt + 90 days
    watch        :  armedAt + 2 hours
```

Schedule one timer at that instant; on fire, recompose in place and schedule the next. Deterministic, zero
I/O, no churn, and it obeys the inferred 10 s / 60 s floors trivially because it fires at most once per
decayed value. It runs for the POI set, both lists, and the detail template.

### 7.3 Origin selection, and saying so in the title

`stationsNear(origin, limit)` takes an **arbitrary origin**, never a hardcoded device location `[settled]`.

| Condition | Origin | Template title |
|---|---|---|
| Map tab, region has been panned | visible-region centre (delegate-driven) | `Chargers in view` |
| Device location authorised and within 200 km of any station | device location | `Chargers nearby` |
| Denied, unavailable, or >200 km from every station | **Kigali centroid** | `Chargers near Kigali` |

The title is free of the two-slot row budget on both platforms, so the substituted origin gets said
without costing a row. Without it a driver in Kampala — or Apple's reviewer in Cupertino — reads `~3.2 km`
for a station 1,500 km away with nothing on the row able to explain it.

The last row does three jobs. **Location permission cannot be granted from CarPlay**, and guideline 2
forbids telling anyone to grant it on the phone — so the map simply opens on Rwanda and works. It handles a
driver outside the coverage area. And it handles Apple's reviewer, for whom Apple states no mock-location
requirement (that is Google's rule), so the fallback is the only thing standing between the submission and
a blank map. No mock-GPS dependency, no debug flag, no special build.

### 7.4 Distance is computed, never fetched — and labelled

CarPlay shows **great-circle distance only**, computed on device from `Station.geo` and the origin. Never
Valhalla's driving distance, never an ETA.

Four reasons: zero network on the paint path, which the locked-phone rule effectively mandates; it works
offline and while locked, which a routing call does not; routing 12 POIs on every map pan is neither cheap
nor reliable on a Rwandan mobile link; and it sits furthest from the `carplay-maps` boundary — Apple
blesses *"distance/bearing text the app computes and puts in `summary` or `detailSubtitle`"* `[hard]`,
while ETA is one of the four things that tips an app over `[hard]`.

ADR-0007 requires straight-line distance to be **labelled as such**. On the car that label is carried two
ways: the **`~` prefix** everywhere it appears in a scan (`~2.4 km`), and the detail screen's
`Distance` item, which spells it — `~2.4 km straight line`. In a country whose road distance routinely
runs 2–3× crow-flies, a driver picking on 6 km of remaining range must not read the number as a road
distance. Routed to ADR-0007 as a car-surface note (§15).

**Banned by lint on this surface:** `ETA`, `min away`, `mins`, `arrive`, `duration`, and any route,
maneuver or polyline. Not merely unmodelled — a `carplay-maps` trigger if rendered.

---

## 8. Anonymous, the watch, and Saved

### 8.1 Directions — anonymous, unconditional, and it cannot dead-end

ADR-0003 as amended: directions are ungated **everywhere**. No car screen presents a sign-in wall, and
`Directions` is present on the POI card and the detail template for every driver, signed in or not.

**The ladder** — all rungs go through the **scene's** `open(_:options:completionHandler:)`, never
`UIApplication.shared.open` `[hard]`:

| Rung | URL | Guaranteed? |
|---|---|---|
| 1 | `comgooglemaps://?daddr=-1.9556,30.1044&directionsmode=driving` | scheme declared in `LSApplicationQueriesSchemes` `[hard]`; gated on `canOpenURL` **and** chained on the completion handler's `false` |
| 2 | `http://maps.apple.com/?daddr=-1.9556,30.1044&dirflg=d` `[hard]` | **yes** — Apple Maps is always installed and **is** a CarPlay app |
| 3 | alert A2 | unreachable in practice; present so a tap is never silent |

Coordinates, never a place name `[settled]` — station names are not in Google's places index.

**Why rung 2 exists.** v1's ladder went Google Maps scheme → Google Maps *universal link* → alert. With
Google Maps not installed, the universal link resolves to Safari, which is **not a CarPlay app**, so the
primary action of the primary category silently pushed content onto the phone the driver must not touch,
and then dead-ended in an alert with no remedy. Guideline 3 (*"All CarPlay flows must be possible without
interacting with iPhone"*) `[hard]` was claimed and not delivered.

ADR-0004's *"Apple Maps has no directions in Rwanda"* is a reason not to make Apple Maps **primary**. It is
not a reason to prefer a dead end. On rung 2 in Rwanda the driver gets the destination shown on the
CarPlay map without a route — degraded, honest, and on the car screen. That degradation is carried as
compromise §12.5, and the ladder is routed to ADR-0004 as an amendment (§15).

### 8.2 The watch — where it appears, and what it is allowed to promise

**Gate.** `canWatch = isSignedIn && notificationAuthorization ∈ {authorized, provisional}`.

Both terms matter. v1 gated on `isSignedIn` alone, so a signed-in driver who had never granted
notifications got the button, tapped it, saw an armed row, and would never be told — on the one function
that clears Apple's EV-1 bar, and the only forward-looking promise on the whole surface. The car screen
cannot ask, and guideline 2 forbids saying so, so the only honest move is **silent omission**, exactly as
for a signed-out driver.

`carPlaySetting` being off is deliberately **not** part of the gate: the watch still fires on the phone, so
the promise is degraded, not broken. (`UNNotificationSettings.carPlaySetting` — verify in the SDK, §14.)

`canWatch` is snapshotted when the detail template is composed and is not re-read while it is on screen, so
the item count and action count cannot change under the driver's finger.

**The `Bay alert` item's three states** — text varies freely, the item never does:

| State | Value | Action title |
|---|---|---|
| not armed | `Not watching · one alert, next 2 h` | `Notify when free` |
| armed, **not yet confirmed by the server** | `Alert requested · not confirmed yet` | `Stop alert` |
| armed and confirmed | `Watching until 15:12 · one alert` | `Stop alert` |

**An unsynced watch is not an armed watch.** v1 wrote the armed row optimistically and reconciled
silently, which survives a *permanently* failing POST — in the rural-Rwanda case ADR-0007 exists for, the
row would sit for two hours asserting a live watch that no server had ever heard of. The middle state is
the fix: the row states exactly what EV Guide knows, which is that a request was made.

**A queued arm expires client-side at `armedAt + 2 h`**, exactly as ADR-0007 drops an unsent report past
its own decay window. A watch delivered three hours late arms a two-hour errand the driver abandoned.
`Watching until 15:12` is computed from `armedAt`, so an unconfirmed arm's window visibly shrinks and the
decay timer (§7.2) clears it at the deadline.

**Ticket 30 clause 3 — "arming is only offered when the watched set is not already Free".** Honoured in
substance, not by hiding the control: tapping while the set is already Free arms nothing and presents
alert **A1** (`Bays are free right now`), which dismisses back to the detail. Hiding the action would make
its presence depend on availability, so a report landing while the screen is open would take the button
away mid-reach. Divergence routed to 30 (§15).

**Anonymous drivers see no `Bay alert` item and no second action, and nothing explains why.** Guideline 2
permits stating a condition and forbids instructing phone manipulation; silent omission is the derived safe
reading `[inferred]`. Carried as compromise §12.9.

### 8.3 Reporting is not on the car surface

Considered and declined for v1 (see §13, D24). A report is a per-**Connector** claim; from a car screen
with a multi-connector station in front of it, EV Guide would be fabricating which gun the driver meant.
The single-Bay-single-Connector carve-out is honest but declined for three reasons: driver reports are
proximity-gated on the captured location, so the action's *presence* would vary with the vehicle's position
— a moving target while driving, and the one thing §0.5 forbids; RURA Annex I makes multi-standard sites
the legal norm, so the carve-out covers a shrinking minority; and it needs an authenticated write from the
template layer, which §10.3's decision forecloses. Carried as compromise §12.6, deferred not refused.

### 8.4 Saved — the tab v1 refused

v1 refused a Saved tab on the grounds that the locked-readable car cache may hold only non-sensitive
directory and availability data — while simultaneously putting armed watches and mirrored vehicle plugs
into that same cache. The design cannot both take the carve-out and cite the rule the carve-out breaks.

**Resolution: take the carve-out explicitly, and let Saved in on the same terms.** The car facet (§10.3)
admits `savedStationIds` alongside `armedWatches` and `vehicleConnectorTypes`, under one named exclusion
list and with **no user identifier anywhere in the file**.

The **Saved** tab is a `CPListTemplate` with identical row anatomy to Nearby, ranked by distance, title
`Saved chargers`, present only when the facet holds ≥1 saved station at scene connect. Its rows push the
same detail template at depth 3. There is no save/unsave action on any car screen — saving is a phone act
and stays there, which keeps guideline 4 clean and the car layer read-only over the facet's saved set.

---

## 9. Safety and voice

### 9.1 Nothing moves

`[hard]` on both platforms: CarPlay does not support animated images (first frame is used), and Android's
`SA-1` forbids animated elements. No spinner, no pulsing "live" dot, no transition on an availability
change, no marquee for an overlong name. The design contains no state that could want one, because no
screen is designed around a network wait (§10.4).

### 9.2 Interaction budget

| Property | Value |
|---|---|
| Taps to Directions from launch | **2** |
| Taps to a station detail | **2** |
| Taps to arm a watch | **3** |
| Templates that require the keyboard | **none** — no `CPSearchTemplate` in v1 |
| Auto-transitions between templates | **none** |
| Screens whose first paint may be a loading state | **none** |
| Strings mentioning the phone, sign-in, install, or permissions | **none** (audited, §11.4) |

`CPSessionConfiguration.limitedUserInterfaces` `[hard]`: `.keyboard` is irrelevant (nothing needs it);
`.lists` is handled by ranking, since iOS shortens lists whether the app cooperates or not and the tail is
the least useful part of a distance-ranked list.

`CPSessionConfiguration.contentStyle` `[hard]`: every bundled asset ships light and dark; runtime-composited
pins are redrawn on a style change.

### 9.3 Voice — out of v1, deliberately

Ticket 18 asks this to be settled. `CPVoiceControlTemplate` is **iOS 27+ for the charging category**
`[hard]`, so it is unavailable to the entire iOS 14–26 base; voice **recording** is navigation-only
`[hard]`; and no SiriKit intent domain covers "find a charger" for this entitlement. On the Android side
`VC-1` applies to Media and Navigation only, so voice is not mandatory there either. **No voice affordance
in v1.** Revisit when the deployment floor rises above iOS 27 — at which point Search and Voice Control
arrive together and should be designed as one addition.

### 9.4 Contrast and legibility

All artwork ships 2× and 3× and light/dark `[hard]`. The Owner glyph and marker label are drawn
monochrome so they hold contrast in both ambient styles without a per-style asset pair, and the free-bay
badge is drawn with the system accent over an opaque ground rather than as a colour-only signal.

---

## 10. On-device data, protection classes, and refresh

CarPlay is *"frequently used while iPhone is in a locked state"* `[hard]`. Every car screen must therefore
be paintable from cache with the phone locked and the network absent. No screen may be designed around a
spinner that resolves from the network, and none may be designed around user-specific state the cache
cannot hold.

### 10.1 The paint floor — three sources, in order

| Order | Source | Protection | Readable when? |
|---|---|---|---|
| 1 | **Store A** — the synced directory + reports cache | `NSFileProtectionCompleteUntilFirstUserAuthentication` `[inferred]` | after the first unlock since boot |
| 2 | **Bundled snapshot** — ADR-0007's release-time directory inside the app binary | app bundle resource | **any lock state, always** |
| 3 | — | — | — |

If Store A is unreadable or absent, the surface paints from the bundled snapshot with **all availability
Unknown**. Bundle resources carry no data-protection class, so this makes the car surface
*unconditionally* paintable. v1 had no such floor: a driver who rebooted the phone and got straight into
the car met an empty map and an empty list before the first unlock, with the empty-state variants — which
say *"no chargers within 200 km"* — saying exactly the wrong thing, and guideline 2 forbidding any string
that could explain it. The fix costs nothing and uses an asset ADR-0007 already ships.

### 10.2 Store A holds raw per-Connector reports, not aggregates

This is the single load-bearing schema decision on the car surface. `docs/domain-model.md` says
`baysFree` and `lastReportedAt` are *"computed projections materialised into sync payloads"*. If the car
renders from those materialised values, the device cannot re-apply decay (no `capturedAt` per connector),
cannot re-run bay propagation (no sibling grouping), cannot produce the per-type wording of §6, and a
`baysFree: 2` written at sync time renders confidently hours later. **The central safety claim of the
whole product would be false precisely on the surface that most needs it.**

```
Station       { id, name, nameShort, ownerId, lat, lng, updatedAt }
Owner         { id, shortName, markerLabel, iconRef }
Bay           { id, stationId, label }
Connector     { id, bayId, type, powerKw, voltage,
                ratePerKwhRwf, sessionFeeRwf, rateConfirmedAt }
LatestReport  { connectorId, state, source, capturedAt }     ← one row per Connector
```

`LatestReport` carries **no `reporterId` and no `capturedLocation`**. The domain `Report` has both; neither
is needed to render anything and both are user-scoped, so they are stripped by an explicit named
projection, not by a filter applied at the cache boundary by convention.

The materialised aggregate may still ride in the sync payload as a transport convenience. **It is never the
car's render input.** A fixture whose materialised aggregate and device-derived aggregate deliberately
disagree belongs in the shared corpus.

### 10.3 Store B — the car facet, and the credential's home

| | |
|---|---|
| Contents | `canWatch: Bool` · `armedWatches[{stationId, connectorTypes[], armedAt, expiresAt, confirmed}]` · `pendingIntents[{op: arm\|disarm, stationId, connectorTypes[], at}]` · `savedStationIds[]` · `vehicleConnectorTypes[]` |
| Protection | `NSFileProtectionCompleteUntilFirstUserAuthentication` `[inferred]` |
| **Never present** | push token · access or refresh token · user id · email · display name · avatar · report history · captured locations · membership or role · saved-station timestamps |

The file holds preferences and errands. **It contains no user identifier**, so it identifies what this
device is watching, not who is watching.

**The car template layer never authenticates.** Arming or disarming writes a `pendingIntent` row and
returns; the template re-renders immediately from Store B with the `Alert requested · not confirmed yet`
text. A separate `WatchSyncQueue` — which no CarPlay code path calls into — drains the queue and performs
the authenticated POST. It is the only component that reads the credential.

| | |
|---|---|
| Credential | refresh/access token, **Keychain**, `kSecAttrAccessibleAfterFirstUnlock` `[inferred]` |
| Read by | `WatchSyncQueue` only |
| Read by the car layer | **never** |
| Before first unlock | unreadable, so the queue cannot drain — which surfaces correctly as `not confirmed yet` rather than as a false armed row |

This gives the credential one named home (the Android review's M7), keeps the template layer free of
secrets, and makes the D1 honesty fix a consequence of the architecture rather than a rule someone has to
remember.

### 10.4 Refresh

| Trigger | Action | Blocking? |
|---|---|---|
| Scene connect | read Store A (or the bundled snapshot), compose, paint | **never blocks on network** |
| Scene connect, then ≤ every 5 min while connected | `changedSince(cursor)` delta sync in background | no — failure is silent |
| App foreground on phone | same delta sync | no |
| Every render | re-run ADR-0008 decay over cached `capturedAt` | pure function, no I/O |
| **Decay deadline reached** | recompose the affected template in place | **one-shot timer, no polling** (§7.2) |
| POI region change | re-rank ≤12 to region centre, `setPointsOfInterest` | no I/O |
| Periodic POI refresh | ≤ once / 60 s `[inferred]` | no I/O |
| Any other periodic update | ≤ once / 10 s `[inferred]` | no I/O |
| Watch arm/disarm | write `pendingIntent`, re-render as *not confirmed*; queue drains out of band | UI updates immediately |

Cold sync budget under 1 MB (ADR-0007). Photos are never fetched for a car surface `[settled]`.

**Row-set stability `[inferred]`.** While a list or the POI picker is on top, the row *set* is frozen
except on a user action (tab change, region pan) or 500 m of vehicle movement. Only text and the pin badge
change under the decay timer. This is a human-factors property — a list reordering under a reaching finger
— not a platform rule; on Android the same discipline is additionally a quota requirement.

---

## 11. Constraint → satisfaction

### 11.1 Entitlement, templates, depth

| Constraint | How this design satisfies it |
|---|---|
| `com.apple.developer.carplay-charging`, iOS 14+ `[hard]` | Declared alone. No `carplay-maps`, no fueling combination. |
| Forbidden template = **runtime exception** `[hard]` | `CPMapTemplate`, `CPContactTemplate`, `CPNowPlayingTemplate`, `CPChargingStationConnection` never referenced; a build-time source check over the target enforces it. |
| No `CPWindow`, no drawing surface `[hard]` | Nothing is drawn. Strings, images, IDs only. |
| Entitlement is account-level, all-or-nothing `[hard]` | No staged rollout or kill switch is assumed anywhere. |
| **Stack depth 5 incl. root** `[hard]` | Max reachable depth **3**, proved structurally in §4: three push edges, all 2→3, and the detail template is a sink. |
| Tab bar root-only, each tab its own hierarchy `[hard]` | `setRootTemplate` only; never pushed, never presented, never nested. |
| Modals presented, not pushed `[hard]` | A1 and A2 via `presentTemplate`. |
| Tabs ≤5, query `maximumTabCount` `[hard/runtime]` | 2–3 tabs; queried, with documented degradation to 2 and 1 (§1.5). |
| Tab bar contains Grid/Information/List/POI only `[hard]` | POI, List, List. |
| Tab icon 24×24 pt `[hard]` | **24 pt / 48 px @2× / 72 px @3×** — v1 misstated this as 48/96. SF Symbols available at the iOS 14 floor. |

### 11.2 Point of interest

| Constraint | How this design satisfies it |
|---|---|
| Max 12 POIs `[hard]` | `min(12, ranked)`; the composer cannot emit more. |
| Delegate mandatory; re-rank on every region change `[hard]` | `setPointsOfInterest(_:selectedIndex:)` on `didChangeMapRegion`, guarded by a 250 m / one-zoom-step delta threshold. |
| *"limited to those most relevant or nearby"* `[hard]` | Ranked to the visible region centre, distance-first. |
| **Do not expose non-EV-charger locations** `[hard]` | The POI array is built from `Station` rows only. No fueling entitlement is held, so the expansion is foreclosed by design. |
| Exactly two card buttons `[hard]` | `Directions` + `Details`. The watch lives one level deeper. |
| Six plain-`String` slots, no variants `[hard]` | §3.1 fills all six from the settled picker-triple and card-triple, each authored to a §2 budget. |
| Pin sizes undocumented `[runtime]` | Pins composited at runtime from `pinImageSize` / `selectedPinImageSize` and `carTraitCollection.displayScale`; `Owner.icon` is a **vector** for exactly this reason. |
| No animated images `[hard]` | Nothing on this surface animates. |

### 11.3 List, information, alert

| Constraint | How this design satisfies it |
|---|---|
| Cars may cut lists to 12; `maximumItemCount` undocumented `[hard/runtime]` | `min(maximumItemCount ?? 12, 12)`; rows independent and ranked, so truncation costs only the tail. |
| `CPListItem` = two text slots `[hard]` | `text` = the **`place-line`** projection; `detailText` = the **`availability-line`** projection. Two named projections, no improvisation, and neither repeats the other. |
| `userInfo` is the sanctioned ID carrier `[hard]` | Opaque `Station.id` on every row. |
| List image size `[runtime]` | Owner glyph rendered to `CPListItem.maximumImageSize`. |
| `emptyView*Variants` — the one variant slot `[hard]` | Three variants each (§3.2). |
| `CPInformationTemplate` item cap **unknown, unqueryable** `[UNKNOWN]` | ≤6 items ordered by decision value; `Rate` pinned at 3 so it can never be the tail; `Distance` is the designed casualty. |
| Information ≤3 actions `[hard]` | Never more than **two**. |
| `CPInformationItem` = title + detail only `[hard]` | Every item is a label/value pair. No image, accessory, or per-item action attempted. |
| `CPAlertTemplate.maximumActionCount` undocumented `[runtime]` | Both alerts authored at one action. |
| `titleVariants` on alerts `[hard]` | Three variants each. |
| `CPTextButton` = plain `String`, no variants `[hard]` | Every button title ≤16 chars (§2). |

### 11.4 Review guidelines

| Guideline | How this design satisfies it |
|---|---|
| 1 — *designed primarily to provide the specified feature* `[hard]` | Launch state is a populated charger map at zero taps. Two or three tabs, all of them chargers. Nothing else is on the surface. |
| 2 — *never instruct people to pick up their iPhone* `[hard]` | **Audited string by string: no string on any car screen mentions the phone, sign-in, installation, or permissions.** A1 and A2 state conditions without instruction; account-gated affordances are silently absent. |
| 3 — *all flows must be possible without interacting with iPhone* `[hard]` | Browse, read availability with source and age, read rate and connectors, get directions, arm and disarm a watch — all complete on the car screen. **The directions ladder terminates in Apple Maps, which is always installed and is a CarPlay app**, so the primary action cannot land on the phone or dead-end. |
| 4 — *meaningful while driving; no unrelated features* `[hard]` | No settings, no account screen, no profile editor, no plug picker, no about, no help, no photos, no history, no statistics. The Grid "lens" tab that made this claim false in v1 is deleted. |
| 5 — no gaming or social networking `[hard]` | N/A. |
| 6 — never show message/text/email content `[hard]` | N/A — no such data exists in the model. |
| 7 — *templates for their intended purpose* `[hard]` | POI = charger locations; Information = charging-location detail (Apple's own named example); List = ranked chargers and saved chargers; Alert = a condition. |
| EV 1 — *can't just be a list of EV chargers* `[hard]` | Three functions above the directory: per-bay availability with source and freshness re-ranked to the viewport on every pan; the anonymous directions hand-off; bay-watch arm/disarm resolved by a CarPlay notification. **None is documented as sufficient — §12.10.** |
| EV 2 — *no non-charger locations on the map* `[hard]` | §11.2. |

### 11.5 Notifications, hand-off, locked phone

| Constraint | How this design satisfies it |
|---|---|
| Notifications permitted for EV charging `[hard]` | One category, one event type. |
| Requires `.carPlay` **and** `allowInCarPlay` `[hard]` | Both declared — **and the action is gated on the authorisation actually being granted** (§8.2), which is the part v1 omitted. |
| Users can disable per app; must degrade `[hard]` | Nothing depends on car delivery; the watch still fires on the phone and the armed item clears either way. |
| *"sparingly … important tasks required while driving"* `[hard]` | One-shot, max 3 armed, 2 h expiry, report-driven transitions only. No repeat path exists. |
| *"not read aloud"* `[hard]` | Written to be read: station front-loaded in the title, one clause in the body. |
| Hand-off via the **scene's** `open(_:options:completionHandler:)` `[hard]` | `CPTemplateApplicationScene.open`, never `UIApplication.shared.open`. |
| Receiving app must be a CarPlay app `[hard]` | Rung 1 Google Maps (a CarPlay navigation app); rung 2 Apple Maps (guaranteed). |
| Google Maps scheme declared `[hard]` | `comgooglemaps` in `LSApplicationQueriesSchemes`; coordinates, never a place name. |
| No route, ETA, maneuver, polyline `[hard]` | No route entity exists; distance is great-circle; ETA vocabulary banned by lint (§7.4). |
| Locked-phone file classes `[hard]` | Stores A and B at `…CompleteUntilFirstUserAuthentication`; **bundled snapshot as the pre-first-unlock floor**; nothing at Class A or B on any car path. |
| Locked-phone keychain classes `[hard]` | One credential at `kSecAttrAccessibleAfterFirstUnlock`, read only by `WatchSyncQueue`, never by the car layer. |
| Refresh floors 60 s / 10 s `[inferred]` | Adopted voluntarily; the decay timer fires at most once per decayed value, and region-change refresh is event-driven and uncapped, as Apple's text allows. |

---

## 12. Where the constraints force an ugly compromise

1. **The POI card has exactly two buttons, so bay-watch costs an extra tap.** `Directions` and `Details`
   are both indispensable from the map, which pushes the watch — one of the three functions clearing
   Apple's EV-1 bar — one level deeper than the action it competes with. The most review-relevant
   affordance on the surface is the one furthest from the driver's finger.

2. **A narrow head unit will truncate the state off the row.** The freshness head is protected and the
   state clause is what gets cut, which is the right trade (§5.4) — but it is still a trade. On a small
   screen a driver may see `Operator · 14 min ago` and have to tap to learn how many bays are free.

3. **Rate cannot appear on a row.** In a market where a driver may well choose on price, the price is
   always one tap away and never in the scan.

4. **The car and the phone disagree about distance.** CarPlay shows great-circle; the phone shows Valhalla
   driving distance and an ETA. In Rwanda's terrain the two can diverge sharply. The `~` and the
   `straight line` label narrow the misreading; they do not remove the discrepancy.

5. **If Google Maps is absent, directions degrade to a pin.** Rung 2 opens Apple Maps on the car screen,
   which cannot route in Rwanda — the driver sees the destination, not a route. The flow completes on the
   car screen, which is what guideline 3 asks; its usefulness is halved. Not papered over.

6. **Reporting is not on the car surface at all.** A driver parked at a broken charger, phone locked in a
   pocket, has no way to say so from the screen in front of them. The alternative — fabricating a
   connector-level claim — is worse, and the honest single-connector carve-out is declined for the reasons
   in §8.3. A real loss.

7. **The plug lens qualifies wording but never filters or reorders, and there is no way to set a plug from
   the car.** A GB/T-only driver still sees Type 2-only sites at the top of their list, correctly labelled
   and occupying a slot. Filtering would hide complete listings and could empty the map; a plug picker is
   a settings screen guideline 4 names by example. "Free for me" is answered by reading, not by the list's
   shape.

8. **No search, so nothing outside the nearest twelve is reachable.** `CPSearchTemplate` is iOS 27+ and
   often keyboard-less while driving. Fine for tens of stations; it would not survive a directory ten
   times the size.

9. **Anonymous drivers meet a silently smaller screen.** No `Bay alert` item, no second action, and no
   string may explain either. Correct under guideline 2, and invisible to the driver as a *choice* rather
   than a bug.

10. **The largest risk is not a layout problem.** Two of the three pillars — availability and bay-watch —
    are invisible when the data is thin, which in year one is most of the time. A reviewer with a US
    origin sees the Kigali fallback map, tens of stations, and mostly capacity clauses. **That is close to
    Apple's own example of what is not sufficient.** Ticket 20's submission must demo against seeded data,
    walk the reviewer through the availability layer, and arm a live watch — with a demo account signed in
    **on the phone before connecting**, so the car screen never shows a wall and the state is simply
    already true. No layout choice available here changes that; ticket 23's fallback ladder is the answer
    if it still fails.

11. **Choosing a tab does not restore a previous selection.** Scene connect always lands on Map. Simple and
    deterministic; a driver who was reading the list finds the map. Accepted rather than solved, because
    programmatic tab selection at the iOS 14 floor is unverified (§14).

---

## 13. Answers to the verdict

### 13.1 Fixed as raised

| # | Where fixed |
|---|---|
| **D1** fatal — armed row promises undeliverable | §8.2 — `canWatch` includes notification authorisation; the *not confirmed yet* state; client-side 2 h expiry of a queued arm; §10.3 makes it architectural |
| **D2** fatal — `Directions` dead-ends | §8.1 — Apple Maps as the guaranteed terminal rung; §11.4 guideline 3 now claims only what it delivers; §12.5 carries the residual honestly |
| **D3** — blank surface before first unlock | §10.1 — bundled snapshot as the paint floor |
| **D4** — no re-render trigger for decay | §7.2 — one-shot `nextDecayDeadline` timer, no polling |
| **D5** — `No recent report` renders Unknown as an absence | §7.1 — capacity clause replaces it everywhere in a scan; the string is deleted |
| **D6** — pins carry Owner identity only | §3.1 — fresh-only free-bay badge; grey is never drawn |
| **D7** — source dropped from the row | §5.4 — source leads the detail slot; no ADR relaxation is needed after all |
| **D9** — substituted origin renders false distances | §7.3 — origin stated in the template title |
| **D11 / D16** — `Other free bays` asserts what it cannot know, and puts a cycle in the stack | Cut entirely. §4's depth bound is now structural |
| **D12** — the Grid plug-lens tab is a settings tab | Cut entirely; the lens moved to wording (§6) |
| **D13** — `Notify me when a bay frees up` will truncate | §2 — ships as `Notify when free` (16 chars); ticket 27 may upgrade, not rescue |
| **D14** — rate competes for an unqueryable cap | §5.5 — one collapsed item, pinned at position 3 |
| **D15** — the facet contradicts the settled cache rule | §8.4 / §10.3 — carve-out taken explicitly with an exclusion list, and Saved admitted on the same terms |
| **D17** — wrong hard number | §11.1 — 24 pt / 48 @2× / 72 @3× |
| **D18** — projection wording would be implemented literally | §11.3 — two distinct named projections, `place-line` and `availability-line` |
| **D19** — wrong caveat to 19 | §6.3 / §15.3 — each per-type denominator is ≤ `baysTotal`; only the sum across types exceeds it |
| **D20** — alert A2 needs an ADR amendment | §15.4 routes it, together with the larger ADR-0004 amendment the ladder requires |
| **D22** — arithmetic off | Corrected: ticket 23 settled on **three** functions and reporting was never among them |
| **D23** — does `markerLabel` reach the CarPlay pin? | §3.1 — **yes**, composited into `pinImage` / `selectedPinImage` |
| **F2** (Android, cross-platform) — grammar not total | §5.3 — total over `(f, o, x, u)`; denominator is the known set; `busy` deleted from the vocabulary; `OutOfService` never folds |
| **M4** (Android) — per-type counts double-count multi-gun bays | §6.3 / §6.4 and fixture S4 |
| **M7** (Android) — the credential has no home | §10.3 — Keychain at first-unlock accessibility, read only by `WatchSyncQueue`; **the car layer never authenticates** |
| **M8** (Android) — car cache must hold raw reports | §10.2 |
| **M9** (Android) — reserved compatibility slot breaks the ranking | §6.2 — no reserved slot; ranking stays total |
| **F1** (Android) — row count varying with availability | §0.5 — count invariance adopted as a cross-platform design law |
| **M5** (Android) — reviewer sees none of the three functions | §12.10, routed to 20 as a hard submission dependency |
| **m16** (Android) — the arm never says which types it sends | §6.5 |
| **m21 / m22** (Android) — glossary and ticket-12 ruling | §15.9, §15.10 |

### 13.2 Where I disagree

**D8 — agreed in substance, remedy declined.** The diagnosis is right: `4.2 km · 2 of 4 free · 20 min ago`
truncates to a confident live claim, and that is the worst outcome available on the surface. The proposed
remedy — demote distance off the CarPlay row entirely — is declined. Distance is the ranking key and the
one number a driver with 6 km of range needs in the scan; moving it to `summary` on the POI is fine, but
`CPListItem` has only two slots and dropping it from the list row would leave the ranking unexplained.
Instead distance rides slot 1 beside the name (`SP Remera · ~2.4 km`, 19 chars — both fit comfortably) and
slot 2 is **reordered** so the freshness head leads. That yields the same protection D8 wanted, at no cost.
The reordered projection is routed to 19 either way.

**D10 — agreed, remedy narrowed.** Great-circle distance must be labelled; ADR-0007 is explicit. But a
label *sentence* in a scan slot would cost more than it buys. The `~` prefix carries it everywhere it
appears at a glance, and the `Distance` item spells it out on the screen where the driver commits. Routed
to ADR-0007 as a car-surface note rather than left as a silent exception.

**D21 — agreed in substance, expression changed.** Ticket 30 clause 3 ("arming is only offered when the
watched set is not already Free") is honoured, but **not** by removing the action. Removing it makes the
action count depend on availability, so the report this whole surface exists to deliver would take the
button away mid-reach — the same class of failure as D12, and precisely what Android's F1 shows is fatal
on the other platform. The action stays; tapping it while the set is Free arms nothing and presents A1.
Divergence routed to 30.

**D24 — declined for v1.** The observation is correct: a Station with exactly one Bay carrying exactly one
Connector can be reported without fabricating anything. It is still declined, for three reasons given in
§8.3 — proximity gating would make the action's *presence* vary with the vehicle's position; RURA Annex I
makes multi-standard sites the legal norm, so the carve-out shrinks over time rather than growing; and it
requires an authenticated write from the template layer, which §10.3 forecloses on purpose. Recorded as
deferred, not refused, and as the cheapest available fourth function if EV-1 is ever contested.

**M3 (Android) — adopted with a change.** Weakest-contributing-source is adopted. The `mixed` fallback is
rejected: it introduces a fourth word into a closed three-word source vocabulary, it is not a source, and
it tells the driver strictly less than the lower bound does. Additionally — and this is not in M3 —
`OutOfService` reports are excluded from the **age** computation, because their 30-day window would have
made a 25-minute-old free bay render as `6 days ago` (worked in §5.4). Both refinements routed to 19.

**M6 (Android) — noted, not applicable here.** CarPlay notification eligibility for EV charging is
documented by name (Developer Guide p.27) `[hard]`; Android's is not. The asymmetry is real and belongs on
ticket 27's blocking list for the Android half — where, if POI notifications turn out to be filtered,
ticket 23's three-function answer holds on CarPlay and needs revisiting on Android only.

---

## 14. Everything I inferred

Do not quote any of these to Apple as a rule.

1. **The tab bar counts as depth level 1.** The conservative reading; the design is safe under the
   permissive one too.
2. **The 60 s / 10 s refresh floors**, adopted from Apple's driving-task section, which is not literally
   binding on a charging app. Carried forward from the research author's own flag.
3. **`NSFileProtectionCompleteUntilFirstUserAuthentication` + `kSecAttrAccessibleAfterFirstUnlock`.**
   Apple documents what is unreadable while locked, never what to use instead.
4. **≤6 Information items, ordered by decision value, with `Rate` pinned at 3** — the hedge against an
   undocumented and unqueryable cap.
5. **The §2 character budgets**, including the 16-character button budget that shortens the watch label.
   Entirely mine. CarPlay publishes no character counts, and the affected slots have no variants.
6. **Count invariance (§0.5) as a CarPlay discipline.** On CarPlay it costs no quota; it is imported
   because a control that changes under a driver's finger is a hazard, not because a platform demands it.
7. **Silent omission of account-gated affordances** rather than explaining them — the derived safe reading
   of guideline 2.
8. **The car facet as a second store**, its exclusion list, and the judgement that a file with no user
   identifier holding station IDs and plug types is "non-sensitive enough" for the locked-readable class.
   This is a security decision, not a derivation, and ticket 19 must ratify or reject it.
9. **Stripping `reporterId` and `capturedLocation` from the cached Report projection.**
10. **The Kigali-centroid fallback beyond 200 km**, including as the reviewer path. Apple states no
    mock-location requirement for CarPlay, so this fills a documented void.
11. **The row-set stability rule** (frozen while on top, except on user action or 500 m of movement).
12. **Great-circle distance on the car, Valhalla only on the phone**, and the `~` prefix as its label.
13. **No offline indicator on CarPlay**, diverging from ADR-0007's phone indicator — there is no permitted
    non-alarming affordance for it, and the surface is designed to be indistinguishable offline.
14. **The never-assert-an-unproven-negative rule** — `0 of 2 free` is never emitted over bays that are
    Unknown (§6.4). Derived from ADR-0002's honesty rule, not stated by it.
15. **Weakest-source + oldest-non-OOS-age** as the aggregate freshness pair.
16. **The free-bay pin badge's self-dating property** — that a badge drawn only while fresh encodes its own
    age by existing. Sound, but it is an argument, not a documented pattern.
17. **`nextDecayDeadline` as a one-shot timer** rather than a poll.
18. **Alert A1 as the expression of ticket 30 clause 3**, and alert A2 as the terminal rung — small
    extensions of ADR-0004's *"no custom fallback UI"*, justified because guideline 2 explicitly permits
    stating a condition and a car button that silently does nothing is worse.

**Needs verification on hardware or in the SDK, before this design is built:**

- Whether `comgooglemaps://` launched via the scene's `open(_:options:completionHandler:)` lands on the
  CarPlay screen. **No longer on the critical path** — rung 2 guarantees the flow either way — but it
  decides whether directions are useful or merely complete. **Ticket 27.**
- Whether `UNNotificationSettings.carPlaySetting` exists at the deployment floor and what it reports when
  the user disables CarPlay notifications per app.
- Whether `CPInformationTemplate.items` / `.actions` are mutable at the target OS. If not, the decay-timer
  re-render and the arm/disarm re-render become pop-then-push replacements — depth-neutral, but visually
  abrupt while driving, which would change §7.2's cadence.
- Whether `CPTabBarTemplate` permits programmatic tab selection at the iOS floor (design assumes not).
- Rendered width of `Notify when free` beside `Directions` on the smallest available head unit.
- Actual runtime values of `maximumItemCount`, `maximumSectionCount`, `maximumTabCount`,
  `maximumActionCount`, `pinImageSize`, `selectedPinImageSize`, `maximumImageSize` across test vehicles.
- Legibility of the composited numeral badge at the smallest reported `pinImageSize`.
- Whether CarPlay activates at all on Rwandan-region devices `[UNKNOWN — ticket 22]`. Changes who sees
  these screens, not what they say.

---

## 15. Routed onward before the schema locks

### To ticket 19 (`docs/domain-model.md`) — must land before the schema locks

1. **Four projections, named in `packages/domain`.** The model names four (one-line, two-line,
   picker-triple, card-triple); this design needs the two-line one **split and reordered**, plus two new
   ones, or four call sites will improvise them:
   - **`place-line(station, origin)`** → `<nameShort> · ~<distance>` — replaces the current two-line's
     first line.
   - **`availability-line(agg, lens, verbosity)`** → `<source> · <age> · <state clause>` — replaces
     `distance · availability`. **The ordering is load-bearing** (§5.4), and `verbosity ∈ {row, detail}`.
   - **`detail-pairs`** → the `CPInformationItem` label/value list, ≤6, ordered by decision value,
     lens-aware, `Rate` pinned at 3.
   - **`push-line`** → notification title + body.
2. **`bayState(bay, now)` must be a named function.** ADR-0008 defines `effective(connector, now)` and
   mentions propagation; it does not name the bay-level roll-up, and **the Bay is the display unit on every
   car surface**. Precedence table in §5.2.
3. **Per-type projections `baysOffering(T)` and `freeBaysOffering(T)`**, with the *correct* caveat: a bay is
   counted once per type, so each individual per-type denominator is **≤ `baysTotal`**; only the **sum
   across types** may exceed it. A guard written the other way round would defend against a condition that
   cannot occur and miss the one that can.
4. **The availability grammar as a pure function of `(f, o, x, u, total, verbosity, lens)`** — §5.3 and
   §6.4, **total**, with the three laws (denominator = known set; `in use` quantifies `o` only;
   `OutOfService` never folds) as tests. Not in the CarPlay layer.
5. **The aggregate's source and age.** Source = weakest contributing (`driver < operator < admin`); age =
   oldest contributing `capturedAt` **excluding `OutOfService` reports** unless all contributors are
   `OutOfService`. Neither is currently defined.
6. **The rate grammar** — §5.5, four cases, collapsed to one displayable string, with an explicit unpriced
   count rather than a claim of coverage.
7. **The car cache schema (§10.2): per-Connector raw reports, never materialised aggregates**, with an
   explicit named `CachedReport` projection excluding `reporterId` and `capturedLocation`. Add a fixture
   whose materialised aggregate and device-derived aggregate deliberately disagree, and a **dual-gun**
   fixture (S4) — the corpus as it stands tests decay and propagation but not the counting.
8. **The car facet store (§10.3)**, with its exclusion list, now including `savedStationIds` and
   `pendingIntents`. Car constraint 9 currently says the car reads *only* non-sensitive directory +
   availability data; ticket 30's armed-state item cannot be rendered under that rule as written. Either 19
   admits this facet explicitly, or ticket 30's car face reduces to disarm-from-notification and the item
   goes — **and if 19 admits it, §8.4's Saved tab is admissible on the same terms and must not be denied by
   citing the rule the facet already amends.**
9. **The credential's home:** Keychain at `kSecAttrAccessibleAfterFirstUnlock`, read only by
   `WatchSyncQueue`; the car template layer never authenticates. State it beside the facet, since it is the
   one item in this area that is actually a secret.
10. **The Watch record gains `armedAt` and `confirmed`**, and a client-side rule dropping a queued arm past
    `armedAt + 2 h`, mirroring ADR-0007's rule for reports.
11. **`nextDecayDeadline(displayed, now)`** as a domain function (§7.2), so both car layers and the phone
    schedule identically.
12. **`Owner.icon` must be a vector asset.** CarPlay pin sizes are runtime values, so a fixed raster cannot
    serve them. The model currently says "bundled/materialised locally", which a PNG satisfies and this
    surface does not. And `Owner.markerLabel` is composited into the CarPlay pin, not Android-only.
13. **Authored length bounds, enforced in the admin:** `nameShort` ≤ 18, `name` ≤ 28, `markerLabel` ≤ 3.
    The model calls these authored; it does not bound them, and the slots that consume them have no
    truncation control.
14. **The negative form of car constraint 13:** ETA, duration and any "minutes away" string are **forbidden**
    on a car surface — not merely unmodelled, but a `carplay-maps` trigger if rendered.

### 15.4 To ADR-0004 — an amendment, not a footnote

The car-surface directions ladder (§8.1) diverges from *"Not-installed falls back to the platform's
universal-link handling; no custom fallback UI"*: on CarPlay the universal link lands in Safari, which has
no car screen, so the ladder terminates in **Apple Maps** and, only if that also fails, in alert **A2**.
Amend ADR-0004 the way ticket 23 amended ADR-0003, rather than carrying it as a design footnote.

### 15.5 To ADR-0007 — a one-line car note

Straight-line distance on the car is labelled by the `~` prefix plus the detail screen's `straight line`
wording, not by a label sentence in a scan slot (§7.4). Record it so the car is not a silent exception to a
settled labelling rule.

### 15.6 To ticket 30

- The car button label is **`Notify when free`** (16 chars), not the phone's
  `Notify me when a bay frees up` (29). `CPTextButton` takes a plain `String` with no variants.
- Clause 3 ("arming is only offered when the watched set is not already Free") is expressed on the car as
  **alert A1**, not as a hidden action — hiding it would make the action count depend on availability.
- The POST carries the mirrored profile's `connectorTypes[]` when one exists and `[]` otherwise, and the
  `Bay alert` item says which.
- The armed state has three values on the car, not two: the middle one is *requested, not confirmed*.

### 15.7 To ticket 20

- The submission demo must run against **seeded availability data**, or two of the three EV-1 functions are
  invisible to the reviewer (§12.10).
- Provide a **demo account signed in on the phone before connecting**, in Apple's review notes. The car
  screen never shows a wall — the state is simply already true.
- Review notes must walk the availability layer and arm a live watch.

### 15.8 To ticket 27

Add, in priority order: (1) whether `comgooglemaps://` via the scene `open` lands on the CarPlay screen;
(2) the runtime values in §14; (3) `CPInformationTemplate` mutability; (4) programmatic tab selection;
(5) badge legibility at the smallest `pinImageSize`.

### 15.9 To `CONTEXT.md`

Line 44 still reads *"needs an account to act — **directions**, saving, reporting, profile sync"*.
ADR-0003's amendment and ticket 23 removed directions from that list. One-line glossary edit.

### 15.10 To ticket 12

One-line ruling needed before 19 locks: is *setting your own connector type* account-gated (the ticket's
**question** says yes) or is it a device-local preference (the ticket's **answer** gates only *syncing* the
vehicle profile)? If the former, §6's entire wording layer only ever appears for signed-in drivers and the
anonymous reviewer sees the generic aggregate. The fallback wording is already specified — it is §6.1's
default — but the ruling decides how often it is what everyone sees.
