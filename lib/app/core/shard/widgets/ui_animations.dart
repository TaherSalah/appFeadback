// 📁 File: ui_animations.dart
// ✅ A collection of reusable animation widgets to enhance Flutter UI experience

// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// 🔄 Enum to select animation type
// 🔄 Enum to select animation type
enum UiAnimationType {
  fade, // إظهار تدريجي بالشفافية
  opacity, // تغيير الشفافية فقط بدون حركة
  scale, // تكبير تدريجي من الحجم الأصلي
  slideLeft, // انزلاق من اليسار
  slideRight, // انزلاق من اليمين
  slideTop, // انزلاق من الأعلى
  slideBottom, // انزلاق من الأسفل
  shake, // اهتزاز أفقي
  flip, // قلب حول المحور Y
  blur, // يظهر بعد إزالة الضبابية تدريجياً
  zoomOut, // يظهر بحجم كبير ثم يصغر لحجمه الطبيعي
  rotate, // دوران أثناء الظهور
  bounce, // نطة صغيرة للأعلى ثم للأسفل
  colorFade, // انتقال تدريجي بين لونين
  gradientSlide, // تدرج لوني متحرك
  popOut, // تكبير مفاجئ ثم اختفاء
  hoverScale, // تكبير عند تمرير الماوس
  pressScale, // تصغير عند الضغط
  scrollAppear, // يظهر عند دخول العنصر في الشاشة
  staggeredList, // تأخير تدريجي بين عناصر القائمة
  switcher, // تبديل بين عنصرين بـ Fade
  crossFade, // انتقال ناعم بين عنصرين بصرياً
  alignChange, // تغيير موضع العنصر تدريجياً
  hero, // انتقال عنصر بين الشاشات باستخدام Hero
  fadeScale, // يظهر تدريجياً مع تكبير
  pulse, // تكرار تكبير/تصغير ناعم مثل ضربات القلب
  typewriter, // كتابة النص حرف حرف
  zoomIn, // يظهر من لا شيء حتى يصل للحجم الكامل
  elasticPop, // يكبر بتأثير نابض (Elastic)
  rotate3D, // دوران ثلاثي الأبعاد
  slideScale, // انزلاق + تكبير معاً
  heartbeat, // تأثير نبضة قلب (Scale نابض)
  flash, // وميض سريع
  blurInScale, // ظهور مع إزالة الضبابية + تكبير
  dropDownAppear, // يسقط من أعلى بشكل ناعم
  jelly, // تأثير جيلاتيني
  fadeRotate, // ظهور بتدوير + شفافية
  slideOpacityLoop, // انزلاق + ظهور + تكرار
  tiltOnTap, // ميل خفيف عند الضغط
  rippleEffect, // دوائر موجية تتسع عند الضغط
  explodeOut, // انفجار للخارج من المنتصف
  explodeIn, // تجميع من الخارج للداخل
  shine, // لمعان ضوء يمر فوق العنصر
  morphing, // تحول شكلي بين حالتين
  pageFlip3D, // قلب الصفحة بشكل ثلاثي الأبعاد
  liquidReveal, // انكشاف بشكل سائل
  magnetHover, // جذب العنصر عند الاقتراب منه بالماوس
  circularReveal, // كشف العنصر بدائرة متسعة
  physicsSpring, // حركة نابض طبيعية باستخدام فيزياء
  glassMorphism, // تأثير زجاجي شفاف
  breathing, // تكبير/تصغير خفيف كأن العنصر يتنفس
  waveDistortion, // تموجات تشوه شكل العنصر
  perspectiveDrag, // سحب مع منظور ثلاثي الأبعاد
  pathMorph, // تحويل مسار الشكل (path)
  shadowPulse, // تكرار توهج الظل
  gradientPulse, // تكرار حركة التدرج
  innerGlow, // توهج داخلي متكرر
  neumorphicPress, // ضغط بأسلوب التصميم النيو مورفيك
  swipeBounceBack, // سحب ثم ارتداد للخلف
  hoverMagnetScale, // تكبير مغناطيسي عند المرور بالماوس
  rippleExplosion, // موجات تنفجر للخارج
  warpShatter, // تفكك وانكسار الشكل
  glitchTransition, // تقطيع Glitch-style
  pixelDissolve, // تفكك إلى بكسلات
  blackholeSuckIn, // التشفط داخل ثقب أسود
  neuralScanLines, // خطوط تمر فوق العنصر كماسح دماغي
  flarePulseExplosion, // انفجار متوهج ساطع
  portalWarp, // انتقال عبر بوابة دوارة
  glassBreakExplosion, // انفجار كأن الزجاج اتكسر
  liquidDropSplash, // سقوط قطرة مع موجة
  timeFreezeZoom, // تجميد الوقت + تكبير بطيء
  lightningStrikeReveal, // ومضة برق تكشف العنصر
  swipeCurtainUnfold, // ستارة تنفتح من الجانب
  echoPop, // تكرار دائرة تظهر خلف العنصر
  xRayReveal, // كشف تدريجي كأنك بـ X-Ray
  cardFlipCascade, // Flip تدريجي لعدة بطاقات
  electricShockFlicker, // وميض صدمة كهربائية
  tornadoSpinCollapse, // دوامة ثم اختفاء
  mirrorSlideReveal, // كشف بانزلاق عاكس
  fireFlickerGlow, // توهج ناري متذبذب
  particleRiseReveal, // ارتفاع جزيئات + كشف
  vortexCollapse, // دوران ثم اختفاء لداخل دوامة
  laserSweep, // خط ليزر يمر على العنصر
  pulseShadowRing, // دائرة ظل نابضة
  zoomPulseInOut, // تكبير/تصغير متكرر
  threeDPopIn, // دخول بتكبير ثلاثي الأبعاد
  sparklingFrame, // حواف تلمع بشكل متكرر
  glowingEdgePulse, // توهج متكرر لحواف العنصر
  slideRotateEntrance, // دخول بانزلاق وتدوير
  glowExpandReveal, // توهج ثم تكبير وظهور
  elasticSlideDrop, // نزول بانزلاق مرن
}


/*
* ✅ أنواع أنيميشن:
fade (شفافية تدريجية)

opacity (تحكم في الشفافية)

scale (تكبير)

slideLeft, slideRight, slideTop, slideBottom (حركة انزلاق من الاتجاهات)

shake (هزة)

flip (قلب حول المحور)

blur (ضبابية)

zoomOut (تصغير تدريجي)

rotate (دوران)

bounce (نطّة)

colorFade (تدرج لون)

gradientSlide (تدرج متحرك)

popOut (تكبير ثم اختفاء)

hoverScale (تكبير عند المرور)

pressScale (تصغير عند الضغط)

scrollAppear (يظهر عند دخوله الشاشة)

staggeredList (حركة متدرجة للعناصر)


*
* */

/// ✅ Unified Wrapper for Animations
class AnimatedWrapper extends StatelessWidget {
  final Widget child;
  final UiAnimationType type;
  final Duration duration;
  final Duration delay;
  final int index; // for staggered list

