import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A grid of dots that sends a **ripple wavefront** outward from wherever you
/// tap — each dot briefly swells and brightens as the wave passes through it,
/// then settles. A playful, tactile backdrop or button surface.
///
/// Unlike `FxRipple` (expanding rings) or `FxDotGrid` (a continuous wave), the
/// motion here is discrete dots reacting to a tap-driven front.
///
/// Honors "reduce motion" (a tap does nothing animated) and repaints in
/// isolation.
///
/// ```dart
/// SizedBox(height: 160, child: FxRippleGrid(color: Colors.indigo));
/// ```
class FxRippleGrid extends StatefulWidget {
  const FxRippleGrid({
    super.key,
    this.color = const Color(0xFF448AFF),
    this.spacing = 26,
    this.dotSize = 5,
    this.duration = const Duration(milliseconds: 900),
  });

  /// Dot color (brightens as the wave passes).
  final Color color;

  /// Gap between dot centers.
  final double spacing;

  /// Resting dot diameter.
  final double dotSize;

  /// Time for the wavefront to travel out and fade.
  final Duration duration;

  @override
  State<FxRippleGrid> createState() => _FxRippleGridState();
}

class _FxRippleGridState extends State<FxRippleGrid>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  Offset? _center;
  double _maxRadius = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxRippleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap(Offset local, Size size) {
    _center = local;
    // Reach the far corner so every dot participates.
    _maxRadius = size.bottomRight(Offset.zero).distance;
    if (reduceMotion) {
      _controller.value = 1; // Skip the animation.
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _tap(d.localPosition, size),
            child: CustomPaint(
              size: size,
              painter: _RippleGridPainter(
                animation: _controller,
                center: _center,
                maxRadius: _maxRadius,
                color: widget.color,
                spacing: widget.spacing,
                dotSize: widget.dotSize,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RippleGridPainter extends CustomPainter {
  _RippleGridPainter({
    required this.animation,
    required this.center,
    required this.maxRadius,
    required this.color,
    required this.spacing,
    required this.dotSize,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Offset? center;
  final double maxRadius;
  final Color color;
  final double spacing;
  final double dotSize;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final front = t * maxRadius;
    // Wave energy fades as it expands and the animation completes.
    final energy = center == null ? 0.0 : (1 - t);
    const falloff = 42.0;
    final baseR = dotSize / 2;

    // Center the grid within the box.
    final cols = (size.width / spacing).floor();
    final rows = (size.height / spacing).floor();
    final offsetX = (size.width - (cols - 1) * spacing) / 2;
    final offsetY = (size.height - (rows - 1) * spacing) / 2;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final p = Offset(offsetX + c * spacing, offsetY + r * spacing);
        var influence = 0.0;
        if (center != null && energy > 0) {
          final delta = ((p - center!).distance - front).abs();
          influence = (1 - delta / falloff).clamp(0.0, 1.0) * energy;
        }
        _paint.color = color.withValues(alpha: 0.25 + 0.75 * influence);
        canvas.drawCircle(p, baseR * (1 + 1.4 * influence), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RippleGridPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotSize != dotSize;
}
