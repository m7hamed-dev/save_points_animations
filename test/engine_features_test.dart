import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';
import 'package:save_points_animations/src/builders/fx_paint_composite.dart';

import 'support/fx_probe.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Directionality(
        textDirection: direction,
        child: Center(child: child),
      ),
    );

/// Mount [chain], start it, and advance [elapsed] into its timeline.
Future<void> _playTo(
  WidgetTester tester,
  Widget chain,
  Duration elapsed, {
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.pumpWidget(_host(chain, direction: direction));
  await tester.pump(); // the post-frame callback calls forward()
  await tester.pump(elapsed);
}

RenderFxPaintComposite _composite(WidgetTester tester, String text) =>
    fxCompositeOf(tester, find.text(text))!;

void main() {
  group('timing inheritance', () {
    testWidgets('.duration() carries forward to later effects', (tester) async {
      await _playTo(
        tester,
        const Text('x')
            .animate(curve: Curves.linear)
            .fade()
            .duration(const Duration(milliseconds: 600))
            .scale(),
        const Duration(milliseconds: 300),
      );
      // Halfway through 600ms for both — not 300 of the default 350ms.
      expect(fxPaintedOpacity(tester, find.text('x')), closeTo(0.5, 0.01));
      expect(
        _composite(tester, 'x').frame.transform.entry(0, 0),
        closeTo(0.5, 0.01),
      );
    });

    testWidgets('a preset is one group: .duration() times all its effects', (
      tester,
    ) async {
      await _playTo(
        tester,
        const Text('x')
            .animate(curve: Curves.linear)
            .fadeIn(from: 0.2)
            .duration(const Duration(seconds: 1)),
        const Duration(milliseconds: 500),
      );
      final frame = _composite(tester, 'x').frame;
      expect(frame.opacity, closeTo(0.5, 0.01));
      expect(frame.fractionalTranslation.dy, closeTo(0.1, 0.005));
    });

    testWidgets('animate(duration:) is the chain default', (tester) async {
      await _playTo(
        tester,
        const Text('x')
            .animate(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
            )
            .fade(),
        const Duration(milliseconds: 100),
      );
      expect(fxPaintedOpacity(tester, find.text('x')), closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 100));
      expect(fxPaintedOpacity(tester, find.text('x')), 1.0);
    });

    testWidgets('constructor timing stays local (elastic does not leak)', (
      tester,
    ) async {
      await _playTo(
        tester,
        const Text('x')
            .animate(
              duration: const Duration(milliseconds: 400),
              curve: Curves.linear,
            )
            .elastic()
            .fade(),
        const Duration(milliseconds: 200),
      );
      expect(fxPaintedOpacity(tester, find.text('x')), closeTo(0.5, 0.01));
    });

    testWidgets('animate(delay:) waits before the first play', (tester) async {
      await tester.pumpWidget(
        _host(
          const Text('x')
              .animate(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 100),
              )
              .fade(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(fxPaintedOpacity(tester, find.text('x')), 0.0);
      await tester.pump(const Duration(milliseconds: 100)); // timer fires
      await tester.pump(const Duration(milliseconds: 150));
      expect(fxPaintedOpacity(tester, find.text('x')), 1.0);
    });
  });

  group('target', () {
    testWidgets('renders at target and animates only when it changes', (
      tester,
    ) async {
      var completes = 0;
      Widget app(double target) => _host(
        const Text('x')
            .animate(
              target: target,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
              onComplete: () => completes++,
            )
            .fade(),
      );

      await tester.pumpWidget(app(0));
      await tester.pump(const Duration(milliseconds: 300));
      expect(fxPaintedOpacity(tester, find.text('x')), 0.0); // no autoplay

      await tester.pumpWidget(app(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(fxPaintedOpacity(tester, find.text('x')), closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 60));
      expect(fxPaintedOpacity(tester, find.text('x')), 1.0);
      expect(completes, 1);

      await tester.pumpWidget(app(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      expect(fxPaintedOpacity(tester, find.text('x')), 0.0);
      expect(completes, 1, reason: 'moving back is not a completion');
    });

    testWidgets('callbacks may call setState when the target changes', (
      tester,
    ) async {
      var selected = false;
      var plays = 0;
      var completes = 0;
      late StateSetter rebuild;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Text('$plays/$completes')
                  .animate(
                    target: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 100),
                    onPlay: () => setState(() => plays++),
                    onComplete: () => setState(() => completes++),
                  )
                  .fade();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0/0'), findsOneWidget);

      // The new target starts playback during build; the callbacks must not
      // run until the frame is done.
      rebuild(() => selected = true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('the initial target is not reported as playback', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          const Text('x')
              .animate(
                target: 1,
                onPlay: () => calls++,
                onComplete: () => calls++,
              )
              .fade(),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('starts at a non-zero target without animating', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Text('x').animate(target: 1).fade()));
      expect(fxPaintedOpacity(tester, find.text('x')), 1.0);
    });
  });

  group('callbacks and looping', () {
    testWidgets('onPlay and onComplete fire once for a one-shot chain', (
      tester,
    ) async {
      var plays = 0;
      var completes = 0;
      await _playTo(
        tester,
        const Text(
          'x',
        ).animate(onPlay: () => plays++, onComplete: () => completes++).fade(),
        const Duration(seconds: 1),
      );
      expect(plays, 1);
      expect(completes, 1);
    });

    testWidgets('looping(count:) stops after count cycles', (tester) async {
      var completes = 0;
      await _playTo(
        tester,
        const Text('x')
            .animate(
              duration: const Duration(milliseconds: 100),
              onComplete: () => completes++,
            )
            .fade()
            .looping(count: 2),
        const Duration(milliseconds: 150),
      );
      expect(completes, 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(completes, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('right-to-left', () {
    testWidgets('slideFromStart enters from the leading edge', (tester) async {
      Future<double> startX(TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(
            const Text('x').animate(autoPlay: false).slideFromStart(),
            direction: direction,
          ),
        );
        return _composite(tester, 'x').frame.fractionalTranslation.dx;
      }

      expect(await startX(TextDirection.ltr), lessThan(0));
      expect(await startX(TextDirection.rtl), greaterThan(0));
    });
  });

  group('paint-time path', () {
    testWidgets('paint-only chains build no Opacity/Transform widgets', (
      tester,
    ) async {
      await _playTo(
        tester,
        const Text('x').animate().fade().scale().moveY(20),
        const Duration(milliseconds: 100),
      );
      expect(fxCompositeOf(tester, find.text('x')), isNotNull);
      expect(find.byType(Opacity), findsNothing);
      expect(
        find.ancestor(of: find.text('x'), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('chains with a wrapping effect use the widget path', (
      tester,
    ) async {
      await _playTo(
        tester,
        const Text('x').animate().fade().blur(),
        const Duration(milliseconds: 100),
      );
      expect(fxCompositeOf(tester, find.text('x')), isNull);
      expect(find.byType(ImageFiltered), findsOneWidget);
    });

    testWidgets('hit testing follows the painted position', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(width: 50, height: 50),
          ).animate(autoPlay: false).moveX(200),
        ),
      );
      final painted = tester.getCenter(find.byType(SizedBox));
      expect(painted, const Offset(600, 300));
      await tester.tapAt(painted);
      expect(taps, 1);
      await tester.tapAt(const Offset(400, 300)); // the layout position
      expect(taps, 1);
    });
  });

  group('onVisible', () {
    testWidgets('once: false replays on every entry and reports exits', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var shown = 0;
      var hidden = 0;
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                const SizedBox(height: 1500, width: 10),
                const Text('t')
                    .animate(duration: const Duration(milliseconds: 100))
                    .fade()
                    .onVisible(
                      once: false,
                      onShown: () => shown++,
                      onHidden: () => hidden++,
                    ),
                const SizedBox(height: 1500, width: 10),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect((shown, hidden), (0, 0));
      expect(fxPaintedOpacity(tester, find.text('t')), 0.0);

      Future<void> jumpTo(double offset) async {
        controller.jumpTo(offset);
        await tester.pumpAndSettle();
      }

      await jumpTo(1300);
      expect((shown, hidden), (1, 0));
      expect(fxPaintedOpacity(tester, find.text('t')), 1.0);

      await jumpTo(0);
      expect((shown, hidden), (1, 1));
      expect(fxPaintedOpacity(tester, find.text('t')), 0.0, reason: 'rewound');

      await jumpTo(1300);
      expect((shown, hidden), (2, 1));
      expect(fxPaintedOpacity(tester, find.text('t')), 1.0);
    });
  });

  testWidgets('triggers honor animate(delay:)', (tester) async {
    await tester.pumpWidget(
      _host(
        const Text('x')
            .animate(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 100),
            )
            .fade()
            .onVisible(),
      ),
    );
    await tester.pump(); // visibility check: on screen, so the delay starts
    await tester.pump(const Duration(milliseconds: 150));
    expect(fxPaintedOpacity(tester, find.text('x')), 0.0);
    await tester.pump(const Duration(milliseconds: 60)); // delay elapses
    await tester.pump(const Duration(milliseconds: 110));
    expect(fxPaintedOpacity(tester, find.text('x')), 1.0);
  });

  group('animateList', () {
    testWidgets('shares timing and staggers by start delay', (tester) async {
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[Text('a'), Text('b')]
                .animateList()
                .fade()
                .duration(const Duration(milliseconds: 100))
                .interval(const Duration(milliseconds: 100))
                .build(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(fxPaintedOpacity(tester, find.text('a')), 1.0);
      expect(fxPaintedOpacity(tester, find.text('b')), 0.0);
      await tester.pump(const Duration(milliseconds: 10)); // b's timer
      await tester.pump(const Duration(milliseconds: 100));
      expect(fxPaintedOpacity(tester, find.text('b')), 1.0);
    });

    testWidgets('keyed children keep their state when reordered', (
      tester,
    ) async {
      Widget app(List<String> order) => _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final id in order) _Probe(key: ValueKey(id), label: id),
          ].animateList().fade().build(),
        ),
      );
      await tester.pumpWidget(app(<String>['a', 'b']));
      await tester.pumpAndSettle();
      final a = tester.state<_ProbeState>(find.byKey(const ValueKey('a')));
      await tester.pumpWidget(app(<String>['b', 'a']));
      await tester.pumpAndSettle();
      expect(
        tester.state<_ProbeState>(find.byKey(const ValueKey('a'))),
        same(a),
      );
    });
  });

  test('FxDurations follow the Material 3 scale', () {
    expect(FxDurations.short1, const Duration(milliseconds: 50));
    expect(FxDurations.medium2, const Duration(milliseconds: 300));
    expect(FxDurations.long4, const Duration(milliseconds: 600));
    expect(FxDurations.extraLong4, const Duration(seconds: 1));
  });
}

class _Probe extends StatefulWidget {
  const _Probe({super.key, required this.label});
  final String label;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => Text(widget.label);
}
