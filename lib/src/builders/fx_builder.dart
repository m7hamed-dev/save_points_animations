import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';
import 'package:save_points_animations/src/core/fx_curves.dart';
import 'package:save_points_animations/src/debug/fx_debug.dart';
import 'package:save_points_animations/src/effects/attention_effects.dart';
import 'package:save_points_animations/src/effects/color_effects.dart';
import 'package:save_points_animations/src/effects/entrance_effects.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';
import 'package:save_points_animations/src/effects/loading_effects.dart';
import 'package:save_points_animations/src/effects/motion_effects.dart';
import 'package:save_points_animations/src/effects/reveal_effects.dart';
import 'package:save_points_animations/src/effects/transform_effects.dart';
import 'package:save_points_animations/src/effects/visual_effects.dart';
import 'package:save_points_animations/src/physics/fx_physics.dart';
import 'package:save_points_animations/src/themes/fx_theme.dart';

/// A single entry in the chain: either an effect or a `then` barrier.
@immutable
sealed class _Op {
  const _Op();
}

class _EffectOp extends _Op {
  const _EffectOp(this.effect);
  final FxEffect effect;
}

class _ThenOp extends _Op {
  const _ThenOp(this.delay);
  final Duration delay;
}

/// A resolved effect slot with absolute timing in milliseconds.
class _Resolved {
  _Resolved(this.effect, this.startMs, this.durationMs, this.curve);
  final FxEffect effect;
  final double startMs;
  final double durationMs;
  final Curve curve;
}

/// An immutable, chainable animation builder that is itself a [Widget].
///
/// Chaining accumulates immutable effects; nothing animates until it builds,
/// where a single [AnimationController] drives every effect. Transform-type
/// effects collapse into one [Transform] and fades into one [Opacity]
/// (see the performance contract in `prompt.enhanced.md` §0.2).
///
/// Effects added without a [then] barrier run **in parallel** from the current
/// cursor; [then] sequences what follows after everything so far completes.
class FxBuilder extends StatelessWidget {
  /// Create a builder around [child]. Prefer `widget.animate()`.
  const FxBuilder({
    super.key,
    required this.child,
    this.controller,
    this.autoPlay = true,
    this.addRepaintBoundary = true,
  }) : _ops = const <_Op>[],
       _repeat = false,
       _reverseOnRepeat = false;

  const FxBuilder._({
    super.key,
    required this.controller,
    required this.autoPlay,
    required this.addRepaintBoundary,
    required this._ops,
    required this._repeat,
    required this._reverseOnRepeat,
    required this.child,
  });

  /// The widget being animated.
  final Widget child;

  /// Optional external controller for imperative playback.
  final FxController? controller;

  /// Whether to play automatically once mounted.
  final bool autoPlay;

  /// Whether to wrap the result in a [RepaintBoundary] (recommended).
  final bool addRepaintBoundary;

  final List<_Op> _ops;
  final bool _repeat;
  final bool _reverseOnRepeat;

  FxBuilder _copy({List<_Op>? ops, bool? repeat, bool? reverseOnRepeat}) =>
      FxBuilder._(
        key: key,
        controller: controller,
        autoPlay: autoPlay,
        addRepaintBoundary: addRepaintBoundary,
        ops: ops ?? _ops,
        repeat: repeat ?? _repeat,
        reverseOnRepeat: reverseOnRepeat ?? _reverseOnRepeat,
        child: child,
      );

  /// Return a copy bound to [controller] with an explicit [autoPlay].
  ///
  /// Used by triggers (e.g. `onTap`) to drive an existing chain imperatively.
  FxBuilder configure({FxController? controller, bool? autoPlay}) =>
      FxBuilder._(
        key: key,
        controller: controller ?? this.controller,
        autoPlay: autoPlay ?? this.autoPlay,
        addRepaintBoundary: addRepaintBoundary,
        ops: _ops,
        repeat: _repeat,
        reverseOnRepeat: _reverseOnRepeat,
        child: child,
      );

