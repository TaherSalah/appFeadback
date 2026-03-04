import 'dart:developer' show log;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/adhan_logic/adhan_controller.dart';
import '../../services/notification_manager.dart';
import '../core/alarm_scheduler.dart';

class AdhanManager {
  static const String _tag = 'AdhanManager';

  /// Reschedules all exact alarms for the next 7 days based on the stored logic
  static Future<void> rescheduleAll() async {
    log('Rescheduling all Adhan exact alarms...', name: _tag);

    // Using the existing AdhanController to calculate times
    final ctrl = AdhanController.instance;
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('Prayer times not initialized. Cannot reschedule.', name: _tag);
      return;
    }

    // Cancel all previously scheduled precise alarms
    // (Assuming IDs 1000 - 9999 are reserved for our adhan alarms)
    for (int i = 1000; i < 9999; i++) {
      await AlarmScheduler.cancelAlarm(i);
    }
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_once');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_loop');

    final now = DateTime.now();
    int scheduledCount = 0;

    // Read user preferences for adhan
    final prefs = await SharedPreferences.getInstance();
    final enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
    final enableNormal = prefs.getBool('enableNormalAdhan') ?? true;

    // Reschedule for next 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      // We fetch from the controller logic which includes offsets, cache, etc.
      Map<String, DateTime>? times = await ctrl.getCalculatedTimesForDate(date);
      if (times == null) continue;

      int prayerIndex = 0;
      for (final entry in times.entries) {
        final prayerKey = entry.key;
        final prayerTime = entry.value;

        // Skip non-prayers or Shuruq handled separately
        if (prayerKey == 'midnight' || prayerKey == 'lastThird') {
          prayerIndex++;
          continue;
        }

        // Check if user disabled adhan types
        if (!enableFajr && prayerKey == 'fajr') {
          prayerIndex++;
          continue;
        }
        if (!enableNormal &&
            ['dhuhr', 'asr', 'maghrib', 'isha'].contains(prayerKey)) {
          prayerIndex++;
          continue;
        }

        // Skip past prayers
        if (prayerTime.isBefore(now)) {
          prayerIndex++;
          continue;
        }

        final uniqueId = 1000 + (day * 10) + prayerIndex;

        // Schedule Shuruq using the regular, non-repeating notification
        if (prayerKey == 'sunrise' || prayerKey == 'الشروق') {
          await NotificationManager()
              .scheduleShruqNotification(prayerTime, uniqueId);
          prayerIndex++;
          continue;
        }

        String arabicPrayerName = prayerKey;
        switch (prayerKey) {
          case 'fajr':
            arabicPrayerName = 'الفجر';
            break;
          case 'dhuhr':
            arabicPrayerName = 'الظهر';
            break;
          case 'asr':
            arabicPrayerName = 'العصر';
            break;
          case 'maghrib':
            arabicPrayerName = 'المغرب';
            break;
          case 'isha':
            arabicPrayerName = 'العشاء';
            break;
        }

        await AlarmScheduler.scheduleExactAlarm(
          id: uniqueId,
          time: prayerTime,
          payload: {
            'prayerName': arabicPrayerName,
            'cityName': ctrl.state.location.isEmpty
                ? 'مدينة غير محددة'
                : ctrl.state.location,
          },
        );
        scheduledCount++;
        prayerIndex++;
      }
    }

    log('Successfully rescheduled $scheduledCount exact alarms.', name: _tag);
  }

  /// Cancels all exact alarms
  static Future<void> cancelAll() async {
    log('Canceling all exact alarms...', name: _tag);
    for (int i = 1000; i < 9999; i++) {
      await AlarmScheduler.cancelAlarm(i);
    }
  }

  /// Test alarm scheduler
  static Future<void> scheduleTestAlarm({int seconds = 10}) async {
    final time = DateTime.now().add(Duration(seconds: seconds));
    log('Scheduling exact test alarm for $time', name: _tag);
    await AlarmScheduler.scheduleExactAlarm(
      id: 99999,
      time: time,
      payload: {
        'prayerName': 'اختبار',
        'cityName': 'اختبار',
      },
    );
  }
}
