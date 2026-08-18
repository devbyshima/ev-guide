/// Smoke tests: the widgets build on the style layer and render the measured
/// values without re-typing them. The TS package had no component tests;
/// these exist because a Flutter widget has layout behaviour of its own.
library;

import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  testWidgets('EVGuideText renders at the step size with no family named', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const EVGuideText(
          'Chargers near you',
          step: Step.display,
          weight: Weight.bold,
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('Chargers near you'));
    expect(text.style?.fontSize, type.display);
    expect(text.style?.fontWeight, FontWeight.w700);
    // The family arrives from the app, never from here (ADR-0010).
    expect(text.style?.fontFamily, isNull);
    // Old-style figures ride along as a required feature, from the token.
    expect(text.style?.fontFeatures, contains(const FontFeature('onum')));
  });

  testWidgets('EVGuideText lets the app inject a family that passed the band', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const EVGuideText('135 000 RWF/day', fontFamily: 'BandApproved')),
    );
    final text = tester.widget<Text>(find.text('135 000 RWF/day'));
    expect(text.style?.fontFamily, 'BandApproved');
    // Body is the default step and the only one carrying a line height.
    expect(
      text.style?.height,
      closeTo(typeMeta.bodyLineHeight / type.body, 1e-9),
    );
  });

  testWidgets('EVGuideButton keeps the measured height, fires, and dims when '
      'disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: EVGuideButton(
            label: 'Find a charger',
            variant: ButtonVariant.sticky,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Find a charger'));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(EVGuideButton)).height,
      closeTo(size.ctaSticky.h / 3, 5e-5),
    );

    await tester.pumpWidget(
      host(
        Center(
          child: EVGuideButton(
            label: 'Find a charger',
            disabled: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Find a charger'), warnIfMissed: false);
    expect(taps, 1);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);
  });

  testWidgets('StationCard renders words without choosing them', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: StationCard(
            title: 'CTO Motors Group Rentals',
            availabilityText: '2 of 4 free',
            distanceText: '1.2 km',
          ),
        ),
      ),
    );
    expect(find.text('CTO Motors Group Rentals'), findsOneWidget);
    // Already-composed strings, joined at the same seam the TS component
    // used; the card itself authored none of the words.
    expect(find.text('1.2 km · 2 of 4 free'), findsOneWidget);
    expect(find.byType(DragHandle), findsOneWidget);

    await tester.pumpWidget(
      host(
        const Center(
          child: StationCard(
            title: 'Kigali Heights',
            availabilityText: 'No data',
            showHandle: false,
          ),
        ),
      ),
    );
    expect(find.byType(DragHandle), findsNothing);
  });

  testWidgets('the chips build on the style layer at their fixed heights', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FeatureChip(label: 'Fast charge'),
              CategoryChip(label: 'Cinemas'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Fast charge'), findsOneWidget);
    expect(find.text('Cinemas'), findsOneWidget);
    // Fixed heights from the tokens; width fits content.
    expect(
      tester.getSize(find.byType(FeatureChip)).height,
      closeTo(size.featureChipHeight / 3, 5e-5),
    );
    expect(
      tester.getSize(find.byType(CategoryChip)).height,
      closeTo(size.categoryChip.h / 3, 5e-5),
    );
  });
}
