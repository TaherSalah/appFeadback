import 'dart:developer' show log;
import 'dart:io' show Platform;

import 'package:adhan/adhan.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adhan_controller.dart';
import 'monthly_prayer_cache.dart';
import 'prayer_cache_manager.dart';

/// PrayerSchedulerService
/// Handles scheduling of Adhan notifications using awesome_notifications.
/// This wraps the new AdhanController to provide a clean API for the UI and
/// for NotificationManager to call.
class PrayerSchedulerService {
  static final PrayerSchedulerService _instance =
      PrayerSchedulerService._internal();
  factory PrayerSchedulerService() => _instance;
  PrayerSchedulerService._internal();

  static const String _tag = 'PrayerSchedulerService';

  // ============================================================
  // Public API
  // ============================================================

  /// Entry point: called from main/NotificationManager on startup.
  /// Initializes AdhanController and schedules prayer notifications.
  Future<void> initialize({
    LatLng? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
    bool forceReschedule = false,
  }) async {
    try {
      log('🚀 Initializing PrayerSchedulerService...', name: _tag);

      // 1. Init AdhanController (calculates and caches prayer times)
      await AdhanController.instance.initializeStoredAdhan(
        newLocation: coordinates,
        forceUpdate: forceReschedule,
      );

      // 2. Schedule notifications in the background
      Future(() async {
        try {
          if (!forceReschedule &&
              !await _shouldReschedule(coordinates, cityName)) {
            log('✅ Skipping reschedule: up-to-date.', name: _tag);
            return;
          }

          await _cancelAllPrayerNotifications();
          await _scheduleAllPrayersForDays(
            coordinates: coordinates,
            calculationParams: calculationParams,
            cityName: cityName,
            days: days,
          );
          await _saveScheduleState(coordinates, cityName ?? 'Unknown');
          log('✅ Prayer notifications scheduled.', name: _tag);
        } catch (e) {
          log('❌ Error scheduling prayers: $e', name: _tag);
        }
      });
    } catch (e) {
      log('❌ Error initializing PrayerSchedulerService: $e', name: _tag);
    }
  }

