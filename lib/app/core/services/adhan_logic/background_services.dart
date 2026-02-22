import 'dart:developer' show log;
import 'dart:io' show Platform;
import 'package:background_fetch/background_fetch.dart';

import 'prayer_background_manager.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    log('Headless task timed-out: $taskId', name: 'Background service');
    BackgroundFetch.finish(taskId);
    return;
  }

  log('Headless event received.', name: 'Background service');

  await _executeBackgroundTasks();

  BackgroundFetch.finish(taskId);
}

Future<void> _executeBackgroundTasks() async {
  try {
    await PrayerBackgroundManager.executePeriodicTasks();

    if (Platform.isIOS || Platform.isAndroid) {
      // Here we could call widget update services for rafuiqElmuslim
      // e.g., HomeWidgetService().updateWidgets();
    }
  } catch (e) {
    log('Error executing background tasks: $e', name: 'Background service');
  }
}

class BGServices {
  Future<void> registerTask() async {
    log('🚀 بدء تسجيل خدمات العمليات في الخلفية...',
        name: 'Background service');

    int status = await BackgroundFetch.status;
    log('Background fetch status: $status', name: 'Background service');

    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onFetch,
      _onTimeOut,
    );

    await BackgroundFetch.start().then((v) async {
      await _executeBackgroundTasks();
      log('Background service started successfully',
          name: 'Background service');
    }).catchError((e) {
      log('Error starting background service: $e', name: 'Background service');
    });

    try {
      await BackgroundFetch.scheduleTask(
        TaskConfig(
          taskId: 'com.rafiq.muslimdaily.fetchNotifications',
          delay: 15 * 60 * 1000,
          stopOnTerminate: false,
          enableHeadless: true,
          periodic: true,
        ),
      );
      log('Periodic task scheduled successfully', name: 'Background service');
    } catch (e) {
      log('Task scheduling error: $e', name: 'Background service');
    }
  }
}

Future<void> _onFetch(String taskId) async {
  log('Background fetch event received: $taskId', name: 'Background service');
  try {
    await _executeBackgroundTasks();
  } catch (e) {}
  BackgroundFetch.finish(taskId);
}

Future<void> _onTimeOut(String taskId) async {
  log('Background task timeout: $taskId', name: 'Background service');
  BackgroundFetch.finish(taskId);
}
