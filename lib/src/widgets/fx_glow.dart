import 'dart:math' as math;
import 'dart:ui' as ui show Gradient;
import 'dart:ui' show PathMetric, lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// How [FxGlow] lights up its child.
enum FxGlowStyle {
  /// A soft two-tone halo that breathes in and out.
  pulse,

  /// A spectrum of the glow colors that turns round the child, with a thin
  /// light along its border: the "AI" glow.
  aurora,

  /// Glowing rings that radiate outward and fade, like a live signal.
  beacon,

  /// A bright tube along the border inside a wide halo that hums and
  /// flickers now and then, like a neon sign.
  neon,

  /// Two lights that chase each other round the border, lighting up the
  /// halo where they pass.
  orbit,

  /// A faint halo that wakes up under the mouse: the border lights up nearest
  /// the pointer and the glow flares while pressed.
  hover,
}

/// Wraps [child] in an animated glow, in one of the [FxGlowStyle]s.
///
/// The glow follows the child's rounded rectangle ([borderRadius]) or circle
/// ([shape]) and is drawn around it without changing its size, reaching about
/// [spread] pixels out. Leave that much room around it, and keep clipping
/// ancestors (such as a scroll view's edge) away from it, so the glow is not
/// cut off.
///
/// The glow is painted on its own layer, so animating it never repaints the
/// child. Under the platform "reduce motion" setting it holds a still frame,
/// and the `hover` style changes without easing.
///
/// ```dart
/// FxGlow(
///   style: FxGlowStyle.aurora,
///   borderRadius: 20,
///   child: card,
/// );
///
/// avatar.fxGlow(style: FxGlowStyle.beacon, shape: BoxShape.circle);
/// ```
class FxGlow extends StatefulWidget {
  const FxGlow({
    super.key,
    required this.child,
    this.style = FxGlowStyle.pulse,
    this.color = const Color(0xFF2575FC),
    this.secondaryColor,
    this.borderRadius = 16,
    this.shape = BoxShape.rectangle,
    this.spread = 18,
    this.intensity = 1,
    this.duration,
  }) : assert(spread >= 0, 'spread must not be negative'),
       assert(intensity >= 0, 'intensity must not be negative');

  final Widget child;

  /// The look; see [FxGlowStyle].
  final FxGlowStyle style;

  /// The main glow color.
  final Color color;

  /// The second tone the glow blends into. Defaults to a neighbor of [color]
  /// on the color wheel (or a lighter or darker shade of a gray).
  final Color? secondaryColor;

  /// The corner radius of the glowing rounded rectangle. Ignored when
  /// [shape] is [BoxShape.circle].
  final double borderRadius;

  /// [BoxShape.circle] makes the glow round, for avatars and icon buttons.
  final BoxShape shape;

  /// About how far the glow reaches beyond the child, in logical pixels.
  final double spread;

  /// Scales the glow's opacity: below 1 is subtler, above 1 is stronger.
  final double intensity;

  /// The length of one cycle. Defaults to a period that suits the [style].
  /// Unused by [FxGlowStyle.hover], which follows the pointer instead.
  final Duration? duration;

  @override
  State<FxGlow> createState() => _FxGlowState();
}

