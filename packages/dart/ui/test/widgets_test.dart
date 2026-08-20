/// Smoke tests: the widgets build on the style layer and render the measured
/// values without re-typing them. The TS package had no component tests;
/// these exist because a Flutter widget has layout behaviour of its own.
library;

import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

/// A live handler, as a constant, so a button under test can be `const`.
void noop() {}

/// Everything the press and inert rules govern: the paint and the geometry.
///
/// Deliberately excludes the semantics node. `inert` does change `enabled`
/// there, and that is a statement to assistive technology rather than a style
/// - section 12.1's "changes nothing visually" governs paint, which is what
/// this reads.
({Decoration? decoration, Size size, TextStyle? label, int depth}) paintOf(
  WidgetTester tester,
) {
  Finder inButton(Finder matching) =>
      find.descendant(of: find.byType(EVGuideButton), matching: matching);
  return (
    decoration: tester
        .widget<Container>(inButton(find.byType(Container)))
        .decoration,
    size: tester.getSize(find.byType(EVGuideButton)),
    label: tester.widget<Text>(inButton(find.byType(Text))).style,
    // Named channels catch a fill, geometry or label swap. The count catches
    // the shape the drift actually took: a wrapper slipped over the child,
    // which changes no property this record reads by name.
    depth: tester.widgetList(inButton(find.byWidgetPredicate((_) => true))).length,
  );
}

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

  testWidgets('EVGuideButton keeps the measured height and fires', (
    tester,
  ) async {
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
  });

  // Ticket 31 section 12.1's own tests for `PressableSurface`, applied to the
  // one control that exists today. (b) the pressed tree is identical to the
  // resting tree; (c) `inert` changes no style and blocks every tap.
  //
  // This replaces an assertion that the button "dims when disabled", which
  // locked in the two things section 4.3 and section 5.2 forbid. It read the
  // 0.85/0.5 ramp as the design and would have failed a correct widget.
  testWidgets('the pressed tree is identical to the resting tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: EVGuideButton(label: 'Find a charger', onPressed: noop),
        ),
      ),
    );
    final resting = paintOf(tester);

    // Hold the finger down: this is the whole state the rule governs.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(EVGuideButton)),
    );
    addTearDown(() => gesture.up());
    await tester.pumpAndSettle();

    expect(paintOf(tester), resting);
    // Named separately from the tree comparison because it is the specific
    // channel section 4.1 priced and rejected, and the one this widget shipped.
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('inert changes no style and blocks every tap', (tester) async {
    var taps = 0;
    Widget button({required bool inert}) => host(
      Center(
        child: EVGuideButton(
          label: 'Save',
          inert: inert,
          onPressed: () => taps++,
        ),
      ),
    );

    await tester.pumpWidget(button(inert: false));
    final live = paintOf(tester);

    await tester.pumpWidget(button(inert: true));
    expect(paintOf(tester), live);
    expect(find.byType(Opacity), findsNothing);

    await tester.tap(find.byType(EVGuideButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);

    // Case (c) is transient by definition, so the control must come back
    // without the caller rebuilding it differently.
    await tester.pumpWidget(button(inert: false));
    await tester.tap(find.byType(EVGuideButton));
    expect(taps, 1);
  });

  testWidgets('an inert control absorbs the tap rather than passing it '
      'through', (tester) async {
    var behind = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 400,
            height: 200,
            child: Stack(
              children: [
                // Stands in for the live map under D-01's CTA.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => behind++,
                    child: const SizedBox.expand(),
                  ),
                ),
                const Center(
                  child: EVGuideButton(label: 'Save', inert: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(EVGuideButton), warnIfMissed: false);
    await tester.pump();
    expect(behind, 0);
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
