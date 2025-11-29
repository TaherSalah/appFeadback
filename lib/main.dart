// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';
import 'package:quran_library/quran.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/localization/localization_manager.dart';
import 'app/features/main_view/widget/IslamicCardWidget.dart';
import 'app/core/utils/services_locator.dart';
import 'app/core/utils/style/responsive_util.dart';
import 'app/core/widgets/custom_text_widget.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   tz.setLocalLocation(tz.getLocation(await tz.local.name));
//   await initl.initializeDateFormatting('ar');
//
//   HijriCalendar.setLocal('ar');
//
//   WidgetsFlutterBinding.ensureInitialized();
//   final List<ConnectivityResult> connectivityResult =
//       await (Connectivity().checkConnectivity());
//   tz.initializeTimeZones();
//   final String timeZoneName = tz.local.name;
//   tz.setLocalLocation(tz.getLocation(timeZoneName));
//   if (connectivityResult.contains(ConnectivityResult.mobile)) {
//     await Firebase.initializeApp();
//     await MyFirebaseMessagingService.requestPermission();
//     await MyFirebaseMessagingService.initialize();
//     FirebaseMessaging.onBackgroundMessage(
//         MyFirebaseMessagingService.firebaseMessagingBackgroundHandler);
//   } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
//     await Firebase.initializeApp();
//     await MyFirebaseMessagingService.requestPermission();
//     await MyFirebaseMessagingService.initialize();
//
//     FirebaseMessaging.onBackgroundMessage(
//         MyFirebaseMessagingService.firebaseMessagingBackgroundHandler);
//   } else if (connectivityResult.contains(ConnectivityResult.none)) {
//     await AzkarNotificationService.initialize();
//     await AzkarNotificationService.scheduleAllAzkarNotifications();
//   }
//
//   await AzkarNotificationService.initialize();
//   await AzkarNotificationService.scheduleAllAzkarNotifications();
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← أول سطر دائمًا
  await QuranLibrary.init();
  // تهيئة خدمة الإشعارات
  await NotificationService().initialize();

  // جدولة الإشعارات الافتراضية
  await _setupDefaultNotifications();
  // SystemChrome و أي platform channels لازم بعد ensureInitialized
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));
  HijriCalendar.setLocal('ar_SA');

  // لو عندك DI بيتعامل مع ملفات/قنوات منصة، خلّيه بعد ensureInitialized
  await Di.init();

  // Intl dates
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  await SharedObj().init();

  // مكتبتك
  // QuranLibrary().initTafsir();

  // Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }

  await Hive.openBox<KhatmahModel>('khatmahBox');

  if (!Hive.isBoxOpen('khatmahBox')) {
    await Hive.openBox<KhatmahModel>('khatmahBox');
  }
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
        // DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (context) => YaqeesApp(), // Wrap your app
        // ),

        BlocProvider<CentralizedCubit>(
            create: (context) =>
                CentralizedCubit(sharedPreferences: Di.sharedPreferences)
                  ..localization(),
            child: BlocBuilder<CentralizedCubit, CentralizedState>(
              builder: (context, state) {
                return const MashkahApp();
              },
            )));
  });
}

