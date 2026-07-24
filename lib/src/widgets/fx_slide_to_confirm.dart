import 'dart:async';

import 'package:flutter/widgets.dart';

/// A "slide to confirm / unlock" control — drag the thumb to the end to fire
/// [onConfirmed]; release early and it springs back.
///
/// ```dart
/// FxSlideToConfirm(label: const Text('Slide to pay'), onConfirmed: pay);
/// ```
class FxSlideToConfirm extends StatefulWidget {
  const FxSlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.height = 56,
    this.trackColor = const Color(0xFF448AFF),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFFFFFFFF),
    this.borderRadius = 28,
  });

  final Widget label;
  final VoidCallback onConfirmed;
  final double height;
  final Color trackColor;
  final Color thumbColor;
  final Color textColor;
  final double borderRadius;

  @override
  State<FxSlideToConfirm> createState() => _FxSlideToConfirmState();
}

class _FxSlideToConfirmState extends State<FxSlideToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _x = 0;
  double _max = 1;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  void _update(DragUpdateDetails d) {
    if (_confirmed) return;
    _controller.stop();
    setState(() => _x = (_x + (d.primaryDelta ?? 0)).clamp(0.0, _max));
  }

  void _end(DragEndDetails d) {
    if (_confirmed) return;
    if (_x >= _max * 0.9) {
      _animateTo(
        _max,
        onDone: () {
          setState(() => _confirmed = true);
          widget.onConfirmed();
        },
      );
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    final anim = Tween<double>(
      begin: _x,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    void listener() => setState(() => _x = anim.value);
    anim.addListener(listener);
    unawaited(
      _controller.forward(from: 0).whenComplete(() {
        anim.removeListener(listener);
        onDone?.call();
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumb = widget.height - 8;
          _max = constraints.maxWidth - thumb - 8;
          final progress = _max <= 0 ? 0.0 : (_x / _max).clamp(0.0, 1.0);
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.trackColor,
              borderRadius: .circular(widget.borderRadius),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 1 - progress,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.label,
                  ),
                ),
                Positioned(
                  left: 4 + _x,
                  top: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _update,
                    onHorizontalDragEnd: _end,
                    child: Container(
                      width: thumb,
                      height: thumb,
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: _ThumbPainter(
                          confirmed: _confirmed,
                          color: widget.trackColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter({required this.confirmed, required this.color});

  final bool confirmed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (confirmed) {
      path
        ..moveTo(w * 0.32, h * 0.52)
        ..lineTo(w * 0.44, h * 0.66)
        ..lineTo(w * 0.7, h * 0.36);
    } else {
      path
        ..moveTo(w * 0.42, h * 0.34)
        ..lineTo(w * 0.6, h * 0.5)
        ..lineTo(w * 0.42, h * 0.66);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) =>
      oldDelegate.confirmed != confirmed || oldDelegate.color != color;
}