  /// Force reschedule (called when user changes city/calculation method).
  Future<void> reschedule({
    LatLng? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    await initialize(
      coordinates: coordinates,
      calculationParams: calculationParams,
      cityName: cityName,
      days: days,
      forceReschedule: true,
    );
  }

  /// Cancel all scheduled prayer (adhan + pre-prayer + iqamah) notifications.
  Future<void> cancelAll() async => _cancelAllPrayerNotifications();

  // ============================================================
  // Scheduling logic
  // ============================================================

  Future<void> _scheduleAllPrayersForDays({
    LatLng? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    final savedLocation = coordinates ?? PrayerCacheManager.getStoredLocation();
    if (savedLocation == null) {
      log('⚠️ No location available to schedule.', name: _tag);
      return;
    }

    cityName ??= await _getSavedCityName();
    final params = calculationParams ?? _buildParams();

    log('📋 Scheduling for $days days...', name: _tag);
    int scheduledCount = 0;

    for (int day = 0; day < days; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final times = await _getPrayerTimesForDate(date, savedLocation, params);

      int prayerIndex = 0;
      for (final entry in times.entries) {
        final error = await _scheduleSinglePrayer(
          prayerName: entry.key,
          prayerTime: entry.value,
          dayOffset: day,
          prayerIndex: prayerIndex,
          cityName: cityName,
        );
        if (error == null) scheduledCount++;
        prayerIndex++;
      }
    }

    log('✅ Scheduled $scheduledCount prayers for $days days.', name: _tag);
  }

  /// Returns the prayer times map (Arabic names) for a given date.
  Future<Map<String, DateTime>> _getPrayerTimesForDate(
    DateTime date,
    LatLng location,
    CalculationParameters params,
  ) async {
    try {
      // Use MonthlyPrayerCache if available
      final cached = MonthlyPrayerCache.getPrayerTimesForDate(date);
      if (cached != null) {
        return {
          'الفجر': cached.fajr,
          'الشروق': cached.sunrise,
          'الظهر': cached.dhuhr,
          'العصر': cached.asr,
          'المغرب': cached.maghrib,
          'العشاء': cached.isha,
        };
      }

      // Fallback: calculate
      final prefs = await SharedPreferences.getInstance();
      final manualOffset = Duration(hours: prefs.getInt('manual_offset') ?? 0);
      final fOff = prefs.getInt('fajr_offset') ?? 0;
      final sOff = prefs.getInt('sunrise_offset') ?? 0;
      final dOff = prefs.getInt('dhuhr_offset') ?? 0;
      final aOff = prefs.getInt('asr_offset') ?? 0;
      final mOff = prefs.getInt('maghrib_offset') ?? 0;
      final iOff = prefs.getInt('isha_offset') ?? 0;

      final coords = Coordinates(location.latitude, location.longitude);
      final dc = DateComponents(date.year, date.month, date.day);
      final pt = PrayerTimes(coords, dc, params);

      return {
        'الفجر': pt.fajr.add(manualOffset).add(Duration(minutes: fOff)),
        'الشروق': pt.sunrise.add(manualOffset).add(Duration(minutes: sOff)),
        'الظهر': pt.dhuhr.add(manualOffset).add(Duration(minutes: dOff)),
        'العصر': pt.asr.add(manualOffset).add(Duration(minutes: aOff)),
        'المغرب': pt.maghrib.add(manualOffset).add(Duration(minutes: mOff)),
        'العشاء': pt.isha.add(manualOffset).add(Duration(minutes: iOff)),
      };
    } catch (e) {
      log('❌ Error calculating prayer times: $e', name: _tag);
      return _defaultPrayerTimes(date);
    }
  }

  CalculationParameters _buildParams() {
    final ctrl = AdhanController.instance;
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      return CalculationMethod.egyptian.getParameters();
    }
    return ctrl.state.params;
  }

  Future<String?> _scheduleSinglePrayer({
    required String prayerName,
    required DateTime prayerTime,
    required int dayOffset,
    required int prayerIndex,
    required String cityName,
  }) async {
    final now = DateTime.now();
    if (prayerTime.isBefore(now.subtract(const Duration(seconds: 5)))) {
      return 'time passed';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isPrePrayerEnabled =
          prefs.getBool('is_pre_prayer_reminder_enabled') ?? true;
      final bool isIqamahEnabled =
          prefs.getBool('is_iqamah_reminder_enabled') ?? true;
      final bool isSunriseEnabled =
          prefs.getBool('is_sunrise_reminder_enabled') ?? true;

      final uniqueId = 1000 + (dayOffset * 10) + prayerIndex;
      String effectivePrayerName = prayerName;
      if (prayerName == 'الظهر' && prayerTime.weekday == DateTime.friday) {
        effectivePrayerName = 'الجمعة';
      }

      // ── Pre-prayer reminder (15 minutes before)
      if (isPrePrayerEnabled && !prayerName.contains('الشروق')) {
        final prePrayerTime = prayerTime.subtract(const Duration(minutes: 15));
        if (prePrayerTime.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 40000 + uniqueId,
              channelKey: 'pre_prayer_channel_v1',
              icon: Platform.isAndroid
                  ? 'resource://drawable/ic_stat_logoapp'
                  : null,
              title: '\u200Fاقتربت صلاة $effectivePrayerName',
              body: '\u200Fباقي 15 دقيقة على صلاة $effectivePrayerName',
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
              autoDismissible: true,
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              payload: {
                'prayerName': effectivePrayerName,
                'type': 'pre_prayer'
              },
            ),
            schedule: NotificationCalendar.fromDate(
              date: prePrayerTime,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
          );
        }
      }

      // ── Iqamah reminder (15 minutes after Adhan)
      if (isIqamahEnabled && !prayerName.contains('الشروق')) {
        final iqamahTime = prayerTime.add(const Duration(minutes: 15));
        if (iqamahTime.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 50000 + uniqueId,
              channelKey: 'iqamah_channel_v1',
              icon: Platform.isAndroid
                  ? 'resource://drawable/ic_stat_logoapp'
                  : null,
              title: '\u200Fحان الآن موعد إقامة صلاة $effectivePrayerName',
              body: '\u200Fلاتنسي أذكار بعد الصلاة المفروضة',
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
              autoDismissible: true,
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              payload: {'prayerName': effectivePrayerName, 'type': 'iqamah'},
            ),
            schedule: NotificationCalendar.fromDate(
              date: iqamahTime,
              preciseAlarm: true,
              allowWhileIdle: true,
            ),
          );
        }
      }

