# 37 - Three policy constants are assumptions, not decisions

Type: decision
Status: open - raised 2026-08-16 while implementing `packages/domain`
Blocked by: - (nothing; this is a product ruling)

## Question

`effective(connector, now)` decays a report by `(source, state)`. Implementing
it forced the full 3 x 3 table, and **two of the nine cells are not stated
anywhere in the record**. They are currently filled by assumption, marked as
such in `packages/domain/src/decay.ts`, and need a ruling before the driver app
ships.

| source | Free | Occupied | OutOfService |
| --- | --- | --- | --- |
| driver | 2h | 2h | **30d?** |
| operator | 6h | 6h | 30d |
| admin | **6h?** | **6h?** | **30d?** |

## Gap 1: driver + OutOfService

The two documents can be read against each other:

- **ADR-0002** names only the operator case: *"operator `OutOfService` in 30
  days - the last purely to stop zombie states outliving a repair."*
- **docs/domain-model.md** states it flat, without a source: *"windows: driver
  2h · operator 6h · OutOfService 30d"*.

The flat reading is implemented, so **a single driver's brokenness claim
suppresses a connector for 30 days**. That is the longest-lived assertion in
the product, granted to its lowest-trust source, and one mistaken or malicious
report takes a working gun off the map for a month with no reputation system
(ticket 09) to temper it.

The opposite reading - driver `OutOfService` decays at the driver window - has
its own cost: a genuinely broken gun reported by the only person who saw it
returns to `Unknown` in two hours, and `Unknown` reads as "maybe fine".

ADR-0002's own justification points at the operator case: a durable fact
asserted by someone who *owns* the equipment. A driver reporting brokenness is
closer to "describes a moment", which is the reasoning behind the 2h window.

## Gap 2: admin, all three states

No document gives `admin` a window at all. Implemented as operator (6h / 6h /
30d) on the grounds that both are trusted write sources under ticket 11's
boundaries. Defensible, but unstated, and admin is the one source that could
justify "does not decay at all" if an admin write is treated as ground truth
rather than an observation.

## Gap 3: the proximity radius

Ticket 09 gates driver reports by proximity and **never says how near**.
`packages/data/src/mock.ts` implements **150 m**, on the reasoning that it
covers a forecourt and a parking deck with consumer GPS error while not being
satisfiable from the road outside.

It is the same class of gap as the two above: a policy constant that the
implementation forced and the record does not state. It is also the one a
reviewer will probe, because a gate that is too tight makes reporting feel
broken at exactly the stations with the worst GPS (underground and covered
bays), and one too loose makes the gate decorative.

Note that the gate is evaluated against the **captured** location, never the
current one - an offline report drains hours later from somewhere else
entirely, and gating on where the phone is at drain time would reject every
queued report. That part *is* settled (ADR-0007) and is implemented and tested.

## Why this cannot wait for the build to finish

It is not a tuning constant. It changes what the map shows on a station whose
only report says a gun is broken, and it changes it for a month at a time. It
also interacts with ticket 30: a `Watch` fires on a report-driven transition
into `Free`, and a 30-day `OutOfService` from a driver means the watch cannot
fire for that connector for 30 days either.

## Recommendation to react to

Driver `OutOfService` decays at **24h**: long enough to outlive the reporting
driver's own visit and to suppress a broken gun through a day, short enough
that a single wrong report does not cost a month. Admin follows operator, with
`OutOfService` at 30d.

The decay numbers live in one table in `packages/domain/src/decay.ts` and the
radius in one constant in `packages/data/src/mock.ts`, so whichever way each
goes it is a one-line change plus a fixture.

## Answer

*(pending)*
