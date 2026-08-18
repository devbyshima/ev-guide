/// The closed vocabulary. docs/availability-display.md section 2.4: the
/// display words are **data in packages/domain**, not string literals in a
/// Swift file and a Kotlin file. Neither transcription may invent a word,
/// and this Dart transcription copies the values byte-for-byte.
library;

import 'types.dart';

/// Backing type for [words]. The values are DATA: every string here is the
/// exact byte sequence the TypeScript reference exports.
class Words {
  const Words._();

  final String free = 'free';

  /// One word for Occupied, every surface, driver and operator alike.
  final String busy = 'busy';
  final String outOfService = 'out of service';
  final String unknown = 'unknown';
  final String bay = 'bay';
  final String bays = 'bays';

  /// Never "no recent report": the offline override yields Unknown from a
  /// 30-second-old report, which would make that string false (law 8).
  final String noConfirmedStatus = 'no confirmed status';
  final String noConfirmedRate = 'no confirmed rate';
  final String all = 'All';
  final String of = 'of';
  final String other = 'other';

  /// The operator write-surface control label, the only capitalised form.
  final String busyControlLabel = 'Busy';
}

const words = Words._();

/// Connector type-words are one projection (section 2.4).
String connectorTypeWord(ConnectorType type) => switch (type) {
  ConnectorType.iec62196T2 => 'Type 2',
  ConnectorType.iec62196T2Combo => 'CCS2',
  ConnectorType.gbtAc => 'GB/T AC',
  ConnectorType.gbtDc => 'GB/T DC',
  // The enum is open, and Android can return a member we do not know.
  _ => 'Other plug',
};

/// The forbidden strings, section 2.2b. **This is the one and only home**: the
/// table there is the union merged under ticket 32, because four copies had
/// drifted into four different lists and deleting the wrong one would have
/// dropped live bans.
///
/// Exported so the test suite can assert that no emitted string contains one,
/// which is the only way a ban stays real.
const List<String> forbiddenSubstrings = [
  // Row 1: asserts report history.
  'unreported',
  'not reported',
  'no recent report',
  'no report yet',
  'no reports yet',
  'last reported',
  'awaiting a report',
  // Row 2: the same, for rates.
  'unknown rate',
  'rate unavailable',
  'no rate reported',
  'no published rate',
  // Row 3: availability claimed as a promise (ticket 28).
  'real-time',
  'realtime',
  // Row 7: a second word for Occupied.
  'in use',
];

/// Row 1 also bans "any phrasing that asserts a report exists, does not exist,
/// or is old", which no substring list can enforce. The literal list above is
/// the mechanical half; the catch-all is a review obligation, recorded here so
/// it is not mistaken for something the tests cover.
const String forbiddenCatchall =
    'any phrasing that asserts a report exists, does not exist, or is old';
