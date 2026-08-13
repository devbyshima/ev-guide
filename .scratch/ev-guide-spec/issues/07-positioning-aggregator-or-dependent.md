# 07 — Neutral aggregator, or dependent on operator cooperation?

Type: grilling
Status: resolved (2026-08-13)
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

## Constraint routed from 26 (2026-08-13)

**Settled by founder decision: no external runtime dependency.** This removes
the third option this ticket had grown — aggregating via Kabisa's feed. EV Guide
must work on its own sources alone.

What remains genuinely open here: the operator app is EV Guide's *own* surface,
but **operator adoption is still outside the studio's control**. The rule gives
you the tooling, not the users of it. So this ticket still has to answer what
the product does when no operator ever signs up, and what the operator app
offers that makes adoption worth it — now with no fallback feed behind it.

## Answer

**EV Guide is fully self-sufficient. It works with zero operator cooperation,
and every source it has is one it owns.**

Forced by 26's no-external-runtime-dependency rule, which removed the third
option this ticket had grown.

**Two channels, both EV Guide's own surfaces:**

1. **The operator app** — highest-confidence availability, but adoption is
   outside the studio's control.
2. **Driver reports** — always available, thin at low user counts.

**What the product does when no operator ever signs up:** it remains a complete
and accurate directory. Station identity, position, connectors, bay count and
rate are all **admin-owned** and therefore always present. Availability is an
**additive layer**, not a precondition — its absence degrades the product
without breaking it.

**What makes the operator app worth adopting**, given operators already have
their own systems and owe EV Guide nothing:

- Free, with no cost and no lock-in — the product has no monetisation anywhere.
- Control over their own listing's accuracy: rate, hours, connectors, bay count.
  Operators care more about being represented correctly than about being
  represented at all, and today they have no way to correct a third party.
- Their own stats, which they mostly cannot get from their existing hardware.
- **Explicitly not a compliance surface.** See below — this is the single
  biggest determinant of whether any operator adopts.

**The regulatory trap, and the decision it forces.** RURA mandates 97% uptime,
1-hour outage reporting, and fines unlicensed operation FRW 1,000,000. An app
holding per-operator reliability history is a de facto compliance monitor for a
regulated industry. **EV Guide does not publish per-operator uptime histories,
reliability league tables, or outage records.** It shows current state only.
Publishing that data would guarantee no operator ever touches the operator app,
which would starve the highest-confidence channel to win an argument the product
does not need to have.

**Competitive position, corrected from charting:** there is effectively no
incumbent. EVP has no app; Kabisa Charge has 5+ downloads, no iOS build, and
labels its own charging flows "(simulated)". The pressure assumed at charting
does not exist.
