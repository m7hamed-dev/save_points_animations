import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Continuously scrolls [child] horizontally — a marquee / ticker for text or
/// content that's wider than its box.
///
/// ```dart
/// SizedBox(
///   width: 200,
///   child: FxMarquee(child: Text('Breaking news • ' * 4)),
/// );
/// ```
class FxMarquee extends StatefulWidget {
  const FxMarquee({
    super.key,
    required this.child,
    this.velocity = 40,
    this.gap = 48,
  });

  final Widget child;

  /// Scroll speed in logical pixels per second.
  final double velocity;

  /// Gap between the repeated copies of [child].
  final double gap;

  @override
  State<FxMarquee> createState() => _FxMarqueeState();
}

class _FxMarqueeState extends State<FxMarquee>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);
  double _childWidth = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant FxMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A changed child/text can have a different width, which drives the wrap
    // span; re-measure after the new child has laid out.
    if (oldWidget.child != widget.child || oldWidget.gap != widget.gap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted) return;
    _childWidth = _key.currentContext?.size?.width ?? 0;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      if (_ticker.isActive) _ticker.stop();
      _offset.value = 0;
    } else if (!_ticker.isActive && _childWidth > 0) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final span = _childWidth + widget.gap;
    if (span <= 0) return;
    _offset.value = (_offset.value + widget.velocity * dt) % span;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A horizontal viewport fills the available width, shrink-wraps to the
    // child's height, and grants the row unbounded horizontal extent — so the
    // wider-than-viewport content lays out without overflowing and is clipped
    // to the box. The transform drives the scroll; the viewport itself is
    // static (NeverScrollableScrollPhysics).
    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        // The row is built once and passed as the static `child`; only the
        // Transform.translate offset updates per frame.
        child: ValueListenableBuilder<double>(
          valueListenable: _offset,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KeyedSubtree(key: _key, child: widget.child),
              SizedBox(width: widget.gap),
              widget.child,
            ],
          ),
          builder: (context, offset, child) =>
              Transform.translate(offset: Offset(-offset, 0), child: child),
        ),
      ),
    );
  }
}
