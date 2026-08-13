# 14 — What does EV Guide run on?

Type: grilling
Status: open
Blocked by: 09, 12

## Question

Pick the backend, knowing the studio owns BWEZE — an AI-native dev PaaS with
Supabase underneath — and that dogfooding is both a genuine benefit and a
genuine risk when the platform is itself in flight.

Settle: BWEZE, Supabase directly, or something else; what the availability
model from 09 demands of it — realtime subscriptions, write throughput from
driver reports, decay jobs on a schedule; what auth from 12 demands, including
phone/OTP if that's chosen; whether the admin dashboard and both apps share one
backend and one auth realm; where it is hosted and what latency looks like from
Rwanda; and what the operational burden is for a free product with no revenue
to fund it.

Note the standing constraint: no billing infrastructure and no plan tiers
anywhere, because EV Guide is free with no monetisation. That removes a large
slice of what a BaaS normally sells.

## Constraint routed from 26 (2026-08-13)

Founder rule: **no reliance on external people; we build everything ourselves.**
That is an argument for **BWEZE**, the studio's own platform, over Supabase or
another third-party BaaS. Weigh it against the risk noted in this ticket's body
— BWEZE is itself a product in flight, and dogfooding a moving platform under a
free product with no revenue to fund operations is a real cost.
