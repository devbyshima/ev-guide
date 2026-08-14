# EV Guide

Find EV charging stations in Rwanda — where they are, what they cost, what
connectors they have, and whether a bay is actually free right now.

A FullTime Studio product. Free, with no monetisation anywhere.

## Surfaces

| Surface | Audience | Platform |
| --- | --- | --- |
| Driver app | EV drivers | Expo (iOS + Android), plus CarPlay and Android Auto |
| Operator app | Station operators | Expo (iOS + Android) |
| Admin dashboard | Studio admin, station owners | Web |

Stations are entered manually by the admin — there is no open dataset for
Rwanda to import from. The admin creates station managers beneath it, in an
owner → operator hierarchy.

## Status

**Charting, nearly done.** This effort is a `/wayfinder` map, not a build. The
destination is a locked `SPEC.md` plus ADR set that an implementation effort
can execute from without relitigating decisions.

- **The spec: [`SPEC.md`](SPEC.md)** — locked for the phone and web surfaces.
  Its car-integration section is deliberately unwritten, pending the device
  test (ticket 27), the scoping call (24) and the platform filings (20).
- The decisions: [`docs/adr/`](docs/adr/) · the model:
  [`docs/domain-model.md`](docs/domain-model.md) · the availability grammar:
  [`docs/availability-display.md`](docs/availability-display.md)
- The map: [`.scratch/ev-guide-spec/map.md`](.scratch/ev-guide-spec/map.md)
- The tickets: [`.scratch/ev-guide-spec/issues/`](.scratch/ev-guide-spec/issues/)

No Expo app has been initialised yet, on purpose. The codebase shape is settled
([ADR-0006](docs/adr/0006-codebase-shape.md) — two Expo apps, one pnpm
monorepo, a Vite admin), but `create-expo-app` pins an SDK, and the platform
floor is a rule: the latest stable SDK at **build** start. That is a separate
effort.
