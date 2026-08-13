# ADR-0004 — Route preview in-app, Google Maps hand-off for the drive

Date: 2026-08-13 · Status: accepted · Ticket: 13

## Decision

EV Guide **previews** the route and **hands off** the drive.

- **Preview, studio-owned.** A **self-hosted Valhalla** instance computes
  routes from the same OSM extract that feeds the tile pipeline (ADR-adjacent:
  ticket 06's MapLibre + self-hosted tiles). The app shows a route line on the
  map, real driving distance, and ETA. No Google routing API anywhere.
- **Drive, handed off.** One tap opens **Google Maps**, deep-linked by
  `lat,lng` — never by place name. No chooser in v1. Not-installed falls back
  to the platform's universal-link handling; no custom fallback UI.
- **No in-app turn-by-turn in v1.** No voice guidance, no rerouting, no
  driving UI, and therefore no CarPlay *navigation* entitlement — only the
  charging entitlement (ticket 04).
- **Auth at the tap.** ~~Directions are account-gated (ADR-0003).~~
  *Superseded 2026-08-13 by ADR-0003's amendment (ticket 23): directions are
  ungated everywhere.* The inline-sheet-with-auto-resume pattern survives —
  it now fires on the gated acts (save, report) instead.
- **Car screens.** The phone hand-off is the specified guarantee. Launching
  Google Maps onto the CarPlay/Android Auto display is undocumented and
  unverified; it is an enhancement pending ticket 27's device test, and
  ticket 18 designs without assuming it.

## Why

- **Apple Maps has no directions in Rwanda** (Maps Standard/Satellite only),
  so an Apple Maps hand-off fails for the entire user base. Google Maps is the
  only viable target and marks Rwanda good-quality for driving directions.
- **Turn-by-turn is a navigation product**, not a directory feature: it means
  owning routing quality on thin map data and the materially harder CarPlay
  navigation entitlement — the single biggest threat to car-platform approval.
- **Founder direction (this ticket): use mature open-source engines** rather
  than building routing or omitting it. Valhalla over OSRM at equal
  Rwanda-scale hosting cost because it keeps two doors open: turn-by-turn
  maneuver narratives (if a later effort adds guidance, it is UI work, not
  infrastructure work) and isochrones (a future "stations reachable on my
  remaining charge" feature — the one directory feature that beats a
  hand-off).
- **Coordinates, not names**: station names are not in Google's places index;
  coordinates always resolve.

## Amendment (2026-08-13, ticket 18)

Designing the car screens showed that *"no custom fallback UI"* cannot be
applied literally there: a universal link opens Safari, and Safari has no car
screen.

- **The CarPlay directions ladder terminates in Apple Maps**, then in an
  in-app alert. Apple Maps cannot route in Rwanda, so this degrades to a
  destination pin — a cost carried openly rather than hidden, and what it
  actually renders for an unroutable Rwandan destination is a **blocking**
  item for ticket 27.
- **Apple Maps is deletable**, so the last rung is genuinely reachable; the
  launch must be installation-checked rather than assumed.
- **The Google Maps car-display rung ships behind a flag defaulting off**,
  flipped only by ticket 27 evidence. Neither `canOpenURL` nor the open
  completion handler can detect the failure that matters — a hand-off that
  succeeds *on the phone* — so the flow must never claim a car-display launch
  it cannot observe.
- **ETA, duration, and any "minutes away" string are forbidden on a car
  surface**, not merely unmodelled: on CarPlay they are a `carplay-maps`
  entitlement trigger.

## Consequences

- The backend (ticket 14) hosts Valhalla beside the tile server; both consume
  one OSM extract job.
- Offline behaviour of the preview is ticket 16's to decide.
- The reference set contains **no route screen**; ticket 17 places the preview
  within the existing screens rather than inventing one.
- Journey planning with charging stops graduated to ticket 29.
- ETAs shown are EV Guide's own (Valhalla), and may differ from Google's after
  hand-off; the preview must not promise Google's numbers.
