import 'dart:developer' show log;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adhan_controller.dart';
import 'prayer_cache_manager.dart';
import 'monthly_prayer_cache.dart';
import '../../adhan_system/manager/adhan_manager.dart';
import '../../services/settings_service.dart';
import '../../services/home_widget_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../notification_manager.dart';

class PrayerBackgroundManager {
  static const String _tag = 'PrayerBackgroundManager';

  // static Future<bool> checkAndUpdatePrayerTimes() async {
  //   try {
  //     log('Starting prayer times check...', name: _tag);
  //
  //     final currentLocation = await _getCurrentLocation();
  //     if (currentLocation == null) {
  //       log('Unable to get current location', name: _tag);
  //       return false;
  //     }
  //
  //     final isMonthlyValid = MonthlyPrayerCache.isMonthlyDataValid(
  //         currentLocation: currentLocation);
  //     final isDailyValid =
  //         PrayerCacheManager.isCacheValid(currentLocation: currentLocation);
  //
  //     if (isMonthlyValid || isDailyValid) {
  //       log('Prayer times cache is valid, no update needed', name: _tag);
  //       return false;
  //     }
  //
  //     log('Prayer times cache is invalid, updating...', name: _tag);
  //
  //     await AdhanController.instance.initializeStoredAdhan(
  //       newLocation: currentLocation,
  //       forceUpdate: true,
  //     );
  //
  //     await PrayerSchedulerService().reschedule();
  //
  //     log('Prayer times updated successfully', name: _tag);
  //     return true;
  //   } catch (e) {
  //     log('Error checking/updating prayer times: $e', name: _tag);
  //     return false;
  //   }
  // }
  static Future<bool> checkAndUpdatePrayerTimes() async {
    try {
      final currentLocation = await _getCurrentLocation();
      if (currentLocation == null) return false;

      final isMonthlyValid = MonthlyPrayerCache.isMonthlyDataValid(
          currentLocation: currentLocation);
      final isDailyValid =
          PrayerCacheManager.isCacheValid(currentLocation: currentLocation);

      // ✅ كلاهما صالح = لا حاجة للتحديث
      if (isMonthlyValid && isDailyValid) return false;

      await AdhanController.instance.initializeStoredAdhan(
        newLocation: currentLocation,
        forceUpdate: true,
      );

      await AdhanManager.rescheduleAll();
      return true;
    } catch (e) {
      log('Error: $e', name: _tag);
      return false;
    }
  }

  static Future<void> executePeriodicTasks() async {
    try {
      final settings = SettingsService();
      await settings.init();

      // 1. التحقق من تغير الموقع تلقائياً إذا كان مفعل
      if (settings.isAutoLocationEnabled) {
        await _checkAndUpdateAutoLocation();
      }

      // 2. تحديث مواعيد الصلاة (يومياً أو دورياً)
      if (await _shouldExecuteDailyTasks()) {
        await executeDailyTasks();
      } else {
        await checkAndUpdatePrayerTimes();
      }

      // 3. تحديث الويدجت
      if (settings.isHomeWidgetEnabled) {
        await updateHomeWidget();
      }
    } catch (e) {
      log('Error in executePeriodicTasks: $e', name: _tag);
    }
  }

  static Future<void> _checkAndUpdateAutoLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      final currentLoc = LatLng(position.latitude, position.longitude);
      final savedLocationData = PrayerCacheManager.getStoredLocation();

