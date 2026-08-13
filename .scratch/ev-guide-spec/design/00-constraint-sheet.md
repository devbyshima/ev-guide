# EV Guide — Car Screen Constraint Sheet

Everything a designer needs to lay out the CarPlay and Android Auto screens, extracted from `/Users/FullTimeStudio/Dev/lab/ev-guide/.scratch/ev-guide-spec/research/04-carplay-android-auto-requirements.md`. No further reading of the source is required.

**Marking legend**

- **[hard]** — a documented platform rule. The doc/API it comes from is named inline.
- **[inferred]** — a derivation, either the research author's or mine. Not a documented safe harbour. Never cite one of these to a reviewer as a rule.
- **[runtime]** — the value is vehicle/host-dependent and undocumented. It must be queried on the device; design against the floor, never against a hoped-for value.

**Governing sources.** CarPlay: *CarPlay Developer Guide*, June 2026 revision (`2026-06-08`), `CarPlay-App-Programming-Guide.pdf` — page numbers are the PDF's own; plus Apple's API reference at `developer.apple.com/documentation/carplay/…`. Android: `developer.android.com` (training, design, quality-guidelines) plus AndroidX/AOSP source (`RowConstraints.java`, `PlaceMarker.java`, `ActionsConstraints.java`, `Screen.java`, `integers.xml`, `CarAppService.java`, `CarIconConstraints.java`, `CarTextConstraints.java`, `ListTemplate.java`, `GridItem.java`, `TabTemplate.java`, `CarContext.java`, `EnergyProfile.java`).

---

# PART A — Apple CarPlay (`com.apple.developer.carplay-charging`, no maps entitlement)

## A0. The entitlement frame (context that fixes everything below)

- **[hard]** The entitlement key is `com.apple.developer.carplay-charging`, minimum **iOS 14** (Developer Guide p.13). The navigation entitlement is keyed `com.apple.developer.carplay-maps` — *not* `carplay-navigation`, which does not exist.
- **[hard]** *"Each CarPlay app category supports specific templates and this is governed by the app entitlement. **Attempting to use an unsupported template triggers an exception at runtime.**"* (Developer Guide p.14.) Template permission is enforced by the framework, not merely by review — a forbidden template is a crash, not a rejection.
- **[hard]** The category→template matrix groups **EV charging, fueling and parking into one column** — identical template set (Developer Guide p.14).
- **[hard]** Only navigation apps get the `CPWindow` base view: *"All other categories of apps use the scene's interface controller exclusively for constructing their user interfaces."* (`developer.apple.com/documentation/carplay/cptemplateapplicationscene`.) **EV Guide has no drawing surface at all on CarPlay.** Every pixel is Apple's template chrome; EV Guide supplies strings, images and IDs only. The visual identity does not appear.
- **[hard]** Charging + fueling entitlements may be combined in one app (Developer Guide p.13, footnote \*2). No other combination except audio+video.
- **[hard]** Entitlement is account-level and all-or-nothing: *"Once a CarPlay app entitlement is added to your app, your app icon will appear on the CarPlay home screen. You cannot selectively show or hide CarPlay for certain people."* (Developer Guide p.12.) No staged rollout, no kill switch, no per-user gate.

## A1. Permitted and forbidden templates (Developer Guide p.14)

| Template | Class | EV charging |
|---|---|---|
| Action sheet | `CPActionSheetTemplate` | **Permitted** |
| Alert | `CPAlertTemplate` | **Permitted** |
| Grid | `CPGridTemplate` | **Permitted** |
| List | `CPListTemplate` | **Permitted** |
| Tab bar | `CPTabBarTemplate` | **Permitted** |
| Information | `CPInformationTemplate` | **Permitted** |
| Point of interest | `CPPointOfInterestTemplate` | **Permitted** |
| Search | `CPSearchTemplate` | **Permitted, iOS 27+ only** (footnote \*5) |
| Voice control | `CPVoiceControlTemplate` | **Permitted, iOS 27+ only** (footnote \*5) |
| Contact | `CPContactTemplate` | **Forbidden** |
| Now playing | `CPNowPlayingTemplate` | **Forbidden** |
| **Map** | **`CPMapTemplate`** | **Forbidden — navigation only** |

All **[hard]**. Also unavailable to a charging app, all **[hard]** and all navigation-only: `CPNavigationSession`, `CPTrip`, `CPRouteChoice`, `CPManeuver`, `CPTravelEstimates`, `CPRouteDetail`, map panels (`pushPanel`/`showPanel`), the panning interface and map buttons, the dashboard and instrument-cluster scenes, voice prompts via `AVAudioSessionModeVoicePrompt`, voice **recording**, and — importantly for this product — **`CPChargingStationConnection`** (connector / voltage / power), which Apple gives to navigation apps only.

> **Design consequence [hard]:** there is no structured connector type on any CarPlay surface available to EV Guide. Connector detail can only be rendered as **free text in a POI or Information string slot**.

