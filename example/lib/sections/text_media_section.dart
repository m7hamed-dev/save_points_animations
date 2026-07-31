part of '../home_screen.dart';

extension _TextMediaSection on _HomeScreenState {
  List<Widget> textMedia(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      Text('Loading · Text · Color', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      // Shimmer skeleton placeholder.
      Container(
        height: 20,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: .circular(6),
        ),
      ).animate().shimmer().looping(),

      const SizedBox(height: 16),

      // Typewriter text.
      'Typing character by character…'.typewriter(
        cursor: '|',
        style: theme.textTheme.titleMedium,
      ),

      const SizedBox(height: 16),

      // Per-character stagger + an animated counter.
      'Staggered'.animateChars(style: theme.textTheme.headlineSmall),
      const SizedBox(height: 8),
      Row(
        children: [
          Text('Downloads: ', style: theme.textTheme.titleMedium),
          (12840).countUp(
            duration: 1200.ms,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // Grayscale → color reveal.
      Row(
        children: [
          const DemoChip(
            color: Colors.pink,
          ).animate().saturate().duration(1500.ms),
          const SizedBox(width: 16),
          // Continuous hue cycle.
          const DemoChip(color: Colors.green).animate().hueShift().looping(),
        ],
      ),

      const SizedBox(height: 32),
      Text('Widgets as extensions', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      // Decorate any widget inline with `.fx…()` methods.
      Row(
        children: [
          Expanded(
            child: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('.fxShine()')),
              ),
            ).fxShine(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('.fxGradientBorder()')),
            ).fxGradientBorder(),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Backdrop effect: content layered on top of an aurora.
      ClipRRect(
        borderRadius: .circular(16),
        child: const SizedBox(
          height: 90,
          child: Center(
            child: Text(
              'content.fxAurora()',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).fxAurora(),
      ),

      const SizedBox(height: 32),
      Text('Reveal · Loaders · FX', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      // Circular reveal + loaders row.
      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          const FxDotsLoader(),
          const FxBarsLoader(color: Colors.pink),
          const FxProgressRing(color: Colors.teal),
          const Icon(
            Icons.star,
            size: 40,
            color: Colors.amber,
          ).animate().circularReveal().duration(900.ms),
        ],
      ),

      const SizedBox(height: 16),

      // Text FX.
      'Gradient headline'.gradientText(style: theme.textTheme.headlineSmall),
      const SizedBox(height: 8),
      'wavy text ~'.wavyText(style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      'DECODING'.scrambleText(style: theme.textTheme.titleMedium),

      const SizedBox(height: 16),

      // Confetti + 3D tilt.
      Row(
        children: [
          FxConfetti(
            controller: _confetti,
            child: FilledButton.icon(
              onPressed: _confetti.play,
              icon: const Icon(Icons.celebration),
              label: const Text('Celebrate'),
            ),
          ),
          const SizedBox(width: 16),
          const Card(
            child: SizedBox(
              width: 90,
              height: 60,
              child: Center(child: Text('tilt me')),
            ),
          ).tilt(),
        ],
      ),

      const SizedBox(height: 32),
      Text('Exit / dismiss', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      OutlinedButton.icon(
        onPressed: () => update(() => _showBanner = !_showBanner),
        icon: Icon(_showBanner ? Icons.visibility_off : Icons.visibility),
        label: Text(_showBanner ? 'Dismiss banner' : 'Show banner'),
      ),
      const SizedBox(height: 8),
      FxAnimatedVisibility(
        visible: _showBanner,
        // Same chain plays forward on show, reversed on dismiss.
        effects: (a) =>
            a.fade().scale(begin: 0.9).slideY(-0.2).duration(300.ms),
        child: Card(
          color: theme.colorScheme.tertiaryContainer,
          child: const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('I animate out before I leave'),
          ),
        ),
      ),

      const SizedBox(height: 32),
      Text('Interactive', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      // 5. Gesture animations: press & hover.
      Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {},
              child: const Text('pressScale'),
            ).pressScale(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.tonal(
              onPressed: () {},
              child: const Text('pressBounce'),
            ).pressBounce(),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(Icons.mouse),
          title: Text('hoverScale me (desktop/web)'),
        ),
      ).hoverScale(),

      const SizedBox(height: 12),

      // 6. Trigger: replay a tada on tap.
      Card(
        color: theme.colorScheme.primaryContainer,
        child: const ListTile(
          leading: Icon(Icons.touch_app),
          title: Text('Tap me to celebrate'),
        ),
      ).animate(autoPlay: false).tada().duration(700.ms).onTap(),

      const SizedBox(height: 12),

      // 7. Trigger: animate on scroll into view.
      ...List.generate(
        8,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.visibility),
              title: Text('Reveals on scroll #$i'),
            ),
          ).animate(autoPlay: false).fadeIn().slideX(0.1).onVisible(),
        ),
      ),

      const SizedBox(height: 32),
      Text(
        'StarField · Bubbles · SpinWheel',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          ClipRRect(
            borderRadius: .circular(12),
            child: const SizedBox(
              width: 120,
              height: 110,
              child: FxStarField(child: ColoredBox(color: Color(0xFF05060E))),
            ),
          ),
          ClipRRect(
            borderRadius: .circular(12),
            child: const SizedBox(
              width: 120,
              height: 110,
              child: FxBubbles(
                color: Color(0x552575FC),
                child: ColoredBox(color: Color(0xFFE3F2FD)),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Center(
        child: Column(
          children: [
            FxSpinWheel(
              size: 180,
              controller: _wheel,
              items: const ['10', '20', '50', '5', '100', '0'],
              colors: const [
                Colors.pink,
                Colors.teal,
                Colors.amber,
                Colors.indigo,
                Colors.green,
                Colors.orange,
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _wheel.spin, child: const Text('Spin!')),
          ],
        ),
      ),

      const SizedBox(height: 32),
      Text('Pie · Fireworks · Tags', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          const FxPieChart(
            values: [5, 3, 2, 4],
            colors: [Colors.pink, Colors.teal, Colors.amber, Colors.indigo],
          ),
          ClipRRect(
            borderRadius: .circular(12),
            child: const SizedBox(
              width: 140,
              height: 120,
              child: FxFireworks(child: ColoredBox(color: Color(0xFF0D0D18))),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      FxTagChips(
        tags: const ['All', 'Design', 'Code', 'Motion'],
        selected: _chips,
        onToggle: (i) => update(() {
          _chips.contains(i) ? _chips.remove(i) : _chips.add(i);
        }),
      ),

      const SizedBox(height: 32),
      Text(
        'Sparkline · BarChart · TypeLoop',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      const FxSparkline(values: [3, 5, 4, 8, 6, 9, 7, 10, 8]),
      const SizedBox(height: 12),
      const FxBarChart(values: [4, 7, 3, 9, 6, 8], height: 90),
      const SizedBox(height: 12),
      Row(
        children: [
          Text('It is ', style: theme.textTheme.titleMedium),
          FxTypeLoop(
            phrases: const ['fast.', 'fluid.', 'fun.'],
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text('Orbit · Snow · CircularText', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          const FxOrbitLoader(),
          ClipRRect(
            borderRadius: .circular(12),
            child: const SizedBox(
              width: 120,
              height: 80,
              child: FxSnow(child: ColoredBox(color: Color(0xFF1B2A4A))),
            ),
          ),
          FxCircularText(
            '• SAVE POINTS ',
            radius: 32,
            style: theme.textTheme.labelLarge!.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ];
  }
}