  const AnimatedWrapper({
    super.key,
    required this.child,
    required this.type,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case UiAnimationType.fade:
        return FadeAnimation(duration: duration, child: child);
      case UiAnimationType.opacity:
        return OpacityAnimation(
          duration: duration,
          showAftter: delay,
          child: child,
        );
      case UiAnimationType.scale:
        return ScaleAnimation(duration: duration, child: child);
      case UiAnimationType.slideLeft:
        return SlideFromDirectionAnimation(
          duration: duration,
          offset: const Offset(-1, 0),
          child: child,
        );
      case UiAnimationType.slideRight:
        return SlideFromDirectionAnimation(
          duration: duration,
          offset: const Offset(1, 0),
          child: child,
        );
      case UiAnimationType.slideTop:
        return SlideFromDirectionAnimation(
          duration: duration,
          offset: const Offset(0, -1),
          child: child,
        );
      case UiAnimationType.slideBottom:
        return SlideFromDirectionAnimation(
          duration: duration,
          offset: const Offset(0, 1),
          child: child,
        );
      case UiAnimationType.shake:
        return ShakeAnimation(duration: duration, child: child);
      case UiAnimationType.flip:
        return FlipAnimation(duration: duration, child: child);
      case UiAnimationType.blur:
        return BlurAnimation(duration: duration, child: child);
      case UiAnimationType.zoomOut:
        return ZoomOutAnimation(duration: duration, child: child);
      case UiAnimationType.rotate:
        return RotateAnimation(duration: duration, child: child);
      case UiAnimationType.bounce:
        return BounceAnimation(duration: duration, child: child);
      case UiAnimationType.colorFade:
        return ColorFadeAnimation(duration: duration, child: child);
      case UiAnimationType.gradientSlide:
        return GradientSlideAnimation(duration: duration, child: child);
      case UiAnimationType.popOut:
        return PopOutAnimation(duration: duration, child: child);
      case UiAnimationType.scrollAppear:
        return ScrollAppearAnimation(duration: duration, child: child);
      case UiAnimationType.staggeredList:
        return StaggeredItemAnimation(
          index: index,
          duration: duration,
          child: child,
        );
      case UiAnimationType.switcher:
        return AnimatedSwitcherWrapper(duration: duration, child: child);
      case UiAnimationType.crossFade:
        return AnimatedCrossFadeWrapper(
          showFirst: true, // يمكن تعديله حسب الحالة
          firstChild: child,
          secondChild: const SizedBox.shrink(), // محتاج تضيف بديل فعلي حسب الاستخدام
          duration: duration,
        );
      case UiAnimationType.alignChange:
        return AnimatedAlignWrapper(
          alignment: Alignment.center, // ممكن تعديله حسب الحاجة
          duration: duration,
          child: child,
        );
      case UiAnimationType.hero:
        return HeroExample(
          tag: 'heroTag_$index', // لكل عنصر Tag مختلف
          child: child,
        );
      case UiAnimationType.fadeScale:
        return FadeScaleAnimation(duration: duration, child: child);

      case UiAnimationType.pulse:
        return PulseAnimation(duration: duration, child: child);

      case UiAnimationType.typewriter:
        return TypewriterAnimation(
          text: child is Text ? (child as Text).data ?? '' : '',
          style: child is Text ? (child as Text).style : null,
        );
      case UiAnimationType.zoomIn:
        return ZoomInAnimation(duration: duration, child: child);

      case UiAnimationType.elasticPop:
        return ElasticPopAnimation(duration: duration, child: child);

      case UiAnimationType.rotate3D:
        return Rotate3DAnimation(duration: duration, child: child);
      case UiAnimationType.slideScale:
        return SlideScaleAnimation(duration: duration, child: child);

      case UiAnimationType.fadeRotate:
        return FadeRotateAnimation(duration: duration, child: child);

      case UiAnimationType.jelly:
        return JellyAnimation(duration: duration, child: child);

      case UiAnimationType.dropDownAppear:
        return DropDownAppear(duration: duration, child: child);

      case UiAnimationType.blurInScale:
        return BlurInScale(duration: duration, child: child);

      case UiAnimationType.flash:
        return FlashAnimation(duration: duration, child: child);

      case UiAnimationType.heartbeat:
        return HeartbeatAnimation(duration: duration, child: child);

      case UiAnimationType.slideOpacityLoop:
        return SlideWithOpacityLoop(child: child);
      case UiAnimationType.rippleEffect:
        return RippleEffectAnimation(child: child); // onTap خارجي

      case UiAnimationType.tiltOnTap:
        return TiltOnTapAnimation(child: child);
      case UiAnimationType.shine:
        return ShineEffectAnimation(child: child);

      case UiAnimationType.explodeIn:
        return ExplodeAnimation(isIn: true, child: child);

      case UiAnimationType.explodeOut:
        return ExplodeAnimation(isIn: false, child: child);
      case UiAnimationType.circularReveal:
        return CircularRevealAnimation(child: child);

      case UiAnimationType.magnetHover:
        return MagnetHoverAnimation(child: child);
      case UiAnimationType.liquidReveal:
        return LiquidRevealAnimation(child: child);

      case UiAnimationType.pageFlip3D:
        return PageFlip3DAnimation(child: child);

      case UiAnimationType.morphing:
        return MorphingAnimation(child: child);
      case UiAnimationType.physicsSpring:
        return PhysicsBasedSpringAnimation(child: child);

      case UiAnimationType.glassMorphism:
        return GlassMorphismAppear(child: child);

      case UiAnimationType.breathing:
        return BreathingEffectAnimation(child: child);
      case UiAnimationType.waveDistortion:
        return WaveDistortionAnimation(child: child);

      case UiAnimationType.perspectiveDrag:
        return PerspectiveDragRotation(child: child);

      case UiAnimationType.pathMorph:
        return const CustomPathMorphAnimation(); // doesn't wrap child

      case UiAnimationType.shadowPulse:
        return ShadowPulseAnimation(child: child);

      case UiAnimationType.gradientPulse:
        return GradientPulseAnimation(child: child);

      case UiAnimationType.innerGlow:
        return InnerGlowPulseAnimation(child: child);

      case UiAnimationType.neumorphicPress:
        return NeumorphicPressAnimation(child: child);
      case UiAnimationType.swipeBounceBack:
        return SwipeBounceBackAnimation(child: child);

      case UiAnimationType.hoverMagnetScale:
        return HoverMagneticScale(child: child);

      case UiAnimationType.rippleExplosion:
        return RippleExplosionOnClick(child: child);
      case UiAnimationType.portalWarp:
        return PortalWarpAnimation(child: child);

      case UiAnimationType.flarePulseExplosion:
        return FlarePulseExplosion(child: child);

      case UiAnimationType.neuralScanLines:
        return NeuralScanLines(child: child);

      case UiAnimationType.blackholeSuckIn:
        return BlackholeSuckIn(child: child);

      case UiAnimationType.pixelDissolve:
        return PixelDissolve(child: child);

      case UiAnimationType.glitchTransition:
        return GlitchTransition(child: child);

      case UiAnimationType.warpShatter:
        return WarpShatter(child: child);

      case UiAnimationType.glassBreakExplosion:
        return GlassBreakExplosion(child: child);
      case UiAnimationType.liquidDropSplash:
        return LiquidDropSplash(child: child);
      case UiAnimationType.timeFreezeZoom:
        return TimeFreezeZoom(child: child);
      case UiAnimationType.lightningStrikeReveal:
        return LightningStrikeReveal(child: child);
      case UiAnimationType.swipeCurtainUnfold:
        return SwipeCurtainUnfold(child: child);
          case UiAnimationType.echoPop:
    return EchoPop(child: child);
  case UiAnimationType.xRayReveal:
    return XRayReveal(child: child);
  case UiAnimationType.cardFlipCascade:
    // تحتاج تمرير قائمة Widgets وليس Widget واحد فقط
    return CardFlipCascade(cards: [child]);
  case UiAnimationType.electricShockFlicker:
    return ElectricShockFlicker(child: child);
  case UiAnimationType.tornadoSpinCollapse:
    return TornadoSpinCollapse(child: child);

        case UiAnimationType.mirrorSlideReveal:
      return MirrorSlideReveal(child: child);
    case UiAnimationType.fireFlickerGlow:
      return FireFlickerGlow(child: child);
    case UiAnimationType.particleRiseReveal:
      return ParticleRiseReveal(child: child);

    case UiAnimationType.threeDPopIn:
      return ThreeDPopIn(child: child);
    case UiAnimationType.sparklingFrame:
      return SparklingFrame(child: child);
    case UiAnimationType.glowingEdgePulse:
      return GlowingEdgePulse(child: child);
    case UiAnimationType.slideRotateEntrance:
      return SlideRotateEntrance(child: child);
    case UiAnimationType.glowExpandReveal:
      return GlowExpandReveal(child: child);
    case UiAnimationType.elasticSlideDrop:
      return ElasticSlideDrop(child: child);
      default:
        return child;
    }
  }
}

