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

## Consequences

- The derivation function is the single most test-worthy unit in the domain
  package; mock and BWEZE data implementations must both feed it unchanged.
- Reports need no coordination or locking — append-only writes, ordering by
  `capturedAt`, most-recent-wins (ticket 11).
- Any future realtime or notification feature computes from the same
  function; nothing ever reads a stored state.
