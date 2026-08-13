# ADR-0001 — EV Guide serves car drivers; moto energy and battery swap are out of scope

Date: 2026-08-13
Status: Accepted

## Context

Rwanda's electric fleet is dominated by two-wheelers. The MININFRA/EU EV
Charging Infrastructure Master Plan, Table 11, sourced to Rwanda Revenue
Authority, records **363 battery-electric cars against 4,823 electric
motorcycles** in March 2024 — roughly 13:1. EVP Charger operates around 95
e-moto charging sites against 20 for cars.

On those numbers alone, an EV app for Rwanda that ignores motorcycles looks
indefensible, and a future reader will reasonably ask why this one does.

## Decision

EV Guide serves **car drivers only**. Moto riders and battery swap are out of
scope for this product, not deferred within it. `Station` carries a nullable
vehicle-class tag from day one, but nothing branches on it.

## Rationale

**The ratio is stale, and stale in one direction.** It is a March 2024 figure.
Car imports ran 512 across the whole of 2020–2024, then **1,555 in the nine
months to March 2026** — a roughly fivefold acceleration on the car side. No
comparable motorcycle growth figure could be found, so the true current ratio is
unknown but materially narrower. Scoping a product on a two-year-old ratio whose
denominator quintupled would be a mistake.

**The product's core promise is undeliverable for riders.** EV Guide's
differentiator is knowing whether a bay is free. The only live availability data
in Rwanda is Kabisa's public feed, which carries 77 charge points and **zero
moto or swap records**. A rider-facing EV Guide would be a static list — the
precise thing the product exists not to be, and the thing both Apple and Google
reject on their car surfaces.

**Battery swap is a different domain, not a variant of charging.** A swap
station holds *battery stock*; a charging station has *occupied bays*. `Bay`,
`Connector` and per-connector availability — the load-bearing concepts of this
model — are all meaningless for swap. Representing both in one schema would
corrupt the one that works.

**Closed networks give a directory nothing to aggregate.** Moto energy in
Rwanda runs on captive subscriptions: an Ampersand rider swaps at Ampersand
stations. A directory earns its keep by informing choice among alternatives, and
for riders there is no choice to inform. Car charging, by contrast, shows 18
operator and venue brands inside a single feed.

## Consequences

- The moto majority of Rwanda's EV fleet is not served by this product. That is
  a deliberate and uncomfortable choice, made on deliverability rather than
  market size.
- Serving riders later means a **new effort with its own premise**, not widening
  this map. The vehicle-class tag is the seam that keeps that cheap; it is not a
  commitment to cross it.
- The domain model stays coherent: availability means bays and connectors,
  everywhere, with no special cases.
- If a live moto availability source appears, or if swap networks open up, this
  decision should be revisited — those are the conditions that would change it.

## Alternatives considered

**Serve both from one model.** Rejected: forces `Bay`/`Connector` to mean two
incompatible things and degrades the car experience to accommodate a rider
experience that has no data behind it.

**Motos first, cars later**, following the fleet numbers. Rejected on the same
deliverability grounds — a rider product could not answer the availability
question at all today.

**Defer motos as in-scope fog.** Rejected as dishonest bookkeeping: it would
leave a permanent unfilled gap on the map implying work that is not planned.
