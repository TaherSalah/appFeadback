import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
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
    bool isDark = context.isDark;
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? const [
              Color(0xFF020617),
              Color(0xFF0F172A),
            ]
                : [
              // baseColor.withOpacity(0.06), // لمسة لون خفيفة
              const Color(0xFFF7F1E1),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Background Circles
            Positioned(
              top: -100.h,
              right: -50.w,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? const Color(0xFFD9A066) : KColors.primaryColor).withOpacity(0.05),
                ),
              ),
            ),
            
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.03 : 0.05,
                child: Image.asset(
                  'assets/images/pattern.png',
                  repeat: ImageRepeat.repeat,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _navigateToHome(context),
                          style: TextButton.styleFrom(
                            backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'تخطي',
                            style: GoogleFonts.cairo(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize:context.isTab?9.sp: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Title & Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            ' ما الجديد ',
                            style: GoogleFonts.cairo(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize:context.isTab?11.sp: 26.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Feature List Container
                  Expanded(
                    child: FadeAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ListView.separated(
                            padding: EdgeInsets.all(20.w),
                            physics: const BouncingScrollPhysics(),
                            itemCount: (widget.newFeatures != null && widget.newFeatures!.isNotEmpty) 
                                ? widget.newFeatures!.length 
                                : recentUpdates.length,
                            separatorBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), thickness: 1),
                            ),
                            itemBuilder: (context, index) {
                              final String title;
                              final String? description;
                              final IconData icon;

                              if (widget.newFeatures != null && widget.newFeatures!.isNotEmpty) {
                                final dynamic feature = widget.newFeatures![index];
                                title = feature.title;
                                description = (feature is AppUpdateFeature) ? null : feature.description;
                                icon = (feature is AppUpdateFeature) ? feature.icon : (feature.icon ?? Icons.auto_awesome_outlined);
                              } else {
                                final update = recentUpdates[index];
                                title = update.title;
                                description = null;
                                icon = update.icon;
                              }
                              // const Color(0xFFD9A066)
                              return FadeAnimation(
                                delay: Duration(milliseconds: 100 + (index * 150)),
                                offset: const Offset(0.1, 0),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: (isDark ?KColors.primaryColor  : KColors.primaryColor).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: isDark ? KColors.primaryColor : KColors.primaryColor,
                                          size: context.isTab?12.sp:20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,

                                              style: TextStyle(
                                                fontFamily: "me",
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontSize:context.isTab?12.sp: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                // letterSpacing: 1,
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                            if (description != null)
                                              Text(
                                                description,
                                                // style: GoogleFonts.cairo(
                                                //   color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                                                //   fontSize: 13.sp,
                                                //   height: 1.4,
                                                // ),
                                                style: TextStyle(
                                                  fontFamily: "cairo",
                                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                                                    fontSize:context.isTab?8.5.sp: 13.sp,
                                                    height: 1.6,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Bottom Action Button
                  Center(
                    child: FadeAnimation(
                      delay: const Duration(milliseconds: 1000),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: Container(
                          width: 240.w,
                          height: 58.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: isDark 
                                // ? [const Color(0xFFD9A066), const Color(0xFFB88655)]
                                ? [KColors.primaryColor, KColors.primaryColor.withOpacity(0.8)]
                                : [KColors.primaryColor, KColors.primaryColor.withOpacity(0.8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? KColors.primaryColor : KColors.primaryColor).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _navigateToHome(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ابدأ الآن',
                                  // style: GoogleFonts.cairo(
                                  //   fontSize: 18.sp,
                                  //   fontWeight: FontWeight.bold,
                                  // ),
                                  style: TextStyle(
                                    fontFamily: "cairo",
                                      fontSize:context.isTab?12.sp: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    // letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Icon(Icons.arrow_forward_ios, size: 16.sp),
                              ],
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
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }
}
