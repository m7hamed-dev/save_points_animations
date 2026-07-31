part of '../home_screen.dart';

extension _MoreSection on _HomeScreenState {
  List<Widget> more(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      Text('Flip · SpeedDial · Check', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: .spaceEvenly,
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
          const FxAnimatedCheck(),
          FxSpeedDial(
            size: 48,
            icon: const Icon(Icons.add, color: Colors.white),
            children: [
              for (final ic in const [Icons.share, Icons.edit, Icons.delete])
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

      FxRating(value: _rating, onChanged: (v) => update(() => _rating = v)),
      const SizedBox(height: 12),

      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FxExpandable(
            header: Text('What is this?', style: theme.textTheme.titleMedium),
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
            onPressed: () =>
                update(() => _progress = (_progress + 0.2).clamp(0.0, 1.0)),
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
        mainAxisAlignment: .spaceEvenly,
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
                    borderRadius: .circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),

      const SizedBox(height: 32),
      Text('Marquee · Swipe · Countdown', style: theme.textTheme.titleMedium),
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
      const Row(
        children: [
          FxSkeleton.circle(size: 48),
          SizedBox(width: 12),
          Expanded(
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
        borderRadius: .circular(16),
        child: const FxAnimatedGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          child: SizedBox(
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
        borderRadius: .circular(16),
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
              ).parallax(),
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

      const SizedBox(height: 32),
      Text('Date strip · Color wheel', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      FxDateStrip(
        days: List.generate(14, (i) => _dayBase.add(Duration(days: i))),
        selected: _day,
        onChanged: (d) => update(() => _day = d),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          FxColorWheel(
            color: _wheelColor,
            size: 180,
            onChanged: (c) => update(() => _wheelColor = c),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 80,
              decoration: BoxDecoration(
                color: _wheelColor,
                borderRadius: .circular(16),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Draggable snapping sheet, shown inside a fixed-height stage.
      SizedBox(
        height: 260,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: .circular(16),
          ),
          child: Stack(
            children: [
              const Center(child: Text('Drag the sheet ↑')),
              FxDraggableSheet(
                snapSizes: const [0.25, 0.55, 0.9],
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    Text(
                      'Bottom sheet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Drag the handle to snap between sizes.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 32),
      Text(
        'Gradient button · Theme toggle',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxGradientButton(
            onPressed: () => update(() => _busy = true),
            child: const Text('Save'),
          ),
          FxThemeToggle(
            isDark: _dark,
            onChanged: (v) => update(() => _dark = v),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text('Wheel picker · Glass', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FxWheelPicker(
              items: const ['Low', 'Medium', 'High', 'Ultra', 'Max'],
              selectedIndex: _wheel2,
              onChanged: (i) => update(() => _wheel2 = i),
            ),
          ),
          const SizedBox(width: 12),
          // Glass card floats over a gradient so the blur reads.
          Expanded(
            child: SizedBox(
              height: 160,
              child: ClipRRect(
                borderRadius: .circular(20),
                child: const Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: FxGlassCard(
                        child: Center(
                          child: Text(
                            'Frosted\nglass',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text('Wizard · Field · Magnetic', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      FxWizardSteps(
        steps: const ['Cart', 'Address', 'Pay', 'Done'],
        currentStep: _wizard,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () => update(() => _wizard = (_wizard - 1).clamp(0, 3)),
            child: const Text('Back'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => update(() => _wizard = (_wizard + 1).clamp(0, 3)),
            child: const Text('Next'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const FxFloatingField(label: 'Email address'),
      const SizedBox(height: 20),
      Center(
        child: FxMagneticButton(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: .circular(30),
            ),
            child: const Text(
              'Hover / tap me',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
