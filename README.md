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

**Charting.** This effort is currently a `/wayfinder` map, not a build. The
destination is a locked `SPEC.md` plus ADR set that an implementation effort
can execute from without relitigating decisions.

- The map: [`.scratch/ev-guide-spec/map.md`](.scratch/ev-guide-spec/map.md)
- The tickets: [`.scratch/ev-guide-spec/issues/`](.scratch/ev-guide-spec/issues/)

No Expo app has been initialised yet — the codebase shape (one app or two,
monorepo layout, admin web stack) is ticket 15, and running `create-expo-app`
now would bake in an answer that ticket hasn't made.
