import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Flip a card programmatically via [FxFlipCard.controller].
class FxFlipCardController {
  VoidCallback? _flip;

  void _attach(VoidCallback flip) => _flip = flip;

  /// Toggle between the front and back faces.
  void flip() => _flip?.call();
}

/// A card that flips in 3D between [front] and [back].
///
/// ```dart
/// FxFlipCard(
///   front: const Card(child: Center(child: Text('Tap me'))),
///   back: const Card(child: Center(child: Text('Hello!'))),
/// );
/// ```
class FxFlipCard extends StatefulWidget {
  const FxFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.axis = Axis.horizontal,
    this.duration = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOut,
    this.flipOnTap = true,
    this.controller,
  });

  final Widget front;
  final Widget back;
  final Axis axis;
  final Duration duration;
  final Curve curve;
  final bool flipOnTap;
  final FxFlipCardController? controller;

  @override
  State<FxFlipCard> createState() => _FxFlipCardState();
}

class _FxFlipCardState extends State<FxFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_flip);
  }

  void _flip() {
    if (_controller.value < 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.flipOnTap ? _flip : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = widget.curve.transform(_controller.value);
            final angle = t * math.pi;
            final showFront = angle <= math.pi / 2;
            final matrix = Matrix4.identity()..setEntry(3, 2, 0.001);
            if (widget.axis == Axis.horizontal) {
              matrix.rotateY(angle);
            } else {
              matrix.rotateX(angle);
            }

            Widget face;
            if (showFront) {
              face = widget.front;
            } else {
              // Un-mirror the back face by pre-rotating it 180°.
              final correction = Matrix4.identity();
              if (widget.axis == Axis.horizontal) {
                correction.rotateY(math.pi);
              } else {
                correction.rotateX(math.pi);
              }
              face = Transform(
                transform: correction,
                alignment: Alignment.center,
                child: widget.back,
              );
            }

            return Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: face,
            );
          },
        ),
      ),
    );
  }
}
