import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/style/responsive_util.dart';

class DailyStreakWidget extends StatefulWidget {
  const DailyStreakWidget({super.key});

  @override
  State<DailyStreakWidget> createState() => _DailyStreakWidgetState();
}

class _DailyStreakWidgetState extends State<DailyStreakWidget> {
  int _streakDays = 0;
  String _lastVisitDate = '';

  @override
  void initState() {
    super.initState();
    _checkStreak();
  }

  Future<void> _checkStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastVisit = prefs.getString('last_visit_date') ?? '';

    if (lastVisit != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toString()
          .substring(0, 10);

      int currentStreak = prefs.getInt('streak_days') ?? 0;

      if (lastVisit == yesterday) {
        // Continue streak
        currentStreak++;
      } else if (lastVisit.isNotEmpty) {
        // Streak broken
        currentStreak = 1;
      } else {
        // First visit
        currentStreak = 1;
      }

      await prefs.setString('last_visit_date', today);
      await prefs.setInt('streak_days', currentStreak);

      setState(() {
        _streakDays = currentStreak;
        _lastVisitDate = today;
      });

      // Show reward if milestone reached
      if (currentStreak == 7 || currentStreak == 14 || currentStreak == 30) {
        _showMilestoneReward(currentStreak);
      }
    } else {
      setState(() {
        _streakDays = prefs.getInt('streak_days') ?? 0;
        _lastVisitDate = lastVisit;
      });
    }
  }

  void _showMilestoneReward(int days) {
    int reward = 0;
    String title = '';

    if (days == 7) {
      reward = 100;
      title = '7 أيام متتالية!';
    } else if (days == 14) {
      reward = 200;
      title = 'أسبوعان رائعان!';
    } else if (days == 30) {
      reward = 500;
      title = 'شهر كامل! أنت بطل!';
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🔥'),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ما شاء الله! واصلت $days يوماً!',
                style: GoogleFonts.cairo(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    '+$reward',
                    style: GoogleFonts.cairo(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(
                'رائع!',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 35),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السلسلة اليومية',
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 11.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_streakDays يوم متتالي',
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_streakDays >= 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _streakDays >= 30
                    ? '🏆'
                    : _streakDays >= 14
                        ? '🥇'
                        : '⭐',
                style: const TextStyle(fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }
}
