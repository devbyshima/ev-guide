# 34 — Declare the extent convention, and pay for it in SPEC.md

Type: decision
Status: **resolved 2026-08-16** — integrated declared, SPEC.md amended;
remaining sizes swept under ticket 36
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

**Ruled 2026-08-16 by the founder: the convention is INTEGRATED, and `SPEC.md`
is amended to match.** Both halves of question 2 went the truthful way rather
than the cheap way.

### 1. The declaration

> **A component's published size is its *integrated* extent** — the sum of
> coverage across a cut, i.e. where the element's edges truly lie, independent of
> the sub-pixel phase the rasteriser happened to catch them at. This is the
> convention `§0.1` already mandates for strokes; it now governs every size in
> the record. **Core and AA-inclusive readings are diagnostic only** and are
> given alongside where they differ, never published alone.

The argument that carried it is the one the ticket already made: integrated is
the only reading that measures the *element* rather than its accidental phase,
and the only one that reproduces the reference when typed into a build. Its two
costs are accepted — it breaks the most locked values (4), and it is the only
candidate that yields fractional tokens.

### 2. Rounding — question 3

**Tokens carry the fraction. Nothing is rounded.** `size.ctaHeight` is
**137.25 px = 45.75 pt**, written as measured. A rounding rule is exactly the
undocumented tiebreak that produced commit `6a5a922`, and the cheapest way to
guarantee this defect never regenerates is to have no tiebreak to get wrong.
Fractional px at @3x are not an implementation problem: 137.25 px is 45.75 pt,
which React Native lays out exactly.

Where px/3 is not exact the pt value is given to **two** decimals (v2's §0.1 said
one, which cannot represent 45.75); the px figure remains authoritative.

### 3. The converted values

| Element | published was | **integrated (published now)** | pt |
| --- | --- | --- | --- |
| Primary CTA (`01`, `03`) | 899 × 138 (AA-inclusive) | **898.00 × 137.25** | 299.33 × 45.75 |
| Floating card (`03`) | 1076 × 521 (core) | **1077.60 × 521.53** | 359.20 × 173.84 |
| Sticky CTA (`04`) | 513 × 131 (core) | **513.00 × 131.25** | 171.00 × 43.75 |
| Map pin (`01`) | 122 × 147 (neither) | **122.30 × 147.25** | 40.77 × 49.08 |
| Drag handle (`03`) | 180 × 13 | **180.00 × 12.75** | 60.00 × 4.25 |
| Feature chip height (`04`) | 105 | **105.49** | 35.16 |
| Category chip (`03`) | 254 × 76 | **254.75 × 76.75** | 84.92 × 25.58 |

The handle and the two chips were **not** among the four the ticket named; they
came out of ticket 33's re-fit, which had to establish each element's true box
before it could fit a radius to it. The handle's height matters beyond bookkeeping
— **½ of 12.75 is 6.4, which is the handle's radius**, so the convention and the
radius are the same measurement.

### 4. What this costs, paid

Four locked `SPEC.md` values move, as counted: `size.ctaHeight`,
`size.ctaHeightSticky`, `size.floatingCard`, `size.pin`. `SPEC.md` §5 is amended
under this ticket together with ticket 33's radii, and §12's form-control
sentence — *"the field is the secondary-control box — `color.surface` at
`size.ctaHeight` 138 px"* — is amended with it. **Commit `6a5a922` is reverted
in substance**: the CTA height returns past 137 to **137.25**, which is what it
always measured.

### 5. What is NOT converted, and why that is a ticket

`SPEC.md`'s component-size line carries ~15 further values — circular buttons
80/90/98/139, quickAction 150, the three avatars, thumbnail 300, statusDot 20,
accentRing 3, puck 40/82 — **all measured before a convention existed**. Several
almost certainly read the same under all three (the sticky CTA's 513 px width is
the worked example of an element whose edges are hard), but *which* ones has not
been checked, and the thumbnail already looks like it is not 300.00 on a single
cut. Converting them by assumption would be the same move that produced
`6a5a922`.

**Raised as [ticket 36](36-size-line-convention-sweep.md)**: sweep the remaining
sizes to the declared convention. Until it closes, those values are marked in
`SPEC.md` as pre-convention.
