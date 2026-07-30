import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// Falling, gently swaying particles over [child] — snow, rain, embers, or
/// petals depending on the color.
///
/// ```dart
/// FxSnow(child: const Card(child: SizedBox(height: 160)));
/// ```
class FxSnow extends StatefulWidget {
  const FxSnow({
    super.key,
    this.count = 40,
    this.color = const Color(0xCCFFFFFF),
    this.maxRadius = 3,
    this.speed = 0.08,
    this.seed,
    this.child,
  });

  final int count;
  final Color color;
  final double maxRadius;

  /// Fall speed in fractions of the height per second.
  final double speed;

  /// Optional seed for the random layout, so it's reproducible.
  /// When null (the default) the layout is random each time.
  final int? seed;
  final Widget? child;

  @override
  State<FxSnow> createState() => _FxSnowState();
}

class _FxSnowState extends State<FxSnow>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final math.Random _random = math.Random(widget.seed);
  late final Ticker _ticker;
  late List<_Flake> _flakes;
  Duration _last = Duration.zero;

  // Bumped each tick to drive the painter's `repaint:` without rebuilding the
  // widget subtree (the flake list is mutated in place).
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _flakes = List.generate(widget.count, (_) {
      return _Flake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        fall: widget.speed * (0.6 + _random.nextDouble() * 0.8),
        sway: _random.nextDouble() * 2 * math.pi,
        radius: 1 + _random.nextDouble() * widget.maxRadius,
      );
    });
    _ticker.start();
  }

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
    for (final f in _flakes) {
      f.y += f.fall * dt;
      f.sway += dt;
      if (f.y > 1) {
        f.y = 0;
        f.x = _random.nextDouble();
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
                painter: _SnowPainter(_flakes, widget.color, repaint: _frame),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Flake {
  _Flake({
    required this.x,
    required this.y,
    required this.fall,
    required this.sway,
    required this.radius,
  });

  double x;
  double y;
  double sway;
  final double fall;
  final double radius;
}

class _SnowPainter extends CustomPainter {
  _SnowPainter(this.flakes, this.color, {required Listenable repaint})
    : super(repaint: repaint);

  final List<_Flake> flakes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final f in flakes) {
      final dx = (f.x + math.sin(f.sway) * 0.02) * size.width;
      canvas.drawCircle(Offset(dx, f.y * size.height), f.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.flakes != flakes;
}
