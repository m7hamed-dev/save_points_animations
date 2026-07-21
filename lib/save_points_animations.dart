/// Save Points Animations — a fluent, extensible animation framework for
/// Flutter built on extension methods and a single-controller engine.
///
/// ```dart
/// import 'package:save_points_animations/save_points_animations.dart';
///
/// Text('Hello')
///     .animate()
///     .fade()
///     .moveY(50)
///     .scale(begin: 0.8)
///     .duration(600.ms)
///     .curve(FxCurves.snappy);
/// ```
library;

// Core
export 'src/core/fx_curves.dart';

// Effects
export 'src/effects/fx_effect.dart' show FxEffect, FxAccumulator, fxLerp;
export 'src/effects/transform_effects.dart';
export 'src/effects/visual_effects.dart';
export 'src/effects/motion_effects.dart';
export 'src/effects/attention_effects.dart';

// Engine / builder
export 'src/builders/fx_builder.dart' show FxBuilder;
export 'src/controllers/fx_controller.dart' show FxController;

// Theming
export 'src/themes/fx_theme.dart'
    show FxTheme, FxThemeData, FxReducedMotionBehavior;

// Extensions
export 'src/extensions/num_duration_extensions.dart';
export 'src/extensions/fx_widget_extensions.dart';
export 'src/extensions/fx_list_extensions.dart';

// Presets
export 'src/presets/fx_presets.dart';

// Triggers & gestures
export 'src/triggers/fx_triggers.dart' show FxTrigger, FxTriggerExtension;
export 'src/gestures/fx_gestures.dart' show FxGestures;

// Physics
export 'src/physics/fx_physics.dart' show FxPhysics, FxSpringCurve;

// Page transitions & Hero
export 'src/transitions/fx_page_route.dart'
    show FxPageRoute, FxPageTransition, FxNavigator, buildFxTransition;
export 'src/transitions/fx_hero.dart' show FxHero, FxArcRectTween;

// Debug tools
export 'src/debug/fx_debug.dart' show FxDebug, FxDebugRegistry;
