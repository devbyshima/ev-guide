/// The style layer: **pure values derived from tokens, no widget import**.
/// Widgets consume these; tests assert them.
///
/// Splitting it this way is deliberate. The 1:1 reference rule lives in
/// numbers, and numbers are what drift. A style value can be asserted against
/// the measured record without pumping a widget tree, so every value the
/// reference pinned gets a test that fails when someone rounds it.
///
/// Cap heights map to the five pt steps as `10-design-system-v2.md` section
/// 4.2 maps them: cap 55 -> display, 47 -> title, 36/37 -> heading, 32 ->
/// label, 27/28 -> body. Build against cap heights where you can; these are
/// the rounded pt values, which is the only place that record rounded.
library;

import 'dart:ui' show Color, FontWeight;

import 'tokens.dart';

/// The four weights, keyed as [typeMeta]'s `weights` table keys them.
///
/// Kept as a closed enum rather than a raw [FontWeight] parameter, so a fifth
/// weight cannot be introduced by a typo: the system has exactly these four
/// (200/400/500/700) and the design record has no others.
enum Weight { extraLight, regular, medium, bold }

/// The five steps of the type scale, keyed as the [type] table keys them.
enum Step { display, title, heading, label, body }

/// The two CTA variants. Both share `radius.button` (ticket 33).
enum ButtonVariant { primary, sticky }

/// 200/400/500/700 as Flutter [FontWeight]s, total over [Weight] so a new
/// member cannot ship unmapped.
FontWeight _fontWeightOf(Weight weight) => switch (weight) {
  Weight.extraLight => FontWeight.w200,
  Weight.regular => FontWeight.w400,
  Weight.medium => FontWeight.w500,
  Weight.bold => FontWeight.w700,
};

double _stepSize(Step step) => switch (step) {
  Step.display => type.display,
  Step.title => type.title,
  Step.heading => type.heading,
  Step.label => type.label,
  Step.body => type.body,
};

/// A text style, carrying everything *except* the family.
///
/// **No font family, ever.** The typeface is not identified and ships as an
/// acceptance band (ADR-0010); this package must not pick a family from the
/// design record. The app injects one after it passes the band, which is why
/// this class has no field for it.
class EVGuideTextStyle {
  const EVGuideTextStyle({
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.letterSpacing,
    this.lineHeight,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;

  /// Absolute line height in pt, as RN carried it. Only body has one, because
  /// only body had one measured.
  final double? lineHeight;

  EVGuideTextStyle copyWith({Color? color}) => EVGuideTextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? this.color,
    letterSpacing: letterSpacing,
    lineHeight: lineHeight,
  );

  /// The style as key/value pairs, mirroring the TS object shape, so tests
  /// can assert what a style does **not** carry (a family; a line height off
  /// body).
  Map<String, Object?> get asMap => {
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'color': color,
    'letterSpacing': letterSpacing,
    if (lineHeight != null) 'lineHeight': lineHeight,
  };
}

/// The one text style factory. Everything except the family: the app injects
/// that after it passes the acceptance band (ADR-0010).
EVGuideTextStyle textStyle(Step step, [Weight weight = Weight.regular]) {
  return EVGuideTextStyle(
    fontSize: _stepSize(step),
    fontWeight: _fontWeightOf(weight),
    color: color.text,
    letterSpacing: typeMeta.tracking,
    lineHeight: step == Step.body ? typeMeta.bodyLineHeight : null,
  );
}

/// The CTA box, shared by both variants.
class EVGuideButtonStyle {
  const EVGuideButtonStyle({
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
  });

  final double height;
  final double borderRadius;
  final Color backgroundColor;
}

/// The primary CTA (`01`, `03`) and the sticky CTA (`04`).
///
/// **Not a pill.** A pill on a 137.25 px button needs r = 69; it measures
/// 16.5. This is the single most likely 1:1 failure in the system, because
/// "lime pill" is what the record used to say and what the shape reads like.
///
/// Both variants share `radius.button`: one value fits all eight corners of
/// both with zero penalty (ticket 33), so there is no `buttonSticky` radius.
/// The label centres in the box; width comes from layout, never from here.
EVGuideButtonStyle buttonStyle([
  ButtonVariant variant = ButtonVariant.primary,
]) {
  final box = variant == ButtonVariant.primary ? size.cta : size.ctaSticky;
  return EVGuideButtonStyle(
    height: pt(box.h),
    borderRadius: pt(radius.button),
    backgroundColor: color.accent,
  );
}

EVGuideTextStyle buttonLabelStyle([
  ButtonVariant variant = ButtonVariant.primary,
]) {
  // Primary label is cap 36 (heading); sticky is cap 32 (label). Both Medium.
  return textStyle(
    variant == ButtonVariant.primary ? Step.heading : Step.label,
    Weight.medium,
  ).copyWith(color: color.onAccent);
}

/// The `04` feature chip box. Deliberately no border field: the chip has no
/// border, and the absence is under test.
class FeatureChipStyle {
  const FeatureChipStyle({
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.paddingLeft,
    required this.paddingRight,
    required this.gap,
  });

  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final double paddingLeft;
  final double paddingRight;

  /// Icon-to-label gap; a row that centres its children vertically.
  final double gap;

