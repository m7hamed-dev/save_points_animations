import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A swipeable carousel where the centered page sits full-size and neighbours
/// shrink and fade — a depth-of-field "cover flow" feel. Pages peek in from the
/// sides via [viewportFraction].
///
/// ```dart
/// FxCarousel(children: [cardA, cardB, cardC]);
/// ```
class FxCarousel extends StatefulWidget {
  const FxCarousel({
    super.key,
    required this.children,
    this.height = 220,
    this.viewportFraction = 0.8,
    this.minScale = 0.84,
    this.onPageChanged,
  });

  final List<Widget> children;
  final double height;
  final double viewportFraction;
  final double minScale;
  final ValueChanged<int>? onPageChanged;

  @override
  State<FxCarousel> createState() => _FxCarouselState();
}

class _FxCarouselState extends State<FxCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
  );
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _page = _controller.page ?? 0);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.children.length,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, i) {
          final delta = (i - _page).abs().clamp(0.0, 1.0);
          final scale = 1 - (1 - widget.minScale) * delta;
          final opacity = 1 - 0.4 * delta;
          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: widget.children[i],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A row of dots that tracks an [FxCarousel] page; the active dot stretches
/// into a pill. Drive [page] from the carousel's `onPageChanged`.
class FxCarouselDots extends StatelessWidget {
  const FxCarouselDots({
    super.key,
    required this.count,
    required this.page,
    this.activeColor = const Color(0xFF448AFF),
    this.color = const Color(0xFFCFD8E3),
    this.size = 8,
  });

  final int count;
  final int page;
  final Color activeColor;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == page ? size * math.max(2.4, 1) : size,
            height: size,
            decoration: BoxDecoration(
              color: i == page ? activeColor : color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
      ],
    );
  }
}
