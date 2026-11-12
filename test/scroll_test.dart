import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _scrollHost(List<Widget> children) => MaterialApp(
  home: Scaffold(
    body: SizedBox(
      height: 600,
      // Non-lazy so off-screen items still build (deterministic for tests).
      child: SingleChildScrollView(child: Column(children: children)),
    ),
  ),
);

void main() {
  group('FxScrollLinked', () {
    testWidgets('an item far below the fold starts hidden, reveals on scroll', (
      tester,
    ) async {
      final target = const Text(
        'reveal-me',
      ).animateOnScroll(const [FadeEffect()]);

      await tester.pumpWidget(
        _scrollHost([
          // Push the target well below the viewport.
          const SizedBox(height: 1200),
          target,
          const SizedBox(height: 1200),
        ]),
      );
      await tester.pump();

      // Off-screen (below): fully transparent -> an Opacity(0) wrapper exists.
      expect(find.byType(Opacity), findsWidgets);
      final before = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .reduce((a, b) => a < b ? a : b);
      expect(before, lessThan(0.5));

      // Scroll it up into view.
      await tester.drag(find.byType(Scrollable), const Offset(0, -1100));
      await tester.pumpAndSettle();

      expect(find.text('reveal-me'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps its child State while the reveal completes', (
      tester,
    ) async {
      _MountCounter.mounts = 0;
      await tester.pumpWidget(
        _scrollHost([
          const SizedBox(height: 1200),
          const _MountCounter().animateOnScroll(const [FadeEffect()]),
          const SizedBox(height: 1200),
        ]),
      );
      await tester.pump();

      // Fully reveal it: the Opacity wrapper is dropped at progress 1.
      await tester.drag(find.byType(Scrollable), const Offset(0, -1100));
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.byType(_MountCounter),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(_MountCounter.mounts, 1);
    });
  });

  group('FxParallax', () {
    testWidgets('translates its child as the list scrolls', (tester) async {
      await tester.pumpWidget(
        _scrollHost([
          const SizedBox(height: 800),
          const SizedBox(height: 100, child: Text('bg')).parallax(amount: 60),
          const SizedBox(height: 800),
        ]),
      );
      await tester.pump();

      double translationY() => tester
          .widget<Transform>(
            find
                .ancestor(of: find.text('bg'), matching: find.byType(Transform))
                .first,
          )
          .transform
          .getTranslation()
          .y;

      final initial = translationY();
      await tester.drag(find.byType(Scrollable), const Offset(0, -300));
      await tester.pump();
      // The parallax offset changed as the item moved through the viewport.
      expect(translationY(), isNot(closeTo(initial, 0.5)));
      expect(tester.takeException(), isNull);
    });
  });
}

/// Counts how many times its State is created (i.e. how often it is mounted).
class _MountCounter extends StatefulWidget {
  const _MountCounter();

  static int mounts = 0;

  @override
  State<_MountCounter> createState() => _MountCounterState();
}

class _MountCounterState extends State<_MountCounter> {
  @override
  void initState() {
    super.initState();
    _MountCounter.mounts++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 40, height: 40);
}
