import 'package:flutter/widgets.dart';

/// A looping "sonar" pulse of expanding, fading rings behind [child] — a
/// live/attention indicator (call button, unread dot, recording light, …).
///
/// ```dart
/// FxPulse(color: Colors.red, child: const Icon(Icons.circle, size: 12));
/// ```
class FxPulse extends StatefulWidget {
  const FxPulse({
    super.key,
    required this.child,
    this.color = const Color(0xFF448AFF),
    this.maxRadius = 18,
    this.rings = 2,
    this.duration = const Duration(milliseconds: 1600),
  });

  final Widget child;
  final Color color;

  /// How far beyond the child the rings expand, in logical pixels.
  final double maxRadius;
  final int rings;
  final Duration duration;

  @override
  State<FxPulse> createState() => _FxPulseState();
}

class _FxPulseState extends State<FxPulse> with SingleTickerProviderStateMixin {
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
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PulsePainter(
                  repaint: _controller,
                  color: widget.color,
                  maxRadius: widget.maxRadius,
                  rings: widget.rings,
                  controller: _controller,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required Listenable repaint,
    required this.color,
    required this.maxRadius,
    required this.rings,
    required this.controller,
  }) : super(repaint: repaint);

  final Color color;
  final double maxRadius;
  final int rings;
  final Animation<double> controller;

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller.value;
    final center = size.center(Offset.zero);
    final base = size.shortestSide / 2;
    for (var i = 0; i < rings; i++) {
      final phase = (t + i / rings) % 1.0;
      final radius = base + phase * maxRadius;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - phase) * 0.35);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.maxRadius != maxRadius ||
      oldDelegate.rings != rings;
}
