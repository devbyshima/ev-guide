# 10 — What is a rate, who writes it, and how does it stay true?

Type: grilling
Status: open
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
