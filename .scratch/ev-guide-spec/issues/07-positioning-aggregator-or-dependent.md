# 07 — Neutral aggregator, or dependent on operator cooperation?

Type: grilling
Status: open
Blocked by: 03

## Question

Does EV Guide work with zero operator cooperation, or does its core promise
require EVP, Kabisa and the rest to adopt the operator app?

This is the load-bearing strategic question and it cascades into availability
(09), rates (10), the role hierarchy (11), and whether the operator app has a
reason to exist at all. The tension is concrete: EVP and Kabisa compete with
each other, and EVP shipped its own app in July 2026. Asking rivals to feed a
shared map is a real commercial ask, not a technical one.

Settle: whether availability and rate data must survive with no operator ever
signing up; what EV Guide offers an operator that makes adoption worth it when
they already have their own app; whether the answer differs per operator;
whether the product degrades gracefully or breaks when an operator refuses; and
whether the studio has or can get relationships with any of these operators.

The recommendation put to the founder during charting — neutral aggregator that
works without cooperation, with operator participation as a quality upgrade
tier — was not answered. Start there, but treat it as an open question.

## Findings routed from 03 (2026-08-13)

This ticket's premise has shifted. It assumed operator cooperation was the only
route to data. It is not: **Kabisa's public feed already aggregates 18
operator/venue brands including EVP's**, so EV Guide could be a neutral
aggregator on day one with *zero* operator cooperation — while being wholly
dependent on a single competitor's undocumented endpoint. That trade is
ticket 26 and should be settled before this one.

Also relevant: **EVP has no app** (the launch coverage was future tense) and the
only shipped competitor is Kabisa Charge with 5+ downloads, no iOS build, and
charging flows it labels "(simulated)". The competitive pressure assumed at
charting does not currently exist.
