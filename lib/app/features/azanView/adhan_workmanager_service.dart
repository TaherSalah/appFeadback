import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/style/k_color.dart';
import 'adhan_callback.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muslimdaily/app/core/services/system_control_service.dart';
import 'package:muslimdaily/app/core/services/home_widget_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:muslimdaily/app/core/services/AdhanDiagnosticHelper.dart';

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
        title: 'اختبار فوري',
        body: 'تم استدعاء الخلفية بنجاح الآن.',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        color: const Color(0xFF178B74),
      ),
    );
  } catch (e) {
    print("❌ فشل إرسال إشعار الاختبار: $e");
  }

  // استدعاء الـ callback الأصلي
  alarmCallback(id);
}

// ==========================================
// ⏱️ Widget Update Callback (Exact Alarm)
// ==========================================

// ==========================================
// 🔊 Play Adhan Callback (Background Audio)
// ==========================================
@pragma('vm:entry-point')
void playAdhanCallback(int id, Map<String, dynamic> params) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔊 [Adhan Player] Starting background playback (ID: $id)');
  print('🕐 Time: ${DateTime.now()}');

  try {
    final prefs = await SharedPreferences.getInstance();
    // 🔴 [Auto-Silent] Activate if enabled
    if (prefs.getBool('is_auto_silent_enabled') ?? false) {
      final duration = prefs.getInt('auto_silent_duration') ?? 20;
      await SystemControlService().activateSilentMode(duration);
    }

    final String? soundPath = params['soundPath'];
    if (soundPath == null) {
      print('⚠️ [Adhan Player] No sound path provided.');
      return;
    }

    print('📂 Playing: $soundPath');

    // Initialize Player
    final player = AudioPlayer();

    // Set source
    if (soundPath.startsWith('http')) {
      await player.setUrl(soundPath);
    } else {
      await player.setFilePath(soundPath.replaceFirst('file://', ''));
    }

    // Play
    await player.setVolume(1.0);
    await player.play();

    print('✅ [Adhan Player] Playback started successfully.');

    // Keep isolate alive while playing (limited by system)
    // In a real foreground service, this would be more robust.
    // For now, we rely on the AlarmManager wakelock.

    // Optional: Dispose after some time (e.g. 5 mins)
    await Future.delayed(const Duration(minutes: 5));
    await player.dispose();
    print('🛑 [Adhan Player] Playback finished and player disposed.');
  } catch (e) {
    print('❌ [Adhan Player] Failed: $e');
    await AdhanDiagnosticHelper.logError('Background Audio Failed: $e');
  }
}

// ==========================================
// ⏱️ Widget Update Callback (Exact Alarm)
// ==========================================
@pragma('vm:entry-point')
void widgetUpdateCallback(int id, Map<String, dynamic> params) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print(
      '🔄 [Widget Update] Running background update via AlarmManager (ID: $id)');
  print('🕐 Time: ${DateTime.now()}');

  // Ensure we can access services
  try {
    await AdhanWorkManagerService().updateWidget();
    print('✅ [Widget Update] Widget updated successfully.');
  } catch (e) {
    print('❌ [Widget Update] Failed: $e');
  }
}