// void main() async {
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.dark,
//     systemNavigationBarColor: Colors.transparent,
//   ),
//   );
//
//   await Di.init();
//   WidgetsFlutterBinding.ensureInitialized();
//   //// for init date language
//   await initializeDateFormatting();
//   await initializeDateFormatting('ar', null);
//   await initializeDateFormatting('en', null);
//   await SharedObj().init();
//   QuranLibrary().init();
//   QuranLibrary().initTafsir();
//   // Init Hive
//   await Hive.initFlutter();
//   Hive.registerAdapter(KhatmahModelAdapter());
//   await Hive.openBox<KhatmahModel>('khatmahBox');
//   await Hive.openBox('khatmahPlans'); // لو عندك خطط الأجزاء
//
//   // await Hive.deleteBoxFromDisk('khatmahBox');
//
//   // Init Notifications
//   // AwesomeNotifications().initialize(
//   //   null,
//   //   [
//   //     NotificationChannel(
//   //       channelKey: 'khatmah_channel',
//   //       channelName: 'ختمتك',
//   //       channelDescription: 'إشعارات ختمتك اليومية',
//   //       defaultColor: Colors.green,
//   //       importance: NotificationImportance.High,
//   //       channelShowBadge: true,
//   //     )
//   //   ],
//   //   debug: true,
//   // );
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
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

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset("assets/icons/arrow.svg",color: Colors.black,height: 25,))

          ],
        ),
          body: Column(
        // spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
                child: Lottie.asset(
                    fit: BoxFit.fill,
                    height: 500,
                    width: 500,
                    'assets/json/wifi.json')),
          ),
          const SizedBox(height: 25),
          TextWidget(
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 8.sp,
              textAlign: TextAlign.center,
              title: LocalizationManager.call('no_connection'))
        ],
      )),
    );
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   tz.setLocalLocation(tz.getLocation(await tz.local.name));
//   await initl.initializeDateFormatting('ar');
//
//   HijriCalendar.setLocal('ar');
//
//   WidgetsFlutterBinding.ensureInitialized();
//   final List<ConnectivityResult> connectivityResult =
//   await (Connectivity().checkConnectivity());
//   tz.initializeTimeZones();
//   final String timeZoneName = tz.local.name;
//   // await Firebase.initializeApp();
//   // await MyFirebaseMessagingService.requestPermission();
//   // await MyFirebaseMessagingService.initialize();
//   // FirebaseMessaging.onBackgroundMessage(
//   //     MyFirebaseMessagingService.firebaseMessagingBackgroundHandler);
//   tz.setLocalLocation(tz.getLocation(timeZoneName));
//   await AzkarNotificationService.initialize();
//   await AzkarNotificationService.scheduleAllAzkarNotifications();
//
//   runApp(const MyApp());
// }
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late String selectedFontSize;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedFontSize = "20";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       builder: (BuildContext context, Widget? child) {
//         return MultiProvider(
//           providers: [
//             ChangeNotifierProvider(
//               create: (context) => AzkarProvider()
//                 ..fetchAzkarMassa()
//                 ..fetchAzkarSabah()
//                 ..fetchAzkarPostPrayer()
//                 ..fetchAzkar(),
//             )
//           ],
//           child: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
//             initialRoute: 'splash',
//             onGenerateRoute: (settings) {
//               WidgetBuilder builder;
//               switch (settings.name) {
//                 case 'splash':
//                   builder = (context) => const SplashScreen();
//                   break;
//                 case 'home':
//                   builder = (context) => const HomeScreen();
//                   break;
//                 case '/azkarSabah':
//                   builder = (context) => const AzkarSabah();
//                   break;
//                 case '/azkarMassa':
//                   builder = (context) => const AzkarMassa();
//                   break;
//                 case '/prayerAzkar':
//                   builder = (context) => const PrayerAzkar();
//                   break;
//                 case '/surahListScreen':
//                   builder = (context) => const SurahListScreen();
//                   break;
//                 case '/timingScreen':
//                   builder = (context) => const TimingScreen();
//                   break;
//                 case '/allazkarlistview':
//                   builder = (context) => const Allazkarlistview();
//                   break;
//                 case '/azkarCounter':
//                   builder = (context) => const AzkarCounter();
//                   break;
//                 case '/sleepAzkar':
//                   builder = (context) => const SleepAzkar();
//                   break;
//                 case '/rokiaScreen':
//                   builder = (context) => const RokiaScreen();
//                   break;
//                 case '/azkarOthers':
//                   builder = (context) => const AzkarOthers();
//                   break;
//                 case '/about':
//                   builder = (context) => const About();
//                   break;
//                 default:
//                   builder = (context) => const SplashScreen(); // fallback
//               }
//
//               return PageRouteBuilder(
//                 pageBuilder: (context, animation, secondaryAnimation) =>
//                     builder(context),
//                 transitionsBuilder:
//                     (context, animation, secondaryAnimation, child) {
//                   const begin = Offset(1.0, 0.0); // Slide from right to left
//                   const end = Offset.zero;
//                   const curve = Curves.easeIn;
//
//                   final tween = Tween(begin: begin, end: end)
//                       .chain(CurveTween(curve: curve));
//
//                   return SlideTransition(
//                     position: animation.drive(tween),
//                     child: child,
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

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
      showWhatsNew(context);
    });

    prefs.setString("last_version", currentVersion);
  }
}

