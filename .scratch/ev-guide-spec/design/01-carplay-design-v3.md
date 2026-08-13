# EV Guide on CarPlay — complete template design (v3)

Ticket 18 · 2026-08-13 · supersedes `01-carplay-design-v2.md`. Standalone: nothing in v1 or v2 need be read.

Reviewed against `05-carplay-verdict-v2.md` (2 FATAL, 10 MAJOR, 12 MINOR) and the cross-surface half of
`04-androidauto-verdict-v1.md`. Every defect is answered in **§13**; the two I narrow rather than adopt
whole are named there with reasons.

Sources obeyed: `design/00-constraint-sheet.md` (the authority — the `[hard]` / `[inferred]` / `[runtime]`
marks are its), `docs/domain-model.md`, `CONTEXT.md`, ADR-0002 / 0003 (as amended) / 0004 / 0006 / 0007 /
0008, tickets 18, 23, 27, 30, and `design/02-androidauto-design-v2.md` §3 — whose grammar this document now
**cites rather than restates** (M8).

---

## 0. The six decisions that shape everything below

1. **No drawing surface exists.** A `carplay-charging` app gets no `CPWindow` `[hard]`. EV Guide supplies
   strings, images and IDs; Apple draws every pixel. The reference designs are not forced, as ticket 18
   instructs.
2. **Five template classes, one push edge.** `CPTabBarTemplate` (root) · `CPPointOfInterestTemplate` ·
   `CPListTemplate` · `CPInformationTemplate` · `CPAlertTemplate`. The station detail has **zero** push
   edges, so the 5-template ceiling `[hard]` is a property of the graph, not of a runtime assertion (§4).
3. **The car never assumes the driver's plug.** CarPlay has no `EnergyProfile` equivalent `[hard]`; a
   mirrored profile is an optional *lens on wording*, never on presence, order or ranking (§6).
4. **Availability is derived at render from per-Connector raw reports held on device** — never from a
   materialised aggregate. This is the only construction under which "a stale green is impossible"
   (ADR-0008) is true *on the car* (§10.2).
5. **Count invariance.** No template's item count, action count, row count or tab count may vary with
   availability, freshness, watch state, distance, lens or the network. Counts vary only with `canWatch`,
   `hasSaved` and the presence of a lens — all three snapshotted at compose time and immutable while the
   template is on screen. A control that appears or vanishes under a driver's finger is a hazard.
6. **One vocabulary, one grammar, two surfaces.** The availability, freshness and rate strings are produced
   by **one pure function shared with Android Auto**, specified in `02-androidauto-design-v2.md` §3 and
   routed to ticket 19 as `packages/domain`. CarPlay owns *assembly* (which slot, what order, which
   compose-time ladder) and owns **no words of its own** (§2, §5).

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
| `CPAlertTemplate` | three conditions, A1 · A2 · A3 | modal | `presentTemplate` `[hard]` |

### 1.3 Templates permitted and deliberately unused

| Template | Why not |
|---|---|
| `CPGridTemplate` | A grid tab spent on a plug picker sets a preference, navigates nowhere and produces no visible change — a settings tab, which guideline 4 names by example, and a control with no response, which reads as broken while driving. The lens lives in wording (§6). |
| `CPActionSheetTemplate` | Nothing here needs a two-or-more-choice modal. `CPAlertTemplate` covers all three conditions. |
| `CPSearchTemplate` | iOS 27+ for this category `[hard]`, so it excludes the entire iOS 14–26 base; keyboards are unavailable while driving in many cars `[hard]`; Apple says it must *"never be the primary way"* `[hard]`. With tens of stations, proximity ranking carries the whole access path. A deferred enhancement, not a compromise the design leans on. |
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

## 2. Vocabulary, targets, and the two truncation invariants

CarPlay publishes **no character counts anywhere** `[hard]`, and `CPListItem`, `CPPointOfInterest` and
`CPInformationItem` take plain `String` — **no variants, no truncation control** `[hard]`. The system cuts
the tail at a width the app cannot know. Two things follow, and they are the whole of this section: the
**order** inside a slot is the only real protection, and any "budget" is a compose-time target, not a
guarantee.

### 2.1 The vocabulary is not CarPlay's to define

The word set is the one specified in `02-androidauto-design-v2.md` §3 and routed to `CONTEXT.md` (§15.7).
CarPlay adopts it unchanged:

| Concept | Words |
|---|---|
| Bay states | `free` · `busy` · `out of service` (short form `broken`, §5.4 ladder only) · `unknown` |
| Source | `operator` · `driver` · `EV Guide` |
| Age | `just now` · `14 min ago` · `3 h ago` · `6 days ago` |
| Distance | `~2.4 km` (scan) · `~2.4 km straight line` (commit screens) |
| Rate | `600 RWF/kWh` · `From 400 RWF/kWh` · `No confirmed rate` |
| Watch | `Not watching` · `Alert requested` · `Watching until 15:12` · `one alert, next 2 h` |

v2 declared a *second*, CarPlay-only closed vocabulary (`in use`, `unreported`, no `busy`, no `unknown`)
while routing one shared function to ticket 19 — which would have handed 19 two contradictory
specifications of the same signature (M8). **The tie is broken toward the tighter surface**: Android has a
`CarText` variant ladder the host resolves; CarPlay has plain `String` and no ladder at all, so the shortest
honest word wins on both. `busy` and `broken` are ADR-0002's own prose (*"occupied means wait, broken means
go elsewhere"*), so the adopted set is also the settled document's set. v2's objection to `busy` was really
an objection to a grammar that folded `Unknown` and `OutOfService` into occupancy; the regime partition
(§5.3) makes that fold unrepresentable, which is the actual fix.

**What is surface-owned, not vocabulary:** capitalisation (CarPlay capitalises the source word when it
begins a string — `Operator, 14 min ago` — and lowercases it mid-string), the `·` separator, and the
compose-time ladder. These never change a word.

### 2.2 Invariant 1 — no cut may leave a number that reads as true

`Nyamirambo Center · ~187.2 km` cut to `Nyamirambo Center · ~18` is not lost information; it is a **false
number**, ten times nearer than the truth, and a driver picking on remaining range picks wrong (M4). This
is the one place where v2's own truncation doctrine inverted. Two mechanisms, together total:

- **The distance token leads its slot.** `place-line` is `~2.4 km · SP Remera`, not the reverse. The
  distance is the only unbounded, decision-critical numeral on the surface, and putting it at the head
  makes a mid-digit cut unreachable. The name is the safe tail — it is also carried by the Owner glyph on
  the same row, by the POI `title`, and by the detail template's title.
- **Every other numeral is a small count followed by its noun, and the composer asserts it is ≤ 9.**
  `2 of 4 bays free`, `1 unknown`, `3 bays`. A single digit cannot be cut mid-digit. A station with ≥10
  bays does not exist in the Rwandan corpus; the assertion fires rather than rendering, and what to render
  in that case is routed to 19 (§15.1).

Distance token forms, so the reserved width is knowable:

| Range | Form | Chars |
|---|---|---|
| < 10 km | one decimal — `~2.4 km` | 7 |
| 10–99 km | integer — `~24 km` | 6 |
| 100–999 km | integer — `~187 km` | 7 |
| ≥ 1000 km | `~999+ km` — unreachable under the origin ladder (§7.3), asserted | 8 |

Dropping the decimal at 10 km shortens the token *and* removes false precision from a crow-flies number.

### 2.3 Invariant 2 — what leads a slot is what survives

`CPListItem` takes a plain `String` and the platform guidance is to put the driving-relevant substring
first `[hard]`. For the availability slot the two orderings available are:

| Ordering | Truncates to | Reading |
|---|---|---|
| `2 of 4 bays free · operator, 14 min ago` | `2 of 4 bays free` | **a live claim** — the confident-stale failure ADR-0002 and ADR-0008 exist to make unrepresentable |
| `Operator, 14 min ago · 2 of 4 bays free` | `Operator, 14 min ago` | less informative, still honest, row still tappable |

The freshness head leads. Losing informativeness on a narrow head unit is a real cost, carried as
compromise §12.2 and mitigated by the ladder in §5.4.

### 2.4 Compose-time targets

These are **[inferred]** and their only job is to bound the composer. They are not compliance claims: below
them the string is emitted as authored, above them the ladder runs, and the head unit may still cut.

| Slot | Target | Composition rule |
|---|---|---|
| `CPListItem.text` — `place-line` | **29** | `~<distance> · <nameShort>`; = 8 + 3 + 18, the authored `nameShort` bound (§15.1) |
| `CPListItem.detailText` — `availability-line` | **52** | head leads; §5.4 ladder; protected head is **21** |
| `CPPointOfInterest.title` | 18 | `nameShort`, whole |
| `CPPointOfInterest.subtitle` | 28 | `~<distance> · <Owner.shortName>` — distance leads |
| `CPPointOfInterest.summary` | **52** | `availability-line`, row verbosity |
| `CPPointOfInterest.detailTitle` | 28 | `name` |
| `CPPointOfInterest.detailSubtitle` | **52** | `availability-line`, row verbosity |
| `CPPointOfInterest.detailSummary` | 90 | `~<d> km straight line · <connectors> · <rate>`; drops from the tail |
| `CPInformationItem.title` | 12 | fixed labels |
| `CPInformationItem.detail` | **52** | detail verbosity, no head (the head is its own item) |
| `CPTextButton.title` | **16** | |
| Template title | 24 | |
| Tab title | 8 | |
| Notification title / body | **30** / 40 | |

The protected head is **21**, not v2's 20: the longest legal head from the adopted vocabulary is
`EV Guide, 30 days ago` = 21 (minor 2). The 16-character button target is why the watch action ships as
**`Notify when free`** (exactly 16) and not ticket 30's phone label `Notify me when a bay frees up` (29);
`CPTextButton` has no variants, so 29 characters in a third of a small head unit is an outcome, not a risk.
Divergence routed to 30 (§15.5).

---

## 3. The worked corpus — five stations, exact strings in every slot

### 3.0 Fixture

Five stations, each present because it is the shape in which a specific defect is invisible.

```
S1  Kabisa – SP Remera      nameShort "SP Remera"    Kabisa · KAB   −1.9556, 30.1044   2.4 km
    B1 GB/T DC 60 kW  600 (12 d)  operator Free     −14 min  → Free
    B2 GB/T DC 60 kW  600 (12 d)  operator Occupied −14 min  → Occupied
    B3 Type 2  22 kW  600 (12 d)  operator Free     −14 min  → Free
    B4 Type 2  22 kW  600 (12 d)  operator Occupied −14 min  → Occupied
    n=4 f=2 o=2 x=0 u=0  · plugs m=4, priced c=4, 1 rate    ← the ticket's required example

S2  Numa – Kisimenti        nameShort "Kisimenti"    Numa · NUM                         3.1 km
    B1 CCS2   50 kW  no rate  no report → Unknown
    B2 Type 2 22 kW  no rate  no report → Unknown
    B3 Type 2 22 kW  no rate  no report → Unknown
    n=3 f=0 o=0 x=0 u=3  · m=3, c=0                         ← Regime 1, the majority case

S3  EVP – Kimironko         nameShort "Kimironko"    EVP · EVP                          5.6 km
    B1 GB/T DC 60 kW  450 (21 d)  operator Free         −25 min  → Free
    B2 GB/T DC 60 kW  450 (21 d)  driver   Occupied     −3 h 10  → decayed → Unknown
    B3 Type 2  22 kW  350 (21 d)  driver   Occupied     −40 min  → Occupied
    B4 Type 2  22 kW  350 (21 d)  operator OutOfService −6 days  → OutOfService
    n=4 f=1 o=1 x=1 u=1  · m=4, c=4, 2 rates                ← decay, all four states, 2 rates

S4  Kabisa – Nyabugogo      nameShort "Nyabugogo"    Kabisa · KAB                       7.3 km
    3 bays, each a dual-gun pedestal: GB/T DC 60 kW @600 + Type 2 22 kW @400, all (5 d)
    B1  GB/T operator Occupied −20 min · Type 2 no report      → bay Occupied  (occupancy propagates)
    B2  GB/T operator Free     −20 min · Type 2 no report      → bay Free
    B3  GB/T operator OOS      −2 days · Type 2 operator Free −20 min → bay Free
    n=3 f=2 o=1 x=0 u=0  · m=6, c=6, 2 rates on one pedestal
                                     ← dual-gun counting (M4), the lensed re-derivation (F-A), rate-per-plug (M9)

S5  Numa – Remera Mall      nameShort "Remera Mall"  Numa · NUM                         8.8 km
    B1 Type 2 22 kW  500 (3 d)  operator Occupied −10 min → Occupied
    B2 Type 2 22 kW  500 (3 d)  no report              → Unknown
    n=2 f=0 o=1 x=0 u=1  · m=2, c=2, 1 rate                 ← the F1 regression: `0 of 2` must be unreachable
```

