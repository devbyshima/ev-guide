# EV Guide — domain model and schema

Synthesised by ticket 19 (2026-08-13) from ADR-0001…0007 and tickets 02, 09,
10, 11, 12. The glossary lives in [CONTEXT.md](../CONTEXT.md); this document
holds the entity model, the schema constraints, and the write boundaries.
Lands in code as `packages/domain` (pure types + derivations) consumed through
`packages/data`'s repository protocols (ADR-0006).

## Entity model

```
Owner 1 ──── N Station 1 ──── N Bay 1 ──── N Connector 1 ──── N Report
                │ 1                                  │
                ├──── N Photo                        └── Rate (fields on Connector)
                └──── N Membership N ──── 1 User ──── N SavedStation
```

- **Owner** — the brand and responsible party (Kabisa, Numa, EVP…). Public:
  `displayName`, `shortName`, `markerLabel` (**exactly ≤3 chars, authored** —
  the car platforms' one hard character limit), `icon` (bundled/materialised
  locally: car surfaces cannot take URLs). Private, admin-only: legal name,
  contacts. Owners form a **bounded, enumerable set** — never a free-text
  string on Station.
- **Station** — exactly one Owner (`owner_id NOT NULL`). `geo` point **NOT
  NULL** (a station without coordinates cannot exist — both car platforms
  require it structurally). Three authored name forms: `name` (full),
  `nameShort` (row/picker — the *place*, operator belongs in icon and marker).
  Nullable `vehicleClassTag` (ADR-0001; nothing branches on it). `updatedAt`
  cursor (delta sync, ADR-0007). Publishable only when it has ≥1 Bay and ≥1
  Photo (draft until then).
- **Bay** — one parking position; one vehicle charges at a time. **1—N
  Connectors** (a charge point may hang several guns on one position), ≥1
  required.
- **Connector** — `type` from ticket 02's **open OCPI 2.3.0 enum**
  (`IEC_62196_T2`, `IEC_62196_T2_COMBO`, `GBT_AC`, `GBT_DC` tier 1; the enum
  can express every RURA Art. 3(c) family and always carries
  `OTHER`/`UNKNOWN` members — Android can return them regardless). The
  platform integer taxonomies disagree with each other; **never persist a
  platform integer** — map at the edge. `powerKw` and `voltage` are numbers.
  **Rate fields live here** (ticket 10): `ratePerKwhRwf`, optional
  `sessionFeeRwf`, with their own `rateConfirmedAt` freshness (90-day decay)
  and `Unknown` stated, not hidden. RURA Art. 27(2) makes tariffs a regulated
  public disclosure — rate is first-class and always present (possibly
  Unknown), displayed and never collected.
- **Report** — a claim about a Connector's availability: `state`
  (`Free | Occupied | OutOfService`), `source` (`driver | operator | admin`),
  `reporterId`, **`capturedAt` + `capturedLocation`** (distinct from
  `receivedAt` — offline queue, ADR-0007; proximity gating evaluates the
  captured location; `capturedAt ≤ receivedAt`). Append-only.
- **Photo** — ordered station media, **admin/owner-provided only** (no driver
  submissions; community media stays in the fog with its moderation problem).
  Feeds the reference's hero carousel. Never reaches car surfaces.
- **User** — one realm across all three surfaces (ADR-0005). `isStaff` flag
  for Admin. Drivers may be anonymous readers; acting requires the account
  (ADR-0003).
- **Membership** — `(userId, stationId, role ∈ {owner, operator})`, unique.
  Role lives on the edge, never on the person (ticket 11).
- **SavedStation** — `(userId, stationId)`, unique. The heart icon.
- **Watch** — `(userId, stationId, connectorTypes[], armedAt)`, one-shot,
  auto-expiring 2 h after `armedAt`, max 3 armed per user (ticket 30). Fires
  once on a **report-driven** transition of any matching Connector into
  effective `Free` — decay never fires it. Deleted on fire or expiry. Ships
  with the car effort's package; the push token beside it is user-scoped and
  **never enters the car cache** (car constraint 9).

**Deliberately absent:** any stored availability column (below); any route,
maneuver, or polyline entity (directions need only a coordinate + display
name — ADR-0004, car constraint 13); any payment, plan, or billing entity
(the structured Rate fields are the whole seam a future payment effort would
build on); any Session entity (EV Guide never observes charging).

## Amendments from ticket 18 (2026-08-13)

Designing the car surfaces forced eight schema-level items, all now binding:

1. **The derivation and the display grammar live in one shared spec** —
   [docs/availability-display.md](availability-display.md) — executed by four
   runtimes. It supersedes the sketch below wherever they differ.
2. **`Report` carries `sourceOnline`**: a source declaring itself offline
   yields `Unknown` immediately, regardless of recency.
3. **The car cache holds raw per-Connector latest reports, never a
   materialised aggregate.** A `CachedReport` projection strips `reporterId`
   and `capturedLocation`; the sync payload carries the raw shape too.
   Without this, the honesty guarantee does not hold on the car surface.
