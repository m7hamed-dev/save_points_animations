import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Bubbles that rise and gently wobble over [child] — an airy, playful backdrop.
///
/// ```dart
/// FxBubbles(child: const Card(child: SizedBox(height: 160)));
/// ```
class FxBubbles extends StatefulWidget {
  const FxBubbles({
    super.key,
    this.count = 22,
    this.color = const Color(0x33FFFFFF),
    this.maxRadius = 14,
    this.speed = 0.14,
    this.child,
  });

  final int count;
  final Color color;
  final double maxRadius;

  /// Rise speed in fractions of the height per second.
  final double speed;
  final Widget? child;

  @override
  State<FxBubbles> createState() => _FxBubblesState();
}

class _FxBubblesState extends State<FxBubbles>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  late final Ticker _ticker = createTicker(_tick);
  late List<_Bubble> _bubbles;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(widget.count, (_) => _spawn(_random.nextDouble()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
        _ticker.start();
      }
    });
  }

  _Bubble _spawn(double y) => _Bubble(
    x: _random.nextDouble(),
    y: y,
    rise: widget.speed * (0.6 + _random.nextDouble() * 0.8),
    wobble: _random.nextDouble() * 2 * math.pi,
    radius: 3 + _random.nextDouble() * widget.maxRadius,
  );

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    setState(() {
      for (final b in _bubbles) {
        b
          ..y -= b.rise * dt
          ..wobble += dt;
        if (b.y < -0.1) {
          b
            ..y = 1.1
            ..x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BubblePainter(_bubbles, widget.color),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.y,
    required this.rise,
    required this.wobble,
    required this.radius,
  });
  double x;
  double y;
  double wobble;
  final double rise;
  final double radius;
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.bubbles, this.color);

  final List<_Bubble> bubbles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color.withValues(alpha: color.a * 1.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final b in bubbles) {
      final cx = (b.x + math.sin(b.wobble) * 0.03) * size.width;
      final cy = b.y * size.height;
      canvas
        ..drawCircle(Offset(cx, cy), b.radius, fill)
        ..drawCircle(Offset(cx, cy), b.radius, stroke);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => true;
}
