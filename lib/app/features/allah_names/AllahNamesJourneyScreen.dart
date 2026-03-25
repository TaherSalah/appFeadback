import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class AllahNamesJourneyScreen extends StatefulWidget {
  final List<Map<String, String>> names;
  final int initialIndex;

  const AllahNamesJourneyScreen({
    super.key,
    required this.names,
    this.initialIndex = 0,
  });

  @override
  State<AllahNamesJourneyScreen> createState() => _AllahNamesJourneyScreenState();
}

class _AllahNamesJourneyScreenState extends State<AllahNamesJourneyScreen> {
  late PageController _pageController;
  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _scrollNotifier.value = widget.initialIndex.toDouble();
    _pageController.addListener(() {
      _scrollNotifier.value = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: ValueListenableBuilder<double>(
        valueListenable: _scrollNotifier,
        builder: (context, currentPage, child) {
          return Stack(
            children: [
              // Background Parallax Layer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(const Color(0xFF0F2027), const Color(0xFF203A43), currentPage % 1)!,
                        Color.lerp(const Color(0xFF2C5364), const Color(0xFF243B55), currentPage % 1)!,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Particle Background Layer
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlePainter(seed: widget.initialIndex),
                ),
              ),
              
              // Pattern Overlay with Parallax
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Transform.translate(
                    offset: Offset(-(currentPage * 40) % 200, 0),
                    child: Image.asset(
                      "assets/images/pattern.webp",
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.none,
                    ),
                  ),
                ),
              ),

              // Main PageView
              PageView.builder(
                controller: _pageController,
                itemCount: widget.names.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final name = widget.names[index];
                  final double relativePosition = index - currentPage;
                  
                  // Animated opacity and scale based on position
                  final double progress = (1 - relativePosition.abs()).clamp(0.0, 1.0);
                  final double scale = 0.85 + (progress * 0.15);

                  // Optimization: Skip heavy filters if not visible
                  if (progress <= 0.05) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Calligraphy Section
                        Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: progress,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFB8860B)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                name['name']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: 80.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 30.h),

                        // Content Card (Performance Optimized Glass effect)
                        Opacity(
                          opacity: progress,
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              // Using solid color with opacity instead of BackdropFilter
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name['meaning']!,
                                  textAlign: TextAlign.center,
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    fontSize: 18.sp,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  width: 30.w,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: const Color(0xFFD4AF37), size: 18.sp),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        name['reflection']!,
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 14.sp,
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Top Bar
              Positioned(
                top: 50.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                    ),
                    Text(
                      "${(currentPage + 1).toInt()} / ${widget.names.length}",
                         style: TextStyle(
                          fontFamily: "cairo",
                        color: Colors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Hint
              Positioned(
                bottom: 30.h,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: (1 - (currentPage % 1)).clamp(0.2, 0.5),
                  child: Center(
                    child: Column(
                      children: [
                         Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 24.sp),
                         Text(
                          "اسحب للأعلى لاستكشاف المزيد",
                             style: TextStyle(
                          fontFamily: "cairo",
                            color: Colors.white54,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final int seed;
  ParticlePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()..color = Colors.white.withOpacity(0.15);
    
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
