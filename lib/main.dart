// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
//
//

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // ← أول سطر دائمًا
//   await QuranLibrary.init();
//
//   // تهيئة خدمة الإشعارات
//   await NotificationService().initialize();
//   // تهيئة خدمة الأذان مع WorkManager
//   await AdhanWorkManagerService().initialize();
//   // جدولة الإشعارات الافتراضية
//   await _setupDefaultNotifications();
//   // SystemChrome و أي platform channels لازم بعد ensureInitialized
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.dark,
//     systemNavigationBarColor: Colors.transparent,
//   ));
//
//   // await Workmanager().initialize(
//   //   callbackDispatcher,      // ← دي واحدة فقط من الملف اللي فوق
//   //   isInDebugMode: false,
//   // );
//   HijriCalendar.setLocal('ar_SA');
//   // لو عندك DI بيتعامل مع ملفات/قنوات منصة، خلّيه بعد ensureInitialized
//   await Di.init();
//
//   // Intl dates
//   await initializeDateFormatting();
//   await initializeDateFormatting('ar', null);
//   await initializeDateFormatting('en', null);
//
//   await SharedObj().init();
//
//   // مكتبتك
//   // QuranLibrary().initTafsir();
//
//   // Hive
//   await Hive.initFlutter();
//   if (!Hive.isAdapterRegistered(0)) {
//     Hive.registerAdapter(KhatmahModelAdapter());
//   }
//
//   await Hive.openBox<KhatmahModel>('khatmahBox');
//
//   if (!Hive.isBoxOpen('khatmahBox')) {
//     await Hive.openBox<KhatmahModel>('khatmahBox');
//   }
//   if (!Hive.isBoxOpen('khatmahPlans')) {
//     await Hive.openBox('khatmahPlans');
//   }
//
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//       .then((_) {
//     runApp(
//         // DevicePreview(
//         //   enabled: !kReleaseMode,
//         //   builder: (context) => YaqeesApp(), // Wrap your app
//         // ),
//
//         BlocProvider<CentralizedCubit>(
//             create: (context) =>
//                 CentralizedCubit(sharedPreferences: Di.sharedPreferences)
//                   ..localization(),
//             child: BlocBuilder<CentralizedCubit, CentralizedState>(
//               builder: (context, state) {
//                 return const MashkahApp();
//               },
//             )));
//   });
// }
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/features/hadith/hadith_view.dart';
import 'package:muslimdaily/app/features/main_view/MainView.dart';
import 'package:muslimdaily/app/features/messa_view/azkar_massa.dart';
import 'package:muslimdaily/app/features/quran/quranView.dart';
import 'package:muslimdaily/app/features/sabah_view/azkar_sabah.dart';
import 'package:muslimdaily/app/features/sleep_view/sleep_azkar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quran_library/quran.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/utils/services_locator.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
import 'app/features/azanView/adhan_workmanager_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrapper());
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  bool _isInitComplete = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      await _initAppServices();
      if (mounted) {
        setState(() => _isInitComplete = true);
      }
    } catch (e, s) {
      print('❌ خطأ في تهيئة التطبيق: $e\n$s');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text(
                    'حدث خطأ أثناء تشغيل التطبيق:\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitComplete) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.white,
              body: SplashItemBuilder(),
            ),
          );
        },
      );
    }

    return BlocProvider<CentralizedCubit>(
      create: (context) => CentralizedCubit(
        sharedPreferences: Di.sharedPreferences,
      )..localization(),
      child: BlocBuilder<CentralizedCubit, CentralizedState>(
        builder: (context, state) => const MashkahApp(),
      ),
    );
  }
}

