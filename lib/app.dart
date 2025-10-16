import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import 'app/core/cache/storage.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/shard/exports/all_exports.dart';
import 'app/core/utils/app_theme/app_theme.dart';
import 'app/core/utils/constent/router.dart';
import 'app/core/utils/services_locator.dart';
import 'app/features/categories/data/repo/categories_repo_immp.dart';
import 'app/features/categories/view/controller/categories_bloc.dart';


class MashkahApp extends StatefulWidget {
  const MashkahApp({super.key});

  @override
  State<MashkahApp> createState() => _MashkahAppState();
}

class _MashkahAppState extends State<MashkahApp> {



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
                child: BlocBuilder<CentralizedCubit, CentralizedState>(
                    builder: (context, state) {
                      final cubit = CentralizedCubit.get(context);

                      return MaterialApp(

                      // useInheritedMediaQuery: true,
                      // locale: DevicePreview.locale(context),
                      // builder: DevicePreview.appBuilder,
                      navigatorKey: CentralizedCubit.navigatorKey,
                      title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                      debugShowCheckedModeBanner: false,
                      onGenerateRoute: (settings) =>
                          RouteGenerator.getRoute(settings, context),
                      initialRoute: Routes.splashRoute,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,            // فعّل ثيم داكنك
                    themeMode: cubit.themeMode(),
                    // theme: AppTheme.light,
                      // darkTheme: AppTheme.dark,
                      // themeMode:  ThemeMode.light
                  );
                }));
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
