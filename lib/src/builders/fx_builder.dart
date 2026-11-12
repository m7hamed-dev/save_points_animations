import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_paint_composite.dart';
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

/// One effect in the chain.
///
/// Effects added by a single call (e.g. `fadeIn()` adds a fade and a slide)
/// share a [group], so `.duration()` / `.delay()` / `.curve()` right after the
/// call apply to all of them. [inheritDuration] / [inheritCurve] record timing
/// set with `.duration()` / `.curve()`; it carries forward to later effects
/// that don't set their own. Timing baked into an effect's constructor (like
/// `elastic()`'s curve) stays local to that effect.
class _EffectOp extends _Op {
  const _EffectOp(
    this.effect,
    this.group, {
    this.inheritDuration,
    this.inheritCurve,
  });

  final FxEffect effect;
  final int group;
  final Duration? inheritDuration;
  final Curve? inheritCurve;
}

class _ThenOp extends _Op {
  const _ThenOp(this.delay);
  final Duration delay;
}

/// The immutable chain an [FxBuilder] accumulates.
@immutable
class _Chain {
  const _Chain({
    this.ops = const <_Op>[],
    this.repeat = false,
    this.reverseOnRepeat = false,
    this.repeatCount,
  });

  final List<_Op> ops;
  final bool repeat;
  final bool reverseOnRepeat;
  final int? repeatCount;

  int get nextGroup {
    for (var i = ops.length - 1; i >= 0; i--) {
      final op = ops[i];
      if (op is _EffectOp) return op.group + 1;
    }
    return 0;
  }

  _Chain copyWith({
    List<_Op>? ops,
    bool? repeat,
    bool? reverseOnRepeat,
    int? repeatCount,
  }) => _Chain(
    ops: ops ?? this.ops,
    repeat: repeat ?? this.repeat,
    reverseOnRepeat: reverseOnRepeat ?? this.reverseOnRepeat,
    repeatCount: repeatCount ?? this.repeatCount,
  );
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
/// effects collapse into one [Transform] and fades into one [Opacity].
///
/// Effects added without a [then] barrier run **in parallel** from the current
/// cursor; [then] sequences what follows after everything so far completes.
///
/// ### Timing
///
/// Each effect's duration and curve resolve in this order:
///
/// 1. timing set on the effect itself (`.duration()` / `.curve()` right after
///    it, or passed to the effect's constructor);
/// 2. otherwise, the timing last set with `.duration()` / `.curve()` earlier
///    in the chain — so `.fade().duration(600.ms).scale()` runs *both* for
///    600ms;
/// 3. otherwise, the chain defaults passed to `animate(duration:, curve:)`;
/// 4. otherwise, the nearest `FxTheme`, then the package defaults.
///
/// Delays are not inherited: `animate(delay:)` offsets the whole timeline and
/// `.delay()` offsets only the effect(s) it follows.
class FxBuilder extends StatelessWidget {
  /// Create a builder around [child]. Prefer `widget.animate()`.
  ///
  /// [duration], [curve] and [delay] are chain-wide defaults (see the class
  /// docs). When [target] is set the chain is driven declaratively instead of
  /// auto-playing: it starts at [target] and animates to each new value.
  const FxBuilder({
    super.key,
    required this.child,
    this.controller,
    this.autoPlay = true,
    this.addRepaintBoundary = true,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    this.target,
    this.onPlay,
    this.onComplete,
  }) : defaultDuration = duration,
       startDelay = delay,
       defaultCurve = curve,
       _chain = const _Chain();

  const FxBuilder._({
    super.key,
    required this.child,
    required this.controller,
    required this.autoPlay,
    required this.addRepaintBoundary,
    required this.defaultDuration,
    required this.startDelay,
    required this.defaultCurve,
    required this.target,
    required this.onPlay,
    required this.onComplete,
    required this._chain,
  });

  /// The widget being animated.
  final Widget child;

  /// Optional external controller for imperative playback.
  final FxController? controller;

  /// Whether to play automatically once mounted. Ignored when [target] is set.
  final bool autoPlay;

  /// Whether to wrap the result in a [RepaintBoundary] (recommended).
  final bool addRepaintBoundary;

  /// Chain-wide default duration for effects that don't set or inherit one.
  final Duration? defaultDuration;

