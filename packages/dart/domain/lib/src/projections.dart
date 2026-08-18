/// The fixed set of station projections (docs/domain-model.md,
/// "Projections", car constraint 5). They live here so three call sites
/// cannot improvise three different answers.
///
/// **Projections return structure, not formatted strings** (amendment 8):
/// `(distanceMeters, nameShort)`, never `"~2.4 km · SP Remera"`. Android must
/// hand the host a `DistanceSpan` and may author no distance literal, so a
/// projection that pre-formatted its distance would make the Android surface
/// unimplementable.
library;

import 'dart:math';

import 'availability.dart';
import 'decay.dart';
import 'grammar.dart';
import 'types.dart';

const double _earthRadiusM = 6371000;

/// Great-circle distance. Rwanda is small; the spherical model is ample.
double distanceMeters(GeoPoint a, GeoPoint b) {
  double toRad(double d) => d * pi / 180;
  final dLat = toRad(b.lat - a.lat);
  final dLng = toRad(b.lng - a.lng);
  final lat1 = toRad(a.lat);
  final lat2 = toRad(b.lat);
  final h =
      pow(sin(dLat / 2), 2) + pow(sin(dLng / 2), 2) * cos(lat1) * cos(lat2);
  return 2 * _earthRadiusM * asin(sqrt(h));
}

/// one-line: `nameShort` and nothing else.
class OneLine {
  const OneLine({required this.stationId, required this.nameShort});

  final String stationId;
  final String nameShort;
}

/// The structured availability counts carried beside the text.
class TwoLineAvailability {
  const TwoLineAvailability({
    required this.free,
    required this.occupied,
    required this.outOfService,
    required this.unknown,
    required this.baysInScope,
  });

  final int free;
  final int occupied;
  final int outOfService;
  final int unknown;
  final int baysInScope;
}

/// two-line: `nameShort` / `distance · availability`.
///
/// Rate has **no room on a car row** and is a detail-screen field, so it is
/// deliberately absent here rather than optional.
class TwoLine extends OneLine {
  const TwoLine({
    required super.stationId,
    required super.nameShort,
    required this.distanceMeters,
    required this.availabilityText,
    required this.availability,
  });

  final double distanceMeters;
  final String availabilityText;

  /// Kept structured beside the text so a surface can style or re-render the
  /// parts without parsing the string back apart.
  final TwoLineAvailability availability;
}

/// The six CarPlay POI strings, as two triples.
class Triple {
  const Triple({
    required this.stationId,
    required this.title,
    required this.subtitle,
    required this.detail,
  });

  final String stationId;
  final String title;
  final String subtitle;
  final String detail;
}

OneLine oneLine(Station station) =>
    OneLine(stationId: station.id, nameShort: station.nameShort);

TwoLine twoLine(
  Station station,
  GeoPoint origin,
  Lens lens,
  LatestReports latest,
  Millis now, [
  Verbosity verbosity = Verbosity.short,
]) {
  final counts = countBays(station.bays, lens, latest, now);
  return TwoLine(
    stationId: station.id,
    nameShort: station.nameShort,
    distanceMeters: distanceMeters(origin, station.geo),
    availabilityText: grammar(GrammarInput.fromCounts(counts), verbosity).text,
    availability: TwoLineAvailability(
      free: counts.free,
      occupied: counts.occupied,
      outOfService: counts.outOfService,
      unknown: counts.unknown,
      baysInScope: counts.n,
    ),
  );
}

/// picker-triple and card-triple.
///
/// The availability string never goes in a row **title**: title changes burn
/// Android's template quota, so the volatile value must sit in a line the
/// host lets us update cheaply.
Triple pickerTriple(
  Station station,
  GeoPoint origin,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  final t = twoLine(station, origin, lens, latest, now, Verbosity.short);
  return Triple(
    stationId: station.id,
    title: station.nameShort,
    subtitle: t.availabilityText,
    detail: station.name,
  );
}

