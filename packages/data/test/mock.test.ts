/**
 * The mock is a first-class citizen, so it is tested like one. These are the
 * behaviours the BWEZE implementation will have to reproduce, which is the
 * point of testing them against the protocol rather than against the mock's
 * internals.
 */
import { describe, expect, it } from 'vitest';
import { HOUR, MINUTE, distanceMeters } from '@ev-guide/domain';
import { NEAR_LIMIT_MAX, REPORT_PROXIMITY_METERS, createMockRepositories } from '../src/mock.js';
import { REPORTS, SEED_NOW, STATIONS } from '../src/seed.js';

const KIGALI = { lat: -1.9441, lng: 30.0619 };

describe('stationsNear', () => {
  it('ranks distance first, with availability only as the tie-break', async () => {
    const repos = createMockRepositories();
    const rows = await repos.stations.stationsNear({ origin: KIGALI, limit: 6 }, SEED_NOW);

    const distances = rows.map((r) => r.distanceMeters);
    expect(distances).toEqual([...distances].sort((a, b) => a - b));

    // The rule that matters: a free bay far away never outranks a nearer
    // station whose bays nobody has reported.
    const rubavu = rows.find((r) => r.stationId === 'st-rubavu');
    expect(rubavu).toBeUndefined();
  });

  it('honours the requested limit and caps it at the car ceiling', async () => {
    const repos = createMockRepositories();
    expect(await repos.stations.stationsNear({ origin: KIGALI, limit: 3 }, SEED_NOW)).toHaveLength(3);

    const asked = await repos.stations.stationsNear({ origin: KIGALI, limit: 50 }, SEED_NOW);
    expect(asked.length).toBeLessThanOrEqual(NEAR_LIMIT_MAX);
  });

  it('takes an arbitrary origin, never a hardcoded device location', async () => {
    const repos = createMockRepositories();
    const fromMusanze = await repos.stations.stationsNear(
      { origin: { lat: -1.4995, lng: 29.6349 }, limit: 1 },
      SEED_NOW,
    );
    // An App Store reviewer's mock GPS has to be able to reach this.
    expect(fromMusanze[0]?.stationId).toBe('st-musanze');
  });

  it('returns structure, never a formatted distance string', async () => {
    const repos = createMockRepositories();
    const [row] = await repos.stations.stationsNear({ origin: KIGALI, limit: 1 }, SEED_NOW);
    expect(typeof row?.distanceMeters).toBe('number');
    expect(JSON.stringify(row)).not.toMatch(/\d\s?km/);
  });
});

describe('derivation runs at read time', () => {
  it('the same data yields a different answer as the clock moves', async () => {
    const repos = createMockRepositories();
    const at = async (now: number) =>
      (await repos.stations.stationDetail('st-nyarutarama', undefined, now))!;

    const fresh = await at(SEED_NOW);
    expect(fresh.bays.map((b) => b.state)).toContain('Free');

    // Six hours on, the operator window has closed and nothing was resynced.
    const later = await at(SEED_NOW + 6 * HOUR + MINUTE);
    expect(later.bays.every((b) => b.state === 'Unknown')).toBe(true);
  });

  it('an offline source yields Unknown from a 30-second-old report', async () => {
    const repos = createMockRepositories();
    const detail = (await repos.stations.stationDetail('st-nyabugogo', undefined, SEED_NOW))!;
    const bay2 = detail.bays.find((b) => b.bayId === 'st-nyabugogo-bay-2');
    expect(bay2?.state).toBe('Unknown');
  });

  it('exposes per-connector state so a broken gun is visible unlensed', async () => {
    const repos = createMockRepositories();
    const detail = (await repos.stations.stationDetail('st-remera', undefined, SEED_NOW))!;
    const broken = detail.connectors.filter((c) => c.state === 'OutOfService');
    expect(broken).toHaveLength(1);
  });
});

describe('rateCoverage is denominated in plugs', () => {
  it('counts plugs and reports distinct rates on a dual-rate bay', async () => {
    const repos = createMockRepositories();
    const detail = (await repos.stations.stationDetail('st-nyabugogo', undefined, SEED_NOW))!;
    const { confirmedPlugs, totalPlugs, distinctRates } = detail.rateCoverage;

    expect(totalPlugs).toBe(4);
    expect(confirmedPlugs).toBe(4);
    // The dual-gun bay carries 450 and 600; the two DC bays carry 700.
    expect(distinctRates).toEqual([450, 600, 700]);
  });

  it('drops a rate older than its 90-day window', async () => {
    const repos = createMockRepositories();
    const detail = (await repos.stations.stationDetail('st-musanze', undefined, SEED_NOW))!;
    expect(detail.rateCoverage.confirmedPlugs).toBe(0);
    expect(detail.rateCoverage.totalPlugs).toBe(2);
  });
});

