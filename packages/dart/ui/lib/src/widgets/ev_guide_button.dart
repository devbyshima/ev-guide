import 'package:flutter/widgets.dart';

import '../styles.dart';
import 'ev_guide_text.dart';

/// The primary CTA (`01`, `03`) and the sticky CTA (`04`).
///
/// State is carried by the accent or by copy, **never by a surface swap
/// alone** (ticket 31). The pressed state therefore moves opacity rather
/// than swapping the fill for a second accent value: there is no second
/// accent value, and the record's "accent shade #9EC52B" was anti-aliasing
/// on pin outlines.
class EVGuideButton extends StatefulWidget {
  const EVGuideButton({
    super.key,
    required this.label,
    this.variant = ButtonVariant.primary,
    this.onPressed,
    this.disabled = false,
  });

  final String label;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final bool disabled;

  @override
  State<EVGuideButton> createState() => _EVGuideButtonState();
}

class _EVGuideButtonState extends State<EVGuideButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final box = buttonStyle(widget.variant);
    final labelStyle = buttonLabelStyle(widget.variant);
    return Semantics(
      button: true,
      enabled: !widget.disabled,
      child: GestureDetector(
        onTapDown: widget.disabled
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.disabled
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: widget.disabled
            ? null
            : () => setState(() => _pressed = false),
        onTap: widget.disabled ? null : widget.onPressed,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : (_pressed ? 0.85 : 1.0),
          child: Container(
            height: box.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: box.backgroundColor,
              borderRadius: BorderRadius.circular(box.borderRadius),
            ),
            child: Text(widget.label, style: labelStyle.toTextStyle()),
          ),
        ),
      ),
    );
  }
}
