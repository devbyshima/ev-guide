# 22 — Are CarPlay and Android Auto usable in Rwanda at all?

Type: research
Status: resolved (2026-08-13)
Blocked by: 04

## Question

Ticket 04 established that **Rwanda is not on either platform's country list** —
Apple lists CarPlay for 37 countries and Android Auto covers ~47, with South
Africa the only African entry in both. Independently verified.

What that does *not* establish is what it means operationally for a Rwandan
user, and the whole scoping decision in 24 turns on the difference between
"not officially supported" and "does not function".

Settle: whether CarPlay is **region-gated in software** — does iOS check device
region, Apple ID country, or carrier and refuse to activate — or whether the
country list is a statement of official support while the feature works
wherever a compatible head unit is present; the same for Android Auto, which
was historically a country-restricted Play Store app before being folded into
Play Services; if gated, **what the gate follows**, since a Rwandan driver with
a US Apple ID or an imported car may land on the other side of it; whether
declaring the CarPlay entitlement or the Android Auto POI category **restricts
where the app can be listed** — an inert car feature is far cheaper than a
blocked App Store listing; and any signal that either platform is expanding
into East Africa.

"This can only be settled by testing on a Rwandan device" is an acceptable
answer and tells the founder exactly what to do next.

## Context pointer

Findings append to `research/04-carplay-android-auto-requirements.md` as §3.3.

## Answer

Findings appended as §3.3 of
[`research/04-carplay-android-auto-requirements.md`](../research/04-carplay-android-auto-requirements.md).

**The two vendors genuinely differ, and that is the finding.**

- **Apple treats country support as a prerequisite.** Rwanda is absent from the
  37-country CarPlay list.
- **Google treats it as marketing rights.** The same 46-country list appears on
  Google's Partner Marketing Hub opening, verbatim: *"You can only market
  Android Auto in countries where it is available."* That is a
  branding-rights document for partners, not a technical availability
  statement. The consumer page says only that "most features won't work".
  **Neither Google source says the software refuses to run.**

**Hardware is not the problem — this is purely a platform-permission
question.** Toyota Rwanda's own downloadable spec sheets name CarPlay and
Android Auto across the range. The decisive data point is the Hilux `2.4GD
Work` grade: vinyl seats, no power windows, no central locking, two speakers —
and still an 8" touchscreen with CarPlay. **In this market CarPlay sits below
the power-windows line.** Counter-example on the record: the petrol Corolla
Cross has a touchscreen and no projection on any grade, so a touchscreen does
not imply CarPlay. Caveat for used imports: Toyota Japan confirms CarPlay was
an extra-cost Display Audio option until June 2020, with SmartDeviceLink the
domestic default — a JDM unit without CarPlay lacks it in Kigali too.

**Not settled, and it cannot be settled from documentation.** The record is
empty in *both* directions — no report of it working, none of it refusing. A
probe of the Play listing under `gl=RW` is recorded as a **failed test**, not
as evidence, because the storefront parameter does not reflect per-country
distribution. This now needs a device, which is **ticket 27**.

**Bonus finding, routed to 02 and 19.** RURA Art. 3(c) enumerates six connector
families, and **every one exists in Apple's 9-case enum**, so EV Guide's app
enum can be RURA's list and still round-trip to CarPlay without loss. Art. 27(2)
requires public tariff display, making rate a *regulated disclosure* and
strengthening it as an always-present field.
