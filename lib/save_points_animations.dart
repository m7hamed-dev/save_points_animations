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
export 'src/extensions/fx_widget_extensions.dart';
export 'src/extensions/fx_wrapper_extensions.dart' show FxWrap;
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
export 'src/transitions/fx_page_route.dart' show FxNavigator, FxPageRoute;
export 'src/transitions/fx_page_transition.dart' show FxPageTransition;
export 'src/transitions/fx_transition_builder.dart' show buildFxTransition;
export 'src/triggers/fx_triggers.dart' show FxTrigger, FxTriggerExtension;
export 'src/widgets/fx_animated_check.dart' show FxAnimatedCheck;
export 'src/widgets/fx_animated_checkbox.dart' show FxAnimatedCheckbox;
export 'src/widgets/fx_animated_gradient.dart' show FxAnimatedGradient;
export 'src/widgets/fx_animated_nav_bar.dart' show FxAnimatedNavBar;
export 'src/widgets/fx_animated_radio.dart' show FxAnimatedRadio;
export 'src/widgets/fx_animated_slider.dart' show FxAnimatedSlider;
export 'src/widgets/fx_animated_tab_bar.dart' show FxAnimatedTabBar;
export 'src/widgets/fx_animated_toggle.dart' show FxAnimatedToggle;
export 'src/widgets/fx_animated_visibility.dart'
    show FxAnimatedVisibility, FxEntranceBuilder, FxVisibility;
export 'src/widgets/fx_aurora.dart' show FxAurora;
export 'src/widgets/fx_avatar_stack.dart' show FxAvatarStack;
export 'src/widgets/fx_badge.dart' show FxBadge, FxBadgeExtension;
export 'src/widgets/fx_bar_chart.dart' show FxBarChart;
export 'src/widgets/fx_blob.dart' show FxBlob;
export 'src/widgets/fx_border_beam.dart' show FxBorderBeam;
export 'src/widgets/fx_bouncing_ball.dart' show FxBouncingBall;
export 'src/widgets/fx_bubbles.dart' show FxBubbles;
export 'src/widgets/fx_carousel.dart' show FxCarousel, FxCarouselDots;
export 'src/widgets/fx_circular_countdown.dart' show FxCircularCountdown;
export 'src/widgets/fx_circular_menu.dart' show FxCircularMenu;
export 'src/widgets/fx_circular_text.dart' show FxCircularText;
export 'src/widgets/fx_color_cycle.dart' show FxColorCycle;
export 'src/widgets/fx_color_wheel.dart' show FxColorWheel;
export 'src/widgets/fx_confetti.dart' show FxConfetti, FxConfettiController;
export 'src/widgets/fx_countdown.dart' show FxCountdown;
export 'src/widgets/fx_curved_nav_bar.dart' show FxCurvedNavBar;
export 'src/widgets/fx_date_strip.dart' show FxDateStrip;
export 'src/widgets/fx_dot_grid.dart' show FxDotGrid;
export 'src/widgets/fx_dot_nav_bar.dart' show FxDotNavBar;
export 'src/widgets/fx_draggable_sheet.dart' show FxDraggableSheet;
export 'src/widgets/fx_expandable.dart' show FxExpandable;
export 'src/widgets/fx_fireworks.dart' show FxFireworks;
export 'src/widgets/fx_flip_card.dart' show FxFlipCard, FxFlipCardController;
export 'src/widgets/fx_flip_clock.dart' show FxFlipClock;
export 'src/widgets/fx_floating_field.dart' show FxFloatingField;
export 'src/widgets/fx_frosted_nav_bar.dart' show FxFrostedNavBar;
export 'src/widgets/fx_gauge.dart' show FxGauge;
export 'src/widgets/fx_glass_card.dart' show FxGlassCard;
export 'src/widgets/fx_glitch.dart' show FxGlitch;
export 'src/widgets/fx_glow_button.dart' show FxGlowButton;
export 'src/widgets/fx_gooey_nav_bar.dart' show FxGooeyNavBar;
export 'src/widgets/fx_gradient_border.dart' show FxGradientBorder;
export 'src/widgets/fx_gradient_button.dart' show FxGradientButton;
export 'src/widgets/fx_heart_button.dart' show FxHeartButton;
export 'src/widgets/fx_hold_button.dart' show FxHoldButton;
export 'src/widgets/fx_image_compare.dart' show FxImageCompare;
export 'src/widgets/fx_ken_burns.dart' show FxKenBurns;
export 'src/widgets/fx_loaders.dart'
    show FxBarsLoader, FxDotsLoader, FxProgressRing;
