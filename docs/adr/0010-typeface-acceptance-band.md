# ADR-0010 — The typeface ships as an acceptance band, chosen free-first

Date: 2026-08-14 · Status: accepted · Founder call from SPEC.md §12

## Context

Ticket 17 measured the reference's type at 3× across six runs and could not name
the family. Confidence went *down* between revisions, not up: Raleway — the
candidate v1 leaned on at 65–70% — fell to **~15%** once two metrics were
re-derived, because it renders 4% taller and 6% wider than measured, and no
rendering pipeline stretches a face in two axes by accident.

What is known with high confidence is the **classification**: a wide geometric
sans, x-height/cap 0.750, cap `O` 0.969 w/h, lowercase `o` 1.028 w/h,
double-storey `a`, single-storey `g`, canted terminals, an `M` vertex stopping
16% above the baseline, real `liga`, four weights from ≈200 to ≈700 — and
**old-style figures by default**, with `3 4 5` descending 5–9 px at cap 27–47.

Most likely (~55%) it is an unidentified geometric sans whose `onum` set is on
by default, or (~25%) a named one with old-style enabled globally. Airbnb Cereal
fits the metrics better than Raleway and is unlicensable, so it is moot.

A design system cannot ship "we think it might be Circular".

## Decision

**`packages/ui` names no family from the design record.** The operative
deliverable of the typeface work is the **acceptance band** in
[`10-design-system-v2.md` §3.5](../../.scratch/ev-guide-spec/design/10-design-system-v2.md):

| Metric | Band |
| --- | --- |
| x-height / cap | 0.75 ± 0.015 |
| cap `O` w/h | 0.97 ± 0.03 |
| lowercase `o` w/h | 1.02 ± 0.04 |
| ascender / cap | 1.02–1.04 |
| descender / cap | 0.28–0.33 |
| `M` vertex | stops ≈16% of cap above the baseline |
| **Figures** | **old-style by default — non-negotiable** |
| Weights | 4 required: ≈200 / 400 / 500 / 700 |
| Tracking | 0 em ± 0.015 |

**Selection is free-first.** Candidates are tested in this order:

1. Free faces (Fontshare, Google Fonts, and any openly licensed geometric sans)
   that meet the band, with `onum` enabled globally if the face carries the set.
2. **Only if none passes**, license a retail face — Circular Std, Aeonik,
   GT Walsheim, Greycliff CF and the rest of §3.4's list are the candidates.

**The 60-second check that settles it**, before any family is pinned: set
`135 000 RWF/day — Forthing T5 — 2024 — CTO Motors Group Rentals` at cap 32 px
and overlay against `refs/04.png`. Reject on any of: `3 4 5` not descending;
`O` measurably oval; `n` height ≠ 0.75 × `T` height; `M` vertex on the baseline.

## Rationale

- **A band is more useful than a name**, and it is what was actually measured. A
  named guess would be relitigated the first time someone put it beside the
  reference; a band is falsifiable in sixty seconds.
- **Free-first, because the product has no revenue.** EV Guide is free with no
  monetisation anywhere; a perpetual or per-app type licence is a standing cost
  against zero income, and it should be paid only when the band demands it —
  not to settle a question a free face might settle.
- **Old-style figures are non-negotiable** because they carry a substantial part
  of the reference's character: descending `3 4 5` appear in every price, year,
  power rating and model number in the product. A face without an `onum` set
  does not fail *elegantly* here, it fails the reference.
- **Raleway was rejected despite being the convenient answer** — free, four
  weights, default old-style. Keeping it required believing two independent
  measurements were noise in the same direction six times.

## Consequences

- The band is an **acceptance test in `packages/ui`**, not a note: the chosen
  face is checked against it, and the check is re-run if the face ever changes.
- **Every point size in the design record inherits ±3%** from an assumed
  cap-height/em of 0.70–0.72, which is not measurable without the face. The cap
  heights themselves are exact; the pt conversions firm up once a family is
  pinned, and no layout should be built to depend on the pt figure where the
  cap figure is available.
- **If no candidate carries old-style figures, that is an impossibility to
  raise, not a detail to drop** — it comes back to the founder as a fresh call,
  with the cost stated (either a licence, or the reference's figure character is
  lost).
- The design record's `font.family` token stays deliberately unresolved until
  the build effort runs the check.
