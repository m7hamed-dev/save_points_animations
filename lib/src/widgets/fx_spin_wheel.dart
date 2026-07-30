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

  /// Segment labels laid out once (not per frame) — see [_buildLabels].
  List<TextPainter> _labels = const <TextPainter>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    widget.controller?._attach(_spin);
    _buildLabels();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotation = _to;
        final i = _indexAtTop(_rotation);
        if (i >= 0) widget.onResult?.call(i);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FxSpinWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      widget.controller?._attach(_spin);
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (!_sameLabels(oldWidget)) _buildLabels();
  }

  bool _sameLabels(FxSpinWheel old) =>
      widget.textStyle == old.textStyle &&
      old.items.length == widget.items.length &&
      List.generate(
        widget.items.length,
        (i) => widget.items[i] == old.items[i],
      ).every((e) => e);

  /// Lay out each segment label a single time. `TextPainter.layout()` is
  /// expensive; doing it per glyph on every frame (as before) was the wheel's
  /// dominant cost while spinning.
  void _buildLabels() {
    for (final p in _labels) {
      p.dispose();
    }
    _labels = [
      for (final item in widget.items)
        TextPainter(
          text: TextSpan(text: item, style: widget.textStyle),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
  }

  void _spin() {
    if (_controller.isAnimating || widget.items.isEmpty) return;
    final turns = 5 + _random.nextDouble() * 3;
    _from = _rotation;
    _to = _rotation + turns * 2 * math.pi;
    _controller.forward(from: 0);
  }

  int _indexAtTop(double rotation) {
    final n = widget.items.length;
    if (n == 0) return -1;
    final seg = 2 * math.pi / n;
    var i = ((-rotation / seg) - 0.5).round() % n;
    if (i < 0) i += n;
    return i;
  }

  @override
  void dispose() {
    for (final p in _labels) {
      p.dispose();
    }
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
                labels: _labels,
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
    required this.labels,
  });

  final List<String> items;
  final List<Color> colors;
  final double rotation;

  /// Pre-laid-out segment labels, one per item (see [_FxSpinWheelState]).
  final List<TextPainter> labels;

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

      final painter = labels[i];
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
      oldDelegate.rotation != rotation ||
      !identical(oldDelegate.labels, labels);
}
