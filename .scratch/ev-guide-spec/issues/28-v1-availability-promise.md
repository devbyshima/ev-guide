# 28 — Does v1 promise availability at all?

Type: grilling
Status: open
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
