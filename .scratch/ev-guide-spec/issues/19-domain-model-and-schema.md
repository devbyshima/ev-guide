# 19 — Domain model and schema synthesis

Type: grilling
Status: closed (2026-08-13)
Blocked by: 08, 09, 10, 11, 12

## Question

Bring every resolved decision together into one coherent domain model, and
finish `CONTEXT.md`.

Station, Bay, Connector, Rate, Driver and Admin are provisionally settled.
Availability, Report, Confidence, Staleness, Operator, Owner, Vehicle Class and
Session were deliberately left undefined so their tickets could define them
rather than have this one guess.

Produce: the complete glossary, with every term earning its place and no
synonyms left ambiguous; the entity model with cardinalities, including the
awkward ones — a bay's connector set, an operator spanning stations, a station
with no known availability at all; the schema, with the constraints that make
illegal states unrepresentable; and the write boundaries, since "who may write
this" was answered separately in 09, 10 and 11 and must now be consistent.

Explicitly leave room for the out-of-scope payment effort without building any
of it, and check the model against 18's car-template needs before locking.

Offer ADRs only where the domain-modeling bar is met: hard to reverse,
surprising without context, and the result of a real trade-off.

## Constraint routed from 15 (2026-08-13)

The model this ticket synthesises lands as `packages/domain` (pure types +
the read-time availability derivation) with its persistence shape consumed
through `packages/data`'s repository protocols (ADR-0006). Mind the seam:
the mock and BWEZE implementations must both satisfy it.

## Constraint routed from 16 (2026-08-13)

The schema carries `updatedAt` cursors for delta sync, and Reports carry
captured-at timestamp + location distinct from arrival time (offline queue,
ADR-0007). The availability derivation must be pure enough to run identically
on device and server — it already lives in `packages/domain` (ADR-0006).

## Resolution (2026-08-13)

Synthesis complete. Three founder calls made, then the model locked:

1. **Bay 1—N Connectors, occupancy propagates** — a Connector's effective
   Availability degrades `Free → Occupied` while any sibling on its Bay is
   occupied. Availability still lives on Connectors; propagation is a
   derivation rule beside decay.
2. **Photos are in the v1 model, admin/owner-provided only** — feeds the
   reference's hero carousel without opening a moderation front; community
   media stays in the fog.
3. **Owner is publicly visible** on station detail (display name + logo, the
   reference's owner row); the legal/contact side stays admin-only. Owner
   also carries the car surfaces' authored `markerLabel` (≤3 chars) and
   bundled icon — Owners are a bounded set, never free text.

Deliverables:

- **[docs/domain-model.md](../../docs/domain-model.md)** — entity model and
  cardinalities, schema constraints (geo NOT NULL, ≥1 Bay/Connector/Photo to
  publish, captured≤received, unique memberships), the derivation, the fixed
  projections, `stationsNear` + `changedSince` as the primary reads, the
  write-boundary table reconciling 09/10/11 (consistent — one clarification:
  Operators *flag* Rate, never write it), and the checklist of all fourteen
  car-surface constraints from research 04.
- **[CONTEXT.md](../../CONTEXT.md)** — glossary completed and repaired: the
  duplicate Rate entry collapsed to the per-connector one, stale ticket
  pointers removed, Bay/Connector multiplicity updated, Route/Photo/Saved
  Station added, Session and Confidence confirmed as deliberate absences.
- **[ADR-0008](../../docs/adr/0008-availability-derived-bay-propagation.md)**
  — availability is derived, never stored; bay occupancy propagates. The one
  new decision meeting the ADR bar (hard to reverse, surprising without
  context, real trade-off).

**Payment room:** structured Rate fields are the entire seam; no payment
entity exists and nothing forecloses one. **No route entity** (ADR-0004 /
car constraint 13). **Connector enum stays 02's open OCPI spellings**; the
platform integer taxonomies disagree with each other and are mapped at the
edge, never persisted.

**Knock-ons routed:** 17 — the projections and authored short-name fields
constrain screen copy; the carousel, owner row, and heart are model-backed;
18 — the car cache reads only non-sensitive directory data at a locked-phone
protection class, and renders from the fixed projections.
