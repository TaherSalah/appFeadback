// lib/background/adhan_callback.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/shard/exports/all_exports.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    // تهيئة الـ notifications هنا
    final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('ic_stat_logoapp');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await notifications.initialize(initSettings);

    // باقي منطق تشغيل الأذان + الإشعار...
    return Future.value(true);
  });
}