/// ✅ 1. Fade + Slide Animation
class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final bool rebuild;
  final Duration delay; // Changed to Duration

  const FadeAnimation({
    required this.child,
    this.rebuild = false,
    super.key,
    this.offset = const Offset(0.0, -0.2),
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero, // Default to zero
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    
    offsetAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    if (widget.delay != Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) controller.forward();
      });
    } else {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rebuild) {
      controller.reset();
       if (widget.delay != Duration.zero) {
        Future.delayed(widget.delay, () {
          if (mounted) controller.forward();
        });
      } else {
        controller.forward();
      }
    }

    return FadeTransition( 
      opacity: opacityAnimation,
      child: SlideTransition(
        position: offsetAnimation, 
        child: widget.child
      ),
    );
  }
}

/// ✅ 2. Opacity Fade In with Delay
class OpacityAnimation extends StatefulWidget {
  const OpacityAnimation({
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.showAftter = const Duration(milliseconds: 1),
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration showAftter;

  @override
  State<OpacityAnimation> createState() => _OpacityAnimationState();
}

class _OpacityAnimationState extends State<OpacityAnimation>
    with TickerProviderStateMixin {
  late Animation<double> animationOpacity;
  late AnimationController controllerOpacity;

  @override
  void initState() {
    controllerOpacity = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    animationOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controllerOpacity);
    animationOpacity.addListener(() {
      setState(() {});
      if (animationOpacity.value > 0.95) controllerOpacity.stop();
    });

    Future.delayed(widget.showAftter, () {
      controllerOpacity.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    controllerOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: animationOpacity.value, child: widget.child);
  }
}

/// ✅ 3. Scale In Effect
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    super.key,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scaleAnimation, child: widget.child);
  }
}

/// ✅ Generic Slide From Any Direction
class SlideFromDirectionAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const SlideFromDirectionAnimation({
    required this.child,
    required this.offset,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<SlideFromDirectionAnimation> createState() =>
      _SlideFromDirectionAnimationState();
}

class _SlideFromDirectionAnimationState
    extends State<SlideFromDirectionAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: slide, child: widget.child);
  }
}

/// ✅ 5. Shake Animation (Useful for errors or notifications)
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShakeAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 1),
    ]).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation.value * 200, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// ✅ 6. Flip Animation (Y-axis rotation)
class FlipAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FlipAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = Tween<double>(
      begin: -1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (context, child) {
        return Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(animation.value),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

/// ✅ Blur Effect (Fades blur out gradually)
class BlurAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlurAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<BlurAnimation> createState() => _BlurAnimationState();
}

class _BlurAnimationState extends State<BlurAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> blur;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    blur = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder:
          (context, child) => ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur.value,
              sigmaY: blur.value,
            ),
            child: widget.child,
          ),
    );
  }
}

/// ✅ Zoom Out Animation (Starts large then shrinks to normal)
class ZoomOutAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ZoomOutAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<ZoomOutAnimation> createState() => _ZoomOutAnimationState();
}

class _ZoomOutAnimationState extends State<ZoomOutAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> zoom;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    zoom = Tween<double>(
      begin: 1.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: zoom, child: widget.child);
  }
}

/// ✅ Rotate Animation
class RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RotateAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    rotation = Tween<double>(
      begin: -1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotation,
      child: widget.child,
      builder:
          (context, child) =>
              Transform.rotate(angle: rotation.value * 3.14, child: child),
    );
  }
}

/// ✅ Bounce Animation
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BounceAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> bounce;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    bounce = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: bounce, child: widget.child);
  }
}

/// ✅ Color Fade Animation
class ColorFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ColorFadeAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<ColorFadeAnimation> createState() => _ColorFadeAnimationState();
}

class _ColorFadeAnimationState extends State<ColorFadeAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorAnim;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    colorAnim = ColorTween(
      begin: Colors.red,
      end: Colors.transparent,
    ).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnim,
      builder:
          (context, child) =>
              Container(color: colorAnim.value, child: widget.child),
    );
  }
}

/// ✅ Pop Out Animation
class PopOutAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PopOutAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<PopOutAnimation> createState() => _PopOutAnimationState();
}

class _PopOutAnimationState extends State<PopOutAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// ✅ Gradient Slide Animation
class GradientSlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const GradientSlideAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => const LinearGradient(
            colors: [Colors.blue, Colors.purple, Colors.blue],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            tileMode: TileMode.mirror,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

/// ✅ Hover Effect (Only works on web/desktop platforms)
class HoverScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const HoverScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    super.key,
  });

  @override
  State<HoverScaleAnimation> createState() => _HoverScaleAnimationState();
}

class _HoverScaleAnimationState extends State<HoverScaleAnimation> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

/// ✅ Press/Tap Scale Feedback
class PressScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PressScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  @override
  State<PressScaleAnimation> createState() => _PressScaleAnimationState();
}

class _PressScaleAnimationState extends State<PressScaleAnimation> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

/// ✅ Scroll Appear Animation (Reveals item when it enters viewport)
class ScrollAppearAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ScrollAppearAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 200), // Reduced from 600ms for snappier scroll
    super.key,
  });

  @override
  State<ScrollAppearAnimation> createState() => _ScrollAppearAnimationState();
}

class _ScrollAppearAnimationState extends State<ScrollAppearAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<Offset> slide;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.forward());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: opacity, child: widget.child),
    );
  }
}

/// ✅ Staggered List Animation (pass in an index to delay items)
class StaggeredItemAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay; // Changed to Duration

  const StaggeredItemAnimation({
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 250), // Reduced from 300ms
    this.delay = Duration.zero,
    super.key,
  });

  @override
  State<StaggeredItemAnimation> createState() => _StaggeredItemAnimationState();
}

class _StaggeredItemAnimationState extends State<StaggeredItemAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    
    offset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    
    opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    // Cap the staggered delay to prevent deep list items from appearing incredibly slowly
    // (index % 10) ensures that we never wait more than ~800ms to start the animation
    Future.delayed(
      Duration(milliseconds: (widget.index % 10) * 80) + widget.delay,
      () {
        if (mounted) controller.forward();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition( // Added FadeTransition
      opacity: opacity,
      child: SlideTransition(position: offset, child: widget.child),
    );
  }
}

/// ✅ Animated ListView builder with Staggered Animation
class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final EdgeInsets padding;

  const AnimatedListView({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedWrapper(
          type: UiAnimationType.staggeredList,
          index: index,
          duration: duration,
          child: children[index],
        );
      },
    );
  }
}

/// ✅ Staggered Column Widget (for fixed vertical layout)
class AnimatedStaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final CrossAxisAlignment crossAxisAlignment;

  const AnimatedStaggeredColumn({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: List.generate(children.length, (index) {
        return AnimatedWrapper(
          type: UiAnimationType.staggeredList,
          index: index,
          duration: duration,
          child: children[index],
        );
      }),
    );
  }
}

/// ✅ Animated Grid with Staggered Effects
class AnimatedGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final Duration duration;

  const AnimatedGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedWrapper(
          type: UiAnimationType.staggeredList,
          index: index,
          duration: duration,
          child: children[index],
        );
      },
    );
  }
}

/// ✅ Swipe To Dismiss with animation
class SwipeToDismiss extends StatelessWidget {
  final Widget child;
  final DismissDirection direction;
  final void Function()? onDismissed;
  final Color backgroundColor;
  final Icon icon;

  const SwipeToDismiss({
    super.key,
    required this.child,
    this.direction = DismissDirection.endToStart,
    this.onDismissed,
    this.backgroundColor = Colors.red,
    this.icon = const Icon(Icons.delete, color: Colors.white),
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: direction,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment:
            direction == DismissDirection.startToEnd
                ? Alignment.centerLeft
                : Alignment.centerRight,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: icon,
      ),
      child: child,
    );
  }
}

