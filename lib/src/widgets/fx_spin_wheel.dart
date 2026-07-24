import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Spin an [FxSpinWheel] programmatically.
class FxSpinWheelController {
  VoidCallback? _spin;

  void _attach(VoidCallback spin) => _spin = spin;

  /// Spin the wheel; it decelerates and lands on a random segment.
  void spin() => _spin?.call();
}

/// A fortune / prize wheel that spins with deceleration and reports the segment
/// under the top pointer via [onResult].
///
/// ```dart
/// final wheel = FxSpinWheelController();
/// FxSpinWheel(items: prizes, colors: palette, controller: wheel,
///   onResult: (i) => print('Won ${prizes[i]}'));
/// // wheel.spin();
/// ```
class FxSpinWheel extends StatefulWidget {
  const FxSpinWheel({
    super.key,
    required this.items,
    required this.colors,
    this.size = 220,
    this.controller,
    this.onResult,
    this.textStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.bold,
    ),
    this.duration = const Duration(milliseconds: 3600),
  });

  final List<String> items;
  final List<Color> colors;
  final double size;
  final FxSpinWheelController? controller;
  final ValueChanged<int>? onResult;
  final TextStyle textStyle;
  final Duration duration;

  @override
  State<FxSpinWheel> createState() => _FxSpinWheelState();
}

class _FxSpinWheelState extends State<FxSpinWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _random = math.Random();
  double _from = 0;
  double _to = 0;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    widget.controller?._attach(_spin);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotation = _to;
        widget.onResult?.call(_indexAtTop(_rotation));
      }
    });
  }

  void _spin() {
    if (_controller.isAnimating) return;
    final turns = 5 + _random.nextDouble() * 3;
    _from = _rotation;
    _to = _rotation + turns * 2 * math.pi;
    _controller.forward(from: 0);
  }

  int _indexAtTop(double rotation) {
    final n = widget.items.length;
    final seg = 2 * math.pi / n;
    var i = ((-rotation / seg) - 0.5).round() % n;
    if (i < 0) i += n;
    return i;
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
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_controller.value);
            final rotation = _from + (_to - _from) * t;
            if (_controller.isAnimating) _rotation = rotation;
            return CustomPaint(
              painter: _WheelPainter(
                items: widget.items,
                colors: widget.colors,
                rotation: rotation,
                textStyle: widget.textStyle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.items,
    required this.colors,
    required this.rotation,
    required this.textStyle,
  });

  final List<String> items;
  final List<Color> colors;
  final double rotation;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final n = items.length;
    if (n == 0) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final seg = 2 * math.pi / n;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (var i = 0; i < n; i++) {
      final start = -math.pi / 2 + i * seg + rotation;
      canvas.drawArc(
        rect,
        start,
        seg,
        true,
        Paint()..color = colors[i % colors.length],
      );

      final painter = TextPainter(
        text: TextSpan(text: items[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final mid = start + seg / 2;
      final pos =
          center + Offset(math.cos(mid), math.sin(mid)) * (radius * 0.62);
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(mid);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }

    // Top pointer.
    final path = Path()
      ..moveTo(center.dx - 10, 0)
      ..lineTo(center.dx + 10, 0)
      ..lineTo(center.dx, 18)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF222222));
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.items != items;
}
