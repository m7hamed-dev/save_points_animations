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
      // Global animation defaults for every `.animate()` below.
      home: const FxTheme(
        duration: Duration(milliseconds: 500),
        curve: FxCurves.snappy,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save Points Animations',
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
          ).animateList().fade().slideX(0.5).interval(90.ms).build(),

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
            ],
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
