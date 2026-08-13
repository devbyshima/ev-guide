# ADR-0005 — Backend on BWEZE, built frontend-first

Date: 2026-08-13 · Status: accepted · Ticket: 14

## Decision

- **EV Guide's backend is BWEZE**, the studio's own PaaS: one BWEZE tenant
  (Postgres, auth, storage) plus git-deployed containers — the API, the OSM
  vector tile server (ticket 06), and Valhalla (ADR-0004). No third-party
  BaaS.
- **Frontend first.** The driver and operator apps are built against a mock
  data layer behind repository protocols; the backend lands after, swapping in
  behind the same seam. Ticket 15 designs the seam.
- **Launch bar.** Before EV Guide serves drivers, the BWEZE data plane must
  run on always-on server infrastructure. As of this ADR it is a Lima VM on
  the founder's Mac behind a Cloudflare tunnel; that is a development
  arrangement, not a serving platform. Frontend-first sequencing gives this
  time to be met without blocking the build.
- **One backend, one auth realm, one user table** across driver app, operator
  app, and admin dashboard. Roles are membership edges (ticket 11); admin is
  a staff flag; operators and owners join by email invitation. If tenant
  auth cannot provide Google + Apple + email magic link (ADR-0003), the API
  carries Better Auth against the same Postgres — the realm stays single
  either way.
- **Availability runtime: store reports, derive at read time, poll.**
  Effective availability is computed on every read from the stored report's
  state, source, and `lastConfirmedAt` against ADR-0002's decay windows. No
  scheduled decay jobs, no websockets in v1; clients refetch on screen focus
  and map movement.
- **Geo serving:** one periodic OSM extract job feeds tiles and routing;
  Cloudflare CDN caches tile and style responses hard (immutable between
  refreshes, purged on refresh); route previews and API reads go to origin.

## Why

- The owns-everything rule (ticket 26) points at BWEZE, and EV Guide is the
  platform's concrete dogfooding case. Runtime traffic touches only the
  tenant and containers, so a BWEZE **control-plane** outage degrades
  deploys, never drivers — the dependency is narrower than "BWEZE is in
  flight" suggests.
- A free product with no revenue cannot fund standing operational complexity:
  read-time derivation and polling remove cron jobs and websocket
  infrastructure whose failure modes would otherwise need pager-grade
  attention, to serve a dataset whose dominant state is `Unknown`.
- Managed alternatives are the external dependency the rule rejects, and the
  studio has prior evidence of the risk (a Supabase cloud project lost to
  NXDOMAIN on another product).

## Consequences

- Ticket 15 is fully unblocked: repo/package shape, the repository-protocol
  seam, and an admin dashboard that leans on what BWEZE already serves.
- Ticket 16 designs offline behaviour around polling as the freshness
  mechanism.
- The notifications fog patch, if it graduates, reopens the push question —
  nothing in this ADR forecloses it; it only keeps it out of v1.
- The BWEZE hardening already owed (real server, persistence) is now on EV
  Guide's critical path to launch, though not to the build.