**Why S4's third bay exists.** B3's GB/T gun is out of service and its Type 2 gun is free. Unlensed the bay
is **Free**; to a GB/T driver it is **OutOfService**. A lens that reused the unlensed bay state would send
a GB/T driver to a broken gun (§6.2). **Why S4 carries two rates on one pedestal.** A dual-gun bay can
carry two prices, so a rate clause denominated in *bays* is a category error (M9); with both guns at 600
the defect is invisible, which is exactly what v2's fixture did. **Why S5 exists.** It is the verdict's own
F1 counter-example, promoted to a fixture.

### 3.1 Map tab — `CPPointOfInterestTemplate`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Chargers nearby                                                     │  ← template title (§7.3)
│                                                                      │
│              [KAB]②        [NUM]                                     │  ← pin = Owner icon + markerLabel
│                                    [EVP]①                            │     badge = fresh free-bay count
│                        [KAB]②                                        │
│                          (MapKit draws all of this)                  │
├──────────────────────────────────────────────────────────────────────┤
│  SP Remera                                                           │  title
│  ~2.4 km · Kabisa                                                    │  subtitle
│  Operator, 14 min ago · 2 of 4 bays free                             │  summary
└──────────────────────────────────────────────────────────────────────┘
```

**Picker triple, all five stations, exact:**

| # | `title` | `subtitle` | `summary` |
|---|---|---|---|
| S1 | `SP Remera` | `~2.4 km · Kabisa` | `Operator, 14 min ago · 2 of 4 bays free` |
| S2 | `Kisimenti` | `~3.1 km · Numa` | `3 bays · CCS2 and Type 2` |
| S3 | `Kimironko` | `~5.6 km · EVP` | `Operator, 25 min ago · 1 bay free · 1 unknown` |
| S4 | `Nyabugogo` | `~7.3 km · Kabisa` | `Operator, 20 min ago · 2 of 3 bays free` |
| S5 | `Remera Mall` | `~8.8 km · Numa` | `Operator, 10 min ago · 1 bay busy · 1 unknown` |

S2's summary carries **no source-and-age head** — there is nothing to date. The capacity clause replaces
the availability clause rather than apologising for it (§7.1).

**Card triple + the two buttons, exact:**

| # | `detailTitle` | `detailSubtitle` | `detailSummary` |
|---|---|---|---|
| S1 | `Kabisa – SP Remera` | `Operator, 14 min ago · 2 of 4 bays free` | `~2.4 km straight line · 2 × GB/T DC 60 kW · 2 × Type 2 22 kW · 600 RWF/kWh` |
| S2 | `Numa – Kisimenti` | `3 bays · CCS2 and Type 2` | `~3.1 km straight line · 1 × CCS2 50 kW · 2 × Type 2 22 kW · No confirmed rate` |
| S3 | `EVP – Kimironko` | `Operator, 25 min ago · 1 bay free · 1 unknown` | `~5.6 km straight line · 2 × GB/T DC 60 kW · 2 × Type 2 22 kW · From 350 RWF/kWh · 2 rates` |
| S4 | `Kabisa – Nyabugogo` | `Operator, 20 min ago · 2 of 3 bays free` | `~7.3 km straight line · 3 bays, each GB/T DC 60 kW + Type 2 22 kW` |
| S5 | `Numa – Remera Mall` | `Operator, 10 min ago · 1 bay busy · 1 unknown` | `~8.8 km straight line · 2 × Type 2 22 kW · 500 RWF/kWh` |

`detailSummary` **leads with the straight-line label**, so ADR-0007's labelling obligation no longer rests
solely on an Information item the design designates as expendable (M7). It drops from the tail: S4's rate
token does not fit inside 90 and is dropped, because the Rate item on the detail screen one tap away
carries it in full.

`primaryButton` = **`Directions`** · `secondaryButton` = **`Details`**. There is no third `[hard]`.

**Template-level calls**

| Call | Value |
|---|---|
| `title` | `Chargers nearby` \| `Chargers near Kigali` \| `Chargers in view` — §7.3 |
| `setPointsOfInterest(_:selectedIndex:)` | `min(12, ranked)` `[hard]`, re-supplied on every `didChangeMapRegion` `[hard]` |
| delegate | mandatory `[hard]`; region-delta threshold (250 m or a zoom step) guards the re-supply loop |

**Pins.** `pinImage` is composited at runtime from `Owner.icon` (vector) + `Owner.markerLabel` (≤3 chars,
authored) at `CPPointOfInterest.pinImageSize` `[runtime]` and `carTraitCollection.displayScale`, in both
`contentStyle` variants. **`selectedPinImage` / `selectedPinImageSize` are iOS 16+** against an iOS 14
deployment floor `[hard]`, so they are set behind an availability guard; on iOS 14–15 one pin image serves
both states and nothing else changes (minor 1). The `markerLabel` is composited into the CarPlay pin — the
constraint routed from 19 ("Marker = Owner icon + ≤3-char markerLabel") is honoured on both platforms, and
twelve pins from three Owners stay distinguishable.

**The free-bay badge.** A small filled numeral badge carrying `f` is composited top-right of the pin **only
when `f > 0` at render time**. Because `f` is derived under decay, the badge's existence *is* its freshness
claim: it decays out by construction and can never be drawn stale. Grey is never drawn — an Unknown
station's pin is simply the Owner mark, which is a complete listing, not an apology (ADR-0002:
*"availability as an additive badge when it exists"*). S1 → `②`, S2 → no badge, S3 → `①`, S4 → `②`,
S5 → no badge.

### 3.2 Nearby tab — `CPListTemplate`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Chargers nearby                                                     │
├──────────────────────────────────────────────────────────────────────┤
│ [KAB]  ~2.4 km · SP Remera                                        ›  │
│        Operator, 14 min ago · 2 of 4 bays free                       │
├──────────────────────────────────────────────────────────────────────┤
│ [NUM]  ~3.1 km · Kisimenti                                        ›  │
│        3 bays · CCS2 and Type 2                                      │
├──────────────────────────────────────────────────────────────────────┤
│ [EVP]  ~5.6 km · Kimironko                                        ›  │
│        Operator, 25 min ago · 1 bay free · 1 unknown                 │
├──────────────────────────────────────────────────────────────────────┤
│ [KAB]  ~7.3 km · Nyabugogo                                        ›  │
│        Operator, 20 min ago · 2 of 3 bays free                       │
├──────────────────────────────────────────────────────────────────────┤
│ [NUM]  ~8.8 km · Remera Mall                                      ›  │
│        Operator, 10 min ago · 1 bay busy · 1 unknown                 │
└──────────────────────────────────────────────────────────────────────┘
```

| Slot | API | Value | Rule honoured |
|---|---|---|---|
| primary | `text` | `place-line` = `~<distance> · <nameShort>` | two text slots only `[hard]`; availability never in a title (settled Part C rule 1); **the number leads** (§2.2) |
| secondary | `detailText` | `availability-line(.row)` = `<Source>, <age> · <state clause>` | **the head leads**, so a cut removes information instead of manufacturing a live claim (§2.3) |
| image | `image` | Owner glyph at `CPListItem.maximumImageSize` `[runtime]`, light + dark | one small static mark per station |
| accessory | `accessoryType` | `.disclosureIndicator` | |
| id | `userInfo` | opaque `Station.id` — the sanctioned carrier `[hard]` | |

Row count = `min(CPListTemplate.maximumItemCount ?? 12, 12)` `[hard/runtime]`. Rows are independent and
distance-ranked, so a car that cuts the list to 12 — or `limitedUserInterfaces` containing `.lists`, which
iOS applies whether the app handles it or not `[hard]` — costs only the tail.

Leading the row with distance also makes the ranking key monotone down the list, which is the one property
a driver can verify at a glance.

**Empty-state variants** (`CPListTemplate` is the only template with length variants on this surface
`[hard]`), longest → shortest:

```
emptyViewTitleVariants     ["No chargers in the EV Guide directory", "No chargers listed", "None listed"]
emptyViewSubtitleVariants  ["EV Guide covers Rwanda — switch to Map to browse",
                            "EV Guide covers Rwanda", "Rwanda only"]
```

With the Kigali fallback (§7.3) and the bundled snapshot floor (§10.1), the only reachable path to this
state is an **empty directory**, for which v2's `"No chargers within 200 km"` was a false specific claim
(minor 6). The wording now states what is actually true on the one path that reaches it.

### 3.3 Station detail — `CPInformationTemplate`, layout `.leading`

Apple's own worked example for this template is *"an EV charging app may display information about a
charging station such as availability"* `[hard]`. `CPInformationItem` is a `title` + `detail` pair and
nothing else `[hard]`; there is **no documented and no queryable item cap** `[UNKNOWN]`, so the design
holds to **six**, ordered by decision value, with the load-bearing pairs first.

**Item order, and which one is the designed casualty**

| # | Item | Why here |
|---|---|---|
| 1 | `Availability` | the product |
| 2 | `Last report` | ADR-0002 requires the freshness axis beside the value |
| 3 | `Rate` | RURA Art. 27(2) makes a tariff a regulated public disclosure; pinned so it can never be the tail |
| 4 | `Distance` | ADR-0007 requires straight-line distance labelled as such; pinned ahead of the discretionary items (M7) |
| 5 | `Connectors` | the structural answer to "free for me" (§6.1) |
| 6 | `Bay alert` | **the casualty.** If an undocumented cap drops the tail, the *action button* still carries armed vs not-armed in its title (`Notify when free` / `Stop alert`), so the function survives; only the *not-confirmed-yet* nuance is lost |

**S1 — signed in, notifications authorised, no vehicle profile:**

```
┌──────────────────────────────────────────────────────────────────────┐
│ ‹   Kabisa – SP Remera                                               │
├──────────────────────────────────────────────────────────────────────┤
│  Availability    2 of 4 bays free                                    │
│  Last report     Operator, 14 min ago                                │
│  Rate            600 RWF/kWh · all 4 plugs · 12 days ago             │
│  Distance        ~2.4 km straight line                               │
│  Connectors      2 × GB/T DC 60 kW · 2 × Type 2 22 kW                │
│  Bay alert       Not watching · one alert, next 2 h                  │
├──────────────────────────────────────────────────────────────────────┤
│         [ Directions ]        [ Notify when free ]                   │
└──────────────────────────────────────────────────────────────────────┘
```

**S2 — Regime 1, anonymous (5 items; `Bay alert` absent, not disabled):**

```
│  Availability    3 bays · up to 50 kW                                │
│  Last report     Not reported recently                               │
│  Rate            No confirmed rate                                   │
│  Distance        ~3.1 km straight line                               │
│  Connectors      1 × CCS2 50 kW · 2 × Type 2 22 kW                   │
├──────────────────────────────────────────────────────────────────────┤
│         [ Directions ]                                               │
```

The detail verbosity of the capacity clause carries **peak power**, not types, because `Connectors` is two
rows below it on the same screen; the row verbosity carries **types**, because on a row nothing else can
(§5.3). Same function, one verbosity parameter.

**S3 — all four states, signed in, no profile:**

```
│  Availability    1 bay free · 1 busy · 1 out of service · 1 unknown  │
│  Last report     Operator, 25 min ago                                │
│  Rate            450 RWF/kWh GB/T DC · 350 Type 2 · 21 days ago      │
│  Distance        ~5.6 km straight line                               │
│  Connectors      2 × GB/T DC 60 kW · 2 × Type 2 22 kW                │
│  Bay alert       Not watching · one alert, next 2 h                  │
```

**S4 — dual-gun, two rates on one pedestal, signed in:**

```
│  Availability    2 of 3 bays free                                    │
│  Last report     Operator, 20 min ago                                │
│  Rate            600 RWF/kWh GB/T DC · 400 Type 2 · 5 days ago       │
│  Distance        ~7.3 km straight line                               │
│  Connectors      3 bays, each GB/T DC 60 kW + Type 2 22 kW           │
│  Bay alert       Not watching · one alert, next 2 h                  │
```

`Connectors` never says *"3 × GB/T DC · 3 × Type 2"*, which would invent three parking positions that do
not exist. `Rate` is denominated in **plugs**, never bays (§5.5).

**S4 under a GB/T DC lens** — the two items the lens touches:

```
│  Availability    1 of 3 GB/T DC bays free · 1 out of service         │
│  Bay alert       Not watching · GB/T DC only, next 2 h               │
```