/// ✅ SlideInMenu - Side drawer style menu with animation
class SlideInMenu extends StatelessWidget {
  final Widget child;
  final Widget menu;
  final bool isOpen;
  final Duration duration;

  const SlideInMenu({
    super.key,
    required this.child,
    required this.menu,
    this.isOpen = false,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: duration,
          left: isOpen ? 0 : -250,
          top: 0,
          bottom: 0,
          width: 250,
          child: Material(elevation: 16, child: menu),
        ),
        AnimatedPositioned(
          duration: duration,
          left: isOpen ? 250 : 0,
          right: isOpen ? -250 : 0,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AbsorbPointer(absorbing: isOpen, child: child),
          ),
        ),
      ],
    );
  }
}

/// ✅ Hero Transition Example
class HeroExample extends StatelessWidget {
  final String tag;
  final Widget child;

  const HeroExample({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(color: Colors.transparent, child: child),
    );
  }
}

/// ✅ AnimatedSwitcherWrapper - Smooth transition between widgets
class AnimatedSwitcherWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedSwitcherWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: child,
      transitionBuilder:
          (widget, animation) =>
              FadeTransition(opacity: animation, child: widget),
    );
  }
}

/// ✅ AnimatedCrossFadeWrapper - Crossfade between two widgets
class AnimatedCrossFadeWrapper extends StatelessWidget {
  final bool showFirst;
  final Widget firstChild;
  final Widget secondChild;
  final Duration duration;

  const AnimatedCrossFadeWrapper({
    super.key,
    required this.showFirst,
    required this.firstChild,
    required this.secondChild,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration,
    );
  }
}

/// ✅ AnimatedAlignWrapper - Smooth alignment transitions
class AnimatedAlignWrapper extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final Duration duration;

  const AnimatedAlignWrapper({
    super.key,
    required this.child,
    required this.alignment,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: alignment,
      duration: duration,
      child: child,
    );
  }
}

class FadeScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<FadeScaleAnimation> createState() => _FadeScaleAnimationState();
}

class _FadeScaleAnimationState extends State<FadeScaleAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    opacity = Tween(begin: 0.0, end: 1.0).animate(controller);
    scale = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: animation, child: widget.child);
  }
}

class TypewriterAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const TypewriterAnimation({
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 60),
    super.key,
  });

  @override
  State<TypewriterAnimation> createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation> {
  String displayedText = "";
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(widget.duration);
      if (currentIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[currentIndex];
          currentIndex++;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(displayedText, style: widget.style);
  }
}

/// ✅ Zoom In Animation - يظهر العنصر من حجم صغير تدريجيًا
class ZoomInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ZoomInAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<ZoomInAnimation> createState() => _ZoomInAnimationState();
}

class _ZoomInAnimationState extends State<ZoomInAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    // 👇 يبدأ من 0 (غير ظاهر) ويصل إلى الحجم الكامل (1)
    scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// ✅ Elastic Pop Animation - تأثير مرن bounce عند الظهور
class ElasticPopAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ElasticPopAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<ElasticPopAnimation> createState() => _ElasticPopAnimationState();
}

class _ElasticPopAnimationState extends State<ElasticPopAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    // 👇 يبدأ صغير وينطّ مرنًا
    scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// ✅ Rotate 3D Animation - يدور العنصر حول محور Y بتأثير ثلاثي الأبعاد
class Rotate3DAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Rotate3DAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<Rotate3DAnimation> createState() => _Rotate3DAnimationState();
}

class _Rotate3DAnimationState extends State<Rotate3DAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotate;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    // 👇 من زاوية 90° (نص لفة) إلى 0°
    rotate = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotate,
      child: widget.child,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(rotate.value * 3.14),
          child: child,
        );
      },
    );
  }
}

/// ✅ Slide + Scale Animation - انزلاق وتكبير في نفس الوقت
class SlideScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const SlideScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 0.3),
    super.key,
  });

  @override
  State<SlideScaleAnimation> createState() => _SlideScaleAnimationState();
}

class _SlideScaleAnimationState extends State<SlideScaleAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

/// ✅ Fade + Rotate Animation - شفافية مع دوران بسيط
class FadeRotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeRotateAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<FadeRotateAnimation> createState() => _FadeRotateAnimationState();
}

class _FadeRotateAnimationState extends State<FadeRotateAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<double> rotation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    opacity = Tween<double>(begin: 0, end: 1).animate(controller);
    rotation = Tween<double>(
      begin: -0.2,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: AnimatedBuilder(
        animation: rotation,
        child: widget.child,
        builder:
            (context, child) =>
                Transform.rotate(angle: rotation.value, child: child),
      ),
    );
  }
}

/// ✅ Jelly Animation - تأثير مطاطي خفيف يشبه الجيلي
class JellyAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const JellyAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<JellyAnimation> createState() => _JellyAnimationState();
}

class _JellyAnimationState extends State<JellyAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleX;
  late Animation<double> scaleY;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    scaleX = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    scaleY = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder:
          (context, child) => Transform(
            transform: Matrix4.diagonal3Values(scaleX.value, scaleY.value, 1),
            alignment: Alignment.center,
            child: widget.child,
          ),
    );
  }
}

/// ✅ Drop Down Appear - ينزل العنصر من الأعلى تدريجيًا
class DropDownAppear extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const DropDownAppear({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<DropDownAppear> createState() => _DropDownAppearState();
}

class _DropDownAppearState extends State<DropDownAppear>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(controller);
    scale = Tween<double>(begin: 0.9, end: 1.0).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

/// ✅ Blur In + Scale - يبدأ ضبابي ثم يظهر بوضوح وتكبير
class BlurInScale extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlurInScale({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<BlurInScale> createState() => _BlurInScaleState();
}

class _BlurInScaleState extends State<BlurInScale>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> blur;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    blur = Tween<double>(begin: 10.0, end: 0.0).animate(controller);
    scale = Tween<double>(begin: 0.8, end: 1.0).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
          child: Transform.scale(scale: scale.value, child: widget.child),
        );
      },
    );
  }
}

/// ✅ Flash Animation - وميض سريع لجذب الانتباه
class FlashAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FlashAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<FlashAnimation> createState() => _FlashAnimationState();
}

class _FlashAnimationState extends State<FlashAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: opacity, child: widget.child);
  }
}

/// ✅ Heartbeat Animation - يشبه نبض القلب
class HeartbeatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const HeartbeatAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<HeartbeatAnimation> createState() => _HeartbeatAnimationState();
}

class _HeartbeatAnimationState extends State<HeartbeatAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// ✅ Slide with Opacity Loop - مناسب للتنبيهات أو loading indicators
class SlideWithOpacityLoop extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Axis direction;

  const SlideWithOpacityLoop({
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.direction = Axis.horizontal,
    super.key,
  });

  @override
  State<SlideWithOpacityLoop> createState() => _SlideWithOpacityLoopState();
}

class _SlideWithOpacityLoopState extends State<SlideWithOpacityLoop>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    slide = Tween<Offset>(
      begin:
          widget.direction == Axis.horizontal
              ? const Offset(-0.1, 0)
              : const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(controller);
    opacity = Tween<double>(begin: 0.5, end: 1.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: opacity, child: widget.child),
    );
  }
}

/// ✅ Ripple Effect Animation - تموّج مائي عند الضغط
class RippleEffectAnimation extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color rippleColor;

  const RippleEffectAnimation({
    required this.child,
    this.onTap,
    this.rippleColor = Colors.black26,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(splashColor: rippleColor, onTap: onTap, child: child);
  }
}

/// ✅ Tilt on Tap - العنصر يميل بشكل بسيط عند الضغط
class TiltOnTapAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const TiltOnTapAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  @override
  State<TiltOnTapAnimation> createState() => _TiltOnTapAnimationState();
}

