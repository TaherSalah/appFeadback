import 'dart:developer' show log;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'adhan_task_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(AdhanTaskHandler());
}

class AdhanForegroundService {
  static const String _tag = 'AdhanForegroundService';

  /// Call this inside main.dart before runApp or extremely early
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'adhan_foreground_service',
        channelName: 'إشعار الأذان النشط',
        channelDescription: 'يضمن عمل الأذان بصوت عالٍ حتى لو الشاشة مغلقة.',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'stop', text: 'إيقاف'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: true,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    log('Starting Foreground Service...', name: _tag);

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: body,
        callback: startCallback,
      );
    }

    // Post the payload to the isolate via SharedPreferences/saveData
    final prayerName = payload['prayerName']?.toString() ?? '';
    await FlutterForegroundTask.saveData(
        key: 'adhan_prayer_name', value: prayerName);
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
