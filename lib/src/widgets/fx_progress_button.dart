import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_animated_check.dart';
import 'package:save_points_animations/src/widgets/fx_loaders.dart';

/// The visual state of an [FxProgressButton].
enum FxButtonState { idle, loading, success, error }

/// A button that morphs into a loading spinner, then a success check (or error
/// cross), driven by [state]. Great for form submits.
///
/// ```dart
/// FxProgressButton(
///   state: _state,
///   onPressed: _submit,
///   child: const Text('Submit'),
/// );
/// ```
class FxProgressButton extends StatelessWidget {
  const FxProgressButton({
    super.key,
    required this.state,
    required this.onPressed,
    required this.child,
    this.color = const Color(0xFF448AFF),
    this.successColor = const Color(0xFF43A047),
    this.errorColor = const Color(0xFFE53935),
    this.height = 48,
    this.borderRadius = 12,
    this.duration = const Duration(milliseconds: 300),
  });

  final FxButtonState state;
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final Color successColor;
  final Color errorColor;
  final double height;
  final double borderRadius;
  final Duration duration;

  Color get _bg => switch (state) {
    FxButtonState.success => successColor,
    FxButtonState.error => errorColor,
    _ => color,
  };

  Widget _content() {
    switch (state) {
      case FxButtonState.idle:
        return DefaultTextStyle.merge(
          key: const ValueKey('idle'),
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
          child: child,
        );
      case FxButtonState.loading:
        return FxProgressRing(
          key: const ValueKey('loading'),
          size: height * 0.5,
          color: const Color(0xFFFFFFFF),
        );
      case FxButtonState.success:
        return FxAnimatedCheck(
          key: const ValueKey('success'),
          size: height * 0.6,
          color: const Color(0xFFFFFFFF),
        );
      case FxButtonState.error:
        return CustomPaint(
          key: const ValueKey('error'),
          size: Size.square(height * 0.5),
          painter: _CrossPainter(const Color(0xFFFFFFFF)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final circle = state != FxButtonState.idle;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 220.0;
        return Align(
          child: GestureDetector(
            onTap: state == FxButtonState.idle ? onPressed : null,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              width: circle ? height : fullWidth,
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(
                  circle ? height / 2 : borderRadius,
                ),
              ),
              child: AnimatedSwitcher(duration: duration, child: _content()),
            ),
          ),
        );
      },
    );
  }
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.75),
        paint,
      )
      ..drawLine(
        Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.25, size.height * 0.75),
        paint,
      );
  }

  @override
  bool shouldRepaint(_CrossPainter oldDelegate) => oldDelegate.color != color;
}