class _TiltOnTapAnimationState extends State<TiltOnTapAnimation> {
  double tiltX = 0;
  double tiltY = 0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      tiltX = 0.03;
      tiltY = 0.02;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      tiltX = 0;
      tiltY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel:
          () => setState(() {
            tiltX = 0;
            tiltY = 0;
          }),
      child: AnimatedContainer(
        duration: widget.duration,
        transform:
            Matrix4.identity()
              ..rotateX(tiltX)
              ..rotateY(tiltY),
        child: widget.child,
      ),
    );
  }
}

/// ✅ Shine Effect - شعاع ضوء متحرك من اليسار لليمين
class ShineEffectAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShineEffectAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<ShineEffectAnimation> createState() => _ShineEffectAnimationState();
}

class _ShineEffectAnimationState extends State<ShineEffectAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.5),
                Colors.transparent,
              ],
              stops: [
                controller.value - 0.3,
                controller.value,
                controller.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// ✅ Explode Effect - العنصر يتفكك أو يتجمع تدريجيًا (Fade + Scale)
class ExplodeAnimation extends StatefulWidget {
  final Widget child;
  final bool isIn; // true = يظهر, false = يختفي
  final Duration duration;

  const ExplodeAnimation({
    required this.child,
    required this.isIn,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<ExplodeAnimation> createState() => _ExplodeAnimationState();
}

class _ExplodeAnimationState extends State<ExplodeAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    opacity = Tween<double>(
      begin: widget.isIn ? 0.0 : 1.0,
      end: widget.isIn ? 1.0 : 0.0,
    ).animate(controller);
    scale = Tween<double>(
      begin: widget.isIn ? 0.7 : 1.0,
      end: widget.isIn ? 1.0 : 1.3,
    ).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

/// ✅ Circular Reveal - العنصر يظهر على شكل دائرة تتسع تدريجيًا
class CircularRevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const CircularRevealAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<CircularRevealAnimation> createState() =>
      _CircularRevealAnimationState();
}

class _CircularRevealAnimationState extends State<CircularRevealAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> radius;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    radius = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CircularRevealClipper(radius.value),
      child: widget.child,
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double radiusFactor;

  _CircularRevealClipper(this.radiusFactor);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * radiusFactor * 1.5;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) =>
      radiusFactor != oldClipper.radiusFactor;
}

/// ✅ Magnet Hover - العنصر يتحرك مع مؤشر الماوس كأنه مغناطيس (Web/Desktop only)
class MagnetHoverAnimation extends StatefulWidget {
  final Widget child;
  final double strength;

  const MagnetHoverAnimation({
    required this.child,
    this.strength = 30.0,
    super.key,
  });

  @override
  State<MagnetHoverAnimation> createState() => _MagnetHoverAnimationState();
}

class _MagnetHoverAnimationState extends State<MagnetHoverAnimation> {
  Offset offset = Offset.zero;

  void _update(PointerEvent event, Size size) {
    final center = size.center(Offset.zero);
    final delta = event.localPosition - center;
    setState(() {
      offset = Offset(delta.dx / widget.strength, delta.dy / widget.strength);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover:
          (event) =>
              _update(event, (context.findRenderObject() as RenderBox).size),
      onExit: (_) => setState(() => offset = Offset.zero),
      child: Transform.translate(offset: offset, child: widget.child),
    );
  }
}

/// ✅ Liquid Reveal Effect - العنصر يظهر وكأن سائل يتمدد عليه
class LiquidRevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const LiquidRevealAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<LiquidRevealAnimation> createState() => _LiquidRevealAnimationState();
}

class _LiquidRevealAnimationState extends State<LiquidRevealAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> wave;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    wave = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wave,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [Colors.white, Colors.transparent],
              stops: [wave.value - 0.2, wave.value],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: widget.child,
        );
      },
    );
  }
}

/// ✅ Page Flip 3D - قلب صفحة ثلاثي الأبعاد من اليمين لليسار
class PageFlip3DAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PageFlip3DAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<PageFlip3DAnimation> createState() => _PageFlip3DAnimationState();
}

class _PageFlip3DAnimationState extends State<PageFlip3DAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> angle;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    angle = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: angle,
      builder: (context, child) {
        return Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle.value * 3.14),
          alignment: Alignment.centerLeft,
          child: widget.child,
        );
      },
    );
  }
}

/// ✅ Morphing Animation - تحول تدريجي في الحجم والشكل
class MorphingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double fromWidth, toWidth;
  final double fromHeight, toHeight;
  final BorderRadius fromRadius, toRadius;

  const MorphingAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.fromWidth = 60,
    this.toWidth = 300,
    this.fromHeight = 60,
    this.toHeight = 180,
    this.fromRadius = const BorderRadius.all(Radius.circular(30)),
    this.toRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  @override
  State<MorphingAnimation> createState() => _MorphingAnimationState();
}

class _MorphingAnimationState extends State<MorphingAnimation> {
  bool toggled = false;

  void _toggle() => setState(() => toggled = !toggled);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: widget.duration,
        width: toggled ? widget.toWidth : widget.fromWidth,
        height: toggled ? widget.toHeight : widget.fromHeight,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: toggled ? widget.toRadius : widget.fromRadius,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// ✅ Physics-based spring animation - نابض واقعي باستخدام BouncingSpring
class PhysicsBasedSpringAnimation extends StatefulWidget {
  final Widget child;

  const PhysicsBasedSpringAnimation({required this.child, super.key});

  @override
  State<PhysicsBasedSpringAnimation> createState() =>
      _PhysicsBasedSpringAnimationState();
}

class _PhysicsBasedSpringAnimationState
    extends State<PhysicsBasedSpringAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController.unbounded(vsync: this);
    scale = controller.drive(Tween<double>(begin: 0.0, end: 1.0));
    controller.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 100, damping: 5),
        0.0,
        1.0,
        0.8,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder:
          (context, child) =>
              Transform.scale(scale: scale.value, child: widget.child),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// ✅ Glass Morphism Appear - تأثير زجاجي ناعم مع شفافية وضبابية
class GlassMorphismAppear extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlassMorphismAppear({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<GlassMorphismAppear> createState() => _GlassMorphismAppearState();
}

class _GlassMorphismAppearState extends State<GlassMorphismAppear>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> blur;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    blur = Tween<double>(begin: 10.0, end: 2.0).animate(controller);
    opacity = Tween<double>(begin: 0.0, end: 0.8).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
            child: Container(
              color: Colors.white.withOpacity(opacity.value),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// ✅ Breathing Effect - العنصر يكبر ويصغر بنعومة مستمرة
class BreathingEffectAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BreathingEffectAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<BreathingEffectAnimation> createState() =>
      _BreathingEffectAnimationState();
}

class _BreathingEffectAnimationState extends State<BreathingEffectAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    scale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// ✅ Wave Distortion - تأثير تموّج متكرر زي سطح الماء
class WaveDistortionAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const WaveDistortionAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<WaveDistortionAnimation> createState() =>
      _WaveDistortionAnimationState();
}

class _WaveDistortionAnimationState extends State<WaveDistortionAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> waveValue;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    waveValue = Tween<double>(begin: 0, end: 2 * 3.1415).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveValue,
      builder: (_, child) {
        return Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(0.01 * (1 + sin(waveValue.value)))
                ..rotateY(0.01 * cos(waveValue.value)),
          alignment: Alignment.center,
          child: widget.child,
        );
      },
    );
  }
}

/// ✅ Perspective Drag - العنصر يدور أثناء السحب
class PerspectiveDragRotation extends StatefulWidget {
  final Widget child;

  const PerspectiveDragRotation({required this.child, super.key});

  @override
  State<PerspectiveDragRotation> createState() =>
      _PerspectiveDragRotationState();
}

