/// The looks of `FxRefreshIndicator`. Internal: the indicator picks one by
/// its `FxRefreshStyle` and hands it an [FxRefreshFrame]. The first five
/// live here with the shared pieces; the rest are in the part file.
library;

import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PathMetric, lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_refresh_indicator.dart';

part 'fx_refresh_styles_more.dart';

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
    required this.secondary,
    required this.onAccent,
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

  /// The accent's gradient partner: the tail of arcs and comets, the far end
  /// of fills.
  final Color secondary;

  /// A color that reads on the accent: check marks and labels on fills.
  final Color onAccent;

  /// The surface behind floating indicators. Translucent surfaces frost what
  /// is behind them.
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
      other.secondary == secondary &&
      other.onAccent == onAccent &&
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
      FxRefreshStyle.morph => _MorphIndicator(frame),
      FxRefreshStyle.spokes => _SpokesIndicator(frame),
      FxRefreshStyle.bars => _BarsIndicator(frame),
      FxRefreshStyle.infinity => _InfinityIndicator(frame),
      FxRefreshStyle.flip => _FlipIndicator(frame),
    };

/// How long [style]'s finish animation runs.
Duration fxRefreshExitDuration(FxRefreshStyle style) => switch (style) {
  FxRefreshStyle.ring => const Duration(milliseconds: 950),
  // Long enough to read the "done" label.
  FxRefreshStyle.capsule => const Duration(milliseconds: 1300),
  FxRefreshStyle.liquid => const Duration(milliseconds: 750),
  FxRefreshStyle.dots => const Duration(milliseconds: 1000),
  FxRefreshStyle.line => const Duration(milliseconds: 700),
  FxRefreshStyle.morph => const Duration(milliseconds: 900),
  FxRefreshStyle.spokes => const Duration(milliseconds: 900),
  FxRefreshStyle.bars => const Duration(milliseconds: 950),
  FxRefreshStyle.infinity => const Duration(milliseconds: 1100),
  FxRefreshStyle.flip => const Duration(milliseconds: 1000),
};

/// The height of the strip below the top edge that [style] draws in.
double fxRefreshAreaHeight(FxRefreshStyle style, double displacement) {
  final extent = switch (style) {
    FxRefreshStyle.ring => _RingIndicator.size,
    FxRefreshStyle.capsule => _CapsuleIndicator.height,
    FxRefreshStyle.liquid => _LiquidIndicator.radius * 2,
    FxRefreshStyle.dots => _DotsIndicator.size.height,
    FxRefreshStyle.line => 0.0,
    FxRefreshStyle.morph => _MorphIndicator.size,
    FxRefreshStyle.spokes => _SpokesIndicator.size,
    FxRefreshStyle.bars => _BarsIndicator.size,
    FxRefreshStyle.infinity => _InfinityIndicator.size.height,
    FxRefreshStyle.flip => _FlipIndicator.size,
  };
  if (style == FxRefreshStyle.line) return _LinePainter.area;
  // Overpulled position plus room for the shadow or the liquid's burst.
  return (displacement + extent) * 1.5 + 40;
}

// ── Shared pieces ───────────────────────────────────────────────────────────

/// [t] mapped onto the interval [begin]–[end], clamped to 0–1.
double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

/// [color] with its alpha multiplied by [opacity].
Color _fade(Color color, double opacity) =>
    color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0));

/// A springy bump over [k] from 0 to 1: up to 1 early on, a slight dip
/// below 0, then rest at 0.
double _bump(double k) =>
    k <= 0 || k >= 1 ? 0 : 2.6 * math.sin(2 * math.pi * k) * math.exp(-4.5 * k);

/// The accent gradient, from the partner color at the top left to the
/// accent at the bottom right.
LinearGradient _diagonal(FxRefreshFrame frame) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [frame.secondary, frame.color],
);

/// Where the top of a floating indicator [extent] tall sits for [pull]:
/// hidden above the edge at 0 and [displacement] below it at the trigger
/// point, the way Material's indicator moves. Past the trigger point it
/// stretches on less and less, like a rubber band.
double _travel(double pull, double displacement, double extent) {
  final span = displacement + extent;
  if (pull <= 1) return pull * span - extent;
  final over = ((pull - 1) / 0.5).clamp(0.0, 1.0);
  return displacement + span * 0.36 * Curves.easeOutCubic.transform(over);
}

