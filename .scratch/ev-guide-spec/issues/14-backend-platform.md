# 14 — What does EV Guide run on?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 09, 12

## Question

Pick the backend, knowing the studio owns BWEZE — an AI-native dev PaaS with
Supabase underneath — and that dogfooding is both a genuine benefit and a
genuine risk when the platform is itself in flight.

Settle: BWEZE, Supabase directly, or something else; what the availability
model from 09 demands of it — realtime subscriptions, write throughput from
driver reports, decay jobs on a schedule; what auth from 12 demands, including
phone/OTP if that's chosen; whether the admin dashboard and both apps share one
backend and one auth realm; where it is hosted and what latency looks like from
Rwanda; and what the operational burden is for a free product with no revenue
to fund it.

Note the standing constraint: no billing infrastructure and no plan tiers
anywhere, because EV Guide is free with no monetisation. That removes a large
slice of what a BaaS normally sells.

## Constraint routed from 26 (2026-08-13)

Founder rule: **no reliance on external people; we build everything ourselves.**
That is an argument for **BWEZE**, the studio's own platform, over Supabase or
another third-party BaaS. Weigh it against the risk noted in this ticket's body
— BWEZE is itself a product in flight, and dogfooding a moving platform under a
free product with no revenue to fund operations is a real cost.

## Constraint routed from 13 (2026-08-13)

The platform now hosts **two self-owned geo services**: the OSM vector tile
server (06) and a **Valhalla routing instance** (ADR-0004), both consuming one
OSM extract job. Whatever this ticket picks must run long-lived containers with
a periodic data-refresh pipeline — this strengthens the self-host lean and is a
concrete test case for the BWEZE question.

## Resolution (2026-08-13)

**BWEZE — after the frontend is built.** Founder call, both halves explicit.

1. **Platform: BWEZE.** EV Guide runs as a BWEZE tenant (Postgres, auth,
   storage) plus git-deployed containers (API, tile server, Valhalla). The
   owns-everything rule (26) lands here deliberately: EV Guide is the concrete
   dogfooding case. Runtime traffic touches only the tenant and containers —
   a BWEZE control-plane outage degrades deploys, never drivers.
2. **Sequencing: frontend first.** The apps are built against a mock data
   layer behind repository protocols (the studio's ZUBA pattern); the BWEZE
   backend lands after. **Launch bar, stated in the spec:** before EV Guide
   serves drivers, the BWEZE data plane must run on always-on server
   infrastructure — as of 2026-08-13 it is a Lima VM on the founder's Mac
   behind a Cloudflare tunnel, and that is not a serving platform.
3. **One backend, one auth realm, one user table** for driver app, operator
   app, and admin dashboard. Roles are membership edges (11); admin is a staff
   flag; operators/owners arrive by email invitation. If tenant auth cannot
   cover ADR-0003's Google + Apple + magic link, EV Guide's API carries
   **Better Auth** (already run in the BWEZE console) against the same
   Postgres — same realm either way.
4. **Availability runtime: store reports, derive at read time, poll.** No
   scheduled decay jobs — effective state is computed from `lastConfirmedAt`
   + source + ADR-0002's windows on every read. No websockets in v1; clients
   refetch on screen focus and map moves. Notifications fog may revisit push.
5. **Geo services: containers beside the tenant.** One periodic OSM extract
   job feeds both the tile server and Valhalla; Cloudflare CDN caches tiles
   hard (immutable between refreshes, purge on refresh); previews and API
   reads go origin.

Recorded as [ADR-0005](../../docs/adr/0005-backend-bweze-frontend-first.md).

**Knock-ons routed:** 15 — now fully unblocked; the mock data layer / repo
protocol seam is the frontend-first sequencing made concrete, and the admin
dashboard's stack should lean on what BWEZE already serves; 16 — polling (not
push) is the freshness mechanism to design offline behaviour around.
