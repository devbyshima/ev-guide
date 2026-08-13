# 10 — Design system, measured from the reference

Ticket 17, part 1 of 2. This file is the **design system**: typeface, type scale,
spacing, radii, components, icons, elevation, tokens. The screen inventory and
the domain mappings are the ticket's other half and are **not** decided here.

Everything below was measured off the pixels of `refs/01.png`–`refs/04.png`.
Nothing is estimated by eye unless it says so.

## 0. Method, units, and how to read this file

**Captures.** `1206 × 2622 px` = iPhone 16 Pro at @3x = `402 × 874 pt`.
**px is the authoritative unit here**; `pt = px / 3` is given alongside because
that is what a build types. Where px/3 is not a whole number the pt value is
shown to one decimal and **is not rounded to a nicer number**.

**Marking legend**

- **[m]** — measured directly from pixels. Reproducible from the scripts' logic.
- **[d]** — derived from one or more [m] values by stated arithmetic.
- **[?]** — could not be measured reliably; the reason is given.
- **[RAISE]** — a place the reference cannot be reproduced 1:1, or contradicts
  itself, or contradicts an EV Guide decision. Per the standing rule these are
  raised, not quietly resolved. **Nine of them are listed in §9.**

**Sub-pixel technique.** Stroke widths are integrated coverage, not thresholded
pixel counts: for a horizontal cut across a stem, `Σ (v − bg)/(fg − bg)`. This
resolves a stem to roughly ±0.1 px and is why the weight classes in §2 separate
cleanly instead of quantising to 2 px / 3 px.

**Colour corrections to `refs/design-observations.md`.** Two rows of the
measured palette are wrong and one is missing:

| Role | In the record | Measured here | Why the record differs |
| --- | --- | --- | --- |
| Surface raised | `#3C3C3C` | **`#3E3E3E`** [m] | `#3C3C3C` is the *mean* of `#393939` and `#3E3E3E` across a scan line that crossed the card/tile boundary. The true value appears pure in the divider, the page-indicator dots, the avatar fill and the hosting-card icon tile. |
| Chip / secondary text | "grey text" | **`#FFFFFF`** [m] | There is no grey text anywhere. Every text core samples `#FFFFFF`. The grey *appearance* is an ExtraLight weight at a ~1.7 px stem anti-aliasing against `#121212`. See §2.4 — this is the single most important finding in the file. |
| On-accent label | — | **`#121212`** [m] | The CTA label is the page background colour, not black. The locate button's arrow glyph *is* `#000000`. [RAISE-8] |

Everything else in the record's palette verified exactly, including
`#C7FC2F` appearing as one value with no tints anywhere in four screens.

---

## 1. The typeface

The observation record says "likely Poppins". **Poppins is ruled out.**

### 1.1 Glyph diagnostic

Crops taken at 6×–18× nearest-neighbour from `Shima Serein` (02, cap 55 px),
`Let's find a car` (01), `CTO Motors Group Rentals` (04), `Forward Collision
Warning` (04, a Thin weight that exposes the skeleton), `technology.` (04) and
`Hybride` (03).

| Test | Reference shows | Consequence |
| --- | --- | --- |
| **`a`** | **Double-storey**, small bowl, **no spur/tail** at the bottom right of the stem | **Rules out Poppins, Outfit, Jost, Futura, Century Gothic, Product Sans/Google Sans** (all single-storey `a`). Also argues against Proxima Nova and Figtree, whose `a` carries a tail. |
| **`g`** | **Single-storey**, open hook descender, does not close | Rules out Gill Sans and other binocular-`g` humanists. |
| **`t`** | Apex **cut at an angle**; foot curves right | Rules out Montserrat, Proxima Nova, SF Pro (flat apexes). |
| **`l`** | Plain stem, **no tail** | Rules out SF Pro Text, Corbel-class faces. |
| **`y`** | **Straight diagonal** tail, no hook, no curl | Consistent with the geometric group. |
| **`G`** | Bar + vertical, **no spur** above the bar | Rules out SF Pro (spurred `G`). |
| **`M`** | **Vertical sides**, apex pointed, **middle vertex stops above the baseline** | Rules out Montserrat and Poppins (vertex reaches the baseline). |
| **`W` / `w`** | Middle apex reaches **full cap / full x-height**; straight strokes; not crossed | Consistent with a modern Raleway cut (the crossed `w` was removed after v1). |
| Terminals on `c e s a r` | **Cut at an angle** (canted), wide apertures | Rules out Montserrat, Proxima Nova, Figtree (horizontal/vertical cuts). |
| `fi` in "find" | **True ligature**, dot absorbed | Face has real OpenType `liga`. |
| Dots on `i / j` | Round | — |
| **cap `O` w/h** | 31 × 32 px = **0.97** [m] | Near-circular. This is the one measurement that *argues against* Raleway. |
| **lowercase `o` w/h** | 24 × 24 px = **1.00** [m] | Same. |

### 1.2 The decisive finding: the figures are old-style

This is the rarest and most diagnostic feature present, and it is unambiguous
across three independent runs.

| Run | Glyph | Ink top → bottom | Baseline | Verdict |
| --- | --- | --- | --- | --- |
| `135 000` (04) | `1` | 2418 → 2446 | 2446 | sits at x-height (29 px vs x-height 27 px), has a **foot bar** |
| | `0` | 2417 → 2446 | | x-height + overshoot |
| | `3`, `5` | 2418 → **2453** | | **descend 7 px below the baseline** |
| `2024` (04) | `2`, `0` | 1145 → 1166 | 1166 | x-height |
| | `4` | 1145 → **1171** | | **descends 5 px** |
| `T5` (04) | `5` | → **1111** | 1102 | **descends 9 px** |

Digits sit at ~x-height (22 px against a 20 px x-height and a 27 px cap) and
`3 4 5` hang below the line. That is textbook **old-style / text figures**
(`0 1 2` at x-height, `3 4 5 7 9` descending, `6 8` ascending), and it is the
face's *default* set — the app never opts into `onum` mid-sentence.

