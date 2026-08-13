# 15 — One Expo app or two, and what runs the admin dashboard?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 05, 14

## Question

The brief specifies a driver app, a separate operator app, and a web admin
dashboard. This ticket decides how that becomes repositories and packages.

Settle: whether driver and operator are two Expo apps or one app with a role
switch — noting that the reference's `Switch to hosting mode` card assumes the
latter, which is a live 1:1 tension for 17; whether a monorepo with shared
packages (domain model, API client, design system) or separate repos; which
package manager and monorepo tool; how much of the design system the admin web
app shares with the mobile apps; what stack the dashboard uses; and what
`05`'s verdict on prebuild does to the repo layout and to CI.

Also settle the concrete platform floor: which iOS and Android versions the
"latest OS releases" requirement actually pins, which Expo SDK, and the New
Architecture position.

Until this resolves, no Expo app is initialised — running `create-expo-app`
would bake in an answer this ticket hasn't made.

## Constraint routed from 05 (2026-08-13)

Managed **CNG/prebuild + dev-client from day one** — never bare, never Expo Go.
The car integrations, when they come, are a **custom Expo module** with an
owned config plugin; nothing in v1 needs to change for that except keeping the
station-read surface (`stationsNear`, station detail) behind a seam a native
module can later call.

## Constraint routed from 14 (2026-08-13)

**Frontend first, backend after** (ADR-0005): the apps are built complete
against a mock data layer behind repository protocols — the ZUBA pattern —
and the BWEZE tenant swaps in behind the same seam later. This ticket designs
that seam. One backend, one auth realm, one user table across all three
surfaces; the admin dashboard should lean on what BWEZE already serves rather
than invent a stack.

## Resolution (2026-08-13)

1. **Two Expo apps — the brief wins over the reference.** Driver and operator
   are separate apps sharing one auth realm; a human can be both. The
   reference's `Switch to hosting mode` card becomes a **cross-app
   affordance** — open-or-install the operator app, shown only to users
   holding an Owner/Operator membership — whose exact face 17 designs.
2. **One monorepo, pnpm workspaces**, no orchestrator until CI pain demands
   one. `apps/driver` · `apps/operator` · `apps/admin` ·
   `packages/domain` (types + read-time availability derivation, pure) ·
   `packages/data` (repository protocols; the **mock implementation is a
   first-class citizen** with the seed dataset; the BWEZE implementation
   lands later behind the same protocols — ADR-0005's seam) ·
   `packages/ui` (the RN design system both mobile apps share, built 1:1
   from the reference in 17). The future car module is a fourth package
   calling into `packages/data`.
3. **Admin dashboard: Vite + React SPA** — the BWEZE console's own shape,
   deployed as a BWEZE-hosted static app. Shares `domain` and `data`, not
   `packages/ui`; visual kinship via shared design tokens only. Internal
   tooling: the 1:1 reference rule does not govern it.
4. **Platform floor as a rule, not a number:** latest stable Expo SDK pinned
   at build start, New Architecture on (already mandatory for the car-module
   path), SDK-default minimum OS versions — no hand-raised floors.

Standing constraint restated: **no `create-expo-app` until the build effort
starts** — initialisation bakes in answers, and the build is a separate
effort from this map.

Recorded as [ADR-0006](../../docs/adr/0006-codebase-shape.md).

**Knock-ons routed:** 17 — design the cross-app affordance that replaces the
mode-switch card, and `packages/ui` is where its design system lands; 19 —
`packages/domain` is the concrete home of the model it synthesises.
