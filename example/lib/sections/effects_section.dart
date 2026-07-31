part of '../home_screen.dart';

extension _EffectsSection on _HomeScreenState {
  List<Widget> effects(BuildContext context) {
    final theme = Theme.of(context);
    return [
      // 1. Headline: several effects composed in parallel.
      Text(
        'Compose effects fluently',
        style: theme.textTheme.headlineSmall,
      ).animate().fade().moveY(24).blur(begin: 6).duration(700.ms),

      const SizedBox(height: 24),

      // 2. Sequential timeline with .then().
      const DemoChip(color: Colors.pink)
          .animate()
          .fade()
          .scale(begin: 0.6)
          .then(120.ms)
          .rotate(-20)
          .then()
          .shake(),

      const SizedBox(height: 24),

      // 3. Imperatively-controlled card.
      const Card(
        child: ListTile(
          leading: Icon(Icons.bolt),
          title: Text('Tap the FAB to replay me'),
          subtitle: Text('Driven by an FxController'),
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
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
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
          const DemoChip(
            color: Colors.teal,
          ).animate().scale().spring(stiffness: 320, damping: 14),
          const SizedBox(width: 16),
          const DemoChip(color: Colors.orange).animate().moveY(-120).gravity(),
          const SizedBox(width: 16),
          // Debug overlay (debug builds only): FPS + frame bars + count.
          const DemoChip(
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
                borderRadius: .circular(12),
              ),
            ).heroAnimate('detail-hero'),
            title: const Text('Open detail'),
            subtitle: const Text('shared-axis transition + Hero'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (!mounted) return;

              context.fxPush<void>(
                const DetailScreen(),
                transition: FxPageTransition.sharedAxisHorizontal,
              );
            },
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
              FxPageTransition.fadeUpwards,
              FxPageTransition.flip,
              FxPageTransition.flipVertical,
              FxPageTransition.shrink,
            ])
              ActionChip(
                label: Text(t.name),
                onPressed: () =>
                    context.fxPush<void>(const DetailScreen(), transition: t),
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
                final box = key.currentContext!.findRenderObject() as RenderBox;
                final rect = box.localToGlobal(Offset.zero) & box.size;
                context.fxPushFrom<void>(const DetailScreen(), rect);
              },
            ),
          );
        },
      ),

      const SizedBox(height: 8),

      // Spring-driven route: timing governed by a real SpringSimulation.
      Builder(
        builder: (context) => OutlinedButton.icon(
          onPressed: () => context.fxPushSpring<void>(
            const DetailScreen(),
            stiffness: 220,
            damping: 18,
          ),
          icon: const Icon(Icons.waves),
          label: const Text('Spring transition'),
        ),
      ),
    ];
  }
}
