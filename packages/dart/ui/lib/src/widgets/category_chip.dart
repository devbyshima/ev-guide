import 'package:flutter/widgets.dart';

import '../styles.dart';
import 'ev_guide_text.dart';

/// `03`'s chip: a pill with a lime border, and **asymmetric padding by
/// measurement** (86 left, 30 right). See RAISE-5. Do not centre the label.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final s = categoryChipStyle();
    return Container(
      height: s.height,
      padding: EdgeInsets.only(left: s.paddingLeft, right: s.paddingRight),
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: BorderRadius.circular(s.borderRadius),
        border: Border.all(color: s.borderColor, width: s.borderWidth),
      ),
      // Vertically centred, shrink-wrapped horizontally: the asymmetry
      // lives in the padding, never in the alignment.
      child: Center(
        widthFactor: 1,
        child: Text(label, style: categoryChipLabelStyle().toTextStyle()),
      ),
    );
  }
}
