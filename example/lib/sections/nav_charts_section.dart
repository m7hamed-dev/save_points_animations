part of '../home_screen.dart';

extension _NavChartsSection on _HomeScreenState {
  List<Widget> navCharts(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      Text(
        'CircularMenu · TiltGlare · NavBar',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: .spaceEvenly,
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
                borderRadius: .circular(14),
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
        borderRadius: .circular(16),
        child: FxAnimatedNavBar(
          currentIndex: _navIndex,
          onTap: (i) => update(() => _navIndex = i),
          items: const [
            Icon(Icons.home),
            Icon(Icons.search),
            Icon(Icons.favorite),
            Icon(Icons.person),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // Curved nav bar (floating icon over a sliding notch).
      FxCurvedNavBar(
        currentIndex: _navIndex,
        onTap: (i) => update(() => _navIndex = i),
        items: _navItems,
      ),
      const SizedBox(height: 12),
      FxDotNavBar(
        currentIndex: _navIndex,
        onTap: (i) => update(() => _navIndex = i),
        items: _navItems,
      ),
      const SizedBox(height: 12),
      FxGooeyNavBar(
        currentIndex: _navIndex,
        onTap: (i) => update(() => _navIndex = i),
        items: _navItems,
      ),
      const SizedBox(height: 12),
      // Frosted bar floats over content — shown over a gradient.
      ClipRRect(
        borderRadius: .circular(32),
        child: Stack(
          children: [
            Container(
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
              ),
            ),
            FxFrostedNavBar(
              currentIndex: _navIndex,
              onTap: (i) => update(() => _navIndex = i),
              items: _navItems,
            ),
          ],
        ),
      ),

      const SizedBox(height: 32),
      Text('Gauge · Scratch · Parallax', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxGauge(
            value: _progress,
            size: 110,
            child: Text('${(_progress * 100).round()}%'),
          ),
          ClipRRect(
            borderRadius: .circular(12),
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
                    borderRadius: .circular(16),
                  ),
                ),
              ),
              const FxParallaxLayer(
                depth: 1.4,
                child: Center(
                  child: Text(
                    'Move me',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxBorderBeam(
            child: Container(
              width: 110,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: .circular(14),
              ),
              child: const Text('New'),
            ),
          ),
          ClipRRect(
            borderRadius: .circular(14),
            child: const SizedBox(
              width: 110,
              height: 64,
              child: FxSpotlight(child: ColoredBox(color: Color(0xFF1A1A2E))),
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
        mainAxisAlignment: .spaceEvenly,
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
    ];
  }
}