class _FxGlowState extends State<FxGlow>
    with TickerProviderStateMixin, FxMotionAware {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: _period,
  );
  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 480),
  );
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 520),
  );
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  Duration get _period =>
      widget.duration ??
      switch (widget.style) {
        FxGlowStyle.pulse => const Duration(milliseconds: 2200),
        FxGlowStyle.aurora => const Duration(milliseconds: 4500),
        FxGlowStyle.beacon => const Duration(milliseconds: 2400),
        FxGlowStyle.neon => const Duration(milliseconds: 3200),
        FxGlowStyle.orbit => const Duration(milliseconds: 3600),
        FxGlowStyle.hover => const Duration(seconds: 1),
      };

  /// The frame each style holds under reduced motion.
  static double _still(FxGlowStyle style) => switch (style) {
    FxGlowStyle.pulse => 0.4,
    FxGlowStyle.beacon => 0.15,
    FxGlowStyle.neon => 0.5,
    FxGlowStyle.orbit => 0.125,
    FxGlowStyle.aurora || FxGlowStyle.hover => 0,
  };

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant FxGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style ||
        widget.duration != oldWidget.duration) {
      _loop.duration = _period;
      if (widget.style != FxGlowStyle.hover) {
        _hover.value = 0;
        _press.value = 0;
        _pointer.value = null;
      }
      _sync();
    }
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) => _sync();

  /// Loops the styles that loop, or holds them still under reduced motion.
  void _sync() {
    if (widget.style == FxGlowStyle.hover) {
      _loop.stop();
    } else if (reduceMotion) {
      _loop
        ..stop()
        ..value = _still(widget.style);
    } else {
      // Restarts with the current period.
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _hover.dispose();
    _press.dispose();
    _pointer.dispose();
    super.dispose();
  }

  void _to(AnimationController controller, double target) {
    if (reduceMotion) {
      controller.value = target;
    } else if (target > controller.value) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    _GlowPainter painter({required bool front}) => _GlowPainter(
      front: front,
      style: style,
      color: widget.color,
      secondary: widget.secondaryColor ?? _neighbor(widget.color, 36),
      third: _neighbor(widget.color, -56),
      borderRadius: widget.borderRadius,
      circle: widget.shape == BoxShape.circle,
      spread: widget.spread,
      intensity: widget.intensity,
      loop: _loop,
      hover: _hover,
      press: _press,
      pointer: _pointer,
    );
    final hasFront = switch (style) {
      FxGlowStyle.aurora ||
      FxGlowStyle.neon ||
      FxGlowStyle.orbit ||
      FxGlowStyle.hover => true,
      FxGlowStyle.pulse || FxGlowStyle.beacon => false,
    };
    Widget glow = CustomPaint(
      painter: painter(front: false),
      foregroundPainter: hasFront ? painter(front: true) : null,
      // The glow repaints every frame; the child does not.
      child: RepaintBoundary(child: widget.child),
    );
    if (style == FxGlowStyle.hover) {
      glow = MouseRegion(
        opaque: false,
        onEnter: (event) {
          _pointer.value = event.localPosition;
          _to(_hover, 1);
        },
        onHover: (event) => _pointer.value = event.localPosition,
        onExit: (_) => _to(_hover, 0),
        child: Listener(
          onPointerDown: (event) {
            _pointer.value = event.localPosition;
            _to(_press, 1);
          },
          onPointerMove: (event) => _pointer.value = event.localPosition,
          onPointerUp: (_) => _to(_press, 0),
          onPointerCancel: (_) => _to(_press, 0),
          child: glow,
        ),
      );
    }
    return RepaintBoundary(child: glow);
  }
}

/// [color] turned [degrees] round the color wheel, or a lighter or darker
/// shade of it when it is nearly gray.
Color _neighbor(Color color, double degrees) {
  final hsl = HSLColor.fromColor(color);
  if (hsl.saturation < 0.15) {
    final l = hsl.lightness;
    return hsl.withLightness(l > 0.5 ? l - 0.2 : l + 0.22).toColor();
  }
  return hsl.withHue((hsl.hue + degrees + 360) % 360).toColor();
}