      if (savedLocationData != null) {
        final distance = Geolocator.distanceBetween(
          savedLocationData.latitude,
          savedLocationData.longitude,
          currentLoc.latitude,
          currentLoc.longitude,
        );

        // إذا تحرك المستخدم أكثر من 10 كيلومترات، نحدّث المواعيد
        if (distance > 10000) {
          log('Location change detected ($distance m). Updating prayer times...',
              name: _tag);
          await AdhanController.instance.initializeStoredAdhan(
            newLocation: currentLoc,
            forceUpdate: true,
          );
          await AdhanManager.rescheduleAll();
        }
      }
    } catch (e) {
      log('Error checking auto-location: $e', name: _tag);
    }
  }

  static Future<void> updateHomeWidget() async {
    try {
      final ctrl = AdhanController.instance;
      // التأكد من تهيئة البيانات
      if (!ctrl.state.isPrayerTimesInitialized.value) {
        await ctrl.initializeStoredAdhan();
      }

      final prayerTimes = ctrl.state.prayerTimes;
      if (prayerTimes != null) {
        final next = prayerTimes.nextPrayer();
        final nextTime = prayerTimes.timeForPrayer(next) ?? DateTime.now();
        final city = ctrl.state.location.isEmpty
            ? 'مدينة غير محددة'
            : ctrl.state.location;
        final nextPrayerName = _getPrayerNameArabic(next);

        await HomeWidgetService.updateFullPrayerWidget(
          fajrTime: DateFormat('hh:mm a').format(prayerTimes.fajr),
          sunriseTime: DateFormat('hh:mm a').format(prayerTimes.sunrise),
          dhuhrTime: DateFormat('hh:mm a').format(prayerTimes.dhuhr),
          asrTime: DateFormat('hh:mm a').format(prayerTimes.asr),
          maghribTime: DateFormat('hh:mm a').format(prayerTimes.maghrib),
          ishaTime: DateFormat('hh:mm a').format(prayerTimes.isha),
          nextPrayer: nextPrayerName,
          nextPrayerTime: nextTime,
          city: city,
        );

        await HomeWidgetService.updatePrayerTimesWidget(
          prayerName: nextPrayerName,
          prayerTime: DateFormat('hh:mm a').format(nextTime),
          city: city,
          nextPrayerTime: nextTime,
        );
      }
    } catch (e) {
      log('Error updating home widget: $e', name: _tag);
    }
  }

  static String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.sunrise:
        return 'الشروق';
      default:
        return 'الصلاة القادمة';
    }
  }

  static Future<LatLng?> _getCurrentLocation() async {
    final stored = PrayerCacheManager.getStoredLocation();
    if (stored != null) return stored;

    // ✅ Fallback حقيقي
    try {
      return await AdhanController.instance.detectCurrentLocation();
    } catch (e) {
      log('Location fallback failed: $e', name: _tag);
      return null;
    }
  }
  // static Future<LatLng?> _getCurrentLocation() async {
  //   try {
  //     final stored = PrayerCacheManager.getStoredLocation();
  //     if (stored != null) {
  //       return stored;
  //     }
  //     // If we need to fetch location dynamically, we rely on the AdhanController
  //     // which has `_detectCurrentLocation`. But usually stored is enough for background tasks.
  //   } catch (e) {
  //     log('Error getting location: $e', name: _tag);
  //   }
  //   return null;
  // }

  static Future<void> executeDailyTasks() async {
    try {
      log('Executing daily tasks...', name: _tag);

      // 1. Update prayer times
      await checkAndUpdatePrayerTimes();

      // 2. Update monthly data in background
      await AdhanController.instance.updateMonthlyDataInBackground();

      // 3. Refresh Azkar and Salawat notifications (To prevent them from "dying" due to OS battery optimization)
      log('Refreshing all notifications in background...', name: _tag);
      await NotificationManager().rescheduleAll();

      // 3. Update last daily task run date
      await _updateLastDailyTaskRun();

      log('Daily tasks completed successfully', name: _tag);
    } catch (e) {
      log('Error executing daily tasks: $e', name: _tag);
    }
  }

  // static Future<void> executePeriodicTasks() async {
  //   try {
  //     log('Executing periodic tasks...', name: _tag);
  //
  //     final updated = await checkAndUpdatePrayerTimes();
  //
  //     if (await _shouldExecuteDailyTasks()) {
  //       await executeDailyTasks();
  //     }
  //
  //     log('Periodic tasks completed ${updated ? "(prayer times updated)" : ""}',
  //         name: _tag);
  //   } catch (e) {
  //     log('Error executing periodic tasks: $e', name: _tag);
  //   }
  // }

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
