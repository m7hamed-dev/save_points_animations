import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A main button that fans its [children] out along an arc when tapped — a
/// radial action menu.
///
/// ```dart
/// FxCircularMenu(icon: const Icon(Icons.add), children: [a, b, c]);
/// ```
class FxCircularMenu extends StatefulWidget {
  const FxCircularMenu({
    super.key,
    required this.icon,
    required this.children,
    this.radius = 90,
    this.startAngle = math.pi,
    this.sweepAngle = math.pi / 2,
    this.backgroundColor = const Color(0xFF448AFF),
    this.size = 56,
    this.duration = const Duration(milliseconds: 340),
  });

  final Widget icon;
  final List<Widget> children;
  final double radius;

  /// Where the arc begins, in radians (default points left).
  final double startAngle;

  /// How far the arc spans, in radians (default a quarter turn).
  final double sweepAngle;
  final Color backgroundColor;
  final double size;
  final Duration duration;

  @override
  State<FxCircularMenu> createState() => _FxCircularMenuState();
}

class _FxCircularMenuState extends State<FxCircularMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < n; i++) _item(i, n),
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 8),
                ],
              ),
              child: Center(
                child: RotationTransition(
                  turns: Tween<double>(
                    begin: 0,
                    end: 0.375,
                  ).animate(_controller),
                  child: widget.icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int i, int n) {
    final angle = n == 1
        ? widget.startAngle + widget.sweepAngle / 2
        : widget.startAngle + widget.sweepAngle * (i / (n - 1));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = Curves.easeOutBack.transform(_controller.value);
        final r = widget.radius * v;
        return Transform.translate(
          offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
          child: Opacity(
            opacity: _controller.value.clamp(0.0, 1.0),
            child: Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
          ),
        );
      },
      child: IgnorePointer(ignoring: !_open, child: widget.children[i]),
    );
  }
}
