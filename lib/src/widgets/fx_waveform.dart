import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// An animated audio-style bar visualizer. When [playing] is true the bars
/// bounce continuously (a lightweight equalizer); when paused they settle to a
/// low idle line. Purely decorative — no audio input required.
///
/// ```dart
/// FxWaveform(playing: isPlaying, color: Colors.pink);
/// ```
class FxWaveform extends StatefulWidget {
  const FxWaveform({
    super.key,
    this.playing = true,
    this.barCount = 5,
    this.color = const Color(0xFF448AFF),
    this.height = 40,
    this.barWidth = 5,
    this.spacing = 4,
    this.speed = 1,
  });

  final bool playing;
  final int barCount;
  final Color color;
  final double height;
  final double barWidth;
  final double spacing;
  final double speed;

  @override
  State<FxWaveform> createState() => _FxWaveformState();
}

class _FxWaveformState extends State<FxWaveform>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick)..start();
  double _t = 0;

  // A fixed phase + frequency per bar so the pattern looks organic, not synced.
  late final List<double> _phase = List.generate(
    widget.barCount,
    (i) => i * 0.7,
  );
  late final List<double> _freq = List.generate(
    widget.barCount,
    (i) => 2.2 + (i % 3) * 0.9,
  );

  void _onTick(Duration elapsed) {
    setState(() => _t = elapsed.inMicroseconds / 1e6 * widget.speed);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.barCount; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              _bar(i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bar(int i) {
    final double level;
    if (widget.playing) {
      final wave = math.sin(_t * _freq[i] + _phase[i]);
      level = 0.2 + (wave * 0.5 + 0.5) * 0.8;
    } else {
      level = 0.14;
    }
    final barHeight = (widget.height * level).clamp(
      widget.barWidth,
      widget.height,
    );
    return AnimatedContainer(
      duration: widget.playing
          ? const Duration(milliseconds: 90)
          : const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: widget.barWidth,
      height: barHeight,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: .circular(widget.barWidth),
      ),
    );
  }
}
