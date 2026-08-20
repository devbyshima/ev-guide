import 'package:flutter/widgets.dart';

/// The one place a press is handled, per ticket 31 section 12.1.
///
/// **Pressed renders nothing** (18-interaction-states-v2.md section 4.3). The
/// palette has no channel that reaches 3:1 for a press: section 4.1 prices all
/// four and rules opacity out by name as "an opacity ramp", which the design
/// record lists as deliberately absent. The feedback for a press is the
/// press's result, which is why section 4.3 pays for the rule by enumerating
/// every interactive element in the product and naming the two where the
/// result is not on screen within a frame.
///
/// Section 4.4 holds three treatments open if the founder wants a visible
/// press. **All three are surface swaps; none of them is opacity.** So a press
/// dim is not an unratified option awaiting a call - it is outside the option
/// set, and section 12.2 prohibition 4 bans it as a component-level invention.
/// If the founder takes 4.4, what arrives here is `surface: 'row' | 'control'`,
/// never `'accent'` (section 4.5 collision 1 forbids accent-press permanently).
///
/// **`inert`, and why it is deliberately not called `disabled`.** Section 5
/// rules that EV Guide has no disabled state and no disabled token, tested
/// against 23 places. An action that cannot be performed is absent, or refuses
/// in words, or is transiently inert. Only the third has a control still on
/// screen, and section 5.2 case (c) defines it as *the control keeps its
/// appearance and stops accepting taps*. Section 12.1 names the prop `inert`
/// precisely because "a prop named `disabled` invites a `disabledStyle` within
/// a week" - which is what happened here before this file existed.
///
/// **The porting note, because the hazard changed shape.** React Native ships
/// the deviation by default: `TouchableOpacity` carries `activeOpacity: 0.2`
/// and `Pressable` carries `android_ripple`, so doing nothing ships both. In
/// Flutter the raw gesture layer draws nothing, and the hazard moved into the
/// widgets that wrap it - `InkWell`, `InkResponse`, `CupertinoButton` and the
/// Material buttons each ship a ramp, a splash or both. The discipline is
/// therefore the same and the prohibited list is different; the sweep in
/// `press_grammar_test.dart` carries the Flutter list.
///
/// It holds no press state on purpose. There is no `_pressed` field to render
/// from, so a press treatment cannot be added here without first adding the
/// state that would carry it, and that edit is the one a reviewer sees.
class PressableSurface extends StatelessWidget {
  const PressableSurface({
    super.key,
    required this.child,
    this.onPressed,
    this.inert = false,
    this.button = true,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Stops taps and **changes nothing visually** (section 5.2 case (c)).
  ///
  /// The tap is absorbed rather than passed through: a control that has gone
  /// inert must not let the press reach the map behind it.
  final bool inert;

  /// React Native's `accessibilityRole`, in the flag Flutter carries it as.
  final bool button;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: button,
      // **A judgement, not a citation.** The design record specifies nothing
      // here: `accessibilityState` appears nowhere in the ticket 31 corpus,
      // and section 12.1 defines `inert` only as "stops taps and changes
      // nothing visually". Two readings are available - mirror the silence, or
      // state the truth to assistive technology - and this takes the second,
      // on the ground that "changes nothing visually" governs paint, which a
      // semantics flag does not touch. Section 6.2's neighbouring ruling
      // points the same way: the OS's own focus indicator is not ours to
      // suppress. It also preserves what the widget did before this file
      // existed, so the fix is not smuggling an a11y change alongside itself.
      //
      // Worth a founder line if the states pass is ever reopened, because the
      // other reading is defensible: section 5.5 accepts that case (c) shows
      // the human a live-looking control for up to one tap, and a screen
      // reader announcing "dimmed" is a channel the sighted user does not get.
      enabled: !inert,
      child: GestureDetector(
        // The whole box is the target, including any transparent inset. A
        // CTA-geometry control is 46 pt of nothing-but-affordance (section
        // 5.2), so it may not have dead pixels inside its own frame.
        behavior: HitTestBehavior.opaque,
        onTap: inert ? null : onPressed,
        child: child,
      ),
    );
  }
}
