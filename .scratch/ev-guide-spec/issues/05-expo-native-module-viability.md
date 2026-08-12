# 05 — Can Expo carry CarPlay and Android Auto, and at what cost?

Type: research
Status: open
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
