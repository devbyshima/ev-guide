/// Driver app, first vertical slice: the ADR-0012 Flutter port of the Expo
/// slice, same seams, same reasoning.
///
/// Not the reference layout yet: what this proves is the two seams. Data
/// comes only through `ev_guide_data`'s protocols (ADR-0005), and every
/// pixel value and every availability word comes from `ev_guide_ui` and
/// `ev_guide_domain`. This file authors **no measurement and no
/// vocabulary**.
library;

import 'package:ev_guide_data/ev_guide_data.dart';
import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

/// Kigali city centre. An origin is always passed, never assumed.
const GeoPoint _origin = GeoPoint(lat: -1.9441, lng: 30.0619);

void main() {
  // The composition root, and the one place allowed to name the mock
  // (ADR-0006). Everything below sees only the ADR-0005 protocols, so the
  // BWEZE implementation can arrive behind the same seam without a screen
  // changing.
  runApp(DriverApp(repositories: createMockRepositories()));
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key, required this.repositories});

  final Repositories repositories;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Guide',
      debugShowCheckedModeBanner: false,
      // Pinned dark: the palette has one ground and one text colour, so
      // there is no light theme to offer. The scaffold ground is the page
      // token, never a Material default.
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: color.page,
      ),
      home: NearbyChargersScreen(stations: repositories.stations),
    );
  }
}

/// The slice's one screen. It holds a [StationRepository] and nothing wider,
/// so it cannot reach the mock's dev handle and the seam stays honest.
class NearbyChargersScreen extends StatefulWidget {
  const NearbyChargersScreen({super.key, required this.stations});

  final StationRepository stations;

  @override
  State<NearbyChargersScreen> createState() => _NearbyChargersScreenState();
}

class _NearbyChargersScreenState extends State<NearbyChargersScreen> {
  List<TwoLine> _rows = const [];

  @override
  void initState() {
    super.initState();
    // Evaluated at the current clock: availability is derived from raw
    // reports at read time, never stored (ADR-0008).
    widget.stations
        .stationsNear(
          const NearQuery(origin: _origin, limit: 6),
          DateTime.now().millisecondsSinceEpoch,
        )
        .then((rows) {
          // The RN slice guarded its setState with an `alive` flag;
          // `mounted` is the same guard.
          if (mounted) setState(() => _rows = rows);
        });
  }

  @override
  Widget build(BuildContext context) {
    final page = pageStyle();
    return Scaffold(
      // The Expo slice's light status bar over the dark page.
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.only(
            left: page.paddingHorizontal,
            right: page.paddingHorizontal,
            top: pt(space.sectionGapLarge) * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EVGuideText(
                'Chargers near you',
                step: Step.display,
                weight: Weight.bold,
              ),
              SizedBox(height: pt(space.blockGap)),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: pt(space.sectionGap)),
                  itemCount: _rows.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: pt(space.cardMargin)),
                  itemBuilder: (context, index) {
                    final item = _rows[index];
                    return StationCard(
                      title: item.nameShort,
                      // Straight from the grammar. This screen must never
                      // build a string like "2 of 4 free" itself: the eight
                      // display laws are enforced in one place and this is
                      // not it.
                      availabilityText: item.availabilityText,
                      distanceText: formatDistance(item.distanceMeters),
                      showHandle: false,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: pt(space.sectionGap)),
                child: const EVGuideButton(
                  label: 'Find a charger',
                  variant: ButtonVariant.sticky,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formatted **at the edge**, on purpose. The projection returns
/// `distanceMeters` as a number: Android Auto must hand its host a
/// `DistanceSpan` and may author no distance literal of its own, so a
/// pre-formatted distance in the projection would make that surface
/// unimplementable.
String formatDistance(double meters) {
  if (meters < 1000) return '${(meters / 10).round() * 10} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
