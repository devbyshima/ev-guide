# 36 — Sweep the remaining component sizes to the declared convention

Type: task
Status: open — raised 2026-08-16 by ticket 34
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

*(pending)*
