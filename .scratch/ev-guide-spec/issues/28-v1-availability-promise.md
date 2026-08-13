# 28 — Does v1 promise availability at all?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 09, 12

## Question

A product-scope call the founder must make, separated out of 09 because it is
about what EV Guide *claims*, not how availability is modelled.

ADR-0002 settles the mechanics. What it cannot settle is whether the layer is
worth shipping in v1, because the arithmetic is thin. Rwanda has on the order of
2,000 electric cars. At 10% adoption that is ~200 users across ~100 sites —
roughly two reports per site per day at best, concentrated at a handful of busy
Kigali locations. Quiet sites get nothing. Ticket 26 removed the feed that would
otherwise have seeded the layer, so this is a genuine cold start: nobody reports
until there are users, nobody uses it until it is accurate.

Settle: whether v1 ships availability at all, or ships as an honest, accurate
directory — rate, connectors, bay count, directions — with availability arriving
once a user base exists to sustain it; if it ships, what the app store listing
and onboarding *claim*, since over-promising here is the fastest way to lose the
early users the layer depends on; whether operator adoption is a precondition
for switching the layer on, per-station or globally; and whether there is a
seeding move that breaks the cold start — studio staff reporting during a survey
week, or the admin marking known-busy patterns.

Weigh honestly that a directory that admits what it does not know beats a live
layer that is wrong, and that the brief explicitly asked for occupancy — so
dropping it from v1 is a visible reduction against what was requested, not a
quiet simplification.

## Resolution (2026-08-13)

**v1 ships the availability layer — and claims the directory.**

1. **The layer ships.** Its mechanics are already the model's spine (derived,
   Unknown-by-default — ADR-0002/0008), the operator app exists to write it,
   and it is the substance behind the car platforms' "not just a list" bar
   (23's ammunition). The thin months are honest, not wrong.
2. **The claim is the directory.** Store listing and onboarding sell: every
   charging station in Rwanda, connectors, rates, directions, works offline.
   Availability is presented as "live status *when reported* by operators
   and drivers" — a bonus, never a promise. The words **"real-time" never
   appear anywhere** in listing, onboarding, or UI.
3. **No adoption precondition, no per-station or global switch.** A gate
   would treat Unknown as a failure state; ADR-0002 says it is a complete
   answer. No gating machinery exists.
4. **Seeding: two legitimate moves, one explicit rejection.**
   - A **launch-week survey pass** — studio staff visit the Kigali sites v1
     needs verified anyway (directory data, photos); their reports seed the
     layer as genuine admin-source reports.
   - **Pre-launch operator recruitment** of the two or three largest
     operators (Kabisa, Numa) so the busiest sites have an operator writing
     status from day one — the operator-onboarding fog patch's first
     concrete shape.
   - **Rejected: admin-marked "known-busy patterns."** Synthetic data wearing
     the availability UI would violate the honesty rule the model is built
     on. Never to be revisited as a "quick win".

**Knock-ons routed:** 29 is now unblocked (stop *suggestions* remain
constrained by Unknown-dominance — weigh there); the Distribution fog patch
inherits the claim language (no "real-time" anywhere); the operator
onboarding fog patch gains the pre-launch recruitment shape.

## Sequencing constraint (2026-08-13, founder rule)

The seeding moves above are **post-build**: acquisition and proposals happen
only after the product is built. "Pre-launch operator recruitment" therefore
means after the build and before launch — **no operator, ministry, or funder
is approached during the build**. The launch-week survey pass is unaffected
(it is the studio's own field work, not an approach to anyone).