  /// How long to wait before the first automatic play (and, under a trigger
  /// such as `onVisible()`, before each triggered play). Not repeated by
  /// loops, and not applied to [target] changes or [FxController] calls.
  final Duration? startDelay;

  /// Chain-wide default curve for effects that don't set or inherit one.
  final Curve? defaultCurve;

  /// Declarative position of the timeline in `0..1`.
  ///
  /// When non-null the chain doesn't auto-play: it renders at [target] on
  /// mount and animates to every new value it is rebuilt with — ideal for
  /// state such as selected/hovered/expanded:
  ///
  /// ```dart
  /// card.animate(target: isSelected ? 1 : 0).scale(begin: 1, end: 1.05);
  /// ```
  final double? target;

  /// Called whenever playback starts forward from rest.
  final VoidCallback? onPlay;

  /// Called whenever the timeline reaches its end.
  final VoidCallback? onComplete;

  final _Chain _chain;

  FxBuilder _copy({_Chain? chain, FxController? controller, bool? autoPlay}) =>
      FxBuilder._(
        key: key,
        controller: controller ?? this.controller,
        autoPlay: autoPlay ?? this.autoPlay,
        addRepaintBoundary: addRepaintBoundary,
        defaultDuration: defaultDuration,
        startDelay: startDelay,
        defaultCurve: defaultCurve,
        target: target,
        onPlay: onPlay,
        onComplete: onComplete,
        chain: chain ?? _chain,
        child: child,
      );

  /// Return a copy bound to [controller] with an explicit [autoPlay].
  ///
  /// Used by triggers (e.g. `onTap`) to drive an existing chain imperatively.
  FxBuilder configure({FxController? controller, bool? autoPlay}) =>
      _copy(controller: controller, autoPlay: autoPlay);

  /// Append an arbitrary (including custom) effect to the chain.
  ///
  /// Timing passed to the effect's constructor applies to that effect only;
  /// use `.duration()` / `.curve()` to set timing later effects inherit.
  FxBuilder addEffect(FxEffect effect) => _addGroup(<FxEffect>[effect]);

  /// Add [effects] as one group (they share later `.duration()` etc. calls).
  FxBuilder _addGroup(List<FxEffect> effects) {
    final group = _chain.nextGroup;
    return _copy(
      chain: _chain.copyWith(
        ops: <_Op>[..._chain.ops, for (final e in effects) _EffectOp(e, group)],
      ),
    );
  }

  /// Apply [transform] to every effect of the most recently added group.
  FxBuilder _mutateLast(
    FxEffect Function(FxEffect e) transform, {
    Duration? inheritDuration,
    Curve? inheritCurve,
  }) {
    final ops = _chain.ops;
    int? group;
    for (var i = ops.length - 1; i >= 0; i--) {
      final op = ops[i];
      if (op is _EffectOp) {
        group = op.group;
        break;
      }
    }
    if (group == null) return this;
    return _copy(
      chain: _chain.copyWith(
        ops: <_Op>[
          for (final op in ops)
            if (op is _EffectOp && op.group == group)
              _EffectOp(
                transform(op.effect),
                group,
                inheritDuration: inheritDuration ?? op.inheritDuration,
                inheritCurve: inheritCurve ?? op.inheritCurve,
              )
            else
              op,
        ],
      ),
    );
  }

  // --- Timeline operators -------------------------------------------------

  /// Sequence: subsequent effects start after everything so far ends,
  /// plus an optional [delayAfter].
  FxBuilder then([Duration delayAfter = Duration.zero]) => _copy(
    chain: _chain.copyWith(ops: <_Op>[..._chain.ops, _ThenOp(delayAfter)]),
  );

  /// Add several effects that run together from the current cursor, as one
  /// group: a following `.duration()` / `.curve()` applies to all of them.
  FxBuilder parallel(List<FxEffect> effects) => _addGroup(effects);

  /// Set the duration of the last effect (or of every effect the last call
  /// added, e.g. both halves of `fadeIn()`). Later effects inherit it.
  FxBuilder duration(Duration value) => _mutateLast(
    (e) => e.copyWithTiming(duration: value),
    inheritDuration: value,
  );

