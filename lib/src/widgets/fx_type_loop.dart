import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Types out each phrase in [phrases], pauses, deletes it, and moves to the
/// next — the looping "typewriter" hero effect.
///
/// ```dart
/// FxTypeLoop(phrases: const ['Fast.', 'Fluid.', 'Fun.']);
/// ```
class FxTypeLoop extends StatefulWidget {
  const FxTypeLoop({
    super.key,
    required this.phrases,
    this.style,
    this.typeSpeed = const Duration(milliseconds: 85),
    this.pause = const Duration(milliseconds: 1200),
    this.cursor = '|',
  });

  final List<String> phrases;
  final TextStyle? style;
  final Duration typeSpeed;
  final Duration pause;
  final String cursor;

  @override
  State<FxTypeLoop> createState() => _FxTypeLoopState();
}

class _FxTypeLoopState extends State<FxTypeLoop> with FxMotionAware {
  Timer? _timer;
  int _phrase = 0;
  int _count = 0;
  bool _deleting = false;
  int _pauseTicks = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only fires onReduceMotionChanged when the flag flips, so
    // start the loop on first mount when motion is allowed.
    if (!_started) {
      _started = true;
      if (!reduceMotion) {
        _timer = Timer.periodic(widget.typeSpeed, (_) => _tick());
      }
    }
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(widget.typeSpeed, (_) => _tick());
    }
  }

  void _tick() {
    if (!mounted || widget.phrases.isEmpty) return;
    if (_pauseTicks > 0) {
      _pauseTicks--;
      return;
    }
    final text = widget.phrases[_phrase];
    if (!_deleting) {
      if (_count < text.length) {
        setState(() => _count++);
        if (_count == text.length) {
          _pauseTicks =
              (widget.pause.inMicroseconds / widget.typeSpeed.inMicroseconds)
                  .round();
          _deleting = true;
        }
      }
    } else {
      if (_count > 0) {
        setState(() => _count--);
      } else {
        _deleting = false;
        _phrase = (_phrase + 1) % widget.phrases.length;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When motion is reduced, show the first phrase in full (no cursor churn).
    if (reduceMotion) {
      final full = widget.phrases.isEmpty ? '' : widget.phrases.first;
      return Semantics(
        liveRegion: true,
        child: Text(full, style: widget.style),
      );
    }
    final text = widget.phrases.isEmpty
        ? ''
        : widget.phrases[_phrase].substring(0, _count);
    return Semantics(
      liveRegion: true,
      child: Text('$text${widget.cursor}', style: widget.style),
    );
  }
}
