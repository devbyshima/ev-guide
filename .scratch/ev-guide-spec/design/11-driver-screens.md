# 11 — Driver app: screen inventory and domain mapping

Ticket 17, part 2 of 2. Part 1 is
[`10-design-system.md`](10-design-system.md) — the measured typeface, scale,
spacing, radii, components and tokens. **This file never re-measures and never
invents a value.** Every dimension quoted here is cited from that file; where a
value does not exist there, it is marked `[RAISE-D…]` rather than filled in.

Scope: the **driver app** (`apps/driver`). The operator app and the admin
dashboard are out of scope. The design system lands as `packages/ui`, shared by
both mobile apps; admin takes tokens only (ADR-0006).

## 0. How to read this file

**The standing rule governs everything below.** Reference designs are
implemented 1:1 with no deliberate deviations. Where the reference cannot be
reproduced, the impossibility is **raised**, not substituted. §16 holds every
raise; nothing is quietly resolved in the body.

**Marking legend**

- **[ref-NN]** — this screen or element exists in reference `NN.png` and is
  reproduced. Geometry is cited from `10-design-system.md`.
- **[ext]** — by extension: no reference screen exists, so the screen is
  *assembled from named reference components* whose geometry is measured. The
  component list is given for every one.
- **[RAISE-D…]** — a place the reference cannot arbitrate. Raised, with a
  recommendation, never silently decided.
- **[vocab]** — the string is **closed vocabulary owned by `packages/domain`**
  (docs/availability-display.md §2.4). The app may not author it. Strings not
  so marked are app copy and live in the driver app's own string table.

**Units.** px is authoritative (captures are @3x); pt = px/3 is given because
that is what a build types. Same convention as part 1.

**The worked station.** Every screen below is drawn with one real Rwandan
fixture, matching car fixture S1 (`01-carplay-design-v3.md` §3.1) so the four
runtimes render one dataset:

| Field | Value |
| --- | --- |
| `Station.name` | `SP Remera` |
| `Station.nameShort` | `SP Remera` |
| `Owner.displayName` / `shortName` / `markerLabel` | `Kabisa` / `Kabisa` / `KAB` |
| Bays | 4 |
| Connectors | 2 × `GBT_DC` 60 kW · 2 × `IEC_62196_T2` 22 kW |
| Rate | 600 RWF/kWh, `rateConfirmedAt` = 12 days ago, all 4 plugs |
| Photos | 3 |
| Route from driver | 4.1 km, 12 min (Valhalla) |

**Availability is drawn Unknown first, everywhere.** ADR-0002: `Unknown` is the
normal case (~87% of the country), not a failure. Every screen below shows the
Regime 1 variant as its **primary** rendering, with the reported variants after
it. Any screen whose primary drawing shows a confident green state is drawn
wrong.

---

## 1. The five substitutions the ticket names

All five are clean. Each keeps the component's every measured property and
changes only its content.

| # | Reference | EV Guide | Component unchanged? |
| --- | --- | --- | --- |
| 1 | car pin (`01`, `03`) | **charger pin** | Yes — §5.3 geometry, colours and stroke identical; only the glyph drawing changes (line-art vehicle → line-art charge point), same `#393939`, same 5–6 px stroke, same ≈100 px ink width inside the ⌀97 px `#F3F3F3` disc |
| 2 | rental card (the `03` sheet composition) | **station card** | Yes — §5.4 slots reassigned in §7.2; no geometry moves |
| 3 | `135 000 RWF` Bold + `/day` Regular | **`600 RWF` Bold + `/kWh` Regular** | Yes — the reference's price composition is *amount-and-currency Bold + slash-unit Regular*, and the rate takes it verbatim. cap 27 Bold on the sheet, cap 36 Bold on the sticky bar |
| 4 | `Check Availability` (sticky CTA, `04`) | **`Directions`** | Yes — §5.8, 515 × 133 px, radius ≈14 px, `#C7FC2F`, label cap 32 **Medium** `#121212` |
| 5 | `Let's find a car` (primary CTA, `01`/`03`) | **`Let's find a charger`** | Yes — §5.1, 899 × 138 px, radius 13.5 px, label cap 37 Medium `#121212`. 20 chars against the reference's 16; at the measured cap-37 Medium advance this is ≈560 px inside an 899 px button |

Substitution 4 is the ticket's named mapping and it is worth stating why it is
exactly right rather than merely available: `Check Availability` in the
reference is *the rental's commit action*. In EV Guide the commit action is
going there. Availability is not a thing you tap to check — it is already on the
screen, derived, and there is no server call that would tell you more.

Substitution 5's destination is **not a new screen**: see §7.3.

---

## 2. The pin — availability without new visual language

The ticket's headline question. The reference pin affords **one accent-bearing
surface (the 2 px `#C7FC2F` outline) and one glyph slot** (`10-design-system.md`
§5.3). EV Guide has four states plus freshness, and the majority state is
`Unknown`.

### 2.1 What is ruled out, and why

| Channel | Why it cannot carry availability |
| --- | --- |
| **Outline colour** | Four states need four colours. §8.1 says the accent is *exactly one value, no tints, no gradients* — verified across four screens. Three new colours is three new tokens, i.e. new visual language. Ruled out. |
| **Glyph substitution** | Four glyphs for four states. Also a category error: availability is a property of a **Connector**, never of a Station (ADR-0002), and a pin is a Station. A station-level state glyph asserts something the model forbids. Ruled out. |
| **Pin fill / disc colour** | Same objection as outline, plus `#F3F3F3` and `#FFFFFF` are the only two pin surfaces and they are 6 units apart — not a signalling range. Ruled out. |
| **Size, opacity, motion** | No size variation, no opacity ramp and no motion exists anywhere in the reference (§7: *there are none, anywhere*). Ruled out. |

### 2.2 The decision

**The pin carries the reference's own status dot, drawn only when a bay is free
for this driver.** Nothing else about the pin changes, ever.

The status dot is a measured component, not a new one — `10-design-system.md`
§5.9, the mark on the map avatar:

| Property | Measured value | On the pin |
| --- | --- | --- |
| Diameter | **20–21 px = 7.0 pt** | unchanged |
| Fill | `#C7FC2F` | unchanged |
| Ring | `#FFFFFF`, ≈4 px | unchanged |
| Placement | centre offset **(+49, −49) px** from a ⌀129 px circle centre — 45° top-right, straddling the edge | **same proportion**: 49 / 64.5 = **0.76 × radius** along the 45° top-right diagonal. On the pin's ⌀120 px head that is **(+46, −46) px** from the head centre [derived, not measured] |
| Shadow | none | none |

Verified independently: the dot's ink box measures `x 168–187, y 367–387` on
both `01` and `03` against an avatar at `x 64, y 362, ⌀129` — 20 × 21 px, centre
offset (+49, −49.5).

**The rule, in one line:** the dot is drawn when
`f = freeBaysOffering(T) > 0` at render time — lensed by the driver's connector
profile `T` when one is set, unlensed (`T = ∅`) when not — and is absent
otherwise.

```
      Unknown  (THE NORMAL CASE)      Free for me            Occupied / OutOfService
           ╭───────╮                      ╭───────╮ ●             ╭───────╮
           │  ⌁▭   │                      │  ⌁▭   │               │  ⌁▭   │
           ╰──╲ ╱──╯                      ╰──╲ ╱──╯               ╰──╲ ╱──╯
              ▽                              ▽                       ▽
      plain pin, complete              plain pin + dot          plain pin, complete
      listing, no apology
```

### 2.3 Why this is the right answer and not merely an available one

- **It is ADR-0002's own instruction, executed literally**: *"availability as an
  additive badge when it exists."* The dot exists or it does not; there is no
  third rendering and no grey.
- **The reference already uses this mark additively, twice** — the map avatar's
  dot and the `Messages` notification dot on `02` are the same construction and
  both mean *there is something here*, drawn only when true. Re-tenanting the
  mark is a content change, not a language change.
- **Freshness needs no channel at all.** `f` is derived under ADR-0002 decay and
  recomputed at `nextDecayDeadline` (docs/availability-display.md §1.3), so the
  dot decays out by construction. Its *existence is* its freshness claim, and a
  stale dot is unrepresentable rather than discouraged. This is the same
  argument CarPlay's badge makes (`01-carplay-design-v3.md` §3.1).
- **It answers "free for me", not "free"** — the lens rides in `f`, which is the
  domain trap the whole model exists to avoid.
- **It cannot render the map as a field of failure.** At ~87% Unknown, any
  scheme that *marks* Unknown paints the country as broken. This one marks only
  the ~13% that is positively actionable.

### 2.4 What the pin deliberately does not say — [RAISE-D1]

`Occupied`, `OutOfService` and `Unknown` are **indistinguishable on the pin**. A
driver cannot tell "someone reported it busy" from "nobody knows" without
tapping the pin and reading the sheet.

That is a knowing cost, not an oversight, and it needs a yes:

- The pin has exactly one additive channel and it is spent on the only
  positively actionable fact.
- The alternative — a second channel for hazard (`OutOfService`) — has no
  reference vocabulary. The nearest candidates (a second dot colour, a struck
  glyph, a desaturated body) all invent language, and `OutOfService` is a
  Connector fact that only rolls up to a station when *every* gun is broken.
- The cost is bounded: one tap surfaces the full grammar, and the sheet is the
  reference's own selection response.

**Recommendation: accept.** Named here so it is a decision rather than a gap.

### 2.5 Three further pin raises

**[RAISE-D2] The dot carries presence, not a count.** CarPlay composites a
filled **numeral** badge carrying `f` onto its pin. The phone's status dot is
7 pt and cannot hold a digit; a disc that could would be a new size and the
numeral itself would be the first numeral-in-a-circle anywhere in the reference.
The cross-surface verdict (§3 item 4) already records pin availability as an
*undeclared* divergence between CarPlay and Android Auto — this **declares** the
phone's. Recommendation: presence-only on the phone; the count is one tap away
in the sheet, which the CarPlay map cannot offer.

**[RAISE-D3] The pin carries no Owner mark.** CarPlay composites
`Owner.icon` + `markerLabel` (≤3 chars) into its pin so twelve pins from three
Owners stay distinguishable. The phone pin's glyph slot is monochrome `#393939`
by measurement and `Owner.icon` is a colour vector; dropping a colour logo in
breaks the measured pin, and the reference's own seven pins are identical.
Recommendation: one uniform charger glyph on the phone; Owner identity is
carried by the station card and the detail's owner row. This is a **third**
per-surface pin treatment and it is declared, not discovered later.

**[RAISE-D4] There is no selected-pin treatment, and no cluster mark.**
Verified: all seven lime outlines in `03` measure 122 × 147 px *while a sheet is
open* — the reference genuinely does not highlight the selected pin.
Recommendation for selection: none — the sheet is the feedback, which is 1:1.
Clustering is different: ticket 06 assumed clustered `SymbolLayer` pins, and a
count-bearing cluster bubble cannot be derived from anything in the reference.
Recommendation: **do not cluster in v1** (ADR-0007 puts the directory at tens of
stations); if clustering is ever needed, it is a new component requiring a yes.

