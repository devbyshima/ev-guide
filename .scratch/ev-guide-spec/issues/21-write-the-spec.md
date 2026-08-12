# 21 — Write SPEC.md and the ADR set

Type: task
Status: open
Blocked by: 02, 03, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

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
