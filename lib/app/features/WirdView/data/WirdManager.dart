// =============== مدير البيانات ===============

import 'dart:convert';

import 'package:intl/intl.dart' as intl;
import 'package:rate_my_app/rate_my_app.dart';

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
    return jsonList.map((j) => Wird.fromJson(j)).toList();
  }

  Future<void> saveAwrad(List<Wird> awrad) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(awrad.map((w) => w.toJson()).toList());
    await prefs.setString(_awradKey, data);
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

    if (stats.dailyCompletions.containsKey(today)) {
      if (stats.dailyCompletions.containsKey(yesterday)) {
        stats.currentStreak++;
      } else {
        stats.currentStreak = 1;
      }
      if (stats.currentStreak > stats.longestStreak) {
        stats.longestStreak = stats.currentStreak;
      }
    }
  }

  void _checkAchievements(UserStats stats) {
    final achievements = <String>[];

    if (stats.totalTasbihat >= 100 && !stats.achievements.contains('beginner')) {
      achievements.add('beginner');
    }
    if (stats.totalTasbihat >= 1000 && !stats.achievements.contains('dedicated')) {
      achievements.add('dedicated');
    }
    if (stats.totalTasbihat >= 10000 && !stats.achievements.contains('master')) {
      achievements.add('master');
    }
    if (stats.currentStreak >= 7 && !stats.achievements.contains('week_streak')) {
      achievements.add('week_streak');
    }
    if (stats.currentStreak >= 30 && !stats.achievements.contains('month_streak')) {
      achievements.add('month_streak');
    }

    stats.achievements.addAll(achievements);
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
