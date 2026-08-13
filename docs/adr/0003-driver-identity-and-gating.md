# ADR-0003 — Anonymous reading, authenticated acting; no SMS

Date: 2026-08-13
Status: Accepted — **amended 2026-08-13 by ticket 23: directions are no
longer gated** (see Amendment below)

## Context

EV Guide is free with no monetisation, so every recurring cost comes out of the
studio. It also has a cold-start problem: Rwanda has on the order of 2,000
electric cars, and after ADR's decision to take no external data dependency, the
availability layer depends entirely on drivers choosing to report.

That pulls in two directions. Friction costs reporters the product cannot spare.
But reports need identity to be attributable and rate-limited, and the reference
design shows a named, avatared user.

## Decision

Reading is anonymous. Acting — directions, saving, reporting, profile sync —
requires an account. Authentication is Google Sign-In, Sign in with Apple, and
email magic link. No SMS OTP.

## Rationale

**The gate sits at the high-intent moment, not the front door.** A signup wall
before anyone has seen value inverts the funnel. Gating at "get directions"
catches the user at the point they have already decided to act, which is both
when they are most willing to sign up and when the account is about to become
useful to them.

**No SMS, for two reasons.** It bills per message indefinitely against no
revenue. And the demographic assumption behind phone-first auth does not hold
here: Rwandan EV car owners own a $30k+ vehicle and overwhelmingly have Google
or Apple accounts already.

**Sign in with Apple is compelled, not chosen.** App Store Guideline 4.8
requires an equivalent privacy-preserving option once third-party social login
is offered on iOS. It also happens to suit a product that takes no payments and
holds no financial data.

## Consequences

- The reference profile screen maps 1:1 with no adaptation, since there is a
  real named user behind it. An earlier device-only proposal would have made it
  a local-only profile and created a 1:1 conflict; that conflict does not arise.
- **The car surfaces require a signed-in user for their primary action.** This
  is a review risk under App Store Guideline 5.1.1(v), which restricts requiring
  registration for features that are not inherently account-based. Routed to
  tickets 23 and 13, and it should be confirmed before the car work is
  scheduled.
- Directions gating is measurable. If it suppresses usage, it is the first thing
  to relax — the gate can move to saving and reporting without touching the
  identity model.
- Anonymous users still see availability, so the read surface stays useful to
  people who never sign up. They simply cannot contribute to it.

## Alternatives considered

**No accounts at all**, with device-scoped local identity and proximity-gated
reporting. Genuinely attractive — zero friction, no auth cost, strong privacy —
and rejected by the founder. It would have cost cross-device sync and allowed a
reinstall to reset a rate limit.

**Account required to browse.** Rejected: fatal to adoption in a market where
the total addressable user base is a few thousand people.

**Phone/OTP.** Rejected on recurring cost against no revenue, with no offsetting
benefit for this demographic.

## Amendment (2026-08-13, ticket 23)

**Directions come out of the account gate, everywhere.** The gated acts are
now saving, reporting, and profile sync — all inherently account-based,
exactly what App Store Guideline 5.1.1(v) permits.

This executes the relaxation this ADR pre-planned ("the gate can move to
saving and reporting without touching the identity model"), triggered by
review risk rather than usage data: on the car surfaces, directions is the
primary action, keyboards are unavailable while driving, and a reviewer
already probing "more than a list of chargers" would meet a sign-in wall
first. A hand-off is a deep link to Google Maps — barely an act, and gating
it bought a rejection magnet plus a hostile moment at the driver's
highest-urgency point. The identity model, providers, and no-SMS rule are
unchanged. The inline auth sheet from ADR-0004 now fires on save and report,
not on the directions tap.
