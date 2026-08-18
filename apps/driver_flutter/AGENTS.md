# EV Guide driver app (Flutter)

Flutter 3.47.0 / Dart 3.13.0, pinned by [ADR-0012](../../docs/adr/0012-flutter-migration.md).
The toolchain lives at `~/Dev/.tools/flutter` and is NOT on PATH:

```bash
export PATH="$HOME/Dev/.tools/flutter/bin:$PATH"
```

## EV Guide notes

This app talks **only** to `ev_guide_data`'s protocols (ADR-0005). It must not
import the mock outside `main()`'s composition root, and it must not compose
availability strings: those come from `ev_guide_domain`'s grammar, which is
the one place the display laws are enforced. Every pixel value comes from
`ev_guide_ui`; this app authors **no measurement and no vocabulary**.

The Dart domain package is a transcription of the TypeScript reference in
`packages/domain`. Its proof of equivalence is `packages/corpus/corpus.json`,
executed by both suites. If you change derivation or grammar behaviour, change
the TS reference and the corpus first, or you are forking the spec.

`ios/` and `android/` are REAL, authored, committed projects. This is the
reverse of the old Expo rule: edit them directly, never regenerate them.

## The iOS 27 UIScene trap (why the Expo predecessor died)

iOS 27.0 (device build 24A5390f) fatally traps any app built against the
27.0 SDK that does not adopt the UIScene lifecycle (TN3187). The trap:

- `devicectl process launch --console` misreports the SIGTRAP as
  `exit code 0`. Never trust that line on this toolchain.
- The SIMULATOR does not reproduce it: its 27.0 runtime (24A5355p) predates
  the enforcement, so "works in the simulator" proves nothing here.
- A bare `UIApplicationSupportsMultipleScenes` flag is not adoption (tested
  on this device: still traps). A full `UISceneConfigurations` manifest with
  a scene delegate is.

The Flutter 3.47 template ships full adoption (`UIApplicationSceneManifest`
plus `Runner/SceneDelegate.swift`). Do not remove either. Real crash logs
come from devicectl's `systemCrashLogs` domain, not
`~/Library/Logs/CrashReporter/` (which stays empty unless Xcode's Devices
window syncs it):

```bash
xcrun devicectl device info files --device <id> --domain-type systemCrashLogs
xcrun devicectl device copy from --device <id> --domain-type systemCrashLogs \
  --source <name>.ips --destination <path>
```

## Building and installing on the physical device (Serein)

Signing is committed: automatic, personal team `7WHQR6L96K`. First verified
end to end 2026-08-18 (Release build, installed and launched over
localNetwork, process stable, no crash log).

```bash
flutter build ios --release
xcrun devicectl device install app --device E41E8007-FB0A-516E-8A80-DA36110DFFDF \
  build/ios/iphoneos/Runner.app
xcrun devicectl device process launch --device E41E8007-FB0A-516E-8A80-DA36110DFFDF \
  com.fulltimestudio.evguide.driver
```

### The things that actually go wrong

1. **Serein is paired over localNetwork**, the flap-prone transport. Installs
   can stall; retry the install, not the build. A USB-C **data** cable is the
   real fix, and only the founder can plug one in.
2. **The free team caps the device at THREE sideloaded apps.** The install
   fails with `IXUserPresentableErrorDomain error 14` and Apple names the
   three holding the slots. Uninstalling one is irreversible and destroys its
   data, so it is the founder's call, never the agent's. This app's bundle id
   (`com.fulltimestudio.evguide.driver`) reuses the slot the Expo build held.
3. **Free-team profiles live 7 days.** Anything installed stops launching
   about a week later with "Unable to Verify App" and no build error. Rebuild
   rather than debug. A paid membership removes both this and the 3-app cap.
4. **Verify launches by polling the process list**, not by the launch
   command's exit status (see the trap above):

   ```bash
   xcrun devicectl device info processes --device <id> --json-output /tmp/procs.json
   ```

## Simulator verification

Per the studio rule, verify UI headlessly, never by driving the simulator GUI:

```bash
flutter build ios --simulator --debug
xcrun simctl install <sim-udid> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <sim-udid> com.fulltimestudio.evguide.driver
xcrun simctl io <sim-udid> screenshot /tmp/shot.png
```

## Android

`flutter config` already points at `~/Dev/.tools/android-sdk`, but there is
no JDK on this machine, so the Android leg cannot build today. Pin work to
iOS until that changes.
