# ADR-0006 — Two apps, one monorepo, admin as a Vite SPA

Date: 2026-08-13 · Status: accepted · Ticket: 15

## Decision

- **Two Expo apps.** Driver and operator are separate apps sharing one auth
  realm (ADR-0005); the same human may hold both roles. Where the reference
  design assumed one app with a mode switch, its `Switch to hosting mode`
  card becomes a **cross-app affordance** — open-or-install the operator
  app, shown only to holders of an Owner/Operator membership. Ticket 17
  designs its face.
- **One monorepo on pnpm workspaces.** No build orchestrator until CI pain
  demands one.
  - `apps/driver`, `apps/operator` — Expo, managed CNG + dev-client (05).
  - `apps/admin` — **Vite + React SPA**, the BWEZE console's own shape,
    deployed as a BWEZE-hosted static app. Internal tooling: not governed by
    the 1:1 reference rule; visual kinship through shared design tokens only.
  - `packages/domain` — pure types and the read-time availability
    derivation. No platform imports.
  - `packages/data` — the repository protocols; the **mock implementation is
    a first-class citizen** carrying the seed dataset; the BWEZE
    implementation arrives later behind the same protocols. This is
    ADR-0005's frontend-first seam made concrete.
  - `packages/ui` — the React Native design system both mobile apps share,
    built 1:1 from the reference (ticket 17).
  - The future car module (05) is an additional package calling into
    `packages/data`.
- **Platform floor is a rule, not a number:** the latest stable Expo SDK is
  pinned when the build effort starts; New Architecture on; SDK-default
  minimum OS versions with no hand-raised floors.
- **No app is initialised during this map.** `create-expo-app` bakes in
  answers; the build is a separate effort.

## Why

- The brief explicitly specifies a separate operator app, and the split
  matches the audiences: thousands of drivers get a lean listing, dozens of
  operators get a workhorse tool. The shared realm keeps one-human-two-roles
  cheap.
- pnpm is the studio's standard, Expo supports workspaces first-class, and
  the package split puts each ADR's seam in exactly one place: domain logic
  testable without a device, data swappable without touching screens, UI
  shared without duplicating the reference work.
- The admin dashboard copying the BWEZE console's stack means the studio
  maintains one web-app shape, not two.
- Rwanda's device fleet skews older Android; SDK-default floors already
  cover it, and every hand-raised floor sheds users for nothing.

## Consequences

- Ticket 17 designs the cross-app affordance and delivers `packages/ui`.
- Ticket 19's model lands as `packages/domain`, consumed through
  `packages/data`'s protocols — mock and BWEZE implementations must both
  satisfy them.
- EAS Build configuration (three build targets, two of them Expo) is build-
  effort work; nothing here blocks the spec.
