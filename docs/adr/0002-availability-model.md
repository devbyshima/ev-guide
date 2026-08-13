# ADR-0002 — Availability is per-connector, four-state, and Unknown by default

Date: 2026-08-13
Status: Accepted

## Context

EV Guide's differentiating promise is telling a driver whether they can charge
now. The original brief framed this as a boolean: occupied or not.

Two things make that framing unworkable. A station has multiple bays with
different plugs, and RURA Regulation No 011/ENERGY/RURA/2026 Annex I *requires*
public infrastructure to support at least the two most prevalent technologies in
the country — so multi-standard sites are the legal norm. A GB/T driver at a
Type 2 + CCS2 site is blocked even with a bay standing empty.

And the data is mostly absent. In the only real dataset examined, 67 of 77
Rwandan charge points reported no availability at all. Under ADR's companion
decision to take no external runtime dependency, EV Guide's only sources are its
own operator app and driver reports, in a market with on the order of 2,000
electric cars.

## Decision

Availability is a property of a **connector**, never a station. Four states:
`Free`, `Occupied`, `OutOfService`, `Unknown`. Freshness is a separate axis
carried as `lastConfirmedAt` plus source. Decay is a function of source and
state. `Unknown` is designed for as the normal case.

## Rationale

**Four states, not three.** `OutOfService` earns its place because drivers act
on it differently: occupied means wait, broken means go elsewhere. Collapsing it
into `Occupied` sends drivers to wait at a charger that will never free.

**Freshness cannot be a state.** Ask whether a three-hour-old `Free` is the same
state as a live `Free` and the state machine collapses. Keeping age orthogonal
also lets the UI degrade gracefully instead of inventing states like `MaybeFree`.

**Decay varies by source and state.** The obvious design is one constant, and it
is wrong. An operator marking a bay out of service asserts a durable fact; a
driver reporting a bay busy describes a moment. Driver `Free`/`Occupied` decays
in 2 hours, operator `Free`/`Occupied` in 6, operator `OutOfService` in 30 days —
the last purely to stop zombie states outliving a repair.

**Confidence as source plus age, not a score.** A numeric score implies
precision that a single report does not have, is hard to render honestly, and
invites tuning nobody can justify. "An operator said so, 20 minutes ago" is more
honest and more actionable.

**Offline overrides recency.** Real data showed an `OFFLINE` pedestal still
publishing a full gun-status array with no marker of staleness. Any source
declaring itself offline yields `Unknown` immediately.

**`Unknown` is the default case, and the UI must not treat it as failure.** At
87% unknown, an interface that greys out or apologises for unknown availability
renders the whole map as broken. Stations with unknown availability show as
complete, confident listings — rate, connectors, bay count, directions — with
availability as an additive badge when it exists.

## Consequences

- The map answers "free **for me**", which requires knowing the driver's
  connector. That makes the driver's vehicle profile load-bearing, not a
  nice-to-have (ticket 12).
- Most stations, most of the time, will show no availability. This is designed
  for rather than mitigated, and it sets what v1 can honestly promise
  (ticket 28).
- Reports are proximity-gated — reportable only at the station — which doubles
  as the primary anti-abuse measure. No reputation system in v1.
- EV Guide will hold data bearing on operators' RURA uptime obligations. It
  publishes current state only, never per-operator reliability history. See
  ticket 07: publishing it would starve the operator channel entirely.

## Alternatives considered

**Station-level boolean**, as the brief framed it. Rejected: wrong for
multi-connector sites, which regulation makes the norm.

**Three states, folding broken into occupied.** Rejected: sends drivers to wait
at a charger that will never free.

**A numeric confidence score.** Rejected as false precision over what is usually
one report, and unexplainable in a list row — which CarPlay and Android Auto
constrain to two short text slots regardless.
