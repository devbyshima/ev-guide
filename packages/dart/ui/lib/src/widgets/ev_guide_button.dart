import 'package:flutter/widgets.dart';

import '../styles.dart';
import 'ev_guide_text.dart';
import 'pressable_surface.dart';

/// The primary CTA (`01`, `03`) and the sticky CTA (`04`).
///
/// **It renders nothing on press and nothing when inert.** Both rules come
/// from ticket 31 and both are enforced in [PressableSurface], which is the
/// only place in this package that accepts a tap.
///
/// State is carried by the accent or by copy, never by a surface swap alone.
/// That sentence used to be quoted here as the licence for moving opacity
/// instead, which inverted it: the four greys span 1.75:1 end to end, and the
/// finding is that *no* non-text channel in this palette reaches 3:1 - which
/// rules a press dim out rather than in. Section 4.1 prices opacity explicitly
/// and rejects it as a ramp the design record lists as deliberately absent.
///
/// **A CTA that cannot act is not drawn faded, ever.** Section 5.2 splits by
/// component and gives this geometry its own answer: rows may stay and gain a
/// reason, but *"CTA-geometry controls are replaced by the reason"*, because
/// 46 pt of fill is nothing but an affordance and there is no reading of it in
/// which it is a label. So a caller with a terminal refusal renders `StateLine`
/// in this control's slot and does not render this widget at all. [inert] is
/// only case (c) - the precondition the human's very next tap on this screen
/// satisfies - and it keeps the button's appearance exactly.
class EVGuideButton extends StatelessWidget {
  const EVGuideButton({
    super.key,
    required this.label,
    this.variant = ButtonVariant.primary,
    this.onPressed,
    this.inert = false,
  });

  final String label;
  final ButtonVariant variant;
  final VoidCallback? onPressed;

  /// Transiently inert (section 5.2 case (c)): the button keeps its appearance
  /// and stops accepting taps. There is no third rendering.
  final bool inert;

  @override
  Widget build(BuildContext context) {
    final box = buttonStyle(variant);
    final labelStyle = buttonLabelStyle(variant);
    return PressableSurface(
      onPressed: onPressed,
      inert: inert,
      child: Container(
        height: box.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: box.backgroundColor,
          borderRadius: BorderRadius.circular(box.borderRadius),
        ),
        child: Text(label, style: labelStyle.toTextStyle()),
      ),
    );
  }
}
