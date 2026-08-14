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

## Founder calls closed (2026-08-14)

All five items SPEC.md §12 carried as owed were ruled the same day, each as
recommended, and are now decisions 4, 22, 23 and 24:

- **Typeface** — ships as the §3.5 **acceptance band, not a name**, selected
  **free-first** with a retail licence only if no free face meets the band.
  Old-style figures stay non-negotiable.
  [ADR-0010](../../../docs/adr/0010-typeface-acceptance-band.md).
- **The two knowing deviations ratified** — `© OpenStreetMap contributors` in
  the wordmark slot; the puck redrawn `#FFFFFF` + `#C7FC2F`.
- **Two fidelity costs carried rather than deviated around** — the hero badge
  reproduced at 1.21:1 under a redundancy invariant, and the operator app
  shipping dark-only, revisited only on launch-week evidence.
  [ADR-0009](../../../docs/adr/0009-reference-fidelity-deviations-and-costs.md)
  holds all four, because a future reader who notices any one of them asks the
  same question.
- **`My plug` stays ungated** — ADR-0003 amended. The gated acts are exactly
  three: save, report, profile sync.

§12 keeps what those rulings leave behind: the three conditions that would
reopen a ratified call (no free face with old-style figures; O4 unreadable in
sunlight; `Rebero`/`Remera` missing from OSM), and the two design gaps still
unratified — **no pressed/disabled/error/empty/confirmation state exists in the
reference**, and **no text input exists**. Both are design passes to commission,
not values to derive.
