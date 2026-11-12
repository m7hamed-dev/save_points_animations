import 'package:flutter/widgets.dart';

/// Whether the platform has asked apps to minimize non-essential motion
/// (the OS "reduce motion" / "remove animations" accessibility setting).
///
/// Prefer this one call over reaching into [MediaQuery] directly so every
/// widget in the package reads the flag the same way.
bool fxReduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Mixin for a [State] that owns a continuously-repeating or ticker-driven
/// animation and wants to honor the OS "reduce motion" setting.
///
/// It tracks the flag, exposes it as [reduceMotion], and calls
/// [onReduceMotionChanged] whenever it flips so the widget can start/stop its
/// controller and settle to a static frame. The flag starts out `false`, so
/// on the first [didChangeDependencies] the callback only fires if reduced
/// motion is already on — start your animation in `initState` (or check
/// [reduceMotion]) rather than waiting for a call that may never come. Reacting to *changes* — not just reading the flag
/// once at mount — means toggling the setting at runtime takes effect
/// immediately.
///
/// ```dart
/// class _MyState extends State<MyWidget>
///     with SingleTickerProviderStateMixin, FxMotionAware {
///   late final AnimationController _c =
///       AnimationController(vsync: this, duration: const Duration(seconds: 2));
///
///   @override
///   void onReduceMotionChanged(bool reduce) {
///     if (reduce) {
///       _c.stop();
///     } else {
///       _c.repeat();
///     }
///   }
/// }
/// ```
mixin FxMotionAware<T extends StatefulWidget> on State<T> {
  bool _reduceMotion = false;

  /// Whether motion should currently be minimized.
  bool get reduceMotion => _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = fxReduceMotion(context);
    if (next != _reduceMotion) {
      _reduceMotion = next;
      onReduceMotionChanged(next);
    }
  }

  /// Called when [reduceMotion] flips. The first call happens on the initial
  /// [didChangeDependencies] only if the setting is already enabled.
  void onReduceMotionChanged(bool reduceMotion) {}
}
