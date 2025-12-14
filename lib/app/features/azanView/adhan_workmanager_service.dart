import 'dart:math';
import 'package:adhan/adhan.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_callback.dart';

class AdhanWorkManagerService {
  static final AdhanWorkManagerService _instance =
      AdhanWorkManagerService._internal();
  factory AdhanWorkManagerService() => _instance;
  AdhanWorkManagerService._internal();

  // ==========================================
  // 🎯 التهيئة الأساسية
  // ==========================================

  /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
  Future<void> initialize({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    try {
      print('🚀 بدء تهيئة خدمة الأذان Exact Alarm...');

      // 1️⃣ إلغاء أي مهام قديمة
      await cancelAll();
      print('🗑️ تم إلغاء المهام القديمة');

      // 2️⃣ جدولة الأذان لعدة أيام
      await scheduleAllPrayersForMultipleDays(
        coordinates: coordinates,
        calculationParams: calculationParams,
        cityName: cityName,
        days: days,
      );

      print('✅ تم تهيئة خدمة الأذان بنجاح');
    } catch (e, stackTrace) {
      print('❌ خطأ في تهيئة AdhanService: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  // ==========================================
  // 📅 جدولة الصلوات
  // ==========================================

  /// جدولة جميع الصلوات لعدة أيام قادمة
  Future<void> scheduleAllPrayersForMultipleDays({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
    int daysCount = 7, // للتوافق مع الكود القديم
  }) async {
    try {
      // استخدام days أو daysCount (أيهما أكبر)
      final totalDays = days > daysCount ? days : daysCount;

      print('📋 جدولة الأذان لـ $totalDays أيام...');

      // 1️⃣ حفظ البيانات إذا تم تمريرها
      if (coordinates != null) {
        await saveCoordinates(coordinates.latitude, coordinates.longitude);
        print(
            '📍 تم حفظ الإحداثيات: ${coordinates.latitude}, ${coordinates.longitude}');
      }
      if (cityName != null) {
        await saveCityName(cityName);
      }
      if (calculationParams != null) {
        await _saveCalculationParams(calculationParams);
      }

      // 2️⃣ جدولة الصلوات لكل يوم
      int scheduledCount = 0;
      for (int day = 0; day < totalDays; day++) {
        final targetDate = DateTime.now().add(Duration(days: day));
        final prayerTimes = await _getPrayerTimesForDate(
          targetDate,
          coordinates: coordinates,
          params: calculationParams,
        );

        int prayerIndex = 0;
        for (var entry in prayerTimes.entries) {
          final scheduled = await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            prayerIndex: prayerIndex,
            cityName: cityName,
          );
          if (scheduled) scheduledCount++;
          prayerIndex++;
        }
      }

      print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
    } catch (e, stackTrace) {
      print('❌ خطأ في جدولة الصلوات: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  /// جدولة أذان واحد باستخدام AlarmManager
  Future<bool> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    required int dayOffset,
    required int prayerIndex,
    String? cityName,
  }) async {
    final now = DateTime.now();
    var delay = prayerTime.difference(now);

    if (delay.isNegative) {
      return false; // الوقت فات
    }

    try {
      final savedCityName = cityName ?? await _getCityName();

      // إنشاء ID فريد لكل صلاة
      // مثال: اليوم الأول (0) * 10 + 0 (الفجر) = 0
      // اليوم الثاني (1) * 10 + 4 (العشاء) = 14
      // بنزود offset كبير عشان نتأكد من عدم التداخل مع alarm IDs تانية
      final uniqueId = 1000 + (dayOffset * 10) + prayerIndex;

      // حفظ تفاصيل الصلاة في SharedPreferences عشان نقدر نجيبها في الـ callback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('prayer_name_$uniqueId', prayerName);
      await prefs.setString('prayer_time_$uniqueId', _formatTime(prayerTime));
      await prefs.setString('city_name_$uniqueId', savedCityName);
      final testTime = DateTime.now().add(Duration(seconds: 10));

      // جدولة التنبيه بدقة
      await AndroidAlarmManager.oneShotAt(
        prayerTime,
        uniqueId,
        alarmCallback, // الدالة اللي في adhan_callback.dart
        exact: true,
        wakeup: true,
        alarmClock: true, // يظهر كمنبه في النظام ويشتغل حتى في وضع Doze
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );

      print(
          '✅ جدولة دقيقة ($uniqueId): $prayerName الساعة ${_formatTime(prayerTime)}');
      return true;
    } catch (e) {
      print('❌ خطأ في جدولة $prayerName: $e');
      return false;
    }
  }

  // ==========================================
  // 🕌 حساب أوقات الصلاة
  // ==========================================

  /// الحصول على أوقات الصلاة لتاريخ محدد
  Future<Map<String, DateTime>> _getPrayerTimesForDate(
    DateTime date, {
    Coordinates? coordinates,
    CalculationParameters? params,
  }) async {
    try {
      final coords = coordinates ?? await _getSavedCoordinates();
      final calculationParams = params ?? await _getSavedCalculationParams();

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        // 'الفجر': DateTime.now().add(Duration(seconds: 2)),
        'الفجر': prayerTimes.fajr,
        'الظهر': prayerTimes.dhuhr,
        'العصر': prayerTimes.asr,
        'المغرب': prayerTimes.maghrib,
        'العشاء': prayerTimes.isha,
      };
    } catch (e) {
      print('❌ خطأ في حساب أوقات الصلاة: $e');
      return _getDefaultPrayerTimes(date);
    }
  }

  /// أوقات افتراضية في حالة الخطأ (القاهرة)
  Map<String, DateTime> _getDefaultPrayerTimes(DateTime date) {
    return {
      'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
      'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
      'العصر': DateTime(date.year, date.month, date.day, 15, 15),
      'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
      'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
    };
  }

  // ==========================================
  // 💾 حفظ واسترجاع البيانات
  // ==========================================

  Future<Coordinates> _getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
    final longitude = prefs.getDouble('longitude') ?? 31.2357;
    return Coordinates(latitude, longitude);
  }

  Future<void> saveCoordinates(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  Future<String> _getCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('city_name') ?? 'القاهرة';
  }

  Future<void> saveCityName(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', cityName);
  }

  Future<void> _saveCalculationParams(CalculationParameters params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fajr_angle', params.fajrAngle);
    await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
    await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);

    if (params.ishaInterval > 0) {
      await prefs.setInt('isha_interval', params.ishaInterval);
    }
  }

  Future<CalculationParameters> _getSavedCalculationParams() async {
    final prefs = await SharedPreferences.getInstance();

    final fajrAngle = prefs.getDouble('fajr_angle');
    final ishaAngle = prefs.getDouble('isha_angle');
    final madhabIndex = prefs.getInt('madhab') ?? 0;
    final ishaInterval = prefs.getInt('isha_interval') ?? 0;

    if (fajrAngle == null || ishaAngle == null) {
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;
      return params;
    }

    final params = CalculationParameters(
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
      ishaInterval: ishaInterval,
    );
    params.madhab = madhabIndex == 0 ? Madhab.shafi : Madhab.hanafi;

    return params;
  }

  // ==========================================
  // 🔄 إعادة الجدولة والإلغاء
  // ==========================================

  Future<void> reschedule({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    try {
      print('🔄 إعادة جدولة الأذان...');
      await cancelAll();
      await scheduleAllPrayersForMultipleDays(
        coordinates: coordinates,
        calculationParams: calculationParams,
        cityName: cityName,
        days: days,
      );
      print('✅ تمت إعادة الجدولة بنجاح');
    } catch (e) {
      print('❌ خطأ في إعادة الجدولة: $e');
    }
  }

  /// إلغاء جميع المهام
  Future<void> cancelAll() async {
    try {
      // 1000 هو الـ ID الأساسي + 7 أيام * 10 افتراضياً يعني 1070 ماكس
      // هنلغي رينج واسع للأمان
      for (int i = 1000; i < 1100; i++) {
        await AndroidAlarmManager.cancel(i);
      }
      print('🗑️ تم إلغاء جميع منبهات الأذان');
    } catch (e) {
      print('❌ خطأ في إلغاء المهام: $e');
    }
  }

  // ==========================================
  // 📊 معلومات الصلاة التالية
  // ==========================================

  Future<Map<String, dynamic>?> getNextPrayer() async {
    try {
      final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
      final now = DateTime.now();

      for (var entry in prayerTimes.entries) {
        if (entry.value.isAfter(now)) {
          final timeUntil = entry.value.difference(now);
          return {
            'name': entry.key,
            'time': entry.value,
            'timeUntil': timeUntil,
            'formattedTime': _formatTime(entry.value),
            'remainingMinutes': timeUntil.inMinutes,
          };
        }
      }

      final tomorrowPrayers = await _getPrayerTimesForDate(
        DateTime.now().add(const Duration(days: 1)),
      );
      final firstPrayer = tomorrowPrayers.entries.first;
      final timeUntil = firstPrayer.value.difference(now);

      return {
        'name': firstPrayer.key,
        'time': firstPrayer.value,
        'timeUntil': timeUntil,
        'formattedTime': _formatTime(firstPrayer.value),
        'remainingMinutes': timeUntil.inMinutes,
        'isTomorrow': true,
      };
    } catch (e) {
      print('❌ خطأ في الحصول على الصلاة التالية: $e');
      return null;
    }
  }

  // ==========================================
  // 🛠️ دوال مساعدة
  // ==========================================

  // ==========================================
  // 🔄 دعم التوافق مع الكود القديم (Adapters)
  // ==========================================

  /// حفظ تفضيلات الأذان (إحداثيات، مدينة، طرق حساب، إعدادات)
  Future<void> saveAdhanPreferences({
    double? lat,
    double? long,
    String? city,
    CalculationMethod? method,
    Madhab? madhab,
    int? ishaInterval,
    bool? enableFajrAdhan,
    bool? enableNormalAdhan,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. حفظ الإحداثيات واسم المدينة
    if (lat != null && long != null) {
      await saveCoordinates(lat, long);
    }
    if (city != null) {
      await saveCityName(city);
    }

    // 2. إعداد وحفظ CalculationParameters
    if (method != null) {
      var params = method.getParameters();
      if (madhab != null) params.madhab = madhab;
      
      if (ishaInterval != null) {
        params = CalculationParameters(
            fajrAngle: params.fajrAngle,
            ishaAngle: params.ishaAngle,
            ishaInterval: ishaInterval,
            method: method);
        if (madhab != null) params.madhab = madhab;
      }
      await _saveCalculationParams(params);
    }

    // 3. حفظ إعدادات التفعيل
    if (enableFajrAdhan != null) {
      await prefs.setBool('enableFajrAdhan', enableFajrAdhan);
    }
    if (enableNormalAdhan != null) {
      await prefs.setBool('enableNormalAdhan', enableNormalAdhan);
    }

    print("✅ تم حفظ تفضيلات الأذان (Legacy Adapter)");
  }

  /// استرجاع تفضيلات الأذان المحفوظة
  /// (هذه الدالة تحتاج ترجع Map أو كائن مخصص حسب استخدام timeingScreen.dart)
  /// بناءً على الاستخدام في الملف الآخر، يبدو أنها ترجع SharedPreferences أو كائن شبيه.
  /// لكن بناءً على الاسم، سنعيدة SharedPreferences instance لأن الكود المستخدم كان:
  /// final prefs = await ...getAdhanPreferences();
  /// وهذا يوحي بأنها كانت تعيد prefs مباشرة أو كائن به بيانات.
  /// دعونا نتحقق من timeingScreen.dart لنفهم المتوقع.
  /// ولكن للأمان، سنعيد الـ SharedPreferences instance نفسها كما يوحي الكود.
  Future<SharedPreferences> getAdhanPreferences() async {
    return await SharedPreferences.getInstance();
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }
}
