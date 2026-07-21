import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

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
    final mid = tester.widget<Opacity>(find.byType(Opacity).first).opacity;
    expect(mid, greaterThan(0.0));
    expect(mid, lessThan(1.0));
    // At rest the engine drops the Opacity wrapper (fully opaque = no-op).
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('reduced motion jumps to the end frame', (tester) async {
    await tester.pumpWidget(
      _host(const Text('Hi').animate().fade(), disableAnimations: true),
    );
    await tester.pump(); // run the post-frame callback
    await tester.pump();
    // Jumped straight to the end frame: fully visible, no Opacity wrapper.
    expect(find.text('Hi'), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
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
    controller.play();
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
