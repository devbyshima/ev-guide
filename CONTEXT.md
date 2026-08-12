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

**Driver** — someone using EV Guide to find a charge. Browsing is the driver's
primary act; whether a Driver needs an account is ticket 12.

**Admin** — FullTime Studio. Creates Stations manually and creates the station
managers above them. Sits over both mobile apps and uses the web dashboard.

## Deliberately not yet defined

*Availability / Occupancy* (ticket 09), *Operator* and *Owner* (ticket 11),
*Vehicle Class* (ticket 08), *Session*, *Report*, *Confidence*, *Staleness*.

These are the terms most likely to be got wrong by assumption, so they are
left blank until their tickets resolve.
