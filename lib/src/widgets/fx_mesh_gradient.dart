import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A soft, living **mesh gradient** background: several colored light sources
/// drift around the surface and blend into a smooth, ever-shifting wash.
///
/// Unlike `FxAurora` (blurred blobs), the colors here bleed edge-to-edge with
/// no visible shapes, giving the modern "mesh gradient" look. Place it behind
/// content (optionally pass a [child] to overlay) and it fills its box.
///
/// Honors the platform "reduce motion" setting (it settles to a static blend)
/// and pauses when scrolled out of view.
///
/// ```dart
/// FxMeshGradient(
///   colors: const [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFFEC008C)],
///   child: const Center(child: Text('Hello')),
/// );
/// ```
class FxMeshGradient extends StatefulWidget {
  const FxMeshGradient({
    super.key,
    this.colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFEC008C),
      Color(0xFF00C9A7),
    ],
    this.duration = const Duration(seconds: 8),
    this.blend = 0.85,
    this.child,
  });

  /// The light-source colors that drift and blend. Two or more looks best.
  final List<Color> colors;

  /// Time for one full drift cycle.
  final Duration duration;

  /// How far each source reaches, as a fraction of the longest side
  /// (higher = softer, more overlap). Clamped to `0.2..1.5`.
  final double blend;

  /// Optional content painted on top of the gradient.
  final Widget? child;

  @override
  State<FxMeshGradient> createState() => _FxMeshGradientState();
}

class _FxMeshGradientState extends State<FxMeshGradient>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only reports reduce-motion *flips*, so start the first
    // loop here once the flag is known.
    if (!_kicked) {
      _kicked = true;
      if (!reduceMotion) _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FxMeshGradient oldWidget) {
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
        painter: _MeshPainter(
          animation: _controller,
          colors: widget.colors,
          blend: widget.blend.clamp(0.2, 1.5),
        ),
        child: widget.child,
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({
    required this.animation,
    required this.colors,
    required this.blend,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;
  final double blend;

  // One reusable Paint per source; only its shader is reassigned per frame.
  final List<Paint> _paints = <Paint>[];

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final rect = Offset.zero & size;
    final reach = size.longestSide * blend;
    final t = animation.value * 2 * math.pi;

    // Base wash so gaps never show through.
    canvas.drawRect(rect, Paint()..color = colors.first);

    for (var i = 0; i < colors.length; i++) {
      // Each source traces its own Lissajous path across the surface.
      final phase = i * (2 * math.pi / colors.length);
      final cx = 0.5 + 0.42 * math.cos(t + phase);
      final cy = 0.5 + 0.42 * math.sin(t * 1.3 + phase * 1.7);
      final center = Offset(cx * size.width, cy * size.height);

      if (_paints.length <= i) _paints.add(Paint());
      _paints[i].shader = RadialGradient(
        colors: [colors[i], colors[i].withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: reach));
      canvas.drawRect(rect, _paints[i]);
    }
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.blend != blend;
}