**What does *not* cross into navigation territory** (all safe inside `carplay-charging`) **[hard]**: station pins on the MapKit-provided POI map with clustering/pan/zoom; a detail card with two action buttons; a `CPInformationTemplate` showing availability (Apple's own worked example); **distance/bearing text the app computes and puts in `summary` or `detailSubtitle`** — that is a string in a POI field, not route guidance; and launching another app to navigate.

**What tips the app into requiring `carplay-maps`** — avoid all four **[hard]**: drawing your own map surface; displaying a **route line, ETA, distance-to-arrival, or an upcoming maneuver**; speaking voice guidance; owning an active navigation session.

## A2. Template stack depth

- **[hard]** **5 templates including the root.** *"Audio, communication, EV charging, parking, public safety, and navigation apps are limited to a depth of 5 templates… These include the root template."* (Developer Guide p.14.) Corroborated at `developer.apple.com/documentation/carplay/cplisttemplate`: *"The framework restricts all other categories of apps to five levels."*
- **[hard]** Modals (`CPAlertTemplate`, `CPActionSheetTemplate`) are **presented**, not pushed — `presentTemplate`, not `pushTemplate`.
- **[hard]** A `CPTabBarTemplate` must be installed with `setRootTemplate`. *"You can't add a tab bar template to an existing navigation hierarchy, or present one modally."* Each tab is **its own navigation hierarchy**.

## A3. `CPPointOfInterestTemplate` — the map screen

- **[hard]** **Maximum 12 points of interest.** Stated twice: *"an overlay containing a list of up to 12 locations with customizable pin images"* (Developer Guide p.23) and *"`CPPointOfInterestTemplate` displays a maximum of twelve points of interest"* (`…/cppointofinterest`).
- **[hard]** The map is **provided by MapKit**; the app does not draw it (Developer Guide p.23). The template *"manages clustering points of interest, selecting a point of interest, and zooming and panning the map"* itself.
- **[hard]** `CPPointOfInterestTemplateDelegate` is **mandatory**. It fires on **visible-region change**; the app re-supplies the ≤12 via `setPointsOfInterest(_:selectedIndex:)`. The app is responsible for **re-ranking to the visible viewport on every pan and zoom**.
- **[hard]** *"The list of locations should be limited to those that are most relevant or nearby."* (Developer Guide p.23.)
- **[hard]** Guideline: *"When showing locations on a map, **do not expose locations other than EV chargers**."* (Developer Guide p.5.) No petrol, no parking, no landmarks on the POI map.

### A3.1 `CPPointOfInterest` — the exact payload, all six string slots

From `init(location:title:subtitle:summary:detailTitle:detailSubtitle:detailSummary:pinImage:)`. All **[hard]**.

| Field | Type | Rendered where |
|---|---|---|
| `location` | `MKMapItem` — **required** | map annotation position |
| `title` | `String` — **required** | scrollable picker (the strip along the bottom) |
| `subtitle` | `String?` | scrollable picker |
| `summary` | `String?` | scrollable picker |
| `detailTitle` | `String?` | detail card |
| `detailSubtitle` | `String?` | detail card |
| `detailSummary` | `String?` | detail card |
| `pinImage` | `UIImage?` | map annotation |
| `selectedPinImage` | `UIImage?` (iOS 16+) | map annotation when selected |
| `primaryButton` | `CPTextButton?` | detail card action |
| `secondaryButton` | `CPTextButton?` | detail card action |

- **[hard]** **Exactly two action buttons on the detail card. There is no third.**
- **[hard]** These are the **picker-triple** (`title`/`subtitle`/`summary`) and the **card-triple** (`detailTitle`/`detailSubtitle`/`detailSummary`) that `docs/domain-model.md` names as fixed projections.
- **[hard]** All three of `CPPointOfInterest`, `CPListItem` and `CPInformationItem` take **plain `String`, not variants** — their text is truncated by the system with **no app control** over where the cut lands.

### A3.2 POI images

- **[runtime]** Pin sizes are class properties `CPPointOfInterest.pinImageSize` and `CPPointOfInterest.selectedPinImageSize`. **Apple documents the properties but not their values** — read at runtime.
- **[hard]** Images must be display-ready, sized using `interfaceController.carTraitCollection` scale, with light/dark variants via an asset catalog or `UIImageAsset`.
- **[hard]** *"CarPlay doesn't support animated images. If you provide an animated image, CarPlay uses only the first image in the animation sequence."*

## A4. `CPListTemplate` / `CPListItem` — the nearby-stations list

- **[hard]** *"Some cars dynamically limit lists to 12 list items. You can check for the maximum number of list items, but you always need to be prepared to handle the case where only 12 list items are shown."* (Developer Guide p.18.)
- **[runtime]** `CPListTemplate.maximumItemCount` (max items **across all sections**) and `CPListTemplate.maximumSectionCount`. **Neither has a documented constant.** Both are vehicle-dependent and must be queried.
- **[hard]** `CPListItem` fields: `text`, `detailText`, `image`, `accessoryImage`, `accessoryType`, plus progress/playing indicators. **Two text slots per row, not three.**
- **[hard]** *"CarPlay doesn't support custom list item types. Instead, use the `userInfo` property to attach a value to the list item"* — this is the sanctioned carrier for the opaque station ID back to the selection handler.
- **[runtime]** List image sizes come from `CPListItem.maximumImageSize` (Developer Guide p.28).
- **[hard]** `CPListTemplate` is the one template with length-variant support for its **empty state**: `emptyViewTitleVariants` and `emptyViewSubtitleVariants`. This is the only place the app can supply multiple lengths on a list screen.

## A5. `CPInformationTemplate` — the station detail screen

- **[hard]** Apple names charging as an intended use, verbatim: *"A template that provides information for a point of interest, food order, parking location, or **charging location**."*
- **[hard]** *"An information template displays a list of items, and **up to three actions** the user can perform."*
- **[hard]** **Item shape: `CPInformationItem` is a `title` + `detail` pair, and nothing else.** No image, no accessory, no third string, no per-item action.
- **[hard]** Two layouts: `CPInformationTemplateLayout.leading` and `.twoColumn`.
- **[hard]** Actions are `CPTextButton` (title + `CPTextButtonStyle`).
- **[UNKNOWN — not documented as a number]** **Item cap.** Apple gives no integer. The only statement is: *"An information screen is a specific style of list that presents a **limited number** of static labels… Since the number of labels is limited, show only the most important summary information needed to complete a task."* (Developer Guide p.17.) There is no runtime property to query either — unlike lists and tabs, `CPInformationTemplate` exposes **no `maximumItemCount`**. **[inferred]** Design the detail screen so it degrades gracefully if the tail of the item list is dropped: put the load-bearing pairs first and treat anything past the first handful as expendable.
- **[hard]** Apple's own worked example for this template is *"an EV charging app may display information about a charging station such as availability"* (Developer Guide p.17). This is the station-detail screen, sanctioned by name.

> **Fits EV Guide's three actions exactly [inferred]:** the three-action ceiling accommodates *Directions* + *Notify me when a bay frees up* + *Report status*. The POI detail card's two-button ceiling does not — on the card, two of the three must be chosen.

## A6. `CPGridTemplate`

- **[hard]** *"A grid is a specific style of menu that presents **up to eight** choices represented by an icon and a title."* (Developer Guide p.16.)
- **[hard]** *"When there are more than eight buttons in the array, the template displays only the first eight. When there are more than four buttons, the template balances the display of the buttons between two rows."* — **silent truncation, no error.**
- **[hard]** `CPGridButton` takes **`titleVariants: [String]`**, not a single title.
- **[hard]** Grid icon size **40×40 pt** (120×120 px @3×, 80×80 px @2×) — Developer Guide p.28.

## A7. `CPTabBarTemplate`

- **[hard]** *"the tab bar allows up to 4 tabs for audio apps and **up to 5 tabs for all other app categories**. This may change in the future so avoid relying on these fixed values."* (Developer Guide p.25.)
- **[runtime]** Query `CPTabBarTemplate.maximumTabCount`. Apple explicitly warns against relying on the fixed 5.
- **[hard]** Container for **Grid, Information, List and Point of interest templates only** (Developer Guide p.25).
- **[hard]** Root-only; each tab is an independent navigation hierarchy (see A2).
- **[hard]** Tab bar icon **24×24 pt** (72×72 px @3×, 48×48 px @2×). SF Symbols are encouraged for tab icons (Developer Guide p.28).

## A8. `CPAlertTemplate` / `CPActionSheetTemplate`

- **[hard]** Alert = `titleVariants` + actions.
- **[runtime]** `CPAlertTemplate.maximumActionCount` — **value undocumented**, must be queried.
- **[hard]** Action sheet = title + message + actions, *"two or more choices"* (Developer Guide p.15).
- **[hard]** Both are **modal** — `presentTemplate`, not `pushTemplate`.

## A9. `CPSearchTemplate` (iOS 27+ for charging apps)

- **[hard]** *"Cars may limit when the keyboard can be shown. **In many cars the keyboard is not available at all while driving.** The search template should be an alternative option and **never the primary way** to accomplish tasks in your app."* (Developer Guide p.24.)
- **[hard]** Search results are an array of `CPListItem` — so the same two-text-slot row rules apply (A4).
- **[hard]** Search is iOS 27+ for this category, so **any design that requires search excludes iOS 14–26 users entirely**.

## A10. Vehicle-imposed runtime limits — the mechanism

- **[hard]** `CPSessionConfiguration` exposes `limitedUserInterfaces`, a `CPLimitableUserInterface` option set with **exactly two members: `.keyboard` and `.lists`**.
- **[hard]** *"iOS automatically disables the keyboard and reduces list lengths when the car indicates it should do so."* (Developer Guide p.50.) **The reduction happens whether the app handles it or not**; the delegate callback exists only so the app can adjust *other* UI.
- **[hard]** `CPSessionConfiguration` also exposes `contentStyle` (light/dark, driven by ambient light). All artwork needs both variants.

## A11. Strings — the variants mechanism, and where it is absent

- **[hard]** **CarPlay publishes no character counts anywhere** — not in the Developer Guide, not in the API reference. The screen is variable: *resolution, aspect ratio and scale differ per vehicle* (Developer Guide p.28, p.34), so a fixed limit could not exist.
- **[hard]** The sanctioned mechanism is **multiple strings, not a length budget**: *"When the system displays the button, it selects the title that best fits the available screen space, so arrange the titles from most to least preferred… localize each title… be sure to include at least one title in the array."*
- **[hard]** Variants exist **only** on: `CPGridButton.titleVariants`, `CPAlertTemplate.titleVariants`, `CPListTemplate.emptyViewTitleVariants` / `emptyViewSubtitleVariants`, and (navigation-only) `instructionVariants`.
- **[hard]** **`CPListItem`, `CPPointOfInterest` and `CPInformationItem` take plain `String`** — no variants, no truncation control.

> **Design consequence [inferred]:** for the row title, the picker triple, the card triple and every Information item, the app must author a *single* string that is short enough to survive the smallest head unit. There is no fallback ladder on those slots. Authored `nameShort` (not a mechanical truncation of `name`) is the only lever.

## A12. Image asset sizes (Developer Guide p.28)

| Element | Points | 3× px | 2× px |
|---|---|---|---|
| Contact action button | 50×50 | 150×150 | 100×100 |
| **Grid icon** | **40×40** | 120×120 | 80×80 |
| Now playing action button | 20×20 | 60×60 | 40×40 |
| **Tab bar icon** | **24×24** | 72×72 | 48×48 |
| Voice control image | 150×150 | 450×450 | 300×300 |

All **[hard]**. **Only grid icon (40×40 pt) and tab bar icon (24×24 pt) apply to a charging app** — contact and now-playing templates are forbidden, and voice control is iOS 27+.

- **[runtime]** List images (`CPListItem.maximumImageSize`) and POI pins (`CPPointOfInterest.pinImageSize`, `.selectedPinImageSize`) are sized at runtime — **no design-time number exists for either**.
- **[hard]** All assets need **2× and 3×** and **light/dark** variants.
- **[hard]** No animated images anywhere (first frame is used).

## A13. Refresh cadence — what is documented vs what is inferred

- **[hard, but written for a different category]** The only published refresh caps sit in the **driving-task** section (Developer Guide p.5): *"Do not periodically refresh data items in the CarPlay UI more than once every **10 seconds** (for example, no real-time engine data)"* and *"Do not periodically refresh points of interest in the POI template more than once every **60 seconds**."*
- **[inferred]** These are written for driving-task apps and are therefore **not literally binding on a charging app**. They are, however, the only numbers Apple gives for the POI template and they express Apple's view of acceptable churn. **Treat 60 s as the floor for background POI refresh and 10 s for any other periodic update.** The research author flags this explicitly as their inference, not Apple's text.
- **[hard]** There is a separate, **event-driven** path that is *not* capped: the POI delegate fires on **every map region change** and the app must respond then. Region-change refresh is not "periodic".

## A14. Locked-phone data access

- **[hard]** *"CarPlay is frequently used while iPhone is in a locked state."* (Developer Guide p.29.) While locked the app **cannot read**:
  - Files saved with **`NSFileProtectionComplete`** or **`NSFileProtectionCompleteUnlessOpen`**.
  - Keychain items with **`kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`**, **`kSecAttrAccessibleWhenUnlocked`**, or **`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`**.
- **[hard]** Restated for widgets: *"if your widget relies on data protection classes A or B it will generally be non-functional in CarPlay because most people use CarPlay while their iPhone is locked"* (Developer Guide p.4).
- **[inferred]** Therefore the station cache must sit at **`NSFileProtectionCompleteUntilFirstUserAuthentication`**, and any credential needed to refresh it at **`kSecAttrAccessibleAfterFirstUnlock`**. This is the security decision CarPlay forces, and it is why the car surface carries **only non-sensitive directory + availability data** — never the push token, never user-scoped rows.

> **Designer-visible consequence [inferred]:** every car screen must be paintable from cache with the phone locked and the network absent. No screen may be designed around a spinner that resolves from the network, and no screen may be designed around user-specific state the cache cannot hold.

## A15. Notifications — what a charging app may put in them

- **[hard]** *"Notifications are supported in CarPlay communication, EV Charging, parking, and public safety apps."* (Developer Guide p.27.) EV charging is one of only four categories that get them.
- **[hard]** Requires **`UNAuthorizationOptions.carPlay`** at authorization time **and** a notification category created with the **`allowInCarPlay`** option. Both are required; either alone is insufficient.
- **[hard]** Users can switch CarPlay notifications off **per app** in Settings, so **the feature must degrade gracefully** — nothing may depend on delivery.
- **[hard]** *"Notifications should be used sparingly in CarPlay and must be reserved for important tasks required while driving."*
- **[hard]** *"In general, notifications are not read aloud in CarPlay."* — **design the notification to be read, not heard.**
- **[hard]** General guideline 6 forbids showing *"the content of messages, texts, or emails"* on the CarPlay screen. Guideline 4 forbids content unrelated to the primary task.
- **[inferred]** A bay-watch fire ("a bay has freed up at X") is squarely a *task required while driving* and is the sanctioned in-car push for this product. It should be short, name the station, and deep-link to the station detail template. Nothing promotional, nothing summarising other stations, no digest.

## A16. Review guidelines that constrain layout

**All CarPlay apps** (Developer Guide p.4, verbatim numbering) — all **[hard]**:

1. *"Your CarPlay app must be designed primarily to provide the specified feature."*
2. *"Never instruct people to pick up their iPhone to perform a task. If there is an error condition, such as a required log in, you can let them know about the condition so they can take action when safe. However, alerts or messages must not include wording that asks people to manipulate their iPhone."*
3. *"All CarPlay flows must be possible without interacting with iPhone."*
4. *"All CarPlay flows must be meaningful to use while driving. Don't include features in CarPlay that aren't related to the primary task (e.g. unrelated settings, maintenance features, etc.)."*
5. *"No gaming or social networking."*
6. *"Never show the content of messages, texts, or emails on the CarPlay screen."*
7. *"Use templates for their intended purpose, and only populate templates with the specified information types."*

**EV charging apps specifically** (Developer Guide p.5 — there are only two, and both bite) — **[hard]**:

1. *"EV charging apps must provide meaningful functionality relevant to driving (for example, **your app can't just be a list of EV chargers**)."*
2. *"When showing locations on a map, **do not expose locations other than EV chargers**."*

> **Copy rules that follow directly [hard]:** no string on any car screen may say "open the app on your phone", "sign in on your phone", or anything of that shape. Guideline 2 permits *stating* a condition; it forbids *instructing* the manipulation. Combined with the settled decision that directions are anonymous everywhere, **no car screen may present a sign-in wall at all**; a signed-out state may only omit the account-gated affordances (bay-watch, saving, reporting) without explaining how to obtain them.
>
> **[inferred — largest open risk]** Apple never defines "meaningful functionality relevant to driving". Shipping charging apps clear the bar with session control and payment, both permanently out of scope here. The candidates for EV Guide are: live per-bay availability refreshed against the viewport; the directions hand-off; the bay-watch notification; and report-a-broken-charger. **None is documented as sufficient.** The car screens should be laid out so these actions are visually primary and the directory is the substrate, not the product.

## A17. Directions hand-off mechanics

- **[hard]** Sanctioned by name in "Launching other apps in CarPlay" (Developer Guide p.29): *"If your app launches other apps in CarPlay, such as **to get directions** or make a phone call, use the `CPTemplateApplicationScene` method `open(_:options:completionHandler:)` to launch the other app using a URL to ensure it launches on the CarPlay screen."*
- **[hard]** It must go through the **scene's** `open(_:options:completionHandler:)` (inherited from `UIScene`), **not `UIApplication.shared.open`**. The scene form is what routes the launch onto the CarPlay screen rather than the phone.
- **[hard]** **The receiving app must itself be a CarPlay app**, or it has no CarPlay screen to land on.
- **[hard]** Apple Maps URL: `http://maps.apple.com/?daddr=<destination>&dirflg=d` (scheme is `http`, not `maps:`). *"A complete directions request includes the `saddr`, `daddr`, and `dirflg` parameters, but only the `daddr` parameter is required. If you don't specify a value for `saddr`, the starting point is 'here.'"* `dirflg=d` is by car.
- **[hard]** `MKMapItem.openInMaps(launchOptions:)` with `MKLaunchOptionsDirectionsModeKey` also works but Apple warns: *"This is a blocking call and the system suspends interaction with your app until the Maps app finishes launching."* **Prefer the scene `open(_:)` route.**
- **[hard]** Google Maps: `comgooglemaps://?daddr=<lat,lng>&directionsmode=driving`, with `comgooglemaps` declared in `LSApplicationQueriesSchemes`.
- **[UNKNOWN — must be verified on hardware]** Google's page says nothing about CarPlay. Google Maps is itself a CarPlay navigation app so the scene-`open` route *should* land it on the car screen, but **neither vendor documents this**. Given the settled decision that Apple Maps cannot navigate in Rwanda (it appears under "Maps: Standard" and "Maps: Satellite" only, and in neither "Maps: Directions" nor "Maps: Turn-by-Turn Navigation"), **Google Maps is the only viable target and the one undocumented hop is on the critical path**.
- **[hard]** Directions require **only a destination coordinate and a display name**. No route, maneuver, ETA or polyline may be modelled or drawn (that would require `carplay-maps`).

---

# PART B — Android Auto (`androidx.car.app.category.POI`)

## B0. Category and manifest frame

- **[hard]** `androidx.car.app.category.CHARGING` and `…PARKING` are **deprecated** since Car App Library **1.3.0-alpha01, 27 July 2022**: *"Beginning with Car App Library version 1.3, the `androidx.car.app.category.PARKING` and `androidx.car.app.category.CHARGING` car app categories are deprecated. Use the `androidx.car.app.category.POI` category instead."* Both constants still exist in `CarAppService.java` carrying `@Deprecated`. **Do not spec `CHARGING`.**
- **[hard]** POI is explicitly scoped to *"finding points of interest such as parking spots, **charging stations**, and gas stations"*.
- **[hard]** Manifest: `<category android:name="androidx.car.app.category.POI"/>` on the `CarAppService` intent filter; `<meta-data android:name="androidx.car.app.minCarApiLevel" .../>`; declare **`androidx.car.app.MAP_TEMPLATES`**; **do not declare `androidx.car.app.NAVIGATION_TEMPLATES`** (navigation apps only).
- **[hard]** Unlike Apple, **Google places no restriction on showing non-charging locations** — POI folds charging, parking and fuel into one category. (EV Guide is still bound by Apple's stricter rule if one design serves both.)
- **[hard]** Android Auto ≠ Android Automotive OS. AAOS is a separate artifact with its own Play track, review and screenshots — **out of scope**.
- **[hard]** Use **`androidx.car.app:1.7.0-rc01` or higher** so permission dialogs appear correctly on Android 14+ and to avoid crashes on AAOS 15+.

## B1. Permitted templates for a POI app

**Available to all app types, therefore to POI** **[hard]**: `ListTemplate`, `GridTemplate`, **`SectionedItemTemplate`** (`@RequiresCarApi(8)`), `PaneTemplate`, `MessageTemplate`, `LongMessageTemplate`, `SearchTemplate`, `SignInTemplate`, `TabTemplate`.

**Special purpose** **[hard]**:

| Template | Who may use it |
|---|---|
| `NavigationTemplate` | **Navigation only — forbidden to POI** |
| **`PlaceListMapTemplate`** | **POI only** (navigation apps cannot use it) |
| **`MapWithContentTemplate`** | Navigation, **POI**, Weather |
| `MediaPlaybackTemplate` | Media only — **forbidden to POI** |

- **[hard]** *"The `NavigationTemplate` (as well as the deprecated `MapTemplate`, `PlaceListNavigationTemplate`, and `RoutePreviewNavigationTemplate`) can **only be used by apps declaring the `androidx.car.app.category.NAVIGATION` car app category**."*
- **[hard]** **Android gives a POI app a real map surface it can draw into** (`MapWithContentTemplate`) — the opposite of CarPlay, which reserves map rendering for navigation apps. Android's boundary is drawn at *turn-by-turn guidance*, not at *map rendering*.
- **[hard]** Google now positions `SectionedItemTemplate` as the successor to List and Grid: *"With the introduction of the Sectioned Item template, list and grid templates are no longer needed."*

## B2. `PlaceListMapTemplate` — the specific requirements

All **[hard]**, from `developer.android.com/training/cars/apps/poi` and the design docs:

- Each row **≤ 2 text lines**.
- **No `Toggle`** in a row.
- A row **may not have both an image and a place marker** — pick one.
- **`IMAGE_TYPE_LARGE` is forbidden** in this template.
- The `ItemList` is **not selectable** (no selection-group / radio behaviour).
- **Every non-browsable row MUST carry a `DistanceSpan`** on its title or its text. Restated as a design MUST: *"Show duration or distance for each list item (except browsable items)"*.
- *"Associate an action with each list row — **information-only rows not allowed**."* Every row must be tappable and lead somewhere.
- `setCurrentLocationEnabled(true)` requires **`ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`**.

> **Row shape this forces [hard]:** Android spends one of its two lines on distance. The realistic row is
> ```
> line 1: <station short name>
> line 2: <distance> · <availability>
> ```
> **Rate has no room on the car row** — it is a detail-screen field on both platforms.

## B3. `ConstraintManager` content floors

From `integers.xml`, whose header reads *"the following content limits are defaults for when the app fails to communicate with the host for the actual limits"*; the Constraints API guide frames the same numbers as **the documented minimum across all supported vehicles**. All **[hard]**.

| Type | Default / floor |
|---|---|
| `CONTENT_LIMIT_TYPE_LIST` | **6** |
| `CONTENT_LIMIT_TYPE_GRID` | **6** |
| `CONTENT_LIMIT_TYPE_PLACE_LIST` | **6** |
| `CONTENT_LIMIT_TYPE_ROUTE_LIST` | 3 — navigation only, not reachable by POI |
| `CONTENT_LIMIT_TYPE_PANE` | **4** |

- **[runtime — must be queried]** `carContext.getCarService(ConstraintManager::class.java).getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST)`. Limits are **host-controlled and cannot be overridden**.
- **[hard]** **Items beyond the limit are silently ignored by the host** (per the `build()` javadoc on `GridTemplate` / `PlaceListMapTemplate` / `PaneTemplate` / `SearchTemplate`). No error, no warning — the tail simply vanishes.
- **[hard]** **Six is the number to design against, not twelve.** Android's worst case is half of CarPlay's.
- **[hard]** Absolute library cap: `ListTemplate.MAX_ALLOWED_ITEMS = 100` across all sections. Irrelevant in practice — the host limit binds first.

> **Cross-platform result [hard]:** **design every ranked list for 6, cap at 12.** Ranking is store-side and mandatory; the key must be cheap and total — distance first, then availability. There is no "show all stations" affordance on either car screen.

## B4. Rows, text lines, and the 120-character guidance

`RowConstraints.java` presets — all **[hard]**:

| Preset | Max text lines/row | Max actions | Image allowed |
|---|---|---|---|
| `CONSERVATIVE` | **1** | 0 | no |
| `PANE` | **2** | **2** | yes |
| `SIMPLE` | **2** | 0 | yes |
| `FULL_LIST` | **2** | 0 | yes |

The 2-line rule, stated three ways — all **[hard]**:

- `Row.Builder#addText`: *"Most templates allow up to 2 text strings, but this may vary."*
- Template `build()` javadoc: *"Each `Row` can add up to 2 lines of texts."*
- Design docs: *"text is truncated to 2 lines **while driving**. Secondary text in list rows can be longer than 2 rows **when parked**."*

- **[hard]** Guidance: **put the driving-relevant substring first, because the tail is what gets cut.**
- **[hard]** `GridItem` secondary text is *"truncated at the end to fit in a **single line** below the title"* — one line, not two.
- **[hard]** **Tabs: 2–4 at Car API ≤ 8, up to 5 at Car API 9.** The header action must be `ACTION_APP_ICON`.
- **[hard]** Design guidance: text while driving **1–3 lines**, with a **120-character glanceability limit** (`design-principles` page). This is the closest thing to a character budget either platform publishes — and it is *guidance on a design page*, not an enforced cap.
- **[hard]** Task flow **MUST be ≤ 5 steps**, **SHOULD be 2–3**; common tasks in **3 taps or fewer**; **a 5-step flow MUST NOT end on a list template**.
- **[hard]** **8 seconds** minimum dwell before auto-transitioning away from content.

## B5. `PlaceMarker` — the only hard character limit on either platform

- **[hard]** **`PlaceMarker.MAX_LABEL_LENGTH = 3`.** `setLabel()` **throws `IllegalArgumentException` above 3 characters**. Spans in the label are **ignored**. Passing `null` lets the host pick its own scheme.
- **[hard]** Design docs agree: map marker text *"up to **3 letters** maximum"*.
- **[hard]** Marker sizes: **`TYPE_ICON` 64×64 dp**, **`TYPE_IMAGE` 72×72 dp**. **`setColor()` is illegal with `TYPE_IMAGE`** — a tinted marker must be an icon.
- **[hard]** This limit is **not derivable from a station name** — "Kabisa – SP Remera" has no mechanical 3-char abbreviation. It must be an **authored** field. (This is exactly the `Owner.markerLabel` the domain model carries.)

## B6. `CarText` variants and span permissions

- **[hard]** **No max-character count is documented** for titles or body text anywhere in the Android car surface.
- **[hard]** The sanctioned mechanism is `CarText` variants: *"variants should be added in order of preference, from most to least preferred (for instance, from longest to shortest)… If the text provided via Builder does not fit in the screen, the host will display the first variant that fits."*
- **[hard]** Span permissions are **per-field** (`CarTextConstraints.java`). Two that bind layout:
  - **`Row.setTitle()` accepts only `DistanceSpan` and `DurationSpan`** — this is *how* the mandatory distance gets into a title, and the only formatting a title accepts.
  - **`ActionStrip` titles accept no spans at all.**

## B7. Images and `CarIcon`

`Row.java` bounding boxes; oversized images are scaled down preserving aspect ratio. All **[hard]**:

| Constant | Box |
|---|---|
| `IMAGE_TYPE_EXTRA_SMALL` | 48×48 dp |
| `IMAGE_TYPE_SMALL` / `IMAGE_TYPE_ICON` | 88×88 dp |
| `IMAGE_TYPE_MEDIUM` | 128×128 dp (from 1.8.0-beta01) |
| `IMAGE_TYPE_LARGE` | 224×224 dp — **forbidden in `PlaceListMapTemplate`** |

- **[hard]** UX minimum for map imagery: **36×36 dp** for images, icons and map markers; **map text ≥ 24 dp**.
- **[hard]** **`CarIconConstraints.DEFAULT` allows only `TYPE_BITMAP` and `TYPE_RESOURCE`. `TYPE_URI` is generally not permitted**, and where allowed the scheme must be **`content://`**.
- **[hard]** **Remote image URLs cannot be handed to the car.** Assets must be **bundled or materialised locally** — which is why Owner is a bounded, enumerable set with a bundled icon rather than a free-text operator string.
- **[hard]** **`IU-1`: no images except** a single static context image, navigation-drawer icons, images that aid driving decisions, and lane/junction guidance. **One small static mark per station — realistically the Owner icon — and no photographs.** Station `Photo` never reaches a car surface.
- **[hard]** **`SA-1`: no animated elements** — no animated graphics, no video; canvas animations only while parked. Matches CarPlay's *"CarPlay doesn't support animated images"*. **No spinners, no pulsing "live" dot, no transitions on availability change.**
- **[hard]** **`ST-1`: no automatically scrolling text.** No marquee for an overlong station name.

## B8. Action constraints (`ActionsConstraints.java`)

All **[hard]**: `HEADER` **1** · `MULTI_HEADER` **2** · `BODY` **2** · `SIMPLE` **2** · `ROW` **2** · **`FAB` 2** · `NAVIGATION` 4 · `MAP` 4 · `TABS` 1.

- **[hard]** `ActionStrip` itself declares **no maximum**; the ceiling comes from the template's preset.
- **[hard]** `MapWithContentTemplate` ActionStrip: **max 4**.
- **[hard]** `MessageTemplate` / `SearchTemplate` / `SignInTemplate` ActionStrip: **max 2, and only one may carry a title.**

## B9. The 5-template quota — the constraint most likely to bite

All **[hard]** unless marked:

- **Max 5 templates per task.** It counts **templates sent, not `Screen` instances**.
- **The 5th template must be** `NavigationTemplate`, `PaneTemplate`, `MessageTemplate`, `MediaPlaybackTemplate`, `SignInTemplate` or `LongMessageTemplate`. Navigation and MediaPlayback are category-locked away from POI, so **for EV Guide the terminal template can only be `PaneTemplate`, `MessageTemplate`, `SignInTemplate` or `LongMessageTemplate` — never a list and never a map.**
- **Exceeding it:** *"the host displays an error message and closes the app."* The UX docs are blunter: *"Task flows must not exceed 5 steps or the app will crash."*
- **Going back refunds the quota**, by the number of templates popped.
- **Full reset** on reaching a `NavigationTemplate` (unavailable to POI), **or on an intent from a notification or the launcher** — *"even if the app is already in the foreground"*. **That launcher/notification reset is EV Guide's only escape hatch.**
- `SignInTemplate` and `LongMessageTemplate` **bodies do not count** against the quota.
- Screen stack cap: **5 screens**.

### B9.1 What counts as a *refresh* (free — does not consume quota)

Per class javadoc — all **[hard]**:

| Template | Counts as a refresh when… |
|---|---|
| `ListTemplate` | title unchanged **and** list structure unchanged — same section count, same section headers, **same rows and row titles** |
| `GridTemplate` | title unchanged **and** **item count and each item's title** unchanged |
| **`PlaceListMapTemplate`** | title unchanged **and** **row count and row titles** unchanged (**spans excluded**); **or** responding to `setOnContentRefreshListener` |
| `PaneTemplate` | title unchanged **and** row count and row titles unchanged |
| `MessageTemplate` | title and messages unchanged |
| `SearchTemplate` | **any** content change is a refresh |

**Consequences that bind the layout** — first two **[hard]**, mitigations **[inferred]**:

1. On a `PlaceListMapTemplate`, changing the **number of rows** or a **row title** is a *new template* and costs a step. A live availability feed that adds or removes stations as data lands **will burn the quota and the host will close the app**.
2. **Availability therefore cannot live in the row title on Android.** It must live in the secondary text.
3. **[inferred]** Fix the row **set** for the lifetime of the screen (N nearest, resolved once) and let only non-title text change. Note the spans exclusion — **the `DistanceSpan` in the title may update freely**, so distance can tick down live while the title text stays put.

### B9.2 Adaptive task limits

- **[hard]** With it on, *"all updates where the layout stays the same"* count as refreshes — **including changes to the number of rows** — and flows >5 steps become legal while parked.
- **[hard]** But availability is **regional and OEM-dependent**, is **not available for JAMA-affiliated Android Auto vehicles**, and must be probed with **`ConstraintManager.isAppDrivenRefreshEnabled()`** (`@RequiresCarApi(6)`, **returns `false` on host-call failure**).
- **[hard]** **Design for it being off.**

### B9.3 Throttling

- **[hard]** `Screen.onGetTemplate()`: *"To minimize user distraction while driving, the host will throttle template updates to the car screen. When the app invalidates multiple times in a short period, the host will call this method for each call, but it may not update the actual car screen right away."*
- **[UNKNOWN]** **No numeric interval is published.** The one documented timing floor anywhere is the **8-second** minimum dwell before an auto-transition.

## B10. Quality guidelines a POI app must pass

Tier 2 "Car optimized" is the **pass/fail bar** for POI, because POI is a drive-time category: *"Apps in [categories built for use while driving] must meet all of the applicable requirements in this tier to be accepted on the Google Play Store."* All **[hard]**.

| ID | Requirement |
|---|---|
| **`PF-1`** | **POI apps "must provide meaningful functionality relevant to driving"** |
| `PC-1` | No features outside the intended car app types |
| `EP-1` | Works as described in the Play listing |
| `EP-2` | **Restores state on relaunch from the car home screen** |
| `AR-1` | UI not obstructed by system bars or display cutouts |
| **`SA-1`** | **No animated elements** — no animated graphics or video; canvas animations only while parked |
| `AD-1` | No text-based advertising beyond advertiser/product name |
| `NA-1` | No ads via notifications |
| `IN-1` | **Notifications only when relevant to the driver** |
| **`IU-1`** | **No images except**: a single static context image, nav-drawer icons, images aiding driving decisions, lane/junction guidance |
| `VI-1` | If the user must go to the phone (e.g. a permission request), the app **must display a message telling them to look at the phone only when safe** |
| `ST-1` | **No automatically scrolling text** |
| **`DR-1`** | **Buttons respond in ≤ 2 seconds** |
| **`DR-2`** | **App launches in ≤ 10 seconds** |
| **`DR-3`** | **Content loads in ≤ 10 seconds** |
| `VD-1` | Icons and colours meet contrast requirements |
| `TH-1` | Custom theming on Car App Library v1.9+ must support light and dark |
| `MR-1` | Apps drawing maps honour the host's light/dark instruction |
| `PA-1` | Purchase flows: no payment-method setup, no multi-item selection, no subscriptions (moot — no payments ever) |
| `AC-1` | Complete tasks in **5 screens or fewer** — ⚠️ **[flagged]** the *rule* is independently and clearly documented on the UX requirements page, but the *ID* may be misattributed (the heading rendered as "App doesn't crash" in one pass). **Verify by eye before quoting `AC-1` in a spec.** |

**Not applicable:** all messaging (`MF-*`/`TMF-*`), navigation (`NF-*`), calling (`CF-*`), media, video/games/browsers, IoT, weather.

- **[hard]** **`VC-1`** (Gemini + Google Assistant voice commands) applies to **Media and Navigation only — voice is *not* mandatory for a POI app**, though the POI guide demonstrates the pattern (*"Hey Google, find nearby charging stations on ExampleApp"*).
- **[hard]** **Contrast 4.5:1**, WCAG 2.0 AA normal text — the exact URL `VD-1` links to. Android Auto uses a **black background across day and night**, with **white text at 88 / 72 / 56 % opacity in day and 96 % in night**.
- **[hard]** **`DR-1` (≤2 s) / `DR-2` (≤10 s) / `DR-3` (≤10 s) are the latency gates**, and they are pass/fail on review. **[inferred]** Over a Rwandan mobile link a cold network fetch will not reliably clear them — which, together with CarPlay's locked-phone rule, is why the car surface renders from an **on-device cache** with `changedSince(cursor)` refreshing behind it. **No car screen may be designed with a loading state as its normal first paint.**

**On login and "usable without the phone"** — **[hard]**: Android has **no** requirement that the app be fully usable without the phone. `VI-1` explicitly contemplates the phone being needed and demands a safety message, and on Android Auto the **runtime-permission dialog appears on the phone**. **CarPlay's rule is stricter** (*"All CarPlay flows must be possible without interacting with iPhone"*), so **build to Apple's**.

**Reviewer access** — **[hard]**: *"If your app is not available in the United States, you must permit users to use a mock GPS location app"* so the reviewer can test navigation and POI features. **A Rwanda-only directory reviewed from the US shows an empty screen unless mock locations are supported. This must be built** — and the same problem applies to the CarPlay reviewer, for whom Apple states nothing equivalent, so a demo/mock-origin path is needed on both. This is why `stationsNear` takes an **arbitrary origin** and never a hardcoded "device location".

## B11. `ACTION_NAVIGATE` hand-off mechanics

- **[hard]** Mechanism is **`CarContext.startCarApp(Intent)`**. From the AndroidX javadoc: *"**An Intent to navigate.** The action must be `ACTION_NAVIGATE`. The data URI scheme must be either a latitude,longitude pair, or a `+` separated string query as follows: 1) `"geo:12.345,14.8767"` for a latitude, longitude pair. 2) `"geo:0,0?q=123+Main+St,+Seattle,+WA+98101"` for an address. 3) `"geo:0,0?q=a+place+name"` for a place to search for."*
- **[hard]** **`ACTION_NAVIGATE = "androidx.car.app.action.NAVIGATE"`.**
- **[hard]** **Throws `SecurityException` if you name another app's component explicitly.**
- **[hard]** Full grammar: scheme `geo`; parameters `q`, `intent=` (`navigation` | `add_a_stop` | `directions`), `mode=` (`d` drive, `w` walk, `b` bicycle, `l` two-wheeler, `r` transit, `x` taxi), `avoid=` (`f` / `h` / `t`).
- **[hard]** **It does not require the navigation category.** The navigation category is for *receivers*: `NF-6` obliges navigation apps to **handle** navigation requests from other apps.
- **[hard]** Positively endorsed: **"POI apps SHOULD provide a way to launch a navigation app to the POI"** (UX requirements page).
- **[hard]** **You cannot target Google Maps by name.** The recipient is the **default navigation app = the last navigation app the user launched**.
- **[inferred / UNKNOWN]** The chain "nav apps must handle `ACTION_NAVIGATE` (`NF-6`) + host routes to the default nav app" is strong, but **no Google page names Google Maps as a guaranteed receiver**. Must be verified on hardware.
- **[hard]** Consequently the model needs **only a destination coordinate and a display name** — no route, maneuver, ETA or polyline entity, on either platform.

## B12. Vehicle EV APIs — they describe the car, never the station

- **[hard]** **None of `androidx.car.app.hardware.info` describes charging stations.** Station data is entirely EV Guide's own.
- **[hard]** `EnergyLevel` (`@RequiresCarApi(3)`) — `getBatteryPercent()`, `getRangeRemainingMeters()`, `getEnergyIsLow()`. The genuinely useful one: rank stations by reachability.
- **[hard]** `EvStatus` (`@ExperimentalCarApi`) — `getEvChargePortOpen()`, `getEvChargePortConnected()`.
- **[hard]** `EnergyProfile.getEvConnectorTypes()` (`@RequiresCarApi(3)`) — **what the car can plug into**: `UNKNOWN=0, J1772=1, MENNEKES=2, CHADEMO=3, COMBO_1=4, COMBO_2=5, TESLA_ROADSTER=6, TESLA_HPWC=7, TESLA_SUPERCHARGER=8, GBT=9, GBT_DC=10, SCAME=11, OTHER=101`.
- **[hard]** **Every field returns a `CarValue` that can be `STATUS_UNIMPLEMENTED`.** On Android Auto — a phone projecting to an arbitrary head unit — **expect these unavailable most of the time. The app must work fully without them.**
- **[hard]** A second AAOS enumeration, `android.car.hardware.property.EvChargingConnectorType`, uses **the same names with different integers** (CHAdeMO is 3 in `EnergyProfile` but 4 there; CCS1 is 4 vs 5) and renames `TESLA_HPWC`/`TESLA_SUPERCHARGER` to `SAE_J3400_AC`/`SAE_J3400_DC`. **Never persist a platform integer** — persist the app's string enum and map at the edge.

> **"Free for me" on the car screen [hard + inferred]:** the connector filter can only be seeded from `EnergyProfile.getEvConnectorTypes()`, which is **unavailable most of the time on Android Auto and has no CarPlay equivalent at all** for a charging app. **Design the car screens so the driver's connector is never assumed.** Availability on a car row is the *aggregate* per station; per-connector state exists as a filter dimension in the model, not as a display on either car surface.

---

# PART C — The cross-platform envelope (design once to the tighter of each pair)

| Requirement | CarPlay | Android Auto | **Design to** |
|---|---|---|---|
| "Not just a list" | *"your app can't just be a list of EV chargers"* | `PF-1` *"must provide meaningful functionality relevant to driving"* | Both. Whatever satisfies Apple satisfies Google. |
| Template permission | entitlement gates templates; **runtime exception** | category gates templates | Never touch a forbidden template |
| Turn-by-turn boundary | `carplay-maps` required | `NAVIGATION` category required | Hand off, never guide |
| Directions hand-off | Developer Guide p.29, sanctioned | UX req: POI apps *SHOULD* | Hand-off is first-class on both |
| Result-set size | **12** POIs; lists cut to 12 | **6** place-list floor | **Design for 6, cap at 12** |
| Text slots per row | `text` + `detailText` | 2 lines, truncated while driving | **Two slots. One of them is distance on Android.** |
| String lengths | `titleVariants` where available; plain `String` on rows/POI/info | `CarText.addVariant`; 120-char glanceability guidance | **Author short forms; never rely on truncation** |
| Hierarchy depth | **5 templates** incl. root | **5 templates** per task | **≤5, aim for 2–3; ≤3 taps to a common task** |
| Animation | *"CarPlay doesn't support animated images"* | `SA-1` no animated elements | **Nothing moves** |
| Host-controlled limits | `maximumItemCount`, `CPSessionConfiguration` | `ConstraintManager.getContentLimit` | **Query at runtime, render the floor** |
| Phone-free operation | **required** (guideline 3) | not required (`VI-1` mitigates) | **Apple's rule — no flow may require the phone** |
| Platform can revoke | entitlement is account-level | Addendum kill switch (*"Google may block any Products… at any time for any reason"*) | Nothing may be load-bearing on the car surface |

**The four rules that flow from all of the above and constrain every screen** (settled, and consistent with `docs/domain-model.md`):

1. **Availability never appears in a row title** — a title change costs an Android template step; a stale green is impossible by construction because the aggregate decays.
2. **Rate never appears on a row** — two slots, one spent on distance. Rate is a detail-screen field with its own freshness and its own `Unknown`.
3. **Unknown is a complete listing, not an error state** — it is the normal case, and there is no animated or alarming affordance available to render it as anything else (`SA-1`, no CarPlay animation).
4. **Freshness rides alongside availability as a separate axis**, in the second text slot or an Information item — never folded into the state.

---

# PART D — UNKNOWN / vehicle-dependent — must be read at runtime

Nothing in this list has a design-time value. Every layout must render correctly at the documented floor and degrade silently above it.

**CarPlay**

| Value | API | Documented? |
|---|---|---|
| Max list items across all sections | `CPListTemplate.maximumItemCount` | **No constant.** Guide says *"some cars dynamically limit lists to 12"* — treat 12 as the working ceiling |
| Max list sections | `CPListTemplate.maximumSectionCount` | **No constant** |
| Max tabs | `CPTabBarTemplate.maximumTabCount` | 5 stated, but Apple says *"This may change in the future so avoid relying on these fixed values"* |
| Max alert actions | `CPAlertTemplate.maximumActionCount` | **No constant** |
| POI pin size | `CPPointOfInterest.pinImageSize` | Property documented, **value not** |
| Selected POI pin size | `CPPointOfInterest.selectedPinImageSize` | Property documented, **value not** |
| List image size | `CPListItem.maximumImageSize` | **No constant** |
| Screen resolution / aspect / scale | `interfaceController.carTraitCollection` | Varies per vehicle by design |
| Keyboard availability | `CPSessionConfiguration.limitedUserInterfaces` contains `.keyboard` | *"In many cars the keyboard is not available at all while driving"* |
| List-length reduction | `limitedUserInterfaces` contains `.lists` | iOS reduces list length automatically, app or no app |
| Light/dark ambient state | `CPSessionConfiguration.contentStyle` | Per ambient light |
| **`CPInformationTemplate` item cap** | **none exists** | **Not documented, and not queryable — Apple says only "a limited number"** |

**Android Auto**

| Value | API | Floor to design against |
|---|---|---|
| Place-list rows | `ConstraintManager.getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST)` | **6** |
| List rows | `…(CONTENT_LIMIT_TYPE_LIST)` | **6** |
| Grid items | `…(CONTENT_LIMIT_TYPE_GRID)` | **6** |
| Pane rows | `…(CONTENT_LIMIT_TYPE_PANE)` | **4** |
| Adaptive task limits (relaxed refresh) | `ConstraintManager.isAppDrivenRefreshEnabled()` (`@RequiresCarApi(6)`) | **Assume `false`** — returns `false` on host-call failure, regional/OEM-dependent, unavailable on JAMA-affiliated vehicles |
| Tab count | Car API level | **2–4** at API ≤8, up to 5 at API 9 |
| Template throttle interval | `Screen.onGetTemplate()` | **No number published** |
| Car EV data (battery %, range, connector types) | `EnergyLevel`, `EvStatus`, `EnergyProfile` | **Assume `STATUS_UNIMPLEMENTED`** |
| Which app receives `ACTION_NAVIGATE` | default nav app = last nav app launched | **Cannot be targeted or predicted** |

---

# PART E — Everything marked [inferred], collected

Do not present any of these to a platform reviewer as a rule, and do not let any of them harden into a spec number without a note.

1. **The 60 s / 10 s CarPlay refresh floors.** Apple's text is in the **driving-task** section (p.5) and is not literally binding on a charging app. Applying it here is the research author's inference. It remains the only number Apple gives for the POI template.
2. **`NSFileProtectionCompleteUntilFirstUserAuthentication` + `kSecAttrAccessibleAfterFirstUnlock`** as the cache/credential classes. Apple documents what is *unreadable* while locked, not what to use instead.
3. **The `CPInformationTemplate` "put the important pairs first" strategy** — a hedge against an undocumented, unqueryable cap.
4. **Fixing the row set for a screen's lifetime on `PlaceListMapTemplate`** as the mitigation for the quota. The refresh rules are documented; this particular mitigation is a derivation.
5. **Which functions satisfy "meaningful functionality relevant to driving" / `PF-1`.** Undefined by both vendors. Live per-bay availability, the directions hand-off, bay-watch and report-a-charger are *candidates*, not a safe harbour. **This is the largest open risk on the whole car effort, and it is a judgement call, not a research gap.**
6. **The bay-watch notification copy shape** (short, names the station, deep-links to detail). `IN-1`, `NA-1` and Apple's "sparingly / reserved for important tasks" are documented; the specific shape is a derivation.
7. **That a signed-out car screen should silently omit account-gated affordances** rather than explain them. Apple's guideline 2 forbids *instructing* phone manipulation; silent omission is the derived safe reading.
8. **Three name fields** (`markerLabel` ≤3 authored, `nameShort`, `name`). Only the 3-char limit is hard; the three-field decomposition is derived from it plus the two-slot row.

**Open questions that must be settled on hardware before the design is final** (from the research's own gap list):

- **Whether `comgooglemaps://` can be launched onto the CarPlay screen** via the scene's `open(_:options:completionHandler:)`. Undocumented by both vendors. Apple Maps is the guaranteed path but **cannot navigate in Rwanda**, so this hop is on the critical path for the directions story.
- **Whether Google Maps is a guaranteed `ACTION_NAVIGATE` receiver** on Android Auto. Strongly implied by `NF-6` + default-nav-app routing; documented by nobody.
- **The `AC-1` identifier** (the 5-screen rule is solid; the ID may be misattributed).
- **The CarPlay Human Interface Guidelines** are a JavaScript SPA and were never read. The Developer Guide is the binding document and *was* read in full, so the gap is **design nuance, not requirements** — but a designer looking for Apple's own layout advice will not find it reflected here.
- **Whether CarPlay and Android Auto function at all on Rwandan-region devices.** Rwanda is absent from both vendors' country lists (CarPlay's 37-country list is byte-identical to Apple's Siri list; Android Auto's ~46-country list has South Africa as its only African entry). Distribution is **not** restricted on either platform, but device gating is undocumented on both. This does not change any constraint above — it changes who ever sees the screens.