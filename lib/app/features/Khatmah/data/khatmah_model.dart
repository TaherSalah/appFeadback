import 'package:hive/hive.dart';

//
// @HiveType(typeId: 0)
// class KhatmahModel extends HiveObject {
//   @HiveField(0)
//   String id;
//
//   @HiveField(1)
//   String title;
//
//   @HiveField(2)
//   int totalPages;
//
//   @HiveField(3)
//   int currentPage;
//
//   @HiveField(4)
//   DateTime startDate;
//
//   @HiveField(5)
//   DateTime endDate;
//
//   @HiveField(6)
//   bool isCompleted;
//
//   @HiveField(7)
//   int dailyPages;
//
//   @HiveField(8)
//   List<DateTime> progressDates;
//   @HiveField(9)
//   String distributionType; // "صفحات" أو "أجزاء"
//
//   @HiveField(10)
//   List<int> selectedAjzaa; // أرقام الأجزاء (1..30)
//
//   KhatmahModel({
//     required this.id,
//     this.distributionType = "صفحات",
//     this.selectedAjzaa = const [],
//     required this.title,
//     required this.totalPages,
//     this.currentPage = 0,
//     required this.startDate,
//     required this.endDate,
//     required this.dailyPages,
//     List<DateTime>? progressDates,
//     this.isCompleted = false,
//   }) : progressDates = progressDates ?? [];
//
//   /// عدد الصفحات المتبقية
//   int get pagesLeft => (totalPages - currentPage).clamp(0, totalPages);
//
//   /// الأيام المتبقية حتى نهاية الختمة
//   int get daysLeft {
//     final diff = endDate.difference(DateTime.now()).inDays;
//     return diff < 0 ? 0 : diff;
//   }
//
//   /// حزب أو ورد اليوم
//   String get todayWird {
//     final start = currentPage + 1;
//     final end = (currentPage + dailyPages) > totalPages
//         ? totalPages
//         : (currentPage + dailyPages);
//     return "من صفحة $start إلى صفحة $end";
//   }
//
//   /// نسبة التقدم
//   double get progressPercent =>
//       totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0, 1);
//
//   /// تحديث التقدم
//   void markProgress(int pagesReadToday) {
//     currentPage += pagesReadToday;
//     progressDates.add(DateTime.now());
//     if (currentPage >= totalPages) {
//       currentPage = totalPages;
//       isCompleted = true;
//     }
//     save(); // حفظ التغيرات في Hive
//   }
// }
// flutter pub run build_runner watch --delete-conflicting-outputs

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
}
