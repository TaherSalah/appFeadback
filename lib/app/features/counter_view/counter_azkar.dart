import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../../core/shard/constanc/app_string.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';

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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // العنوان الرئيسي
              Text(
                'سبحة الأذكار',
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 32.sp : 28.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: isTablet ? 20.h : 10.h),

              // شريط الأذكار
              _buildAzkarBar(context),
              SizedBox(height: isTablet ? 30.h : 20.h),

              // العداد
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // العداد المركزي
                      _buildCounterDisplay(),
                      SizedBox(height: isTablet ? 40.h : 30.h),
                  
                      // السبحه
                      TasbeehRealPlus(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildCounterDisplay() {

    return Consumer<AzkarProvider>(
      builder: (context, controller, child) {
        bool isTablet = ResponsiveUtil.isTablet(context);
        return Column(
          children: [
            // تاج العداد
            Icon(
              Icons.star_outlined,
              color: const Color(0xFFF59E0B),
              size: 30.sp,
            ),
            SizedBox(height: 10.h),

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
                '${controller.counter}',
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 48.sp : 42.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // النص تحت العداد
            Text(
              'عدد التسبيحات',
              style: GoogleFonts.cairo(
                fontSize: isTablet ? 18.sp : 16.sp,
                color: const Color(0xFFCBD5E1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
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

class TasbeehRealPlus extends StatefulWidget {
  const TasbeehRealPlus({super.key});
  @override
  State<TasbeehRealPlus> createState() => _TasbeehRealPlusState();
}

class _TasbeehRealPlusState extends State<TasbeehRealPlus> with SingleTickerProviderStateMixin {
  static const int beadsCount = 33;
  static const Duration animDur = Duration(milliseconds: 300);

  late AnimationController _controller;
  late Animation<double> _animation;

  int _currentBead = 0;
  int _cycleCount = 0;
  final List<Offset> _beadPositions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: animDur,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculateBeadPositions(Size size) {
    _beadPositions.clear();

    final double radius = size.width * 0.4;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (int i = 0; i < beadsCount; i++) {
      final angle = (2 * pi / beadsCount) * i;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      _beadPositions.add(Offset(x, y));
    }
  }

  void _moveToNextBead() {
    if (_controller.isAnimating) return;

    HapticFeedback.lightImpact();

    setState(() {
      _currentBead = (_currentBead + 1) % beadsCount;
      if (_currentBead == 0) {
        _cycleCount++;
      }
    });

    _controller.reset();
    _controller.forward();
  }

  void _resetCounter() {
    setState(() {
      _currentBead = 0;
      _cycleCount = 0;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return Column(
      children: [
        // مؤشر الدورة
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFF475569),
              width: 2.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.autorenew,
                color: const Color(0xFF10B981),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'الدورة: $_cycleCount',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'الخرزة: ${_currentBead + 1}/$beadsCount',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 30.h),

        // الحلقة الدائرية للسبحة
        SizedBox(
          height: isTablet ? 400.h : 320.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              _calculateBeadPositions(size);

              return Stack(
                children: [
                  // الحلقة الخلفية
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 3.w,
                        ),
                      ),
                    ),
                  ),

                  // الخرزات الثابتة
                  ...List.generate(beadsCount, (index) {
                    final pos = _beadPositions[index];
                    return Positioned(
                      left: pos.dx - 20,
                      top: pos.dy - 20,
                      child: _buildBead(
                        isActive: false,
                        index: index,
                        size: 40,
                      ),
                    );
                  }),

                  // الخرزة النشطة المتحركة
                  if (_beadPositions.isNotEmpty)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final startPos = _beadPositions[_currentBead];
                        final nextPos = _beadPositions[(_currentBead + 1) % beadsCount];

                        final x = startPos.dx + (nextPos.dx - startPos.dx) * _animation.value;
                        final y = startPos.dy + (nextPos.dy - startPos.dy) * _animation.value;

                        return Positioned(
                          left: x - 25,
                          top: y - 25,
                          child: _buildBead(
                            isActive: true,
                            index: _currentBead,
                            size: 50,
                          ),
                        );
                      },
                    ),

                  // الزر المركزي
                  Center(
                    child: GestureDetector(
                      onTap: _moveToNextBead,
                      child: Container(
                        width: isTablet ? 120 : 100,
                        height: isTablet ? 120 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              const Color(0xFF6366F1),
                              const Color(0xFF4F46E5),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: 4.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.touch_app,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: 30.h),

        // أزرار التحكم
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // زر التسبيح
              _buildControlButton(
                icon: Icons.favorite,
                label: 'تسبيح',
                color: const Color(0xFF10B981),
                onTap: _moveToNextBead,
                isTablet: isTablet,
              ),

              // زر التصفير
              _buildControlButton(
                icon: Icons.refresh,
                label: 'تصفير',
                color: const Color(0xFFEF4444),
                onTap: _resetCounter,
                isTablet: isTablet,
              ),

              // زر التكبير
              _buildControlButton(
                icon: Icons.volume_up,
                label: 'تكبير',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  HapticFeedback.heavyImpact();
                },
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBead({required bool isActive, required int index, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
            const Color(0xFFFBBF24),
            const Color(0xFFF59E0B),
          ]
              : [
            const Color(0xFF475569),
            const Color(0xFF334155),
          ],
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          width: isActive ? 3.w : 2.w,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: GoogleFonts.cairo(
            fontSize: isActive ? 14.sp : 12.sp,
            color: isActive ? Colors.black : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: isTablet ? 80 : 70,
            height: isTablet ? 80 : 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: isTablet ? 30.sp : 28.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTablet ? 14.sp : 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
