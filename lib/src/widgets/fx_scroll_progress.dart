import 'package:flutter/widgets.dart';

/// A thin bar that fills to reflect how far a scroll view has been scrolled —
/// the "reading progress" indicator for articles and long pages.
///
/// Pass a [controller], or place it inside/near a [Scrollable] and it finds the
/// nearest one.
///
/// ```dart
/// FxScrollProgress(controller: _scrollController);
/// ```
class FxScrollProgress extends StatefulWidget {
  const FxScrollProgress({
    super.key,
    this.controller,
    this.height = 4,
    this.color = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.borderRadius = 0,
  });

  final ScrollController? controller;
  final double height;
  final Color color;
  final Color backgroundColor;
  final double borderRadius;

  @override
  State<FxScrollProgress> createState() => _FxScrollProgressState();
}

class _FxScrollProgressState extends State<FxScrollProgress> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(covariant FxScrollProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _attach();
    }
  }

  void _attach() {
    final next = widget.controller?.hasClients ?? false
        ? widget.controller!.position
        : Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      setState(() => _position = next);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _position == null) _attach();
      });
    }
  }

  double get _fraction {
    final pos = _position;
    if (pos == null || !pos.hasContentDimensions) return 0;
    final max = pos.maxScrollExtent;
    return max <= 0 ? 0.0 : (pos.pixels / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final position = _position;
    Widget buildBar() => ClipRRect(
      borderRadius: .circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: widget.backgroundColor),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _fraction,
                child: ColoredBox(color: widget.color),
              ),
            ),
          ],
        ),
      ),
    );
    return RepaintBoundary(
      child: position == null
          ? buildBar()
          : AnimatedBuilder(
              animation: position,
              builder: (context, _) => buildBar(),
            ),
    );
  }
}
