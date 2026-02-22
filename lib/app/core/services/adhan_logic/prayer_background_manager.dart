import 'dart:developer' show log;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adhan_controller.dart';
import 'prayer_cache_manager.dart';
import 'monthly_prayer_cache.dart';
import 'prayer_scheduler_service.dart';

class PrayerBackgroundManager {
  static const String _tag = 'PrayerBackgroundManager';

  static Future<bool> checkAndUpdatePrayerTimes() async {
    try {
      log('Starting prayer times check...', name: _tag);

      final currentLocation = await _getCurrentLocation();
      if (currentLocation == null) {
        log('Unable to get current location', name: _tag);
        return false;
      }

      final isMonthlyValid = MonthlyPrayerCache.isMonthlyDataValid(
          currentLocation: currentLocation);
      final isDailyValid =
          PrayerCacheManager.isCacheValid(currentLocation: currentLocation);

      if (isMonthlyValid || isDailyValid) {
        log('Prayer times cache is valid, no update needed', name: _tag);
        return false;
      }

      log('Prayer times cache is invalid, updating...', name: _tag);

      await AdhanController.instance.initializeStoredAdhan(
        newLocation: currentLocation,
        forceUpdate: true,
      );

      await PrayerSchedulerService().reschedule();

      log('Prayer times updated successfully', name: _tag);
      return true;
    } catch (e) {
      log('Error checking/updating prayer times: $e', name: _tag);
      return false;
    }
  }

  static Future<LatLng?> _getCurrentLocation() async {
    try {
      final stored = PrayerCacheManager.getStoredLocation();
      if (stored != null) {
        return stored;
      }
      // If we need to fetch location dynamically, we rely on the AdhanController
      // which has `_detectCurrentLocation`. But usually stored is enough for background tasks.
    } catch (e) {
      log('Error getting location: $e', name: _tag);
    }
    return null;
  }

  static Future<void> executeDailyTasks() async {
    try {
      log('Executing daily tasks...', name: _tag);

      // 1. Update prayer times
      await checkAndUpdatePrayerTimes();

      // 2. Update monthly data in background
      await AdhanController.instance.updateMonthlyDataInBackground();

      // 3. Update last daily task run date
      await _updateLastDailyTaskRun();

      log('Daily tasks completed successfully', name: _tag);
    } catch (e) {
      log('Error executing daily tasks: $e', name: _tag);
    }
  }

  static Future<void> executePeriodicTasks() async {
    try {
      log('Executing periodic tasks...', name: _tag);

      final updated = await checkAndUpdatePrayerTimes();

      if (await _shouldExecuteDailyTasks()) {
        await executeDailyTasks();
      }

      log('Periodic tasks completed ${updated ? "(prayer times updated)" : ""}',
          name: _tag);
    } catch (e) {
      log('Error executing periodic tasks: $e', name: _tag);
    }
  }

  static Future<bool> _shouldExecuteDailyTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRun = prefs.getString('last_daily_task_run');

      if (lastRun == null) return true;

      final lastRunDate = DateTime.parse(lastRun);
      final now = DateTime.now();

      return now.difference(lastRunDate).inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  static Future<void> _updateLastDailyTaskRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'last_daily_task_run', DateTime.now().toIso8601String());
    } catch (e) {
      log('Error updating last daily task run: $e', name: _tag);
    }
  }
}
