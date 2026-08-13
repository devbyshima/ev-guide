# 04 — What CarPlay and Android Auto actually require of an EV-charging app

Research for ticket
[`04-carplay-android-auto-requirements`](../issues/04-carplay-android-auto-requirements.md).
Researched 2026-08-13.

## Sourcing note

The governing document for CarPlay is the **CarPlay Developer Guide, June 2026
revision** (`2026-06-08`), a PDF Apple publishes at
<https://developer.apple.com/carplay/documentation/CarPlay-App-Programming-Guide.pdf>.
It is the only place Apple publishes the category→template matrix, the template
depth limits, and the per-category review guidelines. Everything cited as
"Developer Guide" below is from that PDF; page numbers are the PDF's own.

Apple's API reference pages are cited by their `developer.apple.com/documentation/...`
URLs. Those pages are JavaScript-rendered; the underlying content was read from
Apple's own JSON endpoints (`developer.apple.com/tutorials/data/<path>.json`),
which is what the documentation site itself fetches.

Anything not from Apple, Google or `developer.android.com` is **explicitly
labelled** as secondary/anecdotal.

---

# Part 1 — Apple CarPlay

## 1.1 The category list, and where an EV-charging finder sits

Apple supports exactly these CarPlay app categories (Developer Guide p.3,
"CarPlay apps"):

1. Audio apps
2. Communication apps (SiriKit Messaging or VoIP Calling)
3. Driving task apps
4. **EV charging apps**
5. Fueling apps
6. Navigation apps (route guidance with turn-by-turn directions)
7. Parking apps
8. Public safety apps
9. Quick food ordering apps
10. Video apps
11. Voice-based conversational apps

