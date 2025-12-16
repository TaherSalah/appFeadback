// lib/background/adhan_callback.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io';

// ✅ دالة الـ Callback المبسطة - بدون تشغيل صوت يدوي
@pragma('vm:entry-point')
void alarmCallback(int id) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🔊 [AlarmCallback] بدء معالجة الأذان (ID: $id)");
    print("🕐 الوقت الحالي: ${DateTime.now()}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // 1️⃣ استرجاع البيانات
    final prefs = await SharedPreferences.getInstance();
    final prayerName = prefs.getString('prayer_name_$id') ?? 'الصلاة';
    final cityName = prefs.getString('city_name_$id') ?? '';
    final prayerTime = prefs.getString('prayer_time_$id') ?? '';

    print("📋 البيانات المسترجعة:");
    print("   🕌 الصلاة: $prayerName");
    print("   📍 المدينة: $cityName");
    print("   ⏰ الوقت: $prayerTime");

    // 2️⃣ تهيئة AwesomeNotifications
    await _initAwesomeNotifications();

    // 3️⃣ تحديد القناة المناسبة
    final bool isFajr = prayerName.contains('الفجر');
    String channelKey = isFajr ? 'fajr_adhan_channel_v2' : 'adhan_channel_v2';

    print("🔔 إرسال إشعار على قناة: $channelKey");

    // 4️⃣ إرسال الإشعار (الصوت هيشتغل تلقائياً من القناة)
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: isFajr ? '\u200F🌅 حان الآن موعد أذان الفجر' : '\u200F🕌 حان الآن موعد أذان $prayerName',
        body: '\u200F$cityName - $prayerTime\n${_getPrayerDescription(prayerName)}',
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        locked: true,
        autoDismissible: false,
        backgroundColor: isFajr ? Colors.orange : Colors.green,
        color: Colors.white,
        payload: {
          'prayerName': prayerName,
          'cityName': cityName,
          'id': id.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'إيقاف',
          actionType: ActionType.DismissAction,
          isDangerousOption: false,
        ),
      ],
    );

    print("✅ تم إرسال الإشعار بنجاح (ID: $notificationId)");

    // 5️⃣ انتظار 3 دقائق ثم إرسال إشعار الانتهاء
    await Future.delayed(const Duration(minutes: 3));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId + 1,
        channelKey: 'athkar_channel',
        title: '✅ انتهى وقت أذان $prayerName',
        body: prayerName.contains('الفجر')
            ? 'الصلاة خير من النوم، تقبل الله طاعتكم'
            : 'حي على الصلاة، حي على الفلاح',
        notificationLayout: NotificationLayout.Default,
      ),
    );

    print("✅ اكتمل callback الأذان");

  } catch (e, s) {
    print("❌ خطأ في alarmCallback: $e");
    print("Stack: $s");
  }
}

// ✅ تهيئة مبسطة لـ AwesomeNotifications
Future<void> _initAwesomeNotifications() async {
  try {
    await AwesomeNotifications().initialize(
      null,
      [
        // 🌅 أذان الفجر
        NotificationChannel(
          channelKey: 'fajr_adhan_channel',
          channelName: 'أذان الفجر',
          channelDescription: 'تشغيل أذان الفجر',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/fajr', // ✅ الصوت من raw folder
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.orange,
          criticalAlerts: true,
          locked: true,
        ),

        // 🕌 الأذان العادي
        NotificationChannel(
          channelKey: 'adhan_channel',
          channelName: 'أذان الصلاة',
          channelDescription: 'تشغيل صوت الأذان',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/athan', // ✅ الصوت من raw folder
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.green,
          criticalAlerts: true,
          locked: true,
        ),

        // 📿 قناة للإشعارات العادية
        NotificationChannel(
          channelKey: 'athkar_channel',
          channelName: 'الأذكار',
          channelDescription: 'إشعارات عامة',
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );
    print('✅ تم تهيئة AwesomeNotifications في الخلفية');
  } catch (e) {
    print('❌ فشل تهيئة AwesomeNotifications: $e');
  }
}

String _getPrayerDescription(String prayerName) {
  if (prayerName.contains('الفجر')) {
    return 'رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا';
  } else if (prayerName.contains('الظهر')) {
    return 'مَن غَدَا إلى المَسجدِ أو راح أعَدّ الله له نُزُلًا';
  } else if (prayerName.contains('العصر')) {
    return 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ';
  } else if (prayerName.contains('المغرب')) {
    return 'اللهم هذا إقبال ليلك وإدبار نهارك';
  } else if (prayerName.contains('العشاء')) {
    return 'من صلى العشاء في جماعة فكأنما قام نصف الليل';
  }
  return 'الله أكبر الله أكبر';
}

// ═══════════════════════════════════════════════════════════
// 🔋 Battery Optimization Helper
// ═══════════════════════════════════════════════════════════

class BatteryOptimizationHelper {
  static Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    try {
      var status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      print('❌ خطأ في فحص Battery: $e');
      return false;
    }
  }

  static Future<bool> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    try {
      var status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (e) {
      print('❌ خطأ في طلب Battery: $e');
      return false;
    }
  }

  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      const intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      try {
        await openAppSettings();
      } catch (e2) {
        print('❌ فشل فتح الإعدادات');
      }
    }
  }

  static Future<void> showBatteryOptimizationDialog(BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();
    if (isDisabled || !context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.battery_alert, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              const Expanded(child: Text('⚠️ تنبيه هام')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لضمان عمل الأذان في الخلفية بشكل صحيح، يجب إيقاف وضع توفير البطارية للتطبيق.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  '📌 في الإعدادات، ابحث عن اسم التطبيق واختر "عدم التحسين" أو "Don\'t optimize"',
                  style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final granted = await requestBatteryOptimization();
                if (!granted) {
                  await openBatteryOptimizationSettings();
                }
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('فتح الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}