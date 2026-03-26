import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../exports/all_exports.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          context.isTab ? 70 : 50,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            AppString.KForYou,
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: const DoneDialogWidget(
        onPressedRepeat: null,
      ),
    );
  }
}

class DoneDialogWidget extends StatelessWidget {
  final VoidCallback? onPressedRepeat;
  final String? doneText;
  final String? KZakarFeaturesTitle;
  final String? KDaialogText;
  final String? repratBtn;

  const DoneDialogWidget({
    super.key,
    this.onPressedRepeat,
    this.doneText,
    this.KZakarFeaturesTitle,
    this.KDaialogText,
    this.repratBtn,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;
    bool isTap = context.isTab;
    return Stack(
      children: [
        // Subtle Background Decoration
        Positioned(
          top: -50,
          right: -50,
          child: FadeInDown(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.05),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -30,
          child: FadeInUp(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.05),
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  // Image with ZoomIn animation
                  ZoomIn(
                    duration: const Duration(seconds: 1),
                    child: Center(
                      child: Container(
                        height: 150,
                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white10 : Colors.green.withOpacity(0.05),
                        ),
                        // child: Image.asset(
                        //   doneZakar,
                        //   height: 180.h,
                        // ),
                        child: Lottie.asset(doneZakar2),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Main Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      KDaialogText ?? AppString.KSabahDaialogText,
                      textAlign: TextAlign.center,
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontWeight: FontWeight.bold,
                        fontSize: isTap?18.sp:14.sp,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Features Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      KZakarFeaturesTitle ?? AppString.KZakarSleepFeaturesTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                  fontFamily: "cairo",
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize:isTap?14.sp: 12.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Divider
                  FadeIn(
                    delay: const Duration(milliseconds: 1000),
                    child: Container(
                      height: 4,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Description Card (Glassmorphism Effect)
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.green.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.green.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        doneText ?? AppString.doneText,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                  fontFamily: "cairo",
                          height: 1.8,
                          fontSize:isTap?16.sp :12.sp,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  if (onPressedRepeat != null) ...[
                    SizedBox(height: 40.h),
                    // Premium Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 1500),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: onPressedRepeat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
                            elevation: 0,
                          ),
                          child: Text(
                            repratBtn ?? "إعادة العداد",
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize:isTap?18.sp: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
