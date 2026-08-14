# 34 — Declare the extent convention, and pay for it in SPEC.md

Type: decision
Status: open — raised 2026-08-14 by ticket 32
Blocked by: — (the measurement is done; this is a cost decision)

## Question

Ticket 32 item 2 instructed: *"Declare an edge convention in file 10 §0.1.
Several of the 60 are a core/anti-aliasing split — 899 vs 897, 1076 vs 1078,
138 vs 137 — where both numbers are defensible and the corpus never said which
it meant. Until that convention exists, the same class of defect regenerates."*

The instruction was right about the defect and wrong about the price. **Every
candidate convention breaks values that are locked in `SPEC.md`**, so ticket 32
could not declare one unilaterally and raised it instead.

## The finding

A component's size reads three ways, and **file 10 has been using two of them
without saying so**:

| Element | core | integrated (true) | AA-inclusive | file 10 publishes |
| --- | --- | --- | --- | --- |
| Primary CTA (`01`) | 897 × 136 | **898.00 × 137.25** | 899 × 138 | **AA-inclusive** |
| Floating card (`03`) | 1076 × 521 | **1077.60 × 521.53** | 1078 × 522 | **core** |
| Sticky CTA (`04`) | 513 × 131 | 513.00 × 131.25 | 513 × 132 | core |
| Map pin (`01`) | 122 × 147 | 122.3 × 147.25 | 124 × 148 | *neither* |

Two adjacent components in one file, measured to opposite conventions, with
nothing anywhere declaring which was meant. The two published figures sit on
opposite sides of their own true values: the CTA is published **1.0 px wide and
0.75 px tall larger** than the truth, the card **1.6 px wide and 0.53 px tall
smaller**.

Neither reading is a property of the component. An element whose edges land on
whole pixels reads the same all three ways — the `04` sticky CTA's 513 px width,
whose left, right and top edges are **hard**. One whose edges land mid-pixel
reads 2 px apart. The rasteriser quantises coverage to quarter-levels (2×2
supersampling), so every fractional figure above is good to ±0.25 px.

## This has already caused one wrong "correction"

Commit `6a5a922`, 2026-08-14, four commits before this ticket was raised:

> *"SPEC: CTA is 899 x 138 px, matching size.ctaHeight (was 137)"*

SPEC.md said **137**. It was changed to **138** — not by measuring, but by
matching the token. The true integrated height is **137.25 px**, so the value
that was there was the closer of the two, and the "correction" moved it away
from the reference. Nobody did anything wrong: with no convention declared,
matching the token is the only available tiebreak, and it is the wrong one.

That is the argument for closing this ticket rather than living with the
ambiguity. It is not hypothetical churn — it has already happened once, in the
locked document, in the direction of the number that is less true.

## The cost of each candidate, counted honestly

| Convention | Locked `SPEC.md` values broken | Which |
| --- | --- | --- |
| **Core** | **2** | `size.ctaHeight` 138 → 136, and §5's *"899 × 138 px"* → 897 × 136 |
| **AA-inclusive** | **3** | `size.floatingCard` → 1078 × 522, `size.ctaHeightSticky` → 132, `size.pin` → 124 × 148 |
| **Integrated** | **4** | all of the above plus `size.ctaHeight` → 137.25 |

`size.pin` moves under **all three**, so it is not a bargaining chip — ticket 32
corrected it on its own merits (120 was a plain error matching no convention).

**AA-inclusive is the only candidate that preserves `size.ctaHeight` = 138**,
which SPEC.md cites twice — in §5's component sizes and again in §12's
form-control ruling (*"the field is the secondary-control box — `color.surface`
at `size.ctaHeight` 138 px"*). **Integrated is the most truthful**: it is the
only reading that measures the element rather than its accidental sub-pixel
phase, it is the convention §0.1 *already* mandates for strokes, and it is the
number that reproduces the reference when typed into a build. It is also the
only one that yields fractional tokens (137.25 px, 45.75 pt).

## What must be decided

1. Which convention file 10 §0.1 declares.
2. Whether SPEC.md's locked values are amended to match, or whether SPEC.md
   keeps its numbers and the design record records the divergence. **The second
   option is how this defect regenerated in the first place** and is not
   recommended, but it is the cheaper one and the choice is the founder's.
3. Whether tokens carry the fraction (`137.25`) or round, and if they round,
   which way — because a rounding rule that is not written down is exactly the
   ambiguity this ticket exists to close.

## Meanwhile

File 10 §0.1 carries the three-way table and an explicit **"NOT YET DECLARED"**.
Ticket 32 re-derived files 11 and 12 against **what file 10 publishes**, which is
its actual instruction, and noted in each file that those sizes are
convention-dependent and move if this ticket rules for core or integrated.

## Answer

*(pending)*
