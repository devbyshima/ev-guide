# 16 — What does EV Guide do on a bad connection?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 09, 14

## Question

A driver looking for a charge is, by definition, mobile — often low on battery,
sometimes outside Kigali, sometimes on an expensive or absent connection. The
app failing at that moment fails at its only job.

Settle: what works fully offline — the station list, positions, rates and
connectors are all slow-changing and cacheable; what cannot be trusted offline,
which is availability above all, and how the UI is honest about that rather
than showing a stale green; whether map tiles are cached and at what cost;
whether availability reports queue and sync when connectivity returns, and what
happens if the state changed meanwhile; how much data a cold start costs, which
matters when data is metered; and what the first-run experience is with no
connection at all.

This is also where the honesty rule from 09 gets its hardest test: an offline
app showing confident availability is the exact failure that would destroy
trust in the product.

## Finding routed from 06 (2026-08-13)

**This ticket now gates the map provider choice.** 06 recommends MapLibre with
self-hosted OSM tiles *because* Google's ToS §3.2.3(a) forbids tile caching and
offers no offline API. If offline tiles turn out not to be required, Google
becomes the strongest option and 06 must be revisited.

Measured, so the cost is known: **Kigali metro as an offline vector basemap is
5.6 MB; all of Rwanda is 76 MB** — within Cloudflare R2's free tier.

## Constraint routed from 13 (2026-08-13)

The route preview (ADR-0004) is a **server call** to Valhalla. Decide its
offline behaviour: degrade to straight-line distance from cached station
coordinates, or hide the preview and leave the hand-off button (Google Maps
handles its own offline story). The hand-off itself must never be blocked by
the preview failing.

## Constraint routed from 14 (2026-08-13)

Freshness reaches the client by **polling on screen focus and map movement**
(ADR-0005) — no push, no sockets. Offline design is therefore about how stale
cached reads are presented (ADR-0002's freshness axis does the honest work)
and when refetches fire, not about reconnecting a stream.

## Resolution (2026-08-13)

**Offline is first-class.** Five parts:

1. **Basemap:** Kigali's vector basemap (5.6 MB) ships **inside the app
   binary**; the all-Rwanda pack (76 MB) is an opt-in download in settings;
   the station directory is fully synced on every online launch (it is
   kilobytes). **This closes 06's conditional: MapLibre confirmed** — offline
   tiles are required, which Google's ToS cannot provide.
2. **Honesty:** the ADR-0002 decay derivation runs **on device** over cached
   reports, so no availability state is ever rendered beyond its decay
   window, offline or on — a stale green is structurally impossible. A quiet
   offline indicator plus the standard freshness timestamps; offline is a
   normal mode, not an error.
3. **Reports queue offline**, capturing timestamp and location at tap time;
   they sync with the original timestamp (11's most-recent-wins orders them),
   expire unsent after their own decay window (2h driver), and proximity
   gating evaluates the captured location.
4. **Route preview degrades to labeled straight-line distance** from cached
   coordinates; the Google Maps hand-off button is never blocked; route line
   and ETA simply don't render offline.
5. **Cold start:** a directory snapshot ships in the binary (refreshed each
   release), so a zero-connectivity first run shows every station with all
   availability honestly `Unknown`. Online syncs are delta fetches on an
   `updatedAt` cursor; photos lazy-load. Budget stated in the spec: cold
   online start under 1 MB excluding actually-panned tiles.

Recorded as [ADR-0007](../../docs/adr/0007-offline-model.md).

**Knock-ons routed:** 06 — conditional resolved, MapLibre stands; 17 — the
offline indicator, straight-line label, and Rwanda-pack settings row need
faces; 19 — the schema carries `updatedAt` cursors and the report queue's
captured-at fields.