**S5 — the F1 regression, signed in:**

```
│  Availability    1 bay busy · 1 unknown                              │
│  Last report     Operator, 10 min ago                                │
│  Rate            500 RWF/kWh · all 2 plugs · 3 days ago              │
│  Distance        ~8.8 km straight line                               │
│  Connectors      2 × Type 2 22 kW                                    │
│  Bay alert       Not watching · one alert, next 2 h                  │
```

Under a Type 2 lens S5 reads `1 Type 2 bay busy · 1 unknown` — **never** `0 of 2 Type 2 bays free`. §5.3
emits a denominator only where the unknown count is zero, so the string is unreachable by construction
(§6.4).

**Actions** — `CPTextButton`, ≤3 `[hard]`, this design uses ≤2:

| Condition | Action 1 | Action 2 |
|---|---|---|
| any driver | `Directions` (`.confirm` style) | — |
| `canWatch`, not armed | `Directions` | `Notify when free` |
| `canWatch`, armed | `Directions` | `Stop alert` |

`Directions` is unconditional and anonymous on every path (ADR-0003 as amended). No car screen presents a
sign-in wall of any kind.

### 3.4 The three alerts — `CPAlertTemplate`, presented, never pushed `[hard]`

| | A1 | A2 | A3 |
|---|---|---|---|
| trigger | `Notify when free` tapped while the watched set is already effectively Free | the directions ladder (§8.1) exhausts every enabled rung | `Notify when free` tapped while 3 watches are already armed (M3) |
| `titleVariants` | `["Bays are free right now", "Bays are free now", "Free now"]` | `["Directions aren't available right now", "Directions aren't available", "No directions"]` | `["You're already watching 3 chargers", "Already watching 3", "3 already"]` |
| actions | `OK` | `OK` | `OK` |

All three **state a condition without instructing anyone to touch a phone** — the exact latitude guideline 2
permits `[hard]`. `CPAlertTemplate.maximumActionCount` is undocumented `[runtime]`; every alert is authored
at one action, so no ceiling can bite. A3 is checked against `armedWatches` in Store B **before** a
`pendingIntent` is written, so the device never asserts a request it already knows the server will reject.

### 3.5 The bay-watch notification

| Field | Value |
|---|---|
| Authorisation | `UNAuthorizationOptions [.alert, .sound, .carPlay]` `[hard]` |
| Category | `EV_GUIDE_BAY_FREE`, created with `.allowInCarPlay` `[hard]` — both are required, either alone is insufficient |
| Title | `SP Remera · bay free` (target 30; worst case 18 + 11 = 29) |
| Body | `A bay just freed up · operator report` |
| Tap | deep link → station detail for `stationId` |

Written to be **read, not heard** — notifications are generally not read aloud in CarPlay `[hard]`. The
station leads the title so a driver with up to three armed watches knows which one fired; the meaning is
restated in the body, so a title cut costs nothing (v2's `SP Remera · a bay is free` was 34 against its own
28-char target, and cut into `…a bay is`). One event type, total. Fires only on a **report-driven**
transition into `Free`; decay never fires it (ticket 30). One-shot, max 3 armed, 2 h expiry, so no
repeat-fire path exists and no digest, quiet-hours or rate-limiter machinery is built. Users can switch
CarPlay notifications off per app `[hard]`: nothing on the surface depends on car delivery — the watch
still fires on the phone, and the armed item clears on completion either way.

**The deep link's stack effect.** The intent pushes the detail template onto the active tab's stack. If a
detail template is already on top it is **replaced**: by mutating `items`/`actions` in place if
`CPInformationTemplate` is mutable at the target OS, and otherwise by pop-then-push, which is
depth-neutral. Which of the two applies is on §14's verification list, so §3.5 states both rather than
presuming the mutable one (minor 10). Max depth stays 3 either way.

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
                                       │ A1 / A2 / A3     │
                                       └──────────────────┘
```

| Node | Template | Depth | Push out-edges |
|---|---|---|---|
| R | `CPTabBarTemplate` | **1** | none (tab selection is not a push) |
| A | `CPPointOfInterestTemplate` | **2** | → D |
| B | `CPListTemplate` (Nearby) | **2** | → D |
| C | `CPListTemplate` (Saved) | **2** | → D |
| D | `CPInformationTemplate` | **3** | **none** |
| A1, A2, A3 | `CPAlertTemplate` | modal | none |

**Proof that 5 holds `[hard]`.** The graph has exactly three push edges, all of the form *(tab root at 2) →
(detail at 3)*, and D is a sink. Maximum reachable push depth is therefore **3**, under the conservative
reading that the tab bar occupies level 1. Two levels of headroom remain unused. No invariant is asserted
at runtime and no push wrapper is needed.

Every function is reachable in ≤3 taps: Directions in **2** (select pin → `Directions`), the watch in **3**
(select pin → `Details` → `Notify when free`), a station detail in **2**.

---

## 5. The grammar — one shared function, and where CarPlay's part begins

### 5.1 The chain

```
Report(connector)                  latest per Connector, by capturedAt (most-recent-wins, ticket 11)
   │  any source declaring itself offline → Unknown immediately (ADR-0002)
   │  ADR-0002 decay: window(source, state) — driver 2 h · operator 6 h · OutOfService 30 d
   ▼
effective(connector, now) ∈ {Free, Occupied, OutOfService, Unknown}
   │  ADR-0008 bay propagation: Free → Occupied while any sibling on the Bay is Occupied
   ▼
bayState(bay, now)  ·  bayState_T(bay, now) under a lens (§6.2)     ← named domain functions, routed to 19
   │  count
   ▼
(n, f, o, x, u)                    f+o+x+u = n ; known k = f+o+x
   │  Grammar G (§5.3) · freshness head (§5.4) · Grammar R (§5.5) · Grammar Q (§6)
   ▼
clause strings                     ← SHARED with Android Auto, no CarPlay branch
   │  assembly: slot, order, compose-time ladder                     ← CarPlay's part, §2 and §5.4
   ▼
one String per slot
```

**The boundary matters, because the two surfaces truncate differently.** Android hands the host a `CarText`
variant ladder and the host picks; CarPlay hands the system one plain `String` and the system cuts the
tail. So Android's ladder drops the freshness head first and keeps the state counts; CarPlay must do the
opposite (§2.3) or a cut manufactures a confident live claim. **That difference is assembly, not grammar.**
The shared function returns *clauses*; each surface orders and ladders them. Ticket 19 gets one signature
and one word set, not two (§15.1).

### 5.2 `bayState(bay, now)` — precedence, total

Let `s = { effective(c, now) : c ∈ bay.connectors }`.

| Test, in order | Result | Why |
|---|---|---|
| `Occupied ∈ s` | **Occupied** | one vehicle occupies the position (ADR-0008 propagation) |
| `Free ∈ s` | **Free** | a working gun on a free position |
| `s ⊆ {OutOfService}`, `s ≠ ∅` | **OutOfService** | every gun on the position is known broken |
| otherwise | **Unknown** | at least one gun is Unknown and none is Free or Occupied |

Worked: S4/B1 `s = {Occupied, Unknown}` → Occupied. S4/B2 `s = {Free, Unknown}` → Free. S4/B3
`s = {OutOfService, Free}` → Free. S3/B2 `s = {Unknown}` (the driver Occupied report is 3 h 10 old, past
the 2 h driver window) → Unknown.

### 5.3 Grammar G — the availability clause, cited not restated

**`02-androidauto-design-v2.md` §3.2 is the specification.** Its three regimes partition `(n, f, o, x, u)`
and CarPlay adopts them verbatim:

| Regime | Condition | Form |
|---|---|---|
| **1** | `u = n` — nothing known | **capacity clause**, no availability words, no freshness head |
| **2** | `u = 0` — everything known | a total is legitimate: `2 of 4 bays free` · `1 of 4 bays free · 1 out of service` · `All 4 bays busy` · `No free bays · 1 out of service` · `All 4 bays out of service` |
| **3** | `0 < u < n` | **no total, no fraction, never the word *all***: the non-zero counts in fixed order — `{f} bay(s) free · {o} busy · {x} out of service · {u} unknown` |

Three properties follow, and they are the tests ticket 19 should carry:

1. **A denominator appears only in Regime 2, where the known set and the total coincide.** So *the
   denominator is always the known set* — and `0 of N free` is **unreachable by construction**: Regime 3
   emits no denominator at all, and Regime 2 with `f = 0` emits `All N bays busy` or
   `No free bays · …`, never `0 of N`. This is the property the lens broke in v2 (F1) and now inherits for
   free (§6.4).
2. **`busy` may only quantify `o`.** Never a bay counted in `u` or `x`.
3. **`OutOfService` never folds into occupancy** at any count — occupied means wait, broken means go
   elsewhere (ADR-0002). And the word *all* never appears beside *busy* when any bay is broken.

**The capacity clause is the one place CarPlay parameterises the shared function**, because CarPlay has no
third slot for types:

| Verbosity | Form | Used in |
|---|---|---|
| `row` | `3 bays · CCS2 and Type 2` | `CPListItem.detailText`, POI `summary` / `detailSubtitle` — nothing else on a row can carry types, and types are what answer "free for me" |
| `detail` | `3 bays · up to 50 kW` | `CPInformationItem.detail` — the `Connectors` item is two rows below on the same screen |

**The distinguishing rule, learnable in one glance:** an availability clause always contains a state word
(`free` / `busy` / `out of service` / `unknown`); a capacity clause never does. `3 bays · CCS2 and Type 2`
cannot be misread as `3 bays free`.

### 5.4 The freshness head — scope, and the compose-time ladder

**Format:** `<Source>, <age> ago` at the head of a row slot (capitalised because it begins the string);
`<Source>, <age> ago` as the `Last report` item's value on the detail screen, where it is its own labelled
item and no head is prefixed to `Availability`.

**Scope — the leading clause, inside the lens.** Contributing reports are the latest in-window report per
Connector on the bays counted in **the state named first by the clause**, intersected with the lensed
subset when a lens is active:

| The clause leads with | Contributors are the reports behind |
|---|---|
| `free` (`f > 0`) | the Free bays |
| `busy` (`f = 0`, `o > 0`) | the Occupied bays |
| `out of service` (`f = o = 0`) | the OutOfService bays |
| nothing (Regime 1) | **no head is emitted** — freshness qualifies a state, and Regime 1 asserts none |

Source = the **weakest** contributor (`driver < operator < admin`); age = the **oldest** contributor.

This supersedes both v2 documents' rules and fixes two defects at once. v2 (CarPlay) computed the head over
*all* known bays and excluded `OutOfService` by a special case; the result was S3 rendering
`Driver, 40 min ago · 1 bay free` where the free bay was a **25-minute-old operator** report — the head did
not date the fact beside it (minor 8). And neither version's rule had a lens term, so under a lens the head
dated reports about connectors outside the set being quantified (M6). Scoping to the leading clause makes
both correct by construction, and it subsumes Android's `OutOfService`-exclusion rule: an `OutOfService`
report sets the head only when `x` is the leading state, which is exactly when its 30-day age is the right
thing to show. Routed to 19 and to the Android design as one reconciliation (§15.1, §15.9).

`mixed` is not adopted: it is a fourth word in a three-word source vocabulary, it is not a source, and
Android's own ladder already collapses it to the weakest contributor. Weakest-always is the intersection of
the two rules and is a consistent lower bound on confidence.

**The row ladder.** CarPlay has no variants, so the *composer* resolves the ladder against the 52-character
target and emits one string. Steps run in order until the string fits:

| # | Drop | Guard |
|---|---|---|
| 0 | the lens remainder clause (`· 2 other bays`) | lens only |
| 1 | `out of service` → `broken` | always |
| 2 | the `busy` count | only when `f > 0` — when `f = 0` it is the leading clause and dates the head |
| 3 | the `broken` count | only when `f > 0` — when `f = 0` it changes the decision from *wait* to *go elsewhere* |
| 4 | `ago` | |
| 5 | the age, keeping the source word | |

**Never dropped:** the `free` count, the `unknown` count, and the source word. Worked, with counts:

| Case | Ladder | Result | Chars |
|---|---|---|---|
| S1 `(4,2,2,0,0)` | — | `Operator, 14 min ago · 2 of 4 bays free` | 39 |
| S3 `(4,1,1,1,1)` | 1 → 2 → 3 | `Operator, 25 min ago · 1 bay free · 1 unknown` | 45 |
| `(4,0,1,1,2)` | 1 | `Operator, 25 min ago · 1 busy · 1 broken · 2 unknown` | 52 |
| S5 `(2,0,1,0,1)` | — | `Operator, 10 min ago · 1 bay busy · 1 unknown` | 45 |
| S4 GB/T lens `(3,1,1,1,0)` | 1 → 3 | `Operator, 20 min ago · 1 of 3 GB/T DC bays free` | 46 |

v2 claimed in §11.3 that every string was authored to its budget while §5.3's clauses ran to 67 characters
against a 44-character budget (M10). The ladder is the reconciliation: **one number, 52, for every
availability slot**, a defined drop order, and §12.2 carrying the residual honestly rather than as an edge
case. The detail verbosity has no head, so the longest clause in the corpus —
`1 bay free · 1 busy · 1 out of service · 1 unknown`, 50 — fits the same 52 without laddering.

### 5.5 Grammar R — the rate clause, denominated in plugs

Rate lives on the **Connector** `[settled]`. A dual-gun bay can carry two prices, so a *bay* denominator is
a category error (M9). Partition the station's `m` connectors into `c` with a confirmed in-window rate and
`m − c` without. `02-androidauto-design-v2.md` §3.5 is the specification; CarPlay assembles it into one
52-character slot rather than two lines:

| Condition | `Rate` value |
|---|---|
| `c = 0` | `No confirmed rate` |
| one distinct rate, `c = m` | `600 RWF/kWh · all 4 plugs · 12 days ago` |
| one distinct rate, `c < m` | `600 RWF/kWh · 3 of 5 plugs · 12 days ago` |
| two distinct rates | `450 RWF/kWh GB/T DC · 350 RWF/kWh Type 2 · 21 days ago` |
| ≥3 distinct rates | `From 400 RWF/kWh · 3 rates · 5 days ago` |

Assembly ladder against 52, in order: (1) drop `all N plugs` when `c = m`; (2) state the unit once —
`450 RWF/kWh GB/T DC · 350 Type 2`; (3) drop the age. **Never dropped:** the price (or `No confirmed
rate`), and `k of m plugs` whenever `k < m`. Worked: S3 → `450 RWF/kWh GB/T DC · 350 Type 2 · 21 days ago`
(46) · S4 → `600 RWF/kWh GB/T DC · 400 Type 2 · 5 days ago` (45) · S1 →
`600 RWF/kWh · all 4 plugs · 12 days ago` (39) · S5 → `500 RWF/kWh · all 2 plugs · 3 days ago` (38).

`No confirmed rate` — never *"not published"*, which would assert something about a licensee's RURA
Art. 27(2) compliance that EV Guide cannot know. A rate past its 90-day window is treated exactly like a
decayed availability: the number is not shown at all. In the POI `detailSummary`, where the slot is 90 and
the type mapping does not fit, a multi-rate station renders `From 350 RWF/kWh · 2 rates` — a floor over the
confirmed set with the count stated in the same breath, and the full mapping one tap away on the detail
screen.

**Rate never appears on a row** `[settled]` — two slots, and both are spent.

---

## 6. "Free for me" when the car does not know the driver's connector

### 6.1 The default is not knowing

CarPlay has **no `CPChargingStationConnection`** for a charging app and **no `EnergyProfile` equivalent at
all** `[hard]`. There is no car-side source for the driver's plug and no permitted screen on which to ask
for one — a plug picker is a settings screen, which guideline 4 names by example. So the primary answer is
structural:

> **Every surface states the connector types plainly, and the driver does the matching by reading.** The
> row's capacity clause carries types whenever nothing is known; the POI card's `detailSummary` always
> carries them with power; the detail screen's `Connectors` item always carries them with counts and power.
> "Free for me" is answered by *reading*, never by the list's shape.

### 6.2 The lensed bay state — occupancy propagates, capability does not

`vehicleConnectorTypes` may be mirrored into the car facet from the phone profile (§10.3). When present it
is a **lens on wording only**: it changes what the `Availability` item and the row's state clause quantify,
and it **never** changes presence, count, order or ranking. `stationsNear` stays distance-first then
availability, total, with **no reserved slot** for a nearest-compatible station. Incompatible stations are
never hidden and never demoted — filtering would empty the map in a market where multi-standard sites are
the legal norm.

A lensed roll-up must be **re-derived over the bay's T-offering connectors only**. Reusing the unlensed bay
state is the mirror of the double-counting defect, and it is decision-changing in the *go* direction:

```
bayState_T(bay, now), T = the driver's connector types
  1. if bayState(bay, now) = Occupied            → Occupied      ← a vehicle holds the position; no gun on
                                                                   it is usable, whatever its type
  2. s_T ← { effective(c, now) : c ∈ bay.connectors, type(c) ∈ T }
     if s_T = ∅                                  → bay is not in the offers-T subset
  3. if Free ∈ s_T                               → Free
  4. if s_T ⊆ {OutOfService}                     → OutOfService
  5. otherwise                                   → Unknown
