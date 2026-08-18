import 'package:flutter/widgets.dart';

import '../styles.dart';
import '../tokens.dart';

/// Bridges the pure style layer into Flutter's [TextStyle]. The measured
/// numbers pass through unchanged; the two representational differences from
/// the RN original are converted here and nowhere else.
extension EVGuideTextStyleFlutter on EVGuideTextStyle {
  TextStyle toTextStyle() => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: this.color,
    letterSpacing: letterSpacing,
    // RN carried an absolute line height in pt; Flutter wants a multiple
    // of the font size. Same measured number, converted once.
    height: lineHeight == null ? null : lineHeight! / fontSize,
    // Old-style figures are a required feature, not a preference
    // (`typeMeta.fontFeatures`). RN had no way to request them; Flutter
    // does, so the set is asked for wherever the injected family
    // carries it.
    fontFeatures: [for (final tag in typeMeta.fontFeatures) FontFeature(tag)],
  );
}

/// The shared text widget: a step and a weight, nothing else to decide.
///
/// The typeface arrives from the app, never from here: it is an acceptance
/// band, not a name (ADR-0010). Leaving [fontFamily] null falls back to the
/// platform face, which is a legitimate state during development and an
/// illegitimate one at release.
class EVGuideText extends StatelessWidget {
  const EVGuideText(
    this.text, {
    super.key,
    this.step = Step.body,
    this.weight = Weight.regular,
    this.fontFamily,
    this.style,
    this.maxLines,
  });

  final String text;
  final Step step;
  final Weight weight;
  final String? fontFamily;

  /// Merged last, so a caller can adjust what the step does not pin.
  final TextStyle? style;

  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = textStyle(
      step,
      weight,
    ).toTextStyle().copyWith(fontFamily: fontFamily);
    return Text(
      text,
      maxLines: maxLines,
      // RN's numberOfLines truncates with an ellipsis; match it.
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style == null ? base : base.merge(style),
    );
  }
}
