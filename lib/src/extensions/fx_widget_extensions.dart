import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';

/// Entry point: turn any widget into an animation chain.
extension FxAnimate on Widget {
  /// Begin an animation chain around this widget.
  ///
  /// ```dart
  /// Text('Hi')
  ///     .animate(duration: 600.ms, delay: 200.ms, curve: FxCurves.snappy)
  ///     .fade()
  ///     .moveY(50);
  /// ```
  ///
  /// [duration] and [curve] are defaults for every effect in the chain that
  /// doesn't set (or inherit) its own; [delay] waits before the first
  /// automatic play — or, with a trigger such as `onVisible()`, before each
  /// triggered play. With [target] the chain is driven declaratively instead
  /// of auto-playing — it sits at [target] (`0..1`) and animates whenever the
  /// value changes:
  ///
  /// ```dart
  /// card.animate(target: selected ? 1 : 0).scale(begin: 1, end: 1.05);
  /// ```
  ///
  /// [onPlay] fires whenever playback starts forward, [onComplete] whenever
  /// it finishes (never for an endless loop).
  FxBuilder animate({
    FxController? controller,
    bool autoPlay = true,
    bool addRepaintBoundary = true,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double? target,
    VoidCallback? onPlay,
    VoidCallback? onComplete,
  }) => FxBuilder(
    controller: controller,
    autoPlay: autoPlay,
    addRepaintBoundary: addRepaintBoundary,
    duration: duration,
    delay: delay,
    curve: curve,
    target: target,
    onPlay: onPlay,
    onComplete: onComplete,
    child: this,
  );
}

/// One-call presets on any widget, e.g. `Text('Hi').fadeIn()`.
///
/// Each is `animate().<preset>()`, so the result stays chainable. These are
/// exported by `save_points_animations.dart` but not by `core.dart`, for apps
/// that prefer to keep `Widget`'s namespace to [FxAnimate.animate] alone.
extension FxAnimateShortcuts on Widget {
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

  /// Slide in from the leading edge (mirrors in right-to-left locales).
  FxBuilder slideFromStart({double distance = 0.25}) =>
      animate().slideFromStart(distance: distance);

  /// Slide in from the trailing edge (mirrors in right-to-left locales).
  FxBuilder slideFromEnd({double distance = 0.25}) =>
      animate().slideFromEnd(distance: distance);

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

  /// Reveal through an expanding circular clip.
  FxBuilder circularReveal({Alignment center = Alignment.center}) =>
      animate().circularReveal(center: center);

  /// Reveal through a directional wipe.
  FxBuilder wipe({
    AxisDirection direction = AxisDirection.right,
    bool fromCenter = false,
  }) => animate().wipe(direction: direction, fromCenter: fromCenter);

  /// Reveal outward from the center.
  FxBuilder curtain() => animate().curtain();
}
