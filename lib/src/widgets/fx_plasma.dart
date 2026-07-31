import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A retro **plasma field** — overlapping sine waves ripple through a color
/// palette to create a turbulent, lava-lamp-like wash. More energetic and
/// swirly than `FxMeshGradient`. Fills its box; pass a [child] to overlay.
///
/// Rendered on a fixed low-resolution cell grid (see [resolution]) so cost is
/// bounded regardless of size. Honors "reduce motion" (settles static) and
/// repaints in isolation.
///
/// ```dart
/// FxPlasma(colors: const [Color(0xFF0B0033), Color(0xFFFF2E63), Color(0xFF08D9D6)]);
/// ```
class FxPlasma extends StatefulWidget {
  const FxPlasma({
    super.key,
    this.colors = const [
      Color(0xFF2B0B98),
      Color(0xFFFF2E63),
      Color(0xFFF9ED69),
      Color(0xFF08D9D6),
    ],
    this.duration = const Duration(seconds: 6),
    this.resolution = 28,
    this.child,
  });

  /// Palette the plasma cycles through (two or more).
  final List<Color> colors;

  /// Time for one full cycle.
  final Duration duration;

  /// Number of cells per axis. Higher = finer detail but more cost.
  final int resolution;

  /// Optional content painted on top.
  final Widget? child;

  @override
  State<FxPlasma> createState() => _FxPlasmaState();
}

class _FxPlasmaState extends State<FxPlasma>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxPlasma oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PlasmaPainter(
          animation: _controller,
          colors: widget.colors,
          resolution: widget.resolution.clamp(4, 96),
        ),
        child: widget.child,
      ),
    );
  }
}

class _PlasmaPainter extends CustomPainter {
  _PlasmaPainter({
    required this.animation,
    required this.colors,
    required this.resolution,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;
  final int resolution;

  final Paint _paint = Paint();

  double _plasma(double u, double v, double time) {
    final a = math.sin(u * 3 + time);
    final b = math.sin(v * 4 - time * 0.8);
    final c = math.sin((u + v) * 2.5 + time * 0.6);
    final dx = u - 0.5, dy = v - 0.5;
    final d = math.sin(math.sqrt(dx * dx + dy * dy) * 8 - time);
    return (a + b + c + d) / 8 + 0.5; // → 0..1
  }

  Color _palette(double x) {
    if (colors.length == 1) return colors.first;
    final scaled = x.clamp(0.0, 1.0) * (colors.length - 1);
    final i = scaled.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[i], colors[i + 1], scaled - i)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final time = animation.value * 2 * math.pi;
    final cw = size.width / resolution;
    final ch = size.height / resolution;
    // Overlap cells by half a pixel to avoid hairline seams.
    for (var j = 0; j < resolution; j++) {
      for (var i = 0; i < resolution; i++) {
        final u = (i + 0.5) / resolution;
        final v = (j + 0.5) / resolution;
        _paint.color = _palette(_plasma(u, v, time));
        canvas.drawRect(
          Rect.fromLTWH(i * cw, j * ch, cw + 0.5, ch + 0.5),
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PlasmaPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.resolution != resolution;
}