```

**Occupancy propagates into the lens because it is physical; capability does not because it is per-gun.**
Two consequences, both exercised by S4:

- **S4/B3** — GB/T gun OutOfService, Type 2 gun Free. Unlensed: **Free**. Under a GB/T lens:
  **OutOfService**. Without step 4 a GB/T driver would be sent to a broken gun on the strength of a report
  about a different plug.
- **S4/B2** — GB/T gun Free, Type 2 gun never reported. Under a Type 2 lens: **Unknown**, not Free. A free
  sibling never vouches for an unreported gun; that would be asserting an unproven *positive*, which is the
  same class of error as F1's unproven negative.

Per-type capacity: `baysOffering(T)` = bays carrying ≥1 Connector of type `T`. A bay is counted **once per
type**, so each individual denominator is ≤ `n`; only the **sum across types** may exceed it (S4:
`baysOffering(GBT) = baysOffering(T2) = 3`, sum 6 > n 3). `knownBaysOffering(T)` = those whose `bayState_T`
is not Unknown.

### 6.3 Grammar Q — one side of the partition is named, the other is not

`02-androidauto-design-v2.md` §3.6 is the specification, and CarPlay now uses it instead of carrying a
second, weaker lens grammar:

> **Name exactly one side of a binary partition.** `offers-T` and `does-not-offer-T` partition the bays.
> Name the driver's side by type and count; name the other side as `<k> other bays`, its types listed only
> where a slot has room, and **never counted by type**.

`n_T + (n − n_T) = n`, always, because the partition is on *offers this type*, not on *is this type*. A
dual-gun bay is counted once, on the driver's side, and never again.

### 6.4 The lens grammar is Grammar G over the lensed subset — so `0 of N` cannot be said

| Situation | `Availability` value |
|---|---|
| no lens | Grammar G over all `n` bays |
| `baysOffering(T) = 0` | `No GB/T DC bay here · 4 bays, Type 2 and CCS2` |
| otherwise | **Grammar G over `(n_T, f_T, o_T, x_T, u_T)`**, type-qualified, `· <n − n_T> other bays` appended when non-zero and the slot has room |

That is the whole fix. v2's §6.4 had a third row of its own — `<freeBaysOffering(T)> of <baysOffering(T)>
bays free` — whose denominator was a **capacity** count including Unknown bays, so a station with one
Occupied and one never-reported Type 2 bay rendered `0 of 2 Type 2 bays free`: a positive claim that the
unreported bay is not free, disproved by v2's own denominator law (now §5.3 property 1) and by CONTEXT.md's
rule that Unknown is never rendered as an absence. Deleting that row and delegating to Grammar G removes the possibility rather
than the instance — Regime 3 emits no denominator, and Regime 2's denominator *is* `knownBaysOffering(T)`
because `u_T = 0` there.

Worked over the corpus:

| Station | Lens | Subset | Regime | `Availability` value |
|---|---|---|---|---|
| S5 | Type 2 | `(2,0,1,0,1)` | 3 | `1 Type 2 bay busy · 1 unknown` — **never** `0 of 2 Type 2 bays free` |
| S3 | GB/T DC | `(2,1,0,0,1)` | 3 | `1 GB/T DC bay free · 1 unknown · 2 other bays` |
| S3 | Type 2 | `(2,0,1,1,0)` | 2 | `No free Type 2 bays · 1 out of service · 2 other bays` |
| S3 | CCS2 | `n_T = 0` | — | `No CCS2 bay here · 4 bays, GB/T DC and Type 2` |
| S4 | GB/T DC | `(3,1,1,1,0)` | 2 | `1 of 3 GB/T DC bays free · 1 out of service` — remainder is 0, clause omitted |
| S4 | Type 2 | `(3,1,1,0,1)` | 3 | `1 Type 2 bay free · 1 busy · 1 unknown` |
| S2 | Type 2 | `(2,0,0,0,2)` | 1 | `2 Type 2 bays · up to 22 kW · 1 other bay` |
| S1 | GB/T DC | `(2,1,1,0,0)` | 2 | `1 of 2 GB/T DC bays free · 2 other bays` |

Row assembly adds the head (scoped to the lensed subset, §5.4) and runs the ladder; step 0 drops the
remainder clause first, because the remainder is restated by the `Connectors` item on the screen the row
leads to. S3/GB-T DC row: `Operator, 25 min ago · 1 GB/T DC bay free · 1 unknown` (50).

### 6.5 What the watch sends

`watch(stationId, connectorTypes[])` carries the mirrored profile's types when one exists and `[]`
(= all types) otherwise, and the `Bay alert` item says which: `Not watching · one alert, next 2 h` becomes
`Not watching · GB/T DC only, next 2 h` under a lens. Without this the same tap means different things to a
driver who changed cars.

---

## 7. Unknown, decay, and the origin

### 7.1 Unknown is a complete listing, never an absence

`Unknown` is the **normal case** — 67 of 77 Rwandan charge points reported nothing in the only real dataset
examined. The rules:

| Rule | Effect |
|---|---|
| Regime 1 emits **no availability clause at all** | the slot carries capacity + types instead: `3 bays · CCS2 and Type 2` |
| No greying, no dimming, no apology, no "no data" phrasing | the scan never spends its scarcest slot on an absence |
| No pin badge is drawn | absence of a badge, never a grey badge |
| Nothing animates, pulses, or spins | `[hard]` on both platforms |
| The word `unknown` appears **only as a count beside other counts** | `1 bay free · 1 unknown` states what is known and what is not; it never stands alone as a state |

Only the detail screen's `Last report` item states the negative directly — `Not reported recently` — and it
does so on a screen where four other items are carrying complete, confident facts, at the moment the driver
is committing to a drive.

### 7.2 Decay and age both run at render, and both need a deadline

Decay runs **at render** (ADR-0008). A template composed once and never recomposed will therefore show a
value past its window — a driver opening the detail on a 1 h 57 m-old driver report sees
`Driver, 1 h 57 min ago · 2 of 4 bays free`, and three minutes later the window closes while the screen
still reads free. **And the age string decays too**: a detail screen opened on `Operator, 14 min ago` whose
only availability deadline is at +6 h renders `14 min ago` for five hours and forty-six minutes (M1). The
state stays inside its window; the freshness axis — which ADR-0002 makes the entire confidence expression —
goes stale and confident.

**Fix — one-shot deadlines over both axes, no polling.**

```
nextDecayDeadline(displayed, now) = min over every displayed value of
    availability  :  capturedAt + window(source, state)
    age label     :  the next age-word boundary  (just now → N min → N h → N days)
    rate          :  rateConfirmedAt + 90 days
    watch         :  armedAt + 2 hours