Almost no geometric sans ships old-style as the default. This single fact
eliminates every "looks about right" candidate at once: Circular Std, Aeonik,
GT Walsheim, Gilroy, Greycliff CF, General Sans, Satoshi, Airbnb Cereal,
Montserrat, Proxima Nova, Figtree — **all ship lining figures by default.**

### 1.3 Ranked identification

**1. Raleway (SIL OFL, Google Fonts) — best fit, ~65–70% confidence**

For: it is the one widely-deployed family whose *default* figure set is
old-style — the most-asked-about quirk of the face and an exact match for §1.2.
It also satisfies every row of §1.1: double-storey spurless `a`, single-storey
open-hook `g`, angled `t` apex with a curved foot, plain `l`, straight `y` tail,
spurless `G`, vertical-sided `M` with a raised vertex, canted terminals, `fi`
ligature, and a **full Thin(100)→Black(900) range** — which the reference
demands, because §2.4 measures a genuine ExtraLight body weight alongside Bold.
It is free, which matters both for a Kigali indie build and for EV Guide's own
licensing. The app is otherwise a literal Airbnb clone (`Trips`, `Wishlist`,
`Messages`, `Payment & payouts`, `Switch to hosting mode` are Airbnb's own
strings), and a free Cereal-alike from Google Fonts is exactly what that
implies.

Against: measured cap `O` w/h = 0.97 and lowercase `o` w/h = 1.00 read more
geometric than Raleway usually does (≈0.90–0.93). Measured x-height/cap of
**0.745–0.775** also runs 2–5% above Raleway's ≈0.72. Both are within the error
bar of a 24–55 px ink measurement, but they are the reason this is 65–70% and
not 90%.

**2. A geometric sans with `onum` deliberately enabled — ~20%**

Any of Circular Std, Aeonik, GT Walsheim, Gilroy, Greycliff CF, General Sans or
Satoshi would satisfy §1.1 and the `O`/`o` circularity *better* than Raleway,
but only if the developer explicitly turned on old-style figures (Flutter
`FontFeature.oldstyleFigures()`, CSS `font-variant-numeric: oldstyle-nums`).
That is an unusual thing for this kind of app to do, and it would have to have
been applied consistently to prices, years and model numbers alike — which is
what we observe. Cannot be excluded.

**3. Airbnb Cereal — ~5%**

The IA is copied from Airbnb verbatim, so a ripped Cereal is imaginable. Cereal
matches most of §1.1 but has lining figures, and it is not licensable, so it is
unusable for EV Guide regardless.

**Ruled out with confidence:** Poppins (double-storey `a`), Outfit / Jost /
Futura / Century Gothic / Product Sans (single-storey `a`), **the iOS system
font** — the status bar in the same screenshots is a free SF Pro control and
differs on the `t` apex, the `G` spur and the figures — Montserrat, Proxima
Nova, Figtree (terminals, `t`, `a` spur, lining figures).

**Honest statement of confidence.** I am **high-confidence on the
classification** (geometric-leaning sans, double-storey `a`, single-storey `g`,
canted terminals, old-style figures, four weights in use) and only
**moderate-confidence on the name**. Naming it from a 3× screenshot without the
candidate fonts installed to overlay is not something to be more certain about
than that. **The 30-second check that settles it:** set `135 000 RWF/day —
Forthing T5 — 2024 — Basics and features` in Raleway Regular and Bold and
compare the descenders on `3 4 5`, the `M` vertex and the `t` apex against
`refs/04.png`. Do that before `packages/ui` picks a face.

### 1.4 The fallback that matters more than the name

If the exact face turns out to be unlicensable, a substitute is correct when it
matches **these measured metrics**, not when it "looks similar".

| Metric | Measured | Notes |
| --- | --- | --- |
| **x-height / cap-height** | **0.745 – 0.775**, 4 independent runs [m] | 41/55, 24/32, 27/36, 24/31. Use **0.75 ± 0.02** as the acceptance band. A face at 0.70 or 0.80 is the wrong face. |
| **ascender / cap-height** | **1.02 – 1.04** [m] | Ascenders barely clear the caps (56 vs 55 px; 33 vs 32 px). A face whose `l` towers over `H` is wrong. |
| **descender / cap-height** | **0.28 – 0.31** [m] | 9 px on cap 32; 11 px on cap 36. |
| **cap-height / em** | **assumed 0.70–0.72** [?] | Not measurable without the identified face. Every "font size" in §2 inherits this uncertainty (±3%); the **cap heights themselves are exact**. |
| **lowercase `o` ink w/h** | **1.00** [m] | Circular bowls. |
| **cap `O` ink w/h** | **0.97** [m] | |
| **Figures** | **Old-style default**, `3 4 5` descending | Non-negotiable if the reference is to be reproduced 1:1. If the substitute has no old-style set, that is an impossibility to raise, not a detail to drop — see [RAISE-1]. |
| **Weights required** | **4**: ExtraLight ≈200, Regular ≈400, Medium ≈500, Bold ≈700 | Measured stem/cap ratios in §2.4. A 2- or 3-weight family cannot render these screens. |
| **Tracking** | **Default (0 em)** [m] | Measured on the `ll` pair in "Collision": 12 px pitch against ≈11.5 px expected default advance, and on the `Shima Serein` sidebearings (7–10 px at cap 55 ≈ 0.05 em/side). No size shows deliberate tracking. Resolution ±0.015 em. |
| **Ligatures** | `liga` on (`fi` observed) | |

---

## 2. Type scale

### 2.1 Every distinct text run, measured

Cap height and x-height are ink extents in px; `stem` is sub-pixel integrated
stroke width; `stem/cap` is the weight discriminator.

