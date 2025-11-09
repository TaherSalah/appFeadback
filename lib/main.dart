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

import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/localization/localization_manager.dart';
import 'app/core/shard/widgets/def_controller_tabs.dart';
import 'app/core/utils/services_locator.dart';
import 'app/core/utils/style/responsive_util.dart';
import 'app/core/widgets/custom_text_widget.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
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
