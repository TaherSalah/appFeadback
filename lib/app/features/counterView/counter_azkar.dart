import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

import '../../core/shard/exports/all_exports.dart';

class AzkarCounter extends StatefulWidget {
  const AzkarCounter({super.key});

  @override
  State<AzkarCounter> createState() => _AzkarCounterState();
}

class _AzkarCounterState extends State<AzkarCounter> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                context.isTab ? 70 : 50),
            child: AppBar(
              leading: CupertinoNavigationBarBackButton(
                color: context.isDark
                    ? Colors.white
                    : Colors.black,
              ),
              centerTitle: true,
              title: Text(
                AppString.KCounter,
                   style: TextStyle(
                          fontFamily: "cairo",
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        context.isTab ? 12.sp : 18.sp),
              ),
            ),
          ),
          body: const CounterWidgetBuilder2()),
    );
  }
}

class CounterWidgetBuilder2 extends StatefulWidget {
  const CounterWidgetBuilder2({super.key});

  @override
  State<CounterWidgetBuilder2> createState() => _CounterWidgetBuilder2State();
}

class _CounterWidgetBuilder2State extends State<CounterWidgetBuilder2> {
  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTab;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // العنوان الرئيسي
              // Text(
              //   'سبحة الأذكار',
              //      style: TextStyle(
               //    fontFamily: "cairo",
              //     fontSize: isTablet ? 32.sp : 28.sp,
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 1.2,
              //   ),
              // ),
              // SizedBox(height: isTablet ? 20.h : 10.h),
              //
              // // شريط الأذكار
              // _buildAzkarBar(context),
              // SizedBox(height: isTablet ? 30.h : 20.h),

