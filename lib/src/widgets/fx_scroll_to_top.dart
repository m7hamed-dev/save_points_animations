import 'package:flutter/widgets.dart';

/// A floating "scroll to top" button that fades and scales in once its
/// [controller] scrolls past [threshold], and animates back out near the top.
/// Tapping it smoothly scrolls to offset 0. Place it in a `Stack` above your
/// scroll view (typically bottom-right).
///
/// ```dart
/// Stack(children: [listView, FxScrollToTop(controller: _scroll)]);
/// ```
class FxScrollToTop extends StatefulWidget {
  const FxScrollToTop({
    super.key,
    required this.controller,
    this.threshold = 300,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
    this.color = const Color(0xFF448AFF),
    this.iconColor = const Color(0xFFFFFFFF),
    this.size = 48,
    this.child,
  });

  final ScrollController controller;
  final double threshold;
  final Alignment alignment;
  final EdgeInsets margin;
  final Color color;
  final Color iconColor;
  final double size;
  final Widget? child;

  @override
  State<FxScrollToTop> createState() => _FxScrollToTopState();
}

class _FxScrollToTopState extends State<FxScrollToTop> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant FxScrollToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
      _onScroll();
    }
  }

  void _onScroll() {
    final show =
        widget.controller.hasClients &&
        widget.controller.offset > widget.threshold;
    if (show != _visible) setState(() => _visible = show);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _toTop() {
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.margin,
        child: AnimatedScale(
          scale: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Semantics(
              button: true,
              label: 'Scroll to top',
              child: GestureDetector(
                onTap: _toTop,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      widget.child ??
                      Text(
                        '↑',
                        style: TextStyle(
                          color: widget.iconColor,
                          fontSize: widget.size * 0.5,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