  /// The style as key/value pairs, so tests can assert there is no
  /// `borderWidth` here.
  Map<String, Object?> get asMap => {
    'height': height,
    'borderRadius': borderRadius,
    'backgroundColor': backgroundColor,
    'paddingLeft': paddingLeft,
    'paddingRight': paddingRight,
    'gap': gap,
  };
}

/// The `04` feature chip. Height is fixed; **width fits content**.
/// No border. Padding is left 30 / icon-to-label 18 / right 26.
FeatureChipStyle featureChipStyle() {
  return FeatureChipStyle(
    height: pt(size.featureChipHeight),
    borderRadius: pt(radius.featureChip),
    backgroundColor: color.surface,
    paddingLeft: pt(space.chipPaddingH),
    paddingRight: pt(26),
    gap: pt(space.chipIconGap),
  );
}

EVGuideTextStyle featureChipLabelStyle() {
  return textStyle(Step.label, Weight.extraLight);
}

/// The `03` category chip box: a pill with a border and asymmetric padding.
class CategoryChipStyle {
  const CategoryChipStyle({
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderWidth,
    required this.borderColor,
    required this.paddingLeft,
    required this.paddingRight,
  });

  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final double borderWidth;
  final Color borderColor;
  final double paddingLeft;
  final double paddingRight;
}

/// The `03` category chip. A **pill** (ticket 33 reversed the record here),
/// with a 2.5 px lime border and a lime label.
///
/// **The padding is asymmetric on purpose: 86 left against 30 right.** That
/// is measured, it is RAISE-5 in the design record, and it is not a mistake
/// to centre. `86 + 138 + 30 = 254` closes exactly at the chip's own lime
/// extent.
CategoryChipStyle categoryChipStyle() {
  return CategoryChipStyle(
    height: pt(size.categoryChip.h),
    borderRadius: PILL,
    backgroundColor: color.surface,
    borderWidth: pt(2.5),
    borderColor: color.accent,
    paddingLeft: pt(86),
    paddingRight: pt(30),
  );
}

EVGuideTextStyle categoryChipLabelStyle() {
  return textStyle(Step.body, Weight.regular).copyWith(color: color.accent);
}

/// The `03` drag handle box. Centred in its parent's cross axis.
class DragHandleStyle {
  const DragHandleStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
}

/// The `03` drag handle. A pill at half its integrated height, and
/// **`#262626` on `#121212` is 1.24:1** - invisible-grade, measured, and
/// correct. Do not "fix" the contrast.
DragHandleStyle dragHandleStyle() {
  return DragHandleStyle(
    width: pt(size.handle.w),
    height: pt(size.handle.h),
    borderRadius: PILL,
    backgroundColor: color.handle,
  );
}

/// The `03` floating card box: one radius for all four corners, on purpose.
class StationCardStyle {
  const StationCardStyle({
    required this.borderRadius,
    required this.backgroundColor,
    required this.padding,
  });

  final double borderRadius;
  final Color backgroundColor;
  final double padding;

  /// The style as key/value pairs, so tests can assert there are no
  /// per-corner radii here: a sheet would carry them, a card must not.
  Map<String, Object?> get asMap => {
    'borderRadius': borderRadius,
    'backgroundColor': backgroundColor,
    'padding': padding,
  };
}

/// The `03` floating card. **Not a bottom sheet**: it is rounded on all four
/// corners and is never anchored to the screen edge, with 64 px of live map
/// between its bottom edge and the CTA.
///
/// This package names it `StationCard` and must not build it on a sheet
/// primitive, whose whole contract is bottom anchoring.
StationCardStyle stationCardStyle() {
  return StationCardStyle(
    borderRadius: pt(radius.floatingCard),
    backgroundColor: color.page,
    padding: pt(space.floatingCardPadding),
  );
}

/// The thumbnail box: square, and rounder than every container.
class ThumbnailStyle {
  const ThumbnailStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;
}

ThumbnailStyle thumbnailStyle() {
  return ThumbnailStyle(
    width: pt(size.thumbnail),
    height: pt(size.thumbnail),
    borderRadius: pt(radius.image),
  );
}

/// The `02` hosting card box.
class HostingCardStyle {
  const HostingCardStyle({
    required this.borderRadius,
    required this.backgroundColor,
    required this.padding,
  });

  final double borderRadius;
  final Color backgroundColor;
  final double padding;
}

/// The `02` hosting card and its icon tile.
HostingCardStyle hostingCardStyle() {
  return HostingCardStyle(
    borderRadius: pt(radius.card),
    backgroundColor: color.surface,
    padding: pt(space.cardPadding),
  );
}

/// The icon tile box, raised one step off the hosting card.
class IconTileStyle {
  const IconTileStyle({
    required this.borderRadius,
    required this.backgroundColor,
  });

  final double borderRadius;
  final Color backgroundColor;
}

IconTileStyle iconTileStyle() {
  return IconTileStyle(
    borderRadius: pt(radius.tile),
    backgroundColor: color.raised,
  );
}

/// A circular button box: a true circle, so width equals height.
class CircleButtonStyle {
  const CircleButtonStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
}

/// Circular buttons. Five diameters, and they are genuinely all different.
CircleButtonStyle circleButtonStyle(CircleButtonSize which) {
  final d = pt(switch (which) {
    CircleButtonSize.sm => size.circleButton.sm,
    CircleButtonSize.md => size.circleButton.md,
    CircleButtonSize.lg => size.circleButton.lg,
    CircleButtonSize.xl => size.circleButton.xl,
  });
  return CircleButtonStyle(
    width: d,
    height: d,
    borderRadius: PILL,
    backgroundColor: color.surface,
  );
}

/// The page ground: fills the screen, contents centre nothing by default.
class PageStyle {
  const PageStyle({
    required this.backgroundColor,
    required this.paddingHorizontal,
  });

  final Color backgroundColor;
  final double paddingHorizontal;
}

/// The page. There is exactly one text colour, and this is its ground.
PageStyle pageStyle() {
  return PageStyle(
    backgroundColor: color.page,
    paddingHorizontal: pt(space.pageMargin),
  );
}
