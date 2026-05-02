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
    // Check if initialized, if not wait a bit
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('Prayer times not initialized. Waiting...', name: _tag);
      await Future.delayed(const Duration(seconds: 2));
      if (!ctrl.state.isPrayerTimesInitialized.value) {
        log('Still not initialized. Attempting manual init...', name: _tag);
        await ctrl.initializeStoredAdhan();
      }
    }

    // ⭐ [Safety Check]: If not initialized, we CANNOT calculate times.
    if (!ctrl.state.isPrayerTimesInitialized.value) {
      log('❌ [AdhanManager] Prayer times not initialized. Canceling existing schedules.', name: _tag);
      await _cancelAllAdhanChannels();
      return;
    }

    // Cancel all previously scheduled adhan and shruq notifications efficiently
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_channel_v4');
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
        .cancelSchedulesByChannelKey('iqamah_channel_v1');
    await AwesomeNotifications()
        .cancelSchedulesByChannelKey('adhan_iqamah_channel_v1');

    final now = DateTime.now();
    int scheduledCount = 0;

    // Read user preferences for adhan
    final prefs = await SharedPreferences.getInstance();
    final enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
    final enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
    final isPrePrayerEnabled = prefs.getBool('is_pre_prayer_reminder_enabled') ?? true;
    final isIqamahEnabled = prefs.getBool('is_iqamah_reminder_enabled') ?? true;
    
    // ⭐ Sync city name for notifications
    final cityName = prefs.getString('selected_city') ?? '';
    ctrl.state.location = cityName;

    // Reschedule for next 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      // We fetch from the controller logic which includes offsets, cache, etc.
      Map<String, DateTime>? times = await ctrl.getCalculatedTimesForDate(date);

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

        // ── Pre-prayer reminder (15 minutes before)
        if (isPrePrayerEnabled && prayerKey != 'sunrise' && arabicPrayerName != 'الشروق') {
          final prePrayerTime = prayerTime.subtract(const Duration(minutes: 15));
          if (prePrayerTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 40000 + uniqueId,
                channelKey: 'pre_prayer_channel_v1',
                title: '\u200Fاقتربت صلاة $arabicPrayerName',
                body: '\u200Fباقي 15 دقيقة على صلاة $arabicPrayerName',
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
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
        if (isIqamahEnabled && prayerKey != 'sunrise' && arabicPrayerName != 'الشروق') {
          final iqamahTime = prayerTime.add(const Duration(minutes: 15));
          if (iqamahTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 50000 + uniqueId,
                channelKey: 'iqamah_channel_v1',
                title: '\u200Fحان الآن موعد إقامة صلاة $arabicPrayerName',
                body: '\u200Fلاتنسي أذكار بعد الصلاة المفروضة',
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
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
        final bool isBetweenAdhanIqamahEnabled = prefs.getBool('is_between_adhan_iqamah_enabled') ?? true;
        if (isBetweenAdhanIqamahEnabled && prayerKey != 'sunrise' && arabicPrayerName != 'الشروق') {
          final duaTime = prayerTime.add(const Duration(minutes: 7));
          if (duaTime.isAfter(now)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 60000 + uniqueId,
                channelKey: 'adhan_iqamah_channel_v1',
                title: 'الدعاء بين الأذان والإقامة',
                body: 'قال ﷺ: لا يُرد الدعاء بين الأذان والإقامة؛ فادعوا',
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
                autoDismissible: true,
                icon: 'resource://drawable/ic_stat_logoapp',
                largeIcon: 'resource://drawable/ic_stat_logoapp',
                notificationLayout: NotificationLayout.BigText,
                color: const Color(0xFF178B74),
                payload: {'prayerName': arabicPrayerName, 'type': 'adhan_iqamah_reminder'},
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
        // 🛠️ [تعديل تقني]: تم استبدال AlarmManager بنظام جدولة النظام الأصلي (Native)
        // هذا يضمن أن الأذان سيعمل حتى لو كان التطبيق مغلقاً تماماً والهاتف في وضع القفل (Lock Screen).
        // تم استلهام هذا الحل من إشعار "الصلاة على النبي" الذي أثبت كفاءته.
        // [تصحيح]: تم استخدام .toLocal() لضمان الموعد الصحيح حسب التوقيت المحلي للمستخدم.
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: uniqueId,
            channelKey: prayerKey == 'fajr'
                ? 'fajr_adhan_channel_v4'
                : 'adhan_channel_v4',
            title: '\u200Fحان الآن وقت صلاة $arabicPrayerName',
            body:
                '\u200Fفي مدينتك (${ctrl.state.location.isEmpty ? 'غير محددة' : ctrl.state.location})',
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
            // 🛠️ fullScreenIntent = false: هام جداً!
            // لو كان true فإن النظام يفتح واجهة التطبيق على شاشة القفل بدلاً من عرض الإشعار.
            // هذا كان سبب عدم ظهور الصوت والإشعار على شاشة القفل.
            fullScreenIntent: false,
            criticalAlert: false,
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
    await AwesomeNotifications().cancelSchedulesByChannelKey('fajr_adhan_channel_v4');
    await AwesomeNotifications().cancelSchedulesByChannelKey('adhan_channel_v4');
    await AwesomeNotifications().cancelSchedulesByChannelKey('shruq_channel_v1');
    await AwesomeNotifications().cancelSchedulesByChannelKey('shruq_channel_v2');
    await AwesomeNotifications().cancelSchedulesByChannelKey('shruq_channel_once');
    await AwesomeNotifications().cancelSchedulesByChannelKey('shruq_channel_loop');
    await AwesomeNotifications().cancelSchedulesByChannelKey('pre_prayer_channel_v1');
    await AwesomeNotifications().cancelSchedulesByChannelKey('iqamah_channel_v1');
    await AwesomeNotifications().cancelSchedulesByChannelKey('adhan_iqamah_channel_v1');
  }
}
