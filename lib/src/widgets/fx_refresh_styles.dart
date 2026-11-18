/// The five looks of `FxRefreshIndicator`. Internal: the indicator picks one
/// by its `FxRefreshStyle` and hands it an [FxRefreshFrame].
library;

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_refresh_indicator.dart';

/// Everything a style needs to draw one indicator.
@immutable
class FxRefreshFrame {
  /// Creates a frame; built by `FxRefreshIndicator` on every build.
  const FxRefreshFrame({
    required this.status,
    required this.pull,
    required this.spin,
    required this.exit,
    required this.color,
    required this.background,
    required this.foreground,
    required this.dark,
    required this.rtl,
    required this.displacement,
    required this.labels,
    required this.reduceMotion,
  });

  /// Where the gesture is.
  final FxRefreshStatus status;

  /// The pull: 0 hidden, 1 at the trigger point, up to 1.5 when overpulled.
  final Animation<double> pull;

  /// 0 to 1, repeating while refreshing. Stays put under reduced motion.
  final Animation<double> spin;

  /// 0 to 1 over the finish animation, after `onRefresh` completes.
  final Animation<double> exit;

  /// The accent.
  final Color color;

  /// The surface behind floating indicators.
  final Color background;

  /// The text color around the indicator.
  final Color foreground;

  /// Whether the surroundings are dark.
  final bool dark;

  /// Whether the text direction is right-to-left.
  final bool rtl;

  /// Resting distance below the top edge while refreshing.
  final double displacement;

  /// The capsule texts.
  final FxRefreshLabels labels;

  /// Whether to hold still frames instead of looping.
  final bool reduceMotion;

  /// Pull toward the trigger point, 0 to 1.
  double get progress => pull.value.clamp(0.0, 1.0);

  /// Pull past the trigger point, 0 to 1.
  double get overpull => ((pull.value - 1) / 0.5).clamp(0.0, 1.0);

  /// Whether the drag has not reached the trigger point (or was let go
  /// before it).
  bool get beforeTrigger =>
      status == FxRefreshStatus.drag || status == FxRefreshStatus.canceled;

  /// Repaints on every tick of [pull], [spin] and [exit].
  Listenable get ticks => Listenable.merge([pull, spin, exit]);

  /// Whether [other] draws the same apart from the animation values.
  bool sameLook(FxRefreshFrame other) =>
      other.status == status &&
      other.color == color &&
      other.background == background &&
      other.foreground == foreground &&
      other.dark == dark &&
      other.rtl == rtl &&
      other.displacement == displacement &&
      other.reduceMotion == reduceMotion;
}

/// The indicator for [style].
Widget fxRefreshIndicatorFor(FxRefreshStyle style, FxRefreshFrame frame) =>
    switch (style) {
      FxRefreshStyle.ring => _RingIndicator(frame),
      FxRefreshStyle.capsule => _CapsuleIndicator(frame),
      FxRefreshStyle.liquid => _LiquidIndicator(frame),
      FxRefreshStyle.dots => _DotsIndicator(frame),
      FxRefreshStyle.line => _LineIndicator(frame),
    };

/// How long [style]'s finish animation runs.
Duration fxRefreshExitDuration(FxRefreshStyle style) => switch (style) {
  FxRefreshStyle.ring => const Duration(milliseconds: 650),
  // Long enough to read the "done" label.
  FxRefreshStyle.capsule => const Duration(milliseconds: 1100),
  FxRefreshStyle.liquid => const Duration(milliseconds: 450),
  FxRefreshStyle.dots => const Duration(milliseconds: 600),
  FxRefreshStyle.line => const Duration(milliseconds: 500),
};

/// The height of the strip below the top edge that [style] draws in.
double fxRefreshAreaHeight(FxRefreshStyle style, double displacement) {
  final extent = switch (style) {
    FxRefreshStyle.ring => _RingIndicator.size,
    FxRefreshStyle.capsule => _CapsuleIndicator.height,
    FxRefreshStyle.liquid => _LiquidIndicator.radius * 2,
    FxRefreshStyle.dots => _DotsIndicator.size.height,
    FxRefreshStyle.line => 0.0,
  };
  if (style == FxRefreshStyle.line) return 12;
  // Overpulled position plus room for the shadow or the liquid's ripple.
  return (displacement + extent) * 1.5 + 32;
}

