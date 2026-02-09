import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/charity_models.dart';
import '../../../core/services/home_widget_service.dart';

class CharityService {
  static const String _charityBoxName = 'charityBox';
  static const String _recurringBoxName = 'recurringCharityBox';
  static const String _settingsBoxName = 'charitySettingsBox';
  static const String _monthlyGoalsBoxName = 'monthlyGoalsBox';
  static const String _achievementsBoxName = 'charityAchievementsBox';
  static const String _monthlyIncomeKey = 'monthlyIncome';
  static const String _longestStreakKey = 'longestStreak';

  late Box<CharityDonation> _charityBox;
  late Box<RecurringCharity> _recurringBox;
  late Box<MonthlyGoal> _monthlyGoalsBox;
  late Box<CharityAchievement> _achievementsBox;
  late Box _settingsBox;
  final Uuid _uuid = const Uuid();
  
  /// Get a listenable for charity donations to react to changes
  ValueListenable<Box<CharityDonation>> get donationsListenable => _charityBox.listenable();

  /// Get a listenable for recurring charities to react to status changes
  ValueListenable<Box<RecurringCharity>> get recurringListenable => _recurringBox.listenable();

  /// تهيئة الخدمة
  Future<void> init() async {
    if (!Hive.isBoxOpen(_charityBoxName)) {
      _charityBox = await Hive.openBox<CharityDonation>(_charityBoxName);
    } else {
      _charityBox = Hive.box<CharityDonation>(_charityBoxName);
    }

    if (!Hive.isBoxOpen(_recurringBoxName)) {
      _recurringBox = await Hive.openBox<RecurringCharity>(_recurringBoxName);
    } else {
      _recurringBox = Hive.box<RecurringCharity>(_recurringBoxName);
    }

    if (!Hive.isBoxOpen(_settingsBoxName)) {
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } else {
      _settingsBox = Hive.box(_settingsBoxName);
    }

    if (!Hive.isBoxOpen(_monthlyGoalsBoxName)) {
      _monthlyGoalsBox = await Hive.openBox<MonthlyGoal>(_monthlyGoalsBoxName);
    } else {
      _monthlyGoalsBox = Hive.box<MonthlyGoal>(_monthlyGoalsBoxName);
    }

    if (!Hive.isBoxOpen(_achievementsBoxName)) {
      _achievementsBox =
          await Hive.openBox<CharityAchievement>(_achievementsBoxName);
    } else {
      _achievementsBox = Hive.box<CharityAchievement>(_achievementsBoxName);
    }

    // اطلب إذن الإشعارات إذا لم يكن موجوداً
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// حفظ صدقة جديدة
  Future<void> addDonation(CharityDonation donation) async {
    await _charityBox.put(donation.id, donation);
    await _updateLongestStreak();
    await checkAchievements(); // تحقق من الإنجازات بعد كل تبرع
    await _updateCharityWidget(); // تحديث الـ widget
  }

  /// تحديث صدقة
  Future<void> updateDonation(CharityDonation donation) async {
    await _charityBox.put(donation.id, donation);
    await _updateCharityWidget(); // تحديث الـ widget
  }

  /// حذف صدقة
  Future<void> deleteDonation(String id) async {
    await _charityBox.delete(id);
    await _updateLongestStreak();
    await _updateCharityWidget(); // تحديث الـ widget
  }

  /// الحصول على جميع الصدقات
  List<CharityDonation> getAllDonations() {
    return _charityBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// الحصول على صدقات حسب الفترة
  List<CharityDonation> getDonationsByDateRange(DateTime start, DateTime end) {
    return _charityBox.values
        .where((d) => d.date.isAfter(start) && d.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// حساب الإحصائيات
  CharityStats calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    final allDonations = getAllDonations();

    // الإجماليات
    final totalToday =
        _sumDonations(allDonations.where((d) => _isSameDay(d.date, today)));
    final totalThisWeek =
        _sumDonations(allDonations.where((d) => d.date.isAfter(weekStart)));
    final totalThisMonth =
        _sumDonations(allDonations.where((d) => d.date.isAfter(monthStart)));
    final totalThisYear =
        _sumDonations(allDonations.where((d) => d.date.isAfter(yearStart)));
    final totalAllTime = _sumDonations(allDonations);

    // العدد
    final donationsCount = allDonations.length;

    // المتوسط
    final averagePerDonation =
        donationsCount > 0 ? (totalAllTime / donationsCount).toDouble() : 0.0;

    // Streak
    final currentStreak = _calculateCurrentStreak(allDonations);
    final longestStreak = _getLongestStreak();

    // التوزيع حسب الفئات
    final categoryBreakdown = _getCategoryBreakdown(allDonations);

    // بيانات الرسم البياني (آخر 6 شهور)
    final monthlyData = _getMonthlyData(allDonations);

    return CharityStats(
      totalToday: totalToday,
      totalThisWeek: totalThisWeek,
      totalThisMonth: totalThisMonth,
      totalThisYear: totalThisYear,
      totalAllTime: totalAllTime,
      donationsCount: donationsCount,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averagePerDonation: averagePerDonation,
      categoryBreakdown: categoryBreakdown,
      monthlyData: monthlyData,
    );
  }

  /// اقتراح الصدقة اليومية
  CharitySuggestion getDailySuggestion() {
    final monthlyIncome = getMonthlyIncome();

    if (monthlyIncome <= 0) {
      return CharitySuggestion(
        suggestedAmount: 10,
        reason: 'ابدأ بمبلغ صغير',
        motivation: '\"لا تحقرن من المعروف شيئاً\" - حديث شريف',
      );
    }

    // 1% من الدخل الشهري مقسوم على 30 يوم
    final dailySuggestion = (monthlyIncome * 0.01) / 30;

    final motivations = [
      '\"مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ\" - صحيح مسلم',
      '\"الصَّدَقَةُ تُطْفِئُ الخَطِيئَةَ كَمَا يُطْفِئُ المَاءُ النَّارَ\" - صحيح الترمذي',
      '\"اتَّقُوا النَّارَ وَلَوْ بِشِقِّ تَمْرَةٍ\" - صحيح البخاري ومسلم',
      '\"كُلُّ امْرِئٍ فِي ظِلِّ صَدَقَتِهِ حَتَّى يُفْصَلَ بَيْنَ النَّاسِ\" - صحيح ابن حبان',
      '\"إِنَّ الصَّدَقَةَ لَتُطْفِئُ عَنْ أَهْلِهَا حَرَّ القُبُورِ\" - السلسلة الصحيحة',
      '\"صَنَائِعُ الْمَعْرُوفِ تَقِي مَصَارِعَ السُّوءِ وَالآفَاتِ وَالْهَلَكَاتِ\" - مستدرك الحاكم (حسن)',
    ];
    final random = DateTime.now().millisecond % motivations.length;

    return CharitySuggestion(
      suggestedAmount: dailySuggestion,
      reason: 'حوالي 1% من دخلك الشهري',
      motivation: motivations[random],
    );
  }

  // / حفظ الدخل الشهري
  Future<void> setMonthlyIncome(double income) async {
    await _settingsBox.put(_monthlyIncomeKey, income);
  }

  // / الحصول على الدخل الشهري
  double getMonthlyIncome() {
    return _settingsBox.get(_monthlyIncomeKey, defaultValue: 0.0) as double;
  }

  // / حفظ الهدف الشهري
  Future<void> setMonthlyGoal(double amount) async {
    final now = DateTime.now();
    final key = '${now.year}_${now.month}';
    await _monthlyGoalsBox.put(
        key, MonthlyGoal(amount: amount, month: now.month, year: now.year));
  }

  // / الحصول على الهدف الشهري الحالي
  MonthlyGoal? getMonthlyGoal() {
    final now = DateTime.now();
    final key = '${now.year}_${now.month}';
    return _monthlyGoalsBox.get(key);
  }

  // / حساب نسبة التقدم نحو الهدف
  double getGoalProgress(double currentTotal) {
    final goal = getMonthlyGoal();
    if (goal == null || goal.amount <= 0) return 0;
    return (currentTotal / goal.amount).clamp(0.0, 1.0);
  }

  // / حفظ إعدادات التذكير
  Future<void> saveReminderSettings(Map<String, dynamic> settings) async {
    for (var entry in settings.entries) {
      await _settingsBox.put('reminder_${entry.key}', entry.value);
    }
    await _rescheduleReminders();
  }

  // / الحصول على إعدادات التذكير
  Future<Map<String, dynamic>> getReminderSettings() async {
    return {
      'dailyEnabled':
          _settingsBox.get('reminder_dailyEnabled', defaultValue: true),
      'dailyHour': _settingsBox.get('reminder_dailyHour', defaultValue: 9),
      'dailyMinute': _settingsBox.get('reminder_dailyMinute', defaultValue: 0),
      'weeklyEnabled':
          _settingsBox.get('reminder_weeklyEnabled', defaultValue: false),
      'weeklyDay':
          _settingsBox.get('reminder_weeklyDay', defaultValue: 5), // الجمعة
      'weeklyHour': _settingsBox.get('reminder_weeklyHour', defaultValue: 10),
      'weeklyMinute':
          _settingsBox.get('reminder_weeklyMinute', defaultValue: 0),
      'goalReminderEnabled':
          _settingsBox.get('reminder_goalReminderEnabled', defaultValue: true),
    };
  }

  Future<void> _rescheduleReminders() async {
    final settings = await getReminderSettings();

    await AwesomeNotifications().cancel(900); // Daily
    await AwesomeNotifications().cancel(901); // Weekly

    if (settings['dailyEnabled']) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 900,
          channelKey: 'charity_reminder_channel',
          title: 'تذكير الصدقة اليومي ',
          body: '\"ما نقص مال من صدقة\".. لا تنسَ صدقتك اليوم ولو بشق تمرة ',
          notificationLayout: NotificationLayout.Default,
          payload: {'route': 'charity_dashboard'},
        ),
        schedule: NotificationCalendar(
          hour: settings['dailyHour'],
          minute: settings['dailyMinute'],
          second: 0,
          repeats: true,
        ),
      );
    }

    if (settings['weeklyEnabled']) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 901,
          channelKey: 'charity_reminder_channel',
          title: 'تذكير الصدقة الأسبوعي ',
          body:
              'يوم مبارك.. تذكر أن مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ، وَمَا زَادَ اللهُ عَبْدًا بِعَفْوٍ إِلَّا عِزًّا، وَمَا تَوَاضَعَ أَحَدٌ لِلَّهِ إِلَّا رَفَعَهُ اللهُ',
          notificationLayout: NotificationLayout.Default,
          payload: {'route': 'charity_dashboard'},
        ),
        schedule: NotificationCalendar(
          weekday: settings['weeklyDay'],
          hour: settings['weeklyHour'],
          minute: settings['weeklyMinute'],
          second: 0,
          repeats: true,
        ),
      );
    }
  }

  // ======== Achievement Logic ========

  /// الحصول على جميع الإنجازات المفتوحة
  List<CharityAchievement> getUnlockedAchievements() {
    return _achievementsBox.values.toList();
  }

  /// التحقق من فتح إنجازات جديدة
  Future<void> checkAchievements() async {
    final stats = calculateStats();
    final unlocked = getUnlockedAchievements();
    final newAchievements = <CharityAchievement>[];

    // 1. أول صدقة
    if (stats.donationsCount >= 1 &&
        !unlocked.any((a) => a.id == 'first_donation')) {
      newAchievements.add(CharityAchievement(
        id: 'first_donation',
        title: 'أول الغيث ️',
        description: 'قمت بأول تبرع لك في التطبيق',
        icon: '',
        unlockedDate: DateTime.now(),
      ));
    }

    // 2. المحسن المثابر (streak 7 days)
    if (stats.longestStreak >= 7 && !unlocked.any((a) => a.id == 'streak_7')) {
      newAchievements.add(CharityAchievement(
        id: 'streak_7',
        title: 'المحسن المثابر ',
        description: 'حافظت على التبرع لمدة 7 أيام متتالية',
        icon: '',
        unlockedDate: DateTime.now(),
      ));
    }

    // 3. السخي (Total > 1000)
    if (stats.totalAllTime >= 1000 &&
        !unlocked.any((a) => a.id == 'generous_1000')) {
      newAchievements.add(CharityAchievement(
        id: 'generous_1000',
        title: 'اليد السخية ',
        description: 'تجاوز إجمالي صدقاتك 1000 جنيه',
        icon: '',
        unlockedDate: DateTime.now(),
        goalValue: 1000,
      ));
    }

    // 4. محقق الأهداف
    final goalProgress = getGoalProgress(stats.totalThisMonth);
    if (goalProgress >= 1.0 && !unlocked.any((a) => a.id == 'goal_reached')) {
      newAchievements.add(CharityAchievement(
        id: 'goal_reached',
        title: 'محقق الأهداف',
        description: 'حققت هدفك المالي لهذا الشهر بالكامل',
        icon: '',
        unlockedDate: DateTime.now(),
      ));
    }

    for (var achievement in newAchievements) {
      await _achievementsBox.put(achievement.id, achievement);
      await _notifyAchievement(achievement);
    }
  }

  Future<void> _notifyAchievement(CharityAchievement achievement) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: achievement.id.hashCode.abs(),
        channelKey: 'achievement_unlocked_channel',
        title: 'إنجاز جديد فتح!',
        body:
            'لقد حصلت على وسام [${achievement.title}] - ${achievement.description}',
        notificationLayout: NotificationLayout.Default,
        payload: {'route': 'achievements'},
      ),
    );
  }

  /// توليد ID جديد
  String generateId() => _uuid.v4();

  // ======== Recurring Charity Methods ========

  /// إضافة صدقة دورية
  Future<void> addRecurringCharity(RecurringCharity recurring) async {
    await _recurringBox.put(recurring.id, recurring);
    if (recurring.isActive) {
      await scheduleRecurringNotification(recurring);
    }
  }

  /// تحديث صدقة دورية
  Future<void> updateRecurringCharity(RecurringCharity recurring) async {
    await _recurringBox.put(recurring.id, recurring);
    if (recurring.isActive) {
      await scheduleRecurringNotification(recurring);
    } else {
      await cancelRecurringNotification(recurring.id);
    }
  }

  /// حذف صدقة دورية
  Future<void> deleteRecurringCharity(String id) async {
    await _recurringBox.delete(id);
    await cancelRecurringNotification(id);
  }

  /// الحصول على جميع الصدقات الدورية
  List<RecurringCharity> getAllRecurringCharities() {
    return _recurringBox.values.toList();
  }

  /// الحصول على الصدقات المستحقة اليوم
  List<RecurringCharity> getDueRecurringCharities() {
    final now = DateTime.now();
    final today = now.day;

    return _recurringBox.values.where((r) {
      if (!r.isActive) return false;

      final isDueDay = r.dayOfMonth == today;
      final donatedThisMonth = r.lastDonatedDate != null &&
          r.lastDonatedDate!.month == now.month &&
          r.lastDonatedDate!.year == now.year;

      return isDueDay && !donatedThisMonth;
    }).toList();
  }

  /// تأكيد التبرع بصدقة دورية
  Future<void> confirmRecurringDonation(RecurringCharity recurring) async {
    final now = DateTime.now();
    final donation = CharityDonation(
      id: _uuid.v4(),
      amount: recurring.amount,
      categoryIndex: recurring.categoryIndex,
      date: now,
      notes: 'صدقة دورية: ${recurring.title}',
      currency: recurring.currency,
    );
    await addDonation(donation);
    final updatedRecurring = recurring.copyWith(lastDonatedDate: now);
    await updateRecurringCharity(updatedRecurring);
  }

  // ======== Notification Logic ========

  Future<void> scheduleRecurringNotification(RecurringCharity recurring) async {
    final notificationId = recurring.id.hashCode.abs();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'charity_reminder_channel',
        title: 'موعد الصدقة الدورية: ${recurring.title}',
        body:
            'حان موعد إخراج صدقتك الشهرية بمقدار ${recurring.amount} ${recurring.currency}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'recurring_id': recurring.id},
      ),
      schedule: NotificationCalendar(
        day: recurring.dayOfMonth,
        hour: 9,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  Future<void> cancelRecurringNotification(String id) async {
    await AwesomeNotifications().cancel(id.hashCode.abs());
  }

  // ======== Helper Methods ========

  double _sumDonations(Iterable<CharityDonation> donations) {
    return donations.fold(0, (sum, d) => sum + d.amount);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _calculateCurrentStreak(List<CharityDonation> donations) {
    if (donations.isEmpty) return 0;
    donations.sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime checkDate = DateTime.now();
    final latestDonation = donations.first;
    final daysDiff = checkDate.difference(latestDonation.date).inDays;
    if (daysDiff > 1) return 0;
    for (var donation in donations) {
      final normalizedDate =
          DateTime(donation.date.year, donation.date.month, donation.date.day);
      final normalizedCheck =
          DateTime(checkDate.year, checkDate.month, checkDate.day);
      if (_isSameDay(normalizedDate, normalizedCheck)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(normalizedCheck)) {
        if (_isSameDay(
            normalizedDate, checkDate.subtract(const Duration(days: 1)))) {
          streak++;
          checkDate = normalizedDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }
    return streak;
  }

  Future<void> _updateLongestStreak() async {
    final currentStreak = _calculateCurrentStreak(getAllDonations());
    final longestStreak = _getLongestStreak();
    if (currentStreak > longestStreak) {
      await _settingsBox.put(_longestStreakKey, currentStreak);
    }
  }

  int _getLongestStreak() {
    return _settingsBox.get(_longestStreakKey, defaultValue: 0) as int;
  }

  Map<CharityCategory, double> _getCategoryBreakdown(
      List<CharityDonation> donations) {
    final breakdown = <CharityCategory, double>{};
    for (var donation in donations) {
      breakdown[donation.category] =
          (breakdown[donation.category] ?? 0) + donation.amount;
    }
    return breakdown;
  }

  List<ChartData> _getMonthlyData(List<CharityDonation> donations) {
    final now = DateTime.now();
    final data = <ChartData>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final monthDonations = donations
          .where((d) => d.date.isAfter(month) && d.date.isBefore(nextMonth));
      final total = _sumDonations(monthDonations);
      final monthName = _getArabicMonthName(month.month);
      data.add(ChartData(label: monthName, value: total, date: month));
    }
    return data;
  }

  String _getArabicMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  // ======== Widget Update ========

  /// تحديث widget الصدقة على الشاشة الرئيسية
  Future<void> _updateCharityWidget() async {
    try {
      final stats = calculateStats();
      await HomeWidgetService.updateCharityWidget(
        monthlyTotal: stats.totalThisMonth,
        streakDays: stats.currentStreak,
        currency: ' ج.م',
        title: 'صدقاتي هذا الشهر',
      );
    } catch (e) {
      debugPrint('❌ Error updating charity widget: $e');
    }
  }

  // ======== Test Methods ========

  Future<void> testNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'charity_reminder_channel',
        title: 'تجربة إشعارات الصدقة 🔔',
        body: 'هذا إشعار تجريبي للتأكد من عمل نظام التذكير بالصدقة بنجاح ✨',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
      ),
    );
  }
}