| # | Run | Screen | cap px | x-h px | stem px | stem/cap | Weight | Colour |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Profile name `Shima Serein` | 02 | **55** | 41 | 10.06 | 0.183 | Bold | `#FFFFFF` |
| 2 | Detail title `Forthing T5` | 04 | **47** | 34 | 8.54 | 0.182 | Bold | `#FFFFFF` |
| 3 | Section heading `Settings` | 02 | **37** | 27 | 6.70 | 0.181 | Bold | `#FFFFFF` |
| 4 | Card title `Switch to hosting mode` | 02 | **37** | 27 | 6.61 | 0.178 | Bold | `#FFFFFF` |
| 5 | Primary CTA label `Let's find a car` | 01, 03 | **37** | 28 | 5.45 | 0.147 | **Medium** | `#121212` |
| 6 | Sheet title `Forthing T5` | 03 | **36** | 27 | 6.68 | 0.186 | Bold | `#FFFFFF` |
| 7 | Detail price `135 000 RWF` | 04 | **36** | 27 | 6.83 | 0.190 | Bold | `#FFFFFF` |
| 8 | Owner name `CTO Motors Group Rentals` | 04 | **32** | 24 | 6.10 | 0.191 | Bold | `#FFFFFF` |
| 9 | Sub-head `Basics and features` | 04 | **32** | 24 | — | — | Bold | `#FFFFFF` |
| 10 | Sub-head `Description` | 04 | **31** | 24 | 5.85 | 0.189 | Bold | `#FFFFFF` |
| 11 | Sticky CTA label `Check Availability` | 04 | **32** | 24 | 4.75 | 0.148 | **Medium** | `#121212` |
| 12 | Settings row label | 02 | **32** | 24 | 3.78 | 0.118 | Regular | `#FFFFFF` |
| 13 | Feature chip label | 04 | **32** | 24 | 2.12 | 0.066 | **ExtraLight** | `#FFFFFF` |
| 14 | Quick-action label `Trips` | 02 | **27** | 20 | 4.94 | 0.183 | Bold | `#FFFFFF` |
| 15 | Sheet price `135 000 RWF/day` | 03 | **27** | 20 | 5.05 | 0.187 | Bold | `#FFFFFF` |
| 16 | Subtitle `Hybride - Black - 2024` | 03, 04 | **27** | 20 | 3.25 | 0.120 | Regular | `#FFFFFF` |
| 17 | Link `Show and edit my profile` | 02 | **27** | 20 | 3.05 | 0.113 | Regular | `#C7FC2F` |
| 18 | Category chip label `Hybride` | 03 | **27** | 20 | 3.13 | 0.116 | Regular | `#C7FC2F` |
| 19 | Hero badge label `Hybride` | 04 | **27** | 20 | ~3 | 0.111 | Regular | `#FFFFFF` |
| 20 | Body copy (description) | 04 | **27** | 20 | 1.68 | 0.062 | **ExtraLight** | `#FFFFFF` |
| 21 | Card body (`Take pictures…`) | 02 | **28** | 21 | 1.68 | 0.060 | **ExtraLight** | `#FFFFFF` |

Nothing on any screen is smaller than cap 27 px.

### 2.2 The scale

Cap heights collapse into **five** steps. The 36/37 and 31/32 pairs are one step
each — a 1 px spread at these sizes is measurement noise, not a design decision.

| Step | cap px | cap pt | Implied font size ([d], cap/em 0.70–0.72) | Rounded | Runs |
| --- | --- | --- | --- | --- | --- |
| **display** | 55 | 18.3 | 25.5 – 26.2 pt | **26 pt** | 1 |
| **title** | 47 | 15.7 | 21.8 – 22.4 pt | **22 pt** | 2 |
| **heading** | 36–37 | 12.0–12.3 | 16.7 – 17.6 pt | **17 pt** | 3, 4, 5, 6, 7 |
| **label** | 31–32 | 10.3–10.7 | 14.4 – 15.2 pt | **15 pt** | 8–13 |
| **body** | 27–28 | 9.0–9.3 | 12.5 – 13.3 pt | **13 pt** | 14–21 |

**This is the smallest scale that covers all of them without inventing sizes:
26 / 22 / 17 / 15 / 13.** It is *not* a modular scale — the successive ratios
are 1.18, 1.29, 1.13, 1.15. Do not "fix" that into a 1.2 ratio; a 1.2 scale from
13 would give 13/15.6/18.7/22.5/27, which misses `heading` by a whole point.

**The rounded pt column is the only place in this file where I rounded.** The
cap px column is exact; the font sizes carry the ±3% cap/em uncertainty from
§1.4 plus whatever the renderer did. Build against cap heights if you can.

### 2.3 Line height

**Body line pitch = 45 px = 15 pt** [m] — measured over 10 consecutive lines of
the 04 description (tops at 1456, 1501, 1546 … 1861, pitch exactly 45 every
time) and confirmed independently on the 3-line 02 card body. Against a 13 pt
body that is **1.15**; against 12.5 pt, 1.20.

Every other run in the reference is a single line, so **no other line height is
measurable** [?]. Do not invent them — if `packages/ui` needs multi-line titles,
that is a new decision, not a reading of the reference.

### 2.4 Weight — the finding that carries the hierarchy

Four weight classes separate cleanly by stem/cap:

| Class | stem/cap measured | Maps to | Used for |
| --- | --- | --- | --- |
| **ExtraLight** | 0.060 – 0.066 | ~200 | all body copy, all feature-chip labels |
| **Regular** | 0.111 – 0.120 | ~400 | subtitles, links, settings rows, category chips, hero badge |
| **Medium** | 0.147 – 0.148 | ~500 (600 possible) | **CTA labels only**, both of them |
| **Bold** | 0.178 – 0.191 | ~700 | titles, section headings, owner name, prices, quick-action labels |

Two consequences worth stating plainly:

