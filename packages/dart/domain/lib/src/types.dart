/// Entity types. Source of truth: docs/domain-model.md.
///
/// Pure types only, no platform imports (ADR-0006). Nothing here carries an
/// availability column: availability is derived, never stored (ADR-0008).
///
/// Dart transcription of `packages/domain/src/types.ts` (ADR-0012). Same
/// entities, same reasoning; `packages/corpus/corpus.json` is the proof that
/// the derivation over these types stays equivalent.
library;

/// Connector type, ticket 02's **open** OCPI 2.3.0 enum.
///
/// Tier 1 is enumerated; the type stays open because Android can hand us a
/// value we do not know, and RURA Art. 3(c) enumerates families with an open
/// clause. Never persist a platform integer: map at the edge.
///
/// An extension type over the raw string, never a closed Dart `enum`: the
/// tier-1 constants and `other`/`unknown` are always present, and any raw
/// string stays representable.
extension type const ConnectorType(String value) {
  static const iec62196T2 = ConnectorType('IEC_62196_T2');
  static const iec62196T2Combo = ConnectorType('IEC_62196_T2_COMBO');
  static const gbtAc = ConnectorType('GBT_AC');
  static const gbtDc = ConnectorType('GBT_DC');

  /// `OTHER`/`UNKNOWN` are always present; a raw string models the open tail.
  static const other = ConnectorType('OTHER');
  static const unknown = ConnectorType('UNKNOWN');
}

/// The enumerated tier-1 members of the open [ConnectorType].
const List<ConnectorType> connectorTypesTier1 = [
  ConnectorType.iec62196T2,
  ConnectorType.iec62196T2Combo,
  ConnectorType.gbtAc,
  ConnectorType.gbtDc,
];

/// A report's claim. `Unknown` is never reported, only derived.
enum ReportedState { free, occupied, outOfService }

/// What a derivation yields. `Unknown` is the normal case (~87%).
enum AvailabilityState { free, occupied, outOfService, unknown }

/// TypeScript spells `AvailabilityState = ReportedState | 'Unknown'`; Dart
/// enums cannot share members, so the widening is this projection instead.
extension ReportedStateAsAvailability on ReportedState {
  AvailabilityState get asAvailability => switch (this) {
    ReportedState.free => AvailabilityState.free,
    ReportedState.occupied => AvailabilityState.occupied,
    ReportedState.outOfService => AvailabilityState.outOfService,
  };
}

enum ReportSource { driver, operator, admin }

/// Epoch milliseconds. The domain never holds a DateTime: it must be
/// serialisable.
typedef Millis = int;

class Report {
  const Report({
    required this.connectorId,
    required this.state,
    required this.source,
    required this.reporterId,
    required this.capturedAt,
    required this.receivedAt,
    this.capturedLocation,
    required this.sourceOnline,
  });

  final String connectorId;
  final ReportedState state;
  final ReportSource source;
  final String reporterId;

  /// When the observation happened, not when we received it (ADR-0007).
  /// Proximity gating evaluates [capturedLocation]; `capturedAt <= receivedAt`.
  final Millis capturedAt;
  final Millis receivedAt;
  final GeoPoint? capturedLocation;

  /// Amendment 2 (ticket 18): a source declaring itself offline yields
  /// `Unknown` immediately, regardless of recency.
  final bool sourceOnline;
}

/// The car cache holds raw per-Connector latest reports, never a materialised
/// aggregate (amendment 3). This projection strips the two sensitive fields
/// (`reporterId` and `capturedLocation`).
class CachedReport {
  const CachedReport({
    required this.connectorId,
    required this.state,
    required this.source,
    required this.capturedAt,
    required this.receivedAt,
    required this.sourceOnline,
  });

  CachedReport.of(Report r)
    : this(
        connectorId: r.connectorId,
        state: r.state,
        source: r.source,
        capturedAt: r.capturedAt,
        receivedAt: r.receivedAt,
        sourceOnline: r.sourceOnline,
      );

  final String connectorId;
  final ReportedState state;
  final ReportSource source;
  final Millis capturedAt;
  final Millis receivedAt;
  final bool sourceOnline;
}

class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class Connector {
  const Connector({
    required this.id,
    required this.bayId,
    required this.type,
    this.powerKw,
    this.voltage,
    this.ratePerKwhRwf,
    this.sessionFeeRwf,
    this.rateConfirmedAt,
  });

  final String id;
  final String bayId;
  final ConnectorType type;
  final num? powerKw;
  final num? voltage;

  /// Rate lives on the Connector (ticket 10), with its own 90-day freshness.
  final num? ratePerKwhRwf;
  final num? sessionFeeRwf;
  final Millis? rateConfirmedAt;
}

/// One parking position. One vehicle charges at a time; hence propagation.
class Bay {
  const Bay({
    required this.id,
    required this.stationId,
    required this.connectors,
  });

  final String id;
  final String stationId;

  /// 1..N, at least one required.
  final List<Connector> connectors;
}

class Owner {
  const Owner({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.markerLabel,
    required this.iconRef,
  });

  final String id;
  final String displayName;

  /// <= 17 chars (amendment 7).
  final String shortName;

  /// 1-3 chars, NOT NULL: the car platforms' one hard character limit.
  final String markerLabel;

  /// Must be a vector; CarPlay pin sizes are runtime values.
  final String iconRef;
}

class Station {
  const Station({
    required this.id,
    required this.ownerId,
    required this.geo,
    required this.name,
    required this.nameShort,
    required this.bays,
    this.vehicleClassTag,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;

  /// NOT NULL: a station without coordinates cannot exist (car constraint 1).
  final GeoPoint geo;

  /// <= 28 chars (amendment 7).
  final String name;

  /// <= 18 chars. The *place*; the operator belongs in icon and marker.
  final String nameShort;
  final List<Bay> bays;

  /// ADR-0001: nothing branches on this.
  final String? vehicleClassTag;

  /// Delta-sync cursor (ADR-0007).
  final Millis updatedAt;
}

/// The driver's connector types. `null` or empty means unlensed (T = 0),
/// which is not a special case: it is the same function with an empty set.
typedef Lens = List<ConnectorType>?;
