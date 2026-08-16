/**
 * Driver app, first vertical slice.
 *
 * Not the reference layout yet: what this proves is the two seams. Data comes
 * only through `@ev-guide/data`'s protocols (ADR-0005), and every pixel value
 * and every availability word comes from `@ev-guide/ui` and
 * `@ev-guide/domain`. This file authors **no measurement and no vocabulary**.
 */
import { useEffect, useMemo, useState } from 'react';
import { FlatList, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { createMockRepositories } from '@ev-guide/data';
import type { TwoLine } from '@ev-guide/domain';
import { Button, StationCard, Text, pageStyle, pt, space } from '@ev-guide/ui';

/** Kigali city centre. An origin is always passed, never assumed. */
const ORIGIN = { lat: -1.9441, lng: 30.0619 };

export default function App() {
  const repos = useMemo(() => createMockRepositories(), []);
  const [rows, setRows] = useState<readonly TwoLine[]>([]);

  useEffect(() => {
    let alive = true;
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
    <View style={[pageStyle(), { paddingTop: pt(space.sectionGapLarge) * 2 }]}>
      <StatusBar style="light" />
      <Text step="display" weight="bold" style={{ marginBottom: pt(space.blockGap) }}>
        Chargers near you
      </Text>

      <FlatList
        data={rows}
        keyExtractor={(r) => r.stationId}
        contentContainerStyle={{ gap: pt(space.cardMargin), paddingBottom: pt(space.sectionGap) }}
        renderItem={({ item }) => (
          <StationCard
            title={item.nameShort}
            /*
             * Straight from the grammar. This screen must never build a
             * string like "2 of 4 free" itself: the eight display laws are
             * enforced in one place and this is not it.
             */
            availabilityText={item.availabilityText}
            distanceText={formatDistance(item.distanceMeters)}
            showHandle={false}
          />
        )}
      />

      <Button
        label="Find a charger"
        variant="sticky"
        style={{ marginBottom: pt(space.sectionGap) }}
      />
    </View>
  );
}

/**
 * Formatted **at the edge**, on purpose. The projection returns
 * `distanceMeters` as a number: Android Auto must hand its host a
 * `DistanceSpan` and may author no distance literal of its own, so a
 * pre-formatted distance in the projection would make that surface
 * unimplementable.
 */
function formatDistance(meters: number): string {
  if (meters < 1000) return `${Math.round(meters / 10) * 10} m`;
  return `${(meters / 1000).toFixed(1)} km`;
}