```

Schedule one timer at that instant; on fire, recompose in place (or pop-then-push, §3.5) and schedule the
next. Coalescing rules, so the inferred refresh floors still hold `[inferred]`:

| Template | Coalescing |
|---|---|
| `CPPointOfInterestTemplate` | deadlines bucketed to **60 s**, so twelve POIs whose reports were captured in the same minute produce one recomposition, not twelve (minor 3) |
| lists and the detail template | bucketed to **10 s** |

**Recompose triggers:** scene connect, **scene became active**, and a fired deadline. Adding *became
active* is not optional — a one-shot timer missed while the scene was suspended (driver in Maps, then back)
restores exactly the stale screen this section exists to prevent; on resume, any deadline already past
fires immediately (minor 4).

### 7.3 Origin — ranked to the viewport, measured from the driver

`stationsNear(origin, limit)` takes an **arbitrary origin**, never a hardcoded device location `[settled]`.
v2 conflated two origins into one and produced M5: the Map tab ranked *and measured* to the visible-region
centre, so a driver in Kigali who panned to Musanze read `~2.4 km` for a station 90 km away, while the same
station read `~91 km` on the Nearby tab. **The two are now separate:**

| | Value |
|---|---|
| **Rank origin** | the visible-region centre on the Map tab (mandatory `[hard]` — the delegate fires on region change and the app must re-rank); the measure origin on the list tabs |
| **Measure origin** | **always the driver's origin**, on every tab and every slot |

Every distance on every surface is therefore from the same point, and the two tabs can never disagree.

| Measure-origin condition | Origin | Template title |
|---|---|---|
| Device location authorised and within 200 km of any station | device location | `Chargers nearby`, or `Chargers in view` when the map has been panned |
| Denied, unavailable, or >200 km from every station | **Kigali centroid** | `Chargers near Kigali` — **on every tab, including when panned** |

The title is free of the two-slot row budget on both platforms, so the substituted origin gets said without
costing a row; the substitution disclosure outranks the pan disclosure, because a wrong origin makes every
number wrong while a pan only changes which stations are listed. Without it a driver in Kampala — or
Apple's reviewer in Cupertino — reads `~3.2 km` for a station 1,500 km away with nothing on the row able to
explain it.

The fallback row does three jobs. **Location permission cannot be granted from CarPlay**, and guideline 2
forbids telling anyone to grant it on the phone — so the map simply opens on Rwanda and works. It handles a
driver outside the coverage area. And it handles Apple's reviewer, for whom Apple states no mock-location
requirement (that is Google's rule), so the fallback is the only thing standing between the submission and
a blank map. No mock-GPS dependency, no debug flag, no special build. It also bounds every rendered
distance below 1000 km, which is what makes §2.2's distance token 8 characters wide.

### 7.4 Distance is computed, never fetched — and labelled

CarPlay shows **great-circle distance only**, computed on device from `Station.geo` and the measure origin.
Never Valhalla's driving distance, never an ETA.

Four reasons: zero network on the paint path, which the locked-phone rule effectively mandates; it works
offline and while locked, which a routing call does not; routing 12 POIs on every map pan is neither cheap
nor reliable on a Rwandan mobile link; and it sits furthest from the `carplay-maps` boundary — Apple
blesses *"distance/bearing text the app computes and puts in `summary` or `detailSubtitle`"* `[hard]`,
while ETA is one of the four things that tips an app over `[hard]`.

ADR-0007 requires straight-line distance to be **labelled as such**. On the car the label rides two slots
that are not the expendable tail: the **`~` prefix** everywhere it appears in a scan (`~2.4 km`), and the
words `straight line` at the **head** of the POI card's `detailSummary` (§3.1) as well as in the `Distance`
item, now pinned at position 4 (§3.3). v2 rested the obligation on a single item it simultaneously
designated as the cap casualty (M7). The `~` alone is not the label — to a driver it reads *approximately*,
not *crow-flies*; it is a reminder of a label stated twice elsewhere on the path. **The phone renders
Valhalla driving distance with no `~`**, which is what makes the prefix a convention rather than decoration
(minor 12). In a country whose road distance routinely runs 2–3× crow-flies, a driver picking on 6 km of
remaining range must not read the number as a road distance. Routed to ADR-0007 (§15.3).

**Banned by lint on this surface:** `ETA`, `min away`, `mins`, `arrive`, `duration`, and any route,
maneuver or polyline. Not merely unmodelled — a `carplay-maps` trigger if rendered.

---

## 8. Directions, the watch, Saved, and reporting

### 8.1 Directions — anonymous, unconditional, and honest about where it lands

ADR-0003 as amended: directions are ungated **everywhere**. No car screen presents a sign-in wall, and
`Directions` is present on the POI card and the detail template for every driver, signed in or not.

**ADR-0004 governs the rest of this section, verbatim:** *"Launching Google Maps onto the CarPlay/Android
Auto display is undocumented and unverified; it is an enhancement pending ticket 27's device test, and
ticket 18 designs without assuming it."* v2 shipped the Google Maps rung first and claimed guideline-3
compliance on the strength of two gates that cannot see the failure that matters (F2):

- `canOpenURL` reports only that **some** app claims the scheme.
- the completion handler's `Bool` reports only that the URL **was opened** — never *on which display*.

If it lands on the phone, rung 1 returns `true`, rung 2 never runs, and the primary action of the primary
category has silently pushed content onto the phone the driver must not touch — with nothing in the app
able to detect it.

**The ladder** — all rungs go through the **scene's** `open(_:options:completionHandler:)`, never
`UIApplication.shared.open` `[hard]`:

| Rung | URL | Ships enabled? | What is guaranteed |
|---|---|---|---|
| 1 | `comgooglemaps://?daddr=-1.9556,30.1044&directionsmode=driving` | **No — flag `googleMapsCarDisplayHandoff`, default OFF** | nothing, until ticket 27's device test says which display it lands on |
| 2 | `http://maps.apple.com/?daddr=-1.9556,30.1044&dirflg=d` `[hard]` | **Yes — the shipped path** | Apple Maps is always installed and **is** a CarPlay app, so the launch never requires the iPhone |
| 3 | alert A2 | yes | a tap is never silent |

The flag is a build-time constant, optionally overridden by a value synced into Store A (readable after
first unlock; **off** before it, and off on any read failure). It is flipped only by evidence from ticket
27, never by a hopeful default. `comgooglemaps` stays declared in `LSApplicationQueriesSchemes` `[hard]`
so the flag can be flipped without a resubmission. Coordinates, never a place name `[settled]` — station
names are not in Google's places index.

**What this design therefore claims, and what it does not.** It claims that the directions flow **never
requires the driver to touch the iPhone**, because the shipped rung launches an app that is always present
and always has a CarPlay screen. It does **not** claim that the driver gets a route: Apple Maps has no
directions in Rwanda (ADR-0004), so the best case is a destination shown on the car screen with no route,
and **what Apple Maps actually renders on CarPlay for a Rwandan `daddr` it cannot route has never been
verified — an error sheet is as plausible as a pin.** That verification is now a **blocking** item on §14
and §15.4, because the usefulness of the primary action rests on it. Both residuals are carried as
compromises §12.5 and §12.6, and the ladder is routed to ADR-0004 as an amendment (§15.2).

### 8.2 The watch — where it appears, and what it is allowed to promise

**Gate.** `canWatch = isSignedIn && notificationAuthorization == .authorized`.

`.provisional` is **excluded**. Provisional authorisation delivers quietly, straight to Notification
Center with no banner — precisely the alert a driver will never see while driving, which re-opens the hole
the gate exists to close (M2). Authorisation is **re-read live from `UNUserNotificationCenter` at compose
time** (readable while locked); Store B's `canWatch` bool is only a pessimistic default for the
pre-first-unlock window, and is never trusted over a live read, so it cannot outlive a phone-side sign-out
or a revoked permission. Who writes it: the phone app on every authorisation or session change, never the
car layer.

`carPlaySetting` being off is deliberately **not** part of the gate: the watch still fires on the phone, so
the promise is degraded, not broken. (`UNNotificationSettings.carPlaySetting` — verify in the SDK, §14.)

`canWatch` and the lens are snapshotted when the detail template is composed and are not re-read while it
is on screen, so the item count and action count cannot change under the driver's finger (§0.5).

**The `Bay alert` item's three states** — text varies freely, the item never does:

| State | Value | Action title |
|---|---|---|
| not armed | `Not watching · one alert, next 2 h` | `Notify when free` |
| armed, **not yet confirmed by the server** | `Alert requested · not confirmed yet` | `Stop alert` |
| armed and confirmed | `Watching until 15:12 · one alert` | `Stop alert` |

**An unsynced watch is not an armed watch.** Writing the armed row optimistically and reconciling silently
survives a *permanently* failing POST — in the rural-Rwanda case ADR-0007 exists for, the row would sit for
two hours asserting a live watch no server had ever heard of. The middle state states exactly what EV Guide
knows, which is that a request was made.

**The max-3 ceiling is checked before the request, not after.** Ticket 30 caps concurrent watches at three.
The device already holds `armedWatches[]` in Store B, so arming a fourth would write a `pendingIntent`,
render `Alert requested · not confirmed yet`, and sit for two hours asserting a request the device **knew**
would be rejected (M3). Instead: if `|armedWatches| ≥ 3`, no intent is written and alert **A3** is
presented. Same pattern as A1 — count-invariant, one action, states a condition without instructing phone
manipulation.

**A queued arm expires client-side at `armedAt + 2 h`**, exactly as ADR-0007 drops an unsent report past
its own decay window. A watch delivered three hours late arms a two-hour errand the driver abandoned.
`Watching until 15:12` is computed from `armedAt`, so an unconfirmed arm's window visibly shrinks and the
decay timer (§7.2) clears it at the deadline.

**Ticket 30 clause 3 — "arming is only offered when the watched set is not already Free"** — is honoured in
substance, not by hiding the control: tapping while the set is already Free arms nothing and presents alert
**A1**, which dismisses back to the detail. Hiding the action would make its presence depend on
availability, so a report landing while the screen is open would take the button away mid-reach. Divergence
routed to 30 (§15.5).

**Anonymous drivers see no `Bay alert` item and no second action, and nothing explains why.** Guideline 2
permits stating a condition and forbids instructing phone manipulation; silent omission is the derived safe
reading `[inferred]`. Carried as compromise §12.10.

### 8.3 Reporting is not on the car surface

Considered and declined for v1. A report is a per-**Connector** claim; from a car screen with a
multi-connector station in front of it, EV Guide would be fabricating which gun the driver meant. The
single-Bay-single-Connector carve-out is honest but declined for three reasons: driver reports are
proximity-gated on the captured location, so the action's *presence* would vary with the vehicle's position
— a moving target while driving, and the one thing §0.5 forbids; RURA Annex I makes multi-standard sites
the legal norm, so the carve-out covers a shrinking minority; and it needs an authenticated write from the
template layer, which §10.3's decision forecloses. Carried as compromise §12.7, deferred not refused, and
recorded as the cheapest available fourth function if EV-1 is ever contested.

### 8.4 Saved

The locked-readable car cache may hold only non-sensitive directory and availability data — but armed
watches and mirrored vehicle plugs already live in that same cache, so the rule has an explicit carve-out
(§10.3) or it has been broken silently. **The carve-out is taken explicitly, and Saved is admitted on the
same terms:** the car facet holds `savedStationIds` alongside `armedWatches` and `vehicleConnectorTypes`,
under one named exclusion list, with **no user identifier anywhere in the file**.

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

`CPVoiceControlTemplate` is **iOS 27+ for the charging category** `[hard]`, so it is unavailable to the
entire iOS 14–26 base; voice **recording** is navigation-only `[hard]`; and no SiriKit intent domain covers
"find a charger" for this entitlement. On the Android side `VC-1` applies to Media and Navigation only, so
voice is not mandatory there either. **No voice affordance in v1.** Revisit when the deployment floor rises
above iOS 27 — at which point Search and Voice Control arrive together and should be designed as one
addition.

### 9.4 Contrast and legibility

All artwork ships 2× and 3× and light/dark `[hard]`. The Owner glyph and marker label are drawn monochrome
so they hold contrast in both ambient styles without a per-style asset pair, and the free-bay badge is
drawn with the system accent over an opaque ground rather than as a colour-only signal.

---

## 10. On-device data, protection classes, and refresh

CarPlay is *"frequently used while iPhone is in a locked state"* `[hard]`. Every car screen must therefore
be paintable from cache with the phone locked and the network absent. No screen may be designed around a
spinner that resolves from the network, and none around user-specific state the cache cannot hold.

### 10.1 The paint floor

| Order | Source | Protection | Readable when? |
|---|---|---|---|
| 1 | **Store A** — the synced directory + reports cache | `NSFileProtectionCompleteUntilFirstUserAuthentication` `[inferred]` | after the first unlock since boot |
| 2 | **Bundled snapshot** — ADR-0007's release-time directory inside the app binary | app bundle resource | **any lock state, always** |

If Store A is unreadable or absent, the surface paints from the bundled snapshot with **all availability
Unknown** — i.e. every station in Regime 1, every row a capacity clause. Bundle resources carry no
data-protection class, so the car surface is *unconditionally* paintable: a driver who reboots the phone
and gets straight into the car meets a populated map, not an empty one whose only available explanation is
a string guideline 2 forbids.

**Store B before first unlock** is equally unreadable, and the surface degrades explicitly (minor 5):
`canWatch = false`, **no Saved tab**, **no armed state**, and **no lens** — every string renders in its
unlensed form. All four are the pessimistic direction, and all four are indistinguishable from a signed-out
driver, which is a state the design already renders without explanation.

### 10.2 Store A holds raw per-Connector reports, not aggregates

