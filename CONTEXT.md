# EV Guide — domain glossary

The ubiquitous language for EV Guide. Glossary only — no implementation
details, no decisions (those live in `docs/adr/` and the wayfinder map). The
entity model, schema constraints, and write boundaries live in
[docs/domain-model.md](docs/domain-model.md).

Completed by ticket 19 (2026-08-13). Every term below is settled.

## Settled

**Station** — a physical location a driver can drive to in order to charge.
Has a position (mandatory — a Station without coordinates cannot exist), three
authored name forms (full, short, and its Owner's marker label), exactly one
Owner, one or more Bays, and one or more Photos.

**Bay** — a single parking position at a Station where one vehicle charges at
a time. A Station's capacity is its Bay count. A Bay carries **one or more
Connectors** (a charge point may hang several guns on one position); because
one vehicle occupies the position, a vehicle on any of them makes the others
effectively unavailable — see *Availability*.

**Connector** — a plug a Bay offers, typed by an open enum in OCPI 2.3.0
spellings (tier 1 in Rwanda: `IEC_62196_T2`, `IEC_62196_T2_COMBO`, `GBT_AC`,
`GBT_DC`; `OTHER` and `UNKNOWN` always expressible). Bays at one Station need
not share a Connector type. Carries numeric power (kW) and voltage, and its
Rate.

**Rate** — what a Connector costs to use, in RWF per kWh plus an optional
session fee. A property of the **Connector**, not the Station: a 7 kW AC bay
and a 120 kW DC bay at one site do not cost the same. Carries its own
Freshness (90-day decay) and `Unknown` case, like Availability. EV Guide
displays a Rate and never collects it; under RURA Art. 27(2) a tariff is a
regulated public disclosure, so a Rate is always present even when `Unknown`.

**Vehicle Class** — the kind of vehicle a Station serves. A nullable **tag**
on Station, not a dimension: nothing in v1 branches on it. EV Guide serves cars
only ([ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md)); the tag exists
so the admin can mark mixed sites without inventing a concept mid-build.

**Driver** — someone using EV Guide to find a charge. A car driver: moto riders
are out of scope ([ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md)).
Reads the whole product anonymously; needs an account to act — directions,
saving, reporting, profile sync
([ADR-0003](docs/adr/0003-driver-identity-and-gating.md)).

**Availability** — whether a Connector can be used right now. One of `Free`,
`Occupied`, `OutOfService`, `Unknown`. A property of a **Connector**, never of
a Station ([ADR-0002](docs/adr/0002-availability-model.md)) — and **derived,
never stored** ([ADR-0008](docs/adr/0008-availability-derived-bay-propagation.md)):
a pure function over the latest Report, decayed by source and state, run
identically on server and device. A `Free` Connector degrades to `Occupied`
while any sibling Connector on its Bay is occupied (one vehicle per Bay).

**Unknown** — Availability that is absent or has decayed past its window. The
**normal case**, not a failure: a Station whose Availability is Unknown is
still a complete listing. Not to be rendered as an error or an absence.

**Report** — a claim about a Connector's Availability, carrying its state,
source, and the moment and place it was **captured** (distinct from when it
arrived — reports queue offline, [ADR-0007](docs/adr/0007-offline-model.md)).
Append-only; most recent capture wins regardless of source; source always
shown. Driver reports are proximity-gated on the captured location.

**Freshness** — how long ago a Report (or Rate) was confirmed, carried as a
timestamp alongside every displayed value. An axis, never a state.

**Route** — the driving path from the Driver to a Station, computed by the
studio's own routing engine (Valhalla, on the same OSM extract as the tiles)
and shown as a preview: line, driving distance, ETA. EV Guide never guides the
drive itself — one tap hands off to Google Maps, deep-linked by coordinates.
See [ADR-0004](docs/adr/0004-directions-preview-and-handoff.md). Not an
entity: nothing about a Route is persisted.

**Photo** — ordered Station media provided by the Admin or the Station's
Owner, feeding the detail screen's carousel. Never driver-submitted, never
shown on car screens.

**Saved Station** — a Driver's bookmark of a Station (the heart icon).
Requires an account ([ADR-0003](docs/adr/0003-driver-identity-and-gating.md)).

**Watch** — a Driver's one-shot request to be told when a Bay frees up at a
Station, optionally narrowed to their own Connector types. Fires once on a
report-driven transition into `Free` — never on decay, because ceasing to know
is not an event — then completes; unfired Watches lapse after two hours. An
errand, not a subscription. Requires an account.

**Owner** — the party responsible for one or more Stations, and the **brand**
drivers see (public display name, short name, ≤3-character marker label, and a
bundled icon — Owners are a bounded, enumerable set, never free text). A
Station has exactly one Owner. Created by the Admin; creates their own
Operators. Writes Rate; the private legal/contact side is admin-only.

**Operator** — someone who works a Station day to day. Assigned to one or more
Stations by their Owner. Writes Availability, not Rate (may flag a wrong
Rate).

**Membership** — the edge binding a person to a Station as Owner or Operator.
Role lives on this edge, never on the person: the same human may be an Owner
at one Station and an Operator at another. One account realm serves drivers,
operators, owners, and admin
([ADR-0005](docs/adr/0005-backend-bweze-frontend-first.md)).

**Admin** — FullTime Studio. Creates Stations manually and creates the Owners
above them. Sits over both mobile apps and uses the web dashboard.

## Deliberately not defined

*Session* — EV Guide never observes a charging session, which is why operator
statistics contain no kWh, revenue or session count, and why no such entity
exists.

*Confidence* — expressed as **source plus Freshness** (ADR-0002), never as a
score, so there is no such term.

**Never to be defined here:** *Battery Swap*, *Battery Stock*. Out of scope by
[ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md) — a swap station holds
battery stock rather than occupied bays, and carrying both concepts would
corrupt the bay/connector model. Not a gap to fill.
