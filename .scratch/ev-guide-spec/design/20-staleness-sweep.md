# 20 — Staleness sweep: files 11 and 12 against `10-design-system-v2.md`

Commissioned 2026-08-14 out of ticket 31. Both round-1 adversaries, working
independently on different documents, hit the same cross-cutting defect: the two
v2 screen inventories carry geometry that **contradicts** the measured design
system **while citing it**. File 11 §18 names the mechanism —
`10-design-system-v2.md` did not exist when file 11 was written, six corrections
were owed to it, and the authority note added on 2026-08-13 flags exactly one of
them (the floating card's radius) while the body was never touched.

**This document corrects nothing.** It is the correction list. Every row states
the file, the exact quoted text, what 10-v2 measures, and — the part that
matters — whether anything downstream computes from the stale number.

---

## 0. Method, scope and the ranking that governs this file

### 0.1 What was swept

- `11-driver-screens-v2.md` (2 238 lines) — every numeric value, every token
  citation, every fit calculation.
- `12-operator-admin-screens-v2.md` (1 163 lines) — same.
- `SPEC.md` §5 (and §§1–4, 6–13 for design-system values that leaked into them)
  — every token table, transcribed from file 10 and required to match exactly.
- Cross-checked: `docs/adr/0009`, `docs/adr/0010`, `docs/availability-display.md`
  §2.2b. All three are **clean** against 10-v2 (ADR-0009's puck `40 px disc /
  82 px halo` and wordmark `159 × 50 px at x73–232, y2256–2306` match §2.5 and
  file 11 §11; ADR-0010's nine metrics match §3.5 row for row).

Every fit calculation found in either file was **recomputed**, not read.
Character counts were recounted mechanically.

### 0.2 Marking legend (house style)

- **[m]** — measured value, quoted from 10-v2 with its section.
- **[d]** — derived here by stated arithmetic.
- **[?]** — unmeasurable / the reference cannot arbitrate.
- **[INVENTED]** — a number with no source in file 10, file 11 or file 12.

### 0.3 The ranking, which is the point of this document

A wrong number nobody used is a typo. A wrong number a fit check passes *only
at* is a design defect hiding behind a typo. Three tiers:

| Tier | Meaning |
| --- | --- |
| **T1** | A fit calculation, an identity or a stated conclusion **computes from** the stale value. Recomputed below; verdict stated. |
| **T2** | The value is **shipped geometry** — a build types it — but nothing computes from it. Wrong pixels, no wrong reasoning. |
| **T3** | Citation, section pointer or token name only. |

**Totals: 40 distinct defects in file 11, 20 in file 12, 1 substantive error +
1 omission in SPEC.md.** Repeated occurrences of one wrong value are counted
once, with the occurrence count given.

---

## 1. SPEC.md — first, because it is the locked document

SPEC.md §5 is **substantially clean**. Every row of the spacing table (19
tokens), the radius table (8 tokens), the component-size table (16 tokens), the
type scale, the weights, the line height, the tracking, the link style and the
colour list matches 10-v2 §§10.1–10.5 exactly. It did **not** inherit file 11's
`897 px` CTA — it carries 10-v2's `899 × 138 px` — nor file 12's
`radius.button 4.5 pt`; it carries **button 13**. Whoever transcribed §5 worked
from file 10 and not from the inventories, and it shows.

Two findings.

### S-1 · The floating card's resting position — **T1, and it would build wrong**

> **SPEC.md §5, "Five findings that would each have shipped visibly wrong",
> item 3:**
> *"**The `03` container is a floating card**, not a bottom sheet — 14 px on all
> four corners, 64 px above the screen bottom."*

**10-v2 §7.4** [m]: frame `y1797 → 2317`; `Gap to the CTA below | **64 px =
21.3 pt**`; §7.1 [m]: the CTA's `Bottom offset | 103 px = 34.3 pt from the
screen bottom`. §10.3 names the value `space.floatingCardBottomGap` = 64 —
**card to CTA**, not card to screen.

The card's bottom edge is **305 px above the screen bottom** [d] (2622 − 2317).
`64 px above the screen bottom` is not a measured relationship in the reference
and there is nothing at that offset.

**Downstream.** This is the one place in SPEC.md where an implementer reading
only the locked document lands somewhere the reference does not. A card placed
64 px above the screen edge sits *below* the CTA (whose own bottom offset is
103 px) and overlaps it. The sentence is in the list of five findings
specifically labelled *"would each have shipped visibly wrong"*, which is where
it will be trusted hardest.

Note the near miss: 10-v2 §0.2 M2 says *"**64 px of live map below it**"* and
§7.4 says *"Rows 2318–2381 inclusive — **exactly 64 rows** — are map"*. The
`64` is real; the anchor it was attached to is not.

### S-2 · Two colour tokens absent from §5's palette — omission, **T3**

> **SPEC.md §5, Colour:** *"… `#262626` handle · `#717171` `iconMuted` (the `03`
> heart and only that) · pin `#FFFFFF`/`#F3F3F3`/`#393939`."*

**10-v2 §10.1** also defines `color.iconOnLight` = `#121212` (map-avatar person
glyph) and `color.iconOnLightBlack` = `#000000` (**locate arrow only** — §8.1's
finding that this is *the only `#000000` in the product*, and the subject of
[RAISE-8]).

Not a contradiction — SPEC.md states it is not exhaustive (*"the citation of
record for anything not restated here"*). Recorded because the two-blacks
question is a live raise and the palette a build reads is SPEC.md's.

**Nothing else in SPEC.md is wrong.** §6's `(+53, −53) px` survives
re-derivation (see F11-24 below). §5's `899 × 138 px`, `899` not `897`, is
correct and contradicts file 11.

---

## 2. File 11 — `11-driver-screens-v2.md`

40 distinct defects. Grouped by root cause, because six roots produce
thirty-one of them.

### 2.1 Root A — the floating card frame (v1 geometry, never corrected)

The authority note at the top of file 11 flags **only** the radius. The frame,
the size, the gap, the handle offset and the derived inner box are all still v1.

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-1** | §0.3 row 2: *"The sheet is a **floating card**: x 64→1141, y 1796→**2317**"* | §7.4 [m]: **`x65 → 1140, y1797 → 2317`** — *"AA columns at x64 / x1141, AA row at y1796"* | T1 |
| **F11-2** | §8/D-02: *"Frame x 64 → 1141, y 1796 → 2317 (**1078 × 522 px = 359.3 × 174.0 pt**)"* | §7.4 / §10.5 `size.floatingCard` = **1076 × 521 px = 358.7 × 173.7 pt** | T2 |
| **F11-3** | §0.3 row 2, §8/D-02, D-02 ASCII, S-01 ×2, S-02, §15/M2, §17 ×2 — **9 occurrences**: *"rounded on **all four** corners at **r ≈ 16 px**"* | §6 / §7.4 / §10.4 `radius.floatingCard` = **14 px = 4.7 pt** | T2 |
| **F11-4** | §0.3 row 2 / §8/D-02 / D-02 ASCII: *"Below it, **65 px** of `#212121` map"* | §7.4 [m]: *"Rows 2318–2381 inclusive — **exactly 64 rows** — are map"*; §10.3 `space.floatingCardBottomGap` = **64** | T2 |
| **F11-5** | §0.3 row 2: *"then the CTA at **y 2383**"* | §7.1 [m] frame `y2382 → 2519`; §7.4: *"The CTA's accent begins at y2382"* | T1 |
| **F11-6** | §8/D-02 + slot map: *"handle … **26 px** below the card's top"* | §5.2 [m]: *"card top (y1797) → handle ink top (y1822) — **25 px = 8.3 pt**"* | T2 |
| **F11-7** | §5.1 table + [RAISE-D31] + S-01/S-02 ASCII ×2 + §17 + §16/D31 — **9 occurrences of `950 px`**: *"card x 64 → 1141 less 64 px padding each side = **x 128 → 1077 = 950 px = 316.7 pt**"* | [d] from §7.4's frame: `x129 → 1076` = **948 px = 316.0 pt** | **T1** |

**The radius error and the frame error are one error.** File 11 §0.3 row 2's own
corner evidence — *"top row y 1797 spans x 79→1126"* — is byte-identical to
10-v2 §7.4's. 10-v2 measures the arc from the **true edge at x64.5** and gets
14.5; file 11 measures it from the AA column at x64 and gets ≈16. Correct the
frame and the radius corrects itself. That is why nine occurrences of `r 16`
survive a note that says `r 14` is right: nobody re-derived them.

### 2.2 Root B — the primary CTA

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-8** | §0.3 row 5 + §1 sub-5 + §1 + D-01 ASCII + D-01 components + §15/M6 + §17 — **8 occurrences**: *"**897 px** of lime core, x 65→961"* | §7.1 [m]: `Frame x64 → 962`, `Size **899 × 138 px = 299.7 × 46.0 pt**` | **T1** |
| **F11-9** | §0.3 row 5: *"**Content width 1078 = CTA 897 + gap 41 + locate 137.**"* | 897 + 41 + 137 = **1075** [d] — the identity is short by 3 px and does not hold | **T1** |
| **F11-10** | §0.3 row 5: *"The locate button occupies x 1003→**1139**"* (137 px) | §7.2 [m] `Locate ➤ **137–139 outer**`; §10.5 `size.circleButton.xl` = **139** | T1 |
| **F11-11** | §1 sub-5, D-01 ASCII, S-01 ×2, [RAISE-D31], [RAISE-D20], §12.2, §12.3, §16/D20 — **8 occurrences**: *"radius **13.5 px**"* | §10.4 `radius.button` = **13 px = 4.3 pt**, *"**both CTAs**"* | T2 |
| **F11-12** | §0.3 row 6, §1 sub-5, S-01 ASCII — **3 occurrences**: *"label **cap 37** Medium `#121212`"* (primary CTA) | §4.1 row 5 [m]: `Primary CTA label 'Let's find a car' — **cap 36 px**, Medium`. §4.1's own note: rows measured from a **flat cap** (`L`) *"are exact"* | **T1** |
| **F11-13** | §0.3 row 6: *"cap 37 Medium **k = 0.574** (`Let's find a car`, 16 ch, 340 px)"* | [d] at the measured cap 36: 340 ÷ (16 × 36) = **0.590** | T1 |

**On cap 37.** §4.2 collapses `36/37` into one *step*, which is a statement about
the type scale, not a licence to use 37 as the measured cap of this run. §4.1
row 5 measures **36**, and the asterisk under §4.1 exists precisely to stop
round-cap over-reads being treated as sizes. Every arithmetic that divides by
`cap_px = 37` for a Medium CTA label is dividing by a value 10-v2 does not
carry. See §4.1 below for where this lands hardest — in file 12, not file 11.

### 2.3 Root C — the `04` hero frame (v1 geometry)

10-v2 §0.2 row 12 is explicit: *"hero frame 'x65→1140, y354→973 = 1076 × 620'"*
→ **`x64 → 1141, y354 → 965 = 1078 × 612 px`**, *"verified at five columns and
two rows"*. File 11 carries the v1 frame and everything derived from its bottom
edge.

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-14** | D-03 ASCII + slot map + Loading state — **3 occurrences**: *"hero **1076 × 620 px**, radius 30 px"* | §7.7 [m]: **`1078 × 612 px = 359.3 × 204.0 pt (1.762 : 1)`** | T2 |
| **F11-15** | D-03 slot map: *"Page indicator … **34 px above hero bottom**"* | §7.7 [m]: *"**26 px (8.7 pt) above the hero's bottom**"* | T2 |
| **F11-16** | D-03 slot map + §9.3/[RAISE-D16] — **2 occurrences**: *"active **96 × 16 px** lime"* | §7.7 [m]: **`95 × 16 px = 31.7 × 5.3 pt`** (x512–606, y924–939) | T2 |
| **F11-17** | D-03 slot map: *"Hero badge \| **249 × 71 px** [m·11], radius ≈32 px"* | §7.7 [m]: **`248 × 70 px = 82.7 × 23.3 pt`** (250 × 72 with AA) — 249 × 71 is neither the core nor the AA extent | T2 |
| **F11-18** | D-03 slot map: *"**filled lightning** + cap 27 Regular `#FFFFFF`"* | §0.2 m4 / §7.7 / §8.3 [m]: *"the bolt is **stroked** — its interior samples lime"*, **≈4.2 px**. *"**Exactly one filled icon exists**: the locate arrow"* | **T2, drawing-level** |

**F11-15 is an 8 px placement error with one cause**: the indicator's offset was
taken from the v1 hero bottom at `y973`, not the measured `y965`. **F11-18 is
not a dimension but a drawing instruction** — 10-v2 §0.2 m4 exists specifically
to stop a build painting a solid bolt, and file 11 tells it to.

### 2.4 Root D — circular buttons, read AA-inclusive

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-19** | D-03 ASCII + slot map + §17 — **3 occurrences**: *"Close `×` \| **⌀81 px** `#393939`"* | §7.2 [m] **⌀80** (x65–144, y230–309); §10.5 `size.circleButton.sm` = **80 = 26.7 pt** | T2 |
| **F11-20** | D-03 ASCII + slot map + §17 — **3 occurrences**: *"Overflow `⋯` \| **⌀100 px**"* | §7.2 [m] **⌀98** (x1043–1140, y221–318); `size.circleButton.lg` = **98 = 32.7 pt** | T2 |
| **F11-21** | D-03 slot map: *"3 white dots **⌀6 px**"* | §7.2 / §8.1 row 19 [m]: `3 × #FFFFFF dots, ⌀ **7.6 px**` | T2 |
| **F11-22** | D-03 slot map: *"Close `×` … **6 px white stroke**"* | §7.2 [m] *"`#FFFFFF`, **~3.8 px** perpendicular"*; §8.1 row 18 **≈3.8** (5.3 raw ÷ √2); §8.2 files it in the **Light** band | T2 |
| **F11-23** | D-04 ASCII + D-05 — **2 occurrences**: *"back **⌀91** `#393939` x38"* | §7.2 [m] **⌀90** (x39–128); `size.circleButton.md` = **90 = 30.0 pt** | T2 |

All five are +1 or +2 on the token — AA columns counted as ink. This root
propagates into file 12 as **pt** values (§4.1, F12-1/2/3), where it is worse,
because file 12 quotes them as `§5.2`'s own measurements.

### 2.5 Root E — the pin

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-24** | §2.4 [m·11] + §2.6/[RAISE-D4] — **2 occurrences**: *"Outer bbox \| **122 × 147 px**"*, *"Head \| a circle **⌀122 px**"*, *"Lime rim … at radius **60–61**"* | §7.3 [m] *"Outer bbox 120 × 147 px = 40.0 × 49.0 pt"*; §10.5 `size.pin` = **120 × 147** | **T1** |
| **F11-25** | §2.4: *"Inner disc \| `#F3F3F3`, radius ≈50 (**⌀100**)"* | §7.3 [m]: *"Inner disc `#F3F3F3` (6 292 px), **⌀ ≈97 px = 32.3 pt**, inset ≈8 px from the body"* | T2 |
| **F11-26** | §2.2: *"centre offset (**+49, −49.5**)"* | §7.9 [m]: *"centre offset **(+49, −49) px**"* | T3 |

### 2.6 Root F — the hosting card

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-27** | §6: *"part 1 §5.10: **1130 × 335 px (376.7 × 111.7 pt)**"* | §7.10 [m]: `x39 → 1166, y1448 → 1781 = **1128 × 334 px = 376.0 × 111.3 pt**` | T2 |
| **F11-28** | §6 + §6.1 ASCII — **2 occurrences**: *"icon tile **257 × 257 px**"* | §7.10 [m]: **`256 × 257 px = 85.3 × 85.7 pt`** | T1 (via file 12 §5.1) |
| **F11-29** | §6 / §6.1: *"a lime **≈9 px**-stroke glyph"* | §7.10 / §8.1 row 12 [m]: **9.8 px integrated = 3.3 pt** — *"the heaviest stroke in the system"* | T3 |

### 2.7 Root G — the settings-row container

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-30** | §5, §5.1 ×2, D-04 ASCII, D-05, [RAISE-D14] — **6 occurrences**: *"Divider `#3E3E3E` 1 px, **x 38 → 1167**, no inset"* | §7.6 [m]: *"core **x39 → 1166** (AA at x38 / x1167)"* — the file quotes the AA extent as the core | T2 |
| **F11-31** | D-03: connector rows *"1 px `#3E3E3E` divider **at x 64 → 1141** per §5.1 … **label x 196** cap 32 Regular"* | §5.2 [m]: *"settings row: left edge → label **158 px**"*. In a `space.pageMargin` 64 container the label is at **x222** [d], not x196. The row's divider was moved to the page column and its label was not | **T1 (internal)** |

F11-31 is file 11 contradicting **its own** §5.1 ruling (*"`full width, no inset`
is a relationship to the row's container"*) two sections later. Same defect
appears in file 12 §4.2 — see F12-14.

### 2.8 Standalone defects in file 11

| # | File 11, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F11-32** | D-03: *"cap 28 ExtraLight at 45 px pitch, full **358.7 pt** content width"* | 358.7 pt = 1076 px = `size.floatingCard`'s **width**. The `04` content column is `x64 → 1141` = 1078 px = **359.3 pt** [d, §5.1 + §7.7] | T2 |
| **F11-33** | D-03 slot map: *"`Description` \| **cap 31 Bold** + cap 28 ExtraLight"* | §4.1 row 10 [m]: `Sub-head 'Description' — **cap 32**, Bold`. No cap-31 run exists in §4.1 | T2 |
| **F11-34** | §7.2: *"giving **86 px of left padding against 30 px of right**"* | §7.5 / §12 [RAISE-5a] [m]: *"left **88 px** / right **29 px**"* | T1 — **see §5, this one runs the other way** |
| **F11-35** | §9.1: offline chip *"a **2 pt stroke icon on the 24 pt grid**"* | §7.5 [m]: the feature chip's icon is `43 × 48 px stroke icon, **4.2 px perpendicular**`; §10.3 `size.iconGridChip` = 48 px = **16 pt**; §8.2 files chip icons in the **Light** band, **1.4 pt** | T2 |
| **F11-36** | §0.3 row 4 + §15/F4: card heart *"Stroke integrates to **6.0 px**, i.e. the §6 2 pt stroke unchanged; only the colour differs"* | §8.1 row 17 [m]: **4.8–6.0 px**; §8.2 files the card heart at **4.8 px** in the **Light** band (1.4–1.7 pt). The claim *"the 2 pt stroke unchanged"* is not supported | **T1** |
| **F11-37** | §0.3 row 4 + D-03 slot map — **2 occurrences**: *"The `04` heart (**68 × 62 px**)"* | §8.1 row 21 [m] **66 × 62**; §12 [RAISE-11] **66–67 × 62** | T2 |
| **F11-38** | §11: *"sitting **77 px** (25.7 pt) above the CTA's top edge at y 2383"* | [d] from §7.1's `y2382`: **76 px = 25.3 pt** | T3 |
| **F11-39** | [RAISE-D31]: *"a layout consequence of two measured values (the card frame and **`space.sheetPadding`**)"* | **No such token.** §10.3 defines `space.floatingCardPadding` = 64; §10.4: *"There is no `radius.sheet` token either — **there is no sheet**"* | T3 |
| **F11-40** | §13.1: *"**Canonical location: `docs/availability-display.md` §2.2, law 8**"*, followed by a four-row restatement of the list | Four claimed homes are now in circulation: 10-v2 §0.3/R3 (*"lives in §11.2 of this file and nowhere else"*), file 11 §0.2/R3 (*"§13.1"*), file 11 §13.1 (*"availability-display §2.2, law 8"*), and both authority notes + the ticket (**availability-display §2.2b**). §2.2b exists and is titled *"The forbidden strings — the one and only home"* | **T3, but unresolved** |

**On F11-40.** 10-v2 is one of the four claimants, so this is not simply "11 is
stale against 10". It is a four-way contradiction in which the governing ticket
and both authority notes agree on `availability-display.md §2.2b`, and both
file 10 §11.2 and file 11 §13.1 hold restated copies that the notes declare
stale. SPEC.md §4 is the only document that gets it right, and it does so by
naming both (*"[availability-display.md §2.2b], with the product-wide extension
in the design record §11.2"*).

---

## 3. File 12 — `12-operator-admin-screens-v2.md`

20 distinct defects. File 12 is shorter and cites more and measures less, so its
defects are concentrated in **token values it quotes** and in **one fit
calculation that does not survive recomputation**.

| # | File 12, quoted | 10-v2 says | Tier |
| --- | --- | --- | --- |
| **F12-1** | §1, §3.0 rows O5a/b, O6, O7, O8, §3.0 bullet 1 — **3 occurrences**: *"back `←`, `§5.2` md, **30.3 pt**"* | §7.2 [m] ⌀90 px; §10.5 `size.circleButton.md` = 90 = **30.0 pt**. 30.3 pt = 91 px — file 11's AA-inclusive ⌀91 (F11-23) | T2 |
| **F12-2** | §1, §3.0 rows O3/O4, §4.2, §4.2 ASCII, §3/O3 — **6 occurrences**: *"close `×`, `§5.2` sm, **27 pt**"* | §7.2 [m] ⌀80 px = **26.7 pt**. 10-v2 §0.1 forbids the rounding: *"the pt value is shown to one decimal and **is not rounded to a nicer number**"* | T2 |
| **F12-3** | §3/O3: *"overflow `⋯` **33.3 pt**"* | §7.2 [m] ⌀98 px = **32.7 pt**. 33.3 pt = 100 px — file 11's ⌀100 (F11-20) | T2 |
| **F12-4** | §3/O1 ×2, §4.3, §7 — **4 occurrences**: *"`§5.1` primary CTA (46 pt, **`radius.button` 4.5 pt**)"* | §10.4 [m]: `radius.button` = **13 px = 4.3 pt** | T2 |
| **F12-5** | §4.3: *"At the primary CTA's own **cap-37 Medium (≈28 px/char)**, `Out of service` is **392 px** and **does not fit**"* | cap **36** (§4.1 row 5). `≈28 px/char` is **[INVENTED]** — no measured Medium advance in any file is 28; the nearest is **28.8 = cap-36 *Bold*** (file 12 §0.2 row 1) | **T1 — verdict flips** |
| **F12-6** | §5.1 + §0/M9 — **3 occurrences**: *"Frame \| x 38 → 1167, y 1448 → 1782 = **1130 × 335 px = 376.7 × 111.7 pt** [m]"* | §7.10 [m]: `x39 → 1166, y1448 → 1781 = **1128 × 334 px = 376.0 × 111.3 pt**` | **T1** |
| **F12-7** | §5.1: *"Icon tile \| **257 × 257 px** `#3E3E3E`"* | §7.10 [m]: **256 × 257 px** | T1 |
| **F12-8** | §5.1: *"Padding \| **39 px all four sides**"* and *"**`39 + 257 + 39 = 335` exactly [m]**"* | §7.10's frame gives top pad `1487 − 1448 = 39`, bottom pad `1781 − 1743 = **38**`, total **334** [d]. §5.1 [m] records the family as *"**38–39** px"*. The identity is off by 1 px and is not *"exactly [m]"* | **T1** |
| **F12-9** | §5.1: *"Content box \| 1487 → 1743 (**335 − 2 × 39 = 257 px**)"* | At 334 with 39/38 padding the content box is **256 px** by that formula; the tile's own measured height is 257 | T1 |
| **F12-10** | §0.2 row 1: *"`135 000 RWF/day` … x 93 → 524 \| **432 px** \| 15 \| **28.8 px/char** [m]"* | 10-v2 does not measure this ink. File 11 §0.3 row 6 measures the same run at **433 px**. Two [m] claims, one string, 1 px apart | T3 |
| **F12-11** | §0.2 row 2: *"`Check Availability` … x 673 → 1045 \| **373 px** \| 18 \| **20.7 px/char** [m]"* | File 11 §0.3 row 6: **374 px** for the same run | T3 |
| **F12-12** | §3/O3: *"at the full **358.7 pt** content width"* | The `04` content column is 1078 px = **359.3 pt** [d]; 358.7 pt is `size.floatingCard`'s width. File 12's own §4.3 uses **1078 px** correctly two sections later | T2 |
| **F12-13** | §3/O3: *"with the `§6` **24 pt / 2 pt-stroke** glyph in the chip's icon slot"* | §7.5 [m]: chip icon `43 × 48 px`, **4.2 px** stroke; §10.3 `size.iconGridChip` = 48 px = **16 pt**; §8.2 Light band = **1.4 pt** | T2 |
| **F12-14** | §4.2: *"right-aligned to the divider's own right end (**x 1167**), so it begins at x 760 against a label column starting at **x 196**"* | §7.6 [m]: core **x39 → 1166**. And the screen's chrome is placed at `space.pageMargin` (§4.2: *"`§5.2` close `×` (27 pt) at `space.pageMargin`"*), so under file 11 §5.1's container rule the row's own divider is `x64 → 1141` and its label is at **x222** [d]. The fit is computed in the 38-px container on a 64-px screen | **T1** |
| **F12-15** | §4.2: *"a longest label of `GB/T DC · 60 kW` (15 chars, **≈300 px**)"* | At file 12's own cap-27 Bold constant: 15 × 21.4 = **321 px** [d] | T3 |
| **F12-16** | §0.2 caveat: *"the face's figures are old-style (**file 10 §1.2**)"* | §1.2 in v2 is **Contrast**. Old-style figures are **§3.2**. Not covered by the authority note's translation table | T3 |
| **F12-17** | §1 + §9/[RAISE-OA-2]: *"Pressed / disabled / focus state (**[?] in file 10 §9**)"* | §9 in v2 is **Elevation, blur, shadow**. *"Pressed / disabled / focus states — no screen shows one"* is in **§12, "Could not be measured"** | T3 |
| **F12-18** | §7: *"It takes file 10 **`§8.1`–`§8.4`** … and **none of `§8.5`**"* | v2 renumbers these to **§10.1–§10.5**. Covered by the authority note's table, so it resolves — but only for a reader who read the note | T3 |
| **F12-19** | §0.1: *"Per **R3** the forbidden list is written **once** … It is **file 11 §13**"* | Contradicted by file 12's own authority note 3 (*"Its one home is `docs/availability-display.md` §2.2b"*) and by 10-v2 §0.3/R3 (*"§11.2 of this file and nowhere else"*). File 12 then restates a three-item summary of the list anyway | T3 |
| **F12-20** | §3/O9: *"`§5.10` hosting card as the explanatory block (**85.7 pt** `#3E3E3E` tile …)"* | §7.10 [m]: `256 × 257 px = **85.3 × 85.7 pt**` — one figure quoted for a non-square tile | T3 |

---

## 4. Every fit calculation, recomputed

This is the section the ranking exists for. Sixteen fit or budget calculations
appear across the two files. Each was recomputed at 10-v2's values.

### 4.1 The one whose verdict flips — file 12 §4.3

> **File 12 §4.3:** *"Three-up across the 1078 px content column with two 27 px
> gaps gives **341 px per button**. At the primary CTA's own cap-37 Medium
> (**≈28 px/char**), `Out of service` is **392 px** and **does not fit**. At the
> sticky CTA's measured cap-32 Medium (20.7 px/char) it is **290 px**, leaving
> 25.6 px each side."*

Recomputed [d]:

| Constant | Source | `Out of service` (14 ch) | Fits 341.3 px? |
| --- | --- | --- | --- |
| **28 px/char** | **[INVENTED]** — no file measures this for Medium | 392 px | **no** |
| 21.25 px/char | file 11 §0.3 row 6 [m·11], `Let's find a car` 340 px ÷ 16 ÷ **cap 36** | **297.5 px** | **yes**, 21.9 px each side |
| 23.4 px/char | file 11 §0.4's *pessimistic* Medium k = 0.65 × **cap 36** | **327.6 px** | **yes**, 6.9 px each side |
| 24.05 px/char | k = 0.65 × cap 37 (the file's own stale cap) | **336.7 px** | **yes**, 2.3 px each side |
| 20.7 px/char | file 12 §0.2 row 2 [m], cap-32 Medium | 289.8 px | yes, 25.8 px each side |

**Where 28 came from:** file 12 §0.2 row 1 measures **28.8 px/char** for
`135 000 RWF/day` at **cap 36 Bold**. A Bold advance was used for a Medium
label.

**Consequence.** `Out of service` at the primary CTA's own label size fits at
every legitimate constant, including file 11 §0.4's deliberately pessimistic
one. The claim *"does not fit"* is false, and with it the sentence that opens
the paragraph — *"the arithmetic that forces it"* — because the arithmetic does
not force it. At the pessimistic constant the margin is 2.3 px each side
(0.8 pt), which is inside the ~5 % slack §0.2 declares, so *"does not fit
comfortably"* would survive; *"does not fit"* does not. **This is the single
most valuable finding in the sweep: it is the only fit in either file that
passes only at the wrong number.**

The shipped design (control row at cap 32 Medium) is unaffected — the smaller
label is still the prudent choice. What is affected is the justification, which
is currently an asserted impossibility that is not one, in a document whose
whole method is that impossibilities get raised rather than designed around.

### 4.2 The identity that does not close — file 11 §0.3 row 5

> *"**Content width 1078 = CTA 897 + gap 41 + locate 137.** The CTA's width is a
> *residual*, not a component property"*

| | CTA | gap | locate | total | vs 1078 |
| --- | --- | --- | --- | --- | --- |
| File 11 [m·11] | 897 | 41 | 137 | **1075** | **−3 px** |
| 10-v2 [m] §7.1/§7.2/§10.5 | **899** | **40** | **139** | **1078** | **exact** |

The identity is the sole evidence for the residual-width claim, which drives
[RAISE-D31], the S-01/S-02 button width, and §1's *"A width that is not a
token"*. **The claim survives — but only on 10-v2's figures, not the file's.**
File 11 asserts an exact identity from three numbers that do not add up, and
10-v2's three numbers do, exactly. That is a strong independent check that
10-v2's CTA frame is the right one.

### 4.3 The stacked-button fit — file 11 §8/S-02

> | Surface | Container | Three-up width [d] | ink | Verdict |
> | S-02 | **card inner box, 950 px** | (950 − 54) / 3 = **299 px** | 291 px | **fails — 4 px side clearance** |

Recomputed at the corrected inner box of **948 px** [d]:
`(948 − 54) / 3 = 298 px`; `(298 − 291) / 2 = **3.5 px**`.

**Verdict unchanged — it still fails, and the sheet still stacks.** The
conclusion is safe. The 950 px figure is not: it is the **shipped width** of
three buttons on two sheets (7 occurrences across S-01, S-02, §16 and §17), so
a build types 950 where 948 is correct.

The operator half of the same table — *"page content column, 1078 px →
(1078 − 54)/3 = 341 px, 291 px ink, fits, 25 px side clearance"* — is correct at
every input.

### 4.4 The hosting-card height reconciliation — file 12 §5.1

> *"the card's height is fixed by the tile, not by the text. **`39 + 257 + 39 =
> 335` exactly [m]**, so the content box is the tile's own height."*

At 10-v2's frame [d]: top pad 39, tile 257, bottom pad **38**, total **334**.
`39 + 257 + 39 = 335` is 1 px more than the measured card.

The downstream claims **survive**: the 3-line body ends at `y1718`, the tile
floor is `y1743`, clearance **25 px** ✓; a 4th line reaches `y1763`, overrun
**20 px** ✓. So the M9 reconciliation ("3 lines is a ceiling, 2 lines is the
copy, the card does not resize") holds. What does not hold is the identity it is
argued from, and its `[m]` marking.

### 4.5 The Regime-3 ladder — file 11 §8/D-02 — **changes emitted copy**

Not a staleness defect. A counting defect, found by recomputation, that changes
what a driver reads.

| Rung | String | File 11 | Recounted [d] | Fits 60? |
| --- | --- | --- | --- | --- |
| 0 | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 74 | **73** | no |
| 1 | `Operator, 14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 70 | **69** | no |
| 2 | `14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 60 — *"exactly, zero margin"* | **59** | **yes, 1 char spare** |
| 3 | `14 min · 1 bay free · 1 out of service · 1 unknown` | 51 | **50** | yes |

> **File 11:** *"Rung 2 lands exactly on the budget with no margin, so the
> composer takes rung 3."*

At the true count rung 2 fits, and the `busy` clause survives in the card
subtitle. **The decision to drop `busy` from the Regime-3 card rests entirely on
a one-character miscount.** Same off-by-one in the neighbouring table:
`Operator, 14 min ago · 2 of 4 bays free` is **39** characters, not 38;
`No GB/T DC bay here · 4 bays · Type 2, CCS2` is **43**, not 42. The direction
is conservative everywhere except rung 2, where it is decisive.

(The 60-character budget itself is safe: `594 px ÷ (27 × 0.73) = 30.14` → 30
chars/line; at the corrected column width of 593 px, `30.09` → still 30.)

### 4.6 The pin-dot re-derivation — file 11 §2.4

> *"`d − ringOuterRadius ≥ headRadius`, i.e. `d ≥ 61 + 14.5 = 75.5 px`, giving an
> offset of **(+53, −53) px**"*

Recomputed at `size.pin` = **120 × 147** [m, §10.5], head radius **60** [d]:
`d ≥ 60 + 14.5 = 74.5` → `74.5 / √2 = **52.7** → (+53, −53)`.

**Recommendation survives at the corrected pin.** Ranked T1 anyway, because the
input is stale and the output is already **locked into SPEC.md §6** (*"at
(+53, −53) px, tangent to the pin rim"*) and into file 11 §16/[RAISE-D26]. It
now needs re-deriving on the record rather than re-deriving in a sweep.

### 4.7 The category-chip fit — file 11 §7.2 — **this one runs the other way**

> | `Hybride` (reference) | 7 | 138 px [m·11] | **254 px** [m·11] |
> | `8 min · 2.9 km` | 14 | 276 px | **392 px** |
> | `~2.4 km straight line` | 21 | 414 px | **530 px** |

File 11 builds chip width as `ink + 86 + 30`. 10-v2 §7.5 and §12/[RAISE-5a] give
the padding as **88 / 29**.

At 88/29 [d]: `8 min · 2.9 km` → **393 px**; `~2.4 km straight line` → **531 px**.
Both still far exceed the fixed 254 px, so **[RAISE-D27] is unchanged** —
content-sizing or the placement is impossible.

**But note which file the error is in.** The chip measures `x480 → 733` = 254 px
and its label ink `x566 → 703` = 138 px [both m, and both files agree]. Left
padding = `566 − 480` = **86**; right = `733 − 703` = **30**; `86 + 138 + 30 =
254` ✓. At 10-v2's 88/29: `88 + 138 + 29 = **255** ≠ 254`. **File 11's padding
reconciles with the measured extents and 10-v2's does not.** Filed under §5.

### 4.8 The fits that are clean

Recomputed and correct at every input:

| Fit | File | Result |
| --- | --- | --- |
| D-03 sticky bar, four strings vs `x603` CTA start at 90 px padding, cap 36 Bold k = 0.80 | 11 | ✓ `No confirmed rate` 490 px, **23 px clear**. Every input matches §7.8/§10.3 |
| D-02 `nameShort ≤ 18` at cap 36 Bold k = 0.80 → 518 px in the 543 px column left of the heart | 11 | ✓ absolute x-coords, unaffected by the card frame |
| §1 sub-4 `Directions` 10 ch at k 0.65 → 208 px in 513 px | 11 | ✓ |
| §1 sub-5 `Let's find a charger` 20 ch at k 0.65 → 481 px (468 px at cap 36) in 897/899 px | 11 | ✓ at both caps and both widths |
| D-02 subtitle budget 594 px → 30 chars | 11 | ✓ unchanged at 593 px |
| O2 value slot: 39-ch clause = 835 px vs 594 px column; short forms 235 / 342 / 364 px | 12 | ✓ arithmetic exact; conclusion unchanged at 593 px |
| O3 `Update availability` 19 ch × 20.7 = 393 px in 513 px, 60 px each side | 12 | ✓ |
| §4.4 `Save 3 updates` 14 ch × 20.7 = 290 px in 513 px | 12 | ✓ |
| §4.2 `no confirmed status` 19 ch × 21.4 = 407 px | 12 | ✓ arithmetic — **container wrong**, see F12-14 |
| O3 sticky budget 510 px, `No confirmed rate` 490 px, 20 px clear | 12 | ✓ arithmetic — but file 11 computes the same slot as 513 px / 23 px clear from `x90`. Two budgets, one slot, 3 px apart |

---

## 5. Where 10-v2 itself should be checked

The rule is that 10-v2 outranks. Four places where the sweep found the
discrepancy pointing the other way. **Not corrections** — flags, because
"silently prefer the higher-ranked number" is how the first six corrections got
lost.

1. **§7.3, the pin.** States `Outer bbox 120 × 147 px` and, in the same row,
   *"verified on the isolated pin at **x961–1082**, y752–898"*. `1082 − 961 + 1 =
   **122**` [d]; `898 − 752 + 1 = 147` ✓. The stated bbox and the stated x-range
   disagree by 2 px unless AA is being excluded on x and included on y. Token
   `size.pin` = 120 × 147. File 11's 122 may be right and the token wrong.
2. **§7.5, the category chip's padding.** `88 / 29` does not reconcile with the
   chip's own measured extents; `86 / 30` does (§4.7 above). [RAISE-5a] quotes
   88/29 as a reference *defect*, so the exact figures carry weight.
3. **§10.4, `radius.button` = 13 px for "both CTAs".** §6 measures the sticky
   CTA at **~14 px = ~4.7 pt** and §7.8 repeats it. Files 11 and 12 both use
   ≈14 px for the sticky CTA, which matches §6/§7.8 and contradicts §10.4's
   token. A token that collapses two measured values needs to say it is doing so.
4. **§0.3 R3 and §11**, which assert the forbidden list's *"one place"* is
   10-v2 §11.2, against the ticket, both authority notes and
   `availability-display.md §2.2b`'s own title. See F11-40.

---

## 6. What propagated, and where

The sweep's brief noted that stale values *"have since propagated into new
work"*. Traced:

| Stale value | Origin | Propagated to |
| --- | --- | --- |
| ⌀81 / ⌀91 / ⌀100 circular buttons | file 11 §8/D-03, D-04 | **file 12** as `27 pt` / `30.3 pt` / `33.3 pt`, 10 occurrences, quoted as `§5.2`'s own measurements |
| hosting card `1130 × 335`, tile `257 × 257` | file 11 §6 | **file 12 §5.1**, re-marked `[m]` and *"re-verified for v2 off `02.png`"*, and used to build the `39 + 257 + 39 = 335` identity |
| `358.7 pt` as the page content width | file 11 D-03 | **file 12 §3/O3 and §4.2** |
| chip icon at `24 pt / 2 pt` | file 11 §9.1 | **file 12 §3/O3** |
| `radius.button` at a non-token value | 13.5 px (file 11) | **file 12** as `4.5 pt`, incl. §7's statement of the images-rounder-than-containers signature |
| cap-37 Medium for the primary CTA | file 11 §0.3 row 6 | **file 12 §4.3**, where it is combined with an invented 28 px/char advance |
| `(+53, −53)` from a ⌀122 pin | file 11 §2.4 | **SPEC.md §6** (survives re-derivation) |

**What did not propagate to SPEC.md:** the 897 px CTA, the 13.5/4.5 pt radius,
the 16 px card radius, the 1076 × 620 hero, the ⌀81/⌀91/⌀100 buttons, the
1130 × 335 card. SPEC.md §5 carries 10-v2's values in every case. The single
SPEC.md error (S-1) is not inherited from either inventory; it is an
independent mis-anchoring of `space.floatingCardBottomGap`.

---

## 7. Verdict

**Can the two v2 screen inventories be trusted as they stand?**

**No, not as dimension sources — and yes, as design records.** The distinction
is sharp and it is worth stating precisely, because "the inventories are stale"
would over-claim.

- **Every design decision in both files survives the sweep.** Sixteen fit
  calculations were recomputed; **fifteen keep their verdict** at 10-v2's
  values. The stacked report sheet still stacks. The route preview still cannot
  live in a fixed-width chip. The hosting card is still tile-fixed at 3 lines.
  The pin dot still lands at (+53, −53). The card subtitle still needs two
  lines. Nothing designed has to be redesigned.
- **One fit does not survive** (file 12 §4.3) and it fails in the direction that
  matters: it asserts an impossibility that is not one, from a number that
  exists in no document.
- **One arithmetic slip changes shipped copy** (file 11's Regime-3 rung 2), and
  it is not a staleness defect at all — it would have been there whatever file
  10 said.
- **Sixty distinct wrong values** are, however, in the two files a build would
  read for geometry, and they are cited *as* 10-v2 throughout. The authority
  notes at the top of both files are not sufficient: they name **one** conflict
  (the card radius) and the body then contradicts 10-v2 in thirty-nine other
  places in file 11 alone, nine of them being that same radius.

The mechanism is worth naming for whatever gets written next. **File 11 §0.3
was a good instrument used once.** It declared a measurement policy, listed six
corrections owed to a file that did not yet exist, and said part 1's originals
were void until it landed. File 10-v2 then landed, adopted five of the six
(M1–M4 and the `#717171` token are all in §0.2's change log), **corrected the
sixth in the opposite direction** (the card frame and its radius), and nobody
ran the reverse pass. The corrections owed *to* file 10 were paid; the
corrections owed *back* were not.

**Recommended sequencing** (recommendation only — this document fixes nothing):

1. **SPEC.md S-1 first.** It is one sentence in the locked document, in the list
   labelled *"would each have shipped visibly wrong"*.
2. **File 12 §4.3 second.** It is the only place either file asserts something
   the measurements do not support. Either re-derive the composition on a
   correct constant or raise it — the two options the standing rule allows.
3. **File 11's Regime-3 ladder third**, because it changes what a driver reads.
4. **Then the sixty values**, mechanically, by root cause: the card frame
   (7 defects, 20+ occurrences), the CTA (6), the hero (5), the circular buttons
   (5, plus 10 in file 12), the pin (3), the hosting card (3, plus 4 in file 12),
   the settings container (2, plus 1 in file 12).
5. **Last, the four flags in §5** — the places where 10-v2 is the one that needs
   re-measuring, which should be settled before the values above are copied out
   of it.
