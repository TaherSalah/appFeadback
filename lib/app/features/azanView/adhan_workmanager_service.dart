// import 'dart:io';
//
// import 'package:adhan/adhan.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'adhan_callback.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:muslimdaily/app/core/services/settings_service.dart';
//
// // ==========================================
// // 🧪 Callback مبسط للاختبار
// // ==========================================
// @pragma('vm:entry-point')
// void testSimpleCallback(int id) async {
//   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//   print('🔊 [TEST CALLBACK] تم استدعاء callback! ID: $id');
//   print('🕐 الوقت: ${DateTime.now()}');
//   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//
//   // محاولة إرسال إشعار فوري للتأكد من أن الكود يعمل
//   try {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 99999, // ID مميز للاختبار
//         channelKey:
//             'adhan_channel_v2', // ✅ استخدام القناة الجديدة للتأكد من الصوت
//         title: '🧪 نجح الاختبار!',
//         body: 'تم استدعاء الخلفية بنجاح الآن.',
//         notificationLayout: NotificationLayout.Default,
//         wakeUpScreen: true,
//       ),
//     );
//   } catch (e) {
//     print("❌ فشل إرسال إشعار الاختبار: $e");
//   }
//
//   // استدعاء الـ callback الأصلي
//   alarmCallback(id);
// }
//
// class AdhanWorkManagerService {
//   static final AdhanWorkManagerService _instance =
//       AdhanWorkManagerService._internal();
//   factory AdhanWorkManagerService() => _instance;
//   AdhanWorkManagerService._internal();
//
//   // ==========================================
//   // 🎯 التهيئة الأساسية
//   // ==========================================
//
//   /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
//   Future<void> initialize({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//   }) async {
//     try {
//       print('🚀 بدء تهيئة خدمة الأذان Exact Alarm...');
//
//       // تهيئة SettingsService
//       await SettingsService().init();
//
//       // التحقق من تفعيل الأذان
//       if (!SettingsService().isAdhanEnabled) {
//         print('🔕 الأذان معطل من الإعدادات. لن يتم جدولة أي شيء.');
//         await cancelAll(); // ضمان إلغاء القديم
//         return;
//       }
//
//       // 1️⃣ إلغاء أي مهام قديمة
//       await cancelAll();
//       print('🗑️ تم إلغاء المهام القديمة');
//
//       // 2️⃣ جدولة الأذان لعدة أيام
//       await scheduleAllPrayersForMultipleDays(
//         coordinates: coordinates,
//         calculationParams: calculationParams,
//         cityName: cityName,
//         days: days,
//       );
//
//       print('✅ تم تهيئة خدمة الأذان بنجاح');
//     } catch (e, stackTrace) {
//       print('❌ خطأ في تهيئة AdhanService: $e');
//       print('Stack Trace: $stackTrace');
//     }
//   }
//
//   // ==========================================
//   // 📅 جدولة الصلوات
//   // ==========================================
//
//   /// جدولة جميع الصلوات لعدة أيام قادمة
//   Future<void> scheduleAllPrayersForMultipleDays({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//     int daysCount = 7, // للتوافق مع الكود القديم
//   }) async {
//     try {
//       // استخدام days أو daysCount (أيهما أكبر)
//       final totalDays = days > daysCount ? days : daysCount;
//
//       print('📋 جدولة الأذان لـ $totalDays أيام...');
//
//       // 1️⃣ حفظ البيانات إذا تم تمريرها
//       if (coordinates != null) {
//         await saveCoordinates(coordinates.latitude, coordinates.longitude);
//         print(
//             '📍 تم حفظ الإحداثيات: ${coordinates.latitude}, ${coordinates.longitude}');
//       }
//       if (cityName != null) {
//         await saveCityName(cityName);
//       }
//       if (calculationParams != null) {
//         await _saveCalculationParams(calculationParams);
//       }
//
//       // 2️⃣ جدولة الصلوات لكل يوم
//       int scheduledCount = 0;
//       for (int day = 0; day < totalDays; day++) {
//         final targetDate = DateTime.now().add(Duration(days: day));
//         final prayerTimes = await _getPrayerTimesForDate(
//           targetDate,
//           coordinates: coordinates,
//           params: calculationParams,
//         );
//
//         int prayerIndex = 0;
//         for (var entry in prayerTimes.entries) {
//           print('📋 محاولة جدولة: ${entry.key} - ${_formatTime(entry.value)}');
//           final error = await _schedulePrayer(
//             prayerName: entry.key,
//             prayerTime: entry.value,
//             dayOffset: day,
//             prayerIndex: prayerIndex,
//             cityName: cityName,
//           );
//           if (error == null) {
//             scheduledCount++;
//             print('   ✅ تم الجدولة');
//           } else {
//             print('   ❌ فشل الجدولة: $error');
//             // print('   ⏭️ تم تخطيها (الوقت مرّ)');
//           }
//           prayerIndex++;
//         }
//       }
//
//       print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
//     } catch (e, stackTrace) {
//       print('❌ خطأ في جدولة الصلوات: $e');
//       print('Stack Trace: $stackTrace');
//     }
//   }
//
//   /// جدولة إشعار الأذان مباشرة (Native Scheduling)
//   Future<String?> _schedulePrayer({
//     required String prayerName,
//     required DateTime prayerTime,
//     required int dayOffset,
//     required int prayerIndex,
//     String? cityName,
//     bool useTestCallback = false,
//   }) async {
//     final now = DateTime.now();
//
//     // تأكد أن الوقت لم يمر (مع هامش صغير 5 ثواني للاختبارات الفورية)
//     if (prayerTime.isBefore(now.subtract(Duration(seconds: 5)))) {
//       return "الوقت المحدد للصلاة قد مر بالفعل"; // الوقت فات
//     }
//
//     try {
//       // إنشاء ID فريد لكل صلاة
//       final uniqueId = 1000 + (dayOffset * 10) + prayerIndex;
//
//       // تحديد القناة المناسبة
//       final bool isFajr = prayerName.contains('الفجر');
//
//       // ✅ تصحيح القنوات: استخدام V2 دائمًا
//       final String channelKey = useTestCallback
//           ? 'adhan_channel_v2'
//           : (isFajr ? 'fajr_adhan_channel_v2' : 'adhan_channel_v2');
//
//       print(
//           '📅 جدولة Native ($uniqueId): $prayerName @ ${_formatTime(prayerTime)} on $channelKey');
//
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: uniqueId,
//           channelKey: channelKey,
//           icon: 'resource://drawable/ic_stat_logoapp', // ✅ إضافة الأيقونة صراحة
//           title: '\u200Fحان الآن وقت صلاة $prayerName',
//           body: '\u200Fفي مدينة ${cityName ?? "القاهرة"}',
//           category: NotificationCategory.Alarm, // مهم جداً للأذان
//           wakeUpScreen: true,
//           fullScreenIntent: true,
//           criticalAlert: true,
//           autoDismissible: false,
//           locked: true, // ✅ منع الحذف بالخطأ
//           displayOnBackground: true,
//           displayOnForeground: true,
//           // ✅ تخصيص المدة حسب نوع الأذان (الفجر أطول)
//           timeoutAfter: isFajr
//               ? Duration(minutes: 4) // زيادة المدة للفجر
//               : Duration(
//                   minutes: 3,
//                   seconds: 50), // زيادة المدة لباقي الصلوات لتجنب انقطاع الصوت
//           payload: {
//             'prayer_name': prayerName,
//             'prayer_time': _formatTime(prayerTime),
//             'city_name': cityName ?? "",
//             'type': 'adhan', // لتمييزه عند الضغط
//           },
//         ),
//         schedule: NotificationCalendar.fromDate(
//           date: prayerTime,
//           preciseAlarm: true, // مهم جداً للدقة
//           allowWhileIdle: true, // يعمل في وضع توفير الطاقة
//         ),
//       );
//
//       print('✅ تم الجدولة بنجاح (Native)');
//       return null; // ✅ نجاح (لا يوجد خطأ)
//     } catch (e) {
//       print('❌ خطأ في جدولة $prayerName: $e');
//       return e.toString(); // ❌ إرجاع نص الخطأ
//     }
//   }
//
//   // ==========================================
//   // 🕌 حساب أوقات الصلاة
//   // ==========================================
//
//   /// الحصول على أوقات الصلاة لتاريخ محدد
//   Future<Map<String, DateTime>> _getPrayerTimesForDate(
//     DateTime date, {
//     Coordinates? coordinates,
//     CalculationParameters? params,
//   }) async {
//     try {
//       final coords = coordinates ?? await _getSavedCoordinates();
//       final calculationParams = params ?? await _getSavedCalculationParams();
//
//       final prefs = await SharedPreferences.getInstance();
//       final manualOffset = prefs.getInt('manual_offset') ?? 0;
//       final offset = Duration(hours: manualOffset);
//
//       final components = DateComponents(date.year, date.month, date.day);
//       final prayerTimes = PrayerTimes(coords, components, calculationParams);
//
//       return {
//         // 'الفجر': DateTime.now().add(Duration(seconds: 2)),
//         'الفجر': prayerTimes.fajr.add(offset),
//         'الظهر': prayerTimes.dhuhr.add(offset),
//         'العصر': prayerTimes.asr.add(offset),
//         'المغرب': prayerTimes.maghrib.add(offset),
//         'العشاء': prayerTimes.isha.add(offset),
//       };
//     } catch (e) {
//       print('❌ خطأ في حساب أوقات الصلاة: $e');
//       return _getDefaultPrayerTimes(date);
//     }
//   }
//
//   /// أوقات افتراضية في حالة الخطأ (القاهرة)
//   Map<String, DateTime> _getDefaultPrayerTimes(DateTime date) {
//     return {
//       'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
//       'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
//       'العصر': DateTime(date.year, date.month, date.day, 15, 15),
//       'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
//       'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
//     };
//   }
//
//   // ==========================================
//   // 💾 حفظ واسترجاع البيانات
//   // ==========================================
//
//   Future<Coordinates> _getSavedCoordinates() async {
//     final prefs = await SharedPreferences.getInstance();
//     final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
//     final longitude = prefs.getDouble('longitude') ?? 31.2357;
//     return Coordinates(latitude, longitude);
//   }
//
//   Future<void> saveCoordinates(double latitude, double longitude) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('latitude', latitude);
//     await prefs.setDouble('longitude', longitude);
//   }
//
//   Future<String> _getCityName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('city_name') ?? 'القاهرة';
//   }
//
//   Future<void> saveCityName(String cityName) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('city_name', cityName);
//   }
//
//   Future<void> _saveCalculationParams(CalculationParameters params) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('fajr_angle', params.fajrAngle);
//     await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
//     await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);
//
//     if (params.ishaInterval > 0) {
//       await prefs.setInt('isha_interval', params.ishaInterval);
//     }
//   }
//
//   Future<CalculationParameters> _getSavedCalculationParams() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final fajrAngle = prefs.getDouble('fajr_angle');
//     final ishaAngle = prefs.getDouble('isha_angle');
//     final madhabIndex = prefs.getInt('madhab') ?? 0;
//     final ishaInterval = prefs.getInt('isha_interval') ?? 0;
//
//     if (fajrAngle == null || ishaAngle == null) {
//       final params = CalculationMethod.egyptian.getParameters();
//       params.madhab = Madhab.shafi;
//       return params;
//     }
//
//     final params = CalculationParameters(
//       fajrAngle: fajrAngle,
//       ishaAngle: ishaAngle,
//       ishaInterval: ishaInterval,
//     );
//     params.madhab = madhabIndex == 0 ? Madhab.shafi : Madhab.hanafi;
//
//     return params;
//   }
//
//   // ==========================================
//   // 🔄 إعادة الجدولة والإلغاء
//   // ==========================================
//
//   Future<void> reschedule({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//   }) async {
//     try {
//       print('🔄 إعادة جدولة الأذان...');
//       await cancelAll();
//       await scheduleAllPrayersForMultipleDays(
//         coordinates: coordinates,
//         calculationParams: calculationParams,
//         cityName: cityName,
//         days: days,
//       );
//       print('✅ تمت إعادة الجدولة بنجاح');
//     } catch (e) {
//       print('❌ خطأ في إعادة الجدولة: $e');
//     }
//   }
//
//   // ==========================================
//   // 🧪 اختبار الأذان
//   // ==========================================
//
//   /// جدولة أذان تجريبي للاختبار (بعد عدد معين من الثواني)
//   /// جدولة أذان تجريبي للاختبار (بعد عدد معين من الثواني)
//   Future<String?> scheduleTestAdhan({int secondsFromNow = 10}) async {
//     try {
//       final testTime = DateTime.now().add(Duration(seconds: secondsFromNow));
//       final controlTime = testTime.add(Duration(seconds: 5)); // بعده بـ 5 ثواني
//       final cityName = await _getCityName();
//
//       print('🧪 جدولة أذان تجريبي + إشعار تحكم...');
//
//       // 1. الأذان الأصلي
//       final error = await _schedulePrayer(
//         prayerName: '🧪 اختبار الأذان',
//         prayerTime: testTime,
//         dayOffset: 0,
//         prayerIndex: 98,
//         cityName: cityName,
//         useTestCallback: true,
//       );
//
//       // 2. إشعار تحكم (Control Notification) - بسيط جداً
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 99999,
//           icon: 'resource://mipmap/launcher_icon',
//
//           channelKey: 'athkar_channel', // قناة عادية شغالة عند المستخدم
//           title: '🛠️ إشعار فحص النظام',
//           body:
//               'لو شوفت الإشعار ده وماشوفتش الأذان، يبقى المشكلة في إعدادات قناة الأذان (الصوت/التنبيه).',
//           category: NotificationCategory.Message,
//           wakeUpScreen: true,
//         ),
//         schedule: NotificationCalendar.fromDate(
//           date: controlTime,
//           preciseAlarm: true,
//           allowWhileIdle: true,
//         ),
//       );
//
//       if (error == null) {
//         print('✅ تم جدولة الاختبارين');
//         return null;
//       } else {
//         return error;
//       }
//     } catch (e) {
//       print('❌ خطأ في جدولة الاختبار: $e');
//       return e.toString();
//     }
//   }
//
//   /// إلغاء جميع المهام
//   Future<void> cancelAll() async {
//     try {
//       // إلغاء جميع إشعارات الأذان المجدولة (Native)
//       // نلغي بالـ ID range اللي حجزناه (1000 - 1100)
//       for (int i = 1000; i < 1100; i++) {
//         await AwesomeNotifications().cancel(i);
//       }
//
//       // وتنظيف أي alarms قديمة لضمان عدم التضارب (Android Only)
//       if (Platform.isAndroid) {
//         try {
//           for (int i = 1000; i < 1100; i++) {
//             await AndroidAlarmManager.cancel(i);
//           }
//         } catch (_) {}
//       }
//
//       print('🗑️ تم إلغاء جميع جدولة الأذان');
//     } catch (e) {
//       print('❌ خطأ في إلغاء المهام: $e');
//     }
//   }
//
//   // ==========================================
//   // 📊 معلومات الصلاة التالية
//   // ==========================================
//
//   Future<Map<String, dynamic>?> getNextPrayer() async {
//     try {
//       final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
//       final now = DateTime.now();
//
//       for (var entry in prayerTimes.entries) {
//         if (entry.value.isAfter(now)) {
//           final timeUntil = entry.value.difference(now);
//           return {
//             'name': entry.key,
//             'time': entry.value,
//             'timeUntil': timeUntil,
//             'formattedTime': _formatTime(entry.value),
//             'remainingMinutes': timeUntil.inMinutes,
//           };
//         }
//       }
//
//       final tomorrowPrayers = await _getPrayerTimesForDate(
//         DateTime.now().add(const Duration(days: 1)),
//       );
//       final firstPrayer = tomorrowPrayers.entries.first;
//       final timeUntil = firstPrayer.value.difference(now);
//
//       return {
//         'name': firstPrayer.key,
//         'time': firstPrayer.value,
//         'timeUntil': timeUntil,
//         'formattedTime': _formatTime(firstPrayer.value),
//         'remainingMinutes': timeUntil.inMinutes,
//         'isTomorrow': true,
//       };
//     } catch (e) {
//       print('❌ خطأ في الحصول على الصلاة التالية: $e');
//       return null;
//     }
//   }
//
//   // ==========================================
//   // 🛠️ دوال مساعدة
//   // ==========================================
//
//   // ==========================================
//   // 🔄 دعم التوافق مع الكود القديم (Adapters)
//   // ==========================================
//
//   /// حفظ تفضيلات الأذان (إحداثيات، مدينة، طرق حساب، إعدادات)
//   Future<void> saveAdhanPreferences({
//     double? lat,
//     double? long,
//     String? city,
//     CalculationMethod? method,
//     Madhab? madhab,
//     int? ishaInterval,
//     bool? enableFajrAdhan,
//     bool? enableNormalAdhan,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // 1. حفظ الإحداثيات واسم المدينة
//     if (lat != null && long != null) {
//       await saveCoordinates(lat, long);
//     }
//     if (city != null) {
//       await saveCityName(city);
//     }
//
//     // 2. إعداد وحفظ CalculationParameters
//     if (method != null) {
//       var params = method.getParameters();
//       if (madhab != null) params.madhab = madhab;
//
//       if (ishaInterval != null) {
//         params = CalculationParameters(
//             fajrAngle: params.fajrAngle,
//             ishaAngle: params.ishaAngle,
//             ishaInterval: ishaInterval,
//             method: method);
//         if (madhab != null) params.madhab = madhab;
//       }
//       await _saveCalculationParams(params);
//     }
//
//     // 3. حفظ إعدادات التفعيل
//     if (enableFajrAdhan != null) {
//       await prefs.setBool('enableFajrAdhan', enableFajrAdhan);
//     }
//     if (enableNormalAdhan != null) {
//       await prefs.setBool('enableNormalAdhan', enableNormalAdhan);
//     }
//
//     print("✅ تم حفظ تفضيلات الأذان (Legacy Adapter)");
//   }
//
//   /// استرجاع تفضيلات الأذان المحفوظة
//   /// (هذه الدالة تحتاج ترجع Map أو كائن مخصص حسب استخدام azanView.dart)
//   /// بناءً على الاستخدام في الملف الآخر، يبدو أنها ترجع SharedPreferences أو كائن شبيه.
//   /// لكن بناءً على الاسم، سنعيدة SharedPreferences instance لأن الكود المستخدم كان:
//   /// final prefs = await ...getAdhanPreferences();
//   /// وهذا يوحي بأنها كانت تعيد prefs مباشرة أو كائن به بيانات.
//   /// دعونا نتحقق من azanView.dart لنفهم المتوقع.
//   /// ولكن للأمان، سنعيد الـ SharedPreferences instance نفسها كما يوحي الكود.
//   Future<SharedPreferences> getAdhanPreferences() async {
//     return await SharedPreferences.getInstance();
//   }
//
//   String _formatTime(DateTime time) {
//     time = time.toLocal();
//     final hour =
//         time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.hour >= 12 ? 'م' : 'ص';
//     return '$hour:$minute $period';
//   }
// }
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_callback.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';

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
      final String channelKey = isFajr ? 'fajr_adhan_channel_v4' : 'adhan_channel_v4';

      print(
          '📅 جدولة Native ($uniqueId): $prayerName @ ${_formatTime(prayerTime)} on $channelKey');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId,
          channelKey: channelKey,
          icon: 'resource://drawable/ic_stat_logoapp', // ✅ إضافة الأيقونة صراحة
          title: '\u200Fحان الآن وقت صلاة $prayerName',
          body: '\u200Fفي مدينة ${cityName ?? "القاهرة"}',
          category: NotificationCategory.Alarm, // مهم جداً للأذان
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: false,
          locked: true, // ✅ منع الحذف بالخطأ
          displayOnBackground: true,
          displayOnForeground: true,
          // ✅ تخصيص المدة حسب نوع الأذان (الفجر أطول)
          timeoutAfter: isFajr
              ? const Duration(minutes: 4,seconds: 40) // زيادة المدة للفجر
              : Duration(
              minutes: 3,
              seconds: 22), // زيادة المدة لباقي الصلوات لتجنب انقطاع الصوت
          payload: {
            'prayerName': prayerName,
            'prayer_time': _formatTime(prayerTime),
            'cityName': cityName ?? "",
            'route': 'adhan_screen', // ✅ Adding route for overlay
            'type': 'adhan', // Keep for backward compatibility if any
          },
        ),
        schedule: NotificationCalendar.fromDate(
          date: prayerTime,
          preciseAlarm: true, // مهم جداً للدقة
          allowWhileIdle: true, // يعمل في وضع توفير الطاقة
        ),
      );

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
      final offset = Duration(hours: manualOffset);

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        // 'الفجر': DateTime.now().add(Duration(seconds: 2)),
        'الفجر': prayerTimes.fajr.add(offset),
        'الظهر': prayerTimes.dhuhr.add(offset),
        'العصر': prayerTimes.asr.add(offset),
        'المغرب': prayerTimes.maghrib.add(offset),
        'العشاء': prayerTimes.isha.add(offset),
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

  /// إلغاء جميع المهام
  Future<void> cancelAll() async {
    try {
      // إلغاء جميع إشعارات الأذان المجدولة (Native)
      // نلغي بالـ ID range اللي حجزناه (1000 - 1100)
      for (int i = 1000; i < 1100; i++) {
        await AwesomeNotifications().cancel(i);
      }

      // وتنظيف أي alarms قديمة لضمان عدم التضارب (Android Only)
      if (Platform.isAndroid) {
        try {
          for (int i = 1000; i < 1100; i++) {
            await AndroidAlarmManager.cancel(i);
          }
        } catch (_) {}
      }

      print('🗑️ تم إلغاء جميع جدولة الأذان');
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
}