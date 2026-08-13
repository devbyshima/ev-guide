# 05 — Can Expo carry CarPlay and Android Auto, and at what cost?

Research for ticket
[`05-expo-native-module-viability`](../issues/05-expo-native-module-viability.md).
Researched 2026-08-13. All maintenance-status figures (versions, commit dates,
download counts) are volatile and stamped **as of 2026-08-13**.

## Sourcing note

Primary sources are Expo's documentation (`docs.expo.dev`), the libraries' own
GitHub repositories and npm registry records (versions and publish dates read
from `registry.npmjs.org`, downloads from `api.npmjs.org`), and Apple/Google
documents already established in research 04. GitHub repo metadata (last push,
archived flag, issue counts) read from the GitHub API. Community blog posts and
forum threads are **explicitly labelled** secondary/anecdotal.

---

## Verdict, up front

**Expo can carry both integrations without ever leaving CNG/prebuild — a bare
workflow is not mandatory — but no library you can adopt today gives EV Guide
its CarPlay screen.** The ecosystem's one maintained library
(`@iternio/react-native-auto-play`, New-Architecture-only, actively developed,
backed by a real EV-routing company) implements the **navigation-app** template
set and **does not implement `CPPointOfInterestTemplate` or Android's
`PlaceListMapTemplate`** — the two templates research 04 established are the
centrepiece of a `carplay-charging` / `POI`-category app. The one library that
*does* implement them (`birkir/react-native-carplay`) is old-architecture-only,
has published nothing to npm since a June 2024 beta, and says "No Expo support
due to Scenes" in its own README. Its actively-maintained fork was **archived
in February 2026** in favour of the Iternio library.

