
## Round 1 settled (2026-08-13) — interim, ticket not yet resolved

**Driver accounts exist.** Founder decision, against the recommendation of a
device-only local identity. Consequence worth noting: this **removes** the 1:1
tension flagged for ticket 17 — the reference profile screen shows a named,
avatared user, which now maps directly rather than becoming a local-only
profile.

Still open: whether browsing is anonymous or gated, what specifically requires
an account, and the auth method — which is now a **running-cost** question,
since the product has no revenue to fund per-message SMS (Round 2).

## Answer

**Accounts exist. Browsing is anonymous; acting requires an account. Google,
Apple, and email magic link — no SMS.**

Recorded as [ADR-0003](../../../docs/adr/0003-driver-identity-and-gating.md).

**Anonymous** — browse the map, open a station, see its rate, connectors, bay
count and availability. The whole read surface.

**Requires an account** — get directions, save a station, report availability,
and sync the vehicle profile that powers "free for me".

**Auth: Google Sign-In, Sign in with Apple, and email magic link.** No SMS
OTP — it bills per message forever on a product with no revenue, and Rwandan EV
car owners are an affluent segment for whom the usual phone-first assumptions do
not hold. **Sign in with Apple is not optional**: App Store Guideline 4.8
requires it once third-party social login is offered on iOS.

**Consequence routed to 23 and 13.** Gating *directions* puts the account prompt
at the highest-intent moment, which converts better than a front-door wall — but
it also lands when the driver is in a hurry, and it means the CarPlay and Android
Auto surfaces require a signed-in user for their primary action. That is a review
risk under App Store Guideline 5.1.1(v), which restricts requiring registration
for features that are not account-based. Worth confirming before the car work is
scheduled.
