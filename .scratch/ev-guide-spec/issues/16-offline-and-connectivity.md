# 16 — What does EV Guide do on a bad connection?

Type: grilling
Status: open
Blocked by: 09, 14

## Question

A driver looking for a charge is, by definition, mobile — often low on battery,
sometimes outside Kigali, sometimes on an expensive or absent connection. The
app failing at that moment fails at its only job.

Settle: what works fully offline — the station list, positions, rates and
connectors are all slow-changing and cacheable; what cannot be trusted offline,
which is availability above all, and how the UI is honest about that rather
than showing a stale green; whether map tiles are cached and at what cost;
whether availability reports queue and sync when connectivity returns, and what
happens if the state changed meanwhile; how much data a cold start costs, which
matters when data is metered; and what the first-run experience is with no
connection at all.

This is also where the honesty rule from 09 gets its hardest test: an offline
app showing confident availability is the exact failure that would destroy
trust in the product.
