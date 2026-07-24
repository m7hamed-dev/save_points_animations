import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A "warp speed" starfield — stars stream outward from the center toward the
/// viewer, resetting to depth when they pass.
///
/// ```dart
/// FxStarField(child: const Center(child: Text('Launching…')));
/// ```
class FxStarField extends StatefulWidget {
  const FxStarField({
    super.key,
    this.count = 140,
    this.color = const Color(0xFFFFFFFF),
    this.speed = 0.6,
    this.child,
  });

  final int count;
  final Color color;

  /// Approach speed (depth units per second).
  final double speed;
  final Widget? child;

  @override
  State<FxStarField> createState() => _FxStarFieldState();
}

class _FxStarFieldState extends State<FxStarField>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  late final Ticker _ticker;
  late List<_Star> _stars;
  Duration _last = Duration.zero;

  // Bumped each tick to drive the painter's `repaint:` without rebuilding the
  // widget subtree (the star list is mutated in place).
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _stars = List.generate(widget.count, (_) => _spawn());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
        _ticker.start();
      }
    });
  }

  _Star _spawn() => _Star(
    x: _random.nextDouble() * 2 - 1,
    y: _random.nextDouble() * 2 - 1,
    z: _random.nextDouble() * 0.9 + 0.1,
  );

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    for (final s in _stars) {
      s.z -= widget.speed * dt;
      if (s.z <= 0.05) {
        s
          ..z = 1
          ..x = _random.nextDouble() * 2 - 1
          ..y = _random.nextDouble() * 2 - 1;
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
                painter: _StarPainter(_stars, widget.color, repaint: _frame),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Star {
  _Star({required this.x, required this.y, required this.z});
  double x;
  double y;
  double z;
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.color, {required Listenable repaint})
    : super(repaint: repaint);

  final List<_Star> stars;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final s in stars) {
      final sx = center.dx + (s.x / s.z) * center.dx;
      final sy = center.dy + (s.y / s.z) * center.dy;
      if (sx < 0 || sx > size.width || sy < 0 || sy > size.height) continue;
      final radius = (1 - s.z) * 2.2;
      canvas.drawCircle(
        Offset(sx, sy),
        radius,
        Paint()..color = color.withValues(alpha: (1 - s.z).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stars != stars;
}
