# ADR-0011 - Platform floor pinned at Expo SDK 57

Date: 2026-08-16 · Status: accepted · Supersedes the rule in ADR-0006

## Decision

The build effort has started, so [ADR-0006](0006-codebase-shape.md)'s rule
resolves to a number:

- **Expo SDK 57** (`expo@57.0.13`, the `latest` dist-tag on 2026-08-16).
- **React Native 0.87**.
- **New Architecture on.**
- **SDK-default minimum OS versions**, with no hand-raised floors.

Checked live rather than assumed: SDK 58 exists only as a canary
(`58.0.0-canary-20260812`), and canaries are not stable, so 57 is the latest
stable and is what gets pinned.

## Why a number now, and only now

ADR-0006 deliberately refused to name a version during the spec map, because
`create-expo-app` bakes in an SDK and a spec that names one ages badly against
a build that may start months later. The rule was "latest stable **at build
start**". This is build start, so the rule is executed once, here, and the
number stops moving.

`node` is v26.7 and `pnpm` 11.22 on the studio machine; the workspace pins
`packageManager` so CI cannot drift.

## Consequences

- Upgrades after this point are ordinary maintenance decisions, not a
  re-reading of ADR-0006. Nobody needs to re-derive the floor.
- The SDK-default minimums stand unexamined on purpose: Rwanda's fleet skews
  older Android, and every hand-raised floor sheds users for nothing.
- `apps/driver` and `apps/operator` are created against SDK 57 with managed
  CNG + a dev-client from day one (ticket 05); Expo Go is never used.
