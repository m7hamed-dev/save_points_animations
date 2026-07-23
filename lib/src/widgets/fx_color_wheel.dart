import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A circular HSV color picker. Drag anywhere on the wheel to pick a hue
/// (angle) and saturation (distance from center); the selector ring animates
/// to the touch point. Value/brightness is fixed at [value].
///
/// ```dart
/// FxColorWheel(color: c, onChanged: (v) => setState(() => c = v));
/// ```
class FxColorWheel extends StatelessWidget {
  const FxColorWheel({
    super.key,
    required this.color,
    required this.onChanged,
    this.size = 220,
    this.value = 1,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final double size;
  final double value;

  _Hsv get _hsv => _Hsv.fromColor(color);

  void _emit(Offset local) {
    final radius = size / 2;
    final dx = local.dx - radius;
    final dy = local.dy - radius;
    final dist = math.sqrt(dx * dx + dy * dy);
    var hue = math.atan2(dy, dx) * 180 / math.pi;
    if (hue < 0) hue += 360;
    final sat = (dist / radius).clamp(0.0, 1.0);
    onChanged(_Hsv(hue, sat, value).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final hsv = _hsv;
    final radius = size / 2;
    final angle = hsv.h * math.pi / 180;
    final selDist = hsv.s * radius;
    return GestureDetector(
      onPanDown: (d) => _emit(d.localPosition),
      onPanUpdate: (d) => _emit(d.localPosition),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _WheelPainter(value),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                left: radius + math.cos(angle) * selDist - 12,
                top: radius + math.sin(angle) * selDist - 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFFFF),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x44000000), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    // Hue sweep.
    const steps = 360;
    for (var i = 0; i < steps; i++) {
      final start = i * math.pi / 180;
      final sweep = (2 * math.pi / steps) + 0.02;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _Hsv(i.toDouble(), 1, value).toColor();
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arc(center, radius, start, sweep)
        ..close();
      canvas.drawPath(path, paint);
    }
    // Saturation fade toward white at the center.
    final radial = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromARGB((255 * value).round(), 255, 255, 255),
          const Color(0x00FFFFFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, radial);
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => oldDelegate.value != value;
}

extension _ArcPath on Path {
  void arc(Offset center, double radius, double startAngle, double sweep) {
    arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
    );
  }
}

/// Minimal HSV helper so the widget stays Material-free.
class _Hsv {
  const _Hsv(this.h, this.s, this.v);

  factory _Hsv.fromColor(Color c) {
    final r = c.r;
    final g = c.g;
    final b = c.b;
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;
    double h = 0;
    if (delta != 0) {
      if (max == r) {
        h = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        h = 60 * (((b - r) / delta) + 2);
      } else {
        h = 60 * (((r - g) / delta) + 4);
      }
    }
    if (h < 0) h += 360;
    final s = max == 0 ? 0.0 : delta / max;
    return _Hsv(h, s, max);
  }

  final double h;
  final double s;
  final double v;

  Color toColor() {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;
    double r = 0;
    double g = 0;
    double b = 0;
    if (h < 60) {
      r = c;
      g = x;
    } else if (h < 120) {
      r = x;
      g = c;
    } else if (h < 180) {
      g = c;
      b = x;
    } else if (h < 240) {
      g = x;
      b = c;
    } else if (h < 300) {
      r = x;
      b = c;
    } else {
      r = c;
      b = x;
    }
    return Color.fromARGB(
      255,
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    );
  }
}
