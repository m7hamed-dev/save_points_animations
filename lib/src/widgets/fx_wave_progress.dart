import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A liquid "water fill" progress indicator — an animated wave rises to [value]
/// inside a circle or rounded box.
///
/// ```dart
/// FxWaveProgress(value: 0.65, child: const Text('65%'));
/// ```
class FxWaveProgress extends StatefulWidget {
  const FxWaveProgress({
    super.key,
    this.value = 0.5,
    this.size = 110,
    this.color = const Color(0xFF2575FC),
    this.backgroundColor = const Color(0x222575FC),
    this.shape = BoxShape.circle,
    this.waveHeight = 7,
    this.duration = const Duration(milliseconds: 1600),
    this.borderRadius = 16,
    this.child,
  });

  /// Fill level in `0..1`.
  final double value;
  final double size;
  final Color color;
  final Color backgroundColor;
  final BoxShape shape;
  final double waveHeight;
  final Duration duration;
  final double borderRadius;

  /// Optional overlay (e.g. a percentage label), centered.
  final Widget? child;

  @override
  State<FxWaveProgress> createState() => _FxWaveProgressState();
}

class _FxWaveProgressState extends State<FxWaveProgress>
    with SingleTickerProviderStateMixin {
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
    final box = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: widget.backgroundColor),
          CustomPaint(
            painter: _WavePainter(
              repaint: _controller,
              value: widget.value.clamp(0.0, 1.0),
              controller: _controller,
              color: widget.color,
              waveHeight: widget.waveHeight,
            ),
          ),
          if (widget.child != null) Center(child: widget.child),
        ],
      ),
    );

    return RepaintBoundary(
      child: widget.shape == BoxShape.circle
          ? ClipOval(child: box)
          : ClipRRect(borderRadius: .circular(widget.borderRadius), child: box),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required Listenable repaint,
    required this.value,
    required this.controller,
    required this.color,
    required this.waveHeight,
  }) : super(repaint: repaint);

  final double value;
  final Animation<double> controller;
  final Color color;
  final double waveHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = controller.value * 2 * math.pi;
    final level = (1 - value) * size.height;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, level);
    for (var x = 0.0; x <= size.width; x += 2) {
      final y =
          level + math.sin(x / size.width * 2 * math.pi + phase) * waveHeight;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.waveHeight != waveHeight;
}