  /// Append an arbitrary (including custom) effect to the chain.
  FxBuilder addEffect(FxEffect effect) =>
      _copy(ops: <_Op>[..._ops, _EffectOp(effect)]);

  FxBuilder _mutateLast(FxEffect Function(FxEffect e) transform) {
    final next = <_Op>[..._ops];
    for (var i = next.length - 1; i >= 0; i--) {
      final op = next[i];
      if (op is _EffectOp) {
        next[i] = _EffectOp(transform(op.effect));
        break;
      }
    }
    return _copy(ops: next);
  }

  // --- Timeline operators -------------------------------------------------

  /// Sequence: subsequent effects start after everything so far ends,
  /// plus an optional [delayAfter].
  FxBuilder then([Duration delayAfter = Duration.zero]) =>
      _copy(ops: <_Op>[..._ops, _ThenOp(delayAfter)]);

  /// Add several effects that run together from the current cursor.
  FxBuilder parallel(List<FxEffect> effects) =>
      _copy(ops: <_Op>[..._ops, ...effects.map(_EffectOp.new)]);

  /// Set the duration of the last effect.
  FxBuilder duration(Duration value) =>
      _mutateLast((e) => e.copyWithTiming(duration: value));

  /// Set the delay of the last effect.
  FxBuilder delay(Duration value) =>
      _mutateLast((e) => e.copyWithTiming(delay: value));

  /// Set the curve of the last effect.
  FxBuilder curve(Curve value) =>
      _mutateLast((e) => e.copyWithTiming(curve: value));

  /// Loop this animation, optionally mirroring each cycle.
  FxBuilder looping({bool mirror = false}) =>
      _copy(repeat: true, reverseOnRepeat: mirror);

  // --- Core effects -------------------------------------------------------

  /// Fade opacity from [begin] to [end].
  FxBuilder fade({double begin = 0.0, double end = 1.0}) =>
      addEffect(FadeEffect(begin: begin, end: end));

  /// Fade out to [end].
  FxBuilder fadeOut({double begin = 1.0, double end = 0.0}) =>
      addEffect(FadeEffect(begin: begin, end: end));

  /// Translate on X (pixels) from [begin] to [end].
  FxBuilder moveX(double begin, {double end = 0}) =>
      addEffect(MoveEffect(beginX: begin, endX: end));

  /// Translate on Y (pixels) from [begin] to [end].
  FxBuilder moveY(double begin, {double end = 0}) =>
      addEffect(MoveEffect(beginY: begin, endY: end));

  /// Translate on both axes.
  FxBuilder move({
    double beginX = 0,
    double beginY = 0,
    double endX = 0,
    double endY = 0,
  }) => addEffect(
    MoveEffect(beginX: beginX, beginY: beginY, endX: endX, endY: endY),
  );

  /// Size-relative slide on X (fraction of width).
  FxBuilder slideX(double begin, {double end = 0}) =>
      addEffect(SlideEffect(beginX: begin, endX: end));

  /// Size-relative slide on Y (fraction of height).
  FxBuilder slideY(double begin, {double end = 0}) =>
      addEffect(SlideEffect(beginY: begin, endY: end));

  /// Scale from [begin] to [end] about center.
  FxBuilder scale({double begin = 0.0, double end = 1.0}) =>
      addEffect(ScaleEffect(begin: begin, end: end));

  /// Rotate (degrees) from [begin] into [end].
  FxBuilder rotate([double begin = 15, double end = 0]) =>
      addEffect(RotateEffect(beginDegrees: begin, endDegrees: end));

  /// Skew (degrees) on X and/or Y.
  FxBuilder skew({double beginX = 0, double beginY = 0}) =>
      addEffect(SkewEffect(beginX: beginX, beginY: beginY));

  /// Horizontal 3D flip (degrees begin → 0).
  FxBuilder flipX({double begin = 90}) =>
      addEffect(FlipEffect(beginDegrees: begin));