  /// Set the delay of the last effect (or of every effect the last call
  /// added). Delays are not inherited.
  FxBuilder delay(Duration value) =>
      _mutateLast((e) => e.copyWithTiming(delay: value));

  /// Set the curve of the last effect (or of every effect the last call
  /// added). Later effects inherit it.
  FxBuilder curve(Curve value) =>
      _mutateLast((e) => e.copyWithTiming(curve: value), inheritCurve: value);

  /// Loop this animation, optionally mirroring each cycle.
  ///
  /// [count] stops after that many iterations (as counted by
  /// [AnimationController.repeat]) and then fires `onComplete`; `null` loops
  /// forever.
  FxBuilder looping({bool mirror = false, int? count}) {
    assert(count == null || count > 0, 'count must be positive');
    return _copy(
      chain: _chain.copyWith(
        repeat: true,
        reverseOnRepeat: mirror,
        repeatCount: count,
      ),
    );
  }

  // --- Core effects -------------------------------------------------------

  /// Fade opacity from [begin] to [end].
  FxBuilder fade({double begin = 0.0, double end = 1.0}) =>
      addEffect(FadeEffect(begin: begin, end: end));

  /// Fade out to [end].
  FxBuilder fadeOut({double begin = 1.0, double end = 0.0}) =>
      addEffect(FadeEffect(begin: begin, end: end));

  /// Translate on X (pixels) from [begin] to [end].
  ///
  /// With [directional], positive values point toward the trailing edge, so
  /// the motion mirrors in right-to-left locales.
  FxBuilder moveX(double begin, {double end = 0, bool directional = false}) =>
      addEffect(MoveEffect(beginX: begin, endX: end, directional: directional));

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
  ///
  /// With [directional], positive values point toward the trailing edge, so
  /// the motion mirrors in right-to-left locales.
  FxBuilder slideX(double begin, {double end = 0, bool directional = false}) =>
      addEffect(
        SlideEffect(beginX: begin, endX: end, directional: directional),
      );

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

  // Each preset below adds its effects as ONE group, so `.duration()`,
  // `.delay()` and `.curve()` right after it apply to the whole preset.

  /// Fade + gentle upward slide.
  FxBuilder fadeIn({double from = 0.05}) =>
      _addGroup(<FxEffect>[const FadeEffect(), SlideEffect(beginY: from)]);

  /// Fade + scale up entrance.
  FxBuilder scaleIn({double begin = 0.8}) =>
      _addGroup(<FxEffect>[const FadeEffect(), ScaleEffect(begin: begin)]);

  /// Scale down exit.
  FxBuilder scaleOut({double end = 0.8}) => _addGroup(<FxEffect>[
    const FadeEffect(begin: 1, end: 0),
    ScaleEffect(begin: 1, end: end),
  ]);

  /// Slide in from below (with fade).
  FxBuilder slideFromBottom({double distance = 0.25}) =>
      _addGroup(<FxEffect>[const FadeEffect(), SlideEffect(beginY: distance)]);

  /// Slide in from above (with fade).
  FxBuilder slideFromTop({double distance = 0.25}) =>
      _addGroup(<FxEffect>[const FadeEffect(), SlideEffect(beginY: -distance)]);

  /// Slide in from the left (with fade). For layouts that should mirror in
  /// right-to-left locales, prefer [slideFromStart].
  FxBuilder slideFromLeft({double distance = 0.25}) =>
      _addGroup(<FxEffect>[const FadeEffect(), SlideEffect(beginX: -distance)]);

  /// Slide in from the right (with fade). For layouts that should mirror in
  /// right-to-left locales, prefer [slideFromEnd].
  FxBuilder slideFromRight({double distance = 0.25}) =>
      _addGroup(<FxEffect>[const FadeEffect(), SlideEffect(beginX: distance)]);

  /// Slide in from the leading edge (with fade): from the left in
  /// left-to-right text, from the right in right-to-left text (e.g. Arabic).
  FxBuilder slideFromStart({double distance = 0.25}) => _addGroup(<FxEffect>[
    const FadeEffect(),
    SlideEffect(beginX: -distance, directional: true),
  ]);

