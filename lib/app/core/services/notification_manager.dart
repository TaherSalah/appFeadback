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
import 'package:muslimdaily/app/features/azanView/adhan_workmanager_service.dart';
import 'package:muslimdaily/app/features/azanView/view/adhan_overlay_screen.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final SettingsService _settingsService = SettingsService();

  Future<void> initialize() async {
    await _settingsService.init();

    await updateAllChannels();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    await AwesomeNotifications().isNotificationAllowed().then((allowed) {
      if (!allowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // 🚀 تهيئة خدمة الأذان (التي ستقوم بدورها بتحديث القنوات بالأصوات المختارة)
    await AdhanWorkManagerService().initialize();
  }

  static Future<void> updateAllChannels() async {
    final fajrPath = await AdhanWorkManagerService().getAdhanPath('fajr');
    final normalPath = await AdhanWorkManagerService().getAdhanPath('normal');

    await AwesomeNotifications().initialize(
      Platform.isAndroid ? 'resource://drawable/ic_stat_logoapp' : null,
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
          locked: true,
          criticalAlerts: true,
        ),

        // 📿 قناة الأذكار والتذكيرات
        NotificationChannel(
          channelKey: 'sabah_athkar_channel',
          channelName: '🌅 أذكار الصباح',
          channelDescription: 'حان وقت أذكار الصباح',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          soundSource:
              Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),

        NotificationChannel(
          channelKey: 'mesaa_athkar_channel',
          channelName: '🌙 أذكار المساء',
          channelDescription: 'تذكير أذكار المساء',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          soundSource:
              Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),

        NotificationChannel(
          channelKey: 'sleep_athkar_channel',
          channelName: '😴 أذكار النوم',
          channelDescription: 'تذكير أذكار النوم',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          soundSource:
              Platform.isAndroid ? 'resource://raw/tasbihat' : 'tasbihat.mp3',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),

        NotificationChannel(
          channelKey: 'qiam_channel',
          channelName: '🌙 قيام الليل',
          channelDescription: 'وقت قيام الليل',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          soundSource: Platform.isAndroid ? 'resource://raw/qiam' : 'qiam.mp3',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),

        // 🤲 قناة الصلاة على النبي
        NotificationChannel(
          channelKey: 'salawat_channel',
          channelName: 'الصلاة على النبي',
          channelDescription: 'تذكير بالالصلاة على النبي',
          importance: NotificationImportance.High,
          defaultColor: Colors.teal,
          ledColor: Colors.teal,
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
          defaultColor: Colors.purple,
          ledColor: Colors.purple,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        // 🤲 قناة أذكار بعد الصلاة
        NotificationChannel(
          channelKey: 'post_prayer_dhikr_channel',
          channelName: 'أذكار بعد الصلاة',
          channelDescription: 'تذكير بأذكار ما بعد الصلاة',
          importance: NotificationImportance.High,
          defaultColor: Colors.green,
          ledColor: Colors.green,
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
          defaultColor: Colors.amber,
          ledColor: Colors.amber,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        // 💰 قناة تذكير الزكاة
        NotificationChannel(
          channelKey: 'zakat_reminder_channel',
          channelName: 'تذكير الزكاة',
          channelDescription: 'تذكير بمرور الحول على الزكاة',
          importance: NotificationImportance.High,
          defaultColor: Colors.green,
          ledColor: Colors.green,
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
          defaultColor: Colors.green,
          ledColor: Colors.green,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        // 🏆 قناة الإنجازات
        NotificationChannel(
          channelKey: 'achievement_unlocked_channel',
          channelName: 'إنجازات الصدقة',
          channelDescription: 'إشعارات عند فتح إنجاز جديد في قسم الصدقة',
          importance: NotificationImportance.High,
          defaultColor: Colors.amber,
          ledColor: Colors.amber,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        // 🗓️ قناة تذكير التقويم
        NotificationChannel(
          channelKey: 'calendar_reminders_channel',
          channelName: 'تذكير التقويم',
          channelDescription: 'تنبيهات للمناسبات والأحداث الخاصة في التقويم',
          importance: NotificationImportance.High,
          defaultColor: Colors.purple,
          ledColor: Colors.purple,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      debug: true,
    );
  }

  Future<bool> checkAndRequestExactAlarmPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
    }
    return isAllowed;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      await AwesomeNotifications().showAlarmPage();
    }
  }

  Future<void> scheduleInstantTestNotification() async {
    DateTime testTime = DateTime.now().add(const Duration(seconds: 10));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9999,
        channelKey: 'fajr_adhan_channel_v4',
        title: '🔔 اختبار فوري',
        body: 'إذا وصلك هذا الصوت، فنظام المنبهات يعمل بنجاح!',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
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
    print('🔄 Rescheduling all notifications based on settings...');

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
    await AdhanWorkManagerService().initialize(forceReschedule: force);

    print('✅ Reschedule completed.');
  }

  Future<void> _setupDailyReminders() async {
    try {
      // 🌅 أذكار الصباح
      if (_settingsService.isAzkarSabahEnabled) {
        await _scheduleDailyNotification(
          id: 1,
          channelKey: 'sabah_athkar_channel',
          title: '🌅 أذكار الصباح',
          body: 'حان وقت أذكار الصباح، بارك الله في صباحك',
          hour: 9,
          minute: 0,
          payload: {'route': 'morning_athkar'},
        );
      }

      // 🌙 أذكار المساء
      if (_settingsService.isAzkarMassaEnabled) {
        await _scheduleDailyNotification(
          id: 2,
          channelKey: 'mesaa_athkar_channel',
          title: '🌙 أذكار المساء',
          body: 'حان وقت أذكار المساء، جعل الله مساءك مباركاً',
          hour: 18,
          minute: 0,
          payload: {'route': 'evening_athkar'},
        );
      }

      // 📖 ورد القرآن (Always on for now, or add setting later)
      await _scheduleDailyNotification(
        id: 3,
        channelKey: 'quran_channel',
        title: '📖 ورد القرآن اليومي',
        body: 'لا تنسَ وردك اليومي من القرآن الكريم',
        hour: 20,
        minute: 0,
        payload: {'route': 'quran_wird'},
      );

      // 📿 حديث اليوم (متجدد يومياً)
      // await _scheduleHadithSeries(); // Old way
      await scheduleHadithSeries();

      // 😴 أذكار النوم
      if (_settingsService.isAzkarSleepEnabled) {
        await _scheduleDailyNotification(
          id: 6,
          channelKey: 'sleep_athkar_channel',
          title: '😴 أذكار النوم',
          body: 'حان وقت أذكار النوم، تصبح على خير',
          hour: 22,
          minute: 0,
          payload: {'route': 'sleep_athkar'},
        );
      }

      // 🌙 قيام الليل
      if (_settingsService.isQiyamEnabled) {
        await _scheduleDailyNotification(
          id: 7,
          channelKey: 'qiam_channel',
          title: '🌙 قيام الليل',
          body: 'وقت قيام الليل، تقبل الله طاعاتكم',
          hour: 23,
          minute: 0,
          payload: {'route': 'qiyam_reminder'},
        );
      }

      // 🤲 الصلاة على النبي
      if (_settingsService.isSalatAlaNabiEnabled) {
        await _scheduleSalawat();
      }

      // ⏰ منبه الفجر المتقدم
      await _scheduleAdvancedFajrAlarm();
    } catch (e, stackTrace) {
      print('❌ Error in scheduling reminders: $e');
      print(stackTrace);
    }
  }

  // ==========================================
  // 📅 جدولة الأحاديث (منقول من main.dart)
  // ==========================================
  Future<void> scheduleHadithSeries() async {
    try {
      print("📅 جاري جدولة سلسلة الأحاديث لـ 30 يوماً...");

      // 1️⃣ إلغاء الجدولة القديمة للأحاديث
      await AwesomeNotifications()
          .cancelSchedulesByChannelKey('hadith_channel');

      final now = DateTime.now();
      // ⏰ وقت الحديث: 11 صباحاً كل يوم
      DateTime baselineTime = DateTime(now.year, now.month, now.day, 11, 0);

      if (baselineTime.isBefore(now)) {
        baselineTime = baselineTime.add(const Duration(days: 1));
      }

      // 2️⃣ جدولة حديث مختلف لكل يوم لمدة 30 يوم
      for (int i = 0; i < 30; i++) {
        final scheduledDate = baselineTime.add(Duration(days: i));
        // اختيار حديث من القائمة
        final hadithText = dailyHadiths[i % dailyHadiths.length];

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 500 + i,
            channelKey: 'hadith_channel', // تأكد من وجود هذه القناة
            title: '\u200F📖 حديث اليوم',
            body: '\u200F$hadithText',
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Reminder,
            payload: {'route': 'daily_hadith'},
          ),
          schedule: NotificationCalendar.fromDate(
            date: scheduledDate,
            allowWhileIdle: true,
            preciseAlarm: true,
          ),
        );
      }
      print("✅ تم جدولة الأحاديث بنجاح");
    } catch (e) {
      print("❌ خطأ في جدولة الأحاديث: $e");
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
        icon: 'resource://mipmap/launcher_icon',
        id: id,
        channelKey: channelKey,
        title: '\u200F$title',
        body: '\u200F$body',
        notificationLayout: NotificationLayout.Default,
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
    int minutes = _settingsService.getSalatAlaNabiMinutes();
    print('Scheduling Salawat every $minutes minutes');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888, // Constant ID for the repeating schedule
        channelKey: 'salawat_channel',
        icon: 'resource://mipmap/launcher_icon',
        title: 'ﷺ',
        body: 'اللهم صل وسلم على نبينا محمد',
        notificationLayout: NotificationLayout.Default,
        payload: {'route': 'salawat'},
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
    await _settingsService.init();
    await _scheduleAdvancedFajrAlarm();
  }

  Future<void> _scheduleAdvancedFajrAlarm() async {
    // 1. Cancel existing advanced fajr alarms
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');

    if (!_settingsService.isFajrAlarmEnabled) {
      print("🔕 Advanced Fajr Alarm is DISABLED.");
      return;
    }

    final hour = _settingsService.fajrAlarmHour;
    final minute = _settingsService.fajrAlarmMinute;
    final days = _settingsService.fajrAlarmDays; // 1-7 (Mon-Sun)
    final repetitions = _settingsService.fajrAlarmRepetitions;

    // Default 5 minutes interval, but we could make it settings based later
    const int intervalMinutes = 5;

    print(
        '🕒 Scheduling Advanced Fajr Alarm at $hour:$minute for days: $days with $repetitions repetitions (Interval: ${intervalMinutes}m)');

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
            title: '⏰ منبه الفجر المتقدم',
            body: r == 0
                ? 'حان وقت الاستيقاظ لصلاة الفجر 👋'
                : 'تذكير إضافي: صلاة الفجر خير من النوم 🕌', // Different body for snoozes
            category: NotificationCategory.Alarm,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            autoDismissible: true, // User must dismiss it
            locked: false, // Requires interaction
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
        print(
            "✅ Scheduled Alarm ID: $uniqueId for Day: $day at $finalHour:$finalMinute");
      }
    }
    print('✅ All Advanced Fajr Alarms scheduled successfully.');
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
          title: '📿 حان وقت وردك',
          body: 'تذكير بقراءة ورد: $wirdName',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: schedule,
      );
      print('✅ تم جدولة تذكير الورد ($wirdName) الساعة $timeStr - $frequency');
    } catch (e) {
      print('❌ خطأ في جدولة تذكير الورد: $e');
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
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      print('✅ تم جدولة تذكير التقويم: $title في $scheduledDate');
    } catch (e) {
      print('❌ خطأ في جدولة تذكير التقويم: $e');
    }
  }

  Future<void> cancelCalendarReminder(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // ==========================================
  // 🕌 جدولة الأذان (منقول من main.dart)
  // ==========================================

  Future<void> scheduleAzan(DateTime prayerTime, String prayerName) async {
    try {
      final channelKey =
          prayerName == 'الفجر' ? 'fajr_adhan_channel_v4' : 'adhan_channel_v4';

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: prayerTime.millisecondsSinceEpoch % 100000,
          channelKey: channelKey,
          title: 'حان الآن وقت $prayerName',
          body: 'الله أكبر الله أكبر',
          notificationLayout: NotificationLayout.Default,
          criticalAlert: true,
          wakeUpScreen: true,
          fullScreenIntent: true,
          payload: {'prayer': prayerName},
        ),
        schedule: NotificationCalendar.fromDate(
          date: prayerTime,
          preciseAlarm: true,
        ),
      );
      print('✅ تم جدولة أذان $prayerName: ${prayerTime.toString()}');
    } catch (e) {
      print('❌ خطأ في جدولة أذان $prayerName: $e');
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
    print('📱 Notification Displayed: ${receivedNotification.id}');

    // Check if this is an Adhan notification with route
    final route = receivedNotification.payload?['route'];
    if (route == 'adhan_screen') {
      // Check if overlay is enabled
      final settings = SettingsService();
      await settings.init();

      if (settings.isAdhanOverlayEnabled) {
        final navigator = CentralizedCubit.navigatorKey.currentState;
        if (navigator != null) {
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
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // print('📱 Notification Dismissed: ${receivedAction.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('🎯 Notification Clicked: ${receivedAction.payload}');

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
    }
  }

  Future<void> scheduleBasicSystemTest() async {
    print('Scheduling basic system test (no custom sound)...');
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
      print('✅ Basic system test scheduled.');
    } catch (e) {
      print('❌ Error scheduling basic test: $e');
    }
  }
}
