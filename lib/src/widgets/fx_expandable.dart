import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A tappable header with a collapsible [body] that animates open/closed while
/// a chevron rotates. The header is keyboard-focusable; Enter / Space toggle it.
///
/// ```dart
/// FxExpandable(
///   header: const Text('Details'),
///   body: const Padding(padding: EdgeInsets.all(12), child: Text('…')),
/// );
/// ```
class FxExpandable extends StatefulWidget {
  const FxExpandable({
    super.key,
    required this.header,
    required this.body,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOut,
    this.chevronColor = const Color(0xFF888888),
  });

  final Widget header;
  final Widget body;
  final bool initiallyExpanded;
  final Duration duration;
  final Curve curve;
  final Color chevronColor;

  @override
  State<FxExpandable> createState() => _FxExpandableState();
}

class _FxExpandableState extends State<FxExpandable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _curved;

  late bool _expanded = widget.initiallyExpanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.initiallyExpanded ? 1 : 0,
    );
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant FxExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve) {
      _curved.dispose();
      _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            enabled: true,
            expanded: _expanded,
            // Enter / Space toggle the header when it has keyboard focus.
            child: FxFocusableControl(
              enabled: true,
              onActivate: _toggle,
              builder: (context, showFocus) => FxFocusRing(
                visible: showFocus,
                color: widget.chevronColor,
                borderRadius: .circular(6),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Row(
                    children: [
                      Expanded(child: widget.header),
                      RotationTransition(
                        turns: Tween<double>(
                          begin: 0,
                          end: 0.5,
                        ).animate(_curved),
                        child: CustomPaint(
                          size: const Size(14, 14),
                          painter: _ChevronPainter(widget.chevronColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _curved,
            alignment: Alignment.topCenter,
            child: widget.body,
          ),
        ],
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.38)
      ..lineTo(size.width * 0.5, size.height * 0.66)
      ..lineTo(size.width * 0.8, size.height * 0.38);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