  /// Vertical 3D flip (degrees begin → 0).
  FxBuilder flipY({double begin = 90}) =>
      addEffect(FlipEffect(horizontal: false, beginDegrees: begin));

  /// Gaussian blur (sigma begin → 0).
  FxBuilder blur({double begin = 8, double end = 0}) =>
      addEffect(BlurEffect(begin: begin, end: end));

  /// Color tint fading from [begin] strength to [end].
  FxBuilder tint(Color color, {double begin = 1.0, double end = 0.0}) =>
      addEffect(TintEffect(color: color, begin: begin, end: end));

  /// Damped horizontal shake.
  FxBuilder shake({double amplitude = 10, int count = 3}) =>
      addEffect(ShakeEffect(amplitude: amplitude, count: count));

  /// Damped vertical bounce.
  FxBuilder bounce({double amplitude = 20, int count = 3}) =>
      addEffect(BounceEffect(amplitude: amplitude, count: count));

  /// Single grow-and-return pulse.
  FxBuilder pulse({double amount = 0.1}) =>
      addEffect(PulseEffect(amount: amount));

  // --- One-shot / preset sugar (compose the effects above) ---------------

  /// Fade + gentle upward slide.
  FxBuilder fadeIn({double from = 0.05}) =>
      fade().addEffect(SlideEffect(beginY: from));

  /// Fade + scale up entrance.
  FxBuilder scaleIn({double begin = 0.8}) => fade().scale(begin: begin);

  /// Scale down exit.
  FxBuilder scaleOut({double end = 0.8}) =>
      fadeOut().scale(begin: 1.0, end: end);

  /// Slide in from below (with fade).
  FxBuilder slideFromBottom({double distance = 0.25}) =>
      fade().slideY(distance);

  /// Slide in from above (with fade).
  FxBuilder slideFromTop({double distance = 0.25}) => fade().slideY(-distance);

  /// Slide in from the left (with fade).
  FxBuilder slideFromLeft({double distance = 0.25}) => fade().slideX(-distance);

  /// Slide in from the right (with fade).
  FxBuilder slideFromRight({double distance = 0.25}) => fade().slideX(distance);

  // --- Attention seekers & extra entrances -------------------------------

  /// Elastic (spring-overshoot) scale entrance.
  FxBuilder elastic({double begin = 0.0}) =>
      scale(begin: begin).curve(FxCurves.elastic);

  /// Zoom entrance: fade + scale up from [begin].
  FxBuilder zoom({double begin = 0.3}) => fade().scale(begin: begin);

  /// Fade in with a scale that overshoots past 1 and settles — a subtle "pop".
  FxBuilder pop({double overshoot = 1.1}) =>
      addEffect(PopEffect(overshoot: overshoot));

  /// Opacity flash on/off.
  FxBuilder flash() => addEffect(const FlashEffect());

  /// Blink on/off [count] times (pair with [looping] for a persistent blink).
  FxBuilder blink({int count = 3, double minOpacity = 0.0}) =>
      addEffect(BlinkEffect(count: count, minOpacity: minOpacity));

  /// Horizontal wobble with rotation.
  FxBuilder wobble({double amplitude = 1.0}) =>
      addEffect(WobbleEffect(amplitude: amplitude));

  /// Pendulum swing.
  FxBuilder swing() => addEffect(const SwingEffect());

  /// Two-beat heartbeat scale.
  FxBuilder heartbeat({double peak = 1.3}) =>
      addEffect(HeartbeatEffect(peak: peak));

  /// Jello-like skew wobble.
  FxBuilder jelly() => addEffect(const JellyEffect());

  /// Squash-and-stretch rubber band.
  FxBuilder rubberBand() => addEffect(const RubberBandEffect());

  /// Wiggle-and-grow celebration.
  FxBuilder tada() => addEffect(const TadaEffect());

  /// Gentle continuous vertical bob (pair with [looping]).
  FxBuilder float({double amplitude = 8}) =>
      addEffect(FloatEffect(amplitude: amplitude));

