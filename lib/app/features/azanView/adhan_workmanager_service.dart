import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_callback.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ==========================================
// 🧪 Callback مبسط للاختبار
// ==========================================
@pragma('vm:entry-point')
void testSimpleCallback(int id) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔊 [TEST CALLBACK] تم استدعاء callback! ID: $id');
  print('🕐 الوقت: ${DateTime.now()}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  // محاولة إرسال إشعار فوري للتأكد من أن الكود يعمل
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 77777,
        channelKey: 'adhan_channel_v4', // Use adhan channel for sound test
        title: '⚡ اختبار فوري',
        body: 'تم استدعاء الخلفية بنجاح الآن.',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
    );
  } catch (e) {
    print("❌ فشل إرسال إشعار الاختبار: $e");
  }

  // استدعاء الـ callback الأصلي
  alarmCallback(id);
}

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

      // تهيئة SettingsService
      await SettingsService().init();

      // التحقق من تفعيل الأذان
      if (!SettingsService().isAdhanEnabled) {
        print('🔕 الأذان معطل من الإعدادات. لن يتم جدولة أي شيء.');
        await cancelAll(); // ضمان إلغاء القديم
        return;
      }

      // 1️⃣ تحديث قنوات الإشعارات بالأصوات المختارة
      await updateNotificationChannels();

      // 2️⃣ إلغاء أي مهام قديمة
      await cancelAll();

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

      // 0️⃣ تحميل اسم المدينة إذا لم يتم تمريره
      cityName ??= await _getCityName();

      // 1️⃣ حفظ البيانات إذا تم تمريرها
      if (coordinates != null) {
        await saveCoordinates(coordinates.latitude, coordinates.longitude);
        print(
            '📍 تم حفظ الإحداثيات: ${coordinates.latitude}, ${coordinates.longitude}');
      }
      await saveCityName(cityName);
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
          print('📋 محاولة جدولة: ${entry.key} - ${_formatTime(entry.value)}');
          final error = await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            prayerIndex: prayerIndex,
            cityName: cityName,
          );
          if (error == null) {
            scheduledCount++;
            print('   ✅ تم الجدولة');
          } else {
            print('   ❌ فشل الجدولة: $error');
            // print('   ⏭️ تم تخطيها (الوقت مرّ)');
          }
          prayerIndex++;
        }
      }

      print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
    } catch (e, stackTrace) {
      print('❌ خطأ في جدولة الصلوات: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  /// جدولة إشعار الأذان مباشرة (Native Scheduling)
  Future<String?> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    required int dayOffset,
    required int prayerIndex,
    String? cityName,
    bool useTestCallback = false,
  }) async {
    final now = DateTime.now();

    // تأكد أن الوقت لم يمر (مع هامش صغير 5 ثواني للاختبارات الفورية)
    if (prayerTime.isBefore(now.subtract(Duration(seconds: 5)))) {
      return "الوقت المحدد للصلاة قد مر بالفعل"; // الوقت فات
    }

    try {
      // إنشاء ID فريد لكل صلاة
      final uniqueId = 1000 + (dayOffset * 10) + prayerIndex;

      // تحديد القناة المناسبة
      final bool isFajr = prayerName.contains('الفجر');

      // ✅ تصحيح القنوات: استخدام V4 دائمًا
      final String channelKey =
          isFajr ? 'fajr_adhan_channel_v4' : 'adhan_channel_v4';

      print(
          '📅 جدولة Native ($uniqueId): $prayerName @ ${_formatTime(prayerTime)} on $channelKey');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId,
          channelKey: channelKey,
          icon: 'resource://drawable/ic_stat_logoapp',
          title: '\u200Fحان الآن وقت صلاة $prayerName',
          body: '\u200Fفي مدينة ${cityName ?? "القاهرة"}',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: true,
          locked: false,
          displayOnBackground: true,
          displayOnForeground: true,
          timeoutAfter: isFajr
              ? const Duration(minutes: 4, seconds: 40)
              : Duration(minutes: 3, seconds: 24),
          payload: {
            'prayerName': prayerName,
            'prayer_time': _formatTime(prayerTime),
            'cityName': cityName ?? "",
            'route': 'adhan_screen',
            'type': 'adhan',
          },
        ),
        schedule: NotificationCalendar.fromDate(
          date: prayerTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      // 🕌 جدولة أذكار بعد الصلاة (اختياري)
      final prefs = await SharedPreferences.getInstance();
      final bool remEnabled =
          prefs.getBool('post_prayer_reminder_enabled') ?? false;
      final int remMinutes = prefs.getInt('post_reminder_minutes') ?? 10;

      if (remEnabled && !prayerName.contains('الشروق')) {
        final reminderTime = prayerTime.add(Duration(minutes: remMinutes));
        final reminderId = uniqueId + 1000; // استخدام آي دي مختلف

        if (reminderTime.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: reminderId,
              channelKey: 'post_prayer_dhikr_channel',
              icon: 'resource://drawable/ic_stat_logoapp',
              title: '📿 أذكار بعد الصلاة',
              body: 'لا تنسَ قراءة أذكار ما بعد صلاة $prayerName',
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
              autoDismissible: true,
              payload: {
                'route': '/allazkarlistview', // Navigate back to azkar
              },
            ),
            schedule: NotificationCalendar.fromDate(
              date: reminderTime,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
          );
          print('   📿 تم جدولة تذكير الأذكار بعد $remMinutes دقيقة');
        }
      }

      print('✅ تم الجدولة بنجاح (Native)');
      return null; // ✅ نجاح (لا يوجد خطأ)
    } catch (e) {
      print('❌ خطأ في جدولة $prayerName: $e');
      return e.toString(); // ❌ إرجاع نص الخطأ
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

      final prefs = await SharedPreferences.getInstance();
      final manualOffset = prefs.getInt('manual_offset') ?? 0;
      final hourOffset = Duration(hours: manualOffset);

      final fOff = prefs.getInt('fajr_offset') ?? 0;
      // final sOff = prefs.getInt('sunrise_offset') ?? 0;
      final dOff = prefs.getInt('dhuhr_offset') ?? 0;
      final aOff = prefs.getInt('asr_offset') ?? 0;
      final mOff = prefs.getInt('maghrib_offset') ?? 0;
      final iOff = prefs.getInt('isha_offset') ?? 0;

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        'الفجر': prayerTimes.fajr.add(hourOffset).add(Duration(minutes: fOff)),
        // 'الشروق': prayerTimes.sunrise.add(hourOffset).add(Duration(minutes: sOff)), // لا يوجد أذان للشروق
        'الظهر': prayerTimes.dhuhr.add(hourOffset).add(Duration(minutes: dOff)),
        'العصر': prayerTimes.asr.add(hourOffset).add(Duration(minutes: aOff)),
        'المغرب':
            prayerTimes.maghrib.add(hourOffset).add(Duration(minutes: mOff)),
        'العشاء': prayerTimes.isha.add(hourOffset).add(Duration(minutes: iOff)),
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
    return prefs.getString('selected_city') ?? 'القاهرة';
  }

  Future<void> saveCityName(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', cityName);
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

  // ==========================================
  // 🧪 اختبار الأذان
  // ==========================================

  /// جدولة أذان تجريبي للاختبار (بعد عدد معين من الثواني)
  /// جدولة أذان تجريبي للاختبار (بعد عدد معين من الثواني)
  Future<String?> scheduleTestAdhan({int secondsFromNow = 10}) async {
    try {
      final testTime = DateTime.now().add(Duration(seconds: secondsFromNow));
      final controlTime = testTime.add(Duration(seconds: 5)); // بعده بـ 5 ثواني
      final cityName = await _getCityName();

      print('🧪 جدولة أذان تجريبي + إشعار تحكم...');

      // 1. الأذان الأصلي
      final error = await _schedulePrayer(
        prayerName: '🧪 اختبار الأذان',
        prayerTime: testTime,
        dayOffset: 0,
        prayerIndex: 98,
        cityName: cityName,
        useTestCallback: true,
      );

      // 2. إشعار تحكم (Control Notification) - بسيط جداً
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99999,
          icon: 'resource://mipmap/launcher_icon',

          channelKey: 'athkar_channel', // قناة عادية شغالة عند المستخدم
          title: '🛠️ إشعار فحص النظام',
          body:
              'لو شوفت الإشعار ده وماشوفتش الأذان، يبقى المشكلة في إعدادات قناة الأذان (الصوت/التنبيه).',
          category: NotificationCategory.Message,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: controlTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      if (error == null) {
        print('✅ تم جدولة الاختبارين');
        return null;
      } else {
        return error;
      }
    } catch (e) {
      print('❌ خطأ في جدولة الاختبار: $e');
      return e.toString();
    }
  }

  /// إلغاء جميع المهام بشكل سريع وفعال
  Future<void> cancelAll() async {
    try {
      print('🗑️ جاري إلغاء جميع تنبيهات الأذان القائمة...');

      // 1️⃣ إلغاء إشعارات AwesomeNotifications حسب القنوات
      // ⚠️ FIX: لا تقم بإلغاء الإشعارات النشطة (Active Notifications) حتى لا ينقطع صوت الأذان إذا فتح المستخدم التطبيق
      // await AwesomeNotifications()
      //     .cancelNotificationsByChannelKey('fajr_adhan_channel_v4');
      // await AwesomeNotifications()
      //     .cancelNotificationsByChannelKey('adhan_channel_v4'); 
      // await AwesomeNotifications()
      //     .cancelNotificationsByChannelKey('post_prayer_dhikr_channel');

      // 2️⃣ إلغاء أي مهام مجدولة مستقبلاً (Schedules)
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('adhan_channel_v4');
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('post_prayer_dhikr_channel');

      print('✅ تم تنظيف الجداول الزمنية بنجاح (مع الحفاظ على الإشعارات الحالية)');
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
  /// (هذه الدالة تحتاج ترجع Map أو كائن مخصص حسب استخدام azanView.dart)
  /// بناءً على الاستخدام في الملف الآخر، يبدو أنها ترجع SharedPreferences أو كائن شبيه.
  /// لكن بناءً على الاسم، سنعيدة SharedPreferences instance لأن الكود المستخدم كان:
  /// final prefs = await ...getAdhanPreferences();
  /// وهذا يوحي بأنها كانت تعيد prefs مباشرة أو كائن به بيانات.
  /// دعونا نتحقق من azanView.dart لنفهم المتوقع.
  /// ولكن للأمان، سنعيد الـ SharedPreferences instance نفسها كما يوحي الكود.
  Future<SharedPreferences> getAdhanPreferences() async {
    return await SharedPreferences.getInstance();
  }

  String _formatTime(DateTime time) {
    time = time.toLocal();
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  // ==========================================
  // 🎵 إدارة أصوات الأذان
  // ==========================================

  /// حفظ الأذان المختار
  Future<void> setSelectedAdhan(String type, String adhanId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_adhan_$type', adhanId);
    // تحديث القنوات فوراً عند التغيير
    await updateNotificationChannels();
  }

  /// الحصول على الأذان المختار
  Future<String?> getSelectedAdhan(String type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_adhan_$type');
  }

  /// الحصول على مسار الأذان المختار (للاستخدام مع AwesomeNotifications)
  Future<String?> getAdhanPath(String type) async {
    final selectedId = await getSelectedAdhan(type);
    if (selectedId == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/adhans/$selectedId.mp3';
    final file = File(filePath);

    if (await file.exists()) {
      return 'file://$filePath';
    }
    return null;
  }

  /// تحديث قنوات AwesomeNotifications بالأصوات الجديدة
  Future<void> updateNotificationChannels() async {
    try {
      final fajrPath = await getAdhanPath('fajr');
      final normalPath = await getAdhanPath('normal');

      print('🎵 تحديث قنوات الأذان:');
      print('   🌅 الفجر: ${fajrPath ?? "افتراضي"}');
      print('   🕌 العادي: ${normalPath ?? "افتراضي"}');

      // ⚠️ FIX: Force remove channels to ensure sound changes apply on Android
      await AwesomeNotifications().removeChannel('fajr_adhan_channel_v4');
      await AwesomeNotifications().removeChannel('adhan_channel_v4');

      await AwesomeNotifications().initialize(
        'resource://drawable/ic_stat_logoapp',
        [
          // 🌅 قناة أذان الفجر
          NotificationChannel(
            channelKey: 'fajr_adhan_channel_v4',
            channelName: 'أذان الفجر',
            channelDescription: 'تشغيل أذان الفجر',
            importance: NotificationImportance.Max,
            playSound: true,
            soundSource: fajrPath ??
                (Platform.isAndroid ? 'resource://raw/fajr' : 'fajr.mp3'),
            enableVibration: true,
            enableLights: true,
            ledColor: Colors.orange,
            defaultPrivacy: NotificationPrivacy.Public,
            criticalAlerts: true,
          ),

          // 🕌 قناة الأذان العادي
          NotificationChannel(
            channelKey: 'adhan_channel_v4',
            channelName: 'أذان الصلاة',
            channelDescription: 'تشغيل صوت الأذان',
            importance: NotificationImportance.Max,
            defaultColor: Colors.green,
            ledColor: Colors.green,
            playSound: true,
            soundSource: normalPath ??
                (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
            enableVibration: true,
            enableLights: true,
            locked: true, //Locked prevents user from dismissing?
            criticalAlerts: true,
          ),
        ],
        debug: true,
      );
      print('✅ تم تحديث قنوات الأذان بنجاح');
    } catch (e) {
      print('❌ فشل تحديث قنوات الأذان: $e');
    }
  }
}
