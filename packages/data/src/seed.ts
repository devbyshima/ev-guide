/**
 * The seed dataset for the mock repositories.
 *
 * **Every station here is fictional.** It is shaped like Kigali (plausible
 * coordinates, plausible operator mix, plausible connector families per ticket
 * 02) but no row asserts that a real charger exists at a real address. Two
 * reasons, both deliberate:
 *
 * 1. Ticket 26 ruled out any dependence on Kabisa's feed, and copying its
 *    contents into a seed file would be that dependence with extra steps.
 * 2. Ticket 28 says real data arrives via a launch-week studio survey. A
 *    development fixture that looks like real data is the fastest way for a
 *    fixture to end up in a listing.
 *
 * The `FICTIONAL` marker is exported so a build can assert it never ships.
 */
import type { Bay, Connector, Owner, Report, Station } from '@ev-guide/domain';
import { DAY, HOUR, MINUTE } from '@ev-guide/domain';

export const FICTIONAL = true as const;

export const SEED_NOW = 1_760_000_000_000;

export const OWNERS: readonly Owner[] = [
  { id: 'own-1', displayName: 'Umuriro Power', shortName: 'Umuriro', markerLabel: 'UMU', iconRef: 'owner/umuriro' },
  { id: 'own-2', displayName: 'Rwenzori Charge', shortName: 'Rwenzori', markerLabel: 'RWZ', iconRef: 'owner/rwenzori' },
  { id: 'own-3', displayName: 'Ikaze Mobility', shortName: 'Ikaze', markerLabel: 'IKZ', iconRef: 'owner/ikaze' },
];

const T2 = 'IEC_62196_T2';
const CCS2 = 'IEC_62196_T2_COMBO';
const GBT_DC = 'GBT_DC';
const GBT_AC = 'GBT_AC';

let n = 0;
function c(
  type: string,
  bayId: string,
  over: Partial<Connector> = {},
): Connector {
  n += 1;
  return { id: `con-${n}`, bayId, type, ...over };
}

function bay(stationId: string, index: number, connectors: (id: string) => Connector[]): Bay {
  const id = `${stationId}-bay-${index}`;
  return { id, stationId, connectors: connectors(id) };
}

const RATE_FRESH = SEED_NOW - 10 * DAY;

/**
 * Eight stations, chosen to exercise the shapes the grammar cares about:
 * a single-bay site, a dual-gun bay with two rates, a site with no rate at
 * all, and a site whose every bay is unreported (which is the normal case).
 */
