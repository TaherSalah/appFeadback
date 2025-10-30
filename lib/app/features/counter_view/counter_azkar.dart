import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

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
          body: const CounterWidgetBuilder()),
    );
  }
}







class TasbeehRealPlus extends StatefulWidget {
  const TasbeehRealPlus({super.key});
  @override
  State<TasbeehRealPlus> createState() => _TasbeehRealPlusState();
}

class _TasbeehRealPlusState extends State<TasbeehRealPlus> with SingleTickerProviderStateMixin {
  static const int stopsCount = 12;
  static const double beadSize = 44;
  static const Duration dur = Duration(milliseconds: 230);

  late final AnimationController _c = AnimationController(vsync: this, duration: dur);
  late Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  int count = 0;
  double curDist = 0;
  double step = 0;
  Size area = Size.zero;

  void _tap() {
    if (_c.isAnimating) return;
    HapticFeedback.lightImpact();
    setState(() => count++);
    final target = (curDist + step) % _pathLen();
    _a = Tween(begin: curDist, end: target)
        .chain(CurveTween(curve: Curves.easeOutBack)) // لمسة ارتداد خفيفة
        .animate(_c)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) setState(() => curDist = target);
      });
    _c.forward(from: 0);
  }

  Path _buildPath(Size s) {
    final y = s.height * 0.62;
    return Path()
      ..moveTo(0, y - 8)
      ..quadraticBezierTo(s.width * .32, y + 34, s.width * .68, y - 10)
      ..quadraticBezierTo(s.width * .88, y - 24, s.width, y + 6);
  }

  double _pathLen() => _buildPath(area).computeMetrics().first.length;

  List<_StopPoint> _stops(Size s) {
    final m = _buildPath(s).computeMetrics().first;
    final len = m.length;
    step = len / (stopsCount - 1);
    return List.generate(stopsCount, (i) {
      final t = m.getTangentForOffset(i * step)!;
      return _StopPoint(
        pos: t.position,
        angle: t.angle,          // دوران مع اتجاه الخيط
        normal: Offset(-t.vector.dy, t.vector.dx), // عمودي على المماس
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablate = MediaQuery.sizeOf(context).width > 600;

    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: LayoutBuilder(builder: (context, box) {
          area = Size(box.maxWidth, 130);
          final path = _buildPath(area);
          final metric = path.computeMetrics().first;
          final len = metric.length;
          final stops = _stops(area);

          // موضع الخرزة المتحركة
          final mover = AnimatedBuilder(
            animation: _a,
            builder: (_, __) {
              final d = _c.isAnimating ? _a.value : curDist;
              final tan = metric.getTangentForOffset(d % len)!;
              final pos = tan.position;
              final normal = Offset(-tan.vector.dy, tan.vector.dx);
              return _placedBead(
                pos: pos + normal * 2,             // تلامس مع الخيط
                angle: tan.angle,
                baseSize: beadSize,
                color: cs.primary,
              );
            },
          );

          return Column(
            spacing: 60,
            children: [
              const SizedBox(height: 12),

              Card(
                elevation: 10,
                color: Colors.black.withOpacity(0.5),
                shape: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(AppStyle.whiteColor), width: 5)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Text('$count',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.sp,
                          color: Colors.white)),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                height: area.height,
                width: area.width,
                child: Stack(
                  children: [

                    // ظل الخيط
                    Positioned.fill(child: CustomPaint(painter: _CordPainter(path, Colors.black12, 4))),
                    // الخيط
                    Positioned.fill(child: CustomPaint(painter: _CordPainter(path, Colors.black26, 3))),
                    // الخرز الثابت
                    ...stops.map((s) => _placedBead(
                      pos: s.pos + s.normal * 2,
                      angle: s.angle,
                      baseSize: beadSize,
                      color: cs.primary.withOpacity(.65),
                    )),
                    // الخرزة المتحركة فوق
                    mover,
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap:_tap,
                      child: CircleAvatar(
                          radius:isTablate?50: 35,
                          backgroundColor: Colors.white,
                          child: Text(AppString.KSabhText,
                              style: GoogleFonts.cairo(
                                  fontSize: isTablate ? 17.sp :23.sp, color: Colors.black))),
                    ),
                    SizedBox(
                      width: 85.w,
                    ),
                    InkWell(
                      onTap: () => setState(() { count = 0; curDist = 0; }),
                      child: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          radius:isTablate ?25.r: 25.r,
                          child: Text(AppString.KRestText,
                              style: GoogleFonts.cairo(
                                  fontSize:isTablate?11.sp : 15.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500))),
                    ),
                    //
                    // ElevatedButton(
                    //     style: ButtonStyle(
                    //         shape: MaterialStatePropertyAll(
                    //             BeveledRectangleBorder(
                    //                 borderRadius:
                    //                     const BorderRadius.all(Radius.circular(
                    //                   0,
                    //                 )),
                    //                 side: BorderSide(
                    //                     width: 1.5.w,
                    //                     color:
                    //                         const Color(AppStyle.whiteColor)))),
                    //         backgroundColor: const MaterialStatePropertyAll(
                    //             Color(AppStyle.secondaryColor))),
                    //     onPressed: () {
                    //       controller.incrementCount();
                    //     },
                    //     child: Text(AppString.KSabahText,
                    //         style: GoogleFonts.cairo(
                    //             fontSize: 25.sp, color: Colors.black))),

                    // ElevatedButton(
                    //     style: ButtonStyle(
                    //         shape: MaterialStatePropertyAll(
                    //             BeveledRectangleBorder(
                    //                 borderRadius:
                    //                     const BorderRadius.all(Radius.circular(
                    //                   8,
                    //                 )),
                    //                 side: BorderSide(
                    //                     width: 1.5.w,
                    //                     color:
                    //                         const Color(AppStyle.whiteColor)))),
                    //         elevation: const MaterialStatePropertyAll(8),
                    //         backgroundColor: MaterialStatePropertyAll(
                    //             const Color(AppStyle.primaryColor)
                    //                 .withOpacity(0.8))),
                    //     onPressed: () {
                    //       controller.restCount();
                    //     },
                    //     child: Row(
                    //       children: [
                    //         Text('تصفير',
                    //             style: GoogleFonts.cairo(
                    //                 fontSize: 25.sp, color: Colors.black)),
                    //       ],
                    //     ))
                  ],
                ),
              ),



              // Padding(
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              //   child: Row(
              //     children: [
              //       Text('$count', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
              //       const SizedBox(width: 12),
              //       TextButton.icon(
              //         onPressed: () => setState(() { count = 0; curDist = 0; }),
              //         icon: const Icon(Icons.refresh),
              //         label: const Text('إعادة'),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        }),
      ),
    );
  }

  // وضع الخرزة مع دوران ومنظور بسيط
  Widget _placedBead({
    required Offset pos,
    required double angle,
    required double baseSize,
    required Color color,
  }) {
    // منظور: كلما زاد y تكبر قليلاً
    final scale = 0.9 + (pos.dy / area.height) * 0.15;
    return Positioned(
      left: pos.dx - baseSize / 2,
      top: pos.dy - baseSize / 2,
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          child: _Bead(size: baseSize, color: color),
        ),
      ),
    );
  }
}

// بيانات محطة
class _StopPoint {
  final Offset pos;
  final double angle;
  final Offset normal;
  _StopPoint({required this.pos, required this.angle, required this.normal});
}

// رسم الخيط
class _CordPainter extends CustomPainter {
  final Path path;
  final Color color;
  final double stroke;
  _CordPainter(this.path, this.color, this.stroke);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant _CordPainter old) => false;
}

// خرزة بلمعان وظل
class _Bead extends StatelessWidget {
  final double size;
  final Color color;
  const _Bead({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [Colors.white.withOpacity(.55), color],
          stops: const [0.0, 0.9],
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x33000000)),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.55, -0.55),
        child: Container(
          width: size * .22,
          height: size * .22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.65),
          ),
        ),
      ),
    );
  }
}
