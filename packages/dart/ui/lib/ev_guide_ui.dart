/// Design tokens, the pure style layer and the shared Flutter widgets,
/// ported 1:1 from `packages/ui` with the ticket 33/34/36 corrections
/// (ADR-0012). The TypeScript package remains the token source for the admin
/// SPA; this package is what the phone consumes.
library;

export 'src/styles.dart';
export 'src/tokens.dart';
export 'src/widgets/category_chip.dart';
export 'src/widgets/drag_handle.dart';
export 'src/widgets/ev_guide_button.dart';
export 'src/widgets/ev_guide_text.dart';
export 'src/widgets/feature_chip.dart';
export 'src/widgets/station_card.dart';
