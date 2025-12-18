import '../models/achievement_models.dart';

class AchievementsData {
  static final List<Achievement> allAchievements = [
    // إنجازات الصلاة
    Achievement(
      id: 'prayer_first',
      title: 'أول صلاة',
      description: 'صلِّ أول صلاة في التطبيق',
      emoji: '🕌',
      points: 10,
      type: AchievementType.prayer,
      rarity: AchievementRarity.common,
      targetValue: 1,
    ),
    Achievement(
      id: 'prayer_week',
      title: 'مصلٍ منتظم',
      description: 'صلِّ 5 صلوات يومية لمدة أسبوع',
      emoji: '📿',
      points: 50,
      type: AchievementType.prayer,
      rarity: AchievementRarity.rare,
      targetValue: 35,
    ),
    Achievement(
      id: 'fajr_early',
      title: 'صلاة الفجر',
      description: 'صلِّ الفجر 30 يوماً متتالياً',
      emoji: '🌅',
      points: 100,
      type: AchievementType.prayer,
      rarity: AchievementRarity.epic,
      targetValue: 30,
    ),

    // إنجازات القرآن
    Achievement(
      id: 'quran_start',
      title: 'قارئ القرآن',
      description: 'اقرأ أول صفحة من القرآن',
      emoji: '📖',
      points: 10,
      type: AchievementType.quran,
      rarity: AchievementRarity.common,
      targetValue: 1,
    ),
    Achievement(
      id: 'quran_juz',
      title: 'جزء كامل',
      description: 'أكمل قراءة جزء كامل',
      emoji: '📚',
      points: 50,
      type: AchievementType.quran,
      rarity: AchievementRarity.rare,
      targetValue: 20,
    ),
    Achievement(
      id: 'quran_khatmah',
      title: 'ختمة القرآن',
      description: 'أكمل ختمة كاملة للقرآن الكريم',
      emoji: '✨',
      points: 200,
      type: AchievementType.quran,
      rarity: AchievementRarity.legendary,
      targetValue: 604,
    ),

    // إنجازات الأذكار
    Achievement(
      id: 'azkar_morning',
      title: 'أذكار الصباح',
      description: 'اقرأ أذكار الصباح 7 أيام متتالية',
      emoji: '🌤️',
      points: 30,
      type: AchievementType.azkar,
      rarity: AchievementRarity.common,
      targetValue: 7,
    ),
    Achievement(
      id: 'azkar_evening',
      title: 'أذكار المساء',
      description: 'اقرأ أذكار المساء 7 أيام متتالية',
      emoji: '🌙',
      points: 30,
      type: AchievementType.azkar,
      rarity: AchievementRarity.common,
      targetValue: 7,
    ),
    Achievement(
      id: 'azkar_complete',
      title: 'ذاكر دائم',
      description: 'اقرأ أذكار الصباح والمساء لمدة شهر',
      emoji: '📿',
      points: 100,
      type: AchievementType.azkar,
      rarity: AchievementRarity.epic,
      targetValue: 60,
    ),

    // إنجازات الصدقة
    Achievement(
      id: 'charity_first',
      title: 'متصدق',
      description: 'تصدق بأول صدقة',
      emoji: '💰',
      points: 20,
      type: AchievementType.charity,
      rarity: AchievementRarity.common,
      targetValue: 1,
    ),
    Achievement(
      id: 'charity_streak',
      title: 'صدقة يومية',
      description: 'تصدق كل يوم لمدة أسبوع',
      emoji: '🔥',
      points: 50,
      type: AchievementType.charity,
      rarity: AchievementRarity.rare,
      targetValue: 7,
    ),
    Achievement(
      id: 'charity_generous',
      title: 'كريم سخي',
      description: 'تصدق 100 مرة',
      emoji: '💎',
      points: 150,
      type: AchievementType.charity,
      rarity: AchievementRarity.legendary,
      targetValue: 100,
    ),

    // إنجازات التعلم
    Achievement(
      id: 'hadith_reader',
      title: 'قارئ الأحاديث',
      description: 'اقرأ 10 أحاديث',
      emoji: '📜',
      points: 30,
      type: AchievementType.learning,
      rarity: AchievementRarity.common,
      targetValue: 10,
    ),
    Achievement(
      id: 'story_lover',
      title: 'محب القصص',
      description: 'اقرأ 5 قصص ملهمة',
      emoji: '📚',
      points: 20,
      type: AchievementType.learning,
      rarity: AchievementRarity.common,
      targetValue: 5,
    ),

    // إنجازات السلاسل
    Achievement(
      id: 'week_warrior',
      title: 'محارب الأسبوع',
      description: 'حافظ على نشاط يومي لمدة أسبوع',
      emoji: '⚔️',
      points: 40,
      type: AchievementType.streaks,
      rarity: AchievementRarity.rare,
      targetValue: 7,
    ),
    Achievement(
      id: 'month_master',
      title: 'سيد الشهر',
      description: 'حافظ على نشاط يومي لمدة شهر',
      emoji: '👑',
      points: 150,
      type: AchievementType.streaks,
      rarity: AchievementRarity.epic,
      targetValue: 30,
    ),

    // إنجازات خاصة
    Achievement(
      id: 'ramadan_champion',
      title: 'بطل رمضان',
      description: 'أكمل جميع الأنشطة في رمضان',
      emoji: '🌙',
      points: 300,
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 30,
    ),
    Achievement(
      id: 'complete_profile',
      title: 'ملف كامل',
      description: 'أكمل ملفك الشخصي',
      emoji: '✅',
      points: 10,
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
    ),
  ];

  /// الحصول على إنجازات حسب النوع
  static List<Achievement> getAchievementsByType(AchievementType type) {
    return allAchievements.where((a) => a.type == type).toList();
  }

  /// الحصول على إنجازات حسب الندرة
  static List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return allAchievements.where((a) => a.rarity == rarity).toList();
  }
}
