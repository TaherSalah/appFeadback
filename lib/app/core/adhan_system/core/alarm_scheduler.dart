import 'dart:developer' show log;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../service/adhan_task_handler.dart';

class AlarmScheduler {
  static const String _tag = 'AlarmScheduler';

  /// Schedules an exact alarm that will wake up the device.
  static Future<bool> scheduleExactAlarm({
    required int id,
    required DateTime time,
    required Map<String, dynamic> payload,
  }) async {
    try {
      log('Scheduling exact alarm $id for $time', name: _tag);
      return await AndroidAlarmManager.oneShotAt(
        time,
        id,
        AdhanTaskHandler.alarmCallback, // Top-level callback
        wakeup: true,
        exact: true,
        allowWhileIdle: true,
        alarmClock: true,
        rescheduleOnReboot: true,
        // Passing payload so the callback knows which prayer it is
        params: payload,
      );
    } catch (e) {
      log('Error scheduling alarm: $e', name: _tag);
      return false;
    }
  }

  /// Cancels an alarm by ID
  static Future<bool> cancelAlarm(int id) async {
    log('Cancelling alarm $id', name: _tag);
    return await AndroidAlarmManager.cancel(id);
  }
}
