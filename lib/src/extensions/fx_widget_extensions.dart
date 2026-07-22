import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';

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

  /// Elastic scale entrance.
  FxBuilder elastic({double begin = 0.0}) => animate().elastic(begin: begin);

  /// Zoom entrance (fade + scale).
  FxBuilder zoom({double begin = 0.3}) => animate().zoom(begin: begin);

  /// Opacity flash.
  FxBuilder flash() => animate().flash();

  /// Horizontal wobble.
  FxBuilder wobble({double amplitude = 1.0}) =>
      animate().wobble(amplitude: amplitude);

  /// Pendulum swing.
  FxBuilder swing() => animate().swing();

  /// Two-beat heartbeat.
  FxBuilder heartbeat({double peak = 1.3}) => animate().heartbeat(peak: peak);

  /// Jello-like wobble.
  FxBuilder jelly() => animate().jelly();

  /// Rubber-band squash and stretch.
  FxBuilder rubberBand() => animate().rubberBand();

  /// Wiggle-and-grow celebration.
  FxBuilder tada() => animate().tada();

  /// Continuous vertical bob (loops).
  FxBuilder float({double amplitude = 8}) =>
      animate().float(amplitude: amplitude).looping();

  /// Pulsing glow (loops).
  FxBuilder glow({Color color = const Color(0xFF448AFF)}) =>
      animate().glow(color: color).looping();

  /// General attention grabber.
  FxBuilder attention() => animate().attention();

  /// Loading shimmer sweep (loops).
  FxBuilder shimmer({Color color = const Color(0xCCFFFFFF)}) =>
      animate().shimmer(color: color).looping();

  /// Breathing pulse (loops).
  FxBuilder breathe() => animate().breathe().looping();

  /// Grayscale-to-color reveal.
  FxBuilder saturate({double begin = 0.0, double end = 1.0}) =>
      animate().saturate(begin: begin, end: end);

  /// Roll in from the left.
  FxBuilder rollIn() => animate().rollIn();

  /// Swing then drop away (exit).
  FxBuilder hinge() => animate().hinge();

  /// Pop out of a box.
  FxBuilder jackInTheBox() => animate().jackInTheBox();

  /// Streak in with a skew.
  FxBuilder lightSpeedIn() => animate().lightSpeedIn();

  /// Rotate + fade into place.
  FxBuilder rotateIn({double begin = -90}) => animate().rotateIn(begin: begin);
}
