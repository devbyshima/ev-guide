# ADR-0008 — Availability is derived, never stored; Bay occupancy propagates

Date: 2026-08-13 · Status: accepted · Ticket: 19

## Decision

- **No table carries an availability state.** Reports are append-only claims;
  effective Availability is a pure function (`packages/domain`) over the
  latest Report per Connector, applying ADR-0002's decay windows — run
  identically on server and device (ADR-0007). Aggregates surfaces need
  (`baysFree`, `lastReportedAt`) are computed projections materialised into
  sync payloads, never authored columns.
- **A Bay carries one or more Connectors, and occupancy propagates.** A charge
  point may hang several guns on one parking position; one vehicle occupies
  the position. So a Connector's effective Availability degrades `Free →
  Occupied` while any sibling Connector on its Bay is effectively Occupied.
  Availability still *lives* on Connectors (ADR-0002 intact); the propagation
  is a derivation rule beside decay, not stored state.

## Why

- Storing a state column invites the exact failure ADR-0002 exists to
  prevent: a confident stale value. Deriving on read makes a stale green
  **unrepresentable** rather than discouraged — the same code path enforces
  honesty online, offline, and on the car cache.
- Multi-gun charge points are the physical reality (Kabisa's feed shows
  them); modelling one Connector per Bay would either undercount plugs or
  double-count capacity. Propagation keeps "a Station with a free Type 2 bay
  is unavailable to a GB/T driver" true in both directions.

## Amendment (2026-08-13, ticket 18)

Adversarial review of the car designs found this ADR's guarantee to be
**necessary but not sufficient**, and its propagation rule to be **too broad**.
Both corrections now live in
[docs/availability-display.md](../availability-display.md), which is the single
specification all four runtimes execute.

1. **Deriving on read makes a stale value unrepresentable only if a render
   happens.** A screen left open across a decay boundary keeps painting the old
   value indefinitely — and offline, no sync will ever arrive to correct it.
   The derivation therefore ships with `nextDecayDeadline(displayed, now)`, and
   every surface schedules a one-shot recompose at that instant (bucketed to
   protect refresh floors, and repeated on scene resume).
2. **Occupancy propagates; brokenness does not.** The original rule degraded a
   `Free` sibling whenever any connector on the bay was occupied, which is
   right — a parked car holds the whole position. But inheriting the *bay's*
   state under a connector-type lens told a GB/T driver a bay was free while
   EV Guide held a report saying that plug was broken. The corrected function,
   `bayStateUnder(bay, T?, now)`, re-derives capability over only the guns of
   the driver's type, with `OutOfService` outranking `Occupied` under a lens:
   if every gun of your type is broken, waiting is pointless.
3. **"Run identically on server and device" widens to four runtimes** — server
   TypeScript, phone TypeScript, CarPlay Swift, Android Auto Kotlin — held
   together by the shared fixture corpus, which mitigates the duplication
   rather than eliminating it.

## Consequences

- The derivation function is the single most test-worthy unit in the domain
  package; mock and BWEZE data implementations must both feed it unchanged.
- Reports need no coordination or locking — append-only writes, ordering by
  `capturedAt`, most-recent-wins (ticket 11).
- Any future realtime or notification feature computes from the same
  function; nothing ever reads a stored state.
