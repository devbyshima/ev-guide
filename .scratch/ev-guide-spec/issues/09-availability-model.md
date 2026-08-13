# 09 — How does EV Guide know a bay is free?

Type: grilling
Status: open
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
