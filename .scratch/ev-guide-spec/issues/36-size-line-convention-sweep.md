# 36 — Sweep the remaining component sizes to the declared convention

Type: task
Status: **resolved 2026-08-16** — every size converted; files 11/12 propagation still owed
Blocked by: — (the convention exists; this is measurement)

## Question

Nothing to decide. [Ticket 34](34-extent-convention.md) declared **integrated**
as the extent convention and converted the seven values that ticket 33's radius
re-fit had already established true boxes for. **The rest of `SPEC.md`'s
component-size line was measured before a convention existed** and has not been
checked against it:

circular buttons 80 / 90 / 98 / 139 · quickAction 150 · avatars 129 map /
316 profile / 76 owner · thumbnail 300 · statusDot 20 · accentRing 3 ·
puck 40 disc / 82 halo — plus every size in `§7` of
[file 10](../design/10-design-system-v2.md) not listed in ticket 34's table.

Several will read the same under all three conventions: an element whose edges
land on whole pixels is convention-independent, and the sticky CTA's 513 px
width is the worked example. **Which ones has not been established**, and
assuming it is precisely the move that produced commit `6a5a922`.

## One value already looks wrong

A single horizontal cut through the `03` thumbnail at y2020 puts its integrated
width at **≈299.0**, not the published 300 — its left edge at x128 carries only
partial coverage, so it is not a hard-edged element. One cut through a photo is
not a measurement; it is a reason to run this sweep rather than assume.

## Files 11 and 12 carry the same debt

Ticket 34's *Meanwhile* recorded that ticket 32 re-derived files 11 and 12
against **what file 10 publishes**, and that those sizes *"move if this ticket
rules for core or integrated"*. It ruled for integrated, so they move. Both files
still carry `899 × 138`, `1076 × 521`, `513 × 131`, `size.ctaHeight = 138 =
46.0 pt`, `handle 180 × 13` and `hero 1078 × 612` in prose, in tables and in the
ASCII diagrams' annotations. **Ticket 33's radius release swept this file pair
for radii only** — the sizes were deliberately left, because converting them is
this ticket's job and doing half of it in a radius commit is how a record drifts.

`size.ctaHeight` is the one to watch: it appears as a *derived* quantity in the
form-control ruling (the field box) and in the operator/admin surfaces that take
primary-CTA geometry, so it moves in more places than a grep for `138` finds.

## Method

`§0.1`'s integrated technique: `Σ (v − bg)/(fg − bg)` across a cut, taken at
several positions along each edge and moded, exactly as ticket 33's harness did
for the four contested elements. Report core / integrated / AA-inclusive for
every row so the next reader can see which are convention-independent.

Where an element is photo-filled, note the conditioning — ticket 33 found that
the `04` hero sits on a **20 → 32 gradient**, not `#121212`, and that a fit
assuming a uniform dark ground returns a confident, wrong answer.

## Answer

**Swept 2026-08-16.** Every remaining size is measured at its integrated extent.
Three results are corrections rather than conversions, and one is a defect in
`SPEC.md` rather than in the measurement.

### 1. The sweep

| Element | published | **integrated** | pt | verdict |
| --- | --- | --- | --- | --- |
| Close `×` (`04`) | 80 | **81.4** | 27.13 | moves |
| Back `←` (`02`) | 90 | **90.8** | 30.27 | moves |
| Overflow `⋯` (`04`) | 98 | **99.5** | 33.17 | moves |
| Locate `➤` (`01`, `03`) | "137–139" | **137.7** | 45.90 | a range resolves to a number |
| Quick action ① (`02`) | — | **154.8** | 51.60 | see §2 |
| Quick action ② (`02`) | — | **150.3** | 50.10 | see §2 |
| Quick action ③ (`02`) | — | **149.9** | 49.97 | see §2 |
| Profile avatar (`02`) | 316 | **315.9** | 105.30 | **holds** |
| Map avatar (`01`) | 129 | **128.6** | 42.87 | moves |
| Owner avatar (`04`) | 76 | **76.7** | 25.57 | moves |
| Thumbnail (`03`) | 300 | **≈297.5 ±1.5** | 99.17 | **cannot be pinned** — see §3 |
| Status dot | "20–21" | **20.4** | 6.80 | a range resolves to a number |
| Accent ring | 3 | **3.0** | 1.00 | **holds exactly** |
| Puck disc | 40 | **39.6** | 13.20 | holds |
| Puck ring | 4 | **4.0** | 1.33 | **holds exactly** |
| Puck halo | 82 | **82.0** | 27.33 | **holds exactly** |

Circles are measured by **integrated area** (`D = 2√(A/π)`), which needs no edge
location at all and is therefore immune to the sub-pixel phase that ticket 34 is
about. Where an element carries a glyph darker than its own fill — the locate
button's arrow is **filled `#000000`**, the only filled icon in the system —
a coverage-from-background reading counts the glyph as *outside* and under-reads
the diameter by ~20 px. Those were measured edge-to-edge instead.

