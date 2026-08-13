# 05 — Can Expo carry CarPlay and Android Auto, and at what cost?

Type: research
Status: closed (2026-08-13)
Blocked by: 04

## Question

Given what 04 establishes the platforms require: how does that get built in an
Expo app, and what does it cost in complexity?

Neither integration is React Native — CarPlay is Swift against `CPTemplate`,
Android Auto is Kotlin against the Car App Library. Establish: whether Expo's
prebuild/bare workflow is mandatory from day one (assume yes, confirm it); the
maturity and maintenance status of `react-native-carplay` and any Android Auto
equivalent; whether a config plugin can manage the entitlements, Info.plist
scenes, and manifest entries reproducibly; how EAS Build handles the added
entitlements; and what testing looks like without physical car hardware
(simulators, head-unit emulators).

Then the honest verdict: is the right shape a community library, a custom Expo
module wrapping native code, or hand-maintained native directories? Include
what this decision costs the *rest* of the app — Expo Go availability, upgrade
friction across SDK versions, CI complexity.

## Resolution (2026-08-13)

Full findings: [research/05](../research/05-expo-native-module-viability.md).

**Expo carries both integrations without leaving CNG/prebuild — bare is never
mandatory (and is strictly dominated) — but no adoptable library exists today.**
Expo Go is categorically out (native code + entitlement signing); dev-client
from day one.

- The ecosystem gap: nothing is simultaneously maintained + New-Architecture +
  Expo-viable + implementing the POI/place-list templates a charging-category
  app is allowed to use. `birkir/react-native-carplay` has the right templates
  but is old-arch, npm-stale since a June-2024 beta, and disclaims Expo; its
  active fork was archived Feb 2026 in favour of
  `@iternio/react-native-auto-play` — genuinely maintained (Iternio/ABRP,
  New-Arch/Nitro) but navigation-category only: **no POI templates**, and its
  Expo path costs `buildReactNativeFromSource` app-wide.
- **Chosen shape: custom Expo module** (Expo Modules API, small Swift/Kotlin
  surface — POI template, detail template, hand-off, notifications) plus an
  **owned config plugin** for the entitlement, scene manifest, and Android
  car-app service. Worked plugin examples exist but all are stale.
- EAS: CarPlay is absent from the auto-synced capability list (confirmed
  absence) — one manual portal enablement, then managed credentials work.
  Pre-grant, iOS **simulator** builds run CarPlay fine; signed builds cannot.
  Android has no gate until Play review.
- Testing without hardware: Xcode's CarPlay Simulator window + Google's DHU
  both work against dev builds; known friction is dev-client crashes under
  scene configs until Expo ships UIScene prebuild (expo/expo#46663).

**Knock-ons routed:** 15 — managed CNG + dev-client from day one, car code as
a later custom module, keep station reads behind a seam; 24 — two dated
re-checks before deciding (Iternio growing POI templates; Expo's UIScene
prebuild work).