This is the single load-bearing schema decision on the car surface. `docs/domain-model.md` says `baysFree`
and `lastReportedAt` are *"computed projections materialised into sync payloads"*. If the car renders from
those materialised values, the device cannot re-apply decay (no `capturedAt` per connector), cannot re-run
bay propagation (no sibling grouping), cannot produce the lensed re-derivation of §6.2, and a
`baysFree: 2` written at sync time renders confidently hours later. **The central safety claim of the whole
product would be false precisely on the surface that most needs it.**

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
| Contents | `canWatch: Bool` (pessimistic default only) · `armedWatches[{stationId, connectorTypes[], armedAt, expiresAt, confirmed}]` · `pendingIntents[{op: arm\|disarm, stationId, connectorTypes[], at}]` · `savedStationIds[]` · `vehicleConnectorTypes[]` · `googleMapsCarDisplayHandoff: Bool` (default false) |
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

This gives the credential one named home, keeps the template layer free of secrets, and makes the honesty
of the armed state a consequence of the architecture rather than a rule someone must remember.

### 10.4 Refresh

| Trigger | Action | Blocking? |
|---|---|---|
| Scene connect | read Store A (or the bundled snapshot), compose, paint | **never blocks on network** |
| **Scene became active** | recompose; fire any deadline already past | no I/O (minor 4) |
| Scene connect, then ≤ every 5 min while connected | `changedSince(cursor)` delta sync in background | no — failure is silent |
| App foreground on phone | same delta sync | no |
| Every render | re-run ADR-0008 decay over cached `capturedAt` | pure function, no I/O |
| **Decay or age deadline reached** | recompose the affected template in place | **one-shot timer, bucketed 60 s POI / 10 s elsewhere** (§7.2) |
| POI region change | re-rank ≤12 to the region centre, `setPointsOfInterest`; **distances unchanged** (§7.3) | no I/O |
| Periodic POI refresh | ≤ once / 60 s `[inferred]` | no I/O |
| Any other periodic update | ≤ once / 10 s `[inferred]` | no I/O |
| Watch arm/disarm | check the 3-watch ceiling, then write `pendingIntent` and re-render as *not confirmed*; queue drains out of band | UI updates immediately |

Cold sync budget under 1 MB (ADR-0007). Photos are never fetched for a car surface `[settled]`.

**Row-set stability `[inferred]`.** While a list or the POI picker is on top, the row *set* is frozen except
on a **user action** — tab change, region pan, or a tap — or while the vehicle is **stationary**. Only text
and the pin badge change under the decay timer. The rule exists to stop a list reordering under a reaching
finger, and v2's "or 500 m of vehicle movement" exception swallowed it whole: at 60 km/h that is every
thirty seconds of driving, which is the reaching-finger case, not an exception to it (minor 9). v2 also
claimed Android enforces the same 500 m rule as a quota requirement; it does not —
`02-androidauto-design-v2.md` latches the origin and never re-anchors mid-instance, so the claim is deleted
rather than restated.

---

## 11. Constraint → satisfaction

### 11.1 Entitlement, templates, depth

| Constraint | How this design satisfies it |
|---|---|
| `com.apple.developer.carplay-charging`, iOS 14+ `[hard]` | Declared alone. No `carplay-maps`, no fueling combination. |
| Forbidden template = **runtime exception** `[hard]` | `CPMapTemplate`, `CPContactTemplate`, `CPNowPlayingTemplate`, `CPChargingStationConnection` never referenced; a build-time source check over the target enforces it. |
| No `CPWindow`, no drawing surface `[hard]` | Nothing is drawn. Strings, images, IDs only. |
| Entitlement is account-level, all-or-nothing `[hard]` | No staged rollout or kill switch is assumed anywhere. |
| **Stack depth 5 incl. root** `[hard]` | Max reachable depth **3**, proved structurally in §4. |
| Tab bar root-only, each tab its own hierarchy `[hard]` | `setRootTemplate` only; never pushed, never presented, never nested. |
| Modals presented, not pushed `[hard]` | A1, A2, A3 via `presentTemplate`. |
| Tabs ≤5, query `maximumTabCount` `[hard/runtime]` | 2–3 tabs; queried, with documented degradation to 2 and 1 (§1.5). |
| Tab bar contains Grid/Information/List/POI only `[hard]` | POI, List, List. |
| Tab icon 24×24 pt `[hard]` | 24 pt / 48 px @2× / 72 px @3×. SF Symbols available at the iOS 14 floor. |

### 11.2 Point of interest

| Constraint | How this design satisfies it |
|---|---|
| Max 12 POIs `[hard]` | `min(12, ranked)`; the composer cannot emit more. |
| Delegate mandatory; re-rank on every region change `[hard]` | `setPointsOfInterest(_:selectedIndex:)` on `didChangeMapRegion`, guarded by a 250 m / one-zoom-step delta threshold. Ranking follows the viewport; **distances do not** (§7.3). |
| *"limited to those most relevant or nearby"* `[hard]` | Ranked to the visible region centre, distance-first. |
| **Do not expose non-EV-charger locations** `[hard]` | The POI array is built from `Station` rows only. No fueling entitlement is held, so the expansion is foreclosed by design. |
| Exactly two card buttons `[hard]` | `Directions` + `Details`. The watch lives one level deeper. |
| Six plain-`String` slots, no variants `[hard]` | §3.1 fills all six, each composed to a §2.4 target with the §2.2/§2.3 invariants. |
| Pin sizes undocumented `[runtime]` | Pins composited at runtime from `pinImageSize` and `carTraitCollection.displayScale`; `Owner.icon` is a **vector** for exactly this reason. `selectedPinImage` is iOS 16+ and behind an availability guard (minor 1). |
| No animated images `[hard]` | Nothing on this surface animates. |

### 11.3 List, information, alert

| Constraint | How this design satisfies it |
|---|---|
| Cars may cut lists to 12; `maximumItemCount` undocumented `[hard/runtime]` | `min(maximumItemCount ?? 12, 12)`; rows independent and ranked, so truncation costs only the tail. |
| `CPListItem` = two text slots `[hard]` | `text` = `place-line`; `detailText` = `availability-line`. Two named projections, neither repeating the other. |
| **No truncation control on plain `String`** `[hard]` | Not claimed as compliance. §2.2 makes a cut unable to falsify a number; §2.3 makes it unable to manufacture a live claim; §5.4's ladder makes the composed string short before the system ever sees it. The residual — losing state detail on a narrow unit — is carried as §12.2, not asserted away. |
| `userInfo` is the sanctioned ID carrier `[hard]` | Opaque `Station.id` on every row. |
| List image size `[runtime]` | Owner glyph rendered to `CPListItem.maximumImageSize`. |
| `emptyView*Variants` — the one variant slot `[hard]` | Three variants each (§3.2). |
| `CPInformationTemplate` item cap **unknown, unqueryable** `[UNKNOWN]` | ≤6 items ordered by decision value; `Rate` at 3 and `Distance` at 4 so neither can be the tail; `Bay alert` is the designed casualty, and the *action* preserves the function if it is dropped (§3.3). |
| Information ≤3 actions `[hard]` | Never more than **two**. |
| `CPInformationItem` = title + detail only `[hard]` | Every item is a label/value pair. No image, accessory, or per-item action attempted. |
| `CPAlertTemplate.maximumActionCount` undocumented `[runtime]` | All three alerts authored at one action. |
| `titleVariants` on alerts `[hard]` | Three variants each. |
| `CPTextButton` = plain `String`, no variants `[hard]` | Every button title ≤16 chars (§2.4). |

### 11.4 Review guidelines