class _PerspectiveDragRotationState extends State<PerspectiveDragRotation> {
  double rotationY = 0.0;

  void _update(DragUpdateDetails details) {
    setState(() {
      rotationY += details.delta.dx * 0.01;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _update,
      child: Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotationY),
        child: widget.child,
      ),
    );
  }
}

/// ✅ Custom Path Morphing - الشكل يتغير تدريجيًا بين path وpath
class CustomPathMorphAnimation extends StatefulWidget {
  final Duration duration;

  const CustomPathMorphAnimation({
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<CustomPathMorphAnimation> createState() =>
      _CustomPathMorphAnimationState();
}

class _CustomPathMorphAnimationState extends State<CustomPathMorphAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> progress;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    progress = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder:
          (_, __) => ClipPath(
            clipper: _MorphPathClipper(progress.value),
            child: Container(width: 100, height: 100, color: Colors.blue),
          ),
    );
  }
}

class _MorphPathClipper extends CustomClipper<Path> {
  final double t;

  _MorphPathClipper(this.t);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      (size.height / 2) + (30 * t),
      size.width,
      size.height / 2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_MorphPathClipper oldClipper) => t != oldClipper.t;
}

/// ✅ Shadow Pulse - الظل يكبر ويصغر مثل النبض
class ShadowPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShadowPulseAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<ShadowPulseAnimation> createState() => _ShadowPulseAnimationState();
}

class _ShadowPulseAnimationState extends State<ShadowPulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> spread;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    spread = Tween<double>(
      begin: 2.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spread,
      builder:
          (_, __) => Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: spread.value,
                  spreadRadius: spread.value / 2,
                ),
              ],
            ),
            child: widget.child,
          ),
    );
  }
}

/// ✅ Gradient Pulse - تدرج لون متحرك (خلفية نابضة)
class GradientPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GradientPulseAnimation({
    required this.child,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  @override
  State<GradientPulseAnimation> createState() => _GradientPulseAnimationState();
}

class _GradientPulseAnimationState extends State<GradientPulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Alignment> alignment;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    alignment = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: alignment,
      builder:
          (_, __) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: alignment.value,
                end: alignment.value * -1,
                colors: const [Colors.blueAccent, Colors.purpleAccent],
              ),
            ),
            child: widget.child,
          ),
    );
  }
}

/// ✅ Inner Glow Pulse - توهج داخلي متغير ناعم
class InnerGlowPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const InnerGlowPulseAnimation({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<InnerGlowPulseAnimation> createState() =>
      _InnerGlowPulseAnimationState();
}

class _InnerGlowPulseAnimationState extends State<InnerGlowPulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> glow;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    glow = Tween<double>(begin: 0.2, end: 0.7).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(glow.value),
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

/// ✅ Neumorphic Press - شكل الزر الغارق عند الضغط
class NeumorphicPressAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const NeumorphicPressAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    super.key,
  });

  @override
  State<NeumorphicPressAnimation> createState() =>
      _NeumorphicPressAnimationState();
}

class _NeumorphicPressAnimationState extends State<NeumorphicPressAnimation> {
  bool pressed = false;

  void _onTap(bool isDown) {
    setState(() => pressed = isDown);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTap(true),
      onTapUp: (_) => _onTap(false),
      onTapCancel: () => _onTap(false),
      child: AnimatedContainer(
        duration: widget.duration,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              pressed
                  ? [
                    BoxShadow(
                      offset: const Offset(2, 2),
                      blurRadius: 5,
                      color: Colors.grey.shade500,
                    ),
                    const BoxShadow(
                      offset: Offset(-2, -2),
                      blurRadius: 5,
                      color: Colors.white,
                    ),
                  ]
                  : [
                    const BoxShadow(
                      offset: Offset(-2, -2),
                      blurRadius: 5,
                      color: Colors.white,
                    ),
                    BoxShadow(
                      offset: const Offset(2, 2),
                      blurRadius: 5,
                      color: Colors.grey.shade500,
                    ),
                  ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// ✅ Swipe + Bounce Back - العنصر يُسحب ويرتد تلقائيًا لمكانه
class SwipeBounceBackAnimation extends StatefulWidget {
  final Widget child;

  const SwipeBounceBackAnimation({required this.child, super.key});

  @override
  State<SwipeBounceBackAnimation> createState() =>
      _SwipeBounceBackAnimationState();
}

class _SwipeBounceBackAnimationState extends State<SwipeBounceBackAnimation>
    with TickerProviderStateMixin {
  Offset offset = Offset.zero;
  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(controller);
    super.initState();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      offset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    animation = Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    controller.forward(from: 0);
    controller.addListener(() {
      setState(() => offset = animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: Transform.translate(offset: offset, child: widget.child),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// ✅ Hover Magnet Scale - العنصر يتضخم كلما اقترب الماوس منه
class HoverMagneticScale extends StatefulWidget {
  final Widget child;
  final double maxScale;

  const HoverMagneticScale({
    required this.child,
    this.maxScale = 1.08,
    super.key,
  });

  @override
  State<HoverMagneticScale> createState() => _HoverMagneticScaleState();
}

class _HoverMagneticScaleState extends State<HoverMagneticScale> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? widget.maxScale : 1.0,
        duration: const Duration(milliseconds: 300),
        child: widget.child,
      ),
    );
  }
}

/// ✅ Ripple Explosion - انفجار دائري عند الضغط
class RippleExplosionOnClick extends StatefulWidget {
  final Widget child;
  final Color color;

  const RippleExplosionOnClick({
    required this.child,
    this.color = Colors.blueAccent,
    super.key,
  });

  @override
  State<RippleExplosionOnClick> createState() => _RippleExplosionOnClickState();
}

class _RippleExplosionOnClickState extends State<RippleExplosionOnClick>
    with TickerProviderStateMixin {
  Offset? tapPosition;
  late AnimationController controller;
  late Animation<double> rippleRadius;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    rippleRadius = Tween<double>(
      begin: 0,
      end: 200,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    tapPosition = details.localPosition;
    controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: Stack(
        children: [
          widget.child,
          if (tapPosition != null)
            AnimatedBuilder(
              animation: controller,
              builder:
                  (_, __) => Positioned(
                    left: tapPosition!.dx - rippleRadius.value / 2,
                    top: tapPosition!.dy - rippleRadius.value / 2,
                    child: Container(
                      width: rippleRadius.value,
                      height: rippleRadius.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withOpacity(1 - controller.value),
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ✅ Rare & Visually Striking Animations for Viral Shorts

/// ✅ 1. Portal Warp Animation
class PortalWarpAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PortalWarpAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  @override
  State<PortalWarpAnimation> createState() => _PortalWarpAnimationState();
}

class _PortalWarpAnimationState extends State<PortalWarpAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> rotation;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    scale = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    rotation = Tween<double>(begin: -2 * pi, end: 0).animate(controller);
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.scale(
            scale: scale.value,
            child: Transform.rotate(angle: rotation.value, child: widget.child),
          ),
        );
      },
    );
  }
}

/// ✅ 2. Flare Pulse Explosion
class FlarePulseExplosion extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const FlarePulseExplosion({
    required this.child,
    this.color = Colors.orangeAccent,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<FlarePulseExplosion> createState() => _FlarePulseExplosionState();
}

class _FlarePulseExplosionState extends State<FlarePulseExplosion>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> flare;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    flare = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: controller,
          builder:
              (_, __) => Container(
                width: 100 * flare.value,
                height: 100 * flare.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(1 - controller.value),
                ),
              ),
        ),
        widget.child,
      ],
    );
  }
}

/// ✅ 3. Neural Scan Lines
class NeuralScanLines extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const NeuralScanLines({
    required this.child,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  @override
  State<NeuralScanLines> createState() => _NeuralScanLinesState();
}

class _NeuralScanLinesState extends State<NeuralScanLines>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: controller,
          builder:
              (_, __) => Align(
                alignment: Alignment(0, 2 * controller.value - 1),
                child: Container(
                  height: 2,
                  width: double.infinity,
                  color: Colors.cyanAccent.withOpacity(0.6),
                ),
              ),
        ),
      ],
    );
  }
}