1. **Hierarchy in this design is carried by weight and size alone.** There is
   one text colour (`#FFFFFF`) plus the accent for links. No `text-secondary`,
   no opacity ramp, no grey tier. §8 therefore has no secondary text token, and
   adding one would be a deviation.
2. **The body weight is genuinely ExtraLight at 13 pt.** At a 1.7 px stem on
   `#121212` that is a real legibility and accessibility question for a product
   used one-handed in a car park at night, and it is the kind of thing the 1:1
   rule forces to be raised rather than quietly corrected. See [RAISE-2].

---

## 3. Spacing

### 3.1 The two constants that hold across screens

| Constant | px | pt | Where verified |
| --- | --- | --- | --- |
| **Content margin** | **64** | **21.3** | 01 CTA left edge, 03 CTA left edge (identical), 03 sheet left/right, 01+03 crosshair rule left/right, 04 hero left/right, 04 chips left, 04 body text left (65), 04 close button left, 04 overflow button right, 01 avatar left |
| **Card margin / card padding** | **38–39** | **12.7–13.0** | 02 hosting card left+right, 02 settings dividers left+right, 02 card inner padding on all four sides (39 px), 02 back button left |

Two margins coexist deliberately: full-bleed content sits at 64 px, the
settings/card family sits at 38–39 px. Both recur too often to be accidents.

**Sheet padding = 64 px** [m] — the 03 thumbnail's left edge is at 128, the
sheet's at 64. The sheet re-uses the content margin as its own inset.

### 3.2 Every measured gap

Vertical, 02 (profile), top to bottom:

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

Vertical, 04 (detail):

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

Vertical, 03 (sheet):

| From → to | px | pt |
| --- | --- | --- |
| sheet top → handle | 26 | 8.7 |
| handle → thumbnail | 38 | 12.7 |
| title → subtitle | 19 | 6.3 |
| subtitle → chip | 39 | 13.0 |

Component-internal:

| Gap | px | pt |
| --- | --- | --- |
| chip left padding → icon | 30 | 10.0 |
| chip icon → label | 18 | 6.0 |
| chip label → right padding | 26 | 8.7 |
| owner avatar → owner name | 29 | 9.7 |
| heart → share (04) | 31 | 10.3 |
| page-indicator dot gap | 13 | 4.3 |
| card icon tile → card text | 67 | 22.3 |
| settings row: left edge → icon ink | 7 | 2.3 |
| settings row: left edge → label | 158 | 52.7 |

### 3.3 Is there a grid? — verdict and confidence

**There is no clean grid, and I am confident about that.** [d]

- Against a **4 pt grid**, the 28 measured gaps have a mean absolute error of
  ≈1.0 pt — no better than what random values would produce at that granularity.
- Against a **2 pt grid**, mean error ≈0.6 pt. Still not a fit.
- The most attractive theory — that the reference was laid out at **375 pt and
  scaled to 402 pt** (×1.072), which turns 64 px into exactly 20 pt and 38 px
  into 12 pt — explains **about half** the values and breaks on the rest
  (the 100 pt thumbnail becomes 93.3, the 59 pt row becomes 54.9, the 46 pt CTA
  becomes 42.9). I record it as a hypothesis and nothing more.
- Meanwhile several values *are* exact points with no scaling at all: thumbnail
  **100.0 pt**, quick-action circle **50.0 pt**, image radius **10.0 pt**, back
  button **30.0 pt**, card padding **13.0 pt**.

So: some of this design is on whole points, some of it is not, and no single
transform reconciles both. **The reference's spacing is ad hoc.**

**The scale to ship.** Under the 1:1 rule the correct move is to ship the
measured values verbatim as named tokens rather than normalise them — see §8.3
and **[RAISE-3]**, which puts the normalise-or-not question to the founder
rather than deciding it here.

---

## 4. Radii

All measured by corner-arc profiling: for a rounded rect the topmost scanline's
fill begins exactly `r` px in from the left edge, and the leftmost column's fill
begins exactly `r` px down from the top. Both were checked on every row below;
they agree to ±1 px in every case. **Nothing here is inferred from shape.**

| Element | radius px | radius pt | Arc measured |
| --- | --- | --- | --- |
| **Category chip** (03 `Hybride`) | **31.5** | **10.5** | x 478.5→510, y 2029.5→2062 |
| **Hero badge** (04) | **~32** | **~10.7** | x 849→881, y 865→896 |
| **Hero image** (04) | **30** | **10.0** | x 75→105, y 354→406 |
| **Sheet thumbnail** (03) | **30** | **10.0** | x 128→158, y 1873→1904 |
| **Bottom sheet, top corners** (03) | **16** | **5.3** | x 64→82, y 1796→1812 |
| **Hosting-card icon tile** (02) | ~15 | ~5.0 | ±2 px |
| **Sticky CTA** (04) | **~14** | **~4.7** | x 602→617, y 2362→2374 |
| **Primary CTA** (01, 03) | **13.5** | **4.5** | x 63.5→77, y 2381.5→2395 |
| **Hosting card** (02) | **13** | **4.3** | x 38→49, y 1448→1461 |
| **Feature chip** (04) | **10** | **3.3** | x 64→74, y 2055→2065 |
| Circles (avatars, icon buttons, pin head, indicator dots) | ½ diameter | | |

**Two corrections to the observation record, both material:**

1. **The primary CTA is not a pill.** The record calls it a "full-width lime
   pill"; a pill on a 138 px-tall button would need r = 69 px. It measures
   **13.5 px**. The button is a *tightly* rounded rectangle, and so is the
   sticky CTA (~14 px against a 66 px pill). Building these as pills is the
   single most likely 1:1 failure in the whole system, because "lime pill" is
   what the record says and what the shape reads like at a glance.
2. **The sheet's top radius is 5.3 pt, not "~20".**

The category chip and hero badge *approach* a pill but measurably fall short —
both land at r ≈ 0.85 × half-height (31.5 vs 38.5; 32 vs 36). They should be
built with an explicit radius, not `borderRadius: 9999`.

