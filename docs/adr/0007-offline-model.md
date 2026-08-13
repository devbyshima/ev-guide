# ADR-0007 — Offline is first-class

Date: 2026-08-13 · Status: accepted · Ticket: 16

## Decision

- **Bundled basemap.** Kigali's vector basemap (5.6 MB) ships inside the app
  binary. An all-Rwanda pack (76 MB) is an opt-in download in settings. This
  requirement is what fixes MapLibre + self-hosted tiles as the map stack
  (ticket 06's conditional, now closed): Google's ToS forbids the tile
  caching offline demands.
- **Bundled directory snapshot.** A release-time snapshot of the station
  directory ships in the binary, so a first run with zero connectivity shows
  every station — with all availability honestly `Unknown`. When online, the
  directory fully syncs on launch via delta fetches on an `updatedAt`
  cursor.
- **Honesty is structural.** The ADR-0002 decay derivation runs on device
  over cached reports: no availability state is ever rendered beyond its
  decay window, offline or on. A stale green is impossible by construction,
  not by discipline. Offline gets a quiet indicator; it is a normal mode,
  never an error screen.
- **Reports queue offline.** A report captures its timestamp and location at
  tap time, syncs with the original timestamp (most-recent-wins ordering,
  ticket 11), and expires unsent after its own decay window (2 h for driver
  reports). Proximity gating evaluates the captured location.
- **Route preview degrades; hand-off never blocks.** Offline, the Valhalla
  preview falls back to straight-line distance from cached coordinates,
  labeled as such; route line and ETA don't render. The Google Maps hand-off
  button is never gated on the preview.
- **Data budget.** Cold online start under 1 MB, excluding tiles the driver
  actually pans over. Station photos lazy-load.

## Why

- The driver who most needs EV Guide is low on battery, outside Kigali, on a
  metered or absent connection. Failing there is failing the product's only
  job.
- The dataset is small enough (tens of stations, kilobytes) that full
  caching is free; the honesty problem is therefore presentation, and
  running the same pure derivation on device removes the failure mode
  entirely rather than mitigating it.
- A queued report older than its decay window would be erased by decay on
  arrival — dropping it client-side is equivalent and cheaper.

## Consequences

- Ticket 17 designs the offline indicator, the straight-line label, and the
  Rwanda-pack settings row.
- Ticket 19's schema carries `updatedAt` cursors and the report's
  captured-at fields, and keeps the derivation pure (device + server).
- Release engineering refreshes the bundled snapshot and basemap each
  release — build-effort work.
