# EV Guide — domain glossary

The ubiquitous language for EV Guide. Glossary only — no implementation
details, no decisions (those live in `docs/adr/` and the wayfinder map).

Most of this model is still being built: ticket 19 is the synthesis. Terms
below are only those genuinely settled. Everything else is deliberately absent
rather than guessed.

## Settled

**Station** — a physical location a driver can drive to in order to charge.
Has a position, a name, an operator, and one or more Bays.

**Bay** — a single parking position at a Station where one vehicle charges at
a time. A Station's capacity is its Bay count. Availability is a property of
Bays, never of Stations.

**Connector** — the plug standard a Bay offers (CCS2, Type 2, CHAdeMO, GB/T,
…). Bays at one Station need not share a Connector. Which Connectors actually
matter in Rwanda is ticket 02.

**Rate** — what it costs a driver to charge at a Station. EV Guide *displays*
the Rate and never collects it; there is no payment anywhere in the product.
Its units, currency, and who is entitled to write it are ticket 10.

**Vehicle Class** — the kind of vehicle a Station serves. A nullable **tag**
on Station, not a dimension: nothing in v1 branches on it. EV Guide serves cars
only ([ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md)); the tag exists
so the admin can mark mixed sites without inventing a concept mid-build.

**Driver** — someone using EV Guide to find a charge. A car driver: moto riders
are out of scope, see [ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md).
May read the whole product anonymously; needs an account to act — directions,
saving, reporting, profile sync. See
[ADR-0003](docs/adr/0003-driver-identity-and-gating.md). Browsing is the driver's
primary act; whether a Driver needs an account is ticket 12.

**Availability** — whether a Connector can be used right now. One of `Free`,
`Occupied`, `OutOfService`, `Unknown`. A property of a **Connector**, never of a
Station: a Station with a free Type 2 bay is unavailable to a GB/T driver. See
[ADR-0002](docs/adr/0002-availability-model.md).

**Unknown** — Availability that is absent or has decayed past its window. The
**normal case**, not a failure: a Station whose Availability is Unknown is still
a complete listing. Not to be rendered as an error or an absence.

**Report** — a claim about a Connector's Availability, carrying its source and
the moment it was made. Reports are proximity-gated: a Driver may only report a
Station they are at.

**Freshness** — how long ago a Report was made, carried as `lastConfirmedAt`
alongside every Availability. An axis, never a state.

**Rate** — what a Connector costs to use, in RWF per kWh. A property of the
**Connector**, not the Station: a 7 kW AC bay and a 120 kW DC bay at one site do
not cost the same. Carries its own Freshness and `Unknown` case, like
Availability. EV Guide displays a Rate and never collects it.

**Owner** — the party responsible for one or more Stations. A Station has
exactly one Owner. Created by the Admin; creates their own Operators.

**Operator** — someone who works a Station day to day. Assigned to one or more
Stations by their Owner. Writes Availability, not Rate.

**Membership** — the edge binding a person to a Station as Owner or Operator.
Role lives on this edge, never on the person: the same human may be an Owner at
one Station and an Operator at another.

**Admin** — FullTime Studio. Creates Stations manually and creates the station
managers above them. Sits over both mobile apps and uses the web dashboard.

## Deliberately not yet defined

*Session* — and it may never be needed: EV Guide never observes a charging
session, which is why the operator statistics contain no kWh, revenue or session
count.

*Confidence* will not be defined: ADR-0002 expresses it as **source plus
Freshness** rather than as a score, so there is no such term.

**Never to be defined here:** *Battery Swap*, *Battery Stock*. Out of scope by
[ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md) — a swap station holds
battery stock rather than occupied bays, and carrying both concepts would
corrupt the bay/connector model. Not a gap to fill.

These are the terms most likely to be got wrong by assumption, so they are
left blank until their tickets resolve.
