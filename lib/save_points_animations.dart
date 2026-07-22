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

export 'src/builders/fx_builder.dart' show FxBuilder;
export 'src/controllers/fx_controller.dart' show FxController;
export 'src/core/fx_curves.dart';
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
export 'src/extensions/fx_widget_extensions.dart';
export 'src/extensions/num_duration_extensions.dart';
export 'src/gestures/fx_gestures.dart' show FxGestures;
export 'src/gestures/fx_tilt.dart' show FxTilt, FxTiltExtension;
export 'src/physics/fx_physics.dart' show FxPhysics, FxSpringCurve;
export 'src/presets/fx_presets.dart';
export 'src/scroll/fx_scroll.dart'
    show FxParallax, FxScrollExtension, FxScrollLinked;
export 'src/text/fx_text.dart'
    show FxAnimatedText, FxCountNum, FxCountUp, FxTextString, FxTypewriter;
export 'src/text/fx_text_fx.dart'
    show FxGradientText, FxScrambleText, FxTextEffects, FxWavyText, FxWordsText;
export 'src/themes/fx_theme.dart'
    show FxReducedMotionBehavior, FxTheme, FxThemeData;
export 'src/transitions/fx_hero.dart' show FxArcRectTween, FxHero;
export 'src/transitions/fx_page_route.dart'
    show FxNavigator, FxPageRoute, FxPageTransition, buildFxTransition;
export 'src/triggers/fx_triggers.dart' show FxTrigger, FxTriggerExtension;
export 'src/widgets/fx_animated_check.dart' show FxAnimatedCheck;
export 'src/widgets/fx_animated_gradient.dart' show FxAnimatedGradient;
export 'src/widgets/fx_animated_visibility.dart'
    show FxAnimatedVisibility, FxEntranceBuilder, FxVisibility;
export 'src/widgets/fx_badge.dart' show FxBadge, FxBadgeExtension;
export 'src/widgets/fx_confetti.dart' show FxConfetti, FxConfettiController;
export 'src/widgets/fx_countdown.dart' show FxCountdown;
export 'src/widgets/fx_expandable.dart' show FxExpandable;
export 'src/widgets/fx_flip_card.dart' show FxFlipCard, FxFlipCardController;
export 'src/widgets/fx_loaders.dart'
    show FxBarsLoader, FxDotsLoader, FxProgressRing;
export 'src/widgets/fx_marquee.dart' show FxMarquee;
export 'src/widgets/fx_page_indicator.dart' show FxPageIndicator;
export 'src/widgets/fx_progress_bar.dart' show FxProgressBar;
export 'src/widgets/fx_pulse.dart' show FxPulse;
export 'src/widgets/fx_rating.dart' show FxRating;
export 'src/widgets/fx_skeleton.dart' show FxSkeleton;
export 'src/widgets/fx_speed_dial.dart' show FxSpeedDial;
export 'src/widgets/fx_swipe.dart' show FxSwipeToDismiss;
export 'src/widgets/fx_switcher.dart' show FxSwitcher, FxSwitcherEffect;
