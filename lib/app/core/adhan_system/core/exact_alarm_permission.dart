import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

class ExactAlarmPermission {
  static Future<bool> checkAndRequestExactAlarm() async {
    if (!Platform.isAndroid) return true;

    // Android 12+ required exact alarm scheduling
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) return false;
    }
    return true;
  }

  static Future<void> checkAndRequestBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    // Check if the app is already exempt from aggressive battery killing
    bool? isIgnored =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    if (isIgnored != true) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  static Future<void> requestAllRequiredPermissions() async {
    await checkAndRequestExactAlarm();
    await checkAndRequestBatteryOptimization();

    if (Platform.isAndroid) {
      await Permission.notification.request();
      await Permission.systemAlertWindow.request();
    }
  }
}
