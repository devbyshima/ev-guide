# 11 — Driver app: screen inventory and domain mapping (v2)

> ## Authority note (added 2026-08-13 when ticket 17 closed — read first)
>
> **1. `10-design-system-v2.md` is the single measurement authority.** Where this
> file states a measurement that disagrees with it, **file 10-v2 wins** and this
> file is wrong. Any clause in this file declaring its own numbers authoritative
> "until file 10 lands" is void — file 10-v2 has landed. The known conflict is
> the floating card's corner radius: this file says r ≈ 16 px, **file 10-v2's
> r ≈ 14 px is correct**.
>
> **2. Citations into file 10 use v1 section numbers, which v2 renumbered.**
> Translate with this table; `§5.4` and `§5.7`–`§5.11` do not exist in v2 at all.
>
> | cited here (v1) | read in 10-v2 |
> | --- | --- |
> | §2.3 line height | §4.3 |
> | §2.4 no grey text | §1.3 |
> | §5.1–§5.11 components | §7.1–§7.11 |
> | §6 icon system | §8 |
> | §7 elevation | §9 |
> | §8.1–§8.5 tokens | §10.1–§10.5 (native-only block = §10.5) |
> | §9 raises | §12 |
>
> **3. The forbidden-string list is NOT held here.** Its one home is
> `docs/availability-display.md` §2.2b. Any table of forbidden strings in this
> file is a stale copy; the canonical list governs.



Ticket 17, part 2 of 2. Supersedes `11-driver-screens.md` in full. Part 1 is
`10-design-system.md`, pending correction as `10-design-system-v2.md` (§0.3).

Scope: the **driver app** (`apps/driver`). The operator app and the admin
dashboard are out of scope. The design system lands as `packages/ui`, shared by
both mobile apps; admin takes tokens only (ADR-0006).

This revision answers the round-1 adversarial verdict
([`13-design-verdict-v1.md`](13-design-verdict-v1.md)) — 5 fatal, 14 major,
10 minor. Every finding is answered in **§15**, fixed or rebutted, none left
silent.

---

## 0. How to read this file

**The standing rule governs everything below.** Reference designs are
implemented 1:1 with no deliberate deviations. Where the reference cannot be
reproduced, the impossibility is **raised**, not substituted. §16 holds every
raise; nothing is quietly resolved in the body.

### 0.1 Marking legend and units

- **[ref-NN]** — this screen or element exists in reference `NN.png` and is
  reproduced. Geometry is cited from part 1, or measured here and declared in
  §0.3.
- **[ext]** — by extension: no reference screen exists, so the screen is
  *assembled from named reference components* whose geometry is measured. The
  component list is given for every one.
- **[m·11]** — measured from the PNGs **by this file**. Every such value is
  listed in §0.3; there are no undeclared measurements anywhere below.
- **[d]** — derived by stated arithmetic from [m] values.
- **[RAISE-D…]** — a place the reference cannot arbitrate. Raised, with a
  recommendation, never silently decided.
- **[vocab]** — the string is **closed vocabulary owned by `packages/domain`**
  (docs/availability-display.md §2.4). The app may not author it.

**Units.** px is authoritative (captures are 1206 × 2622 = iPhone 16 Pro @3x);
pt = px/3 is given because that is what a build types.

### 0.2 The five settled rulings this file executes

Binding on files 10, 11 and 12 alike. Not re-decided here.

| # | Ruling |
| --- | --- |
| **R1** | The word for `Occupied` in user-facing copy is **`busy`**, everywhere, both apps. The operator write control reads **`Busy`**. **`in use` is deleted product-wide.** |
| **R2** | **Availability never appears in the accent badge, on any surface.** The hero badge carries **peak power** or is absent. It measures 1.21:1 and may never carry a value a driver must read (§15, M12). |
| **R3** | **`unreported` is forbidden product-wide**, with every string asserting report history. The permitted form is **`no confirmed status`** (and `no confirmed rate`). The forbidden list lives in **exactly one place** — §13.1 — and is cited, never restated. |
| **R4** | A **short rate projection** exists for the card / sheet / sticky slots, defined once in `packages/domain` (§13.2). The long Grammar R ladder stays on the **detail screen only**. |
| **R5** | Colour tokens are whatever the **pixels** say. The reference contains a grey icon; the "no grey tier" finding narrows to **text** (§0.3). |

### 0.3 Measurement policy, and the corrections owed to part 1

Part 1 says it is the only file that measures. v1 of this file then measured
anyway, silently, in five places, and three of those measurements disagreed
with part 1. That is the defect behind verdict minor **m1**. The policy now:

> **This file cites part 1 for every dimension. Where it measures, it says
> [m·11] and the measurement appears in the table below. Where a [m·11] value
> contradicts part 1, the contradiction is stated here and owed back to
> `10-design-system-v2.md` — it is never resolved by silently preferring one
> number in the body.**

**Corrections owed to `10-design-system-v2.md`.** All re-measured from the PNGs
for this revision. `10-design-system-v2.md` **did not exist when this file was
written**; until it lands, the values in the right-hand column are the ones this
file builds on, and part 1's originals are void.

| # | Part 1 says | Measured [m·11] | Method |
| --- | --- | --- | --- |
| 1 | Drag handle **12 × 13 px** core, `#262626` | **180 × 13 px**, `#262626`, x 513→692, y 1822→1834 on `03`, fully rounded (r = 6.5 px), centred on the sheet's own centre x 602.5 | run-length scan of every row 1815–1845 |
| 2 | Sheet "bottom corners square (sheet runs under the CTA)" | **False.** The sheet is a **floating card**: x 64→1141, y 1796→**2317**, rounded on **all four** corners at r ≈ 16 px. Below it, 65 px of `#212121` map, then the CTA at y 2383 | corner-arc profiling both ends; top row y 1797 spans x 79→1126, bottom row y 2317 spans x 82→1123 — symmetric |
| 3 | Category chip **256 × 77 px** (v1 of this file said 253 × 75) | **254 × 76 px**, x 480→733, y 2030→2105 | lime-ink bbox |
| 4 | Icon colour is `#FFFFFF` except the pin glyph and the hosting tile | **False.** The `03` sheet heart is **`#717171`** — 517 px of solid core, no white pixel anywhere in its ink box (x 1025→1074, y 1881→1926, 50 × 46 px). Stroke integrates to **6.0 px**, i.e. the §6 2 pt stroke unchanged; only the colour differs. The `04` heart (68 × 62 px) and share (67 × 67 px) glyphs *are* `#FFFFFF` | colour histogram over the ink box; sub-pixel stroke integration across three perpendicular cuts |
| 5 | Primary CTA **899 × 138 px** | **897 px** of lime core, x 65→961 (899 px counting the 1 px AA each side). The locate button occupies x 1003→1139. **Content width 1078 = CTA 897 + gap 41 + locate 137.** The CTA's width is a *residual*, not a component property | run-length scan at y 2450 |
| 6 | — (no advance model) | **Mean ink advance is string-dependent**, so every fit check below states its constant. Measured: cap 27 Regular k = 0.667 (`Hybride - Black - 2024`, 22 ch, 397 px) … 0.730 (`Hybride`, 7 ch, 138 px). cap 32 Medium k = 0.650 (`Check Availability`, 18 ch, 374 px). cap 37 Medium k = 0.574 (`Let's find a car`, 16 ch, 340 px). **Bold k = 0.80** — two independent runs agreeing to 0.01 (`135 000 RWF/day` at cap 36, 433 px; at cap 27, 321 px) | ink bbox ÷ (chars × cap px) |

**Consequence of correction 4, and R5.** Part 1 §2.4's headline finding —
*"there is no grey text anywhere; every text core samples `#FFFFFF`"* — is
**still true and still load-bearing**, and this file relies on it. What is
false is the wider claim that the system has no grey tier at all. It has
exactly one grey, and it is an **icon** colour:

| Token | Value | Where measured | Contrast on `#121212` |
| --- | --- | --- | --- |
| `color.iconMuted` | **`#717171`** | `03` sheet heart, 517 px solid | **3.84 : 1** — clears the 3:1 floor for a non-text UI component |

The three decisions part 1 rested on the no-grey premise survive unchanged,
because all three are about **text**: one text colour (§2.4), no `text.secondary`
token (§8.1), and errors rendered as `#FFFFFF` body copy (§9.4 here). None of
them is disturbed by an icon token.

### 0.4 The advance model, stated once

Every fit check below uses **ink ≈ k × cap_px × nChars**, with k taken from
§0.3 row 6 at its **pessimistic end for the weight in question**: Regular
**0.73**, Medium **0.65**, Bold **0.80**. A fit is only ever asserted when it
holds at that constant. This is an estimate, not a guarantee: the definitive
check is setting the string in the chosen face, which is itself blocked on
part 1's [RAISE-1].

### 0.5 The worked station

Every screen below is drawn with **CarPlay fixture S1**
(`01-carplay-design-v3.md` §3.0) unchanged, so all four runtimes render one
dataset. v1 of this file quietly used 4.1 km against the fixture's 2.4 km;
corrected (verdict **m2**).

| Field | Value | Source |
| --- | --- | --- |
| `Station.name` | `Kabisa – SP Remera` | S1 |
| `Station.nameShort` | `SP Remera` | S1 |
| `Owner.displayName` / `shortName` / `markerLabel` | `Kabisa` / `Kabisa` / `KAB` | S1 |
| Position | −1.9556, 30.1044 | S1 |
| Bays | 4 | S1 |
| Connectors | 2 × `GBT_DC` 60 kW · 2 × `IEC_62196_T2` 22 kW | S1 |
| Rate | 600 RWF/kWh on all 4 plugs, `rateConfirmedAt` = 12 days ago | S1 |
| Reports | operator, −14 min: B1 Free · B2 Occupied · B3 Free · B4 Occupied | S1 |
| Derived at t = 0 | `n=4 f=2 o=2 x=0 u=0` — **Regime 2** | S1 |
| Derived at t = +6 h | `n=4 u=4` — **Regime 1**, by operator decay | ADR-0002 |
| **Straight-line distance** | **2.4 km** — the shared figure, rendered `~2.4 km straight line` on both CarPlay and the phone | S1 |
| Driving distance / duration (phone only) | **2.9 km / 8 min** — *fixture data, not a measurement*; the phone is the only surface that renders it (ADR-0004 forbids duration on car surfaces) | this file |

**Availability is drawn Unknown first, everywhere.** ADR-0002: `Unknown` is the
normal case (~87% of the country), not a failure. Every screen below shows the
**Regime 1** variant as its primary rendering, with the reported variants after.
Any screen whose primary drawing shows a confident green state is drawn wrong.

v1 was criticised internally for drawing Regime 1 while claiming S1 as its
fixture, since S1 carries operator reports. It is the **same station at a
different clock time**: S1 at t = 0 is Regime 2; at t = +6 h its operator
reports decay and S1 *is* Regime 1 with `n=4, u=4`. One fixture, two renders, no
second dataset.

---

## 1. The five substitutions the ticket names

All five are clean. Each keeps the component's every measured property and
changes only its content.

| # | Reference | EV Guide | Component unchanged? |
| --- | --- | --- | --- |
| 1 | car pin (`01`, `03`) | **charger pin** | Yes — §5.3 geometry, colours and stroke identical; only the glyph drawing changes (line-art vehicle → line-art charge point), same `#393939`, same 5–6 px stroke, same ink width inside the inner disc |
| 2 | rental card (the `03` card composition) | **station card** | Yes — §5.4 slots reassigned in §8/D-02; no geometry moves |
| 3 | `135 000 RWF` Bold + `/day` Regular | **the R4 short rate projection** (§13.2) | Yes — the reference's composition is *amount-and-currency Bold + slash-unit Regular*, and `rateShort` takes it verbatim. cap 27 Bold on the card, cap 36 Bold on the sticky bar. **Never a per-Connector rate rendered as the station's** — see §13.2 |
| 4 | `Check Availability` (sticky CTA, `04`) | **`Directions`** | Yes — §5.8, 513 × 131 px lime core [m·11], radius ≈14 px, `#C7FC2F`, label cap 32 **Medium** `#121212`. 10 chars at k = 0.65 → 208 px in a 513 px button |
| 5 | `Let's find a car` (primary CTA, `01`/`03`) | **`Let's find a charger`** | Yes — §5.1, **897 px** core × 138 px, radius 13.5 px, label cap 37 Medium `#121212`. 20 chars at k = 0.65 → 481 px inside 897 px; the reference's own 16-char label measures 340 px [m·11] |

Substitution 4 is the ticket's named mapping and it is worth stating why it is
exactly right rather than merely available: `Check Availability` in the
reference is *the rental's commit action*. In EV Guide the commit action is
going there. Availability is not a thing you tap to check — it is already on the
screen, derived, and there is no server call that would tell you more.

Substitution 5's destination is **not a new screen**: see §8, D-02.

**A width that is not a token.** The 897 px CTA is *not* a full-width button and
must never be tokenised as one. §0.3 row 5: it is `contentWidth − gap −
locateButton`. **There is no full-width CTA anywhere in the four references**,
and any screen that stacks 897 px buttons has inherited a number that means
something else (verdict **M6**; fixed in §8, S-01).

---

## 2. The pin — availability without new visual language

The ticket's headline question. The reference pin affords **one accent-bearing
surface (the 2 px `#C7FC2F` outline) and one glyph slot**. EV Guide has four
states plus freshness, and the majority state is `Unknown`.

### 2.1 What is ruled out, and why

| Channel | Why it cannot carry availability |
| --- | --- |
| **Outline colour** | Four states need four colours. Part 1 §8.1: the accent is *exactly one value, no tints, no gradients* — verified across four screens. Three new colours is three new tokens, i.e. new visual language. Ruled out. |
| **Glyph substitution** | Four glyphs for four states. Also a category error: availability is a property of a **Connector**, never of a Station (ADR-0002), and a pin is a Station. A station-level state glyph asserts something the model forbids. Ruled out. |
| **Pin fill / disc colour** | `#F3F3F3` and `#FFFFFF` are the only two pin surfaces and they are 6 units apart — not a signalling range. Ruled out. |
| **Size, opacity, motion** | No size variation, no opacity ramp and no motion exists anywhere in the reference (part 1 §7: *there are none, anywhere*). Ruled out. |

