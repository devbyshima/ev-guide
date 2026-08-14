# 33 — Every radius in the design system is under-read

Type: decision
Status: open — raised 2026-08-14 by ticket 32's flag pass
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

*(pending)*