              // العداد
              Stack(
                children: [
                  // Positioned.fill(child:
                  //
                  //
                  // Container(
                  //   // height: MediaQuery.of(context).size.height,
                  //   width: MediaQuery.of(context).size.width,
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     image: const DecorationImage(image: AssetImage("assets/images/pattern.webp",),fit: BoxFit.cover,opacity: 0.3),
                  //
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: const BorderDirectional(
                  //       start: BorderSide(color: Color(0xffd6bb7a), width: 3),
                  //     ),
                  //     // color: Theme.of(context).cardColor,
                  //     color: AppThemeColors.cardBackgroundColor(context),
                  //   ),
                  //   child:SizedBox(),
                  // ),
                  // ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4), // غمّق الصورة
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // العداد المركزي
                      // _buildCounterDisplay(),

                      SizedBox(height: isTablet ? 15.h : 8.h),
                      
                      // أزرار التبديل (Tabs)
                      Consumer<AzkarProvider>(
                        builder: (context, provider, child) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 40.w : 24.w),
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A), // Darker background
                                borderRadius: BorderRadius.circular(25.r),
                                border: Border.all(color: const Color(0xFF334155), width: 1.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => provider.toggleRosaryMode(false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: !provider.isElectronicRosaryMode ? const Color(0xFF1E293B) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20.r),
                                          boxShadow: !provider.isElectronicRosaryMode ? [
                                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                                          ] : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'المسبحة التقليدية',
                                            style: TextStyle(
                                            fontFamily: "cairo",
                                              fontSize: isTablet ? 14.sp : 12.sp,
                                              color: !provider.isElectronicRosaryMode ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                              fontWeight: !provider.isElectronicRosaryMode ? FontWeight.bold : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => provider.toggleRosaryMode(true),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: provider.isElectronicRosaryMode ? const Color(0xFF1E293B) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20.r),
                                          boxShadow: provider.isElectronicRosaryMode ? [
                                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                                          ] : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'العداد الإلكتروني',
                                            style: TextStyle(
                                            fontFamily: "cairo",
                                              fontSize: isTablet ? 14.sp : 12.sp,
                                              color: provider.isElectronicRosaryMode ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                              fontWeight: provider.isElectronicRosaryMode ? FontWeight.bold : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      ),

                      SizedBox(height: isTablet ? 30.h : 15.h),

                      Consumer<AzkarProvider>(
                        builder: (context, provider, child) {
                          return provider.isElectronicRosaryMode
                              ? const ElectronicRosaryView()
                              : const TasbeehRealPlus();
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildAzkarBar(BuildContext context) {
    final isTablet = context.isTab;

    return SizedBox(
      height: isTablet ? 120.h : 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemCount: Azkary.azkarDescription.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showZikrDetails(context, index),
            child: Container(
              width: isTablet ? 140.w : 120.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF475569),
                  width: 1.5.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16.r : 12.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Azkary.azkarDescription[index],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: isTablet ? 12.sp : 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        '${Azkary.azkarCount[index]} مرة',
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: isTablet ? 10.sp : 8.sp,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showZikrDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(top: 50.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  Azkary.azkarDescription[index],
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        color: const Color(0xFF10B981),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${Azkary.azkarCount[index]} مرة',
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 14.sp,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      Azkary.azkarContent[index],
                      style: TextStyle(
                        fontFamily: "cairo",
                        fontSize: 16.sp,
                        color: const Color(0xFFCBD5E1),
                        height: 1.8,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    child: Text(
                      'تم',
                      style: TextStyle(
                        fontFamily: "cairo",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget buildCounterDisplay({dynamic counter}) {
  return Consumer<AzkarProvider>(
    builder: (context, controller, child) {
      bool isTablet = context.isTab;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // // تاج العداد
          // Icon(
          //   Icons.star_outlined,
          //   color: const Color(0xFFF59E0B),
          //   size: 30.sp,
          // ),
          // SizedBox(height: 10.h),

          // العداد
          Container(
            padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: const Color(0xFF475569),
                width: 3.w,
              ),
            ),
            child: Text(
              '$counter',
              style: TextStyle(
                fontFamily: "cairo",
                fontSize: isTablet ? 22.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          // SizedBox(height: 16.h),
          // // النص تحت العداد
          // Text(
          //   'عدد التسبيحات',
          //      style: TextStyle(
                      //    fontFamily: "cairo",
          //     fontSize: isTablet ? 18.sp : 16.sp,
          //     color: const Color(0xFFCBD5E1),
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
        ],
      );
    },
  );
}

class TasbeehRealPlus extends StatefulWidget {
  final bool isElectronic;
  const TasbeehRealPlus({this.isElectronic = false, super.key});
  @override
  State<TasbeehRealPlus> createState() => _TasbeehRealPlusState();
}

// كلاس للتأثيرات الجزيئية
class ParticleEffect {
  final double angle;
  final double distance;
  final double size;
  final Color? color;

  ParticleEffect({
    required this.angle,
    required this.distance,
    required this.size,
    this.color,
  });
}

class ZikrItem {
  final String text;
  final int targetCount;
  ZikrItem({required this.text, required this.targetCount});
}

class DhikrItem {
  final String text;
  final int count;

  DhikrItem({required this.text, required this.count});

  Map<String, dynamic> toJson() => {
        'text': text,
        'count': count,
      };

  factory DhikrItem.fromJson(Map<String, dynamic> json) =>
      DhikrItem(text: json['text'], count: json['count']);
}

class _TasbeehRealPlusState extends State<TasbeehRealPlus>
    with TickerProviderStateMixin {
  static const int beadsCount = 33;
  static const Duration animDur = Duration(milliseconds: 400);

  late AnimationController _moveController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late Animation<double> _moveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;

  int currentBead = 0;
  int _cycleCount = 0;
  final List<Offset> _beadPositions = [];
  final List<ParticleEffect> _particles = [];

  // 1. قائمة الأذكار + متغيرات التتبع
  final List<ZikrItem> zikrList = [
    ZikrItem(text: "سبحان الله", targetCount: 33),
    ZikrItem(text: "الحمد لله", targetCount: 33),
    ZikrItem(text: "الله أكبر", targetCount: 34),
    ZikrItem(text: "لا حول ولا قوة إلا بالله", targetCount: 100),
  ];

  int currentZikrIndex = 0;
  int currentZikrCount = 0;

  // باقي المتغيرات + انيميشن كما في كودك...

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: animDur,
      vsync: this,
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOutCubic,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _glowAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _shimmerAnimation =
        Tween<double>(begin: -2.0, end: 2.0).animate(_shimmerController);

    // تحميل الحالة من الـ Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AzkarProvider>(context, listen: false);
      setState(() {
        currentBead = provider.currentBead;
        _cycleCount = provider.cycleCount;
        currentZikrIndex = provider.currentZikrIndex;
        currentZikrCount = provider.currentZikrCount;
      });
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _calculateBeadPositions(Size size) {
    _beadPositions.clear();
    final double radius = size.width * 0.38;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (int i = 0; i < beadsCount; i++) {
      final angle = (2 * pi / beadsCount) * i - pi / 2;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      _beadPositions.add(Offset(x, y));
    }
  }

  void _moveToNextBead() {
    if (_moveController.isAnimating) return;
    HapticFeedback.mediumImpact();

    final provider = Provider.of<AzkarProvider>(context, listen: false);
    provider.incrementCount();

    setState(() {
      // زيادة العداد للذكر الحالي
      currentZikrCount++;

      // إذا وصلنا للعدد المطلوب لهذا الذكر → الانتقال للذكر التالي
      if (currentZikrCount >= zikrList[currentZikrIndex].targetCount) {
        // اختياري: effect دورة كاملة قبل الانتقال
        // _createCompletionEffect();

        // انتقال للذكر التالي
        if (currentZikrIndex < zikrList.length - 1) {
          currentZikrIndex++;
        } else {
          // إنتهت كل الأذكار — نبدأ من أول ذكر
          currentZikrIndex = 0;
        }
        currentZikrCount = 0;
      }

      // (اختياري) يمكنك إعادة تعيين _currentBead و _cycleCount إذا تريد
      currentBead = (currentBead + 1) % beadsCount;
      if (currentBead == 0) {
        _cycleCount++;
        HapticFeedback.heavyImpact();
        // تأثير خاص لإكمال دورة beads
        // _createCompletionEffect();
      }

      // حفظ الحالة في الـ Provider
      provider.updateTasbeehState(
        newCurrentZikrIndex: currentZikrIndex,
        newCurrentZikrCount: currentZikrCount,
        newCurrentBead: currentBead,
        newCycleCount: _cycleCount,
      );
    });

    _moveController.reset();
    _moveController.forward();
    _particleController.reset();
    _particleController.forward();
  }

  void _createParticleEffect() {
    final random = Random();
    for (int i = 0; i < 8; i++) {
      _particles.add(ParticleEffect(
        angle: (2 * pi / 8) * i + random.nextDouble() * 0.3,
        distance: 40 + random.nextDouble() * 30,
        size: 4 + random.nextDouble() * 6,
      ));
    }
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  // void _createCompletionEffect() {
  //   final random = Random();
  //   for (int i = 0; i < 20; i++) {
  //     _particles.add(ParticleEffect(
  //       angle: random.nextDouble() * 2 * pi,
  //       distance: 60 + random.nextDouble() * 80,
  //       size: 6 + random.nextDouble() * 10,
  //       color: i % 2 == 0 ? const Color(0xFFFBBF24) : const Color(0xFF10B981),
  //     ));
  //   }
  // }

  void _resetCounter() {
    HapticFeedback.heavyImpact();
    final provider = Provider.of<AzkarProvider>(context, listen: false);
    provider.restCount();

    setState(() {
      currentBead = 0;
      _cycleCount = 0;
      currentZikrIndex = 0;
      currentZikrCount = 0;
    });
    _moveController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTab;

    return InkWell(
      enableFeedback: false,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        _moveToNextBead();
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: isTablet ? 5.h : 20),

          // مؤشر الإحصائيات المحسّن
          FadeAnimation(
            delay: const Duration(milliseconds: 100),
            child: _buildStatsCard(isTablet),
          ),
          SizedBox(height: isTablet ? 30.h : 60),

          // المسبحة الدائرية
          FadeAnimation(
            delay: const Duration(milliseconds: 300),
            child: SizedBox(
              height: isTablet ? 420.h : 360.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                _calculateBeadPositions(size);

                return Stack(
                  children: [
                    // طبقة توهج خلفية متعددة الألوان
                    // Positioned.fill(
                    //   child: AnimatedBuilder(
                    //     animation: _glowAnimation,
                    //     builder: (context, child) {
                    //       return Transform.rotate(
                    //         angle: _glowAnimation.value * 2 * pi,
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             gradient: SweepGradient(
                    //               colors: [
                    //                 Colors.transparent,
                    //                 const Color(0xFF10B981).withOpacity(0.15),
                    //                 Colors.transparent,
                    //                 const Color(0xFF6366F1).withOpacity(0.15),
                    //                 Colors.transparent,
                    //                 const Color(0xFFFBBF24).withOpacity(0.15),
                    //                 Colors.transparent,
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),

                    // الحلقة الخارجية المزخرفة بتدرج متحرك
                    // Positioned.fill(
                    //   child: AnimatedBuilder(
                    //     animation: _shimmerAnimation,
                    //     builder: (context, child) {
                    //       return Container(
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           border: Border.all(
                    //             color: const Color(0xFF1E293B),
                    //             width: 5.w,
                    //           ),
                    //           // boxShadow: [
                    //           //   BoxShadow(
                    //           //     color: Colors.black.withOpacity(0.4),
                    //           //     blurRadius: 25,
                    //           //     spreadRadius: -5,
                    //           //   ),
                    //           //   BoxShadow(
                    //           //     color: const Color(0xFF10B981).withOpacity(0.2),
                    //           //     blurRadius: 40,
                    //           //     spreadRadius: 0,
                    //           //   ),
                    //           // ],
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),

                    // حلقة وسطى بزخارف إسلامية
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 3.w,
                                  //   gradient: LinearGradient(
                                  //     begin: Alignment.topLeft,
                                  //     end: Alignment.bottomRight,
                                  //     colors: [
                                  //       const Color(0xFF334155),
                                  //       const Color(0xFF475569),
                                  //       const Color(0xFF334155),
                                  //     ],
                                  //     stops: [
                                  //       0.0,
                                  //       (_glowAnimation.value + 0.5) % 1.0,
                                  //       1.0,
                                  //     ],
                                  //   ),
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF0F172A).withOpacity(0.3),
                                    const Color(0xFF0F172A).withOpacity(0.6),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // حلقة داخلية متوهجة
                    // Positioned.fill(
                    //   child: Padding(
                    //     padding: EdgeInsets.all(24.0),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         border: Border.all(
                    //           color: const Color(0xFF0067FF).withOpacity(0.5),
                    //           width: 1.5.w,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // خطوط زخرفية دائرية
                    ...List.generate(12, (index) {
                      final angle = (2 * pi / 12) * index;
                      return Positioned.fill(
                        child: Transform.rotate(
                          angle: angle,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 2.w,
                              height: 15.h,
                              margin: EdgeInsets.only(top: 8.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1.r),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // الخرزات
                    if (!widget.isElectronic)
                      ...List.generate(beadsCount, (index) {
                        final pos = _beadPositions[index];
                        final isPassed = index < currentBead ||
                            (currentBead == 0 && index < beadsCount);
                        final isNext = index == (currentBead + 1) % beadsCount;

                        return Positioned(
                          left: pos.dx - 13,
                          top: pos.dy - 13,
                          child: _buildBead(
                            isPassed: isPassed && currentBead > 0,
                            isNext: isNext,
                            index: index,
                            size: 30,
                          ),
                        );
                      }),

                    // الخرزة النشطة المتحركة
                    if (!widget.isElectronic && _beadPositions.isNotEmpty)
                      AnimatedBuilder(
                        animation: _moveAnimation,
                        builder: (context, child) {
                          const beadSize = 33.0;
                          final startPos = _beadPositions[currentBead];
                          final nextPos =
                              _beadPositions[(currentBead + 1) % beadsCount];

                          final x = startPos.dx +
                              (nextPos.dx - startPos.dx) *
                                  _moveAnimation.value -
                              beadSize / 2;
                          final y = startPos.dy +
                              (nextPos.dy - startPos.dy) *
                                  _moveAnimation.value -
                              beadSize / 2;

                          return Positioned(
                            left: x,
                            top: y,
                            child: _buildActiveBead(size: beadSize),
                          );
                        },
                      ),

                    // جزيئات التأثير
                    if (!widget.isElectronic && _particles.isNotEmpty)
                      ...(_beadPositions.isNotEmpty
                          ? _particles.map((particle) {
                              final centerX = size.width / 2;
                              final centerY = size.height / 2;
                              return AnimatedBuilder(
                                animation: _particleAnimation,
                                builder: (context, child) {
                                  final distance = particle.distance *
                                      _particleAnimation.value;
                                  final opacity =
                                      1.0 - _particleAnimation.value;
                                  return Positioned(
                                    left: centerX +
                                        cos(particle.angle) * distance -
                                        particle.size / 2,
                                    top: centerY +
                                        sin(particle.angle) * distance -
                                        particle.size / 2,
                                    child: Container(
                                      width: particle.size,
                                      height: particle.size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (particle.color ??
                                                const Color(0xFFFBBF24))
                                            .withOpacity(opacity),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (particle.color ??
                                                    const Color(0xFFFBBF24))
                                                .withOpacity(opacity * 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          : []),

                    // الزر المركزي المحسّن
                    // Center(
                    //   child: _buildCenterButton(isTablet),
                    // ),
                    // Center(
                    //   child: Card(
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           TextWidget(title: zikrList[currentZikrIndex].text),
                    //           TextWidget(
                    //             title: "${currentZikrCount} / ${zikrList[currentZikrIndex].targetCount} مرة",
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Center(child: buildCounterDisplay(counter: currentZikrCount))
                  ],
                );
              },
            ),
          ),),

          SizedBox(height: isTablet ? 35.h : 75),

          // أزرار التحكم المحدثة
          FadeAnimation(
            delay: const Duration(milliseconds: 500),
            child: _buildControlButtons(isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isTablet) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            // border: Border.all(
            //   // width: 1.w,
            //   color: Colors.amberAccent.shade400
            //   // gradient: LinearGradient(
            //   //   colors: [
            //   //     const Color(0xFF10B981).withOpacity(0.5),
            //   //     const Color(0xFF6366F1).withOpacity(0.5),
            //   //   ],
            //   //   transform: GradientRotation(_glowAnimation.value * 2 * pi),
            //   // ),
            // ),
            // boxShadow: [
            //   BoxShadow(
            //     color: const Color(0xFF10B981).withOpacity(0.2),
            //     blurRadius: 25,
            //     spreadRadius: 3,
            //   ),
            //   BoxShadow(
            //     color: const Color(0xFF6366F1).withOpacity(0.15),
            //     blurRadius: 35,
            //     spreadRadius: 5,
            //   ),
            // ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة الدورة مع توهج
              // Expanded(
              //   child: Container(
              //     padding: EdgeInsets.all(10.r),
              //     decoration: BoxDecoration(
              //       gradient: RadialGradient(
              //         colors: [
              //           const Color(0xFF10B981).withOpacity(0.3),
              //           const Color(0xFF10B981).withOpacity(0.1),
              //         ],
              //       ),
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: const Color(0xFF10B981).withOpacity(0.5),
              //           blurRadius: 15,
              //           spreadRadius: 2,
              //         ),
              //       ],
              //     ),
              //     // child: Icon(
              //     //   Icons.autorenew_rounded,
              //     //   color: const Color(0xFF10B981),
              //     //   size: 22.sp,
              //     // ),
              //   ),
              // ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'الدورة الحالية',
                    style: TextStyle(
                      fontFamily: "cairo",
                      fontSize:isTablet?10.sp: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.2),
                          const Color(0xFF10B981).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      '$_cycleCount',
                      style: TextStyle(
                        fontFamily: "cairo",
                        fontSize:isTablet?15.sp :20.sp,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 24.w),

              // فاصل متوهج
              Container(
                width: 2.5.w,
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF475569),
                      Color(0xFF64748B),
                      Color(0xFF475569),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              SizedBox(width: 24.w),

              // أيقونة الخرزة مع توهج
              // Container(
              //   padding: EdgeInsets.all(10.r),
              //   decoration: BoxDecoration(
              //     gradient: RadialGradient(
              //       colors: [
              //         const Color(0xFF6366F1).withOpacity(0.3),
              //         const Color(0xFF6366F1).withOpacity(0.1),
              //       ],
              //     ),
              //     shape: BoxShape.circle,
              //     boxShadow: [
              //       BoxShadow(
              //         color: const Color(0xFF6366F1).withOpacity(0.5),
              //         blurRadius: 15,
              //         spreadRadius: 2,
              //       ),
              //     ],
              //   ),
              //   child: Icon(
              //     Icons.circle,
              //     color: const Color(0xFF6366F1),
              //     size: 22.sp,
              //   ),
              // ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'الخرزة',
                    style: TextStyle(
                      fontFamily: "cairo",
                      fontSize:isTablet?10.sp: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.2),
                          const Color(0xFF6366F1).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      '${currentBead + 1} / $beadsCount',
                      style: TextStyle(
                        fontFamily: "cairo",
                        fontSize:isTablet?15.sp :20.sp,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBead({
    required bool isPassed,
    required bool isNext,
    required int index,
    required double size,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPassed
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              )
            : isNext
                ? const RadialGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF334155),
                      Color(0xFF1E293B),
                    ],
                  ),
        boxShadow: isPassed
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : isNext
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
        border: Border.all(
          color: isPassed
              ? const Color(0xFF34D399)
              : isNext
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF475569),
          width: isPassed
              ? 3.w
              : isNext
                  ? 2.5.w
                  : 1.5.w,
        ),
      ),
      child: isPassed
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            )
          : isNext
              ? Center(
                  child: Container(
                    width: size * 0.4,
                    height: size * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildActiveBead({required double size}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // توهج خارجي متعدد الطبقات
              // Container(
              //   width: size * 1.6,
              //   height: size * 1.6,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     gradient: RadialGradient(
              //       colors: [
              //         const Color(0xFFFBBF24).withOpacity(0.3),
              //         Colors.transparent,
              //       ],
              //     ),
              //   ),
              // ),
              Container(
                width: size * 1.3,
                height: size * 1.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // الخرزة الرئيسية
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      Color(0xFFFDE047),
                      Color(0xFFFBBF24),
                      Color(0xFFF59E0B),
                      Color(0xFFFBBF24),
                      Color(0xFFFDE047),
                    ],
                    transform: GradientRotation(_glowAnimation.value * 2 * pi),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: const Color(0xFFFBBF24).withOpacity(0.8),
                  //     blurRadius: 30,
                  //     spreadRadius: 5,
                  //   ),
                  //   BoxShadow(
                  //     color: const Color(0xFFF59E0B),
                  //     blurRadius: 20,
                  //     spreadRadius: 2,
                  //   ),
                  // ],
                  border: Border.all(
                    color: Colors.white,
                    width: 4.w,
                  ),
                ),
                child: Stack(
                  children: [
                    // انعكاس الضوء
                    Positioned(
                      top: size * 0.10,
                      left: size * 0.10,
                      child: Container(
                        width: size * 0.3,
                        height: size * 0.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // الرقم في المركز
                    Center(
                      child: Container(
                        width: size * 0.55,
                        height: size * 0.55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.95),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${currentBead + 1}',
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: context.isTab
                                  ? 18.sp
                                  : 11.sp,
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFFFBBF24).withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterButton(bool isTablet) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) {
            _moveToNextBead();
          },
          onTapCancel: () => setState(() {}),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // توهج خارجي نابض
              Container(
                width: isTablet ? 180 : 160,
                height: isTablet ? 180 : 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1)
                          .withOpacity(0.3 * _pulseAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: isTablet ? 150 : 135,
                height: isTablet ? 150 : 135,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6)
                          .withOpacity(0.4 * _pulseAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // الزر الرئيسي
              Container(
                width: isTablet ? 130 : 110,
                height: isTablet ? 130 : 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                    transform: GradientRotation(_shimmerAnimation.value),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.6),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 12,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2.w,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF4F46E5),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // بريق متحرك
                        Positioned.fill(
                          child: Transform.rotate(
                            angle: _shimmerAnimation.value * pi,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // المحتوى
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: Icon(
                                  Icons.touch_app_rounded,
                                  size: 32.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'سبِّح',
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  fontSize: 15.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.favorite_rounded,
              label: 'تسبيح سريع',
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              glowColor: const Color(0xFF10B981),
              onTap: _moveToNextBead,
              isTablet: isTablet,
            ),
            SizedBox(width: 12.w),
            Container(
              width: 2.5.w,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF334155),
                    Color(0xFF475569),
                    Color(0xFF334155),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            _buildControlButton(
              icon: Icons.refresh_rounded,
              label: 'إعادة تعيين',
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              glowColor: const Color(0xFFEF4444),
              onTap: _resetCounter,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10.w : 16.w,
            vertical: isTablet ? 10.h : 16.h,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container(
              //   padding: EdgeInsets.all(6.r),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Colors.white.withOpacity(0.2),
              //   ),
              //   child: Icon(
              //     icon,
              //     size: isTablet ? 22.sp : 20.sp,
              //     color: Colors.white,
              //   ),
              // ),
              // SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: isTablet ? 10.sp : 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElectronicRosaryView extends StatefulWidget {
  const ElectronicRosaryView({super.key});

  @override
  State<ElectronicRosaryView> createState() => _ElectronicRosaryViewState();
}

class _ElectronicRosaryViewState extends State<ElectronicRosaryView> with SingleTickerProviderStateMixin {
  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.heavyImpact();
    Provider.of<AzkarProvider>(context, listen: false).incrementCount();
    _btnController.forward().then((value) => _btnController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTab;
    final provider = Provider.of<AzkarProvider>(context);

    return Column(
      children: [
        SizedBox(height: isTablet ? 60.h : 40.h),
        Center(
          child: Container(
            width: isTablet ? 300.w : 240.w,

            padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
            decoration: BoxDecoration(
              color: const Color(0xFF111111), // Black body
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(80.r),
                bottom: Radius.circular(120.r),
              ),
              border: Border.all(color: const Color(0xFF00ADB5), width: 8.w), // Cyan border exactly like image
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25, offset: const Offset(0, 15))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LCD Screen displaying the counter
                Container(
                  width: double.infinity,
                  height: isTablet ? 90.h : 70.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90A492), // Retro LCD greenish-grey background
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3.w), // Gold inner border
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5) // Simulated depth
                    ],
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${provider.counter}',
                    style: TextStyle(
                      fontFamily: "cairo",
                      fontSize: isTablet ? 55.sp : 45.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Text "تسبيح"
                Text(
                  'تسبيح',
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: isTablet ? 28.sp : 22.sp,
                    color: const Color(0xFFD4AF37), // Gold
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.h),
                // Small buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('إعادة تعيين', style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 10.sp, fontFamily: "cairo", fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                             HapticFeedback.heavyImpact();
                             provider.restCount();
                          },
                          child: Container(
                            width: 20.w, height: 20.w,
                            decoration: BoxDecoration(
                              color: Colors.red.shade600, 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 2))]
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('الوضع الخفي', style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 10.sp, fontFamily: "cairo", fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            width: 20.w, height: 20.w,
                            decoration: BoxDecoration(
                              color: Colors.red.shade600, 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 2))]
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                // Big Red Tally Button
                GestureDetector(
                  onTap: _onTap,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.92).animate(
                      CurvedAnimation(parent: _btnController, curve: Curves.easeOut)
                    ),
                    child: Container(
                      width: isTablet ? 120.w : 90.w,
                      height: isTablet ? 120.w : 90.w,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600, // Vibrant red
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.5),
                          radius: 1.0,
                          colors: [
                            Colors.red.shade400, // Highlight
                            Colors.red.shade800, // Base red
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
                          const BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 8)), // Shadow below button
                        ],
                        border: Border.all(color: const Color(0xFF550000), width: 3.w), // Dark red rim
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
