/**
 * Driver app, first vertical slice.
 *
 * This is not the reference design: `packages/ui`'s components land next, and
 * the 1:1 work belongs there. What this screen proves is the **seam** -
 * ADR-0005's frontend-first arrangement, where the app talks only to
 * `@ev-guide/data`'s protocols and the mock is installed behind them.
 *
 * It also renders availability through the shared grammar rather than
 * composing its own strings, which is the rule the whole spec turns on.
 */
import { useEffect, useMemo, useState } from 'react';
import { FlatList, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { createMockRepositories } from '@ev-guide/data';
import type { TwoLine } from '@ev-guide/domain';
import { color, pt, radius, space, type as typeScale } from '@ev-guide/ui';

/** Kigali city centre. An origin is always passed, never assumed. */
const ORIGIN = { lat: -1.9441, lng: 30.0619 };

export default function App() {
  const repos = useMemo(() => createMockRepositories(), []);
  const [rows, setRows] = useState<readonly TwoLine[]>([]);

  useEffect(() => {
    let alive = true;
    // `now` is passed in, never read inside the derivation, so a test and a
    // screen can disagree about the clock without the domain caring.
    void repos.stations
      .stationsNear({ origin: ORIGIN, limit: 6 }, Date.now())
      .then((r) => {
        if (alive) setRows(r);
      });
    return () => {
      alive = false;
    };
  }, [repos]);

  return (
    <View style={styles.page}>
      <StatusBar style="light" />
      <Text style={styles.display}>Chargers near you</Text>
      <FlatList
        data={rows}
        keyExtractor={(r) => r.stationId}
        contentContainerStyle={styles.list}
        renderItem={({ item }) => <StationRow row={item} />}
      />
    </View>
  );
}

function StationRow({ row }: { row: TwoLine }) {
  return (
    <View style={styles.card}>
      <Text style={styles.title}>{row.nameShort}</Text>
      <Text style={styles.subtitle}>
        {/*
          The distance is formatted HERE, at the edge. The projection returns
          `distanceMeters` as a number and never a string, because the Android
          Auto surface must hand its host a DistanceSpan and may author no
          distance literal of its own.
        */}
        {formatDistance(row.distanceMeters)} · {row.availabilityText}
      </Text>
    </View>
  );
}

function formatDistance(meters: number): string {
  if (meters < 1000) return `${Math.round(meters / 10) * 10} m`;
  return `${(meters / 1000).toFixed(1)} km`;
}

const styles = StyleSheet.create({
  page: {
    flex: 1,
    backgroundColor: color.page,
    paddingHorizontal: pt(space.pageMargin),
    paddingTop: pt(space.sectionGapLarge) * 2,
  },
  display: {
    color: color.text,
    fontSize: typeScale.display,
    fontWeight: '700',
    marginBottom: pt(space.blockGap),
  },
  list: { gap: pt(space.cardMargin) },
  card: {
    backgroundColor: color.surface,
    borderRadius: pt(radius.card),
    padding: pt(space.cardPadding),
  },
  title: {
    color: color.text,
    fontSize: typeScale.title,
    fontWeight: '500',
  },
  subtitle: {
    color: color.text,
    fontSize: typeScale.body,
    fontWeight: '200',
    marginTop: pt(space.titleToSubtitle),
  },
});
