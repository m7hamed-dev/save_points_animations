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
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  double _offset = 0;
  double _childWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    _childWidth = _key.currentContext?.size?.width ?? 0;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduced && !_ticker.isActive && _childWidth > 0) _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final span = _childWidth + widget.gap;
    if (span <= 0) return;
    setState(() => _offset = (_offset + widget.velocity * dt) % span);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.translate(
        offset: Offset(-_offset, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KeyedSubtree(key: _key, child: widget.child),
            SizedBox(width: widget.gap),
            widget.child,
          ],
        ),
      ),
    );
  }
}
