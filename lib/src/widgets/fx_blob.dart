import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// An organic, continuously morphing blob shape — a soft, living container for
/// avatars, icons, or decorative accents.
///
/// ```dart
/// FxBlob(color: Colors.purple, child: const Icon(Icons.star, color: Colors.white));
/// ```
class FxBlob extends StatefulWidget {
  const FxBlob({
    super.key,
    this.size = 120,
    this.color = const Color(0xFF7E57C2),
    this.amplitude = 0.08,
    this.duration = const Duration(seconds: 6),
    this.child,
  });

  final double size;
  final Color color;

  /// How strongly the outline wobbles (fraction of the radius).
  final double amplitude;
  final Duration duration;

  /// Optional content clipped inside the blob.
  final Widget? child;

  @override
  State<FxBlob> createState() => _FxBlobState();
}

class _FxBlobState extends State<FxBlob>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant FxBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      // A running repeat keeps its old period until restarted; a
      // controller stopped for reduced motion stays stopped.
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
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            final clipper = _BlobClipper(
              phase: _controller.value * 2 * math.pi,
              amplitude: widget.amplitude,
            );
            return ClipPath(
              clipper: clipper,
              child: ColoredBox(
                color: widget.color,
                child: child == null ? null : Center(child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  _BlobClipper({required this.phase, required this.amplitude});

  final double phase;
  final double amplitude;

  double _radiusAt(double angle, double base) =>
      base *
      (1 +
          amplitude * math.sin(3 * angle + phase) +
          amplitude * 0.6 * math.sin(5 * angle - phase * 1.3));

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    final base = size.shortestSide / 2 * (1 - amplitude);
    final path = Path();
    // Far fewer sample points than before; quadratic beziers through the
    // midpoints keep the outline smooth. 44 samples is plenty here.
    const steps = 44;
    const twoPi = 2 * math.pi;

    Offset pointAt(double angle) {
      final r = _radiusAt(angle, base);
      return Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
    }

    final first = pointAt(0);
    // Start at the midpoint between the last and first sample so the closing
    // curve joins seamlessly.
    final prev = pointAt(-twoPi / steps);
    final start = Offset((prev.dx + first.dx) / 2, (prev.dy + first.dy) / 2);
    path.moveTo(start.dx, start.dy);
    var current = first;
    for (var i = 1; i <= steps; i++) {
      final next = pointAt(i / steps * twoPi);
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
      current = next;
    }
    return path..close();
  }

  @override
  bool shouldReclip(_BlobClipper oldClipper) =>
      oldClipper.phase != phase || oldClipper.amplitude != amplitude;
}
