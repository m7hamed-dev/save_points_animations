import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A rotating **DNA double-helix** loader — two strands of dots wind around
/// each other with occasional connecting rungs, dots swelling as they come
/// "forward" and shrinking as they recede. A fresh alternative to spinner dots.
///
/// Honors "reduce motion" (holds a static helix) and repaints in isolation.
///
/// ```dart
/// FxDnaLoader(colorA: Colors.cyan, colorB: Colors.pink);
/// ```
class FxDnaLoader extends StatefulWidget {
  const FxDnaLoader({
    super.key,
    this.colorA = const Color(0xFF00C9A7),
    this.colorB = const Color(0xFFFF2E63),
    this.dotCount = 10,
    this.dotSize = 6,
    this.size = const Size(120, 40),
    this.duration = const Duration(milliseconds: 1600),
  });

  /// Colors of the two strands.
  final Color colorA;
  final Color colorB;

  /// Number of dot pairs along the helix.
  final int dotCount;

  /// Base dot diameter (scaled by depth).
  final double dotSize;

  /// Overall size of the loader.
  final Size size;

  /// Time for one full rotation.
  final Duration duration;

  @override
  State<FxDnaLoader> createState() => _FxDnaLoaderState();
}

class _FxDnaLoaderState extends State<FxDnaLoader>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxDnaLoader oldWidget) {
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
        size: widget.size,
        painter: _DnaPainter(
          animation: _controller,
          colorA: widget.colorA,
          colorB: widget.colorB,
          dotCount: widget.dotCount,
          dotSize: widget.dotSize,
        ),
      ),
    );
  }
}

class _DnaPainter extends CustomPainter {
  _DnaPainter({
    required this.animation,
    required this.colorA,
    required this.colorB,
    required this.dotCount,
    required this.dotSize,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color colorA;
  final Color colorB;
  final int dotCount;
  final double dotSize;

  final Paint _paintA = Paint();
  final Paint _paintB = Paint();
  final Paint _rung = Paint()..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (dotCount < 1) return;
    final phase = animation.value * 2 * math.pi;
    final amp = size.height / 2 - dotSize;
    final midY = size.height / 2;
    final r = dotSize / 2;

    for (var i = 0; i < dotCount; i++) {
      final x = dotCount == 1
          ? size.width / 2
          : i / (dotCount - 1) * size.width;
      final angle = phase + i * (math.pi / 4);
      final s = math.sin(angle);
      final depth = math.cos(angle); // -1 (back) .. 1 (front)

      final yA = midY + s * amp;
      final yB = midY - s * amp;
      // Dots coming forward are larger and more opaque.
      final scaleA = 0.5 + 0.5 * ((depth + 1) / 2);
      final scaleB = 0.5 + 0.5 * ((-depth + 1) / 2);

      // Rung connecting the strands, dimmer when edge-on.
      _rung.color = const Color(
        0x33FFFFFF,
      ).withValues(alpha: 0.12 + 0.12 * s.abs());
      canvas.drawLine(Offset(x, yA), Offset(x, yB), _rung);

      // Draw the rear dot first for correct overlap.
      if (depth >= 0) {
        _paintB.color = colorB.withValues(alpha: scaleB);
        canvas.drawCircle(Offset(x, yB), r * scaleB, _paintB);
        _paintA.color = colorA.withValues(alpha: scaleA);
        canvas.drawCircle(Offset(x, yA), r * scaleA, _paintA);
      } else {
        _paintA.color = colorA.withValues(alpha: scaleA);
        canvas.drawCircle(Offset(x, yA), r * scaleA, _paintA);
        _paintB.color = colorB.withValues(alpha: scaleB);
        canvas.drawCircle(Offset(x, yB), r * scaleB, _paintB);
      }
    }
  }

  @override
  bool shouldRepaint(_DnaPainter oldDelegate) =>
      oldDelegate.colorA != colorA ||
      oldDelegate.colorB != colorB ||
      oldDelegate.dotCount != dotCount ||
      oldDelegate.dotSize != dotSize;
}