### 2.2 The decision

**The pin carries the reference's own status dot, drawn only when a bay is free
for this driver.** Nothing else about the pin changes, ever.

The status dot is a measured component, not a new one — part 1 §5.9, the mark on
the map avatar: ⌀ **20–21 px = 7.0 pt**, fill `#C7FC2F`, ring `#FFFFFF` ≈4 px, no
shadow. Its ink box measures x 168–187, y 367–387 on `01` against an avatar at
x 64, y 362, ⌀129 — centre offset (+49, −49.5).

**The rule, in one line:** the dot is drawn when
`f = freeBaysOffering(T) > 0` at render time — lensed by the driver's connector
profile `T` when one is set, unlensed (`T = ∅`) when not — and is absent
otherwise.

```
      Unknown  (THE NORMAL CASE)      Free for me            Busy / OutOfService
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
  stale dot is unrepresentable rather than discouraged.
- **It answers "free for me", not "free"** — the lens rides in `f`, which is the
  domain trap the whole model exists to avoid.
- **It cannot render the map as a field of failure.** At ~87% Unknown, any
  scheme that *marks* Unknown paints the country as broken. This one marks only
  the ~13% that is positively actionable.

### 2.4 The dot's geometry, re-derived — [RAISE-D26]

v1 scaled the avatar's offset onto the pin by axis ratio and got (+46, −46).
Re-derived here from the pin's own measured geometry, that placement **destroys
the mark** (verdict **M13**).

**Measured pin geometry** [m·11], from the isolated pin at x 967–1088,
y 991–1137 on `01`:

| Property | Value |
| --- | --- |
| Outer bbox | 122 × 147 px |
| Head | a circle **⌀122 px**, centre (1027.5, 1052) — the widest row is y 1052, exactly 61 px below the top |
| Lime rim | `#C7FC2F`, 2 px, at radius **60–61** |
| White body ring | `#FFFFFF`, radius ≈51–59 |
| Inner disc | `#F3F3F3`, radius ≈50 (⌀100) |
| Tip | y 1137, 85 px below the head centre |

**The collision, in numbers** [d]:

| Quantity | Avatar (works) | Pin at v1's (+46, −47) (fails) |
| --- | --- | --- |
| Host radius | 64.5 px | **61 px** |
| Dot centre distance from host centre | 69.3 px (= 1.074 × r) | 65.8 px (= 1.079 × r) |
| Dot lime ink spans radius | 59.3 → 79.3 | **55.8 → 75.8** |
| Host's lime rim at radius | *none — the avatar has no rim* | **60 – 61** |
| Dot's white ring spans radius | 54.8 → 59.3 | **51.3 → 55.8** |
| What the ring's inner half lands on | `#FFFFFF` avatar — invisible, but harmless | **`#FFFFFF` pin body — invisible, and it is the only thing separating two lime shapes** |

So: **the dot's lime fill crosses the pin's lime rim** (55.8 < 60 < 75.8), and
the white ring that would have separated them lands on the white pin body. The
dot fuses to the rim and stops reading as a mark. The avatar escapes this only
because it has no rim — the proportion is transferable, the *context* is not.

**Re-derivation.** For the ring to do its job it must sit on the `#212121` map,
clear of the rim: `d − ringOuterRadius ≥ headRadius`, i.e.
`d ≥ 61 + 14.5 = 75.5 px`, giving an offset of **(+53, −53) px = (+17.7, −17.7)
pt** along the 45° top-right diagonal — the tangent case, the smallest departure
that keeps the mark legible. That is **1.238 × head radius** against the
avatar's 1.074, and **it is a value the reference does not contain**.

**Recommendation: (+53, −53) px, tangent.** Raised because it is a derived
placement, not a measured one, and because the alternative — reproducing the
proportion literally — produces a mark that cannot be seen. Reproducing an
offset is not reproducing a *mark*; the thing the reference contains is a
legible additive dot, and 1:1 on the pin means preserving that, not the arithmetic
that happened to produce it on a rimless host.

### 2.5 What the pin deliberately does not say — [RAISE-D1]

`Occupied`, `OutOfService` and `Unknown` are **indistinguishable on the pin**. A
driver cannot tell "someone reported it busy" from "nobody knows" without
tapping the pin and reading the card.

That is a knowing cost, not an oversight, and it needs a yes:

- The pin has exactly one additive channel and it is spent on the only
  positively actionable fact.
- The alternative — a second channel for hazard (`OutOfService`) — has no
  reference vocabulary. The nearest candidates (a second dot colour, a struck
  glyph, a desaturated body) all invent language, and `OutOfService` is a
  Connector fact that only rolls up to a station when *every* gun is broken.
- The cost is bounded: one tap surfaces the full grammar.

**Recommendation: accept.**

### 2.6 Three further pin raises

**[RAISE-D2] The dot carries presence, not a count.** CarPlay composites a
filled **numeral** badge carrying `f` onto its pin. The phone's status dot is
7 pt and cannot hold a digit; a disc that could would be a new size and the
numeral itself would be the first numeral-in-a-circle anywhere in the reference.
The cross-surface verdict (§3 item 4) already records pin availability as an
*undeclared* divergence between CarPlay and Android Auto — this **declares** the
phone's. Recommendation: presence-only on the phone; the count is one tap away.

**[RAISE-D3] The pin carries no Owner mark.** CarPlay composites `Owner.icon` +
`markerLabel` (≤3 chars) into its pin so twelve pins from three Owners stay
distinguishable. The phone pin's glyph slot is monochrome `#393939` by
measurement and `Owner.icon` is a colour vector; dropping a colour logo in
breaks the measured pin, and the reference's own seven pins are identical.
Recommendation: one uniform charger glyph on the phone; Owner identity is
carried by the station card and the detail's owner row. This is a **third**
per-surface pin treatment and it is declared, not discovered later.

**[RAISE-D4] There is no selected-pin treatment, and no cluster mark.**
Verified: all seven lime outlines in `03` measure 122 × 147 px *while a card is
open* — the reference genuinely does not highlight the selected pin.
Recommendation for selection: none — the card is the feedback, which is 1:1.
Clustering is different: ticket 06 assumed clustered `SymbolLayer` pins, and a
count-bearing cluster bubble cannot be derived from anything in the reference.
Recommendation: **do not cluster in v1** (ADR-0007 puts the directory at tens of
stations); if clustering is ever needed, it is a new component requiring a yes.

---

## 3. The crosshair rule

Part 1 §5.11, left open there as `[RAISE-7]`: a 2 px `#FFFFFF` horizontal rule
at y 249–250 spanning **x 64 → 1141 — exactly the content width** — terminated by
two 3 × 83 px vertical arms inset 29 px from the left end and 34 px from the
right (asymmetric by 5 px). Identical on both map screens. Attached to nothing,
enclosing nothing, moving with nothing.

**Decision: EV Guide reproduces it verbatim, on both map screens, as a static
mark with no behaviour and no state.**

It is the **content-column datum**. That is not a story invented to justify
keeping it — it is what the measurement says: the rule's extent is *identical*
to the card's (x 64 → 1141), to the CTA's left edge (x 64), and to the map
avatar's left edge (x 64). Every floating element on the map screen aligns to
it. It marks the top of the region in which map chrome sits, below the status
bar.

Three tempting jobs are **explicitly rejected**, because each would be inventing
behaviour a still cannot support:

- It is **not** the offline indicator (§9.1 gives that its own face).
- It is **not** a "search this area" control — the reference has no search
  anywhere.
- It does **not** animate, move, or respond to the card. Part 1 §7 found no
  motion anywhere in the system.

**[RAISE-D5]** The asymmetric arm inset (29 px left / 34 px right) is part 1's
[RAISE-5c] — a reference defect. Reproducing it is the literal reading of 1:1;
correcting it to 29/29 is a deviation. This file does not rule; it inherits the
ruling made on [RAISE-5].

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
  package** (ticket 23).

**The notification dot is dropped from this row**, and from the map avatar. One
mark may not carry two meanings in one product, and the status-dot component is
spent on the pin (§2.2).

**[RAISE-D6] The row's composition at v1.** If the founder ships the phone app
before ticket 30's package, `Alerts` has no destination and the row is **two
circles**, not three. The reference shows exactly one instance of this row, with
three items, and cannot arbitrate a two-item variant — and it is already a
defective row (part 1 [RAISE-5d]: spacing 64 px / 81 px, circle 1 ⌀154 against
⌀149). Options: (a) ship two circles at v1 and three later, (b) ship `Alerts`
from the first release with an empty-state screen, (c) ship two permanently and
reach alerts from settings. **Recommendation: (a).**

---

## 5. `Payment & payouts`

The reference settings list (`02`), measured at 176–177 px pitch with 1 px
`#3E3E3E` dividers at y 2188 / 2364 / 2541: `Personal Information` ·
`Login & Security` · `Payment & payouts` · `Notifications` (clipped by the
capture).

EV Guide has no payments anywhere and never will — there is no payment, plan or
billing entity in the model, and the structured Rate fields are explicitly *the
whole seam a future payment effort would build on* (docs/domain-model.md).

**Decision: `Payment & payouts` → `Offline & map data`.**

| Property | Reference row | EV Guide row |
| --- | --- | --- |
| Pitch | 176–177 px = 58.7–59.0 pt | unchanged |
| Icon | banknote, 6 px = 2 pt stroke, 62–68 px ink at x 45–46 | download-arrow, **same stroke, same grid, same x** |
| Label | `Payment & payouts`, x 196, cap 32 Regular `#FFFFFF` | `Offline & map data`, unchanged treatment |
| Divider | `#3E3E3E` 1 px, x 38 → 1167, no inset | unchanged (see §5.1) |
| Trailing affordance | none | none |

Three reasons this is a substitution rather than a deletion:

1. **Nothing financial-shaped can ever take the slot**, so the choice is free —
   the only question is what deserves it.
2. **ADR-0007 requires a settings home** for the opt-in all-Rwanda map pack
   (76 MB), and ticket 17 is charged with designing that row.
