import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Emits an expanding, fading ripple from each tap point over [child] — a
/// standalone, colorable ink-ripple that works without a Material ancestor.
///
/// ```dart
/// FxRipple(color: Colors.blue, child: myCard);
/// ```
class FxRipple extends StatefulWidget {
  const FxRipple({
    super.key,
    required this.child,
    this.color = const Color(0x33448AFF),
    this.duration = const Duration(milliseconds: 600),
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  State<FxRipple> createState() => _FxRippleState();
}

class _FxRippleState extends State<FxRipple>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Ripple> _ripples = [];
  Duration _elapsed = Duration.zero;

  // Bumped each tick to drive the painter's `repaint:` without rebuilding the
  // widget subtree (the ripple list is mutated in place).
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    _elapsed = elapsed;
    _ripples.removeWhere((r) => elapsed - r.start > widget.duration);
    if (_ripples.isEmpty) {
      _ticker.stop();
      return;
    }
    _frame.value++;
  }

  void _addRipple(Offset position) {
    _ripples.add(_Ripple(position: position, start: _elapsed));
    if (!_ticker.isActive) _ticker.start();
    _frame.value++;
    widget.onTap?.call();
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _addRipple(details.localPosition),
        child: ClipRect(
          child: CustomPaint(
            foregroundPainter: _RipplePainter(
              ripples: _ripples,
              elapsed: _elapsed,
              duration: widget.duration,
              color: widget.color,
              repaint: _frame,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _Ripple {
  _Ripple({required this.position, required this.start});

  final Offset position;
  final Duration start;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.ripples,
    required this.elapsed,
    required this.duration,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Ripple> ripples;
  final Duration elapsed;
  final Duration duration;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = size.longestSide;
    for (final r in ripples) {
      final progress =
          ((elapsed - r.start).inMicroseconds / duration.inMicroseconds).clamp(
            0.0,
            1.0,
          );
      final paint = Paint()
        ..color = color.withValues(alpha: color.a * (1 - progress));
      canvas.drawCircle(r.position, progress * maxR, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      // The `_frame` Listenable passed as `repaint:` already drives per-tick
      // repaints; only config that changes the drawing needs checking here.
      oldDelegate.color != color || oldDelegate.duration != duration;
}