The honest shape for EV Guide is therefore a **custom Expo module** (Expo
Modules API, Swift + Kotlin) wrapping the small template surface EV Guide
actually needs, plus an **own config plugin** for the entitlement, scene
manifest, and manifest entries — with `@iternio/react-native-auto-play` watched
as a possible future adoption if it grows POI templates. Since the map already
rules car integrations out of the first build, this cost lands in a later
effort; nothing about it needs to distort the v1 codebase beyond what ticket
15 should already do (keep the car surface's data reads behind a seam).

Expo Go can never run any of it — confirmed, on two independent grounds
(§1). The rest of the app keeps CNG, EAS, and every Expo affordance except
Expo Go.

---

## 1. Prebuild/CNG vs bare — and Expo Go

**CNG/prebuild is sufficient; bare is not mandatory.** Expo's Continuous Native
Generation docs describe exactly this class of customization: config plugins
automate changes to `AndroidManifest.xml` and `Info.plist`, and the docs'
own examples include multi-target features (Safari extensions, iMessage
stickers, App Clips, widgets) that are structurally harder than what CarPlay
needs (<https://docs.expo.dev/workflow/continuous-native-generation/>). The
native `ios/` and `android/` directories stay gitignored and regenerated.
**Verified fact** for the mechanism; **inference** for "sufficient for
CarPlay specifically", because no maintained end-to-end worked example exists
(§3) — the claim is that every individual modification CarPlay needs
(entitlements file, Info.plist keys, added Swift files, manifest `<service>`
entries) has a documented config-plugin mod covering it.

Two real caveats keep this from being free:

- **The scene problem.** `react-native-carplay`-style libraries split the app
  into a phone `UIScene` and a CarPlay `CPTemplateApplicationScene`. Expo's
  generated `AppDelegate` still uses the legacy window lifecycle, and an Expo
  maintainer's position (tsapeta, Sep 2023) remains the last official word:
  *"We currently don't use scenes anywhere, but we're open for an RFC and
  adding support for them"*
  (<https://github.com/expo/expo/discussions/24354>). No movement since —
  **confirmed absence** of any official Expo car-platform support, roadmap
  item, or scene RFC as of 2026-08-13. Community reports in that thread
  (2025–2026, anecdotal) include expo-dev-client crashing under scene
  configurations.
- **Apple is about to force the issue in Expo's favour.** Apps built with the
  iOS 27 SDK / Xcode 27 must adopt the UIScene lifecycle or they will not
  launch (Apple TN3187). Expo prebuild's template currently fails under Xcode
  27 beta for exactly this reason
  (<https://github.com/expo/expo/issues/46663>, filed against SDK 56, closed
  as needs-repro; twin issue #46664). **Inference:** Expo must ship
  scene-lifecycle templates within roughly one SDK cycle, which removes the
  structural half of the "no Expo support due to Scenes" objection — what
  will remain is registering an *additional* CarPlay scene, a much smaller
  config-plugin job.

**Expo Go: categorically impossible, on two grounds.** (1) A development build
is *"essentially your own version of Expo Go where you are free to use any
native libraries and change any native configuration"*
(<https://docs.expo.dev/develop/development-builds/introduction/>) — Expo Go
is the version where you are not; none of these libraries' native code is
compiled into it. (2) Even if it were, Expo Go is signed with Expo's own
provisioning; it can never carry `com.apple.developer.carplay-charging`, and
CarPlay templates require the entitlement at runtime (research 04 §1.4:
unsupported template use throws). Ground 1 is **verified fact** (vendor
documentation); ground 2 is **inference** from Apple's signing model.

Everything else survives: EAS Build, EAS Update, dev clients, CNG upgrades.
The only Expo affordance lost is Expo Go itself — which any app with any
custom native module loses anyway.

## 2. The library landscape — a lineage, not a choice of peers

The story as of 2026-08-13 is one lineage with three nodes. All maintenance
figures below are **verified facts** read from npm/GitHub on that date.

### 2.1 `birkir/react-native-carplay` — canonical, dormant, old-architecture

- **npm:** latest published version is `2.4.1-beta.0`, published
  **12 June 2024** — the `latest` dist-tag has pointed at a beta for over two
  years. Last *stable* release: 2.3.0, May 2023
  (<https://registry.npmjs.org/react-native-carplay>).
- **Downloads:** ~5,833/week (week of 3–9 Aug 2026) — still the most-used
  package by an order of magnitude, i.e. the install base is riding a 2024
  beta.
- **GitHub:** last commit **23 Sep 2025** (a dependency-fix merge); ~805
  stars; 49 open issues
  (<https://github.com/birkir/react-native-carplay>).
- **Expo:** README states verbatim: **"No Expo support due to Scenes"**.
  The request to support an Expo config plugin
  (<https://github.com/birkir/react-native-carplay/issues/101>) has been open
  since **August 2022**.
- **New Architecture:** not supported. Feature request open since Feb 2025
  with no maintainer commitment
  (<https://github.com/birkir/react-native-carplay/issues/225>); a
  Hermes-runtime crash report under new-arch conditions is open
  (issue #237, Aug 2025). No release notes mention Fabric/TurboModules.
- **iOS support:** minimum iOS 14; no release since June 2024 means **no
  release has ever targeted iOS 18, 26 or 27** — silence, not verified
  breakage, but for a framework surface Apple revises annually
  (research 04 shows iOS 26.4/27 template changes) that silence is the risk.
- **Android Auto:** shipped in `2.4.0-beta.2` (Oct 2023) via the Car App
  Library — the same package covers both platforms
  (<https://birkir.dev/react-native-carplay/>).
- **Templates — the one thing it gets right for EV Guide:** its docs list
  `PointOfInterestTemplate` (iOS) and `PlaceListMapTemplate` (Android Auto)
  among supported templates (<https://birkir.dev/react-native-carplay/>) —
  the exact pair a charging/POI app is built from.

**Assessment (mine):** the only library covering EV Guide's template needs is
old-architecture-only — a direct conflict with the map's standing "New
Architecture" preference — incompatible with Expo by its own README, and
publishing nothing for two years. Adopting it means adopting its maintenance
burden.

### 2.2 `@g4rb4g3/react-native-carplay` — the fork that bridged, now archived

The fork that made CarPlay work under Expo SDK 52/53 in a production
navigation app (per its author's comments in the Expo discussion). **Archived
on GitHub 4 Feb 2026**, read-only, with the notice *"Archived in favor of
@iternio/react-native-auto-play"*
(<https://github.com/g4rb4g3/react-native-carplay>). npm latest 2.7.22;
~427 downloads/week — residual. Do not adopt an archived package; its only
significance is that its author (Manuel Auer, g4rb4g3) is now a maintainer of
the successor, i.e. the Expo-compatibility knowledge migrated there.

### 2.3 `@iternio/react-native-auto-play` — the living successor, wrong template set

- **Who:** Iternio Planning AB — the company behind A Better Routeplanner
  (ABRP), a shipping EV-routing product. Maintainers include g4rb4g3.
  **Assessment:** this is the healthiest possible sponsor shape for a car
  library — a company whose own revenue product depends on it.
- **Maintenance:** repo created **14 Nov 2025**; last push **11 Aug 2026**
  (two days before this research); 978 commits; 3 open issues; 61 stars.
  npm `0.5.13` latest, ~2,257 downloads/week — young (nine months old,
  0.x versioning) but genuinely active
  (<https://github.com/Iternio-Planning-AB/react-native-auto-play>).
- **Architecture:** README: **"Supports React Native new architecture
  only."** Built on Nitro modules (`react-native-nitro-modules` peer
  dependency). Android exceptions are broken below RN 0.80. This is the only
  car library aligned with the map's New Architecture preference.
- **Expo:** no config plugin ships in the package (verified: no
  `app.plugin.js` or plugin directory in
  `packages/react-native-autoplay/`). Setup is manual native modification —
  AppDelegate method, four scene delegates in Info.plist, Entitlements.plist
  (<https://github.com/Iternio-Planning-AB/react-native-auto-play/blob/master/packages/react-native-autoplay/README.md>).
  One Expo-specific known issue is documented: under **Expo SDK ≥ 56 you must
  set `buildReactNativeFromSource: true`** (expo-build-properties) so the
  library's React Native patch can apply — which **forfeits SDK 54+'s
  precompiled-React-Native fast builds** for the whole app. A patch to
  expo-splash-screen via patch-package is also carried. **Verified fact**
  (their README); the build-time cost is **inference**.
- **The disqualifying gap for EV Guide:** supported templates are Map, List,
  Grid, Search (Android-only), Information, Message, SignIn (Android-only).
  **No `PointOfInterestTemplate`, no `PlaceListMapTemplate`, no POI
  category support — confirmed absence** (README template table and full-repo
  search, 2026-08-13). The library is shaped around ABRP's own needs: a
  **navigation-category** app whose root is `MapTemplate`. Research 04
  established that `CPMapTemplate` is *forbidden* to a `carplay-charging` app
  — the framework throws at runtime — and `NavigationTemplate` is
  category-locked away from an Android POI app. **A charging-category EV
  Guide cannot build its centrepiece screen with this library as shipped.**
  Its List/Grid/Information templates would work, but the map-with-pins
  screen — the product — would not exist.

### 2.4 What this adds up to

**As of 2026-08-13 there is no library that is simultaneously (a) maintained,
(b) New-Architecture, (c) Expo-viable, and (d) implements the templates a
charging/POI-category app is permitted to use.** (a)+(b) exist without (d)
(Iternio); (d) exists without (a)(b)(c) (birkir). This is the confirmed
absence at the heart of the ticket, and it is what forces the verdict in §6.

## 3. Config plugins for the three native artifacts

Can a config plugin reproducibly manage each thing CarPlay/Android Auto needs?
Mechanism by mechanism (all **verified** against Expo docs; the composition is
**inference**):

| Artifact | Config-plugin mechanism | Status |
|---|---|---|
| `com.apple.developer.carplay-charging` entitlement | `ios.entitlements` in app config (static, first-class — no plugin code needed) | Trivial |
| Info.plist scene manifest (`UIApplicationSceneManifest` → `CPTemplateApplicationSceneSessionRoleApplication` pointing at a CarPlay scene-delegate class) | `ios.infoPlist` merges arbitrary keys; the referenced Swift scene-delegate class must be delivered as native code (a library's, or an Expo module's `ios/` sources) | Doable; the class, not the plist, is the work |
| AndroidManifest `<service>` with `androidx.car.app.CarAppService` action + `androidx.car.app.category.POI` category, `minCarApiLevel` meta-data, `MAP_TEMPLATES` permission | `withAndroidManifest` dangerous-free mod; adding services/meta-data is a standard, stable plugin operation | Routine |
| Extra Swift/Kotlin source files | Not needed as plugin file-copies if the code lives in a library/Expo module — autolinking carries it | Preferred shape |

The important nuance: entitlements and manifest entries are *data* and config
plugins own data outright. The scene delegate and `CarAppService` subclass are
*code*, and code should live in a module that autolinks, not in a plugin that
copies files — that is exactly the split the Expo Modules API is designed for
(<https://docs.expo.dev/modules/config-plugin-and-native-module-tutorial/>).

**Worked examples exist but every one is stale — confirmed, none maintained:**

- `KMalkowski/expo-config-carplay-plugin` — proves the two-scene split is
  expressible as a config plugin, but targets react-native-carplay **2.3.0 on
  the old architecture only**, 3 commits, 0 stars, no releases; its own README
  says the natural next step is a rewrite *"using Turbo or Expo modules"*
  (<https://github.com/KMalkowski/expo-config-carplay-plugin>).
- A 2022 gist wiring 2.1.0 into Expo 47 via dangerous mods
  (<https://gist.github.com/nixolas1/62f5ce8473224cc8437211e787489b1d>) —
  historical evidence only.
- The g4rb4g3 fork ran in a production Expo SDK 52 app (author's claim in
  <https://github.com/expo/expo/discussions/24354>) — the strongest
  existence proof that prebuild + CarPlay ships, and it is archived.

So: **reproducible, yes; off-the-shelf, no.** The plugin EV Guide needs would
be written and owned by EV Guide (roughly: one entitlements entry, one
`ios.infoPlist` merge, one `withAndroidManifest` mod — small, but ours).

## 4. EAS Build and the entitlement

**How capability sync works.** EAS reads the entitlements from app config and
*"automatically synchronizes capabilities on the Apple Developer Console with
your local entitlements configuration when you run `eas build`"*; it supports
~69 capabilities for auto-enable, and *"EAS Build will only enable
capabilities that it has built-in support for, any unsupported entitlements
must be manually enabled via Apple Developer Console."* Sync can be disabled
with `EXPO_NO_CAPABILITY_SYNC=1`
(<https://docs.expo.dev/build-reference/ios-capabilities/>). **CarPlay is not
addressed anywhere in that document — confirmed absence.**

**Inference, flagged as such:** CarPlay is an "Additional Capability" that
Apple assigns to the *account* after the entitlement request (research 04
§1.3), and the developer then enables it on the App ID under the Additional
Capabilities tab. Expect EAS's automatic sync **not** to cover it; the
enablement is a one-time manual portal step (App ID → Additional Capabilities
→ CarPlay → new provisioning profile). After that, EAS **managed credentials
should regenerate profiles that include it** — the expo/fyi recovery document
for missing-capability profiles prescribes exactly "define the entitlement
statically in `ios.entitlements`, re-run `eas build`"
(<https://github.com/expo/fyi/blob/main/provisioning-profile-missing-capabilities.md>).
If sync misbehaves against the unrecognized key, the documented fallbacks are
`EXPO_NO_CAPABILITY_SYNC=1` plus manually-managed credentials
(`credentialsSource: local` or uploaded profiles). No public report of an EAS
build failing specifically on a `carplay-*` key was found (searched
2026-08-13) — the risk is friction, not a wall. Apple-forum reports do exist
of CarPlay entitlements missing from portal-generated profiles even outside
EAS (<https://developer.apple.com/forums/thread/702310>, anecdotal).

**What works before Apple grants the entitlement — the useful asymmetry:**

- **iOS Simulator builds: everything.** Simulator builds are not checked
  against a provisioning profile, so the entitlement key can sit in
  `ios.entitlements` ungranted and CarPlay still runs in the simulator's
  CarPlay window. Community-verified practice, including Flitsmeister's
  engineering write-up
  (<https://medium.com/flitsmeister/start-developing-your-navigation-app-for-carplay-6e4c6c2b4e47>)
  and an Apple forum thread confirming simulator-only testing pre-grant
  (<https://developer.apple.com/forums/thread/726227>). **Secondary sources,
  consistent, not Apple-documented.**
- **Any signed build (device, TestFlight, CarPlay Simulator on a real
  iPhone): nothing.** The profile cannot carry an ungranted entitlement;
  signing fails or the scene never attaches (research 04 §1.3: a
  CarPlay-supporting profile is required even for the CarPlay Simulator Mac
  app). Development on the whole rest of the app is unaffected — the
  entitlement key would simply be left out of dev-build profiles until
  granted, e.g. behind an EAS build-profile-specific app-config branch.
- **Android has no equivalent gate at all.** The POI category needs no
  pre-grant; the blocking Play review arrives only at Open testing/Production
  tracks (research 04 §2.6).

## 5. Testing without car hardware

- **iOS Simulator's built-in CarPlay window** (I/O → External Displays →
  CarPlay): works pre-entitlement (§4). Expo-specific friction: none beyond
  needing a dev-client/simulator build — Expo Go is already out.
- **CarPlay Simulator** (Mac app in *Additional Tools for Xcode*, Hardware
  folder): drives a real cabled iPhone as if it were a car head unit —
  requires the granted entitlement in the provisioning profile (research 04
  §1.3). Friction is Apple's, not Expo's.
- **Android Desktop Head Unit (DHU):** standard SDK tool; the Iternio example
  app documents the workflow and even ships an `adb` port-forward script
  (<https://github.com/Iternio-Planning-AB/react-native-auto-play> —
  `apps/example`). Works against any debuggable build, including an Expo dev
  client. Expo-specific friction: **none identified — confirmed absence** of
  any reported DHU/Expo incompatibility (searched 2026-08-13).
- The one reported Expo-specific test-loop problem is the expo-dev-client
  crash under scene configurations (2025 community reports in
  <https://github.com/expo/expo/discussions/24354>, anecdotal) — meaning the
  car surface may need `expo run:ios`-style local builds rather than the dev
  client until Expo's scene-lifecycle work (§1) lands.

## 6. The verdict the ticket asks for

Three candidate shapes, costed against what 04 requires and §2's landscape:

**(a) Community library.** Today this means either birkir's
react-native-carplay (right templates; old-arch, Expo-hostile, npm dormant
since June 2024 — adopting it means forking it, which is how the g4rb4g3 line
started and ended) or Iternio's react-native-auto-play (right health; cannot
draw the POI screen a charging-category app is allowed, and its Expo path
costs `buildReactNativeFromSource` for the whole app). **Neither is adoptable
for EV Guide as shipped.** Rejected for now; Iternio's library is the one to
re-check at build time — if it grows POI/PlaceListMap templates and a config
plugin, this verdict flips.

**(b) Custom Expo module (recommended).** An Expo Modules API module — Swift
side registering the CarPlay scene delegate and speaking
`CPPointOfInterestTemplate`/`CPInformationTemplate`; Kotlin side a
`CarAppService` in category POI speaking `PlaceListMapTemplate` — plus an
owned config plugin for the entitlement, scene manifest, and manifest service
(§3). The surface 04 actually permits EV Guide is *small*: one map-with-pins
template, one detail template, a hand-off `open()`, notifications. That is
weeks of native work, not a platform — and it is the only shape that is
simultaneously New-Architecture, CNG-clean, and owns nothing it doesn't need.
Precedent: the ecosystem's own conclusion points here (KMalkowski's README;
Iternio rebuilt on Nitro rather than patching the old module).
Cost to the rest of the app: **near zero** — the module autolinks, prebuild
stays canonical, EAS stays managed (§4's one-time portal step aside), SDK
upgrades touch the module only where Apple/Google move the frameworks.
Expo Go was already forfeit. The real costs are (i) owning Swift/Kotlin
in-house, (ii) the dev-client/scene wrinkle in §5 until Expo ships scene
lifecycle, (iii) being off the community path — no upstream to lean on when
iOS 27 moves something.

**(c) Hand-maintained native directories (bare).** Strictly dominated by (b):
everything (b) does, plus the permanent loss of CNG — every Expo SDK upgrade
becomes a manual native migration for the *entire app*, forever, to serve a
feature the map keeps out of the first build. The existence proofs (§3) show
bare is not required. Rejected.

**Sequencing consequence, restating the map:** because CarPlay/Android Auto
are out of the first build, *none* of (b)'s cost is v1 cost. What v1 must do
is (i) file the `carplay-charging` entitlement request early (research 04's
long pole — and per §1.6 of 04, describe functionality, not a directory), and
(ii) keep the car-facing reads (`stationsNear`, station detail, availability
cache readable while locked) behind the seam 04's data-model constraints
already force.

## What this means for other tickets

- **Ticket 15 (codebase shape):** nothing here requires bare, a monorepo
  native package, or checked-in `ios/`/`android/` directories. CNG + Expo
  Modules API handles the hardest native integration the product will ever
  need, so 15 can commit to managed CNG without a car-integration escape
  hatch. The one structural ask: the future car module wants the station
  read-path as a clean, importable unit (no UI imports), and the app should
  tolerate an extra iOS scene — both free if decided now, expensive
  retrofits later. Expo Go is unavailable the moment *any* custom native
  module lands (likely before CarPlay does — e.g. MapLibre from ticket 06),
  so 15 should assume dev-client-based development from day one.
- **Ticket 24 (car integrations in or out):** "in the spec, out of the first
  build" survives this research, but the build-time cost is now known to be
  **custom native work, not a library install** — roughly an Expo module with
  two platform implementations plus an owned config plugin. Two dated
  re-checks belong in 24: whether `@iternio/react-native-auto-play` has
  grown POI-category templates (repo above; if yes, the custom module
  shrinks to a config plugin), and whether Expo has shipped UIScene-lifecycle
  prebuild templates (forced by Xcode 27 — expo/expo#46663/#46664; if yes,
  the scene half of the integration becomes routine).
- **Ticket 23 (review risk):** unchanged by this research, but note §4's
  asymmetry — everything reviewable pre-grant is simulator-only, so the
  entitlement request cannot be validated against a running build first.

## Confidence and gaps

- Library maintenance facts, archive status, template coverage: **high** —
  read directly from npm/GitHub on 2026-08-13.
- "Prebuild suffices, bare never required": **high** on mechanism, **medium**
  on composition — no maintained public end-to-end example exists; the proof
  is an archived fork's production use plus per-mechanism documentation.
- EAS behaviour with an ungranted/granted CarPlay entitlement: **medium** —
  Expo's docs are silent on CarPlay specifically; the manual-portal +
  fallback path is inferred from documented general behaviour, and no
  contradicting failure report was found.
- Simulator-without-grant: **medium** — consistent multi-source community
  practice, never stated by Apple.
- The Iternio library's roadmap (POI templates? config plugin?): **unknown**
  — a 9-month-old 0.x package moving fast; the re-check in 24 exists because
  this is the finding most likely to be stale by build time.