The system's distinctive move is that **images are rounder than containers**:
images and thumbnails 10 pt, near-pills 10.5 pt, containers 3.3–5.3 pt. Buttons
are the *least* rounded things on the screen. That inversion must survive into
`packages/ui` — every instinct will be to do the opposite.

---

## 5. Components

### 5.1 Primary CTA (`01`, `03` — byte-identical between the two)

| Property | Value |
| --- | --- |
| Frame | x 64 → 962, y 2382 → 2519 [m] |
| Size | **899 × 138 px = 299.7 × 46.0 pt** |
| Radius | **13.5 px = 4.5 pt — a rounded rectangle, not a pill** (§4) |
| Fill | `#C7FC2F` |
| Label | `Let's find a car`, cap 37 px, **Medium**, **`#121212` — dark on lime, not black** |
| Label optical centring | 50 px above cap, 51 px below baseline [m] |
| Bottom offset | 103 px = 34.3 pt from the screen bottom (sits on the home-indicator inset) |
| Paired with | 46 pt circular button to its right, 40 px (13.3 pt) gap |

The sticky-bar variant on `04` is **not** the same component — 133 px tall
(44.3 pt), 515 px wide, label cap 32 px. See [RAISE-4].

### 5.2 Circular icon buttons

The reference contains **five different diameters**. They are listed as
measured; §9 raises the inconsistency rather than harmonising it.

| Button | Screen | Diameter px | pt | Fill | Glyph |
| --- | --- | --- | --- | --- | --- |
| Close `×` | 04 | **81** | 27.0 | `#393939` | white stroke, 6 px |
| Back `←` | 02 | **91** | 30.3 | `#393939` | white stroke, 6 px, 46 px wide |
| Overflow `⋯` | 04 | **100** | 33.3 | `#393939` | 3 white dots, ⌀6 px |
| Locate `➤` | 01, 03 | **139** outer | 46.3 | `#FFFFFF` + **4 px lime ring** | **filled** black arrow ≈41 × 45 px |
| Quick action | 02 | **150** (one measures 154) | 50.0 | `#393939` | white stroke, 6 px |

The close and overflow buttons sit on the **same centre line** (y 269.5) at
different sizes — this is not a chord artefact, both were flood-filled.

The locate button is the **only filled icon in the entire system** and the only
one with an accent ring.

### 5.3 Map pin

| Property | Value |
| --- | --- |
| Outer bbox | 120 × 147 px = **40.0 × 49.0 pt** (w:h ≈ 1 : 1.22) [m] |
| Shape | teardrop, point down |
| Body fill | `#FFFFFF` |
| Inner disc | `#F3F3F3`, ⌀ ≈97 px = 32.3 pt, inset ≈8 px from the body |
| Outline | `#C7FC2F`, **2 px = 0.67 pt** |
| Glyph | line-art vehicle, **`#393939`**, ≈5–6 px stroke, ≈100 px wide |
| Shadow | **none** |

That the pin body is white but carries a slightly darker inner disc is real, not
compression — both sample cleanly across many rows.

**For EV Guide:** the pin has exactly one accent-bearing surface (the 2 px
outline) and one glyph slot. Availability is four-state with `Unknown` the
normal case (ADR-0002/0008), and the reference gives no second channel to encode
it on a pin without inventing visual language. That mapping is the screen
inventory's job, not this file's — but the constraint is recorded here:
**one outline colour + one glyph is all the pin affords.**

### 5.4 Bottom sheet (`03`)

| Property | Value |
| --- | --- |
| Frame | x 64 → 1141, y 1796 → 2317 [m] |
| Size | **1078 × 522 px = 359.3 × 174.0 pt** |
| Top radius | **16 px = 5.3 pt**; bottom corners square (sheet runs under the CTA) |
| Fill | `#121212` — *the page background*, on a `#212121` map |
| Shadow / blur | **none** — the map above the sheet samples a flat `#212121` right up to the 1 px AA edge |
| Drag handle | 12 × 13 px core, `#262626`, centred, **26 px (8.7 pt) below the sheet top**; very low contrast |
| Internal padding | **64 px = 21.3 pt** (thumbnail left edge at 128) |
| Thumbnail | **300 × 300 px = 100 × 100 pt**, radius 30 px = 10 pt |
| Title | cap 36 px Bold, baseline 1921 |
| Subtitle | cap 27 px Regular, 19 px below |
| Category chip | 256 × 77 px = 85.3 × 25.7 pt, radius 31.5 px, `#393939` fill, **`#C7FC2F` 2.5 px border**, lime Regular label |
| Heart | 50 × 46 px ink = 16.7 × 15.3 pt, top-right, 67 px inside the sheet's right edge |
| Price | cap 27 px Bold, baseline 2244, right-aligned |

### 5.5 Chips — two variants, and they share nothing

| | **Category chip** (03) | **Feature chip** (04) |
| --- | --- | --- |
| Size | 256 × 77 px = 85.3 × 25.7 pt | height **105 px = 35.0 pt**, width fits content (271 / 652 px measured) |
| Radius | **31.5 px = 10.5 pt** (near-pill, not a pill) | **10 px = 3.3 pt** |
| Fill | `#393939` | `#393939` |
| Border | `#C7FC2F`, 2.5 px ≈ 0.8 pt | **none** |
| Label | cap 27 px, Regular, `#C7FC2F` | cap 32 px, **ExtraLight**, `#FFFFFF` |
| Icon | none | 43 × 48 px stroke icon, 6 px stroke |
| Padding | left 88 px / right 29 px — **not symmetric** | left 30 px, icon→label 18 px, right 26 px |
| Gaps | — | 27 px horizontal, 26 px vertical |

The category chip's label is **not centred** — 88 px of dead space on the left
against 29 px on the right. See [RAISE-5].

### 5.6 Settings rows (`02`)

