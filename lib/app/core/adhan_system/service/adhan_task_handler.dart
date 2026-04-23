import 'dart:developer' show log;
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:just_audio/just_audio.dart';

import 'adhan_foreground_service.dart';
import '../../services/adhan_logic/prayer_background_manager.dart';

class AdhanTaskHandler extends TaskHandler {
  static const String _tag = 'AdhanTaskHandler';
  AudioPlayer? _audioPlayer;

  /// Top-level callback fired by AndroidAlarmManager
  @pragma('vm:entry-point')
  static Future<void> alarmCallback(
      int alarmId, Map<String, dynamic> params) async {
    log('Alarm Triggered for ID: $alarmId with params: $params', name: _tag);

    // 1. Acquire CPU WakeLock so the device stays awake
    WakelockPlus.enable();

    // 2. Start Foreground Service to ensure aggressive OEMs don't kill the isolate
    final title = params['prayerName'] != null
        ? 'صلاة ${params['prayerName']}'
        : 'وقت الأذان';
    const body = 'حان الآن موعد الأذان';

    await AdhanForegroundService.startService(
      title: title,
      body: body,
      payload: params,
    );

    // 3. We no longer launch the app automatically to respect user's request to rely only on notifications.
    // Instead, we ensure the notification is high-priority and shows the prayer time.

    // 4. Force wake up using a high-priority notification on the silent channel
    // (We keep it silent to avoid double audio from foreground service audio player)
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: alarmId + 10000,
          channelKey: 'silent_adhan_channel',
          title: title,
          body: body,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent:
              true, // This makes it show on lock screen even without launching app
          criticalAlert: true,
          locked: true,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
      );
    } catch (e) {
      log('Failed to create notification: $e', name: _tag);
    }

    // 5. Instantly force update home widgets to jump to the *next* prayer
    try {
      // Need to import background manager if not imported
      await PrayerBackgroundManager.updateHomeWidget();
    } catch (e) {
      log('Failed to update home widgets on alarm: $e', name: _tag);
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    log('Foreground Task Started', name: _tag);
    _audioPlayer = AudioPlayer();

    // Check payload passed from the main isolate
    final prayerName =
        await FlutterForegroundTask.getData<String>(key: 'adhan_prayer_name');
    final isFajr = prayerName?.contains('الفجر') ?? false;
    final asset = isFajr ? 'assets/athan/fajr.mp3' : 'assets/athan/athan.mp3';

    try {
      await _audioPlayer?.setAsset(asset);
      _audioPlayer?.play();

      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          FlutterForegroundTask.stopService();
        }
      });
    } catch (e) {
      log('Error playing audio in isolate: $e', name: _tag);
      FlutterForegroundTask.stopService(); // Failsafe
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    log('Foreground Task Destroyed', name: _tag);
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();

    // Release WakeLock
    WakelockPlus.disable();
  }

  // onReceiveData removed in flutter_foreground_task 6.5.0

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}
