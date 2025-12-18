import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/charity_models.dart';

class CharityService {
  static const String _charityBoxName = 'charityBox';
  static const String _recurringBoxName = 'recurringCharityBox';
  static const String _settingsBoxName = 'charitySettingsBox';
  static const String _monthlyIncomeKey = 'monthlyIncome';
  static const String _longestStreakKey = 'longestStreak';

  late Box<CharityDonation> _charityBox;
  late Box<RecurringCharity> _recurringBox;
  late Box _settingsBox;
  final Uuid _uuid = const Uuid();

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
  }

  /// تحديث صدقة
  Future<void> updateDonation(CharityDonation donation) async {
    await _charityBox.put(donation.id, donation);
  }

  /// حذف صدقة
  Future<void> deleteDonation(String id) async {
    await _charityBox.delete(id);
    await _updateLongestStreak();
  }

  /// الحصول على جميع الصدقات
  List<CharityDonation> getAllDonations() {
    return _charityBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// الحصول على صدقات حسب الفترة
  List<CharityDonation> getDonationsByDateRange(
      DateTime start, DateTime end) {
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
    final totalToday = _sumDonations(
        allDonations.where((d) => _isSameDay(d.date, today)));
    final totalThisWeek = _sumDonations(
        allDonations.where((d) => d.date.isAfter(weekStart)));
    final totalThisMonth = _sumDonations(
        allDonations.where((d) => d.date.isAfter(monthStart)));
    final totalThisYear = _sumDonations(
        allDonations.where((d) => d.date.isAfter(yearStart)));
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

    if (monthlyIncome == null || monthlyIncome <= 0) {
      return CharitySuggestion(
        suggestedAmount: 10,
        reason: 'ابدأ بمبلغ صغير',
        motivation:
            '\"لا تحقرن من المعروف شيئاً\" - حديث شريف',
      );
    }

    // 1% من الدخل الشهري مقسوم على 30 يوم
    final dailySuggestion = (monthlyIncome * 0.01) / 30;

    final motivations = [
      '\"ما نقص مال من صدقة\" - حديث شريف',
      '\"الصدقة تطفئ الخطيئة كما يطفئ الماء النار\" - حديث شريف',
      'صدقتك اليوم قد تكون سبب رزقك غداً',
      '\"داووا مرضاكم بالصدقة\" - حديث شريف',
      'صدقة اليوم خير من صدقة الغد',
    ];

    final random = DateTime.now().millisecond % motivations.length;

    return CharitySuggestion(
      suggestedAmount: dailySuggestion,
      reason: 'حوالي 1% من دخلك الشهري',
      motivation: motivations[random],
    );
  }

  /// حفظ الدخل الشهري
  Future<void> setMonthlyIncome(double income) async {
    await _settingsBox.put(_monthlyIncomeKey, income);
  }

  /// الحصول على الدخل الشهري
  double? getMonthlyIncome() {
    return _settingsBox.get(_monthlyIncomeKey) as double?;
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
      
      // إذا كان اليوم هو يوم التذكير، ولم يتم التبرع هذا الشهر
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
    
    // 1. إنشاء صدقة عادية وسجلها في التاريخ
    final donation = CharityDonation(
      id: _uuid.v4(),
      amount: recurring.amount,
      categoryIndex: recurring.categoryIndex,
      date: now,
      notes: 'صدقة دورية: ${recurring.title}',
      currency: recurring.currency,
    );
    
    await addDonation(donation);
    
    // 2. تحديث تاريخ آخر تبرع في الصدقة الدورية
    final updatedRecurring = recurring.copyWith(
      lastDonatedDate: now,
    );
    await updateRecurringCharity(updatedRecurring);
  }

  // ======== Notification Logic ========

  /// جدولة إشعار للصدقة الدورية
  Future<void> scheduleRecurringNotification(RecurringCharity recurring) async {
    // استخدم hash للـ id لتحويله لـ int
    final notificationId = recurring.id.hashCode.abs();
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'charity_reminder_channel',
        title: 'موعد الصدقة الدورية: ${recurring.title} 🤲',
        body: 'حان موعد إخراج صدقتك الشهرية بمقدار ${recurring.amount} ${recurring.currency}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'recurring_id': recurring.id},
      ),
      schedule: NotificationCalendar(
        day: recurring.dayOfMonth,
        hour: 9, // التذكير الساعة 9 صباحاً
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  /// إلغاء إشعار
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

    // تحقق من وجود صدقة اليوم أو الأمس
    final latestDonation = donations.first;
    final daysDiff = checkDate.difference(latestDonation.date).inDays;

    if (daysDiff > 1) return 0; // انقطع الـ streak

    // ابدأ العد
    for (var donation in donations) {
      final normalizedDate =
          DateTime(donation.date.year, donation.date.month, donation.date.day);
      final normalizedCheck = DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (_isSameDay(normalizedDate, normalizedCheck)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(normalizedCheck)) {
        // تحقق من اليوم السابق
        if (_isSameDay(normalizedDate, checkDate.subtract(const Duration(days: 1)))) {
          streak++;
          checkDate = normalizedDate.subtract(const Duration(days: 1));
        } else {
          break; // انقطع الـ streak
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

    // آخر 6 شهور
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthDonations = donations.where((d) =>
          d.date.isAfter(month) && d.date.isBefore(nextMonth));

      final total = _sumDonations(monthDonations);

      final monthName = _getArabicMonthName(month.month);

      data.add(ChartData(
        label: monthName,
        value: total,
        date: month,
      ));
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
}
