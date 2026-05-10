import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/cache/storage.dart';
import 'package:provider/single_child_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'app/core/shard/exports/all_exports.dart';
import 'app/core/utils/app_theme/app_theme.dart';
import 'app/core/utils/constent/router.dart';
import 'app/core/utils/style/k_color.dart';
import 'app/features/categories/data/repo/categories_repo_immp.dart';
import 'app/features/categories/view/controller/categories_bloc.dart';
import 'app/core/services/notification_manager.dart';
import 'main.dart';

// import 'main.dart';

class RafiqMuslimApp extends StatefulWidget {
  const RafiqMuslimApp({super.key});

  @override
  State<RafiqMuslimApp> createState() => _RafiqMuslimAppState();
}

class _RafiqMuslimAppState extends State<RafiqMuslimApp> {
  // late final RateService rateService;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkWhatsNew(context);
    // });
    // final rateMyApp = RateMyApp(
    //   preferencesPrefix: 'rateMyApp',
    //   minDays: 3,
    //   minLaunches: 5,
    //   remindDays: 3,
    //   remindLaunches: 5,
    //   googlePlayIdentifier: 'com.rafiq.muslimdaily',
    //   appStoreIdentifier: '6749927338',
    // );
    // rateService = RateService(rateMyApp);
    // rateService.init().then((_) => rateService.maybeAskForRating(context));

    // 🚀 Check if app was launched by Adhan notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLaunchNotification();
    });
  }

  Future<void> _checkLaunchNotification() async {
    try {
      final receivedAction = await AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: true);

      if (receivedAction != null) {
        print("🚀 App launched by Notification: ${receivedAction.payload}");
        
        // استخدام المحرك الموحد للتنقل في NotificationManager لضمان ذهاب المستخدم للمكان الصحيح
        NotificationManager.onActionReceivedMethod(receivedAction);
      }
    } catch (e) {
      logger.e("❌ Error checking launch notification: $e");
    }
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return KColors.primaryColor;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return KColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, widget) {
            KStorage.i.delTime;
            return MultiBlocProvider(
                providers: provider,
                // child: Provider<RateService>.value(
                //     value: rateService,
                child: BlocBuilder<CentralizedCubit, CentralizedState>(
                    builder: (context, state) {
                  final cubit = CentralizedCubit.get(context);

                  // return MaterialApp(
                  //   // useInheritedMediaQuery: true,
                  //   // locale: DevicePreview.locale(context),
                  //   // builder: DevicePreview.appBuilder,
                  //   navigatorKey: CentralizedCubit.navigatorKey,
                  //   title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                  //   debugShowCheckedModeBanner: false,
                  //   onGenerateRoute: (settings) =>
                  //       RouteGenerator.getRoute(settings, context),
                  //   initialRoute: Routes.splashRoute,
                  //   theme: AppTheme.light(primaryColor: _hexToColor(CentralizedCubit.dynamicPrimaryColor)),
                  //   darkTheme: AppTheme.dark(primaryColor: _hexToColor(CentralizedCubit.dynamicPrimaryColor)),
                  //   themeMode: cubit.themeMode(),
                  //
                  //   // ⭐ اضيف الـ builder هنا
                  //   builder: (context, child) {
                  //     return MediaQuery(
                  //       data: MediaQuery.of(context).copyWith(
                  //         textScaler:
                  //             MediaQuery.textScalerOf(context).clamp(
                  //           minScaleFactor: 0.8,
                  //           maxScaleFactor:
                  //               1.2, // أو 1.0 لو عايزه ثابت تمامًا
                  //         ),
                  //       ),
                  //       child: child!,
                  //     );
                  //   },
                  // );
                  return ShowCaseWidget(
                    builder: (context) => MaterialApp(
                      navigatorKey: CentralizedCubit.navigatorKey,
                      title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                      debugShowCheckedModeBanner: false,
                      onGenerateRoute: (settings) =>
                          RouteGenerator.getRoute(settings, context),
                      initialRoute: Routes.splashRoute,
                      theme: AppTheme.light(
                          primaryColor: _hexToColor(
                              CentralizedCubit.dynamicPrimaryColor)),
                      darkTheme: AppTheme.dark(
                          primaryColor: _hexToColor(
                              CentralizedCubit.dynamicPrimaryColor)),
                      themeMode: cubit.themeMode(),
                      locale: const Locale('ar', 'EG'),
                      supportedLocales: const [
                        Locale('ar', 'EG'),
                        Locale('en', 'US'),
                      ],
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      builder: (context, child) {

                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: MediaQuery.textScalerOf(context).clamp(
                              minScaleFactor: 0.8,
                              maxScaleFactor: 1.15, // 🚀 Reduced from 1.2 to 1.15 for better UI stability
                            ),
                          ),
                          child: child!,
                        );
                      },
                    ),
                  );
                }));
          }),
    );
  }
}

List<SingleChildWidget> provider = [
  BlocProvider<CategoriesBloc>(
    create: (BuildContext context) =>
        CategoriesBloc(CategoriesRepoImmp())..getAllCategories(),
  ),
  ChangeNotifierProvider(
    create: (context) => AzkarProvider()
      ..fetchAzkarMassa()
      ..fetchAzkarSabah()
      ..fetchAzkarPostPrayer()
      ..fetchAzkar(),
  )
];