  /// Pulsing glow (pair with [looping]).
  FxBuilder glow({
    Color color = const Color(0xFF448AFF),
    double maxBlur = 24,
    double maxSpread = 2,
  }) => addEffect(
    GlowEffect(color: color, maxBlur: maxBlur, maxSpread: maxSpread),
  );

  /// A general attention grabber (a firm double pulse).
  FxBuilder attention() => addEffect(const HeartbeatEffect(peak: 1.15));

  // --- Loading & skeleton -------------------------------------------------

  /// A moving highlight sweep (pair with [looping]).
  FxBuilder shimmer({
    Color color = const Color(0xCCFFFFFF),
    double bandWidth = 0.25,
    double angle = 0.2,
  }) => addEffect(
    ShimmerEffect(color: color, bandWidth: bandWidth, angle: angle),
  );

  /// A gentle scale + opacity breathing pulse (pair with [looping]).
  FxBuilder breathe({double scaleAmount = 0.04, double opacityDip = 0.25}) =>
      addEffect(
        BreatheEffect(scaleAmount: scaleAmount, opacityDip: opacityDip),
      );

  // --- Color & filter -----------------------------------------------------

  /// Animate saturation from [begin] (0 = grayscale) to [end] (1 = full).
  FxBuilder saturate({double begin = 0.0, double end = 1.0}) =>
      addEffect(SaturationEffect(begin: begin, end: end));

  /// Fade to grayscale (saturation 1 → 0).
  FxBuilder grayscale() => addEffect(const SaturationEffect(begin: 1, end: 0));

  /// Animate brightness (1 = normal).
  FxBuilder brightness({double begin = 0.0, double end = 1.0}) =>
      addEffect(BrightnessEffect(begin: begin, end: end));

  /// Animate a hue rotation, in degrees (pair with [looping] for a cycle).
  FxBuilder hueShift({double begin = 0, double end = 360}) =>
      addEffect(HueEffect(begin: begin, end: end));

  // --- Entrance choreography ---------------------------------------------

  /// Reveal through an expanding circular clip.
  FxBuilder circularReveal({Alignment center = Alignment.center}) =>
      addEffect(CircularRevealEffect(center: center));

  /// Reveal through a directional wipe (a curtain).
  FxBuilder wipe({
    AxisDirection direction = AxisDirection.right,
    bool fromCenter = false,
  }) => addEffect(WipeEffect(direction: direction, fromCenter: fromCenter));

  /// Reveal by opening outward from the center.
  FxBuilder curtain() => addEffect(const WipeEffect(fromCenter: true));

  /// Roll in from the left with an unrolling rotation.
  FxBuilder rollIn() => addEffect(const RollInEffect());

  /// Swing from a corner then drop away (an exit).
  FxBuilder hinge() => addEffect(const HingeEffect());

  /// Pop out of a box (tiny + rotated → full).
  FxBuilder jackInTheBox() => addEffect(const JackInTheBoxEffect());

  /// Streak in from the right with a skew (Animate.css `lightSpeedIn`).
  FxBuilder lightSpeedIn() => fade().slideX(0.5).skew(beginX: -30);

  /// Streak out to the right with a skew (Animate.css `lightSpeedOut`).
  FxBuilder lightSpeedOut() => fadeOut().slideX(0, end: 0.5).skew(beginX: 30);

  /// Rotate + fade into place from [begin] degrees.
  FxBuilder rotateIn({double begin = -90}) =>
      fade().addEffect(RotateEffect(beginDegrees: begin));

  // --- Physics -----------------------------------------------------------

  /// Drive the last effect with a real spring simulation, setting both its
  /// curve and its physically-correct settle duration.
  ///
  /// ```dart
  /// icon.animate().scale(begin: 0.5).spring(stiffness: 300, damping: 15);
  /// ```
  FxBuilder spring({
    double stiffness = 180,
    double damping = 12,
    double mass = 1,
    double velocity = 0,
  }) {
    final springCurve = FxPhysics.spring(
      stiffness: stiffness,
      damping: damping,
      mass: mass,
      velocity: velocity,
    );
    return curve(springCurve).duration(springCurve.settleDuration);
  }

