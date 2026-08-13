
## Constraint routed from 12 (2026-08-13)

ADR-0003 gates **directions** behind an account. Since directions is the primary
action on both car surfaces, **CarPlay and Android Auto would require a
signed-in user to do the main thing they exist for.**

That compounds this ticket's risk rather than easing it. App Store Guideline
5.1.1(v) restricts requiring registration for features that are not inherently
account-based, and a reviewer already looking for "more than a list of chargers"
will meet a sign-in wall first. Establish whether the car surfaces should permit
anonymous directions as an exception, and whether that undermines the gate on
the phone.