**Ticket 34's prediction is confirmed in both directions.** Elements with hard
edges read the same under every convention and did not move: `accentRing` 3.0,
the puck ring 4.0, the puck halo 82.0, the profile avatar 315.9. The elements
that moved all moved **up**, by 0.4–1.5 px, which is what a pixels-touched count
does against an integrated one.

### 2. `size.quickAction` is one token for three different buttons

`SPEC.md` publishes **`quickAction 150`**. There are three of them and they
measure **154.8 / 150.3 / 149.9** — the first is **4.9 px (1.6 pt) larger** than
the other two, which is above any measurement error here.

This is not a sweep finding: **file 10 §7.2 already recorded "154 / 149 / 149"**,
and §7.2's own preamble says *"Five different diameters. Listed as measured; §12
raises the inconsistency rather than harmonising it."* The single 150 token was
introduced when the sizes were carried into `SPEC.md`, and it **harmonised
exactly what the design record refused to harmonise**. The 1:1 rule makes this a
defect, not a simplification.

`SPEC.md` now carries all three. Whether `packages/ui` ships three tokens or one
plus two overrides is a build decision; what it may not do is pick 150 and lose
the distinction.

### 3. The thumbnail cannot be pinned, and every method reads below 300

Three estimators disagree by 4 px and **all three land under the published 300**:
a single clean cut gives 299.0, a 35-cut median gives 297.5, and the three
highest-contrast rows give 294.9. The disagreement is systematic — the brighter
the reference sample, the smaller the width — which is the signature of a photo
that darkens toward its own edge, biasing any estimate that normalises by an
interior sample.

**What is solid: 300 was a pixels-touched bbox**, the same over-read §0.1 already
documented for strokes ("*where v1 reported a white run of exactly 6 px it was
counting pixels touched, which over-reads by 1–2 px*"). Published as
**≈297.5 ±1.5**, with the band, not a false precision. This is the second
photo-filled element the record cannot resolve, after the `04` hero (ticket 33).

### 4. The heading cone is real, mis-described, and unmeasured

Not a size on the list, found while measuring the puck. **`10-v2` §2.5 does
record a heading cone** — so this is not an undocumented element — but both of
its statements are wrong:

- *"projecting from the disc"* — it is **detached**. Measured row by row on
  **both** map screens, the gap between the blue disc and the cone is **6–7 px at
  every row**, never zero. That is the 4 px white ring plus its anti-aliasing:
  the cone sits **outside the ring**, clear of the disc.
- *"⌀ ≈ 82 px envelope"* — 82 px is the **halo's** diameter, which the cone sits
  inside. The cone itself measures **16 × 19 px** (`01`: x626–641, y1306–1324;
  `03`: x200–215, y1473–1490), area ≈130 px, in the same `#4285F4`, at the same
  bearing on both screens.

`size.puck` publishes "40 disc / 82 halo" and has **no cone term**, so a build
sizing the puck from the tokens draws a plain dot and silently drops the heading
indicator. Added as **`size.puckCone` 16 × 19** with the gap recorded, and
[RAISE-10] is amended: the ADR-0009 redraw off Google's blue has **four** parts
to redraw, not three.

### 5. Propagated into files 11 and 12 — and it reversed two of ticket 32's own corrections

67 sites converted. Three results were not conversions:

- **Ticket 32's circular-button corrections went the wrong way.** It moved close
  `×` ⌀81 → 80, overflow `⋯` ⌀100 → 98 and back `←` ⌀91 → 90, calling the
  originals *"the AA-inclusive read, the same defect as the `04` close and
  overflow buttons"*. It was the same defect — but the defect was the
  **correction**. Integrated, they measure **81.4 / 99.5 / 90.8**, so the
  original annotations were the *closer* of the two readings. This is commit
  `6a5a922` again, in a different file: with no convention declared, correcting
  toward core is a guess dressed as a fix, and it went against the reference
  three times.
- **The residual-width identity is withdrawn.** Ticket 32 offered
  `899 + 40 + 139 = 1078` as the proof that part 1 was right about the CTA.
  It closes **only** because all three terms are AA-inclusive over-reads that
  happen to sum to the AA-inclusive card width. Measured integrated on `01` at
  y2450: CTA left **64.25**, right **962.25**; gap **40.16**; locate left
  **1002.41**, right **1140.01** — span **1075.76** against a **1077.60**
  content column, **1.83 px short**. The CTA row is **left-aligned** with the
  floating card (64.25 against 64.20) and **not right-aligned** (1140.01 against
  1141.80). The row's verdict is unaffected; the arithmetic offered as its proof
  is not available.
- **A blanket value sweep damages prose that *describes* a convention.** Three
  notes in files 11 and 12 explain the core/integrated/AA-inclusive split by
  quoting example numbers; replacing values by string match turned them into
  sentences that label integrated numbers "AA-inclusive". Found and rewritten.
  **Convert the values, then re-read every paragraph that names a convention** —
  they are the ones a value sweep is guaranteed to corrupt.

### 6. What this leaves

Nothing on `SPEC.md`'s component-size line is pre-convention any more; the
marker is removed. The thumbnail carries a band and the reason for it. Files 11 and 12 are propagated (§5).
**Nothing in the design record is now pre-convention**, and no ticket in this map
is open except the car cluster, which needs the founder's device test.
