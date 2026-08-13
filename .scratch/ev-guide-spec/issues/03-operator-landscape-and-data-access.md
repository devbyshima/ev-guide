# 03 — Who operates Rwanda's stations, and can any of them be read programmatically?

Type: research
Status: claimed (research agent, 2026-08-13)
Blocked by: —

## Question

Charting established the operators at headline level: EVP Charger (~95 e-moto,
~20 car), Kabisa (26 public points, 7 at SP fuel stations), Volkswagen Mobility
Solutions Rwanda with Siemens, ~200 public stations in Kigali by Feb 2026, and
EVP's own app shipped July 2026. That was one search. This ticket goes deep.

Establish, per operator: how many stations and bays, where, what connectors and
power, what they charge and in what units, and whether the hardware is
networked at all. Then the decisive question — **is there any programmatic
read**? OCPP backends, OCPI roaming endpoints, a public or partner API, a
scrapeable web map, or nothing. Note what EVP's app exposes about *its own*
station status, since that sets the bar users will compare against.

Also: is anyone else already aggregating across operators in Rwanda, and does
REG or the government publish a station registry?

This ticket is the difference between availability being *read* and availability
being *reported*. Answer accordingly — it unblocks 07, 08 and 10.

## Context pointer

Findings in progress at `.scratch/ev-guide-spec/research/03-operator-landscape-and-data-access.md`.
