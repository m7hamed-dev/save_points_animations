import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A full-surface loading overlay: when [visible] it blurs and dims whatever is
/// behind it and shows a centered spinner (with an optional [message]); when
/// hidden it fades out and ignores pointers. Place it as the top child of a
/// `Stack`.
///
/// ```dart
/// Stack(children: [page, FxLoadingOverlay(visible: busy, message: 'Saving…')]);
/// ```
class FxLoadingOverlay extends StatelessWidget {
  const FxLoadingOverlay({
    super.key,
    required this.visible,
    this.message,
    this.blur = 4,
    this.barrierColor = const Color(0x66000000),
    this.spinnerColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 240),
  });

  final bool visible;
  final String? message;
  final double blur;
  final Color barrierColor;
  final Color spinnerColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              color: barrierColor,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Spinner(color: spinnerColor),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: TextStyle(
                        color: spinnerColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});

  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.rotate(
        angle: _controller.value * 2 * math.pi,
        child: CustomPaint(
          size: const Size(42, 42),
          painter: _ArcPainter(widget.color),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color],
      ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(center: rect.center, radius: size.width / 2 - 2),
      0,
      math.pi * 1.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.color != color;
}
