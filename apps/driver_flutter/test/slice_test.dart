/// The slice's smoke test: pumps the app over the mock repositories and
/// asserts the three things the slice promises. The title renders, the mock
/// feeds station cards whose availability words came through the grammar,
/// and the sticky CTA is present.
library;

import 'package:ev_guide_data/ev_guide_data.dart';
import 'package:ev_guide_driver/main.dart';
import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('slice renders title, mock-fed station cards and the CTA', (
    tester,
  ) async {
    await tester.pumpWidget(DriverApp(repositories: createMockRepositories()));
    // stationsNear resolves in a microtask; one more frame shows the rows.
    await tester.pump();

    expect(find.text('Chargers near you'), findsOneWidget);

    final cards = find.byType(StationCard);
    expect(cards, findsWidgets);
    // The words come from the domain grammar, never from a widget; the
    // slice's job is only to carry a non-empty string through.
    final card = tester.widget<StationCard>(cards.first);
    expect(card.availabilityText, isNotEmpty);

    expect(find.text('Find a charger'), findsOneWidget);
  });
}
