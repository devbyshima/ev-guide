# 21 — Write SPEC.md and the ADR set

Type: task
Status: open — **written up to the car boundary (2026-08-14)**
Blocked by: 20 (for §9 only)

## Question

Nothing to decide — this is the destination made concrete. Every decision has
been made in its own ticket; this assembles them.

Write `SPEC.md` as the single source of truth an implementation effort executes
from: the product and who it serves, the domain model from 19, the three
surfaces at the agreed uneven depth, the availability model with its honesty
rules, the design system and screen inventory from 17, the car integrations
from 18 and 20, the architecture from 14 and 15, and the explicit non-goals —
payment above all.

Lock it the way Prelys' spec is locked: decisions recorded so they are not
relitigated mid-build. Where a decision was a genuine trade-off that a future
reader would find surprising, it belongs in `docs/adr/`, not buried in prose.

Carry forward, clearly marked as still open, everything in the map's **Not yet
specified** section that never graduated — an unresolved question that looks
settled in a spec is worse than one that is visibly open.

## Progress (2026-08-14)

[`SPEC.md`](../../../SPEC.md) is written and locked for every surface the car
decision does not touch. Sections 1–8 and 10–13 are final: the product and its
corrected market figures, **21 locked decisions** each citing the ADR or ticket
that argued it, the domain model and write boundaries, the availability honesty
rules, the measured design system with its five would-have-shipped-wrong
findings, the driver screen inventory, the operator app with its write surface,
the admin with its six prohibitions, the architecture, the non-goals, the
open-items list, and a §13 of the eight guarantees that decay silently unless
tested.

**§9 Car integrations is deliberately unwritten**, with its blocking chain
named in the section itself: 27 → 24 → 20. What ticket 18 produced that the
phone app depends on — availability-display.md, the ADR-0004/0007/0008
amendments, the 14 constraints already honoured in the model, and directions
ungated everywhere — is locked above and survives whichever way 24 goes. Only
§9 and this ticket's status wait on 20.

Two staleness fixes made in passing: `README.md`'s status block (it still said
the codebase shape was undecided; ADR-0006 settled it), and its claim that the
effort had no spec.

**Not done, and not this ticket's to do:** the founder calls in SPEC.md §12 —
the typeface acceptance band, the two knowing 1:1 deviations, `My plug`'s
gating, the hero badge's contrast, and the operator app's dark-only palette
used outdoors.
