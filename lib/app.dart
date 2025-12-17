import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'app/core/cache/storage.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/shard/exports/all_exports.dart';
import 'app/core/utils/app_theme/app_theme.dart';
import 'app/core/utils/constent/router.dart';
import 'app/core/utils/services_locator.dart';
import 'app/features/aboutView/RateService.dart';
import 'app/features/categories/data/repo/categories_repo_immp.dart';
import 'app/features/categories/view/controller/categories_bloc.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'main.dart';

class MashkahApp extends StatefulWidget {
  const MashkahApp({super.key});

  @override
  State<MashkahApp> createState() => _MashkahAppState();
}

class _MashkahAppState extends State<MashkahApp> {
  late final RateService rateService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkWhatsNew(context);
    });
    final rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp',
      minDays: 3,
      minLaunches: 5,
      remindDays: 3,
      remindLaunches: 5,
      googlePlayIdentifier: 'com.rafiq.muslimdaily', // عدّل
      appStoreIdentifier: '6749927338', // عدّل
    );
    rateService = RateService(rateMyApp);
    rateService.init().then((_) => rateService.maybeAskForRating(context));
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
                child: Provider<RateService>.value(
                  value: rateService,
                  child: BlocBuilder<CentralizedCubit, CentralizedState>(
                      builder: (context, state) {
                    final cubit = CentralizedCubit.get(context);

                    return UpgradeAlert(
                      child: MaterialApp(
                        // useInheritedMediaQuery: true,
                        // locale: DevicePreview.locale(context),
                        // builder: DevicePreview.appBuilder,
                        navigatorKey: CentralizedCubit.navigatorKey,
                        title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                        debugShowCheckedModeBanner: false,
                        onGenerateRoute: (settings) =>
                            RouteGenerator.getRoute(settings, context),
                        initialRoute: Routes.splashRoute,
                        theme: AppTheme.light,
                        darkTheme: AppTheme.dark,
                        themeMode: cubit.themeMode(),

                        // ⭐ اضيف الـ builder هنا
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler:
                                  MediaQuery.textScalerOf(context).clamp(
                                minScaleFactor: 0.8,
                                maxScaleFactor:
                                    1.2, // أو 1.0 لو عايزه ثابت تمامًا
                              ),
                            ),
                            child: child!,
                          );
                        },
                      ),
                    );
                  }),
                ));
          }),
    );
  }
}

List<SingleChildWidget> provider = [
  BlocProvider<CentralizedCubit>(
      create: (BuildContext context) =>
          CentralizedCubit(sharedPreferences: Di.sharedPreferences)
            ..localization()),
  BlocProvider<CategoriesBloc>(
      create: (BuildContext context) => CategoriesBloc(CategoriesRepoImmp())),
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