Plus a twelfth, non-app surface: **Widgets and Live Activities**, which
explicitly *"does not need to be a CarPlay app"* (Developer Guide p.3, p.9,
p.10). The marketing page lists the same set
(<https://developer.apple.com/carplay/>). Automaker apps are a separate
category the guide does not cover (Developer Guide p.3, Note).

There is no "directory", "POI", "map" or "utility" category. **EV charging is
the only category EV Guide fits**, and the fit is unambiguous: it is the
category Apple created for exactly this app shape. The nearest neighbours are
ruled out by their own guidelines:

- *Driving task apps* are explicitly forbidden from being location finders:
  *"Do not create POI (point of interest) apps that are focused on finding
  locations on a map. Driving tasks apps must be primarily designed to
  accomplish tasks and are not intended to be location finders (for example,
  store finders)."* (Developer Guide p.5, driving-task guideline 6.)
- *Navigation apps* require turn-by-turn directions (§1.7 below).

**Combination is allowed in one direction that matters:** *"CarPlay EV charging
app and CarPlay fueling app entitlements may be combined in a single app."*
(Developer Guide p.13, footnote \*2.) No other combination is permitted except
audio+video.

## 1.2 The entitlement — confirmed

`com.apple.developer.carplay-charging` is correct. Full current table
(Developer Guide p.13):

| Entitlement | Key | Minimum iOS |
|---|---|---|
| CarPlay audio app \*1 | `com.apple.developer.carplay-audio` | iOS 14 |
| CarPlay communication app | `com.apple.developer.carplay-communication` | iOS 14 |
| CarPlay driving task app | `com.apple.developer.carplay-driving-task` | iOS 16 |
| **CarPlay EV charging app \*2** | **`com.apple.developer.carplay-charging`** | **iOS 14** |
| CarPlay fueling app \*2 | `com.apple.developer.carplay-fueling` | iOS 16 |
| CarPlay navigation app | `com.apple.developer.carplay-maps` | iOS 12 |
| CarPlay parking app | `com.apple.developer.carplay-parking` | iOS 14 |
| CarPlay public safety app | `com.apple.developer.carplay-public-safety` | iOS 14 |
| CarPlay quick food ordering app | `com.apple.developer.carplay-quick-ordering` | iOS 14 |
| CarPlay video app \*1 | `com.apple.developer.carplay-video` | iOS 27 |
| CarPlay voice-based conversational app | `com.apple.developer.carplay-voice-based-conversation` | iOS 26.4 |

Note the entitlement key for navigation is **`carplay-maps`**, not
`carplay-navigation`. The ticket's working name `com.apple.developer.carplay-navigation`
does not exist; the hard entitlement EV Guide wants to avoid is
`com.apple.developer.carplay-maps`.

Apple's HTML page *Requesting CarPlay Entitlements*
(<https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements>)
carries a **shorter, stale table** listing only audio, communication, EV
charging, navigation, parking and quick food ordering. Where the two disagree,
the June 2026 PDF is newer and more complete. Both agree on
`com.apple.developer.carplay-charging` = EV Charging.

## 1.3 The entitlement request process, end to end

**Where you apply.** *"To request a CarPlay app entitlement, go to
http://developer.apple.com/carplay and provide information about your app,
including the category of entitlement that you are requesting. You also need to
agree to the CarPlay Entitlement Addendum."* (Developer Guide p.12.) The
"Request CarPlay app entitlement" link on <https://developer.apple.com/carplay/>
resolves to `https://developer.apple.com/contact/request/carplay/`, which is
**behind Apple ID sign-in** (verified: it 302s to `idmsa.apple.com`). The form
contents therefore cannot be read without an account.

**What Apple asks for.** Apple does not publish the form's fields. From the
Developer Guide the minimum is: app identity, the **category** of entitlement
requested, and agreement to the **CarPlay Entitlement Addendum**. *Secondary
source, unverified against the live form:* a third-party how-to says the form
asks for app name and bundle ID, the category, and an explanation of *"why the
app is useful and safe to use while driving"*
(<https://newly.app/how-to/carplay-entitlement>) — treat as indicative only.

**What Apple does with it.** *"Apple will review your request. If your app
meets the criteria for the CarPlay app category, Apple will assign a CarPlay app
entitlement to your Apple Developer account and notify you."* (Developer Guide
p.12.) The entitlement is granted as a **managed capability on the developer
account**, not per-build
(<https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements>).

**After approval**, six steps (Developer Guide p.12;
<https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements>):

1. Developer Account → Certificates, IDs & Profiles → Identifiers → your App ID.
2. Additional Capabilities tab → enable the CarPlay capability → Save.
3. Create a **new provisioning profile** for that App ID.
4. Import into Xcode; turn **off** "Automatically manage signing".
5. Add an `Entitlements.plist` with `<key>com.apple.developer.carplay-charging</key><true/>`.
6. Point `Code Signing Entitlements` at that file.

**Approval timeline: Apple publishes none.** There is no documented SLA
anywhere in the guide or on the developer site. *Developer-reported, anecdotal
(Apple Developer Forums — Apple-hosted but not Apple-authored, and no Apple
staff replies appear in any of these threads):*

- ~4 weeks to approval, and a separate report of 2–3 weeks with no response at
  all on two applications (<https://developer.apple.com/forums/thread/784932>).
- One request submitted 19 June 2023 with no update at all as of August 2023
  (<https://developer.apple.com/forums/thread/736111>).
- Recurring complaint across threads: Apple often sends **no rejection**, only
  silence, so developers cannot tell a "no" from a "not yet"
  (<https://developer.apple.com/forums/thread/739023>,
  <https://developer.apple.com/forums/thread/781225>).

**Planning consequence:** the entitlement is an unbounded-latency, no-feedback
external dependency. The map is right that it starts early. Budget for
"weeks to months, possibly silent", and design so that a `carplay-charging`
denial costs EV Guide nothing but the CarPlay target.

**One-way door.** *"Once a CarPlay app entitlement is added to your app, your
app icon will appear on the CarPlay home screen. You cannot selectively show or
hide CarPlay for certain people. Only publish your app with CarPlay support
when you are ready for everyone to see it."* (Developer Guide p.12.) There is no
staged rollout, no remote kill switch, no per-user gate. Shipping the
entitlement ships CarPlay to 100% of users at once.

**Testing before/without a car.** CarPlay Simulator is a Mac app in *Additional
Tools for Xcode* (Hardware folder), also reachable via Device Hub; connect an
iPhone by USB and CarPlay starts as if it were a car (Developer Guide p.8). A
provisioning profile that supports CarPlay is required for Simulator too
(Developer Guide p.12). Aftermarket head units work; pick a **wireless** one so
the phone can be cabled to Xcode simultaneously (Developer Guide p.8).

## 1.4 Which templates an EV charging app may use

From the category→template matrix (Developer Guide p.14). Note the matrix
groups **EV charging, fueling and parking into one column** — they get an
identical template set.

| Template | Class | Allowed for EV charging? |
|---|---|---|
| Action sheet | `CPActionSheetTemplate` | **Yes** |
| Alert | `CPAlertTemplate` | **Yes** |
| Grid | `CPGridTemplate` | **Yes** |
| List | `CPListTemplate` | **Yes** |
| Tab bar | `CPTabBarTemplate` | **Yes** |
| Information | `CPInformationTemplate` | **Yes** |
| Point of interest | `CPPointOfInterestTemplate` | **Yes** |
| Search | `CPSearchTemplate` | **Yes, iOS 27 or later** (footnote \*5) |
| Voice control | `CPVoiceControlTemplate` | **Yes, iOS 27 or later** (footnote \*5) |
| Contact | `CPContactTemplate` | **No** |
| Now playing | `CPNowPlayingTemplate` | **No** |
| **Map** | **`CPMapTemplate`** | **No — navigation only** |

*"Each CarPlay app category supports specific templates and this is governed by
the app entitlement. **Attempting to use an unsupported template triggers an
exception at runtime.**"* (Developer Guide p.14.) This is enforced by the
framework, not just by review.

**Navigation-stack depth: 5 templates, including the root.** *"Audio,
communication, EV charging, parking, public safety, and navigation apps are
limited to a depth of 5 templates… These include the root template."*
(Developer Guide p.14.) Corroborated in the API reference: *"The framework
restricts all other categories of apps to five levels"*
(<https://developer.apple.com/documentation/carplay/cplisttemplate>).

**Notifications are permitted.** *"Notifications are supported in CarPlay
communication, EV Charging, parking, and public safety apps."* (Developer Guide
p.27.) Requires `UNAuthorizationOptions.carPlay` at authorization time **and**
a notification category created with the `allowInCarPlay` option; users can
switch CarPlay notifications off per-app in Settings, so the feature must
degrade gracefully. *"Notifications should be used sparingly in CarPlay and
must be reserved for important tasks required while driving."* *"In general,
notifications are not read aloud in CarPlay."* (Developer Guide p.27.)

This is the sanctioned route for the map's "tell me when a bay frees up" idea —
but only if the notification is genuinely a driving-time need.

## 1.5 Hard limits, per template

### `CPPointOfInterestTemplate` — the centrepiece screen

- **Maximum 12 points of interest**, stated twice: *"an overlay containing a
  list of up to 12 locations with customizable pin images"* (Developer Guide
  p.23) and *"`CPPointOfInterestTemplate` displays a maximum of twelve points
  of interest"*
  (<https://developer.apple.com/documentation/carplay/cppointofinterest>).
- The map is **provided by MapKit** — the app does not draw it (Developer Guide
  p.23).
- The template *"manages clustering points of interest, selecting a point of
  interest, and zooming and panning the map"* itself
  (<https://developer.apple.com/documentation/carplay/cppointofinteresttemplate>).
- A delegate (`CPPointOfInterestTemplateDelegate`) is **mandatory**; it fires on
  visible-region change and the app re-supplies the 12 via
  `setPointsOfInterest(_:selectedIndex:)`. The app is therefore responsible for
  *re-ranking to the visible viewport on every pan/zoom* (same URL).
- *"The list of locations should be limited to those that are most relevant or
  nearby."* (Developer Guide p.23.)

Each `CPPointOfInterest` carries exactly this payload
(<https://developer.apple.com/documentation/carplay/cppointofinterest/init(location:title:subtitle:summary:detailtitle:detailsubtitle:detailsummary:pinimage:)>):

| Field | Type | Shown where |
|---|---|---|
| `location` | `MKMapItem` (**required**) | map annotation |
| `title` | `String` (**required**) | scrollable picker |
| `subtitle` | `String?` | scrollable picker |
| `summary` | `String?` | scrollable picker |
| `detailTitle` | `String?` | detail card |
| `detailSubtitle` | `String?` | detail card |
| `detailSummary` | `String?` | detail card |
| `pinImage` | `UIImage?` | map annotation |
| `selectedPinImage` | `UIImage?` (iOS 16+) | map annotation when selected |
| `primaryButton` | `CPTextButton?` | detail card action |
| `secondaryButton` | `CPTextButton?` | detail card action |

**Exactly two action buttons on the detail card.** There is no third.

Pin sizes are runtime class properties `CPPointOfInterest.pinImageSize` and
`.selectedPinImageSize` — Apple documents the properties but **not their
values**, so they must be read at runtime. Images must be display-ready, sized
using `interfaceController.carTraitCollection` scale, with light/dark variants
via an asset catalog or `UIImageAsset`. *"CarPlay doesn't support animated
images. If you provide an animated image, CarPlay uses only the first image in
the animation sequence."* (same init URL.)

### `CPListTemplate`

- *"Some cars dynamically limit lists to 12 list items. You can check for the
  maximum number of list items, but you always need to be prepared to handle
  the case where only 12 list items are shown."* (Developer Guide p.18.)
- Runtime limits, both **vehicle-dependent**:
  `CPListTemplate.maximumItemCount` (max items *across all sections*) and
  `.maximumSectionCount`
  (<https://developer.apple.com/documentation/carplay/cplisttemplate/maximumitemcount>,
  <https://developer.apple.com/documentation/carplay/cplisttemplate/maximumsectioncount>).
  Neither has a documented constant — they must be queried.
- `CPListItem` fields: `text`, `detailText`, `image`, `accessoryImage`,
  `accessoryType`, plus progress/playing indicators
  (<https://developer.apple.com/documentation/carplay/cplistitem>). So **two
  text slots per row**, not three.
- *"CarPlay doesn't support custom list item types. Instead, use the `userInfo`
  property to attach a value to the list item"* (same URL) — the standard hook
  for carrying a station ID back to the selection handler.
- List image sizes come from `CPListItem.maximumImageSize` at runtime
  (Developer Guide p.28).

### `CPInformationTemplate`

- Abstract, verbatim: *"A template that provides information for a point of
  interest, food order, parking location, or **charging location**."*
  (<https://developer.apple.com/documentation/carplay/cpinformationtemplate>) —
  Apple names charging as an intended use.
- *"An information template displays a list of items, and **up to three actions**
  the user can perform."* (same URL.)
- Items are `CPInformationItem`, a **`title` + `detail` pair** only
  (<https://developer.apple.com/documentation/carplay/cpinformationitem>).
- Two layouts: `.leading` and `.twoColumn`
  (<https://developer.apple.com/documentation/carplay/cpinformationtemplatelayout>).
- **Item count is not documented as a number.** The guide only says: *"An
  information screen is a specific style of list that presents a **limited
  number** of static labels… Since the number of labels is limited, show only
  the most important summary information needed to complete a task."*
  (Developer Guide p.17.) The guide's own worked example for this template is
  *"an EV charging app may display information about a charging station such as
  availability"* (Developer Guide p.17). This is the station-detail screen.
- Actions are `CPTextButton` (title + `CPTextButtonStyle`)
  (<https://developer.apple.com/documentation/carplay/cptextbutton>).

### `CPGridTemplate`

- *"A grid is a specific style of menu that presents **up to eight** choices
  represented by an icon and a title."* (Developer Guide p.16.)
- *"When there are more than eight buttons in the array, the template displays
  only the first eight. When there are more than four buttons, the template
  balances the display of the buttons between two rows."*
  (<https://developer.apple.com/documentation/carplay/cpgridtemplate>) — silent
  truncation, no error.
- `CPGridButton` takes **`titleVariants: [String]`**, not a single title
  (<https://developer.apple.com/documentation/carplay/cpgridbutton>).

### `CPTabBarTemplate`

- *"the tab bar allows up to 4 tabs for audio apps and **up to 5 tabs for all
  other app categories**. This may change in the future so avoid relying on
  these fixed values."* — query `maximumTabCount` (Developer Guide p.25;
  <https://developer.apple.com/documentation/carplay/cptabbartemplate>).
- Container for **Grid, Information, List and Point of interest** templates
  only (Developer Guide p.25).
- Must be set with `setRootTemplate`; *"You can't add a tab bar template to an
  existing navigation hierarchy, or present one modally."* Each tab is its own
  navigation hierarchy (same URL).

### `CPAlertTemplate` / `CPActionSheetTemplate`

- Alert = `titleVariants` + actions; max actions from
  `CPAlertTemplate.maximumActionCount` (runtime, value undocumented)
  (<https://developer.apple.com/documentation/carplay/cpalerttemplate/maximumactioncount>).
- Action sheet = title + message + actions, *"two or more choices"* (Developer
  Guide p.15).
- Both are **modal** — `presentTemplate`, not `pushTemplate`.

### `CPSearchTemplate` (iOS 27+ for charging apps)

- *"Cars may limit when the keyboard can be shown. **In many cars the keyboard
  is not available at all while driving.** The search template should be an
  alternative option and **never the primary way** to accomplish tasks in your
  app."* (Developer Guide p.24.)
- Search results are an array of `CPListItem` (Developer Guide p.24).

### Vehicle-imposed runtime limits — the mechanism

`CPSessionConfiguration` exposes `limitedUserInterfaces`, a
`CPLimitableUserInterface` option set with exactly two members: **`.keyboard`**
and **`.lists`**
(<https://developer.apple.com/documentation/carplay/cpsessionconfiguration>,
<https://developer.apple.com/documentation/carplay/cplimitableuserinterface>).
*"iOS automatically disables the keyboard and reduces list lengths when the car
indicates it should do so."* — the reduction happens whether the app handles it
or not; the delegate callback exists only so the app can adjust *other* UI
(Developer Guide p.50). It also exposes `contentStyle` (light/dark per ambient
light).

### Strings: the variants mechanism

CarPlay's answer to "how long may a string be" is **not a character limit — it
is multiple strings**. `titleVariants` on `CPGridButton` and `CPAlertTemplate`,
`emptyViewTitleVariants`/`emptyViewSubtitleVariants` on `CPListTemplate`,
`instructionVariants` on navigation maneuvers:

> *"When the system displays the button, it selects the title that best fits the
> available screen space, so arrange the titles from most to least preferred…
> localize each title… be sure to include at least one title in the array."*
> (<https://developer.apple.com/documentation/carplay/cpgridbutton/titlevariants>,
> identical wording at
> <https://developer.apple.com/documentation/carplay/cpalerttemplate/titlevariants>)

Apple publishes **no character counts anywhere** in the guide or reference. The
screen is variable — resolution, aspect ratio and scale differ per vehicle
(Developer Guide p.28, p.34) — so a fixed limit could not exist. `CPListItem`,
`CPPointOfInterest` and `CPInformationItem` take **plain `String`, not
variants**, so their text is simply truncated by the system with no control.

### Image assets

Maximum sizes (Developer Guide p.28):

| Element | Points | 3× px | 2× px |
|---|---|---|---|
| Contact action button | 50×50 | 150×150 | 100×100 |
| Grid icon | 40×40 | 120×120 | 80×80 |
| Now playing action button | 20×20 | 60×60 | 40×40 |
| Tab bar icon | 24×24 | 72×72 | 48×48 |
| Voice control image | 150×150 | 450×450 | 300×300 |

Of these only **grid icon (40×40pt)** and **tab bar icon (24×24pt)** apply to a
charging app. List and POI images are sized at runtime
(`CPListItem.maximumImageSize`, `CPPointOfInterest.pinImageSize`). All assets
need 2×/3× and light/dark variants; SF Symbols are encouraged for tab icons
(Developer Guide p.28).

### Refresh cadence

The only published refresh caps sit in the **driving-task** section (Developer
Guide p.5):

- *"Do not periodically refresh data items in the CarPlay UI more than once
  every 10 seconds (for example, no real-time engine data)."*
- *"Do not periodically refresh points of interest in the POI template more than
  once every 60 seconds."*

These are written for driving-task apps, so they are not *literally* binding on
a charging app — but they are the only numbers Apple gives for the POI template
and they express Apple's view of acceptable churn on a car screen. **Treat
60 s as the floor for background POI refresh and 10 s for any other periodic
update.** (This inference is mine, not Apple's text.)

Note the separate, *event-driven* refresh path: the POI delegate fires on every
map region change and the app must respond then. Region-change refresh is not
"periodic" and is not capped.

### Locked-phone data access — a real constraint

*"CarPlay is frequently used while iPhone is in a locked state."* While locked
the app **cannot** read (Developer Guide p.29):

- Files saved with `NSFileProtectionComplete` or
  `NSFileProtectionCompleteUnlessOpen`.
- Keychain items with `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`,
  `kSecAttrAccessibleWhenUnlocked`, or `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

The same point is made about widgets: *"if your widget relies on data
protection classes A or B it will generally be non-functional in CarPlay because
most people use CarPlay while their iPhone is locked"* (Developer Guide p.4).

## 1.6 Review criteria for CarPlay apps

**The general App Store Review Guidelines contain no CarPlay section.** A full
text scan of <https://developer.apple.com/app-store/review/guidelines/> finds
CarPlay mentioned exactly once, in the introduction: *"Some features and
technologies that are not generally available to developers may be offered as
an entitlement for limited use cases. For example, we offer entitlements for
CarPlay Audio, HyperVisor, and Privileged File Operations."* There is no
driver-distraction guideline in the ASRG.

Apple confirms the criteria live elsewhere: *"CarPlay-enabled apps are subject
to an **additional set of App Store Review guidelines**. For more information,
see the CarPlay-App-Programming-Guide.pdf."*
(<https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements>)
and *"CarPlay apps must meet the basic requirements defined in the **CarPlay
Entitlement Addendum**, and must follow the Guidelines."* (Developer Guide
p.11). The Addendum is only shown inside the signed-in request flow and could
not be read.

**Guidelines for all CarPlay apps** (Developer Guide p.4, verbatim numbering):

1. *"Your CarPlay app must be designed primarily to provide the specified
   feature."*
2. *"Never instruct people to pick up their iPhone to perform a task. If there
   is an error condition, such as a required log in, you can let them know about
   the condition so they can take action when safe. However, alerts or messages
   must not include wording that asks people to manipulate their iPhone."*
3. *"All CarPlay flows must be possible without interacting with iPhone."*
4. *"All CarPlay flows must be meaningful to use while driving. Don't include
   features in CarPlay that aren't related to the primary task (e.g. unrelated
   settings, maintenance features, etc.)."*
5. *"No gaming or social networking."*
6. *"Never show the content of messages, texts, or emails on the CarPlay
   screen."*
7. *"Use templates for their intended purpose, and only populate templates with
   the specified information types."*

**Additional guidelines for CarPlay EV charging apps** (Developer Guide p.5,
verbatim — there are only two, and both bite):

1. *"EV charging apps must provide meaningful functionality relevant to driving
   (for example, **your app can't just be a list of EV chargers**)."*
2. *"When showing locations on a map, **do not expose locations other than EV
   chargers**."*

### The single largest CarPlay risk to EV Guide

Guideline 1 is aimed squarely at what EV Guide is. The map describes EV Guide
as *"a directory of EV charging stations in Rwanda"* where drivers *"find a
station, see its rate, connector types and bay count, learn whether a bay is
free, and get directions"* — and "a list of EV chargers" is Apple's own example
of what is **not** sufficient.

Apple never defines "meaningful functionality relevant to driving". The
shipping CarPlay charging apps clear the bar with session control and payment
(start/stop a charge, pay, monitor session state) — both of which EV Guide has
ruled out permanently ("No payment anywhere", map §Out of scope). *This
paragraph is my assessment, not Apple's text.* What EV Guide can still put on
the CarPlay screen that is arguably "functionality" rather than "a list":

- **Live per-bay availability**, refreshed against the viewport — the thing a
  driver actually needs mid-drive and cannot get from Maps.
- **Directions hand-off** to a navigation app (§1.8) — sanctioned, and turns
  browsing into an action.
- **"Notify me when a bay frees up"** via CarPlay notifications (§1.4) — an
  action taken in the car, resolved in the car.
- **Report a broken/occupied charger** — a write action, done while driving,
  that improves the shared dataset.

None of these is documented as sufficient. **Recommendation:** do not treat the
charging entitlement as a formality. Decide, before applying, which two or
three of these are in the CarPlay build, and describe *those* in the request —
not the directory. And note guideline 2 forecloses any "show me petrol stations
/ parking too" expansion on the CarPlay map unless the fueling entitlement is
also held.

## 1.7 The boundary: `carplay-charging` vs `carplay-maps`

This is the decision-critical question, and Apple's line is unusually crisp.

**The trigger is turn-by-turn route guidance, and nothing else.** Apple's own
one-line definition of the navigation category is *"Navigation apps (route
guidance with turn-by-turn directions)"* (Developer Guide p.3), and the first
navigation guideline is *"Navigation apps must provide turn-by-turn directions
with upcoming maneuvers"* (Developer Guide p.6). It is a **requirement** of the
navigation category, not merely a permission — an app that does not do
turn-by-turn cannot be a navigation app.

**What the navigation entitlement uniquely unlocks** — every one of these is
unavailable to a charging app:

| Capability | Class / mechanism | Why it's navigation-only |
|---|---|---|
| Drawing your own map | **base view** via `CPWindow` | *"Only navigation apps have access to that window, and use it for drawing map content. **All other categories of apps use the scene's interface controller exclusively** for constructing their user interfaces."* (<https://developer.apple.com/documentation/carplay/cptemplateapplicationscene>) |
| Map control overlay | `CPMapTemplate` | Matrix p.14: Map = navigation column only |
| Active route session | `CPNavigationSession`, `CPTrip`, `CPRouteChoice`, `CPManeuver`, `CPTravelEstimates` | All are `CPMapTemplate` APIs (<https://developer.apple.com/documentation/carplay/cpmaptemplate>) |
| Voice prompts for maneuvers | `AVAudioSessionModeVoicePrompt` config | Developer Guide p.51, "CarPlay navigation apps must…" |
| Dashboard + instrument-cluster maps | second CarPlay scene | Developer Guide p.34: cluster iOS 15.4, dashboard iOS 13.4 |
| Sharing destination/route/maneuvers with the vehicle | `CPManeuver`, `CPRouteDetail` | Developer Guide p.34, iOS 17.4 / 26.4 |
| Map panels | `pushPanel`/`showPanel` on `CPMapTemplate` | Developer Guide p.41, iOS 27 |
| Panning interface, map buttons, touch gestures | `CPMapTemplate` | Developer Guide p.34, p.35 |
| Recording (voice input) | exception carved out for navigation + voice apps | Developer Guide p.29 |

**What tips an app over the line, concretely.** Any one of these makes the app
a navigation app and the charging entitlement insufficient:

1. Drawing your **own** map surface in CarPlay (Mapbox, Google tiles, a custom
   MapKit view). A charging app has no window to draw into — the POI template's
   map is MapKit's, rendered by the system, and the app supplies only pins.
2. Displaying a **route line, ETA, distance-to-arrival, or an upcoming
   maneuver** on the CarPlay screen.
3. Speaking **voice guidance**.
4. Any **active navigation session** the app owns and updates.

**What does *not* tip it over.** The following are all inside the charging
entitlement:

- Showing station pins on the MapKit-provided POI map, with clustering, pan and
  zoom — the template does all of it (§1.5).
- A detail card with two action buttons.
- An `CPInformationTemplate` station screen showing availability — Apple's own
  example (§1.5).
- Distance/bearing text computed by the app and put in `summary` or
  `detailSubtitle` — that is a string in a POI field, not route guidance.
- **Launching another app to do the navigating** (§1.8).

**The practical read for EV Guide:** the boundary is not near where EV Guide
sits. As long as CarPlay directions are a hand-off and never a route drawn or
spoken by EV Guide, `com.apple.developer.carplay-charging` is sufficient and
`carplay-maps` is not needed. The risk to manage is §1.6's "can't just be a
list", not this boundary.

Worth noting the asymmetry: navigation apps are the *only* category that gets
`CPChargingStationConnection` (connector / voltage / power, shown in a map
panel during route selection —
<https://developer.apple.com/documentation/carplay/cpchargingstationconnection>).
**Apple gives the richest EV-charging data type to navigation apps, not to
charging apps.** A charging app can express connector detail only as free text
in POI/Information fields.

## 1.8 Handing off to Apple Maps or Google Maps — yes, explicitly

The Developer Guide sanctions it in its own section, "Launching other apps in
CarPlay" (p.29), verbatim:

> *"If your app launches other apps in CarPlay, such as **to get directions** or
> make a phone call, use the `CPTemplateApplicationScene` method
> `open(_:options:completionHandler:)` to launch the other app using a URL to
> ensure it launches on the CarPlay screen."*

Three things follow:

1. **Directions hand-off is a first-class, documented CarPlay pattern**, named
   as such by Apple, requiring no navigation entitlement.
2. It must go through the **scene's** `open(_:options:completionHandler:)`
   (inherited from `UIScene` —
   <https://developer.apple.com/documentation/uikit/uiscene/open(_:options:completionhandler:)>),
   **not** `UIApplication.shared.open`. The scene form is what routes the launch
   onto the CarPlay screen rather than the phone.
3. The receiving app must itself be a CarPlay app, or it has no CarPlay screen
   to land on.

**Apple Maps.** Two mechanisms:

- URL: `http://maps.apple.com/?daddr=<destination>&dirflg=d`. *"A complete
  directions request includes the `saddr`, `daddr`, and `dirflg` parameters,
  but only the `daddr` parameter is required. If you don't specify a value for
  `saddr`, the starting point is 'here.'"* `dirflg=d` is by car
  (<https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html>).
  Note the scheme is `http`, not `maps:`.
- `MKMapItem.openInMaps(launchOptions:)` with `MKLaunchOptionsDirectionsModeKey`
  — *"the Maps app interprets that as an attempt to map from the user's current
  location to the location that the map item specifies"*
  (<https://developer.apple.com/documentation/mapkit/mkmapitem/openinmaps(launchoptions:)>).
  Caveat in Apple's own note: *"This is a blocking call and the system suspends
  interaction with your app until the Maps app finishes launching."* Prefer the
  scene `open(_:)` route for CarPlay.

**Google Maps.** `comgooglemaps://?daddr=<lat,lng>&directionsmode=driving`,
with `comgooglemaps` declared in `LSApplicationQueriesSchemes`
(<https://developers.google.com/maps/documentation/urls/ios-urlscheme>).
Google's page **says nothing about CarPlay**. Google Maps is itself a CarPlay
navigation app, so the scene-`open` route should land it on the car screen, but
**this is not documented by either vendor and must be tested on hardware.**
Treat Apple Maps as the guaranteed path and Google Maps as a nice-to-have.

Relevance to ticket 13 (directions): the CarPlay build's directions story is
necessarily hand-off. That is a *reason to prefer* hand-off on the phone too —
one directions abstraction, not two.

---

# Part 2 — Android Auto

## 2.1 Read this first: Android Auto is not available in Rwanda

Google publishes the country list at
<https://support.google.com/androidauto/answer/6348019>. It names ~47
countries. **Rwanda is not among them. South Africa is the only African country
on the list.** Google's own caveat on that page: *"Most features won't work if
you use Android Auto outside these countries."*

This is not a footnote. It means the Android Auto integration cannot be
exercised by EV Guide's users, in EV Guide's only market. See §3 below for how
this combines with the CarPlay and Apple Maps findings.

## 2.2 The category: `CHARGING` is dead, `POI` is correct

**Do not spec `androidx.car.app.category.CHARGING`.** It is deprecated:

> *"Beginning with Car App Library version 1.3, the
> `androidx.car.app.category.PARKING` and `androidx.car.app.category.CHARGING`
> car app categories are **deprecated**. Use the
> `androidx.car.app.category.POI` category instead."*
> — <https://developer.android.com/training/cars/apps/poi>

Deprecated in `1.3.0-alpha01`, 27 July 2022
(<https://developer.android.com/jetpack/androidx/releases/car-app>). Both
constants still exist in `CarAppService.java` carrying `@Deprecated`
(<https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/CarAppService.java>).

POI is explicitly scoped to *"finding points of interest such as parking spots,
**charging stations**, and gas stations"* (same POI URL). Google's structural
choice is the mirror image of Apple's: Apple gives charging its own entitlement
and forbids showing anything but chargers; Google folds charging, parking and
fuel into one POI category with no such restriction.

**Full current category list** (`CarAppService.java`, source above):

| Constant | String | Gate |
|---|---|---|
| `CATEGORY_NAVIGATION_APP` | `androidx.car.app.category.NAVIGATION` | — |
| `CATEGORY_PARKING_APP` | `androidx.car.app.category.PARKING` | **deprecated** |
| `CATEGORY_CHARGING_APP` | `androidx.car.app.category.CHARGING` | **deprecated** |
| **`CATEGORY_POI_APP`** | **`androidx.car.app.category.POI`** | — |
| `CATEGORY_IOT_APP` | `androidx.car.app.category.IOT` | `@RequiresCarApi(6)` |
| `CATEGORY_SETTINGS_APP` | `androidx.car.app.category.SETTINGS` | `@RequiresCarApi(6)` |
| `CATEGORY_MESSAGING_APP` | `androidx.car.app.category.MESSAGING` | `@ExperimentalCarApi` |
| `CATEGORY_CALLING_APP` | `androidx.car.app.category.CALLING` | `@ExperimentalCarApi` |
| `CATEGORY_WEATHER_APP` | `androidx.car.app.category.WEATHER` | `@RequiresCarApi(7)` |
| `CATEGORY_MEDIA_APP` | `androidx.car.app.category.MEDIA` | `@RequiresCarApi(8)` |
| `CATEGORY_FEATURE_CLUSTER` | `androidx.car.app.category.FEATURE_CLUSTER` | capability flag, not a category |

The Play-facing taxonomy in the quality guidelines is: Media, Media (templated),
Communication, Navigation, **Point of Interest**, IOT, Weather, Video, Games,
Browsers (<https://developer.android.com/docs/quality-guidelines/car-app-quality>).

**Manifest** (<https://developer.android.com/training/cars/apps/poi>,
<https://developer.android.com/training/cars/apps/library/set-up-project>):

```xml
<service android:name=".MyCarAppService" android:exported="true">
  <intent-filter>
    <action android:name="androidx.car.app.CarAppService" />
    <category android:name="androidx.car.app.category.POI"/>
  </intent-filter>
</service>
<meta-data android:name="androidx.car.app.minCarApiLevel" android:value="1"/>
<uses-permission android:name="androidx.car.app.MAP_TEMPLATES"/>
```

Declare `androidx.car.app.MAP_TEMPLATES`. **Do not** declare
`androidx.car.app.NAVIGATION_TEMPLATES` — navigation apps only
(<https://developer.android.com/training/cars/apps/navigation>).

**Android Auto ≠ Android Automotive OS.** Android Auto is phone-projected and
needs only `CarAppService`. AAOS is a separate build/module requiring
`android.hardware.type.automotive`, `android.software.car.templates_host`, an
`automotive_app_desc.xml` with `<uses name="template"/>`, `minSdkVersion 29`,
and a `CarAppActivity` launcher
(<https://developer.android.com/training/cars/apps/automotive-os>). **AAOS is
optional and out of scope** — it is a second artifact with its own Play track,
its own screenshots and its own review, and no Rwandan relevance.

## 2.3 Permitted templates for a POI app

From <https://developer.android.com/design/ui/cars/guides/templates/overview>:

**Available to all app types (so, to POI):** List, Grid, **Sectioned Item**
(`@RequiresCarApi(8)`), Pane, Message, Long Message, Search, Sign-in, Tab.

**Special purpose:**

| Template | Who may use it |
|---|---|
| `NavigationTemplate` | **Navigation only** |
| `PlaceListMapTemplate` (Place List) | **POI only** |
| `MapWithContentTemplate` (Map + Content) | Navigation, **POI**, Weather |
| `MediaPlaybackTemplate` | Media only |

> *"The `NavigationTemplate` (as well as the deprecated `MapTemplate`,
> `PlaceListNavigationTemplate`, and `RoutePreviewNavigationTemplate`) can
> **only be used by apps declaring the `androidx.car.app.category.NAVIGATION`
> car app category**."*
> — <https://developer.android.com/training/cars/apps/navigation>

And the reverse exclusivity: `PlaceListMapTemplate` is *"available **only** to
apps declaring `androidx.car.app.category.POI`… Navigation apps cannot use these
templates"* (<https://developer.android.com/training/cars/apps/poi>).

Note the shape difference from CarPlay: **Android gives a POI app a real map
surface it can draw into** (`MapWithContentTemplate`), which CarPlay reserves
for navigation apps. Android's boundary is drawn at *turn-by-turn guidance*
(`NavigationTemplate`), not at *map rendering*.

Google now positions `SectionedItemTemplate` as the successor to List and Grid:
*"With the introduction of the Sectioned Item template, list and grid templates
are no longer needed"*
(<https://developer.android.com/design/ui/cars/guides/templates/sectioned-item-template>).

## 2.4 Hard limits

### Content limits — `ConstraintManager`

Five types, with fallback values from
[`integers.xml`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/res/values/integers.xml),
whose header comment reads *"the following content limits are defaults for when
the app fails to communicate with the host for the actual limits"*. The
[Constraints API guide](https://developer.android.com/training/cars/apps/library/constraints-api)
frames the same numbers as the **documented minimum across all supported
vehicles**:

| Type | Default / floor |
|---|---|
| `CONTENT_LIMIT_TYPE_LIST` | **6** |
| `CONTENT_LIMIT_TYPE_GRID` | **6** |
| `CONTENT_LIMIT_TYPE_PLACE_LIST` | **6** |
| `CONTENT_LIMIT_TYPE_ROUTE_LIST` | 3 (navigation only) |
| `CONTENT_LIMIT_TYPE_PANE` | **4** |

Query at runtime:
`carContext.getCarService(ConstraintManager::class.java).getContentLimit(CONTENT_LIMIT_TYPE_PLACE_LIST)`.
Limits are host-controlled and cannot be overridden. **Items beyond the limit
are silently ignored by the host** (per the `build()` javadoc on
`GridTemplate`/`PlaceListMapTemplate`/`PaneTemplate`/`SearchTemplate`).

**Six is the number to design against**, not twelve. Android's worst case is
half of CarPlay's.

Absolute library cap: `ListTemplate.MAX_ALLOWED_ITEMS = 100` across all sections
([ListTemplate.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/ListTemplate.java)).

### Rows and text lines

[`RowConstraints.java`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/constraints/RowConstraints.java):

| Preset | Max text lines/row | Max actions | Image |
|---|---|---|---|
| `CONSERVATIVE` | **1** | 0 | no |
| `PANE` | **2** | **2** | yes |
| `SIMPLE` | **2** | 0 | yes |
| `FULL_LIST` | **2** | 0 | yes |

The 2-line rule, three ways:

- `Row.Builder#addText`: *"Most templates allow up to 2 text strings, but this
  may vary."*
- Template `build()` javadoc: *"Each `Row` can add up to 2 lines of texts."*
- Design docs: *"text is truncated to 2 lines **while driving**. Secondary text
  in list rows can be longer than 2 rows **when parked**."*
  (<https://developer.android.com/design/ui/cars/guides/components/row>,
  <https://developer.android.com/design/ui/cars/guides/templates/list-template>)
  Guidance: put the driving-relevant substring **first**, because the tail is
  what gets cut.

`GridItem` secondary text is *"truncated at the end to fit in a **single line**
below the title"* — one line, not two
([GridItem.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/GridItem.java)).

Tabs: **2–4** at Car API ≤ 8, **up to 5** at Car API 9; header action must be
`ACTION_APP_ICON`
([TabTemplate.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/TabTemplate.java)).

### `PlaceListMapTemplate` row rules — these bind the schema

From <https://developer.android.com/training/cars/apps/poi> and the design docs
(<https://developer.android.com/design/ui/cars/guides/templates/place-list-map-template>):

- Each row ≤ 2 text lines. No `Toggle`. A row may not have **both** an image and
  a place marker. `IMAGE_TYPE_LARGE` forbidden. `ItemList` not selectable.
- **Every non-browsable row MUST carry a `DistanceSpan`** on its title or text.
  Restated as a design MUST: *"Show duration or distance for each list item
  (except browsable items)"*.
- *"Associate an action with each list row — information-only rows not
  allowed."*
- `setCurrentLocationEnabled(true)` requires `ACCESS_FINE_LOCATION` or
  `ACCESS_COARSE_LOCATION`.

### `PlaceMarker` — the only hard character limit on either platform

`PlaceMarker.MAX_LABEL_LENGTH = 3`. `setLabel()` throws
`IllegalArgumentException` above 3 characters; spans are ignored; `null` lets the
host pick its own scheme
([PlaceMarker.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/PlaceMarker.java)).
Design docs agree: map marker text *"up to **3 letters** maximum"*. Marker
types: `TYPE_ICON` **64×64 dp**, `TYPE_IMAGE` **72×72 dp**; `setColor()` is
illegal with `TYPE_IMAGE`.

### Strings elsewhere: `CarText` variants

No max-character count is documented for titles or body text. The sanctioned
mechanism is
[`CarText`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/CarText.java)
variants — the same idea as CarPlay's `titleVariants`:

> *"variants should be added in order of preference, from most to least
> preferred (for instance, from longest to shortest)… If the text provided via
> Builder does not fit in the screen, the host will display the first variant
> that fits."*

Span permissions are per-field
([CarTextConstraints.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/constraints/CarTextConstraints.java)).
Notably **`Row.setTitle()` accepts only `DistanceSpan` and `DurationSpan`** —
which is how the mandatory distance gets into a title — and ActionStrip titles
accept no spans at all.

Design guidance elsewhere: text while driving **1–3 lines**, with a
**120-character** glanceability limit
(<https://developer.android.com/design/ui/cars/guides/foundations/design-principles>).

### Images

[`Row.java`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/Row.java)
bounding boxes; oversized images are scaled down preserving aspect ratio:

| Constant | Box |
|---|---|
| `IMAGE_TYPE_EXTRA_SMALL` | 48×48 dp |
| `IMAGE_TYPE_SMALL` / `IMAGE_TYPE_ICON` | 88×88 dp |
| `IMAGE_TYPE_MEDIUM` | 128×128 dp (1.8.0-beta01) |
| `IMAGE_TYPE_LARGE` | 224×224 dp — **forbidden in `PlaceListMapTemplate`** |

UX minimum for map imagery: **36×36 dp** for images, icons and map markers; map
text **≥ 24 dp**
(<https://developer.android.com/design/ui/cars/guides/templates/map-content-template>).
`CarIconConstraints.DEFAULT` allows only `TYPE_BITMAP` and `TYPE_RESOURCE` —
**`TYPE_URI` is generally not permitted**, and where allowed the scheme must be
`content://`
([CarIconConstraints.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/constraints/CarIconConstraints.java)).
**Remote image URLs cannot be handed to the car** — assets must be bundled or
materialised locally.

### Actions

[`ActionsConstraints.java`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/model/constraints/ActionsConstraints.java):
`HEADER` 1 · `MULTI_HEADER` 2 · `BODY` 2 · `SIMPLE` 2 · `ROW` 2 · **`FAB` 2** ·
`NAVIGATION` 4 · `MAP` 4 · `TABS` 1. `ActionStrip` itself declares no maximum;
the ceiling comes from the template's preset. `MapWithContentTemplate` ActionStrip:
max 4. `MessageTemplate`/`SearchTemplate`/`SignInTemplate` ActionStrip: max 2, only
one may carry a title.

## 2.5 The 5-template quota — the constraint most likely to bite

From <https://developer.android.com/training/cars/apps/library/template-restrictions>
and [`Screen.java`](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/Screen.java):

- **Max 5 templates per task.** It counts **templates sent, not `Screen`
  instances**.
- **The 5th template must be** `NavigationTemplate`, `PaneTemplate`,
  `MessageTemplate`, `MediaPlaybackTemplate`, `SignInTemplate` or
  `LongMessageTemplate`. Navigation and MediaPlayback are category-locked away
  from a POI app, so **for EV Guide the terminal template can only be Pane,
  Message, Sign-in or Long Message** — never a list or a map.
- **Exceeding it:** *"the host displays an error message and closes the app."*
  The UX docs are blunter: *"Task flows must not exceed 5 steps or the app will
  crash."*
- **Going back refunds the quota**, by the number of templates popped.
- **Full reset** on reaching a `NavigationTemplate` (unavailable to POI), **or on
  an intent from a notification or the launcher** — *"even if the app is already
  in the foreground"*. That launcher/notification reset is EV Guide's only
  escape hatch.
- `SignInTemplate` and `LongMessageTemplate` bodies **do not count** against the
  quota.
- Screen stack cap: **5 screens**
  (<https://developer.android.com/training/cars/apps/library/screen-navigation>).

### What counts as a refresh (does not consume quota)

This is the subtle part, and it directly constrains how live availability may be
rendered. Per class javadoc:

| Template | Counts as a refresh when… |
|---|---|
| `ListTemplate` | title unchanged **and** list structure unchanged — same section count, same section headers, **same rows and row titles** |
| `GridTemplate` | title unchanged **and** **item count and each item's title** unchanged |
| `PlaceListMapTemplate` | title unchanged **and** **row count and row titles** unchanged (spans excluded); **or** responding to `setOnContentRefreshListener` |
| `PaneTemplate` | title unchanged **and** row count and row titles unchanged |
| `MessageTemplate` | title and messages unchanged |
| `SearchTemplate` | **any** content change |

**Consequence:** on a `PlaceListMapTemplate`, changing the *number of rows* or a
*row title* is a new template and costs a step from the 5-step quota. A live
availability feed that adds or removes stations as data lands will burn the
quota and the host will close the app. Two mitigations, both of which shape the
model:

1. Fix the row **set** for the lifetime of the screen (N nearest, resolved once),
   and let only non-title text change. Note the spans exclusion — the
   `DistanceSpan` in the title may update freely.
2. **Availability therefore cannot live in the row title on Android.** It must
   live in the secondary text.

**Adaptive task limits** relaxes this: with it on, *"all updates where the layout
stays the same"* count as refreshes, **including changes to the number of rows**,
and flows >5 steps become legal while parked. But availability is regional and
OEM-dependent, is **not available for JAMA-affiliated Android Auto vehicles**,
and must be probed with `ConstraintManager.isAppDrivenRefreshEnabled()`
(`@RequiresCarApi(6)`, returns `false` on host-call failure). **Design for it
being off.**

### Throttling

`Screen.onGetTemplate()`: *"To minimize user distraction while driving, the host
will throttle template updates to the car screen. When the app invalidates
multiple times in a short period, the host will call this method for each call,
but it may not update the actual car screen right away."* **No numeric interval
is published.** The one documented timing floor is **8 seconds** minimum dwell
before auto-transitioning away from content
(<https://developer.android.com/design/ui/cars/guides/ux-requirements/overview>).

## 2.6 Play Console path and review

**Where.** Play Console → **Advanced settings → Form factors → Add form factor
→ Android Auto**
(<https://developer.android.com/training/cars/distribute>). There is **no
separate "Android Auto declaration"** — it is a form-factor opt-in, and Android
Auto ships inside the ordinary mobile artifact with no dedicated track. (The
Play Console Help article on form-factor tracks,
<https://support.google.com/googleplay/android-developer/answer/13295490>, lists
only Wear OS, Android TV, Android Automotive OS and Android XR — Android Auto is
absent for exactly that reason.)

**Prerequisite:** an Android Auto–capable artifact must already be on a testing
track, with the `com.google.android.gms.car.application` metadata declaring
capabilities (same distribute URL).

**Is there still an allowlist?** **No, not for this category.** The supported-
categories table (<https://developer.android.com/training/cars#supported-app-categories>)
lists Point of Interest — described explicitly as covering *"parking, charging,
fuel"* — as publishable to **"All track types"** on both Android Auto and AAOS,
usable *"while driving or parked"*. Production publishing for this class opened
in **April 2021** with Car App Library 1.0
(<https://developer.android.com/jetpack/androidx/releases/car-app>). Gates that
do remain — templated messaging/calling/games (Internal + Closed only),
browsers (Internal only), templated media (Early Access Program) — do not touch
a POI app.

**There is an additional review, and it is track-conditional:**

| Track | Car review |
|---|---|
| Internal app sharing | none |
| Internal testing | none |
| Closed testing | **non-blocking** (flagged, still approved) |
| Open testing | **blocking** |
| Production | **blocking** |

Outcome arrives by email; rejections summarise what to fix and **the rejected
artifacts must be removed before resubmitting** (distribute URL). The quality
page independently describes it as *"an additional manual review"* by the Play
Store team.

**Turnaround: no car-specific SLA is published.** Only *"may take longer"* than
phone-only apps, plus the generic Play figure — *"review times of up to 7 days
or longer in exceptional cases"*
(<https://support.google.com/googleplay/android-developer/answer/9859751>).
Materially better than CarPlay's open-ended silence.

**The contractual layer.** The **Android for Cars Addendum to the Developer
Distribution Agreement**
(<https://play.google/auto/developer-distribution-agreement-addendum/>), reached
via Policy Center → Other Programs → Android Auto/Automotive
(<https://play.google/developer-content-policy/>), reserves two rights:

> *"If your Products are published for Android Auto or Android Automotive OS,
> your Products may be subject to review and approval before external
> publication via the Play Store."*
>
> *"Google may block any Products being used in a car running Android Auto or
> Android Automotive OS at any time for any reason."*

No application allowlist, but an approval right plus an unconditional kill
switch — structurally the same exposure as Apple's entitlement, arriving later
in the lifecycle.

**Two reviewer-access clauses aimed straight at EV Guide** (distribute URL):

- POI apps with booking must let the test account complete bookings without
  charge. (Not applicable — EV Guide books nothing.)
- **"If your app is not available in the United States, you must permit users to
  use a mock GPS location app"** so the reviewer can test navigation and POI
  features. **A Rwanda-only charging directory reviewed from the US shows an
  empty screen unless mock locations are supported.** This must be built.

## 2.7 The quality guidelines a POI app must pass

Canonical: <https://developer.android.com/docs/quality-guidelines/car-app-quality>.
Three tiers; **Tier 2 "Car optimized" is the pass/fail bar** for POI, because POI
is a drive-time category: *"Apps in [categories built for use while driving] must
meet all of the applicable requirements in this tier to be accepted on the Google
Play Store."*

Requirements that apply to a POI app:

| ID | Requirement |
|---|---|
| `PF-1` | **POI apps "must provide meaningful functionality relevant to driving"** |
| `PC-1` | No features outside the intended car app types |
| `EP-1` | Works as described in the Play listing |
| `EP-2` | Restores state on relaunch from the car home screen |
| `AR-1` | UI not obstructed by system bars or display cutouts |
| `SA-1` | **No animated elements** — no animated graphics or video; canvas animations only while parked |
| `AD-1` | No text-based advertising beyond advertiser/product name |
| `NA-1` | No ads via notifications |
| `IN-1` | Notifications only when relevant to the driver |
| `IU-1` | **No images except**: a single static context image, nav-drawer icons, images aiding driving decisions, lane/junction guidance |
| `VI-1` | If the user must go to the phone (e.g. a permission request), the app **must display a message telling them to look at the phone only when safe** |
| `ST-1` | **No automatically scrolling text** |
| `DR-1` | **Buttons respond in ≤ 2 seconds** |
| `DR-2` | **App launches in ≤ 10 seconds** |
| `DR-3` | **Content loads in ≤ 10 seconds** |
| `VD-1` | Icons and colours meet contrast requirements |
| `TH-1` | Custom theming on Car App Library v1.9+ must support light and dark |
| `MR-1` | Apps drawing maps honour the host's light/dark instruction |
| `PA-1` | Purchase flows: no payment-method setup, no multi-item selection, no subscriptions |
| `AC-1` | Complete tasks in **5 screens or fewer** |

Not applicable: all messaging (`MF-*`/`TMF-*`), navigation (`NF-*`), calling
(`CF-*`), media, video/games/browsers, IoT, weather. **`VC-1`** (Gemini + Google
Assistant voice commands) applies to **Media and Navigation only** — voice is
*not* mandatory for POI, though the POI guide demonstrates the pattern
(*"Hey Google, find nearby charging stations on ExampleApp"*).

Hard numbers from the design docs:

- **Contrast 4.5:1**, WCAG 2.0 AA normal text
  (<https://developers.google.com/cars/design/android-auto/design-system/color#contrast>
  — the exact URL `VD-1` links to). Android Auto uses a black background across
  day and night, with white text at 88/72/56% opacity in day and 96% in night.
- Task flow **MUST be ≤ 5 steps**, **SHOULD be 2–3**; common tasks in **3 taps
  or fewer**; a 5-step flow **MUST NOT** end on a list template
  (<https://developer.android.com/design/ui/cars/guides/ux-requirements/overview>).
- **8 seconds** minimum dwell before an auto-transition.

**`PF-1` is Google's version of Apple's "can't just be a list of EV chargers."
Both platforms independently apply the same test to the same app shape.** That
convergence is the strongest signal in this research: a pure directory is
unlikely to clear either review. Whatever functionality EV Guide adds to satisfy
Apple satisfies Google too — design it once.

**On login and "usable without the phone".** There is **no** requirement that the
app be fully usable without the phone screen. The documented position is the
opposite-and-mitigated: `VI-1` explicitly contemplates the phone being needed and
demands a safety message, and the library docs confirm that **on Android Auto the
runtime-permission dialog appears on the phone**
(<https://developer.android.com/training/cars/apps/library/request-permissions>).
That page also warns to use **`androidx.car.app:1.7.0-rc01` or higher** so
permission dialogs appear on Android 14+ and to avoid crashes on AAOS 15+.

Contrast with CarPlay, which *does* require it: *"All CarPlay flows must be
possible without interacting with iPhone"* (§1.6). **Apple's rule is stricter,
so build to Apple's.**

## 2.8 Testing

- **Desktop Head Unit (DHU)** — Android Studio → SDK Manager → SDK Tools →
  "Android Auto Desktop Head Unit Emulator"; `adb forward tcp:5277 tcp:5277`
  then `./desktop-head-unit` (2.x recommends `--usb`)
  (<https://developer.android.com/training/cars/testing/dhu>). The quality page
  instructs: *"Use the Android Auto Desktop Head Unit (DHU) to validate each
  checklist item."*
- **Android Auto developer mode** — Android Auto app → About → tap Version block
  **10 times** (<https://developer.android.com/training/cars/testing>).
- **The sideloading trap.** The developer setting permitting unknown-source apps
  covers *media apps, messaging notifications and parked apps* and **explicitly
  does not apply to Car App Library apps**
  (<https://developer.android.com/training/cars/testing>). **A templated POI app
  cannot be sideloaded to a real head unit.** Getting onto real hardware means
  Internal App Sharing or the Internal test track.
- **No documented requirement to test on real hardware.** The DHU page states a
  real head unit is not required.
- The AAOS emulator tests AAOS, not Android Auto — the two paths are disjoint
  (<https://developer.android.com/training/cars/testing/emulator>).

## 2.9 Navigation hand-off — yes, and Google positively recommends it

Mechanism is `CarContext.startCarApp(Intent)`. From the AndroidX source javadoc
(<https://github.com/androidx/androidx/blob/androidx-main/car/app/app/src/main/java/androidx/car/app/CarContext.java>):

> *"**An Intent to navigate.** The action must be `ACTION_NAVIGATE`. The data URI
> scheme must be either a latitude,longitude pair, or a `+` separated string
> query as follows: 1) `"geo:12.345,14.8767"` for a latitude, longitude pair.
> 2) `"geo:0,0?q=123+Main+St,+Seattle,+WA+98101"` for an address.
> 3) `"geo:0,0?q=a+place+name"` for a place to search for."*

`ACTION_NAVIGATE = "androidx.car.app.action.NAVIGATE"`. Throws `SecurityException`
if you name another app's component explicitly.

Full grammar at
<https://developer.android.com/develop/devices/assistant/intents-assistant-nav-app>:
scheme `geo`, parameters `q`, `intent=` (`navigation` | `add_a_stop` |
`directions`), `mode=` (`d` drive, `w` walk, `b` bicycle, `l` two-wheeler,
`r` transit, `x` taxi), `avoid=` (`f`/`h`/`t`).

**It does not require the navigation category.** The navigation category is for
*receivers*: `NF-6` obliges navigation apps to **handle** navigation requests
from other apps. And the UX requirements page positively endorses the hand-off:
**"POI apps SHOULD provide a way to launch a navigation app to the POI"**
(<https://developer.android.com/design/ui/cars/guides/ux-requirements/overview>).

**You cannot target Google Maps by name.** On Android Auto the recipient is the
**default navigation app = the last navigation app the user launched**
(<https://developer.android.com/training/cars/apps/navigation>). The chain
"nav apps must handle `ACTION_NAVIGATE` (`NF-6`) + host routes to the default nav
app" is strong but the last hop is inferential — no Google page names Google Maps
as a guaranteed receiver.

## 2.10 Vehicle EV APIs — describe the car, not the station

There is EV surface in `androidx.car.app.hardware.info`, but **none of it
describes charging stations**. Station data is entirely EV Guide's own.

- `EnergyLevel` (`@RequiresCarApi(3)`) — `getBatteryPercent()`,
  `getRangeRemainingMeters()`, `getEnergyIsLow()`. The genuinely useful one:
  rank stations by reachability.
- `EvStatus` (`@ExperimentalCarApi`) — `getEvChargePortOpen()`,
  `getEvChargePortConnected()`.
- `EnergyProfile.getEvConnectorTypes()` (`@RequiresCarApi(3)`) — what the car can
  plug into. Values:
  `UNKNOWN=0, J1772=1, MENNEKES=2, CHADEMO=3, COMBO_1=4, COMBO_2=5,
  TESLA_ROADSTER=6, TESLA_HPWC=7, TESLA_SUPERCHARGER=8, GBT=9, GBT_DC=10,
  SCAME=11, OTHER=101`
  ([EnergyProfile.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/hardware/info/EnergyProfile.java)).

Every field returns a `CarValue` that can be `STATUS_UNIMPLEMENTED`. On Android
Auto — a phone projecting to an arbitrary head unit — **expect these unavailable
most of the time. The app must work fully without them.**

There is a second, AAOS-platform enumeration,
[`android.car.hardware.property.EvChargingConnectorType`](https://android.googlesource.com/platform/packages/services/Car/+/refs/heads/main/car-lib/src/android/car/hardware/property/EvChargingConnectorType.java),
which supersedes the deprecated `android.car.EvConnectorType`. **It uses the same
names with different integers** — CHAdeMO is 3 in `EnergyProfile` but 4 there;
CCS1 is 4 vs 5 — and it renames `TESLA_HPWC`/`TESLA_SUPERCHARGER` to
`SAE_J3400_AC`/`SAE_J3400_DC`. See the data-model section: **never persist a
platform integer.**

---

# Part 3 — Where the two platforms agree, and the Rwanda problem

## 3.1 The convergences (these are the real requirements)

| Requirement | CarPlay | Android Auto |
|---|---|---|
| "Not just a list" | *"your app can't just be a list of EV chargers"* | `PF-1`: *"must provide meaningful functionality relevant to driving"* |
| Category gate on templates | entitlement gates templates; **runtime exception** | category gates templates |
| Turn-by-turn is the hard boundary | `carplay-maps` required | `NAVIGATION` category required |
| Directions hand-off sanctioned | Developer Guide p.29 | UX req: POI apps *SHOULD* |
| Tiny result sets | 12 POIs; lists cut to 12 | **6** place-list floor |
| Two text slots per row | `text` + `detailText` | 2 lines, truncated while driving |
| Strings as length variants | `titleVariants` | `CarText.addVariant` |
| Shallow hierarchy | **5 templates** incl. root | **5 templates** per task |
| No animation | *"CarPlay doesn't support animated images"* | `SA-1` no animated elements |
| Host-controlled limits, queried at runtime | `maximumItemCount`, `CPSessionConfiguration` | `ConstraintManager.getContentLimit` |
| No published approval SLA | none at all | *"may take longer"*, generic ≤7d |
| Platform can revoke | entitlement is account-level | Addendum kill switch |

## 3.2 The Rwanda problem — decision-critical

Three separate, independently verified facts:

1. **Android Auto is not available in Rwanda.** ~47-country list; South Africa is
   the only African entry
   (<https://support.google.com/androidauto/answer/6348019>).
2. **CarPlay is not listed as available in Rwanda.** Apple's iOS feature
   availability page lists Apple CarPlay for 37 countries — Australia, Austria,
   Belgium, Brazil, Canada, Chile, China mainland, Denmark, Finland, France,
   Germany, Hong Kong, India, Ireland, Israel, Italy, Japan, Malaysia, Mexico,
   Netherlands, New Zealand, Norway, Russia, Saudi Arabia, Singapore, South
   Africa, South Korea, Spain, Sweden, Switzerland, Taiwan, Thailand, Türkiye,
   UAE, UK, US, Vietnam. **Rwanda is absent; South Africa is again the only
   African entry.** (<https://www.apple.com/ios/feature-availability/>, section
   "Apple CarPlay"; verified by direct text extraction of the page.)
3. **Apple Maps has neither Directions nor Turn-by-Turn Navigation in Rwanda.**
   On the same page, Rwanda appears under **"Maps: Standard"** and **"Maps:
   Satellite"** only. It is absent from **"Maps: Directions"** and absent from
   **"Maps: Turn-by-Turn Navigation"** (whose list includes South Africa, Egypt,
   Morocco and Réunion, but no other African country).

Against which: **Google Maps does have driving directions in Rwanda.** Google's
Navigation SDK coverage table marks Rwanda ⬤ ("available in the area, with good
data quality and availability") for **Traffic Layer, Driving Directions, Walking
Directions and Two-Wheeled Vehicle**
(<https://developers.google.com/maps/documentation/navigation/android-sdk/coverage-nav-sdk>).
That table governs the Navigation SDK rather than the consumer Maps app, but it
is the strongest primary evidence available.

**What follows:**

- Neither car integration can be used by EV Guide's target users today. They are
  features for a market EV Guide does not serve. Whatever the reason to build
  them — regional expansion, diaspora users, a South Africa play, portfolio
  credibility — it is **not** "Rwandan drivers will use this".
- Both platforms' reviews will be performed from a market where EV Guide's data
  is empty. Google states the mock-GPS obligation explicitly (§2.6); Apple states
  nothing equivalent, so the CarPlay reviewer will simply see a blank map unless
  the app can be pointed at Kigali. **Build a demo/mock-location path for both.**
- **The directions decision (ticket 13) is settled by this, on the phone too:
  Apple Maps cannot navigate in Rwanda.** A hand-off that targets Apple Maps
  fails for the whole user base. Google Maps is the only viable target. This
  finding belongs to 13 as much as to 04.
- This does not argue for cutting the car work from the *spec* — the map already
  places it out of the first build, and the entitlement lead time is the stated
  reason to start early. It argues for **re-examining whether the CarPlay
  entitlement application should be filed at all right now**, given that Apple
  will be asked to approve a driving feature for a country where it does not
  ship CarPlay. That is a founder decision, not a research finding.

---

## What this forces on the data model

Ordered by how much each constrains the schema. Items marked **[hard]** are
forced by a documented platform rule; **[derived]** are my inference from those
rules.

### 1. A geo-point is mandatory and non-null **[hard]**

CarPlay requires an `MKMapItem` for every POI; Android requires a `CarLocation`
inside every `Place`. Latitude/longitude are structurally required, not optional
enrichment. A station row with a text address and no coordinate cannot be shown
in either car UI.

### 2. The primary read is `stationsNear(lat, lng, limit)`, not `allStations()` **[hard]**

Three independent forces converge on the same query:

- CarPlay's `CPPointOfInterestTemplateDelegate` fires on **every map region
  change** and the app must re-supply the (max 12) most relevant POIs for the new
  viewport.
- Android's `PlaceListMapTemplate` requires a **`DistanceSpan` on every
  non-browsable row**, so distance-from-origin is part of the row, not a detail.
- Play review requires the app to honour a **mock GPS location** so a US reviewer
  can see Kigali data.

All three need an **arbitrary origin**, not "the device's location". The station
store needs a geospatial index and a bounded, ranked nearby query. This is the
single most load-bearing schema consequence.

### 3. Result sets are tiny: design for 6, cap at 12 **[hard]**

Android's documented floor is **6** (`CONTENT_LIMIT_TYPE_PLACE_LIST`), CarPlay's
ceiling is **12**. Both are host-controlled and must be queried at runtime; both
silently drop the overflow. Ranking is therefore **server/store-side and
mandatory**, and the ranking key must be cheap and total — distance first, then
availability. There is no "show all ~200 Kigali stations" affordance on either
car screen, so the model needs no support for one.

### 4. Every display string needs a short form; one needs to be 3 characters **[hard]**

- **`PlaceMarker.setLabel()` throws above 3 characters.** This is the only hard
  character limit on either platform, and it is not derivable from a station
  name — "Kabisa – SP Remera" has no mechanical 3-char abbreviation. It must be
  an authored field.
- Both platforms select among **length variants** rather than truncating
  intelligently (`titleVariants`, `CarText.addVariant`, ordered longest→shortest).
- Android truncates row text to **2 lines while driving** and advises putting the
  driving-relevant substring first; the design guidance is 1–3 lines and a
  **120-character** glanceability limit.

**[derived]** Concretely, a station needs at least three name fields, not one:
`marker_label` (exactly ≤3 chars, authored), `name_short` (row/picker title), and
`name` (full, for the detail screen and the phone). Rwanda's operator-prefixed
naming ("EVP Charger — Kimironko Market") makes this acute: the useful short form
is the *place*, and the operator belongs in the icon and the marker label.

### 5. Two text slots per row, and Android spends one of them on distance **[hard]**

CarPlay `CPListItem` = `text` + `detailText`. Android `Row` = 2 lines. Android
*mandates* distance in the row. So the Android row is realistically:

```
line 1: <station short name>
line 2: <distance> · <availability>
```

**Rate has no room on the car row.** It is a detail-screen field. That is a
product consequence of the templates, and it should be recorded in 17 rather than
discovered during implementation.

**[derived]** Rather than letting each surface concatenate ad hoc, the model
should expose a small fixed set of **projections** of a station — one-line,
two-line, picker-triple, card-triple — because CarPlay's POI type wants exactly
six strings (`title`/`subtitle`/`summary` for the picker,
`detailTitle`/`detailSubtitle`/`detailSummary` for the card) and will otherwise
be filled by improvisation at three different call sites.

### 6. Availability must be structured, short-renderable, and **not in the row title** **[hard]**

- Apple names this template's purpose: *"an EV charging app may display
  information about a charging station such as availability"*
  (`CPInformationTemplate`, whose items are strictly `title`+`detail` pairs).
- On Android, **changing a row title costs a template step** from the 5-step
  quota, whereas changing non-title text on a stable row set is a free refresh
  (§2.5). Putting "2/4 free" in the title would burn the quota and get the app
  closed by the host.

**[derived]** Store availability as fields, never as prose:
`bays_total`, `bays_available`, `status` (enum), `last_reported_at`. Derive the
short strings. A `last_reported_at` plus a freshness threshold is required
because a car row must be able to say "unknown" rather than assert a stale
number — this belongs to 09.

### 7. Per-connector availability: needed for **filtering**, not for **display** **[hard]**

This was the ticket's specific question. The answer is clean:

- **Neither car surface can display per-connector availability in any structured
  form.** CarPlay's `CPChargingStationConnection` (connector/voltage/power) is
  reachable only by **navigation** apps, in a map panel during route selection
  (§1.7). Android's `EvConnectorType` describes the **car**, not the station.
- So the car screens get **one aggregate availability figure per station**, plus
  at most a one-line connector summary as free text.
- **But** the vehicle-side connector enum is exactly what a filter would match
  against ("only stations my car can plug into"). Per-connector rows therefore
  still belong in the schema — as a filter dimension.

**[derived]** The shape that satisfies both:

```
station_connector(station_id, connector_type, power_kw, voltage,
                  count_total, count_available)
station(..., bays_total, bays_available, last_reported_at)   -- denormalised
```

The denormalised aggregate on `station` exists because the car row needs one
number without a join, under a 2-second button-response budget.

### 8. Connector type is an app-owned string enum, mapped at every boundary **[hard]**

Three vendor taxonomies exist and **they disagree**:

| | Apple `CPChargingStationConnection.Connector` | Android `EnergyProfile` | AAOS `EvChargingConnectorType` |
|---|---|---|---|
| J1772 / Type 1 | `j1772` | 1 | 1 |
| Mennekes / Type 2 | `mennekes` | 2 | 2 |
| Scame / Type 3 | — | 11 | 3 |
| CHAdeMO | `chaDeMo` | **3** | **4** |
| CCS1 | `ccs1` | **4** | **5** |
| CCS2 | `ccs2` | **5** | **6** |
| Tesla Roadster / HPWC / Supercharger | — | 6 / 7 / 8 | 7 / 8 (dep.) / 9 (dep.) |
| NACS AC / DC | `nacsAC` / `nacsDC` | — | `SAE_J3400_AC` 8 / `_DC` 9 |
| GB/T AC | `gbtAC` | 9 | 10 |
| GB/T DC | `gbtDC` | 10 | 11 |
| unknown / other | — | 0 / 101 | 0 / 101 |

Sources:
<https://developer.apple.com/documentation/carplay/cpchargingstationconnection/connector-swift.enum>,
[EnergyProfile.java](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/car/app/app/src/main/java/androidx/car/app/hardware/info/EnergyProfile.java),
[EvChargingConnectorType.java](https://android.googlesource.com/platform/packages/services/Car/+/refs/heads/main/car-lib/src/android/car/hardware/property/EvChargingConnectorType.java).

**Never persist a platform integer.** Persist a string enum and map at the edge.
Note the asymmetries the mapping must survive: Apple has **no `unknown` and no
`other`** while both Android enums do; Apple has **no Tesla-proprietary cases**
while Android has three; Apple splits NACS into AC/DC where the older Android
enum has no NACS at all. **[derived]** The app enum needs an `unknown` member
regardless, because both Android enums can hand one back.

Store `power_kw` and `voltage` as **numbers**, not strings — that is the shape
Apple's own initializer takes (`init(connector:voltage:power:)`).

### 9. The car surface must render from an on-device cache, readable while the phone is locked **[hard]**

Two independent forces:

- Android quality gates are pass/fail: **`DR-2` launch ≤ 10 s**, **`DR-3` content
  load ≤ 10 s**, **`DR-1` button response ≤ 2 s**. Over a Rwandan mobile link, a
  cold network fetch will not reliably clear these.
- **CarPlay is used with the phone locked**, and while locked the app cannot read
  files at `NSFileProtectionComplete`/`CompleteUnlessOpen` or keychain items at
  `kSecAttrAccessibleWhenUnlocked*` (Developer Guide p.29).

**[derived]** So: the station cache must be stored at a protection class readable
while locked (`…CompleteUntilFirstUserAuthentication`), and any credential needed
to refresh it must use `kSecAttrAccessibleAfterFirstUnlock`. **This is a security
decision that CarPlay forces**, and it argues strongly that the car surface reads
only non-sensitive directory + availability data and never anything user-specific
— which conveniently is all EV Guide has, since there are no payments.

The cache in turn needs a sync shape: **`updated_at` per station and a
changed-since endpoint**, so the car can paint from cache immediately and refresh
behind it.

### 10. Exactly one small static image per station, and it cannot be a URL **[hard]**

- CarPlay: pin images sized at runtime from `CPPointOfInterest.pinImageSize`;
  grid icons 40×40 pt; **no animated images**.
- Android: `PlaceMarker` 64×64 dp (icon) / 72×72 dp (image); `IMAGE_TYPE_LARGE`
  forbidden in `PlaceListMapTemplate`; **`CarIconConstraints.DEFAULT` permits only
  bitmaps and resources — not `TYPE_URI`**; `IU-1` forbids images beyond a single
  static context image; `SA-1` forbids animation.

**[derived]** This puts a hard ceiling on the map's "station media" idea: the car
surface takes **one small static mark per station — realistically the operator's
icon — and no photographs**. Since remote URLs cannot be handed to the car, the
icon set must be **bundled or materialised locally**, which means a **bounded,
enumerable set of operators** (EVP, Kabisa, VW Mobility Solutions, …) rather than
a free-text operator string. That makes `operator` a first-class entity with
`name`, `short_name`, `marker_label` and a bundled `icon` — and it happens to be
where the 3-char marker label most naturally lives.

### 11. A stable, opaque station ID that survives the round trip **[hard]**

CarPlay round-trips it through `CPListItem.userInfo` / `CPPointOfInterest.userInfo`
(*"CarPlay doesn't support custom list item types"*); Android through the click
listener closure. Both need an identifier that is stable across refreshes and not
positional.

### 12. Browse-by-proximity is the primary access path; search is secondary **[hard]**

CarPlay: *"In many cars the keyboard is not available at all while driving. The
search template should be an alternative option and **never the primary way** to
accomplish tasks."* Android: `SearchTemplate` exists but the 5-step and
driving-state rules apply.

**[derived]** The geospatial index is load-bearing; the text index is not. If
only one is built first, build the geospatial one.

### 13. Navigation is always a hand-off, so directions need only a coordinate **[hard]**

Both platforms sanction hand-off and neither requires EV Guide to model routes,
maneuvers, ETAs or polylines. Combined with §3.2 (Apple Maps has no Rwanda
navigation; Google Maps does), the model needs **only** a destination coordinate
and a display name, and the target must be **Google Maps**. There is no route
entity in this schema, and the "journey planning with charging stops" idea in the
map's *Not yet specified* list would be a substantially larger commitment than it
looks — on CarPlay it would require the navigation entitlement.

### 14. Notifications are the only sanctioned in-car push, and only CarPlay grants them here **[hard]**

CarPlay allows notifications for EV charging apps (§1.4). Android's `IN-1` allows
notifications *"only when relevant to the driver"* and `NA-1` forbids ads in them
— and on Android an incoming notification intent is one of the only two things
that **resets the 5-template quota**.

**[derived]** "Notify me when a bay frees up" (map, *Not yet specified*) has a
real home on both platforms and is one of the better candidates for satisfying
Apple's "can't just be a list" and Google's `PF-1`. It needs a
`watch(station_id, user)` relation and a push token — the first genuinely
user-scoped data in an otherwise anonymous app, and therefore the first thing to
check against §9's locked-phone rule.

---

## Confidence and gaps

**High confidence.** Everything sourced from the CarPlay Developer Guide (June
2026), Apple's API reference JSON, `developer.android.com`, and the
AndroidX/AOSP source. Specifically: the category lists; the entitlement keys and
minimum iOS versions; the CarPlay template matrix and 5-deep limit; the 12-POI
cap; the `CHARGING`→`POI` deprecation; the `ConstraintManager` floors; the
5-template quota and its refresh rules; `PlaceMarker` = 3 chars; the connector
enumerations; both platforms' "not just a list" clauses; the hand-off mechanisms;
and all three Rwanda availability facts (the CarPlay and Apple Maps ones verified
by direct text extraction of Apple's page, not by a summariser).

**Deliberately not answered, because no primary source states it:**

1. **CarPlay approval timeline.** Apple publishes no SLA. The only figures are
   developer-reported forum anecdotes (§1.3), explicitly labelled as such. Do not
   let a number from this document harden into a plan.
2. **The CarPlay entitlement request form's actual fields**, and the text of the
   **CarPlay Entitlement Addendum**. Both are behind Apple ID sign-in. The
   founder can read them; this research could not.
3. **What Apple accepts as "meaningful functionality relevant to driving."**
   Undefined by Apple and by Google (`PF-1`). §1.6's list of candidates is my
   analysis, not a documented safe harbour. **This is the largest open risk in
   the ticket** and it is a judgement call, not a research gap that more reading
   would close.
4. **`CPInformationTemplate`'s maximum item count** — Apple says "a limited
   number" and gives no integer; and the runtime values behind
   `CPPointOfInterest.pinImageSize`, `CPAlertTemplate.maximumActionCount`,
   `CPListTemplate.maximumItemCount`, `maximumSectionCount` and
   `CPTabBarTemplate.maximumTabCount`. All are vehicle-dependent by design and
   must be read at runtime.
5. **Real per-vehicle `ConstraintManager` values.** Google publishes only the
   6/6/6/3/4 fallbacks and instructs runtime querying.
6. **A numeric refresh-throttle interval on either platform.** CarPlay's 10 s /
   60 s figures are written for *driving-task* apps; applying them to a charging
   app is my inference (§1.5). Android documents throttling behaviour with no
   number.
7. **Whether Google Maps specifically is a guaranteed `ACTION_NAVIGATE` receiver
   on Android Auto**, and whether Google Maps can be launched onto the CarPlay
   screen via `comgooglemaps://`. Both are strongly implied and neither is
   documented. **Must be verified on hardware before the hand-off is specified as
   the directions story.**
8. **The CarPlay Human Interface Guidelines.**
   <https://developer.apple.com/design/human-interface-guidelines/carplay>
   returns 200 but is a JavaScript SPA, and no JSON endpoint for it could be
   located (several probed, all 404). Its design guidance is therefore unread.
   The Developer Guide is the binding document and was read in full, so the gap
   is design nuance, not requirements.
9. **Android quality requirement `AC-1`.** Its heading rendered as "App doesn't
   crash" in one pass and its body as the 5-screen rule in another. The 5-screen
   limit is independently and clearly documented on the UX requirements page, so
   the *rule* is solid; the *ID* may be misattributed. Verify by eye before
   quoting `AC-1` in a spec.
10. **Apple's semantics for "Maps: Directions" vs "Maps: Turn-by-Turn
    Navigation."** The page does not explain the distinction. What is certain is
    that Rwanda appears in **neither**, and appears only under Maps: Standard and
    Maps: Satellite.
11. **Expo/React Native feasibility.** Neither vendor addresses it. Both car
    surfaces are native — `CPTemplateApplicationScene`/`CPInterfaceController` in
    Swift, `CarAppService`/`Screen` in Kotlin — with no JS runtime on the car
    screen and no React reconciler. An Expo build needs custom native modules,
    config plugins for the manifest/`Info.plist` entries, and a prebuild, for
    **both** platforms. There is no official Expo binding for either. This is an
    inference from the API shapes, and it deserves its own ticket before the car
    work is scheduled.

