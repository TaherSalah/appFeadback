import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ForceUpdateView extends StatelessWidget {
  const ForceUpdateView({super.key});

  // Future<void> _launchStore() async {
  //   final links = await SystemControlService().getSupportLinks();
  //   final url = Platform.isAndroid
  //       ? (links['link_playstore'] ?? '')
  //       : (links['link_appstore'] ?? '');
  //
  //   if (url.isNotEmpty) {
  //     final uri = Uri.parse(url);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24.w),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF178B74), Color(0xFF0D5446)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.update, size: 100, color: Colors.white),
            SizedBox(height: 30.h),
            Text(
              'تحديث جديد متوفر!',
                 style: TextStyle(
                          fontFamily: "cairo",
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.h),
            Text(
              'أنت تستخدم نسخة قديمة من التطبيق. يرجى التحديث الآن للاستمرار في الاستمتاع بكافة المميزات والخدمات بشكل صحيح.',
                 style: TextStyle(
                          fontFamily: "cairo",
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              // onPressed: _launchStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF178B74),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 5,
              ),
              onPressed: () {},
              child: Text(
                'تحديث الآن 🚀',
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
