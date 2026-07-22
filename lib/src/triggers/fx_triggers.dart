import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';

/// How a triggered animation is (re)started.
enum FxTrigger {
  /// Play once when first mounted.
  appear,

  /// Replay on each tap.
  tap,

  /// Replay on each double tap.
  doubleTap,

  /// Replay on each long press.
  longPress,

  /// Replay when the pointer enters (desktop/web hover).
  hover,

  /// Play once when the widget first scrolls into the viewport.
  visible,
}

/// Attach event triggers to an animation chain.
///
/// ```dart
/// icon.animate().scale(begin: 0.6).curve(FxCurves.elastic).onTap();
/// card.animate().fadeIn().onVisible();
/// ```
extension FxTriggerExtension on FxBuilder {
  /// Replay this chain on tap.
  Widget onTap({VoidCallback? onTap}) =>
      _FxTriggered(builder: this, trigger: FxTrigger.tap, onEvent: onTap);

  /// Replay this chain on double tap.
  Widget onDoubleTap({VoidCallback? onDoubleTap}) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.doubleTap,
    onEvent: onDoubleTap,
  );

  /// Replay this chain on long press.
  Widget onLongPress({VoidCallback? onLongPress}) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.longPress,
    onEvent: onLongPress,
  );

  /// Replay this chain when the pointer hovers over it.
  Widget onHover() => _FxTriggered(builder: this, trigger: FxTrigger.hover);

  /// Play this chain once when it first mounts (explicit form of autoplay).
  Widget onAppear() => _FxTriggered(builder: this, trigger: FxTrigger.appear);

  /// Play this chain once when it first scrolls into the viewport.
  Widget onVisible({double visibleFraction = 0.1}) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.visible,
    visibleFraction: visibleFraction,
  );

  /// Alias for [onVisible].
  Widget animateOnVisible({double visibleFraction = 0.1}) =>
      onVisible(visibleFraction: visibleFraction);
}

class _FxTriggered extends StatefulWidget {
  const _FxTriggered({
    required this.builder,
    required this.trigger,
    this.onEvent,
    this.visibleFraction = 0.1,
  });

  final FxBuilder builder;
  final FxTrigger trigger;
  final VoidCallback? onEvent;
  final double visibleFraction;

  @override
  State<_FxTriggered> createState() => _FxTriggeredState();
}

class _FxTriggeredState extends State<_FxTriggered> {
  final FxController _controller = FxController();
  bool _firedVisible = false;

  bool get _playOnMount => widget.trigger == FxTrigger.appear;

  void _fire() {
    _controller.restart();
    widget.onEvent?.call();
  }

  void _checkVisible() {
    if (_firedVisible) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final screenHeight = MediaQuery.of(context).size.height;
    final visiblePx =
        bottom.clamp(0.0, screenHeight) - top.clamp(0.0, screenHeight);
    final fraction = box.size.height == 0 ? 0.0 : visiblePx / box.size.height;
    if (fraction >= widget.visibleFraction) {
      _firedVisible = true;
      _controller.restart();
      widget.onEvent?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.trigger == FxTrigger.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkVisible();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final animated = widget.builder.configure(
      controller: _controller,
      autoPlay: _playOnMount,
    );

    switch (widget.trigger) {
      case FxTrigger.appear:
        return animated;
      case FxTrigger.tap:
        return GestureDetector(onTap: _fire, child: animated);
      case FxTrigger.doubleTap:
        return GestureDetector(onDoubleTap: _fire, child: animated);
      case FxTrigger.longPress:
        return GestureDetector(onLongPress: _fire, child: animated);
      case FxTrigger.hover:
        return MouseRegion(onEnter: (_) => _fire(), child: animated);
      case FxTrigger.visible:
        return NotificationListener<ScrollNotification>(
          onNotification: (_) {
            _checkVisible();
            return false;
          },
          child: animated,
        );
    }
  }
}
