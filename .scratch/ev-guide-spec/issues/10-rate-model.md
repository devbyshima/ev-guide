# 10 — What is a rate, who writes it, and how does it stay true?

Type: grilling
Status: resolved (2026-08-13)
Blocked by: 03, 07

## Question

The driver app displays what charging costs. EV Guide never collects it.

Settle: the unit — per kWh, per minute, per session, or a combination, and
whether that varies by operator (03 should have found the real-world answer);
currency and formatting, following the reference's `135 000 RWF` treatment;
whether the rate varies by connector or power level at the same station, by
time of day, or by membership; whether there are connection or parking fees on
top; who is entitled to write it, given the admin enters stations manually but
operators know their own pricing; how a stale rate is detected and shown; and
what the app displays when the rate is unknown.

A wrong rate is worse than no rate — a driver who drives across Kigali on a
stale price has been actively misled. Decide what EV Guide owes the driver in
accuracy, and what it promises.

## Lead routed from 02 (2026-08-13)

**RURA Regulation No 011/ENERGY/RURA/2026** (in force 29 June 2026) governs EV
charging in Rwanda. Before this ticket is worked, establish whether it sets,
caps, or requires approval of charging tariffs, and in what units — a filed
tariff would be a rate source **independent of operator goodwill**, which
matters because the working assumption is that EV Guide may get no operator
cooperation at all. Ticket 03 has been asked to check this.

## Findings routed from 03 and 22 (2026-08-13)

**No regulatory rate source exists.** RURA Art. 27 requires only that tariffs be
displayed **at the facility** — no cap, no filing, no approval. The manual-entry
model for rates is settled by absence, not preference.

**But rate is a regulated disclosure.** Art. 27(2) requires public tariff
display, which argues for treating rate as an always-present field rather than
an optional one.

**A real price signal exists.** Kabisa's public feed carries `pricePerKwh` for
**12 of 77** Rwandan records, uniformly **600 RWF/kWh** (verified by the
coordinator). That both answers the unit question — per kWh, in RWF — and hints
at a de facto market rate. Whether EV Guide displays a figure sourced from a
competitor's feed is part of ticket 26.

## Constraint routed from 26 (2026-08-13)

Kabisa's `pricePerKwh` is ruled out as a source. Rates are **fully manual** —
admin- or operator-entered — which is consistent with RURA requiring no tariff
filing. The uniform **600 RWF/kWh** across the 12 populated records stands as
market intelligence for sanity-checking manual entries, not as an input.

## Round 1 settled (2026-08-13) — interim, ticket not yet resolved

- **Rate attaches to the Connector, not the Station.** A station-level price is
  a lie at a mixed site, and the AC/DC mix is real (45 DC / 32 AC nationally).
- Unit **RWF per kWh**, with an optional session or connection fee. Every
  populated record observed was `pricePerKwh` at a uniform 600 RWF/kWh.
- Reuses ADR-0002's shape: `rate` + `rateConfirmedAt` + an `Unknown` case,
  decaying at **90 days** — prices move on a different timescale than bays.
- When unknown, say so rather than hiding the field: RURA Art. 27 requires the
  tariff be displayed at the facility, so the driver finds out on arrival.

Still open: **who may write it** (Round 2).

## Answer

**Rate is a property of the Connector, in RWF per kWh, written by Owners and
Admin only.**

- **Per connector, not per station.** A station-level price is a lie at a mixed
  site, and the AC/DC mix is real — 45 DC against 32 AC nationally. A 7 kW AC bay
  and a 120 kW DC bay at the same site do not cost the same.
- **RWF per kWh**, with an optional session or connection fee. Every populated
  record observed used `pricePerKwh`, uniformly 600 RWF/kWh.
- **Freshness reuses ADR-0002 wholesale**: `rate` + `rateConfirmedAt` + an
  `Unknown` case, decaying at **90 days**. Prices move on a different timescale
  than bays, so the decay constant differs while the shape does not.
- **Unknown is stated, not hidden.** RURA Art. 27 requires the tariff be
  displayed at the facility, so the driver finds out on arrival regardless —
  an empty field is less honest than "rate not confirmed".
- **Write permission: Owners and Admin only.** Operators write availability but
  not rates. The split is operational versus commercial: the person on site is
  best placed to say a bay is busy, while a price belongs to whoever sets
  prices, and a mistyped rate misleads every driver until someone notices.
  Operators may **flag** a rate as wrong without changing it.

No regulatory source exists to cross-check against — RURA requires no tariff
filing (03). The uniform 600 RWF/kWh remains market intelligence for sanity
checks, not an input.
