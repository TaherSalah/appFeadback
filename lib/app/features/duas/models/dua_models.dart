import 'package:hive/hive.dart';

part 'dua_models.g.dart';

/// فئة الدعاء
enum DuaCategory {
  travel, // سفر
  study, // دراسة
  health, // صحة
  anxiety, // قلق
  morning, // صباح
  evening, // مساء
  sleep, // نوم
  prophet, // أدعية الأنبياء
  quran, // أدعية من القرآن
  general, // عام
}

extension DuaCategoryExtension on DuaCategory {
  String get arabicName {
    const names = {
      DuaCategory.travel: 'السفر',
      DuaCategory.study: 'الدراسة',
      DuaCategory.health: 'الصحة',
      DuaCategory.anxiety: 'القلق والهم',
      DuaCategory.morning: 'الصباح',
      DuaCategory.evening: 'المساء',
      DuaCategory.sleep: 'النوم',
      DuaCategory.prophet: 'أدعية الأنبياء',
      DuaCategory.quran: 'أدعية من القرآن',
      DuaCategory.general: 'عام',
    };
    return names[this]!;
  }

  String get emoji {
    const emojis = {
      DuaCategory.travel: '✈️',
      DuaCategory.study: '📚',
      DuaCategory.health: '🏥',
      DuaCategory.anxiety: '💆',
      DuaCategory.morning: '🌅',
      DuaCategory.evening: '🌙',
      DuaCategory.sleep: '😴',
      DuaCategory.prophet: '🌟',
      DuaCategory.quran: '📖',
      DuaCategory.general: '🤲',
    };
    return emojis[this]!;
  }
}

/// دعاء
class Dua {
  final String id;
  final String title;
  final String arabic;
  final String meaning;
  final DuaCategory category;
  final String? source; // المصدر (آية/حديث)

  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.category,
    this.source,
  });
}

/// دعاء مخصص
@HiveType(typeId: 14)
class CustomDua extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String arabic;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final DateTime createdAt;

  CustomDua({
    required this.id,
    required this.title,
    required this.arabic,
    this.notes,
    required this.createdAt,
  });
}

/// تذكير بالدعاء
@HiveType(typeId: 15)
class DuaReminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String duaId; // ID الدعاء

  @HiveField(2)
  final String title;

  @HiveField(3)
  final int hour;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  final List<int> weekdays; // 1-7 (الأحد = 7)

  @HiveField(6)
  bool isActive;

  DuaReminder({
    required this.id,
    required this.duaId,
    required this.title,
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.isActive = true,
  });
}
