import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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

class _FxBlobState extends State<FxBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

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

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    final base = size.shortestSide / 2 * (1 - amplitude);
    final path = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final angle = i / steps * 2 * math.pi;
      final r =
          base *
          (1 +
              amplitude * math.sin(3 * angle + phase) +
              amplitude * 0.6 * math.sin(5 * angle - phase * 1.3));
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(_BlobClipper oldClipper) =>
      oldClipper.phase != phase || oldClipper.amplitude != amplitude;
}
