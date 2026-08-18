import 'package:flutter/widgets.dart';

import '../styles.dart';

/// The `03` drag handle. A pill at half its integrated height, and
/// **`#262626` on `#121212` is 1.24:1** - invisible-grade, measured, and
/// correct. Do not "fix" the contrast.
///
/// Hidden from assistive technology, as the RN original was.
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = dragHandleStyle();
    // `alignSelf: center` in the RN original: centred in the cross axis
    // without claiming any height beyond the handle's own.
    return ExcludeSemantics(
      child: Align(
        heightFactor: 1,
        child: Container(
          width: s.width,
          height: s.height,
          decoration: BoxDecoration(
            color: s.backgroundColor,
            borderRadius: BorderRadius.circular(s.borderRadius),
          ),
        ),
      ),
    );
  }
}
