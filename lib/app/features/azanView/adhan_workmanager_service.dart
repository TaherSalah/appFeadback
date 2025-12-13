import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

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
      print('🚀 بدء تهيئة خدمة الأذان...');

      // 1️⃣ إلغاء أي مهام قديمة
      await Workmanager().cancelAll();
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
      print('❌ خطأ في تهيئة AdhanWorkManager: $e');
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
        print('🏙️ تم حفظ المدينة: $cityName');
      }
      if (calculationParams != null) {
        await _saveCalculationParams(calculationParams);
        print('⚙️ تم حفظ إعدادات الحساب');
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

        for (var entry in prayerTimes.entries) {
          final scheduled = await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            cityName: cityName,
          );
          if (scheduled) scheduledCount++;
        }
      }

      print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
    } catch (e, stackTrace) {
      print('❌ خطأ في جدولة الصلوات: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  /// جدولة جميع الصلوات لليوم الحالي فقط
  Future<void> scheduleAllPrayers() async {
    try {
      print('📅 جدولة صلوات اليوم...');
      final prayerTimes = await _getPrayerTimesForDate(DateTime.now());

      int scheduledCount = 0;
      for (var entry in prayerTimes.entries) {
        final scheduled = await _schedulePrayer(
          prayerName: entry.key,
          prayerTime: entry.value,
        );
        if (scheduled) scheduledCount++;
      }

      print('✅ تم جدولة $scheduledCount صلاة لليوم');
    } catch (e) {
      print('❌ خطأ في جدولة صلوات اليوم: $e');
    }
  }

  /// جدولة أذان واحد بشكل محسّن
  Future<bool> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    int dayOffset = 0,
    String? cityName,
  }) async {
    final now = DateTime.now();
    var delay = prayerTime.difference(now);

    if (delay.isNegative) {
      if (dayOffset == 0) {
        print('⏭️ تم تخطي $prayerName - الوقت فات');
      }
      return false;
    }

    if (delay.inMinutes < 1) {
      print('⚠️ تأخير قصير جداً لـ $prayerName');
      return false;
    }

    try {
      final savedCityName = cityName ?? await _getCityName();

      // ✅ تحديد نوع الأذان
      final isFajr = prayerName == 'الفجر';

      final uniqueId =
          'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';

      await Workmanager().registerOneOffTask(
        uniqueId,
        'adhanTask',
        initialDelay: delay,
        inputData: {
          'prayerName': prayerName,
          'cityName': savedCityName,
          'prayerTime': _formatTime(prayerTime),
          'timestamp': prayerTime.millisecondsSinceEpoch,
          'dayOffset': dayOffset,
          'isFajr': isFajr, // ⭐ هام جداً!
        },
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
      );

      final delayInMinutes = delay.inMinutes;
      final adhanType = isFajr ? '🌅 (فجر)' : '🕌 (عادي)';

      print(
          '✅ جدولة $prayerName $adhanType: ${_formatTime(prayerTime)} (بعد ${delayInMinutes}د)');
      return true;
    } catch (e, stackTrace) {
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
      // استخدام الإحداثيات المُمررة أو المحفوظة
      final coords = coordinates ?? await _getSavedCoordinates();

      // استخدام parameters المُمررة أو المحفوظة
      final calculationParams = params ?? await _getSavedCalculationParams();

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        'الفجر': prayerTimes.fajr,
        'الظهر': prayerTimes.dhuhr,
        'العصر': prayerTimes.asr,
        'المغرب': prayerTimes.maghrib,
        'العشاء': prayerTimes.isha,
      };
    } catch (e) {
      print('❌ خطأ في حساب أوقات الصلاة: $e');
      // أوقات افتراضية في حالة الخطأ
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

  /// الحصول على الإحداثيات المحفوظة
  Future<Coordinates> _getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
    final longitude = prefs.getDouble('longitude') ?? 31.2357;
    return Coordinates(latitude, longitude);
  }

  /// حفظ الإحداثيات
  Future<void> saveCoordinates(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  /// الحصول على اسم المدينة المحفوظ
  Future<String> _getCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('city_name') ?? 'القاهرة';
  }

  /// حفظ اسم المدينة
  Future<void> saveCityName(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', cityName);
  }

  /// حفظ تفضيلات الأذان
  Future<void> saveAdhanPreferences({
    bool? enableFajrAdhan,
    bool? enableNormalAdhan,
    String? fajrAdhanPath,
    String? normalAdhanPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (enableFajrAdhan != null) {
      await prefs.setBool('enable_fajr_adhan', enableFajrAdhan);
    }
    if (enableNormalAdhan != null) {
      await prefs.setBool('enable_normal_adhan', enableNormalAdhan);
    }
    if (fajrAdhanPath != null) {
      await prefs.setString('fajr_adhan_path', fajrAdhanPath);
    }
    if (normalAdhanPath != null) {
      await prefs.setString('normal_adhan_path', normalAdhanPath);
    }
  }

  /// الحصول على تفضيلات الأذان
  Future<Map<String, dynamic>> getAdhanPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'enableFajrAdhan': prefs.getBool('enable_fajr_adhan') ?? true,
      'enableNormalAdhan': prefs.getBool('enable_normal_adhan') ?? true,
      'fajrAdhanPath':
          prefs.getString('fajr_adhan_path') ?? 'assets/athan/fajr.mp3',
      'normalAdhanPath':
          prefs.getString('normal_adhan_path') ?? 'assets/athan/athan.mp3',
    };
  }

  /// حفظ إعدادات الحساب
  Future<void> _saveCalculationParams(CalculationParameters params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fajr_angle', params.fajrAngle);
    await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
    await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);

    if (params.ishaInterval > 0) {
      await prefs.setInt('isha_interval', params.ishaInterval);
    }
  }

  /// الحصول على إعدادات الحساب المحفوظة
  Future<CalculationParameters> _getSavedCalculationParams() async {
    final prefs = await SharedPreferences.getInstance();

    final fajrAngle = prefs.getDouble('fajr_angle');
    final ishaAngle = prefs.getDouble('isha_angle');
    final madhabIndex = prefs.getInt('madhab') ?? 0;
    final ishaInterval = prefs.getInt('isha_interval') ?? 0;

    // إذا مفيش بيانات محفوظة، استخدم الطريقة المصرية كـ default
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

  /// إعادة جدولة الأذان (استدعيها يومياً أو عند تغيير الموقع)
  Future<void> reschedule({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    try {
      print('🔄 إعادة جدولة الأذان...');
      await Workmanager().cancelAll();
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
      await Workmanager().cancelAll();
      print('🗑️ تم إلغاء جميع مهام الأذان');
    } catch (e) {
      print('❌ خطأ في إلغاء المهام: $e');
    }
  }

  // ==========================================
  // 📊 معلومات الصلاة التالية
  // ==========================================

  /// الحصول على الصلاة التالية
  Future<Map<String, dynamic>?> getNextPrayer() async {
    try {
      final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
      final now = DateTime.now();

      // البحث عن الصلاة التالية اليوم
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

      // إذا كل الأوقات فاتت، جيب أول صلاة بكرة (الفجر)
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

  /// تنسيق الوقت بالعربي
  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  /// طباعة جميع الأوقات المجدولة (للتجربة والتطوير)
  Future<void> printScheduledPrayers({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    int days = 7,
  }) async {
    print('\n╔════════════════════════════════════╗');
    print('║   📋 أوقات الصلاة المجدولة       ║');
    print('╚════════════════════════════════════╝\n');

    for (int day = 0; day < days; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final prayerTimes = await _getPrayerTimesForDate(
        date,
        coordinates: coordinates,
        params: calculationParams,
      );

      final dayName = _getDayName(date.weekday);
      print('📅 $dayName ${date.day}/${date.month}/${date.year}:');
      print('─────────────────────────────────────');

      for (var entry in prayerTimes.entries) {
        final icon = _getPrayerIcon(entry.key);
        print('   $icon ${entry.key}: ${_formatTime(entry.value)}');
      }
      print('');
    }
    print('════════════════════════════════════════\n');
  }

  /// الحصول على اسم اليوم بالعربي
  String _getDayName(int weekday) {
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return days[weekday - 1];
  }

  /// الحصول على أيقونة الصلاة
  String _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return '🌅';
      case 'الظهر':
        return '☀️';
      case 'العصر':
        return '🌤️';
      case 'المغرب':
        return '🌆';
      case 'العشاء':
        return '🌙';
      default:
        return '🕌';
    }
  }

  /// التحقق من حالة الجدولة
  Future<Map<String, dynamic>> getSchedulingStatus() async {
    try {
      final nextPrayer = await getNextPrayer();
      final coords = await _getSavedCoordinates();
      final city = await _getCityName();

      return {
        'isScheduled': nextPrayer != null,
        'nextPrayer': nextPrayer,
        'city': city,
        'coordinates': {
          'latitude': coords.latitude,
          'longitude': coords.longitude,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isScheduled': false,
        'error': e.toString(),
      };
    }
  }
}
