import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/services/system_control_service.dart';

// ✅ دالة الـ Callback المبسطة - تشغيل الأذان عبر قنوات الإشعارات
@pragma('vm:entry-point')
void alarmCallback(int id) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🔊 [AlarmCallback] بدء معالجة الأذان (ID: $id)");
    print("🕑 الوقت الحالي: ${DateTime.now()}");
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

    // 🔴 [Auto-Silent] Activate if enabled
    if (prefs.getBool('is_auto_silent_enabled') ?? false) {
      final duration = prefs.getInt('auto_silent_duration') ?? 20;
      await SystemControlService().activateSilentMode(duration);
    }

    // 2️⃣ تهيئة AwesomeNotifications بكافة القنوات
    await NotificationManager.updateAllChannels();

    // 3️⃣ تحديد القناة المناسبة
    final bool isFajr = prayerName.contains('الفجر');
    String channelKey = isFajr ? 'fajr_adhan_channel_v4' : 'adhan_channel_v4';

    print("🔔 إرسال إشعار على قناة: $channelKey");

    // 4️⃣ إرسال الإشعار (الصوت يعمل تلقائياً من النظام)
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: isFajr
            ? '\u200F🌅 حان الآن موعد أذان الفجر'
            : '\u200F🕌 حان الآن موعد أذان $prayerName',
        body:
            '\u200F$cityName - $prayerTime\n${_getPrayerDescription(prayerName)}',
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        locked: false,
        autoDismissible: true,
        backgroundColor: isFajr ? Colors.orange : Colors.green,
        color: Colors.white,
        payload: {
          'prayerName': prayerName,
          'cityName': cityName,
          'prayer_time': prayerTime,
          'id': id.toString(),
        },
      ),
      actionButtons: (prefs.getBool('is_stop_action_enabled') ?? true)
          ? [
              NotificationActionButton(
                color: KColors.primaryColor,
                key: 'STOP_ADHAN',
                label: 'إيقاف الأذان',
                actionType: ActionType.DismissAction,
                isDangerousOption: true,
              ),
              NotificationActionButton(
                color: Colors.red,
                key: 'MUTE_ADHAN',
                label: 'كتم الصوت',
                actionType: ActionType.DismissAction,
              ),
            ]
          : null,
    );

    print("✅ تم إرسال الإشعار بنجاح (ID: $notificationId)");
    print("✅ اكتمل callback الأذان");
  } catch (e, s) {
    print("❌ خطأ في alarmCallback: $e");
    print("Stack: $s");
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

  static Future<void> showBatteryOptimizationDialog(
      BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();
    if (isDisabled || !context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // جسم الديالوج
              Container(
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF0B2B1D), const Color(0xFF052015)]
                        : [const Color(0xFFF2FFF9), const Color(0xFFE1FFF2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Text(
                      'تنبيه هام',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // النص التوضيحي
                    Text(
                      'لضمان عمل الأذان في الخلفية بشكل صحيح، يجب إيقاف وضع توفير البطارية للتطبيق لضمان عدم توقفه.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // كارت الخطوات
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.teal.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 20,
                              color: isDark ? Colors.tealAccent : Colors.teal),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'في الإعدادات، ابحث عن اسم التطبيق واختر "عدم التحسين" أو "Don\'t optimize"',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'لاحقاً',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              final granted =
                                  await requestBatteryOptimization();
                              if (!granted) {
                                await openBatteryOptimizationSettings();
                              }
                            },
                            icon: const Icon(Icons.settings, size: 18),
                            label: const Text('فتح الإعدادات'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // الأيقونة العلوية
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.green],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.battery_saver_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
