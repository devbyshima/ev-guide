# 26 — Do we build on Kabisa's unofficial feed?

Type: grilling
Status: open
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
