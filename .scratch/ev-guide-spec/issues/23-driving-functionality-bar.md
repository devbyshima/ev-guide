# 23 — What is EV Guide's "meaningful functionality relevant to driving"?

Type: grilling
Status: open
Blocked by: 04

## Question

Ticket 04 found the single largest risk to the car integrations, and it is a
convergence: Apple's review criteria say a CarPlay app **can't just be a list
of EV chargers**, and Google's `PF-1` requires an app to **provide meaningful
functionality relevant to driving**. Neither platform defines the bar. Both
apply it to precisely EV Guide's shape.

The usual way charging apps clear it — session control, starting and stopping a
charge, payment — is **permanently out of scope**, since EV Guide is free and
never collects money. So the bar has to be cleared some other way.

The candidates 04 identified: live availability, directions hand-off,
notifications when a bay frees up, and broken-charger reporting. Whether any of
those is enough is not a research gap that more reading would close — it is a
judgement call about what EV Guide is for.

Settle: which functions EV Guide offers on the car screen that constitute more
than a list; whether the answer differs between Apple and Google; whether
anything the product would otherwise not build should be built *because* the
car surface needs it — and if so, whether that tail is wagging the dog; and
what the fallback position is if a submission is rejected on this ground.

Depends on 09, since "live availability" is only a differentiator if
availability is actually live.