| Property | Value |
| --- | --- |
| Row pitch | **176–177 px = 58.7–59.0 pt** (divider to divider) [m] |
| Divider | **`#3E3E3E`, 1 px = 0.33 pt**, x 38 → 1167 — **full row width, no inset** |
| Icon ink | 62–68 px = 20.7–22.7 pt, left edge at x 45–46 (varies with the glyph) |
| Icon stroke | **6 px = 2 pt**, `#FFFFFF` |
| Label | x 196, cap 32 px, **Regular**, `#FFFFFF` |
| Vertical alignment | content optically centred between dividers (51–53 px pad each side) |
| Section heading | `Settings`, cap 37 px Bold, x 40, 69 px above the first row |
| Chevron / disclosure | **none** — the rows carry no trailing affordance |

### 5.7 Hero carousel + page indicator (`04`)

| Property | Value |
| --- | --- |
| Hero frame | x 65 → 1140, y 354 → 973 = **1076 × 620 px = 358.7 × 206.7 pt** (≈1.74 : 1) |
| Hero radius | 30 px = 10 pt |
| Active indicator | **96 × 16 px = 32.0 × 5.3 pt**, fully rounded (r ≈ 8 px — at 16 px tall this is at the limit of what the capture can resolve [?]), `#C7FC2F` |
| Inactive dots | 3 × ⌀16 px = 5.3 pt, **`#3E3E3E`** |
| Indicator gap | 13 px = 4.3 pt |
| Indicator position | horizontally centred on the hero; 34 px (11.3 pt) above the hero's bottom |
| Badge | x 849 → 1098, y 865 → 936 = **250 × 72 px = 83.3 × 24.0 pt**, radius ≈32 px = 10.7 pt (near-pill), `#C7FC2F` |
| Badge label | cap 27 px Regular `#FFFFFF` + a filled lightning glyph |
| Badge position | 42 px (14 pt) inside the hero's right edge, 37 px (12.3 pt) above its bottom |

Four indicator positions for what is one visible photo — the carousel is
paginated, not a scroll-strip.

### 5.8 Sticky bottom bar (`04`)

| Property | Value |
| --- | --- |
| Bar region | y 2337 → 2622 = **285 px = 95.0 pt** |
| Background | **opaque `#121212`** — it clips the third chip row at y 2336 with a hard edge and no gradient, so there is **no blur and no translucency** |
| Top border | **none** |
| Shadow | **none** |
| Horizontal padding | **≈89–90 px = ≈30 pt** — *not* the 64 px content margin. See [RAISE-6] |
| Price | `135 000 RWF/day`, cap 36 px Bold, left, baseline 2446 |
| CTA | 515 × 133 px = 171.7 × 44.3 pt, radius ≈14 px = 4.7 pt (**not** a pill), `#C7FC2F`, label cap 32 px Medium `#121212` |
| Bottom offset | 128 px = 42.7 pt (vs 34.3 pt on the 01/03 CTA) |

### 5.9 Avatar

**Map avatar (`01`, `03`)**

| Property | Value |
| --- | --- |
| Circle | ⌀ **129 px = 43.0 pt**, `#FFFFFF`, **no ring** |
| Position | x 64 (content margin), y 362 |
| Glyph | person, `#000000`-ish stroke |
| Status dot | ⌀ **20–21 px = 7.0 pt**, `#C7FC2F`, with a white ring ≈4 px |
| Dot placement | centre offset **(+49, −49) px** from the circle centre — 45° top-right, straddling the edge |

**Profile avatar (`02`)**

| Property | Value |
| --- | --- |
| Circle | ⌀ **316 px = 105.3 pt** outer |
| Ring | `#C7FC2F`, **≈3 px = 1.0 pt** |
| Fill | `#3E3E3E` (empty state — no image) |
| Position | horizontally centred (centre x 602 vs screen centre 603) |

The lime ring appears on the profile avatar and **not** on the map avatar; the
map avatar carries the status dot and the profile avatar does not.

### 5.10 Hosting-mode card (`02`)

| Property | Value |
| --- | --- |
| Frame | x 38 → 1167, y 1448 → 1782 = **1130 × 335 px = 376.7 × 111.7 pt** |
| Radius | 13 px = 4.3 pt |
| Fill | `#393939` |
| Padding | **39 px = 13 pt**, all four sides |
| Icon tile | 257 × 257 px = **85.7 × 85.7 pt**, `#3E3E3E`, radius ≈15 px |
| Tile glyph | lime car-with-arrow, ≈9 px stroke |
| Tile → text | 67 px = 22.3 pt |
| Title | cap 37 px Bold, baseline 1558 |
| Body | cap 28 px ExtraLight, 3 lines, 45 px line pitch |

### 5.11 The crosshair rule (`01`, `03`)

Measured, because the record could not say what it was:

| Property | Value |
| --- | --- |
| Horizontal rule | y 249 → 250, **2 px = 0.67 pt**, `#FFFFFF` |
| Extent | x 64 → 1141 — **exactly the content width**, same as the sheet and the CTA |
| Cross arms | 2 vertical strokes, **3 px wide × 83 px tall = 1 × 27.7 pt** |
| Arm positions | x 92–94 and x 1106–1108, centred on the rule |
| Arm insets | 29 px from the left end, **34 px** from the right end — **asymmetric by 5 px** |

**Purpose: still undetermined [?].** It is identical on both map screens, is not
attached to any control, does not move with the sheet, and encloses nothing. It
reads as a viewfinder/registration mark. It cannot be inferred from two stills;
it needs the founder or the source app. Recorded here as geometry so the screen
inventory can decide whether EV Guide carries it at all — and **[RAISE-7]** puts
that question rather than answering it.

---

## 6. Icon system

