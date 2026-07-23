import 'package:flutter/widgets.dart';

/// One layer in an [FxParallaxLayers] stack, with a [depth] that scales how far
/// it shifts (larger = moves more = feels closer).
class FxParallaxLayer {
  const FxParallaxLayer({required this.child, this.depth = 1.0});

  final Widget child;
  final double depth;
}

/// A stack of layers that shift by different amounts as the pointer moves,
/// creating a 3D depth / parallax effect (great for product or hero cards).
///
/// ```dart
/// FxParallaxLayers(
///   layers: [
///     FxParallaxLayer(child: background, depth: 0.3),
///     FxParallaxLayer(child: subject, depth: 1.2),
///   ],
/// );
/// ```
class FxParallaxLayers extends StatefulWidget {
  const FxParallaxLayers({super.key, required this.layers, this.maxShift = 18});

  final List<FxParallaxLayer> layers;

  /// Peak shift in logical pixels for a depth of 1.0.
  final double maxShift;

  @override
  State<FxParallaxLayers> createState() => _FxParallaxLayersState();
}

class _FxParallaxLayersState extends State<FxParallaxLayers> {
  Offset _target = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (event) {
            if (size.isEmpty) return;
            setState(() {
              _target = Offset(
                (event.localPosition.dx / size.width) * 2 - 1,
                (event.localPosition.dy / size.height) * 2 - 1,
              );
            });
          },
          onExit: (_) => setState(() => _target = Offset.zero),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: _target),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            builder: (context, value, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (final layer in widget.layers)
                  Transform.translate(
                    offset: value * (widget.maxShift * layer.depth),
                    child: layer.child,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
