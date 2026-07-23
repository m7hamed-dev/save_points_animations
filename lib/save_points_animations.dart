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
export 'src/widgets/fx_animated_checkbox.dart' show FxAnimatedCheckbox;
export 'src/widgets/fx_animated_gradient.dart' show FxAnimatedGradient;
export 'src/widgets/fx_animated_nav_bar.dart' show FxAnimatedNavBar;
export 'src/widgets/fx_animated_toggle.dart' show FxAnimatedToggle;
export 'src/widgets/fx_animated_visibility.dart'
    show FxAnimatedVisibility, FxEntranceBuilder, FxVisibility;
export 'src/widgets/fx_aurora.dart' show FxAurora;
export 'src/widgets/fx_badge.dart' show FxBadge, FxBadgeExtension;
export 'src/widgets/fx_blob.dart' show FxBlob;
export 'src/widgets/fx_border_beam.dart' show FxBorderBeam;
export 'src/widgets/fx_circular_countdown.dart' show FxCircularCountdown;
export 'src/widgets/fx_circular_menu.dart' show FxCircularMenu;
export 'src/widgets/fx_color_cycle.dart' show FxColorCycle;
export 'src/widgets/fx_confetti.dart' show FxConfetti, FxConfettiController;
export 'src/widgets/fx_countdown.dart' show FxCountdown;
export 'src/widgets/fx_dot_grid.dart' show FxDotGrid;
export 'src/widgets/fx_expandable.dart' show FxExpandable;
export 'src/widgets/fx_flip_card.dart' show FxFlipCard, FxFlipCardController;
export 'src/widgets/fx_flip_clock.dart' show FxFlipClock;
export 'src/widgets/fx_gauge.dart' show FxGauge;
export 'src/widgets/fx_glitch.dart' show FxGlitch;
export 'src/widgets/fx_gradient_border.dart' show FxGradientBorder;
export 'src/widgets/fx_heart_button.dart' show FxHeartButton;
export 'src/widgets/fx_ken_burns.dart' show FxKenBurns;
export 'src/widgets/fx_loaders.dart'
    show FxBarsLoader, FxDotsLoader, FxProgressRing;
export 'src/widgets/fx_marquee.dart' show FxMarquee;
export 'src/widgets/fx_morph_icon.dart' show FxMorphIcon;
export 'src/widgets/fx_neon_text.dart' show FxNeonText;
export 'src/widgets/fx_odometer.dart' show FxOdometer;
export 'src/widgets/fx_page_indicator.dart' show FxPageIndicator;
export 'src/widgets/fx_parallax_layers.dart'
    show FxParallaxLayer, FxParallaxLayers;
export 'src/widgets/fx_particles.dart' show FxParticles;
export 'src/widgets/fx_progress_bar.dart' show FxProgressBar;
export 'src/widgets/fx_progress_button.dart'
    show FxButtonState, FxProgressButton;
export 'src/widgets/fx_pulse.dart' show FxPulse;
export 'src/widgets/fx_radar.dart' show FxRadar;
export 'src/widgets/fx_rating.dart' show FxRating;
export 'src/widgets/fx_ripple.dart' show FxRipple;
export 'src/widgets/fx_rotating_words.dart' show FxRotatingWords;
export 'src/widgets/fx_scratch_card.dart' show FxScratchCard;
export 'src/widgets/fx_scroll_progress.dart' show FxScrollProgress;
export 'src/widgets/fx_segmented_control.dart' show FxSegmentedControl;
export 'src/widgets/fx_shimmer_button.dart' show FxShimmerButton;
export 'src/widgets/fx_shine.dart' show FxShine;
export 'src/widgets/fx_skeleton.dart' show FxSkeleton;
export 'src/widgets/fx_slide_to_confirm.dart' show FxSlideToConfirm;
export 'src/widgets/fx_speed_dial.dart' show FxSpeedDial;
export 'src/widgets/fx_spotlight.dart' show FxSpotlight;
export 'src/widgets/fx_step_progress.dart' show FxStepProgress;
export 'src/widgets/fx_swipe.dart' show FxSwipeToDismiss;
export 'src/widgets/fx_swipe_cards.dart' show FxSwipeCards;
export 'src/widgets/fx_switcher.dart' show FxSwitcher, FxSwitcherEffect;
export 'src/widgets/fx_tilt_glare_card.dart' show FxTiltGlareCard;
export 'src/widgets/fx_timeline.dart' show FxTimeline;
export 'src/widgets/fx_typing_indicator.dart' show FxTypingIndicator;
export 'src/widgets/fx_wave_divider.dart' show FxWaveDivider;
export 'src/widgets/fx_wave_progress.dart' show FxWaveProgress;
