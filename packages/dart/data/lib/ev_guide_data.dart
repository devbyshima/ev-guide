/// Repository protocols plus the mock implementation and seed.
///
/// Dart transcription of `packages/data` (ADR-0012), behind the same
/// ADR-0005 seam: apps are built against the protocols, the mock is a
/// first-class citizen (ADR-0006), and availability is always derived,
/// never stored (ADR-0008).
library;

export 'src/mock.dart';
export 'src/protocols.dart';
export 'src/seed.dart';
