import 'package:flutter/widgets.dart';

import '../styles.dart';
import 'drag_handle.dart';
import 'ev_guide_text.dart';

/// The `03` container. A **floating card, not a bottom sheet**: rounded on
/// all four corners, never anchored to the screen edge. Not built on a sheet
/// primitive, whose whole contract is the anchoring this card does not do.
///
/// **The one rule that outranks the others:** no widget here composes an
/// availability string. Words come from the domain grammar, which is the
/// only place the eight display laws are enforced. A widget that builds its
/// own "2 of 4 free" reintroduces exactly the failure that made
/// `availability-display.md` a single shared document.
class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.title,
    required this.availabilityText,
    this.distanceText,
    this.thumbnail,
    this.trailing,
    this.showHandle = true,
  });

  final String title;

  /// Already-composed availability text, from the domain grammar. Typed as a
  /// plain [String] on purpose: this widget may **render** words, never
  /// choose them.
  final String availabilityText;

  final String? distanceText;
  final Widget? thumbnail;
  final Widget? trailing;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final s = stationCardStyle();
    final distance = distanceText;
    return Container(
      padding: EdgeInsets.all(s.padding),
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: BorderRadius.circular(s.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) const DragHandle(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnail != null) thumbnail!,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EVGuideText(
                      title,
                      step: Step.heading,
                      weight: Weight.bold,
                      maxLines: 1,
                    ),
                    EVGuideText(
                      distance != null
                          ? '$distance · $availabilityText'
                          : availabilityText,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}
