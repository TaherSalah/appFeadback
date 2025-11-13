// =============== نماذج البيانات ===============


// class UserStats {
//   int totalTasbihat;
//   int currentStreak;
//   int longestStreak;
//   int level;
//   List<String> achievements;
//   Map<String, int> dailyCompletions;
//
//
//
//   UserStats({
//     this.totalTasbihat = 0,
//     this.currentStreak = 0,
//     this.longestStreak = 0,
//
//     this.level = 1,
//     List<String>? achievements,
//     Map<String, int>? dailyCompletions,
//   })  : achievements = achievements ?? [],
//         dailyCompletions = dailyCompletions ?? {};
//
//   Map<String, dynamic> toJson() => {
//     'totalTasbihat': totalTasbihat,
//     'currentStreak': currentStreak,
//     'longestStreak': longestStreak,
//     'level': level,
//     'achievements': achievements,
//     'dailyCompletions': dailyCompletions,
//
//   };
//
//   factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
//     totalTasbihat: json['totalTasbihat'] ?? 0,
//     currentStreak: json['currentStreak'] ?? 0,
//     longestStreak: json['longestStreak'] ?? 0,
//     level: json['level'] ?? 1,
//     achievements: List<String>.from(json['achievements'] ?? []),
//     dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
//   );
// }
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  int totalTasbihat;
  int currentStreak;
  int longestStreak;
  int level;
  List<String> achievements;
  Map<String, int> dailyCompletions;

  UserStats({
    this.totalTasbihat = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.level = 1,
    List<String>? achievements,
    Map<String, int>? dailyCompletions,
  })  : achievements = achievements ?? [],
        dailyCompletions = dailyCompletions ?? {};

  Map<String, dynamic> toJson() => {
    'totalTasbihat': totalTasbihat,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'level': level,
    'achievements': achievements,
    'dailyCompletions': dailyCompletions,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalTasbihat: json['totalTasbihat'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    level: json['level'] ?? 1,
    achievements: List<String>.from(json['achievements'] ?? []),
    dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
  );

  /// حفظ البيانات في SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_stats', jsonEncode(toJson()));
  }

  /// تحميل البيانات من SharedPreferences
  static Future<UserStats> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_stats');
    if (jsonString != null) {
      return UserStats.fromJson(jsonDecode(jsonString));
    } else {
      return UserStats(); // لو ما فيش بيانات، ارجع القيم الافتراضية
    }
  }
}
