
## Round 1 settled (2026-08-13) — interim, ticket not yet resolved

- **Owner has many Stations; a Station has one Owner; an Operator is assigned to
  one or more Stations.** Role is a **membership edge, not a user attribute**, so
  one person can be an owner at one site and an operator at another with no
  migration.
- **Admin creates Owners; Owners create their own Operators**, scoped to their
  own stations. Admin retains full override. This is the loose reading of the
  brief's "admin creates station managers", confirmed by the founder — the
  strict reading makes the admin a bottleneck past a handful of sites.
- **Stats are four metrics, and that is the whole list**: station views,
  direction taps, availability reports received, and observed uptime. EV Guide
  never sees a charging session, so there is no kWh delivered, no revenue and no
  session count — say so plainly rather than shipping an empty dashboard.
- Operators see assigned stations; owners see theirs aggregated with cross-site
  comparison; admin sees everything. **An owner sees their own uptime and nobody
  else's** — the ticket 07 boundary holds.

Still open: **write permissions per tier, and conflict resolution** (Round 2).
