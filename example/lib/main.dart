import 'package:flutter/material.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'package:save_points_animations_example/home_screen.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Points Animations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Effects and page transitions are themed independently.
      home: const FxTheme(
        // Effects: snappy and a touch longer.
        duration: Duration(milliseconds: 500),
        curve: FxCurves.snappy,
        // Page transitions: Material 3 emphasized, slightly quicker.
        transitionCurve: FxCurves.emphasized,
        transitionDuration: Duration(milliseconds: 400),
        child: HomeScreen(),
      ),
    );
  }
}