      // ── Main Adhan notification
      bool shouldScheduleMain = true;
      String channelKey = prayerName.contains('الفجر')
          ? 'fajr_adhan_channel_v4'
          : 'adhan_channel_v4';

      if (prayerName.contains('الشروق')) {
        channelKey = 'shruq_channel_v1';
        if (!isSunriseEnabled) shouldScheduleMain = false;
      }

      if (shouldScheduleMain) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: uniqueId,
            channelKey: channelKey,
            icon: Platform.isAndroid
                ? 'resource://drawable/ic_stat_logoapp'
                : null,
            title: prayerName.contains('الشروق')
                ? '\u200Fحان الآن وقت الشروق'
                : '\u200Fحان الآن وقت صلاة $effectivePrayerName',
            body: prayerName.contains('الشروق')
                ? '\u200Fصلاة الضحى صلاة الأوابين وهي صدقة عن كل مفصل'
                : '\u200Fفي مدينة $cityName',
            category: NotificationCategory.Alarm,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            autoDismissible: true,
            locked: false,
            displayOnBackground: true,
            displayOnForeground: true,
            notificationLayout: NotificationLayout.BigText,
            color: const Color(0xFF178B74),
            payload: {
              'prayerName': effectivePrayerName,
              'prayer_time': _formatTime(prayerTime),
              'cityName': cityName,
              'route': 'adhan_screen',
              'type': 'adhan',
            },
          ),
          schedule: NotificationCalendar.fromDate(
            date: prayerTime,
            preciseAlarm: true,
            allowWhileIdle: true,
          ),
          actionButtons: [
            NotificationActionButton(
              key: 'STOP_ADHAN',
              label: 'إيقاف الأذان',
              actionType: ActionType.DismissAction,
              isDangerousOption: true,
            ),
            NotificationActionButton(
              key: 'MUTE_ADHAN',
              label: 'كتم الصوت',
              actionType: ActionType.DismissAction,
            ),
          ],
        );
      }

      return null; // success
    } catch (e) {
      log('❌ Error scheduling $prayerName: $e', name: _tag);
      return e.toString();
    }
  }

  // ============================================================
  // Helpers
  // ============================================================

  Future<void> _cancelAllPrayerNotifications() async {
    // Cancel by ranges used above (IDs 1000–9999 for adhan, 40000+ for pre-prayer, 50000+ for iqamah)
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v1');
    log('🗑️ All prayer notifications cancelled.', name: _tag);
  }

  Map<String, DateTime> _defaultPrayerTimes(DateTime date) => {
        'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
        'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
        'العصر': DateTime(date.year, date.month, date.day, 15, 15),
        'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
        'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
      };

  Future<String> _getSavedCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_city') ?? 'القاهرة';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  // ============================================================
  // Smart scheduling (skip if up to date)
  // ============================================================

  Future<bool> _shouldReschedule(LatLng? coords, String? cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRun = prefs.getInt('adhan_last_schedule_time') ?? 0;
    final lastHash = prefs.getString('adhan_settings_hash') ?? '';
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastRun = (now - lastRun) / (1000 * 60 * 60 * 24);
    if (daysSinceLastRun > 3) return true;
    final currentHash = _generateHash(coords, cityName);
    return currentHash != lastHash;
  }

  Future<void> _saveScheduleState(LatLng? coords, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'adhan_last_schedule_time', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(
        'adhan_settings_hash', _generateHash(coords, cityName));
  }

  String _generateHash(LatLng? coords, String? cityName) {
    final lat = coords?.latitude.toStringAsFixed(3) ?? '0';
    final lng = coords?.longitude.toStringAsFixed(3) ?? '0';
    return '${lat}_${lng}_${cityName ?? 'unknown'}';
  }
}