4. **The car's non-directory field list is fixed and is a security decision**
   (an amendment to car constraint 9): `isSignedIn`/`canWatch`,
   `notificationsPermitted`, `armedWatches[]`, `pendingIntents[]`,
   `vehicleConnectorTypes[]`, `savedStationIds[]`. Explicitly **not** a
   credential, a user id, or a push token — the car layer never authenticates;
   a drain process on the phone performs authenticated writes.
5. **`Watch` gains `armedAt` and `confirmed`**, with the max-3 ceiling
   evaluated on-device *before* the request, and a queued arm dropped past
   `armedAt + 2h`.
6. **`rateCoverage(station)` is denominated in plugs**, not bays, and carries
   the session fee: `(confirmedPlugs, totalPlugs, distinctRates[],
   oldestConfirmedAt, sessionFeeRwf?)`.
7. **Authored length bounds are enforced in the admin**: `nameShort ≤ 18`,
   `name ≤ 28`, `Owner.shortName ≤ 17`, `markerLabel` 1–3 chars `NOT NULL`
   with a `CHECK`. `Owner.icon` must be a **vector** — CarPlay pin sizes are
   runtime values.
8. **Projections return structure, not formatted strings** — `(distanceMeters,
   nameShort)`, not `"~2.4 km · SP Remera"` — because Android must hand the
   host a `DistanceSpan` and may author no distance literal. Per-Connector
   state must be reachable in the detail projection so a known-broken gun is
   visible to a driver with no profile set.

**Vehicle connector profile:** setting your own connector type is a
**device-local preference**, ungated — it is a reading aid, and the read
surface is anonymous (ADR-0003 as amended). Only *syncing* it across devices
needs an account. Flagged for founder ratification, since ticket 12's question
and its answer can be read either way, and gating it would make the unlensed
aggregate the normal case for every driver and every store reviewer.

## Availability is derived, never stored

The star constraint (ADR-0008): **no table carries an availability state.**
Effective availability is a pure function in `packages/domain`, run
identically on server and device (ADR-0007), over the latest Report per
Connector:

```
effective(connector, now) =
  1. r ← latest Report for connector (by capturedAt; most-recent-wins, ticket 11)
  2. if r is absent or now − r.capturedAt > window(r.source, r.state) → Unknown
     windows: driver 2h · operator 6h · OutOfService 30d (ADR-0002)
  3. else r.state, carrying (source, capturedAt) — freshness is an axis, not a state
  4. bay propagation: if any sibling Connector on the same Bay is effectively
     Occupied, a Free result degrades to Occupied (one vehicle per Bay)
```

Aggregates the car row and map pins need (`baysTotal`, `baysFree`,
`lastReportedAt`) are **computed projections materialised into sync payloads**,
never authored columns — under the same decay, so a stale green is impossible
by construction.

## Projections

Each surface renders one of a fixed set of station projections defined in
`packages/domain` (car constraint 5 — otherwise three call sites improvise):

- **one-line** — `nameShort`
- **two-line** — `nameShort` / `distance · availability` (rate has **no room
  on a car row**; it is a detail-screen field)
- **picker-triple** and **card-triple** — the six CarPlay POI strings
- availability strings are derived from the structured fields, short-form,
  never placed in a row *title* (title changes burn Android's template quota)

## Primary reads

- **`stationsNear(origin, limit)`** — *the* load-bearing query (car constraint
  2): arbitrary origin (viewport, mock reviewer GPS — never "device location"
  hardcoded), geospatial index, ranked distance-first then availability,
  bounded (car floors/caps: design for 6, cap at 12). The text search index is
  secondary.
- **`changedSince(cursor)`** — delta sync on `updatedAt` (ADR-0007; also what
  the car cache refreshes behind).
- Station detail by opaque stable id (round-trips through car templates).

## Write boundaries (consistency check of 09 · 10 · 11)

| What | Admin | Owner | Operator | Driver |
| --- | --- | --- | --- | --- |
| Station / Bay / Connector structure | write | — | — | — |
| Owner entity, memberships | write | creates own Operators | — | — |
| Rate (on Connector) | write | write | **flag only** | — |
| Availability Reports | write | write | write (6h window) | write (2h window, proximity-gated, account required) |
| Photos | write | write | — | — |
| SavedStation | — | — | — | own rows |

Conflicts: most recent `capturedAt` wins regardless of source; source always
shown (ticket 11). No reputation system (ticket 09).

## Car-surface constraints honoured (research 04, §"What this forces")

1 geo NOT NULL · 2 `stationsNear` primary · 3 bounded ranked results ·
4 authored `markerLabel`/`nameShort`/`name` · 5 fixed projections ·
6 structured availability, never prose, never in titles · 7 per-connector
rows kept as the **filter** dimension, aggregate for display · 8 app-owned
open connector enum, mapped at every platform edge · 9 on-device cache
readable while locked → the car surface reads only non-sensitive directory +
availability data (EV Guide has nothing else) · 10 one small static image =
Owner icon, bundled · 11 opaque stable station id · 12 geospatial index
before text index · 13 no route entity · 14 the future `watch(station, user)`
notification relation has a home; it stays in the fog.
