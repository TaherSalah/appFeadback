import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:muslimdaily/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// أداة تشخيص شاملة لنظام الأذان
class AdhanDiagnosticHelper {
  /// الحصول على تقرير تشخيصي كامل
  static Future<Map<String, dynamic>> getDiagnosticReport() async {
    final settings = await checkSettings();
    final permissions = await checkPermissions();
    final scheduled = await getScheduledAdhans();
    final errors = await getRecentErrors();
    final batteryOptimization = await checkBatteryOptimization();
    final deviceBrand = await getDeviceBrand();

    return {
      'settings': settings,
      'permissions': permissions,
      'scheduled_count': scheduled.length,
      'scheduled_notifications': scheduled,
      'recent_errors': errors,
      'battery_optimization_disabled': batteryOptimization,
      'device_brand': deviceBrand,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// الحصول على ماركة الجهاز
  static Future<String> getDeviceBrand() async {
    if (!Platform.isAndroid) return 'iOS';
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.manufacturer.toLowerCase();
    } catch (e) {
      return 'unknown';
    }
  }

  /// التحقق مما إذا كان نظام الأذان لا يعمل بكفاءة
  static Future<bool> isAdhanUnhealthy() async {
    if (!Platform.isAndroid) return false;

    final settings = await checkSettings();
    if (!settings['adhan_enabled']!) return false;

    final permissions = await checkPermissions();
    final batteryOptimizationDisabled = await checkBatteryOptimization();

    // نعتبر النظام غير صحي إذا كان أي من الأذونات الأساسية معطلاً
    // أو إذا كانت تحسينات البطارية مفعلة
    // ملاحظة: تم استبعاد display_over_apps لتجنب مشاكل سياسة جوجل بلاي
    if (!permissions['notifications_allowed']! ||
        !permissions['schedule_exact_alarm']! ||
        !batteryOptimizationDisabled) {
      return true;
    }

    return false;
  }

  /// فحص جميع الإشعارات المجدولة للأذان
  static Future<List<Map<String, dynamic>>> getScheduledAdhans() async {
    try {
      final scheduled =
          await AwesomeNotifications().listScheduledNotifications();

      // تصفية الإشعارات الخاصة بالأذان فقط
      final adhanNotifications = scheduled.where((notification) {
        final channelKey = notification.content?.channelKey ?? '';
        return channelKey.contains('adhan') ||
            channelKey.contains('fajr') ||
            channelKey.contains('pre_prayer') ||
            channelKey.contains('iqamah') ||
            channelKey.contains('shruq');
      }).toList();

      // تحويل إلى قائمة قابلة للقراءة
      return adhanNotifications.map((notification) {
        final schedule = notification.schedule;
        DateTime? scheduledTime;

        if (schedule is NotificationCalendar) {
          final now = DateTime.now();
          scheduledTime = DateTime(
            schedule.year ?? now.year,
            schedule.month ?? now.month,
            schedule.day ?? now.day,
            schedule.hour ?? 0,
            schedule.minute ?? 0,
            schedule.second ?? 0,
          );
        }

        return {
          'id': notification.content?.id,
          'title': notification.content?.title,
          'body': notification.content?.body,
          'channel': notification.content?.channelKey,
          'scheduled_time': scheduledTime?.toString() ?? 'Unknown',
          'payload': notification.content?.payload,
        };
      }).toList();
    } catch (e) {
      logger.e('❌ خطأ في جلب الإشعارات المجدولة: $e');
      return [];
    }
  }

  /// فحص إعدادات الأذان
  static Future<Map<String, bool>> checkSettings() async {
    await SettingsService().init();
    final settings = SettingsService();

    return {
      'adhan_enabled': settings.isAdhanEnabled,
      'pre_prayer_enabled': settings.isPrePrayerReminderEnabled,
      'iqamah_enabled': settings.isIqamahReminderEnabled,
      'sunrise_enabled': settings.isSunriseReminderEnabled,
      'post_prayer_enabled': settings.isPostPrayerReminderEnabled,
      'adhan_vibration_enabled': settings.isAdhanVibrationEnabled,
    };
  }

  /// فحص الأذونات المطلوبة
  static Future<Map<String, bool>> checkPermissions() async {
    final notificationAllowed =
        await AwesomeNotifications().isNotificationAllowed();

    bool scheduleExactAlarm = true;
    bool ignoreBatteryOptimizations = false;
    bool displayOverApps = true;

    if (Platform.isAndroid) {
      try {
        // فحص صلاحية جدولة المنبهات الدقيقة (Android 12+)
        scheduleExactAlarm =
            await AwesomeNotifications().isNotificationAllowed();

        // فحص تحسين البطارية
        final status = await Permission.ignoreBatteryOptimizations.status;
        ignoreBatteryOptimizations = status.isGranted;

        // فحص صلاحية الظهور فوق التطبيقات
        final overlayStatus = await Permission.systemAlertWindow.status;
        displayOverApps = overlayStatus.isGranted;
      } catch (e) {
        logger.e('❌ خطأ في فحص الأذونات: $e');
      }
    }

    return {
      'notifications_allowed': notificationAllowed,
      'schedule_exact_alarm': scheduleExactAlarm,
      'ignore_battery_optimizations': ignoreBatteryOptimizations,
      'display_over_apps': displayOverApps,
    };
  }

  /// فحص صلاحية الظهور فوق التطبيقات
  static Future<bool> checkSystemAlertWindow() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.systemAlertWindow.status;
      return status.isGranted;
    } catch (e) {
      logger.e('❌ خطأ في فحص System Alert Window: $e');
      return false;
    }
  }

  /// فحص تحسين البطارية
  static Future<bool> checkBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      logger.e('❌ خطأ في فحص Battery Optimization: $e');
      return false;
    }
  }

  /// الحصول على آخر الأخطاء المسجلة
  static Future<List<String>> getRecentErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('adhan_errors') ?? [];
    } catch (e) {
      logger.e('❌ خطأ في جلب الأخطاء: $e');
      return [];
    }
  }

  /// حفظ خطأ جديد
  static Future<void> logError(String error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errors = prefs.getStringList('adhan_errors') ?? [];
      errors.insert(0, '${DateTime.now().toIso8601String()}: $error');
      // الاحتفاظ بآخر 20 خطأ فقط
      await prefs.setStringList('adhan_errors', errors.take(20).toList());
    } catch (e) {
      logger.e('❌ خطأ في حفظ الخطأ: $e');
    }
  }

  /// مسح سجل الأخطاء
  static Future<void> clearErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('adhan_errors');
    } catch (e) {
      logger.e('❌ خطأ في مسح الأخطاء: $e');
    }
  }

  /// الحصول على معلومات آخر جدولة
  static Future<Map<String, dynamic>> getLastScheduleInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastScheduleTime = prefs.getInt('adhan_last_schedule_time') ?? 0;
      final lastSettingsHash = prefs.getString('adhan_settings_hash') ?? '';

      final lastScheduleDate = lastScheduleTime > 0
          ? DateTime.fromMillisecondsSinceEpoch(lastScheduleTime)
          : null;

      final daysSinceLastSchedule = lastScheduleDate != null
          ? DateTime.now().difference(lastScheduleDate).inDays
          : -1;

      return {
        'last_schedule_time': lastScheduleDate?.toString() ?? 'Never',
        'days_since_last_schedule': daysSinceLastSchedule,
        'settings_hash': lastSettingsHash,
      };
    } catch (e) {
      logger.e('❌ خطأ في جلب معلومات الجدولة: $e');
      return {
        'last_schedule_time': 'Error',
        'days_since_last_schedule': -1,
        'settings_hash': '',
      };
    }
  }

  /// إنشاء تقرير نصي كامل
  static Future<String> generateTextReport() async {
    final report = await getDiagnosticReport();
    final scheduleInfo = await getLastScheduleInfo();

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📊 تقرير تشخيص نظام الأذان');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🕐 الوقت: ${report['timestamp']}');
    buffer.writeln();

    // الإعدادات
    buffer.writeln('⚙️ الإعدادات:');
    final settings = report['settings'] as Map<String, bool>;
    settings.forEach((key, value) {
      buffer.writeln('  ${value ? '✅' : '❌'} $key');
    });
    buffer.writeln();

    // الأذونات
    buffer.writeln('🔐 الأذونات:');
    final permissions = report['permissions'] as Map<String, bool>;
    permissions.forEach((key, value) {
      buffer.writeln('  ${value ? '✅' : '❌'} $key');
    });
    buffer.writeln();

    // تحسين البطارية
    buffer.writeln('🔋 تحسين البطارية:');
    buffer.writeln(
        '  ${report['battery_optimization_disabled'] ? '✅' : '❌'} معطّل (مطلوب)');
    buffer.writeln();

    // الجدولة
    buffer.writeln('📅 معلومات الجدولة:');
    buffer.writeln('  آخر جدولة: ${scheduleInfo['last_schedule_time']}');
    buffer.writeln('  منذ: ${scheduleInfo['days_since_last_schedule']} يوم');
    buffer.writeln('  عدد الإشعارات المجدولة: ${report['scheduled_count']}');
    buffer.writeln();

    // الإشعارات المجدولة
    if (report['scheduled_count'] > 0) {
      buffer.writeln('🔔 الإشعارات المجدولة:');
      final scheduled =
          report['scheduled_notifications'] as List<Map<String, dynamic>>;
      for (var notification in scheduled.take(10)) {
        buffer.writeln('  • ${notification['title']}');
        buffer.writeln('    الوقت: ${notification['scheduled_time']}');
        buffer.writeln('    القناة: ${notification['channel']}');
      }
      if (scheduled.length > 10) {
        buffer.writeln('  ... و ${scheduled.length - 10} إشعار آخر');
      }
      buffer.writeln();
    }

    // الأخطاء
    final errors = report['recent_errors'] as List<String>;
    if (errors.isNotEmpty) {
      buffer.writeln('❌ آخر الأخطاء:');
      for (var error in errors.take(5)) {
        buffer.writeln('  • $error');
      }
      if (errors.length > 5) {
        buffer.writeln('  ... و ${errors.length - 5} خطأ آخر');
      }
    } else {
      buffer.writeln('✅ لا توجد أخطاء مسجلة');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }
}
