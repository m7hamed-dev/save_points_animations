import 'package:flutter/widgets.dart';

/// A before/after comparison slider. [before] fills the frame; [after] is
/// revealed up to a draggable vertical divider. Drag anywhere to move the
/// divider; it eases toward the touch point.
///
/// ```dart
/// FxImageCompare(before: Image.asset('a.jpg'), after: Image.asset('b.jpg'));
/// ```
class FxImageCompare extends StatefulWidget {
  const FxImageCompare({
    super.key,
    required this.before,
    required this.after,
    this.height = 220,
    this.initialPosition = 0.5,
    this.dividerColor = const Color(0xFFFFFFFF),
    this.dividerWidth = 3,
    this.borderRadius = 16,
  });

  final Widget before;
  final Widget after;
  final double height;
  final double initialPosition;
  final Color dividerColor;
  final double dividerWidth;
  final double borderRadius;

  @override
  State<FxImageCompare> createState() => _FxImageCompareState();
}

class _FxImageCompareState extends State<FxImageCompare> {
  late double _pos = widget.initialPosition;
  bool _dragging = false;

  void _update(double dx, double width) {
    setState(() => _pos = (dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ClipRRect(
          borderRadius: .circular(widget.borderRadius),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (d) {
              setState(() => _dragging = true);
              _update(d.localPosition.dx, width);
            },
            onHorizontalDragUpdate: (d) => _update(d.localPosition.dx, width),
            onHorizontalDragEnd: (_) => setState(() => _dragging = false),
            onTapDown: (d) => _update(d.localPosition.dx, width),
            child: SizedBox(
              height: widget.height,
              width: width,
              child: Stack(
                children: [
                  Positioned.fill(child: widget.before),
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _RevealClipper(_pos),
                      child: widget.after,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    left: _pos * width - widget.dividerWidth / 2,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: widget.dividerWidth,
                      color: widget.dividerColor,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    left: _pos * width - 16,
                    top: widget.height / 2 - 16,
                    child: _Handle(color: widget.dividerColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_RevealClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _Handle extends StatelessWidget {
  const _Handle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
      ),
      // A simple left/right arrow pair, drawn without the Material icon font.
      child: const Center(
        child: Text(
          '⟺',
          style: TextStyle(color: Color(0xFF444444), fontSize: 16, height: 1),
        ),
      ),
    );
  }
}
