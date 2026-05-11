import 'dart:developer' show log;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
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

    // Wait up to 10 seconds for initialization (5 attempts × 2s)
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('Prayer times not initialized. Waiting up to 10s...', name: _tag);
      for (int attempt = 0; attempt < 5; attempt++) {
        await Future.delayed(const Duration(seconds: 2));
        if (ctrl.state.isPrayerTimesInitialized.value) break;
      }
    }

    // Last resort: manual init
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('Attempting manual init...', name: _tag);
      await ctrl.initializeStoredAdhan();
    }

    // ⭐ [Critical Fix]: Don't cancel existing schedules on failure.
    // If init failed, keep whatever was scheduled and try again next time.
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('⚠️ [AdhanManager] Prayer times not initialized. Keeping existing schedules intact.',
          name: _tag);
      return; // Return WITHOUT canceling
    }

    // Cancel all previously scheduled adhan and shruq notifications efficiently
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v5');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v5');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v6');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_once');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_loop');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v3');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v3');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_iqamah_channel_v1');

    final now = DateTime.now();
    int scheduledCount = 0;

    // Read user preferences for adhan
    final prefs = await SharedPreferences.getInstance();
    final enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
    final enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
    final isPrePrayerEnabled =
        prefs.getBool('is_pre_prayer_reminder_enabled') ?? true;
    final isIqamahEnabled = prefs.getBool('is_iqamah_reminder_enabled') ?? true;
    final isFullAdhanEnabled = prefs.getBool('is_full_adhan_enabled') ?? true;
    final isBetweenAdhanIqamahEnabled =
        prefs.getBool('is_between_adhan_iqamah_enabled') ?? true;

    // ⭐ Sync city name for notifications
    final cityName = prefs.getString('selected_city') ?? '';
    ctrl.state.location = cityName;

    // Reschedule for next 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      // We fetch from the controller logic which includes offsets, cache, etc.
      // Use getPrayerTimesForDate → uses monthly cache first (more reliable)
      Map<String, DateTime> times = await ctrl.getPrayerTimesForDate(date);

      int prayerIndex = 0;
      for (final entry in times.entries) {
        final prayerKey = entry.key;
        final prayerTime = entry.value.toLocal();

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

        final uniqueId = 1000 + (day * 10) + prayerIndex;

        // Schedule Shuruq using the regular, non-repeating notification
        if (prayerKey == 'sunrise' || prayerKey == 'الشروق') {
          if (prayerTime.isAfter(now)) {
            await NotificationManager()
                .scheduleShruqNotification(prayerTime, uniqueId);
          }
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

        // ── Pre-prayer reminder (15 minutes before)
        if (isPrePrayerEnabled &&
            prayerKey != 'sunrise' &&
            arabicPrayerName != 'الشروق') {
          final prePrayerTime =
              prayerTime.subtract(const Duration(minutes: 15));
          if (prePrayerTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 40000 + uniqueId,
                channelKey: 'pre_prayer_channel_v3',
                title: '\u200Fاقتربت صلاة $arabicPrayerName',
                body: '\u200Fباقي 15 دقيقة على صلاة $arabicPrayerName',
                category: NotificationCategory.Alarm,
                timeoutAfter: const Duration(seconds: 15),
                wakeUpScreen: true,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
                criticalAlert: true,
                payload: {'prayerName': arabicPrayerName, 'type': 'pre_prayer'},
              ),
              schedule: NotificationCalendar.fromDate(
                date: prePrayerTime,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
          }
        }

        // ── Iqamah reminder (15 minutes after)
        if (isIqamahEnabled &&
            prayerKey != 'sunrise' &&
            arabicPrayerName != 'الشروق') {
          final iqamahTime = prayerTime.add(const Duration(minutes: 15));
          if (iqamahTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 50000 + uniqueId,
                channelKey: 'iqamah_channel_v3',
                title: '\u200Fحان الآن موعد إقامة صلاة $arabicPrayerName',
                body: '\u200Fلاتنسي أذكار بعد الصلاة المفروضة',
                category: NotificationCategory.Alarm,
                timeoutAfter: const Duration(seconds: 10),
                wakeUpScreen: true,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
                criticalAlert: true,
                payload: {'prayerName': arabicPrayerName, 'type': 'iqamah'},
              ),
              schedule: NotificationCalendar.fromDate(
                date: iqamahTime,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
          }
        }

        // ── Dua between Adhan and Iqamah (7 minutes after Adhan)
        if (isBetweenAdhanIqamahEnabled &&
            prayerKey != 'sunrise' &&
            arabicPrayerName != 'الشروق') {
          final duaTime = prayerTime.add(const Duration(minutes: 7));
          if (duaTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 60000 + uniqueId,
                channelKey: 'adhan_iqamah_channel_v1',
                title: 'الدعاء بين الأذان والإقامة',
                body: 'قال ﷺ: لا يُرد الدعاء بين الأذان والإقامة؛ فادعوا',
                // ⭐ Alarm = الأقوى (يوقظ الشاشة ويظهر فوق كل شيء)
                category: NotificationCategory.Reminder,
                timeoutAfter: const Duration(seconds: 20),
                locked: false,
                wakeUpScreen: true,
                criticalAlert: false,
                fullScreenIntent: false,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
                payload: {
                  'prayerName': arabicPrayerName,
                  'type': 'adhan_iqamah_reminder'
                },
              ),
              schedule: NotificationCalendar.fromDate(
                date: duaTime,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
          }
        }

        // ⭐ Native AwesomeNotifications Scheduling (Mirrors Salawat/Azkar)
        if (prayerTime.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: uniqueId,
              channelKey: prayerKey == 'fajr'
                  ? 'fajr_adhan_channel_v5'
                  : 'adhan_channel_v6',
              title: '\u200Fحان الآن وقت صلاة $arabicPrayerName',
              body:
                  '\u200Fفي مدينتك (${ctrl.state.location.isEmpty ? 'غير محددة' : ctrl.state.location})',
              category: NotificationCategory.Alarm,
              timeoutAfter: !isFullAdhanEnabled
                  ? const Duration(seconds: 28)
                  : (prayerKey == 'fajr'
                      ? const Duration(minutes: 4, seconds: 54)
                      : const Duration(minutes: 2, seconds: 16)),
              wakeUpScreen: true,
              fullScreenIntent: false,
              criticalAlert: true,
              icon: 'resource://drawable/ic_stat_logoapp',
              largeIcon: 'resource://drawable/ic_stat_logoapp',
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              payload: {
                'prayerName': arabicPrayerName,
                'cityName': ctrl.state.location,
                'type': 'adhan'
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
                label: 'إيقاف الصوت',
                actionType: ActionType.DismissAction,
                isDangerousOption: true,
              ),
            ],
          );
          scheduledCount++;
        }
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

  static Future<void> _cancelAllAdhanChannels() async {
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v5');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v5');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v6');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_once');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('shruq_channel_loop');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('pre_prayer_channel_v3');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v2');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('iqamah_channel_v3');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_iqamah_channel_v1');
  }
}
