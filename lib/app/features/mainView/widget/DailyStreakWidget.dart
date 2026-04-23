import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/style/k_dialog_helper.dart';

class DailyStreakWidget extends StatefulWidget {
  const DailyStreakWidget({super.key});

  @override
  State<DailyStreakWidget> createState() => _DailyStreakWidgetState();
}

class _DailyStreakWidgetState extends State<DailyStreakWidget> {
  int _streakDays = 0;

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
      });

      // Show reward if milestone reached
      if (currentStreak == 7 || currentStreak == 14 || currentStreak == 30) {
        _showMilestoneReward(currentStreak);
      }
    } else {
      setState(() {
        _streakDays = prefs.getInt('streak_days') ?? 0;
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
      KDialogHelper.showCustomDialog(
        context: context,
        type: KDialogType.success,
        icon: Icons.local_fire_department_rounded,
        title: title,
        description: 'ما شاء الله! واصلت $days يوماً!',
        additionalContent: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded,
                  color: Color(0xFFF59E0B), size: 28),
              const SizedBox(width: 10),
              Text(
                'لقد حصلت على $reward نجمة 🔥',
                   style: const TextStyle(
                          fontFamily: "cairo",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        actions: [
          KDialogHelper.buildButton(
            context: context,
            label: 'رائع!',
            color: const Color(0xFFF59E0B),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2C3E50), const Color(0xFF000000)]
              : [const Color(0xFFFF9A8B), const Color(0xFFFF6A88)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFFFF6A88))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التزامك اليومي',
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_streakDays يوم متتالي',
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 18.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _streakDays > 0
                      ? 'ما شاء الله! استمر في التقدم'
                      : 'ابدأ رحلتك اليوم!',
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.7),
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
