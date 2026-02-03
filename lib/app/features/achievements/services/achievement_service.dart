import 'package:hive/hive.dart';
import '../models/achievement_models.dart';
import '../data/achievements_data.dart';

class AchievementService {
  static const String _progressBoxName = 'userProgressBox';
  static const String _challengesBoxName = 'challengesBox';
  static const String _completedStoriesBoxName = 'completedStoriesBox';

  late Box _progressBox;
  late Box<Challenge> _challengesBox;
  late Box<String> _completedStoriesBox;

  UserProgress? _userProgress;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_progressBoxName)) {
      _progressBox = await Hive.openBox(_progressBoxName);
    } else {
      _progressBox = Hive.box(_progressBoxName);
    }

    if (!Hive.isBoxOpen(_completedStoriesBoxName)) {
      _completedStoriesBox = await Hive.openBox<String>(_completedStoriesBoxName);
    } else {
      _completedStoriesBox = Hive.box<String>(_completedStoriesBoxName);
    }

    if (!Hive.isBoxOpen(_challengesBoxName)) {
      _challengesBox = await Hive.openBox<Challenge>(_challengesBoxName);
    } else {
      _challengesBox = Hive.box<Challenge>(_challengesBoxName);
    }

    _loadProgress();
  }

  void _loadProgress() {
    final data = _progressBox.get('progress');
    if (data != null) {
      _userProgress = data as UserProgress;
    } else {
      _userProgress = UserProgress();
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    await _progressBox.put('progress', _userProgress);
  }

  UserProgress getProgress() => _userProgress ?? UserProgress();

  /// إضافة نقاط
  Future<void> addPoints(int points, {String? reason}) async {
    _userProgress!.addPoints(points);
    await _saveProgress();
  }

  /// التحقق من إكمال القصة
  bool isStoryCompleted(String storyId) {
    return _completedStoriesBox.containsKey(storyId);
  }

  /// تسجيل إكمال القصة ومنح النقاط (مرة واحدة فقط)
  Future<bool> completeStory(String storyId, int points) async {
    if (isStoryCompleted(storyId)) return false;

    await _completedStoriesBox.put(storyId, DateTime.now().toIso8601String());
    await addPoints(points, reason: 'إكمال قصة');
    return true;
  }

  /// تسجيل نشاط
  Future<List<Achievement>> recordActivity(String activityType, {int count = 1}) async {
    final currentCount = _userProgress!.activityCounters[activityType] ?? 0;
    _userProgress!.activityCounters[activityType] = currentCount + count;

    // تحقق من الإنجازات
    final unlockedAchievements = await _checkAchievements(activityType);

    await _saveProgress();
    return unlockedAchievements;
  }

  /// تحقق من الإنجازات
  Future<List<Achievement>> _checkAchievements(String activityType) async {
    final newlyUnlocked = <Achievement>[];

    for (var achievement in AchievementsData.allAchievements) {
      if (_userProgress!.unlockedAchievements.contains(achievement.id)) {
        continue; // تم فتحه بالفعل
      }

      final activityCount = _userProgress!.activityCounters[activityType] ?? 0;

      // تحقق بسيط: إذا كان النشاط يطابق ووصل للهدف
      if (activityCount >= achievement.targetValue) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        _userProgress!.unlockedAchievements.add(achievement.id);
        _userProgress!.addPoints(achievement.points);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// الحصول على كل الإنجازات
  List<Achievement> getAllAchievements() {
    return AchievementsData.allAchievements.map((a) {
      if (_userProgress!.unlockedAchievements.contains(a.id)) {
        a.isUnlocked = true;
      }
      return a;
    }).toList();
  }

  /// الحصول على الإنجازات المفتوحة
  List<Achievement> getUnlockedAchievements() {
    return getAllAchievements().where((a) => a.isUnlocked).toList();
  }

  /// إنشاء تحديات تلقائية
  Future<void> generateDailyChallenges() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // تحقق إذا كان هناك تحديات يومية اليوم
    final existingDaily = _challengesBox.values
        .where((c) =>
            c.type == ChallengeType.daily &&
            c.startDate.day == now.day &&
            c.startDate.month == now.month)
        .toList();

    if (existingDaily.isEmpty) {
      // إنشاء تحديات جديدة
      final challenges = [
        Challenge(
          id: 'daily_prayer_${now.millisecondsSinceEpoch}',
          title: 'صلِّ 5 صلوات اليوم',
          description: 'أكمل الصلوات الخمس',
          emoji: '🕌',
          type: ChallengeType.daily,
          targetValue: 5,
          rewardPoints: 30,
          startDate: today,
          endDate: tomorrow,
        ),
        Challenge(
          id: 'daily_quran_${now.millisecondsSinceEpoch}',
          title: 'اقرأ صفحة من القرآن',
          description: 'اقرأ صفحة واحدة على الأقل',
          emoji: '📖',
          type: ChallengeType.daily,
          targetValue: 1,
          rewardPoints: 20,
          startDate: today,
          endDate: tomorrow,
        ),
      ];

      for (var challenge in challenges) {
        await _challengesBox.put(challenge.id, challenge);
      }
    }
  }

  /// الحصول على التحديات النشطة
  List<Challenge> getActiveChallenges() {
    return _challengesBox.values.where((c) => c.isActive).toList();
  }

  /// تحديث تقدم التحدي
  Future<bool> updateChallengeProgress(String challengeId, int progress) async {
    final challenge = _challengesBox.get(challengeId);
    if (challenge != null && !challenge.isCompleted) {
      challenge.currentProgress += progress;

      if (challenge.currentProgress >= challenge.targetValue) {
        challenge.isCompleted = true;
        await addPoints(challenge.rewardPoints, reason: 'إكمال تحدي');
      }

      await _challengesBox.put(challengeId, challenge);
      return challenge.isCompleted;
    }
    return false;
  }

  /// Leaderboard وهمي للتحفيز
  List<LeaderboardEntry> getLeaderboard() {
    final userPoints = _userProgress!.totalPoints;
    final userLevel = _userProgress!.level;

    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        name: 'أنت',
        points: userPoints,
        level: userLevel,
        rank: 1,
        avatar: '😊',
      ),
      LeaderboardEntry(
        name: 'محمد أحمد',
        points: userPoints + 500,
        level: userLevel + 2,
        rank: 2,
        avatar: '🌟',
      ),
      LeaderboardEntry(
        name: 'فاطمة علي',
        points: userPoints + 300,
        level: userLevel + 1,
        rank: 3,
        avatar: '✨',
      ),
      LeaderboardEntry(
        name: 'عمر خالد',
        points: userPoints - 100,
        level: userLevel,
        rank: 4,
        avatar: '🎯',
      ),
      LeaderboardEntry(
        name: 'عائشة حسن',
        points: userPoints - 200,
        level: userLevel - 1,
        rank: 5,
        avatar: '💎',
      ),
    ];

    // ترتيب حسب النقاط
    entries.sort((a, b) => b.points.compareTo(a.points));

    // تصحيح الترتيب
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        name: entries[i].name,
        points: entries[i].points,
        level: entries[i].level,
        rank: i + 1,
        avatar: entries[i].avatar,
      );
    }

    return entries;
  }
}
