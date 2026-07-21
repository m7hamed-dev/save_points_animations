import 'package:flutter/widgets.dart';

import '../builders/fx_builder.dart';
import '../controllers/fx_controller.dart';

/// Entry point: turn any widget into an animation chain.
extension FxAnimate on Widget {
  /// Begin an animation chain around this widget.
  ///
  /// ```dart
  /// Text('Hi').animate().fade().moveY(50).duration(600.ms);
  /// ```
  FxBuilder animate({
    FxController? controller,
    bool autoPlay = true,
    bool addRepaintBoundary = true,
  }) => FxBuilder(
    controller: controller,
    autoPlay: autoPlay,
    addRepaintBoundary: addRepaintBoundary,
    child: this,
  );

  // One-shot sugar — each is `animate().<preset>()` so it stays chainable.

  /// Fade + gentle slide up.
  FxBuilder fadeIn({double from = 0.05}) => animate().fadeIn(from: from);

  /// Fade out.
  FxBuilder fadeOut() => animate().fadeOut();

  /// Scale up entrance (with fade).
  FxBuilder scaleIn({double begin = 0.8}) => animate().scaleIn(begin: begin);

  /// Scale down exit (with fade).
  FxBuilder scaleOut({double end = 0.8}) => animate().scaleOut(end: end);

  /// Slide in from below.
  FxBuilder slideFromBottom({double distance = 0.25}) =>
      animate().slideFromBottom(distance: distance);

  /// Slide in from above.
  FxBuilder slideFromTop({double distance = 0.25}) =>
      animate().slideFromTop(distance: distance);

  /// Slide in from the left.
  FxBuilder slideFromLeft({double distance = 0.25}) =>
      animate().slideFromLeft(distance: distance);

  /// Slide in from the right.
  FxBuilder slideFromRight({double distance = 0.25}) =>
      animate().slideFromRight(distance: distance);

  /// Damped shake (looping attention grabber when combined with `.looping()`).
  FxBuilder shake({double amplitude = 10, int count = 3}) =>
      animate().shake(amplitude: amplitude, count: count);

  /// Damped bounce.
  FxBuilder bounce({double amplitude = 20, int count = 3}) =>
      animate().bounce(amplitude: amplitude, count: count);

  /// Single pulse.
  FxBuilder pulse({double amount = 0.1}) => animate().pulse(amount: amount);
}
