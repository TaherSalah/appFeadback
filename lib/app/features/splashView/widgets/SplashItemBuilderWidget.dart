import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashItemBuilderWidget extends StatefulWidget {
  const SplashItemBuilderWidget({super.key});

  @override
  State<SplashItemBuilderWidget> createState() => _SplashItemBuilderWidgetState();
}

class _SplashItemBuilderWidgetState extends State<SplashItemBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    
    // Luxury Islamic Color Palette
    const Color primaryGreen = Color(0xFF064E3B);
    const Color deepEmerald = Color(0xFF022C22);
    const Color goldColor = Color(0xFFD4AF37);

    final List<Color> bgColors = isDark 
      // ? [deepEmerald, const Color(0xFF011C16)]
      ? [Colors.black, Colors.black12]
      : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: bgColors,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🕌 1. Majestic Background Pattern (Subtle & Elegant)
            Opacity(
              // opacity: isDark ? 0.08 : 0.04,
              opacity:  0.04,
              child: Image.asset(
                "assets/images/pattern.webp",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),

            // ✨ 2. Decorative Ambient Light (Top Glow)
            Positioned(
              top: -150.h,
              child: Container(
                width: 400.w,
                height: 400.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      goldColor.withOpacity(isDark ? 0.1 : 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 🕋 3. Main Logo Section with Glowing Halo
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Pulse(
                    duration: const Duration(seconds: 3),
                    infinite: true,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Glowing Ring
                        // Container(
                        //   width: 240.w,
                        //   height: 240.h,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     border: Border.all(
                        //       color: goldColor.withOpacity(0.2),
                        //       width: 1.5,
                        //     ),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: goldColor.withOpacity(isDark ? 0.3 : 0.1),
                        //         blurRadius: 50,
                        //         spreadRadius: 10,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // App Logo Image
                        Container(
                          width: 210.w,
                          height: 210.h,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.75),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                              width: 0.5,
                            ),
                          ),
                          child: Image.asset(
                            "assets/images/logoApp.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.isTab ? 90.h : 70.h),
                
                // ⏳ Elegant Pulse Loading
                // ⏳ Premium Animated Title & Slogan
                Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 900),
                      child: Text(
                        "رَفِيقُ الْمُسْلِمِ الْيَوْمِيُّ",
                        style: TextStyle(
                          fontFamily: "me",
                          fontSize: context.isTab ? 14.sp : 30.sp,
                          color:  primaryGreen,
                          fontWeight: FontWeight.w900,
                          // letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 1100),
                      child: Text(
                        "فِي حَيَاتِهِ الْيَوْمِيَّةِ",
                        style: TextStyle(
                          fontFamily: "me",

                          fontSize: context.isTab ? 10.sp : 20.sp,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w600,
                          // letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 👨‍💻 4. Premium Cut-out Branding Section (Bottom)
            Positioned(
              bottom:context.isTab ? 15.h :0.h,
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Main Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            // border: Border.all(
                            //   color: isDark ? Colors.white.withOpacity(0.12) : Colors.white70,
                            //   width: 1.2,
                            // ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.02),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/images/perLogo.png",
                                    height: 30.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // SizedBox(height: 12.h),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: isDark
                                    ? [Colors.white, Colors.white70]
                                    : [primaryGreen, const Color(0xFF034D3D)],
                                ).createShader(bounds),
                                child: Text(
                                  "Taher Salah",
                                  style: GoogleFonts.momoSignature(
                                    fontSize: context.isTab ? 6.sp : 9.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 🏷️ "Developed By" Cut-out Label
                    // Positioned(
                    //   top: -12,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: isDark ? deepEmerald : const Color(0xFFF8FAFC),
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(
                    //         color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    //         width: 0.5,
                    //       ),
                    //     ),
                    //     child: Text(
                    //       "تطوير بواسطة",
                    //       style: TextStyle(
                    //         fontFamily: "cairo",
                    //         fontSize: context.isTablet ? 6.sp : 10.sp,
                    //         color: isDark ? Colors.white70 : Colors.grey.shade600,
                    //         letterSpacing: 2,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