  /// Slide in from the trailing edge (with fade): from the right in
  /// left-to-right text, from the left in right-to-left text.
  FxBuilder slideFromEnd({double distance = 0.25}) => _addGroup(<FxEffect>[
    const FadeEffect(),
    SlideEffect(beginX: distance, directional: true),
  ]);

  // --- Attention seekers & extra entrances -------------------------------

  /// Elastic (spring-overshoot) scale entrance. The elastic curve stays local
  /// to this effect — later effects don't inherit it.
  FxBuilder elastic({double begin = 0.0}) =>
      addEffect(ScaleEffect(begin: begin, curve: FxCurves.elastic));

  /// Zoom entrance: fade + scale up from [begin].
  FxBuilder zoom({double begin = 0.3}) =>
      _addGroup(<FxEffect>[const FadeEffect(), ScaleEffect(begin: begin)]);

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

  /// A sharp diagonal light streak sweeping across the child (a specular
  /// "sheen"). One-shot by default; pair with [looping] to repeat.
  FxBuilder sheen({
    Color color = const Color(0xFFFFFFFF),
    double bandWidth = 0.12,
    double angle = 0.6,
  }) =>
      addEffect(SheenEffect(color: color, bandWidth: bandWidth, angle: angle));

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
  FxBuilder lightSpeedIn() => _addGroup(const <FxEffect>[
    FadeEffect(),
    SlideEffect(beginX: 0.5),
    SkewEffect(beginX: -30),
  ]);

  /// Streak out to the right with a skew (Animate.css `lightSpeedOut`).
  FxBuilder lightSpeedOut() => _addGroup(const <FxEffect>[
    FadeEffect(begin: 1, end: 0),
    SlideEffect(endX: 0.5),
    SkewEffect(beginX: 30),
  ]);

  /// Rotate + fade into place from [begin] degrees.
  FxBuilder rotateIn({double begin = -90}) => _addGroup(<FxEffect>[
    const FadeEffect(),
    RotateEffect(beginDegrees: begin),
  ]);

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

double _ms(Duration d) => d.inMicroseconds / 1000.0;

class _FxRunnerState extends State<_FxRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  Timer? _delayTimer;

  // Derived from the chain, the theme and reduced motion; refreshed whenever
  // any of them changes (see [_sync]).
  List<_Resolved> _resolved = const <_Resolved>[];
  double _totalMs = 1;
  bool _paintOnly = false;
  late FxThemeData _defaults;
  bool _reduced = false;
  TextDirection _textDirection = TextDirection.ltr;

  /// Keeps the animated child's subtree (and any `State` inside it) alive
  /// while the composed wrappers above it come and go. No-op wrappers are
  /// dropped at rest, which changes the widget type above the child; without
  /// a stable [GlobalKey] Flutter would unmount and re-create the child there.
  final GlobalKey _childKey = GlobalKey(debugLabel: 'FxBuilder.child');

  FxBuilder get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Rendering at the initial target is not playback: set it before
    // listening, so it reports neither onPlay nor onComplete.
    final target = _config.target;
    if (target != null) _controller.value = target.clamp(0.0, 1.0);
    _controller.addStatusListener(_onStatus);
    _config.controller?.attach(_controller);
    FxDebugRegistry.activeControllers++;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
    _startOnce();
  }

