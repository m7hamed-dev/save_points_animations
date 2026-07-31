import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Fast falling **rain streaks** over [child], with a configurable slant. Unlike
/// `FxSnow` (slow, swaying flakes), drops here are thin lines that fall quickly
/// at an angle.
///
/// Honors "reduce motion" (the rain freezes), pauses off-screen, and repaints
/// in isolation. Pass a [seed] for a reproducible layout.
///
/// ```dart
/// FxRain(child: const ColoredBox(color: Color(0xFF10131A)));
/// ```
class FxRain extends StatefulWidget {
  const FxRain({
    super.key,
    this.count = 90,
    this.color = const Color(0x99AECBFF),
    this.speed = 1.1,
    this.slant = 0.18,
    this.thickness = 1.4,
    this.seed,
    this.child,
  });

  /// Number of drops.
  final int count;
  final Color color;

  /// Fall speed in fractions of the height per second.
  final double speed;

  /// Horizontal drift per unit fall (0 = straight down, higher = more slanted).
  final double slant;

  /// Stroke width of each streak.
  final double thickness;

  /// Optional seed for a reproducible layout (null = random each time).
  final int? seed;
  final Widget? child;

  @override
  State<FxRain> createState() => _FxRainState();
}

class _FxRainState extends State<FxRain>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final math.Random _random = math.Random(widget.seed);
  late final Ticker _ticker;
  late List<_Drop> _drops;
  Duration _last = Duration.zero;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _drops = List.generate(widget.count, (_) => _spawn(_random.nextDouble()));
    _ticker.start();
  }

  _Drop _spawn(double y) => _Drop(
    x: _random.nextDouble(),
    y: y,
    fall: widget.speed * (0.7 + _random.nextDouble() * 0.6),
    length: 0.05 + _random.nextDouble() * 0.08,
  );

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _ticker.stop();
    } else if (!_ticker.isTicking) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    for (final d in _drops) {
      d.y += d.fall * dt;
      d.x += d.fall * widget.slant * dt;
      if (d.y > 1) {
        d
          ..y = -d.length
          ..x = _random.nextDouble();
      }
    }
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
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
                painter: _RainPainter(
                  _drops,
                  widget.color,
                  widget.slant,
                  widget.thickness,
                  repaint: _frame,
                ),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Drop {
  _Drop({
    required this.x,
    required this.y,
    required this.fall,
    required this.length,
  });

  double x;
  double y;
  final double fall;
  final double length;
}

class _RainPainter extends CustomPainter {
  _RainPainter(
    this.drops,
    this.color,
    this.slant,
    this.thickness, {
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Drop> drops;
  final Color color;
  final double slant;
  final double thickness;

  late final Paint _paint = Paint()
    ..color = color
    ..strokeWidth = thickness
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in drops) {
      final x = d.x * size.width;
      final y = d.y * size.height;
      final dx = slant * d.length * size.height;
      final dy = d.length * size.height;
      canvas.drawLine(Offset(x, y), Offset(x - dx, y - dy), _paint);
    }
  }

  @override
  bool shouldRepaint(_RainPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.drops != drops ||
      oldDelegate.thickness != thickness;
}