/// ✅ 4. Blackhole Suck In
class BlackholeSuckIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlackholeSuckIn({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<BlackholeSuckIn> createState() => _BlackholeSuckInState();
}

class _BlackholeSuckInState extends State<BlackholeSuckIn>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> rotate;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    scale = Tween<double>(begin: 1.0, end: 0.0).animate(controller);
    rotate = Tween<double>(begin: 0.0, end: 4 * pi).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder:
          (_, child) => Transform.scale(
            scale: scale.value,
            child: Transform.rotate(angle: rotate.value, child: widget.child),
          ),
    );
  }
}

/// ✅ 5. Pixel Dissolve (Simplified version)
class PixelDissolve extends StatelessWidget {
  final Widget child;
  final bool dissolve;

  const PixelDissolve({required this.child, this.dissolve = true, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dissolve ? 0.0 : 1.0,
      duration: const Duration(seconds: 1),
      child: child,
    );
  }
}

/// ✅ 6. Glitch Transition (Basic flicker)
class GlitchTransition extends StatefulWidget {
  final Widget child;

  const GlitchTransition({required this.child, super.key});

  @override
  State<GlitchTransition> createState() => _GlitchTransitionState();
}

class _GlitchTransitionState extends State<GlitchTransition>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double dx = sin(controller.value * 10 * pi) * 5;
        return Transform.translate(offset: Offset(dx, 0), child: widget.child);
      },
    );
  }
}

/// ✅ 7. Warp Shatter - Placeholder for shatter effect
class WarpShatter extends StatelessWidget {
  final Widget child;

  const WarpShatter({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    // Advanced visual shatter requires custom rendering or shader support
    return child;
  }
}

// 📁 File: rare_ui_animations.dart
// ✅ Rare & Visually Striking Animations for Viral Shorts

/// ✅ 8. Glass Break Explosion
class GlassBreakExplosion extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlassBreakExplosion({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<GlassBreakExplosion> createState() => _GlassBreakExplosionState();
}

class _GlassBreakExplosionState extends State<GlassBreakExplosion>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> shake;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    shake = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticIn));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder:
          (_, __) => Transform(
            transform: Matrix4.rotationZ(sin(shake.value * pi / 180)),
            child: Opacity(
              opacity: 1.0 - controller.value,
              child: widget.child,
            ),
          ),
    );
  }
}

/// ✅ 9. Liquid Drop Splash
class LiquidDropSplash extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const LiquidDropSplash({
    required this.child,
    this.duration = const Duration(milliseconds: 900),
    super.key,
  });

  @override
  State<LiquidDropSplash> createState() => _LiquidDropSplashState();
}

class _LiquidDropSplashState extends State<LiquidDropSplash>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleY;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    scaleY = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 0.4),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 0.3),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleY,
      alignment: Alignment.bottomCenter,
      child: widget.child,
    );
  }
}

/// ✅ 10. Time Freeze Zoom
class TimeFreezeZoom extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const TimeFreezeZoom({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<TimeFreezeZoom> createState() => _TimeFreezeZoomState();
}

class _TimeFreezeZoomState extends State<TimeFreezeZoom>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> zoom;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    zoom = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: controller, curve: Curves.linearToEaseOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: zoom, child: widget.child);
  }
}

/// ✅ 11. Lightning Strike Reveal
class LightningStrikeReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const LightningStrikeReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<LightningStrikeReveal> createState() => _LightningStrikeRevealState();
}

class _LightningStrikeRevealState extends State<LightningStrikeReveal>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> flicker;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    flicker = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flicker,
      builder:
          (_, __) => Opacity(
            opacity: (flicker.value * sin(flicker.value * 20)).abs(),
            child: widget.child,
          ),
    );
  }
}

/// ✅ 12. Swipe Curtain Unfold
class SwipeCurtainUnfold extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SwipeCurtainUnfold({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<SwipeCurtainUnfold> createState() => _SwipeCurtainUnfoldState();
}

class _SwipeCurtainUnfoldState extends State<SwipeCurtainUnfold>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> slideIn;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    slideIn = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: Offset(slideIn.value, 0),
      child: widget.child,
    );
  }
}

/// ✅ 13. Echo Pop
class EchoPop extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const EchoPop({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<EchoPop> createState() => _EchoPopState();
}

class _EchoPopState extends State<EchoPop>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> opacity;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    scale = Tween<double>(begin: 1.0, end: 1.1).animate(controller);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// ✅ 14. X-Ray Reveal
class XRayReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const XRayReveal({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<XRayReveal> createState() => _XRayRevealState();
}

class _XRayRevealState extends State<XRayReveal>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.0),
          ],
          stops: [controller.value - 0.1, controller.value, controller.value + 0.1],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: widget.child,
    );
  }
}

/// ✅ 15. Card Flip Cascade (simplified)
class CardFlipCascade extends StatefulWidget {
  final List<Widget> cards;

  const CardFlipCascade({required this.cards, super.key});

  @override
  State<CardFlipCascade> createState() => _CardFlipCascadeState();
}

class _CardFlipCascadeState extends State<CardFlipCascade> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.cards.length, (index) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: pi, end: 0.0),
          duration: Duration(milliseconds: 500 + index * 200),
          builder: (_, double val, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(val),
            child: child,
          ),
          child: widget.cards[index],
        );
      }),
    );
  }
}

/// ✅ 16. Electric Shock Flicker
class ElectricShockFlicker extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ElectricShockFlicker({
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  @override
  State<ElectricShockFlicker> createState() => _ElectricShockFlickerState();
}

class _ElectricShockFlickerState extends State<ElectricShockFlicker>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: TweenSequence([
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.2),
        TweenSequenceItem(tween: ConstantTween(0.3), weight: 0.1),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.2),
        TweenSequenceItem(tween: ConstantTween(0.6), weight: 0.1),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.4),
      ]).animate(controller),
      child: widget.child,
    );
  }
}

/// ✅ 17. Tornado Spin Collapse
class TornadoSpinCollapse extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const TornadoSpinCollapse({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<TornadoSpinCollapse> createState() => _TornadoSpinCollapseState();
}

class _TornadoSpinCollapseState extends State<TornadoSpinCollapse>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotate;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    rotate = Tween<double>(begin: 0, end: 10 * pi).animate(controller);
    scale = Tween<double>(begin: 1.0, end: 0.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Transform.rotate(
        angle: rotate.value,
        child: Transform.scale(scale: scale.value, child: widget.child),
      ),
    );
  }
}


/// ✅ 25. 3D Pop In
class ThreeDPopIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ThreeDPopIn({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<ThreeDPopIn> createState() => _ThreeDPopInState();
}

class _ThreeDPopInState extends State<ThreeDPopIn>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> depth;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    depth = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scale(depth.value, depth.value, 1.0),
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}

/// ✅ 18. Mirror Slide Reveal
class MirrorSlideReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const MirrorSlideReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  @override
  State<MirrorSlideReveal> createState() => _MirrorSlideRevealState();
}

class _MirrorSlideRevealState extends State<MirrorSlideReveal>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> slide;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    slide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutExpo),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: slide,
            builder: (_, __) => FractionalTranslation(
              translation: Offset(slide.value, 0),
              child: Container(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// ✅ 19. Fire Flicker Glow
class FireFlickerGlow extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FireFlickerGlow({
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  @override
  State<FireFlickerGlow> createState() => _FireFlickerGlowState();
}

class _FireFlickerGlowState extends State<FireFlickerGlow>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> glow;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    glow = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(glow.value),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// ✅ 20. Particle Rise Reveal (basic vertical lift)
class ParticleRiseReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ParticleRiseReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<ParticleRiseReveal> createState() => _ParticleRiseRevealState();
}

class _ParticleRiseRevealState extends State<ParticleRiseReveal>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> rise;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    rise = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: rise, child: widget.child);
  }
}





