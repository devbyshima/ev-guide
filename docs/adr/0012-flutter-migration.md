# ADR-0012 - The mobile apps move to Flutter

Date: 2026-08-18 · Status: accepted · Founder decision
Supersedes: [ADR-0011](0011-platform-floor-pinned.md) entirely, and
[ADR-0006](0006-codebase-shape.md)'s choice of Expo for the mobile apps.
Everything else in ADR-0006 stands: two apps, one monorepo, admin as a Vite
SPA, the package seams, the mock as a first-class citizen.

## Decision

- **`apps/driver` and (when it starts) `apps/operator` are Flutter apps.**
  Dart, not React Native; no Expo anywhere in the mobile surface.
- **New platform floor: Flutter 3.47.0 stable / Dart 3.13.0**, resolved the
  same way ADR-0011 resolved Expo's: latest stable on the day the migration
  started, pinned once, upgrades thereafter are ordinary maintenance.
  Toolchain lives at `~/Dev/.tools/flutter` (studio convention, not on PATH).
- **The TypeScript packages are not deleted.** `packages/domain` and
  `packages/data` remain the **server-side reference implementation**: the
  backend is BWEZE in TypeScript (ADR-0005, unchanged), and the derivation
  must still run there. `packages/ui` remains the token source for the admin
  Vite SPA, which ADR-0006 gives "tokens only".
- **The phone gets Dart ports** under `packages/dart/`: `ev_guide_domain`,
  `ev_guide_data`, `ev_guide_ui`, same seams, same laws, consumed by the
  Flutter apps as path dependencies.
- **The fixture corpus becomes data, not code.** The ten fixtures of
  `docs/availability-display.md` section 3 are exported from the TypeScript
  suite as a committed `packages/corpus/corpus.json`; a TS test regenerates
  and asserts no drift, and the Dart suite executes the same file. A
  transcription of the derivation is *proven* equivalent or it does not ship.
  (Structural laws that cannot serialise, such as "there is no bay-level rate
  field", stay as language-native tests on both sides.)
- **The Expo `apps/driver` stays in-tree until the Flutter app is verified on
  the physical device**, then is deleted in this same effort. The migration
  exists because of a device-only failure; it is not done until the
  replacement launches on that exact device.

## Why - and what this decision actually was

The prompt was the Serein launch failure: the Expo build installs, then dies
in ~74 ms, and the founder saw it crash on every tap. **The diagnosis landed
before this decision was taken, and it exonerated the build**: iOS 27.0
(device build 24A5390f) fatally traps any app built against the 27.0 SDK that
does not adopt the UIScene lifecycle (TN3187), `devicectl` misreports the
SIGTRAP as `exit code 0`, and the simulator's older 27.0 runtime (24A5355p)
predates the enforcement, which is why "works in the simulator" proved
nothing. A patched scene manifest on the same signed bundle survived on the
device. Expo SDK 57 ships no UIScene support, so the in-place fix was a
config-plugin manifest, not a framework upgrade.

**The migration is therefore not justified by the crash**, and is not being
sold as such. It is a platform choice the founder made with the diagnosis in
hand, and it was made knowingly against these recorded costs:

- **3,023 lines of TypeScript and 82 green tests** stop being the phone
  implementation (they survive as the server reference, so the loss is the
  phone half, not the whole).
- **The availability derivation gains a transcription.**
  `docs/availability-display.md` named three executors: server (TS), phone
  (TS, shared with the server), CarPlay (Swift), Android Auto (Kotlin). The
  phone now becomes a *fourth* implementation in Dart. The corpus-as-data
  mechanism above is the mitigation, and it is mandatory, not advisory.
- **Ticket 05 is void.** Its conclusion (custom Expo module + owned config
  plugin for CarPlay) was Expo-specific. The car cluster (20, 22, 24, 27)
  was already blocked on the in-car device test; it now also needs the
  CarPlay/Android Auto viability research redone against Flutter's add-on
  ecosystem before section 9 of the spec can be written.
- **ADR-0011 is dead** eleven days after it was written; its one correction
  worth keeping (take the version from the scaffold, never from the
  dependency's own `latest`) is carried forward here and was applied to
  Flutter the same way.

What Flutter buys, in exchange: one rendering stack owned end to end rather
than a JS bridge over two native scaffolds, no CNG/prebuild regeneration of
`ios/` (the folder is real and committed, so the class of "generated native
project drifts from the docs" problems disappears), and a single binary whose
launch path does not depend on a Metro bundle or Hermes.

## The trap this migration must not walk back into

The UIScene enforcement that killed the Expo build applies to **any** app
built against the iOS 27.0 SDK. The Flutter runner must be checked for a
`UIApplicationSceneManifest` with a full `UISceneConfigurations` entry before
the first device install - a bare `UIApplicationSupportsMultipleScenes` flag
was tested on this device and still traps. If the Flutter template does not
adopt UIScene, the manifest is added by hand in the (now committed) runner
and the reason is this paragraph.

## Consequences

- `packages/dart/domain` ports types, decay, freshness, availability,
  grammar, vocabulary, projections; `packages/dart/data` ports the protocols,
  mock and seed; `packages/dart/ui` ports the tokens and styles with the
  same 1:1 values under test (tickets 33/34/36 corrections included).
- The seed's report ages must anchor to the render clock, not a fixed epoch:
  the TS seed pinned `SEED_NOW` to a 2025 instant, so by 2026 every report
  had decayed and every station derived Unknown. Latent in TS, fixed in the
  Dart port, and owed back to the TS seed as a separate correction.
- `docs/availability-display.md`'s executor list is amended by this ADR:
  server (TS), phone (Dart), CarPlay (Swift), Android Auto (Kotlin), one
  corpus, now as JSON.
- The device build/install recipe in `apps/driver/AGENTS.md` largely carries
  over (devicectl, free-team caps, the systemCrashLogs recipe); the
  Expo-specific rows (prebuild, Metro, `--device` picker hang) die with the
  Expo app.
- `apps/operator` and `apps/admin` remain unscaffolded until asked
  (unchanged).