/// Places a floating indicator [extent] tall along [_travel]. It fades and
/// grows in over the pull.
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
        final shown = Curves.easeOut.transform(pull.clamp(0.0, 1.0));
        return Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, _travel(pull, frame.displacement, extent)),
            child: Opacity(
              opacity: shown,
              child: Transform.scale(scale: 0.8 + 0.2 * shown, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Fades [child] out (and shrinks it by [shrink] and moves it up by [lift] ×
/// the fade) over the last part of the finish animation, from [from] on.
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

/// Hands [builder] an animation that plays from 0 to 1 each time [on] turns
/// true, for the little celebration at the trigger point. It rests at 1, and
/// stays there under reduced motion.
class _Kick extends StatefulWidget {
  const _Kick({
    required this.on,
    required this.reduceMotion,
    required this.builder,
  });

  final bool on;
  final bool reduceMotion;
  final Widget Function(BuildContext context, Animation<double> kick) builder;

  @override
  State<_Kick> createState() => _KickState();
}

class _KickState extends State<_Kick> with SingleTickerProviderStateMixin {
  late final AnimationController _kick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    value: 1,
  );

  @override
  void didUpdateWidget(_Kick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.on && !oldWidget.on && !widget.reduceMotion) {
      _kick.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _kick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _kick);
}

/// The raised surface behind the floating indicators: frosted glass when the
/// background is translucent, a sheen across its top, a hairline edge, a
/// soft shadow and a glow in the accent.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.frame,
    required this.radius,
    required this.child,
  });

  final FxRefreshFrame frame;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final dark = frame.dark;
    Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: frame.background,
        borderRadius: shape,
        border: Border.all(
          color: dark ? const Color(0x2EFFFFFF) : const Color(0x12101828),
          width: 0.8,
        ),
      ),
      // Light from above: a sheen across the top of a dark surface, a faint
      // shade toward the bottom of a light one.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          gradient: dark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
                )
              : const LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00101828), Color(0x0D101828)],
                ),
        ),
        child: child,
      ),
    );
    if (frame.background.a < 1) {
      body = ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: body,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: _fade(frame.color, dark ? 0.18 : 0.24),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: dark ? const Color(0x8C000000) : const Color(0x14101828),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: dark ? const Color(0x66000000) : const Color(0x0F101828),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: body,
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

/// Draws an arc of [sweep] radians from [start] on the circle of [radius]
/// around [center], shading from [from] at its tail (through [via] at 40%,
/// if given) to [to] at its head, with round ends.
void _gradientArc(
  Canvas canvas,
  Offset center,
  double radius,
  double start,
  double sweep,
  double width,
  Color from,
  Color to, {
  Color? via,
}) {
  if (sweep < 0.01) return;
  final rect = Rect.fromCircle(center: center, radius: radius);
  final turn = math.min(sweep, 2 * math.pi);
  canvas.drawArc(
    rect,
    start,
    turn,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = SweepGradient(
        endAngle: turn,
        colors: [from, ?via, to],
        stops: via == null ? null : const [0, 0.4, 1],
        transform: GradientRotation(start),
      ).createShader(rect),
  );
  if (turn >= 2 * math.pi - 0.001) return;
  // Round ends, each in the color of its own end.
  Offset at(double angle) =>
      center + Offset(math.cos(angle), math.sin(angle)) * radius;
  canvas
    ..drawCircle(at(start), width / 2, Paint()..color = from)
    ..drawCircle(at(start + turn), width / 2, Paint()..color = to);
}

/// Draws a rounded arrowhead [scale] × full size at [angle] on the circle of
/// [radius] around [center], pointing clockwise.
void _drawArrowHead(
  Canvas canvas,
  Offset center,
  double radius,
  double angle,
  double scale,
  Color color,
) {
  if (scale <= 0.01) return;
  final out = Offset(math.cos(angle), math.sin(angle));
  final along = Offset(-math.sin(angle), math.cos(angle));
  final base = center + out * radius;
  final s = 5 * scale;
  final tip = base + along * (1.15 * s);
  final a = base + out * s - along * (0.25 * s);
  final b = base - out * s - along * (0.25 * s);
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..close();
  canvas
    ..drawPath(path, Paint()..color = color)
    ..drawPath(path, _stroke(color, 1.2));
}

/// Start angle and sweep of a refreshing arc at spin phase [s]: one calm
/// turn per cycle while the arc breathes between short and long.
({double start, double sweep}) _spinnerArc(double s, {required bool still}) {
  if (still) return (start: -math.pi / 2, sweep: math.pi * 1.5);
  final sweep =
      math.pi * 2 * (0.2 + 0.5 * (0.5 - 0.5 * math.cos(2 * math.pi * s)));
  return (start: -math.pi / 2 + 2 * math.pi * s - sweep / 2, sweep: sweep);
}

/// Start angle and sweep of a comet at spin phase [s]: a turn per cycle that
/// surges and eases, its tail stretching and shrinking twice per turn.
({double start, double sweep}) _cometArc(double s, {required bool still}) {
  if (still) return (start: -math.pi / 2, sweep: math.pi * 1.5);
  final head =
      -math.pi / 2 + 2 * math.pi * (s + 0.06 * math.sin(2 * math.pi * s));
  final sweep = math.pi * 2 * (0.5 + 0.16 * math.sin(4 * math.pi * s));
  return (start: head - sweep, sweep: sweep);
}

/// Draws the comet for [frame]'s spin on the circle of [radius] around
/// [center]: a tail that fades in quickly, then shades from the partner
/// color to a bright head with a soft glow.
void _drawComet(
  Canvas canvas,
  Offset center,
  double radius,
  double width,
  FxRefreshFrame frame,
) {
  final head = frame.color;
  final tail = frame.secondary;
  final arc = _cometArc(frame.spin.value, still: frame.reduceMotion);
  final end = arc.start + arc.sweep;
  canvas.drawCircle(
    center + Offset(math.cos(end), math.sin(end)) * radius,
    width * 1.5,
    Paint()
      ..color = _fade(head, 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  _gradientArc(
    canvas,
    center,
    radius,
    arc.start,
    arc.sweep,
    width,
    _fade(tail, frame.reduceMotion ? 1 : 0),
    head,
    via: tail,
  );
}

// ── ring ────────────────────────────────────────────────────────────────────

/// A glass disc around a gradient refresh arrow that winds up with the pull,
/// closes into a glowing ring at the trigger point, orbits as a comet while
/// refreshing and floods with the accent behind a check mark when done.
class _RingIndicator extends StatelessWidget {
  const _RingIndicator(this.frame);

  static const double size = 46;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.72,
        shrink: 0.4,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => AnimatedBuilder(
            animation: Listenable.merge([kick, frame.pull, frame.exit]),
            builder: (context, child) {
              final done = frame.status == FxRefreshStatus.done;
              // A pop at the trigger point and another as the check lands,
              // plus a slight swell when overpulled.
              final pop =
                  0.12 * _bump(kick.value) +
                  0.06 * Curves.easeOut.transform(frame.overpull) +
                  (done
                      ? 0.1 * _bump(_interval(frame.exit.value, 0.2, 0.75))
                      : 0);
              return Transform.scale(scale: 1 + pop, child: child);
            },
            child: _Surface(
              frame: frame,
              radius: size / 2,
              child: SizedBox.square(
                dimension: size,
                child: CustomPaint(painter: _RingPainter(frame, kick)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  static const double _radius = 13.5;
  static const double _width = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final accent = frame.color;
    final track = frame.dark ? 0.24 : 0.13;
    void drawTrack(double opacity) => canvas.drawCircle(
      center,
      _radius,
      _stroke(_fade(accent, track * opacity), _width),
    );

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        drawTrack(1);
        _drawComet(canvas, center, _radius, _width, frame);
      case FxRefreshStatus.done:
        final e = frame.exit.value;
        // The comet closes into a full ring, the disc floods with the accent
        // from the middle, and a check mark draws on it.
        final close = Curves.easeOutCubic.transform(_interval(e, 0, 0.24));
        final arc = _cometArc(frame.spin.value, still: frame.reduceMotion);
        drawTrack(1);
        _gradientArc(
          canvas,
          center,
          _radius,
          arc.start,
          lerpDouble(arc.sweep, 2 * math.pi, close)!,
          _width,
          Color.lerp(_fade(frame.secondary, 0), accent, close)!,
          accent,
          via: Color.lerp(frame.secondary, accent, close),
        );
        final flood = Curves.easeOutCubic.transform(_interval(e, 0.16, 0.44));
        if (flood > 0) {
          final disc = Rect.fromCircle(center: center, radius: size.width / 2);
          canvas.drawCircle(
            center,
            size.width / 2 * flood,
            Paint()..shader = _diagonal(frame).createShader(disc),
          );
        }
        _drawCheck(
          canvas,
          center,
          17,
          Curves.easeOutCubic.transform(_interval(e, 0.34, 0.62)),
          _stroke(frame.onAccent, 2.6),
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        final grow = Curves.easeOut.transform(p);
        // 0 short of the trigger point; past it, runs to 1 as the arc closes.
        final ready = frame.beforeTrigger
            ? 0.0
            : Curves.easeOutCubic.transform(kick.value);
        drawTrack(grow);
        final sweep = lerpDouble(
          2 * math.pi * 0.78 * grow,
          2 * math.pi,
          ready,
        )!;
        if (sweep < 0.02) return;
        // The arrow winds clockwise as it grows.
        final start = -math.pi / 2 + math.pi * 0.85 * p;
        if (ready > 0) {
          canvas.drawCircle(
            center,
            _radius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _width + 3
              ..color = _fade(accent, 0.4 * ready)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
        _gradientArc(
          canvas,
          center,
          _radius,
          start,
          sweep,
          _width,
          _fade(
            Color.lerp(frame.secondary, accent, ready)!,
            0.45 + 0.55 * grow,
          ),
          accent,
        );
        _drawArrowHead(
          canvas,
          center,
          _radius,
          start + sweep,
          (1 - ready) * Curves.easeOut.transform(_interval(p, 0.2, 0.6)),
          accent,
        );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── capsule ─────────────────────────────────────────────────────────────────

/// A glass pill that grows out of a round badge as you pull, fills with a
/// tint toward the trigger point, shimmers while refreshing and floods with
/// the accent to say it is done.
class _CapsuleIndicator extends StatelessWidget {
  const _CapsuleIndicator(this.frame);

  static const double height = 40;
  static const double _badge = 28;

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
        : const Duration(milliseconds: 300);
    const inset = (height - _badge) / 2;
    return _Floating(
      frame: frame,
      extent: height,
      child: _ExitFade(
        frame: frame,
        from: 0.74,
        lift: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _Surface(
            frame: frame,
            radius: height / 2,
            child: CustomPaint(
              painter: _CapsuleFillPainter(frame),
              child: SizedBox(
                height: height,
                child: AnimatedBuilder(
                  animation: frame.pull,
                  builder: (context, child) {
                    // The pill opens out of the badge early in the pull and
                    // closes into it again when let go too soon.
                    final reveal = frame.beforeTrigger
                        ? Curves.easeOutCubic.transform(
                            _interval(frame.progress, 0.1, 0.55),
                          )
                        : 1.0;
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: inset,
                        end: inset + 10 * reveal,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CapsuleBadge(frame: frame, motion: motion),
                          Flexible(
                            child: ClipRect(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                widthFactor: reveal,
                                child: Opacity(opacity: reveal, child: child),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: AnimatedSize(
                      duration: motion,
                      curve: Curves.easeOutCubic,
                      alignment: AlignmentDirectional.centerStart,
                      child: AnimatedSwitcher(
                        duration: motion,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previous, ?current],
                        ),
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
                        child: _CapsuleLabel(
                          key: ValueKey((label, frame.status)),
                          frame: frame,
                          text: label,
                        ),
                      ),
                    ),
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

/// The capsule's text: on the accent when done, with a sheen sweeping
/// through it while refreshing.
class _CapsuleLabel extends StatelessWidget {
  const _CapsuleLabel({super.key, required this.frame, required this.text});

  final FxRefreshFrame frame;
  final String text;

  @override
  Widget build(BuildContext context) {
    final done = frame.status == FxRefreshStatus.done;
    final ink = done ? frame.onAccent : frame.foreground;
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ink,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.2,
      ),
    );
    if (frame.status != FxRefreshStatus.refresh || frame.reduceMotion) {
      return label;
    }
    return AnimatedBuilder(
      animation: frame.spin,
      child: label,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          // A band of the accent that crosses the text in the text
          // direction, once per cycle.
          final s = frame.rtl ? 1 - frame.spin.value : frame.spin.value;
          return LinearGradient(
            colors: [ink, frame.color, ink],
            stops: const [0.3, 0.5, 0.7],
          ).createShader(
            bounds.shift(Offset(lerpDouble(-1, 1, s)! * bounds.width, 0)),
          );
        },
        child: child,
      ),
    );
  }
}

/// The capsule's round badge: a tinted arrow while pulling, the solid accent
/// once armed, a frosted circle behind the check when done.
class _CapsuleBadge extends StatelessWidget {
  const _CapsuleBadge({required this.frame, required this.motion});

  final FxRefreshFrame frame;
  final Duration motion;

  @override
  Widget build(BuildContext context) {
    final status = frame.status;
    final done = status == FxRefreshStatus.done;
    final solid = !frame.beforeTrigger && !done;
    final decoration = done
        ? BoxDecoration(
            shape: BoxShape.circle,
            color: _fade(frame.onAccent, 0.2),
          )
        : solid
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: _diagonal(frame),
            boxShadow: [
              BoxShadow(
                color: _fade(frame.color, 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: _fade(frame.color, frame.dark ? 0.22 : 0.12),
          );
    return AnimatedContainer(
      duration: motion,
      curve: Curves.easeOutCubic,
      width: _CapsuleIndicator._badge,
      height: _CapsuleIndicator._badge,
      alignment: Alignment.center,
      decoration: decoration,
      child: SizedBox.square(
        dimension: 16,
        child: _CapsuleIcon(
          frame: frame,
          motion: motion,
          ink: solid || done ? frame.onAccent : frame.color,
        ),
      ),
    );
  }
}

/// The capsule's icon: an arrow that flips at the trigger point, a spinner
/// while refreshing, a check when done.
class _CapsuleIcon extends StatelessWidget {
  const _CapsuleIcon({
    required this.frame,
    required this.motion,
    required this.ink,
  });

  final FxRefreshFrame frame;
  final Duration motion;
  final Color ink;

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
        child: CustomPaint(size: _size, painter: _ArrowPainter(ink)),
      ),
      FxRefreshStatus.snap || FxRefreshStatus.refresh => CustomPaint(
        key: const ValueKey('spinner'),
        size: _size,
        painter: _MiniSpinnerPainter(frame, ink),
      ),
      FxRefreshStatus.done => CustomPaint(
        key: const ValueKey('check'),
        size: _size,
        painter: _MiniCheckPainter(frame, ink),
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
    final paint = _stroke(color, 2 * u);
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
  _MiniSpinnerPainter(this.frame, this.color) : super(repaint: frame.spin);

  final FxRefreshFrame frame;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width * 0.38,
    );
    final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
    canvas.drawArc(rect, arc.start, arc.sweep, false, _stroke(color, 2));
  }

  @override
  bool shouldRepaint(_MiniSpinnerPainter old) =>
      !old.frame.sameLook(frame) || old.color != color;
}

class _MiniCheckPainter extends CustomPainter {
  _MiniCheckPainter(this.frame, this.color) : super(repaint: frame.exit);

  final FxRefreshFrame frame;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCheck(
      canvas,
      size.center(Offset.zero),
      size.width * 0.8,
      Curves.easeOutCubic.transform(_interval(frame.exit.value, 0.12, 0.36)),
      _stroke(color, 2.2),
    );
  }

  @override
  bool shouldRepaint(_MiniCheckPainter old) =>
      !old.frame.sameLook(frame) || old.color != color;
}

/// The capsule's fills: a tint that grows toward the trigger point, then the
/// accent flooding out of the badge with a sheen crossing it when done.
class _CapsuleFillPainter extends CustomPainter {
  _CapsuleFillPainter(this.frame) : super(repaint: frame.ticks);

  final FxRefreshFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final pill = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(h / 2),
    );
    // A pill [width] wide on the leading side.
    RRect lead(double width) => RRect.fromRectAndRadius(
      frame.rtl
          ? Rect.fromLTWH(size.width - width, 0, width, h)
          : Rect.fromLTWH(0, 0, width, h),
      Radius.circular(h / 2),
    );
    final tint = _fade(frame.color, frame.dark ? 0.16 : 0.09);
    switch (frame.status) {
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.canceled:
        final p = Curves.easeOut.transform(frame.progress);
        canvas.drawRRect(
          lead(lerpDouble(h, size.width, p)!),
          Paint()..color = _fade(tint, p),
        );
      case FxRefreshStatus.snap || FxRefreshStatus.refresh:
        canvas.drawRRect(pill, Paint()..color = tint);
      case FxRefreshStatus.done:
        final e = frame.exit.value;
        final flood = Curves.easeOutCubic.transform(_interval(e, 0, 0.3));
        final fill = lead(lerpDouble(h, size.width, flood)!);
        canvas
          ..drawRRect(pill, Paint()..color = _fade(tint, 1 - flood))
          ..drawRRect(
            fill,
            Paint()
              ..shader = LinearGradient(
                colors: frame.rtl
                    ? [frame.color, frame.secondary]
                    : [frame.secondary, frame.color],
              ).createShader(Offset.zero & size),
          );
        // A slanted sheen crosses the filled pill once.
        final sheen = _interval(e, 0.3, 0.68);
        if (sheen > 0 && sheen < 1) {
          final x = lerpDouble(-0.3, 1.3, Curves.easeInOut.transform(sheen))!;
          final at = (frame.rtl ? 1 - x : x) * size.width;
          canvas
            ..save()
            ..clipRRect(fill)
            ..drawRect(
              Rect.fromLTWH(at - 30, 0, 60, h),
              Paint()
                ..shader = const LinearGradient(
                  begin: Alignment(-1, -0.4),
                  end: Alignment(1, 0.4),
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0x47FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ).createShader(Rect.fromLTWH(at - 30, 0, 60, h)),
            )
            ..restore();
        }
    }
  }

  @override
  bool shouldRepaint(_CapsuleFillPainter old) => !old.frame.sameLook(frame);
}

// ── liquid ──────────────────────────────────────────────────────────────────

/// A glossy drop stretched out of the top edge on a thinning neck. It snaps
/// free at the trigger point with a jiggle, wobbles while refreshing and
/// bursts into droplets when done.
class _LiquidIndicator extends StatelessWidget {
  const _LiquidIndicator(this.frame);

  static const double radius = 16;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) => _Kick(
    on: frame.status == FxRefreshStatus.armed,
    reduceMotion: frame.reduceMotion,
    builder: (context, kick) => SizedBox.expand(
      child: CustomPaint(painter: _LiquidPainter(frame, kick)),
    ),
  );
}

class _LiquidPainter extends CustomPainter {
  _LiquidPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  /// The body color: the partner color at the top, the accent below.
  Shader _body(Rect bounds) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [frame.secondary, frame.color],
  ).createShader(bounds);

  /// A soft shadow under a drop in [oval], [opacity] strong.
  void _shadow(Canvas canvas, Rect oval, double opacity) {
    if (opacity <= 0) return;
    canvas.drawOval(
      oval.shift(const Offset(0, 4)),
      Paint()
        ..color = _fade(
          frame.dark ? const Color(0x8C000000) : frame.color,
          (frame.dark ? 1 : 0.42) * opacity,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  /// The glint on the upper left of a drop in [oval].
  void _glint(Canvas canvas, Rect oval, double opacity) {
    final w = oval.width / 2;
    final h = oval.height / 2;
    canvas
      ..save()
      ..translate(oval.center.dx - w * 0.36, oval.center.dy - h * 0.42)
      ..rotate(-math.pi / 5)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.62, height: h * 0.34),
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, 0.5 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
      )
      ..restore();
  }

  /// A free drop of [radius] around [center], squashed by [sx] and [sy].
  void _drop(
    Canvas canvas,
    Offset center,
    double radius, {
    double sx = 1,
    double sy = 1,
  }) {
    if (radius <= 0.2) return;
    final oval = Rect.fromCenter(
      center: center,
      width: 2 * radius * sx,
      height: 2 * radius * sy,
    );
    _shadow(canvas, oval, 1);
    canvas.drawOval(oval, Paint()..shader = _body(oval));
    _glint(canvas, oval, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const r = _LiquidIndicator.radius;
    final p = frame.progress;
    final cx = size.width / 2;
    // Same travel as the floating styles: hidden at 0, resting at the
    // displacement at the trigger point.
    final cy = _travel(frame.pull.value, frame.displacement, 2 * r) + r;
    final center = Offset(cx, cy);

    switch (frame.status) {
      case FxRefreshStatus.done:
        // The drop gathers itself, then bursts: droplets fly out and fall
        // away while a ripple spreads.
        final e = frame.exit.value;
        final squeeze = Curves.easeInOut.transform(_interval(e, 0, 0.22));
        final burst = _interval(e, 0.22, 0.85);
        final out = Curves.easeOutCubic.transform(burst);
        if (burst > 0 && burst < 1) {
          canvas.drawCircle(
            center,
            r * (0.9 + 1.3 * out),
            _stroke(_fade(frame.color, 0.5 * (1 - out)), 0.4 + 2.2 * (1 - out)),
          );
          final left = 1 - Curves.easeInCubic.transform(burst);
          for (var i = 0; i < 8; i++) {
            final angle = -math.pi / 2 + (i + 0.5) * math.pi / 4;
            final reach = r * (0.55 + (i.isEven ? 1.25 : 0.95) * out);
            final droplet = (i.isEven ? 4.4 : 3.3) * left;
            if (droplet <= 0.3) continue;
            canvas.drawCircle(
              center +
                  Offset(math.cos(angle), math.sin(angle)) * reach +
                  Offset(0, 6 * burst * burst),
              droplet,
              Paint()
                ..color = _fade(
                  Color.lerp(frame.secondary, frame.color, i / 7)!,
                  math.min(1, left * 1.6),
                ),
            );
          }
        }
        final pop = 1 - Curves.easeIn.transform(_interval(e, 0.22, 0.4));
        _drop(
          canvas,
          center,
          r * (1 - 0.1 * squeeze) * pop,
          sx: 1 + 0.12 * squeeze,
          sy: 1 - 0.12 * squeeze,
        );
      case FxRefreshStatus.drag || FxRefreshStatus.canceled:
        // Still attached: the drop grows as it stretches on a thinning neck.
        // Near the trigger point the neck pinches off and its tip springs
        // back into the edge.
        final radius = r * lerpDouble(0.55, 1, Curves.easeOut.transform(p))!;
        final snap = Curves.easeIn.transform(_interval(p, 0.8, 1));
        final oval = Rect.fromCircle(center: center, radius: radius);
        final body = Paint()
          ..shader = _body(
            Rect.fromLTRB(
              cx - r,
              math.min(0, cy - radius),
              cx + r,
              cy + radius,
            ),
          );
        _shadow(canvas, oval, 0.6 * p);
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
                    ..cubicTo(
                      cx - waist,
                      0,
                      cx - waist,
                      joinY,
                      cx - joinX,
                      joinY,
                    )
                    ..lineTo(cx + joinX, joinY)
                    ..cubicTo(cx + waist, joinY, cx + waist, 0, cx + base, 0)
                    ..close())
                : (Path()
                    ..moveTo(cx - base, 0)
                    ..cubicTo(
                      cx - waist,
                      0,
                      cx - waist * 0.6,
                      tip * 0.6,
                      cx,
                      tip,
                    )
                    ..cubicTo(
                      cx + waist * 0.6,
                      tip * 0.6,
                      cx + waist,
                      0,
                      cx + base,
                      0,
                    )
                    ..close()),
            body,
          );
        }
        canvas.drawOval(oval, body);
        _glint(canvas, oval, p);
      case FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.refresh:
        // Free: it jiggles as it lets go, swells a little when overpulled
        // and wobbles around a spinner while refreshing.
        final jiggle = 0.16 * _bump(kick.value);
        var sx = 1 - 0.7 * jiggle;
        var sy = 1 + jiggle;
        final refreshing = frame.status == FxRefreshStatus.refresh;
        if (refreshing && !frame.reduceMotion) {
          final wobble = 0.04 * math.sin(4 * math.pi * frame.spin.value);
          sx += wobble;
          sy -= wobble;
        }
        _drop(canvas, center, r * (1 + 0.06 * frame.overpull), sx: sx, sy: sy);
        if (refreshing) {
          final arc = _spinnerArc(frame.spin.value, still: frame.reduceMotion);
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: r * 0.46),
            arc.start,
            arc.sweep,
            false,
            _stroke(frame.onAccent, 2.2),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_LiquidPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── dots ────────────────────────────────────────────────────────────────────

/// Three gradient dots on a glass pill: they rise in one by one with the
/// pull, ripple at the trigger point, bounce with squash and stretch while
/// refreshing and merge into a check badge when done.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator(this.frame);

  static const Size size = Size(80, 34);

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size.height,
      child: _ExitFade(
        frame: frame,
        from: 0.76,
        shrink: 0.25,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => _Surface(
            frame: frame,
            radius: size.height / 2,
            child: SizedBox.fromSize(
              size: size,
              child: CustomPaint(painter: _DotsPainter(frame, kick)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  static const double _r = 4.4;
  static const double _gap = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Dot 0 is on the leading side, so staggers read in the text direction,
    // and the gradient runs from the partner color to the accent.
    double slot(int i) => frame.rtl ? 1.0 - i : i - 1.0;
    Color tone(int i) => Color.lerp(frame.secondary, frame.color, i / 2)!;
    void dot(Offset c, double r, Color color, {double sx = 1, double sy = 1}) {
      if (r <= 0.1) return;
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 2 * r * sx, height: 2 * r * sy),
        Paint()..color = color,
      );
    }

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        // Each dot hops off the line it rests on, stretching in flight and
        // squashing as it lands.
        final ground = center.dy + _r;
        for (var i = 0; i < 3; i++) {
          final x = center.dx + slot(i) * _gap;
          var lift = 0.0;
          var sx = 1.0;
          var sy = 1.0;
          if (!frame.reduceMotion) {
            final phase = (frame.spin.value * 2 - i * 0.13) % 1.0;
            if (phase < 0.56) {
              final t = phase / 0.56;
              lift = 7 * 4 * t * (1 - t);
              final stretch = 0.36 * math.sin(math.pi * t) * (1 - 2 * t).abs();
              sy = 1 + stretch;
              sx = 1 - 0.7 * stretch;
            } else if (phase < 0.74) {
              final squash = math.sin(math.pi * (phase - 0.56) / 0.18);
              sy = 1 - 0.3 * squash;
              sx = 1 + 0.24 * squash;
            }
          }
          dot(Offset(x, ground - _r * sy - lift), _r, tone(i), sx: sx, sy: sy);
        }
      case FxRefreshStatus.done:
        // The dots slide together into one, which swells into a badge with
        // a check mark.
        final e = frame.exit.value;
        final merge = Curves.easeInOutCubic.transform(_interval(e, 0, 0.3));
        if (merge < 1) {
          for (var i = 0; i < 3; i++) {
            dot(
              center + Offset(slot(i) * _gap * (1 - merge), 0),
              _r * (1 + 0.3 * merge),
              Color.lerp(tone(i), frame.color, merge)!,
            );
          }
          return;
        }
        final grow = Curves.easeOutBack.transform(_interval(e, 0.28, 0.52));
        final radius = lerpDouble(_r * 1.3, 12, grow)!;
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = _diagonal(
              frame,
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
        _drawCheck(
          canvas,
          center,
          13,
          Curves.easeOutCubic.transform(_interval(e, 0.42, 0.66)),
          _stroke(frame.onAccent, 2.2),
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        final spread = lerpDouble(0.5, 1, Curves.easeOut.transform(p))!;
        final swell = 1 + 0.15 * Curves.easeOut.transform(frame.overpull);
        for (var i = 0; i < 3; i++) {
          final local = _interval(p, i * 0.2, i * 0.2 + 0.4);
          final appear = Curves.easeOutBack.transform(local);
          if (appear <= 0) continue;
          // Each rises into place as it appears, and hops in turn at the
          // trigger point.
          final rise = 6 * (1 - Curves.easeOutCubic.transform(local));
          final hop = frame.beforeTrigger
              ? 0.0
              : 7 * _bump(_interval(kick.value, i * 0.1, i * 0.1 + 0.62));
          dot(
            center + Offset(slot(i) * _gap * spread, rise - hop),
            _r * appear * swell,
            tone(i),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── line ────────────────────────────────────────────────────────────────────

/// A gradient string across the top edge. The pull bows it down; it glows at
/// the trigger point and twangs back straight when let go, a comet runs along
/// it while refreshing and it flashes out from the middle when done.
class _LineIndicator extends StatefulWidget {
  const _LineIndicator(this.frame);

  final FxRefreshFrame frame;

  @override
  State<_LineIndicator> createState() => _LineIndicatorState();
}

class _LineIndicatorState extends State<_LineIndicator>
    with SingleTickerProviderStateMixin {
  /// Runs once from release, while the string springs back.
  late final AnimationController _spring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );

  /// How far the string was bowed when let go.
  double _released = 0;

  @override
  void didUpdateWidget(_LineIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final frame = widget.frame;
    if (frame.status == FxRefreshStatus.snap &&
        oldWidget.frame.status != FxRefreshStatus.snap) {
      _released = _LinePainter.bowFor(frame);
      if (!frame.reduceMotion && _released > 0) _spring.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomPaint(painter: _LinePainter(widget.frame, _spring, _released)),
  );
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.frame, this.spring, this.released)
    : super(repaint: Listenable.merge([frame.ticks, spring]));

  final FxRefreshFrame frame;
  final Animation<double> spring;
  final double released;

  /// The height the string can bow into, glow included.
  static const double area = 60;

  static const double _thickness = 3;

  /// How far the pull bows the string at its middle.
  static double bowFor(FxRefreshFrame frame) =>
      26 * Curves.easeOut.transform(frame.progress) +
      14 * Curves.easeOut.transform(frame.overpull);

  /// The current bow: the pull's while dragging, a damped twang once let go.
  double get _bow {
    if (frame.status == FxRefreshStatus.drag ||
        frame.status == FxRefreshStatus.armed ||
        frame.status == FxRefreshStatus.canceled) {
      return bowFor(frame);
    }
    final t = spring.value;
    if (t >= 1) return 0;
    final bow =
        released *
        (1 - t) *
        math.exp(-2.8 * t) *
        math.cos(2 * math.pi * 2.4 * t);
    // It can only flick a little way up past the edge.
    return bow < 0 ? bow * 0.3 : bow;
  }

  /// The string, pinned at both ends, bowed by [bow] in a smooth bell.
  static Path _string(double width, double bow) {
    const y = _thickness / 2 + 0.5;
    final mid = y + bow;
    return Path()
      ..moveTo(0, y)
      ..cubicTo(width * 0.28, y, width * 0.34, mid, width / 2, mid)
      ..cubicTo(width * 0.66, mid, width * 0.72, y, width, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final accent = frame.color;
    final path = _string(w, _bow);

    Paint line({double width = _thickness}) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The partner color at both ends, the accent in the middle.
    Shader shade(double opacity) => LinearGradient(
      colors: [
        _fade(frame.secondary, opacity),
        _fade(accent, opacity),
        _fade(frame.secondary, opacity),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, size.height));

    void glow(Path path, double opacity) {
      if (opacity <= 0) return;
      canvas.drawPath(
        path,
        line(width: 7)
          ..color = _fade(accent, 0.45 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    void track(double opacity) =>
        canvas.drawPath(path, line()..color = _fade(accent, opacity));

    switch (frame.status) {
      case FxRefreshStatus.drag || FxRefreshStatus.canceled:
        final shown = Curves.easeOut.transform(frame.progress);
        if (shown <= 0) return;
        canvas.drawPath(path, line()..shader = shade(shown));
      case FxRefreshStatus.armed || FxRefreshStatus.snap:
        glow(path, 1);
        canvas.drawPath(path, line()..shader = shade(1));
      case FxRefreshStatus.refresh:
        track(frame.dark ? 0.24 : 0.16);
        if (frame.reduceMotion) {
          canvas.drawPath(path, line()..shader = shade(0.75));
          return;
        }
        // A comet that eases across in the text direction: a tail fading in
        // toward a bright, glowing head, longest mid-way. It fades in a
        // little way in rather than creeping out of the edge, so the line is
        // never empty for long.
        final metric = path.computeMetrics().first;
        final length = metric.length;
        final s = frame.spin.value;
        final comet = length * (0.22 + 0.18 * math.sin(math.pi * s));
        final head = lerpDouble(
          length * 0.2,
          length + comet,
          Curves.easeInOutSine.transform(s),
        )!;
        final tail = head - comet;
        final from = math.max(tail, 0.0);
        final to = math.min(head, length);
        if (to - from < 0.5) return;
        final enter = _interval(s, 0, 0.12);
        canvas.save();
        if (frame.rtl) {
          canvas
            ..translate(w, 0)
            ..scale(-1, 1);
        }
        glow(metric.extractPath(math.max(head - comet * 0.4, 0), to), enter);
        canvas
          ..drawPath(
            metric.extractPath(from, to),
            line()
              ..shader = LinearGradient(
                colors: [_fade(frame.secondary, 0), _fade(accent, enter)],
              ).createShader(Rect.fromLTRB(tail, 0, head, _thickness)),
          )
          ..restore();
      case FxRefreshStatus.done:
        // The string lights up from the middle out, then fades.
        final e = frame.exit.value;
        final fill = Curves.easeOutCubic.transform(_interval(e, 0, 0.35));
        final fade = 1 - Curves.easeIn.transform(_interval(e, 0.35, 1));
        track((frame.dark ? 0.24 : 0.16) * fade);
        final metric = path.computeMetrics().first;
        final half = metric.length / 2;
        final lit = metric.extractPath(half * (1 - fill), half * (1 + fill));
        glow(lit, fade);
        canvas.drawPath(lit, line()..shader = shade(fade));
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      !old.frame.sameLook(frame) ||
      old.spring != spring ||
      old.released != released;
}
