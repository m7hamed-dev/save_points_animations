import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_switcher.dart';

/// A countdown that ticks down from [duration], animating each change.
///
/// By default it shows whole seconds with a slide-up digit swap; supply
/// [builder] for full control (e.g. a `mm:ss` label or a progress ring).
///
/// ```dart
/// FxCountdown(
///   duration: const Duration(seconds: 10),
///   onComplete: () => print('liftoff'),
/// );
/// ```
class FxCountdown extends StatefulWidget {
  const FxCountdown({
    super.key,
    required this.duration,
    this.onComplete,
    this.style,
    this.builder,
  });

  final Duration duration;
  final VoidCallback? onComplete;
  final TextStyle? style;

  /// Custom renderer for the remaining time. When null, whole seconds are
  /// shown with an animated swap.
  final Widget Function(BuildContext context, Duration remaining)? builder;

  @override
  State<FxCountdown> createState() => _FxCountdownState();
}

class _FxCountdownState extends State<FxCountdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller
      ..addListener(_tick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      })
      ..forward();
  }

  /// The whole seconds the default display last built.
  int? _shownSeconds;

  /// The default display only changes once a second, so it rebuilds then and
  /// not on every frame. A custom [FxCountdown.builder] gets every frame
  /// through its own [AnimatedBuilder].
  void _tick() {
    if (widget.builder == null && _remaining.inSeconds != _shownSeconds) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant FxCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.forward(from: _controller.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _remaining => Duration(
    milliseconds: (widget.duration.inMilliseconds * (1 - _controller.value))
        .round(),
  );

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (builder != null) {
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => builder(context, _remaining),
        ),
      );
    }
    final seconds = _shownSeconds = _remaining.inSeconds;
    return RepaintBoundary(
      child: Semantics(
        liveRegion: true,
        label: '$seconds seconds remaining',
        child: FxSwitcher(
          effect: FxSwitcherEffect.slideUp,
          child: Text(
            '$seconds',
            key: ValueKey<int>(seconds),
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
