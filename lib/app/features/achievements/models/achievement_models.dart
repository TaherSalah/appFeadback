import 'package:hive/hive.dart';

part 'achievement_models.g.dart';

/// أنواع الإنجازات
@HiveType(typeId: 16)
enum AchievementType {
  @HiveField(0)
  prayer, // صلاة
  @HiveField(1)
  quran, // قرآن
  @HiveField(2)
  azkar, // أذكار
  @HiveField(3)
  charity, // صدقة
  @HiveField(4)
  learning, // تعلم
  @HiveField(5)
  streaks, // سلاسل متواصلة
  @HiveField(6)
  special, // خاص
}

/// مستوى الإنجاز
@HiveType(typeId: 17)
enum AchievementRarity {
  @HiveField(0)
  common, // عادي
  @HiveField(1)
  rare, // نادر
  @HiveField(2)
  epic, // أسطوري
  @HiveField(3)
  legendary, // خرافي
}

/// إنجاز
@HiveType(typeId: 11)
class Achievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final int points;

  @HiveField(5)
  final AchievementType type;

  @HiveField(6)
  final AchievementRarity rarity;

  @HiveField(7)
  final int targetValue; // القيمة المطلوبة

  @HiveField(8)
  bool isUnlocked;

  @HiveField(9)
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    required this.type,
    required this.rarity,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

/// تقدم المستخدم
@HiveType(typeId: 12)
class UserProgress {
  @HiveField(0)
  int totalPoints;

  @HiveField(1)
  int level;

  @HiveField(2)
  List<String> unlockedAchievements;

  @HiveField(3)
  Map<String, int> activityCounters; // عداد النشاطات

  UserProgress({
    this.totalPoints = 0,
    this.level = 1,
    List<String>? unlockedAchievements,
    Map<String, int>? activityCounters,
  })  : unlockedAchievements = unlockedAchievements ?? [],
        activityCounters = activityCounters ?? {};

  int get currentLevelPoints {
    return totalPoints - _getPointsForLevel(level - 1);
  }

  int get nextLevelPoints {
    return _getPointsForLevel(level) - _getPointsForLevel(level - 1);
  }

  double get levelProgress {
    if (nextLevelPoints == 0) return 1.0;
    return currentLevelPoints / nextLevelPoints;
  }

  String get levelTitle {
    if (level < 5) return 'مبتدئ';
    if (level < 10) return 'متقدم';
    if (level < 20) return 'محترف';
    if (level < 30) return 'خبير';
    if (level < 50) return 'أستاذ';
    return 'عالم';
  }

  int _getPointsForLevel(int lvl) {
    return (lvl * lvl * 100).toInt();
  }

  void addPoints(int points) {
    totalPoints += points;
    while (totalPoints >= _getPointsForLevel(level)) {
      level++;
    }
  }
}

/// تحدٍ
@HiveType(typeId: 18)
enum ChallengeType {
  @HiveField(0)
  daily, // يومي
  @HiveField(1)
  weekly, // أسبوعي
  @HiveField(2)
  monthly, // شهري
}

@HiveType(typeId: 13)
class Challenge {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final ChallengeType type;

  @HiveField(5)
  final int targetValue;

  @HiveField(6)
  int currentProgress;

  @HiveField(7)
  final int rewardPoints;

  @HiveField(8)
  final DateTime startDate;

  @HiveField(9)
  final DateTime endDate;

  @HiveField(10)
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  double get progress {
    if (targetValue == 0) return 1.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isCompleted;
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate) && !isCompleted;
  }
}

/// إدخال في اللوحة
class LeaderboardEntry {
  final String name;
  final int points;
  final int level;
  final int rank;
  final String avatar;

  LeaderboardEntry({
    required this.name,
    required this.points,
    required this.level,
    required this.rank,
    required this.avatar,
  });
}
