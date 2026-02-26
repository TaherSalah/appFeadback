import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';
import 'package:muslimdaily/app/features/quran/quranView.dart';
import 'package:muslimdaily/app/features/hadith/hadith_view.dart';
import 'package:muslimdaily/app/features/sabahView/azkar_sabah.dart';
import 'package:muslimdaily/app/features/sleep_view/sleep_azkar.dart';
import 'package:muslimdaily/app/features/charity/CharityDashboardScreen.dart';
import 'package:muslimdaily/app/core/services/adhan_logic/prayer_scheduler_service.dart';
import 'package:muslimdaily/app/features/azanView/view/adhan_overlay_screen.dart';
import 'package:muslimdaily/app/features/Khatmah/view/GlobalKhatmahScreen.dart';
import 'package:muslimdaily/app/features/charity/AchievementsScreen.dart';
import 'package:muslimdaily/app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:muslimdaily/app/features/mainView/widget/AllAzkarListView.dart';
import 'package:muslimdaily/app/features/notifications/view/notification_dialog_screen.dart';
import 'package:hijri/hijri_calendar.dart' as hijri;
import 'package:muslimdaily/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

//   final SettingsService _settingsService = SettingsService();

  // 🔊 إيقاف صوت الإشعارات والأذان فوراً
  static Future<void> stopAdhan() async {
    print('🛑 Requesting to stop all notifications and adhan audio...');
    try {
      // 1. إيقاف الإشعارات (هذا يوقف الصوت إذا كان تابعاً للقناة)
      await AwesomeNotifications().dismissAllNotifications();

      // 2. إيقاف أي صوت مشغل عبر AudioManager (إذا كان مفعلاً)
      // await AudioManager().stop();

      print('✅ All notifications dismissed/stopped.');
    } catch (e) {
      print('❌ Error stopping adhan: $e');
    }
  }

  Future<void> initialize() async {
    await SettingsService().init();

    await updateAllChannels();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    await AwesomeNotifications().isNotificationAllowed().then((allowed) {
      if (!allowed) {
        AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.CriticalAlert,
            NotificationPermission.FullScreenIntent,
            NotificationPermission.PreciseAlarms, // ⭐ مطلوب لـ Infinix/Realme
          ],
        );
      }
    });

    // ⭐ طلب إعفاء تحسين البطارية (مطلوب لـ Infinix وRealme لتشغيل الأذان على الشاشة المقفولة)
    await _requestBatteryExemptionIfNeeded();

    // 🚀 تهيئة خدمة الأذان عبر النظام الجديد
    await PrayerSchedulerService().initialize();
  }

  static Future<void> updateAllChannels() async {
    // القنوات الثابتة للأذان (لا تتغير ديناميكياً في هذا النظام)
    const fajrPath = null;
    const normalPath = null;
    final currentChannels = {
      'fajr': 'fajr_adhan_channel_v4',
      'normal': 'adhan_channel_v4',
    };

    print(
        '🔔 [NotificationManager] Initializing Awesome Notifications channels...');

    final channels = [
      // 🌅 قناة أذان الفجر (ديناميكية)
      NotificationChannel(
        channelKey: currentChannels['fajr']!,
        channelName: 'أذان الفجر',
        channelDescription: 'تشغيل أذان الفجر',
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: fajrPath ??
            (Platform.isAndroid ? 'resource://raw/fajr' : 'fajr.mp3'),
        enableVibration: SettingsService().isAdhanVibrationEnabled,
        enableLights: true,
        ledColor: const Color(0xFF178B74),
        defaultColor: const Color(0xFF178B74),
        defaultPrivacy: NotificationPrivacy.Public,
        locked: false,
        criticalAlerts: true,
      ),

      // 🕌 قناة الأذان العادي (ديناميكية)
      NotificationChannel(
        channelKey: currentChannels['normal']!,
        channelName: 'أذان الصلاة',
        channelDescription: 'تشغيل صوت الأذان',
        importance: NotificationImportance.Max,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
        enableVibration: SettingsService().isAdhanVibrationEnabled,
        enableLights: true,
        locked: false,
        criticalAlerts: true,
      ),

      // 📿 قناة الأذكار والتذكيرات
      NotificationChannel(
        channelKey: 'sabah_athkar_channel',
        channelName: 'أذكار الصباح',
        channelDescription: 'حان وقت أذكار الصباح',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        soundSource:
            Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),

      NotificationChannel(
        channelKey: 'mesaa_athkar_channel',
        channelName: 'أذكار المساء',
        channelDescription: 'تذكير أذكار المساء',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        soundSource:
            Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),

      NotificationChannel(
        channelKey: 'sleep_athkar_channel',
        channelName: 'أذكار النوم',
        channelDescription: 'تذكير أذكار النوم',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        soundSource:
            Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),

      NotificationChannel(
        channelKey: 'qiam_channel',
        channelName: 'قيام الليل',
        channelDescription: 'وقت قيام الليل',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        soundSource: Platform.isAndroid ? 'resource://raw/qiam' : 'qiam.mp3',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),

      // 🤲 قناة الصلاة على النبي
      NotificationChannel(
        channelKey: 'salawat_channel',
        channelName: 'الصلاة على النبي',
        channelDescription: 'تذكير بالصلاة على النبي',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource:
            Platform.isAndroid ? 'resource://raw/profet' : 'profet.mp3',
        enableVibration: true,
        enableLights: true,
      ),

      // 📖 قناة القرآن
      NotificationChannel(
        channelKey: 'quran_channel',
        channelName: 'ورد القرآن',
        channelDescription: 'تذكير بالورد اليومي',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        enableVibration: true,
        enableLights: true,
      ),
      // 🤲 قناة أذكار بعد الصلاة
      NotificationChannel(
        channelKey: 'post_prayer_dhikr_channel',
        channelName: 'أذكار بعد الصلاة',
        channelDescription: 'تذكير بأذكار ما بعد الصلاة',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource:
            Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
        enableVibration: true,
        enableLights: true,
      ),

      // 📿 قناة الحديث اليومي
      NotificationChannel(
        channelKey: 'hadith_channel',
        channelName: 'الحديث اليومي',
        channelDescription: 'تذكير بحديث اليوم',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        enableVibration: true,
        enableLights: true,
      ),
      // 💰 قناة تذكير الزكاة
      NotificationChannel(
        channelKey: 'zakat_reminder_channel',
        channelName: 'تذكير الزكاة',
        channelDescription: 'تذكير بمرور الحول على الزكاة',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      // 💰 قناة تذكيرات الصدقة
      NotificationChannel(
        channelKey: 'charity_reminder_channel',
        channelName: 'تذكير الصدقة',
        channelDescription: 'تذكير بالصدقة اليومية والأسبوعية والدورية',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        enableVibration: true,
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        enableLights: true,
      ),
      // 🏆 قناة الإنجازات
      NotificationChannel(
        channelKey: 'achievement_unlocked_channel',
        channelName: 'إنجازات الصدقة',
        channelDescription: 'إشعارات عند فتح إنجاز جديد في قسم الصدقة',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        enableVibration: true,
        enableLights: true,
      ),
      // 🗓️ قناة تذكير التقويم
      NotificationChannel(
        channelKey: 'calendar_reminders_channel',
        channelName: 'تذكير التقويم',
        channelDescription: 'تنبيهات للمناسبات والأحداث الخاصة في التقويم',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: Platform.isAndroid
            ? 'resource://raw/notification'
            : 'notification.wav',
        enableVibration: true,
        enableLights: true,
      ),

      // 🔔 قناة التنبيهات قبل الصلاة
      NotificationChannel(
        channelKey: 'pre_prayer_channel_v1',
        channelName: 'تنبيهات قبل الصلاة',
        channelDescription: 'تنبيه قبل الصلاة بـ 15 دقيقة',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource:
            Platform.isAndroid ? 'resource://raw/pre_prayer' : 'pre_prayer.mp3',
        enableVibration: true,
        enableLights: true,
      ),

      // 📢 قناة إقامة الصلاة
      NotificationChannel(
        channelKey: 'iqamah_channel_v1',
        channelName: 'تنبيهات الإقامة',
        channelDescription: 'تنبيه بموعد إقامة الصلاة',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource:
            Platform.isAndroid ? 'resource://raw/iqamah' : 'iqamah.mp3',
        enableVibration: true,
        enableLights: true,
      ),

      // 🌅 قناة وقت الشروق
      NotificationChannel(
        channelKey: 'shruq_channel_v1',
        channelName: 'تنبيه الشروق',
        channelDescription: 'تنبيه بموعد الشروق',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF178B74),
        ledColor: const Color(0xFF178B74),
        playSound: true,
        soundSource: Platform.isAndroid ? 'resource://raw/shruq' : 'shruq.mp3',
        enableVibration: true,
        enableLights: true,
        criticalAlerts: true,
      ),

      // 🕌 Legacy Channels from NotifyHelper (Old Adhan Logic)
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak',
        channelName: 'Prayer Times Notifications',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_saqqaf',
        channelName: 'Prayer Times Notifications saqqaf',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_sarihi',
        channelName: 'Prayer Times Notifications sarihi',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_baset',
        channelName: 'Prayer Times Notifications baset',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_qatami',
        channelName: 'Prayer Times Notifications qatami',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_salah',
        channelName: 'Prayer Times Notifications salah',
        channelDescription: 'Notification channel for Prayer Times',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: normalPath ??
            (Platform.isAndroid ? 'resource://raw/athan' : 'athan.mp3'),
      ),
      NotificationChannel(
        channelKey: 'prayers_notifications_channel_ak_notification',
        channelName: 'App Notifications',
        channelDescription: 'Notification channel for App Notifications',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/notification',
      ),
    ];

    try {
      await AwesomeNotifications().initialize(
        Platform.isAndroid ? 'resource://drawable/ic_stat_logoapp' : null,
        channels,
        debug: true,
      );
      print(
          '✅ [NotificationManager] Awesome Notifications initialized successfully.');
    } catch (e) {
      print(
          '❌ [NotificationManager] Failed to initialize Awesome Notifications: $e');
      // Try to initialize ONE BY ONE to find the bad one
      for (var channel in channels) {
        try {
          await AwesomeNotifications().setChannel(channel);
          print(
              '✅ [NotificationManager] Channel ${channel.channelKey} initialized.');
        } catch (ex) {
          print(
              '❌ [NotificationManager] Channel ${channel.channelKey} FAILED: $ex');
        }
      }
      rethrow;
    }
  }

  Future<bool> checkAndRequestExactAlarmPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.CriticalAlert,
          NotificationPermission.FullScreenIntent,
        ],
      );
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
    }
    return isAllowed;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      await AwesomeNotifications().showAlarmPage();
    }
  }

  /// ⭐ يطلب إعفاء تحسين البطارية مرة واحدة فقط (عند أول تشغيل)
  /// هذا الحل أساسي لأجهزة Infinix وRealme وXiaomi وOppo
  Future<void> _requestBatteryExemptionIfNeeded() async {
    if (!Platform.isAndroid) return;
    try {
      final prefs = await _getPrefs();
      final alreadyRequested = prefs.getBool('battery_exemption_requested') ?? false;
      if (alreadyRequested) return;

      // هذه الدالة تفتح صفحة "السماح بضبط التنبيهات والتذكيرات" على Android 12+
      // وهي الخطوة المطلوبة لضمان دقة أوقات الأذان على Infinix وRealme
      await AwesomeNotifications().showAlarmPage();
      await prefs.setBool('battery_exemption_requested', true);
    } catch (e) {
      // تجاهل الخطأ — على أجهزة Android القديمة الدالة غير موجودة وهذا طبيعي
    }
  }

  /// الحصول على SharedPreferences (يُخزّن instance واحد)
  static SharedPreferences? _prefsInstance;
  static Future<SharedPreferences> _getPrefs() async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  Future<void> scheduleInstantTestNotification() async {
    DateTime testTime = DateTime.now().add(const Duration(seconds: 10));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9999,
        channelKey: 'fajr_adhan_channel_v4',
        title: 'اختبار فوري',
        body: 'إذا وصلك هذا الصوت، فنظام المنبهات يعمل بنجاح!',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar.fromDate(
        date: testTime,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Cancels all existing scheduled notifications (Azkar & Salawat) and reschedules them
  /// based on current settings.
  /// Note: Adhan is handled by AdhanWorkManagerService, but we can control its 'enable' state via SettingsService
  /// which AdhanWorkManagerService should check before notifying.
  Future<void> rescheduleAll({bool force = false}) async {
    // print('🔄 Rescheduling all notifications based on settings...');

    // إلغاء كل التذكيرات المجدولة (ما عدا الأذان الذي يديره WorkManager مبدئياً)
    // أو يمكننا إلغاء الأذان أيضاً إذا أردنا إيقافه تماماً

    // IDs ranges:
    // 1: Sabah
    // 2: Massa
    // 3: Quran
    // 6: Sleep
    // 7: Qiyam
    // 100+: Salawat

    await AwesomeNotifications().cancel(1);
    await AwesomeNotifications().cancel(2);
    await AwesomeNotifications().cancel(3);
    await AwesomeNotifications().cancel(6);
    await AwesomeNotifications().cancel(7);
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('salawat_channel'); // Cancel all salawat

    // re-schedule if enabled
    await _setupDailyReminders();

    // 🚀 إعادة جدولة الأذان
    // When calling rescheduleAll manually, we usually WANT to force an update (e.g. settings changed)
    // If called from main.dart on startup, force might be false (default)
    await PrayerSchedulerService().reschedule();

    // print('✅ Reschedule completed.');
  }

  Future<void> _setupDailyReminders() async {
    try {
      // 🌅 أذكار الصباح
      if (SettingsService().isAzkarSabahEnabled) {
        await _scheduleDailyNotification(
          id: 1,
          channelKey: 'sabah_athkar_channel',
          title: 'أذكار الصباح',
          body: 'حان وقت أذكار الصباح، بارك الله في صباحك',
          hour: 9,
          minute: 0,
          payload: {'route': 'morning_athkar'},
        );
      }

      // 🌙 أذكار المساء
      if (SettingsService().isAzkarMassaEnabled) {
        await _scheduleDailyNotification(
          id: 2,
          channelKey: 'mesaa_athkar_channel',
          title: 'أذكار المساء',
          body: 'حان وقت أذكار المساء، جعل الله مساءك مباركاً',
          hour: 18,
          minute: 0,
          payload: {'route': 'evening_athkar'},
        );
      }

      // 📖 ورد القرآن
      if (SettingsService().isDailyQuranReminderEnabled) {
        await _scheduleDailyNotification(
          id: 3,
          channelKey: 'quran_channel',
          title: 'ورد القرآن اليومي',
          body: 'لا تنسَ وردك اليومي من القرآن الكريم',
          hour: 20,
          minute: 0,
          payload: {'route': 'quran_wird'},
        );
      }

      // 📿 حديث اليوم (متجدد يومياً)
      await scheduleHadithSeries();

      // 😴 أذكار النوم
      if (SettingsService().isAzkarSleepEnabled) {
        await _scheduleDailyNotification(
          id: 6,
          channelKey: 'sleep_athkar_channel',
          title: 'أذكار النوم',
          body: 'حان وقت أذكار النوم، تصبح على خير',
          hour: 22,
          minute: 0,
          payload: {'route': 'sleep_athkar'},
        );
      }

      // 🌙 قيام الليل
      if (SettingsService().isQiyamEnabled) {
        await _scheduleDailyNotification(
          id: 7,
          channelKey: 'qiam_channel',
          title: 'قيام الليل',
          body: 'وقت قيام الليل، تقبل الله طاعاتكم',
          hour: 23,
          minute: 0,
          payload: {'route': 'qiyam_reminder'},
        );
      }

      // 🤲 الصلاة على النبي
      if (SettingsService().isSalatAlaNabiEnabled) {
        await _scheduleSalawat();
      }

      // ⏰ منبه الفجر المتقدم
      await _scheduleAdvancedFajrAlarm();

      // 🍽️ تذكير صيام الاثنين والخميس
      if (SettingsService().isFastingReminderEnabled) {
        await _scheduleFastingReminders();
      }

      // 🕌 سنن الجمعة (الكهف وساعة الاستجابة)
      if (SettingsService().isFridayRemindersEnabled) {
        await _scheduleFridayReminders();
      }

      // ⚪ الأيام البيض (13، 14، 15 هجرياً)
      if (SettingsService().isWhiteDaysReminderEnabled) {
        await _scheduleWhiteDaysReminders();
      }

      // ✨ المناسبات الإسلامية
      if (SettingsService().isReligiousOccasionsEnabled) {
        await _scheduleReligiousOccasions();
      }

      // 🌕 سورة الملك
      if (SettingsService().isMulkReminderEnabled) {
        await _scheduleMulkReminder();
      }

      // ☀️ صلاة الضحى
      if (SettingsService().isDuhaReminderEnabled) {
        await _scheduleDuhaReminder();
      }

      // 💡 سنة اليوم
      if (SettingsService().isSunnahReminderEnabled) {
        await _scheduleSunnahReminder();
      }

      // 🤲 الدعاء بين الأذان والإقامة
      if (SettingsService().isBetweenAdhanIqamahEnabled) {
        await _scheduleBetweenAdhanIqamah();
      }
    } catch (e, stackTrace) {
      print('❌ Error in scheduling reminders: $e');
      print(stackTrace);
    }
  }

  // ==========================================
  // 📅 جدولة الأحاديث
  // ==========================================
  Future<void> scheduleHadithSeries() async {
    try {
      logger.i("📅 جاري جدولة حديث اليوم...");

      // 1️⃣ إلغاء الجدولة القديمة
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('hadith_channel');

      final now = DateTime.now();

      // 3️⃣ اختيار الحديث المناسب ليوم السنة الحالي (يتغير كل يوم تلقائياً)
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final todayHadith = dailyHadiths[dayOfYear % dailyHadiths.length];

      // 4️⃣ إشعار يومي واحد متكرر للأبد — repeats: true
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 500,
          channelKey: 'hadith_channel',
          title: '\u200F حديث اليوم',
          body: '\u200F$todayHadith',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Reminder,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          payload: {'route': 'daily_hadith'},
          color: const Color(0xFF178B74),
        ),
        schedule: NotificationCalendar(
          hour: 11,
          minute: 0,
          second: 0,
          millisecond: 0,
          repeats: true,        // ✅ يتكرر كل يوم للأبد
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      logger.i("✅ تم جدولة حديث اليوم بنجاح (يومي متكرر)");
    } catch (e) {
      logger.e("❌ خطأ في جدولة الأحاديث: $e");
    }
  }

  // قائمة الأحاديث
  static const List<String> dailyHadiths = [
    "عن ابن عباس، أن النبي صلى الله عليه وسلم دخل قبرا ليلا، فأسرج له سراج، فأخذه من قبل القبلة، وقال: «رحمك الله، إن كنت لأواها تلاء للقرآن»، وكبر عليه أربعا وفي الباب عن جابر، ويزيد بن ثابت، وهو أخو زيد بن ثابت أكبر منه.",
    'عن أبي هريرة، أن رسول الله صلى الله عليه وسلم قال: " الشهداء خمس: المطعون، والمبطون، والغرق، وصاحب الهدم، والشهيد في سبيل الله "',
    "عن أبي حية، قال: رأيت عليا رضي الله عنه «توضأ فذكر وضوءه كله ثلاثا ثلاثا»، قال: «ثم مسح رأسه، ثم غسل رجليه إلى الكعبين»، ثم قال: «إنما أحببت أن أريكم طهور رسول الله صلى الله عليه وسلم»",
    "عن أبي هريرة، قال: قال رسول الله صلى الله عليه وسلم: «لا صلاة لمن لا وضوء له، ولا وضوء لمن لم يذكر اسم الله تعالى عليه»",
    "عن حفصة زوج النبي صلى الله عليه وسلم، «أن النبي صلى الله عليه وسلم كان يجعل يمينه لطعامه وشرابه وثيابه، ويجعل شماله لما سوى ذلك»",
    "عن ‌أبي هريرة رضي الله عنه قال: قال النبي صلى الله عليه وسلم: «كلمتان حبيبتان إلى الرحمن، خفيفتان على اللسان، ثقيلتان في الميزان: سبحان الله وبحمده، سبحان الله العظيم.»",
    "عن ‌أبي موسى رضي الله عنه عن النبي صلى الله عليه وسلم قال: «مثل المؤمن الذي يقرأ القرآن كالأترجة، طعمها طيب وريحها طيب، والذي لا يقرأ كالتمرة، طعمها طيب ولا ريح لها، ومثل الفاجر الذي يقرأ القرآن كمثل الريحانة، ريحها طيب وطعمها مر، ومثل الفاجر الذي لا يقرأ القرآن كمثل الحنظلة، طعمها مر ولا ريح لها.»",
    "عن ‌عمران قال: «قلت: يا رسول الله، فيما يعمل العاملون؟ قال: كل ميسر لما خلق له.»",
    "عن ‌البراء قال: «سمعت النبي صلى الله عليه وسلم يقرأ في العشاء: {والتين والزيتون} فما سمعت أحدا أحسن صوتا أو قراءة منه.»",
    "عن عبد الله بن عمر رضي الله عنهما، قال: «صليت مع النبي صلى الله عليه وسلم بمنى ركعتين، وأبي بكر، وعمر ومع عثمان صدرا من إمارته ثم أتمها»",
    "عن أبي سلمة، قال: رأيت أبا هريرة رضي الله عنه، قرأ: إذا السماء انشقت، فسجد بها، فقلت: يا أبا هريرة ألم أرك تسجد؟ قال: «لو لم أر النبي صلى الله عليه وسلم يسجد لم أسجد»",
    'عن عبد الله رضي الله عنه قال: قال رجل: يا رسول الله أيؤاخذ الرجل بما عمل في الجاهلية؟ قال: «من أحسن في الإسلام لم يؤاخذ بما كان عمل في الجاهلية، ومن أساء في الإسلام، أخذ بالأول والآخر»',
    'عن أنس بن مالك قال: قال رسول الله صلى الله عليه وسلم: «قد أكثرت عليكم في السواك»',
    'عن ابن عمر، عن النبي صلى الله عليه وسلم قال: «أحفوا الشوارب، وأعفوا اللحى»',
    'عن أبي مسعود، قال: قال رسول الله صلى الله عليه وسلم: «الشمس والقمر لا ينكسفان لموت أحد ولا لحياته، ولكنهما آيتان من آيات الله فإذا رأيتموهما فصلوا»',
    'عن عائشة رضي الله عنها، قالت: كسفت الشمس على عهد رسول الله صلى الله عليه وسلم، فقام النبي صلى الله عليه وسلم، فصلى بالناس، فأطال القراءة، ثم ركع، فأطال الركوع، ثم رفع رأسه، فأطال القراءة وهي دون قراءته الأولى، ثم ركع، فأطال الركوع دون ركوعه الأول، ثم رفع رأسه، فسجد سجدتين، ثم قام، فصنع في الركعة الثانية مثل ذلك، ثم قام فقال: «إن الشمس والقمر لا يخسفان لموت أحد ولا لحياته، ولكنهما آيتان من آيات الله يريهما عباده، فإذا رأيتم ذلك، فافزعوا إلى الصلاة»',
    'عن أبي هريرة رضي الله عنه، قال: «كان النبي صلى الله عليه وسلم يقرأ في الجمعة في صلاة الفجر الم تنزيل السجدة وهل أتى على الإنسان»',
    'عن جابر بن عبد الله قال: قال رسول الله صلى الله عليه وسلم: «مفتاح الجنة الصلاة، ومفتاح الصلاة الوضوء»',
    'عن أنس بن مالك، قال: " كان النبي صلى الله عليه وسلم إذا دخل الخلاء، قال: اللهم إني أعوذ بك " قال شعبة: وقد قال مرة أخرى: «أعوذ بالله من الخبث والخبيث - أو الخبث والخبائث -».',
    "عن أنس بن مالك، قال: قال رسول الله صلى الله عليه وسلم: «من ترك الكذب وهو باطل، بني له قصر في ربض الجنة، ومن ترك المراء وهو محق، بني له في وسطها، ومن حسن خلقة، بني له في أعلاها»",
    "عن جابر، قال: قال رسول الله صلى الله عليه وسلم: «من كذب علي متعمدا، فليتبوأ مقعده من النار»",
    "عن أبي سلمة، أن أبا هريرة، قال لرجل: يا ابن أخي، «إذا حدثتك عن رسول الله صلى الله عليه وسلم حديثا، فلا تضرب له الأمثال»قال: أبو الحسن، حدثنا يحيى بن عبد الله الكرابيسي قال: حدثنا علي بن الجعد، عن شعبة، عن عمرو بن مرة، مثل حديث علي رضي الله تعالى عنه",
    "عن أبي الدرداء، قال: خرج علينا رسول الله صلى الله عليه وسلم، ونحن نذكر الفقر ونتخوفه، فقال: «آلفقر تخافون؟ والذي نفسي بيده، لتصبن عليكم الدنيا صبا، حتى لا يزيغ قلب أحدكم إزاغة إلا هيه، وايم الله، لقد تركتكم على مثل البيضاء، ليلها ونهارها سواء» قال أبو الدرداء: صدق والله رسول الله صلى الله عليه وسلم: «تركنا والله على مثل البيضاء، ليلها ونهارها سواء»",
    "قال رسول الله ﷺ: (ما أمرتكم به فخذوه، وما نهيتكم عنه فانتهوا).",
    "قال رسول الله ﷺ: (يسروا ولا تعسروا، وبشروا، ولا تنفروا).",
    "عن جابر بن عبد الله، قال: كان رسول الله صلى الله عليه وسلم: إذا خطب احمرت عيناه، وعلا صوته، واشتد غضبه، كأنه منذر جيش يقول: «صبحكم مساكم» ويقول: «بعثت أنا والساعة كهاتين، ويقرن بين إصبعيه السبابة والوسطى» ثم يقول: «أما بعد، فإن خير الأمور كتاب الله، وخير الهدي هدي محمد، وشر الأمور محدثاتها، وكل بدعة ضلالة» وكان يقول: «من ترك مالا فلأهله، ومن ترك دينا أو ضياعا، فعلي وإلي»",
    "قال رسول الله ﷺ: (يسروا ولا تعسروا، وبشروا، ولا تنفروا).",
    "قال رسول الله ﷺ: (خيركم من تعلم القرآن وعلمه).",
    "قال رسول الله ﷺ: (إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى).",
    "قال رسول الله ﷺ: (الكلمة الطيبة صدقة).",
    "عن علي، عن النبي صلى الله عليه وسلم قال: «من حدث عني حديثا وهو يرى أنه كذب، فهو أحد الكاذبين»",
    "قال رسول الله ﷺ: (المسلم من سلم المسلمون من لسانه ويده).",
    "قال رسول الله ﷺ: (لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه).",
    "قال رسول الله ﷺ: (اتق الله حيثما كنت، وأتبع السيئة الحسنة تمحها).",
    "قال رسول الله ﷺ: (الدال على الخير كفاعله).",
    "قال رسول الله ﷺ: (من صلّى عليّ صلاة صلّى الله عليه بها عشراً).",
    "قال رسول الله ﷺ: (تبسمك في وجه أخيك صدقة).",
    "قال رسول الله ﷺ: (من كان يؤمن بالله واليوم الآخر فليقل خيراً أو ليصمت).",
    "قال رسول الله ﷺ: (أحب الأعمال إلى الله أدومها وإن قل).",
    "قال رسول الله ﷺ: (من سلك طريقاً يلتمس فيه علماً سهل الله له به طريقاً إلى الجنة).",
    "قال رسول الله ﷺ: (من اتبع جنازة مسلم، إيمانا واحتسابا، وكان معه حتى يصلى عليها ويفرغ من دفنها، فإنه يرجع من الأجر بقيراطين، كل قيراط مثل أحد، ومن صلى عليها ثم رجع قبل أن تدفن، فإنه يرجع بقيراط).",
    "قال رسول الله ﷺ: (إذا أحسن أحدكم إسلامه: فكل حسنة يعملها تكتب له بعشر أمثالها إلى سبع مائة ضعف، وكل سيئة يعملها تكتب له بمثلها).",
  ];

  Future<void> _scheduleDailyNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    required int hour,
    required int minute,
    Map<String, String>? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        icon: 'resource://drawable/ic_stat_logoapp',
        id: id,
        channelKey: channelKey,
        title: '\u200F$title',
        body: '\u200F$body',
        notificationLayout: NotificationLayout
            .Default, // Changed from BigText to Default if the body is short, but user wants chic. BigText is generally safer for varying lengths. Let's stick to BigText for better appearance.
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        payload: payload,
      ),
      schedule: NotificationCalendar(
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> _scheduleSalawat() async {
    int minutes = SettingsService().getSalatAlaNabiMinutes();
    // print('Scheduling Salawat every $minutes minutes');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888, // Constant ID for the repeating schedule
        channelKey: 'salawat_channel',
        icon: 'resource://drawable/ic_stat_logoapp',
        title: 'ﷺ',
        body: 'اللهم صل وسلم على نبينا محمد',
        notificationLayout: NotificationLayout.Default,
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        payload: {'route': 'salawat'},
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationInterval(
        interval: Duration(minutes: minutes),
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> scheduleAdvancedFajrAlarm() async {
    await SettingsService().init();
    await _scheduleAdvancedFajrAlarm();
  }

  Future<void> _scheduleAdvancedFajrAlarm() async {
    // 1. Cancel existing advanced fajr alarms
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');

    if (!SettingsService().isFajrAlarmEnabled) {
      logger.e("🔕 Advanced Fajr Alarm is DISABLED.");
      return;
    }

    final hour = SettingsService().fajrAlarmHour;
    final minute = SettingsService().fajrAlarmMinute;
    final days = SettingsService().fajrAlarmDays; // 1-7 (Mon-Sun)
    final repetitions = SettingsService().fajrAlarmRepetitions;

    // Default 5 minutes interval, but we could make it settings based later
    const int intervalMinutes = 5;

    // print(
    //     '🕒 Scheduling Advanced Fajr Alarm at $hour:$minute for days: $days with $repetitions repetitions (Interval: ${intervalMinutes}m)');

    for (int day in days) {
      for (int r = 0; r < repetitions; r++) {
        // Calculate offset time
        int offsetMinutes = r * intervalMinutes;
        int totalMin = minute + offsetMinutes;

        int finalHour = (hour + (totalMin ~/ 60)) % 24;
        int finalMinute = totalMin % 60;

        // Generate unique ID:
        // Day (1-7) * 100 -> 100, 200... 700
        // Repetition (0-9) -> 0, 1...
        // Base 2000
        // Example: Monday (1), 1st rep (0) -> 2100
        // Example: Monday (1), 2nd rep (1) -> 2101
        int uniqueId = 2000 + (day * 100) + r;

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: uniqueId,
            channelKey: 'fajr_adhan_channel_v4',
            title: 'منبه الفجر المتقدم',
            body: r == 0
                ? 'حان وقت الاستيقاظ لصلاة الفجر'
                : 'تذكير إضافي: صلاة الفجر خير من النوم ', // Different body for snoozes
            category: NotificationCategory.Alarm,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            autoDismissible: true, // User must dismiss it
            locked: false, // Requires interaction
            largeIcon: 'resource://drawable/ic_stat_logoapp',
            notificationLayout: NotificationLayout.BigText,
            color: const Color(0xFF178B74),
          ),
          schedule: NotificationCalendar(
            weekday: day,
            hour: finalHour,
            minute: finalMinute,
            second: 0,
            repeats: true,
            preciseAlarm: true,
            allowWhileIdle: true,
          ),
        );
        logger.i(
            "✅ Scheduled Alarm ID: $uniqueId for Day: $day at $finalHour:$finalMinute");
      }
    }
    // print('✅ All Advanced Fajr Alarms scheduled successfully.');
  }

  // ==========================================
  // 🍽️ تذكير الصيام (الاثنين والخميس)
  // ==========================================
  Future<void> _scheduleFastingReminders() async {
    // تذكير صيام الاثنين (يوم الأحد الساعة 8 مساءً)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 701,
        channelKey:
            'sabah_athkar_channel', // using existing channel for simplicity
        title: 'تذكير صيام الاثنين',
        body: 'غداً يوم الاثنين، تذكير بصيام يوم في سبيل الله',
        category: NotificationCategory.Reminder,
        payload: {'route': 'fasting_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        weekday: 7, // Sunday
        hour: 20,
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    // تذكير صيام الخميس (يوم الأربعاء الساعة 8 مساءً)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 702,
        channelKey: 'sabah_athkar_channel',
        title: 'تذكير صيام الخميس',
        body: 'غداً يوم الخميس، تذكير بصيام يوم في سبيل الله',
        category: NotificationCategory.Reminder,
        payload: {'route': 'fasting_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        weekday: 3, // Wednesday
        hour: 20,
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // ==========================================
  // 🕌 سنن الجمعة
  // ==========================================
  Future<void> _scheduleFridayReminders() async {
    // 📖 قراءة سورة الكهف (الجمعة 9 صباحاً)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 801,
        channelKey: 'quran_channel',
        title: 'سورة الكهف',
        body:
            'قال ﷺ: «من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين»',
        category: NotificationCategory.Reminder,
        payload: {'route': 'kahf_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        weekday: 5, // Friday
        hour: 9,
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    // 🤲 ساعة الاستجابة (الجمعة 4:30 عصراً)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 802,
        channelKey: 'sabah_athkar_channel',
        title: 'ساعة الاستجابة',
        body:
            'في يوم الجمعة ساعة لا يسأل الله أحد فيها شيئا وهو قائم يصلي إلا أعطاه الله إياه',
        category: NotificationCategory.Reminder,
        payload: {'route': 'friday_hour_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        weekday: 5, // Friday
        hour: 16,
        minute: 30,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // ==========================================
  // ⚪ تذكير الأيام البيض (13، 14، 15 هجرياً)
  // ==========================================
  Future<void> _scheduleWhiteDaysReminders() async {
    try {
      final now = DateTime.now();
      final currentHijri = hijri.HijriCalendar.fromDate(now);

      // We want to schedule for 13, 14, 15 of current month
      // AND 13, 14, 15 of next month to ensure we always have 3-6 scheduled
      List<int> monthsToSchedule = [currentHijri.hMonth];
      if (currentHijri.hMonth == 12) {
        monthsToSchedule.add(1);
      } else {
        monthsToSchedule.add(currentHijri.hMonth + 1);
      }

      int notificationIdBase = 900;
      int count = 0;

      for (int hMonth in monthsToSchedule) {
        int hYear = currentHijri.hYear;
        if (hMonth < currentHijri.hMonth) hYear++;

        for (int hDay in [13, 14, 15]) {
          final hDate = hijri.HijriCalendar();
          final gregDate = hDate.hijriToGregorian(hYear, hMonth, hDay);
          // Reminder on the evening BEFORE (8 PM)
          final reminderDate =
              DateTime(gregDate.year, gregDate.month, gregDate.day)
                  .subtract(const Duration(hours: 4)); // 8 PM of previous day

          if (reminderDate.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: notificationIdBase + count,
                channelKey: 'sabah_athkar_channel',
                title: 'صيام الأيام البيض',
                body:
                    'غداً يوم ${hDate.hDay} $hMonth، نذكركم بصيام الأيام البيض',
                category: NotificationCategory.Reminder,
                payload: {'route': 'white_days_reminder'},
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
              ),
              schedule: NotificationCalendar.fromDate(
                date: reminderDate,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
            count++;
          }
        }
      }
      logger.i('✅ Scheduled $count White Days reminders.');
    } catch (e) {
      logger.e('❌ Error scheduling White Days reminders: $e');
    }
  }

  // ==========================================
  // ✨ المناسبات الإسلامية
  // ==========================================
  Future<void> _scheduleReligiousOccasions() async {
    try {
      final now = DateTime.now();
      final currentHijri = hijri.HijriCalendar.fromDate(now);

      // List of annual occasions (Month, Day, Title, Virtue/Info)
      final occasions = [
        [1, 1, 'رأس السنة الهجرية', 'بداية عام هجري جديد، فرصة لتجديد النية'],
        [
          1,
          10,
          'يوم عاشوراء',
          'قال ﷺ: صيام يوم عاشوراء أحتسب على الله أن يكفر السنة التي قبله'
        ],
        [
          3,
          12,
          'المولد النبوي الشريف',
          'ذكرى مولد سيد الخلق ﷺ، فرصة للإكثار من الصلاة عليه'
        ],
        [7, 27, 'الإسراء والمعراج', 'معجزة النبي ﷺ ورحلته المباركة'],
        [8, 15, 'ليلة النصف من شعبان', 'ليلة ترفع فيها الأعمال إلى الله'],
        [9, 1, 'بداية شهر رمضان', 'شهر الرحمة والمغفرة والعتق من النار'],
        [10, 1, 'عيد الفطر المبارك', 'عيد المسلمين، شكر لله على تمام الصيام'],
        [
          12,
          9,
          'يوم عرفة',
          'قال ﷺ: صيام يوم عرفة أحتسب على الله أن يكفر السنة التي قبله والسنة التي بعده'
        ],
        [12, 10, 'عيد الأضحى المبارك', 'يوم النحر، أعظم الأيام عند الله'],
      ];

      int notificationIdBase = 1000;
      int count = 0;

      for (var occasion in occasions) {
        int hMonth = occasion[0] as int;
        int hDay = occasion[1] as int;
        String title = occasion[2] as String;
        String body = occasion[3] as String;

        int hYear = currentHijri.hYear;
        // If the occasion already passed this year, schedule for next year
        if (hMonth < currentHijri.hMonth ||
            (hMonth == currentHijri.hMonth && hDay < currentHijri.hDay)) {
          hYear++;
        }

        final hDate = hijri.HijriCalendar();
        final gregDate = hDate.hijriToGregorian(hYear, hMonth, hDay);
        // Remind at 8 AM on the day of occasion
        final reminderDate =
            DateTime(gregDate.year, gregDate.month, gregDate.day, 8, 0);

        if (reminderDate.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: notificationIdBase + count,
              channelKey: 'sabah_athkar_channel',
              title: title,
              body: body,
              category: NotificationCategory.Reminder,
              payload: {
                'route': 'religious_occasion_reminder',
                'title': title,
                'body': body
              },
              largeIcon: 'resource://drawable/ic_stat_logoapp',
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
            ),
            schedule: NotificationCalendar.fromDate(
              date: reminderDate,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
          );
          count++;
        }
      }
      logger.i('✅ Scheduled $count religious occasion reminders.');
    } catch (e) {
      logger.e('❌ Error scheduling religious occasions: $e');
    }
  }

  // ==========================================
  // 🌕 سورة الملك
  // ==========================================
  Future<void> _scheduleMulkReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1100,
        channelKey: 'quran_channel',
        title: 'سورة الملك',
        body:
            'قال النبي ﷺ عن سورة الملك: هي المانعة، هي المنجية، تنجيه من عذاب القبر',
        category: NotificationCategory.Reminder,
        payload: {'route': 'mulk_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        hour: 22, // 10 PM
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // ==========================================
  // ☀️ صلاة الضحى
  // ==========================================
  Future<void> _scheduleDuhaReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1101,
        channelKey: 'sabah_athkar_channel',
        title: 'صلاة الضحى',
        body:
            'يصبح على كل سلامى من أحدكم صدقة.. ويجزئ من ذلك ركعتان يركعهما من الضحى',
        category: NotificationCategory.Reminder,
        payload: {'route': 'duha_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        hour: 9, // 9 AM
        minute: 30,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // ==========================================
  // 💡 سنة اليوم
  // ==========================================
  Future<void> _scheduleSunnahReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1102,
        channelKey: 'sabah_athkar_channel',
        title: 'سنة اليوم',
        body: 'إحياء سنة من سنن المصطفى ﷺ، اضغط لتتعرف على سنة اليوم',
        category: NotificationCategory.Reminder,
        payload: {'route': 'sunnah_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        hour: 12, // 12 PM
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // ==========================================
  // 🤲 الدعاء بين الأذان والإقامة
  // ==========================================
  Future<void> _scheduleBetweenAdhanIqamah() async {
    // We'll schedule a single general reminder for now, as precise tracking of 5 prayers is complex here
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1103,
        channelKey: 'sabah_athkar_channel',
        title: 'الدعاء بين الأذان والإقامة',
        body: 'قال ﷺ: لا يُرد الدعاء بين الأذان والإقامة؛ فادعوا',
        category: NotificationCategory.Reminder,
        payload: {'route': 'adhan_iqamah_reminder'},
        largeIcon: 'resource://drawable/ic_stat_logoapp',
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF178B74),
      ),
      schedule: NotificationCalendar(
        hour: 18, // 6 PM (Common time for Maghrib/Isha gap)
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> scheduleWirdReminder(
      String wirdId, String wirdName, String timeStr, String frequency) async {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Generate a unique ID from the wirdId (hashcode logic)
      final notificationId = wirdId.hashCode.abs() % 100000;

      NotificationSchedule? schedule;

      if (frequency == 'daily') {
        schedule = NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
        );
      } else if (frequency == 'weekly') {
        final now = DateTime.now();
        schedule = NotificationCalendar(
          weekday: now.weekday,
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
        );
      } else if (frequency == 'monthly') {
        final now = DateTime.now();
        schedule = NotificationCalendar(
          day: now.day,
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
        );
      } else {
        // Once
        final now = DateTime.now();
        var scheduledDate =
            DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        schedule = NotificationCalendar.fromDate(
          date: scheduledDate,
          preciseAlarm: true,
          allowWhileIdle: true,
        );
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'sabah_athkar_channel', // نستخدم قناة الأذكار العامة
          title: 'حان وقت وردك',
          body: 'تذكير بقراءة ورد: $wirdName',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF178B74),
        ),
        schedule: schedule,
      );
      logger
          .i('✅ تم جدولة تذكير الورد ($wirdName) الساعة $timeStr - $frequency');
    } catch (e) {
      logger.e('❌ خطأ في جدولة تذكير الورد: $e');
    }
  }

  // ==========================================
  // 🗓️ تذكيرات التقويم
  // ==========================================

  Future<void> scheduleCalendarReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (scheduledDate.isBefore(DateTime.now())) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'calendar_reminders_channel',
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          payload: {'route': 'calendar_screen'},
          largeIcon: 'resource://drawable/ic_stat_logoapp',
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF178B74),
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      logger.i('✅ تم جدولة تذكير التقويم: $title في $scheduledDate');
    } catch (e) {
      logger.e('❌ خطأ في جدولة تذكير التقويم: $e');
    }
  }

  Future<void> cancelCalendarReminder(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // ==========================================
  // 🕌 جدولة الأذان (منقول من main.dart)
  // ==========================================

  // ==========================================
  // 🕋 تذكيرات الختمة الجماعية
  // ==========================================

  Future<void> scheduleCommunityKhatmahReminder({
    required int index,
    required String label,
  }) async {
    try {
      // Reminder after 2 hours
      final scheduledDate = DateTime.now().add(const Duration(hours: 2));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10000 + index, // Unique ID range for Khatmah items
          channelKey: 'quran_channel',
          title: 'تذكير بالختمة الجماعية',
          body:
              'هل قرأت $label؟ لا تنسَ إتمام الورد المحجوز لتفسح المجال لغيرك.',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          payload: {'route': 'global_khatmah'},
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      logger.i('✅ تم جدولة تذكير الختمة للورد $index بعد ساعتين');
    } catch (e) {
      logger.e('❌ خطأ في جدولة تذكير الختمة: $e');
    }
  }

  Future<void> cancelCommunityKhatmahReminder(int index) async {
    try {
      await AwesomeNotifications().cancel(10000 + index);
      logger.i('✅ تم إلغاء تذكير الختمة للورد $index');
    } catch (e) {
      logger.e('❌ خطأ في إلغاء تذكير الختمة: $e');
    }
  }

  // --- Static Listeners ---

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // print('🔔 Notification Created: ${receivedNotification.id}');
    // ⚠️ DO NOT push overlay here. It triggers immediately on schedule.
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    logger.i('📱 Notification Displayed: ${receivedNotification.id}');

    final route = receivedNotification.payload?['route'];
    if (route == 'adhan_screen') {
      // Small delay to ensure Flutter's navigator is ready
      await Future.delayed(const Duration(milliseconds: 300));

      final navigator = CentralizedCubit.navigatorKey.currentState;
      if (navigator != null) {
        // Show the adhan overlay screen whenever notification fires
        // (whether app is in foreground, background, or locked screen)
        navigator.push(MaterialPageRoute(
          builder: (_) => AdhanOverlayScreen(
            prayerName: receivedNotification.payload?['prayerName'],
            cityName: receivedNotification.payload?['cityName'],
            prayerTime: receivedNotification.payload?['prayer_time'],
          ),
        ));
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // print('📱 Notification Dismissed: ${receivedAction.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    logger.i('🎯 Notification Clicked: ${receivedAction.payload}');

    final navigator = CentralizedCubit.navigatorKey.currentState;
    if (navigator == null) return;

    final route = receivedAction.payload?['route'] ?? '';

    switch (route) {
      case 'morning_athkar':
        navigator.push(MaterialPageRoute(builder: (_) => const AzkarSabah()));
        break;
      case 'evening_athkar':
        navigator.push(MaterialPageRoute(builder: (_) => const AzkarMassa()));
        break;
      case 'quran_wird':
        navigator.push(MaterialPageRoute(builder: (_) => const QuranView()));
        break;
      case 'daily_hadith':
        navigator.push(MaterialPageRoute(builder: (_) => const HadithView()));
        break;
      case 'sleep_athkar':
        navigator.push(MaterialPageRoute(builder: (_) => const SleepAzkar()));
        break;
      case 'qiyam_reminder':
        navigator.push(MaterialPageRoute(builder: (_) => const QuranView()));
        break;
      case 'salawat':
        navigator.push(MaterialPageRoute(builder: (_) => const MainView()));
        break;
      case 'charity_dashboard':
        navigator.push(
            MaterialPageRoute(builder: (_) => const CharityDashboardScreen()));
        break;
      case 'adhan_screen':
        // Check if overlay is enabled in settings
        final settings = SettingsService();
        await settings.init();
        if (settings.isAdhanOverlayEnabled) {
          navigator.push(MaterialPageRoute(
            builder: (_) => AdhanOverlayScreen(
              prayerName: receivedAction.payload?['prayerName'],
              cityName: receivedAction.payload?['cityName'],
              prayerTime: receivedAction.payload?['prayer_time'],
            ),
          ));
        }
        break;
      case 'global_khatmah':
        navigator.push(
            MaterialPageRoute(builder: (_) => const GlobalKhatmahScreen()));
        break;
      case 'achievements':
        navigator.push(
            MaterialPageRoute(builder: (_) => const AchievementsScreen()));
        break;
      case 'calendar_screen':
        navigator
            .push(MaterialPageRoute(builder: (_) => const CalendarScreen()));
        break;
      case 'allazkarlistview':
        navigator
            .push(MaterialPageRoute(builder: (_) => const Allazkarlistview()));
        break;
      case 'STOP_ADHAN':
      case 'MUTE_ADHAN':
        // These are DismissActions, but we can explicitly stop audio here if needed.
        // For now, they will dismiss the notification.
        logger.i('🛑 Adhan Stopped/Muted by user.');
        break;

      // New Routes
      case 'fasting_reminder':
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => NotificationDialogScreen(
              title: 'فضل الصيام',
              content:
                  '1. عن سَهلٍ رَضِيَ الله تعالى عنه أنَّ النَّبيَّ صلَّى اللهُ عليه وسلَّم قال: ((إنَّ في الجنَّةِ بابًا يقال له: الريَّانُ، يدخُلُ منه الصَّائِمونَ يومَ القيامةِ، لا يدخُلُ منه أحدٌ غَيرُهم. فيقال: أين الصَّائِمونَ؟ فيقومونَ، لا يدخُلُ منه أحدٌ غَيرُهم، فإذا دخَلُوا أُغلِقَ، فلم يدخُلْ منه أحدٌ ))\n\n'
                  '2. عن أبي سعيدٍ رَضِيَ الله تعالى عنه، عن النبيِّ صلَّى اللهُ عليه وسلَّم أنَّه قال: ((من صام يومًا في سبيلِ الله، باعَدَ اللهُ وَجهَه عن النَّارِ سَبعينَ خريفًا ))',
            ),
          ),
        );
        break;

      case 'kahf_reminder':
        // Open Quran at Page 293 (Surah Al-Kahf start page in standard Mushaf)
        navigator.push(MaterialPageRoute(
            builder: (_) => const QuranView(initialPage: 293)));
        break;

      case 'friday_hour_reminder':
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const NotificationDialogScreen(
              title: 'دعاء ساعة الاستجابة',
              content:
                  'اللَّهُمَّ رَبَّ السَّمَوَاتِ وَرَبَّ الأرْضِ وَرَبَّ العَرْشِ العَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شيءٍ، فَالِقَ الحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بكَ مِن شَرِّ كُلِّ شيءٍ أَنْتَ آخِذٌ بنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الأوَّلُ فليسَ قَبْلَكَ شيءٌ، وَأَنْتَ الآخِرُ فليسَ بَعْدَكَ شيءٌ، وَأَنْتَ الظَّاهِرُ فليسَ فَوْقَكَ شيءٌ، وَأَنْتَ البَاطِنُ فليسَ دُونَكَ شيءٌ، اقْضِ عَنَّا الدَّيْنَ، وَأَغْنِنَا مِنَ الفَقْرِ.\n\n'
                  'أسألك اللهم إن كان رزقي في السماء فأنزله، وإن كان في الأرض فأخرجه، وأسألك برحمتك إن كان رزقي بعيدًا فقربه، وإن كان قريبًا فيسره، وإن كان قليلًا فكثره، وإن كان كثيرًا، فبارك لي فيه. اللهم اكفني بحلالك عن حرامك، وأغنني بفضلك عمن سواك. اللهم يا رازق السائلين، ويا ذا القوة المتين، يا غياث المستغيثين، أسألك رزقًا واسعًا طيبًا من رزقك. يا راحم المساكين، ويا ذا القوة المتين، ويا خير الناصرين، يا ولي المؤمنين، يا غيّاث المستغيثين، إياك نعبد وإيّاك نستعين، اللهم إني أسألك رزقًا واسعًا طيبًا.',
            ),
          ),
        );
        break;

      case 'white_days_reminder':
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const NotificationDialogScreen(
              title: 'فضل صيام الأيام البيض',
              content:
                  'عن جرير بن عبد الله رضي الله عنه عن النبي صلى الله عليه وسلم قال: «صيام ثلاثة أيام من كل شهر صيام الدهر، وأيام البيض صبيحة ثلاث عشرة وأربع عشرة وخمس عشرة» (رواه النسائي)\n\n'
                  'وعن أبي هريرة رضي الله عنه قال: «أوصاني خليلي صلى الله عليه وسلم بثلاث: صيام ثلاثة أيام من كل شهر، وركعتي الضحى، وأن أوتر قبل أن أنام» (متفق عليه)',
            ),
          ),
        );
        break;

      case 'mulk_reminder':
        // Surah Al-Mulk is on page 562
        navigator.push(MaterialPageRoute(
            builder: (_) => const QuranView(initialPage: 562)));
        break;

      case 'duha_reminder':
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const NotificationDialogScreen(
              title: 'فضل صلاة الضحى',
              content:
                  'قال رسول الله ﷺ: «يُصْبِحُ علَى كُلِّ سُلَامَى مِن أَحَدِكُمْ صَدَقَةٌ، فَكُلُّ تَسْبِيحَةٍ صَدَقَةٌ، وَكُلُّ تَحْمِيدَةٍ صَدَقَةٌ، وَكُلُّ تَهْلِيلَةٍ صَدَقَةٌ، وَكُلُّ تَكْبِيرَةٍ صَدَقَةٌ، وَأَمْرٌ بالمَعْرُوفِ صَدَقَةٌ، وَنَهْيٌ عَنِ المُنْكَرِ صَدَقَةٌ، وَيُجْزِئُ مِن ذلكَ رَكْعَتَانِ يَرْكَعُهُما مِنَ الضُّحَى» (رواه مسلم)',
            ),
          ),
        );
        break;

      case 'sunnah_reminder':
        // We can pick a random Sunnah or just show a high-quality selection
        final sunnahs = [
          'تبسمك في وجه أخيك لك صدقة',
          'البدء بالسلام قبل الكلام',
          'النوم على طهارة وعلى الجانب الأيمن',
          'التسمية قبل الأكل والأكل باليمين ومما يليك',
          'نفض الفراش قبل النوم',
          'الدعاء عند لبس الثوب الجديد',
        ];
        final randomSunnah =
            sunnahs[DateTime.now().millisecond % sunnahs.length];

        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => NotificationDialogScreen(
              title: 'سنة اليوم',
              content:
                  'سنة اليوم هي: $randomSunnah\n\nقال ﷺ: «من سنَّ في الإسلام سنةً حسنةً فله أجرها وأجر من عمل بها بعده من غير أن ينقص من أجورهم شيء»',
            ),
          ),
        );
        break;

      case 'adhan_iqamah_reminder':
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const NotificationDialogScreen(
              title: 'الدعاء بين الأذان والإقامة',
              content:
                  'عن أنس بن مالك رضي الله عنه قال: قال رسول الله ﷺ: «لا يُردُّ الدَّعاءُ بينَ الأذانِ والإقامةِ» (رواه الترمذي)\n\n'
                  'اغتنم هذه اللحظات المباركة في التضرع إلى الله وسؤاله من فضله العظيم.',
            ),
          ),
        );
        break;

      case 'religious_occasion_reminder':
        final title = receivedAction.payload?['title'] ?? 'مناسبة إسلامية';
        final body = receivedAction.payload?['body'] ?? '';
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => NotificationDialogScreen(
              title: title,
              content: body,
            ),
          ),
        );
        break;
    }
  }

  Future<void> scheduleBasicSystemTest() async {
    // print('Scheduling basic system test (no custom sound)...');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 8888,
          channelKey: 'quran_channel', // Simple channel
          title: '🔔 اختبار النظام',
          body: 'هذا إشعار تجريبي باستخدام صوت النظام الافتراضي.',
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar.fromDate(
          date: DateTime.now().add(const Duration(seconds: 5)),
        ),
      );
      // print('✅ Basic system test scheduled.');
    } catch (e) {
      logger.e('❌ Error scheduling basic test: $e');
    }
  }
}
