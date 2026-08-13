# 04 — What do CarPlay and Android Auto actually require of an EV-charging app?

Type: research
Status: resolved (2026-08-13)
Blocked by: —

## Question

Both car integrations are in the spec, out of the first build. This ticket
establishes exactly what they demand, so the data model and the entitlement
applications are shaped correctly from the start rather than retrofitted.

For **CarPlay**: confirm the EV-charging entitlement
(`com.apple.developer.carplay-charging`) is the right one and that EV Guide
qualifies; the application process, what Apple asks for, and realistic approval
timelines; which `CPTemplate` types a charging app may use and what data shape
each expects; the review criteria an app must pass; and precisely where the
boundary sits between the charging entitlement and the far harder
`carplay-maps` one.

For **Android Auto**: the equivalent Car App Library category, its template
set, the Play Console approval path, quality guidelines, and testing
requirements.

Note anything that constrains the *phone* app's model — if the car templates
need per-connector availability in a particular shape, that shape propagates
backwards into the schema and must be known before 09 and 19.

## Context pointer

Findings in progress at `.scratch/ev-guide-spec/research/04-carplay-android-auto-requirements.md`.

## Answer

Full findings, 105 cited sources: [`research/04-carplay-android-auto-requirements.md`](../research/04-carplay-android-auto-requirements.md).

**Entitlement.** `com.apple.developer.carplay-charging` confirmed correct; EV
charging is one of 11 CarPlay categories and is unambiguously the fit
(driving-task apps are *explicitly forbidden* from being location finders).

**Correction carried into this ticket:** the harder entitlement is
`com.apple.developer.carplay-maps` — **`carplay-navigation` does not exist**.
The substance stands: it gates turn-by-turn specifically, only navigation apps
get a `CPWindow` to draw into, and the POI template's map is MapKit's, rendered
by the system. EV Guide sits far from that boundary, and **handing off for
directions is a documented, named CarPlay pattern** requiring no maps
entitlement.

**Android:** `androidx.car.app.category.CHARGING` was **deprecated** in Car App
Library 1.3 (July 2022). The correct category is `POI`. Declaring CHARGING
would have been a dead end.

**Fourteen data-model constraints** are enumerated in the findings, marked
`[hard]` (documented rule) vs `[derived]` (inference). Load-bearing ones: the
primary read must be `stationsNear(lat, lng, limit)` with an arbitrary origin;
design for **6** results, not 12; `PlaceMarker.setLabel()` throws above **3
characters** and that label cannot be derived from a Rwandan station name, so
it is an authored column; per-connector availability **cannot be displayed** on
either car surface but is still needed as a filter dimension; three vendor
connector enums exist and **disagree on the integers**, so never persist one;
and CarPlay's locked-phone rule forces the station cache into a protection
class readable while locked.

**Surfaced, and now separate tickets:** neither platform ships in Rwanda (22);
both platforms apply an undefined "meaningful functionality relevant to
driving" bar that EV Guide's shape sits right against (23); whether the car
work survives that (24).

**Routed elsewhere:** Apple Maps has neither Directions nor Turn-by-Turn in
Rwanda, so an Apple Maps hand-off fails for the entire user base — recorded on
ticket 13. Expo/RN feasibility was gap 11 and is already ticket 05, now
unblocked.
