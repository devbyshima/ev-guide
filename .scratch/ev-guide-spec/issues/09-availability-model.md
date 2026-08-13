# 09 — How does EV Guide know a bay is free?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 07, 08

## Question

The central question of the product. Everything else is a directory; this is
the promise.

It cannot be a station-level boolean. A station has multiple bays, bays are not
interchangeable, and a site with two CCS2 and one CHAdeMO — both CCS2 in use —
is *full* to one driver and *free* to another. Availability is per connector,
and the map has to answer "free **for me**".

Settle: what the sources of truth are and how they rank (operator-reported,
driver-reported, hardware telemetry if 03 found any, inferred from nothing);
how confidence and staleness are represented, and how the UI shows "probably
free, last confirmed 40 minutes ago" without lying; what decays and how fast;
who is entitled to write availability; how bad or malicious reports are
handled; what the app shows when it simply doesn't know — which for many
stations will be the normal case; and whether "broken" is a distinct state from
"occupied".

Name the terms precisely in `CONTEXT.md`: Availability, Report, Confidence,
Staleness are all deliberately undefined until this resolves.

## Finding routed from 02 (2026-08-13)

Per-connector availability is now **regulatorily forced**, not just a design
preference. RURA Regulation No 011/ENERGY/RURA/2026 Annex I requires public
infrastructure to support at least the two most prevalent technologies in the
country, so multi-standard sites are the norm by law. A GB/T driver at a
Type 2 + CCS2 site must see it as incompatible even with a bay free.

Also from 02, constraining what "read from the operator" could ever mean:
**Kabisa runs OCPP 1.6**, which carries connector *status* but has no
connector-type field. Ticket 03 is establishing whether that backend is
reachable at all.

## Findings routed from 03 (2026-08-13)

A live availability source exists — see 03 — and its shape dictates this model.

**Three states are mandatory, not optional.** 67 of 77 Rwandan records report
`{available: 0, total: 0}`, which means **unknown**, not full. A two-state model
renders 87% of the country as occupied. Verified directly by the coordinator.

**Availability and liveness disagree and must be modelled separately.**
`EV Plugin Kacyiru 120kw` reports 3/4 available while `onlineStatus` is
`OFFLINE`. Only 3 of the 10 records carrying real numbers are actually ONLINE.
Trusting `availability` alone renders stale data as live — the precise failure
this ticket exists to prevent.

**Freshness is per-record and mostly batched** — only 9 distinct `liveUpdatedAt`
values across 77 records, and one has read `IN_USE` since 19 February 2026. A
single feed-level timestamp would be a lie about 76 of them.

**Regulatory hook worth considering.** RURA mandates 97% uptime and 1-hour
outage reporting. EV Guide would hold data bearing on a licensed operator's
compliance, and unlicensed operation carries a FRW 1,000,000 fine. Publishing
uptime or reliability history about named operators is therefore not a neutral
product decision — weigh it here rather than discovering it later.

## Answer

Recorded as [ADR-0002](../../../docs/adr/0002-availability-model.md).
**Availability is a property of a connector, and `Unknown` is the normal case.**

**Four states, per connector, never per station:** `Free`, `Occupied`,
`OutOfService`, `Unknown`. `OutOfService` is distinct because a driver acts on
it differently — occupied means wait, broken means leave. Per-connector is
forced twice over: by RURA requiring two incompatible standards per site, and by
the fact that a GB/T driver at a Type 2 + CCS2 site is blocked even with a bay
standing empty.

**Freshness is a separate axis, never a state.** Every reading carries
`lastConfirmedAt` and its source. Folding age into the state collapses the
moment you ask whether a three-hour-old `Free` is the same state as a live one.

**Decay is a function of source *and* state, not one number.**

| Source | State | Decays to `Unknown` after |
| --- | --- | --- |
| Driver report | `Free` / `Occupied` | **2 hours** |
| Operator app | `Free` / `Occupied` | **6 hours** |
| Operator app | `OutOfService` | **30 days** — a declaration, not an observation |

A single decay constant was the obvious design and it is wrong: an operator
marking a bay broken is asserting a durable fact, while anyone reporting a bay
busy is describing a moment. The 30-day ceiling exists only to prevent zombie
states outliving the repair.

**Confidence is expressed as source plus age, not a numeric score.** A score is
hard to explain in UI, easy to tune wrongly, and invites false precision from
what will often be a single report. "An operator said so, 20 minutes ago" is
both more honest and more useful to a driver than "78%".

**The honesty rule.** Never render a state without its age unless the reading is
live. Past its decay window a state becomes `Unknown` regardless of what it last
said. **Any pedestal reporting itself offline is `Unknown` immediately**, however
recent its last reading — the failure mode observed in real data, where an
`OFFLINE` pedestal still published a full gun-status array with no marker saying
it was stale.

**Design for `Unknown` as the default, not the exception.** It will be the
common case — 87% in the only real dataset available. A station with unknown
availability must render as a **complete, confident listing** showing what *is*
known: rate, connectors, bay count, directions. Availability appears as an
additive badge when present and is simply absent when not. Treating `Unknown` as
a failure state would make the entire map look broken, which is a UI decision
disguised as a data decision.

**Anti-abuse, sized for the actual user base.** Reports are **proximity-gated** —
you may only report a station you are physically at — which is cheap, improves
data quality, and is far harder to game than a reputation system. Plus
rate-limiting per identity (12). **No reputation or trust scoring in v1**: with a
few hundred possible reporters it would be elaborate machinery over a handful of
rows. A later contradicting report supersedes an earlier one.

**Not decided here — see ticket 28.** Whether v1 *promises* availability at all,
or ships as an honest directory with the layer arriving once there is a user
base to sustain it. That is a product-scope call, not a modelling one, and it
belongs to the founder.