  @override
  void didUpdateWidget(covariant _FxRunner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.config.controller, _config.controller)) {
      oldWidget.config.controller?.detach(_controller);
      _config.controller?.attach(_controller);
    }
    _sync();
    final target = _config.target;
    if (target != null && target != oldWidget.config.target) {
      _delayTimer?.cancel();
      final value = target.clamp(0.0, 1.0);
      if (_reduced) {
        _controller.value = value;
      } else if (value >= _controller.value) {
        _controller.animateTo(value);
      } else {
        // animateBack so the status reads `reverse`, not `forward`, and
        // onPlay / onComplete only fire for forward motion.
        _controller.animateBack(value);
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _config.controller?.detach(_controller);
    _controller.dispose();
    FxDebugRegistry.activeControllers--;
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        _notify(_config.onPlay);
      case AnimationStatus.completed:
        _notify(_config.onComplete);
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        break;
    }
  }

  /// Call a user callback — after the frame if the status changed during
  /// build (e.g. a new `target` in didUpdateWidget), so the callback may
  /// safely call `setState`.
  void _notify(VoidCallback? callback) {
    if (callback == null) return;
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (mounted) callback();
      });
    } else {
      callback();
    }
  }

  /// Re-resolve the timeline against the current chain and theme.
  void _sync() {
    _defaults = FxTheme.of(context);
    _reduced = _reducedMotion();
    _resolved = _resolve();
    _paintOnly = _resolved.every((r) => r.effect.paintOnly);
    _controller.duration = Duration(microseconds: (_totalMs * 1000).round());
  }

  List<_Resolved> _resolve() {
    final config = _config;
    final resolved = <_Resolved>[];
    var cursor = 0.0;
    var maxEnd = 0.0;
    // Timing set with `.duration()` / `.curve()` carries forward to later
    // effects that don't set their own (see the FxBuilder docs).
    Duration? inheritedDuration;
    Curve? inheritedCurve;
    for (final op in config._chain.ops) {
      switch (op) {
        case _ThenOp(:final delay):
          cursor = maxEnd + _ms(delay);
        case _EffectOp(:final effect):
          final start = cursor + _ms(effect.delay ?? _defaults.delay);
          final dur = _ms(
            effect.duration ??
                inheritedDuration ??
                config.defaultDuration ??
                _defaults.duration,
          );
          final curve =
              effect.curve ??
              inheritedCurve ??
              config.defaultCurve ??
              _defaults.curve;
          resolved.add(_Resolved(effect, start, dur, curve));
          if (start + dur > maxEnd) maxEnd = start + dur;
          inheritedDuration = op.inheritDuration ?? inheritedDuration;
          inheritedCurve = op.inheritCurve ?? inheritedCurve;
      }
    }
    _totalMs = maxEnd <= 0 ? 1 : maxEnd;
    return resolved;
  }

  bool _reducedMotion() {
    if (!_defaults.respectReducedMotion) return false;
    if (_defaults.reducedMotionBehavior == FxReducedMotionBehavior.play) {
      return false;
    }
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  void _startOnce() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final config = _config;
      // Target-driven chains render at their target and only move when it
      // changes (see didUpdateWidget).
      if (config.target != null) return;
      if (_reduced) {
        // `disable` renders the child untouched (see build), so only
        // `jumpToEnd` needs the controller parked on the final frame.
        if (_defaults.reducedMotionBehavior ==
            FxReducedMotionBehavior.jumpToEnd) {
          _controller.value = 1.0;
        }
        return;
      }
      if (!config._chain.repeat && !config.autoPlay) return;
      final delay = config.startDelay ?? Duration.zero;
      if (delay > Duration.zero) {
        _delayTimer = Timer(delay, _play);
      } else {
        _play();
      }
    });
  }

  void _play() {
    if (!mounted) return;
    final chain = _config._chain;
    if (chain.repeat) {
      _controller.repeat(
        reverse: chain.reverseOnRepeat,
        count: chain.repeatCount,
      );
    } else {
      _controller.forward();
    }
  }

  /// Compose the frame for the controller's current value.
  FxAccumulator _composeFrame() {
    final acc = FxAccumulator(textDirection: _textDirection);
    final elapsed = _controller.value * _totalMs;
    for (final r in _resolved) {
      final double f;
      if (r.durationMs <= 0) {
        f = elapsed >= r.startMs ? 1.0 : 0.0;
      } else {
        f = ((elapsed - r.startMs) / r.durationMs).clamp(0.0, 1.0);
      }
      r.effect.apply(acc, r.curve.transform(f));
    }
    return acc;
  }

  @override
  Widget build(BuildContext context) {
    _textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final child = KeyedSubtree(key: _childKey, child: _config.child);
    if (_resolved.isEmpty) return child;
    if (_reduced &&
        _defaults.reducedMotionBehavior == FxReducedMotionBehavior.disable) {
      return child;
    }

    if (_paintOnly) {
      // Every effect only moves or fades the child: animate at paint time,
      // with no per-frame rebuilds.
      return FxPaintComposite(
        animation: _controller,
        compose: _composeFrame,
        repaintBoundary: _config.addRepaintBoundary,
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, child) => fxComposeFrame(
        child!,
        _composeFrame(),
        addRepaintBoundary: _config.addRepaintBoundary,
      ),
    );
  }
}