| Guideline | How this design satisfies it |
|---|---|
| 1 — *designed primarily to provide the specified feature* `[hard]` | Launch state is a populated charger map at zero taps. Two or three tabs, all of them chargers. Nothing else is on the surface. |
| 2 — *never instruct people to pick up their iPhone* `[hard]` | **Audited string by string: no string on any car screen mentions the phone, sign-in, installation, or permissions.** A1, A2 and A3 state conditions without instruction; account-gated affordances are silently absent. |
| 3 — *all flows must be possible without interacting with iPhone* `[hard]` | Browse, read availability with source and age, read rate and connectors, request directions, arm and disarm a watch — all complete on the car screen. The shipped directions rung is **Apple Maps**, always installed and itself a CarPlay app, so the flow never requires touching the iPhone. **Two limits stated rather than papered over:** what Apple Maps renders for a Rwandan `daddr` it cannot route is unverified (§14, blocking), and the Google Maps rung is **disabled by default** precisely because neither `canOpenURL` nor the completion handler can tell whether it landed on the car or the phone (§8.1, ADR-0004). |
| 4 — *meaningful while driving; no unrelated features* `[hard]` | No settings, no account screen, no profile editor, no plug picker, no about, no help, no photos, no history, no statistics. |
| 5 — no gaming or social networking `[hard]` | N/A. |
| 6 — never show message/text/email content `[hard]` | N/A — no such data exists in the model. |
| 7 — *templates for their intended purpose* `[hard]` | POI = charger locations; Information = charging-location detail (Apple's own named example); List = ranked chargers and saved chargers; Alert = a condition. |
| EV 1 — *can't just be a list of EV chargers* `[hard]` | Three functions above the directory: per-bay availability with source and freshness re-ranked to the viewport on every pan; the anonymous directions hand-off; bay-watch arm/disarm resolved by a CarPlay notification. **None is documented as sufficient — §12.11.** |
| EV 2 — *no non-charger locations on the map* `[hard]` | §11.2. |

### 11.5 Notifications, hand-off, locked phone

| Constraint | How this design satisfies it |
|---|---|
| Notifications permitted for EV charging `[hard]` | One category, one event type. |
| Requires `.carPlay` **and** `allowInCarPlay` `[hard]` | Both declared — and the action is gated on `.authorized`, re-read live at compose time; `.provisional` does not qualify (§8.2). |
| Users can disable per app; must degrade `[hard]` | Nothing depends on car delivery; the watch still fires on the phone and the armed item clears either way. |
| *"sparingly … important tasks required while driving"* `[hard]` | One-shot, max 3 armed (enforced on-device before the request), 2 h expiry, report-driven transitions only. No repeat path exists. |
| *"not read aloud"* `[hard]` | Written to be read: station leads the title, meaning restated in the body. |
| Hand-off via the **scene's** `open(_:options:completionHandler:)` `[hard]` | `CPTemplateApplicationScene.open`, never `UIApplication.shared.open`. |
| Receiving app must be a CarPlay app `[hard]` | Shipped rung is Apple Maps (guaranteed). Rung 1 targets Google Maps, itself a CarPlay navigation app — but **which display it lands on is undocumented**, so it ships off (§8.1). |
| Google Maps scheme declared `[hard]` | `comgooglemaps` in `LSApplicationQueriesSchemes`, so the flag can be flipped without resubmission; coordinates, never a place name. |
| No route, ETA, maneuver, polyline `[hard]` | No route entity exists; distance is great-circle; ETA vocabulary banned by lint (§7.4). |
| Locked-phone file classes `[hard]` | Stores A and B at `…CompleteUntilFirstUserAuthentication`; bundled snapshot as the pre-first-unlock floor; the degraded pre-unlock surface is specified (§10.1). |
| Locked-phone keychain classes `[hard]` | One credential at `kSecAttrAccessibleAfterFirstUnlock`, read only by `WatchSyncQueue`, never by the car layer. |
| Refresh floors 60 s / 10 s `[inferred]` | Adopted voluntarily; decay and age deadlines are bucketed to 60 s on the POI template and 10 s elsewhere, so clustered deadlines cannot breach them; region-change refresh is event-driven and uncapped, as Apple's text allows. |

---

## 12. Where the constraints force an ugly compromise

1. **The POI card has exactly two buttons, so bay-watch costs an extra tap.** `Directions` and `Details`
   are both indispensable from the map, which pushes the watch — one of the three functions clearing
   Apple's EV-1 bar — one level deeper than the action it competes with.

2. **A narrow head unit will truncate the state off the row, and the ladder will have shortened it first.**
   The freshness head is protected and the state clause is what gets cut, which is the right trade (§2.3) —
   but on a small screen a driver may see `Operator, 14 min ago` and have to tap to learn how many bays are
   free. Before that, §5.4's ladder may already have dropped the `busy` and `broken` counts. Nothing untrue
   is ever said; less is said than the driver would want.

3. **Rate cannot appear on a row.** In a market where a driver may well choose on price, the price is
   always one tap away and never in the scan.

4. **The car and the phone disagree about distance.** CarPlay shows great-circle; the phone shows Valhalla
   driving distance and an ETA. In Rwanda's terrain the two can diverge sharply. The `~` prefix and the
   `straight line` wording narrow the misreading; they do not remove the discrepancy.

5. **The shipped directions rung cannot route in Rwanda.** Apple Maps has no Rwandan directions (ADR-0004),
   so the guaranteed outcome is a destination on the car screen without a route — and **what Apple Maps
   actually draws for a `daddr` it cannot route is unverified**; an error sheet is possible. The flow
   completes on the car screen either way, which is what guideline 3 asks; its usefulness may be near zero
   until ticket 27 reports. This is the largest single loss in the design and it is not papered over.

6. **The Google Maps rung may land on the phone, and nothing in the app could tell.** `canOpenURL` reports
   only that some app claims the scheme; the completion handler reports only that the URL opened, never on
   which display. That is why the rung ships **off** (ADR-0004). If ticket 27 clears it, the compromise
   inverts into an enhancement; if ticket 27 finds it lands on the phone, the rung is deleted rather than
   shipped with a caveat.

7. **Reporting is not on the car surface at all.** A driver parked at a broken charger, phone locked in a
   pocket, has no way to say so from the screen in front of them. The alternative — fabricating a
   connector-level claim — is worse, and the single-connector carve-out is declined for the reasons in
   §8.3. A real loss.

8. **The plug lens qualifies wording but never filters or reorders, and there is no way to set a plug from
   the car.** A GB/T-only driver still sees Type 2-only sites at the top of their list, correctly labelled
   and occupying a slot. Filtering would hide complete listings and could empty the map; a plug picker is a
   settings screen guideline 4 names by example. And **before the first unlock there is no lens at all**,
   so the same driver sees unlensed strings on the trip where the phone rebooted.

9. **No search, so nothing outside the nearest twelve is reachable.** `CPSearchTemplate` is iOS 27+ and
   often keyboard-less while driving. Fine for tens of stations; it would not survive a directory ten times
   the size.

10. **Anonymous drivers meet a silently smaller screen.** No `Bay alert` item, no second action, and no
    string may explain either. Correct under guideline 2, and invisible to the driver as a *choice* rather
    than a bug.

11. **The largest risk is not a layout problem.** Two of the three pillars — availability and bay-watch —
    are invisible when the data is thin, which in year one is most of the time. A reviewer with a US origin
    sees the Kigali fallback map, tens of stations, and mostly capacity clauses. **That is close to Apple's
    own example of what is not sufficient.** Ticket 20's submission must demo against seeded data, walk the
    reviewer through the availability layer, and arm a live watch — with a demo account signed in **on the
    phone before connecting**, so the car screen never shows a wall and the state is simply already true.
    No layout choice available here changes that; ticket 23's fallback ladder is the answer if it fails.

12. **Choosing a tab does not restore a previous selection.** Scene connect always lands on Map. Simple and
    deterministic; a driver who was reading the list finds the map. Accepted rather than solved, because
    programmatic tab selection at the iOS 14 floor is unverified (§14).

---

## 13. Answers to the verdict

### 13.1 The two fatals

| # | Fix |
|---|---|
| **F1** — the lens asserts `0 of N free` over Unknown bays | §6.4 — v2's §6.4 row 3 is **deleted**. The lens now applies **Grammar G** (§5.3) to the lensed subset, so a denominator appears only in Regime 2 where `u_T = 0` and the denominator therefore *is* `knownBaysOffering(T)`; Regime 3 emits no denominator and Regime 2 with `f = 0` emits `All N bays busy` / `No free bays · …`. **`0 of N` is unreachable by construction, not by rule.** The remainder is named as one un-counted side of the partition (`2 other bays`), adopting Android's §3.6 rather than carrying a second, weaker grammar. Fixture **S5** is the verdict's own counter-example, promoted to the corpus. |
| **F1 / F-A** — a lensed roll-up must re-derive the bay state over the T-offering connectors only | §6.2 — `bayState_T`: unlensed `Occupied` propagates into the lens (physical), everything else is re-derived over the T-offering guns only. So S4/B3 (GB/T OutOfService + Type 2 Free) is **OutOfService** to a GB/T driver and **Free** unlensed, and S4/B2 (GB/T Free + Type 2 unreported) is **Unknown** to a Type 2 driver. Fixture **S4** gains a third bay to carry it. |
| **F2** — the ladder cannot detect landing on the phone; §11.4 and §14 claim otherwise | §8.1 — rung 1 is behind `googleMapsCarDisplayHandoff`, **default OFF**, flipped only by ticket 27 evidence, exactly as ADR-0004 requires of ticket 18; rung 2 (Apple Maps) is the shipped path. §11.4's guideline-3 row now claims only that no flow requires the iPhone, and names both unverified limits. §14's *"no longer on the critical path"* is deleted. *"May land on the phone"* is restored as compromise **§12.6**, and *"no route in Rwanda"* stands as **§12.5**. **"What Apple Maps renders on CarPlay for a Rwandan `daddr` with no route"** is added to §14 and §15.4 as a **blocking** item. |

### 13.2 The ten majors

| # | Fix |
|---|---|
| **M1** — the age string never rolls over | §7.2 — the age-word boundary is now a term in `nextDecayDeadline`, bucketed 60 s on the POI template and 10 s elsewhere so the inferred floors still hold. |
| **M2** — `canWatch` accepts `.provisional` | §8.2 — `.authorized` only; re-read live from `UNUserNotificationCenter` at compose time; Store B's bool is a pre-first-unlock pessimistic default and is named as written by the phone app, never the car layer. |
| **M3** — the max-3 ceiling has no rendering | §8.2 / §3.4 — the ceiling is checked against `armedWatches` **before** an intent is written, and alert **A3** is presented. Count-invariant, one action, states a condition. |
| **M4** — a truncating distance becomes a false number | §2.2 — **the distance token leads `place-line`** (`~2.4 km · SP Remera`), so a cut can never reach the digits; the decimal is dropped at 10 km; the token is bounded at 8 characters by §7.3's origin ladder; §2.4's target is reconciled to §15.1's authored bound as `29 = 8 + 3 + 18`. Every other numeral is a count ≤9 followed by its noun, asserted by the composer. |
| **M5** — map-tab distance measured from the map centre | §7.3 — **rank origin and measure origin are separated.** Ranking follows the viewport as `[hard]` requires; every rendered distance is measured from the driver's origin on every tab, so the two tabs can never disagree. The Kigali substitution is disclosed in the title on **every** tab, including when panned. |
| **M6** — the freshness head is not lens-scoped | §5.4 — contributors are the reports behind the bays in **the leading clause's state, inside the lens**. |
| **M7** — `Distance` carries the ADR-0007 label and is the designated casualty | §3.3 — `Distance` pinned at position 4; `Bay alert` becomes the casualty, and the *action title* preserves armed-vs-not if it is dropped. §3.1 — `~<d> km straight line` also **leads** the POI card's `detailSummary`, so the obligation no longer depends on an unqueryable cap at all. |
| **M8** — two vocabularies, one shared function | §2.1 — CarPlay adopts Android's word set unchanged (`free` · `busy` · `out of service` · `unknown`; `operator` · `driver` · `EV Guide`), the tie broken toward the surface with no variant ladder. §5.3 and §5.5 now **cite** `02-androidauto-design-v2.md` §3 instead of restating it; §5.1 states exactly where the shared function stops and surface assembly begins. Settling it in `CONTEXT.md` is routed (§15.7). |
| **M9** — the rate grammar counts bays for a per-Connector property | §5.5 — denominated in **plugs**, four cases plus the multi-rate forms, adopted from Android §3.5. Fixture **S4** now carries 600 RWF/kWh on its GB/T guns and 400 on its Type 2 guns, so the corpus breaks a bay-denominated grammar immediately. |
| **M10** — the clauses exceed §2's own budget, so §11.3's claim is false | §5.4 — **one number, 52**, for every availability slot, with a defined compose-time ladder and worked character counts; the protected head is 21 (minor 2). §11.3 no longer claims budget compliance — it claims the two invariants and carries the residual as §12.2. |

### 13.3 The twelve minors

| # | Fix |
|---|---|
| 1 | §3.1 — `selectedPinImage` / `selectedPinImageSize` behind an iOS 16 availability guard; one pin image serves both states on iOS 14–15. |
| 2 | §2.4 — protected head is **21** (`EV Guide, 30 days ago`). |
| 3 | §7.2 — POI deadlines bucketed to 60 s. |
| 4 | §7.2 / §10.4 — **scene became active** is a recompose trigger; missed deadlines fire immediately. |
| 5 | §10.1 — Store B's pre-first-unlock degradation stated: `canWatch = false`, no Saved tab, no armed state, **no lens**. |
| 6 | §3.2 — the empty-state longest variant is now `"No chargers in the EV Guide directory"`; the only reachable path is an empty directory. |
| 7 | §5.3 / §5.4 — the prose no longer under-describes the table, because the table is now Android's regime partition, cited whole, and the row's droppable clauses are an explicit ordered ladder rather than a sentence. |
| 8 | §5.4 — the head is scoped to the **leading clause**, so S3 renders `Operator, 25 min ago · 1 bay free · 1 unknown` and the head dates the fact beside it. |
| 9 | §10.4 — the 500 m exception is deleted (it was the reaching-finger case, not an exception to it); re-rank on user action or while stationary. The misattribution to the Android design is deleted. |
| 10 | §3.5 — pop-then-push is stated as the fallback if `CPInformationTemplate.items` proves immutable. |
| 11 | §15.3 — the absence of an offline indicator on CarPlay is routed to **ADR-0007 as an amendment**, alongside the distance note, rather than living in the inference ledger. |
| 12 | §7.4 — stated: the phone renders Valhalla driving distance **without** `~`, which is what makes the prefix a convention; routed with §15.3. |

### 13.4 Where I narrow rather than adopt

**M8, direction of travel.** The verdict says settle one vocabulary; it does not say which. CarPlay adopts
Android's, rather than the reverse, for three reasons stated in §2.1: CarPlay has no variant ladder and the
shortest honest word must therefore win on both; `busy` and `broken` are ADR-0002's own prose; and adopting
in this direction means one document changes and the other does not. **No change is required on the Android
side for the vocabulary.**

**Minor 8, expressed as a rule rather than a caveat.** The verdict says *consider* binding the head to the
report behind the leading clause. It is adopted as **the** rule (§5.4) rather than a special case, because
doing so also fixes M6 and subsumes Android's separate `OutOfService`-exclusion rule. This *is* a change to
the shared function as Android currently specifies it (Android §3.3 takes contributors from Free and
Occupied bays together, and admits `mixed`), so it is routed as a reconciliation to ticket 19 and to the
Android design (§15.9) rather than silently diverging. It is the only place where this document asks the
other one to move.

**D24 / reporting on the car — still declined for v1.** A Station with exactly one Bay carrying exactly one
Connector can be reported without fabricating anything. Declined for the three reasons in §8.3: proximity
gating would make the action's *presence* vary with the vehicle's position; RURA Annex I makes
multi-standard sites the legal norm, so the carve-out shrinks over time; and it requires an authenticated
write from the template layer, which §10.3 forecloses on purpose. Recorded as deferred, not refused.

### 13.5 Carried forward unchanged, because the verdict found them sound

Template selection and the forbidden set with its build-time source check; every documented numeric cap;
the structural depth-3 proof; `bayState(bay, now)`; Grammar G's totality and the ban on folding
`OutOfService` into occupancy; raw per-Connector reports on device with `reporterId` and `capturedLocation`
stripped by a named projection; the credential's single home and the car layer that never authenticates;
the *not-confirmed-yet* third state and the client-side 2 h expiry; the bundled-snapshot paint floor; the
capacity clause replacing an apology; no sign-in wall anywhere and the string-by-string guideline-2 audit;
a paint path with zero network I/O; `Notify when free` at 16 characters; alert A1 as the expression of
ticket 30 clause 3; and §0.5 count invariance.

---

## 14. Everything inferred, and everything that must be verified

**Inferences.** Do not quote any of these to Apple as a rule.

1. **The tab bar counts as depth level 1.** The conservative reading; the design is safe under the
   permissive one too.
2. **The 60 s / 10 s refresh floors**, adopted from Apple's driving-task section, which is not literally
   binding on a charging app.
3. **`NSFileProtectionCompleteUntilFirstUserAuthentication` + `kSecAttrAccessibleAfterFirstUnlock`.**
4. **≤6 Information items, ordered by decision value, `Rate` at 3 and `Distance` at 4** — the hedge against
   an undocumented and unqueryable cap, and the judgement that `Bay alert` is the right casualty because
   the action title preserves the function.
5. **The §2.4 targets and the §5.4 / §5.5 ladders**, including the 16-character button target that shortens
   the watch label, and the choice of 52 as the single availability-slot number.
6. **Count invariance (§0.5) as a CarPlay discipline.** On CarPlay it costs no quota; it is imported
   because a control that changes under a driver's finger is a hazard.
7. **Silent omission of account-gated affordances** rather than explaining them — the derived safe reading
   of guideline 2.
8. **The car facet as a second store**, its exclusion list, and the judgement that a file with no user
   identifier holding station IDs and plug types is non-sensitive enough for the locked-readable class.
   This is a security decision, not a derivation, and ticket 19 must ratify or reject it.
9. **Stripping `reporterId` and `capturedLocation` from the cached Report projection.**
10. **The Kigali-centroid fallback beyond 200 km**, including as the reviewer path, and the bound it puts on
    the distance token.
11. **The row-set stability rule** (frozen while on top, except on a user action or while stationary).
12. **Great-circle distance on the car, Valhalla only on the phone**, and `~` as the convention that marks
    the difference.
13. **No offline indicator on CarPlay** — routed to ADR-0007 as an amendment (§15.3), not carried here.
14. **`bayState_T`'s rule that occupancy propagates into the lens and capability does not**, and its
    corollary that a free sibling never vouches for an unreported gun.
15. **Weakest source + oldest age, scoped to the leading clause.**
16. **The free-bay pin badge's self-dating property** — a badge drawn only while fresh encodes its own age
    by existing. Sound, but an argument, not a documented pattern.
17. **`nextDecayDeadline` as a one-shot timer** rather than a poll, and the 60 s / 10 s buckets.
18. **Alerts A1, A2, A3** as small extensions of ADR-0004's *"no custom fallback UI"*, justified because
    guideline 2 explicitly permits stating a condition and a car button that silently does nothing is
    worse.

**Must be verified on hardware or in the SDK.** The first two are **blocking**: guideline-3 usefulness and
the default state of the directions ladder both rest on them.

| | Item | Status |
|---|---|---|
| 1 | **What Apple Maps renders on the CarPlay screen for a Rwandan `daddr` it cannot route** — a destination pin, an error sheet, or nothing. The shipped directions path is this. | **BLOCKING** |
| 2 | **Whether `comgooglemaps://` launched via the scene's `open(_:options:completionHandler:)` lands on the CarPlay screen or the phone.** Decides whether `googleMapsCarDisplayHandoff` is ever enabled, or the rung is deleted. | **BLOCKING** |
| 3 | Whether `UNNotificationSettings.carPlaySetting` exists at the deployment floor and what it reports when the user disables CarPlay notifications per app. | open |
| 4 | Whether `CPInformationTemplate.items` / `.actions` are mutable at the target OS. If not, the decay-timer and arm/disarm re-renders become pop-then-push (§3.5) — depth-neutral, but visually abrupt while driving. | open |
| 5 | Whether `CPTabBarTemplate` permits programmatic tab selection at the iOS floor (design assumes not). | open |
| 6 | Rendered width of `Notify when free` beside `Directions` on the smallest available head unit. | open |
| 7 | Runtime values of `maximumItemCount`, `maximumSectionCount`, `maximumTabCount`, `maximumActionCount`, `pinImageSize`, `selectedPinImageSize` (iOS 16+ only), `maximumImageSize` across test vehicles. | open |
| 8 | Legibility of the composited numeral badge at the smallest reported `pinImageSize`. | open |
| 9 | Whether CarPlay activates at all on Rwandan-region devices `[UNKNOWN — ticket 22]`. Changes who sees these screens, not what they say. | open |

---

## 15. Routed onward before the schema locks

### 15.1 To ticket 19 (`docs/domain-model.md`) — must land before the schema locks

1. **Four projections, named in `packages/domain`.** The model names four (one-line, two-line,
   picker-triple, card-triple); this design needs the two-line one **split and reordered**, plus two new
   ones, or four call sites will improvise them:
   - **`place-line(station, origin)`** → `~<distance> · <nameShort>`. **The distance leads** — that
     ordering is the only thing standing between a truncating head unit and a false number (§2.2).
   - **`availability-line(agg, lens, verbosity, budget)`** → `<Source>, <age> · <state clause>`, resolving
     the §5.4 ladder against `budget`. **The head-first ordering is load-bearing** (§2.3).
   - **`detail-pairs`** → the `CPInformationItem` label/value list, ≤6, in the §3.3 order, lens-aware.
   - **`push-line`** → notification title + body.
2. **`bayState(bay, now)` and `bayState_T(bay, now, T)` must both be named functions.** ADR-0008 defines
   `effective(connector, now)` and mentions propagation; it names neither roll-up, and **the Bay is the
   display unit on every car surface**. Precedence tables in §5.2 and §6.2. `bayState_T`'s first rule —
   unlensed occupancy propagates into the lens, capability does not — is the whole of the F-A fix and must
   be a test, not a comment.
3. **Per-type projections `baysOffering(T)` and `knownBaysOffering(T)`**, with the *correct* caveat: a bay
   is counted once per type, so each individual per-type denominator is **≤ `n`**; only the **sum across
   types** may exceed it. A guard written the other way round defends against a condition that cannot occur
   and misses the one that can.
4. **The availability grammar as one pure function of `(n, f, o, x, u, verbosity, lens)`**, specified by
   `02-androidauto-design-v2.md` §3.2 / §3.6 and used unchanged by both car surfaces, with these as tests:
   `0 of N` is never emitted for any input; a denominator appears only when `u = 0`; `busy` quantifies `o`
   only; `OutOfService` never folds into occupancy; *all* never appears beside *busy* when `x > 0`; and the
   lensed subset uses `bayState_T`, not `bayState`. **Not in the CarPlay layer.**
5. **The aggregate's source and age**, per §5.4: contributors are the reports behind the bays in **the
   leading clause's state**, intersected with the lens; source = weakest (`driver < operator < admin`);
   age = oldest. This supersedes both car designs' current rules and removes `mixed` (§15.9).
6. **The rate grammar denominated in plugs**, §5.5 / Android §3.5 — never in bays, because a dual-gun bay
   can carry two prices.
7. **The car cache schema (§10.2): per-Connector raw reports, never materialised aggregates**, with an
   explicit named `CachedReport` projection excluding `reporterId` and `capturedLocation`.
8. **Three fixtures the corpus does not yet have**, all in this document's §3.0: a **dual-gun bay whose two
   guns disagree in state** (S4/B3 — the F-A case), a **dual-gun bay carrying two distinct rates** (S4 —
   the M9 case), and a **partially-reported station under a lens** (S5 — the F1 case). Plus one whose
   materialised aggregate and device-derived aggregate deliberately disagree.
9. **The car facet store (§10.3)** with its exclusion list, now including `savedStationIds`,
   `pendingIntents` and the directions flag. Car constraint 9 says the car reads *only* non-sensitive
   directory + availability data; ticket 30's armed-state item cannot be rendered under that rule as
   written. Either 19 admits this facet explicitly, or ticket 30's car face reduces to
   disarm-from-notification — **and if 19 admits it, §8.4's Saved tab is admissible on the same terms.**
10. **The credential's home:** Keychain at `kSecAttrAccessibleAfterFirstUnlock`, read only by
    `WatchSyncQueue`; the car template layer never authenticates.
11. **The Watch record gains `armedAt` and `confirmed`**, plus a client-side rule dropping a queued arm past
    `armedAt + 2 h`, and the **max-3 check evaluated on-device before the request** (§8.2).
12. **`nextDecayDeadline(displayed, now)`** as a domain function including the **age-label boundary** term
    (§7.2), so both car layers and the phone schedule identically.
13. **`Owner.icon` must be a vector asset.** CarPlay pin sizes are runtime values, so a fixed raster cannot
    serve them. And `Owner.markerLabel` is composited into the CarPlay pin, not Android-only.
14. **Authored length bounds, enforced in the admin:** `nameShort ≤ 18`, `name ≤ 28`, `markerLabel ≤ 3` —
    reconciled with §2.4's `place-line` target of 29 (= 8-char distance token + 3 + 18).
15. **A composer assertion that every rendered bay/plug count is ≤ 9**, with 19 to decide what a ≥10-bay
    station renders (§2.2).
16. **The negative form of car constraint 13:** ETA, duration and any "minutes away" string are
    **forbidden** on a car surface — not merely unmodelled, but a `carplay-maps` trigger if rendered.

### 15.2 To ADR-0004 — an amendment, not a footnote

Two changes. The car-surface ladder terminates in **Apple Maps** and, only if that also fails, in alert
**A2**, because on CarPlay a universal link lands in Safari, which has no car screen — so *"Not-installed
falls back to the platform's universal-link handling; no custom fallback UI"* cannot be applied literally
here. And the Google Maps rung ships **behind a flag defaulting off**, which is ADR-0004's own car-screens
clause made operational rather than merely honoured in prose. Amend it the way ticket 23 amended ADR-0003.

### 15.3 To ADR-0007 — two car notes, as an amendment

- Straight-line distance on the car is labelled by the `~` prefix, by `straight line` at the **head** of
  the POI card's `detailSummary`, and by the `Distance` item pinned at position 4 (§7.4). The phone renders
  driving distance without `~`, which is what makes the prefix a convention.
- **There is no offline indicator on CarPlay**, diverging from ADR-0007's quiet phone indicator: there is
  no permitted non-alarming affordance for it, and the surface is designed to be indistinguishable offline.
  Record it as an amendment rather than a silent exception (minor 11).

### 15.4 To ticket 27 — two blocking items, in priority order

1. **What Apple Maps renders on the CarPlay screen for a Rwandan `daddr` with no available route.** The
   shipped directions path is this; guideline-3 *usefulness* rests on it.
2. **Whether `comgooglemaps://` via the scene `open` lands on the CarPlay screen or the phone.** Decides
   whether `googleMapsCarDisplayHandoff` is ever enabled or the rung is deleted.
3. Then, non-blocking: the runtime values in §14, `CPInformationTemplate` mutability, programmatic tab
   selection, badge legibility at the smallest `pinImageSize`, and the rendered width of
   `Notify when free`.

### 15.5 To ticket 30

- The car button label is **`Notify when free`** (16 chars), not the phone's
  `Notify me when a bay frees up` (29). `CPTextButton` takes a plain `String` with no variants.
- Clause 3 ("arming is only offered when the watched set is not already Free") is expressed on the car as
  **alert A1**, not as a hidden action — hiding it would make the action count depend on availability.
- Clause 3's **max-3 ceiling is enforced on-device before the request**, and expressed as alert **A3**.
- The POST carries the mirrored profile's `connectorTypes[]` when one exists and `[]` otherwise, and the
  `Bay alert` item says which.
- The armed state has three values on the car, not two: the middle one is *requested, not confirmed*.
- The gate is `.authorized` only — `.provisional` does not qualify.

### 15.6 To ticket 20

- The submission demo must run against **seeded availability data**, or two of the three EV-1 functions are
  invisible to the reviewer (§12.11).
- Provide a **demo account signed in on the phone before connecting**, in Apple's review notes.
- Review notes must walk the availability layer and arm a live watch.
- **Do not claim a Google Maps hand-off onto the car display in the submission.** It ships off.

### 15.7 To `CONTEXT.md`

- Line 44 still reads *"needs an account to act — **directions**, saving, reporting, profile sync"*.
  ADR-0003's amendment and ticket 23 removed directions from that list.
- **Add the shared display vocabulary** (§2.1) as a glossary entry, so neither car design declares its own
  closed set and ticket 19 receives one specification (M8).

### 15.8 To ticket 12

One-line ruling needed before 19 locks: is *setting your own connector type* account-gated (the ticket's
**question** says yes) or a device-local preference (the ticket's **answer** gates only *syncing* the
vehicle profile)? If the former, §6's entire wording layer only ever appears for signed-in drivers and the
anonymous reviewer sees the unlensed aggregate. The fallback wording is already specified — it is §6.1's
default — but the ruling decides how often it is what everyone sees.

### 15.9 To `02-androidauto-design-v2.md` — one reconciliation, everything else already agrees

The vocabulary, Grammar G, Grammar Q and Grammar R are adopted from that document unchanged; **no change is
required there for M8**. One rule does need to move, and it is §5.4's: the freshness head's contributors
should be the reports behind **the bays in the leading clause's state, inside the lens**, rather than Free
and Occupied bays together — which also removes `mixed` from the source vocabulary and subsumes the
separate `OutOfService`-exclusion rule. Reasons in §13.4. Ticket 19 arbitrates; whichever way it rules,
both documents must cite the same rule.
