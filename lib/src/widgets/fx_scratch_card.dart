import 'package:flutter/widgets.dart';

/// A scratch-to-reveal card — drag across the cover to erase it and reveal
/// [child] beneath (scratch cards, coupons, spoilers).
///
/// ```dart
/// FxScratchCard(child: const Text('You won!'));
/// ```
class FxScratchCard extends StatefulWidget {
  const FxScratchCard({
    super.key,
    required this.child,
    this.coverColor = const Color(0xFFB0B0B0),
    this.brushSize = 28,
  });

  final Widget child;
  final Color coverColor;
  final double brushSize;

  @override
  State<FxScratchCard> createState() => _FxScratchCardState();
}

class _FxScratchCardState extends State<FxScratchCard> {
  final List<Offset> _points = [];

  // Bumped whenever a point is added so the painter (via `repaint:`) redraws
  // without rebuilding the whole Stack — which would rebuild widget.child too.
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  // Minimum distance between consecutive stored points. Skipping closer moves
  // caps the unbounded growth of _points (and the per-frame re-pathing cost)
  // while staying dense enough for a smooth stroke at typical brush sizes.
  static const double _minSpacing = 4;

  void _add(Offset p) {
    if (_points.isNotEmpty) {
      final last = _points.last;
      if ((p - last).distanceSquared < _minSpacing * _minSpacing) return;
    }
    _points.add(p);
    _revision.value++;
  }

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => _add(d.localPosition),
      onPanUpdate: (d) => _add(d.localPosition),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: CustomPaint(
              painter: _ScratchPainter(
                points: _points,
                coverColor: widget.coverColor,
                brushSize: widget.brushSize,
                repaint: _revision,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  _ScratchPainter({
    required this.points,
    required this.coverColor,
    required this.brushSize,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<Offset> points;
  final Color coverColor;
  final double brushSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..color = coverColor);

    final erase = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = brushSize;
    if (points.isNotEmpty) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas
        ..drawPath(path, erase)
        ..drawCircle(
          points.last,
          brushSize / 2,
          Paint()..blendMode = BlendMode.clear,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScratchPainter oldDelegate) =>
      oldDelegate.points.length != points.length ||
      oldDelegate.coverColor != coverColor;
}
