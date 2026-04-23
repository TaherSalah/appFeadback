import 'package:hive/hive.dart';

part 'charity_models.g.dart';

/// طرق الدفع
enum PaymentMethod {
  cash, // نقدي
  card, // بطاقة
  eWallet, // محفظة إلكترونية
  bankTransfer, // تحويل بنكي
  check, // شيك
}

/// امتداد للحصول على اسم طريقة الدفع بالعربية
extension PaymentMethodExtension on PaymentMethod {
  String get arabicName {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.card:
        return 'بطاقة ائتمان';
      case PaymentMethod.eWallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.check:
        return 'شيك';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.eWallet:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.check:
        return '📝';
    }
  }
}

/// فئات الصدقة
enum CharityCategory {
  zakat, // زكاة المال
  sadaqah, // صدقة عامة
  orphan, // كفالة يتيم
  education, // تعليم
  health, // صحة
  water, // مشاريع المياه
  mosque, // بناء المساجد
  quran, // طباعة المصاحف
  food, // إطعام
  other, // أخرى
}

/// امتداد للحصول على اسم الفئة بالعربية
extension CharityCategoryExtension on CharityCategory {
  String get arabicName {
    switch (this) {
      case CharityCategory.zakat:
        return 'زكاة المال';
      case CharityCategory.sadaqah:
        return 'صدقة عامة';
      case CharityCategory.orphan:
        return 'كفالة يتيم';
      case CharityCategory.education:
        return 'تعليم';
      case CharityCategory.health:
        return 'صحة';
      case CharityCategory.water:
        return 'مشاريع المياه';
      case CharityCategory.mosque:
        return 'بناء المساجد';
      case CharityCategory.quran:
        return 'طباعة المصاحف';
      case CharityCategory.food:
        return 'إطعام';
      case CharityCategory.other:
        return 'أخرى';
    }
  }

  String get emoji {
    switch (this) {
      case CharityCategory.zakat:
        return '💰';
      case CharityCategory.sadaqah:
        return '🤲';
      case CharityCategory.orphan:
        return '👶';
      case CharityCategory.education:
        return '📚';
      case CharityCategory.health:
        return '🏥';
      case CharityCategory.water:
        return '💧';
      case CharityCategory.mosque:
        return '🕌';
      case CharityCategory.quran:
        return '📖';
      case CharityCategory.food:
        return '🍲';
      case CharityCategory.other:
        return '🎁';
    }
  }
}

/// نموذج الصدقة
@HiveType(typeId: 10)
class CharityDonation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int categoryIndex; // Store as int instead of enum

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String currency; // EGP, SAR, USD, etc.

  @HiveField(6)
  final int? paymentMethodIndex; // طريقة الدفع

  CharityDonation({
    required this.id,
    required this.amount,
    required this.categoryIndex,
    required this.date,
    this.notes,
    this.currency = 'EGP',
    this.paymentMethodIndex,
  });

  // Helper getter for category
  CharityCategory get category => CharityCategory.values[categoryIndex];

  // Helper getter for payment method
  PaymentMethod? get paymentMethod => paymentMethodIndex != null
      ? PaymentMethod.values[paymentMethodIndex!]
      : null;

  // Helper factory with category
  factory CharityDonation.withCategory({
    required String id,
    required double amount,
    required CharityCategory category,
    required DateTime date,
    String? notes,
    String currency = 'EGP',
    PaymentMethod? paymentMethod,
  }) {
    return CharityDonation(
      id: id,
      amount: amount,
      categoryIndex: category.index,
      date: date,
      notes: notes,
      currency: currency,
      paymentMethodIndex: paymentMethod?.index,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.index,
      'date': date.toIso8601String(),
      'notes': notes,
      'currency': currency,
      'paymentMethod': paymentMethodIndex,
    };
  }

  /// إنشاء من Map
  factory CharityDonation.fromMap(Map<String, dynamic> map) {
    return CharityDonation(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryIndex: map['category'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      currency: map['currency'] as String? ?? 'EGP',
      paymentMethodIndex: map['paymentMethod'] as int?,
    );
  }
}

/// إحصائيات الصدقة
class CharityStats {
  final double totalToday;
  final double totalThisWeek;
  final double totalThisMonth;
  final double totalThisYear;
  final double totalAllTime;
  final int donationsCount;
  final int currentStreak; // عدد الأيام المتتالية
  final int longestStreak;
  final double averagePerDonation;
  final Map<CharityCategory, double> categoryBreakdown;
  final List<ChartData> monthlyData; // للرسوم البيانية

  CharityStats({
    required this.totalToday,
    required this.totalThisWeek,
    required this.totalThisMonth,
    required this.totalThisYear,
    required this.totalAllTime,
    required this.donationsCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.averagePerDonation,
    required this.categoryBreakdown,
    required this.monthlyData,
  });

  factory CharityStats.empty() {
    return CharityStats(
      totalToday: 0,
      totalThisWeek: 0,
      totalThisMonth: 0,
      totalThisYear: 0,
      totalAllTime: 0,
      donationsCount: 0,
      currentStreak: 0,
      longestStreak: 0,
      averagePerDonation: 0,
      categoryBreakdown: {},
      monthlyData: [],
    );
  }
}

/// بيانات الرسم البياني
class ChartData {
  final String label; // اسم الشهر أو الأسبوع
  final double value; // المبلغ
  final DateTime date;

  ChartData({
    required this.label,
    required this.value,
    required this.date,
  });
}

/// اقتراح الصدقة اليومية
class CharitySuggestion {
  final double suggestedAmount;
  final String reason;
  final String motivation;

  CharitySuggestion({
    required this.suggestedAmount,
    required this.reason,
    required this.motivation,
  });
}

/// نموذج الصدقة الدورية (شهرية)
@HiveType(typeId: 21)
class RecurringCharity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int categoryIndex;

  @HiveField(4)
  final int dayOfMonth; // يوم التذكير (1-31)

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final String currency;

  @HiveField(7)
  final DateTime? lastDonatedDate;

  RecurringCharity({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryIndex,
    required this.dayOfMonth,
    this.isActive = true,
    this.currency = 'EGP',
    this.lastDonatedDate,
  });

  CharityCategory get category => CharityCategory.values[categoryIndex];

  RecurringCharity copyWith({
    String? title,
    double? amount,
    int? categoryIndex,
    int? dayOfMonth,
    bool? isActive,
    DateTime? lastDonatedDate,
  }) {
    return RecurringCharity(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      currency: currency,
      lastDonatedDate: lastDonatedDate ?? this.lastDonatedDate,
    );
  }
}

/// نموذج الهدف الشهري
@HiveType(typeId: 22)
class MonthlyGoal extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final int month;

  @HiveField(2)
  final int year;

  MonthlyGoal({
    required this.amount,
    required this.month,
    required this.year,
  });
}

/// نموذج الإنجاز
@HiveType(typeId: 23)
class CharityAchievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final DateTime unlockedDate;

  @HiveField(5)
  final double? goalValue; // القيمة المطلوبة للفتح (مثلاً 1000 جنيه)

  CharityAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedDate,
    this.goalValue,
  });
}
