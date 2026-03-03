import 'dart:developer' show log;
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:just_audio/just_audio.dart';

import 'adhan_foreground_service.dart';

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
    final body = 'حان الآن موعد الأذان';

    await AdhanForegroundService.startService(
      title: title,
      body: body,
      payload: params,
    );

    // 3. Launch the full-screen activity (the app itself)
    // We send payload so the main UI knows it was opened by the alarm
    FlutterForegroundTask.launchApp('/');
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
