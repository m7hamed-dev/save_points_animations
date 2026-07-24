import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A count badge overlaid on [child] that **pops** whenever the count changes.
///
/// ```dart
/// FxBadge(count: unread, child: const Icon(Icons.notifications));
/// ```
class FxBadge extends StatefulWidget {
  const FxBadge({
    super.key,
    required this.child,
    required this.count,
    this.color = const Color(0xFFE53935),
    this.textColor = const Color(0xFFFFFFFF),
    this.alignment = Alignment.topRight,
    this.showZero = false,
    this.maxCount = 99,
  });

  final Widget child;
  final int count;
  final Color color;
  final Color textColor;
  final Alignment alignment;
  final bool showZero;
  final int maxCount;

  @override
  State<FxBadge> createState() => _FxBadgeState();
}

class _FxBadgeState extends State<FxBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  bool get _visible => widget.count > 0 || widget.showZero;

  @override
  void initState() {
    super.initState();
    if (_visible) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant FxBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && _visible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alignment;
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_visible)
            Positioned(
              top: a.y < 0 ? -6 : null,
              bottom: a.y > 0 ? -6 : null,
              left: a.x < 0 ? -6 : null,
              right: a.x > 0 ? -6 : null,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.scale(
                  scale: 1 + math.sin(_controller.value * math.pi) * 0.35,
                  child: child,
                ),
                child: _badge(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge() {
    final label = widget.count > widget.maxCount
        ? '${widget.maxCount}+'
        : '${widget.count}';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: .circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: widget.textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

/// Sugar for wrapping a widget in an [FxBadge].
extension FxBadgeExtension on Widget {
  /// Overlay a popping count [count] badge.
  Widget badge(
    int count, {
    Color color = const Color(0xFFE53935),
    Alignment alignment = Alignment.topRight,
    bool showZero = false,
  }) => FxBadge(
    count: count,
    color: color,
    alignment: alignment,
    showZero: showZero,
    child: this,
  );
}
