# 11 — Owner, operator, station: what is the hierarchy and what does each tier see?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 07, 09

## Question

The brief says the admin creates station managers, in a hierarchy of station
operator and station owner, and each gets "all the relevant stats". That
sentence hides most of a permissions model.

Settle the cardinality first: can one owner own many stations, can one operator
work several, can a station have several operators, can a person be an owner at
one site and an operator at another, and does an operator belong to an owner or
directly to a station. Then: who creates whom — the brief says admin creates
managers, so can an owner create their own operators, or is every account
admin-minted. Then: what each tier may **write** (availability, rate, station
details) and what each may **read**.

"All the relevant stats" needs a concrete list per tier — and the honest
question of what statistics a free directory app can even produce, since with
no payments there are no transactions to count. Views, direction taps,
availability reports, and reported occupancy over time are probably it. Say so
plainly rather than promising dashboards the data can't fill.

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

## Answer

**Owner → Stations one-to-many; role is a membership edge; owners create their
own operators; stats are four metrics and that is the whole list.**

**Shape.** An Owner has many Stations; a Station has exactly one Owner; an
Operator is assigned to one or more Stations. **Role is a membership edge, not a
user attribute** — the same person can be an owner at one site and an operator
at another without a migration the first time it happens.

**Creation.** Admin creates Owners. **Owners create their own Operators**,
scoped to their own stations. Admin retains full override. This is the loose
reading of the brief's "admin creates station managers", confirmed by the
founder — the strict reading makes the admin a bottleneck past a handful of
sites.

**Write boundaries.**

| | Availability | Rate | Station details | Manage users |
| --- | --- | --- | --- | --- |
| Operator | ✅ assigned | flag only | — | — |
| Owner | ✅ own | ✅ own | ✅ own | ✅ own operators |
| Admin | ✅ all | ✅ all | ✅ all + create | ✅ all |

**Conflicts: most recent wins, regardless of source, with the source always
shown.** The only answer consistent with ADR-0002's confidence-is-source-plus-age
rule. Any weighting scheme means inventing coefficients nobody can justify, and
would let a six-hour-old operator reading suppress a report from someone
standing at the charger. Admin can override anything, with an audit trail.

**Stats — four metrics, and saying so is part of the answer.** Station views,
direction taps, availability reports received, and observed uptime. **EV Guide
never sees a charging session**, so there is no kWh delivered, no revenue and no
session count — none of the numbers an operator would normally expect. Shipping
a dashboard that implies otherwise would be worse than a short honest one.

Operators see assigned stations; owners see theirs aggregated with cross-site
comparison; admin sees everything. **An owner sees their own uptime and nobody
else's** — the ticket 07 boundary, which is what keeps the operator app an
attractive tool rather than a compliance surface under RURA's 97% regime.
