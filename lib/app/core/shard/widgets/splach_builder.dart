import 'package:muslimdaily/app/core/widgets/KLoading.dart';

import '../exports/all_exports.dart';

class SplashItemBuilder extends StatefulWidget {
  const SplashItemBuilder({super.key});

  @override
  State<SplashItemBuilder> createState() => _SplashItemBuilderState();
}

class _SplashItemBuilderState extends State<SplashItemBuilder> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      // color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🏠 Main App Logo
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logoApp.png",
                height: 250.0.h,
                width: 250.0.w,
              ),
              SizedBox(height: 20.h),
              KLoading.progressIOSIndicator(context: context),
            ],
          ),

          // 👨‍💻 Developer Branding (Bottom)
          Positioned(
            bottom: 40.h,
            child: Column(
              children: [
                Text(
                  "تطوير بواسطة",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: Colors.grey.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Image.asset(
                  "assets/images/perLogo.png",
                  height: 45.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
