/// The animation engine alone: `.animate()` chains, effects, timelines,
/// staggers, triggers, scroll effects, physics, page transitions and theming.
///
/// Import this instead of `save_points_animations.dart` to leave out the
/// ready-made widget catalog and the one-call `Widget` shortcuts
/// (`Text('Hi').fadeIn()`, …), keeping `Widget`'s namespace to `animate()`:
///
/// ```dart
/// import 'package:save_points_animations/core.dart';
///
/// Text('Hello').animate(duration: 600.ms).fade().moveY(50);
/// ```
library;

export 'src/builders/fx_builder.dart' show FxBuilder;
export 'src/controllers/fx_controller.dart' show FxController;
export 'src/core/fx_curves.dart';
export 'src/core/fx_durations.dart';
export 'src/core/fx_motion.dart' show FxMotionAware, fxReduceMotion;
export 'src/debug/fx_debug.dart' show FxDebug, FxDebugRegistry;
export 'src/effects/attention_effects.dart';
export 'src/effects/color_effects.dart';
export 'src/effects/entrance_effects.dart';
export 'src/effects/fx_effect.dart'
    show FxAccumulator, FxEffect, fxKeyframe, fxLerp;
export 'src/effects/loading_effects.dart';
export 'src/effects/motion_effects.dart';
export 'src/effects/reveal_effects.dart';
export 'src/effects/transform_effects.dart';
export 'src/effects/visual_effects.dart';
export 'src/extensions/fx_list_extensions.dart';
export 'src/extensions/fx_widget_extensions.dart' show FxAnimate;
export 'src/extensions/fx_wrapper_extensions.dart' show FxWrap;
export 'src/extensions/num_duration_extensions.dart';
export 'src/gestures/fx_gestures.dart' show FxGestures;
export 'src/gestures/fx_tilt.dart' show FxTilt, FxTiltExtension;
export 'src/physics/fx_physics.dart' show FxPhysics, FxSpringCurve;
export 'src/presets/fx_presets.dart';
export 'src/scroll/fx_scroll.dart'
    show FxParallax, FxScrollExtension, FxScrollLinked;
export 'src/themes/fx_theme.dart'
    show FxReducedMotionBehavior, FxTheme, FxThemeData;
export 'src/transitions/fx_hero.dart' show FxArcRectTween, FxHero;
export 'src/transitions/fx_page_route.dart' show FxNavigator, FxPageRoute;
export 'src/transitions/fx_page_transition.dart' show FxPageTransition;
export 'src/transitions/fx_transition_builder.dart' show buildFxTransition;
export 'src/triggers/fx_triggers.dart' show FxTrigger, FxTriggerExtension;