Future<void> _initAppServices() async {
  // ✅ 1) تخصيصات النظام
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  // ✅ 2) تهيئة البيانات
  HijriCalendar.setLocal('ar_SA');
  await Di.init();
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await SharedObj().init();

  // ✅ 3) Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }
  await Hive.openBox<KhatmahModel>('khatmahBox');
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }

  // ✅ 4) تهيئة AwesomeNotifications أولاً قبل أي استخدام
  await _initializeAwesomeNotifications();

  // ✅ 5) AndroidAlarmManager
  await AndroidAlarmManager.initialize();

  // ✅ 6) خدمة الأذان
  await AdhanWorkManagerService().initialize();

  // ✅ 7) مكتبة القرآن
  await QuranLibrary.init();

  // ✅ 8) قفل التدوير
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ✅ 9) جدولة التذكيرات اليومية (بعد تهيئة AwesomeNotifications)
  await _setupDailyReminders();
}

// ═══════════════════════════════════════════════════════════
// ✅ تهيئة AwesomeNotifications مع جميع القنوات
// ═══════════════════════════════════════════════════════════
Future<void> _initializeAwesomeNotifications() async {
  try {
    await AwesomeNotifications().initialize(
      null,
      [
        // 🌅 قناة أذان الفجر
        NotificationChannel(
          channelKey: 'fajr_adhan_channel',
          channelName: 'أذان الفجر',
          channelDescription: 'تشغيل أذان الفجر',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/fajr',
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.orange,
          defaultPrivacy: NotificationPrivacy.Public,
          criticalAlerts: true,
        ),

        // 🕌 قناة الأذان العادي
        NotificationChannel(
          channelKey: 'adhan_channel',
          channelName: 'أذان الصلاة',
          channelDescription: 'تشغيل صوت الأذان',
          importance: NotificationImportance.Max,
          defaultColor: Colors.green,
          ledColor: Colors.green,
          playSound: true,
          soundSource: 'resource://raw/athan',
          enableVibration: true,
          enableLights: true,
          locked: true,
          criticalAlerts: true,
        ),

        // 📿 قناة الأذكار والتذكيرات
        NotificationChannel(
          channelKey: 'athkar_channel',
          channelName: 'الأذكار اليومية',
          channelDescription: 'تذكير بالأذكار اليومية',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
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
          defaultColor: Colors.teal,
          ledColor: Colors.teal,
          playSound: true,
          soundSource: 'resource://raw/athan',
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

        // 💰 قناة الزكاة
        NotificationChannel(
          channelKey: 'zakat_reminder_channel',
          channelName: 'تذكير الزكاة',
          channelDescription: 'تذكير سنوي لموعد الزكاة',
          importance: NotificationImportance.High,
          defaultColor: Colors.teal,
          ledColor: Colors.teal,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      debug: true, // ✅ فعّل debug للتأكد من القنوات
    );

    // ✅ إعداد المستمعين
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    // ✅ طلب الأذونات
    bool allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    print('✅ تم تهيئة AwesomeNotifications بنجاح');
  } catch (e, stackTrace) {
    print('❌ خطأ في تهيئة الإشعارات: $e');
    print('Stack Trace: $stackTrace');
    rethrow;
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ جدولة التذكيرات اليومية
// ═══════════════════════════════════════════════════════════
Future<void> _setupDailyReminders() async {
  try {
    // 🌅 أذكار الصباح - 9 صباحاً
    await _scheduleDailyNotification(
      id: 1,
      channelKey: 'athkar_channel',
      title: '🌅 أذكار الصباح',
      body: 'حان وقت أذكار الصباح، بارك الله في صباحك',
      hour: 9,
      minute: 0,
      payload: {'route': 'morning_athkar'},
    );

    // 🌙 أذكار المساء - 6 مساءً
    await _scheduleDailyNotification(
      id: 2,
      channelKey: 'athkar_channel',
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء، جعل الله مساءك مباركاً',
      hour: 18,
      minute: 0,
      payload: {'route': 'evening_athkar'},
    );

    // 📖 ورد القرآن - 8 مساءً
    await _scheduleDailyNotification(
      id: 3,
      channelKey: 'quran_channel',
      title: '📖 ورد القرآن اليومي',
      body: 'لا تنسَ وردك اليومي من القرآن الكريم',
      hour: 20,
      minute: 0,
      payload: {'route': 'quran_wird'},
    );

    // 📿 حديث اليوم - 12 ظهراً
    await _scheduleDailyNotification(
      id: 4,
      channelKey: 'hadith_channel',
      title: '📿 حديث اليوم',
      body: 'اطلع على الحديث الشريف لهذا اليوم',
      hour: 12,
      minute: 0,
      payload: {'route': 'daily_hadith'},
    );

    // 😴 أذكار النوم - 10 مساءً
    await _scheduleDailyNotification(
      id: 6,
      channelKey: 'athkar_channel',
      title: '😴 أذكار النوم',
      body: 'حان وقت أذكار النوم، تصبح على خير',
      hour: 22,
      minute: 0,
      payload: {'route': 'sleep_athkar'},
    );

    // 🌙 قيام الليل - 11 مساءً
    await _scheduleDailyNotification(
      id: 7,
      channelKey: 'athkar_channel',
      title: '🌙 قيام الليل',
      body: 'وقت قيام الليل، تقبل الله طاعاتكم',
      hour: 23,
      minute: 0,
      payload: {'route': 'qiyam_reminder'},
    );

    // 🤲 الصلاة على النبي - كل ساعة (أو كل دقيقة للاختبار)
    // await _scheduleHourlySalawat();
    await _scheduleMinutelySalawatTest(); // للاختبار فقط

    print('✅ تم جدولة جميع التذكيرات اليومية');
  } catch (e, stackTrace) {
    print('❌ خطأ في جدولة التذكيرات: $e');
    print('Stack Trace: $stackTrace');
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ دالة جدولة إشعار يومي متكرر
// ═══════════════════════════════════════════════════════════
Future<void> _scheduleDailyNotification({
  required int id,
  required String channelKey,
  required String title,
  required String body,
  required int hour,
  required int minute,
  Map<String, String>? payload,
}) async {
  try {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // إذا الوقت فات، جدّله بكره
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        icon: 'resource://mipmap/launcher_icon',
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: payload,
        criticalAlert: channelKey.contains('adhan'),
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        repeats: true, // ✅ يتكرر يومياً
        preciseAlarm: true,
      ),
    );

    print('✅ تم جدولة: $title في الساعة $hour:$minute');
  } catch (e) {
    print('❌ خطأ في جدولة $title: $e');
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ الصلاة على النبي - كل ساعة
// ═══════════════════════════════════════════════════════════
Future<void> _scheduleHourlySalawat() async {
  try {
    for (int hour = 0; hour < 24; hour++) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 100 + hour,
          channelKey: 'salawat_channel',
          title: 'ﷺ',
          body: 'اللهم صل وسلم على نبينا محمد',
          notificationLayout: NotificationLayout.Default,
          payload: {'route': 'salawat'},
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: 0,
          second: 0,
          repeats: true,
          preciseAlarm: true,
        ),
      );
    }
    print('✅ تم جدولة الصلاة على النبي كل ساعة');
  } catch (e) {
    print('❌ خطأ في جدولة الصلاة على النبي: $e');
  }
}

// 🧪 اختبار: كل دقيقة
Future<void> _scheduleMinutelySalawatTest() async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888,
        channelKey: 'salawat_channel',
        icon: 'resource://mipmap/launcher_icon',
        title: 'ﷺ',
        body: 'اللهم صل وسلم على نبينا محمد',
        notificationLayout: NotificationLayout.Default,
        payload: {'route': 'salawat'},
      ),
      schedule: NotificationInterval(
        interval: Duration(hours: 1), // كل 60 ثانية
        repeats: true,
        preciseAlarm: true,
      ),
    );
    print('🧪 تم جدولة اختبار الصلاة على النبي كل دقيقة');
  } catch (e) {
    print('❌ خطأ في جدولة الاختبار: $e');
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ جدولة الأذان (للاستخدام من AdhanService)
// ═══════════════════════════════════════════════════════════
Future<void> scheduleAzan(DateTime prayerTime, String prayerName) async {
  try {
    final channelKey =
        prayerName == 'الفجر' ? 'fajr_adhan_channel' : 'adhan_channel';

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

// ═══════════════════════════════════════════════════════════
// ✅ NotificationController - معالجة الإشعارات
// ═══════════════════════════════════════════════════════════
@pragma('vm:entry-point')
class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('📱 إشعار جديد: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print('📱 تم عرض الإشعار: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('📱 تم إغلاق الإشعار: ${receivedAction.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('🎯 تم الضغط على الإشعار: ${receivedAction.payload}');

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
    }
  }
}

void checkWhatsNew(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final lastVersion = prefs.getString("last_version");

  // هات معلومات التطبيق
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version; // هنا بقت String تلقائيًا
  print("currentVersion $currentVersion");
  print("lastVersion $lastVersion");
  if (lastVersion != currentVersion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showWhatsNew(context);
    });

    prefs.setString("last_version", currentVersion);
  }
}


// في نهاية main.dart، بعد دالة main()

// void showWhatsNew(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (_) {
//       return DraggableScrollableSheet(
//         initialChildSize: 0.55,
//         maxChildSize: 0.85,
//         minChildSize: 0.4,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//             ),
//             child: ListView(
//               controller: scrollController,
//               padding: EdgeInsets.all(20),
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   "🌟 ما الجديد في التحديث؟",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 whatsNewItem(
//                   Icons.star,
//                   "تحسين واجهة قراءة القرآن",
//                   "تم إضافة وضع ليلي محسن + تحسين حجم الخط + تقليل استهلاك البطارية.",
//                 ),
//                 whatsNewItem(
//                   Icons.bookmark,
//                   "إدارة العلامات المرجعية",
//                   "تقدر تحفظ، تعدل، وتمسح العلامات بسهولة وسرعة.",
//                 ),
//                 whatsNewItem(
//                   Icons.search,
//                   "بحث أسرع",
//                   "تحسين سرعة البحث داخل السور والآيات.",
//                 ),
//                 whatsNewItem(
//                   Icons.bug_report,
//                   "إصلاحات أخطاء",
//                   "إصلاح مشكلة تحميل الصفحات وتحسين الأداء العام.",
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: Text(
//                     "تمام، فهمت 👍",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// Widget whatsNewItem(IconData icon, String title, String desc) {
//   return Container(
//     margin: EdgeInsets.only(bottom: 15),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: Colors.green, size: 28),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 desc,
//                 style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//               ),
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
//

// إعداد الإشعارات الافتراضية

//# دليل إعداد WorkManager للأذان التلقائي
//
//## ✅ ما تم عمله:
//
//### 1. WorkManager
//- يشغل الأذان **تلقائياً في الخلفية**
//- يعمل حتى لو التطبيق **مقفول تماماً**
//- يعمل حتى لو الهاتف في **وضع السكون**
//
//### 2. المميزات:
//- ✅ أذان تلقائي بدون تدخل المستخدم
//- ✅ يعمل لـ 7 أيام قادمة
//- ✅ تنبيه قبل الأذان بـ 5 دقائق (اختياري)
//- ✅ يحدّث نفسه عند تغيير الموقع
//
//---
//
//## 📱 الإعدادات المطلوبة على الهاتف:
//
//### أ) تعطيل توفير البطارية للتطبيق:
//1. إعدادات الهاتف → البطارية
//2. تحسين استهلاك البطارية
//3. ابحث عن التطبيق
//4. اختر **"لا تحسّن"** أو **"غير مقيد"**
//
//### ب) السماح بالعمل في الخلفية:
//1. إعدادات الهاتف → التطبيقات
//2. اختر التطبيق
//3. الأذونات → **السماح بالعمل في الخلفية**
//
//### ج) تفعيل التشغيل التلقائي (للهواتف الصينية):
//**Xiaomi/Redmi/POCO:**
//- الإعدادات → الأمان → الأذونات → التشغيل التلقائي
//- فعّل التطبيق
//
//**Huawei:**
//- الإعدادات → التطبيقات → إدارة التطبيقات
//- اختر التطبيق → التشغيل التلقائي
//
//**Oppo/Realme:**
//- الإعدادات → البطارية → تحسين استخدام البطارية
//- اختر التطبيق → لا تحسّن
//
//**Samsung:**
//- الإعدادات → البطارية وصيانة الجهاز
//- التطبيقات غير المراقبة → أضف التطبيق
//
//---
//
//## 🔧 إعدادات للمطورين:
//
//### 1. تفعيل Debug Mode:
//في `adhan_workmanager_service.dart`:
//```dart
//await Workmanager().initialize(
//callbackDispatcher,
//isInDebugMode: true, // غيّرها لـ true للتجربة
//);
//```
//
//### 2. اختبار الأذان فوراً:
//```dart
//// تشغيل الأذان بعد 10 ثواني للتجربة
//await Workmanager().registerOneOffTask(
//'test_adhan',
//'playAdhan',
//initialDelay: Duration(seconds: 10),
//inputData: {
//'prayerName': 'الفجر',
//'cityName': 'القاهرة',
//},
//);
//```
//
//### 3. عرض سجل الأحداث:
//في Android Studio:
//```
//Run → Flutter → Run
//ثم افتح Logcat وابحث عن:
//- 🔊 (لتتبع تشغيل الأذان)
//- ✅ (للعمليات الناجحة)
//- ❌ (للأخطاء)
//```
//
//---
//
//## ⚠️ ملاحظات مهمة:
//
//### 1. صوت الأذان:
//- **يجب** وضع الملف في: `assets/athan/athan.mp3`
//- أضفه في `pubspec.yaml`:
//```yaml
//flutter:
//assets:
//- assets/athan/athan.mp3
//```
//
//### 2. القيود في Android 12+:
//- Android 12 وما فوق يحتاج إذن `SCHEDULE_EXACT_ALARM`
//- التطبيق سيطلبه تلقائياً عند أول تشغيل
//
//### 3. مدة الأذان:
//- الأذان يشتغل كاملاً ثم يتوقف تلقائياً
//- لو عايز توقفه يدوياً، ممكن تضيف زر في الإشعار
//
//### 4. استهلاك البطارية:
//- WorkManager مُحسّن ولا يستهلك بطارية كثيرة
//- يعمل فقط عند موعد الأذان بالضبط
//
//---
//
//## 🐛 حل المشاكل الشائعة:
//
//### المشكلة: الأذان ما يشتغلش
//**الحل:**
//1. تأكد من تعطيل توفير البطارية
//2. تأكد من أن ملف `athan.mp3` موجود
//3. راجع الـ Logcat للأخطاء
//
//### المشكلة: الأذان يتأخر
//**الحل:**
//1. تأكد من إذن `SCHEDULE_EXACT_ALARM`
//2. أغلق تطبيقات توفير البطارية الخارجية
//3. فعّل التشغيل التلقائي (للهواتف الصينية)
//
//### المشكلة: الأذان يتوقف بعد يوم
//**الحل:**
//- التطبيق يجدول لـ 7 أيام
//- افتح التطبيق مرة كل أسبوع لتجديد الجدولة
//- أو استخدم `BOOT_COMPLETED` receiver
//
//---
//
//## 🎯 الخطوات التالية (اختيارية):
//
//1. **إضافة زر إيقاف الأذان** في الإشعار
//2. **تطبيق Foreground Service** للموثوقية الأعلى
//3. **جدولة تلقائية** بعد إعادة تشغيل الجهاز
//4. **إعدادات مخصصة** لصوت الأذان لكل صلاة
//
//---
//
//## 📊 اختبار الجودة:
//
//```dart
//// في TimingScreen، أضف هذا الزر للاختبار:
//ElevatedButton(
//onPressed: () async {
//// اختبار فوري
//await Workmanager().registerOneOffTask(
//'test_now',
//'playAdhan',
//initialDelay: Duration(seconds: 5),
//inputData: {
//'prayerName': 'اختبار',
//'cityName': 'القاهرة',
//},
//);
//
//ScaffoldMessenger.of(context).showSnackBar(
//const SnackBar(content: Text('سيبدأ الأذان بعد 5 ثواني')),
//);
//},
//child: const Text('اختبار الأذان الآن'),
//)
//```