| Property | Measured |
| --- | --- |
| **Stroke weight** | **6 px = 2.0 pt**, uniform. Verified on the heart, share, close `×`, back `←`, and all three settings icons (white runs of exactly 6 px in every case). |
| **Corner / terminal style** | rounded caps and joins, no mitres [m, visual] |
| **Optical grid** | ≈**64–76 px = 21–25 pt** ink box. Heart 68 × 62, share 67 × 67, settings icons 62–68 wide, chip icons 43 × 48, owner avatar 76 × 76. Nominal grid ≈**24 pt** with per-glyph ink variation. |
| **Fill vs stroke** | **All stroked, one exception**: the locate button's navigation arrow is solid. The hero badge's lightning bolt is also solid. |
| **Colour** | `#FFFFFF`, except the pin glyph (`#393939`) and the hosting-tile glyph (`#C7FC2F`) |
| **Known set?** | **No confident match [?]**. 2 pt stroke on a ~24 pt box with round caps and geometric construction is consistent with Feather/Lucide (2 px on 24), but the heart, shield and banknote glyphs do not match Feather's drawing exactly, and the car-with-arrow in the hosting tile is custom. Treat the set as **"Feather/Lucide-compatible metrics, bespoke drawings"** and do not claim a source. |

The 2 pt stroke at 24 pt is the one icon rule the whole system obeys without
exception. It is the tokenisable part.

---

## 7. Elevation, blur, shadow

**There are none. Anywhere.** This was checked, not assumed:

| Surface | Test | Result |
| --- | --- | --- |
| Bottom sheet over map | column scan above the sheet's top edge | flat `#212121` to the 1 px AA row — **no shadow** |
| CTA over map | column above the button | flat `#212121` — **no shadow** |
| Map avatar over map | row beside the circle | flat `#212121` — **no shadow** |
| Map pin over map | crop at 6× | **no shadow** |
| Hosting card over page | column above the card | flat `#121212` — **no shadow** |
| Sticky bar over content | column through the clipped chip row | `#393939` at y 2336 → `#121212` at y 2337, **hard edge** — opaque, **no blur, no border** |
| Page background | sampled every 300 px down 02 and 04 | **flat `#121212`**, no gradient |

The only depth cues in the entire system are **surface colour steps**:
`#121212` page → `#212121` map → `#393939` surface → `#3E3E3E` raised.

Adding a shadow, a blur, a border or a gradient to any of these would be a
breach of the 1:1 rule, and the temptation will be strongest on the bottom sheet
and the sticky bar — the two places where iOS convention says "add a blur".
**Do not.**

---

## 8. The token set as it will exist in `packages/ui`

`packages/ui` is shared by the driver and operator apps (ADR-0006, ticket 15).
The **admin dashboard takes tokens only** — the colour, type, space and radius
primitives below — and **no React Native components**.

Marked **[admin]** = inherited by the web dashboard.

### 8.1 Colour

| Token | Value | Notes |
| --- | --- | --- |
| `color.bg` | `#121212` | page **[admin]** |
| `color.map` | `#212121` | map canvas only — not an admin surface |
| `color.surface` | `#393939` | cards, chips, circular buttons **[admin]** |
| `color.surfaceRaised` | `#3E3E3E` | avatar fill, inner tiles, dividers, inactive dots **[admin]** |
| `color.accent` | `#C7FC2F` | **exactly one value, no tints, no gradients** **[admin]** |
| `color.onAccent` | `#121212` | CTA label colour **[admin]** |
| `color.text` | `#FFFFFF` | **the only text colour** **[admin]** |
| `color.divider` | `#3E3E3E` | **[admin]** |
| `color.pinBody` | `#FFFFFF` | |
| `color.pinDisc` | `#F3F3F3` | |
| `color.pinGlyph` | `#393939` | |
| `color.iconOnDark` | `#000000` | locate-arrow only — see [RAISE-8] |

Deliberately absent: any `text.secondary`, `text.muted`, opacity ramp, elevation
colour, or accent tint. §2.4 and §7 say the reference has none.

### 8.2 Typography

| Token | Value |
| --- | --- |
| `font.family` | see §1 — pending the 30-second Raleway check |
| `font.weight.extraLight` | 200 |
| `font.weight.regular` | 400 |
| `font.weight.medium` | 500 |
| `font.weight.bold` | 700 |
| `type.display` | 26 pt / cap 18.3 pt / Bold |
| `type.title` | 22 pt / cap 15.7 pt / Bold |
| `type.heading` | 17 pt / cap 12.2 pt / Bold *(Medium on CTA)* |
| `type.label` | 15 pt / cap 10.5 pt / Bold · Medium · Regular · ExtraLight |
| `type.body` | 13 pt / cap 9.2 pt / line-height **15 pt** / Regular · ExtraLight |
| `type.tracking` | 0 at every size |

All **[admin]**, except that the admin dashboard is a different medium and its
line lengths will not match; it inherits the sizes and weights, not the layout.

### 8.3 Spacing — measured values, verbatim

Named after where they were measured, not after a grid position, because §3.3
found no grid.

| Token | px | pt |
| --- | --- | --- |
| `space.pageMargin` | 64 | 21.3 |
| `space.cardMargin` | 38 | 12.7 |
| `space.cardPadding` | 39 | 13.0 |
| `space.sheetPadding` | 64 | 21.3 |
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
| `size.iconStroke` | 6 | 2.0 |

**[admin]** for all of them, with the caveat that the dashboard's own margins are
a web problem this file does not solve.

### 8.4 Radius

| Token | px | pt | Applies to |
| --- | --- | --- | --- |
| `radius.chip` | 10 | 3.3 | feature chips |
| `radius.card` | 13 | 4.3 | hosting card |
| `radius.button` | 13.5 | 4.5 | **both CTAs** — see §4, this is not a pill |
| `radius.sheet` | 16 | 5.3 | bottom sheet top corners |
| `radius.image` | 30 | 10.0 | hero, thumbnails |
| `radius.nearPill` | 31.5 | 10.5 | category chip, hero badge |
| `radius.circle` | 9999 | — | avatars, icon buttons, dots |

