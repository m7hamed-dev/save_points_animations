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
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _showBanner = true;
  int _rating = 3;
  double _progress = 0.4;
  int _score = 1234;
  int _segment = 0;
  bool _menuOpen = false;
  bool _toggle = true;
  int _step = 1;
  bool _liked = false;
  FxButtonState _btnState = FxButtonState.idle;
  int _navIndex = 0;
  bool _checked = true;

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
        controller: _scrollController,
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
          Text(
            'Checkbox · Timeline · DotGrid',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              FxAnimatedCheckbox(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v),
              ),
              const SizedBox(width: 12),
              const Text('Animated checkbox'),
            ],
          ),
          const SizedBox(height: 12),
          const FxTimeline(
            items: [
              Text('Order placed'),
              Text('Shipped'),
              Text('Out for delivery'),
              Text('Delivered'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: FxDotGrid(
                child: Center(
                  child: Text('Dot grid', style: theme.textTheme.titleLarge),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'CircularMenu · TiltGlare · NavBar',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxCircularMenu(
                size: 48,
                icon: const Icon(Icons.add, color: Colors.white),
                children: [
                  for (final ic in const [Icons.share, Icons.edit, Icons.star])
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x22000000), blurRadius: 6),
                        ],
                      ),
                      child: Icon(ic, size: 20, color: Colors.indigo),
                    ),
                ],
              ),
              FxTiltGlareCard(
                child: Container(
                  width: 120,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Tilt me',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FxAnimatedNavBar(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              items: const [
                Icon(Icons.home),
                Icon(Icons.search),
                Icon(Icons.favorite),
                Icon(Icons.person),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Gauge · Scratch · Parallax',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxGauge(
                value: _progress,
                size: 110,
                child: Text('${(_progress * 100).round()}%'),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 130,
                  height: 80,
                  child: FxScratchCard(
                    child: ColoredBox(
                      color: theme.colorScheme.primaryContainer,
                      child: const Center(child: Text('You won! 🎁')),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: FxParallaxLayers(
                layers: [
                  FxParallaxLayer(
                    depth: 0.3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const FxParallaxLayer(
                    depth: 1.4,
                    child: Center(
                      child: Text(
                        'Move me',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'BorderBeam · Spotlight · ScrollBar',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxBorderBeam(
                child: Container(
                  width: 110,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('New'),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 110,
                  height: 64,
                  child: FxSpotlight(
                    child: ColoredBox(color: Color(0xFF1A1A2E)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Reading progress for this whole list.
          FxScrollProgress(controller: _scrollController),

          const SizedBox(height: 32),
          Text(
            'RotatingWords · FlipClock · ColorCycle',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text('We ', style: theme.textTheme.headlineSmall),
              FxRotatingWords(
                words: const ['Build', 'Ship', 'Scale'],
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const FxFlipClock(value: '12:45'),
              FxColorCycle(
                colors: const [Colors.red, Colors.orange, Colors.purple],
                builder: (context, color) => Text(
                  'Rainbow',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text('Slide · Progress · Swipe', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          FxSlideToConfirm(
            label: const Text('Slide to confirm'),
            onConfirmed: () {},
          ),
          const SizedBox(height: 12),
          FxProgressButton(
            state: _btnState,
            child: const Text('Submit'),
            onPressed: () async {
              setState(() => _btnState = FxButtonState.loading);
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              setState(() => _btnState = FxButtonState.success);
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              setState(() => _btnState = FxButtonState.idle);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: FxSwipeCards(
              cards: [
                for (final c in [Colors.pink, Colors.teal, Colors.amber])
                  Card(
                    color: c.withValues(alpha: 0.85),
                    child: const Center(
                      child: Text(
                        'Swipe me',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text('Heart · Neon · CTA', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: FxNeonText(
                'NEON',
                color: const Color(0xFFFF3CAC),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxHeartButton(
                isLiked: _liked,
                size: 36,
                onChanged: (v) => setState(() => _liked = v),
              ),
              FxShimmerButton(
                onPressed: () {},
                child: const Text('Get started'),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Steps · Toggle · Countdown',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          FxStepProgress(count: 4, currentStep: _step),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _step = (_step + 1) % 4),
                child: const Text('Next step'),
              ),
              FxAnimatedToggle(
                value: _toggle,
                onChanged: (v) => setState(() => _toggle = v),
              ),
              const FxCircularCountdown(duration: Duration(seconds: 20)),
            ],
          ),

          const SizedBox(height: 32),
          Text('MorphIcon · Ripple · Wave', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            children: [
              FxMorphIcon(
                isOpen: _menuOpen,
                size: 32,
                onTap: () => setState(() => _menuOpen = !_menuOpen),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FxRipple(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Tap for ripples'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const FxWaveDivider(),
          ),

          const SizedBox(height: 32),
          Text('Aurora · Radar · Blob', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Aurora background.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              height: 110,
              width: double.infinity,
              child: FxAurora(
                child: Center(
                  child: Text(
                    'Aurora',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const FxRadar(size: 120),
              FxBlob(
                color: theme.colorScheme.primary,
                child: const Icon(Icons.star, color: Colors.white, size: 32),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text('KenBurns · Glitch · Shine', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Ken Burns zoom/pan over a gradient "image".
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 110,
              child: FxKenBurns(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo, Colors.pink.shade300],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Ken Burns',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxGlitch(
                child: Text('GLITCH', style: theme.textTheme.headlineSmall),
              ),
              FxShine(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Shine',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Odometer · Segments · Particles',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              FxOdometer(value: _score),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => setState(() => _score += 111),
                child: const Text('+111'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          FxSegmentedControl(
            segments: const ['Day', 'Week', 'Month'],
            selectedIndex: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 90,
              child: FxParticles(
                color: const Color(0x66FFFFFF),
                child: const ColoredBox(
                  color: Color(0xFF283593),
                  child: Center(
                    child: Text(
                      'Ambient particles',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Gradient border · Wave · Typing',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FxGradientBorder(
                borderRadius: 16,
                child: Container(
                  width: 90,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text('AI'),
                ),
              ),
              const FxWaveProgress(
                value: 0.65,
                size: 84,
                child: Text(
                  '65%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const FxTypingIndicator(),
            ],
          ),

          const SizedBox(height: 32),
          Text('Flip · SpeedDial · Check', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 96,
                height: 72,
                child: FxFlipCard(
                  front: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: const Center(child: Text('Tap')),
                  ),
                  back: Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: const Center(child: Text('👋')),
                  ),
                ),
              ),
              const FxAnimatedCheck(size: 64),
              FxSpeedDial(
                size: 48,
                icon: const Icon(Icons.add, color: Colors.white),
                children: [
                  for (final ic in const [
                    Icons.share,
                    Icons.edit,
                    Icons.delete,
                  ])
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x22000000), blurRadius: 6),
                        ],
                      ),
                      child: Icon(ic, size: 20, color: Colors.indigo),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Rating · Expandable · Progress',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          FxRating(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FxExpandable(
                header: Text(
                  'What is this?',
                  style: theme.textTheme.titleMedium,
                ),
                body: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'An animated accordion — the body expands and the chevron '
                    'rotates. Tap the header to toggle.',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: FxProgressBar(value: _progress)),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(
                  () => _progress = (_progress + 0.2).clamp(0.0, 1.0),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const FxProgressBar(), // indeterminate

          const SizedBox(height: 32),
          Text('Badge · Pulse · Dots', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Count badge that pops when tapped (increments via FAB replay).
              const Icon(Icons.notifications, size: 36).badge(3),
              // Sonar pulse behind a live dot.
              const FxPulse(
                color: Color(0xFF43A047),
                child: Icon(Icons.circle, size: 14, color: Color(0xFF43A047)),
              ),
              // Animated page dots.
              FxPageIndicator(controller: _pageController, count: 4),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: PageView(
              controller: _pageController,
              children: [
                for (final c in [
                  Colors.pink,
                  Colors.teal,
                  Colors.orange,
                  Colors.indigo,
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Marquee · Swipe · Countdown',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Scrolling ticker.
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: FxMarquee(
                child: Text(
                  'Breaking:  save_points_animations now ships marquees, '
                  'swipe-to-dismiss, and countdowns   •   ',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Swipe to dismiss.
          FxSwipeToDismiss(
            onDismissed: () {},
            child: Card(
              color: theme.colorScheme.errorContainer,
              child: const ListTile(
                leading: Icon(Icons.swipe),
                title: Text('Swipe me away'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Countdown.
          Row(
            children: [
              Text('Launch in ', style: theme.textTheme.titleMedium),
              FxCountdown(
                duration: const Duration(seconds: 30),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text('s', style: theme.textTheme.titleMedium),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Switcher · Skeleton · Gradient',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Animated content swap (tap the FAB counter to see it switch).
          FxSwitcher(
            child: Text(
              'count: ${_card.value.toStringAsFixed(2)}',
              key: ValueKey(_showBanner),
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),

          // Shimmer skeleton placeholders for a loading card.
          Row(
            children: [
              FxSkeleton.circle(size: 48),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxSkeleton(width: 180),
                    SizedBox(height: 8),
                    FxSkeleton(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Living animated gradient background.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FxAnimatedGradient(
              colors: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
              child: const SizedBox(
                height: 80,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Animated gradient',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
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
