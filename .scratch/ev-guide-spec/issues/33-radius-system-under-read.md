# 33 — Every radius in the design system is under-read

Type: decision
Status: **resolved 2026-08-16** — six rows re-fitted, signature finding ruled;
`SPEC.md` amendment pending the founder (bundled with ticket 34)
Blocked by: — (the measurement is done; what is owed is a ruling and six re-fits)

## Question

Ticket 32 was asked to re-check `10-design-system-v2.md` in four places where
the staleness sweep suspected file 10 itself was wrong. Three of the four
resolved into ordinary corrections. The fourth did not: `radius.button` = 13 px
"both CTAs" was not a token collapsing two measured values, as the sweep
supposed. **Both measured values are wrong, and so is every other radius in
§6, because §6's stated method is geometrically false.**

## The defect

§6 said:

> *"All measured by corner-arc profiling: for a rounded rect the topmost
> scanline's fill begins `r` px in from the left edge, and the leftmost column's
> fill begins `r` px down from the top."*

That identity does not hold. For a corner of radius `r` whose true edge lies at
offset `d` above a scanline, that scanline's fill begins **`r − √(2rd − d²)`** px
in — roughly **`r − √r`** at the first scanline. `r` is where the *straight edge*
begins, not where the first scanline's fill does. The table therefore under-reads
every row by about `√r`, by an amount that varies with each element's sub-pixel
phase, which is why the errors are not a constant offset.

**The file's own evidence already contradicted it.** §7.4 records, as its corner
proof, that the floating card's row 1797 first carries card colour at **x79** —
14.5 px in from the true edge at x64.5. A 14 px radius predicts **8.8 px** there.
The observation was read *as* `r`, and the 14 px token was derived from it.

## What was re-measured

Three independent estimators, agreeing: a rasteriser-matched model fit, a
least-squares circle through sub-pixel boundary points, and a **threshold-free**
corner-missing-area check (`area = r²(1 − π/4)`), which needs no arc-extent or
threshold decision at all. Cross-checked a fourth time by hand on the floating
card (missing area 82.75 px² measured, against 81.6 predicted at r = 19.5 and
42.1 at r = 14).

| Element | published | re-measured | band | SSE at published vs optimum |
| --- | --- | --- | --- | --- |
| Primary CTA (`01`, `03`) | 13 ±2 | **16.4** | 16.3–16.6 | 60.7 vs 1.3 — 46× worse |
| Sticky CTA (`04`) | ~14 | **16.2** | 16.0–16.6 | 37.6 vs 2.2 — 17× worse |
| Floating card (`03`) | 14 | **19.5** | 19.3–19.8 | 133.3 vs 2.7 — 50× worse |
| Hosting card (`02`) | 13 | **15.5** | 15.2–15.8 | 37.0 vs 2.0 |
| Category chip (`03`) | 31.5 | **38.4** | — | — |

Every one under-reads, and the error tracks `√r` as the wrong model predicts.

**Six rows were never re-fitted** — hero badge, hero image, card thumbnail,
hosting-card icon tile, feature chip, drag handle — and carry the same bias.

## What must be decided

1. **Re-fit the six remaining rows.** Cheap; the harness exists.
2. **Then rule on the signature finding**, which cannot be evaluated until they
   are done. §6 currently closes on *"images are rounder than containers"* —
   images and thumbnails 10 pt, near-pills 10.5 pt, containers 3.3–4.7 pt — and
   calls that inversion the thing `packages/ui` must not "fix". At the
   re-measured values the floating card (19.5) has overtaken the buttons (16.4)
   and is closing on the images (30). If the image rows are equally under-read
   the inversion may narrow, hold, or invert outright. **The finding is not
   currently supported either way.**
3. **Accept the cost, which is why this is a ticket and not a correction.**
   Correcting the values moves `radius.*` in `packages/ui` **and** the radius
   table in **`SPEC.md` §5, which is locked** — `chip 10 · card 13 · button 13 ·
   floatingCard 14 · handle 6.5 · image 30 · nearPill 31.5`. It also moves
   SPEC.md's finding 1, *"The CTA is not a pill — r ≈ 13 on a 899 × 138 px
   button"*. The "not a pill" conclusion survives comfortably at 16.4 (a pill
   needs 69), so what changes is the number, not the finding.

## One thing this settles already

