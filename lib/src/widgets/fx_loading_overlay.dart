import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A full-surface loading overlay: when [visible] it blurs and dims whatever is
/// behind it and shows a centered spinner (with an optional [message]); when
/// hidden it fades out and ignores pointers. Place it as the top child of a
/// `Stack`.
///
/// Honors the platform "reduce motion" setting, at mount and when it is
/// toggled at runtime: the spinner holds still while it is on.
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
                  _Spinner(color: spinnerColor, active: visible),
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
  const _Spinner({required this.color, required this.active});

  final Color color;

  /// Whether the overlay is shown. When false the spinner stops rotating so it
  /// doesn't burn a frame callback (and force the backdrop blur to recomposite)
  /// while hidden behind a faded-out, ignored overlay.
  final bool active;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only reports reduce-motion *flips*, so start the first spin
    // here once the flag is known.
    if (!_kicked) {
      _kicked = true;
      _sync();
    }
  }

  // Toggling the OS setting at runtime stops/resumes the spin immediately.
  @override
  void onReduceMotionChanged(bool reduceMotion) => _sync();

  @override
  void didUpdateWidget(covariant _Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) _sync();
  }

  // Spin only while shown and motion is allowed; under reduced motion the arc
  // holds still (the dimmed backdrop and message still signal "busy").
  void _sync() {
    if (widget.active && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Isolate the spinning arc so its per-frame repaint does not invalidate the
    // expensive BackdropFilter blur sitting in the same layer.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: const Size(42, 42),
            painter: _ArcPainter(widget.color),
          ),
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
