import 'package:flutter/widgets.dart';

/// A pointer-driven 3D perspective tilt (a "card hover" effect).
///
/// Follows the pointer while hovering and springs back to flat on exit.
class FxTilt extends StatefulWidget {
  const FxTilt({
    super.key,
    required this.child,
    this.maxTilt = 0.18,
    this.perspective = 0.001,
    this.duration = const Duration(milliseconds: 120),
  });

  final Widget child;

  /// Maximum tilt in radians at the edges.
  final double maxTilt;

  /// Perspective depth (smaller = subtler).
  final double perspective;

  /// How quickly the tilt eases toward the pointer.
  final Duration duration;

  @override
  State<FxTilt> createState() => _FxTiltState();
}

class _FxTiltState extends State<FxTilt> {
  Offset _target = Offset.zero;

  void _update(Offset local, Size size) {
    if (size.isEmpty) return;
    final dx = (local.dx / size.width - 0.5) * 2;
    final dy = (local.dy / size.height - 0.5) * 2;
    setState(() => _target = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Read the size from the constraints local to this build pass and pass
        // it into the hover handler, rather than stashing it in a field during
        // build (which would be a build-phase side-effect).
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (event) => _update(event.localPosition, size),
          onExit: (_) => setState(() => _target = Offset.zero),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: _target),
            duration: widget.duration,
            builder: (context, value, child) {
              final rx = -value.dy * widget.maxTilt;
              final ry = value.dx * widget.maxTilt;
              final matrix = Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateX(rx)
                ..rotateY(ry);
              return Transform(
                transform: matrix,
                alignment: Alignment.center,
                child: child,
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Sugar for wrapping a widget in [FxTilt].
extension FxTiltExtension on Widget {
  /// Add a pointer-driven 3D tilt.
  Widget tilt({double maxTilt = 0.18, double perspective = 0.001}) =>
      FxTilt(maxTilt: maxTilt, perspective: perspective, child: this);
}
