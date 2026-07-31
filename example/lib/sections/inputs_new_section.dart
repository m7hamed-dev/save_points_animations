part of '../home_screen.dart';

extension _InputsNewSection on _HomeScreenState {
  List<Widget> inputsNew(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      Text('Compare · Keypad · Reactions', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      const FxImageCompare(
        height: 160,
        before: ColoredBox(color: Color(0xFF37474F)),
        after: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8A65), Color(0xFFFFD54F)],
            ),
          ),
          child: Center(
            child: Text(
              'AFTER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: FxReactionBar(
          reactions: const ['👍', '❤️', '😂', '😮', '😢'],
          labels: const ['Like', 'Love', 'Haha', 'Wow', 'Sad'],
          selected: _reaction,
          onChanged: (i) => update(() => _reaction = i),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          _pinEntry.isEmpty ? '— — — —' : _pinEntry,
          style: const TextStyle(fontSize: 24, letterSpacing: 6),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: FxNumberPad(
          onDigit: (d) => update(() {
            if (_pinEntry.length < 4) _pinEntry += '$d';
          }),
          onBackspace: () => update(() {
            if (_pinEntry.isNotEmpty) {
              _pinEntry = _pinEntry.substring(0, _pinEntry.length - 1);
            }
          }),
        ),
      ),

      const SizedBox(height: 32),
      Text('Carousel · Range · Waveform', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      FxCarousel(
        height: 160,
        onPageChanged: (i) => update(() => _carousel = i),
        children: [
          for (final c in [
            Colors.pink,
            Colors.teal,
            Colors.indigo,
            Colors.orange,
          ])
            DecoratedBox(
              decoration: BoxDecoration(color: c, borderRadius: .circular(20)),
            ),
        ],
      ),
      const SizedBox(height: 10),
      Center(child: FxCarouselDots(count: 4, page: _carousel)),
      const SizedBox(height: 16),
      FxRangeSlider(values: _range, onChanged: (v) => update(() => _range = v)),
      const SizedBox(height: 8),
      Text(
        'Range: ${(_range.start * 100).round()}–'
        '${(_range.end * 100).round()}',
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          FxWaveform(playing: _playing, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => update(() => _playing = !_playing),
            child: Text(_playing ? 'Pause' : 'Play'),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text('Sliders · Steppers · Toasts', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      FxAnimatedSlider(
        value: _slider,
        onChanged: (v) => update(() => _slider = v),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quantity'),
          FxStepper(
            value: _qty,
            onChanged: (v) => update(() => _qty = v),
            max: 10,
          ),
          OutlinedButton(
            onPressed: () => update(() => _toast = !_toast),
            child: Text(_toast ? 'Hide toast' : 'Show toast'),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text(
        'New: Mesh · Glow · WaveDots · .pop()',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      // Animated mesh-gradient backdrop.
      ClipRRect(
        borderRadius: .circular(16),
        child: const SizedBox(
          height: 120,
          width: double.infinity,
          child: FxMeshGradient(
            child: Center(
              child: Text(
                'Mesh gradient',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Glowing button + traveling-wave dots loader.
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FxGlowButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Glow tapped'),
                duration: Duration(seconds: 1),
              ),
            ),
            child: const Text('Get Pro'),
          ),
          const FxWaveDots(),
        ],
      ),
      const SizedBox(height: 16),
      // `.pop()` entrance, staggered across a row of chips.
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            const DemoChip(
              color: Colors.deepPurple,
            ).animate().pop().delay((i * 140).ms),
          ],
        ],
      ),

      const SizedBox(height: 32),
      Text(
        'New: Plasma · ShinyText · Ball · RippleGrid · .blink()',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      // Turbulent plasma field with shiny text laid over it.
      ClipRRect(
        borderRadius: .circular(16),
        child: const SizedBox(
          height: 120,
          width: double.infinity,
          child: FxPlasma(
            child: Center(
              child: FxShinyText(
                'PREMIUM',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Squash-and-stretch loader.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxBouncingBall(color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              const Text('Loading'),
            ],
          ),
          // A blinking "LIVE" indicator via the .blink() effect.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fiber_manual_record,
                color: Colors.red,
                size: 14,
              ).animate().blink(count: 1).duration(1200.ms).looping(),
              const SizedBox(width: 6),
              const Text('LIVE'),
            ],
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Tap anywhere on the grid to send a ripple.
      ClipRRect(
        borderRadius: .circular(16),
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: FxRippleGrid(color: theme.colorScheme.primary),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Tap the grid ↑',
        style: theme.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 32),
      Text(
        'New: Rain · Jelly · Heartbeat · DNA · .sheen()',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      // Rain over a dark scene, with a .sheen() streak on the card.
      ClipRRect(
        borderRadius: .circular(16),
        child: const SizedBox(
          height: 120,
          width: double.infinity,
          child: FxRain(
            child: ColoredBox(
              color: Color(0xFF10131A),
              child: Center(
                child: Text(
                  'Rainy night',
                  style: TextStyle(
                    color: Color(0xFFAECBFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FxJellyButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Boing!'),
                duration: Duration(seconds: 1),
              ),
            ),
            child: const Text('Squish me'),
          ),
          const FxDnaLoader(),
        ],
      ),
      const SizedBox(height: 16),
      // ECG heartbeat line.
      SizedBox(
        height: 60,
        child: FxHeartbeatLine(color: theme.colorScheme.error),
      ),
      const SizedBox(height: 16),
      // One-shot specular sheen sweeping across a card (looped here).
      const Card(
        child: ListTile(
          leading: Icon(Icons.workspace_premium),
          title: Text('Sheen sweep'),
          subtitle: Text('.sheen() diagonal highlight'),
        ),
      ).animate().sheen(bandWidth: 0.15).duration(1600.ms).looping(),

      const SizedBox(height: 48),
    ];
  }
}
