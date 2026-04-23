import 'package:flutter/material.dart';
import 'dart:io';
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
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'app/features/calendar/data/models/calendar_event_model.dart';
import 'app/core/services/adhan_logic/background_services.dart';
import 'package:logger/logger.dart';

import 'app/core/adhan_system/service/adhan_foreground_service.dart';
import 'app/features/quranView/pdf/data/pdf_book_model.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Start Native Splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 🚀 Initialize synchronous services early
  AdhanForegroundService.init();

  // 🚀 Parallelize critical Async Core Initializations
  await Future.wait<dynamic>([
    if (Platform.isAndroid) AndroidAlarmManager.initialize(),
    QuranLibrary.init(),
    _initAppServices(),
  ]);

  // 🛡️ Global Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    SystemControlService()
        .logError(details.exceptionAsString(), details.stack?.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    SystemControlService().logError(error.toString(), stack.toString());
    return true;
  };

  runApp(
    BlocProvider<CentralizedCubit>(
      create: (context) => CentralizedCubit(
        sharedPreferences: Di.sharedPreferences,
      )..localization(),
      child: BlocBuilder<CentralizedCubit, CentralizedState>(
        builder: (context, state) => const RafiqMuslimApp(),
      ),
    ),
  );
}

Future<void> _initAppServices() async {
  try {
    // Stage 1: Critical Infrastructure (Parallel)
    await Future.wait([
      Supabase.initialize(
        url: 'https://kghwboxevphvxtsagrer.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnaHdib3hldnBodnh0c2FncmVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxMjcwNzUsImV4cCI6MjA4MTcwMzA3NX0.PPh6rwxDbHGHHyHBUjdEz1WWdF_psdygbtF0nY5hNR4',
      ),
      Hive.initFlutter(),
    ]);

    // Stage 2: Data Adapters & UI Style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));

    _registerHiveAdapters();
    tz_data.initializeTimeZones();

    // Stage 3: Services & Boxes (Parallel where possible)
    await Future.wait<dynamic>([
      _openHiveBoxes(),
      Di.init(),
      _initTimezone(),
    ]);

    // Stage 4: Localization & Notifications
    HijriCalendar.setLocal('ar_SA');
    await Future.wait<dynamic>([
      initializeDateFormatting(),
      initializeDateFormatting('ar', null),
      initializeDateFormatting('en', null),
      NotificationManager().initialize(),
    ]);

    // Stage 5: Background Tasks & Analytics (Non-blocking)
    BGServices()
        .registerTask()
        .catchError((e) => debugPrint('⚠️ BGServices fail: $e'));
    AnalyticsService().logAppLaunch();
  } catch (e, s) {
    logger.e('❌ Error in _initAppServices: $e', error: e, stackTrace: s);
  }
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(KhatmahModelAdapter());
  if (!Hive.isAdapterRegistered(22)) Hive.registerAdapter(MonthlyGoalAdapter());
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(CharityAchievementAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(CharityDonationAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(AchievementAdapter());
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(UserProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(ChallengeAdapter());
  if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(CustomDuaAdapter());
  if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(DuaReminderAdapter());
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
}

Future<void> _openHiveBoxes() async {
  await Future.wait([
    Hive.openBox<KhatmahModel>('khatmahBox'),
    if (!Hive.isBoxOpen('khatmahPlans')) Hive.openBox('khatmahPlans'),
    Hive.openBox<PdfBookModel>('pdfBooksBox'),
  ]);
}

Future<void> _initTimezone() async {
  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    debugPrint('Could not set local location: $e');
  }
}
