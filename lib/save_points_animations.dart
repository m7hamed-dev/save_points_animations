/// Save Points Animations — a fluent, extensible animation framework for
/// Flutter built on extension methods and a single-controller engine.
///
/// ```dart
/// import 'package:save_points_animations/save_points_animations.dart';
///
/// Text('Hello')
///     .animate(duration: 600.ms, curve: FxCurves.snappy)
///     .fade()
///     .moveY(50)
///     .scale(begin: 0.8);
/// ```
///
/// This library exports everything. To import a part only, use
/// `core.dart` (the engine) or `widgets.dart` (the widget catalog).
library;

export 'core.dart';
export 'src/extensions/fx_widget_extensions.dart' show FxAnimateShortcuts;
export 'widgets.dart';
