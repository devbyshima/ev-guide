# Expo HAS CHANGED

Read the exact versioned docs at https://docs.expo.dev/versions/v57.0.0/ before writing any code.

## EV Guide notes

This app talks **only** to `@ev-guide/data`'s protocols (ADR-0005). It must not
import the mock directly outside `App.tsx`'s composition root, and it must not
compose availability strings: those come from `@ev-guide/domain`'s grammar,
which is the one place the display laws are enforced.

`packages/ui` currently exports tokens only; components land next.

## Building and installing on a physical device (Serein)

Established 2026-08-16. Three studio projects had independently retyped this
sequence and none had it written down.

**`ios/` is GENERATED and gitignored (ADR-0006, managed CNG).** There is no
copy anywhere: `expo prebuild --clean` deletes it with no confirmation. Native
changes go in a **config plugin**, never in the folder. The Xcode scheme is
`EVGuide`, from `sanitizedName("EV Guide")`.

```bash
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8   # CocoaPods needs it; both are empty by default here
pnpm exec expo prebuild --platform ios --no-install
pnpm install && (cd ios && pod install)
pnpm exec expo run:ios --device "Serein"     # first install only: writes signing into the pbxproj
```

Thereafter, **split build from install** so a dropped connection costs a retry
of the install rather than the whole build:

```bash
xcrun devicectl device install app --device E41E8007-FB0A-516E-8A80-DA36110DFFDF \
  ~/Library/Developer/Xcode/DerivedData/EVGuide-*/Build/Products/Release-iphoneos/EVGuide.app
xcrun devicectl device process launch --device E41E8007-FB0A-516E-8A80-DA36110DFFDF \
  com.fulltimestudio.evguide.driver
```

### The five things that actually go wrong

1. **Never pass a bare `--device`.** `@expo/cli` opens an interactive picker
   (`resolveDevice.js:131`) and hangs forever in a non-interactive shell.
   Always `--device "Serein"`.
2. **`- Connecting to: Serein` stalls** on the wireless (localNetwork)
   transport. Expo's own installer is what hangs; `devicectl` direct works.
   A USB-C **data** cable is the real fix.
3. **The free team caps the device at THREE sideloaded apps.** The install
   fails with `IXUserPresentableErrorDomain error 14` and Apple names the
   three holding the slots. Uninstalling one is irreversible and destroys its
   data, so it is the founder's call, never the agent's.
4. **Free-team profiles live 7 days.** Anything installed stops launching about
   a week later with "Unable to Verify App" and no build error. Rebuild rather
   than debug. A paid membership removes both this and the 3-app cap.
5. **`devicectl process launch --console` reporting `exit code 0` can be a
   crash.** The line is a devicectl artifact: this app died in ~74 ms with
   `EXC_BREAKPOINT` / `Trace/BPT trap: 5` and devicectl still printed exit
   code 0. Never trust that line on this toolchain; pull the real crash log:

   ```bash
   xcrun devicectl device info files --device <id> --domain-type systemCrashLogs
   xcrun devicectl device copy from --device <id> --domain-type systemCrashLogs \
     --source <name>.ips --destination <path>
   ```

   (`~/Library/Logs/CrashReporter/MobileDevice/` stays empty unless Xcode's
   Devices window syncs it; the domain above works without Xcode.)

   The crash behind this entry: **iOS 27.0 (device build 24A5390f) fatally
   traps apps built against the iOS 27.0 SDK that do not adopt the UIScene
   lifecycle** — "UIScene life cycle is required for apps built with this
   SDK", TN3187. Expo SDK 57 / RN 0.86 ship no scene support, and a bare
   `UIApplicationSupportsMultipleScenes` flag is not adoption (tested: still
   traps); a full `UISceneConfigurations` manifest survives. The simulator
   does not reproduce it — its 27.0 runtime (24A5355p) predates the
   enforcement — so "works in the simulator" proves nothing here.

### Debug vs Release

A **Debug** build needs Metro reachable from the phone, which is the flaky part
over wireless. A **Release** build embeds `main.jsbundle` and runs standalone:

```bash
pnpm exec expo run:ios --device "Serein" --configuration Release
```

Use Release to *show* the app on a device, Debug with `expo start --dev-client`
to *work* on it.
