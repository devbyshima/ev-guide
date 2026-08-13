# 30 — Bay-watch notifications: scope and mechanics

Type: grilling
Status: open
Blocked by: —

## Question

Graduated from the fog by 23: **"notify me when a bay frees up" ships in the
car effort's package** — it is one of the three functions clearing the
"more than a list" bar, and the only one not yet designed.

Settle the mechanics of watching a **derived** layer: what exactly a watch
binds to (Connector, Bay, or Station — noting availability lives on
Connectors but a driver thinks in Stations); what fires it (a report arriving
that flips effective state to Free, vs decay flipping it to Unknown — decay
alone should probably never notify); expiry (a watch during one errand is not
a subscription — auto-expire after hours, not days); rate limits and quiet
behaviour so a flapping connector doesn't spam; the push transport on the
BWEZE backend (Expo push vs raw APNs/FCM — and note research 04 §9: the
locked-phone rule makes the push token the first user-scoped data the car
cache must never hold); and what the car screen shows for an armed watch
(constraint 14: notification intents reset Android's template quota, so this
is also a navigation affordance).

Account-gated (a watch is inherently account-based — consistent with
ADR-0003 as amended). Out of the v1 phone launch, in the spec: the car
effort cannot pass review without it (23).
