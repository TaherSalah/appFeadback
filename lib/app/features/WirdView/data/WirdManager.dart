// =============== مدير البيانات ===============

import 'dart:convert';

import 'package:intl/intl.dart' as intl;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure this is here just in case
import 'package:muslimdaily/app/core/services/notification_manager.dart';

import 'UserStats.dart';
import 'Wird.dart';

class WirdManager {
  static const String _awradKey = 'awrad_data';
  static const String _statsKey = 'user_stats';
  static const String _themeKey = 'app_theme';
  static const String _soundKey = 'sound_enabled';
  static const String _hapticKey = 'haptic_enabled';

  Future<List<Wird>> loadAwrad() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_awradKey);
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    
    var list = jsonList.map((j) => Wird.fromJson(j)).toList();
    
    // ✅ التحقق من إعادة تعيين الأوراد المتكررة
    final now = DateTime.now();
    bool needsSave = false;

    for (var wird in list) {
      if (wird.isCompleted && wird.lastCompletedDate != null) {
        final last = wird.lastCompletedDate!;
        bool shouldReset = false;

        if (wird.frequency == 'daily') {
          // لو اليوم مختلف عن يوم الإكمال
          if (last.year != now.year || last.month != now.month || last.day != now.day) {
            shouldReset = true;
          }
        } else if (wird.frequency == 'weekly') {
          // لو مر أسبوع
          if (now.difference(last).inDays >= 7) {
            shouldReset = true;
          }
        } else if (wird.frequency == 'monthly') {
          // لو مر شهر (بسيط)
           if (now.difference(last).inDays >= 30) {
            shouldReset = true;
          }
        }

        if (shouldReset) {
          wird.isCompleted = false;
          wird.isInProgress = false;
          wird.currentDhikrIndex = 0;
          wird.completedCount = wird.completedCount; // keep history
          needsSave = true;
        }
      }
    }

    if (needsSave) {
      _refreshNotifications(list); // Ensure notifications are active
      final String newData = json.encode(list.map((w) => w.toJson()).toList());
      await prefs.setString(_awradKey, newData);
    }

    return list;
  }

  Future<void> saveAwrad(List<Wird> awrad) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(awrad.map((w) => w.toJson()).toList());
    await prefs.setString(_awradKey, data);
    
    // ✅ تحديث التنبيهات عند الحفظ
    _refreshNotifications(awrad);
  }

  void _refreshNotifications(List<Wird> awrad) {
    // نمر على كل الأوراد، لو فيه تنبيه نجدوله
    for (var wird in awrad) {
      if (wird.reminderTime != null && wird.reminderTime!.isNotEmpty) {
        NotificationManager().scheduleWirdReminder(
          wird.id, 
          wird.name, 
          wird.reminderTime!, 
          wird.frequency
        );
      } else {
        // لو مفيش وقت أو تم حذفه، نلغي التنبيه المرتبط
        // (نحتاج لمنطق إلغاء، لكن حالياً schedules هتتكتب فوق القديمة لو نفس الـ ID)
        // لتحسين الأداء ودقة الحذف عند المسح الحقيقي، يفضل إلغاء التنبيه إذا لم يعد موجوداً
      }
    }
  }

  Future<UserStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_statsKey);
    if (data == null) return UserStats();
    return UserStats.fromJson(json.decode(data));
  }

  Future<void> saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> updateStats(int tasbihatCount) async {
    final stats = await loadStats();
    stats.totalTasbihat += tasbihatCount;

    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    stats.dailyCompletions[today] = (stats.dailyCompletions[today] ?? 0) + 1;

    // تحديث المستوى
    stats.level = (stats.totalTasbihat / 1000).floor() + 1;

    // تحديث السلسلة
    _updateStreak(stats);

    // فتح الإنجازات
    _checkAchievements(stats);

    await saveStats(stats);
  }

  void _updateStreak(UserStats stats) {
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = intl.DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    // لو اليوم موجود بالفعل، متزودش الـ streak تاني
    if (stats.dailyCompletions.containsKey(today)) {
      // اليوم متسجل، بس نتأكد إن الـ streak محدث
      if (stats.currentStreak == 0) {
        stats.currentStreak = 1; // أول يوم
      }
      // لو أمس كمان متسجل، يبقى الـ streak مستمر
      if (stats.dailyCompletions.containsKey(yesterday)) {
        // الـ streak مستمر، متعملش حاجة
      }
    } else {
      // أول مرة نسجل اليوم
      if (stats.dailyCompletions.containsKey(yesterday)) {
        stats.currentStreak++; // استمرار الـ streak
      } else {
        stats.currentStreak = 1; // بداية جديدة
      }
    }

    // تحديث أطول سلسلة
    if (stats.currentStreak > stats.longestStreak) {
      stats.longestStreak = stats.currentStreak;
    }
  }
  void _checkAchievements(UserStats stats) {
    final newAchievements = <String>[];

    // ✅ إنجازات بناءً على عدد التسبيحات
    if (stats.totalTasbihat >= 100 && !stats.achievements.contains('beginner')) {
      newAchievements.add('beginner');
    }
    if (stats.totalTasbihat >= 1000 && !stats.achievements.contains('dedicated')) {
      newAchievements.add('dedicated');
    }
    if (stats.totalTasbihat >= 5000 && !stats.achievements.contains('fifty')) {
      newAchievements.add('fifty');
    }
    if (stats.totalTasbihat >= 5000 && !stats.achievements.contains('thousand')) {
      newAchievements.add('thousand');
    }
    if (stats.totalTasbihat >= 10000 && !stats.achievements.contains('master')) {
      newAchievements.add('master');
    }
    if (stats.totalTasbihat >= 10000 && !stats.achievements.contains('ten_thousand')) {
      newAchievements.add('ten_thousand');
    }
    if (stats.totalTasbihat >= 100000 && !stats.achievements.contains('millions')) {
      newAchievements.add('millions');
    }
    if (stats.totalTasbihat >= 1000000 && !stats.achievements.contains('golden_achievement')) {
      newAchievements.add('golden_achievement');
    }

    // ✅ إنجازات بناءً على الأيام المتتالية
    if (stats.currentStreak >= 1 && !stats.achievements.contains('first_day')) {
      newAchievements.add('first_day');
    }
    if (stats.currentStreak >= 2 && !stats.achievements.contains('two_days_streak')) {
      newAchievements.add('two_days_streak');
    }
    if (stats.currentStreak >= 7 && !stats.achievements.contains('week_streak')) {
      newAchievements.add('week_streak');
    }
    if (stats.currentStreak >= 30 && !stats.achievements.contains('month_streak')) {
      newAchievements.add('month_streak');
    }
    if (stats.currentStreak >= 60 && !stats.achievements.contains('two_months_streak')) {
      newAchievements.add('two_months_streak');
    }
    if (stats.currentStreak >= 100 && !stats.achievements.contains('hundred_days')) {
      newAchievements.add('hundred_days');
    }
    if (stats.currentStreak >= 365 && !stats.achievements.contains('year_streak')) {
      newAchievements.add('year_streak');
    }

    // ✅ إنجازات خاصة بالوقت (اختياري - محتاج تطبيق منطق أعقد)
    // يمكنك إضافتها لاحقاً بناءً على وقت إكمال الورد

    stats.achievements.addAll(newAchievements);
  }
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<bool> isHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticKey) ?? true;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }

  Future<String> exportData() async {
    final awrad = await loadAwrad();
    final stats = await loadStats();
    final data = {
      'awrad': awrad.map((w) => w.toJson()).toList(),
      'stats': stats.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    return json.encode(data);
  }

  Future<void> importData(String jsonData) async {
    final data = json.decode(jsonData);
    final awrad = (data['awrad'] as List).map((w) => Wird.fromJson(w)).toList();
    final stats = UserStats.fromJson(data['stats']);
    await saveAwrad(awrad);
    await saveStats(stats);
  }
}
