# 29 — Journey planning with charging stops: in scope or out?

Type: grilling
Status: closed — out of scope (2026-08-13)
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

## Resolution (2026-08-13): ruled out of scope

**Journey planning — including the corridor filter and the "reachable on my
remaining charge" isochrone — is out of this map's destination.** Founder
call.

Why: the brief never asked for it (the fog patch was born from EVP's
marketed journey planner, and research 03 established EVP has no app — the
competitive pressure that created the idea does not exist); the reference
set has no such screen and the 1:1 rule makes every invented screen
expensive; stop suggestions from an Unknown-dominant layer (28) would be
hollow exactly where they'd matter; and most of the fleet is in Kigali with
most trips within range.

The seam that keeps a future effort cheap already exists and needs nothing
added: Valhalla + isochrones are in the stack (ADR-0004), so journey
planning later is UI work on existing infrastructure — a fresh effort with
its own premise, not this map widened.
