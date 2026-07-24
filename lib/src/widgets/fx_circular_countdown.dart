import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A ring that depletes over [duration], with the remaining seconds in the
/// center. Fires [onComplete] at zero.
///
/// ```dart
/// FxCircularCountdown(duration: const Duration(seconds: 10));
/// ```
class FxCircularCountdown extends StatefulWidget {
  const FxCircularCountdown({
    super.key,
    required this.duration,
    this.size = 84,
    this.strokeWidth = 6,
    this.color = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.textStyle,
    this.onComplete,
    this.builder,
  });

  final Duration duration;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;

  /// Custom center content given the remaining time.
  final Widget Function(BuildContext context, Duration remaining)? builder;

  @override
  State<FxCircularCountdown> createState() => _FxCircularCountdownState();
}

class _FxCircularCountdownState extends State<FxCircularCountdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _remaining => Duration(
    milliseconds: (widget.duration.inMilliseconds * (1 - _controller.value))
        .round(),
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final remaining = _remaining;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(
                      fraction: 1 - _controller.value,
                      color: widget.color,
                      backgroundColor: widget.backgroundColor,
                      strokeWidth: widget.strokeWidth,
                    ),
                  ),
                ),
                widget.builder?.call(context, remaining) ??
                    Text('${remaining.inSeconds}', style: widget.textStyle),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);
    canvas.drawArc(
      inset,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    canvas.drawArc(
      inset,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
