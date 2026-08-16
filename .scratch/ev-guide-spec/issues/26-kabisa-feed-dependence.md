# 26 — Do we build on Kabisa's unofficial feed?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 03

## Question

Ticket 03 found the only live availability data in Rwanda, and it belongs to
someone else. `https://api.gokabisa.com/api/client/chargers-geojson` is
unauthenticated, serves 77 Rwandan charge points across 18 brands **including
EVP's**, and carries per-gun availability for 10 of them plus `pricePerKwh` for
12. Verified independently. Kabisa's own web map consumes it, so it is public by
design — but there are **no terms and no SLA**, and the studio holds an unsent
security note about the wider surface it sits on (details withheld from this
repository until the operator has been notified).

This is a governance and strategy decision, not a technical one, and it should
be made deliberately rather than by an engineer noticing the endpoint works.

Settle: whether consuming it is acceptable given no published terms — and
whether the absence of terms is permission or merely silence; that EV Guide
would be **aggregating a competitor's data, including data Kabisa collected
about EVP**, into a rival free product, and how that reads if Kabisa notices;
the relationship cost, since Kabisa is exactly the operator whose cooperation
ticket 07 wants, and discovering the scrape later is a worse first contact than
asking now; whether to **ask Kabisa for permission or a documented feed**
instead, which converts a liability into the partnership 07 is chasing; the
resilience question, since an undocumented endpoint can change or vanish with no
notice and EV Guide's core promise would go with it; and what the product does
on the day it breaks.

Also settle the narrower disclosure question: if EV Guide shows a rate or an
availability figure sourced from Kabisa, does it say so?

Note the responsible-disclosure angle: the wider surface finding is a
finding about *someone else's* security. Decide whether to tell them, and let
that inform the tone of first contact.

Recommendation to react to: **ask before building.** The feed's existence proves
the data is obtainable, which is the hard part; a documented feed obtained by
asking is worth more than an undocumented one taken quietly, and it turns
ticket 07's central problem into a solved one.

## Answer

**No. EV Guide takes no runtime dependency on Kabisa's feed, or on any external
data source. The studio builds and owns the whole pipeline.**

Founder decision, 2026-08-13: *"no reliance on external people, we build
everything ourselves."*

Scope of the rule as applied: **no third-party service in the runtime path.** No
consuming `api.gokabisa.com`, no reselling another operator's gun states, no
product promise that breaks when someone else's undocumented endpoint changes.

What this rules out that was otherwise available: 77 geocoded Rwandan charge
points across 18 brands, live per-gun availability for 10 of them, and
`pricePerKwh` for 12 at 600 RWF/kWh.

**Consequences, recorded here so they are not rediscovered as surprises:**

- **Availability becomes EV Guide's own problem entirely.** The only sources
  left are the operator app and driver reports. See 07 and 09.
- **Rates are fully manual**, consistent with RURA requiring no tariff filing
  (10). The 600 RWF/kWh signal is now market intelligence, not a data source.
- **Station seeding is fully manual**, which raises the value of ticket 25 —
  though see the open question below on whether a one-time dataset counts as
  external reliance.
- **06's recommendation gets stronger.** MapLibre with self-hosted OSM tiles was
  already the pick; under this rule it is the *only* consistent one, since
  Google's map service is exactly the runtime third-party dependency being ruled
  out.
- **14 leans toward BWEZE.** "Build everything ourselves" is an argument for the
  studio's own platform over Supabase. Routed there rather than decided here.

**Q2 answered 2026-08-13: yes, disclose.** Draft at
the disclosure draft (**held locally, unsent**)
— **not sent**; the founder sends it. Pure disclosure with no ask attached,
since this ticket removed any reason to ask. Claims are held to what is
verifiable, and the specifics are withheld from this repository until the
operator has been notified. It does **not** claim any endpoint was exercised or
that specific data is exposed. It discloses that the studio is building an
adjacent product, deliberately.

**Open question of interpretation, routed to 25:** whether a *one-time*
acquisition of MININFRA's station dataset counts as external reliance. Reading
the rule as being about runtime dependency, it does not — the studio would own
the data outright thereafter, and admin-entered stations were always the design.
Flagged rather than assumed.
