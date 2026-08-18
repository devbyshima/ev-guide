/// The seed dataset for the mock repositories.
///
/// **Every station here is fictional.** It is shaped like Kigali (plausible
/// coordinates, plausible operator mix, plausible connector families per
/// ticket 02) but no row asserts that a real charger exists at a real
/// address. Two reasons, both deliberate:
///
/// 1. Ticket 26 ruled out any dependence on Kabisa's feed, and copying its
///    contents into a seed file would be that dependence with extra steps.
/// 2. Ticket 28 says real data arrives via a launch-week studio survey. A
///    development fixture that looks like real data is the fastest way for a
///    fixture to end up in a listing.
///
/// The [fictional] marker is exported so a build can assert it never ships.
///
/// Timestamps here are **ages, not instants** (ADR-0012). The TypeScript
/// seed pinned `SEED_NOW` to a fixed 2025 epoch, so once the wall clock
/// moved far enough past it every report had decayed and every station
/// derived Unknown. Latent in TS, fixed in this port: every timestamp is an
/// offset subtracted from the caller's `now`, so each row keeps its intended
/// age at any render time. Station timestamps anchor the same way, because
/// rates carry their own 90-day freshness window and would have gone stale
/// exactly like the reports.
library;

import 'package:ev_guide_domain/ev_guide_domain.dart';

const bool fictional = true;

const List<Owner> seedOwners = [
  Owner(
    id: 'own-1',
    displayName: 'Umuriro Power',
    shortName: 'Umuriro',
    markerLabel: 'UMU',
    iconRef: 'owner/umuriro',
  ),
  Owner(
    id: 'own-2',
    displayName: 'Rwenzori Charge',
    shortName: 'Rwenzori',
    markerLabel: 'RWZ',
    iconRef: 'owner/rwenzori',
  ),
  Owner(
    id: 'own-3',
    displayName: 'Ikaze Mobility',
    shortName: 'Ikaze',
    markerLabel: 'IKZ',
    iconRef: 'owner/ikaze',
  ),
];

const _t2 = ConnectorType.iec62196T2;
const _ccs2 = ConnectorType.iec62196T2Combo;
const _gbtDc = ConnectorType.gbtDc;
const _gbtAc = ConnectorType.gbtAc;

