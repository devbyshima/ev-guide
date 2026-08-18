/// The decay windows, in one place, because changing them is a product
/// decision and must be a one-line change.
///
/// ADR-0002: decay is a function of source AND state. Driver Free/Occupied
/// decays in 2h, operator Free/Occupied in 6h, OutOfService in 30d.
library;

import 'types.dart';

const Millis minute = 60000;
const Millis hour = 60 * minute;
const Millis day = 24 * hour;

/// Two rows here are **assumptions, not quotations**, and are flagged so they
/// can be ruled on rather than inherited:
///
/// - `driver` + `OutOfService`. ADR-0002 names only *operator* OutOfService at
///   30d; docs/domain-model.md's synthesis states a flat "OutOfService 30d".
///   The flat reading is taken here, so a driver's brokenness claim persists
///   for 30 days. That is a large claim from the lowest-trust source, and the
///   opposite reading (driver OutOfService decays at the driver window) is
///   equally defensible from the two documents.
/// - `admin`. Neither document gives admin a window. Treated as operator,
///   since both are trusted write sources under the ticket 11 boundaries.
const Map<ReportSource, Map<ReportedState, Millis>> decayWindows = {
  ReportSource.driver: {
    ReportedState.free: 2 * hour,
    ReportedState.occupied: 2 * hour,
    ReportedState.outOfService: 30 * day,
  },
  ReportSource.operator: {
    ReportedState.free: 6 * hour,
    ReportedState.occupied: 6 * hour,
    ReportedState.outOfService: 30 * day,
  },
  ReportSource.admin: {
    ReportedState.free: 6 * hour,
    ReportedState.occupied: 6 * hour,
    ReportedState.outOfService: 30 * day,
  },
};

Millis decayWindow(ReportSource source, ReportedState state) =>
    decayWindows[source]![state]!;

/// The rate's own freshness axis (ticket 10).
const Millis rateWindow = 90 * day;

/// A watch is one-shot and expires 2h after arming (ticket 30).
const Millis watchWindow = 2 * hour;
