import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../../core/shard/constanc/app_string.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/widgets/custom_text_widget.dart';

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
          // appBar: PreferredSize(
          //   preferredSize: Size.fromHeight(
          //       MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          //   child: AppBar(
          //     leading: const CupertinoNavigationBarBackButton(
          //       color: Colors.black,
          //     ),
          //     centerTitle: true,
          //     title: Text(
          //       AppString.KCounter,
          //       style: GoogleFonts.cairo(
          //           color: Colors.green,
          //           fontWeight: FontWeight.bold,
          //           fontSize:
          //               MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          //     ),
          //   ),
          // ),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
            child: AppBar(
              leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,),
              centerTitle: true,
              title: Text(
                AppString.KCounter,
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
              ),
            ), ),
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
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // العنوان الرئيسي
            // Text(
            //   'سبحة الأذكار',
            //   style: GoogleFonts.cairo(
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
                Positioned.fill(child: Image.asset("assets/images/dd.jpg",fit: BoxFit.cover,)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // العداد المركزي
                    // _buildCounterDisplay(),

                    SizedBox(height: isTablet ? 40.h : 2.h),

                    // السبحه
                    TasbeehRealPlus(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarBar(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF334155),
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
                      style: GoogleFonts.cairo(
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
                        style: GoogleFonts.cairo(
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
                  style: GoogleFonts.cairo(
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
                        style: GoogleFonts.cairo(
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
                      style: GoogleFonts.cairo(
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
                      style: GoogleFonts.cairo(
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
      bool isTablet = ResponsiveUtil.isTablet(context);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,

        crossAxisAlignment:  CrossAxisAlignment.center,
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
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
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
              '${counter}',
              style: GoogleFonts.cairo(
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
          //   style: GoogleFonts.cairo(
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
  const TasbeehRealPlus({super.key});
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

class _TasbeehRealPlusState extends State<TasbeehRealPlus> with TickerProviderStateMixin {
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
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

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
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(_shimmerController);
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
    });
    _moveController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return InkWell(
      enableFeedback: false,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        _moveToNextBead();
        setState(() {

        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height:isTablet? 5.h:20),

          // مؤشر الإحصائيات المحسّن
          _buildStatsCard(isTablet),
          SizedBox(height:isTablet? 30.h:60),

          // المسبحة الدائرية
          SizedBox(
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
                        padding: EdgeInsets.all(12.0),
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
                    ...List.generate(beadsCount, (index) {
                      final pos = _beadPositions[index];
                      final isPassed = index < currentBead || (currentBead == 0 && index < beadsCount);
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
                    if (_beadPositions.isNotEmpty)
                      AnimatedBuilder(
                        animation: _moveAnimation,
                        builder: (context, child) {
                          // final startPos = _beadPositions[_currentBead];
                          // final nextPos = _beadPositions[(_currentBead + 1) % beadsCount];
                          //
                          // final x = startPos.dx + (nextPos.dx - startPos.dx) * _moveAnimation.value;
                          // final y = startPos.dy + (nextPos.dy - startPos.dy) * _moveAnimation.value;

                          // return Positioned(
                          //   left: x - 25,
                          //   top: y - 13,
                          //   child: _buildActiveBead(size:33),
                          // );
                          final beadSize = 33.0;
                          final startPos = _beadPositions[currentBead];
                          final nextPos = _beadPositions[(currentBead + 1) % beadsCount];

                          final x = startPos.dx + (nextPos.dx - startPos.dx) * _moveAnimation.value - beadSize/2;
                          final y = startPos.dy + (nextPos.dy - startPos.dy) * _moveAnimation.value - beadSize/2;

                          return Positioned(
                            left: x,
                            top: y,
                            child: _buildActiveBead(size: beadSize),
                          );

                        },
                      ),

                    // جزيئات التأثير
                    if (_particles.isNotEmpty)
                      ...(_beadPositions.isNotEmpty
                          ? _particles.map((particle) {
                        final centerX = size.width / 2;
                        final centerY = size.height / 2;
                        return AnimatedBuilder(
                          animation: _particleAnimation,
                          builder: (context, child) {
                            final distance = particle.distance * _particleAnimation.value;
                            final opacity = 1.0 - _particleAnimation.value;
                            return Positioned(
                              left: centerX + cos(particle.angle) * distance - particle.size / 2,
                              top: centerY + sin(particle.angle) * distance - particle.size / 2,
                              child: Container(
                                width: particle.size,
                                height: particle.size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (particle.color ?? const Color(0xFFFBBF24)).withOpacity(opacity),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (particle.color ?? const Color(0xFFFBBF24)).withOpacity(opacity * 0.5),
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
                    Center(child: buildCounterDisplay(counter: currentBead + 1))
                  ],
                );
              },
            ),
          ),

          SizedBox(height:isTablet? 35.h:75),

          // أزرار التحكم المحدثة
          _buildControlButtons(isTablet),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
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
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,


                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
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
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
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
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF475569),
                      const Color(0xFF64748B),
                      const Color(0xFF475569),
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
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
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
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
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
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
        )
            : isNext
            ? RadialGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF4F46E5),
          ],
        )
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF334155),
            const Color(0xFF1E293B),
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
          width: isPassed ? 3.w : isNext ? 2.5.w : 1.5.w,
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
                    colors: [
                      const Color(0xFFFDE047),
                      const Color(0xFFFBBF24),
                      const Color(0xFFF59E0B),
                      const Color(0xFFFBBF24),
                      const Color(0xFFFDE047),
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
                            style: GoogleFonts.cairo(
                              fontSize:ResponsiveUtil.isTablet(context)? 18.sp:11.sp,
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFBBF24).withOpacity(0.5),
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
                      const Color(0xFF6366F1).withOpacity(0.3 * _pulseAnimation.value),
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
                      const Color(0xFF8B5CF6).withOpacity(0.4 * _pulseAnimation.value),
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
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF6366F1),
                      const Color(0xFF4F46E5),
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF4F46E5),
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
                                style: GoogleFonts.cairo(
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF334155),
                    const Color(0xFF475569),
                    const Color(0xFF334155),
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
            horizontal: isTablet ? 20.w : 16.w,
            vertical: isTablet ? 18.h : 16.h,
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
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 14.sp : 13.sp,
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


// class TasbeehRealPlus extends StatefulWidget {
//   const TasbeehRealPlus({super.key});
//   @override
//   State<TasbeehRealPlus> createState() => _TasbeehRealPlusState();
// }
//
// class _TasbeehRealPlusState extends State<TasbeehRealPlus> with SingleTickerProviderStateMixin {
//   static const int stopsCount = 12;
//   static const double beadSize = 44;
//   static const Duration dur = Duration(milliseconds: 230);
//
//   late final AnimationController _c = AnimationController(vsync: this, duration: dur);
//   late Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
//
//   int count = 0;
//   double curDist = 0;
//   double step = 0;
//   Size area = Size.zero;
//
//   void _tap() {
//     if (_c.isAnimating) return;
//     HapticFeedback.lightImpact();
//     setState(() => count++);
//     final target = (curDist + step) % _pathLen();
//     _a = Tween(begin: curDist, end: target)
//         .chain(CurveTween(curve: Curves.easeOutBack)) // لمسة ارتداد خفيفة
//         .animate(_c)
//       ..addStatusListener((s) {
//         if (s == AnimationStatus.completed) setState(() => curDist = target);
//       });
//     _c.forward(from: 0);
//   }
//
//   Path _buildPath(Size s) {
//     final y = s.height * 0.62;
//     return Path()
//       ..moveTo(0, y - 8)
//       ..quadraticBezierTo(s.width * .32, y + 34, s.width * .68, y - 10)
//       ..quadraticBezierTo(s.width * .88, y - 24, s.width, y + 6);
//   }
//
//   double _pathLen() => _buildPath(area).computeMetrics().first.length;
//
//   List<_StopPoint> _stops(Size s) {
//     final m = _buildPath(s).computeMetrics().first;
//     final len = m.length;
//     step = len / (stopsCount - 1);
//     return List.generate(stopsCount, (i) {
//       final t = m.getTangentForOffset(i * step)!;
//       return _StopPoint(
//         pos: t.position,
//         angle: t.angle,          // دوران مع اتجاه الخيط
//         normal: Offset(-t.vector.dy, t.vector.dx), // عمودي على المماس
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isTablate = MediaQuery.sizeOf(context).width > 600;
//
//     final cs = Theme.of(context).colorScheme;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _tap,
//         child: LayoutBuilder(builder: (context, box) {
//           area = Size(box.maxWidth, 130);
//           final path = _buildPath(area);
//           final metric = path.computeMetrics().first;
//           final len = metric.length;
//           final stops = _stops(area);
//
//           // موضع الخرزة المتحركة
//           final mover = AnimatedBuilder(
//             animation: _a,
//             builder: (_, __) {
//               final d = _c.isAnimating ? _a.value : curDist;
//               final tan = metric.getTangentForOffset(d % len)!;
//               final pos = tan.position;
//               final normal = Offset(-tan.vector.dy, tan.vector.dx);
//               return _placedBead(
//                 pos: pos + normal * 2,             // تلامس مع الخيط
//                 angle: tan.angle,
//                 baseSize: beadSize,
//                 color: cs.primary,
//               );
//             },
//           );
//
//           return Column(
//             spacing: ResponsiveUtil.isTablet(context)?60: 40,
//             children: [
//               const SizedBox(height: 12),
//
//               Card(
//                 elevation: 10,
//                 color: Colors.black.withOpacity(0.5),
//                 shape: const OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Color(AppStyle.whiteColor), width: 5)),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   padding: const EdgeInsets.all(25),
//                   child: Text('$count',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.cairo(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 25.sp,
//                           color: Colors.white)),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: area.height,
//                 width: area.width,
//                 child: Stack(
//                   children: [
//
//                     // ظل الخيط
//                     Positioned.fill(child: CustomPaint(painter: _CordPainter(path, Colors.black12, 4))),
//                     // الخيط
//                     Positioned.fill(child: CustomPaint(painter: _CordPainter(path, Colors.black26, 3))),
//                     // الخرز الثابت
//                     ...stops.map((s) => _placedBead(
//                       pos: s.pos + s.normal * 2,
//                       angle: s.angle,
//                       baseSize: beadSize,
//                       color: cs.primary.withOpacity(.65),
//                     )),
//                     // الخرزة المتحركة فوق
//                     mover,
//                   ],
//                 ),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap:_tap,
//                       child: CircleAvatar(
//                           radius:isTablate?50: 35,
//                           backgroundColor: Colors.white,
//                           child: Text(AppString.KSabhText,
//                               style: GoogleFonts.cairo(
//                                   fontSize: isTablate ? 17.sp :23.sp, color: Colors.black))),
//                     ),
//                     SizedBox(
//                       width: 85.w,
//                     ),
//                     InkWell(
//                       onTap: () => setState(() { count = 0; curDist = 0; }),
//                       child: CircleAvatar(
//                           backgroundColor: Colors.deepOrange,
//                           radius:isTablate ?25.r: 25.r,
//                           child: Text(AppString.KRestText,
//                               style: GoogleFonts.cairo(
//                                   fontSize:isTablate?11.sp : 15.sp,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500))),
//                     ),
//                     //
//                     // ElevatedButton(
//                     //     style: ButtonStyle(
//                     //         shape: MaterialStatePropertyAll(
//                     //             BeveledRectangleBorder(
//                     //                 borderRadius:
//                     //                     const BorderRadius.all(Radius.circular(
//                     //                   0,
//                     //                 )),
//                     //                 side: BorderSide(
//                     //                     width: 1.5.w,
//                     //                     color:
//                     //                         const Color(AppStyle.whiteColor)))),
//                     //         backgroundColor: const MaterialStatePropertyAll(
//                     //             Color(AppStyle.secondaryColor))),
//                     //     onPressed: () {
//                     //       controller.incrementCount();
//                     //     },
//                     //     child: Text(AppString.KSabahText,
//                     //         style: GoogleFonts.cairo(
//                     //             fontSize: 25.sp, color: Colors.black))),
//
//                     // ElevatedButton(
//                     //     style: ButtonStyle(
//                     //         shape: MaterialStatePropertyAll(
//                     //             BeveledRectangleBorder(
//                     //                 borderRadius:
//                     //                     const BorderRadius.all(Radius.circular(
//                     //                   8,
//                     //                 )),
//                     //                 side: BorderSide(
//                     //                     width: 1.5.w,
//                     //                     color:
//                     //                         const Color(AppStyle.whiteColor)))),
//                     //         elevation: const MaterialStatePropertyAll(8),
//                     //         backgroundColor: MaterialStatePropertyAll(
//                     //             const Color(AppStyle.primaryColor)
//                     //                 .withOpacity(0.8))),
//                     //     onPressed: () {
//                     //       controller.restCount();
//                     //     },
//                     //     child: Row(
//                     //       children: [
//                     //         Text('تصفير',
//                     //             style: GoogleFonts.cairo(
//                     //                 fontSize: 25.sp, color: Colors.black)),
//                     //       ],
//                     //     ))
//                   ],
//                 ),
//               ),
//
//
//
//               // Padding(
//               //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
//               //   child: Row(
//               //     children: [
//               //       Text('$count', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
//               //       const SizedBox(width: 12),
//               //       TextButton.icon(
//               //         onPressed: () => setState(() { count = 0; curDist = 0; }),
//               //         icon: const Icon(Icons.refresh),
//               //         label: const Text('إعادة'),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   // وضع الخرزة مع دوران ومنظور بسيط
//   Widget _placedBead({
//     required Offset pos,
//     required double angle,
//     required double baseSize,
//     required Color color,
//   }) {
//     // منظور: كلما زاد y تكبر قليلاً
//     final scale = 0.9 + (pos.dy / area.height) * 0.15;
//     return Positioned(
//       left: pos.dx - baseSize / 2,
//       top: pos.dy - baseSize / 2,
//       child: Transform.rotate(
//         angle: angle,
//         child: Transform.scale(
//           scale: scale,
//           child: _Bead(size: baseSize, color: color),
//         ),
//       ),
//     );
//   }
// }
//
// // بيانات محطة
// class _StopPoint {
//   final Offset pos;
//   final double angle;
//   final Offset normal;
//   _StopPoint({required this.pos, required this.angle, required this.normal});
// }
//
// // رسم الخيط
// class _CordPainter extends CustomPainter {
//   final Path path;
//   final Color color;
//   final double stroke;
//   _CordPainter(this.path, this.color, this.stroke);
//   @override
//   void paint(Canvas canvas, Size size) {
//     final p = Paint()
//       ..color = color
//       ..strokeWidth = stroke
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//     canvas.drawPath(path, p);
//   }
//   @override
//   bool shouldRepaint(covariant _CordPainter old) => false;
// }
//
// // خرزة بلمعان وظل
// class _Bead extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Bead({required this.size, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: RadialGradient(
//           center: const Alignment(-0.3, -0.3),
//           radius: 0.9,
//           colors: [Colors.white.withOpacity(.55), color],
//           stops: const [0.0, 0.9],
//         ),
//         boxShadow: const [
//           BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x33000000)),
//         ],
//       ),
//       child: Align(
//         alignment: const Alignment(-0.55, -0.55),
//         child: Container(
//           width: size * .22,
//           height: size * .22,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white.withOpacity(.65),
//           ),
//         ),
//       ),
//     );
//   }
// }
