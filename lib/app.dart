import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
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
    final rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 3,
      minLaunches: 5,
      remindDays: 3,
      remindLaunches: 5,
      googlePlayIdentifier: 'com.rafiq.muslimdaily', // عدّل
      appStoreIdentifier: '1234567890', // عدّل
    );
    rateService = RateService(rateMyApp);
    rateService.init().then((_) => rateService.maybeAskForRating(context));
  }
//   final RateMyApp rateMyApp = RateMyApp(
//     preferencesPrefix: 'rateMyApp_',
//     minDays: 3, // بعد 3 أيام من التثبيت
//     minLaunches: 5, // أو بعد 5 مرات تشغيل
//     remindDays: 3,
//     remindLaunches: 5,
//     googlePlayIdentifier: 'com.rafiq.muslimdaily', // ← غيّرها
//     appStoreIdentifier: '1234567890', // ← غيّرها
//   );
//   @override
//   void initState() {
//     super.initState();
//
//     rateMyApp.init().then((_) {
//       if (rateMyApp.shouldOpenDialog) {
//         _showRatingDialog();
//       }
//     });
//   }
//   Future<void> _openStore() async {
//     if (Platform.isAndroid) {
//       // 🔹 تحقق أولاً إذا كان على Huawei أم لا
//       try {
//         final bool isHuawei = await _isHuaweiDevice();
//         if (isHuawei) {
//           await launchUrl(Uri.parse('https://appgallery.huawei.com/app/C123456789')); // رابط تطبيقك في AppGallery
//           return;
//         }
//       } catch (_) {}
//
//       // 🔹 غير Huawei → Google Play
//       await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.yourcompany.yourapp'));
//     } else if (Platform.isIOS) {
//       // 🔹 App Store
//       await launchUrl(Uri.parse('https://apps.apple.com/app/id1234567890'));
//     }
//   }
//
// // فحص هل الجهاز Huawei
//   Future<bool> _isHuaweiDevice() async {
//     try {
//       // إذا الجهاز بيحتوي على خدمات Huawei
//       return await File('/system/app/HwOUC').exists();
//     } catch (_) {
//       return false;
//     }
//   }
//   void _showRateDialog() {
//     rateMyApp.showStarRateDialog(
//       context,
//       title: '⭐ قيّم تطبيقنا',
//       message: 'ساعدنا بتقييمك لتطوير التطبيق أكثر 🙏',
//       starRatingOptions: const StarRatingOptions(initialRating: 5),
//       actionsBuilder: (context, stars) {
//         return [
//           TextButton(
//             child: const Text('لاحقًا'),
//             onPressed: () {
//               rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//               Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.later);
//             },
//           ),
//           ElevatedButton(
//             child: const Text('إرسال'),
//             onPressed: () async {
//               final rating = (stars ?? 0).round();
//               if (rating >= 4) {
//                 await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
//                 await _openStore(); // ← افتح المتجر المناسب
//               } else {
//                 // لو التقييم منخفض افتح صفحة ملاحظات أو تجاهل
//                 await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//               }
//               Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
//             },
//           ),
//         ];
//       },
//       ignoreNativeDialog: false,
//       dialogStyle: const DialogStyle(
//         titleAlign: TextAlign.center,
//         messageAlign: TextAlign.center,
//       ),
//       onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
//     );
//   }
//   // ListTile(
//   // leading: const Icon(Icons.star, color: Colors.amber),
//   // title: const Text('تقييم التطبيق'),
//   // onTap: _showRateDialog,
//   // ),
//
//   void _showRatingDialog() {
//     rateMyApp.showStarRateDialog(
//       context,
//       title: '⭐ قيم تطبيقنا',
//       message: 'إذا أعجبك التطبيق، يسعدنا أن تترك لنا تقييمًا بسيطًا 🙏',
//       actionsBuilder: (context, stars) {
//         return [
//           TextButton(
//             child: const Text('إلغاء'),
//             onPressed: () {
//               Navigator.pop<RateMyAppDialogButton>(
//                   context, RateMyAppDialogButton.no);
//             },
//           ),
//           ElevatedButton(
//             child: const Text('إرسال'),
//             onPressed: () async {
//               print('تم التقييم: ${stars ?? 0} نجوم');
//
//               if ((stars ?? 0) >= 4) {
//                 // ⭐ لو التقييم عالي، افتح صفحة التطبيق في المتجر
//                 await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
//               } else {
//                 // 💬 لو التقييم قليل، ممكن توجه المستخدم لصفحة الملاحظات
//                 await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//               }
//
//               Navigator.pop<RateMyAppDialogButton>(
//                   context, RateMyAppDialogButton.rate);
//             },
//           ),
//         ];
//       },
//       ignoreNativeDialog: Platform.isAndroid,
//       dialogStyle: const DialogStyle(
//         titleAlign: TextAlign.center,
//         messageAlign: TextAlign.center,
//       ),
//       starRatingOptions: const StarRatingOptions(
//         initialRating: 5,
//         minRating: 1,
//         allowHalfRating: true,
//       ),
//       onDismissed: () => rateMyApp
//           .callEvent(RateMyAppEventType.laterButtonPressed), // لما يقفل النافذة
//     );
//   }

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
