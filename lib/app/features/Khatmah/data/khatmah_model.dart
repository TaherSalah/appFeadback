import 'package:hive/hive.dart';

part 'khatmah_model.g.dart'; // مهم جدًا

@HiveType(typeId: 0) // حافظ على نفس typeId لو كان مستخدم قبل كده
class KhatmahModel extends HiveObject {
  KhatmahModel({
    required this.id,
    required this.title,
    required this.totalPages,
    this.currentPage = 0,
    required this.startDate,
    required this.endDate,
    required this.dailyPages,
    this.isCompleted = false,
    List<DateTime>? progressDates,
  }) : progressDates = progressDates ?? [];

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int totalPages;

  @HiveField(3)
  int currentPage;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime endDate;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int dailyPages;

  @HiveField(8)
  List<DateTime> progressDates;

  // ----- getters المساعدة -----
  double get progressPercent =>
      totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0.0, 1.0);

  int get pagesLeft => (totalPages - currentPage).clamp(0, totalPages);

  int get daysLeft {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get todayWird {
    final start = currentPage + 1;
    final end = (currentPage + dailyPages) > totalPages
        ? totalPages
        : (currentPage + dailyPages);
    return "من صفحة $start إلى صفحة $end";
  }

  // ----- New Status Getters -----

  int get currentDay {
    final diff = DateTime.now().difference(startDate).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  bool get isBehind {
    if (isCompleted) return false;
    final expectedPages = currentDay * dailyPages;
    return currentPage < expectedPages;
  }

  bool get isAhead {
    if (isCompleted) return true;
    final expectedPages = currentDay * dailyPages;
    return currentPage >= expectedPages;
  }

  int get pagesBehind {
    final expectedPages = currentDay * dailyPages;
    final diff = expectedPages - currentPage;
    return diff > 0 ? diff : 0;
  }

  int get daysBehind {
    if (dailyPages == 0) return 0;
    return (pagesBehind / dailyPages).ceil();
  }

  int get daysAhead {
    if (dailyPages == 0) return 0;
    final expectedPages = currentDay * dailyPages;
    final diff = currentPage - expectedPages;
    return diff > 0 ? (diff / dailyPages).floor() : 0;
  }
}
