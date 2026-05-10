import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'whats_new_data.dart';

class WhatsNewView extends StatefulWidget {
  final bool isFirstTime;
  final List<dynamic>? newFeatures; // Added for compatibility

  const WhatsNewView({
    super.key,
    this.isFirstTime = false,
    this.newFeatures,
  });

  @override
  State<WhatsNewView> createState() => _WhatsNewViewState();
}

class _WhatsNewViewState extends State<WhatsNewView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263222), // Dark Olive Background
      body: Stack(
        children: [
          // Background subtle pattern or gradient if needed
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/pattern.png', // Assuming a subtle pattern exists
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Skip
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _navigateToHome(context),
                        child: Text(
                          'تخطي',
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Title Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9A066), // Orange/Tan bar
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Text(
                        'ما الجديد',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Feature List Container
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: FadeAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: ListView.separated(
                            padding: EdgeInsets.all(25.w),
                            itemCount: (widget.newFeatures != null && widget.newFeatures!.isNotEmpty) 
                                ? widget.newFeatures!.length 
                                : recentUpdates.length,
                            separatorBuilder: (context, index) => SizedBox(height: 20.h),
                            itemBuilder: (context, index) {
                              final String title;
                              final IconData icon;

                              if (widget.newFeatures != null && widget.newFeatures!.isNotEmpty) {
                                final feature = widget.newFeatures![index];
                                // Handle both AppFeature and our internal AppUpdateFeature
                                if (feature is AppUpdateFeature) {
                                  title = feature.title;
                                  icon = feature.icon;
                                } else {
                                  // Assuming it's AppFeature from app_updates.dart
                                  title = feature.title;
                                  icon = Icons.auto_awesome_outlined;
                                }
                              } else {
                                final update = recentUpdates[index];
                                title = update.title;
                                icon = update.icon;
                              }

                              return FadeAnimation(
                                delay: Duration(milliseconds: 300 + (index * 100)),
                                offset: const Offset(0.2, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Icon(
                                        icon,
                                        color: const Color(0xFFD9A066),
                                        size: 22.sp,
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: GoogleFonts.cairo(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 15.sp,
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Bottom Action Button
                Center(
                  child: FadeAnimation(
                    delay: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.h),
                      child: SizedBox(
                        width: 200.w,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () => _navigateToHome(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9A066),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black45,
                          ),
                          child: Text(
                            'ابدأ',
                            style: GoogleFonts.cairo(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }
}
