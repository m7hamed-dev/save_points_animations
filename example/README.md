# save_points_animations example

A small, complete app showing the main ideas: an entrance chain, a sequence
replayed through a controller, a state-driven animation, a staggered list and
a ready-made widget.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() => runApp(const MaterialApp(home: DemoPage()));

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _logo = FxController();
  var _liked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            // Effects in one chain run together, on one controller.
            const Text('Hello', style: TextStyle(fontSize: 32))
                .animate(duration: 600.ms, curve: FxCurves.snappy)
                .fade()
                .moveY(30)
                .scale(begin: 0.8),

            // .then() waits for the effects before it; the controller
            // replays the whole chain.
            const FlutterLogo(size: 64)
                .animate(controller: _logo)
                .scale(begin: 0.6)
                .then()
                .shake(),

            // State-driven: animates whenever `target` changes.
            const Icon(Icons.star, size: 48)
                .animate(target: _liked ? 1 : 0, duration: 200.ms)
                .scale(end: 1.3)
                .tint(Colors.amber),

            // A staggered list: item i starts 80ms × i after the first.
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                for (var i = 0; i < 5; i++)
                  Container(width: 24, height: 24, color: Colors.indigo),
              ].animateList().fade().slideY(0.5).interval(80.ms).build(),
            ),

            // A ready-made widget from the catalog.
            FxHeartButton(
              isLiked: _liked,
              onChanged: (liked) => setState(() => _liked = liked),
            ),

            FxGradientButton(
              onPressed: () => _logo.restart(),
              child: const Text('Replay the logo'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Every effect jumps to its end frame when the OS "reduce motion" setting is
on, so try it with that setting off.

## The full demo app

[`lib/main.dart`](lib/main.dart) is a tour of the whole package:

- **Home screen:** effects, text and media, controls, navigation bars and
  charts, inputs and the rest of the widget catalog, each section a live demo.
- **Playground:** pick effects, timing, direction and play mode, watch the
  result, and copy the chain that produces it.
- **Detail screen:** opened with `context.fxPush`, to try the page
  transitions and Hero flights.

Run it on any platform:

```bash
cd example
flutter run
```

The demo uses `package:material_ui` for its app shell. The animation package
itself builds only on `package:flutter/widgets.dart`.
