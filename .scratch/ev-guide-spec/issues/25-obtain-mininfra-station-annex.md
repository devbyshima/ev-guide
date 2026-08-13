# 25 — Obtain MININFRA's Annex No. 2: the existing-stations dataset

Type: task
Status: open
Blocked by: —

## Question

Nothing to decide. This is the highest-value manual action on the map.

Ticket 02 found that MININFRA's EU-funded **EV Charging Infrastructure Master
Plan (Oct 2024)** references **"Annex No. 2 — Existing charging stations in
Rwanda"**, described as carrying, per station: name, location, latitude and
longitude, bay count, kW rating **and connector type**. Every annex in the
document is marked "(Attached)" and **none is present in the published PDF**.

That is precisely the seed dataset EV Guide needs, from an authoritative
government source, and it does not exist anywhere public. For comparison,
OpenStreetMap holds 7 stations for the entire country and PlugShare,
OpenChargeMap and Chargemap all refuse programmatic access.

Request the annexes from MININFRA's Energy Directorate, and in parallel from
the EU delegation or consultancy that funded and authored the master plan. One
email is worth more than any further desk research.

Record in the answer: what was requested, from whom, when, and what came back.
If the dataset arrives, capture its actual shape and row count — that becomes
concrete input to 19's schema and may graduate the **data seeding** patch out
of the map's Not yet specified section entirely.

If it does not arrive, say so plainly and the manual-entry model stands
unchanged — it is already the working assumption, not a contingency.

## Open question routed from 26 (2026-08-13)

The founder's rule is **no reliance on external people; we build everything
ourselves**. Confirm before acting whether a *one-time* dataset acquisition
falls under it.

The reading applied on the map is that the rule targets **runtime dependency** —
a request for a government dataset produced under a public EU contract is
reference material the studio would own outright thereafter, and admin-entered
stations were always the design. Under the opposite reading this ticket closes
and all 224 sites are entered by hand from scratch.
