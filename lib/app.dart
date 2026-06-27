import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/cache/storage.dart';
import 'package:provider/single_child_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'app/core/shard/exports/all_exports.dart';
import 'app/core/utils/app_theme/app_theme.dart';
import 'app/core/utils/constent/router.dart';
import 'app/core/utils/style/k_color.dart';
import 'app/features/categories/data/repo/categories_repo_immp.dart';
import 'app/features/categories/view/controller/categories_bloc.dart';
import 'package:get_it/get_it.dart';
import 'app/features/communities/presentation/cubit/communities_cubit.dart';
import 'app/features/communities/presentation/cubit/community_details_cubit.dart';
import 'app/features/communities/domain/repositories/communities_repository.dart';
import 'app/core/services/notification_manager.dart';
import 'main.dart';
// 🔔 Push Notifications
import 'app/core/services/push_notifications/presentation/cubit/notification_cubit.dart';
import 'app/core/services/push_notifications/core/notification_navigator.dart';
import 'app/core/utils/services_locator.dart';

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

    // 🚀 Check if app was launched by Adhan notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLaunchNotification();

      // 🔔 تهيئة نظام Push Notifications بعد بناء الـ Widget tree
      _initPushNotifications();
    });
  }

  /// تهيئة Push Notifications وبدء الاستماع للأحداث
  Future<void> _initPushNotifications() async {
    try {
      final supabaseAuth = Supabase.instance.client.auth;
      
      // تسجيل دخول مجهول إذا لم يكن المستخدم مسجلاً
      // لضمان حصولنا على user_id لتخزين الـ Token في قاعدة البيانات
      if (supabaseAuth.currentSession == null) {
        try {
          await supabaseAuth.signInAnonymously();
        } catch (authError) {
          logger.w('⚠️ Anonymous sign in failed (make sure it is enabled in Supabase dashboard): $authError');
        }
      }

      final userId = supabaseAuth.currentUser?.id;
      final cubit = Di.notificationCubit;

      // تهيئة الـ Cubit — يطلب الإذن ويجلب الـ Token ويرسله للخادم إذا وجد userId
      await cubit.initialize(userId: userId);

    } catch (e) {
      logger.e('❌ Push notification init error: $e');
    }
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
                    builder: (context) => BlocListener<NotificationCubit, NotificationState>(
                      bloc: Di.notificationCubit,
                      listener: (context, state) {
                        // Deep Linking — التنقل عند الضغط على إشعار
                        if (state is NotificationTapped) {
                          NotificationNavigator(
                            navigatorKey: CentralizedCubit.navigatorKey,
                          ).navigate(state.payload);
                        }
                      },
                      child: MaterialApp(
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
                          CountryLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: MediaQuery.textScalerOf(context).clamp(
                                minScaleFactor: 0.8,
                                maxScaleFactor: 1.15,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      ),
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
  ),
  BlocProvider<CommunitiesCubit>(
    create: (context) => CommunitiesCubit(repository: GetIt.instance<CommunitiesRepository>()),
  ),
  BlocProvider<CommunityDetailsCubit>(
    create: (context) => CommunityDetailsCubit(repository: GetIt.instance<CommunitiesRepository>()),
  )
];
