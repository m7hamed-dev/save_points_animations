import 'package:flutter/material.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Points Animations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Effects and page transitions are themed independently.
      home: const FxTheme(
        // Effects: snappy and a touch longer.
        duration: Duration(milliseconds: 500),
        curve: FxCurves.snappy,
        // Page transitions: Material 3 emphasized, slightly quicker.
        transitionCurve: FxCurves.emphasized,
        transitionDuration: Duration(milliseconds: 400),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FxController _card = FxController();
  final FxConfettiController _confetti = FxConfettiController();
  bool _showBanner = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save Points Animations V 1.0',
        ).animate().fade().slideY(-0.5).duration(400.ms),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _card.restart,
        label: const Text('Replay card'),
        icon: const Icon(Icons.refresh),
      ).animate().scale(begin: 0.0).curve(FxCurves.elastic),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. Headline: several effects composed in parallel.
          Text(
            'Compose effects fluently',
            style: theme.textTheme.headlineSmall,
          ).animate().fade().moveY(24).blur(begin: 6).duration(700.ms),

          const SizedBox(height: 24),

          // 2. Sequential timeline with .then().
          _Chip(color: Colors.pink)
              .animate()
              .fade()
              .scale(begin: 0.6)
              .then(120.ms)
              .rotate(-20)
              .then()
              .shake(),

          const SizedBox(height: 24),

          // 3. Imperatively-controlled card.
          Card(
            child: ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text('Tap the FAB to replay me'),
              subtitle: const Text('Driven by an FxController'),
            ),
          ).animate(controller: _card).fadeIn().scaleIn(begin: 0.9),

          const SizedBox(height: 24),

          // 4. Staggered list.
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                tileColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text('Staggered item #$i'),
              ),
            ),
          ).animateList().fade().slideX(0.2).interval(90.ms).build(),

          const SizedBox(height: 32),
          Text('Physics', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Spring-driven entrance (real SpringSimulation).
          Row(
            children: [
              _Chip(
                color: Colors.teal,
              ).animate().scale(begin: 0.0).spring(stiffness: 320, damping: 14),
              const SizedBox(width: 16),
              _Chip(color: Colors.orange).animate().moveY(-120).gravity(),
              const SizedBox(width: 16),
              // Debug overlay (debug builds only): FPS + frame bars + count.
              _Chip(
                color: Colors.blueGrey,
              ).animate().float().looping().showPerformance(),
            ],
          ),

          const SizedBox(height: 12),

          // Page transition + Hero.
          Builder(
            builder: (context) => Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).heroAnimate('detail-hero'),
                title: const Text('Open detail'),
                subtitle: const Text('shared-axis transition + Hero'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.fxPush(
                  const DetailScreen(),
                  transition: FxPageTransition.sharedAxisHorizontal,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Modern page transitions — tap a chip to preview.
          Builder(
            builder: (context) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in const [
                  FxPageTransition.fadeThrough,
                  FxPageTransition.cupertino,
                  FxPageTransition.depth,
                  FxPageTransition.sheet,
                  FxPageTransition.circularReveal,
                  FxPageTransition.cube3D,
                  FxPageTransition.blur,
                  FxPageTransition.glass,
                ])
                  ActionChip(
                    label: Text(t.name),
                    onPressed: () =>
                        context.fxPush(const DetailScreen(), transition: t),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Real container transform: the page grows from this card's bounds.
          Builder(
            builder: (context) {
              final key = GlobalKey();
              return Card(
                key: key,
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.open_in_full),
                  title: const Text('Expand this card'),
                  subtitle: const Text('container transform from its rect'),
                  onTap: () {
                    final box =
                        key.currentContext!.findRenderObject() as RenderBox;
                    final rect = box.localToGlobal(Offset.zero) & box.size;
                    context.fxPushFrom(const DetailScreen(), rect);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Spring-driven route: timing governed by a real SpringSimulation.
          Builder(
            builder: (context) => OutlinedButton.icon(
              onPressed: () => context.fxPushSpring(
                const DetailScreen(),
                stiffness: 220,
                damping: 18,
              ),
              icon: const Icon(Icons.waves),
              label: const Text('Spring transition'),
            ),
          ),

          const SizedBox(height: 32),
          Text('Loading · Text · Color', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Shimmer skeleton placeholder.
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
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
              _Chip(color: Colors.pink).animate().saturate().duration(1500.ms),
              const SizedBox(width: 16),
              // Continuous hue cycle.
              _Chip(color: Colors.green).animate().hueShift().looping(),
            ],
          ),

          const SizedBox(height: 32),
          Text('Reveal · Loaders · FX', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Circular reveal + loaders row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          'Gradient headline'.gradientText(
            style: theme.textTheme.headlineSmall,
          ),
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
              Card(
                child: const SizedBox(
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
            onPressed: () => setState(() => _showBanner = !_showBanner),
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
          Card(
            child: const ListTile(
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
          Text('Scroll-driven', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Parallax banner — moves as you scroll.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.purple.shade300],
                      ),
                    ),
                  ).parallax(amount: 40),
                  const Center(
                    child: Text(
                      'Parallax',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Scroll-linked reveal: progress driven by scroll position.
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child:
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.animation),
                      title: Text('Scroll-linked #$i'),
                    ),
                  ).animateOnScroll(const [
                    FadeEffect(),
                    SlideEffect(beginY: 0.2),
                    ScaleEffect(begin: 0.9),
                  ]),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Hero grows from the list tile's small square.
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(28),
              ),
            ).heroAnimate('detail-hero'),
            const SizedBox(height: 24),
            const Text(
              'Arrived via shared-axis',
            ).animate().fadeIn().slideY(0.3).duration(500.ms),
          ],
        ),
      ),
    );
  }
}