3. **A driver low on charge outside Kigali is the product's defining user**
   (ADR-0007's own rationale). Offline data is the single most consequential
   setting the driver app has — the same "account plumbing" weight the payment
   row carried in the reference.

**The row-count claim, corrected** (verdict **m3**). v1 said the settings list
*"keeps the reference's row count and pitch exactly."* That is false and
contradicted its own D-04, which lists six rows signed-in. What is true:

> The reference's capture shows **four** rows, the fourth clipped. EV Guide
> keeps **all four 1:1** — three unchanged, one relabelled — and adds **two
> `[ext]` rows below the capture's cut-off** (`My plug`, `About EV Guide`).
> The reference cannot contradict a row count it does not show. **Pitch,
> divider, icon grid, stroke and label treatment are unchanged on every row,
> added or not.**

### 5.1 What "full width, no inset" means — [RAISE-D29]

Part 1 §5.6 records the divider as `#3E3E3E`, 1 px, **x 38 → 1167 — full row
width, no inset**. Verdict **M14**: that x-range belongs to the 38 px
card-margin family, and this file also uses §5.6 rows inside 64 px page margins.
Stated once, so three containers do not silently disagree:

> **`full width, no inset` is a relationship to the row's container, not an
> absolute x-range.** The divider spans its container's content box, edge to
> edge, with no additional inset of its own.

| Container | Where | Divider x-range |
| --- | --- | --- |
| Settings-list family (card margin 38 px) — **the measured instance** | `02` and D-04 … D-12 | **x 38 → 1167** |
| Page content column (page margin 64 px) | **D-03's connector rows only** | x 64 → 1141 [d] |
| Card inner box (card 64 → 1141, padding 64) | D-02's list detent, D-11's rows | x 128 → 1077 [d] |

**Raised** because the reference contains exactly one container, so the
generalisation is a derivation from a single instance. **Recommendation:
accept** — the alternative is a 38 px-anchored divider floating 26 px outside
D-03's own content column, which is visibly wrong at 1×.

---

## 6. `Switch to hosting mode` — the cross-app affordance

Reference card (`02`), part 1 §5.10: 1130 × 335 px (376.7 × 111.7 pt), radius
13 px, fill `#393939`, 39 px padding on all four sides, icon tile 257 × 257 px
`#3E3E3E` radius ≈15 px with a lime ≈9 px-stroke glyph, tile→text 67 px, title
cap 37 Bold, body cap 28 ExtraLight over 3 lines at 45 px pitch.

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
164 is the larger, so nothing crowds.

---

## 7. The route preview, inside the existing screens

ADR-0004 requires a preview — route line, real driving distance, ETA — and the
reference contains **no route screen**. ADR-0004's own consequence section says
so.

**Decision: the preview is split across two slots that already exist.**

### 7.1 The route line goes on the map, in the map + card screen (D-02)

A Valhalla polyline from the driver's position to the selected station, drawn on
the MapLibre map beneath the existing card. Colour **`#C7FC2F`** — the only
accent, and the reference already spends it on the map (pin outlines), so a lime
line adds no colour to the map's budget. Round caps and joins, matching the icon
system's only stated join rule (part 1 §6).

**[RAISE-D8] The route line's width has no reference value.** The reference's
entire line vocabulary is 2 px (pin outline, crosshair rule), 2.5 px (chip
border), 3 px (crosshair arms), 6 px (icon stroke), ≈9 px (hosting tile glyph) —
none of them a line drawn *on the map*. **Recommendation: 12 px = 4 pt**, twice
the icon stroke, which reads at map zoom without competing with the pins. This
is the **one invented dimension in the whole driver design** and it needs a yes.

### 7.2 The distance and duration go in the category-chip slot — re-solved

The `03` chip measures **254 × 76 px** [m·11], x 480–733, radius 31.5 px,
`#393939` fill, `#C7FC2F` 2.5 px border, label cap 27 Regular `#C7FC2F`. Its
label ink is x 566–703 = 138 px for `Hybride`, giving **86 px of left padding
against 30 px of right** — part 1's [RAISE-5a] defect, measured again here only
because the fit arithmetic needs it.

It carries **`8 min · 2.9 km`**.

This is the correct tenant, for four reasons:

1. In the reference the chip is **redundant** — it repeats `Hybride`, the first
   token of the subtitle directly above it. It is the one slot on the card
   carrying no unique information, so re-tenanting it costs nothing.
2. Accent throughout this system means *actionable, yours, now* — the CTA, the
   link, the active page indicator, the status dot. A route computed for **this
   driver from this position right now** is exactly that.
3. It is **additive**, like every other accent mark: absent until the route
   resolves, absent when there is no location, absent offline. The reference has
   no spinner or skeleton anywhere and none is introduced.
4. Availability must **not** go here, per **R2** — a lime-bordered chip on ~87%
   of stations reading *no confirmed status* is the outcome ADR-0002 forbids by
   name.

**The fit, checked against the chip and not the column** — verdict **M5**. v1
checked `~4.1 km straight line` against the card's 594 px *content column* and
declared it fitted. The chip is 254 px. Checked properly, at Regular k = 0.73
(§0.4) and with the measured 86/30 padding:

| String | chars | label ink [d] | chip width [d] | chip right edge from x 480 |
| --- | --- | --- | --- | --- |
| `Hybride` (reference) | 7 | 138 px [m·11] | **254 px** [m·11] | 733 |
| `8 min · 2.9 km` | 14 | 276 px | **392 px** | 872 |
| `~2.4 km straight line` | 21 | 414 px | **530 px** | 1010 |

Both fit **only if the chip grows with its content.** At a fixed 254 px neither
fits and the placement is impossible.

**[RAISE-D27] The category chip's width behaviour cannot be measured.** The
reference contains exactly **one** category chip, so one width. The only chip
whose width behaviour *is* measured is the sibling **feature chip** (`04`), which
part 1 §5.5 records as *"width fits content (271 / 652 px measured)"* — two
instances, two widths, one height. **Recommendation: the category chip is
content-sized**, on the strength of the system's only measured chip-width rule.
That is a citation across components, not an invention, but it is still a
derivation from a single instance and needs a yes. If the answer is no — if the
chip is fixed at 254 px — **the route preview cannot live in the chip and the
placement is an impossibility**, which is the honest alternative and is recorded
as such rather than papered over.

Content-sizing carries the 86 px left padding with it, which will look wrong on
a route string. That padding is part 1's [RAISE-5a] and this file inherits the
ruling; it does not correct it here.

**The chip is a label, not a control** (verdict **M7** — see §12.3).

### 7.3 Offline and failure — what it degrades to

| Condition | Chip | Route line |
| --- | --- | --- |
| Online, location known, route resolved | `8 min · 2.9 km` | drawn |
| Route in flight | **absent** | absent |
| Route failed (server error) | `~2.4 km straight line` | absent |
| **Offline** (ADR-0007) | `~2.4 km straight line` | absent |
| No location permission | **absent** | absent |

`~2.4 km straight line` is exactly ADR-0007's amendment for a marked
straight-line figure, and the `~` + `straight line` form is the wording CarPlay
already ships **with the same number** (§0.5), so one product carries one
phrasing over one fixture.

**The `Directions` CTA is never gated on any of this** (ADR-0007: *"the Google
Maps hand-off button is never gated on the preview"*), and it is never gated on
an account (ADR-0003 as amended, ticket 23).

### 7.4 What the preview must not promise

ADR-0004: ETAs shown are EV Guide's own (Valhalla) and may differ from Google's
after hand-off. The chip therefore says `8 min`, never `arrive 11:14` — a clock
time would be read as a promise about the drive EV Guide does not own.

---

## 8. The screen inventory

Twelve screens, three sheets, six non-screens.

### 8.0 Entry points — every screen, no orphans

Verdict **M11**: v1 gave several screens no way in. Corrected; this table is
exhaustive and is the index for the rest of §8.

| Screen | Entered from | Exit |
| --- | --- | --- |
| **D-01 Map home** | app launch — the root | — |
| **D-02 Map + station card** | tap a pin on D-01 · tap the CTA on D-01 (list detent) | drag the card down, or tap the map → D-01 |
| **D-03 Station detail** | **tap the station card on D-02** · tap a row in D-02's list detent · tap a row on D-11 · tap a row on D-12 | `×` → back to the caller |
| **D-04 Profile** | tap the map avatar on D-01 or D-02 | `←` |
| **D-05 Personal Information** | settings row on D-04 | `←` |
| **D-06 Login & Security** | settings row on D-04 | `←` |
| **D-07 Offline & map data** | settings row on D-04 | `←` |
| **D-08 Notifications** | settings row on D-04 | `←` |
| **D-09 My plug** | `My plug` quick action **or** settings row on D-04 | `←` |
| **D-10 About EV Guide** | settings row on D-04 · **tap the attribution mark on D-01 / D-02** | `←` |
| **D-11 Saved** | `Saved` quick action on D-04 (gated → S-01) | `←` |
| **D-12 Alerts** | `Alerts` quick action on D-04 (gated → S-01) | `←` |
| **S-01 Auth sheet** | any gated tap: heart on D-02 / D-03 / D-11 · a connector row or the bay-alert control on D-03 · `Saved` or `Alerts` on D-04 · `Sign in` row on D-04 | dismiss, or success → auto-resume |
| **S-02 Report sheet** | a connector row on D-03 · `Report availability` in S-03 | one tap commits and dismisses |
| **S-03 Overflow menu** | `⋯` on D-03 | platform dismissal |

---

### D-01 · Map home — [ref-01]

**Purpose.** The app's front door and its primary surface: every station in
Rwanda on a dark map, reachable anonymously with no account, no permission and
no connection.

```
 ┌──────────────────────────────────────────────────────────┐
 │  11:01                                    ▮▮▯ ᯤ  79      │  status bar (OS)
 │                                                          │
 │  ├──────────────────────────────────────────────────┤    │  crosshair rule §5.11
 │                                                          │  y 249–250, x 64→1141
 │   ⬤                                          ▭ Offline   │  avatar ⌀129 x64 y362
 │   avatar                                     feature chip│  offline chip §9.1
 │                                                          │
 │              ◉        ◉●                                 │  pins 122×147 px
 │                                ◉                         │  ● = free-bay dot
 │                    ◉                                     │    at (+53,−53) §2.4
 │                        ◉                                 │
 │                  ◉                                       │
 │                     ⬤ location puck                      │  §11 [RAISE-D25]
 │                                                          │
 │  © OpenStreetMap contributors                            │  attribution §11
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA 897×138 r13.5
 │  └──────────────────────────────────┘   ╰──╯             │  locate ⌀139 +lime ring
 └──────────────────────────────────────────────────────────┘
```

**Components:** map canvas `#212121` · crosshair rule (part 1 §5.11) · map
avatar (§5.9, ⌀129 px `#FFFFFF`, x 64, y 362, **no status dot** — §4) · charger
pins (§5.3 + §2.2/§2.4) · primary CTA (§5.1, **897 px** [m·11]) · locate button
(§5.2, ⌀139 px `#FFFFFF` with a 4 px lime ring and the system's **only filled
glyph**) · attribution mark (§11) · offline chip (§9.1).

**Behaviour**

| Element | Action |
| --- | --- |
| Avatar | push **D-04** |
| Pin | select → **D-02** (card opens, no screen change) |
| Locate `➤` | recentre on the driver; if permission not granted, request it |
| CTA `Let's find a charger` | expand the card to its list detent — D-02's second detent, **not a new screen** |
| Attribution mark | push **D-10** |
| Crosshair rule | **none** — a static mark, §3 |
| Map pan / zoom | pans; `stationsNear` re-queries on the viewport centre |
| Offline chip | none — a label |

**States**

| State | Rendering |
| --- | --- |
| **Default / first run, no connection** | Fully populated. ADR-0007 ships the Kigali basemap (5.6 MB) and a directory snapshot **inside the binary**, so pins paint immediately with every availability honestly Regime 1. **There is no loading state for the directory, ever.** |
| **Loading** | None exists. Tiles that are neither bundled nor cached leave flat `#212121` — the map colour, not an error surface. |
| **Offline** | The offline chip appears (§9.1). Nothing else changes. Panning outside the bundled Kigali extent without the Rwanda pack shows flat `#212121` with pins still drawn in their true positions. |
| **No location permission** | The puck is absent; the locate button still renders and requests on tap. `stationsNear` uses the **viewport centre** as origin — never a hardcoded "device location". No distances are shown anywhere until a position exists. |
| **Signed out** | Identical. The whole read surface is anonymous (ADR-0003); the avatar takes the measured empty state — see D-04. |
| **Error** | No error state. A failed sync leaves the cached directory; a failed tile leaves `#212121`. |
| **Empty** | Not reachable — the bundled snapshot is never empty. |

**Strings:** `Let's find a charger` · `Offline` (app copy) ·
`© OpenStreetMap contributors` (licence text — **not** app copy, §11).

---

### D-02 · Map + station card — [ref-03]

**Purpose.** Answer, without leaving the map, the four questions a driver has
about a pin: what is it, can I charge there, how far, what does it cost.

**The card is a floating card, not an edge-anchored bottom sheet** — verdict
**M2**, measured in §0.3 row 2. Frame x 64 → 1141, y 1796 → 2317
(1078 × 522 px = 359.3 × 174.0 pt), **all four corners at r ≈ 16 px**, fill
`#121212`, no shadow, 64 px internal padding, **65 px of visible map between its
bottom edge and the CTA**. Drag handle **180 × 13 px** `#262626`, fully rounded,
centred, 26 px below the card's top.

**Layout — Regime 1, the normal case, drawn first**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ├──────────────────────────────────────────────────┤    │  crosshair (unchanged)
 │   ⬤                                                      │
 │              ◉        ◉●        ═══════╗                 │  lime route line, 12 px
 │                    ◉             (§7.1) ║                │
 │                        ◉════════════════╝                │
 │  ╭────────────────────────────────────────────────────╮  │  floating card, r16 all
 │  │                   ▭▭▭▭▭▭▭▭▭                        │  │  handle 180×13 #262626
 │  │  ┌────────┐  SP Remera                        ♡     │ │  title cap 36 Bold x483
 │  │  │ photo  │  4 bays · no confirmed status           │ │  subtitle cap 27 Regular
 │  │  │100×100 │  ╭───────────────╮                      │ │  heart #717171 [m·11]
 │  │  │  pt    │  │ 8 min · 2.9 km│                      │ │  chip = route preview
 │  │  └────────┘  ╰───────────────╯                      │ │  content-sized, D27
 │  │                                      600 RWF/kWh    │ │  rateShort, cap 27 Bold
 │  ╰────────────────────────────────────────────────────╯  │
 │            ← 65 px of map, then →                        │
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA unchanged from D-01
 │  └──────────────────────────────────┘   ╰──╯             │
 └──────────────────────────────────────────────────────────┘
```

**Measured slot map** (card frame x 64 → 1141, y 1796 → 2317; 64 px padding):

| Reference slot | Measured | EV Guide content |
| --- | --- | --- |
| Drag handle | **180 × 13 px** `#262626`, r 6.5, centred, 26 px below the top [m·11] | unchanged |
| Thumbnail | 300 × 300 px = 100 pt, radius 30 px, x 128 | `Photo[0]` |
| Title | cap 36 Bold, x 483, baseline 1921 | **`nameShort`** — `SP Remera` |
| Subtitle | cap 27 Regular, x 483, 19 px below title | **the availability clause** |
| Category chip | 254 × 76 px [m·11], x 480, r 31.5, lime 2.5 px border, **content-sized** [RAISE-D27] | **the route preview** (§7.2) |
| Price | cap 27 Bold, right-aligned to x 1075 | **`rateShort`** (§13.2) |
| Heart | ink 50 × 46 px, x 1025–1074, y 1881–1926, **`#717171`** [m·11] | `SavedStation` toggle |

**Behaviour** — verdict **M11**: v1 had no behaviour table on this screen at
all, so the single most-taken action in the app (card → detail) was never
written down.

| Element | Action |
| --- | --- |
| **The station card, anywhere but the heart** | **push D-03 Station detail** |
| Thumbnail | same as the card — push D-03. There is no photo viewer anywhere in the app (§8, *deliberately not screens*) |
| Heart | toggle `SavedStation`. Signed out → **S-01**, auto-resume the save |
| Route chip | **none — it is a label** (§12.3) |
| Drag handle / card drag | up → the list detent · down → dismiss to D-01 |
| Another pin | reselect; the card's content swaps in place, the card does not close |
| Map pan / zoom | the card stays, the route line stays |
| CTA `Let's find a charger` | expand to the list detent |
| Locate `➤` | recentre |
| Avatar | push D-04 |
| Attribution mark | push D-10 |
| A row in the list detent | **push D-03** |

**Why the title is `nameShort` and not `Kabisa – SP Remera`.** Ticket 19's
routed constraint is explicit: `nameShort` is *the place, not the operator*, and
the operator belongs in icon and marker. The CarPlay **card** composes
`Kabisa – SP Remera` because that card is the last thing many drivers see; the
phone card has a detail one tap away carrying a dedicated owner row with
`Owner.icon`. `nameShort ≤ 18` characters at cap 36 Bold, k = 0.80, is
≤ 518 px inside the 543 px column left of the heart — **it fits by construction,
for every station in the directory.** Declared as a per-surface difference
rather than left to be discovered.

**The subtitle and the variant ladder.** The content column is x 483 → 1077 =
**594 px**. At cap 27 Regular and the pessimistic k = 0.73 (§0.4) that is
**30 characters per line**; at the optimistic k = 0.667 it is 33. **The ladder is
run against 30**, so it never depends on the friendlier constant.

The availability clause runs the shared drop order
(docs/availability-display.md; `02-androidauto-design-v3.md` §3.4 — drop `ago`,
then the source word, then the `busy` clause, then plural nouns; **`free`,
`out of service` and `unknown` counts are never dropped**) until it fits **two
lines** at the measured 45 px pitch — a 60-character budget.

**[RAISE-D9] Two-line subtitle.** The reference's card subtitle is one line, and
part 1 §2.3 says *no line height but body's is measurable — do not invent them*.
The 45 px pitch is measured over ten consecutive lines at cap 27–28 and is a
function of size, not weight, so applying it to a two-line cap-27 Regular run is
a **derivation**; the card's measured 522 px height is then the one-line case and
a second line adds exactly 45 px. Needs a yes, because it makes the card
content-sized. Regime 3's worst string cannot fit one line at any rung of the
ladder — the alternative is breaking the ladder's law, which is worse.

**Every availability variant, drawn** — all [vocab], all `busy` per **R1**, all
qualified per **M10**:

| Regime | Data | Subtitle as emitted | chars |
| --- | --- | --- | --- |
| **1 — the normal case** | `n=4, u=4` | `4 bays · no confirmed status` | 28 ✓ one line |
| **2** | `n=4, f=2, o=2`, operator −14 min | `Operator, 14 min ago · 2 of 4 bays free` | 38 ✓ two lines |
| **3** | `n=4, f=1, o=1, x=1, u=1` | ladder, see below | 51 ✓ two lines |
| **Lensed, GB/T DC** | `n_T=2, f=1, u=1` | `14 min · 1 GB/T DC bay free · 1 unknown ·` / `2 other bays` | 53 ✓ |
| **Lensed, no compatible plug** | `n_T=0` | `No GB/T DC bay here · 4 bays · Type 2, CCS2` | 42 ✓ |

**The Regime 3 ladder, run** — v1 drew this variant at 74 characters over two
lines, i.e. 37 per line, above even the optimistic budget. Corrected:

| Rung | String | chars | fits 60? |
| --- | --- | --- | --- |
| 0 (full) | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 74 | no |
| 1 — drop `ago` | `Operator, 14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 70 | no |
| 2 — drop the source word | `14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 60 | exactly, zero margin |
| **3 — drop the `busy` clause** | `14 min · 1 bay free · 1 out of service · 1 unknown` | **51** | **yes** |

Rung 2 lands exactly on the budget with no margin, so the composer takes rung 3.
`free`, `out of service` and `unknown` all survive, as the law requires; `busy`
is the first droppable clause by the shared order, and the total is absent in
Regime 3, so dropping it creates no false arithmetic.

**Freshness leads the clause**, matching the car surfaces, and for the same
reason: a line that can truncate must truncate to something honest.
`2 of 4 bays free` surviving alone is a live claim; `Operator, 14 min ago`
surviving alone is merely less informative. Regime 1 emits **no freshness head**
— there is no state to date.

**The rate slot takes `rateShort`, never a Connector's rate** (§13.2, **R4**).
S1 has one confirmed rate, so it renders `600 RWF` Bold + `/kWh` Regular. Had
its GB/T guns been priced 600 and its Type 2 guns 400, this slot would read
`From 400 RWF/kWh` — **not** `600 RWF/kWh`, which is what v1's unqualified
"`600 RWF` Bold + `/kWh` Regular" would have produced: one plug's price
presented as the station's.

**The list detent.** Tapping `Let's find a charger` expands the same card to a
taller detent holding the nearby list: repeated station cards in the card's own
composition, separated by 1 px `#3E3E3E` dividers at the card's inner width
(x 128 → 1077, §5.1). **This is a detent, not a screen** — the drag handle
implies detents in the reference itself. Ordering is `stationsNear(origin, …)`
distance-first then availability. No search field: the reference contains no
search component, and a directory of tens of stations sorted by distance needs
none.

**[RAISE-D10] The list detent has two unmeasured properties.** (a) Its height —
recommendation: **~70% of screen height**, leaving the map and the crosshair
visible, since the reference's card always leaves the map visible. (b) What the
CTA does once the detent is open, since the reference shows no expanded state —
recommendation: **the CTA stays rendered and unchanged, and tapping it collapses
back to the card detent.** Both need a yes.

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Card content is instant (cached directory). An uncached `Photo` renders as a **`#3E3E3E` block at the thumbnail's exact geometry** — the reference's own measured empty state. No spinner, no shimmer, no broken-image glyph: none exists in the reference. |
| **Offline** | Offline chip on the map; the route chip degrades to `~2.4 km straight line`; no route line; photos that are not cached stay `#3E3E3E`. Everything else is identical, because everything else is cached. |
| **Error** | Route failure → the straight-line form. There is no other failure: nothing else on this card requires the network. |
| **Signed out** | Identical, except the heart. Tapping it opens **S-01** and auto-resumes the save. |
| **Saved** | The heart fills `#C7FC2F`. **[RAISE-D11]** — see below. |
| **Empty** | Not reachable. |

**[RAISE-D11] The heart's two states, re-based on the measured default.** v1
assumed a white outline heart and recommended filling it lime. The measured
default is **`#717171`** (§0.3 row 4), so the progression is *muted grey outline
→ accent fill*, which is better founded: the reference already de-emphasises the
unsaved heart, and the accent already means *yours* everywhere else in the
system. **Recommendation: `#717171` outline unsaved, `#C7FC2F` fill saved.**
Still a raise, because the reference shows only the unsaved state.

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
 │  │                indicator §5.7          ╰─────────╯  │ │  1.21:1 — [RAISE-D28]
 │  └────────────────────────────────────────────────────┘  │
 │  Kabisa – SP Remera                           ♡    ↗     │  cap 47 Bold + heart/share
 │  4 bays · GB/T DC · Type 2                               │  cap 27 Regular
 │  ⬤ Kabisa                                                │  owner icon ⌀76 + cap 32 Bold
 │                                                          │
 │  Availability                                            │  cap 32 Bold
 │  4 bays · no confirmed status                            │  cap 28 ExtraLight, 45 px
 │    ⌁  GB/T DC · 60 kW · 2 plugs                          │  settings-row §5.6
 │    ⌁  Type 2 · 22 kW · 2 plugs                           │  divider x 64→1141 §5.1
 │  ┌─────────────────────────────────────────────────────┐ │
 │  │        Notify me when a bay frees up                │ │  CTA geometry, §12.3
 │  └─────────────────────────────────────────────────────┘ │  46 pt, r 4.5, #393939
 │                                                          │
 │  Connectors                                              │  cap 32 Bold
 │  ┌──────────────────┐ ┌──────────────────┐               │  feature chips §5.5
 │  │ ⌁ 2 × GB/T DC 60 kW│ │ ⌁ 2 × Type 2 22 kW│            │  105 px tall, r 10 px
 │  └──────────────────┘ └──────────────────┘               │  #393939, cap 32 ExtraLight
 │  600 RWF/kWh · All 4 plugs · confirmed 12 days ago       │  Grammar R, §13.3
 │                                                          │
 │  Getting there                                           │  cap 32 Bold  [RAISE-D12]
 │  Inside the SP forecourt, entrance from KG 11 Ave.       │  cap 28 ExtraLight
 │  Chargers are behind the shop, on the left.              │  45 px line pitch
 ├──────────────────────────────────────────────────────────┤
 │  600 RWF/kWh              ┌────────────────────────┐     │  sticky bar §5.8
 │  = rateShort              │      Directions        │     │  opaque #121212
 └───────────────────────────└────────────────────────┘─────┘  513×131 px, r 14 px
```

**Slot map**

| Reference | Measured | EV Guide |
| --- | --- | --- |
| Close `×` | ⌀81 px `#393939`, 6 px white stroke, x 64, centre y 269.5 | dismiss |
| Overflow `⋯` | ⌀100 px, 3 white dots ⌀6 px, right x 64, **same centre y** | S-03 |
| Hero | 1076 × 620 px, radius 30 px | `Photo[i]`, paginated |
| Page indicator | active 96 × 16 px lime, inactive ⌀16 px `#3E3E3E`, gap 13 px, 34 px above hero bottom | `Photo` count |
| Hero badge | 249 × 71 px [m·11], radius ≈32 px, `#C7FC2F`, filled lightning + cap 27 Regular `#FFFFFF` | **peak power** — `60 kW`, per **R2**. Absent when no Connector carries `powerKw`. **[RAISE-D28]** |
| Title | cap 47 Bold | **`Station.name`** — `Kabisa – SP Remera` |
| Heart + share | ink 68 × 62 / 67 × 67 px, 31 px apart, both **`#FFFFFF`** [m·11] | save · share |
| Subtitle | cap 27 Regular, 20 px below title | `4 bays · GB/T DC · Type 2` |
| Owner row | avatar ⌀76 px + cap 32 Bold, 29 px gap, 39 px below subtitle | `Owner.icon` + `Owner.displayName` |
| Owner row trailing icon | message glyph | **dropped** — see below |
| `Description` | cap 31 Bold + cap 28 ExtraLight, 45 px pitch | **`Getting there`** — [RAISE-D12] |
| `Basics and features` | cap 32 Bold + feature chips | **`Connectors`** |
| Sticky bar | 285 px region, opaque `#121212`, ≈90 px padding | `rateShort` + `Directions` |

**Behaviour**

| Element | Action |
| --- | --- |
| `×` | dismiss, back to the caller (D-02, D-11 or D-12) |
| `⋯` | open **S-03** |
| Hero | swipe paginates `Photo[i]`. **No tap target** — there is no full-screen viewer |
| Page indicator | none — a mark |
| Hero badge | none — a label, and per **R2** never a data value a driver must read |
| Heart | toggle `SavedStation`; signed out → **S-01**, auto-resume |
| Share `↗` | platform share sheet with the station's universal link |
| Owner row | **none.** There is no Owner screen anywhere in the app and none is invented |
| Connector row | open **S-02** for that Connector. Not at the station → non-interactive, §12.1 |
| Bay-alert control | arm / disarm; gated → **S-01**, then OS permission, then auto-resume, §12.2 |
| Feature chips | none — labels |
| `Directions` | Google Maps deep link by `lat,lng` (ADR-0004). **Ungated, always** |
| Sticky rate | none — a label |

**The owner row's message icon is dropped and nothing replaces it.** EV Guide
has no driver↔operator channel, deliberately: there is no messaging entity
anywhere in the model and no ticket creates one. This is a named content
deviation; the row's geometry, avatar size and label treatment are unchanged.

**[RAISE-D12] `Description` has no field behind it.** `Station` carries `name`,
`nameShort`, `geo`, `vehicleClassTag`, `updatedAt`, `owner_id`, Photos and Bays
— **no prose field**. Options: (a) drop the block — loses a measured region of
the reference; (b) add a nullable authored `Station.description`, admin-entered
like everything else about a station, and title the block **`Getting there`**;
(c) synthesise text from structured fields, which the model forbids
(*availability strings are derived from structured fields, never prose*).
**Recommendation: (b).** A charge point inside a petrol forecourt is the normal
Rwandan case, and *where exactly, and how do I get in* is precisely what
coordinates cannot say. Routed to ticket 19 as a schema addition. When null, the
whole block is absent.

**[RAISE-D28] The hero badge measures 1.21:1 and the reference put text in it.**
Measured: `#FFFFFF` label on `#C7FC2F` fill = **1.21 : 1** [m·11] — against
WCAG 1.4.3's 4.5:1 for text, this is not a marginal failure, it is the worst
contrast in the system by a wide margin (`#121212` on the same fill measures
15.52:1). The reference itself is unreadable here; `Hybride` is legible only
because the reader already knows the word.

**R2 already removes the danger**: availability never enters this badge, and the
badge carries peak power. This file adds the invariant that makes that safe:

> **Nothing may appear in the hero badge that is not also rendered in `#FFFFFF`
> text elsewhere on the same screen.** `60 kW` appears in the `Connectors`
> feature chips (cap 32 ExtraLight `#FFFFFF` on `#393939` = 11.55:1), so the
> badge is redundant by construction and a driver who cannot read it loses
> nothing.

**Recommendation: reproduce at 1.21:1 under the 1:1 rule, with the redundancy
invariant as the guarantee.** The one-token alternative, if the founder prefers
legibility over fidelity, is the label in `color.onAccent` `#121212` — the value
the CTA already uses on the same fill. **Raised, not chosen.**

**The `⋯` overflow.** Two items: `Share station` and `Report availability` (the
same proximity-gated flow as the connector rows — §12.1). **[RAISE-D13]** nothing
in the domain models a *non-availability* correction channel for drivers (ticket
11 gives operators a rate **flag**; drivers get nothing). If the founder wants
"report a wrong rate / wrong location / permanently closed", that is a new entity
and a new ticket, not a menu item this file may add.

**Availability block content**, in full, per regime — sub-head cap 32 Bold, body
cap 28 ExtraLight at 45 px pitch, full 358.7 pt content width, **no ladder** (the
block has room for the longest string). All [vocab], all `busy` per **R1**:

| Regime | Body |
| --- | --- |
| **1 — drawn first** | `4 bays · no confirmed status` |
| 2 | `Operator, 14 min ago · 2 of 4 bays free` |
| 3 | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` |
| Lensed GB/T DC | `Operator, 14 min ago · 1 of 2 GB/T DC bays free · 2 other bays` |
| All broken | `All 4 bays out of service` |
| Single-bay site | `The bay is free` / `The bay is busy` / `The bay is out of service` |

Below it, **one settings-row per Connector type** (part 1 §5.6 geometry exactly:
176 px pitch, 1 px `#3E3E3E` divider **at x 64 → 1141** per §5.1, 24 pt icon at
2 pt stroke, label x 196 cap 32 Regular, no trailing affordance), so
per-Connector state is reachable:

```
   ⌁   GB/T DC · 60 kW · 2 plugs · 1 out of service
   ⌁   Type 2 · 22 kW · 2 plugs
```

**Rate line — Grammar R, quoted verbatim.** Verdict **m10**: v1 paraphrased it
and drifted (`all 4 plugs` for `All 5 plugs`, a bay-shaped `0 of 4 plugs` for
`0 of 5 plugs confirmed`). The source is `02-androidauto-design-v3.md` §3.5,
reproduced here exactly:

> | Condition | text 1 | text 2 |
> |---|---|---|
> | `c = 0` | `No confirmed rate` | `0 of 5 plugs confirmed` |
> | one distinct rate among the confirmed | `600 RWF/kWh` | `All 5 plugs · confirmed 12 days ago` **or** `3 of 5 plugs · 2 unknown · 12 days ago` |
> | two distinct rates | `600 RWF/kWh GB/T · 400 RWF/kWh Type 2` | as above |
> | ≥3 distinct rates | `From 400 RWF/kWh · 3 rates` | as above |
>
> Three deliberate choices. **`No confirmed rate`, not "no published rate"** —
> the first states EV Guide's knowledge, the second would assert a licensee is
> out of compliance with RURA Art. 27(2). **The denominator is plugs, not bays**
> — a dual-gun bay can carry two different rates, so a bay denominator is a
> category error. **`From` asserts a floor over the confirmed set only**, and the
> unknown remainder is stated in the same breath.
>
> An optional `sessionFeeRwf` appends to text 1 when present and the string
> still fits: `600 RWF/kWh + 500 RWF session`.

Grammar R is a **two-slot** grammar (Android's pane row has a title and a
subtitle). The phone's detail has one line, so **the phone's rendering rule is
`text 1 · text 2`**, joined by the system's own `·` separator. Stated once here;
not a new grammar. On fixture S1, `m = 4`, `c = 4`, one rate:

```
600 RWF/kWh · All 4 plugs · confirmed 12 days ago
```

Grammar R's own two-rate example carries a bare `GB/T`, which is not in the
closed projection — see **[RAISE-D32]**, §13.4. This file does not close it by
adopting it.

**Sticky bar.** Left slot at cap 36 Bold: **`rateShort`** (§13.2), *not*
Grammar R — the long ladder stays in the block above (**R4**). `Directions` CTA
right, 513 × 131 px lime core [m·11], radius ≈14 px, label cap 32 Medium
`#121212`. Bar padding ≈90 px (part 1 [RAISE-6] — the bar ignores the content
margin and that is reproduced).

The tightest string in the system, checked at Bold k = 0.80 (§0.4):

| Left-slot string | chars | ink [d] | starts | ends | CTA starts at x 603 [m·11] |
| --- | --- | --- | --- | --- | --- |
| `600 RWF/kWh` | 11 | 317 px | 90 | 407 | 196 px clear |
| `From 400 RWF/kWh` | 16 | 461 px | 90 | 551 | 52 px clear |
| **`No confirmed rate`** | 17 | **490 px** | 90 | **580** | **23 px clear** — the tightest string in the system |
| reference `135 000 RWF/day` | 15 | 433 px [m·11] | 93 | 525 | 78 px clear |

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Everything but photos is cached and instant. Uncached hero → `#3E3E3E` block at the hero's exact 1076 × 620 px, radius 30 px. |
| **Offline** | Offline chip under the top button row, right-aligned. `Directions` still works — the hand-off is a deep link and Google Maps owns its own offline story (ADR-0004). |
| **Error** | No error surface. There is no request this screen makes that can fail visibly. |
| **Signed out** | Identical, except the heart and the bay-alert control, which open S-01 and auto-resume. `Directions` is **ungated** (ADR-0003 as amended). |
| **Empty** | Not reachable: a Station is publishable only with ≥1 Bay and ≥1 Photo. |
| **Not at the station** | The connector rows are non-interactive and the block carries one line: `Report status when you're at the station` — §12.1. |

---

### D-04 · Profile — [ref-02]

**Purpose.** The driver's account, their three quick actions, the operator
cross-app affordance, and the settings list.

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
 │   🔔  Notifications                                        │  ← last row in the capture
 │  ────────────────────────────────────────────────────     │
 │   ⌁  My plug                                              │  [ext] — below the cut-off
 │  ────────────────────────────────────────────────────     │
 │   ⓘ  About EV Guide                                       │  [ext] — below the cut-off
 └──────────────────────────────────────────────────────────┘
```

**Settings list, both auth states**

| Row | Signed in | Signed out | Destination | Ref? |
| --- | --- | --- | --- | --- |
| `Personal Information` | ✓ | — | D-05 | [ref-02] |
| `Login & Security` | ✓ | — | D-06 | [ref-02] |
| `Sign in` | — | ✓ | S-01 | [ext] |
| `Offline & map data` | ✓ | ✓ | D-07 | [ref-02] (relabelled, §5) |
| `Notifications` | ✓ | ✓ | D-08 | [ref-02] |
| `My plug` | ✓ | ✓ | D-09 | [ext] |
| `About EV Guide` | ✓ | ✓ | D-10 | [ext] |

The last two are **below the reference's cut-off** and are `[ext]` rows built
from the measured row component with no change to pitch, divider, icon grid,
stroke or label treatment (§5, corrected row-count claim).

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-01 / D-02 |
| Avatar | **none.** Editing the photo lives on D-05; the reference gives the avatar no affordance and none is added |
| `Show and edit my profile` link | push **D-05** |
| `Saved` quick action | push **D-11**; signed out → S-01, auto-resume |
| `My plug` quick action | push **D-09** — always, no gate |
| `Alerts` quick action | push **D-12**; signed out → S-01, auto-resume |
| Hosting card | universal link `https://evguide.rw/operator` (§6.2), every state |
| Any settings row | push its destination, per the table above |

**States**

| State | Rendering |
| --- | --- |
| **Signed in** | As drawn. `Shima Serein` cap 55 Bold; lime link `Show and edit my profile`. |
| **Signed out** | Avatar renders its measured empty state — ⌀316 px, `#3E3E3E` fill, 3 px `#C7FC2F` ring — **unchanged**, because that is exactly what the reference captured. Display line: `Not signed in`. Lime link: `Sign in to save and report`. Quick actions all present; `Saved` and `Alerts` open S-01 and auto-resume; `My plug` opens directly. Hosting card absent. |
| **No membership** | Hosting card absent; the labels→`Settings` gap is 164 px [RAISE-D7]. |
| **Loading** | None — every field is local. |
| **Offline** | Offline chip under the back button, right-aligned. Rows that need the network on tap (`Personal Information`, `Login & Security`) still open and show their cached values. |
| **Error** | None on this screen. |

---

### D-05 · Personal Information — [ext]

**Assembled from:** back button (part 1 §5.2, ⌀91 px) · section heading
(cap 37 Bold, x 40) · settings rows (§5.6, divider x 38 → 1167) · profile
avatar (§5.9).

**Purpose.** View and edit the account's name, email and photo.

**Layout:** back button · heading `Personal Information` · avatar ⌀316 centred
with its lime ring · rows `Name` / `Email` / `Photo`.

**Behaviour:** back `←` pops to D-04 · each row opens its edit affordance in
place, using the [RAISE-D21] text input · `Photo` opens the platform picker.

**[RAISE-D14] Settings rows carry no value slot.** Part 1 §5.6 is explicit: *no
chevron, no trailing affordance*. A settings screen that shows `Name` without
showing the name is useless. Recommendation: **compose the row with the card's
right-aligned price treatment** — value at cap 27 Bold `#FFFFFF`, right edge at
the divider's right end (x 1167). Both halves are measured components; the
composition is not. Used by D-05, D-06, D-07, D-10 and D-12. Needs a yes.

**States.** Signed-in only (unreachable otherwise). Offline: values render from
cache, edits queue or are refused with `You're offline. Try again when you're
back on.`. No loading state — the account is local. Error: the body line is
replaced in place; there is **no error colour in the token set**, so every error
string is `#FFFFFF` body copy where it belongs.

**Strings:** `Personal Information` · `Name` · `Email` · `Photo` ·
`You're offline. Try again when you're back on.`

---

### D-06 · Login & Security — [ext]

**Assembled from:** back button · heading · settings rows with the [RAISE-D14]
value slot.

**Purpose.** Show which providers are connected, sign out, delete the account.

**Rows:** `Apple` / `Connected` · `Google` / `Not connected` · `Email` /
`shima@…` · `Sign out` · `Delete account`.

**Behaviour:** back `←` pops to D-04 · a provider row starts or unlinks that
provider · `Sign out` signs out locally and pops to D-04 · `Delete account`
opens the platform confirmation, then deletes.

`Delete account` is not optional: App Store Guideline 5.1.1(v) requires in-app
account deletion for any app offering account creation. Deleting removes
`SavedStation`, `Watch` and profile rows; **`Report` rows are append-only and are
retained with the reporter detached** — availability the driver contributed does
not vanish and re-break the map. Say so on the confirmation.

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
| `Delete downloaded maps` | `76 MB` | delete, with a platform confirmation |

**Behaviour:** back `←` pops to D-04; each row acts per the table; no row
navigates anywhere.

**`All of Rwanda` row states**

| State | Value slot |
| --- | --- |
| Not downloaded | `76 MB` |
| Downloading | `42%` |
| Downloaded | `Downloaded · 76 MB` |
| Update available | `Update · 76 MB` |
| Offline, not downloaded | `76 MB · needs a connection` (row non-interactive) |
| Failed | `Download didn't finish. Tap to try again.` |

**[RAISE-D16] There is no progress component.** No bar, no ring, no spinner
anywhere in the reference; the hero's active page indicator (96 × 16 px lime) is
a pagination mark, not a meter, and pressing it into service would be inventing.
Recommendation: **a text percentage in the value slot and nothing else** — the
minimum possible invention for a 76 MB download.

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

**Assembled from:** back button · heading · settings rows + the [RAISE-D17]
trailing check.

**Purpose.** Control bay alerts. This is the only notification EV Guide sends —
ticket 30 permits exactly one event type, product-wide.

**Rows:** `Bay alerts` (toggle) · `System settings` (opens the OS sheet when
permission is denied).

**Behaviour:** back `←` pops to D-04 · `Bay alerts` toggles, arming/disarming
nothing by itself — it is the master switch · `System settings` leaves the app.

**[RAISE-D17] The reference contains no switch, checkbox, radio or toggle of any
kind.** A global gap, not a D-08 gap: it also blocks D-09. Options: (a) the
platform's native switch — conventional, and a visible foreign object in a
system with no other platform control; (b) **a trailing `#C7FC2F` check at the
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
the card and the detail answer *free for me* rather than *free* — ADR-0002 calls
the vehicle profile load-bearing.

**Rows** (the closed type-word projection, docs/availability-display.md §2.4):
`Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug`. Multi-select; the
trailing lime check marks each selection.

**Behaviour:** back `←` pops to D-04 · each row toggles its own type · selection
takes effect immediately on every screen; there is no Save.

**Gating. Ungated.** Setting your own connector type is a device-local
preference and a reading aid, and the read surface is anonymous (ADR-0003 as
amended). Only **syncing it across devices** needs an account. The domain model
flags this for founder ratification and this file restates the flag rather than
settling it: **[RAISE-D18]** — gating it would make the unlensed aggregate the
normal case for every driver and every store reviewer.

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

**Behaviour:** back `←` pops to its caller — **D-04 or the map attribution mark
on D-01 / D-02**, which is this screen's second entry point · `Open source
licences`, `Privacy` and `Terms` push their own text · `Version` and `Map data`
are non-interactive.

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
cards** (D-02's card composition) · 1 px `#3E3E3E` dividers at the list's own
container width (§5.1).

**Purpose.** The driver's `SavedStation` list.

**Layout.** Back button · `Saved` heading · one card per saved station, each
carrying thumbnail 100 pt / `nameShort` cap 36 Bold / availability clause cap 27
Regular / `rateShort` right-aligned cap 27 Bold / heart `#717171`. **No route
chip** — the list is not tied to a position and computing a route per row would
be a burst of Valhalla calls for a screen the driver is browsing, not acting on.

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-04 |
| A card | **push D-03** |
| A card's heart | un-save, in place; the row leaves the list |

**States**

| State | Rendering |
| --- | --- |
| **Populated** | As above, ordered by distance when a position exists, else by save time. |
| **Empty** | Heading + one line: `Stations you save appear here. Tap the heart on any station.` No illustration and no button — the reference has neither, anywhere. |
| **Offline** | Fully functional; every field is cached. Uncached thumbnails → `#3E3E3E`. |
| **Signed out** | Unreachable — the quick action opens S-01 first. |
| **Loading / error** | None. |

**Strings:** `Saved` ·
`Stations you save appear here. Tap the heart on any station.`

---

### D-12 · Alerts — [ext] · **car-effort package**

**Assembled from:** back button · heading · settings rows + value slot.

**Purpose.** The armed `Watch` list — max 3, one-shot, auto-expiring 2 h.

**Rows:** `SP Remera` / value `until 15:12`.

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-04 |
| A row's label | **push D-03** for that station |
| A row's value slot | disarm that watch |

**States**

| State | Rendering |
| --- | --- |
| Armed | one row per watch, value `until 15:12` |
| Empty | `No alerts set.` + `Open a station and tap "Notify me when a bay frees up". One alert, next 2 hours.` |
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

**Assembled from:** the **floating card** (§0.3 row 2: 1078 px wide at x 64, all
four corners r 16 px, `#121212`, 64 px padding, drag handle **180 × 13 px**
`#262626` 26 px below the top) · primary CTA geometry (138 px tall, r 13.5 px) ·
hosting-card fill (`#393939`) for the secondary buttons · body copy.

**Purpose.** ADR-0003 as amended (ticket 23): the gate fires on **save and
report**, never on directions. It overlays the screen the driver is on and
**auto-resumes** the action, so the driver never loses their station.

```
 ╭─────────────────────────────────────────────────────╮  r 16 px, all four
 │                   ▭▭▭▭▭▭▭▭▭                         │  handle 180×13
 │  Sign in to save stations                           │  cap 36 Bold
 │  Reading EV Guide never needs an account.           │  cap 28 ExtraLight
 │                                                      │
 │  ┌────────────────────────────────────────────────┐ │  Apple's own button
 │  │            Sign in with Apple                  │ │  [RAISE-D20]
 │  └────────────────────────────────────────────────┘ │  950 px × 138 px
 │  ┌────────────────────────────────────────────────┐ │  #393939, 138 px, r 13.5
 │  │            Continue with Google                │ │  cap 37 Medium #FFFFFF
 │  └────────────────────────────────────────────────┘ │
 │  ┌────────────────────────────────────────────────┐ │
 │  │            Continue with email                 │ │
 │  └────────────────────────────────────────────────┘ │
 ╰─────────────────────────────────────────────────────╯  bottom edge 103 px
                                                          above the screen bottom
```

**[RAISE-D31] The button width — the 899 px number was the wrong one.** Verdict
**M6**: v1 stacked three buttons at "899 px", which is the *residual* width of a
CTA sharing its row with the locate button (§0.3 row 5), not a component
property. **There is no full-width button anywhere in the reference.**

> The correct width is the **card's own inner box**: card x 64 → 1141 less
> 64 px padding each side = **x 128 → 1077 = 950 px = 316.7 pt.** That is a
> layout consequence of two measured values (the card frame and
> `space.sheetPadding`), not an invented button size. Height 138 px and radius
> 13.5 px are measured and unchanged.

Raised because the reference never stacks buttons, so the *stack* — three
buttons at the card's inner width with a gap between them — has no measured
precedent. **Recommendation: 950 px wide, `space.chipGap` 27 px between**, the
only measured vertical gap between sibling controls in the system.

**[RAISE-D34] The card's bottom offset when nothing sits below it.** On `03` the
card's bottom edge is 65 px above the CTA, which is itself 103 px above the
screen bottom. S-01 and S-02 have no CTA beneath them, so that 65 px measures
nothing. **Recommendation: 103 px = 34.3 pt above the screen bottom** — the
measured resting height of the lowest floating element in the system.

**Title is trigger-specific**, because a sheet that names the act it will resume
is a sheet the driver can decide about: `Sign in to save stations` ·
`Sign in to report status` · `Sign in to set an alert`.

**Only one button may be lime.** The accent budget is measured at ~3.9% of the
map screens and the reference spends it on pins plus **one** CTA. Three lime
buttons would be the largest accent deviation in the design. So: the platform's
native provider takes the accent slot; the other two use the hosting card's
`#393939` fill at the CTA's measured height and radius.

**[RAISE-D20] Sign in with Apple cannot be reproduced 1:1.** Apple's guidelines
fix that button's appearance — black / white / white-outline, its own logo
lockup and type — and it cannot be restyled to `#C7FC2F` with a `#121212` label.
It is also **compelled**: Guideline 4.8 requires it once Google sign-in is
offered on iOS (ADR-0003). Options: (a) ship Apple's native button, setting only
its `cornerRadius` to the measured 13.5 px — the one property the API exposes;
(b) draw a custom button, a common rejection cause. **Recommendation: (a).** This
is the second provably-impossible element in the driver app, after the `Google`
wordmark (§11).

**Behaviour**

| Element | Action |
| --- | --- |
| Drag handle / drag down | dismiss; the pending action is dropped, silently |
| Tap outside the card | dismiss, same |
| Any provider button | start that flow; on success dismiss and **fire the original action without a second tap** |

**States**

| State | Rendering |
| --- | --- |
| Idle | as drawn |
| In flight | **no spinner** (none exists). The buttons become non-interactive; nothing else changes. |
| Success | card dismisses; the original action fires — heart fills, or S-02 opens |
| Cancelled | card dismisses; nothing is lost; no message |
| Failed | body line replaced in place: `Sign-in didn't finish. Try again.` — `#FFFFFF` body copy, because **the token set has no error colour** |
| Offline | the card still opens; body line reads `You're offline. Sign-in needs a connection.`; buttons non-interactive |
| Email path | the body becomes an email field + `Send me a link`, then `Check your email. The link signs you in.` |

**[RAISE-D21] There is no text input anywhere in the reference.** No field, no
caret, no placeholder, no keyboard-adjacent chrome. The email path and D-05's
edits both need one. Recommendation: build it from the measured feature-chip
surface (`#393939`, radius 10 px, height 105 px) with a cap-32 Regular `#FFFFFF`
value — the closest measured container — and name it as an addition to
`packages/ui`.

**Strings:** `Sign in to save stations` · `Sign in to report status` ·
`Sign in to set an alert` · `Reading EV Guide never needs an account.` ·
`Sign in with Apple` · `Continue with Google` · `Continue with email` ·
`Send me a link` · `Check your email. The link signs you in.` ·
`Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.`

---

### S-02 · Report sheet — [ext]

**Assembled from:** the floating card (§0.3 row 2, handle 180 × 13 px) ·
**primary CTA geometry for the three controls** (§12.3, *not* chips) · body copy.

**Purpose.** File a `Report` — a claim about one **Connector's** availability.
Proximity-gated on the captured location, account-required, offline-queueing.

```
 ╭─────────────────────────────────────────────────────╮  r 16 px, all four
 │                   ▭▭▭▭▭▭▭▭▭                         │  handle 180×13 #262626
 │  GB/T DC · 60 kW                                    │  cap 36 Bold
 │  What's happening at this plug?                     │  cap 28 ExtraLight
 │                                                      │
 │  ┌────────────────────────────────────────────────┐ │  950 px × 138 px
 │  │                  Free                          │ │  #393939 + #FFFFFF
 │  └────────────────────────────────────────────────┘ │  cap 32 Medium
 │  ┌────────────────────────────────────────────────┐ │  27 px gap
 │  │                  Busy                          │ │
 │  └────────────────────────────────────────────────┘ │
 │  ┌────────────────────────────────────────────────┐ │
 │  │             Out of service                     │ │
 │  └────────────────────────────────────────────────┘ │
 ╰─────────────────────────────────────────────────────╯
```

**Why the controls stack instead of going three-up** — the one place this file
diverges from `12-operator-admin-screens.md` §4.3, stated rather than
discovered. The component is identical; the **container width** differs:

| Surface | Container | Three-up button width [d] | `Out of service` at cap 32 Medium, k = 0.65 | Verdict |
| --- | --- | --- | --- | --- |
| Operator write surface (file 12 §4.3) | page content column, 1078 px | (1078 − 54) / 3 = **341 px** | 291 px ink | fits, 25 px side clearance |
| **S-02** | **card inner box, 950 px** | (950 − 54) / 3 = **299 px** | 291 px ink | **fails — 4 px side clearance** |

So the driver's sheet stacks, at the card's inner width (950 px), 27 px apart.
One component, one reason, arithmetic shown. *(Routed to file 12: at the
conservative constant its own three-up leaves 25 px of side padding, which is
tight; that is file 12's call, not this file's.)*

**One tap commits.** The reference contains **no selected/unselected control
pair**, so there is no way to show a pending choice without inventing a state.
Tapping a control files the report and dismisses the card. This suits the actual
user — a driver standing at a charge point, one-handed — and mis-taps are cheap:
reports are append-only and most-recent-wins, so the correction is another tap.
**[RAISE-D22]** named, because it is a consequence of a missing state rather than
a UX preference. It is *also* why no accent fill appears here: file 12 spends the
accent on **selected**, and S-02 has no selected state to render.

**The three labels reuse the closed state words exactly** — `free`, **`busy`**
(R1), `out of service` — so the report sheet introduces **zero new state
vocabulary**. Title-cased because each begins its own string
(`01-carplay-design-v3.md` §2.x capitalisation rule). **[RAISE-D23]** the closed
vocabulary in `packages/domain` currently covers state words, capacity clauses,
watch strings and notification bodies; **report action labels are not listed**
and must be added there rather than authored in the app.

**States**

| State | Rendering |
| --- | --- |
| **Signed out** | The card does not open. S-01 opens instead and auto-resumes into this one. |
| **Not at the station** | The card does not open. The connector rows on D-03 are non-interactive and the availability block carries `Report status when you're at the station`. |
| **Offline** | Files normally. `capturedAt` and `capturedLocation` are recorded at tap time and queued (ADR-0007). **The confirmation is the report's own effect**: the card dismisses and the connector row re-renders with the new state immediately, because the derivation runs on device over cached reports including this one. No toast, no snackbar — the reference has neither. |
| **Queued report expired** | Dropped client-side past its 2 h decay window; the row simply re-derives. Nothing is shown, because nothing is true. |
| **Loading / error** | None. A report is a local write. |

**Strings:** `GB/T DC · 60 kW` [vocab] · `What's happening at this plug?` ·
`Free` · `Busy` · `Out of service` [vocab] ·
`Report status when you're at the station`

---

### S-03 · Overflow menu — [ext, from `04`'s `⋯`]

Two items: `Share station` · `Report availability`. The platform's own action
sheet; the reference gives no menu component and none is invented.

**Behaviour:** `Share station` → the platform share sheet · `Report
availability` → a connector picker first when the station carries more than one
type, then **S-02**. See [RAISE-D13] for what is deliberately absent from it.

---

### Deliberately **not** screens

| Not built | Why |
| --- | --- |
| **Route / navigation screen** | ADR-0004 forbids inventing one; the preview lives in D-02 (§7). |
| **Search screen** | The reference has no search component; a directory of tens of stations sorted by distance needs none. Recorded as an accepted reduction, not an oversight. |
| **Full-screen photo viewer** | The hero carousel is the whole photo surface. No ticket asks for more, and a viewer would be the only full-bleed modal in the app. |
| **Owner screen** | The owner row is identity, not navigation. Nothing in the model has an Owner-scoped read for drivers. |
| **Onboarding** | No reference, no ticket. Ticket 28 fixes what the *listing and onboarding claim* (`real-time` never appears anywhere) but does not commission screens. **[RAISE-D24]** — if onboarding ships, it is a new design pass, and its copy is already constrained. |
| **Filters** | Nothing in the model is a filter dimension on the phone; the plug lens (D-09) is a reading aid, not a filter, and it never hides a station. |
| **Operator anything** | Different app (ADR-0006). |

---

## 9. The offline surfaces

### 9.1 The quiet offline indicator

**It is a feature chip** (part 1 §5.5, the `04` variant): height 105 px =
35.0 pt, radius 10 px = 3.3 pt, fill `#393939`, **no border**, a 2 pt stroke icon
on the 24 pt grid, 30 px left padding, 18 px icon→label, 26 px right padding,
label cap 32 **ExtraLight** `#FFFFFF`, width fits content.

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
the *data* — §13.1's law: no string may claim report history, and `Offline`
describes the device.

**It is a label, not a control** (§12.3), and it is explicitly not the crosshair
rule (§3).

### 9.2 The straight-line label

§7.3. `~2.4 km straight line`, in the card's chip slot, with the same number the
CarPlay surface ships (§0.5). The phone shows **unmarked** driving distance when
online, which is what makes the marker meaningful (ADR-0007's amendment).

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
| Motion | **none, anywhere** — part 1 §7 found no shadow, blur, gradient or motion in the whole reference, and no shimmer or skeleton animation is introduced |

---

## 10. The inline auth sheet — summary of the gate

| Action | Gate | On tap when signed out |
| --- | --- | --- |
| Browse map, open a station, read rate / connectors / bays / availability | **none** | — |
| **Directions** | **none** (ADR-0003 amended, ticket 23) | fires |
| Save (heart) | account | S-01 → auto-resume the save |
| Report availability | account | S-01 → auto-resume into S-02 |
| Arm a bay alert | account + notification permission | S-01 → permission → auto-resume the arm |
| Set `My plug` | **none** (device-local) | opens directly |
| Sync `My plug` across devices | account | — |

The card overlays the screen the driver is on and never navigates. On success it
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

**A second Google-provenance element sits on the same screens:** the location
puck. Sampled at `x 583–642, y 1291–1331` on `01`, its fill is **`#4285F4`** —
Google's brand blue, drawn by the Google Maps SDK's own location UI. It is not in
the token set, it is not EV Guide's to use, and under MapLibre the puck is ours
to draw. **[RAISE-D25]** — it needs either a measured reproduction (which
reproduces a Google brand colour) or a token decision. Recommendation: draw the
puck at the measured geometry in `#FFFFFF` with a `#C7FC2F` core, which uses only
existing tokens; flagged because it changes a visible reference element.

### Options for the wordmark slot, and the recommendation

| # | Option | Cost |
| --- | --- | --- |
| **a** | **Replace the wordmark with the required OSM attribution in the same slot** — same position (x ≈ 64–73, above the CTA), the reference's own type (cap 27 Regular `#FFFFFF`), reading `© OpenStreetMap contributors`, tapping through to D-10 | The *word* differs and there is no logo lockup. The slot, its position, its treatment and its role all survive. |
| b | Drop the slot and put attribution only in D-10 | Empties a measured region of the reference, and OSMF's guidance expects the credit in the corner of a browsable map, permitting a reduced form only where screen space is genuinely limited — not obviously true of a full-bleed map. |
| c | Use Google Maps and keep the pixel exactly | Contradicts ADR-0007 (offline tiles are required and Google's ToS §3.2.3(a) forbids caching), contradicts ticket 26's rule, and runs into Google's ToS §3.2.3(d)(iii) barring use "in a listings or directory service" — EV Guide's own one-line description. Named only because it is the sole path that reproduces the reference. |

**Recommendation: (a).** Attribution is a licence obligation rather than a design
choice, so the slot must carry *something*; the reference's own bottom-left mark
slot is exactly where it belongs, and using the reference's own type treatment
keeps the deviation to the smallest possible unit — one word replaced by a credit
that is legally required.

**Record it as a knowing, founder-approved deviation.** Two further consequences
travel with it: the neighbourhood labels **Rebero** and **Remera**, visible in the
reference, **do not exist in OSM as places** and must be added upstream before the
basemap can reproduce the reference's own label set.

---

## 12. The report flow and the bay-watch affordance

### 12.1 Report — proximity-gated, per-Connector

Three entry points, all leading to S-02:

1. **A connector row in D-03's availability block**, tapped — the primary path,
   because it names the exact Connector the report is about.
2. **`Report availability` in S-03** — opens a connector picker first when the
   station has more than one type.
3. Nothing on D-01 or D-02. Reporting requires being at the station and knowing
   which plug; neither is true from the map.

**The gate.** Proximity is evaluated on the **captured** location (ADR-0007), so
a report filed at the charger and synced from the car park an hour later is still
valid. Not-at-the-station is a **non-interactive row plus a line of body copy**,
never a hidden control — the same discipline ticket 30 forced on the watch
affordance, for the same reason: a control that disappears teaches the driver
nothing.

**Anti-abuse is the gate itself.** ADR-0002: proximity gating *doubles as the
primary anti-abuse measure. No reputation system in v1.* Nothing in this design
adds a second mechanism.

### 12.2 Bay watch — arm and disarm

**Component: primary CTA geometry** (§12.3), 138 px tall, radius 13.5 px,
`#393939` fill, cap 32 Medium `#FFFFFF` label, content width, placed directly
under D-03's availability block at the content margin.

| Condition | Slot renders | Tap |
| --- | --- | --- |
| Can arm, not armed | **control**: `Notify me when a bay frees up` | arm |
| Armed | **control**: `Watching · until 15:12` | disarm |
| Signed out | **control**: `Notify me when a bay frees up` | S-01 → auto-resume |
| No notification permission | **control**: `Notify me when a bay frees up` | OS permission → auto-resume |
| Offline | **control**: `Notify me when a bay frees up` | queues; dropped past `armedAt + 2h` |
| Already free | **body line**, cap 28 ExtraLight: `A bay is free now` | — |
| At the ceiling | **body line**: `3 alerts set. That's the most at once.` | — |

The slot **always says something**; nothing disappears. Where the action is
impossible, the reason replaces the control in place — which is exactly ticket
30's amendment (*"a refusal with a reason in the row's text, never a disappearing
control"*) rather than a departure from it. A control that is permanently
untappable is a lie about a tap target; a sentence is not.

Fires **only** on a report-driven transition into `Free`. Decay never fires it —
ceasing to know is not an event. One-shot; expires silently after 2 h.

**Ships with the car effort's package** (tickets 23 / 30). Specified here so the
detail screen's composition is settled once.

### 12.3 No chip in the driver app is a tap target — [resolves M7]

v1 made the category chip a control twice: once for arm/disarm, once for the
three report actions. `12-operator-admin-screens.md` §4.3 had already rejected
exactly that, with reasons this file accepts in full rather than re-arguing:

> *the feature chip is **35 pt** tall and the category chip **25.7 pt**, and
> neither is interactive in the reference — they are labels. Both are under any
> tap-target floor. Using CTA geometry keeps the target at 46 pt and introduces
> no value that was not measured.*

**One answer, adopted product-wide:**

| Rule | Consequence in this file |
| --- | --- |
| **Chips are labels.** Both variants, both apps. | The route-preview chip (§7.2), the connector feature chips (D-03), and the offline chip (§9.1) are all non-interactive, and every behaviour table above says so. |
| **Interactive controls take primary-CTA geometry**: 138 px tall (46 pt), radius 13.5 px, `#393939` + `#FFFFFF` label unselected, `#C7FC2F` + `#121212` Medium label selected. | S-02's three report controls (§8, S-02) and D-03's bay-watch control (§12.2). |
| **Accent means *selected*.** | S-02 has no selected state (one tap commits), so nothing there is lime — which is also why the accent budget survives. |
| Layout may differ where the **container width** differs, with the arithmetic shown. | S-02 stacks where file 12 goes three-up (§8, S-02). |

The one thing this file adds to file 12's ruling is the **fallback for an
impossible action**: a body line, not a dead button (§12.2).

---

## 13. Vocabulary, strings and the closed sets

### 13.1 The forbidden list — the single place

**Canonical location: `docs/availability-display.md` §2.2, law 8.** Every other
document — files 10, 11 and 12 — **cites this section and never restates the
list.** Routed to ticket 18 for the edit; quoted once here so this file is
readable, and marked as routed, not authored:

| Forbidden | Why | Permitted form |
| --- | --- | --- |
| `unreported` · `not reported` · `no recent report` — **any string asserting report history** | The offline override yields `Unknown` from a thirty-second-old report, which makes every such string false | **`no confirmed status`** |
| `no published rate` | Asserts a licensee is out of compliance with RURA Art. 27(2) | **`No confirmed rate`** |
| **`in use`** (R1) | Two words for one state across two apps; `busy` is the word law 3 quantifies with | **`busy`** |
| `real-time` | Ticket 28: never in the listing, onboarding, or UI, anywhere | — (the claim is not made) |

**Three corrections owed to `docs/availability-display.md` itself**, routed with
the list:

1. §2.1's Regime 3 example reads `1 free · 1 in use · 1 out of service ·
   1 unreported` — **two forbidden words in one example**, in the document that
   forbids them. Corrected form: `1 free · 1 busy · 1 out of service ·
   1 unknown`.
2. Law 8's own permitted form reads `No confirmed bay status`; **R3** fixes the
   product on `no confirmed status`. Align law 8's wording.
3. Grammar R's two-rate example carries a bare `GB/T` — see §13.4.

### 13.2 `rateShort` — the R4 short projection

Defined **once**, in `packages/domain`, and consumed by every slot too small for
Grammar R. It returns **structure, not a formatted string** (domain-model
amendment 8); the closed vocabulary supplies the words.

```
rateShort(station) →
  { kind: 'single', rwfPerKwh }        -- exactly one distinct confirmed rate
  { kind: 'from',   floorRwfPerKwh }   -- two or more distinct confirmed rates
  { kind: 'none'   }                   -- no confirmed, in-window rate on any plug
```

| kind | Rendered | Composition |
| --- | --- | --- |
| `single` | `600 RWF/kWh` | `600 RWF` **Bold** + `/kWh` Regular |
| `from` | `From 400 RWF/kWh` | `From 400 RWF` **Bold** + `/kWh` Regular |
| `none` | `No confirmed rate` | **[RAISE-D33]** |

**Where it is used:** the D-02 card's price slot · the D-02 list detent · D-11's
rows · D-03's **sticky bar**. **Where it is not used:** D-03's rate line under
the connector chips, which is the full Grammar R ladder and the only place the
long form appears (**R4**).

**Why this is a fatal-class fix, not a tidy-up** (verdict **F5**). Rate is a
**Connector** property. A card slot that renders `600 RWF/kWh` for a station
whose GB/T guns cost 600 and whose Type 2 guns cost 400 has asserted a
station-level rate that does not exist, and the driver plugs in at the wrong
price. `From 400 RWF/kWh` is the only honest short form, and `From` asserts a
floor over the **confirmed set only** — Grammar R's own rule, inherited whole.

**[RAISE-D33] The price slot's weight composition when there is no amount.** The
reference's composition is *amount-and-currency Bold + slash-unit Regular*.
`No confirmed rate` has neither an amount nor a unit, so the reference cannot say
which weight it takes. **Recommendation: Regular at the same cap height** — the
Bold run in the reference is the *number*, and there is no number. Needs a yes.

### 13.3 Grammar R stays on the detail

Quoted verbatim at D-03, with the phone's one-line join rule (`text 1 · text 2`)
stated there. Not restated here.

### 13.4 [RAISE-D32] Bare `GB/T` is not in the closed projection — routed, open

docs/availability-display.md §2.4 defines the type-word projection exactly:

```
IEC_62196_T2 → Type 2 · IEC_62196_T2_COMBO → CCS2 · GBT_AC → GB/T AC
GBT_DC → GB/T DC · OTHER / UNKNOWN → Other plug
```

**`GB/T` alone is not a member.** v1 of this file used it in the
no-compatible-plug variant (`No GB/T bay here …`), and Grammar R uses it in its
own two-rate example (`600 RWF/kWh GB/T · 400 RWF/kWh Type 2`). Two documents
have now reached for a word the closed set does not contain, which is what a
closed set exists to catch.

**This file uses the qualified forms everywhere** — `No GB/T DC bay here`,
`1 GB/T DC bay free`, `1 of 2 GB/T DC bays free`, `2 × GB/T DC 60 kW` — and does
**not** close the question by adoption. What is open:

- Is the collapsed form **legal at all**, given that GB/T AC and GB/T DC are
  physically different plugs a driver cannot substitute? Collapsing them in a
  string that tells a driver what is *free for them* would be the same class of
  error the lens exists to prevent.
- If it is legal in some contexts (e.g. Grammar R, where the word disambiguates
  two *rates* rather than two *plugs*), it must be a **named member of the closed
  set** with its own rule, not an ad-hoc contraction.
- What the no-compatible-plug clause says when the lens has **two or more**
  members — `No GB/T AC or GB/T DC bay here` is 30 characters of plug names in a
  30-character line.

**Routed to ticket 18** (which owns §2.4) and to `02-androidauto-design-v3.md`
§3.5 (which shipped the bare form). Not settled here, and not settled twice.

### 13.5 App copy, by screen

Strings marked [vocab] are **data in `packages/domain`** and may not be authored
in the app. Availability, capacity, freshness, rate and type words are all
[vocab], defined in docs/availability-display.md §2 and enumerated in
`02-androidauto-design-v3.md` §3.8; not restated here, because that table is the
source. **The phone adds no state vocabulary at all** — four runtimes, one
grammar.

**New [vocab] members this design requires** (routed to `packages/domain`):

| String | Why |
| --- | --- |
| `Free` · **`Busy`** · `Out of service` | report action labels — the closed set covers state words but not report actions [RAISE-D23] |
| `No confirmed rate` (short form) | `rateShort`'s `none` case, §13.2 |

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
| D-12 | `No alerts set.` · `Open a station and tap "Notify me when a bay frees up". One alert, next 2 hours.` |
| S-01 | `Sign in to save stations` · `Sign in to report status` · `Sign in to set an alert` · `Reading EV Guide never needs an account.` · `Sign in with Apple` · `Continue with Google` · `Continue with email` · `Send me a link` · `Check your email. The link signs you in.` · `Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.` |
| S-02 | `What's happening at this plug?` |

Forbidden words: **§13.1**, cited not restated.

---

## 14. What each screen owes the domain

| Screen | Projection consumed |
| --- | --- |
| D-01 | `stationsNear(origin, …)` → `geo` + `f = freeBaysOffering(T)` per station |
| D-02 card | **two-line** — `nameShort` / availability clause; plus **`rateShort`**, `Photo[0]`, route |
| D-02 list detent | repeated two-line + `rateShort` |
| D-03 | station detail by opaque stable id; **per-Connector state reachable** (amendment 8); `rateCoverage(station)` denominated in **plugs** (amendment 6); Grammar R; `rateShort` for the sticky bar |
| D-11 | two-line + `rateShort` over `SavedStation` |
| D-12 | `Watch` rows with `armedAt` |

Every one of them returns **structure, not formatted strings** (amendment 8) —
`(distanceMeters, nameShort)`, never `"~2.4 km · SP Remera"`. The phone formats
at the edge, exactly as Android must.

**One declared divergence from the car projections.** domain-model §Projections
says the two-line has no rate because *"rate has no room on a car row."* The
phone's card slot exists because the reference has one, and it is filled by
`rateShort` — a projection the car surfaces do not consume. Declared, not
discovered.

---

## 15. Answers to the verdict

Every finding from `13-design-verdict-v1.md`, answered. **Fixed** = the document
changed. **Rebutted** = the document did not change, with the reason.

### The five fatals

| # | Finding | Answer |
| --- | --- | --- |
| **F1** | Two words for `Occupied` | **Fixed by R1.** `busy` everywhere in this file: §2.2's pin diagram, D-02's variant table, D-03's regime table, S-02's control labels, §13.5's new-vocab table. `In use` appears nowhere. Added to the §13.1 forbidden list and routed to availability-display §2.1, whose own example carries it. |
| **F2** | Availability in the accent badge | **Fixed by R2**, which this file already agreed with. The badge carries peak power only (D-03 slot map). Additionally: the 1.21:1 measurement is now raised as [RAISE-D28] with a redundancy invariant, so nothing a driver must read sits there — see M12. |
| **F3** | `unreported` rendered / forbidden | **Fixed by R3.** The forbidden list lives in exactly one place — §13.1 — and every other reference cites it. `no confirmed status` is the only permitted form and is what every regime table emits. Law 8's own wording and §2.1's example are routed for correction. |
| **F4** | The sheet heart is `#717171`; "no grey tier" is false | **Fixed, and re-measured** — §0.3 row 4, 517 px of solid `#717171`, no white pixel in the ink box, 6.0 px stroke unchanged. The `04` heart and share glyphs *are* `#FFFFFF`, so the reference draws one icon in two colours: **[RAISE-D30]**. Per **R5** the no-grey claim narrows to **text**, where it is still true and still load-bearing; a `color.iconMuted` token is owed to `10-design-system-v2.md`. [RAISE-D11] is re-based on the measured default. **Dependency stated: `10-design-system-v2.md` did not exist when this file was written**; until it does, §0.3 is the citation. |
| **F5** | No short rate projection | **Fixed by R4**, §13.2. `rateShort` is defined once in `packages/domain`, returns structure not strings, and is consumed by the card, the list detent, D-11's rows and the sticky bar. Grammar R stays on the detail only, and is now quoted verbatim there. A per-Connector rate is never rendered as the station's. |

### The fourteen majors

| # | Finding | Answer |
| --- | --- | --- |
| **M1** | Drag handle is 180 × 13 px | **Fixed.** Re-measured (§0.3 row 1) and corrected in D-02, S-01 and S-02. Owed back to part 1. |
| **M2** | The `03` sheet is a floating card with rounded bottom corners | **Fixed.** Re-measured (§0.3 row 2): all four corners r ≈ 16 px, bottom edge y 2317, 65 px of map below it. Corrected in D-02 (including the list detent), S-01 and S-02, with [RAISE-D34] for the bottom offset when no CTA sits below. |
| **M3** | The one link in the system is underlined and no file records it | **Acknowledged, routed.** The link is `Show and edit my profile` (`02`, cap 27 Regular `#C7FC2F`). Underline is a **type property**, not a screen decision, so it belongs in `10-design-system-v2.md` §2/§8.2 beside the weight and colour, not here. This file names the one link and routes the property. |
| **M4** | The basemap's palette and label hierarchy are unmeasured | **Rebutted as out of scope, and routed.** The basemap is the map *provider's* style (ticket 06, MapLibre + a self-hosted OpenMapTiles-derived style), not a `packages/ui` component; it is the only new work in the verdict and it is a style-JSON deliverable. Routed to ticket 06 with the note that it governs ~85% of the front door's pixels and that two of the reference's own labels (Rebero, Remera) do not exist in OSM (§11). |
| **M5** | The route string does not fit the chip | **Fixed by re-solving.** §7.2 checks the fit against the **chip** (254 px measured, 86/30 padding measured) rather than the column, with a stated advance constant (§0.4). The placement survives **only** if the chip is content-sized, which the reference cannot prove from one instance — **[RAISE-D27]**, recommending content-sizing on the strength of the feature chip's measured two-width behaviour, and naming the impossibility that follows if the answer is no. |
| **M6** | There is no full-width CTA anywhere | **Fixed.** §0.3 row 5: the CTA is 897 px because the locate button takes the right end; the width is a residual and is never tokenised. S-01's stack is re-derived to the card's own inner box, **950 px** — **[RAISE-D31]**. |
| **M7** | Chips made interactive; file 12 rejected the same idea | **Fixed, one answer.** §12.3 adopts file 12 §4.3's ruling verbatim and applies it product-wide: chips are labels; controls take CTA geometry. S-02's controls and D-03's bay-watch control are rebuilt on it. The only divergence from file 12 is layout (stacked vs three-up), stated with the container arithmetic that forces it. |
| **M8–M9** | *(not enumerated in the verdict summary; if they carry findings, they are unanswered here and this file says so rather than pretending otherwise)* | **Open.** |
| **M10** | Bare `GB/T` is not in the closed projection | **Fixed and routed, not closed.** Every string in this file uses the qualified forms. **[RAISE-D32]** (§13.4) states the three open questions — legality, membership, multi-member lenses — and routes them to ticket 18 and to `02-androidauto-design-v3.md` §3.5, which shipped the bare form in Grammar R. |
| **M11** | D-02 has no behaviour table; screens have no entry points | **Fixed twice.** §8.0 is an exhaustive entry-point table for all fifteen surfaces. D-02 now has a behaviour table whose first row is *the station card pushes D-03*, and every other screen and sheet gained one. |
| **M12** | `#FFFFFF` on `#C7FC2F` is 1.21:1 | **Raised.** [RAISE-D28], with the contrast recomputed here (1.21:1 against 15.52:1 for `color.onAccent`) and a redundancy invariant that makes R2's peak-power badge safe: nothing may appear in the badge that is not also in `#FFFFFF` text on the same screen. The 1:1 reproduction is recommended; the one-token alternative is named, not chosen. |
| **M13** | The free-bay dot straddles the lime outline; its ring lands on white | **Fixed by re-derivation.** §2.4 measures the pin (head ⌀122, rim at r 60–61, body white to r 51) and shows the collision in numbers: the dot's lime spans r 55.8–75.8, crossing the rim, and its ring lands on the white body. The avatar escapes only because it has no rim. New offset **(+53, −53) px**, tangent to the rim — **[RAISE-D26]**, with the argument that 1:1 on a *mark* means preserving legibility, not the arithmetic that produced it on a rimless host. |
| **M14** | "Full width, no inset" across three margin families | **Fixed.** §5.1 defines it once as a relationship to the row's container, tabulates all three containers, and raises the generalisation from a single measured instance — **[RAISE-D29]**. |

### The minors named in the brief

| # | Finding | Answer |
| --- | --- | --- |
| **m1** | Silent re-measuring | **Fixed.** §0.3 is a measurement policy plus a complete, declared list of every [m·11] value, with the method for each and an explicit statement of what it contradicts in part 1. §0.4 fixes the advance model, so no fit check anywhere below uses an unstated constant. |
| **m2** | The worked station disagrees with CarPlay S1 | **Fixed.** §0.5 adopts S1 unchanged, **2.4 km**, and reconciles the Regime-1-first rule with S1's operator reports as *the same station at t = +6 h* rather than a second dataset. The driving pair (2.9 km / 8 min) is labelled fixture data, phone-only, because ADR-0004 forbids duration on car surfaces. |
| **m3** | Row-count contradiction | **Fixed.** §5's "keeps the reference's row count exactly" is retracted in place and replaced with what is true: four reference rows kept 1:1, two `[ext]` rows added below the capture's cut-off, pitch and treatment unchanged throughout. D-04's table now marks each row [ref-02] or [ext]. |
| **m10** | Grammar R paraphrased | **Fixed.** Quoted verbatim at D-03, including its three deliberate choices and the session-fee rule, plus the phone's one-line join rule stated once. v1's drifted forms (`all 4 plugs`, `0 of 4 plugs`) are gone. |

---

## 16. Raised — impossibilities, gaps and questions

Per the standing rule these are raised, not resolved. **Two are genuine
impossibilities** ([RAISE-D20], §11); the rest are values or components the
reference cannot supply. D1–D25 keep their v1 numbers so earlier correspondence
still resolves; D26–D34 are new in this revision.

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
| **D9** | Two-line card subtitle; 45 px pitch derived, not measured | accept; card becomes content-sized |
| **D10** | List detent: height unmeasured, **and** the CTA's behaviour once expanded | ~70% of screen; CTA stays and collapses the detent |
| **D11** | Heart states, re-based on the measured `#717171` default | `#717171` unsaved → `#C7FC2F` filled saved |
| **D12** | **`Description` has no field behind it** | add nullable `Station.description`; title the block `Getting there`; route to 19 |
| **D13** | No driver channel for non-availability corrections | new ticket if wanted; not a menu item |
| **D14** | Settings rows have no value slot | compose with the card's right-aligned price treatment |
| **D15** | No destructive treatment exists | `Delete account` is an ordinary row; weight goes in the copy |
| **D16** | No progress component exists | text percentage only |
| **D17** | **No switch / checkbox / toggle exists anywhere** | one trailing `#C7FC2F` check at 24 pt / 2 pt stroke, used everywhere |
| **D18** | `My plug` ungated — flagged for founder ratification by the domain model | keep ungated |
| **D19** | Watch vocabulary contradicts across three surfaces | route to 30; do not settle it a fourth time here |
| **D20** | **Sign in with Apple cannot be restyled — impossible 1:1, and compelled by Guideline 4.8** | Apple's native button with `cornerRadius` 13.5 px |
| **D21** | **No text input exists anywhere in the reference** | build from the feature-chip surface; add to `packages/ui` |
| **D22** | No selected-control state → the report sheet commits on one tap | accept; reports are append-only |
| **D23** | Report action labels are not in the closed vocabulary | add `Free` / **`Busy`** / `Out of service` to `packages/domain` |
| **D24** | No onboarding designed | new pass if commissioned; copy already constrained by 28 |
| **D25** | The location puck is Google's `#4285F4` | redraw in `#FFFFFF` + `#C7FC2F` |
| **D26** | **The free-bay dot fuses to the pin's lime rim at the measured proportion** (§2.4) | offset **(+53, −53) px**, tangent to the rim |
| **D27** | **The category chip's width behaviour is unmeasurable** — one instance (§7.2) | content-sized, per the feature chip's measured rule; **if no, the route preview cannot live in the chip** |
| **D28** | **The hero badge's `#FFFFFF` label measures 1.21 : 1** (D-03) | reproduce 1:1 + the redundancy invariant; `color.onAccent` named as the alternative |
| **D29** | **"Full width, no inset" is generalised from one container** (§5.1) | accept the container-relative rule |
| **D30** | **The same heart icon is `#717171` on `03` and `#FFFFFF` on `04`** (§0.3) | reproduce both; add `color.iconMuted`; owed to `10-design-system-v2.md` |
| **D31** | **No full-width button exists; S-01/S-02's width had to be derived** (S-01) | 950 px = the card's inner box; 27 px between |
| **D32** | **Bare `GB/T` is not in the closed projection** (§13.4) | **open — routed to 18 and to Grammar R**; qualified forms used meanwhile |
| **D33** | **The price slot's weight composition when there is no amount** (§13.2) | `No confirmed rate` renders Regular at the same cap height |
| **D34** | **The card's bottom offset when nothing sits below it** (S-01) | 103 px = 34.3 pt above the screen bottom |
| **§11** | **The `Google` wordmark is unreproducible** | replace with `© OpenStreetMap contributors` in the same slot; record as a knowing deviation |

Inherited from part 1 and unresolved here because they are not this file's to
settle: **[RAISE-1]** the typeface and its old-style figures — which also blocks
every fit check in §0.4 from becoming a guarantee; **[RAISE-2]** ExtraLight body
at 13 pt; **[RAISE-3]** normalise the spacing or not; **[RAISE-4]** two different
CTA sizes; **[RAISE-5]** four alignment defects — including [5a], the chip
padding §7.2 inherits; **[RAISE-6]** the sticky bar's 90 px padding;
**[RAISE-8]** two blacks on the accent; **[RAISE-9]** five circular-button
diameters.

---

## 17. The inventory table

| Screen | Ref or ext | Components used | States | What fixes its content |
| --- | --- | --- | --- | --- |
| **D-01 Map home** | **[ref-01]** | map canvas · crosshair rule §5.11 · map avatar §5.9 (no dot) · charger pin §5.3 + status dot §5.9 at (+53,−53) · primary CTA §5.1 (**897 px**) · locate button §5.2 · feature chip §5.5 (offline) · attribution mark | default · offline · no-permission · signed-out · (no loading, no empty, no error) | ADR-0002 · ADR-0007 · ticket 06 · ticket 19 |
| **D-02 Map + station card** | **[ref-03]** | **floating card** (r 16 all corners) · drag handle **180 × 13** · thumbnail · category chip §5.5 (route, content-sized) · `rateShort` price composition · heart `#717171` · route line (new width, D8) · divider §5.1 (list detent) | Regime 1 / 2 / 3 / lensed / no-compatible-plug · route-in-flight · route-failed · offline · signed-out · saved · uncached-photo | availability-display §2 · ADR-0004 · ADR-0007 · ticket 10 · ticket 19 |
| **D-03 Station detail** | **[ref-04]** | circular buttons §5.2 (⌀81, ⌀100) · hero carousel + indicator + badge §5.7 (peak power, D28) · title/subtitle · owner row · settings rows §5.6 (connectors, divider x 64→1141) · feature chips §5.5 · **CTA-geometry bay-alert control** §12.2 · sticky bar §5.8 with `rateShort` | all availability regimes · Grammar R's five rate cases + session fee · offline · signed-out · not-at-station · uncached-hero | ADR-0002 · ADR-0008 · ADR-0004 · ticket 10 · ticket 30 · **D12 (schema)** |
| **D-04 Profile** | **[ref-02]** | back button §5.2 · profile avatar §5.9 · quick actions §5.2 · hosting card §5.10 · settings rows §5.6 (4 [ref] + 2 [ext]) | signed-in · signed-out · membership / no-membership · app-installed / not / undeterminable · offline | ADR-0003 · ADR-0006 · ticket 11 · ticket 15 |
| **D-05 Personal Information** | [ext] | back · heading · settings rows + value slot (D14) · text input (D21) | signed-in only · offline · error-in-place | ADR-0003 |
| **D-06 Login & Security** | [ext] | back · heading · settings rows + value slot | providers connected / not · sign-out · delete-account confirm · offline | ADR-0003 · Guideline 5.1.1(v) |
| **D-07 Offline & map data** | [ext] | back · heading · settings rows + value slot | not-downloaded · downloading · downloaded · update · offline · failed · synced / not-synced | **ADR-0007** · ticket 06 · ticket 16 |
| **D-08 Notifications** | [ext] | back · heading · settings rows + trailing check (D17) | granted · denied · signed-out | ticket 30 · ADR-0003 |
| **D-09 My plug** | [ext] | back · heading · settings rows + trailing check · body copy | none-selected (default) · selected · signed-in (syncs) · signed-out (local) | ADR-0002 · ticket 12 · ticket 19 · **D18** |
| **D-10 About EV Guide** | [ext] | back · heading · settings rows + value slot · body copy | static | **§11 attribution** · ticket 06 |
| **D-11 Saved** | [ext] | back · heading · station cards (D-02 composition, `rateShort`) · dividers §5.1 | populated · empty · offline | ADR-0003 · ticket 19 |
| **D-12 Alerts** | [ext] | back · heading · settings rows + value slot | armed · empty · at-ceiling · offline | **ticket 30** · ticket 23 |
| **S-01 Auth sheet** | [ext] | floating card (handle 180 × 13, r 16 all corners) · CTA geometry at **950 px** (D31) · hosting-card fill §5.10 · Apple's native button (**D20**) · text input (**D21**) | idle · in-flight · success (auto-resume) · cancelled · failed · offline · email path | **ADR-0003 as amended** · ADR-0004 · ticket 23 |
| **S-02 Report sheet** | [ext] | floating card · **three CTA-geometry controls, stacked** (§12.3) | signed-out · not-at-station · offline (queues) · expired | ADR-0002 · ADR-0007 · ticket 09 · ticket 11 |
| **S-03 Overflow menu** | [ext] | platform action sheet | — | **D13** |

---

## 18. What this file does not decide

The operator app's screens (a separate app, ADR-0006) · the admin dashboard
(tokens only, and the 1:1 rule does not govern it) · anything in part 1's raise
list · the basemap style (verdict M4, routed to ticket 06) · the link underline
(verdict M3, routed to part 1) · ticket 30's watch-vocabulary reconciliation ·
the `Station.description` schema addition, which is ticket 19's to accept or
reject · the legality of a bare `GB/T` (D32, routed to ticket 18) · and every
founder call in §16, which is the point of raising them.

**One hard dependency.** `10-design-system-v2.md` does not exist yet. Six
corrections are owed to it (§0.3) and one new token (`color.iconMuted`
`#717171`). Until it lands, §0.3 is the citation of record for those six values
and part 1's originals are void.
