# 10 — Design system, measured from the reference (v2)

Ticket 17, part 1 of 2. Supersedes `10-design-system.md` in full: this is a
standalone document, not a diff. Where v1 and v2 disagree, **v2 is the
measurement of record**.

This file is the **design system**: palette, basemap style, typeface, type
scale, spacing, radii, components, icons, elevation, tokens, and the closed copy
vocabulary the other two files consume. The screen inventory and the domain
mappings are the ticket's other half and are **not** decided here.

Everything below was measured off the pixels of `refs/01.png`–`refs/04.png`.
Nothing is estimated by eye unless it says so.

---

## 0. Method, units, and what changed in v2

### 0.1 Captures and units

**Captures.** `1206 × 2622 px` = iPhone 16 Pro at @3x = `402 × 874 pt`.
**px is the authoritative unit here**; `pt = px / 3` is given alongside because
that is what a build types. Where px/3 is not a whole number the pt value is
shown to one decimal and **is not rounded to a nicer number**.

**Marking legend**

- **[m]** — measured directly from pixels. Reproducible from the stated logic.
- **[d]** — derived from one or more [m] values by stated arithmetic.
- **[?]** — could not be measured reliably; the reason is given.
- **[RAISE]** — a place the reference cannot be reproduced 1:1, or contradicts
  itself, or contradicts an EV Guide decision. Per the standing rule these are
  raised, not quietly resolved. **Fifteen of them are listed in §12 — the nine
  from v1, carried forward unchanged, the three new in v2, and three added by
  ticket 32 (RAISE-13 the radius method, RAISE-14 the extent convention,
  RAISE-15 the price string's two weights).**

**Sub-pixel technique.** Stroke widths are integrated coverage, not thresholded
pixel counts: for a cut across a stem, `Σ (v − bg)/(fg − bg)`. This resolves a
stem to roughly ±0.1 px. **Where v1 reported "a white run of exactly 6 px" it
was counting pixels touched, which over-reads a stroke by 1–2 px.** Every stroke
figure in this file is integrated, so several of them differ from v1 by design.

**Perpendicular width.** For lines drawn at arbitrary angles (roads, diagonal
icon strokes) a horizontal cut over-reads by `1/cos θ`. Line widths in §2 are
`min(horizontal run, vertical run)` taken at every pixel of the exact colour and
then moded, which bounds the error to `[w, 1.41w]` and in practice recovers `w`.

**Extent convention — NOT YET DECLARED. [RAISE-14], ticket 34.** Ticket 32
asked this file to declare one and it cannot, because every candidate breaks
values locked in `SPEC.md`. A component's size can be read three ways, and
**this file has used two of them without saying so**: the `01`/`03` primary CTA
is published at its **AA-inclusive** extent (899 × 138) and the `03` floating
card at its **core** extent (1076 × 521). Measured [m, ticket 32]:

| Element | core | integrated (true) | AA-inclusive | published |
| --- | --- | --- | --- | --- |
| Primary CTA | 897 × 136 | **898.00 × 137.25** | 899 × 138 | AA-inclusive |
| Floating card | 1076 × 521 | **1077.60 × 521.53** | 1078 × 522 | core |
| Sticky CTA | 513 × 131 | **513.00 × 131.25** | 513 × 132 | core |
| Map pin | 122 × 147 | **122.3 × 147.25** | 124 × 148 | *neither* — see §7.3 |

Neither reading is a property of the component: an element whose edges land on
whole pixels reads the same all three ways (the sticky CTA's 513 px width, whose
left, right and top edges are **hard**), and one whose edges land mid-pixel reads
2 px apart. The rasteriser quantises coverage to quarter-levels (2×2
supersampling), so every fractional figure here is good to ±0.25 px.

**Until ticket 34 rules, no size in §7 may be copied into files 11 or 12**, and
the three readings are given wherever they differ. The cost of each candidate,
counted in locked `SPEC.md` values it breaks: **core 2** (`size.ctaHeight`
138 → 136 and the §5 "899 × 138" sentence), **AA-inclusive 3**
(`size.floatingCard`, `size.ctaHeightSticky`, `size.pin`), **integrated 4** (all
of the above plus `size.ctaHeight` → 137.25). `size.pin` moves under all three,
so it is not a bargaining chip — it is corrected in §7.3 on its own merits.

**Fill vs anti-alias test.** A colour is a *real fill* if a meaningful fraction
of its pixels have all four neighbours of the identical value; an anti-alias
ramp has essentially none. Measured on `01`: `#212121` 0.96, `#3C3C3C` 0.73,
`#373737` 0.32, `#272727` 0.20, `#BDBDBD` 0.28 — all real. Every value between
`#222222` and `#3B3B3B` not named in this file scores **0.00** and is a ramp.
This test is what settles §2, and it is cheap to re-run.

### 0.2 Change log against v1

| # | v1 said | v2 measures | Where |
| --- | --- | --- | --- |
| **M1** | drag handle "12 × 13 px core" | **180 × 13 px**, x513–692, y1822–1834, `#262626`, fully rounded, centred | §7.4 |
| **M2** | `03` is a bottom sheet, top radius 16 px, "bottom corners square (sheet runs under the CTA)" | **a floating card**: x65→1140, y1797→**2317**, **all four corners r ≈ 14 px**, 64 px of live map below it | §7.4 |
| **M3** | the link's decoration unrecorded | `Show and edit my profile` is **underlined**: a 2.0 px `#C7FC2F` rule, y964–966, x380–825 | §5.4 |
| **F4** | "There is no grey text anywhere… the single most important finding in the file" | true **of text**; **false of icons** — the `03` heart is a solid `#717171` (517 px, zero white). Claim narrowed per R5 | §1.3, §8 |
| **M4** | basemap unmeasured; `#3C3C3C` called "the *mean* of `#393939` and `#3E3E3E` across a scan line" | **fabricated and withdrawn.** `#3C3C3C` is the reference's **major-road fill**, 34 239 px on `01` in an 8 px band, and appears **89 px total** on `02` | §2 |
| **m4** | "All stroked, one exception… The hero badge's lightning bolt is also solid" (two exceptions) | the bolt is **stroked** — its interior samples lime. **Exactly one filled icon exists**: the locate arrow | §8.3 |
| **m5** | handle colour not tokenised | `color.handle` = `#262626` added | §10.1 |
| **m6** | Raleway 65–70%, deltas "within the error bar" | the deltas are **systematic across six runs and two metrics**. Raleway demoted to ~25 % | §3 |
| — | icon stroke "6 px, uniform… without exception" | modal 6 px but **measured range 4.2 – 9.8 px**; the claim is narrowed, not deleted | §8.2 |
| — | `color.iconOnDark` `#000000` "locate-arrow only" | correct, and now sharper: the map-avatar glyph is `#121212`, so **the locate arrow is the only `#000000` in the product** | §8.1, RAISE-8 |
| — | "no shadows, blurs or gradients. **Anywhere.**" | right about every component; **two sub-threshold exceptions exist** — a rendered ±8/±14-level ramp above and below the `04` hero, and a 1-level `#111111` band hugging `02`'s `#393939` surfaces. Neither is tokenised | §7.7, §9 |
| — | hero frame "x65→1140, y354→973 = 1076 × 620" | **x64 → 1141, y354 → 965 = 1078 × 612 px**, verified at five columns and two rows | §7.7 |

Everything v1 got right is restated here unchanged and marked **[held]**: the
product palette, "the CTA is not a pill", the old-style figures, the four weight
classes, no shadows/blurs/gradients anywhere, and the nine original raises.

### 0.3 Rulings inherited (settled — not re-decided here)

- **R1** — `busy` is the user-facing word for `Occupied` on every surface for
  both audiences. The operator write control reads `Busy`. **`in use` is deleted
  product-wide.** §11.
- **R2** — availability never appears in the accent badge, on any surface. §7.7.
- **R3** — `unreported` is forbidden product-wide, with every string that
  asserts report history. Permitted: `no confirmed status`, `no confirmed rate`.
  **The forbidden list lives in `docs/availability-display.md` §2.2b and nowhere
  else** — this file, file 11 and file 12 all cite it and none may restate it.
  *Corrected by ticket 32:* R3 previously claimed the list for §11.2 of this
  file, which made **four** documents claim to be the one home. §11.2's three
  unique literals and its catch-all clause were merged into §2.2b first, so the
  withdrawal loses nothing.
- **R4** — the short rate projection is defined once in `packages/domain`. §11.3.
- **R5** — colour tokens are what the pixels say. Applied in §1 and §8.

---

## 1. Colour — the product surfaces

### 1.1 The measured palette [held, extended]

| Token role | Value | Verified on | Interior frac. |
| --- | --- | --- | --- |
| Page background | **`#121212`** | 80 % of `02`, 64 % of `04`, the whole `03` card | 0.96 |
| Map canvas | **`#212121`** | 84.75 % of `01`, 68.0 % of `03` | 0.96 |
| Surface | **`#393939`** | hosting card, quick-action circles, all four chips, close/back/overflow buttons | — |
| Surface raised | **`#3E3E3E`** | profile-avatar fill (x449–756, y402–709), hosting icon tile (x78–333, y1487–1743), the three settings dividers (1 px, y2188 / 2364 / 2541), the three inactive page dots on `04` | — |
| Accent | **`#C7FC2F`** | identical in all four screens, **one value, no tints, no gradients** | 0.93 |
| On-accent label | **`#121212`** | both CTA labels — the page background colour, *not* black | — |
| Text | **`#FFFFFF`** | every product text core, without exception | — |
| Pin body | **`#FFFFFF`** | — | — |
| Pin inner disc | **`#F3F3F3`** | 37 935 px on `01` | 0.88 |
| Pin glyph | **`#393939`** | — | — |
| Card-heart ink | **`#717171`** | `03` only — 517 px solid, **zero white pixels** | — |
| Handle | **`#262626`** | `03` only — 2 121 px | — |
| Icon on white | **`#000000`** | locate arrow only — 759 px solid | 0.89 |

**The `#3C3C3C` correction, restated honestly.** v1 recorded the observation
record's `#3C3C3C` as wrong and gave a reason — that it was "the mean of
`#393939` and `#3E3E3E` across a scan line that crossed the card/tile boundary".
**That reason is fabricated and is withdrawn.** `#3C3C3C` is real: it is the
basemap's major-road fill (§2), 34 239 px on `01` in a continuous 8 px band with
a 0.73 interior fraction. The observation record sampled it from the map — its
own note says "pin-adjacent chrome" — and filed it under a UI role it does not
occupy. The correction to the *record* stands: **`#3C3C3C` is not a UI surface**
(89 px on `02`, 341 px on `04`, all anti-alias). `#3E3E3E` is the raised surface.
Two different facts, one of which v1 explained by inventing an arithmetic
artefact that the pixels disprove.

### 1.2 Contrast, measured [m]

WCAG 2.x relative luminance, computed on the measured hexes.

| Pair | Ratio | Consequence |
| --- | --- | --- |
| `#FFFFFF` on `#121212` | **18.73 : 1** | body text is not a contrast problem; §3's weight is |
| `#C7FC2F` on `#121212` | **15.52 : 1** | link and category-chip label |
| `#121212` on `#C7FC2F` | **15.52 : 1** | both CTA labels |
| `#FFFFFF` on `#393939` | **11.55 : 1** | chip labels, circular-button glyphs |
| `#C7FC2F` on `#393939` | **9.57 : 1** | category chip border + label |
| `#717171` on `#121212` | **3.84 : 1** | the `03` heart — clears 3:1 for a graphical object (1.4.11) and nothing more |
| `#3E3E3E` on `#121212` | **1.75 : 1** | dividers, inactive dots — decorative only |
| `#262626` on `#121212` | **1.24 : 1** | the drag handle. Invisible-grade |
| **`#FFFFFF` on `#C7FC2F`** | **1.21 : 1** | **the hero badge label.** See R2 and §7.7 |

The last row is the reason R2 exists and is not negotiable: the badge is a
surface on which *no value a driver must read may be placed*, because a white
label on the accent is functionally unreadable and the reference nevertheless
does exactly that. Reproducing the badge 1:1 means reproducing an unreadable
label; the ruling permits it only for a value that is decorative or duplicated
elsewhere (peak power), never for availability.

### 1.3 The "no grey tier" finding, narrowed per R5

v1's headline was *"There is no grey text anywhere. Every text core samples
`#FFFFFF`."* Re-measured exhaustively, the **text half is true and the general
claim is false.**

**True — every product text run cores to one of three values [m]:**

| Colour | Runs |
| --- | --- |
| `#FFFFFF` | profile name, all titles, all sub-heads, all prices, settings labels, quick-action labels, subtitles, body copy, **all four feature-chip labels**, hero-badge label, sheet title |
| `#C7FC2F` | the one link (`02`), the category chip label (`03`) |
| `#121212` | both CTA labels |

There is no `text.secondary`, no opacity ramp, no grey text tier. The grey
*appearance* of the chip labels and body copy is an ExtraLight weight at a
1.7–2.1 px stem anti-aliasing against `#121212` / `#393939` — the AA ramps are
`#C4C4C4 / #888888 / #4D4D4D` on the page and `#CDCDCD / #9C9C9C / #6A6A6A` on
the surface, exactly the blends white would produce. **§10.1 therefore has no
secondary-text token, and adding one would be a deviation. [held]**

**False as stated — three greys exist outside text:**

1. **`#717171`**, the `03` card heart, 517 px of solid ink with zero white
   pixels in the glyph and a `#414141 / #595959 / #2A2A2A` AA ramp consistent
   with a solid `#717171` source. It is not a blend and not an artefact.
2. **`#262626`**, the drag handle.
3. **The basemap's own three-tier label ramp** — `#757575`, `#BDBDBD`,
   `#FFFFFF` (§2.4). The basemap is 85 % of the front door and it has a grey
   text hierarchy even though the chrome does not.

So the correct sentence is: **the product chrome has one text colour; the icon
set has four; the basemap has its own three-tier label ramp.** Any decision that
rested on "no grey exists" must be re-checked against this.

---

## 2. The basemap — measured, and EV Guide's to author

The reference's map is Google Maps in a dark style. Under MapLibre (ticket 06)
none of it arrives for free: **the basemap is 84.75 % of `01` and 68.0 % of
`03`, and every pixel of it is 1:1 work.** v1 left it unmeasured. This section
is the style JSON's source of truth.

**Scope note.** These are the *paint values*. Which OSM classes map to which
tier, label ranking, collision/generalisation, and the width stop function are
style-authoring decisions two stills cannot determine — marked [?] where they
arise. **Rebero and Remera do not exist as OSM places** (routed from 06) and are
a data problem, not a style one.

### 2.1 Ground and water

| Layer | Value | Evidence |
| --- | --- | --- |
| **Ground / land** | **`#212121`** | 2 680 014 px on `01` (84.75 %), interior 0.96 |
| **Water — line (streams, rivers)** | **`#000000`–`#020202`**, 2 px | continuous dendritic network, no dashes, cores reach `#010101`; 9 701 px in the map body of `01` |
| **Water — polygon (small bodies)** | **`#181818`** | e.g. x766–805 y1094–1109 on `01`; 1 233 px exact, 3 691 px within ±2 |
| **Green / parks** | **none** | — |

**There is no green anywhere.** A saturation scan of the whole map body of both
map screens returns **exactly two saturated families**: `#C7FC2F` with its AA
blends, and `#4285F4` with its halo. Every other pixel is neutral. The reference
basemap is **fully monochrome, water included**, and that is a design decision
worth naming: it is why the lime reads as loudly as it does at only 3.9 % of the
screen.

Water darker than land is the unusual move here and it must survive into the
style — the instinct will be to make water blue.

**Two honesty notes on the water rows.**

1. *That the dendritic network is water is an inference, not a measurement* [d].
   The evidence: it branches and converges downstream, it is drawn continuous
   where the administrative boundary is dashed (§2.3), it is a different colour
   from all three road tiers, and it terminates in the `#181818` polygons. That
   is strong but it is not the same as reading a layer name. Under MapLibre the
   layer is `waterway` either way; if it turns out to be something else the
   *colour* is still right, only the class assignment moves.
2. *The line colour is bounded, not exact.* A 2 px line anti-aliases along its
   whole length, so the source value is whatever the core converges to —
   `#000000`–`#020202` across many perpendicular cuts. Treat it as **`#000000`**
   and accept a ±2 uncertainty; nothing at that level is visible.

`map.water.line` and `map.boundary.casing` are both `#000000` and are
deliberately kept as **two tokens with one value**, because they are two layers
that happen to coincide here and a style author must be able to move one without
moving the other.

### 2.2 Road hierarchy [m]

Widths are perpendicular cores; add ~1 px of AA each side for the rendered
width. **Measured identically on `01` and `03` despite the zoom difference**, so
these are flat within the reference's zoom bracket; the stop function outside it
is [?].

| Tier | Fill | Core width | Interior frac. | px on `01` |
| --- | --- | --- | --- | --- |
| **Major / trunk** | **`#3C3C3C`** | **8 px = 2.7 pt** (mode 8, then 7 and 9) | 0.73 | 34 239 |
| **Secondary** | **`#373737`** | **4–5 px = 1.3–1.7 pt** | 0.32 | 15 093 |
| **Minor / local** | **`#272727`** | **3 px = 1.0 pt** | 0.20 | 15 227 |

Three tiers only. No casings, no outlines, no colour change at junctions, and
**no road is lighter than `#3C3C3C`** — the brightest thing on the basemap is
its own label ramp, not its geometry.

### 2.3 Administrative boundary [m]

| Part | Value |
| --- | --- |
| Dash | **`#6E6E6E`** |
| Casing | **`#000000`**, continuous, ~2 px, drawn under the dash |
| Pattern | short dashes with visible gaps; the casing is unbroken through the gaps |

This is the only two-part line in the basemap. It is what produces the
crenellated line across the lower third of `01`.

### 2.4 Label hierarchy [m]

| Tier | Colour | Cap height | Case | Examples on `01` | Contrast on `#212121` |
| --- | --- | --- | --- | --- | --- |
| **City** | **`#FFFFFF`** | ~55 px [?] (overlapped by a pin on `01`; `03` gives x71–193, y1140–1243 incl. descender) | Title | `Kigali` | 16.1 : 1 |
| **Place** | **`#BDBDBD`** | **18 px** all-caps · **28 px** title-case | both | `NYACYONGA`, `REBERO`, `KICUKIRO`, `Butamwa`, `Ntarama` | 8.57 : 1 |
| **Minor** | **`#757575`** | **18 px** | all-caps | `KABUYE`, `KIBAGABAGA`, `CYIVUGIZA`, `BWERAMVURA` | **3.49 : 1** |

Two sizes, three colours. Note that the place tier carries **both** cases at
different sizes — title-case labels (`Butamwa`, `Ntarama`) are cap 28 px, the
all-caps ones cap 18 px, and both are `#BDBDBD`. Whatever OSM ranking drives
that split is [?].

The minor tier at **3.49 : 1** is below the 4.5 : 1 text threshold. Under
MapLibre this is EV Guide's own choice rather than Google's, which makes it a
decision rather than a reproduction — see **[RAISE-12]**.

### 2.5 The location puck [m]

Google's own control, and under MapLibre EV Guide must draw it.

| Part | Value |
| --- | --- |
| Disc | **`#4285F4`**, ⌀ **40 px = 13.3 pt** |
| Ring | `#FFFFFF`, **4 px = 1.3 pt** |
| Accuracy halo | **`#4285F4` at ≈19 % over `#212121`** (measured `#27344B`; solves to α = 0.18–0.20 on all three channels), ⌀ **82 px = 27.3 pt** |
| Heading cone | `#4285F4`, projecting from the disc in the heading direction, ⌀ ≈ 82 px envelope |
| Centre on `01` | x603.5, y1311 |

`#4285F4` is **Google's brand blue and the only foreign brand colour in the four
screens.** Reproducing it 1:1 means shipping Google's blue in a MapLibre map
that is not Google's. See **[RAISE-10]**.

### 2.6 Basemap token set (style-JSON ready)

```
map.ground              #212121
map.water.line          #000000   width 2px
map.water.fill          #181818
map.road.major          #3C3C3C   width 8px core
map.road.secondary      #373737   width 4-5px core
map.road.minor          #272727   width 3px core
map.boundary.casing     #000000   width 2px, continuous
map.boundary.dash       #6E6E6E   dashed
map.label.city          #FFFFFF
map.label.place         #BDBDBD   cap 18px caps / 28px title
map.label.minor         #757575   cap 18px caps
map.puck.disc           #4285F4   d40
map.puck.ring           #FFFFFF   4px
map.puck.halo           #4285F4 @ 19%   d82
```

**[admin]** for none of it — the dashboard has no map in this ticket's scope.
`map.*` is a separate token namespace from `color.*` deliberately: the map is a
style JSON consumed by MapLibre, not a React Native theme, and merging the two
namespaces would let a UI surface accidentally paint itself `#3C3C3C`.

---

## 3. The typeface

The observation record says "likely Poppins". **Poppins is ruled out.** v1 then
named Raleway at 65–70 %. **v2 demotes Raleway**, because the two metrics v1
called "within the error bar" are systematic and both point the same way.

### 3.1 Glyph diagnostic [held, re-verified]

Measured from `CTO Motors Group Rentals` (`04`, cap 32), `135 000 RWF/day` (`04`,
cap 36), `Shima Serein` (`02`, cap 55), `Forthing T5` (`04`, cap 47),
`Description` (`04`, cap 32) and `Let's find a car` (`01`, cap 36).

| Test | Reference shows | Consequence |
| --- | --- | --- |
| **`a`** | **Double-storey**, small bowl, no spur/tail | **Rules out Poppins, Outfit, Jost, Futura, Century Gothic, Product Sans** (single-storey `a`); argues against Proxima Nova, Figtree (tailed `a`) |
| **`g`** | Single-storey, open hook, does not close | Rules out binocular-`g` humanists |
| **`t`** | Apex cut at an angle, foot curves right | Rules out Montserrat, Proxima Nova, SF Pro |
| **`M`** | Vertical sides; **middle vertex bottom at y1262 against a baseline of 1267 — it stops 5 px (16 % of cap) above the line** [m] | Rules out Montserrat and Poppins (vertex reaches the baseline) |
| **`G`** | Bar + vertical, no spur above the bar | Rules out SF Pro |
| **`y`** | Straight diagonal tail, no hook | Geometric group |
| Terminals `c e s a r` | Cut at an angle, wide apertures | Rules out Montserrat, Proxima Nova, Figtree |
| `fi` in "find" | True ligature, dot absorbed | Real OpenType `liga` |
| **cap `O` w/h** | 31 × 32 = **0.969** [m] | see §3.3 |
| **lowercase `o` w/h** | 25/24, 24/24, 25/24 → **1.028 mean** [m] | see §3.3 |

### 3.2 Old-style figures — confirmed independently, three times [held]

The rarest diagnostic present, and v2 re-derives it from scratch with glyph
segmentation rather than eyeballed ink extents.

| Run | Baseline | Cap | x-height | Digits | Descending |
| --- | --- | --- | --- | --- | --- |
| `135 000 RWF/day` (`04`) | 2446 | 36 (`RWF`) | 27 (`a`) | `1` 29 · `0` 31 | **`3` and `5` → 2453 (−7 px)** |
| `Hybride - Black - 2024` (`04`) | 1166 | 27 (`H`) | 20 (`r`) | `2` 22 · `0` 23 | **`4` → 1171 (−5 px)** |
| `Forthing T5` (`04`) | 1102 | 47 (`F`) | 34 (`n`) | — | **`5` → 1111 (−9 px)** |

Digits sit at x-height + ~2 px (the round-figure overshoot) and `3 4 5` hang
below the line, in three unrelated strings at three sizes. That is textbook
**old-style / text figures**, and it is the face's *default* set — the app never
opts in mid-sentence. Almost no geometric sans ships old-style by default, which
eliminates Circular Std, Aeonik, GT Walsheim, Gilroy, Greycliff CF, General
Sans, Satoshi, Airbnb Cereal, Montserrat, Proxima Nova and Figtree in one move —
**all ship lining figures.**

### 3.3 The two systematic deltas (m6 — the dismissal is strengthened)

v1 measured `x-height/cap` at 0.745–0.775 across four runs and cap `O` w/h at
0.97, then dismissed both as "within the error bar of a 24–55 px ink
measurement". **That dismissal does not survive.**

v2 re-measured using **flat-topped glyphs only** — `T D L H F` for cap, `n r m u`
for x-height — which removes the round-glyph overshoot that inflated v1's spread:

| Run | Screen | cap (flat) | x-height (flat) | ratio |
| --- | --- | --- | --- | --- |
| `CTO Motors Group Rentals` | 04 | 32 (`T`) | 24 (`n`, `r`) | **0.750** |
| `Description` | 04 | 32 (`D`) | 24 (`n`, `r`) | **0.750** |
| `Let's find a car` | 01 | 36 (`L`) | 27 (`r`) | **0.750** |
| `Hybride - Black - 2024` | 04 | 27 (`H`) | 20 (`r`) | **0.741** |
| `Settings` | 02 | 35–36 | 27 (`n`) | **0.760** |
| `Shima Serein` | 02 | 54–55 | 41 (`m`, `r`, `n`) | **0.752** |

**Six runs, five sizes, two screens: 0.750 ± 0.006.** The spread is *tighter*
than v1's, not looser — v1's 0.775 came from measuring a round cap against a
flat x-height. Raleway's published metrics give ≈0.72. A 0.750 face is **+4 %**,
which at cap 55 px is a 1.3 px difference and at cap 32 px is 0.9 px — above the
noise floor of a 3× capture, in the same direction, at every size.

The second delta compounds it. Measured `O` w/h **0.969** and `o` w/h **1.028**
(three independent `o`s at cap 32, and the `o` measures *wider than tall*).
Raleway's bowls are ovals, ≈0.90–0.93. That is **+5 to +10 %**, again in one
direction.

**Two independent metrics, each off by the same sign, across six runs, is not an
error bar. It is a different typeface.**

### 3.4 Ranked identification, revised

**1. An unidentified geometric sans with old-style figures — ~55 %**

Everything measures as a wide, near-circular geometric sans with a large
x-height (0.75), double-storey `a`, single-storey `g`, canted terminals, a
raised `M` vertex, a spurless `G`, real `liga`, and four weights from ≈200 to
≈700. That description *plus* default old-style figures does not resolve to a
family I can name from a 3× screenshot. Some of these are licensed retail faces
with `onum` shipped on by default; some are the app's own webfont build with
`FontFeature.oldstyleFigures()` / `font-variant-numeric: oldstyle-nums` applied
globally — which, applied globally, is indistinguishable from a default.

**2. A named geometric sans with `onum` deliberately enabled — ~25 %**

Circular Std, Aeonik, GT Walsheim, Gilroy, Greycliff CF, General Sans and
Satoshi all satisfy §3.1 *and* the `O`/`o` circularity *and* the 0.75 x-height
better than Raleway does. Each would need old-style turned on globally — unusual,
but it would have to have been applied uniformly to prices, years and model
numbers, which is exactly what is observed. This hypothesis is now **stronger**
than Raleway, not weaker.

**3. Raleway — ~15 %** *(was 65–70 %)*

Still the one widely-deployed free family whose *default* figure set is
old-style, and it satisfies every row of §3.1 with a full Thin→Black range. But
it fails **both** measured metrics by a consistent margin (§3.3), and no
rendering pipeline stretches a face 4 % vertically and 6 % horizontally by
accident. Keeping it at 65 % required believing two independent measurements
were noise in the same direction six times.

**4. Airbnb Cereal — ~5 %**

The IA is copied from Airbnb verbatim (`Trips`, `Wishlist`, `Messages`,
`Payment & payouts`, `Switch to hosting mode` are Airbnb's own strings), so a
ripped Cereal is imaginable, and Cereal's metrics are much closer to the
measurements than Raleway's. It has lining figures and is not licensable, so it
is unusable regardless.

**Honest statement of confidence.** **High confidence on the classification**
(wide geometric sans, x/cap 0.750, `O` 0.97, `o` 1.03, double-storey `a`,
single-storey `g`, canted terminals, old-style default figures, four weights) and
**low confidence on the name** — lower than v1 claimed, because v2 removed the
one candidate v1 was leaning on. **`packages/ui` must not pick a family from this
document.** The check that settles it is in §3.5.

### 3.5 The acceptance test a substitute must pass

A substitute is correct when it matches **these measured metrics**, not when it
"looks similar". This table is now the operative deliverable of §3 — more useful
than the name.

| Metric | Measured | Band | Notes |
| --- | --- | --- | --- |
| **x-height / cap** | **0.750** [m], 6 runs | **0.75 ± 0.015** | 0.72 or 0.78 is the wrong face |
| **cap `O` w/h** | **0.969** [m] | **0.97 ± 0.03** | near-circular |
| **lowercase `o` w/h** | **1.028** [m] | **1.02 ± 0.04** | wider than tall |
| **ascender / cap** | **1.031** [m] (33/32, 56/54.5) | 1.02–1.04 | ascenders barely clear the caps |
| **descender / cap** | **0.313** [m] (10/32, 9/27) | 0.28–0.33 | |
| **`M` vertex height** | stops at **16 % of cap** above the baseline [m] | — | a vertex reaching the line is the wrong face |
| **Figures** | **Old-style by default**; `3 4 5` descend 5–9 px at cap 27–47 | non-negotiable | if the substitute has no old-style set that is an impossibility to raise, not a detail to drop — **[RAISE-1]** |
| **Weights required** | **4**: ≈200 / 400 / 500 / 700 | — | a 2- or 3-weight family cannot render these screens (§5.5) |
| **Tracking** | **0 em** [m] | ±0.015 em | measured on the `ll` pair in `Collision` and the `Shima Serein` sidebearings |
| **Ligatures** | `liga` on (`fi` observed) | — | |
| **cap-height / em** | **assumed 0.70–0.72** [?] | — | not measurable without the face. Every pt size in §5 inherits ±3 % from this; **the cap heights themselves are exact** |

**The 60-second check before `packages/ui` picks a family:** set
`135 000 RWF/day — Forthing T5 — 2024 — CTO Motors Group Rentals` at cap 32 px in
each candidate, and overlay against `refs/04.png`. Reject on any of: `3 4 5` not
descending; `O` measurably oval; `n` height ≠ 0.75 × `T` height; `M` vertex on
the baseline.

---

## 4. Type scale

### 4.1 Every distinct text run, measured

Cap height and x-height are ink extents in px; `stem` is sub-pixel integrated
stroke width; `stem/cap` is the weight discriminator.

| # | Run | Screen | cap px | x-h px | stem px | stem/cap | Weight | Colour |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Profile name `Shima Serein` | 02 | **55** | 41 | 10.06 | 0.183 | Bold | `#FFFFFF` |
| 2 | Detail title `Forthing T5` | 04 | **47** | 34 | 8.54 | 0.182 | Bold | `#FFFFFF` |
| 3 | Section heading `Settings` | 02 | **37**\* | 27 | 6.70 | 0.181 | Bold | `#FFFFFF` |
| 4 | Card title `Switch to hosting mode` | 02 | **37** | 27 | 6.61 | 0.178 | Bold | `#FFFFFF` |
| 5 | Primary CTA label `Let's find a car` | 01, 03 | **36** | 27 | 5.45 | 0.147 | **Medium** | `#121212` |
| 6 | Sheet/card title `Forthing T5` | 03 | **36** | 27 | 6.68 | 0.186 | Bold | `#FFFFFF` |
| 7 | Detail price `135 000 RWF` | 04 | **36** | 27 | 6.83 | 0.190 | Bold | `#FFFFFF` |
| 7b | Detail price tail `/day` | 04 | 36 | 27 | **4.31** | **0.121** | **Regular** | `#FFFFFF` |
| 8 | Owner name `CTO Motors Group Rentals` | 04 | **32** | 24 | 6.10 | 0.191 | Bold | `#FFFFFF` |
| 9 | Sub-head `Basics and features` | 04 | **32** | 24 | — | — | Bold | `#FFFFFF` |
| 10 | Sub-head `Description` | 04 | **32** | 24 | 5.85 | 0.183 | Bold | `#FFFFFF` |
| 11 | Sticky CTA label `Check Availability` | 04 | **32** | 24 | 4.75 | 0.148 | **Medium** | `#121212` |
| 12 | Settings row label | 02 | **32** | 24 | 3.78 | 0.118 | Regular | `#FFFFFF` |
| 13 | Feature chip label | 04 | **32** | 24 | 2.12 | 0.066 | **ExtraLight** | `#FFFFFF` |
| 14 | Quick-action label `Trips` | 02 | **27** | 20 | 4.94 | 0.183 | Bold | `#FFFFFF` |
| 15 | Card price `135 000 RWF` | 03 | **27** | 20 | 5.05 | 0.187 | Bold | `#FFFFFF` |
| 15b | Card price tail `/day` | 03 | 27 | 20 | **1.65** | **0.061** | **ExtraLight** | `#FFFFFF` |
| 16 | Subtitle `Hybride - Black - 2024` | 03, 04 | **27** | 20 | 3.25 | 0.120 | Regular | `#FFFFFF` |
| 17 | Link `Show and edit my profile` | 02 | **27** | 20 | 3.05 | 0.113 | Regular | **`#C7FC2F`, underlined** |
| 18 | Category chip label `Hybride` | 03 | **27** | 20 | 3.13 | 0.116 | Regular | `#C7FC2F` |
| 19 | Hero badge label `Hybride` | 04 | **27** | 20 | ~3 | 0.111 | Regular | `#FFFFFF` |
| 20 | Body copy (description) | 04 | **27** | 20 | 1.68 | 0.062 | **ExtraLight** | `#FFFFFF` |
| 21 | Card body (`Take pictures…`) | 02 | **28** | 21 | 1.68 | 0.060 | **ExtraLight** | `#FFFFFF` |

Nothing on any screen is smaller than cap 27 px. (Basemap labels go down to cap
18 px — but they are a style layer, not a type token; §2.4.)

**\* Round vs flat caps.** Rows whose first glyph is round (`S` in `Settings` and
`Switch to hosting mode`, `C` in `Check Availability`) read 1–2 px taller than a
flat cap at the same size, because the bowl overshoots. Rows measured from a flat
cap (`L`, `T`, `D`, `H`, `F`) are exact. This is why §4.2's `heading` step spans
36–37 and why §3.3 re-derived x-height/cap using flat glyphs only.

### 4.2 The scale [held]

Cap heights collapse into **five** steps. The 36/37 and 31/32 pairs are one step
each — a 1 px spread at these sizes is measurement noise, not a design decision.

| Step | cap px | cap pt | Implied font size ([d], cap/em 0.70–0.72) | Rounded | Runs |
| --- | --- | --- | --- | --- | --- |
| **display** | 55 | 18.3 | 25.5 – 26.2 pt | **26 pt** | 1 |
| **title** | 47 | 15.7 | 21.8 – 22.4 pt | **22 pt** | 2 |
| **heading** | 36–37 | 12.0–12.3 | 16.7 – 17.6 pt | **17 pt** | 3, 4, 5, 6, 7 |
| **label** | 32 | 10.7 | 14.8 – 15.2 pt | **15 pt** | 8–13 |
| **body** | 27–28 | 9.0–9.3 | 12.5 – 13.3 pt | **13 pt** | 14–21 |

**This is the smallest scale that covers all of them without inventing sizes:
26 / 22 / 17 / 15 / 13.** It is *not* a modular scale — the successive ratios
are 1.18, 1.29, 1.13, 1.15. Do not "fix" that into a 1.2 ratio; a 1.2 scale from
13 would give 13/15.6/18.7/22.5/27, which misses `heading` by a whole point.

**The rounded pt column is the only place in this file where I rounded.** Build
against cap heights if you can.

### 4.3 Line height [held]

**Body line pitch = 45 px = 15 pt** [m] — measured over 10 consecutive lines of
the `04` description (tops at 1456, 1501, 1546 … 1861, pitch exactly 45 every
time) and confirmed independently on the 3-line `02` card body. Against a 13 pt
body that is **1.15**; against 12.5 pt, 1.20.

Every other run in the reference is a single line, so **no other line height is
measurable** [?]. Do not invent them.

### 4.4 Text decoration — the one link in the system (M3)

v1 recorded the link's colour and weight and **missed that it is underlined.**
It is the only decorated text in four screens and the only link, so the
decoration *is* the affordance.

| Property | Value |
| --- | --- |
| Run | `Show and edit my profile`, `02`, cap 27 px Regular `#C7FC2F` |
| Text ink | x382 → 824, baseline **y961** |
| **Rule** | **x380 → 825 = 446 px = 148.7 pt**, hard ends, no AA at either end |
| **Thickness** | **2.00 px = 0.67 pt** integrated — y964 at 0.249 coverage, y965 at 1.000, y966 at 0.751 |
| **Colour** | **`#C7FC2F`**, identical to the ink; the rule's centre row is pure accent for all 446 px |
| **Offset** | rule top edge y964.26 → **≈3 px = 1 pt below the baseline** |
| **Extent rule** | **advance width**, not ink width — it overhangs the ink by 2 px left and 1 px right |
| **Descender skip** | **none.** Row 965 is unbroken through the `y` of `my` (x686–716) |

That 2.00 px is the same hairline as the crosshair rule (§7.11) and the map-pin
outline (§7.3): the system has exactly **one hairline weight, 2 px = 0.67 pt**.

**Token:** `type.link = { color: accent, decoration: underline, thickness: 0.67pt,
offset: 1pt, skipInk: false }`. Note `skipInk: false` explicitly — both React
Native and the web default to skipping descenders, which would be a deviation.

### 4.5 Weight — the finding that carries the hierarchy [held]

Four weight classes separate cleanly by stem/cap:

| Class | stem/cap measured | Maps to | Used for |
| --- | --- | --- | --- |
| **ExtraLight** | 0.060 – 0.066 | ~200 | all body copy, all feature-chip labels |
| **Regular** | 0.111 – 0.120 | ~400 | subtitles, links, settings rows, category chips, hero badge |
| **Medium** | 0.147 – 0.148 | ~500 (600 possible) | **CTA labels only**, both of them |
| **Bold** | 0.178 – 0.191 | ~700 | titles, section headings, owner name, prices, quick-action labels |

Two consequences worth stating plainly:

1. **Hierarchy in this design is carried by weight and size alone.** One text
   colour plus the accent for links. See §1.3 for the exact scope of that claim.
2. **The body weight is genuinely ExtraLight at 13 pt.** At a 1.7 px stem on
   `#121212` — an 18.73 : 1 colour contrast delivered through a stroke thin
   enough that the *rendered* result greys out — that is a real legibility
   question for a product used one-handed in a car park at night. See
   **[RAISE-2]**.

---

## 5. Spacing

### 5.1 The two constants that hold across screens [held]

| Constant | px | pt | Where verified |
| --- | --- | --- | --- |
| **Content margin** | **64** | **21.3** | `01` CTA left edge, `03` CTA left edge (identical), **`03` card left/right/bottom (§7.4)**, `01`+`03` crosshair rule left/right, `04` hero left/right, `04` chips left, `04` body text left (65), `04` close button left, `04` overflow button right, `01` avatar left |
| **Card margin / card padding** | **38–39** | **12.7–13.0** | `02` hosting card left+right, `02` settings dividers left+right, `02` card inner padding on all four sides (39 px), `02` back button left |

Two margins coexist deliberately: full-bleed content sits at 64 px, the
settings/card family sits at 38–39 px. Both recur too often to be accidents.

**M2 strengthens this.** With the `03` card re-measured, the content margin now
appears on **five** edges of one element — left (128 − 65 = 63 to the
thumbnail), right (1140 − 1075 = 65 to the price), bottom (2317 − 2252 = 65
under the price), and as the 64 px gap between the card's bottom and the CTA's
top. The reference is more systematic than v1 could see, because v1 had the
card's bottom edge in the wrong place.

### 5.2 Every measured gap [held]

Vertical, `02` (profile), top to bottom:

| From → to | px | pt |
| --- | --- | --- |
| back button → avatar | 82 | 27.3 |
| avatar → name | 111 | 37.0 |
| name → link | 50 | 16.7 |
| link → quick-action circles | 97 | 32.3 |
| circles → their labels | 33 | 11.0 |
| labels → hosting card | 154 | 51.3 |
| card → `Settings` heading | 164 | 54.7 |
| heading → first row content | 69 | 23.0 |
| divider → row content (top pad) | 51–52 | 17.0–17.3 |
| row content → divider (bottom pad) | 52–53 | 17.3–17.7 |
| **settings row pitch (divider to divider)** | **176–177** | **58.7–59.0** |

Vertical, `04` (detail):

| From → to | px | pt |
| --- | --- | --- |
| top buttons → hero | 34 | 11.3 |
| hero → title | 74 | 24.7 |
| title → subtitle | 20 | 6.7 |
| subtitle → owner row | 39 | 13.0 |
| owner row → `Description` | 87 | 29.0 |
| `Description` → body | 35 | 11.7 |
| body → `Basics and features` | 59 | 19.7 |
| sub-head → chip row 1 | 62 | 20.7 |
| **chip row → chip row** | **26** | **8.7** |
| **chip → chip (horizontal)** | **27** | **9.0** |

Vertical, `03` (floating card) — **corrected against the M2 frame**:

| From → to | px | pt |
| --- | --- | --- |
| card top (y1797) → handle ink top (y1822) | **25** | **8.3** |
| handle ink bottom (y1834) → thumbnail top (y1873) | **39** | **13.0** |
| card top → thumbnail top | 76 | 25.3 |
| title → subtitle | 19 | 6.3 |
| subtitle → chip | 39 | 13.0 |
| price ink bottom (y2252) → card bottom (y2317) | **65** | **21.7** |
| **card bottom (y2317) → CTA top (y2382)** | **64** | **21.3** |

Component-internal:

| Gap | px | pt |
| --- | --- | --- |
| chip left padding → icon | 30 | 10.0 |
| chip icon → label | 18 | 6.0 |
| chip label → right padding | 26 | 8.7 |
| owner avatar → owner name | 29 | 9.7 |
| heart → share (`04`) | 31 | 10.3 |
| page-indicator dot gap | 13 | 4.3 |
| card icon tile → card text | 67 | 22.3 |
| settings row: left edge → icon ink | 7 | 2.3 |
| settings row: left edge → label | 158 | 52.7 |

### 5.3 Is there a grid? — verdict and confidence [held]

**There is no clean grid, and I am confident about that.** [d]

- Against a **4 pt grid**, the measured gaps have a mean absolute error of
  ≈1.0 pt — no better than random values at that granularity.
- Against a **2 pt grid**, mean error ≈0.6 pt. Still not a fit.
- The most attractive theory — that the reference was laid out at **375 pt and
  scaled to 402 pt** (×1.072), which turns 64 px into exactly 20 pt and 38 px
  into 12 pt — explains about half the values and breaks on the rest (the 100 pt
  thumbnail becomes 93.3, the 59 pt row becomes 54.9, the 46 pt CTA becomes
  42.9). A hypothesis and nothing more.
- Several values *are* exact points with no scaling: thumbnail **100.0 pt**,
  quick-action circle **50.0 pt**, image radius **10.0 pt**, back button
  **30.0 pt**, card padding **13.0 pt**, drag handle **60.0 pt** (new in v2).

So: some of this design is on whole points, some is not, and no single transform
reconciles both. **The reference's spacing is ad hoc.** §10.3 ships the measured
values verbatim; **[RAISE-3]** puts normalise-or-reproduce to the founder.

---

## 6. Radii

> **⚠ CORRECTED 2026-08-16 by ticket 33 — [RAISE-13] closed.** The method
> sentence below was **geometrically false** and under-read every radius here.
> All twelve rows are now fitted by supersampled analytic coverage, validated
> against ticket 32's four re-measurements. **The freeze is lifted**: files 11
> and 12 may release their `[radius frozen: RAISE-13/ticket 33]` marks against
> the corrected table. `SPEC.md` §5 still carries the old values and is amended
> together with ticket 34's extent convention.

~~All measured by corner-arc profiling: for a rounded rect the topmost scanline's
fill begins `r` px in from the left edge, and the leftmost column's fill begins
`r` px down from the top. Both checked on every row below.~~

**The identity above is wrong.** For a corner of radius `r` whose true edge lies
at offset `d` above a given scanline, that scanline's fill begins
**`r − √(2rd − d²)`** px in from the edge — *not* `r`. At the first scanline
(`d ≈ 1`) that is roughly **`r − √r`**, so the table under-reads by about `√r`,
by an amount that varies with each element's sub-pixel phase. `r` is where the
**straight edge** begins, not where the first scanline's fill does.

The file's own evidence already contradicted the values it derived. §7.4 records
that the floating card's row 1797 first carries card colour at **x79**, i.e.
14.5 px in from the true edge at x64.5 — but a 14 px radius predicts an inset of
**8.8 px** there. The observation was read *as* `r`.

Re-measured under ticket 32 by three independent estimators — a rasteriser-matched
model fit, a least-squares circle through sub-pixel boundary points, and a
**threshold-free** corner-missing-area check (`area = r²(1 − π/4)`, which needs no
arc-extent or threshold decision at all):

| Element | published | re-measured | SSE at published vs optimum |
| --- | --- | --- | --- |
| Primary CTA | 13 ±2 | **16.4** (band 16.3–16.6) | 60.7 vs 1.3 — 46× worse |
| Sticky CTA | ~14 | **16.2** (band 16.0–16.6) | 37.6 vs 2.2 — 17× worse |
| Floating card | 14 | **19.5** (band 19.3–19.8) | 133.3 vs 2.7 — 50× worse |
| Hosting card | 13 | **15.5** (band 15.2–15.8) | 37.0 vs 2.0 |
| Category chip | 31.5 | **38.4** | — |

Every one under-reads, and the error tracks `√r` as the wrong model predicts.
The **six rows not listed** — hero badge, hero image, card thumbnail, tile,
feature chip, handle — were never re-fitted and carry the same bias, which is
why the *signature* finding below ("images are rounder than containers") cannot
be confirmed or overturned until they are. **That is ticket 33's job, not this
table's.**

One consequence is already visible and matters for `radius.button`: at 16.4
(primary) against 16.2 (sticky) the two CTAs **do not differ** — a single value
fits all eight corners with zero penalty, so radius is *not* a fourth [RAISE-4]
difference, and no `radius.buttonSticky` token should be created.

| Element | radius px | radius pt | Basis |
| --- | --- | --- | --- |
| **Category chip** (`03` `Hybride`) | **pill** — ½ h = **38.4** | **12.8** | integrated box 254.75 × 76.75; fit 37.1–38.05 against a 38.4 cap, inside error |
| **Hero badge** (`04`) | **pill** — ½ h = **35.4** | **11.8** | integrated box 249.27 × 70.75; free fit **35.60, above the cap** |
| **Card thumbnail** (`03`) | **31.8** | **10.6** | four-corner joint fit, 4 089 well-conditioned px; band 30–33 |
| **Hero image** (`04`) | **31.8** [d] | **10.6** | **[?]** in its own right — inherits the thumbnail token, see below |
| **Floating card, ALL FOUR corners** (`03`) | **19.5** | **6.5** | ticket 32; re-validated at 19.50, SSE 0.55 |
| **Primary CTA** (`01`, `03`) | **16.5** | **5.5** | re-validated at 16.50, SSE 0.27 |
| **Sticky CTA** (`04`) | **16.5** | **5.5** | 16.60 measured — one token with the primary, see below |
| **Hosting card** (`02`) | **15.6** | **5.2** | ticket 32; re-validated at 15.60, SSE 0.36 |
| **Hosting-card icon tile** (`02`) | **15.2** | **5.1** | ±1 — only 5 levels of contrast (`#3E3E3E` on `#393939`) |
| **Feature chip** (`04`) | **13.4** | **4.5** | quadrant fit, SSE 0.26 |
| **Drag handle** (`03`) | **pill** — ½ h = **6.4** | **2.1** | 180.00 × 12.75; **never biased** — derived from the constraint, not the arc |
| Circles (avatars, icon buttons, pin head, indicator dots) | ½ diameter | | |

**On the hero image [?].** §7.7 blamed the photo, which is true — its corners
sample 19–21 against a background of 18. But **the backdrop is not `#121212`
either**: it is a gradient running 20 → 32 across the corner regions, reading
**32 directly below the hero's bottom edge — brighter than the photo above it**.
A fit assuming a uniform dark backdrop returns r ≈ 45–48 with deceptively good
SSE; that number is an artifact and is recorded only so it is not re-derived and
believed. The hero keeps the thumbnail's token, which is now **31.8, not 30**.

**Three corrections to the record, all material:**

1. **The primary CTA is not a pill. [held]** The record calls it a "full-width
   lime pill"; a pill on a 138 px-tall button would need r = 69 px. It measures
   **≈13 px**. The button is a *tightly* rounded rectangle, and so is the sticky
   CTA (~14 px against a 66 px pill). Building these as pills is the single most
   likely 1:1 failure in the whole system, because "lime pill" is what the record
   says and what the shape reads like at a glance.
2. **The `03` container's radius is 14 px on all four corners, not "16 top,
   square bottom".** v1 measured the top corner against a mis-placed edge and
   assumed the bottom because it assumed a bottom sheet. See §7.4.
3. **The category chip and hero badge ARE pills. [corrected, ticket 33]** v2
   said they "approach a pill but measurably fall short" at r ≈ 0.85 × half-height
   and told `packages/ui` to use an explicit radius. Both readings were products
   of the false method. The badge's free fit returns **35.60 against a geometric
   cap of 35.375** — above the cap — with SSE 15.1 at the cap against 85.4 at the
   published 32. The chip lands 0.3–1.3 px short of its own cap, inside the
   method's ±0.5 px error. **Both build as `borderRadius: 9999`.** This is the
   reverse of the instruction v2 gave, and the only §6 correction that changes
   what is typed rather than which number is typed.

The system's distinctive move is that **images are rounder than containers**:
images and thumbnails **10.6 pt**, pills 11.8–12.8 pt, containers **4.5–6.5 pt**.
That inversion **survives the re-fit [held]** — it narrows from 2.1× to **1.6×**
against the softest container and is 2.4× against the buttons, nowhere near
inverting. It must survive into `packages/ui`; every instinct will be to do the
opposite.

**Two riders on that sentence were wrong and are struck [ticket 33].**
~~Buttons are the least rounded things on the screen~~ — the feature chip is
**4.5 pt** against the button's 5.5, and it was 3.3 against 4.3 in the published
values too; the claim never survived its own table. ~~After M2 the floating card
is in the same 4.7 pt bracket as the buttons~~ — the card is **6.5 pt** against
the button's 5.5, a full point apart, and is now the *softest* container in the
system. M2 itself (all four corners equal, not "16 top, square bottom") is a
corner-count finding and is unaffected.

---

## 7. Components

### 7.1 Primary CTA (`01`, `03`) [held]

| Property | Value |
| --- | --- |
| Frame | x64 → 962, y2382 → 2519 [m] |
| Size | **899 × 138 px = 299.7 × 46.0 pt** |
| Radius | **≈13 px = 4.3 pt — a rounded rectangle, not a pill** (§6) |
| Fill | `#C7FC2F` |
| Label | `Let's find a car`, cap 36 px, **Medium**, **`#121212` — dark on lime, not black** |
| Label optical centring | 50 px above cap, 51 px below baseline [m] |
| Bottom offset | 103 px = 34.3 pt from the screen bottom |
| Paired with | 46.3 pt circular locate button to its right, 40 px (13.3 pt) gap |
| `01` vs `03` | **the CTA interior is byte-identical between the two screens** [m]; the locate button differs only in 858 anti-aliased edge pixels where the map behind it changes |

The sticky-bar variant on `04` is **not** the same component — 131–133 px tall,
513–515 px wide, label cap 32 px. See **[RAISE-4]**.

### 7.2 Circular icon buttons [held]

Five different diameters. Listed as measured; §12 raises the inconsistency
rather than harmonising it.

| Button | Screen | Diameter px | pt | Fill | Glyph |
| --- | --- | --- | --- | --- | --- |
| Close `×` | 04 | **80** | 26.7 | `#393939` (x65–144, y230–309) | `#FFFFFF`, ~3.8 px perpendicular |
| Back `←` | 02 | **90** | 30.0 | `#393939` (x39–128, y225–314) | `#FFFFFF`, 5.0 px |
| Overflow `⋯` | 04 | **98** | 32.7 | `#393939` (x1043–1140, y221–318) | 3 × `#FFFFFF` dots, ⌀ **7.6 px** |
| Locate `➤` | 01, 03 | **137–139** outer | 46.3 | `#FFFFFF` + **4 px lime ring** | **filled `#000000`** arrow |
| Quick action | 02 | **154 / 149 / 149** | 51.3 / 49.7 | `#393939` | `#FFFFFF`, 6.0–8.0 px |

The close and overflow buttons sit on the **same centre line** (y ≈ 269.5) at
different sizes — both were flood-filled, so this is not a chord artefact.

The locate button is the **only filled icon in the entire system** (§8.3) and the
only one with an accent ring.

### 7.3 Map pin [held]

| Property | Value |
| --- | --- |
| Outer bbox | **122 × 147 px = 40.7 × 49.0 pt** (w:h ≈ 1 : 1.20) [m] — core bbox (fully-covered fill), verified on the isolated pin at x961–1082, y752–898. AA-inclusive is 124 × 148. **Corrected from 120 × 147, ticket 32** — the row's own x-range always said 122; `120` was the width at which px/3 lands on a round `40.0 pt`, which is the rounding §0.1 forbids. The left and right extremes are **hard edges** (x960 pure map → x961 pure `#C7FC2F`; x1082 pure lime → x1083 pure map), so this was never a core/AA question. The widest rows are y808–817; a cut outside that band reads 120 |
| Shape | teardrop, point down |
| Body fill | `#FFFFFF` (3 560 px in the pin's box) |
| Inner disc | `#F3F3F3` (6 292 px), ⌀ ≈97 px = 32.3 pt, inset ≈8 px from the body |
| Outline | `#C7FC2F`, **2 px = 0.67 pt** |
| Glyph | line-art vehicle, **`#393939`** (477 px), AA ramp `#696969 / #979797 / #C6C6C6 / #DDDDDD` on `#F3F3F3` |
| Shadow | **none** |

That the pin body is white but carries a slightly darker inner disc is real, not
compression — both sample cleanly across many rows.

**All nine pins are one asset, and the count was wrong too [m, ticket 32].**
Template-matching the isolated pin's 588-pixel exact-`#C7FC2F` footprint across
all four screens finds **9 complete instances — 4 on `01`, 5 on `03`, none on
`02` or `04`** — each at an integer offset with a byte-identical footprint. §8.1
said ×8. Note that only **two per screen are separable by flood fill**: the rest
touch or overlap other lime elements and merge into larger components, which is
why a connected-component count reads 2 and a template count reads 4 and 5. Any
future re-count must template-match, not flood-fill.

**For EV Guide:** the pin has exactly one accent-bearing surface (the 2 px
outline) and one glyph slot. Availability is four-state with `Unknown` the
normal case (ADR-0002/0008), and the reference gives no second channel to encode
it on a pin without inventing visual language. The constraint is recorded here:
**one outline colour + one glyph is all the pin affords.**

### 7.4 The `03` container — a floating card, not a bottom sheet (M2)

This is the largest correction in v2 and it changes the component's identity.

| Property | v1 | **v2, measured** |
| --- | --- | --- |
| Frame | x64→1141, y1796→2317 | **x65 → 1140, y1797 → 2317** (AA columns at x64 / x1141, AA row at y1796) |
| Size | 1078 × 522 px | **1076 × 521 px = 358.7 × 173.7 pt** |
| Top radius | 16 px | **14 px = 4.7 pt** |
| Bottom radius | "square (sheet runs under the CTA)" | **14 px = 4.7 pt — identical to the top** |
| What is below it | assumed: screen edge | **64 px of live `#212121` map**, then the CTA at y2382 |

**Corner evidence [m].** Top-left: the first row carrying card colour (y1797)
begins at x79, i.e. 14.5 px in from the true edge at x64.5; the first column
carrying card colour (x65) begins at y1810, i.e. 13.5 px down from the true edge
at y1796.5. Bottom-left: column x65's last card pixel is y2303, i.e. 14.5 px up
from the true edge at y2317.5; row 2316 spans x77→1128 and row 2317 spans
x82→1123, the classic arc taper. **The bottom corners are rounded, and by the
same radius as the top.**

**Below-the-card evidence [m].** Column x600 reads `#121212` through y2317 and
`#212121` from y2318. Rows 2318–2381 inclusive — **exactly 64 rows** — are map.
The CTA's accent begins at y2382. There is no possible reading in which the
container reaches the screen bottom.

#### What this changes

1. **It is a card, not a sheet.** A bottom sheet is anchored to the bottom edge
   of the screen; this element floats, inset by the content margin on the left,
   the right, and (to the CTA) the bottom. `packages/ui` must name it
   **`StationCard`**, not `BottomSheet`, and must not be built on a sheet
   primitive (`@gorhom/bottom-sheet`, `ModalBottomSheet`, `UISheetPresentation`)
   whose whole contract is bottom anchoring.
2. **There is no `radius.sheet` token.** It becomes **`radius.floatingCard` =
   14 px = 4.7 pt applied to all four corners** (§10.4) — distinct from
   `radius.card` = 13 px, which is the `02` hosting card. The v1 token painted
   three of the four corners wrong.
3. **The card sits in the map layer, not above a scrim.** The map is visible on
   four sides and samples a flat `#212121` right up to the 1 px AA edge in every
   direction — no shadow, no scrim, no dimming (§9). Any implementation that
   reaches for a modal backdrop is a deviation.
4. **Detents cannot be inferred.** A drag handle is present, but the card does
   not touch the bottom, so nothing in a still says whether it expands, or to
   what. Four stills cannot answer it. **[?]** — routed to the screen inventory,
   which must decide it rather than assume the sheet semantics v1 implied.
5. **ADR-0004's route preview "in the sheet" must be re-read as "in the card"** —
   a fixed 173.7 pt box with no detents, not an expandable sheet with room to
   grow. That is a materially tighter constraint on where the route line,
   distance and ETA can go, and it is the screen inventory's problem now.

#### The corrected component

| Property | Value |
| --- | --- |
| Frame | **x65 → 1140, y1797 → 2317** [m] |
| Size | **1076 × 521 px = 358.7 × 173.7 pt** |
| Radius | **14 px = 4.7 pt, all four corners** |
| Fill | `#121212` — *the page background*, on a `#212121` map |
| Shadow / blur / scrim | **none** — flat `#212121` up to the 1 px AA edge on all four sides |
| Left / right inset | 64–65 px = 21.3 pt (the content margin) |
| Gap to the CTA below | **64 px = 21.3 pt** |
| Internal padding | **63–65 px ≈ 64 px = 21.3 pt** on left, right and bottom |
| **Drag handle** | **180 × 13 px = 60.0 × 4.3 pt**, x513 → 692, y1822 → 1834, **`#262626`**, fully rounded (r = 6.5 px), **centred on the card** (handle centre x602.5 = card centre x602.5), 25 px = 8.3 pt below the card's top edge. Contrast **1.24 : 1** |
| Thumbnail | **300 × 300 px = 100 × 100 pt**, x128, y1873, radius 30 px = 10 pt |
| Title | cap 36 px Bold, baseline 1921 |
| Subtitle | cap 27 px Regular, 19 px below |
| Category chip | 254 × 76 px = 84.7 × 25.3 pt, x480–733, y2030–2105, radius 31.5 px, `#393939` fill, **`#C7FC2F` 2.5 px border**, lime Regular label |
| **Heart** | **50 × 46 px ink = 16.7 × 15.3 pt**, x1025–1074, y1881–1926, **`#717171`** — 66 px inside the card's right edge |
| Price | cap 27 px Bold, ink x755–1075 y2217–2252, right-aligned |

**On the handle (M1).** v1's "12 × 13 px core" is a single-column reading. The
handle is 180 px wide: row y1828 runs `#262626` unbroken from x513 to x692, and
the rows taper symmetrically at both ends (y1823: 516–689; y1834: 518–687),
which is the arc of a fully-rounded pill. **Files 11 and 12 inherited the 12 px
figure from v1 and must be corrected.** At 60.0 pt wide and 1.24 : 1 it is a
conventional grabber that is very nearly invisible — a legibility fact worth
carrying into whatever the inventory decides about detents.

### 7.5 Chips — two variants, and they share nothing [held]

| | **Category chip** (`03`) | **Feature chip** (`04`) |
| --- | --- | --- |
| Size | 254 × 76 px = 84.7 × 25.3 pt | height **105 px = 35.0 pt**, width fits content (271 / 316 / 387 / 652 px measured) |
| Radius | **31.5 px = 10.5 pt** (near-pill, not a pill) | **10 px = 3.3 pt** |
| Fill | `#393939` | `#393939` |
| Border | `#C7FC2F`, 2.5 px ≈ 0.8 pt | **none** |
| Label | cap 27 px, Regular, `#C7FC2F` | cap 32 px, **ExtraLight**, `#FFFFFF` |
| Icon | none | 43 × 48 px stroke icon, **4.2 px perpendicular stroke** |
| Padding | **left 86 px / right 30 px — not symmetric** | left 30 px, icon→label 18 px, right 26 px |
| Gaps | — | 27 px horizontal, 26 px vertical |

The category chip's label is **not centred** — **86 px** of dead space on the
left against **30 px** on the right. See **[RAISE-5]**. **Corrected from 88/29,
ticket 32:** the label ink is x566–703 = 138 px (isolated from the 2.5 px lime
border ring by connected-component labelling), and the chip's own lime extent is
x480–733 = 254 px, so `86 + 138 + 30 = 254` closes exactly at the same edge the
254 is quoted at. `88 + 138 + 29 = 255` reconciles with nothing. The asymmetry
— the point [RAISE-5a] makes — is unaffected, and survives at the core edge too
(83 / 27 against the `#393939` fill run x483–730).

### 7.6 Settings rows (`02`) [held]

| Property | Value |
| --- | --- |
| Row pitch | **176–177 px = 58.7–59.0 pt** (divider to divider) [m] |
| Divider | **`#3E3E3E`, exactly 1 px = 0.33 pt**, core x39 → 1166 (AA at x38 / x1167) — **full row width, no inset**; rows y2188, y2364, y2541 |
| Icon ink | 62–68 px = 20.7–22.7 pt, left edge at x45–46 (varies with the glyph) |
| Icon stroke | **6.2–7.0 px integrated = 2.1–2.3 pt**, `#FFFFFF` |
| Label | x196, cap 32 px, **Regular**, `#FFFFFF` |
| Vertical alignment | content optically centred between dividers (51–53 px pad each side) |
| Section heading | `Settings`, cap 36 px Bold, x40, 69 px above the first row |
| Chevron / disclosure | **none** — the rows carry no trailing affordance |

### 7.7 Hero carousel + page indicator + badge (`04`)

| Property | Value |
| --- | --- |
| **Hero photo frame** | **x64 → 1141, y354 → 965 = 1078 × 612 px = 359.3 × 204.0 pt (1.762 : 1)** [m] — hard edges at all four sides, verified at x200/400/600/800/1000 (top y354, bottom y965) and at y354/y700 (left x64, right x1141) |
| Hero radius | 30 px = 10 pt — carried from v1's arc profile. **Not independently re-derivable [?]**: the corner arc can only be read where the photo's own content differs from the background, and this photo is dark and near-neutral at all four corners. The `03` thumbnail's 30 px (§6) is the clean measurement of the same token |
| Active indicator | **95 × 16 px = 31.7 × 5.3 pt** (x512–606, y924–939), fully rounded, `#C7FC2F` |
| Inactive dots | 3 × ⌀15–16 px = 5.3 pt, **`#3E3E3E`**, at x621–635, x650–664, x679–693 |
| Indicator gap | 13–15 px = 4.3–5.0 pt |
| Indicator position | the group spans x512 → 693, centre x602.5 = the hero's centre x602.5 — **exactly centred** [m]; **26 px (8.7 pt) above the hero's bottom** |
| **Badge frame** | x850 → 1097, y866 → 935 = **248 × 70 px = 82.7 × 23.3 pt** (250 × 72 with AA), radius ≈32 px = 10.7 pt (near-pill), `#C7FC2F` |
| **Badge glyph** | lightning bolt, **`#FFFFFF`, STROKED at ≈4.2 px**, ink x879–912 × y882–918 = 34 × 37 px = 11.3 × 12.3 pt |
| Badge label | cap 27 px Regular **`#FFFFFF`**, ink x930 → 1070 |
| **Badge label contrast** | **1.21 : 1** |
| Badge position | 44 px (14.7 pt) inside the hero's right edge, 30 px (10.0 pt) above its bottom |

Four indicator positions for one visible photo — the carousel is paginated, not a
scroll-strip.

**The hero carries the only gradient in the reference [m], and its mechanism is
[?].** Above and below the photo — and **only** above and below — the page
background ramps smoothly away from `#121212`:

| | Extent | Peak at the photo edge |
| --- | --- | --- |
| Above | **y325 → y353 = 29 px = 9.7 pt** | `#1A1A1A` (+8/255) |
| Below | **y966 → y1006 = 41 px = 13.7 pt** | `#202020` (+14/255) |
| Left / right | **none** — x63 is `#121212` and x64 is photo, a hard edge at y354 and y700 alike | — |

The ramp is monotone, identical to the value at x200, x400, x600, x900 and
x1100, and weakens to +4 and +3 at x80 and x1130. That x-invariance across 900 px
and strict clipping to the photo's own x-extent **rule out compression ringing**;
it is rendered. What renders it cannot be told from a still — a vertical linear
gradient on a container taller than its image, or a light-coloured shadow with a
downward offset and no horizontal spread, both fit. It is 8–14 levels out of 255,
i.e. invisible in normal use and only findable by scanning. **Recorded, not
tokenised**, and §9's blanket claim is narrowed accordingly.

**On the bolt (m4).** v1 called it "solid", making two exceptions to the
all-stroked icon rule. It is not. A coverage map of x865–920 × y870–930 shows the
bolt's interior sampling **lime, not white**, in a 15 px-wide channel between the
two limbs at rows 899–901, and the limbs themselves integrate to ≈4.2 px. It is a
stroked zig-zag outline. **The icon rule therefore has exactly one exception, not
two:** the locate arrow (§8.3).

**On R2.** The badge is `#FFFFFF` on `#C7FC2F` at **1.21 : 1**. It is the least
readable surface in the product by a factor of ten. R2's ruling — availability
never appears here, on any surface — is a direct consequence: an accent chip
reading `no confirmed status` on ~87 % of stations would be both an apology
ADR-0002 forbids and *an apology nobody can read*. The badge carries **peak
power** (`60 kW`) or is **absent**. Nothing a driver must read goes on it.

### 7.8 Sticky bottom bar (`04`) [held]

| Property | Value |
| --- | --- |
| Bar region | y2337 → 2622 = **285 px = 95.0 pt** |
| Background | **opaque `#121212`** — it clips the third chip row at y2336 with a hard edge and no gradient, so there is **no blur and no translucency** |
| Top border | **none** |
| Shadow | **none** |
| Horizontal padding | **≈89–90 px = ≈30 pt** — *not* the 64 px content margin. See **[RAISE-6]** |
| Price | `135 000 RWF/day`, cap 36 px, left, baseline 2446 — **two weights [ticket 35]**: `135 000 RWF` **Bold**, the `/day` tail **Regular** (stem 4.31 px, stem/cap 0.121). The `03` card renders the same string with an **ExtraLight** tail; both ship |
| CTA | x603 → 1115, y2363 → 2493 = **513 × 131 px = 171.0 × 43.7 pt**, radius ≈14 px = 4.7 pt (**not** a pill), `#C7FC2F`, label cap 32 px Medium `#121212` |
| Bottom offset | 128 px = 42.7 pt (vs 34.3 pt on the `01`/`03` CTA) |

### 7.9 Avatars [held, one colour corrected]

**Map avatar (`01`, `03`)**

| Property | Value |
| --- | --- |
| Circle | ⌀ **129 px = 43.0 pt**, `#FFFFFF`, **no ring** |
| Position | x64 (content margin), y362 |
| Glyph | person, **`#121212`** — *not* `#000000`; 1 149 px with a `#888888 / #4D4D4D / #C3C3C3` AA ramp, which is exactly what `#121212` on white produces |
| Status dot | ⌀ **20–21 px = 7.0 pt**, `#C7FC2F` (310 px), with a white ring ≈4 px |
| Dot placement | centre offset **(+49, −49) px** from the circle centre — 45° top-right, straddling the edge |

**Profile avatar (`02`)**

| Property | Value |
| --- | --- |
| Circle | ⌀ **316 px = 105.3 pt** outer |
| Ring | `#C7FC2F`, **≈3 px = 1.0 pt** |
| Fill | `#3E3E3E` (empty state — no image), x449–756, y402–709 |
| Position | horizontally centred (centre x602 vs screen centre 603) |

The lime ring appears on the profile avatar and **not** on the map avatar; the
map avatar carries the status dot and the profile avatar does not.

**Owner avatar (`04`)** is a 76 × 76 px photograph (the CTO Motors logo:
`#000000`, `#FF1616`, `#FFFFFF`), not an icon and not a token. Per ADR/§19 the
Owner's bundled icon fills this slot.

### 7.10 Hosting-mode card (`02`) [held]

| Property | Value |
| --- | --- |
| Frame | x39 → 1166, y1448 → 1781 = **1128 × 334 px = 376.0 × 111.3 pt** |
| Radius | 13 px = 4.3 pt |
| Fill | `#393939` |
| Padding | **39 px = 13.0 pt top and left; 38 px = 12.7 pt bottom** [m, ticket 32] — *not* uniform. Top `1487 − 1448 = 39`, bottom `1781 − 1743 = 38`, left `78 − 39 = 39`. The card's height closes as **`39 + 257 + 38 = 334`**, not `39 + 257 + 39 = 335` |
| Icon tile | 256 × 257 px = **85.3 × 85.7 pt**, `#3E3E3E` (x78–333, y1487–1743), radius ≈15 px |
| Tile glyph | lime car-with-arrow, **`#C7FC2F`**, **9.8 px integrated stroke = 3.3 pt** — the heaviest stroke in the system |
| Tile → text | 67 px = 22.3 pt |
| Title | cap 37 px Bold, baseline 1558 — **but see the caveat below; 37 is probably a round-cap over-read** |
| Body | cap 28 px ExtraLight, 3 lines, 45 px line pitch |

**Caveat on the title's cap 37 [m, ticket 32].** §4.1 row 4 measures this run
(`Switch to hosting mode`) at cap 37, and §3.3 separately names *"`S` in
`Switch to hosting mode`"* as one of the **round-cap over-reads** that read 1–2 px
tall. Both are in this file, and they contradict each other. The glyph runs
measure `S` 37 · `w` 27 · `i` 37 · `t` 35 · `c` 27 · `h` 37: **the string's only
capital is that round `S`**, and every other 37 px glyph is a lowercase
*ascender*. So no flat capital exists in this run and **cap 37 cannot have been
measured from one** — the true cap is probably 35–36, as §7.6's `Settings`
heading turned out to be. Not corrected here, because it is a type-scale
measurement rather than a component one and it should be settled with the six
un-refitted rows of §6. **Owed to ticket 33.**

### 7.11 The crosshair rule (`01`, `03`) [held]

| Property | Value |
| --- | --- |
| Horizontal rule | y249 → 250, **2 px = 0.67 pt**, `#FFFFFF` |
| Extent | x64 → 1141 — **exactly the content width**, same as the card and the CTA |
| Cross arms | 2 vertical strokes, **3 px wide × 83 px tall = 1 × 27.7 pt** |
| Arm positions | x92–94 and x1106–1108, centred on the rule |
| Arm insets | 29 px from the left end, **34 px** from the right end — **asymmetric by 5 px** |

**Purpose: still undetermined [?].** Identical on both map screens, not attached
to any control, does not move with the card, encloses nothing. It reads as a
viewfinder/registration mark. It cannot be inferred from two stills; it needs the
founder or the source app. Recorded here as geometry — **[RAISE-7]** puts the
question rather than answering it.

---

## 8. Icon system

### 8.1 Every icon in all four screens, measured exhaustively (F4)

Colour is the **core** value — the modal colour among pixels whose neighbours are
also ink, so anti-alias cannot contaminate it.

| # | Icon | Screen | Ink box px | **Core colour** | Fill/stroke | Perp. stroke px |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Map-avatar person | 01, 03 | ~60 × 55 | **`#121212`** | stroke | ~6 |
| 2 | Avatar status dot | 01, 03 | ⌀ 20–21 | **`#C7FC2F`** | fill (shape) | — |
| 3 | Pin vehicle glyph ×8 | 01, 03 | ~100 wide | **`#393939`** | stroke | 5–6 |
| 4 | Pin outline **×9** | 01 ×4, 03 ×5 | **122 × 147** | **`#C7FC2F`** | stroke | **2.0** |
| 5 | **Locate arrow** | 01, 03 | ≈41 × 45 | **`#000000`** | **FILL** | — |
| 6 | Location puck | 01, 03 | ⌀ 82 | `#4285F4` + `#FFFFFF` | fill | — |
| 7 | Back `←` | 02 | 46 × 34 | **`#FFFFFF`** | stroke | **5.0** |
| 8 | Trips (luggage) | 02 | **58 × 70** | **`#FFFFFF`** | stroke | **6.5** |
| 9 | Wishlist heart | 02 | **67 × 62** | **`#FFFFFF`** | stroke | 6.5–8.2 |
| 10 | Messages bubble | 02 | **65 × 65** | **`#FFFFFF`** | stroke | **6.0** |
| 11 | Messages notification dot | 02 | ⌀ ~20 | **`#C7FC2F`** | fill (shape) | — |
| 12 | Hosting-tile car + arrow | 02 | ~180 × 100 | **`#C7FC2F`** | stroke | **9.8** |
| 13 | Settings person | 02 | 62–68 | **`#FFFFFF`** | stroke | 6.2–7.0 |
| 14 | Settings shield-check | 02 | 62–68 | **`#FFFFFF`** | stroke | **6.5** |
| 15 | Settings banknote | 02 | 62–68 | **`#FFFFFF`** | stroke | **6.2** |
| 16 | Settings bell (clipped) | 02 | — | **`#FFFFFF`** | stroke | ~6 |
| 17 | **Card heart** | **03** | **50 × 46** | **`#717171`** | stroke | **4.8–6.0** |
| 18 | Close `×` | 04 | ~48 × 48 | **`#FFFFFF`** | stroke | **≈3.8** (5.3 raw ÷ √2) |
| 19 | Overflow `⋯` | 04 | 3 × ⌀7.6 | **`#FFFFFF`** | fill (dots) | — |
| 20 | **Hero badge bolt** | 04 | **34 × 37** | **`#FFFFFF`** | **STROKE** | **≈4.2** |
| 21 | Detail heart | 04 | **66 × 62** | **`#FFFFFF`** | stroke | 7.0–8.0 |
| 22 | Share | 04 | ~67 × 67 | **`#FFFFFF`** | stroke | **6.5** |
| 23 | Owner message bubble | 04 | ~62 × 62 | **`#FFFFFF`** | stroke | **5.6** |
| 24 | Chip shield-check ×3 | 04 | 43 × 48 | **`#FFFFFF`** | stroke | **4.2** |
| 25 | Chip Bluetooth | 04 | ~36 × 55 | **`#FFFFFF`** | stroke | **6.0** |

**The true icon colour set is four values, not two:**

| Colour | Count | Where |
| --- | --- | --- |
| **`#FFFFFF`** | 17 of 25 | everything except the six below |
| **`#C7FC2F`** | 4 | pin outline, hosting-tile glyph, and the two status dots (shapes, not glyphs) |
| **`#393939`** | 1 | pin vehicle glyph |
| **`#121212`** | 1 | map-avatar person glyph |
| **`#000000`** | 1 | **locate arrow — the only `#000000` in the product** |
| **`#717171`** | 1 | **the `03` card heart — the finding that falsifies v1's headline** |

**The heart is the same glyph three times, and one instance is different in two
ways at once [m]:** `02` Wishlist 67 × 62 `#FFFFFF`; `04` detail 66 × 62
`#FFFFFF`; `03` card **50 × 46 `#717171`**. Stroke scales proportionally
(≈10.6 % of width in all three), so it is one drawing at two sizes — but the
colour change is not a size effect. Both hearts are *outline* hearts, so this is
not a saved/unsaved fill state either. See **[RAISE-11]**.

### 8.2 Stroke weight — the claim narrowed

v1: *"6 px = 2.0 pt, uniform… the one icon rule the whole system obeys without
exception."* Integrated perpendicular measurement over 25 glyphs gives:

| Band | px | pt | Icons |
| --- | --- | --- | --- |
| Light | **4.2 – 5.0** | 1.4 – 1.7 | feature-chip icons (4.2), close `×` (3.8), badge bolt (4.2), card heart (4.8), back `←` (5.0) |
| **Nominal** | **6.0 – 6.5** | **2.0 – 2.2** | settings icons, share, Bluetooth, Messages, Trips — **the mode** |
| Heavy | **7.0 – 9.8** | 2.3 – 3.3 | detail heart (8.0), Wishlist (8.2), hosting-tile glyph (9.8) |

**The honest rule: 6 px = 2 pt is the *nominal* icon stroke and the mode of the
set, but it is not uniform — the measured range is 4.2 to 9.8 px, a factor of
2.3.** The light band tracks the smaller ink boxes (43 × 48 chip icons) and the
heavy band tracks the larger ones, so the system is closer to *constant optical
weight at a given ink size* than to a constant stroke. `packages/ui` should ship
`size.iconStroke = 2 pt` as the default and carry the two measured departures as
named exceptions rather than pretending the reference is uniform.

*(This is not a new raise — it is a measurement correction. Nothing here is
impossible to reproduce; v1 simply counted pixels touched instead of integrating.)*

### 8.3 Fill vs stroke — one exception, not two (m4)

**Every icon in the reference is stroked except one: the locate button's
navigation arrow**, which is a solid `#000000` (759 px of pure black core inside
the white circle). The hero badge's bolt, which v1 also called solid, is stroked
(§7.7).

Filled *shapes* that are not icons — the two lime status dots, the three overflow
dots, the page-indicator pills, the puck — are not exceptions to a glyph rule and
should not be counted as such.

### 8.4 Grid, terminals, provenance [held]

| Property | Measured |
| --- | --- |
| **Optical grid** | ≈**64–76 px = 21–25 pt** ink box for chrome icons; **43 × 48 px = 14 × 16 pt** for chip icons. Nominal ≈**24 pt** with per-glyph ink variation and a smaller 16 pt chip size |
| **Corner / terminal style** | rounded caps and joins, no mitres [m, visual] |
| **Known set?** | **No confident match [?]**. 2 pt on a ~24 pt box with round caps is consistent with Feather/Lucide (2 px on 24), but the heart, shield and banknote drawings do not match Feather exactly, and the car-with-arrow is custom. Treat the set as **"Feather/Lucide-compatible metrics, bespoke drawings"** and do not claim a source |

---

## 9. Elevation, blur, shadow

**No shadow, no blur, no border, no scrim on any product surface — with exactly
two sub-threshold exceptions, both characterised below rather than waved away.**
v1 said "There are none. Anywhere." That is right about every component a build
will make, and wrong as an absolute; the two exceptions are 8–14 and 1 levels out
of 255 respectively and neither is tokenised, but a design system that claims an
absolute must survive being checked against the pixels.

Checked, not assumed:

| Surface | Test | Result |
| --- | --- | --- |
| **Floating card over map, all four sides** | column scan above y1797 and below y2317, row scans beside x65 and x1140 | flat `#212121` to the 1 px AA row/column in **every** direction — **no shadow, no scrim, no dimming** |
| CTA over map | column above the button | flat `#212121` — **no shadow** |
| Map avatar over map | row beside the circle | flat `#212121` — **no shadow** |
| Map pin over map | crop at 6× | **no shadow** |
| Hosting card over page | column above the card | flat `#121212` — **no shadow** |
| Sticky bar over content | column through the clipped chip row | `#393939` at y2336 → `#121212` at y2337, **hard edge** — opaque, **no blur, no border** |
| Page background | sampled every 300 px down `02` and `04` | **flat `#121212`**, no gradient |
| Basemap | full-image histogram, both map screens | no gradient; the only non-neutral pixels are `#C7FC2F` and `#4285F4` families |
| **`04` hero, above and below** | column scans at 7 x-positions | **a monotone ramp, +8 over 29 px above and +14 over 41 px below, clipped to the photo's x-extent with no lateral component.** Rendered, not ringing. §7.7 |
| **`02` `#393939` surfaces** | column scans above and below the hosting card and the quick-action circles | **a `#111111` band — one level darker than the page — 3 px above and up to 12 px below.** 39 349 px on `02`. Consistent with either a ~3 % downward-offset shadow or DCT undershoot from a lossy source capture; **[?]**, and below any threshold at which it could be reproduced deliberately |

Both exceptions are **[?] on mechanism and are not tokens.** Neither licenses a
shadow, a blur or an elevation ramp anywhere in `packages/ui`. The `03` floating
card, both CTAs, the chips, the pins and the map avatar were each re-scanned for
v2 and every one of them meets flat background on every side: `03` card column
x600 reads `#212121` up to y1795 and `#121212` from y1797; the `04` CTA column
x800 reads `#121212` up to y2362 and accent at y2363; the `01` CTA column x500
reads `#212121` up to y2381; the `04` chips at column x200 read `#121212` up to
y2054. **No halo, no ramp, no border.**

The only depth cues in the entire system are **surface colour steps**:
`#121212` page → `#181818` water → `#212121` map → `#272727`/`#373737`/`#3C3C3C`
roads → `#393939` surface → `#3E3E3E` raised.

Adding a shadow, blur, border or gradient to any of these would breach the 1:1
rule, and the temptation will be strongest on the floating card and the sticky
bar — the two places where iOS convention says "add a blur". **Do not.** The M2
correction makes this sharper, not softer: a card floating over a map with map
visible on all four sides is precisely where a designer reaches for elevation,
and the reference has none.

**Do not reach for the hero ramp as a precedent either.** It is one element, on
one screen, at 3–5 % of a level step, with an undetermined mechanism. Citing it
to justify a card shadow would be exactly the kind of "the reference does it
somewhere" reasoning the 1:1 rule exists to stop.

---

## 10. The token set as it will exist in `packages/ui`

`packages/ui` is shared by the driver and operator apps (ADR-0006, ticket 15).
The **admin dashboard takes tokens only** — the colour, type, space and radius
primitives — and **no React Native components**. Marked **[admin]** = inherited
by the web dashboard.

### 10.1 Colour

| Token | Value | Notes |
| --- | --- | --- |
| `color.bg` | `#121212` | page **[admin]** |
| `color.map` | `#212121` | map canvas only — see also `map.ground` in §2.6 |
| `color.surface` | `#393939` | cards, chips, circular buttons **[admin]** |
| `color.surfaceRaised` | `#3E3E3E` | avatar fill, inner tiles, dividers, inactive dots **[admin]** |
| `color.accent` | `#C7FC2F` | **exactly one value, no tints, no gradients** **[admin]** |
| `color.onAccent` | `#121212` | CTA label colour **[admin]** |
| `color.text` | `#FFFFFF` | **the only text colour** **[admin]** |
| `color.divider` | `#3E3E3E` | 1 px **[admin]** |
| **`color.handle`** | **`#262626`** | **new in v2 (m5)** — the drag handle, 1.24 : 1 |
| **`color.iconMuted`** | **`#717171`** | **new in v2 (F4)** — the `03` card heart, and *only* that, pending **[RAISE-11]** |
| `color.pinBody` | `#FFFFFF` | |
| `color.pinDisc` | `#F3F3F3` | |
| `color.pinGlyph` | `#393939` | |
| `color.iconOnLight` | `#121212` | map-avatar person glyph |
| `color.iconOnLightBlack` | `#000000` | **locate arrow only** — see **[RAISE-8]** |

Deliberately absent: any `text.secondary`, `text.muted`, opacity ramp, elevation
colour, or accent tint. §4.5 and §9 say the reference has none. `color.iconMuted`
is **not** a text token and must not be used as one.

The `map.*` namespace (§2.6) is separate and is consumed by the MapLibre style,
not by React Native.

### 10.2 Typography

| Token | Value |
| --- | --- |
| `font.family` | **unresolved — see §3.4/§3.5.** Do not pick a family from this file |
| `font.weight.extraLight` | 200 |
| `font.weight.regular` | 400 |
| `font.weight.medium` | 500 |
| `font.weight.bold` | 700 |
| `type.display` | 26 pt / cap 18.3 pt / Bold |
| `type.title` | 22 pt / cap 15.7 pt / Bold |
| `type.heading` | 17 pt / cap 12.0 pt / Bold *(Medium on CTA)* |
| `type.label` | 15 pt / cap 10.7 pt / Bold · Medium · Regular · ExtraLight |
| `type.body` | 13 pt / cap 9.0 pt / line-height **15 pt** / Regular · ExtraLight |
| `type.tracking` | 0 at every size |
| **`type.link`** | **accent · underline · 0.67 pt thick · 1 pt below baseline · `skipInk: false`** — new in v2 (M3) |
| `type.figures` | **old-style / `onum`** — a required feature, not a preference (§3.2) |

All **[admin]**, except that the dashboard is a different medium and its line
lengths will not match; it inherits sizes and weights, not layout.

### 10.3 Spacing — measured values, verbatim

Named after where they were measured, not after a grid position, because §5.3
found no grid.

| Token | px | pt |
| --- | --- | --- |
| `space.pageMargin` | 64 | 21.3 |
| `space.cardMargin` | 38 | 12.7 |
| `space.cardPadding` | 39 | 13.0 |
| `space.floatingCardPadding` | 64 | 21.3 |
| **`space.floatingCardBottomGap`** | **64** | **21.3** |
| `space.stickyBarPadding` | 90 | 30.0 |
| `space.chipGap` | 27 | 9.0 |
| `space.chipRowGap` | 26 | 8.7 |
| `space.chipPaddingH` | 30 | 10.0 |
| `space.chipIconGap` | 18 | 6.0 |
| `space.titleToSubtitle` | 20 | 6.7 |
| `space.blockGap` | 39 | 13.0 |
| `space.sectionGap` | 62 | 20.7 |
| `space.sectionGapLarge` | 87 | 29.0 |
| `size.settingsRow` | 176 | 58.7 |
| `size.iconGrid` | 72 | 24.0 |
| `size.iconGridChip` | 48 | 16.0 |
| `size.iconStroke` | 6 | 2.0 |
| `size.hairline` | 2 | 0.67 |

**[admin]** for all of them, with the caveat that the dashboard's own margins are
a web problem this file does not solve.

### 10.4 Radius

| Token | px | pt | Applies to |
| --- | --- | --- | --- |
| `radius.chip` | 10 | 3.3 | feature chips |
| `radius.card` | 13 | 4.3 | hosting card |
| `radius.button` | 13 | 4.3 | **both CTAs** — see §6, this is not a pill |
| **`radius.floatingCard`** | **14** | **4.7** | **the `03` card — all four corners** (was `radius.sheet` = 16, top only) |
| `radius.handle` | 6.5 | 2.2 | ½ the handle's height |
| `radius.image` | 30 | 10.0 | hero, thumbnails |
| `radius.nearPill` | 31.5 | 10.5 | category chip, hero badge |
| `radius.circle` | 9999 | — | avatars, icon buttons, dots |

**There is no `radius.pill` token, deliberately** — nothing in the reference is
one. **There is no `radius.sheet` token either** — there is no sheet.
**[admin]**, and the images-rounder-than-buttons inversion (§6) is the part the
dashboard must not "fix".

### 10.5 Component sizes

| Token | px | pt |
| --- | --- | --- |
| `size.ctaHeight` | 138 | 46.0 |
| `size.ctaHeightSticky` | 131 | 43.7 |
| `size.circleButton.sm` | 80 | 26.7 |
| `size.circleButton.md` | 90 | 30.0 |
| `size.circleButton.lg` | 98 | 32.7 |
| `size.circleButton.xl` | 139 | 46.3 |
| `size.quickAction` | 150 | 50.0 |
| `size.avatarMap` | 129 | 43.0 |
| `size.avatarProfile` | 316 | 105.3 |
| `size.avatarOwner` | 76 | 25.3 |
| `size.thumbnail` | 300 | 100.0 |
| `size.chipHeight` | 105 | 35.0 |
| **`size.floatingCard`** | **1076 × 521** | **358.7 × 173.7** |
| **`size.handle`** | **180 × 13** | **60.0 × 4.3** |
| `size.pin` | **122 × 147** | **40.7 × 49.0** |
| `size.statusDot` | 20 | 7.0 |
| `size.accentRing` | 3 | 1.0 |
| `size.puck` | 40 disc / 82 halo | 13.3 / 27.3 |

Native only — the admin dashboard inherits none of §10.5.

---

## 11. Copy tokens — the single normative list (R1, R3, R4)

Per **R3** this list exists in exactly one place, and **that place is
`docs/availability-display.md`** — §2.2b for the forbidden strings, §2.4 for the
closed vocabulary. This section cites it and does not hold it; so do files 11
and 12. *Corrected by ticket 32, which found this preamble claiming ownership
for §11 while three other documents claimed it too.* The words themselves are
**data in `packages/domain`** (availability-display.md §2.4), not string literals
in a Swift file and a Kotlin file; this section is the normative statement of
what that data may and may not contain, and `packages/domain` enforces it with a
test that greps the emitted vocabulary.

### 11.1 The one word for `Occupied` (R1) — cited, not held

The three-row mapping (driver-facing `busy` · operator-facing `busy` · the
operator write-surface control label `Busy`) now lives in
`docs/availability-display.md` **§2.4**, with the rest of the closed vocabulary.
Ticket 32 moved it there: this section was the only place it was enumerated, and
it sat under a preamble that forbade exactly that.

`busy` quantifies `o` and nothing else (§2.2 law 3). **`in use` is deleted
product-wide** and must not appear in any file, fixture or component — note the
capitalised **`In use`** is the same ban and is still in circulation in files 11
and 12.

### 11.2 Forbidden strings — cited, not held

**The list lives in `docs/availability-display.md` §2.2b and nowhere else.**

This section previously held a six-row copy. Ticket 32 found that the copy was
**not** a subset of §2.2b — it uniquely carried `last reported`,
`awaiting a report`, `no reports yet` and the catch-all clause *"or any phrasing
that asserts a report exists, does not exist, or is old"* — so the four
competing copies in circulation could not simply be deleted down to one without
dropping live bans. Those four items were merged into §2.2b on 2026-08-14, and
this table was then replaced by this pointer.

Adding a string is a change to `packages/domain`, and every addition needs a
fixture in the shared corpus (availability-display.md §3).

### 11.3 The short rate projection (R4)

Defined **once**, in `packages/domain`, for the card / floating-card / sticky
slots. The long Grammar-R ladder stays on the detail screen only.

| Input | `rateShort` returns | Rendered |
| --- | --- | --- |
| exactly one Connector rate confirmed | `{kind: 'single', rwfPerKwh}` | **`600 RWF/kWh`** |
| more than one distinct confirmed rate | `{kind: 'from', floorRwfPerKwh}` | **`From 400 RWF/kWh`** |
| no confirmed rate | `{kind: 'none'}` | **`No confirmed rate`** |

**The projection returns structure, never a formatted string** —
`docs/domain-model.md` amendment 8, which is binding and which the previous
version of this table violated by presenting the rendered strings *as* the
projection. The closed vocabulary (availability-display.md §2.4) supplies the
words; the structural signature is file 11 §13.2. *Corrected by ticket 32.*

Rate is a **Connector** property (grammar law 7): a dual-gun pedestal can carry
two rates, and the short slot must never assert a station-level rate. The
`From …` form is what makes the projection honest at station scope.

**Where each slot renders it, measured:** the `03` card's price slot is cap 27 px
`#FFFFFF`, right-aligned, ink right edge x1075 (65 px inside the card); the `04`
sticky slot is cap 36 px, left-aligned, baseline 2446. Both are single lines with
no room for the long ladder, which is the layout reason R4 exists.

**Neither slot is one weight — [RAISE-15], and this sentence used to say Bold.**
The amount is Bold and **the unit tail is lighter**, by a different amount in
each slot [m, ticket 32, integrated stem coverage]: `04` sticky at cap 36, `F` of
`RWF` 6.92 px (stem/cap 0.192, Bold) against `d`/`a`/`y` 4.36 / 4.21 / 4.37 px
(0.121, **Regular**); `03` card at cap 27, `1` 5.19 px and `F` 5.22 px (0.192,
Bold) against `d`/`a` 1.65 px (0.061, **ExtraLight**). §4.1 row 15 and §7.8 carry
the same single-weight error and are **not** corrected here — the weight
assignment per slot is RAISE-15's to settle, and a build must not type either
version until it does.

---

## 12. Raised: impossibilities, contradictions and open questions

Per the standing rule these are **raised, not resolved.** None has been
substituted, harmonised or improved in the sections above; §§1–11 report what is
there. **RAISE-1 through RAISE-9 are carried forward unchanged from v1;
RAISE-10, RAISE-11 and RAISE-12 are new in v2.**

**[RAISE-1] The typeface may be unnameable, and its figures may be
unreproducible.** §3 now reaches *lower* confidence than v1 did, not higher: the
best-named candidate fails two measured metrics. Separately, the reference's
**old-style figures** — `3 4 5` descending below the baseline in prices, years
and model numbers — are a substantial part of its character. If the chosen face
has no old-style set, that character cannot be reproduced, and no substitution is
equivalent. §3.5 gives the acceptance test; the family choice is a founder call.

**[RAISE-2] The body weight is ExtraLight (≈200) at 13 pt on `#121212`.** A
1.7 px stem. Reproducing it 1:1 is straightforward; whether EV Guide *should*,
for a product read one-handed in a dim car park and used offline, is a founder
call. The reference is unambiguous, so the default is to reproduce it.

**[RAISE-3] The spacing is not on a grid (§5.3) — normalise or reproduce?**
Reproducing verbatim honours 1:1 and gives `packages/ui` twenty oddly-named
constants. Normalising to 4 pt gives a clean system and a ~1 pt deviation on most
values, which is a deliberate deviation and therefore needs saying yes to. §10.3
currently ships the measured values.

**[RAISE-4] The two primary CTAs are different components.** `01`/`03`: 138 px
tall, label cap 36 px. `04` sticky: 131 px tall, label cap 32 px. Also different
bottom offsets (34.3 pt vs 42.7 pt). Either the reference has two CTA sizes on
purpose or this is drift; 1:1 means shipping both unless told otherwise.

**[RAISE-5] Four alignment defects in the reference.**
(a) The `Hybride` category chip's label is not centred — **86 px** left padding
against **30 px** right (corrected from 88/29, ticket 32; §7.5).
(b) `Basics and features` starts at x79 while `Description`
starts at x68 — an 11 px (3.7 pt) mismatch between two peer sub-heads on the same
screen. (c) The crosshair's cross arms are inset 29 px from the left end and
34 px from the right. (d) The three profile quick actions are **not evenly
spaced**: circle 1 measures ⌀154 px against ⌀149 px for the other two, with
unequal gaps. All four are visible at 1×. Reproducing defects is the literal
reading of 1:1; correcting them is a deviation. Needs a ruling.

**[RAISE-6] The sticky bar ignores the content margin.** 90 px (30 pt) padding
against the 64 px (21.3 pt) used by every other element on the same screen,
including the chips directly above it.

**[RAISE-7] The crosshair rule's purpose is unknown (§7.11).** Fully measured,
but a still cannot say what it does. It appears on both map screens and nowhere
else. EV Guide has to decide whether it carries over at all — and if it does,
what it means — before the map screen can be specified.

**[RAISE-8] Two different "black"s in the system.** The CTA label is `#121212`,
and v2 shows the map-avatar's person glyph is `#121212` too — so the odd one out
is a single glyph: the locate button's arrow at `#000000`. One value in one place
against `#121212` everywhere else. Probably a mistake, and 1:1 does not say which.

**[RAISE-9] Circular icon buttons come in five diameters** (26.7 / 30.0 / 32.7 /
46.3 / 50 pt), including two on the *same screen at the same centre line* — the
`04` close button (26.7 pt) and overflow button (32.7 pt). Both were flood-filled,
so this is not a measurement artefact. A design system wants one or two sizes;
1:1 wants five.

**[RAISE-10 — NEW] The location puck is Google's brand blue.** `#4285F4` with a
19 % halo (§2.5) is the only foreign brand colour in the four screens and the
only saturated colour besides the accent. Under MapLibre EV Guide draws its own
puck, so 1:1 means deliberately shipping Google's blue in a map that is not
Google's. The alternatives — the lime accent, or a neutral white — are both
deviations, and the lime one collides with the pin outline, which is the same
colour. Needs a ruling before the map screen can be specified.

**[RAISE-11 — NEW] The same heart icon is two colours and two sizes.** `02`
Wishlist and `04` detail: 66–67 × 62 px, `#FFFFFF`. `03` card: 50 × 46 px,
**`#717171`** at 3.84 : 1. Both are outline hearts, so it is not a saved/unsaved
fill state, and the stroke scales proportionally, so it is one drawing. Either
the card's heart is deliberately de-emphasised (a legitimate move — the card is a
preview, the detail screen is the commitment) or it is drift. **This matters
beyond aesthetics: the heart is the ADR-0003 auth trigger**, so how prominent it
is on the card is a gating decision, not a colour decision. 1:1 means shipping a
grey heart on the card and a white one on the detail screen unless told otherwise.

**[RAISE-12 — NEW] The basemap's minor label tier fails text contrast, and under
MapLibre that becomes EV Guide's decision.** `#757575` on `#212121` is
**3.49 : 1** (§2.4) — below 4.5 : 1 for normal text and below 3 : 1 only for
large text, which cap-18 px is not. In the reference this is Google's choice
rendered into a screenshot; under MapLibre it is a value EV Guide types into its
own style JSON, which converts a reproduction into an authored accessibility
decision. Reproducing it 1:1 is defensible (it is a basemap label, not product
copy, and every one of those names is duplicated in the station data); lifting it
is a deliberate deviation. Needs a ruling.

**[RAISE-13 — NEW, ticket 32 → ticket 33] Every radius in §6 is under-read,
because §6's method sentence states a false geometric identity.** The topmost
scanline's fill does not begin `r` px in from the edge; it begins
`r − √(2rd − d²)`, i.e. roughly `r − √r`. Five rows re-measured by three
independent estimators (including a threshold-free area check) come back
**16.4 / 16.2 / 19.5 / 15.5 / 38.4** against published **13 / 14 / 14 / 13 /
31.5** — every one low, with the error tracking `√r`. §7.4's own quoted corner
evidence (row 1797 first carries card colour at x79, 14.5 px in) is incompatible
with the 14 px it was used to justify, which predicts 8.8 px. **Six rows have not
been re-fitted**, so the system's signature finding — *images are rounder than
containers* — could be neither confirmed nor overturned at the time.

**CLOSED 2026-08-16 by ticket 33.** All six were re-fitted and §6 is corrected.
The signature finding **holds** (images 10.6 pt against containers 4.5–6.5 pt,
narrowed from 2.1× to 1.6× but nowhere near inverting), but **two riders on it
were false and are struck** — buttons are *not* the least-rounded thing (the
feature chip is), and the floating card is *not* in the buttons' bracket (6.5 pt
against 5.5). The material change for `packages/ui` is that **the category chip
and the hero badge are pills**, not near-pills: `borderRadius: 9999`, the reverse
of what v2 instructed. The hero image is confirmed **[?]** — its backdrop is a
20 → 32 gradient, not `#121212`, so a fit that assumes a dark ground returns a
plausible-looking 45–48 that is pure artifact. **`SPEC.md` §5's radius table is
wrong in all seven rows and is still to be amended**, bundled with ticket 34.

**[RAISE-14 — NEW, ticket 32 → ticket 34] The extent convention is undeclared,
and this file uses two.** See §0.1. The primary CTA is published AA-inclusive,
the floating card core; each candidate convention breaks 2, 3 or 4 values locked
in `SPEC.md`. Ticket 32 asked for a declaration and correctly could not make one
unilaterally.

**[RAISE-15 — NEW, ticket 32] The price string is two weights, and this file
calls it one.** §4.1 row 15, §7.8 and §11.3 all describe `135 000 RWF/day` as a
single Bold run. It is not: the **unit tail is lighter than the amount**, and the
two slots use *different* lighter weights. Integrated stem measurement [m,
ticket 32] — `04` sticky, cap 36: `F` of `RWF` 6.92 px (stem/cap 0.192, Bold),
`d`/`a`/`y` 4.36 / 4.21 / 4.37 px (0.121, **Regular**); `03` card, cap 27: `1`
5.19 px and `F` 5.22 px (0.192, Bold), `d`/`a` 1.65 px (0.061, **ExtraLight**).
File 11 §13.2 is right that two weights exist but assigns Regular to all four
consuming slots. This lands in §11.3 — a section ticket 32 was about to
propagate into files 11 and 12 — so it is raised before it spreads.

**CLOSED 2026-08-16 by ticket 35: ship both, as measured.** The founder ruled it
the same way as [RAISE-4] and [RAISE-11] — 1:1 means shipping the reference's own
inconsistency, not tidying it. §4.1 gains rows **7b** and **15b**, and §7.8 states
both weights. **No projection change is owed**: `rateShort` already returns
numbers, not a formatted string (`domain-model.md` amendment 8), so the slot
composes the three runs itself — amount and currency Bold everywhere, and the
tail's weight a property of the **slot**. The composition rule lands in file 11
§13.2.

**Already raised by the ticket, restated because it lands in this file:** the
`Google` wordmark on the map screens cannot be reproduced under MapLibre (ticket
17's routed finding from 06). It sits at the map's bottom-left, above the CTA, in
`#FFFFFF` with a `#0D0D0D` outline, and it is the only element of these four
screens that is provably impossible. **v2 narrows what else is at risk:** with §2
measured, the basemap's *palette* is fully reproducible; what is not reproducible
from stills is Google's label ranking and generalisation (§2.4, marked [?]) and
the width stop function outside the two captured zooms (§2.2). **Rebero and
Remera do not exist in OSM as places** and need adding upstream.

### Could not be measured

- **cap-height / em** for the face (§3.5) — needs the identified font. Every pt
  font size in §4.2 carries ±3 % from this.
- **Line height for anything but body copy** — every other run is one line.
- **Whether the `03` card expands, and to what** — §7.4. A handle is present and
  the card does not touch the screen bottom, so detents cannot be inferred.
- **The basemap's zoom stop functions and label ranking** — §2.
- **Which OSM classes map to which of the three road tiers** — the tiers are
  measured; the mapping is a style-authoring decision.
- **What renders the `04` hero's vertical ramp** (§7.7) and what renders `02`'s
  `#111111` band (§9) — both are measured to the level; neither mechanism is
  recoverable from a still, and both are below the threshold at which a build
  could reproduce them on purpose.
- **The `Messages` notification dot** (`02`) — same construction as the map
  avatar's status dot by inspection, `#C7FC2F`, not separately measured for
  diameter.
- **Pressed / disabled / focus states** — no screen shows one. The record's
  "accent shade `#9EC52B`" is anti-aliasing on pin outlines, **not** a pressed
  state; there is no evidence of a second accent value anywhere.
- **Any motion, transition or gesture behaviour** — four stills.

---

## 13. What this file does not decide

The ticket's other half: the screen inventory, `Payment & payouts`'s replacement,
the `Switch to hosting mode` cross-app affordance, the three profile quick
actions, how availability reads on a pin, the ADR-0004 route preview inside the
existing screens (now constrained by §7.4 — a fixed 173.7 pt card, not an
expandable sheet), the ADR-0003 auth sheet (triggered by save and report, **not**
directions — ticket 23; and see RAISE-11 on how prominent the save trigger is),
and the ADR-0007 offline surfaces. Those are design decisions that consume this
system; they belong in the inventory document, not here.