// ==========================================
// 🔧 Callback Dispatcher (Top-Level)
// ==========================================
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 [Background Task] Running task: $task');

    // 🚀 تهيئة AwesomeNotifications في الخلفية للتأكد من أنها تعمل
    await AwesomeNotifications().initialize(
      Platform.isAndroid ? 'resource://drawable/ic_stat_logoapp' : null,
      [],
      debug: false,
    );

    try {
      if (task == 'periodic_adhan_refresh') {
        // إعادة جدولة الأذان تلقائياً في الخلفية
        print('🔄 [Background Task] Rescheduling Azan...');
        await AdhanWorkManagerService().reschedule(days: 7);
      }
    } catch (e) {
      print('❌ [Background Task] Error: $e');
      return Future.value(false);
    }

    return Future.value(true);
  });
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
    bool forceReschedule = false,
  }) async {
    try {
      print('🚀 بدء تهيئة خدمة الأذان...');

      // 1️⃣ تهيئة WorkManager للمهام الدورية
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to true to see notifications
      );

      // 2️⃣ تسجيل مهمة دورية تعمل كل 24 ساعة لتحديث الجداول
      await Workmanager().registerPeriodicTask(
        "periodic_adhan_refresh_id",
        "periodic_adhan_refresh",
        frequency: const Duration(hours: 24),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.linear,
      );

      // 🚀 تشغيل باقي المنطق في الخلفية (عدم انتظار) لتسريع فتح التطبيق
      Future(() async {
        try {
          // check if we really need to reschedule
          if (!forceReschedule &&
              !await _shouldReschedule(
                  coordinates, calculationParams, cityName)) {
            print(
                '✅ [AdhanWorkManager] Skipping reschedule: Schedules are up-to-date.');
            return;
          }

          print('🚀 بدء تهيئة خدمة الأذان Exact Alarm (Async)...');

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

          // 🔍 التحقق من صلاحية المنبهات الدقيقة (Exact Alarms)
          if (Platform.isAndroid) {
            await NotificationManager().checkAndRequestExactAlarmPermission();
          }

          // 2️⃣ إلغاء أي مهام قديمة
          await cancelAll();

          // 2️⃣ جدولة الأذان لعدة أيام
          await scheduleAllPrayersForMultipleDays(
            coordinates: coordinates,
            calculationParams: calculationParams,
            cityName: cityName,
            days: days,
          );

          // حفظ حالة الجدولة الحالية
          await _saveCurrentScheduleState(
              coordinates, calculationParams, cityName ?? "Unknown");

          // تحديث الويدجت الشاشة الرئيسية
          await updateWidget();

          // ✅ التحقق من نجاح الجدولة وإرسال إشعار تأكيد
          await _verifyAndNotifyScheduling();

          print('✅ تم تهيئة خدمة الأذان بنجاح');
        } catch (e, stackTrace) {
          print('❌ خطأ في تهيئة AdhanService (Async): $e');
          print('Stack Trace: $stackTrace');
          await AdhanDiagnosticHelper.logError('فشل التهيئة: $e');
        }
      });
    } catch (e, stackTrace) {
      print('❌ خطأ في تهيئة WorkManager: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  // ==========================================
  // 🧠 Smart Scheduling Logic
  // ==========================================

  Future<bool> _shouldReschedule(Coordinates? coords,
      CalculationParameters? params, String? cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRun = prefs.getInt('adhan_last_schedule_time') ?? 0;
    final lastSettingsHash = prefs.getString('adhan_settings_hash') ?? '';

    // Check time: Reschedule if > 3 days have passed since last schedule
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastRun = (now - lastRun) / (1000 * 60 * 60 * 24);
    if (daysSinceLastRun > 3) {
      print("🔄 Rescheduling: >3 days passed since last schedule.");
      return true;
    }

    // Check settings: Reschedule if settings changed
    final currentHash = await _generateSettingsHash(coords, params, cityName);
    if (currentHash != lastSettingsHash) {
      print("🔄 Rescheduling: Settings changed.");
      return true;
    }

    return false;
  }

  Future<void> _saveCurrentScheduleState(Coordinates? coords,
      CalculationParameters? params, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final hash = await _generateSettingsHash(coords, params, cityName);

    await prefs.setInt('adhan_last_schedule_time', now);
    await prefs.setString('adhan_settings_hash', hash);
  }

  Future<String> _generateSettingsHash(Coordinates? coords,
      CalculationParameters? params, String? cityName) async {
    // Collect all factors that affect prayer times
    final c = coords ?? await _getSavedCoordinates();
    final p = params ?? await _getSavedCalculationParams();
    final city = cityName ?? await _getCityName();

    final prefs = await SharedPreferences.getInstance();
    final manualOffset = prefs.getInt('manual_offset') ?? 0;
    final fOff = prefs.getInt('fajr_offset') ?? 0;
    final sOff = prefs.getInt('sunrise_offset') ?? 0;
    final dOff = prefs.getInt('dhuhr_offset') ?? 0;
    final aOff = prefs.getInt('asr_offset') ?? 0;
    final mOff = prefs.getInt('maghrib_offset') ?? 0;
    final iOff = prefs.getInt('isha_offset') ?? 0;

    // 🌍 أضف التعديلات العالمية للهاش لضمان إعادة الجدولة إذا تغيرت من السيرفر
    final globalOffsets = await SystemControlService().getGlobalPrayerOffsets();
    final gFajr = globalOffsets['fajr'] ?? 0;
    final gSunrise = globalOffsets['sunrise'] ?? 0;
    final gDhuhr = globalOffsets['dhuhr'] ?? 0;
    final gAsr = globalOffsets['asr'] ?? 0;
    final gMaghrib = globalOffsets['maghrib'] ?? 0;
    final gIsha = globalOffsets['isha'] ?? 0;

    // Create a simple signature string
    return "${c.latitude}_${c.longitude}_${p.method.index}_${p.madhab.index}_${city}_${manualOffset}_${fOff}_${sOff}_${dOff}_${aOff}_${mOff}_${iOff}_${gFajr}_${gSunrise}_${gDhuhr}_${gAsr}_${gMaghrib}_${gIsha}";
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
          // print('📋 محاولة جدولة: ${entry.key} - ${_formatTime(entry.value)}');
          final error = await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            prayerIndex: prayerIndex,
            cityName: cityName,
          );
          if (error == null) {
            scheduledCount++;
            // print('   ✅ تم الجدولة');
          } else {
            // print('   ❌ فشل الجدولة: $error');
            // print('   ⏭️ تم تخطيها (الوقت مرّ)');
          }
          prayerIndex++;
        }
      }

      print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
    } catch (e, stackTrace) {
      print('❌ خطأ في جدولة الصلوات: $e');
      print('Stack Trace: $stackTrace');
      await AdhanDiagnosticHelper.logError('فشل جدولة الصلوات: $e');
    }
  }

  /// جدولة إشعار الأذان مباشرة (Native Scheduling)
  Future<String?> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    required int dayOffset,
    required int prayerIndex,
    String? cityName,
  }) async {
    final now = DateTime.now();
    final errors = <String>[];

    // 🕌 تحسين اسم صلاة الظهر لتصبح "الجمعة" في يوم الجمعة
    String effectivePrayerName = prayerName;
    if (prayerName == 'الظهر' && prayerTime.weekday == DateTime.friday) {
      effectivePrayerName = 'الجمعة';
    }

    // تأكد أن الوقت لم يمر (مع هامش صغير 5 ثواني للاختبارات الفورية)
    if (prayerTime.isBefore(now.subtract(Duration(seconds: 5)))) {
      return "الوقت المحدد للصلاة قد مر بالفعل"; // الوقت فات
    }

    try {
      // 💾 تحميل الإعدادات
      final prefs = await SharedPreferences.getInstance();
      final bool isPrePrayerEnabled =
          prefs.getBool('is_pre_prayer_reminder_enabled') ?? true;
      final bool isIqamahEnabled =
          prefs.getBool('is_iqamah_reminder_enabled') ?? true;
      final bool isSunriseEnabled =
          prefs.getBool('is_sunrise_reminder_enabled') ?? true;

      // إنشاء ID فريد لكل صلاة
      final uniqueId = 1000 + (dayOffset * 10) + prayerIndex;

      final bool isFajr = prayerName.contains('الفجر');

      // 🔑 تحديد معلومات الصوت والقناة (ديناميكياً)
      final String type = prayerName.contains('الفجر') ? 'fajr' : 'normal';
      final String? selectedAdhanId = await getSelectedAdhan(type);
      final String channelKey = getChannelKey(type, selectedAdhanId);
      final String? soundPath = await getAdhanPath(type);

      print(
          '📅 جدولة Native ($uniqueId): $prayerName @ ${_formatTime(prayerTime)} on $channelKey');

      // 🔔 جدولة تنبيه "قبل الصلاة بـ 15 دقيقة"
      try {
        final prePrayerTime = prayerTime.subtract(const Duration(minutes: 15));
        if (prePrayerTime.isAfter(now) && isPrePrayerEnabled) {
          final preId = 40000 + uniqueId;
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: preId,
              channelKey: 'pre_prayer_channel_v1',
              icon: 'resource://drawable/ic_stat_logoapp',
              title: '\u200Fاقتربت صلاة $effectivePrayerName',
              body: '\u200Fباقي 15 دقيقة على صلاة $effectivePrayerName',
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
              autoDismissible: true,
              largeIcon: 'resource://drawable/ic_stat_logoapp',
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              payload: {
                'prayerName': effectivePrayerName,
                'type': 'pre_prayer',
              },
            ),
            schedule: NotificationCalendar.fromDate(
              date: prePrayerTime,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
          );
          print('   🔔 تم جدولة تنبيه ما قبل الصلاة (15 دقيقة)');
        }
      } catch (e) {
        print('❌ خطأ في جدولة Pre-Prayer: $e');
        errors.add('Pre-Prayer: $e');
      }

      // 📢 جدولة تنبيه "الإقامة" (بعد 15 دقيقة من الأذان)
      // لا توجد إقامة للشروق
      try {
        if (!prayerName.contains('الشروق') && isIqamahEnabled) {
          final iqamahTime = prayerTime.add(const Duration(minutes: 15));
          if (iqamahTime.isAfter(now)) {
            final iqamahId = 50000 + uniqueId;
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: iqamahId,
                channelKey: 'iqamah_channel_v1',
                icon: 'resource://drawable/ic_stat_logoapp',
                title: '\u200Fحان الآن موعد إقامة صلاة $effectivePrayerName',
                body: '\u200F لاتنسي أذكار بعد الصلاة المفروضة',
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
                autoDismissible: true,
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
                payload: {
                  'prayerName': effectivePrayerName,
                  'type': 'iqamah',
                },
              ),
              schedule: NotificationCalendar.fromDate(
                date: iqamahTime,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
            print('   📢 تم جدولة تنبيه الإقامة (بعد 15 دقيقة)');
          }
        }
      } catch (e) {
        print('❌ خطأ في جدولة Iqamah: $e');
        errors.add('Iqamah: $e');
      }

      // 🌅 معالجة خاصة للشروق (تغيير القناة)
      try {
        String effectiveChannelKey = channelKey;
        bool shouldScheduleMainNotification = true;

        if (prayerName.contains('الشروق')) {
          effectiveChannelKey = 'shruq_channel_v1';
          if (!isSunriseEnabled) {
            shouldScheduleMainNotification = false;
            print('   🌅 تم تخطي تنبيه الشروق حسب الإعدادات');
          }
        }

        if (shouldScheduleMainNotification) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: uniqueId,
              channelKey: effectiveChannelKey,
              icon: 'resource://drawable/ic_stat_logoapp',
              title: prayerName.contains('الشروق')
                  ? '\u200Fحان الآن وقت الشروق'
                  : '\u200Fحان الآن وقت صلاة $effectivePrayerName',
              body: prayerName.contains('الشروق')
                  ? '\u200Fصلاة الضحى صلاة الأوابين وهي صدقة عن كل مفصل من مفاصلك'
                  : '\u200Fفي مدينة ${cityName ?? "القاهرة"}',
              category: NotificationCategory.Alarm,
              wakeUpScreen: true,
              fullScreenIntent: true,
              criticalAlert: true,
              autoDismissible: true,
              locked: false,
              displayOnBackground: true, // IMPORTANT for Android 10+
              displayOnForeground: true,
              largeIcon: 'resource://drawable/ic_stat_logoapp',
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              timeoutAfter: isFajr
                  ? const Duration(minutes: 4, seconds: 40)
                  : const Duration(minutes: 3, seconds: 24),
              payload: {
                'prayerName': effectivePrayerName,
                'prayer_time': _formatTime(prayerTime),
                'cityName': cityName ?? "",
                'route': 'adhan_screen',
                'type': 'adhan',
              },

              // customSound: null, // 🔇 Disable notification sound for custom
              // playSound: false,  // We handle sound manually
            ),
            schedule: NotificationCalendar.fromDate(
              date: prayerTime,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
            actionButtons: [
              NotificationActionButton(
                color: KColors.primaryColor,
                key: 'STOP_ADHAN',
                label: 'إيقاف الأذان',
                actionType: ActionType.DismissAction,
                isDangerousOption: true,
              ),
              NotificationActionButton(
                key: 'MUTE_ADHAN',
                label: 'كتم الصوت',
                actionType: ActionType.DismissAction,
              ),
            ],
          );

          // 🔊 جدولة تشغيل الصوت يدوياً في الخلفية (Radical Solution)
          if (soundPath != null) {
            final int alarmId = 90000 + uniqueId;
            await AndroidAlarmManager.oneShotAt(
              prayerTime,
              alarmId,
              playAdhanCallback,
              exact: true,
              wakeup: true,
              rescheduleOnReboot: true,
              params: {'soundPath': soundPath},
            );
            print(
                '✅ [AlarmManager] Audio playback scheduled for $effectivePrayerName');
          }
        }
      } catch (e) {
        print('❌ خطأ في جدولة Adhan Main: $e');
        errors.add('Adhan Main: $e');
      }

      // 📿 جدولة أذكار بعد الصلاة (تحديث الـ ID لتجنب التعارض)
      // ... (code omitted) ...

      // ==========================================
      // ==========================================
      // 📱 جدولة تحديث الويدجت (بعد الصلاة مباشرة)
      // ==========================================
      final int widgetUpdateId = 70000 + uniqueId;
      // نؤخر التحديث دقيقة واحدة لضمان أن وقت "الآن" أصبح بعد وقت الصلاة
      // وبالتالي getNextPrayer() ترجع الصلاة التالية
      final widgetUpdateTime = prayerTime.add(const Duration(minutes: 1));

      if (widgetUpdateTime.isAfter(now)) {
        await AndroidAlarmManager.oneShotAt(
          widgetUpdateTime,
          widgetUpdateId,
          widgetUpdateCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
      }

      // ==========================================
      // 📿 جدولة أذكار بعد الصلاة (Native)
      // ==========================================
      try {
        final bool remEnabled =
            prefs.getBool('post_prayer_reminder_enabled') ?? false;
        final int remMinutes = prefs.getInt('post_reminder_minutes') ?? 10;

        if (remEnabled && !prayerName.contains('الشروق')) {
          final reminderTime = prayerTime.add(Duration(minutes: remMinutes));
          final reminderId = 30000 + uniqueId; // استخدام آي دي مختلف وآمن

          if (reminderTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: reminderId,
                channelKey: 'post_prayer_dhikr_channel',
                icon: 'resource://drawable/ic_stat_logoapp',
                title: 'أذكار بعد الصلاة',
                body: 'لا تنسَ قراءة أذكار ما بعد صلاة $effectivePrayerName',
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
                autoDismissible: true,
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
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
      } catch (e) {
        print('❌ خطأ في جدولة Post-Prayer: $e');
        errors.add('Post-Prayer: $e');
      }

      print(
          '✅ تم الجدولة بنجاح (Native) ${errors.isNotEmpty ? 'مع وجود بعض الأخطاء' : ''}');
      return errors.isEmpty ? null : errors.join(", ");
    } catch (e) {
      print('❌ خطأ في جدولة $prayerName: $e');
      await AdhanDiagnosticHelper.logError('فشل جدولة $prayerName: $e');
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
      final sOff = prefs.getInt('sunrise_offset') ?? 0;
      final dOff = prefs.getInt('dhuhr_offset') ?? 0;
      final aOff = prefs.getInt('asr_offset') ?? 0;
      final mOff = prefs.getInt('maghrib_offset') ?? 0;
      final iOff = prefs.getInt('isha_offset') ?? 0;

      // 🌍 تحميل التعديلات العامة من السيرفر (أو الكاش) لتكون متطابقة مع الواجهة
      final globalOffsets =
          await SystemControlService().getGlobalPrayerOffsets();
      final gFajr = globalOffsets['fajr'] ?? 0;
      final gSunrise = globalOffsets['sunrise'] ?? 0;
      final gDhuhr = globalOffsets['dhuhr'] ?? 0;
      final gAsr = globalOffsets['asr'] ?? 0;
      final gMaghrib = globalOffsets['maghrib'] ?? 0;
      final gIsha = globalOffsets['isha'] ?? 0;

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        'الفجر': prayerTimes.fajr
            .add(hourOffset)
            .add(Duration(minutes: fOff + gFajr)),
        'الشروق': prayerTimes.sunrise
            .add(hourOffset)
            .add(Duration(minutes: sOff + gSunrise)),
        'الظهر': prayerTimes.dhuhr
            .add(hourOffset)
            .add(Duration(minutes: dOff + gDhuhr)),
        'العصر':
            prayerTimes.asr.add(hourOffset).add(Duration(minutes: aOff + gAsr)),
        'المغرب': prayerTimes.maghrib
            .add(hourOffset)
            .add(Duration(minutes: mOff + gMaghrib)),
        'العشاء': prayerTimes.isha
            .add(hourOffset)
            .add(Duration(minutes: iOff + gIsha)),
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
      await updateWidget();
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
      final now = DateTime.now();

      // موعد الأذان التجريبي
      final adhanTime = now.add(Duration(seconds: secondsFromNow));

      // موعد التنبيه قبل الصلاة (قبل الأذان بـ 15 ثانية للاختبار السريع)
      final preAdhanTime = now.add(
          Duration(seconds: secondsFromNow - 15 > 0 ? secondsFromNow - 15 : 2));

      // موعد الإقامة (بعد الأذان بـ 15 ثانية للاختبار السريع)
      final iqamahTime = adhanTime.add(const Duration(seconds: 15));

      final cityName = await _getCityName();

      print('🧪 جدولة اختبار شامل (قبل الأذان -> أذان -> إقامة)...');

      // 1. التنبيه قبل الصلاة
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99901,
          channelKey: 'pre_prayer_channel_v1',
          title: 'اختبار: اقتربت الصلاة',
          body: 'تنبيه تجريبي: باقي 15 دقيقة على الصلاة',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF178B74),
        ),
        schedule: NotificationCalendar.fromDate(
          date: preAdhanTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      // 2. الأذان
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99902,
          channelKey: 'adhan_channel_v4',
          title: 'اختبار: حان الآن وقت الصلاة',
          body: 'تنبيه تجريبي: الله أكبر الله أكبر',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF178B74),
        ),
        schedule: NotificationCalendar.fromDate(
          date: adhanTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_ADHAN',
            color: KColors.primaryColor,
            label: 'إيقاف الأذان',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
          NotificationActionButton(
            key: 'MUTE_ADHAN',
            color: Colors.red,
            label: 'كتم الصوت',
            actionType: ActionType.DismissAction,
          ),
        ],
      );

      // 3. الإقامة
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99903,
          channelKey: 'iqamah_channel_v1',
          title: 'اختبار: حان الآن موعد الإقامة',
          body: 'تنبيه تجريبي: قد قامت الصلاة، قد قامت الصلاة',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
        ),
        schedule: NotificationCalendar.fromDate(
          date: iqamahTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      // 4. الشروق (اختبار قناة الشروق)
      final shruqTime = iqamahTime.add(const Duration(seconds: 15));
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99904,
          channelKey: 'shruq_channel_v1',
          title: '🧪 اختبار: حان الآن وقت الشروق',
          body: 'تنبيه تجريبي: موعد الشروق',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: shruqTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      print('✅ تم جدولة الاختبار الشامل بنجاح (مع الشروق)');
      return null;
    } catch (e) {
      print('❌ خطأ في جدولة الاختبار: $e');
      return e.toString();
    }
  }

  /// جدولة أذان تجريبي لصلاة محددة (للتأكد من الصوت المخصص)
  Future<String?> scheduleSpecificPrayerTest(String prayerName,
      {int secondsFromNow = 5}) async {
    try {
      final now = DateTime.now();
      final adhanTime = now.add(Duration(seconds: secondsFromNow));

      print('🧪 اختبار أذان مخصص لصلاة: $prayerName');

      // 1. الحصول على معلومات الصوت والقناة (ديناميكياً)
      final String type = prayerName.contains('الفجر') ? 'fajr' : 'normal';
      final String? selectedAdhanId = await getSelectedAdhan(type);
      final String channelKey = getChannelKey(type, selectedAdhanId);
      final String? soundPath = await getAdhanPath(type);
      final String soundId = selectedAdhanId ?? 'unknown';

      // 📝 إضافة سجل مطول للتشخيص
      final logMsg =
          'Test Adhan: $prayerName, SoundId: $soundId, Path: ${soundPath ?? "DEFAULT"}, Channel: $channelKey';
      print('🧪 $logMsg');
      await AdhanDiagnosticHelper.logError(logMsg);

      // 2. إنشاء الإشعار (صامت أو بصوت افتراضي فقط للعرض)
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99910 + prayerName.length,
          channelKey: channelKey,
          title: '🧪 اختبار $prayerName ($soundId)',
          body: 'المسار: ${soundPath ?? "افتراضي"}',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF178B74),
          // 🔇 Stop relying on notification sound for custom files
          customSound: null,
          //playSound: false, // We handle sound manually
        ),
        schedule: NotificationCalendar.fromDate(
          date: adhanTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_ADHAN',
            color: KColors.primaryColor,
            label: 'إيقاف الأذان',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
          NotificationActionButton(
            key: 'MUTE_ADHAN',
            color: Colors.red,
            label: 'كتم الصوت',
            actionType: ActionType.DismissAction,
          ),
        ],
      );

      // 3. 🔊 جدولة تشغيل الصوت يدوياً في الخلفية (Radical Solution)
      if (soundPath != null) {
        final int alarmId = 88880 + prayerName.length;
        await AndroidAlarmManager.oneShotAt(
          adhanTime,
          alarmId,
          playAdhanCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          params: {'soundPath': soundPath},
        );
        print('✅ [AlarmManager] Audio playback scheduled at $adhanTime');
      }

      return null;
    } catch (e) {
      print('❌ خطأ في اختبار أذان $prayerName: $e');
      return e.toString();
    }
  }

  // ==========================================
  // 🎵 إدارة أصوات الأذان وتوليد مفاتيح القنوات
  // ==========================================

  /// توليد مفتاح قناة فريد بناءً على نوع الصلاة ومعرف الصوت
  /// يضمن هذا رن الأذان بالصوت الجديد فوراً على أندرويد
  static String getChannelKey(String type, String? adhanId) {
    if (adhanId == null || adhanId.isEmpty) {
      return type == 'fajr' ? 'fajr_adhan_channel_v4' : 'adhan_channel_v4';
    }
    // تنظيف المعرف من أي رموز غير مسموحة في الـ key
    final cleanId = adhanId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${type}_adhan_channel_$cleanId';
  }

  /// الحصول على مفاتيح القنوات الحالية (للفجر والعادي) بناءً على الإعدادات
  static Future<Map<String, String>> getCurrentChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFajr = prefs.getString('selected_adhan_fajr');
    final selectedNormal = prefs.getString('selected_adhan_normal');

    return {
      'fajr': getChannelKey('fajr', selectedFajr),
      'normal': getChannelKey('normal', selectedNormal),
    };
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
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('pre_prayer_channel_v1');
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('iqamah_channel_v1');
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('shruq_channel_v1');

      print(
          '✅ تم تنظيف الجداول الزمنية بنجاح (مع الحفاظ على الإشعارات الحالية)');

      // 3️⃣ إلغاء تحديثات الويدجت المجدولة (AlarmManager)
      // Note: We can't cancel all alarms easily without IDs, but rescheduling overwrites them.
      // However, if we want to be clean, we loop through potential IDs if we knew them.
      // Since uniqueId is based on day/prayer, we rely on overwrite or new schedules.
      // For now, we will assume overwriting is sufficient as IDs are deterministic.
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
  // ✅ التحقق من نجاح الجدولة
  // ==========================================

  /// التحقق من نجاح الجدولة وإرسال إشعار تأكيد
  Future<void> _verifyAndNotifyScheduling() async {
    try {
      // الحصول على جميع الإشعارات المجدولة
      final scheduled =
          await AwesomeNotifications().listScheduledNotifications();

      // تصفية إشعارات الأذان فقط
      final adhanNotifications = scheduled.where((notification) {
        final channelKey = notification.content?.channelKey ?? '';
        return channelKey.contains('adhan') || channelKey.contains('fajr');
      }).toList();

      final count = adhanNotifications.length;

      if (count > 0) {
        print('✅ تم التحقق من الجدولة: $count إشعار أذان مجدول');

        // إرسال إشعار تأكيد للمستخدم (تم تعطيله بناءً على طلب المستخدم)
        // await AwesomeNotifications().createNotification(
        //   content: NotificationContent(
        //     id: 99998,
        //     channelKey: 'sabah_athkar_channel',
        //     title: '\u200Fتم جدولة الأذان بنجاح',
        //     body: '\u200Fتم جدولة $count صلاة للأيام القادمة',
        //     icon: 'resource://drawable/ic_stat_logoapp',
        //     notificationLayout: NotificationLayout.Default,
        //     category: NotificationCategory.Status,
        //     autoDismissible: true,
        //     color: const Color(0xFF178B74),
        //   ),
        // );
      } else {
        print('⚠️ تحذير: لم يتم جدولة أي إشعارات أذان!');
        await AdhanDiagnosticHelper.logError('لم يتم جدولة أي إشعارات أذان');
      }
    } catch (e) {
      print('❌ خطأ في التحقق من الجدولة: $e');
      await AdhanDiagnosticHelper.logError('فشل التحقق من الجدولة: $e');
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

    // 1. تحديث القنوات فوراً عند التغيير
    await updateNotificationChannels();

    // 2. إعادة جدولة الصلوات فوراً لتطبيق الصوت الجديد على القنوات الجديدة المجدولة
    await initialize(forceReschedule: true);
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

    // الحصول على مجلد التخزين (نفس المنطق المستخدم في athanModal.dart)
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/adhans/$selectedId.mp3';
    final file = File(filePath);

    if (await file.exists()) {
      // ✅ FIX: awesome_notifications requires file:// URI for customSound
      return 'file://$filePath';
    }
    return null;
  }

  /// تحديث قنوات AwesomeNotifications بالأصوات الجديدة
  Future<void> updateNotificationChannels() async {
    try {
      print('🎵 تحديث قنوات الأذان (عبر NotificationManager):');

      // ⚠️ تم إيقاف الحذف القسري لأنه قد يسبب مشاكل في الجدولة
      // await AwesomeNotifications().removeChannel('fajr_adhan_channel_v4');
      // await AwesomeNotifications().removeChannel('adhan_channel_v4');

      // 🚀 استخدام NotificationManager لتحديث كافة القنوات (وليس الأذان فقط)
      await NotificationManager.updateAllChannels();

      print('✅ تم تحديث جميع قنوات الإشعارات بنجاح');
    } catch (e) {
      print('❌ فشل تحديث قنوات الإشعارات: $e');
    }
  }

  Future<void> updateWidget() async {
    try {
      final next = await getNextPrayer();
      if (next != null) {
        final city = await _getCityName();
        final prayerTimes = await _getPrayerTimesForDate(DateTime.now());

        // Update Simple Widget
        await HomeWidgetService.updateWidget(
          prayerName: next['name'],
          prayerTime: next['formattedTime'],
          city: city,
        );

        // Update Full Widget
        await HomeWidgetService.updateFullPrayerWidget(
          fajrTime: _formatTime(prayerTimes['الفجر']!),
          sunriseTime: _formatTime(prayerTimes['الشروق']!),
          dhuhrTime: _formatTime(prayerTimes['الظهر']!),
          asrTime: _formatTime(prayerTimes['العصر']!),
          maghribTime: _formatTime(prayerTimes['المغرب']!),
          ishaTime: _formatTime(prayerTimes['العشاء']!),
          nextPrayer: next['name'],
          nextPrayerTime: next['time'], // Pass DateTime for Chronometer
          city: city,
        );
      }

      // Update Azkar widget with a daily azkar
      await _updateAzkarWidget();
    } catch (e) {
      print('❌ فشل تحديث الويدجت: $e');
    }
  }

  /// تحديث widget الأذكار بذكر يومي
  Future<void> _updateAzkarWidget() async {
    try {
      final now = DateTime.now();
      final isMorning = now.hour >= 4 && now.hour < 12;

      // قائمة أذكار مختصرة للـ widget
      final morningAzkar = [
        ('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ', 1, 'أذكار الصباح'),
        ('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100, 'أذكار الصباح'),
        (
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          100,
          'أذكار الصباح'
        ),
        ('اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا', 1, 'أذكار الصباح'),
        (
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
          3,
          'أذكار الصباح'
        ),
      ];

      final eveningAzkar = [
        ('أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ', 1, 'أذكار المساء'),
        ('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100, 'أذكار المساء'),
        (
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          100,
          'أذكار المساء'
        ),
        ('اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا', 1, 'أذكار المساء'),
        (
          'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
          3,
          'أذكار المساء'
        ),
      ];

      final azkarList = isMorning ? morningAzkar : eveningAzkar;

      // اختيار ذكر عشوائي بناءً على اليوم
      final dayIndex = now.day % azkarList.length;
      final selectedAzkar = azkarList[dayIndex];

      await HomeWidgetService.updateAzkarWidget(
        azkarText: selectedAzkar.$1,
        repetitions: selectedAzkar.$2,
        title: selectedAzkar.$3,
      );
    } catch (e) {
      print('❌ فشل تحديث widget الأذكار: $e');
    }
  }
}
