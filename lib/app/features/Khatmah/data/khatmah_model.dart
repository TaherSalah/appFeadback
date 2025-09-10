import 'package:hive/hive.dart';

part 'khatmah_model.g.dart';

@HiveType(typeId: 0)
class KhatmahModel extends HiveObject {
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

  KhatmahModel({
    required this.id,
    required this.title,
    required this.totalPages,
    this.currentPage = 0,
    required this.startDate,
    required this.endDate,
    required this.dailyPages,
    List<DateTime>? progressDates,
    this.isCompleted = false,
  }) : progressDates = progressDates ?? [];

  /// عدد الصفحات المتبقية
  int get pagesLeft => (totalPages - currentPage).clamp(0, totalPages);

  /// الأيام المتبقية حتى نهاية الختمة
  int get daysLeft {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// حزب أو ورد اليوم
  String get todayWird {
    final start = currentPage + 1;
    final end = (currentPage + dailyPages) > totalPages
        ? totalPages
        : (currentPage + dailyPages);
    return "من صفحة $start إلى صفحة $end";
  }

  /// نسبة التقدم
  double get progressPercent =>
      totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0, 1);

  /// تحديث التقدم
  void markProgress(int pagesReadToday) {
    currentPage += pagesReadToday;
    progressDates.add(DateTime.now());
    if (currentPage >= totalPages) {
      currentPage = totalPages;
      isCompleted = true;
    }
    save(); // حفظ التغيرات في Hive
  }
}
