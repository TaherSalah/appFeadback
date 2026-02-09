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
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'app/features/achievements/models/achievement_models.dart';
import 'app/features/duas/models/dua_models.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quran_library/quran.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'app/features/calendar/data/models/calendar_event_model.dart';
import 'app/features/quran/pdf/data/pdf_book_model.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 🛡️ Global Error Handling (Dashboard Logging)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    SystemControlService()
        .logError(details.exceptionAsString(), details.stack?.toString());
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
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnaHdib3hldnBodnh0c2FncmVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxMjcwNzUsImV4cCI6MjA4MTcwMzA3NX0.PPh6rwxDbHGHHyHBUjdEz1WWdF_psdygbtF0nY5hNR4',
  );

  // ✅ 2) تخصيصات النظام
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  // ✅ 3) Hive & Data Initialization
  await Hive.initFlutter();
  tz_data.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    debugPrint('Could not set local location: $e');
  }

  // Register all adapters before Di.init() because services might open boxes
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(MonthlyGoalAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(CharityAchievementAdapter());
  }
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
  if (!Hive.isAdapterRegistered(25)) {
    Hive.registerAdapter(CalendarEventAdapter());
  }
  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(PdfBookModelAdapter());
  }

  // ✅ 4) Open Core Boxes
  await Hive.openBox<KhatmahModel>('khatmahBox');
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }
  await Hive.openBox<PdfBookModel>('pdfBooksBox');

  // ✅ 5) Services Locator
  await Di.init();

  // ✅ 6) تهيئة البيانات التكميلية
  HijriCalendar.setLocal('ar_SA');
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await SharedObj().init();

  // ✅ Note: Charity, Achievements, and Duas boxes are opened by their respective services

  // NotificationManager replaces all local notification logic
  final notificationManager = NotificationManager();
  await notificationManager.initialize();

  // ✅ 7) Initialize Android Alarm Manager for exact widget updates
  try {
    await AndroidAlarmManager.initialize();
  } catch (e) {
    debugPrint('⚠️ AndroidAlarmManager init failed (might be not needed on iOS): $e');
  }

  // 🚀 Log App Launch Analytics
  AnalyticsService().logAppLaunch();
}