void showWhatsNew(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "🌟 ما الجديد في التحديث؟",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                whatsNewItem(
                  Icons.star,
                  "تحسين واجهة قراءة القرآن",
                  "تم إضافة وضع ليلي محسن + تحسين حجم الخط + تقليل استهلاك البطارية.",
                ),
                whatsNewItem(
                  Icons.bookmark,
                  "إدارة العلامات المرجعية",
                  "تقدر تحفظ، تعدل، وتمسح العلامات بسهولة وسرعة.",
                ),
                whatsNewItem(
                  Icons.search,
                  "بحث أسرع",
                  "تحسين سرعة البحث داخل السور والآيات.",
                ),
                whatsNewItem(
                  Icons.bug_report,
                  "إصلاحات أخطاء",
                  "إصلاح مشكلة تحميل الصفحات وتحسين الأداء العام.",
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "تمام، فهمت 👍",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget whatsNewItem(IconData icon, String title, String desc) {
  return Container(
    margin: EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        )
      ],
    ),
  );
}



// إعداد الإشعارات الافتراضية
Future<void> _setupDefaultNotifications() async {
  final notificationService = NotificationService();

  // جدولة أذكار الصباح - الساعة 6 صباحاً
  await notificationService.scheduleMorningAthkar(6, 0);

  // جدولة أذكار المساء - الساعة 6 مساءً
  await notificationService.scheduleEveningAthkar(18, 0);

  // جدولة ورد القرآن - الساعة 8 مساءً
  await notificationService.scheduleDailyQuranWird(20, 0);

  // جدولة حديث اليوم - الساعة 12 ظهراً
  await notificationService.scheduleDailyHadith(12, 0);
}
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // تهيئة الإشعارات
  Future<void> initialize() async {
    tz.initializeTimeZones();

    // إعدادات Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // طلب الأذونات
    await _requestPermissions();
  }

  // طلب الأذونات
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // عند النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    // يمكنك هنا التنقل إلى صفحة معينة
    print('تم النقر على الإشعار: ${response.payload}');
  }

  // جدولة أذكار الصباح
  Future<void> scheduleMorningAthkar(int hour, int minute) async {
    await _scheduleNotification(
      id: 1,
      title: '🌅 أذكار الصباح',
      body: 'حان وقت أذكار الصباح، بارك الله في صباحك',
      hour: hour,
      minute: minute,
      payload: 'morning_athkar',
    );
  }

  // جدولة أذكار المساء
  Future<void> scheduleEveningAthkar(int hour, int minute) async {
    await _scheduleNotification(
      id: 2,
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء، جعل الله مساءك مباركاً',
      hour: hour,
      minute: minute,
      payload: 'evening_athkar',
    );
  }

  // جدولة ورد قراني يومي
  Future<void> scheduleDailyQuranWird(int hour, int minute) async {
    await _scheduleNotification(
      id: 3,
      title: '📖 ورد القرآن اليومي',
      body: 'لا تنسَ وردك اليومي من القرآن الكريم',
      hour: hour,
      minute: minute,
      payload: 'quran_wird',
    );
  }

  // جدولة تنبيه بعد صلاة
  Future<void> scheduleAfterPrayerReminder(String prayerName, int afterMinutes) async {
    // هنا يمكنك حساب الوقت بناءً على وقت الصلاة
    // مثال: بعد صلاة الفجر بـ 15 دقيقة
    await _scheduleNotification(
      id: 10,
      title: '🤲 تذكير بعد صلاة $prayerName',
      body: 'وقت الأذكار والدعاء بعد الصلاة',
      hour: 6, // مثال
      minute: 15,
      payload: 'after_prayer',
    );
  }

  // جدولة تنبيه بحديث يومي
  Future<void> scheduleDailyHadith(int hour, int minute) async {
    await _scheduleNotification(
      id: 4,
      title: '📿 حديث اليوم',
      body: 'اطلع على الحديث الشريف لهذا اليوم',
      hour: hour,
      minute: minute,
      payload: 'daily_hadith',
    );
  }

  // الدالة الأساسية للجدولة
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_channel',
          'أذكار وأوراد',
          channelDescription: 'إشعارات الأذكار والأوراد اليومية',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // sound: RawResourceAndroidNotificationSound('azan'),
        ),
        iOS: const DarwinNotificationDetails(
          // sound: 'azan.aiff',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // حساب الوقت التالي للتنبيه
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // إذا كان الوقت قد مضى اليوم، جدوله لليوم التالي
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // إلغاء إشعار معين
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // عرض إشعار فوري (للتجربة)
  Future<void> showInstantNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'إشعارات فورية',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  // الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // دالة عامة للجدولة (للاستخدام المرن)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      payload: payload,
    );
  }
}