  /// Drive the last effect with a constant-acceleration (gravity) curve.
  FxBuilder gravity({double acceleration = 9.8, double velocity = 0}) =>
      curve(FxPhysics.gravity(acceleration: acceleration, velocity: velocity));

  /// Drive the last effect with a decelerating friction/inertia curve.
  FxBuilder friction({double drag = 0.2, double velocity = 1}) =>
      curve(FxPhysics.friction(drag: drag, velocity: velocity));

  @override
  Widget build(BuildContext context) => _FxRunner(config: this);
}

class _FxRunner extends StatefulWidget {
  const _FxRunner({required this.config});
  final FxBuilder config;

  @override
  State<_FxRunner> createState() => _FxRunnerState();
}

class _FxRunnerState extends State<_FxRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  double _totalMs = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    widget.config.controller?.attach(_controller);
    FxDebugRegistry.activeControllers++;
  }

  @override
  void didUpdateWidget(covariant _FxRunner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.config.controller, widget.config.controller)) {
      oldWidget.config.controller?.detach(_controller);
      widget.config.controller?.attach(_controller);
    }
  }

  @override
  void dispose() {
    widget.config.controller?.detach(_controller);
    _controller.dispose();
    FxDebugRegistry.activeControllers--;
    super.dispose();
  }

  List<_Resolved> _resolve(FxThemeData defaults) {
    final resolved = <_Resolved>[];
    var cursor = 0.0;
    var maxEnd = 0.0;
    for (final op in widget.config._ops) {
      if (op is _ThenOp) {
        cursor = maxEnd + op.delay.inMicroseconds / 1000.0;
        continue;
      }
      final effect = (op as _EffectOp).effect;
      final start =
          cursor + (effect.delay ?? defaults.delay).inMicroseconds / 1000.0;
      final dur =
          (effect.duration ?? defaults.duration).inMicroseconds / 1000.0;
      final curve = effect.curve ?? defaults.curve;
      resolved.add(_Resolved(effect, start, dur, curve));
      if (start + dur > maxEnd) maxEnd = start + dur;
    }
    _totalMs = maxEnd <= 0 ? 1 : maxEnd;
    return resolved;
  }

  bool _reducedMotion(FxThemeData defaults) {
    if (!defaults.respectReducedMotion) return false;
    if (defaults.reducedMotionBehavior == FxReducedMotionBehavior.play) {
      return false;
    }
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  void _startOnce(bool reduced, FxThemeData defaults) {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (reduced) {
        _controller.value =
            defaults.reducedMotionBehavior == FxReducedMotionBehavior.disable
            ? 0.0
            : 1.0;
        return;
      }
      if (widget.config._repeat) {
        _controller.repeat(reverse: widget.config._reverseOnRepeat);
      } else if (widget.config.autoPlay) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaults = FxTheme.of(context);
    final resolved = _resolve(defaults);
    _controller.duration = Duration(microseconds: (_totalMs * 1000).round());
    final reduced = _reducedMotion(defaults);
    _startOnce(reduced, defaults);

    if (resolved.isEmpty) return widget.config.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.config.child,
      builder: (context, child) {
        final acc = FxAccumulator();
        final elapsed = _controller.value * _totalMs;
        for (final r in resolved) {
          final double f;
          if (r.durationMs <= 0) {
            f = elapsed >= r.startMs ? 1.0 : 0.0;
          } else {
            f = ((elapsed - r.startMs) / r.durationMs).clamp(0.0, 1.0);
          }
          r.effect.apply(acc, r.curve.transform(f));
        }

        return fxComposeFrame(
          child!,
          acc,
          addRepaintBoundary: widget.config.addRepaintBoundary,
        );
      },
    );
  }
}