`radius.button`'s "both CTAs" is **correct**, and radius is **not** a fourth
[RAISE-4] difference between the two CTA components. A single radius fits all
eight corners of both CTAs with **zero** penalty (total SSE 3.50 either way);
the 0.2 px gap between them is one fifth of either one's own error bar. Do not
create a `radius.buttonSticky` token.

## Meanwhile

File 10 §6 carries a warning banner and its **values are left unchanged**, so
nothing silently shifts under a reader. Ticket 32 **froze every radius in files
11 and 12** rather than correcting them to values that are themselves wrong —
each occurrence is marked `[radius frozen: RAISE-13/ticket 33]`. **No radius
anywhere in the design record may be read by a build until this closes.**

## Answer

**Resolved 2026-08-16. The six rows are re-fitted, and the ruling is: correct the
values.** The harness was rebuilt from scratch and re-validated against all four
of ticket 32's re-measurements before it was pointed at anything new.

### Harness validation

Same two estimators as ticket 32 — a supersampled analytic-coverage model fit
(least squares over `r`) and the threshold-free missing-area check — plus a
**stadium model** that ticket 32 did not have, which matters below. Run against
the four already-published re-measurements:

| Element | ticket 32 | this pass | SSE at optimum |
| --- | --- | --- | --- |
| Floating card (`03`) | 19.5 (band 19.3–19.8) | **19.50** | 0.55 |
| Primary CTA (`01`) | 16.4 (band 16.3–16.6) | **16.50** | 0.27 |
| Sticky CTA (`04`) | 16.2 (band 16.0–16.6) | **16.60** | 0.28 |
| Hosting card (`02`) | 15.5 (band 15.2–15.8) | **15.60** | 0.36 |

Every one inside its published band. The harness is sound.

### 1. The six rows, re-fitted

| Row | published | **re-fitted** | pt | method / conditioning |
| --- | --- | --- | --- | --- |
| **Hero badge** (`04`) | ~32 | **35.4 = ½ height — a full pill** | 11.8 | stadium; the quadrant model is *invalid* here and returns 39.6, above the geometric cap |
| **Hero image** (`04`) | 30 | **[?] — confirmed not re-derivable** | — | see below |
| **Card thumbnail** (`03`) | 30 | **31.8** (band 30–33) | 10.6 | four-corner joint fit, 4 089 well-conditioned px; SSE curve is shallow |
| **Hosting-card icon tile** (`02`) | ~15 | **15.2** (±1) | 5.1 | 5-level contrast (`#3E3E3E` on `#393939`); barely moves |
| **Feature chip** (`04`) | 10 | **13.4** | 4.5 | quadrant, SSE 0.26 — clean |
| **Drag handle** (`03`) | 6.5 | **6.4 = ½ height** | 2.1 | stadium; **unbiased — see below** |

**The handle was never wrong.** Its 6.5 was derived from the *constraint*
"fully rounded", not from the false arc identity, so it carries none of the
bias. Measured box `513.00 → 693.00 × 1822.25 → 1835.00` = 180.00 × 12.75 px,
and every `r` in 6.375–6.55 fits within noise (SSE 0.25–0.29) against 0.67 at
r = 6.0. It is a stadium; ½ height stands, and ½ of the integrated height is
**6.4**, not 6.5.

**The hero image is genuinely unmeasurable, and for a second reason §7.7 never
recorded.** §7.7 blamed the photo — dark and near-neutral at all four corners,
which is true (the `TL` interior samples 19–21 against a background of 18). But
**the background under the hero is not `#121212` either**: it is a soft gradient
running 20 → 32 across the corner regions, and directly below the hero's bottom
edge it reads **32** — *brighter* than the photo above it. A fit that assumes a
uniform `#121212` backdrop returns r ≈ 45–48 with apparently good SSE, and that
number is an **artifact of the wrong background**, not a measurement. It is
recorded here only so nobody re-derives it and believes it. **The hero keeps the
thumbnail's token**, as §7.7 already ruled — which now means **31.8, not 30**.

### 2. The signature finding, now that it can be evaluated

§6 closed on four claims. Re-derived in pt (px/3):

- pills — category chip **12.5**, hero badge **11.8**
- images — thumbnail **10.6**, hero (inherits) **10.6**
- containers — floating card **6.5**, button **5.5**, hosting card **5.2**,
  icon tile **5.1**, feature chip **4.5**, handle **2.1**

