import 'dart:async';

import 'package:flutter/widgets.dart';

/// Cycles through [words], animating each in with a fade + slide — a classic
/// hero-headline word carousel (e.g. "Build.", "Ship.", "Scale.").
///
/// ```dart
/// FxRotatingWords(words: const ['Build', 'Ship', 'Scale']);
/// ```
class FxRotatingWords extends StatefulWidget {
  const FxRotatingWords({
    super.key,
    required this.words,
    this.style,
    this.interval = const Duration(milliseconds: 2000),
    this.transitionDuration = const Duration(milliseconds: 400),
  });

  final List<String> words;
  final TextStyle? style;
  final Duration interval;
  final Duration transitionDuration;

  @override
  State<FxRotatingWords> createState() => _FxRotatingWordsState();
}

class _FxRotatingWordsState extends State<FxRotatingWords> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    if (widget.words.length <= 1) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % widget.words.length);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FxRotatingWords oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.words != widget.words ||
        oldWidget.interval != widget.interval) {
      _index = 0;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        widget.words.isEmpty ? '' : widget.words[_index],
        key: ValueKey(_index),
        style: widget.style,
      ),
    );
  }
}