**There is no `radius.pill` token, deliberately** — nothing in the reference is
one. **[admin]**, and the images-rounder-than-buttons inversion (§4) is the part
the dashboard must not "fix".

### 8.5 Component sizes

| Token | px | pt |
| --- | --- | --- |
| `size.ctaHeight` | 138 | 46.0 |
| `size.ctaHeightSticky` | 133 | 44.3 |
| `size.circleButton.sm` | 81 | 27.0 |
| `size.circleButton.md` | 91 | 30.3 |
| `size.circleButton.lg` | 100 | 33.3 |
| `size.circleButton.xl` | 139 | 46.3 |
| `size.quickAction` | 150 | 50.0 |
| `size.avatarMap` | 129 | 43.0 |
| `size.avatarProfile` | 316 | 105.3 |
| `size.avatarOwner` | 76 | 25.3 |
| `size.thumbnail` | 300 | 100.0 |
| `size.chipHeight` | 105 | 35.0 |
| `size.pin` | 120 × 147 | 40 × 49 |
| `size.statusDot` | 20 | 7.0 |
| `size.accentRing` | 3 | 1.0 |

Native only — the admin dashboard inherits none of §8.5.

---

## 9. Raised: impossibilities, contradictions and open questions

Per the standing rule these are **raised, not resolved**. None has been
substituted, harmonised or improved in the sections above; §§1–8 report what is
there.

**[RAISE-1] The typeface may be unnameable, and its figures may be
unreproducible.** §1 gets to ~65–70% on Raleway and no further from a 3×
screenshot. Separately, the reference's **old-style figures** — `3 4 5`
descending below the baseline in prices, years and model numbers — are a
substantial part of its character. If the chosen face has no old-style set, that
character cannot be reproduced, and no substitution is equivalent. Needs the
30-second check in §1.3 before `packages/ui` picks a family.

**[RAISE-2] The body weight is ExtraLight (≈200) at 13 pt on `#121212`.** A
1.7 px stem. Reproducing it 1:1 is straightforward; whether EV Guide *should*,
for a product read one-handed in a dim car park and used offline, is a founder
call, not mine. The reference is unambiguous, so the default is to reproduce it.

**[RAISE-3] The spacing is not on a grid (§3.3) — normalise or reproduce?**
Reproducing verbatim honours 1:1 and gives `packages/ui` sixteen oddly-named
constants. Normalising to 4 pt gives a clean system and a ~1 pt deviation on
most values, which is a deliberate deviation and therefore needs saying yes to.
§8.3 currently ships the measured values.

**[RAISE-4] The two primary CTAs are different components.** 01/03: 138 px tall,
label cap 37 px. 04 sticky: 133 px tall, label cap 32 px. Also different bottom
offsets (34.3 pt vs 42.7 pt). Either the reference has two CTA sizes on purpose
or this is drift; 1:1 means shipping both unless told otherwise.

**[RAISE-5] Four alignment defects in the reference.**
(a) The `Hybride` category chip's label is not centred — 88 px left padding
against 29 px right. (b) `Basics and features` starts at x 79 while
`Description` starts at x 68 — an 11 px (3.7 pt) mismatch between two peer
sub-heads on the same screen. (c) The crosshair's cross arms are inset 29 px
from the left end and 34 px from the right. (d) The three profile quick actions
are **not evenly spaced**: 64 px between circles 1 and 2, **81 px** between 2
and 3, and circle 1 measures ⌀154 px against ⌀149 px for the other two. All four
are visible at 1×. Reproducing defects is the literal reading of 1:1;
correcting them is a deviation. Needs a ruling.

**[RAISE-6] The sticky bar ignores the content margin.** 90 px (30 pt) padding
against the 64 px (21.3 pt) used by every other element on the same screen,
including the chips directly above it.

**[RAISE-7] The crosshair rule's purpose is unknown (§5.11).** Fully measured,
but a still cannot say what it does. It appears on both map screens and nowhere
else. EV Guide has to decide whether it carries over at all — and if it does,
what it means — before the map screen can be specified.

**[RAISE-8] Two different "black"s on the accent.** The CTA label is `#121212`;
the locate button's arrow is `#000000`. One of them is probably a mistake, and
1:1 does not say which.

**[RAISE-9] Circular icon buttons come in five diameters** (27 / 30.3 / 33.3 /
46.3 / 50 pt), including two on the *same screen at the same centre line* — the
04 close button (27 pt) and overflow button (33.3 pt). Both were flood-filled,
so this is not a measurement artefact. A design system wants one or two sizes;
1:1 wants five.

**Already raised by the ticket, restated because it lands in this file:** the
`Google` wordmark on the map screens cannot be reproduced under MapLibre (ticket
17's routed finding from 06). It sits at the map's bottom-left, above the CTA,
and it is the only element of these four screens that is provably impossible.

### Could not be measured

- **cap-height / em** for the face (§1.4) — needs the identified font. Every pt
  font size in §2.2 carries ±3% from this.
- **Line height for anything but body copy** — every other run is one line.
- **The `Messages` notification dot** (02) — same construction as the map
  avatar's status dot by inspection, but not separately measured.
- **The owner row's message icon** (04) — visible, not measured.
- **Pressed / disabled / focus states** — no screen shows one. The record's
  "accent shade `#9EC52B`" is anti-aliasing on pin outlines, **not** a pressed
  state; there is no evidence of a second accent value anywhere.
- **Any motion, transition or gesture behaviour** — four stills.

---

## 10. What this file does not decide

The ticket's other half: the screen inventory, `Payment & payouts`'s
replacement, the `Switch to hosting mode` cross-app affordance, the three
profile quick actions, how availability reads on a pin, the ADR-0004 route
preview inside the existing screens, the ADR-0003 auth sheet (triggered by save
and report, **not** directions — ticket 23), and the ADR-0007 offline surfaces.
Those are design decisions that consume this system; they belong in the
inventory document, not here.
