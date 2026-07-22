import 'package:flutter/widgets.dart';

/// Animated page dots for a [PageView], synced to its [PageController].
///
/// The active dot smoothly expands (worm-style) and tints as you swipe.
///
/// ```dart
/// FxPageIndicator(controller: _pageController, count: 4);
/// ```
class FxPageIndicator extends StatefulWidget {
  const FxPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.size = 8,
    this.spacing = 6,
    this.expansion = 3,
    this.activeColor = const Color(0xFF448AFF),
    this.color = const Color(0x55448AFF),
    this.onDotTapped,
  });

  final PageController controller;
  final int count;
  final double size;
  final double spacing;

  /// How many times wider the active dot becomes.
  final double expansion;
  final Color activeColor;
  final Color color;
  final ValueChanged<int>? onDotTapped;

  @override
  State<FxPageIndicator> createState() => _FxPageIndicatorState();
}

class _FxPageIndicatorState extends State<FxPageIndicator> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant FxPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  double get _page {
    final controller = widget.controller;
    if (controller.hasClients && controller.position.haveDimensions) {
      return controller.page ?? controller.initialPage.toDouble();
    }
    return controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.count; i++) ...[
          if (i > 0) SizedBox(width: widget.spacing),
          _dot(i, page),
        ],
      ],
    );
  }

  Widget _dot(int index, double page) {
    final selected = (1 - (page - index).abs()).clamp(0.0, 1.0);
    final width = widget.size + widget.size * (widget.expansion - 1) * selected;
    final dot = Container(
      width: width,
      height: widget.size,
      decoration: BoxDecoration(
        color: Color.lerp(widget.color, widget.activeColor, selected),
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
    );
    if (widget.onDotTapped == null) return dot;
    return GestureDetector(onTap: () => widget.onDotTapped!(index), child: dot);
  }
}
