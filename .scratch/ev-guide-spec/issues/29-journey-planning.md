# 29 — Journey planning with charging stops: in scope or out?

Type: grilling
Status: open
Blocked by: 28

## Question

Graduated from the fog by 13's resolution. EVP's promised app markets journey
planning; whether EV Guide competes there is now a sharp question because the
infrastructure answer changed: **Valhalla is already in the stack**
([ADR-0004](../../docs/adr/0004-directions-preview-and-handoff.md)), and it
ships route legs and isochrones — so "route with a charging stop" is no longer
a build-a-router problem, it is a product-scope decision.

Settle: whether v1 includes any journey-planning surface (a route with
suggested stations along it, or "stations reachable on my remaining charge"
via isochrones), or whether it is ruled out of the destination and left to a
future effort. If in, what the minimum honest version is — noting that stop
*suggestions* lean on availability and rate data whose default state is
`Unknown` (ADR-0002), which is why this waits on 28's call about what v1
promises; and that the reference set contains no such screen, so 17 would have
to place it.

The cheap-but-real option to weigh: no planner UI at all, but a "chargers
along this route" filter on the existing map — one Valhalla call plus a
corridor query, no new screen.

## Constraint routed from 28 (2026-08-13)

The availability layer ships in v1 but is **claimed as a bonus, never a
promise** — so any journey-planning surface must work when every station en
route reads `Unknown`, and stop *suggestions* may rank by distance/rate/
connector fit but must not imply live knowledge the layer doesn't have.