export 'src/widgets/fx_loading_overlay.dart' show FxLoadingOverlay;
export 'src/widgets/fx_magnetic_button.dart' show FxMagneticButton;
export 'src/widgets/fx_marquee.dart' show FxMarquee;
export 'src/widgets/fx_mesh_gradient.dart' show FxMeshGradient;
export 'src/widgets/fx_morph_icon.dart' show FxMorphIcon;
export 'src/widgets/fx_nav_item.dart' show FxNavItem;
export 'src/widgets/fx_neon_text.dart' show FxNeonText;
export 'src/widgets/fx_number_pad.dart' show FxNumberPad;
export 'src/widgets/fx_odometer.dart' show FxOdometer;
export 'src/widgets/fx_orbit_loader.dart' show FxOrbitLoader;
export 'src/widgets/fx_page_indicator.dart' show FxPageIndicator;
export 'src/widgets/fx_parallax_layers.dart'
    show FxParallaxLayer, FxParallaxLayers;
export 'src/widgets/fx_particles.dart' show FxParticles;
export 'src/widgets/fx_pie_chart.dart' show FxPieChart;
export 'src/widgets/fx_pill_nav_bar.dart' show FxPillNavBar;
export 'src/widgets/fx_pin_dots.dart' show FxPinDots;
export 'src/widgets/fx_plasma.dart' show FxPlasma;
export 'src/widgets/fx_progress_bar.dart' show FxProgressBar;
export 'src/widgets/fx_progress_button.dart'
    show FxButtonState, FxProgressButton;
export 'src/widgets/fx_pulse.dart' show FxPulse;
export 'src/widgets/fx_radar.dart' show FxRadar;
export 'src/widgets/fx_range_slider.dart' show FxRange, FxRangeSlider;
export 'src/widgets/fx_rating.dart' show FxRating;
export 'src/widgets/fx_reaction_bar.dart' show FxReactionBar;
export 'src/widgets/fx_ripple.dart' show FxRipple;
export 'src/widgets/fx_ripple_grid.dart' show FxRippleGrid;
export 'src/widgets/fx_rotating_words.dart' show FxRotatingWords;
export 'src/widgets/fx_scratch_card.dart' show FxScratchCard;
export 'src/widgets/fx_scroll_progress.dart' show FxScrollProgress;
export 'src/widgets/fx_scroll_to_top.dart' show FxScrollToTop;
export 'src/widgets/fx_segmented_control.dart' show FxSegmentedControl;
export 'src/widgets/fx_shimmer_button.dart' show FxShimmerButton;
export 'src/widgets/fx_shine.dart' show FxShine;
export 'src/widgets/fx_shiny_text.dart' show FxShinyText;
export 'src/widgets/fx_skeleton.dart' show FxSkeleton;
export 'src/widgets/fx_skeleton_text.dart' show FxSkeletonText;
export 'src/widgets/fx_slide_to_confirm.dart' show FxSlideToConfirm;
export 'src/widgets/fx_snow.dart' show FxSnow;
export 'src/widgets/fx_sparkline.dart' show FxSparkline;
export 'src/widgets/fx_speed_dial.dart' show FxSpeedDial;
export 'src/widgets/fx_spin_wheel.dart' show FxSpinWheel, FxSpinWheelController;
export 'src/widgets/fx_spotlight.dart' show FxSpotlight;
export 'src/widgets/fx_star_field.dart' show FxStarField;
export 'src/widgets/fx_step_progress.dart' show FxStepProgress;
export 'src/widgets/fx_stepper.dart' show FxStepper;
export 'src/widgets/fx_swipe.dart' show FxSwipeToDismiss;
export 'src/widgets/fx_swipe_cards.dart' show FxSwipeCards;
export 'src/widgets/fx_switcher.dart' show FxSwitcher, FxSwitcherEffect;
export 'src/widgets/fx_tag_chips.dart' show FxTagChips;
export 'src/widgets/fx_theme_toggle.dart' show FxThemeToggle;
export 'src/widgets/fx_tilt_glare_card.dart' show FxTiltGlareCard;
export 'src/widgets/fx_timeline.dart' show FxTimeline;
export 'src/widgets/fx_toast.dart' show FxToast, FxToastSide;
export 'src/widgets/fx_type_loop.dart' show FxTypeLoop;
export 'src/widgets/fx_typing_indicator.dart' show FxTypingIndicator;
export 'src/widgets/fx_wave_divider.dart' show FxWaveDivider;
export 'src/widgets/fx_wave_dots.dart' show FxWaveDots;
export 'src/widgets/fx_wave_progress.dart' show FxWaveProgress;
export 'src/widgets/fx_waveform.dart' show FxWaveform;
export 'src/widgets/fx_wheel_picker.dart' show FxWheelPicker;
export 'src/widgets/fx_wizard_steps.dart' show FxWizardSteps;
