part of '../home_screen.dart';

extension _WidgetsGallerySection on _HomeScreenState {
  List<Widget> widgetsGallery(BuildContext context) {
    final theme = Theme.of(context);
    return [
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
          update(() => _btnState = FxButtonState.loading);
          await Future<void>.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          update(() => _btnState = FxButtonState.success);
          await Future<void>.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          update(() => _btnState = FxButtonState.idle);
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
          borderRadius: .circular(16),
        ),
        child: const Center(
          child: FxNeonText(
            'NEON',
            color: Color(0xFFFF3CAC),
            style: TextStyle(fontSize: 40),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxHeartButton(
            isLiked: _liked,
            size: 36,
            onChanged: (v) => update(() => _liked = v),
          ),
          FxShimmerButton(onPressed: () {}, child: const Text('Get started')),
        ],
      ),

      const SizedBox(height: 32),
      Text('Steps · Toggle · Countdown', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      FxStepProgress(count: 4, currentStep: _step),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          OutlinedButton(
            onPressed: () => update(() => _step = (_step + 1) % 4),
            child: const Text('Next step'),
          ),
          FxAnimatedToggle(
            value: _toggle,
            onChanged: (v) => update(() => _toggle = v),
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
            onTap: () => update(() => _menuOpen = !_menuOpen),
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
                  borderRadius: .circular(12),
                ),
                child: const Text('Tap for ripples'),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: .circular(12), child: const FxWaveDivider()),

      const SizedBox(height: 32),
      Text('Aurora · Radar · Blob', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      // Aurora background.
      ClipRRect(
        borderRadius: .circular(16),
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
        mainAxisAlignment: .spaceEvenly,
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
        borderRadius: .circular(16),
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
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxGlitch(child: Text('GLITCH', style: theme.textTheme.headlineSmall)),
          FxShine(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: .circular(12),
              ),
              child: const Text('Shine', style: TextStyle(color: Colors.white)),
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
            onPressed: () => update(() => _score += 111),
            child: const Text('+111'),
          ),
        ],
      ),
      const SizedBox(height: 12),

      FxSegmentedControl(
        segments: const ['Day', 'Week', 'Month'],
        selectedIndex: _segment,
        onChanged: (i) => update(() => _segment = i),
      ),
      const SizedBox(height: 12),

      ClipRRect(
        borderRadius: .circular(16),
        child: const SizedBox(
          height: 90,
          child: FxParticles(
            color: Color(0x66FFFFFF),
            child: ColoredBox(
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
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxGradientBorder(
            child: Container(
              width: 90,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: .circular(13),
              ),
              child: const Text('AI'),
            ),
          ),
          const FxWaveProgress(
            value: 0.65,
            size: 84,
            child: Text('65%', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const FxTypingIndicator(),
        ],
      ),
    ];
  }
}
