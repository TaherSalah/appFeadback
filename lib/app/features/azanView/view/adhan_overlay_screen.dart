import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/features/QiblaView/QiblaDirection.dart';
import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'package:muslimdaily/app/features/prayerView/post_prayer_azkar.dart';
import 'package:muslimdaily/app/features/quran/quranView.dart';

class AdhanOverlayScreen extends StatefulWidget {
  final String? prayerName;
  final String? cityName;
  final String? prayerTime;

  const AdhanOverlayScreen({
    super.key,
    this.prayerName,
    this.cityName,
    this.prayerTime,
  });

  @override
  State<AdhanOverlayScreen> createState() => _AdhanOverlayScreenState();
}

class _AdhanOverlayScreenState extends State<AdhanOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainView()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sultan-qaboos-grand-mosque-2606274_1280-min.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay Gradient for better visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: _closeScreen,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Central Content (Animated)
          Center(
            child: FadeTransition(
              opacity: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.prayerName?.contains('الشروق') == true
                        ? "حان الآن موعد"
                        : "حان الان موعد صلاة",
                    style: GoogleFonts.amiri(
                      fontSize: 35.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    widget.prayerName ?? "وقت الصلاة",
                    style: GoogleFonts.amiri(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                  ),
                  if (widget.prayerName?.contains('الشروق') == true) ...[
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Text(
                        "«صلاة الضحى صلاة الأوابين وهي صدقة عن كل مفصل من مفاصلك»",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 20.sp,
                          color: Colors.amberAccent,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (widget.cityName != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      widget.cityName!,
                      style: GoogleFonts.cairo(
                        fontSize: 25.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  if (widget.prayerTime != null) ...[
                    SizedBox(height: 5.h),
                    Text(
                      widget.prayerTime!,
                      style: GoogleFonts.barlow(
                        fontSize: 24.sp,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.mosque,
                    label: "أذكار الصلاة",
                    onTap: () {
                      _closeScreen();
                      // Navigate to Athkar (defaulting to messaa or sabah based on time if needed, 
                      // or just general athkar view if available. For now routing to MainView -> Athkar logic)
                       // You might want to direct to a specific Athkar page. 
                       // Assuming AzkarMassa for PM and Sabah for AM or generally MainView
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerAzkar()));
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.menu_book,
                    label: "القرآن",
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranView())); 
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.explore,
                    label: "القبلة",
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaDirection())); 
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