Triple cardTriple(
  Station station,
  GeoPoint origin,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  final t = twoLine(station, origin, lens, latest, now, Verbosity.full);
  return Triple(
    stationId: station.id,
    title: station.name,
    subtitle: t.availabilityText,
    detail: station.nameShort,
  );
}

/// Per-connector state, reachable in the detail projection (amendment 8).
class ConnectorDetail {
  const ConnectorDetail({
    required this.connectorId,
    required this.bayId,
    required this.type,
    required this.state,
    this.powerKw,
    this.ratePerKwhRwf,
    this.sessionFeeRwf,
    required this.rateConfirmed,
  });

  final String connectorId;
  final String bayId;
  final ConnectorType type;
  final AvailabilityState state;
  final num? powerKw;
  final num? ratePerKwhRwf;
  final num? sessionFeeRwf;
  final bool rateConfirmed;
}

/// One bay's derived state in the detail projection.
class BayDetail {
  const BayDetail({required this.bayId, required this.state});

  final String bayId;
  final AvailabilityState state;
}

class StationDetail {
  const StationDetail({
    required this.stationId,
    required this.name,
    required this.nameShort,
    required this.geo,
    required this.bays,
    required this.connectors,
    required this.rateCoverage,
  });

  final String stationId;
  final String name;
  final String nameShort;
  final GeoPoint geo;
  final List<BayDetail> bays;

  /// Per-connector state must be reachable so a known-broken gun is visible
  /// to a driver **with no profile set**: the unlensed view must not hide it.
  final List<ConnectorDetail> connectors;
  final RateCoverage rateCoverage;
}

/// `rateCoverage(station)` is denominated in **plugs, not bays** (amendment
/// 6), because rate is a Connector property and a dual-gun pedestal can carry
/// two different rates.
class RateCoverage {
  const RateCoverage({
    required this.confirmedPlugs,
    required this.totalPlugs,
    required this.distinctRates,
    this.oldestConfirmedAt,
    this.sessionFeeRwf,
  });

  final int confirmedPlugs;
  final int totalPlugs;
  final List<num> distinctRates;
  final Millis? oldestConfirmedAt;
  final num? sessionFeeRwf;
}

RateCoverage rateCoverage(Station station, Millis now) {
  final connectors = [for (final b in station.bays) ...b.connectors];
  final rates = <num>{};
  var confirmed = 0;
  Millis? oldest;
  num? sessionFee;

  for (final c in connectors) {
    final rate = c.ratePerKwhRwf;
    final at = c.rateConfirmedAt;
    final fresh = rate != null && at != null && now - at <= rateWindow;
    if (!fresh) continue;
    confirmed += 1;
    rates.add(rate);
    if (oldest == null || at < oldest) oldest = at;
    if (c.sessionFeeRwf != null) sessionFee = c.sessionFeeRwf;
  }

  return RateCoverage(
    confirmedPlugs: confirmed,
    totalPlugs: connectors.length,
    distinctRates: [...rates]..sort(),
    oldestConfirmedAt: oldest,
    sessionFeeRwf: sessionFee,
  );
}

StationDetail stationDetail(
  Station station,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  return StationDetail(
    stationId: station.id,
    name: station.name,
    nameShort: station.nameShort,
    geo: station.geo,
    bays: [
      for (final b in station.bays)
        BayDetail(bayId: b.id, state: bayStateUnder(b, lens, latest, now)),
    ],
    connectors: [
      for (final b in station.bays)
        for (final c in b.connectors)
          ConnectorDetail(
            connectorId: c.id,
            bayId: b.id,
            type: c.type,
            // Unlensed on purpose: the detail screen shows every gun's own
            // state, so a broken plug is visible to a driver with no profile.
            state: effective(c, latest, now).state,
            powerKw: c.powerKw,
            ratePerKwhRwf: c.ratePerKwhRwf,
            sessionFeeRwf: c.sessionFeeRwf,
            rateConfirmed:
                c.ratePerKwhRwf != null &&
                c.rateConfirmedAt != null &&
                now - c.rateConfirmedAt! <= rateWindow,
          ),
    ],
    rateCoverage: rateCoverage(station, now),
  );
}
