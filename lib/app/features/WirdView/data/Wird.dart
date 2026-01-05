import 'Dhikr.dart';

class Wird {
  final String id;
  final String name;
  final List<Dhikr> adhkar;
  final DateTime createdAt;
  int completedCount;
  DateTime? lastCompletedDate;
  String? reminderTime;
  String category;
  List<DateTime> completionHistory;
  bool isCompleted;


  // ✅ إضافة حفظ التقدم الحالي
  int currentDhikrIndex;
  bool isInProgress;

  // ✅ إضافة التكرار (daily, weekly, monthly, once)
  final String frequency;
  int color; // ✅ حقل اللون الجديد

  Wird({
    required this.id,
    required this.name,
    required this.adhkar,
    required this.createdAt,
    this.completedCount = 0,
    this.lastCompletedDate,
    this.reminderTime,
    this.category = 'عام',
    List<DateTime>? completionHistory,
    this.currentDhikrIndex = 0,
    this.isInProgress = false,
    this.isCompleted = false,
    this.frequency = 'daily', 
    this.color = 0xFF00897B, // ✅ الافتراضي (Teal)
  }) : completionHistory = completionHistory ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'adhkar': adhkar.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'completedCount': completedCount,
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'reminderTime': reminderTime,
    'category': category,
    'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
    'currentDhikrIndex': currentDhikrIndex,
    'isInProgress': isInProgress,
    'isCompleted': isCompleted,
    'frequency': frequency,
    'color': color, // ✅ حفظ اللون
  };

  factory Wird.fromJson(Map<String, dynamic> json) => Wird(
    isCompleted: json['isCompleted'] ?? false,

    id: json['id'],
    name: json['name'],
    adhkar: (json['adhkar'] as List).map((d) => Dhikr.fromJson(d)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    completedCount: json['completedCount'] ?? 0,
    lastCompletedDate: json['lastCompletedDate'] != null
        ? DateTime.parse(json['lastCompletedDate'])
        : null,
    reminderTime: json['reminderTime'],
    category: json['category'] ?? 'عام',
    completionHistory: (json['completionHistory'] as List?)
        ?.map((d) => DateTime.parse(d))
        .toList() ??
        [],
    currentDhikrIndex: json['currentDhikrIndex'] ?? 0,
    isInProgress: json['isInProgress'] ?? false,
    frequency: json['frequency'] ?? 'daily',
    color: json['color'] ?? 0xFF00897B, // ✅ استرجاع اللون
  );
}
