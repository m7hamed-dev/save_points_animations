import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'support/fx_probe.dart';

Widget _host(Widget child, {bool disableAnimations = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

void main() {
  testWidgets('renders the child widget', (tester) async {
    await tester.pumpWidget(_host(const Text('Hello').animate().fade()));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('autoplays: opacity progresses from 0 toward 1', (tester) async {
    await tester.pumpWidget(
      _host(
        const Text(
          'Hi',
        ).animate().fade().duration(const Duration(milliseconds: 300)),
      ),
    );
    await tester.pump(); // run post-frame forward()
    await tester.pump(const Duration(milliseconds: 150));
    final mid = fxPaintedOpacity(tester, find.text('Hi'));
    expect(mid, greaterThan(0.0));
    expect(mid, lessThan(1.0));
    await tester.pump(const Duration(milliseconds: 200));
    expect(fxPaintedOpacity(tester, find.text('Hi')), 1.0);
    // Fade only changes paint: no Opacity widget is ever built for it.
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('reduced motion jumps to the end frame', (tester) async {
    await tester.pumpWidget(
      _host(const Text('Hi').animate().fade(), disableAnimations: true),
    );
    await tester.pump(); // run the post-frame callback
    await tester.pump();
    // Jumped straight to the end frame: fully visible.
    expect(find.text('Hi'), findsOneWidget);
    expect(fxPaintedOpacity(tester, find.text('Hi')), 1.0);
  });

  testWidgets('reduced motion "disable" shows the child untouched', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        FxTheme(
          reducedMotionBehavior: FxReducedMotionBehavior.disable,
          child: const Text('Hi').animate().fade().scale(begin: 0.5),
        ),
        disableAnimations: true,
      ),
    );
    await tester.pump();
    await tester.pump();
    // No effect applied at all — in particular the entrance fade must not
    // leave the child stuck at opacity 0.
    expect(find.text('Hi'), findsOneWidget);
    expect(fxPaintedOpacity(tester, find.text('Hi')), 1.0);
    expect(fxCompositeOf(tester, find.text('Hi')), isNull);
    expect(
      find.ancestor(of: find.text('Hi'), matching: find.byType(Transform)),
      findsNothing,
    );
  });

  group('child State survives wrappers appearing/disappearing', () {
    Future<int> mountsDuring(WidgetTester tester, FxBuilder chain) async {
      _MountCounter.mounts = 0;
      await tester.pumpWidget(_host(chain));
      await tester.pumpAndSettle();
      return _MountCounter.mounts;
    }

    testWidgets('fade (Opacity dropped at rest)', (tester) async {
      expect(
        await mountsDuring(tester, const _MountCounter().animate().fade()),
        1,
      );
    });

    testWidgets('shake (Transform added after frame 0, dropped at rest)', (
      tester,
    ) async {
      expect(
        await mountsDuring(tester, const _MountCounter().animate().shake()),
        1,
      );
    });

    testWidgets('blur + slide (wrapping effects dropped at rest)', (
      tester,
    ) async {
      expect(
        await mountsDuring(
          tester,
          const _MountCounter().animate().blur().slideY(0.3),
        ),
        1,
      );
    });
  });

  testWidgets('disposes its ticker without leaks', (tester) async {
    await tester.pumpWidget(_host(const Text('Hi').animate().fade()));
    await tester.pump();
    // Replacing the tree disposes the State; a leaked ticker would throw here.
    await tester.pumpWidget(_host(const SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('FxController drives playback imperatively', (tester) async {
    final controller = FxController();
    await tester.pumpWidget(
      _host(
        const Text('Hi')
            .animate(controller: controller, autoPlay: false)
            .fade()
            .duration(const Duration(milliseconds: 200)),
      ),
    );
    await tester.pump();
    expect(controller.value, 0.0);
    unawaited(controller.play());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller.value, closeTo(1.0, 1e-3));
    // No-op dispose must not throw.
    controller.dispose();
  });

  testWidgets('staggered list produces one animated child per item', (
    tester,
  ) async {
    final children = List.generate(4, (i) => Text('item $i'));
    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: children
              .animateList()
              .fade()
              .slideY(0.2)
              .interval(const Duration(milliseconds: 50))
              .build(),
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      expect(find.text('item $i'), findsOneWidget);
    }
    expect(find.byType(FxBuilder), findsNWidgets(4));
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
