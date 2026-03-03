import 'dart:developer' show log;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../manager/adhan_manager.dart';

class RebootReceiver {
  static const String _tag = 'RebootReceiver';

  /// Pragma entry point to be called by AndroidAlarmManager on boot
  @pragma('vm:entry-point')
  static Future<void> onReboot() async {
    log('Device rebooted. Rescheduling all Adhan exact alarms.', name: _tag);
    // Initialize required services in the background isolate
    await AndroidAlarmManager.initialize();

    // Call our manager to recalculate and schedule everything silently
    await AdhanManager.rescheduleAll();
  }
}
