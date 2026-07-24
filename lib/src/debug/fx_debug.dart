import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Tracks live animation controllers created by the package, for the
/// `showControllers` / `showPerformance` debug overlays.
///
/// Incremented/decremented by the engine; read by debug overlays each frame.
class FxDebugRegistry {
  FxDebugRegistry._();

  /// Number of currently-active `.animate()` controllers.
  static int activeControllers = 0;
}

/// Development-only overlays. In release builds (`!kDebugMode`) every method
/// returns the child untouched, so there is **zero** production overhead.
///
/// ```dart
/// myPage.showFPS();
/// myWidget.showBounds();
/// scaffold.showPerformance();
/// ```
extension FxDebug on Widget {
  /// Draw the widget's bounds and size (debug only).
  Widget showBounds({Color color = const Color(0xFFFF00FF)}) =>
      kDebugMode ? _FxBounds(color: color, child: this) : this;

  /// Show a live FPS counter (debug only).
  Widget showFPS() =>
      kDebugMode ? _FxPerfOverlay(fps: true, child: this) : this;

  /// Show a rolling strip of recent frame durations (debug only).
  Widget showTimeline() =>
      kDebugMode ? _FxPerfOverlay(frameBars: true, child: this) : this;

  /// Show the count of active animation controllers (debug only).
  Widget showControllers() =>
      kDebugMode ? _FxPerfOverlay(controllers: true, child: this) : this;

  /// Show FPS + frame timeline + controller count together (debug only).
  Widget showPerformance() => kDebugMode
      ? _FxPerfOverlay(
          fps: true,
          frameBars: true,
          controllers: true,
          child: this,
        )
      : this;
}

class _FxBounds extends StatelessWidget {
  const _FxBounds({required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: color)),
              child: Align(
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (context, constraints) => ColoredBox(
                    color: color.withValues(alpha: 0.75),
                    child: Text(
                      '${constraints.maxWidth.toStringAsFixed(0)}'
                      '×${constraints.maxHeight.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FxPerfOverlay extends StatefulWidget {
  const _FxPerfOverlay({
    required this.child,
    this.fps = false,
    this.frameBars = false,
    this.controllers = false,
  });

  final Widget child;
  final bool fps;
  final bool frameBars;
  final bool controllers;

  @override
  State<_FxPerfOverlay> createState() => _FxPerfOverlayState();
}

class _FxPerfOverlayState extends State<_FxPerfOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  final List<double> _frameMs = <double>[];

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dtMs = (elapsed - _last).inMicroseconds / 1000.0;
    _last = elapsed;
    if (dtMs > 0) {
      _frameMs.add(dtMs);
      if (_frameMs.length > 48) _frameMs.removeAt(0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _avgMs =>
      _frameMs.isEmpty ? 0 : _frameMs.reduce((a, b) => a + b) / _frameMs.length;

  @override
  Widget build(BuildContext context) {
    final avg = _avgMs;
    final fps = avg <= 0 ? 0 : (1000 / avg).round();

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 8,
          left: 8,
          child: IgnorePointer(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 10,
                fontFamilyFallback: ['monospace'],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCC000000),
                  borderRadius: .circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.fps)
                      Text('${fps}fps  ${avg.toStringAsFixed(1)}ms'),
                    if (widget.frameBars) _bars(),
                    if (widget.controllers)
                      Text('ctrls: ${FxDebugRegistry.activeControllers}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bars() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final ms in _frameMs)
              Container(
                width: 2,
                height: (ms / 32 * 24).clamp(1.0, 24.0),
                margin: const EdgeInsets.only(right: 1),
                color: ms <= 16.7
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
              ),
          ],
        ),
      ),
    );
  }
}