// ── Shared pieces ───────────────────────────────────────────────────────────

/// [t] mapped onto the interval [begin]–[end], clamped to 0–1.
double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

/// [color] with its alpha multiplied by [opacity].
Color _fade(Color color, double opacity) =>
    color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0));

/// Places a floating indicator [extent] tall the way Material's indicator
/// moves: hidden above the edge at pull 0, `displacement` below it at the
/// trigger point, lower still when overpulled. It fades in over the pull.
class _Floating extends StatelessWidget {
  const _Floating({
    required this.frame,
    required this.extent,
    required this.child,
  });

  final FxRefreshFrame frame;
  final double extent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: frame.pull,
      child: child,
      builder: (context, child) {
        final pull = frame.pull.value;
        return Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, pull * (frame.displacement + extent) - extent),
            child: Opacity(
              opacity: Curves.easeOut.transform(pull.clamp(0.0, 1.0)),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Fades [child] out (and moves it by [lift] × the fade) over the last part
/// of the finish animation, from [from] on.
class _ExitFade extends StatelessWidget {
  const _ExitFade({
    required this.frame,
    required this.from,
    required this.child,
    this.shrink = 0,
    this.lift = 0,
  });

  final FxRefreshFrame frame;
  final double from;
  final double shrink;
  final double lift;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (frame.status != FxRefreshStatus.done) return child;
    return AnimatedBuilder(
      animation: frame.exit,
      child: child,
      builder: (context, child) {
        final out = Curves.easeInCubic.transform(
          _interval(frame.exit.value, from, 1),
        );
        return Opacity(
          opacity: 1 - out,
          child: Transform.translate(
            offset: Offset(0, -lift * out),
            child: Transform.scale(scale: 1 - shrink * out, child: child),
          ),
        );
      },
    );
  }
}

/// The raised surface behind the ring, capsule and dots: the background with
/// a soft two-layer shadow, plus a hairline edge on dark surroundings.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.frame,
    required this.radius,
    required this.child,
  });

  final FxRefreshFrame frame;
  final double radius;
  final Widget child;

  static const _lightShadows = [
    BoxShadow(color: Color(0x1C101828), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x12101828), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const _darkShadows = [
    BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: frame.background,
        borderRadius: BorderRadius.circular(radius),
        border: frame.dark
            ? Border.all(color: const Color(0x1FFFFFFF), width: 0.5)
            : null,
        boxShadow: frame.dark ? _darkShadows : _lightShadows,
      ),
      child: child,
    );
  }
}

/// An `AnimatedSwitcher` transition that hands over instead of overlapping:
/// the old child fades out over the first half, the new one fades in over the
/// second, each moved by [motion].
Widget _swap(
  Widget child,
  Animation<double> animation,
  Widget Function(Animation<double> shown, Widget child) motion,
) {
  final shown = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.5, 1, curve: Curves.easeOutCubic),
  );
  return FadeTransition(opacity: shown, child: motion(shown, child));
}

/// A round-capped stroke in [color].
Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..color = color;

/// Draws the first [t] (0–1) of a check mark [width] wide around [center].
void _drawCheck(
  Canvas canvas,
  Offset center,
  double width,
  double t,
  Paint paint,
) {
  if (t <= 0) return;
  final u = width / 12;
  final path = Path()
    ..moveTo(center.dx - 5 * u, center.dy + 0.3 * u)
    ..lineTo(center.dx - 1.6 * u, center.dy + 3.6 * u)
    ..lineTo(center.dx + 5.2 * u, center.dy - 3.6 * u);
  if (t >= 1) {
    canvas.drawPath(path, paint);
    return;
  }
  for (final metric in path.computeMetrics()) {
    canvas.drawPath(metric.extractPath(0, metric.length * t), paint);
  }
}

