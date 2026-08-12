# 11 — Owner, operator, station: what is the hierarchy and what does each tier see?

Type: grilling
Status: open
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