describe('report policy', () => {
  const connectorOf = (stationId: string) =>
    STATIONS.find((s) => s.id === stationId)!.bays[0]!.connectors[0]!.id;

  it('rejects an anonymous report: reading is ungated, acting is not', async () => {
    const repos = createMockRepositories();
    const r = await repos.reports.submit({
      connectorId: connectorOf('st-remera'),
      state: 'Free',
      capturedAt: Date.now(),
      sourceOnline: true,
    });
    expect(r).toEqual({ ok: false, reason: 'not-signed-in' });
  });

  it('rejects a report captured too far away', async () => {
    const repos = createMockRepositories({ signedIn: true });
    const r = await repos.reports.submit({
      connectorId: connectorOf('st-remera'),
      state: 'Free',
      capturedAt: Date.now(),
      capturedLocation: { lat: -1.9441, lng: 30.0619 },
      sourceOnline: true,
    });
    expect(r).toEqual({ ok: false, reason: 'too-far' });
  });

  it('accepts a report captured within the gate', async () => {
    const repos = createMockRepositories({ signedIn: true });
    const station = STATIONS.find((s) => s.id === 'st-remera')!;
    const r = await repos.reports.submit({
      connectorId: connectorOf('st-remera'),
      state: 'Free',
      capturedAt: Date.now(),
      capturedLocation: station.geo,
      sourceOnline: true,
    });
    expect(r).toEqual({ ok: true });
  });

  it('gates on the CAPTURED location, so an offline report drains later from elsewhere', async () => {
    const repos = createMockRepositories({ signedIn: true });
    const station = STATIONS.find((s) => s.id === 'st-remera')!;
    // Captured at the station hours ago; submitted now from across town.
    const r = await repos.reports.submit({
      connectorId: connectorOf('st-remera'),
      state: 'Occupied',
      capturedAt: Date.now() - 90 * MINUTE,
      capturedLocation: station.geo,
      sourceOnline: false,
    });
    expect(r).toEqual({ ok: true });
  });

  it('rejects a capturedAt in the future', async () => {
    const repos = createMockRepositories({ signedIn: true });
    const r = await repos.reports.submit({
      connectorId: connectorOf('st-remera'),
      state: 'Free',
      capturedAt: Date.now() + 10 * MINUTE,
      sourceOnline: true,
    });
    expect(r).toEqual({ ok: false, reason: 'captured-in-future' });
  });

  it('the proximity gate is wide enough for a forecourt, tight enough for the road', () => {
    const station = STATIONS[0]!;
    const acrossTheForecourt = { lat: station.geo.lat + 0.0008, lng: station.geo.lng };
    const acrossTown = { lat: station.geo.lat + 0.02, lng: station.geo.lng };
    expect(distanceMeters(station.geo, acrossTheForecourt)).toBeLessThan(REPORT_PROXIMITY_METERS);
    expect(distanceMeters(station.geo, acrossTown)).toBeGreaterThan(REPORT_PROXIMITY_METERS);
  });
});

describe('changedSince', () => {
  it('returns only rows past the cursor and advances it', async () => {
    const repos = createMockRepositories();
    const cursor = SEED_NOW - 10 * 24 * HOUR;
    const { stations, cursor: next } = await repos.stations.changedSince(cursor);
    expect(stations.every((s) => s.updatedAt > cursor)).toBe(true);
    expect(next).toBeGreaterThan(cursor);

    const second = await repos.stations.changedSince(next);
    expect(second.stations).toHaveLength(0);
  });
});

describe('the seed is honest about how little is known', () => {
  it('leaves most connectors unreported, because ~87% Unknown is the normal case', () => {
    const connectors = STATIONS.flatMap((s) => s.bays.flatMap((b) => b.connectors));
    const reported = new Set(REPORTS.map((r) => r.connectorId));
    expect(reported.size / connectors.length).toBeLessThan(0.5);
  });
});