---

## 3. The crosshair rule

Measured in `10-design-system.md` §5.11 and left open there as `[RAISE-7]`:
a 2 px `#FFFFFF` horizontal rule at y 249–250 spanning **x 64 → 1141 — exactly
the content width**, terminated by two 3 × 83 px vertical arms inset 29 px from
the left end and 34 px from the right (asymmetric by 5 px). Identical on both
map screens. Attached to nothing, enclosing nothing, moving with nothing.

**Decision: EV Guide reproduces it verbatim, on both map screens, as a static
mark with no behaviour and no state.**

It is the **content-column datum**. That is not a story invented to justify
keeping it — it is what the measurement says: the rule's extent is *identical*
to the sheet's (x 64 → 1141), to the CTA's left edge (x 64), and to the map
avatar's left edge (x 64). Every floating element on the map screen aligns to
it. It marks the top of the region in which map chrome sits, below the status
bar.

Three tempting jobs are **explicitly rejected**, because each would be inventing
behaviour a still cannot support:

- It is **not** the offline indicator (§9.1 gives that its own face).
- It is **not** a "search this area" control — the reference has no search
  anywhere.
- It does **not** animate, move, or respond to the sheet. §7 of part 1 found no
  motion anywhere in the system.

**[RAISE-D5]** The asymmetric arm inset (29 px left / 34 px right) is
`10-design-system.md` [RAISE-5c] — a reference defect. Reproducing it is the
literal reading of 1:1; correcting it to 29/29 is a deviation. This file does
not rule; it inherits the ruling made on [RAISE-5].

---

## 4. The three profile quick actions

Reference (`02`): three ⌀150 px `#393939` circles with 6 px white stroke glyphs
and cap 27 Bold labels — `Trips`, `Wishlist`, `Messages` — the third carrying a
notification dot.

| Reference | EV Guide | Why |
| --- | --- | --- |
| `Trips` | **removed** | EV Guide never observes a charging session (CONTEXT.md, *deliberately not defined*). There are no bookings, no sessions, no history. Nothing in the model can fill this slot. |
| `Wishlist` | **`Saved`** | Direct 1:1. `SavedStation` is the heart icon; the reference's glyph is already a heart. Account-gated (ADR-0003). |
| `Messages` | **removed** | EV Guide has no messaging entity of any kind, and deliberately so — there is no driver↔operator channel anywhere in the model. The notification dot goes with it. |

That leaves one survivor, so the row must be re-tenanted or dropped. **The row
survives, with three slots:**

| Slot | Label | Glyph | Destination | Gate |
| --- | --- | --- | --- | --- |
| 1 | `Saved` | heart, 2 pt stroke, 24 pt grid | D-11 Saved | account |
| 2 | `My plug` | plug/connector, 2 pt stroke | D-09 My plug | **ungated** — device-local preference |
| 3 | `Alerts` | bell, 2 pt stroke | D-12 Alerts | account + notification permission |

Two of the three are argued, not assumed:

- **`My plug` earns prime real estate.** ADR-0002 makes the vehicle connector
  profile *load-bearing, not a nice-to-have* — it is what turns "free" into
  "free **for me**", which is the product's entire differentiator. The reference
  offers no other home for it above the settings list, and burying the thing the
  map depends on inside settings would be a design error the reference does not
  force.
- **`Alerts` is the armed-`Watch` list** (ticket 30). It is specified now
  because the spec covers the product, and **built with the car effort's
  package** (ticket 23), which is when the phone gains bay-watch too.

**The notification dot is dropped from this row**, and from the map avatar
(§7.1). One mark may not carry two meanings in one product, and the status-dot
component is spent on the pin (§2.2).

**[RAISE-D6] The row's composition at v1.** If the founder ships the phone app
before ticket 30's package, `Alerts` has no destination and the row is **two
circles**, not three. The reference shows exactly one instance of this row, with
three items, and cannot arbitrate a two-item variant — and it is already a
defective row (`10-design-system.md` [RAISE-5d]: spacing 64 px / 81 px, circle 1
⌀154 against ⌀149). Options: (a) ship two circles at v1 and three later, (b)
ship `Alerts` from the first release with an empty-state screen explaining it
arrives with the car surfaces, (c) ship two permanently and reach alerts from
settings. **Recommendation: (a)** — a two-circle row is centred and reads fine,
and the third arriving later is additive.

---

## 5. `Payment & payouts`

The reference settings list (`02`), measured at 176–177 px pitch with 1 px
`#3E3E3E` full-width dividers at y 2188 / 2364 / 2541: `Personal Information` ·
`Login & Security` · `Payment & payouts` · `Notifications` (cut off).

EV Guide has no payments anywhere and never will — there is no payment, plan or
billing entity in the model, and the structured Rate fields are explicitly *the
whole seam a future payment effort would build on* (docs/domain-model.md).

**Decision: `Payment & payouts` → `Offline & map data`.**

| Property | Reference row | EV Guide row |
| --- | --- | --- |
| Pitch | 176–177 px = 58.7–59.0 pt | unchanged |
| Icon | banknote, 6 px = 2 pt stroke, 62–68 px ink at x 45–46 | download-arrow, **same stroke, same grid, same x** |
| Label | `Payment & payouts`, x 196, cap 32 Regular `#FFFFFF` | `Offline & map data`, unchanged treatment |
| Divider | `#3E3E3E` 1 px, x 38 → 1167, no inset | unchanged |
| Trailing affordance | none | none |

Three reasons this is a substitution rather than a deletion:

1. **Nothing financial-shaped can ever take the slot**, so the choice is
   free — the only question is what deserves it.
2. **ADR-0007 requires a settings home** for the opt-in all-Rwanda map pack
   (76 MB), and ticket 17 is charged with designing that row. It has to live
   somewhere in this list.
