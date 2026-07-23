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

  void _add(Offset p) => setState(() => _points.add(p));

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
  });

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