**a. "Images are rounder than containers" — HOLDS. [held]** Images 10.6 pt
against containers 4.5–6.5 pt. The margin narrows from 2.1× to **1.6×** against
the softest container, and is 2.4× against the buttons. It is not close to
inverting, and the instruction to `packages/ui` stands unchanged.

**b. "Buttons are the least rounded things on the screen" — FALSE, and was
already false in the table it was written under.** The feature chip is
**4.5 pt** against the button's 5.5 pt, and it was **3.3 against 4.3** in the
published values too. The claim never survived its own table; the re-fit does
not cause this, it exposes it.

**c. "After M2 the floating card is in the same 4.7 pt bracket as the buttons" —
OVERTURNED.** Card **6.5 pt** against button **5.5 pt**: a full point apart, and
the card is now the *softest* container in the system rather than a peer of the
buttons. The M2 correction (all four corners equal, not "16 top, square bottom")
is unaffected — that was a corner-count finding, not a radius value.

**d. Correction #3, "the category chip and hero badge *approach* a pill but
measurably fall short … build them with an explicit radius, not
`borderRadius: 9999`" — OVERTURNED. Both are pills.**

- **Hero badge**: integrated box 249.27 × 70.75 px, so the geometric cap is
  35.375. The free stadium fit returns **35.60 — above the cap** — and SSE at
  the cap is **15.1 against 85.4 at the published 32**, a 5.7× penalty. It is a
  pill.
- **Category chip**: integrated box 254.75 × 76.75 px, cap 38.375. Across
  sub-pixel edge phases the fit lands **37.1 – 38.05** against a cap of
  38.375–38.625 — i.e. **0.3 to 1.3 px short, inside the ±0.5 px error of the
  method**. Ticket 32's 38.4 was already sitting on the cap and nobody read it
  as the pill it was.

Both are `borderRadius: 9999`. **This is the reverse of the instruction the
record currently gives `packages/ui`**, and it is the one finding in §6 whose
correction changes what gets *typed* rather than only what number is typed.

### 3. `radius.button` — confirmed a second time

16.50 (primary) against 16.60 (sticky), a 0.1 px gap against ±0.5 px error.
**Do not create a `radius.buttonSticky` token.** Unchanged from ticket 32.

### 4. The corrected table

| Element | radius px | radius pt | basis |
| --- | --- | --- | --- |
| **Category chip** (`03`) | **pill** (½ h = 38.4) | 12.8 | ½ integrated height |
| **Hero badge** (`04`) | **pill** (½ h = 35.4) | 11.8 | ½ integrated height |
| **Card thumbnail** (`03`) | **31.8** | 10.6 | four-corner joint fit |
| **Hero image** (`04`) | **31.8** [d] | 10.6 | inherits the thumbnail token — **[?]** in its own right |
| **Floating card** (`03`) | **19.5** | 6.5 | ticket 32, re-validated |
| **Primary + sticky CTA** | **16.5** | 5.5 | one token, both CTAs |
| **Hosting card** (`02`) | **15.6** | 5.2 | ticket 32, re-validated |
| **Hosting-card icon tile** (`02`) | **15.2** | 5.1 | ±1, low contrast |
| **Feature chip** (`04`) | **13.4** | 4.5 | clean |
| **Drag handle** (`03`) | **pill** (½ h = 6.4) | 2.1 | never biased |
| Circles | ½ diameter | | |

### 5. The cost, and what is done about it

`SPEC.md` §5's locked radius table — `chip 10 · card 13 · button 13 ·
floatingCard 14 · handle 6.5 · image 30 · nearPill 31.5` — is wrong in **all
seven rows**, and its finding 1 quotes *"r ≈ 13"* for the CTA. The *conclusion*
"the CTA is not a pill" survives comfortably (a pill needs 69 against a measured
16.5); only the number moves. `nearPill` should not exist as a token at all —
it is `pill`.

**File 10 §6 is corrected under this ticket** and its freeze is lifted; files 11
and 12's `[radius frozen: RAISE-13/ticket 33]` marks can be released against the
table above. **`SPEC.md` is NOT amended here** — it is a locked founder document
and its radius rows move together with ticket 34's extent convention (½-height
pills are stated in terms of a height, and *which* height is exactly what 34
rules on). Both amendments are put to the founder as one edit.
