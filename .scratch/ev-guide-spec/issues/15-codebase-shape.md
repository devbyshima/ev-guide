# 15 — One Expo app or two, and what runs the admin dashboard?

Type: grilling
Status: open
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
