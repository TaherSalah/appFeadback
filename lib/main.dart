import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/services/analytics_service.dart';
import 'package:muslimdaily/app/core/services/system_control_service.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/utils/services_locator.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
import 'app/features/charity/models/charity_models.dart';
import 'app/features/achievements/models/achievement_models.dart';
import 'app/features/duas/models/dua_models.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quran_library/quran.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 🛡️ Global Error Handling (Dashboard Logging)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    SystemControlService().logError(details.exceptionAsString(), details.stack?.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    SystemControlService().logError(error.toString(), stack.toString());
    return true;
  };

  await QuranLibrary.init();
  try {
    await _initAppServices();
  } catch (e, s) {
    print('❌ خطأ في تهيئة التطبيق: $e\n$s');
    // We can't do much here if the root app fails to start,
    // but the error will be handled by the MashkahApp if needed or just crash.
  }

  runApp(
    BlocProvider<CentralizedCubit>(
      create: (context) => CentralizedCubit(
        sharedPreferences: Di.sharedPreferences,
      )..localization(),
      child: BlocBuilder<CentralizedCubit, CentralizedState>(
        builder: (context, state) => const MashkahApp(),
      ),
    ),
  );
}

Future<void> _initAppServices() async {
  // ✅ 1) Initialize Supabase
  await Supabase.initialize(
    url: 'https://kghwboxevphvxtsagrer.supabase.co',
    anonKey: 'sb_publishable_Kl3FXiXa7AHEokVvCiImmQ_03UL91M0',
  );

  // ✅ 2) تخصيصات النظام
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  // ✅ 3) تهيئة البيانات
  HijriCalendar.setLocal('ar_SA');
  await Di.init();
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await SharedObj().init();

  // ✅ 4) Hive
  await Hive.initFlutter();

  // Register existing adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(MonthlyGoalAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(CharityAchievementAdapter());
  }

  // Register new feature adapters
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(CharityDonationAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(AchievementAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(UserProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(ChallengeAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(CustomDuaAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(DuaReminderAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(RecurringCharityAdapter());
  }
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(AchievementTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(17)) {
    Hive.registerAdapter(AchievementRarityAdapter());
  }
  if (!Hive.isAdapterRegistered(18)) {
    Hive.registerAdapter(ChallengeTypeAdapter());
  }

  // Note: CharityCategory enum is handled automatically by CharityDonationAdapter

  // Open existing boxes
  await Hive.openBox<KhatmahModel>('khatmahBox');
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }

  // ✅ Note: Charity, Achievements, and Duas boxes are opened by their respective services

  // NotificationManager replaces all local notification logic
  final notificationManager = NotificationManager();
  await notificationManager.initialize();
  await notificationManager.rescheduleAll();

  // 🚀 Log App Launch Analytics
  AnalyticsService().logAppLaunch();
}