const Color _white = Color(0xFFFFFFFF);

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.front,
    required this.style,
    required this.color,
    required this.secondary,
    required this.third,
    required this.borderRadius,
    required this.circle,
    required this.spread,
    required this.intensity,
    required this.loop,
    required this.hover,
    required this.press,
    required this.pointer,
  }) : super(repaint: Listenable.merge([loop, hover, press, pointer]));

  /// Whether this paints over the child (the lights on the border) rather
  /// than behind it (the halo).
  final bool front;
  final FxGlowStyle style;
  final Color color;
  final Color secondary;
  final Color third;
  final double borderRadius;
  final bool circle;
  final double spread;
  final double intensity;
  final Animation<double> loop;
  final Animation<double> hover;
  final Animation<double> press;
  final ValueListenable<Offset?> pointer;

  /// [tone] at [opacity] of its own alpha, scaled by [intensity].
  Color _tone(Color tone, double opacity) =>
      tone.withValues(alpha: (tone.a * opacity * intensity).clamp(0.0, 1.0));

  static Paint _blur(double sigma) => Paint()
    ..maskFilter = sigma > 0 ? MaskFilter.blur(BlurStyle.normal, sigma) : null;

  static Paint _line(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final box = Offset.zero & size;
    final shape = circle
        ? RRect.fromRectAndRadius(
            Rect.fromCircle(center: box.center, radius: box.shortestSide / 2),
            Radius.circular(box.shortestSide / 2),
          )
        : RRect.fromRectAndRadius(
            box,
            Radius.circular(math.min(borderRadius, box.shortestSide / 2)),
          );
    switch (style) {
      case FxGlowStyle.pulse:
        _pulse(canvas, shape);
      case FxGlowStyle.aurora:
        _aurora(canvas, shape);
      case FxGlowStyle.beacon:
        _beacon(canvas, shape);
      case FxGlowStyle.neon:
        _neon(canvas, shape);
      case FxGlowStyle.orbit:
        _orbit(canvas, shape);
      case FxGlowStyle.hover:
        _hoverGlow(canvas, shape);
    }
  }

  void _pulse(Canvas canvas, RRect shape) {
    final s = spread;
    final breath = 0.5 - 0.5 * math.cos(2 * math.pi * loop.value);
    Shader tones(Rect rect, double opacity) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_tone(color, opacity), _tone(secondary, opacity)],
    ).createShader(rect);
    // A wide halo that swells and a tight one that brightens with it.
    final wide = shape.inflate(s * (0.15 + 0.3 * breath));
    final core = shape.inflate(s * 0.05);
    canvas
      ..drawRRect(
        wide,
        _blur(s * (0.42 + 0.22 * breath))
          ..shader = tones(wide.outerRect, 0.45 + 0.45 * breath),
      )
      ..drawRRect(
        core,
        _blur(s * 0.16)..shader = tones(core.outerRect, 0.3 + 0.4 * breath),
      );
  }

  void _aurora(Canvas canvas, RRect shape) {
    final s = spread;
    final turn = 2 * math.pi * loop.value;
    final rect = shape.outerRect;
    final shimmer = 0.88 + 0.12 * math.sin(4 * math.pi * loop.value);
    Shader spectrum(double opacity, double rotation) => SweepGradient(
      colors: [
        _tone(color, opacity),
        _tone(secondary, opacity),
        _tone(third, opacity),
        _tone(color, opacity),
      ],
      transform: GradientRotation(rotation),
    ).createShader(rect);
    if (front) {
      // A thin light along the border, in the same turning colors.
      canvas.drawRRect(
        shape.deflate(0.75),
        _line(1.5)..shader = spectrum(0.95, turn),
      );
      return;
    }
    // Two layers turning at different speeds and ways keep it organic.
    canvas
      ..drawRRect(
        shape.inflate(s * 0.3),
        _blur(s * 0.6)..shader = spectrum(0.78 * shimmer, turn),
      )
      ..drawRRect(
        shape.inflate(s * 0.08),
        _blur(s * 0.25)..shader = spectrum(0.48, math.pi - 0.6 * turn),
      );
  }

  void _beacon(Canvas canvas, RRect shape) {
    final s = spread;
    const rings = 3;
    // The halo flashes as each ring leaves.
    var flash = 0.0;
    for (var k = 0; k < rings; k++) {
      final p = (loop.value + k / rings) % 1;
      flash = math.max(flash, math.pow(1 - p, 8).toDouble());
    }
    canvas.drawRRect(
      shape.inflate(s * 0.08),
      _blur(s * 0.3)..color = _tone(color, 0.32 + 0.3 * flash),
    );
    for (var k = 0; k < rings; k++) {
      final p = (loop.value + k / rings) % 1;
      final reach = Curves.easeOutCubic.transform(p);
      canvas.drawRRect(
        shape.inflate(s * (0.08 + 1.4 * reach)),
        _line(lerpDouble(3.6, 1, p)!)
          ..color = _tone(
            Color.lerp(color, secondary, p)!,
            math.pow(1 - p, 1.5).toDouble(),
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + 2.5 * p),
      );
    }
  }

  /// The neon tube's brightness at [t]: a faint hum with a few quick dips.
  static double _flicker(double t) {
    const dips = [
      (0.08, 0.095, 0.25),
      (0.11, 0.125, 0.6),
      (0.14, 0.152, 0.15),
      (0.63, 0.645, 0.5),
    ];
    for (final (from, to, level) in dips) {
      if (t >= from && t < to) return level;
    }
    return 0.93 + 0.07 * math.sin(2 * math.pi * 11 * t);
  }

  void _neon(Canvas canvas, RRect shape) {
    final s = spread;
    final on = _flicker(loop.value);
    if (front) {
      // The tube: a colored glow, the glass and a white-hot core.
      canvas
        ..drawRRect(
          shape,
          _line(5)
            ..color = _tone(color, 0.7 * on)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        )
        ..drawRRect(shape, _line(2.4)..color = _tone(color, 0.6 + 0.4 * on))
        ..drawRRect(
          shape,
          _line(1)..color = _tone(Color.lerp(color, _white, 0.7)!, on),
        );
      return;
    }
    canvas
      ..drawRRect(
        shape.inflate(s * 0.05),
        _blur(s * 0.5)..color = _tone(secondary, 0.16 * on),
      )
      ..drawRRect(
        shape,
        _line(s * 0.8)
          ..color = _tone(color, 0.5 * on)
          ..maskFilter = s > 0
              ? MaskFilter.blur(BlurStyle.normal, s * 0.45)
              : null,
      );
  }

  /// Strokes [from]–[to] along [metric], wrapping round the closed border.
  static void _span(
    Canvas canvas,
    PathMetric metric,
    double from,
    double to,
    Paint paint,
  ) {
    final length = metric.length;
    if (to - from <= 0.01) return;
    final start = from % length;
    final end = start + (to - from);
    canvas.drawPath(metric.extractPath(start, math.min(end, length)), paint);
    if (end > length) {
      canvas.drawPath(metric.extractPath(0, end - length), paint);
    }
  }

  void _orbit(Canvas canvas, RRect shape) {
    final s = spread;
    final metric = (Path()..addRRect(shape)).computeMetrics().first;
    final length = metric.length;
    if (!front) {
      canvas.drawRRect(
        shape.inflate(s * 0.06),
        _blur(s * 0.35)
          ..color = _tone(Color.lerp(color, secondary, 0.5)!, 0.22),
      );
    }
    const pieces = 12;
    const tail = 0.3;
    for (var k = 0; k < 2; k++) {
      final tone = k == 0 ? color : secondary;
      final head = ((loop.value + k / 2) % 1) * length;
      // A trail that fades out behind the light.
      for (var i = 0; i < pieces; i++) {
        final fade = (i + 1) / pieces;
        _span(
          canvas,
          metric,
          head - length * tail * (1 - i / pieces),
          head - length * tail * (1 - (i + 1) / pieces),
          front
              ? (_line(2.4)
                  ..color = _tone(
                    Color.lerp(tone, _white, 0.2)!,
                    math.pow(fade, 1.5).toDouble(),
                  ))
              : (_line(s * 0.6)
                  ..color = _tone(tone, 0.6 * fade * fade)
                  ..maskFilter = s > 0
                      ? MaskFilter.blur(BlurStyle.normal, s * 0.35)
                      : null),
        );
      }
      final at = metric.getTangentForOffset(head % length)!.position;
      if (front) {
        canvas
          ..drawCircle(at, 5, _blur(3)..color = _tone(tone, 0.8))
          ..drawCircle(
            at,
            2.2,
            Paint()..color = _tone(Color.lerp(tone, _white, 0.6)!, 1),
          );
      } else {
        canvas.drawCircle(
          at,
          s * 0.8,
          _blur(s * 0.5)..color = _tone(tone, 0.7),
        );
      }
    }
  }

  void _hoverGlow(Canvas canvas, RRect shape) {
    final s = spread;
    final h = hover.value;
    final down = press.value;
    final lit = math.max(h, down);
    final rect = shape.outerRect;
    final at = pointer.value ?? rect.center;
    if (front) {
      if (lit <= 0.001) return;
      // The border lights up nearest the pointer.
      canvas.drawRRect(
        shape.deflate(0.75),
        _line(1.5)
          ..shader = ui.Gradient.radial(
            at,
            rect.longestSide * 0.55,
            [
              _tone(Color.lerp(color, _white, 0.45)!, 0.95 * lit),
              _tone(color, 0.5 * lit),
              _tone(color, 0),
            ],
            const [0, 0.4, 1],
          ),
      );
      return;
    }
    canvas.drawRRect(
      shape.inflate(s * 0.05),
      _blur(s * 0.35)..color = _tone(color, 0.14 + 0.1 * h),
    );
    if (lit <= 0.001) return;
    final halo = shape.inflate(s * (0.1 + 0.18 * h + 0.14 * down));
    canvas.drawRRect(
      halo,
      _blur(s * 0.5)
        ..shader = ui.Gradient.radial(
          at,
          halo.outerRect.longestSide * 0.75,
          [
            _tone(color, 0.6 * h + 0.3 * down),
            _tone(secondary, 0.3 * h + 0.2 * down),
            _tone(secondary, 0.1 * lit),
          ],
          const [0, 0.55, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.front != front ||
      old.style != style ||
      old.color != color ||
      old.secondary != secondary ||
      old.third != third ||
      old.borderRadius != borderRadius ||
      old.circle != circle ||
      old.spread != spread ||
      old.intensity != intensity ||
      old.loop != loop ||
      old.hover != hover ||
      old.press != press ||
      old.pointer != pointer;
}
