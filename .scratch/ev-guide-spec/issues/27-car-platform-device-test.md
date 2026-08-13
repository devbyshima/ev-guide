# 27 — Device test: do CarPlay and Android Auto activate in Rwanda?

Type: task
Status: open
Blocked by: 22

## Question

Nothing to decide — this is the test that closes the question documentation
cannot. Ticket 22 established that Apple treats country support as a
prerequisite while Google frames its list as *marketing rights*, that no source
in either direction reports whether the software actually refuses to run, and
that **hardware is not the obstacle** — Toyota Rwanda ships CarPlay even on the
stripped Hilux Work grade, below the power-windows line.

Establish on real devices in Rwanda:

1. On an iPhone with Rwandan region and a Rwandan Apple ID, does **Settings →
   General → CarPlay** appear, and does it pair with a CarPlay head unit? Record
   any "not available in your country" string verbatim.
2. On an Android phone with a Rwandan Play account, is **Android Auto** present
   in Play Services, and does it launch on a compatible head unit?
3. Whether a US or UK Apple ID or Play account changes either outcome — this
   tells you whether the gate follows the account or the device.
4. Whether the app stores in Rwanda will **list** an app declaring the CarPlay
   entitlement or the Android Auto POI category. This may be the real blocker
   and is separate from whether the car feature works.

Any car sold by Toyota Rwanda with the 8" touchscreen is a valid test rig.

Record what was tested, on what hardware and accounts, and the verbatim
result. Feeds directly into 24.

## Verification items routed from 13 (2026-08-13)

Two undocumented behaviours ADR-0004 depends on for the *enhanced* car
experience (the phone hand-off is the spec'd guarantee either way):

1. Android Auto: is Google Maps a guaranteed `ACTION_NAVIGATE` receiver?
2. CarPlay: does `comgooglemaps://` launch Google Maps onto the car display?

## Merged test list from 18 (2026-08-13) — in priority order

Three of these are **blocking**: a shipped design path rests on each.

1. **BLOCKING (Android)** — are a POI app's notifications surfaced on the
   Android Auto screen at all (`CarAppExtender` + `CarNotificationManager`;
   `IMPORTANCE_HIGH` heads-up has historically been reserved to messaging and
   navigation)? Research 04 documents notifications for **CarPlay** EV apps by
   name and says nothing about Android. If they are filtered, bay-watch does
   not exist on the Android car screen and **ticket 23's three-function `PF-1`
   answer reduces to two** — which must not be discovered at submission.
2. **BLOCKING (CarPlay)** — what does Apple Maps render on the car display for
   a Rwandan `daddr` it cannot route: a pin, an error sheet, or nothing? The
   shipped directions path terminates here (ADR-0004 as amended).
3. **BLOCKING (CarPlay)** — does `comgooglemaps://` via the scene `open` land
   on the **car display or the phone**? Neither `canOpenURL` nor the open
   completion handler can tell. This decides whether the
   `googleMapsCarDisplayHandoff` flag is ever enabled or the rung is deleted.
4. **(Android)** — does `ACTION_NAVIGATE` reach a nav app, is it Google Maps,
   and does it appear on the car display? ADR-0004 forbids assuming any of the
   three.

Plus the runtime values that are vehicle-dependent by design and must be read
rather than assumed: `ConstraintManager` limits, `CPPointOfInterest.pinImageSize`,
`CPListTemplate.maximumItemCount`, `maximumSectionCount`,
`CPAlertTemplate.maximumActionCount`, `CPTabBarTemplate.maximumTabCount`.
