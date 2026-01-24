import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ReadingAnalyticsService {
  static const String _prefixTime = 'analytics_time_';
  static const String _prefixPages = 'analytics_pages_';

  // Get current date key formatted as yyyy-MM-dd
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> addReadingTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefixTime + _getDateKey(DateTime.now());
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + seconds);
  }

  Future<void> incrementPagesRead() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefixPages + _getDateKey(DateTime.now());
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  Future<List<DailyReadingStat>> getWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<DailyReadingStat> stats = [];
    DateTime today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime date = today.subtract(Duration(days: i));
      String dateKey = _getDateKey(date);

      int seconds = prefs.getInt(_prefixTime + dateKey) ?? 0;
      int pages = prefs.getInt(_prefixPages + dateKey) ?? 0;

      // Use Arabic day names if needed, or stick to formatting in UI
      stats.add(DailyReadingStat(
        date: date,
        secondsRead: seconds,
        pagesRead: pages,
      ));
    }
    return stats;
  }

  Future<List<DailyReadingStat>> getMonthlyStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<DailyReadingStat> stats = [];
    DateTime today = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      DateTime date = today.subtract(Duration(days: i));
      String dateKey = _getDateKey(date);

      int seconds = prefs.getInt(_prefixTime + dateKey) ?? 0;
      int pages = prefs.getInt(_prefixPages + dateKey) ?? 0;

      if (seconds > 0 || pages > 0) {
        stats.add(DailyReadingStat(
          date: date,
          secondsRead: seconds,
          pagesRead: pages,
        ));
      }
    }
    // Return newest first for list view
    return stats.reversed.toList();
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = 0;
    DateTime date = DateTime.now();

    // Check today
    if ((prefs.getInt(_prefixTime + _getDateKey(date)) ?? 0) > 0) {
      streak++;
    }

    // Check previous days
    while (true) {
      date = date.subtract(const Duration(days: 1));
      int seconds = prefs.getInt(_prefixTime + _getDateKey(date)) ?? 0;
      if (seconds > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<Map<String, int>> getTodayStats() async {
    final prefs = await SharedPreferences.getInstance();
    String key = _getDateKey(DateTime.now());
    return {
      'seconds': prefs.getInt(_prefixTime + key) ?? 0,
      'pages': prefs.getInt(_prefixPages + key) ?? 0,
    };
  }
}

class DailyReadingStat {
  final DateTime date;
  final int secondsRead;
  final int pagesRead;

  DailyReadingStat({
    required this.date,
    required this.secondsRead,
    required this.pagesRead,
  });
}
