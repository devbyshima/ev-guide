import 'package:flutter/widgets.dart';

import '../styles.dart';
import 'ev_guide_text.dart';

/// `04`'s chip: fixed height, width fits content, no border.
class FeatureChip extends StatelessWidget {
  const FeatureChip({super.key, required this.label, this.icon});

  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final s = featureChipStyle();
    return Container(
      height: s.height,
      padding: EdgeInsets.only(left: s.paddingLeft, right: s.paddingRight),
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: BorderRadius.circular(s.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The gap is between icon and label, so it exists only when an
          // icon does (RN's row gap behaves the same way).
          if (icon != null) ...[icon!, SizedBox(width: s.gap)],
          Text(label, style: featureChipLabelStyle().toTextStyle()),
        ],
      ),
    );
  }
}
