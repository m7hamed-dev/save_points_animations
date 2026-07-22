import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

/// Applies an entrance chain to `child.animate(...)`.
///
/// Receives a builder already bound to the presence controller, so you only
/// add effects: `(a) => a.fadeIn().scaleIn()`.
typedef FxEntranceBuilder = FxBuilder Function(FxBuilder animate);

/// Animates a child **in** when [visible] becomes true and **out** (by playing
/// the same chain in reverse) when it becomes false — only removing it from the
/// layout once the exit animation completes.
///
/// This fills the gap left by the one-shot builder: effects normally play on
/// mount with no way to animate *out* before removal.
///
/// ```dart
/// FxAnimatedVisibility(
///   visible: _show,
///   effects: (a) => a.fadeIn().scaleIn(begin: 0.9),
///   child: const Card(child: Text('Peekaboo')),
/// );
/// ```
class FxAnimatedVisibility extends StatefulWidget {
  const FxAnimatedVisibility({
    super.key,
    required this.visible,
    required this.effects,
    required this.child,
    this.onDismissed,
  });

  /// Whether the child should be shown.
  final bool visible;

  /// The entrance chain; played in reverse on exit.
  final FxEntranceBuilder effects;

  /// The widget to show/hide.
  final Widget child;

  /// Called once the exit animation has finished and the child is removed.
  final VoidCallback? onDismissed;

  @override
  State<FxAnimatedVisibility> createState() => _FxAnimatedVisibilityState();
}

class _FxAnimatedVisibilityState extends State<FxAnimatedVisibility> {
  final FxController _fx = FxController();

  /// Whether the animated child is currently in the tree (true throughout the
  /// exit animation; false only once fully dismissed).
  late bool _present = widget.visible;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fx.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant FxAnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;

    if (widget.visible) {
      setState(() => _present = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fx
          ..reset()
          ..forward();
      });
    } else {
      final future = _fx.reverse();
      if (future == null) {
        _dismiss();
      } else {
        future.then((_) {
          if (mounted && !widget.visible) _dismiss();
        });
      }
    }
  }

  void _dismiss() {
    if (!_present) return;
    setState(() => _present = false);
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_present) return const SizedBox.shrink();
    return widget.effects(
      widget.child.animate(controller: _fx, autoPlay: false),
    );
  }
}

/// Sugar for wrapping a widget in [FxAnimatedVisibility].
extension FxVisibility on Widget {
  /// Show/hide this widget with an animated entrance and reverse exit.
  ///
  /// ```dart
  /// card.animatedVisibility(visible: show, effects: (a) => a.fadeIn());
  /// ```
  Widget animatedVisibility({
    required bool visible,
    required FxEntranceBuilder effects,
    VoidCallback? onDismissed,
    Key? key,
  }) => FxAnimatedVisibility(
    key: key,
    visible: visible,
    effects: effects,
    onDismissed: onDismissed,
    child: this,
  );
}
