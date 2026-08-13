# 20 — Apply for the CarPlay entitlement and Android Auto approval

Type: task
Status: open
Blocked by: 04, 18, 24

## Question

**Do not file anything until 24 decides the car integrations stay in scope.**
Ticket 04 found neither platform ships in Rwanda; filing an Apple entitlement
request for a driving feature in a country without CarPlay is a decision, not
a formality.

Nothing to decide. This is the long-pole external dependency: approval latency
is not under the studio's control, which is exactly why it starts during the
spec effort rather than at build time.

Using the requirements from 04 and the designs from 18, submit the CarPlay
EV-charging entitlement request to Apple and open the Android Auto path with
Google. Record in the answer what was submitted, when, under which developer
account, what each party asked for, and any response or conditions.

Anything either platform demands that the spec doesn't yet cover comes back as
a new ticket — a rejection or a condition is information about the product, not
just paperwork.

## Inputs routed from 23 (2026-08-13)

The submissions' framing is decided: one function set, per-platform words.
Apple review notes walk live availability + bay-watch as "more than a list";
Google's declaration answers PF-1 with the same three functions. Fallback
ladder if rejected on this ground: resubmit with bay-watch live and a
walkthrough; then ship phone-only and retry when the layer has real data.
Session control/payment are never built to satisfy review.