/// ✅ 26. Sparkling Frame Animation
class SparklingFrame extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SparklingFrame({
    required this.child,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<SparklingFrame> createState() => _SparklingFrameState();
}

class _SparklingFrameState extends State<SparklingFrame>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.amber.withOpacity((sin(controller.value * 2 * pi) + 1) / 2),
          width: 2,
        ),
      ),
      child: widget.child,
    );
  }
}

/// ✅ 27. Glowing Edge Pulse
class GlowingEdgePulse extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlowingEdgePulse({
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  @override
  State<GlowingEdgePulse> createState() => _GlowingEdgePulseState();
}

class _GlowingEdgePulseState extends State<GlowingEdgePulse>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> glow;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    glow = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan.withOpacity(glow.value), width: 3),
      ),
      child: widget.child,
    );
  }
}

/// ✅ 28. Slide & Rotate Entrance
class SlideRotateEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SlideRotateEntrance({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<SlideRotateEntrance> createState() => _SlideRotateEntranceState();
}

class _SlideRotateEntranceState extends State<SlideRotateEntrance>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  late Animation<double> rotate;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    offset = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    rotate = Tween<double>(begin: pi / 4, end: 0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: AnimatedBuilder(
        animation: rotate,
        builder: (_, child) => Transform.rotate(
          angle: rotate.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// ✅ 29. Glow Expand Reveal
class GlowExpandReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlowExpandReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  @override
  State<GlowExpandReveal> createState() => _GlowExpandRevealState();
}

class _GlowExpandRevealState extends State<GlowExpandReveal>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> size;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    size = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: size,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 30,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// ✅ 30. Elastic Slide Drop
class ElasticSlideDrop extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ElasticSlideDrop({
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<ElasticSlideDrop> createState() => _ElasticSlideDropState();
}

class _ElasticSlideDropState extends State<ElasticSlideDrop>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> drop;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    drop = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: drop, child: widget.child);
  }
}



// ✅ AnimatedWrapper switch-case snippet (Extended to 30)
Widget animatedWrapper(UiAnimationType type, Widget child) {
  switch (type) {
    case UiAnimationType.portalWarp:
      return PortalWarpAnimation(child: child);
    case UiAnimationType.flarePulseExplosion:
      return FlarePulseExplosion(child: child);
    case UiAnimationType.neuralScanLines:
      return NeuralScanLines(child: child);
    case UiAnimationType.blackholeSuckIn:
      return BlackholeSuckIn(child: child);
    case UiAnimationType.pixelDissolve:
      return PixelDissolve(child: child);
    case UiAnimationType.glitchTransition:
      return GlitchTransition(child: child);
    case UiAnimationType.warpShatter:
      return WarpShatter(child: child);
    case UiAnimationType.glassBreakExplosion:
      return GlassBreakExplosion(child: child);
    case UiAnimationType.liquidDropSplash:
      return LiquidDropSplash(child: child);
    case UiAnimationType.timeFreezeZoom:
      return TimeFreezeZoom(child: child);
    case UiAnimationType.lightningStrikeReveal:
      return LightningStrikeReveal(child: child);
    case UiAnimationType.swipeCurtainUnfold:
      return SwipeCurtainUnfold(child: child);
    case UiAnimationType.echoPop:
      return EchoPop(child: child);
    case UiAnimationType.xRayReveal:
      return XRayReveal(child: child);
    case UiAnimationType.cardFlipCascade:
      return CardFlipCascade(cards: [child]);
    case UiAnimationType.electricShockFlicker:
      return ElectricShockFlicker(child: child);
    case UiAnimationType.tornadoSpinCollapse:
      return TornadoSpinCollapse(child: child);
    case UiAnimationType.mirrorSlideReveal:
      return MirrorSlideReveal(child: child);
    case UiAnimationType.fireFlickerGlow:
      return FireFlickerGlow(child: child);
    case UiAnimationType.particleRiseReveal:
      return ParticleRiseReveal(child: child);
    case UiAnimationType.threeDPopIn:
      return ThreeDPopIn(child: child);
    case UiAnimationType.sparklingFrame:
      return SparklingFrame(child: child);
    case UiAnimationType.glowingEdgePulse:
      return GlowingEdgePulse(child: child);
    case UiAnimationType.slideRotateEntrance:
      return SlideRotateEntrance(child: child);
    case UiAnimationType.glowExpandReveal:
      return GlowExpandReveal(child: child);
    case UiAnimationType.elasticSlideDrop:
      return ElasticSlideDrop(child: child);
    default:
      return child;
  }
}

// ✅ Showcase Page Example for Testing Animations
// class AnimationShowcasePage extends StatelessWidget {
//   const AnimationShowcasePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final allTypes = UiAnimationType.values;
//     return Scaffold(
//       appBar: AppBar(title: const Text('🎬 Animation Showcase')),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: allTypes.length,
//         itemBuilder: (context, index) {
//           final type = allTypes[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12.0),
//             child: animatedWrapper(
//               type,
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.black87,
//                 ),
//                 child: Text(
//                   type.name,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// ✅ Animation Type Enum (Extended to 30)
// [... same as before ...]

// ✅ Showcase Page with Manual Trigger
class AnimationShowcasePage extends StatefulWidget {
  const AnimationShowcasePage({super.key});

  @override
  State<AnimationShowcasePage> createState() => _AnimationShowcasePageState();
}

class _AnimationShowcasePageState extends State<AnimationShowcasePage> {
  UiAnimationType? selectedType;

  @override
  Widget build(BuildContext context) {
    const allTypes = UiAnimationType.values;
    return Scaffold(
      appBar: AppBar(title: const Text('🎬 Animation Showcase')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allTypes.length,
        itemBuilder: (context, index) {
          final type = allTypes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Text(type.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: selectedType == type
                      ? animatedWrapper(
                          type,
                          Container(
                            key: ValueKey(type.name),
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.deepPurple.shade400,
                            ),
                            child: Text(
                              type.name,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade800,
                          ),
                          child: const Text('Idle', style: TextStyle(color: Colors.white54)),
                        ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => selectedType = type),
                  child: const Text('Play Animation'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



/*


✅ أنيميشنات غير مرئية (Visual Enhancements):
1. ShadowPulseAnimation
(نبض خفيف للظل يدي إحساس بالحيوية)

2. GradientPulseAnimation
(تدرج لوني بيتغير ببطء – ممتاز للخلفيات)

3. InnerGlowPulseAnimation
(توهّج داخلي يظهر ويختفي – تأثير ضوء ناعم)

4. NeumorphicPressAnimation
(ضغط مرئي يشبه الأزرار الغارقة – تصميم نيوفورمي)

✅ أنيميشنات متقدمة ومتميزة جدًا:
1. SwipeBounceBackAnimation
(عنصر بتسحبه وبيرجع مكانه بارتداد طبيعي)

2. HoverMagneticScale
(العنصر يجذب الماوس ويتضخم تدريجيًا عند الاقتراب)

3. SparkleTrailAnimation
(عند تحريك الماوس، يترك أثر مثل شرارات خلفه – Web only)

4. RippleExplosionOnClick
(عند الضغط، يظهر انفجار دائري يشبه الموجة المتوسعة)


USAGE EXAMPLES:
------------------
AnimatedWrapper(type: AnimationType.fade, child: YourWidget())
AnimatedWrapper(type: AnimationType.scrollAppear, child: MyWidget())
AnimatedWrapper(type: AnimationType.staggeredList, index: 2, child: MyWidget())
AnimatedGrid(children: [Card(), Card()], crossAxisCount: 2)

SwipeToDismiss(
  child: ListTile(title: Text("Swipe me")),
  onDismissed: () => print("Dismissed"),
)

*/
