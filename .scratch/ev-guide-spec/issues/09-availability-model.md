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