export const STATIONS: readonly Station[] = [
  {
    id: 'st-remera',
    ownerId: 'own-1',
    geo: { lat: -1.9536, lng: 30.1284 },
    name: 'Umuriro Remera Terminal',
    nameShort: 'Remera Terminal',
    updatedAt: SEED_NOW - 2 * DAY,
    bays: [
      bay('st-remera', 1, (b) => [
        c(T2, b, { powerKw: 22, ratePerKwhRwf: 600, rateConfirmedAt: RATE_FRESH }),
        c(GBT_DC, b, { powerKw: 60, ratePerKwhRwf: 750, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-remera', 2, (b) => [
        c(T2, b, { powerKw: 22, ratePerKwhRwf: 600, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-remera', 3, (b) => [
        c(CCS2, b, { powerKw: 120, ratePerKwhRwf: 750, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-remera', 4, (b) => [c(GBT_AC, b, { powerKw: 7 })]),
    ],
  },
  {
    id: 'st-nyarutarama',
    ownerId: 'own-2',
    geo: { lat: -1.9366, lng: 30.1101 },
    name: 'Rwenzori Nyarutarama',
    nameShort: 'Nyarutarama',
    updatedAt: SEED_NOW - 5 * DAY,
    bays: [
      bay('st-nyarutarama', 1, (b) => [
        c(CCS2, b, { powerKw: 150, ratePerKwhRwf: 800, sessionFeeRwf: 500, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-nyarutarama', 2, (b) => [
        c(CCS2, b, { powerKw: 150, ratePerKwhRwf: 800, sessionFeeRwf: 500, rateConfirmedAt: RATE_FRESH }),
      ]),
    ],
  },
  {
    id: 'st-kimihurura',
    ownerId: 'own-1',
    geo: { lat: -1.9508, lng: 30.0925 },
    name: 'Umuriro Kimihurura',
    nameShort: 'Kimihurura',
    updatedAt: SEED_NOW - 9 * DAY,
    // One bay, to exercise the singular forms (no "1 of 1", no "All 1").
    bays: [bay('st-kimihurura', 1, (b) => [c(T2, b, { powerKw: 22 })])],
  },
  {
    id: 'st-nyabugogo',
    ownerId: 'own-3',
    geo: { lat: -1.9397, lng: 30.0444 },
    name: 'Ikaze Nyabugogo Hub',
    nameShort: 'Nyabugogo Hub',
    updatedAt: SEED_NOW - 1 * DAY,
    bays: [
      bay('st-nyabugogo', 1, (b) => [
        c(GBT_DC, b, { powerKw: 240, ratePerKwhRwf: 700, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-nyabugogo', 2, (b) => [
        c(GBT_DC, b, { powerKw: 240, ratePerKwhRwf: 700, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-nyabugogo', 3, (b) => [
        // Two guns, two different rates: the case law 7 exists for.
        c(GBT_AC, b, { powerKw: 7, ratePerKwhRwf: 450, rateConfirmedAt: RATE_FRESH }),
        c(T2, b, { powerKw: 22, ratePerKwhRwf: 600, rateConfirmedAt: RATE_FRESH }),
      ]),
    ],
  },
  {
    id: 'st-kacyiru',
    ownerId: 'own-2',
    geo: { lat: -1.9297, lng: 30.0919 },
    name: 'Rwenzori Kacyiru',
    nameShort: 'Kacyiru',
    updatedAt: SEED_NOW - 20 * DAY,
    // No rate anywhere: "no confirmed rate" must be sayable, and stated.
    bays: [
      bay('st-kacyiru', 1, (b) => [c(T2, b, { powerKw: 22 })]),
      bay('st-kacyiru', 2, (b) => [c(T2, b, { powerKw: 22 })]),
    ],
  },
  {
    id: 'st-gikondo',
    ownerId: 'own-3',
    geo: { lat: -1.9862, lng: 30.0761 },
    name: 'Ikaze Gikondo',
    nameShort: 'Gikondo',
    updatedAt: SEED_NOW - 30 * DAY,
    bays: [
      bay('st-gikondo', 1, (b) => [
        c(GBT_DC, b, { powerKw: 60, ratePerKwhRwf: 700, rateConfirmedAt: RATE_FRESH }),
      ]),
      bay('st-gikondo', 2, (b) => [c(GBT_AC, b, { powerKw: 7 })]),
      bay('st-gikondo', 3, (b) => [c(GBT_AC, b, { powerKw: 7 })]),
    ],
  },
  {
    id: 'st-musanze',
    ownerId: 'own-1',
    geo: { lat: -1.4995, lng: 29.6349 },
    name: 'Umuriro Musanze',
    nameShort: 'Musanze',
    updatedAt: SEED_NOW - 45 * DAY,
    bays: [
      bay('st-musanze', 1, (b) => [
        c(CCS2, b, { powerKw: 120, ratePerKwhRwf: 850, rateConfirmedAt: SEED_NOW - 200 * DAY }),
      ]),
      bay('st-musanze', 2, (b) => [c(T2, b, { powerKw: 22 })]),
    ],
  },
  {
    id: 'st-rubavu',
    ownerId: 'own-2',
    geo: { lat: -1.6777, lng: 29.2596 },
    name: 'Rwenzori Rubavu',
    nameShort: 'Rubavu',
    updatedAt: SEED_NOW - 60 * DAY,
    bays: [bay('st-rubavu', 1, (b) => [c(GBT_DC, b, { powerKw: 60 })])],
  },
];

const conIds = (stationId: string): string[] =>
  STATIONS.find((s) => s.id === stationId)!.bays.flatMap((b) => b.connectors.map((c2) => c2.id));

/**
 * Reports are sparse **on purpose**. Ticket 28: availability is a bonus, never
 * a promise, and roughly 87% Unknown is the honest normal case. A seed that
 * reported every bay would make every screen look like a product we do not
 * have.
 */
export const REPORTS: readonly Report[] = [
  {
    connectorId: conIds('st-remera')[0]!,
    state: 'Occupied',
    source: 'operator',
    reporterId: 'op-1',
    capturedAt: SEED_NOW - 20 * MINUTE,
    receivedAt: SEED_NOW - 20 * MINUTE,
    sourceOnline: true,
  },
  {
    connectorId: conIds('st-remera')[3]!,
    state: 'Free',
    source: 'driver',
    reporterId: 'dr-1',
    capturedAt: SEED_NOW - 40 * MINUTE,
    receivedAt: SEED_NOW - 38 * MINUTE,
    sourceOnline: true,
  },
  {
    connectorId: conIds('st-remera')[4]!,
    state: 'OutOfService',
    source: 'operator',
    reporterId: 'op-1',
    capturedAt: SEED_NOW - 3 * DAY,
    receivedAt: SEED_NOW - 3 * DAY,
    sourceOnline: true,
  },
  {
    connectorId: conIds('st-nyarutarama')[0]!,
    state: 'Free',
    source: 'operator',
    reporterId: 'op-2',
    capturedAt: SEED_NOW - 2 * HOUR,
    receivedAt: SEED_NOW - 2 * HOUR,
    sourceOnline: true,
  },
  {
    connectorId: conIds('st-nyarutarama')[1]!,
    state: 'Occupied',
    source: 'operator',
    reporterId: 'op-2',
    capturedAt: SEED_NOW - 2 * HOUR,
    receivedAt: SEED_NOW - 2 * HOUR,
    sourceOnline: true,
  },
  {
    // Already decayed at SEED_NOW: a driver report from 5 hours ago. Present
    // so the seed exercises the boundary rather than only fresh rows.
    connectorId: conIds('st-nyabugogo')[0]!,
    state: 'Free',
    source: 'driver',
    reporterId: 'dr-2',
    capturedAt: SEED_NOW - 5 * HOUR,
    receivedAt: SEED_NOW - 5 * HOUR,
    sourceOnline: true,
  },
  {
    // Offline source, 30 seconds old: must derive Unknown regardless.
    connectorId: conIds('st-nyabugogo')[1]!,
    state: 'Free',
    source: 'operator',
    reporterId: 'op-3',
    capturedAt: SEED_NOW - 30_000,
    receivedAt: SEED_NOW - 30_000,
    sourceOnline: false,
  },
];
