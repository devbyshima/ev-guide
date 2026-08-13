# 24 — Do the car integrations stay in scope?

Type: grilling
Status: open
Blocked by: 22, 23

## Question

A scoping decision, forced by 04 and pending 22.

The brief asked for CarPlay and Android Auto compatibility, and charting placed
them in the spec but out of the first build, on the reasoning that entitlement
approval latency is the long pole. **That reasoning assumed the features work
for EV Guide's users.** 04 established they are not available in Rwanda at all,
so whatever the case for building them, it is not "Rwandan drivers will use
this".

Settle whether the car work stays, and on what basis. The honest reasons it
might: regional expansion beyond Rwanda, a South Africa play (the only African
country on both platforms' lists), diaspora or visitor users, or portfolio and
credibility value for the studio. Each implies a different priority and a
different build order — a South Africa play, in particular, changes the product
well beyond the car screen.

If it stays: does the CarPlay entitlement application (20) still get filed now,
given Apple is being asked to approve a driving feature for a country where it
does not ship CarPlay, and given 23's undefined bar? Or does filing wait?

If it goes: it moves to the map's **Out of scope** section, 05, 18, 20 and 23
close with it, and the "latest OS releases, native components" requirement
survives on its own merits without the car surfaces. Note that 04's fourteen
data-model constraints were derived from car-screen limits — decide explicitly
which of them are still worth honouring, since several (a stable opaque station
ID, proximity as the primary read, structured availability) are good design
regardless.

This is a scoping act, so the outcome is either a live decision recorded in
**Decisions so far** or a line in **Out of scope** — the founder's call, not a
research finding.
