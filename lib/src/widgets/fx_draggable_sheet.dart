import 'package:flutter/widgets.dart';

/// A lightweight draggable bottom sheet that snaps between a list of height
/// [snapSizes] (as fractions of the available height). Drag the handle or the
/// body to move it; on release it springs to the nearest snap point.
///
/// Place it as the top child of a `Stack` that fills the screen.
///
/// ```dart
/// Stack(children: [page, FxDraggableSheet(child: content)]);
/// ```
class FxDraggableSheet extends StatefulWidget {
  const FxDraggableSheet({
    super.key,
    required this.child,
    this.snapSizes = const [0.3, 0.6, 0.92],
    this.initialSnap = 0,
    this.background = const Color(0xFFFFFFFF),
    this.handleColor = const Color(0xFFD0D0D0),
    this.borderRadius = 24,
    this.onSnapChanged,
  });

  final Widget child;
  final List<double> snapSizes;
  final int initialSnap;
  final Color background;
  final Color handleColor;
  final double borderRadius;
  final ValueChanged<int>? onSnapChanged;

  @override
  State<FxDraggableSheet> createState() => _FxDraggableSheetState();
}

class _FxDraggableSheetState extends State<FxDraggableSheet> {
  late double _fraction = widget.snapSizes[widget.initialSnap];
  bool _dragging = false;

  double get _minSnap => widget.snapSizes.reduce((a, b) => a < b ? a : b);
  double get _maxSnap => widget.snapSizes.reduce((a, b) => a > b ? a : b);

  void _onDragUpdate(double dy, double height) {
    setState(() {
      _dragging = true;
      _fraction = (_fraction - dy / height).clamp(_minSnap, _maxSnap);
    });
  }

  void _settle() {
    var nearest = widget.snapSizes.first;
    var best = double.infinity;
    for (final s in widget.snapSizes) {
      final d = (s - _fraction).abs();
      if (d < best) {
        best = d;
        nearest = s;
      }
    }
    setState(() {
      _dragging = false;
      _fraction = nearest;
    });
    widget.onSnapChanged?.call(widget.snapSizes.indexOf(nearest));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final radius = Radius.circular(widget.borderRadius);
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: _dragging
                ? Duration.zero
                : const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            height: height * _fraction,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.vertical(top: radius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) =>
                      _onDragUpdate(d.delta.dy, height),
                  onVerticalDragEnd: (_) => _settle(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.handleColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
