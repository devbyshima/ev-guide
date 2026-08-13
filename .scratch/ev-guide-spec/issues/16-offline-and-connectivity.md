# 16 — What does EV Guide do on a bad connection?

Type: grilling
Status: open
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
