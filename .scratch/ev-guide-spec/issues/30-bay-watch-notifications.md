# 30 — Bay-watch notifications: scope and mechanics

Type: grilling
Status: closed (2026-08-13)
Blocked by: —

## Question

Graduated from the fog by 23: **"notify me when a bay frees up" ships in the
car effort's package** — it is one of the three functions clearing the
"more than a list" bar, and the only one not yet designed.

Settle the mechanics of watching a **derived** layer: what exactly a watch
binds to (Connector, Bay, or Station — noting availability lives on
Connectors but a driver thinks in Stations); what fires it (a report arriving
that flips effective state to Free, vs decay flipping it to Unknown — decay
alone should probably never notify); expiry (a watch during one errand is not
a subscription — auto-expire after hours, not days); rate limits and quiet
behaviour so a flapping connector doesn't spam; the push transport on the
BWEZE backend (Expo push vs raw APNs/FCM — and note research 04 §9: the
locked-phone rule makes the push token the first user-scoped data the car
cache must never hold); and what the car screen shows for an armed watch
(constraint 14: notification intents reset Android's template quota, so this
is also a navigation affordance).

Account-gated (a watch is inherently account-based — consistent with
ADR-0003 as amended). Out of the v1 phone launch, in the spec: the car
effort cannot pass review without it (23).

## Resolution (2026-08-13)

1. **Binding:** `watch(stationId, connectorTypes[])` — armed where the driver
   thinks (station detail), evaluated where truth lives (Connectors).
   Defaults to all types; settable to "my plug", closing the free-for-me trap.
2. **Trigger:** only a **report-driven transition into `Free`** (fresh report
   flips derived state to Free from not-Free). **Decay never notifies** —
   "we no longer know" is not a push-worthy event. One event type, total.
3. **Lifetime:** one-shot; fires once and completes, or auto-expires silently
   after **2 hours**. Max **3 concurrent watches** per user. Arming is only
   offered when the watched set is not already Free.
4. **Spam control is the design:** at most one notification per watch, at
   most 3 armed — no repeat-fire path exists, so no rate limiter, quiet
   hours, or digest machinery is built.
5. **Transport: raw APNs + FCM from the BWEZE backend.** Expo's push relay
   would sit in the runtime path — exactly what 26 ruled out; the OS vendors'
   channels are irreducible. Push tokens are user-scoped rows and **never
   enter the car cache** (research 04 §9 locked-phone rule).
6. **Car face:** signed-in users get arm/disarm on the station detail
   template + an armed-state row; anonymous users don't see the affordance
   (directions remains their primary action). The notification deep-links to
   the station and legitimately resets Android's template quota.

Account-gated (inherently account-based, ADR-0003 as amended). In the spec;
built in the **car effort's package** (23) — the phone app gains it then too.

**Knock-ons routed:** domain model gains the Watch entity (user-scoped,
one-shot); 18 — the arm/disarm affordance and armed row are template design
inputs; 20 — the submission demo script includes arming a watch.

## Amendment from 18 (2026-08-13) — three surfaces, one gate

- `canWatch = isSignedIn && notificationsPermitted`. Notification
  authorisation must be read live (`.authorized` only — provisional delivers
  silently to Notification Center, which is exactly the alert a driver never
  sees), never from a mirrored bool that can outlive a sign-out.
- The **max-3 ceiling is evaluated on-device before the request**, with a
  count-invariant refusal — otherwise a fourth arm reads "requested" for two
  hours while the client already knew it would fail.
- A watch carries `armedAt` and `confirmed`; an arm queued offline is dropped
  past `armedAt + 2h` rather than firing late.
- "Arm only when the watched set is not already Free" becomes a **refusal with
  a reason in the row's text**, never a disappearing control: on Android a
  changing row *count* is a new template, not a refresh, and would eventually
  have the host close the app mid-drive.