/// Eight stations, chosen to exercise the shapes the grammar cares about:
/// a single-bay site, a dual-gun bay with two rates, a site with no rate at
/// all, and a site whose every bay is unreported (which is the normal case).
///
/// Anchored to the caller's `now`: `updatedAt` and `rateConfirmedAt` are
/// built as `now` minus each row's intended age.
List<Station> seedStations({required Millis now}) {
  // Connector ids are deterministic: the counter restarts on every build, so
  // `con-N` names the same physical plug for any `now`.
  var n = 0;
  Connector plug(
    ConnectorType type,
    String bayId, {
    num? powerKw,
    num? ratePerKwhRwf,
    num? sessionFeeRwf,
    Millis? rateConfirmedAt,
  }) {
    n += 1;
    return Connector(
      id: 'con-$n',
      bayId: bayId,
      type: type,
      powerKw: powerKw,
      ratePerKwhRwf: ratePerKwhRwf,
      sessionFeeRwf: sessionFeeRwf,
      rateConfirmedAt: rateConfirmedAt,
    );
  }

  Bay bay(
    String stationId,
    int index,
    List<Connector> Function(String bayId) connectors,
  ) {
    final id = '$stationId-bay-$index';
    return Bay(id: id, stationId: stationId, connectors: connectors(id));
  }

  final rateFresh = now - 10 * day;

  return [
    Station(
      id: 'st-remera',
      ownerId: 'own-1',
      geo: const GeoPoint(lat: -1.9536, lng: 30.1284),
      name: 'Umuriro Remera Terminal',
      nameShort: 'Remera Terminal',
      updatedAt: now - 2 * day,
      bays: [
        bay(
          'st-remera',
          1,
          (b) => [
            plug(
              _t2,
              b,
              powerKw: 22,
              ratePerKwhRwf: 600,
              rateConfirmedAt: rateFresh,
            ),
            plug(
              _gbtDc,
              b,
              powerKw: 60,
              ratePerKwhRwf: 750,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay(
          'st-remera',
          2,
          (b) => [
            plug(
              _t2,
              b,
              powerKw: 22,
              ratePerKwhRwf: 600,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay(
          'st-remera',
          3,
          (b) => [
            plug(
              _ccs2,
              b,
              powerKw: 120,
              ratePerKwhRwf: 750,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay('st-remera', 4, (b) => [plug(_gbtAc, b, powerKw: 7)]),
      ],
    ),
    Station(
      id: 'st-nyarutarama',
      ownerId: 'own-2',
      geo: const GeoPoint(lat: -1.9366, lng: 30.1101),
      name: 'Rwenzori Nyarutarama',
      nameShort: 'Nyarutarama',
      updatedAt: now - 5 * day,
      bays: [
        bay(
          'st-nyarutarama',
          1,
          (b) => [
            plug(
              _ccs2,
              b,
              powerKw: 150,
              ratePerKwhRwf: 800,
              sessionFeeRwf: 500,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay(
          'st-nyarutarama',
          2,
          (b) => [
            plug(
              _ccs2,
              b,
              powerKw: 150,
              ratePerKwhRwf: 800,
              sessionFeeRwf: 500,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
      ],
    ),
    Station(
      id: 'st-kimihurura',
      ownerId: 'own-1',
      geo: const GeoPoint(lat: -1.9508, lng: 30.0925),
      name: 'Umuriro Kimihurura',
      nameShort: 'Kimihurura',
      updatedAt: now - 9 * day,
      // One bay, to exercise the singular forms (no "1 of 1", no "All 1").
      bays: [
        bay('st-kimihurura', 1, (b) => [plug(_t2, b, powerKw: 22)]),
      ],
    ),
    Station(
      id: 'st-nyabugogo',
      ownerId: 'own-3',
      geo: const GeoPoint(lat: -1.9397, lng: 30.0444),
      name: 'Ikaze Nyabugogo Hub',
      nameShort: 'Nyabugogo Hub',
      updatedAt: now - 1 * day,
      bays: [
        bay(
          'st-nyabugogo',
          1,
          (b) => [
            plug(
              _gbtDc,
              b,
              powerKw: 240,
              ratePerKwhRwf: 700,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay(
          'st-nyabugogo',
          2,
          (b) => [
            plug(
              _gbtDc,
              b,
              powerKw: 240,
              ratePerKwhRwf: 700,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay(
          'st-nyabugogo',
          3,
          (b) => [
            // Two guns, two different rates: the case law 7 exists for.
            plug(
              _gbtAc,
              b,
              powerKw: 7,
              ratePerKwhRwf: 450,
              rateConfirmedAt: rateFresh,
            ),
            plug(
              _t2,
              b,
              powerKw: 22,
              ratePerKwhRwf: 600,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
      ],
    ),
    Station(
      id: 'st-kacyiru',
      ownerId: 'own-2',
      geo: const GeoPoint(lat: -1.9297, lng: 30.0919),
      name: 'Rwenzori Kacyiru',
      nameShort: 'Kacyiru',
      updatedAt: now - 20 * day,
      // No rate anywhere: "no confirmed rate" must be sayable, and stated.
      bays: [
        bay('st-kacyiru', 1, (b) => [plug(_t2, b, powerKw: 22)]),
        bay('st-kacyiru', 2, (b) => [plug(_t2, b, powerKw: 22)]),
      ],
    ),
    Station(
      id: 'st-gikondo',
      ownerId: 'own-3',
      geo: const GeoPoint(lat: -1.9862, lng: 30.0761),
      name: 'Ikaze Gikondo',
      nameShort: 'Gikondo',
      updatedAt: now - 30 * day,
      bays: [
        bay(
          'st-gikondo',
          1,
          (b) => [
            plug(
              _gbtDc,
              b,
              powerKw: 60,
              ratePerKwhRwf: 700,
              rateConfirmedAt: rateFresh,
            ),
          ],
        ),
        bay('st-gikondo', 2, (b) => [plug(_gbtAc, b, powerKw: 7)]),
        bay('st-gikondo', 3, (b) => [plug(_gbtAc, b, powerKw: 7)]),
      ],
    ),
    Station(
      id: 'st-musanze',
      ownerId: 'own-1',
      geo: const GeoPoint(lat: -1.4995, lng: 29.6349),
      name: 'Umuriro Musanze',
      nameShort: 'Musanze',
      updatedAt: now - 45 * day,
      bays: [
        bay(
          'st-musanze',
          1,
          (b) => [
            // Confirmed 200 days ago, past the 90-day rate window on purpose.
            plug(
              _ccs2,
              b,
              powerKw: 120,
              ratePerKwhRwf: 850,
              rateConfirmedAt: now - 200 * day,
            ),
          ],
        ),
        bay('st-musanze', 2, (b) => [plug(_t2, b, powerKw: 22)]),
      ],
    ),
    Station(
      id: 'st-rubavu',
      ownerId: 'own-2',
      geo: const GeoPoint(lat: -1.6777, lng: 29.2596),
      name: 'Rwenzori Rubavu',
      nameShort: 'Rubavu',
      updatedAt: now - 60 * day,
      bays: [
        bay('st-rubavu', 1, (b) => [plug(_gbtDc, b, powerKw: 60)]),
      ],
    ),
  ];
}

/// Reports are sparse **on purpose**. Ticket 28: availability is a bonus,
/// never a promise, and roughly 87% Unknown is the honest normal case. A seed
/// that reported every bay would make every screen look like a product we do
/// not have.
///
/// Each report's `capturedAt` is `now` minus the age it carried relative to
/// the TypeScript seed's `SEED_NOW`, so the fresh rows stay fresh and the
/// deliberately-decayed row stays decayed, at any render time (ADR-0012).
List<Report> seedReports({required Millis now}) {
  // Connector ids are deterministic, so a throwaway build of the stations
  // resolves the same ids as any other.
  final stations = seedStations(now: now);
  List<String> conIds(String stationId) => [
    for (final b in stations.firstWhere((s) => s.id == stationId).bays)
      for (final c in b.connectors) c.id,
  ];

  return [
    Report(
      connectorId: conIds('st-remera')[0],
      state: ReportedState.occupied,
      source: ReportSource.operator,
      reporterId: 'op-1',
      capturedAt: now - 20 * minute,
      receivedAt: now - 20 * minute,
      sourceOnline: true,
    ),
    Report(
      connectorId: conIds('st-remera')[3],
      state: ReportedState.free,
      source: ReportSource.driver,
      reporterId: 'dr-1',
      capturedAt: now - 40 * minute,
      receivedAt: now - 38 * minute,
      sourceOnline: true,
    ),
    Report(
      connectorId: conIds('st-remera')[4],
      state: ReportedState.outOfService,
      source: ReportSource.operator,
      reporterId: 'op-1',
      capturedAt: now - 3 * day,
      receivedAt: now - 3 * day,
      sourceOnline: true,
    ),
    Report(
      connectorId: conIds('st-nyarutarama')[0],
      state: ReportedState.free,
      source: ReportSource.operator,
      reporterId: 'op-2',
      capturedAt: now - 2 * hour,
      receivedAt: now - 2 * hour,
      sourceOnline: true,
    ),
    Report(
      connectorId: conIds('st-nyarutarama')[1],
      state: ReportedState.occupied,
      source: ReportSource.operator,
      reporterId: 'op-2',
      capturedAt: now - 2 * hour,
      receivedAt: now - 2 * hour,
      sourceOnline: true,
    ),
    // Already decayed at `now`: a driver report from 5 hours ago. Present so
    // the seed exercises the boundary rather than only fresh rows.
    Report(
      connectorId: conIds('st-nyabugogo')[0],
      state: ReportedState.free,
      source: ReportSource.driver,
      reporterId: 'dr-2',
      capturedAt: now - 5 * hour,
      receivedAt: now - 5 * hour,
      sourceOnline: true,
    ),
    // Offline source, 30 seconds old: must derive Unknown regardless.
    Report(
      connectorId: conIds('st-nyabugogo')[1],
      state: ReportedState.free,
      source: ReportSource.operator,
      reporterId: 'op-3',
      capturedAt: now - 30000,
      receivedAt: now - 30000,
      sourceOnline: false,
    ),
  ];
}