/// Start angle and sweep of the refreshing arc at spin phase [s]: one calm
/// turn per cycle while the arc breathes between short and long.
({double start, double sweep}) _spinnerArc(double s, {required bool still}) {
  if (still) return (start: -math.pi / 2, sweep: math.pi * 1.5);
  final sweep =
      math.pi * 2 * (0.2 + 0.5 * (0.5 - 0.5 * math.cos(2 * math.pi * s)));
  return (start: -math.pi / 2 + 2 * math.pi * s - sweep / 2, sweep: sweep);
}

// ── ring ────────────────────────────────────────────────────────────────────

/// A disc whose arc winds up with the pull, breathes while refreshing and
/// closes into a check mark.
class _RingIndicator extends StatelessWidget {
  const _RingIndicator(this.frame);

  static const double size = 40;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.62,
        shrink: 0.3,
        child: AnimatedBuilder(
          animation: frame.pull,
          builder: (context, child) => Transform.scale(
            // A slight swell past the trigger point.
            scale: 1 + 0.06 * Curves.easeOut.transform(frame.overpull),
            child: child,
          ),
          child: _Surface(
            frame: frame,
            radius: size / 2,
            child: SizedBox.square(
              dimension: size,
              child: CustomPaint(painter: _RingPainter(frame)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.frame) : super(repaint: frame.ticks);

  final FxRefreshFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: 10);
    final color = frame.color;
    switch (frame.status) {
      case FxRefreshStatus.refresh:
        final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
        canvas.drawArc(rect, arc.start, arc.sweep, false, _stroke(color, 2.4));
      case FxRefreshStatus.done:
        final e = frame.exit.value;
        // The arc closes into a full ring, which then gives way to a check.
        final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
        final close = Curves.easeOutCubic.transform(_interval(e, 0, 0.3));
        final ring = 1 - _interval(e, 0.3, 0.55);
        if (ring > 0) {
          canvas.drawArc(
            rect,
            arc.start,
            lerpDouble(arc.sweep, math.pi * 2, close)!,
            false,
            _stroke(_fade(color, ring), 2.4),
          );
        }
        _drawCheck(
          canvas,
          center,
          13,
          Curves.easeOutCubic.transform(_interval(e, 0.28, 0.62)),
          _stroke(color, 2.4),
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        // The arc grows and winds clockwise with the pull.
        final p = frame.progress;
        final sweep = math.pi * 2 * 0.8 * Curves.easeOut.transform(p);
        if (sweep < 0.02) return;
        canvas.drawArc(
          rect,
          -math.pi / 2 + math.pi * p,
          sweep,
          false,
          _stroke(_fade(color, 0.35 + 0.65 * p), 2.4),
        );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => !old.frame.sameLook(frame);
}

// ── capsule ─────────────────────────────────────────────────────────────────

/// A pill with an icon and a label for each stage.
class _CapsuleIndicator extends StatelessWidget {
  const _CapsuleIndicator(this.frame);

  static const double height = 36;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    final labels = frame.labels;
    final label = switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled => labels.pull,
      FxRefreshStatus.armed => labels.release,
      FxRefreshStatus.snap || FxRefreshStatus.refresh => labels.refreshing,
      FxRefreshStatus.done => labels.done,
    };
    final motion = frame.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);
    return _Floating(
      frame: frame,
      extent: height,
      child: _ExitFade(
        frame: frame,
        from: 0.7,
        lift: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _Surface(
            frame: frame,
            radius: height / 2,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 16),
                child: AnimatedSize(
                  duration: motion,
                  curve: Curves.easeOutCubic,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: _CapsuleIcon(frame: frame, motion: motion),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: motion,
                          // The old label sinks away, then the new one rises
                          // into place.
                          transitionBuilder: (child, animation) => _swap(
                            child,
                            animation,
                            (shown, child) => SlideTransition(
                              position: Tween(
                                begin: const Offset(0, 0.35),
                                end: Offset.zero,
                              ).animate(shown),
                              child: child,
                            ),
                          ),
                          child: Text(
                            label,
                            key: ValueKey(label),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: frame.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The capsule's icon: an arrow that flips at the trigger point, a spinner
/// while refreshing, a check when done.
class _CapsuleIcon extends StatelessWidget {
  const _CapsuleIcon({required this.frame, required this.motion});

  final FxRefreshFrame frame;
  final Duration motion;

  static const _size = Size.square(16);

  @override
  Widget build(BuildContext context) {
    // Each icon is sized: the switcher's stack lays its children out loosely.
    final Widget icon = switch (frame.status) {
      FxRefreshStatus.drag ||
      FxRefreshStatus.armed ||
      FxRefreshStatus.canceled => AnimatedRotation(
        key: const ValueKey('arrow'),
        turns: frame.status == FxRefreshStatus.armed ? 0.5 : 0,
        duration: motion,
        curve: Curves.easeOutBack,
        child: CustomPaint(size: _size, painter: _ArrowPainter(frame.color)),
      ),
      FxRefreshStatus.snap || FxRefreshStatus.refresh => CustomPaint(
        key: const ValueKey('spinner'),
        size: _size,
        painter: _MiniSpinnerPainter(frame),
      ),
      FxRefreshStatus.done => CustomPaint(
        key: const ValueKey('check'),
        size: _size,
        painter: _MiniCheckPainter(frame),
      ),
    };
    return AnimatedSwitcher(
      duration: motion,
      transitionBuilder: (child, animation) => _swap(
        child,
        animation,
        (shown, child) => ScaleTransition(
          scale: Tween(begin: 0.5, end: 1.0).animate(shown),
          child: child,
        ),
      ),
      child: icon,
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 16;
    final paint = _stroke(color, 1.8 * u);
    canvas
      ..drawLine(Offset(8 * u, 3 * u), Offset(8 * u, 13 * u), paint)
      ..drawPath(
        Path()
          ..moveTo(3.8 * u, 8.8 * u)
          ..lineTo(8 * u, 13 * u)
          ..lineTo(12.2 * u, 8.8 * u),
        paint,
      );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

class _MiniSpinnerPainter extends CustomPainter {
  _MiniSpinnerPainter(this.frame) : super(repaint: frame.spin);

  final FxRefreshFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width * 0.38,
    );
    final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
    canvas.drawArc(rect, arc.start, arc.sweep, false, _stroke(frame.color, 2));
  }

  @override
  bool shouldRepaint(_MiniSpinnerPainter old) => !old.frame.sameLook(frame);
}

class _MiniCheckPainter extends CustomPainter {
  _MiniCheckPainter(this.frame) : super(repaint: frame.exit);

  final FxRefreshFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCheck(
      canvas,
      size.center(Offset.zero),
      size.width * 0.8,
      Curves.easeOutCubic.transform(_interval(frame.exit.value, 0, 0.25)),
      _stroke(frame.color, 2),
    );
  }

  @override
  bool shouldRepaint(_MiniCheckPainter old) => !old.frame.sameLook(frame);
}

// ── liquid ──────────────────────────────────────────────────────────────────

/// A drop stretched out of the top edge on a thinning neck. It snaps free at
/// the trigger point, spins while refreshing and pops when done.
class _LiquidIndicator extends StatelessWidget {
  const _LiquidIndicator(this.frame);

  static const double radius = 15;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: CustomPaint(painter: _LiquidPainter(frame)));
}

class _LiquidPainter extends CustomPainter {
  _LiquidPainter(this.frame) : super(repaint: frame.ticks);

  final FxRefreshFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    const r = _LiquidIndicator.radius;
    final color = frame.color;
    final p = frame.progress;
    final cx = size.width / 2;
    // Same travel as the floating styles: hidden at 0, resting at the
    // displacement at the trigger point.
    final cy = frame.pull.value * (frame.displacement + 2 * r) - r;
    final center = Offset(cx, cy);

    if (frame.status == FxRefreshStatus.done) {
      // The drop pops: it swells and fades while a ripple spreads.
      final e = Curves.easeOutCubic.transform(frame.exit.value);
      canvas
        ..drawCircle(
          center,
          r * (1 + 1.2 * e),
          _stroke(_fade(color, 0.5 * (1 - e)), 1.5),
        )
        ..drawCircle(
          center,
          r * (1 + 0.25 * e),
          Paint()..color = _fade(color, 1 - e),
        );
      return;
    }

    final fill = Paint()..color = color;
    if (frame.beforeTrigger) {
      // Still attached: the drop grows as it stretches on a thinning neck.
      // Near the trigger point the neck pinches off and its tip springs back
      // into the edge.
      final radius = r * lerpDouble(0.55, 1, Curves.easeOut.transform(p))!;
      final snap = Curves.easeIn.transform(_interval(p, 0.8, 1));
      if (snap < 1 && cy > 0) {
        final base = radius * lerpDouble(2.2, 1.0, p)! * (1 - 0.5 * snap);
        final waist = radius * lerpDouble(0.9, 0.06, p)!;
        // Where the neck meets the drop, on its upper flanks.
        final joinX = radius * 0.66;
        final joinY = cy - radius * 0.75;
        final tip = joinY * (1 - snap);
        canvas.drawPath(
          snap == 0
              ? (Path()
                  ..moveTo(cx - base, 0)
                  ..cubicTo(cx - waist, 0, cx - waist, joinY, cx - joinX, joinY)
                  ..lineTo(cx + joinX, joinY)
                  ..cubicTo(cx + waist, joinY, cx + waist, 0, cx + base, 0)
                  ..close())
              : (Path()
                  ..moveTo(cx - base, 0)
                  ..cubicTo(cx - waist, 0, cx - waist * 0.6, tip * 0.6, cx, tip)
                  ..cubicTo(
                    cx + waist * 0.6,
                    tip * 0.6,
                    cx + waist,
                    0,
                    cx + base,
                    0,
                  )
                  ..close()),
          fill,
        );
      }
      canvas.drawCircle(center, radius, fill);
      return;
    }

    // Free: a soft shadow lifts the drop off the content, with a slight swell
    // when overpulled and a spinner inside while refreshing.
    final radius = r * (1 + 0.06 * frame.overpull);
    canvas
      ..drawCircle(
        center + const Offset(0, 2),
        radius,
        Paint()
          ..color = Color(frame.dark ? 0x66000000 : 0x29101828)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(center, radius, fill);
    if (frame.status == FxRefreshStatus.refresh) {
      final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.5),
        arc.start,
        arc.sweep,
        false,
        _stroke(frame.background, 2.2),
      );
    }
  }

  @override
  bool shouldRepaint(_LiquidPainter old) => !old.frame.sameLook(frame);
}

// ── dots ────────────────────────────────────────────────────────────────────

/// Three dots that pop in one by one with the pull, ride a wave while
/// refreshing and merge into one when done.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator(this.frame);

  static const Size size = Size(64, 30);

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size.height,
      child: _ExitFade(
        frame: frame,
        from: 0.55,
        shrink: 0.2,
        child: _Surface(
          frame: frame,
          radius: size.height / 2,
          child: SizedBox.fromSize(
            size: size,
            child: CustomPaint(painter: _DotsPainter(frame)),
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.frame) : super(repaint: frame.ticks);

  final FxRefreshFrame frame;

  static const double _r = 3.6;
  static const double _gap = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = frame.color;
    // Dot 0 is on the leading side, so the stagger reads in the text
    // direction.
    double slot(int i) => frame.rtl ? 1.0 - i : i - 1.0;

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        for (var i = 0; i < 3; i++) {
          final hop = frame.reduceMotion
              ? 0.0
              : math.max(
                  0.0,
                  math.sin(2 * math.pi * (frame.spin.value - i * 0.16)),
                );
          paint.color = _fade(frame.color, 0.5 + 0.5 * hop);
          canvas.drawCircle(
            center + Offset(slot(i) * _gap, -4 * hop),
            _r,
            paint,
          );
        }
      case FxRefreshStatus.done:
        // The dots slide together, then the merged dot shrinks away.
        final e = frame.exit.value;
        final merge = Curves.easeInOutCubic.transform(_interval(e, 0, 0.45));
        final grow = Curves.easeOut.transform(_interval(e, 0.3, 0.5));
        final radius = _r * (1 + 0.35 * grow) * (1 - _interval(e, 0.55, 1));
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            center + Offset(slot(i) * _gap * (1 - merge), 0),
            radius,
            paint,
          );
        }
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        final spread = lerpDouble(0.45, 1, Curves.easeOut.transform(p))!;
        final swell = 1 + 0.18 * Curves.easeOut.transform(frame.overpull);
        for (var i = 0; i < 3; i++) {
          final appear = Curves.easeOutBack.transform(
            _interval(p, i * 0.22, i * 0.22 + 0.45),
          );
          if (appear <= 0) continue;
          canvas.drawCircle(
            center + Offset(slot(i) * _gap * spread, 0),
            _r * appear * swell,
            paint,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => !old.frame.sameLook(frame);
}

// ── line ────────────────────────────────────────────────────────────────────

/// A hairline on the top edge that grows from the center with the pull,
/// sweeps while refreshing and fills out when done.
class _LineIndicator extends StatelessWidget {
  const _LineIndicator(this.frame);

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: CustomPaint(painter: _LinePainter(frame)));
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.frame) : super(repaint: frame.ticks);

  final FxRefreshFrame frame;

  static const double _thickness = 3;

  @override
  void paint(Canvas canvas, Size size) {
    const y = _thickness / 2;
    final w = size.width;
    final color = frame.color;
    final line = Paint()
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.round;

    void track(double opacity) => canvas.drawLine(
      const Offset(0, y),
      Offset(w, y),
      line..color = _fade(color, opacity),
    );

    void glow(double from, double to, double opacity) => canvas.drawLine(
      Offset(from, y),
      Offset(to, y),
      Paint()
        ..strokeWidth = _thickness
        ..strokeCap = StrokeCap.round
        ..color = _fade(color, 0.4 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    void segment(double from, double to, double opacity, {bool lit = false}) {
      if (to - from < 0.5) return;
      if (lit) glow(from, to, opacity);
      canvas.drawLine(
        Offset(from, y),
        Offset(to, y),
        line..color = _fade(color, opacity),
      );
    }

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        track(0.14);
        if (frame.reduceMotion) {
          segment(0, w, 0.7);
          return;
        }
        // A comet that eases across in the text direction: a tail fading in
        // toward a bright, glowing head, longest mid-way. It fades in a
        // little way in rather than creeping out of the edge, so the line is
        // never empty for long.
        final s = frame.spin.value;
        final length = w * (0.22 + 0.18 * math.sin(math.pi * s));
        final head = lerpDouble(
          w * 0.2,
          w + length,
          Curves.easeInOutSine.transform(s),
        )!;
        final tail = head - length;
        final enter = _interval(s, 0, 0.12);
        final from = math.max(tail, 0.0);
        final to = math.min(head, w);
        if (to - from < 0.5) return;
        canvas.save();
        if (frame.rtl) {
          canvas
            ..translate(w, 0)
            ..scale(-1, 1);
        }
        final shader = LinearGradient(
          colors: [_fade(color, 0), _fade(color, enter)],
        ).createShader(Rect.fromLTRB(tail, 0, head, _thickness));
        glow(math.max(head - length * 0.4, 0), to, enter);
        canvas
          ..drawLine(
            Offset(from, y),
            Offset(to, y),
            Paint()
              ..strokeWidth = _thickness
              ..strokeCap = StrokeCap.round
              ..shader = shader,
          )
          ..restore();
      case FxRefreshStatus.done:
        // The line fills out from the center, then fades.
        final e = frame.exit.value;
        final fill = Curves.easeOutCubic.transform(_interval(e, 0, 0.35));
        final fade = 1 - Curves.easeIn.transform(_interval(e, 0.35, 1));
        track(0.14 * fade);
        segment(w / 2 * (1 - fill), w / 2 * (1 + fill), fade, lit: true);
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        // The width tracks the pull exactly: edge to edge at the trigger
        // point.
        final p = frame.progress;
        final half = w / 2 * p;
        track(0.14 * p);
        segment(
          w / 2 - half,
          w / 2 + half,
          0.4 + 0.6 * p,
          // Lights up at the trigger point.
          lit: !frame.beforeTrigger,
        );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => !old.frame.sameLook(frame);
}