3. **A driver low on charge outside Kigali is the product's defining user**
   (ADR-0007's own rationale). Offline data is the single most consequential
   setting the driver app has — the same "account plumbing" weight the payment
   row carried in the reference.

The settings list therefore keeps the reference's row count and pitch exactly,
with one label and one glyph changed. Full list in §8, D-04.

---

## 6. `Switch to hosting mode` — the cross-app affordance

Reference card (`02`), measured at `10-design-system.md` §5.10: 1130 × 335 px
(376.7 × 111.7 pt), radius 13 px, fill `#393939`, 39 px padding on all four
sides, icon tile 257 × 257 px `#3E3E3E` radius ≈15 px with a lime ≈9 px-stroke
glyph, tile→text 67 px, title cap 37 Bold, body cap 28 ExtraLight over 3 lines
at 45 px pitch.

ADR-0006 makes driver and operator **two apps**, so this is a cross-app
affordance: open-or-install the operator app, **shown only to holders of an
Owner or Operator `Membership`**.

### 6.1 The component is reproduced exactly; only content and visibility change

```
┌──────────────────────────────────────────────────────────────┐  radius 13 px
│  ┌────────┐   Open EV Guide Operator                         │  #393939
│  │  ⌁→    │   You manage 3 stations.                         │  padding 39 px
│  │        │   Update bay status and rates.                   │
│  └────────┘                                                  │
└──────────────────────────────────────────────────────────────┘
   257×257 px      title cap 37 Bold · body cap 28 ExtraLight
   #3E3E3E tile    tile→text 67 px           45 px line pitch
   lime glyph
```

The tile glyph is the reference's own **car-with-arrow at ≈9 px stroke in
`#C7FC2F`** — the only lime glyph in the system — redrawn as a
**charge-point-with-arrow** at the same stroke and the same tile. Nothing else
about the card changes.

### 6.2 The four states

| State | Title | Body (2 lines, cap 28 ExtraLight) | Tap |
| --- | --- | --- | --- |
| **Membership + operator app installed** | `Open EV Guide Operator` | `You manage 3 stations.` / `Update bay status and rates.` | universal link `https://evguide.rw/operator` → resolves to the installed app |
| **Membership, app not installed** | `Get EV Guide Operator` | `You manage 3 stations.` / `The operator app updates bay status and rates.` | same universal link → OS falls through to the App Store / Play listing |
| **Membership, install state undeterminable** | `Get EV Guide Operator` | as above | same link. The label degrades to the *weaker* claim, never to a claim the app cannot observe |
| **No membership** (the ~99.9% case) | — | — | **the card is absent** |

### 6.3 Why the no-membership case is an absence and not a teaser

The reference card is a **recruitment pitch**: *"Still not an host? Take
pictures, upload your cars and start earning."* EV Guide cannot make that offer
to anyone. Ticket 11 fixes the path: **Admin creates Owners; Owners create their
own Operators.** An ordinary driver cannot self-serve into a membership by any
route, so a card inviting them to would be a lie, and a *disabled* card would
advertise a door with no handle. Absence is the only honest rendering.

Signed-out drivers hold no membership, so they see no card either — the same
branch, no special case.

Offline: membership is a user-scoped fact carried in the last sync. The card
renders from cache; an unsyncable state falls to *no membership*, i.e. absent.

### 6.4 Two engineering constraints this design creates

- **iOS**: the operator app's scheme must be declared in the driver app's
  `LSApplicationQueriesSchemes` for any install check. Both apps are the
  studio's own, so this is free.
- **Android 11+**: package visibility requires a `<queries>` element naming the
  operator package. Same.
- The **tap target is the universal link in every state**, so a wrong *label*
  can never produce a wrong *destination*. The install check only chooses words.

### 6.5 [RAISE-D7] The gap the absent card leaves

Measured on `02`: quick-action labels → card = **154 px**; card → `Settings`
heading = **164 px**. With the card absent, those two gaps collapse into one and
the reference cannot say which value survives.

**Recommendation: 164 px** — the heading keeps its own approach distance, and
164 is the larger, so nothing crowds. Needs a yes because it is a value the
reference does not contain.

---

## 7. The route preview, inside the existing screens

ADR-0004 requires a preview — route line, real driving distance, ETA — and the
reference contains **no route screen**. ADR-0004's own consequence section says
so: *"the reference set contains no route screen; ticket 17 places the preview
within the existing screens rather than inventing one."*

**Decision: the preview is split across two slots that already exist.**

### 7.1 The route line goes on the map, in the map + sheet screen (D-02)

A Valhalla polyline from the driver's position to the selected station, drawn on
the MapLibre map beneath the existing sheet. Colour **`#C7FC2F`** — the only
accent, and the reference already spends it on the map (pin outlines), so a lime
line adds no colour to the map's budget. Round caps and joins, matching the icon
system's only stated join rule (§6).

**[RAISE-D8] The route line's width has no reference value.** The reference's
entire line vocabulary is 2 px (pin outline, crosshair rule), 2.5 px (chip
border), 3 px (crosshair arms), 6 px (icon stroke), ≈9 px (hosting tile glyph) —
none of them a line drawn *on the map*. **Recommendation: 12 px = 4 pt**, twice
the icon stroke, which reads at map zoom without competing with the pins. This
is the **one invented dimension in the whole driver design** and it needs a yes.

### 7.2 The distance and ETA go in the sheet's category-chip slot

The `03` sheet's chip is measured at `x 480–733, y 2030–2105` — 253 × 75 px
(84.3 × 25 pt), radius 31.5 px, `#393939` fill, `#C7FC2F` 2.5 px border, label
cap 27 Regular `#C7FC2F`.

It carries **`12 min · 4.1 km`**.

This is the correct tenant, for four reasons:

1. In the reference the chip is **redundant** — it repeats `Hybride`, the first
   token of the subtitle directly above it. It is the one slot on the sheet
   carrying no unique information, so re-tenanting it costs nothing.
2. Accent throughout this system means *actionable, yours, now* — the CTA, the
   link, the active page indicator, the status dot. A route computed for **this
   driver from this position right now** is exactly that.
3. It is **additive**, like every other accent mark: absent until the route
   resolves, absent when there is no location, absent offline (see below). The
   reference has no spinner or skeleton anywhere and none is introduced.
4. Availability must **not** go here. A lime-bordered chip on ~87% of stations
   reading *no confirmed status* would paint the map's sheet as an apology —
   the outcome ADR-0002 forbids by name.

### 7.3 Offline and failure — what it degrades to

| Condition | Chip | Route line |
| --- | --- | --- |
| Online, location known, route resolved | `12 min · 4.1 km` | drawn |
| Route in flight | **absent** | absent |
| Route failed (server error) | `~4.1 km straight line` | absent |
| **Offline** (ADR-0007) | `~4.1 km straight line` | absent |
| No location permission | **absent** | absent |

`~4.1 km straight line` is exactly ADR-0007's amendment for a marked
straight-line figure, and the `~` + `straight line` form is the wording CarPlay
already ships, so one product carries one phrasing. At the measured cap-27
Regular advance of 18.0 px/char, 21 characters is ≈378 px inside the sheet's
594 px content column — it fits without laddering.

**The `Directions` CTA on the detail is never gated on any of this** (ADR-0007:
*"the Google Maps hand-off button is never gated on the preview"*), and it is
never gated on an account (ADR-0003 as amended, ticket 23).

### 7.4 What the preview must not promise

ADR-0004: ETAs shown are EV Guide's own (Valhalla) and may differ from Google's
after hand-off. The chip therefore says `12 min`, never `arrive 11:14` — a
clock time would be read as a promise about the drive EV Guide does not own.

---

## 8. The screen inventory

Fifteen screens, three sheets, two non-screens. Reference-derived screens first.

---

### D-01 · Map home — [ref-01]

**Purpose.** The app's front door and its primary surface: every station in
Rwanda on a dark map, reachable anonymously with no account, no permission and
no connection.

**Layout** (every value from `10-design-system.md`):

```
 ┌──────────────────────────────────────────────────────────┐
 │  11:01                                    ▮▮▯ ᯤ  79      │  status bar (OS)
 │                                                          │
 │  ├──────────────────────────────────────────────────┤    │  crosshair rule §5.11
 │                                                          │  y 249–250, x 64→1141
 │   ⬤                                          ▭ Offline   │  avatar ⌀129 x64 y362
 │   avatar                                     feature chip│  offline chip §9.1
 │                                                          │
 │              ◉        ◉●                                 │  pins 120×147 px
 │                                ◉                         │  ● = free-bay dot
 │                    ◉                                     │
 │                        ◉                                 │
 │                  ◉                                       │
 │                     ⬤ location puck                      │
 │                                                          │
 │  © OpenStreetMap contributors                            │  attribution §11
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA 899×138 r13.5
 │  └──────────────────────────────────┘   ╰──╯             │  locate ⌀139 +lime ring
 └──────────────────────────────────────────────────────────┘
```

**Components:** map canvas `#212121` · crosshair rule (§5.11) · map avatar
(§5.9, ⌀129 px `#FFFFFF`, x 64, y 362, **no status dot** — §4) · charger pins
(§5.3 + §2.2) · primary CTA (§5.1) · locate button (§5.2, ⌀139 px `#FFFFFF` with
a 4 px lime ring and the system's **only filled glyph**) · attribution mark
(§11) · offline chip (§9.1).

**Behaviour**

| Element | Action |
| --- | --- |
| Avatar | push D-04 Profile |
| Pin | select → D-02 (sheet opens, no screen change) |
| Locate ➤ | recentre on the driver; if permission not granted, request it |
| CTA `Let's find a charger` | expand the sheet to its list detent — D-02's second detent, **not a new screen** |
| Attribution | push D-10 About |

**States**

| State | Rendering |
| --- | --- |
| **Default / first run, no connection** | Fully populated. ADR-0007 ships the Kigali basemap (5.6 MB) and a directory snapshot **inside the binary**, so pins paint immediately with every availability honestly Regime 1. **There is no loading state for the directory, ever.** |
| **Loading** | None exists. Tiles that are neither bundled nor cached leave flat `#212121` — the map colour, not an error surface. |
| **Offline** | The offline chip appears (§9.1). Nothing else changes. Panning outside the bundled Kigali extent without the Rwanda pack shows flat `#212121` with pins still drawn in their true positions. |
| **No location permission** | The puck is absent; the locate button still renders and requests on tap. `stationsNear` uses the **viewport centre** as origin — never a hardcoded "device location" (domain-model, primary reads). No distances are shown anywhere until a position exists. |
| **Signed out** | Identical. The whole read surface is anonymous (ADR-0003), and the avatar is the reference's measured empty state: `#3E3E3E`… — see D-04 for the avatar's signed-out face. |
| **Error** | No error state. A failed sync leaves the cached directory; a failed tile leaves `#212121`. |
| **Empty** | Not reachable — the bundled snapshot is never empty. |

**Strings**

| String | Owner |
| --- | --- |
| `Let's find a charger` | app copy |
| `Offline` | app copy |
| `© OpenStreetMap contributors` | licence text — **not** app copy, see §11 |

---

### D-02 · Map + station card — [ref-03]

**Purpose.** Answer, without leaving the map, the four questions a driver has
about a pin: what is it, can I charge there, how far, what does it cost.

**Layout — Regime 1, the normal case, drawn first**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ├──────────────────────────────────────────────────┤    │  crosshair (unchanged)
 │   ⬤                                                      │
 │              ◉        ◉●        ═══════╗                 │  lime route line, 12 px
 │                    ◉             (§7.1) ║                │
 │                        ◉════════════════╝                │
 │  ┌────────────────────────────────────────────────────┐  │  sheet §5.4
 │  │                     ▬▬▬                             │ │  handle #262626, 26 px down
 │  │  ┌────────┐  SP Remera                        ♡     │ │  title cap 36 Bold x483
 │  │  │ photo  │  4 bays · no confirmed status           │ │  subtitle cap 27 Regular
 │  │  │100×100 │  ╭───────────────╮                      │ │  chip = route preview
 │  │  │  pt    │  │ 12 min · 4.1 km│                     │ │  lime border 2.5 px
 │  │  └────────┘  ╰───────────────╯                      │ │
 │  │                                      600 RWF/kWh    │ │  cap 27 Bold, right x1075
 │  └────────────────────────────────────────────────────┘  │
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA unchanged from D-01
 │  └──────────────────────────────────┘   ╰──╯             │
 └──────────────────────────────────────────────────────────┘
```

**Measured slot map** (sheet frame x 64 → 1141, y 1796 → 2317; 64 px padding):

| Reference slot | Measured | EV Guide content |
| --- | --- | --- |
| Thumbnail | 300 × 300 px = 100 pt, radius 30 px, x 128 | `Photo[0]` |
| Title | cap 36 Bold, x 483, baseline 1921 | **`nameShort`** — `SP Remera` |
| Subtitle | cap 27 Regular, x 483, 19 px below title | **the availability clause** |
| Category chip | x 480–733, 253 × 75 px, r 31.5 px, lime 2.5 px border | **the route preview** (§7.2) |
| Price | cap 27 Bold, right-aligned to x 1075 | **`600 RWF` Bold + `/kWh` Regular** |
| Heart | ink 50 × 46 px, x 1026–1074, y 1881–1925 | `SavedStation` toggle |

**Why the title is `nameShort` and not `Kabisa – SP Remera`.** Ticket 19's
routed constraint is explicit: `nameShort` is *the place, not the operator*, and
the operator belongs in icon and marker. The CarPlay **card** composes
`Kabisa – SP Remera` because that card is the last thing many drivers see;
the phone sheet has a detail one tap away carrying a dedicated owner row with
`Owner.icon`. `nameShort ≤ 18` characters at the measured cap-36 Bold advance of
24.5 px/char is ≤ 441 px inside the 543 px column left of the heart — **it fits
by construction, for every station in the directory.** Declared as a per-surface
difference rather than left to be discovered.

**The subtitle and the variant ladder.** The content column is x 483 → 1077 =
**594 px**; the measured cap-27 Regular advance is **18.0 px/char** (from
`Hybride - Black - 2024`, 22 chars, 397 px ink) → **33 characters per line**.
The availability clause runs the shared drop order
(docs/availability-display.md; `02-androidauto-design-v3.md` §3.4 — drop `ago`,
then the source word, then the `busy` clause, then plural nouns; **`free`,
`out of service` and `unknown` counts are never dropped**) until it fits **two
lines at the measured 45 px pitch**.

**[RAISE-D9] Two-line subtitle.** The reference's sheet subtitle is one line, and
`10-design-system.md` §2.3 says *no line height but body's is measurable — do not
invent them*. The 45 px pitch is measured over ten consecutive lines at cap 27–28
and is a function of size, not weight, so applying it to a two-line cap-27
Regular run is a **derivation**; the sheet's measured 522 px height is then the
one-line case and a second line adds exactly 45 px. Needs a yes, because it makes
the sheet content-sized. Regime 3's worst string cannot fit one line at any rung
of the ladder — the alternative is breaking the ladder's law, which is worse.

**Every availability variant, drawn:**

| Regime | Data | Subtitle |
| --- | --- | --- |
| **1 — the normal case** | `n=4, u=4` | `4 bays · no confirmed status` [vocab] |
| **2** | `n=4, f=2, o=2` operator 14 min | `Operator, 14 min ago · 2 of 4 bays free` [vocab] |
| **3** | `n=4, f=1, o=1, x=1, u=1` | `Operator, 14 min ago · 1 bay free · 1 busy ·` / `1 out of service · 1 unknown` [vocab] |
| **Lensed, GB/T DC** | `n_T=2, f=1, u=1` | `Operator, 14 min ago · 1 GB/T DC bay free ·` / `1 unknown · 2 other bays` [vocab] |
| **Lensed, no compatible plug** | `n_T=0` | `No GB/T bay here · 4 bays · Type 2, CCS2` [vocab] |

**Freshness leads the clause**, matching the car surfaces, and for the same
reason: a line that can truncate must truncate to something honest.
`2 of 4 bays free` surviving alone is a live claim; `Operator, 14 min ago`
surviving alone is merely less informative
(`01-carplay-design-v3.md` §2.x truncation table). Regime 1 emits **no freshness
head** — there is no state to date.

**The list detent.** Tapping `Let's find a charger` expands the same sheet to a
taller detent holding the nearby list: repeated station cards in the sheet's own
composition, separated by 1 px `#3E3E3E` dividers running the sheet's full inner
width. **This is a detent, not a screen** — the sheet's drag handle (12 × 13 px
`#262626`, 26 px below the sheet top) implies detents in the reference itself.
Ordering is `stationsNear(origin, …)` distance-first then availability. No search
field: the reference contains no search component, and a directory of tens of
stations sorted by distance needs none. **[RAISE-D10]** The detent's height has
no measured value; recommendation: ~70% of screen height, leaving the map and the
crosshair visible, since the reference's sheet always leaves the map visible.

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Sheet content is instant (cached directory). An uncached `Photo` renders as a **`#3E3E3E` block at the thumbnail's exact geometry** — the reference's own measured empty state (the profile avatar's fill). No spinner, no shimmer, no broken-image glyph: none exists in the reference. |
| **Offline** | Offline chip on the map; chip degrades to `~4.1 km straight line`; no route line; photos that are not cached stay `#3E3E3E`. Everything else is identical, because everything else is cached. |
| **Error** | Route failure → the straight-line form. There is no other failure: nothing else on this sheet requires the network. |
| **Signed out** | Identical, except the heart. Tapping it opens the **auth sheet** (§10) and auto-resumes the save. |
| **Saved** | The heart fills `#C7FC2F`. **[RAISE-D11]** the reference shows only the outline heart; a filled state must be chosen. Recommendation: fill with the accent — accent means *yours* everywhere else in the system. |
| **Empty** | Not reachable. |

---

### D-03 · Station detail — [ref-04]

**Purpose.** Everything a driver needs before committing to a drive, and the one
place per-Connector truth is reachable — so a known-broken gun is visible even
to a driver with no plug profile set (domain-model amendment 8).

**Layout — Regime 1 first**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ╭─╮                                            ╭───╮     │  × ⌀81  ⋯ ⌀100
 │  │×│                                            │ ⋯ │     │  same centre y 269.5
 │  ╰─╯                                            ╰───╯     │
 │  ┌────────────────────────────────────────────────────┐  │  hero 1076×620 px
 │  │                  Photo 1 of 3                       │ │  radius 30 px
 │  │                                        ╭─────────╮  │ │  badge lime near-pill
 │  │                ▬▬  ·  ·  ·             │ ⚡ 60 kW │  │ │  cap 27 Regular #FFF
 │  │                indicator §5.7          ╰─────────╯  │ │
 │  └────────────────────────────────────────────────────┘  │
 │  SP Remera                                    ♡    ↗     │  cap 47 Bold + heart/share
 │  4 bays · GB/T DC · Type 2                               │  cap 27 Regular
 │  ⬤ Kabisa                                                │  owner icon ⌀76 + cap 32 Bold
 │                                                          │
 │  Availability                                            │  cap 32 Bold
 │  4 bays · no confirmed status                            │  cap 28 ExtraLight, 45 px
 │    ⌁  GB/T DC · 60 kW · 2 plugs                          │  settings-row §5.6
 │    ⌁  Type 2 · 22 kW · 2 plugs                           │  58.7 pt pitch, dividers
 │  ╭─────────────────────────────────╮                     │
 │  │ Notify me when a bay frees up   │                     │  category chip, lime
 │  ╰─────────────────────────────────╯                     │
 │                                                          │
 │  Connectors                                              │  cap 32 Bold
 │  ┌──────────────────┐ ┌──────────────────┐               │  feature chips §5.5
 │  │ ⌁ 2 × GB/T DC 60 kW│ │ ⌁ 2 × Type 2 22 kW│            │  105 px tall, r 10 px
 │  └──────────────────┘ └──────────────────┘               │  #393939, cap 32 ExtraLight
 │  600 RWF/kWh · all 4 plugs · confirmed 12 days ago       │  cap 28 ExtraLight
 │                                                          │
 │  Getting there                                           │  cap 32 Bold  [RAISE-D12]
 │  Inside the SP forecourt, entrance from KG 11 Ave.       │  cap 28 ExtraLight
 │  Chargers are behind the shop, on the left.              │  45 px line pitch
 ├──────────────────────────────────────────────────────────┤
 │  600 RWF/kWh              ┌────────────────────────┐     │  sticky bar §5.8
 │                           │      Directions        │     │  opaque #121212
 └───────────────────────────└────────────────────────┘─────┘  515×133 px, r 14 px
```

**Slot map**

| Reference | Measured | EV Guide |
| --- | --- | --- |
| Close `×` | ⌀81 px `#393939`, 6 px white stroke, x 64, centre y 269.5 | dismiss |
| Overflow `⋯` | ⌀100 px, 3 white dots ⌀6 px, right x 64, **same centre y** | menu: `Share station` · `Report availability` |
| Hero | 1076 × 620 px, radius 30 px | `Photo[i]`, paginated |
| Page indicator | active 96 × 16 px lime, inactive ⌀16 px `#3E3E3E`, gap 13 px, 34 px above hero bottom | `Photo` count |
| Hero badge | 250 × 72 px, radius ≈32 px, `#C7FC2F`, filled lightning + cap 27 Regular `#FFFFFF` | **peak power** — `60 kW`. Absent when no Connector carries `powerKw` |
| Title | cap 47 Bold | **`Station.name`** — `SP Remera` |
| Heart + share | ink 68 × 62 / 67 × 67 px, 31 px apart | save · share |
| Subtitle | cap 27 Regular, 20 px below title | `4 bays · GB/T DC · Type 2` |
| Owner row | avatar ⌀76 px + cap 32 Bold, 29 px gap, 39 px below subtitle | `Owner.icon` + `Owner.displayName` |
| Owner row trailing icon | message glyph | **dropped** — see below |
| `Description` | cap 31 Bold + cap 28 ExtraLight, 45 px pitch | **`Getting there`** — [RAISE-D12] |
| `Basics and features` | cap 32 Bold + feature chips | **`Connectors`** |
| Sticky bar | 285 px region, opaque `#121212`, ≈90 px padding | rate + `Directions` |

**The owner row's message icon is dropped and nothing replaces it.** EV Guide
has no driver↔operator channel, deliberately: there is no messaging entity
anywhere in the model and no ticket creates one. This is a named content
deviation; the row's geometry, avatar size and label treatment are unchanged.

**[RAISE-D12] `Description` has no field behind it.** `Station` carries `name`,
`nameShort`, `geo`, `vehicleClassTag`, `updatedAt`, `owner_id`, Photos and Bays
— **no prose field**. So the reference's Description block has nothing to render.
Options: (a) drop the block — loses a measured region of the reference; (b) add a
nullable authored `Station.description`, admin-entered like everything else about
a station, and title the block **`Getting there`**; (c) synthesise text from
structured fields, which the model forbids (*availability strings are derived
from structured fields, never prose* — and the same discipline should hold for
everything). **Recommendation: (b).** A charge point inside a petrol forecourt is
the normal Rwandan case, and *where exactly, and how do I get in* is precisely
what coordinates cannot say and what a driver needs on arrival. Routed to ticket
19 as a schema addition. When null, the whole block is absent.

**The `⋯` overflow.** Two items: `Share station` and `Report availability` (the
same proximity-gated flow as the connector rows — §12). **[RAISE-D13]** nothing
in the domain models a *non-availability* correction channel for drivers (ticket
11 gives operators a rate **flag**; drivers get nothing). If the founder wants
"report a wrong rate / wrong location / permanently closed", that is a new
entity and a new ticket, not a menu item this file may add.

**Availability block content**, in full, per regime — sub-head cap 32 Bold, body
cap 28 ExtraLight at 45 px pitch, full 358.7 pt content width, **no ladder** (the
block has room for the longest string):

| Regime | Body |
| --- | --- |
| **1 — drawn first** | `4 bays · no confirmed status` |
| 2 | `Operator, 14 min ago · 2 of 4 bays free` |
| 3 | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` |
| Lensed GB/T DC | `Operator, 14 min ago · 1 of 2 GB/T DC bays free · 2 other bays` |
| All broken | `All 4 bays out of service` |
| Single-bay site | `The bay is free` / `The bay is busy` / `The bay is out of service` |

Below it, **one settings-row per Connector type** (§5.6 geometry exactly: 176 px
pitch, 1 px `#3E3E3E` full-width divider, 24 pt icon at 2 pt stroke, label x 196
cap 32 Regular, no trailing affordance), so per-Connector state is reachable:

```
   ⌁   GB/T DC · 60 kW · 2 plugs · 1 out of service
   ⌁   Type 2 · 22 kW · 2 plugs
```

**Rate line**, Grammar R (`02-androidauto-design-v3.md` §3.5), under the
connector chips at cap 28 ExtraLight:

| Case | String |
| --- | --- |
| one rate, all plugs | `600 RWF/kWh · all 4 plugs · confirmed 12 days ago` |
| one rate, partial | `600 RWF/kWh · 3 of 4 plugs · 1 unknown · confirmed 12 days ago` |
| two rates | `600 RWF/kWh GB/T DC · 400 RWF/kWh Type 2 · confirmed 21 days ago` |
| ≥3 rates | `From 400 RWF/kWh · 3 rates · confirmed 5 days ago` |
| **none confirmed** | `No confirmed rate · 0 of 4 plugs` |
| session fee present | `600 RWF/kWh + 500 RWF session · all 4 plugs · confirmed 12 days ago` |

`No confirmed rate`, never *no published rate* — the second would assert a
licensee is out of compliance with RURA Art. 27(2). [vocab]

**Sticky bar.** Rate left at cap 36 Bold, ≈90 px padding
(`10-design-system.md` [RAISE-6] — the bar ignores the content margin and that
is reproduced), `Directions` CTA right at 515 × 133 px, radius ≈14 px. When the
rate is unknown the left slot reads `No confirmed rate` — 17 characters at the
measured cap-36 Bold advance is ≈493 px, ending at x 583 against a CTA starting
at x 601. It fits, with 18 px to spare, and that is the tightest string in the
system.

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Everything but photos is cached and instant. Uncached hero → `#3E3E3E` block at the hero's exact 1076 × 620 px, radius 30 px. |
| **Offline** | Offline chip under the top button row, right-aligned. `Directions` still works — the hand-off is a deep link and Google Maps owns its own offline story (ADR-0004). |
| **Error** | No error surface. There is no request this screen makes that can fail visibly. |
| **Signed out** | Identical, except the heart and the bay-alert chip, which open the auth sheet and auto-resume (§10). `Directions` is **ungated** (ADR-0003 as amended). |
| **Empty** | Not reachable: a Station is publishable only with ≥1 Bay and ≥1 Photo. |
| **Not at the station** | The connector rows are non-interactive and the block carries one line: `Report status when you're at the station` — §12. |

---

### D-04 · Profile — [ref-02]

**Purpose.** The driver's account, their three quick actions, the operator
cross-app affordance, and the settings list.

**Layout — signed in, with an Owner membership**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ╭─╮                                                      │  back ⌀91 #393939 x38
 │  │←│                                                      │
 │  ╰─╯                              82 px                   │
 │                    ╭───────────╮                          │  avatar ⌀316 outer
 │                    │           │                          │  lime ring 3 px
 │                    │  #3E3E3E  │                          │  fill #3E3E3E when no image
 │                    ╰───────────╯                          │
 │                    Shima Serein                           │  cap 55 Bold (display)
 │                Show and edit my profile                   │  cap 27 Regular #C7FC2F
 │                                                           │
 │        ⬤          ⬤          ⬤                            │  ⌀150 #393939, 6 px glyphs
 │      Saved      My plug     Alerts                        │  cap 27 Bold labels
 │                                                           │
 │  ┌─────────────────────────────────────────────────────┐  │  hosting card §6
 │  │ ┌────┐  Open EV Guide Operator                      │  │  only with a Membership
 │  │ │ ⌁→ │  You manage 3 stations.                      │  │
 │  │ └────┘  Update bay status and rates.                 │  │
 │  └─────────────────────────────────────────────────────┘  │
 │                                                           │
 │  Settings                                                 │  cap 37 Bold x40
 │   👤  Personal Information                                │  176 px pitch
 │  ────────────────────────────────────────────────────     │  1 px #3E3E3E x38→1167
 │   🛡  Login & Security                                     │
 │  ────────────────────────────────────────────────────     │
 │   ⭳  Offline & map data                                   │  ← replaces Payment & payouts
 │  ────────────────────────────────────────────────────     │
 │   🔔  Notifications                                        │
 │  ────────────────────────────────────────────────────     │
 │   ⌁  My plug                                              │
 │  ────────────────────────────────────────────────────     │
 │   ⓘ  About EV Guide                                       │
 └──────────────────────────────────────────────────────────┘
```

**Settings list, both auth states**

| Row | Signed in | Signed out | Destination |
| --- | --- | --- | --- |
| `Personal Information` | ✓ | — | D-05 |
| `Login & Security` | ✓ | — | D-06 |
| `Sign in` | — | ✓ | auth sheet (§10) |
| `Offline & map data` | ✓ | ✓ | D-07 |
| `Notifications` | ✓ | ✓ | D-08 |
| `My plug` | ✓ | ✓ | D-09 |
| `About EV Guide` | ✓ | ✓ | D-10 |

The last three are **below the reference's cut-off** (the capture ends inside
`Notifications`), so they are `[ext]` rows built from the measured row component
with no change to pitch, divider, icon grid, stroke or label treatment.

**States**

| State | Rendering |
| --- | --- |
| **Signed in** | As drawn. `Shima Serein` cap 55 Bold; lime link `Show and edit my profile`. |
| **Signed out** | Avatar renders its measured empty state — ⌀316 px, `#3E3E3E` fill, 3 px `#C7FC2F` ring — **unchanged**, because that is exactly what the reference captured. Display line: `Not signed in`. Lime link: `Sign in to save and report`. Quick actions all present; `Saved` and `Alerts` open the auth sheet on tap and auto-resume; `My plug` opens directly. Hosting card absent. |
| **No membership** | Hosting card absent; the labels→`Settings` gap is 164 px [RAISE-D7]. |
| **Loading** | None — every field is local. |
| **Offline** | Offline chip under the back button, right-aligned. Rows that need the network on tap (`Personal Information`, `Login & Security`) still open and show their cached values. |
| **Error** | None on this screen. |

**Strings:** `Shima Serein` · `Show and edit my profile` · `Not signed in` ·
`Sign in to save and report` · `Saved` · `My plug` · `Alerts` ·
`Open EV Guide Operator` · `Get EV Guide Operator` · `You manage 3 stations.` ·
`Update bay status and rates.` ·
`The operator app updates bay status and rates.` · `Settings` ·
`Personal Information` · `Login & Security` · `Sign in` · `Offline & map data` ·
`Notifications` · `My plug` · `About EV Guide`. All app copy.

---

### D-05 · Personal Information — [ext]

**Assembled from:** back button (§5.2, ⌀91 px) · section heading (cap 37 Bold) ·
settings rows (§5.6) · profile avatar (§5.9).

**Purpose.** View and edit the account's name, email and photo.

**Layout:** back button · heading `Personal Information` · avatar ⌀316 centred
with its lime ring · rows: `Name` / `Email` / `Photo`.

**[RAISE-D14] Settings rows carry no value slot.** §5.6 is explicit: *no
chevron, no trailing affordance*. A settings screen that shows `Name` without
showing the name is useless. Recommendation: **compose the row with the sheet's
right-aligned price treatment** — value at cap 27 Bold `#FFFFFF`, right edge at
the divider's right end (x 1167). Both halves are measured components; the
composition is not. Used by D-05, D-07, D-08 and D-12. Needs a yes.

**States.** Signed-in only (unreachable otherwise). Offline: values render from
cache, edits queue or are refused with `You're offline. Try again when you're
back on.`. No loading state — the account is local. Error: the body line is
replaced in place; there is **no error colour in the token set** (§8.1), so
every error string is `#FFFFFF` body copy where it belongs.

**Strings:** `Personal Information` · `Name` · `Email` · `Photo` ·
`You're offline. Try again when you're back on.`

---

### D-06 · Login & Security — [ext]

**Assembled from:** back button · heading · settings rows with the [RAISE-D14]
value slot.

**Purpose.** Show which providers are connected, sign out, delete the account.

**Rows:** `Apple` / value `Connected` · `Google` / value `Not connected` ·
`Email` / value `shima@…` · `Sign out` · `Delete account`.

`Delete account` is not optional: App Store Guideline 5.1.1(v) requires
in-app account deletion for any app offering account creation. Deleting removes
`SavedStation`, `Watch` and profile rows; **`Report` rows are append-only and
are retained with the reporter detached** — availability the driver contributed
does not vanish and re-break the map. Say so on the confirmation.

**[RAISE-D15] There is no destructive treatment in the reference.** One text
colour, one accent, no red anywhere. `Delete account` therefore renders as an
ordinary row. Recommendation: accept, and carry the weight in the confirmation
copy rather than in colour.

**States.** Signed-in only. Offline: rows render; `Sign out` works (local);
`Delete account` refuses with the offline line. Error: in-place body copy.

**Strings:** `Login & Security` · `Apple` · `Google` · `Email` · `Connected` ·
`Not connected` · `Sign out` · `Delete account` ·
`Delete your account? Saved stations and alerts go with it. Availability you reported stays, without your name.` ·
`You're offline. Try again when you're back on.`

---

### D-07 · Offline & map data — [ext]

**Assembled from:** back button · heading · settings rows + the [RAISE-D14]
value slot.

**Purpose.** ADR-0007's settings home. This screen is why `Payment & payouts`
had to become something (§5).

**Rows**

| Label | Value | Tap |
| --- | --- | --- |
| `Kigali map` | `Built in` | — (non-interactive) |
| `All of Rwanda` | `76 MB` | download |
| `Station directory` | `Synced 2 min ago` | sync now |
| `Delete downloaded maps` | `76 MB` | delete |

**`All of Rwanda` row states**

| State | Value slot |
| --- | --- |
| Not downloaded | `76 MB` |
| Downloading | `42%` |
| Downloaded | `Downloaded · 76 MB` |
| Update available | `Update · 76 MB` |
| Offline, not downloaded | `76 MB · needs a connection` (row non-interactive) |
| Failed | `Download didn't finish. Tap to try again.` in the value slot |

**[RAISE-D16] There is no progress component.** No bar, no ring, no spinner
anywhere in the reference; the hero's active page indicator (96 × 16 px lime) is
a pagination mark, not a meter, and pressing it into service as a progress bar
would be inventing. Recommendation: **a text percentage in the value slot and
nothing else** — the minimum possible invention for a 76 MB download.

**`Station directory` values:** `Synced 2 min ago` · `Synced 3 h ago` ·
`Not synced` (fresh install, offline — the bundled snapshot is still serving).
Never *out of date*: the snapshot is a complete listing, and availability
honesty is structural (ADR-0007), not a function of sync age.

**Strings:** `Offline & map data` · `Kigali map` · `Built in` ·
`All of Rwanda` · `76 MB` · `Downloaded` · `Update` · `needs a connection` ·
`Download didn't finish. Tap to try again.` · `Station directory` ·
`Synced 2 min ago` · `Not synced` · `Delete downloaded maps` ·
`EV Guide works offline. Kigali's map is built in; download the rest of Rwanda for trips outside the city.`

---

### D-08 · Notifications — [ext]

**Assembled from:** back button · heading · settings rows + a trailing state
mark.

**Purpose.** Control bay alerts. This is the only notification EV Guide sends —
ticket 30 permits exactly one event type, product-wide.

**Rows:** `Bay alerts` (toggle) · `System settings` (opens the OS sheet when
permission is denied).

**[RAISE-D17] The reference contains no switch, checkbox, radio or toggle of any
kind.** This is a global gap, not a D-08 gap: it also blocks D-09. Options:
(a) the platform's native switch — conventional, and a visible foreign object in
a system with no other platform control; (b) **a trailing `#C7FC2F` check at the
icon system's measured 24 pt grid and 2 pt stroke, present when on and absent
when off** — built entirely from measured icon metrics plus the one accent, and
consistent with the additive-mark rule the whole design runs on; (c) a lime dot
reusing §5.9. **Recommendation: (b).** It is the single component the system must
add, and it should be added once and used everywhere rather than twice in two
shapes.

**States.** Permission granted → the row toggles. Permission denied → the row is
non-interactive and a body line reads
`Turn on notifications for EV Guide in system settings to use bay alerts.` with
the `System settings` row beneath it. Signed out → the row is present and
non-interactive with `Sign in to use bay alerts.` (a `Watch` is inherently
account-based). Offline → unchanged; permission is local.

`canWatch = isSignedIn && notificationsPermitted`, read **live** — never from a
mirrored bool that can outlive a sign-out, and `.authorized` only, never
provisional (ticket 30's amendment from 18).

**Strings:** `Notifications` · `Bay alerts` ·
`One alert when a bay frees up at a station you're watching. Nothing else.` ·
`Turn on notifications for EV Guide in system settings to use bay alerts.` ·
`System settings` · `Sign in to use bay alerts.`

---

### D-09 · My plug — [ext]

**Assembled from:** back button · heading · settings rows + the [RAISE-D17]
trailing check · one body paragraph.

**Purpose.** Set the driver's connector types. This is what makes the pin dot,
the sheet and the detail answer *free for me* rather than *free* — ADR-0002 calls
the vehicle profile load-bearing.

**Rows** (the closed type-word projection, docs/availability-display.md §2.4):
`Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug`. Multi-select; the
trailing lime check marks each selection.

**Gating.** **Ungated.** Setting your own connector type is a device-local
preference and a reading aid, and the read surface is anonymous (ADR-0003 as
amended; domain-model, *Vehicle connector profile*). Only **syncing it across
devices** needs an account. The domain model flags this for founder
ratification and this file restates the flag rather than settling it:
**[RAISE-D18]** — gating it would make the unlensed aggregate the normal case
for every driver and every store reviewer.

**States.** Nothing selected (the default) → every screen renders unlensed,
which is correct and complete, not degraded. Signed in → the selection syncs.
Signed out → it stays on the device; a body line says so. Offline → unchanged.

**Strings:** `My plug` ·
`Pick the plugs your car takes. EV Guide then shows what's free for your car.` ·
`Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug` [all vocab] ·
`Stored on this device. Sign in to keep it across devices.`

---

### D-10 · About EV Guide — [ext]

**Assembled from:** back button · heading · settings rows + value slot · body
copy.

**Purpose.** Version, legal, and — load-bearing, not decorative — the map data
attribution the reference's `Google` wordmark used to carry (§11).

**Rows:** `Version` / `1.0.0 (1)` · `Map data` / `OpenStreetMap` ·
`Open source licences` · `Privacy` · `Terms`.

`Open source licences` lists MapLibre, the OpenMapTiles-derived style, Valhalla
(MPL-2.0), and the OSM data licence (ODbL). None of this is optional and none of
it is design.

**Strings:** `About EV Guide` · `Version` · `Map data` · `OpenStreetMap` ·
`Open source licences` · `Privacy` · `Terms` ·
`Map data © OpenStreetMap contributors` ·
`EV Guide is free. It takes no payments and never will.`

---

### D-11 · Saved — [ext]

**Assembled from:** back button · heading (cap 37 Bold) · repeated **station
cards** (D-02's sheet composition) · 1 px `#3E3E3E` dividers.

**Purpose.** The driver's `SavedStation` list.

**Layout.** Back button · `Saved` heading · one card per saved station, each
carrying thumbnail 100 pt / `nameShort` cap 36 Bold / availability clause cap 27
Regular / rate right-aligned cap 27 Bold / heart. **No route chip** — the list
is not tied to a position and computing a route per row would be a burst of
Valhalla calls for a screen the driver is browsing, not acting on.

**States**

| State | Rendering |
| --- | --- |
| **Populated** | As above, ordered by distance when a position exists, else by save time. |
| **Empty** | Heading + one line: `Stations you save appear here. Tap the heart on any station.` No illustration and no button — the reference has neither, anywhere. |
| **Offline** | Fully functional; every field is cached. Uncached thumbnails → `#3E3E3E`. |
| **Signed out** | Unreachable — the quick action opens the auth sheet first. |
| **Loading / error** | None. |

**Strings:** `Saved` ·
`Stations you save appear here. Tap the heart on any station.`

---

### D-12 · Alerts — [ext] · **car-effort package**

**Assembled from:** back button · heading · settings rows + value slot.

**Purpose.** The armed `Watch` list — max 3, one-shot, auto-expiring 2 h.

**Rows:** `SP Remera` / value `until 15:12` — tap to disarm.

**States**

| State | Rendering |
| --- | --- |
| Armed | one row per watch, value `until 15:12` |
| Empty | `No alerts set.` + `Open a station and tap “Notify me when a bay frees up”. One alert, next 2 hours.` |
| At the ceiling | body line `3 alerts set. That's the most at once.` |
| Signed out / no permission | unreachable — the quick action gates first (§4) |
| Offline | rows render; a disarm queues |

**[RAISE-D19] The watch vocabulary is contradictory across surfaces.** The
cross-surface verdict (§3 item 1) records `one alert, next 2 h` vs
`One alert, next 2 hours`, `Watching until 15:12` vs `Watching · until 14:05`,
`not confirmed yet` vs `Waiting for confirmation`, and CarPlay's `Notify when
free` vs Android's `Bay alert` vs the phone's `Notify me when a bay frees up`.
Android's set is declared **closed**, so these are defects by a rule CarPlay says
it adopted. This file uses the Android forms and the phone's own long label, and
routes the reconciliation to ticket 30 — it must not be settled three times.

---

### S-01 · Auth sheet — [ext]

**Assembled from:** bottom sheet (§5.4: 16 px top radius, `#121212` fill, 64 px
padding, drag handle 12 × 13 px `#262626` 26 px below the top) · primary CTA
(§5.1: 899 × 138 px, radius 13.5 px) · hosting-card fill (`#393939`) for the
secondary buttons · body copy.

**Purpose.** ADR-0003 as amended (ticket 23): the gate fires on **save and
report**, never on directions. It overlays the screen the driver is on and
**auto-resumes** the action, so the driver never loses their station.

```
 ┌────────────────────────────────────────────────────┐
 │                      ▬▬▬                            │
 │  Sign in to save stations                          │  cap 36 Bold
 │  Reading EV Guide never needs an account.          │  cap 28 ExtraLight
 │                                                     │
 │  ┌───────────────────────────────────────────────┐ │  Apple's own button
 │  │            Sign in with Apple                  │ │  [RAISE-D20]
 │  └───────────────────────────────────────────────┘ │
 │  ┌───────────────────────────────────────────────┐ │  #393939, 138 px, r 13.5
 │  │            Continue with Google                │ │  cap 37 Medium #FFFFFF
 │  └───────────────────────────────────────────────┘ │
 │  ┌───────────────────────────────────────────────┐ │
 │  │            Continue with email                 │ │
 │  └───────────────────────────────────────────────┘ │
 └────────────────────────────────────────────────────┘
```

**Title is trigger-specific**, because a sheet that names the act it will resume
is a sheet the driver can decide about: `Sign in to save stations` ·
`Sign in to report status` · `Sign in to set an alert`.

**Only one button may be lime.** The accent budget is measured at ~3.9% of the
map screens and the reference spends it on pins plus **one** CTA. Three lime
buttons would be the largest accent deviation in the design. So: the platform's
native provider takes the CTA slot; the other two use the hosting card's
`#393939` fill at the CTA's measured height and radius.

**[RAISE-D20] Sign in with Apple cannot be reproduced 1:1.** Apple's guidelines
fix that button's appearance — black / white / white-outline, its own logo
lockup and type — and it cannot be restyled to `#C7FC2F` with a `#121212` label.
It is also **compelled**: Guideline 4.8 requires it once Google sign-in is
offered on iOS (ADR-0003). Options: (a) ship Apple's native button, setting only
its `cornerRadius` to the measured 13.5 px — the one property the API exposes;
(b) draw a custom button, which is a common rejection cause. **Recommendation:
(a).** This is the second provably-impossible element in the driver app, after
the `Google` wordmark (§11), and it is raised rather than absorbed.

**States**

| State | Rendering |
| --- | --- |
| Idle | as drawn |
| In flight | **no spinner** (none exists). The buttons become non-interactive; nothing else changes. |
| Success | sheet dismisses; the original action fires without a second tap — heart fills, or the report sheet opens |
| Cancelled | sheet dismisses; nothing is lost; no message |
| Failed | body line replaced in place: `Sign-in didn't finish. Try again.` — `#FFFFFF` body copy, because **the token set has no error colour** |
| Offline | the sheet still opens; body line reads `You're offline. Sign-in needs a connection.`; buttons non-interactive |
| Email path | the sheet's body becomes an email field + `Send me a link`, then `Check your email. The link signs you in.` |

**[RAISE-D21] There is no text input anywhere in the reference.** No field, no
caret, no placeholder, no keyboard-adjacent chrome. The email path and D-05's
edits both need one. Recommendation: build it from the measured feature-chip
surface (`#393939`, radius 10 px, height 105 px) with a cap-32 Regular
`#FFFFFF` value — that is the closest measured container — and name it as an
addition to `packages/ui`.

**Strings:** `Sign in to save stations` · `Sign in to report status` ·
`Sign in to set an alert` · `Reading EV Guide never needs an account.` ·
`Sign in with Apple` · `Continue with Google` · `Continue with email` ·
`Send me a link` · `Check your email. The link signs you in.` ·
`Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.`

---

### S-02 · Report sheet — [ext]

**Assembled from:** bottom sheet (§5.4) · category chips (§5.5) · body copy.

**Purpose.** File a `Report` — a claim about one **Connector's** availability.
Proximity-gated on the captured location, account-required, offline-queueing.

```
 ┌────────────────────────────────────────────────────┐
 │                      ▬▬▬                            │
 │  GB/T DC · 60 kW                                   │  cap 36 Bold
 │  What's happening at this plug?                    │  cap 28 ExtraLight
 │                                                     │
 │  ╭────────╮  ╭────────╮  ╭─────────────────╮       │  category chips
 │  │  Free  │  │  Busy  │  │  Out of service │       │  lime border, lime label
 │  ╰────────╯  ╰────────╯  ╰─────────────────╯       │  27 px gap (space.chipGap)
 └────────────────────────────────────────────────────┘
```

**One tap commits.** The reference contains **no selected/unselected chip pair**,
so there is no way to show a pending choice without inventing a state. Tapping a
chip files the report and dismisses the sheet. This suits the actual user — a
driver standing at a charge point, one-handed — and mis-taps are cheap: reports
are append-only and most-recent-wins, so the correction is another tap.
**[RAISE-D22]** named, because it is a consequence of a missing state rather than
a UX preference.

**The three labels reuse the closed state words exactly** — `free`, `busy`,
`out of service` — so the report sheet introduces **zero new state vocabulary**.
Title-cased here because each begins its own string
(`01-carplay-design-v3.md` §2.x capitalisation rule). **[RAISE-D23]** the closed
vocabulary in `packages/domain` currently covers state words, capacity clauses,
watch strings and notification bodies; **report action labels are not listed**
and must be added there rather than authored in the app.

**States**

| State | Rendering |
| --- | --- |
| **Signed out** | The sheet does not open. The auth sheet opens instead and auto-resumes into this one. |
| **Not at the station** | The sheet does not open. The connector rows are non-interactive and the availability block carries `Report status when you're at the station`. |
| **Offline** | Files normally. `capturedAt` and `capturedLocation` are recorded at tap time and queued (ADR-0007). **The confirmation is the report's own effect**: the sheet dismisses and the connector row re-renders with the new state immediately, because the derivation runs on device over cached reports including this one. No toast, no snackbar — the reference has neither. |
| **Queued report expired** | Dropped client-side past its 2 h decay window; the row simply re-derives. Nothing is shown, because nothing is true. |
| **Loading / error** | None. A report is a local write. |

**Strings:** `GB/T DC · 60 kW` [vocab] · `What's happening at this plug?` ·
`Free` · `Busy` · `Out of service` [vocab] ·
`Report status when you're at the station`

---

### S-03 · Overflow menu — [ext, from `04`'s `⋯`]

Two items: `Share station` · `Report availability`. The platform's own action
sheet; the reference gives no menu component and none is invented. See
[RAISE-D13] for what is deliberately absent from it.

---

### Deliberately **not** screens

| Not built | Why |
| --- | --- |
| **Route / navigation screen** | ADR-0004 forbids inventing one; the preview lives in D-02 (§7). |
| **Search screen** | The reference has no search component; a directory of tens of stations sorted by distance needs none. Recorded as an accepted reduction, not an oversight. |
| **Full-screen photo viewer** | The hero carousel is the whole photo surface. No ticket asks for more, and a viewer would be the only full-bleed modal in the app. |
| **Onboarding** | No reference, no ticket. Ticket 28 fixes what the *listing and onboarding claim* (`real-time` never appears anywhere) but does not commission screens. **[RAISE-D24]** — if onboarding ships, it is a new design pass, and its copy is already constrained. |
| **Filters** | Nothing in the model is a filter dimension on the phone; the plug lens (D-09) is a reading aid, not a filter, and it never hides a station. |
| **Operator anything** | Different app (ADR-0006). |

---

## 9. The offline surfaces

### 9.1 The quiet offline indicator

**It is a feature chip** (`10-design-system.md` §5.5, the `04` variant): height
105 px = 35.0 pt, radius 10 px = 3.3 pt, fill `#393939`, **no border**, a 2 pt
stroke icon on the 24 pt grid, 30 px left padding, 18 px icon→label, 26 px right
padding, label cap 32 **ExtraLight** `#FFFFFF`, width fits content.

That component is the quietest labelled object in the entire reference: dark
surface, no accent, no border, the lightest weight in the system. It is the
correct face for a state ADR-0007 insists is **normal, not an error**.

| Screen | Placement |
| --- | --- |
| D-01, D-02 | right-aligned to the content column (right edge x 1141), vertically centred on the map avatar (avatar y 362, ⌀129 → centre y 426.5) |
| D-03, D-04, and all `[ext]` screens | directly under the top button row, right-aligned to the content margin |

**It is additive** — absent when online, exactly like every other mark in this
system. Label: `Offline`. It never says *No connection*, *Error*, *Offline
mode*, or anything that reads as a failure, and it never asserts anything about
the *data* — per the display grammar's law 8, no string may claim report
history, and `Offline` describes the device.

**It is explicitly not the crosshair rule** (§3).

### 9.2 The straight-line label

§7.3. `~4.1 km straight line`, in the sheet's chip slot. The `~` prefix plus the
words `straight line` is the form CarPlay already ships, so one product carries
one phrasing. The phone shows **unmarked** driving distance when online, which is
what makes the marker meaningful (ADR-0007's amendment).

### 9.3 The all-Rwanda map pack row

D-07, `All of Rwanda` / `76 MB`. Six states, one raise about progress
([RAISE-D16]).

### 9.4 The global loading and empty vocabulary

**The reference contains exactly one empty state, and it is measured**: the
profile avatar on `02` with no image — a `#3E3E3E` fill inside the lime ring.
That single fact settles loading and placeholder behaviour product-wide, with no
invention:

| Situation | Rendering |
| --- | --- |
| Content not yet available (photo, hero, thumbnail) | **`#3E3E3E` block at the target's exact geometry and radius** |
| Additive marks not yet resolved (route chip, free-bay dot, offline chip) | **absent**, then present |
| Structural content | never absent — the bundled snapshot means the directory always paints |
| Empty list | section heading + one line of cap-28 ExtraLight body copy. No illustration, no button, no icon. |
| Any error | body copy replaced in place, `#FFFFFF`. **There is no error colour in the token set** and adding one would be a deviation. |
| Progress | text only ([RAISE-D16]) |
| Motion | **none, anywhere** — §7 of part 1 found no shadow, blur, gradient or motion in the whole reference, and no shimmer or skeleton animation is introduced |

---

## 10. The inline auth sheet — summary of the gate

| Action | Gate | On tap when signed out |
| --- | --- | --- |
| Browse map, open a station, read rate / connectors / bays / availability | **none** | — |
| **Directions** | **none** (ADR-0003 amended, ticket 23) | fires |
| Save (heart) | account | auth sheet → auto-resume the save |
| Report availability | account | auth sheet → auto-resume into S-02 |
| Arm a bay alert | account + notification permission | auth sheet → permission → auto-resume the arm |
| Set `My plug` | **none** (device-local) | opens directly |
| Sync `My plug` across devices | account | — |

The sheet overlays the screen the driver is on and never navigates. On success it
dismisses and the original action fires **without a second tap** — ADR-0004's
auto-resume pattern, which survived the ticket-23 amendment intact and simply
changed which taps trigger it.

---

## 11. The `Google` wordmark — a genuine 1:1 impossibility

Measured on `01`: the wordmark's ink box is **x 73 → 232, y 2256 → 2306**
(159 × 50 px = 53 × 16.7 pt), sitting 77 px (25.7 pt) above the CTA's top edge at
y 2383, with the map label `Ntarama` beside it at x 253 → 412.

Ticket 06, hardened by ticket 26's no-external-runtime-dependency rule, fixes
**MapLibre with self-hosted OSM tiles**. Under any non-Google provider that pixel
**cannot be reproduced under any circumstance.** It is the only provably
impossible element in the four reference screens.

**A second Google-provenance element sits on the same screens and was not
previously flagged:** the location puck. Sampled at `x 583–642, y 1291–1331` on
`01`, its fill is **`#4285F4`** — Google's brand blue, drawn by the Google Maps
SDK's own location UI. It is not in the token set, it is not EV Guide's to use,
and under MapLibre the puck is ours to draw. **[RAISE-D25]** — it needs either a
measured reproduction (which reproduces a Google brand colour) or a token
decision. Recommendation: draw the puck at the measured geometry in
`#FFFFFF` with a `#C7FC2F` core, which uses only existing tokens; flagged
because it changes a visible reference element.

### Options for the wordmark slot, and the recommendation

| # | Option | Cost |
| --- | --- | --- |
| **a** | **Replace the wordmark with the required OSM attribution in the same slot** — same position (x ≈ 64–73, above the CTA), the reference's own type (cap 27 Regular `#FFFFFF`), reading `© OpenStreetMap contributors`, tapping through to D-10 | The *word* differs and there is no logo lockup. The slot, its position, its treatment and its role all survive. |
| b | Drop the slot and put attribution only in D-10 About | Empties a measured region of the reference, and OSMF's attribution guidance expects the credit in the corner of a browsable map, permitting a reduced form only where screen space is genuinely limited — which is not obviously true of a full-bleed map. Verify against the guidelines before choosing this. |
| c | Use Google Maps and keep the pixel exactly | Contradicts ADR-0007 (offline tiles are required and Google's ToS §3.2.3(a) forbids caching), contradicts ticket 26's rule, and runs into Google's ToS §3.2.3(d)(iii) barring use "in a listings or directory service" — which is EV Guide's own one-line description. Named only because it is the sole path that reproduces the reference. |

**Recommendation: (a).** Attribution is a licence obligation rather than a design
choice, so the slot must carry *something*; the reference's own bottom-left mark
slot is exactly where it belongs, and using the reference's own type treatment
keeps the deviation to the smallest possible unit — one word replaced by a
credit that is legally required.

**Record it as a knowing, founder-approved deviation.** Ticket 06 already says
the founder's rule settles the provider; what remained was recording the
deviation, and this is that record. Two further consequences travel with it:
the neighbourhood labels **Rebero** and **Remera**, visible in the reference,
**do not exist in OSM as places** and must be added upstream before the basemap
can reproduce the reference's own label set.

---

## 12. The report flow and the bay-watch affordance

### 12.1 Report — proximity-gated, per-Connector

Three entry points, all leading to S-02:

1. **A connector row in D-03's availability block**, tapped — the primary path,
   because it names the exact Connector the report is about.
2. **`Report availability` in D-03's `⋯` overflow** — opens a connector picker
   first when the station has more than one type.
3. Nothing on D-01 or D-02. Reporting requires being at the station and knowing
   which plug; neither is true from the map.

**The gate.** Proximity is evaluated on the **captured** location (ADR-0007), so
a report filed at the charger and synced from the car park an hour later is
still valid. Not-at-the-station is a **non-interactive row plus a line of body
copy**, never a hidden control — the same discipline ticket 30 forced on the
watch affordance, for the same reason: a control that disappears teaches the
driver nothing.

**Anti-abuse is the gate itself.** ADR-0002: proximity gating *doubles as the
primary anti-abuse measure. No reputation system in v1.* Nothing in this design
adds a second mechanism.

### 12.2 Bay watch — arm and disarm

**Component: the category chip** (§5.5 — `#393939` fill, `#C7FC2F` 2.5 px
border, cap 27 Regular `#C7FC2F` label, radius 31.5 px), content-sized, placed
directly under D-03's availability block at the content margin.

State lives in the **label**, never in the chip's presence or its styling —
ticket 30's amendment: *"a refusal with a reason in the row's text, never a
disappearing control."* There is exactly one chip style in the reference, so
this is forced *and* correct.

| Condition | Label | Tap |
| --- | --- | --- |
| Can arm, not armed | `Notify me when a bay frees up` | arm |
| Armed | `Watching · until 15:12` | disarm |
| Already free | `A bay is free now` | none |
| At the ceiling | `3 alerts set. That's the most at once.` | none |
| Signed out | `Notify me when a bay frees up` | auth sheet → auto-resume |
| No notification permission | `Notify me when a bay frees up` | OS permission → auto-resume |
| Offline | `Notify me when a bay frees up` | queues; dropped past `armedAt + 2h` |

Fires **only** on a report-driven transition into `Free`. Decay never fires it —
ceasing to know is not an event. One-shot; expires silently after 2 h.

**Ships with the car effort's package** (tickets 23 / 30), which is when the
phone gains it. Specified here so the detail screen's composition is settled
once.

---

## 13. The complete string inventory

Strings marked [vocab] are **data in `packages/domain`** and may not be authored
in the app. Everything else is driver-app copy.

**Availability, capacity, freshness, rate, type words** — all [vocab], all
defined in docs/availability-display.md §2 and enumerated in
`02-androidauto-design-v3.md` §3.8. Not restated here; that table is the source.
The phone adds **no state vocabulary at all**, which is the point: four runtimes,
one grammar.

**New [vocab] members this design requires** (routed to `packages/domain`):

| String | Why |
| --- | --- |
| `Free` · `Busy` · `Out of service` | report action labels — the closed set covers state words but not report actions [RAISE-D23] |

**App copy, by screen**

| Screen | Strings |
| --- | --- |
| D-01 | `Let's find a charger` · `Offline` |
| D-02 | — (all content is [vocab] or data) |
| D-03 | `Availability` · `Connectors` · `Getting there` · `Directions` · `Share station` · `Report availability` · `Report status when you're at the station` · `Notify me when a bay frees up` · `Watching · until 15:12` · `A bay is free now` · `3 alerts set. That's the most at once.` |
| D-04 | `Show and edit my profile` · `Not signed in` · `Sign in to save and report` · `Saved` · `My plug` · `Alerts` · `Open EV Guide Operator` · `Get EV Guide Operator` · `You manage 3 stations.` · `Update bay status and rates.` · `The operator app updates bay status and rates.` · `Settings` · `Personal Information` · `Login & Security` · `Sign in` · `Offline & map data` · `Notifications` · `About EV Guide` |
| D-05 | `Name` · `Email` · `Photo` · `You're offline. Try again when you're back on.` |
| D-06 | `Apple` · `Google` · `Email` · `Connected` · `Not connected` · `Sign out` · `Delete account` · `Delete your account? Saved stations and alerts go with it. Availability you reported stays, without your name.` |
| D-07 | `Kigali map` · `Built in` · `All of Rwanda` · `76 MB` · `Downloaded` · `Update` · `needs a connection` · `Download didn't finish. Tap to try again.` · `Station directory` · `Synced 2 min ago` · `Not synced` · `Delete downloaded maps` · `EV Guide works offline. Kigali's map is built in; download the rest of Rwanda for trips outside the city.` |
| D-08 | `Bay alerts` · `One alert when a bay frees up at a station you're watching. Nothing else.` · `Turn on notifications for EV Guide in system settings to use bay alerts.` · `System settings` · `Sign in to use bay alerts.` |
| D-09 | `Pick the plugs your car takes. EV Guide then shows what's free for your car.` · `Stored on this device. Sign in to keep it across devices.` |
| D-10 | `Version` · `Map data` · `OpenStreetMap` · `Open source licences` · `Privacy` · `Terms` · `Map data © OpenStreetMap contributors` · `EV Guide is free. It takes no payments and never will.` |
| D-11 | `Saved` · `Stations you save appear here. Tap the heart on any station.` |
| D-12 | `No alerts set.` · `Open a station and tap “Notify me when a bay frees up”. One alert, next 2 hours.` |
| S-01 | `Sign in to save stations` · `Sign in to report status` · `Sign in to set an alert` · `Reading EV Guide never needs an account.` · `Sign in with Apple` · `Continue with Google` · `Continue with email` · `Send me a link` · `Check your email. The link signs you in.` · `Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.` |
| S-02 | `What's happening at this plug?` |

**Two words appear nowhere in the driver app, by rule:**

- **`real-time`** — ticket 28: it never appears in the listing, onboarding, or
  UI, anywhere.
- **any string asserting report history** — *no recent report*, *not reported*,
  *unreported*. Law 8 of the display grammar: the offline override yields
  `Unknown` from a thirty-second-old report, which would make those strings
  false. The permitted form is `no confirmed status`.

---

## 14. What each screen owes the domain

| Screen | Projection consumed |
| --- | --- |
| D-01 | `stationsNear(origin, …)` → `geo` + `f = freeBaysOffering(T)` per station |
| D-02 card | **two-line** — `nameShort` / availability clause; plus rate, `Photo[0]`, route |
| D-02 list detent | repeated two-line |
| D-03 | station detail by opaque stable id; **per-Connector state reachable** (domain-model amendment 8); `rateCoverage(station)` denominated in **plugs** (amendment 6) |
| D-11 | two-line over `SavedStation` |
| D-12 | `Watch` rows with `armedAt` |

Every one of them returns **structure, not formatted strings** (amendment 8) —
`(distanceMeters, nameShort)`, never `"~2.4 km · SP Remera"`. The phone formats
at the edge, exactly as Android must.

---

## 15. Raised — impossibilities, gaps and questions

Per the standing rule these are raised, not resolved. **Two are genuine
impossibilities** ([RAISE-D20], §11); the rest are values or components the
reference cannot supply.

| # | What | Recommendation |
| --- | --- | --- |
| **D1** | The pin cannot distinguish Occupied / OutOfService / Unknown | accept — one additive channel, spent on the only actionable fact |
| **D2** | Phone pin dot carries presence; CarPlay's carries a numeral | declare the divergence; presence-only on the phone |
| **D3** | Phone pin carries no Owner mark; CarPlay's does | uniform charger glyph; owner on the card and detail |
| **D4** | No selected-pin treatment; no cluster mark | no selection treatment (1:1); **do not cluster** in v1 |
| **D5** | Crosshair arm insets are asymmetric (29 / 34 px) | inherits part 1's [RAISE-5] ruling |
| **D6** | Quick-action row is two circles until ticket 30 ships | ship two, then three |
| **D7** | The gap left by an absent hosting card (154 vs 164 px) | 164 px |
| **D8** | **Route line width has no reference value** — the only invented dimension | 12 px = 4 pt, round caps |
| **D9** | Two-line sheet subtitle; 45 px pitch derived, not measured | accept; sheet becomes content-sized |
| **D10** | List-detent height unmeasured | ~70% of screen, map still visible |
| **D11** | No filled-heart state in the reference | fill `#C7FC2F` |
| **D12** | **`Description` has no field behind it** | add nullable `Station.description`; title the block `Getting there`; route to 19 |
| **D13** | No driver channel for non-availability corrections | new ticket if wanted; not a menu item |
| **D14** | Settings rows have no value slot | compose with the sheet's right-aligned price treatment |
| **D15** | No destructive treatment exists | `Delete account` is an ordinary row; weight goes in the copy |
| **D16** | No progress component exists | text percentage only |
| **D17** | **No switch / checkbox / toggle exists anywhere** | one trailing `#C7FC2F` check at 24 pt / 2 pt stroke, used everywhere |
| **D18** | `My plug` ungated — flagged for founder ratification by the domain model | keep ungated |
| **D19** | Watch vocabulary contradicts across three surfaces | route to 30; do not settle it a fourth time here |
| **D20** | **Sign in with Apple cannot be restyled — impossible 1:1, and compelled by Guideline 4.8** | Apple's native button with `cornerRadius` 13.5 px |
| **D21** | **No text input exists anywhere in the reference** | build from the feature-chip surface; add to `packages/ui` |
| **D22** | No selected-chip state → the report sheet commits on one tap | accept; reports are append-only |
| **D23** | Report action labels are not in the closed vocabulary | add `Free` / `Busy` / `Out of service` to `packages/domain` |
| **D24** | No onboarding designed | new pass if commissioned; copy already constrained by 28 |
| **D25** | The location puck is Google's `#4285F4` | redraw in `#FFFFFF` + `#C7FC2F` |
| **§11** | **The `Google` wordmark is unreproducible** | replace with `© OpenStreetMap contributors` in the same slot; record as a knowing deviation |

Inherited from part 1 and unresolved here because they are not this file's to
settle: **[RAISE-1]** the typeface and its old-style figures; **[RAISE-2]**
ExtraLight body at 13 pt; **[RAISE-3]** normalise the spacing or not;
**[RAISE-4]** two different CTA sizes; **[RAISE-5]** four alignment defects;
**[RAISE-6]** the sticky bar's 90 px padding; **[RAISE-8]** two blacks on the
accent; **[RAISE-9]** five circular-button diameters.

---

## 16. The inventory table

| Screen | Ref or ext | Components used | States | What fixes its content |
| --- | --- | --- | --- | --- |
| **D-01 Map home** | **[ref-01]** | map canvas · crosshair rule §5.11 · map avatar §5.9 (no dot) · charger pin §5.3 + status dot §5.9 · primary CTA §5.1 · locate button §5.2 · feature chip §5.5 (offline) · attribution mark | default · offline · no-permission · signed-out · (no loading, no empty, no error) | ADR-0002 · ADR-0007 · ticket 06 · ticket 19 |
| **D-02 Map + station card** | **[ref-03]** | bottom sheet §5.4 · thumbnail §5.4 · category chip §5.5 (route) · price composition §5.4 · heart · route line (new width, D8) · divider §5.6 (list detent) | Regime 1 / 2 / 3 / lensed / no-compatible-plug · route-in-flight · route-failed · offline · signed-out · saved · uncached-photo | availability-display.md §2 · ADR-0004 · ADR-0007 · ticket 10 · ticket 19 |
| **D-03 Station detail** | **[ref-04]** | circular buttons §5.2 (⌀81, ⌀100) · hero carousel + indicator + badge §5.7 · title/subtitle · owner row · settings rows §5.6 (connectors) · feature chips §5.5 · category chip §5.5 (bay alert) · sticky bar §5.8 | all availability regimes · rate known / partial / two-rate / ≥3 / unknown / session-fee · offline · signed-out · not-at-station · uncached-hero | ADR-0002 · ADR-0008 · ADR-0004 · ticket 10 · ticket 30 · **D12 (schema)** |
| **D-04 Profile** | **[ref-02]** | back button §5.2 · profile avatar §5.9 · quick actions §5.2 · hosting card §5.10 · settings rows §5.6 | signed-in · signed-out · membership / no-membership · app-installed / not / undeterminable · offline | ADR-0003 · ADR-0006 · ticket 11 · ticket 15 |
| **D-05 Personal Information** | [ext] | back · heading · settings rows + value slot (D14) | signed-in only · offline · error-in-place | ADR-0003 |
| **D-06 Login & Security** | [ext] | back · heading · settings rows + value slot | providers connected / not · sign-out · delete-account confirm · offline | ADR-0003 · Guideline 5.1.1(v) |
| **D-07 Offline & map data** | [ext] | back · heading · settings rows + value slot | not-downloaded · downloading · downloaded · update · offline · failed · synced / not-synced | **ADR-0007** · ticket 06 · ticket 16 |
| **D-08 Notifications** | [ext] | back · heading · settings rows + trailing check (D17) | granted · denied · signed-out | ticket 30 · ADR-0003 |
| **D-09 My plug** | [ext] | back · heading · settings rows + trailing check · body copy | none-selected (default) · selected · signed-in (syncs) · signed-out (local) | ADR-0002 · ticket 12 · ticket 19 · **D18** |
| **D-10 About EV Guide** | [ext] | back · heading · settings rows + value slot · body copy | static | **§11 attribution** · ticket 06 |
| **D-11 Saved** | [ext] | back · heading · station cards (D-02 composition) · dividers §5.6 | populated · empty · offline | ADR-0003 · ticket 19 |
| **D-12 Alerts** | [ext] | back · heading · settings rows + value slot | armed · empty · at-ceiling · offline | **ticket 30** · ticket 23 |
| **S-01 Auth sheet** | [ext] | bottom sheet §5.4 · primary CTA §5.1 · hosting-card fill §5.10 · Apple's native button (**D20**) · text input (**D21**) | idle · in-flight · success (auto-resume) · cancelled · failed · offline · email path | **ADR-0003 as amended** · ADR-0004 · ticket 23 |
| **S-02 Report sheet** | [ext] | bottom sheet §5.4 · category chips §5.5 | signed-out · not-at-station · offline (queues) · expired | ADR-0002 · ADR-0007 · ticket 09 · ticket 11 |
| **S-03 Overflow menu** | [ext] | platform action sheet | — | **D13** |

---

## 17. What this file does not decide

The operator app's screens (a separate app, ADR-0006) · the admin dashboard
(tokens only, and the 1:1 rule does not govern it) · anything in part 1's raise
list · ticket 30's watch-vocabulary reconciliation · the `Station.description`
schema addition, which is ticket 19's to accept or reject · and every founder
call in §15, which is the point of raising them.
