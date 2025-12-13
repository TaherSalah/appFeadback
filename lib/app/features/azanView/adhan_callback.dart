// // lib/background/adhan_callback.dart
// import 'package:muslimdaily/app/core/utils/style/k_color.dart';
// import 'package:workmanager/workmanager.dart';
//
// import '../../core/shard/exports/all_exports.dart';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:android_intent_plus/android_intent.dart';
//
//
//
//
//
// class BatteryOptimizationHelper {
//   /// التحقق من حالة Battery Optimization
//   static Future<bool> isBatteryOptimizationDisabled() async {
//     if (!Platform.isAndroid) return true;
//
//     try {
//       // فحص صلاحية ignoreBatteryOptimizations
//       var status = await Permission.ignoreBatteryOptimizations.status;
//       return status.isGranted;
//     } catch (e) {
//       print('❌ خطأ في فحص Battery Optimization: $e');
//       return false;
//     }
//   }
//
//   /// طلب تعطيل Battery Optimization
//   static Future<bool> requestBatteryOptimization() async {
//     if (!Platform.isAndroid) return true;
//
//     try {
//       var status = await Permission.ignoreBatteryOptimizations.request();
//       return status.isGranted;
//     } catch (e) {
//       print('❌ خطأ في طلب Battery Optimization: $e');
//       return false;
//     }
//   }
//
//   /// فتح صفحة إعدادات Battery Optimization مباشرة
//   static Future<void> openBatteryOptimizationSettings() async {
//     if (!Platform.isAndroid) return;
//
//     try {
//       // طريقة 1: فتح صفحة Battery Optimization للتطبيق مباشرة
//       const intent = AndroidIntent(
//         action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
//       );
//       await intent.launch();
//     } catch (e) {
//       print('❌ خطأ في فتح إعدادات Battery: $e');
//
//       // طريقة بديلة: فتح إعدادات التطبيق العامة
//       try {
//         await openAppSettings();
//       } catch (e2) {
//         print('❌ خطأ في فتح إعدادات التطبيق: $e2');
//       }
//     }
//   }
//
//   /// عرض Dialog تحذيري مع زر للانتقال للإعدادات
//   static Future<void> showBatteryOptimizationDialog(BuildContext context) async {
//     final isDisabled = await isBatteryOptimizationDisabled();
//     if (isDisabled) return;
//     if (!context.mounted) return;
//
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           backgroundColor: Colors.transparent,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               // جسم الديالوج
//               Container(
//                 padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(24),
//                   gradient: LinearGradient(
//                     begin: Alignment.topRight,
//                     end: Alignment.bottomLeft,
//                     colors: isDark
//                         ? [const Color(0xFF1B0A0A), const Color(0xFF200505)]
//                         : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 18,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // العنوان
//                     Text(
//                       ' تنبيه هام',
//                       style: GoogleFonts.cairo(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // الرسالة
//                     Text(
//                       'لضمان عمل الأذان في الخلفية بشكل صحيح، يجب إيقاف وضع توفير البطارية للتطبيق.',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.cairo(
//                         fontSize: 14,
//                         height: 1.5,
//                         color: isDark ? Colors.white70 : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       '📌 سنوجهك الآن إلى الإعدادات لتفعيل هذا الخيار\n📌 ابحث عن اسم التطبيق واختر "عدم التحسين" أو "Don\'t optimize"',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.cairo(
//                         fontSize: 13,
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 22),
//
//                     // الأزرار
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.of(dialogContext).pop(),
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(
//                                 color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 11),
//                             ),
//                             child: Text(
//                               'لاحقاً',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: isDark ? Colors.white : Colors.grey.shade800,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               Navigator.of(dialogContext).pop();
//
//                               // محاولة طلب الصلاحية أولاً
//                               final granted = await requestBatteryOptimization();
//
//                               if (!granted) {
//                                 // إذا فشلت، فتح الإعدادات
//                                 await openBatteryOptimizationSettings();
//                               }
//                             },
//                             icon: const Icon(Icons.settings, size: 20),
//                             label: const Text('فتح الإعدادات'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: KColors.primaryColor,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 11),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // الأيقونة العلوية
//               Positioned(
//                 top: -30,
//                 left: 0,
//                 right: 0,
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         colors: [Colors.orange, Colors.deepOrange],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.orange.withOpacity(0.5),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Icon(
//                         Icons.battery_alert,
//                         size: 34,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// عرض SnackBar بسيط إذا كان Battery Optimization مفعّل
//   static Future<void> showBatteryOptimizationSnackBar(BuildContext context) async {
//     final isDisabled = await isBatteryOptimizationDisabled();
//
//     if (isDisabled || !context.mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.battery_alert, color: Colors.white, size: 24),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'لضمان عمل الأذان، يُفضل إيقاف توفير البطارية',
//                 style: TextStyle(fontSize: 15),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.orange.shade700,
//         duration: const Duration(seconds: 6),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         action: SnackBarAction(
//           label: 'إعدادات',
//           textColor: Colors.white,
//           onPressed: () async {
//             final granted = await requestBatteryOptimization();
//             if (!granted) {
//               await openBatteryOptimizationSettings();
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   /// فحص شامل وعرض رسالة مناسبة
//   // static Future<void> checkAndPrompt(BuildContext context, {bool showSuccess = true}) async {
//   //   final isDisabled = await isBatteryOptimizationDisabled();
//   //
//   //   if (!context.mounted) return;
//   //
//   //   if (isDisabled && showSuccess) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: const Row(
//   //           children: [
//   //             Icon(Icons.check_circle, color: Colors.white),
//   //             SizedBox(width: 10),
//   //             Text(' التطبيق مُستثنى من توفير البطارية'),
//   //           ],
//   //         ),
//   //         backgroundColor: Colors.green,
//   //         duration: const Duration(seconds: 2),
//   //       ),
//   //     );
//   //   } else if (!isDisabled) {
//   //     await showBatteryOptimizationDialog(context);
//   //   }
//   // }
// }

// lib/background/adhan_callback.dart
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/shard/exports/all_exports.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // مهم جدًا مع الـ plugins في الخلفية
      WidgetsFlutterBinding.ensureInitialized();

      print("🔊 بدء تشغيل الأذان في الخلفية: $task");

      final prayerName = inputData?['prayerName'] ?? 'الصلاة';
      final cityName = inputData?['cityName'] ?? '';
      final adhanPath = inputData?['adhanPath'];

      // 1) تهيئة الـ notifications في هذا الـ isolate
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
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

      // 2) تشغيل صوت الأذان
      final audioPlayer = AudioPlayer();

      try {
        if (adhanPath != null && adhanPath.isNotEmpty) {
          // إذا كان مسار ملف محلي
          if (!adhanPath.startsWith('assets/')) {
            final file = File(adhanPath);
            if (await file.exists()) {
              await audioPlayer.setFilePath(adhanPath);
            } else {
              print(
                  "⚠️ ملف الأذان غير موجود: $adhanPath - جاري استخدام الافتراضي");
              await audioPlayer.setAsset('assets/athan/athan.mp3');
            }
          } else {
            // إذا كان asset
            await audioPlayer.setAsset(adhanPath);
          }
        } else {
          await audioPlayer.setAsset('assets/athan/athan.mp3');
        }
      } catch (e) {
        print("⚠️ خطأ في تحميل الملف الصوتي: $e - جاري استخدام الافتراضي");
        try {
          await audioPlayer.setAsset('assets/athan/athan.mp3');
        } catch (e2) {
          print("❌ فشل تحميل الصوت الافتراضي أيضًا: $e2");
        }
      }

      await audioPlayer.play();

      final notificationBody = _getPrayerDescription(prayerName);

      // 3) إظهار الإشعار
      await notifications.show(
        999,
        '🕌 وقت صلاة $prayerName',
        notificationBody,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_channel',
            'أذان الصلاة',
            channelDescription: 'إشعارات الأذان',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/launcher_icon',
            playSound: false,
            ongoing: true,
            autoCancel: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          ),
        ),
      );

      // انتظار انتهاء الصوت (أو مهلة زمنية أقصاها 5 دقائق)
      try {
        await audioPlayer.playerStateStream
            .firstWhere(
              (state) => state.processingState == ProcessingState.completed,
            )
            .timeout(const Duration(minutes: 5));
      } catch (e) {
        print("⚠️ انتهت مهلة انتظار الأذان أو حدث خطأ");
      }

      await audioPlayer.dispose();

      // إلغاء الإشعار المستمر وإظهار إشعار 'انتهى الأذان'
      await notifications.cancel(999);

      final endNotificationBody = prayerName.contains('الفجر')
          ? 'الصلاة خير من النوم، تقبل الله طاعتكم'
          : 'حي على الصلاة، حي على الفلاح';

      await notifications.show(
        DateTime.now().millisecond,
        '✅ انتهى أذان $prayerName',
        endNotificationBody,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_complete_channel',
            'تنبيهات ما بعد الأذان',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );

      return Future.value(true);
    } catch (e, s) {
      print("❌ خطأ جسيم في تشغيل الأذان: $e");
      print(s);
      return Future.value(false);
    }
  });
}

String _getPrayerDescription(String prayerName) {
  if (prayerName.contains('الفجر')) {
    return 'رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا';
  } else if (prayerName.contains('الظهر')) {
    return 'مَن غَدَا إلى المَسجدِ أو راح أعَدّ الله له في الجنة نُزُلًا كلما غدا أو راح.';
  } else if (prayerName.contains('العصر')) {
    return 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ';
  } else if (prayerName.contains('المغرب')) {
    return 'اللهم هذا إقبال ليلك وإدبار نهارك وأصوات دعاتك فاغفر لي';
  } else if (prayerName.contains('العشاء')) {
    return 'من صلى العشاء في جماعة فكأنما قام نصف الليل';
  } else {
    return 'صَلاَةُ الجَمَاعَةِ تَفْضُلُ صَلاَةَ الفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً';
  }
}

class BatteryOptimizationHelper {
  /// التحقق من حالة Battery Optimization
  static Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;

    try {
      // فحص صلاحية ignoreBatteryOptimizations
      var status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      print('❌ خطأ في فحص Battery Optimization: $e');
      return false;
    }
  }

  /// طلب تعطيل Battery Optimization
  static Future<bool> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    try {
      var status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (e) {
      print('❌ خطأ في طلب Battery Optimization: $e');
      return false;
    }
  }

  /// فتح صفحة إعدادات Battery Optimization مباشرة
  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      // طريقة 1: فتح صفحة Battery Optimization للتطبيق مباشرة
      const intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      print('❌ خطأ في فتح إعدادات Battery: $e');

      // طريقة بديلة: فتح إعدادات التطبيق العامة
      try {
        await openAppSettings();
      } catch (e2) {
        print('❌ خطأ في فتح إعدادات التطبيق: $e2');
      }
    }
  }

  /// عرض Dialog تحذيري مع زر للانتقال للإعدادات
  static Future<void> showBatteryOptimizationDialog(
      BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();
    if (isDisabled) return;
    if (!context.mounted) return;

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
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF1B0A0A), const Color(0xFF200505)]
                        : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
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
                      ' تنبيه هام',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الرسالة
                    Text(
                      'لضمان عمل الأذان في الخلفية بشكل صحيح، يجب إيقاف وضع توفير البطارية للتطبيق.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '📌 سنوجهك الآن إلى الإعدادات لتفعيل هذا الخيار\n📌 ابحث عن اسم التطبيق واختر "عدم التحسين" أو "Don\'t optimize"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
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

                              // محاولة طلب الصلاحية أولاً
                              final granted =
                                  await requestBatteryOptimization();

                              if (!granted) {
                                // إذا فشلت، فتح الإعدادات
                                await openBatteryOptimizationSettings();
                              }
                            },
                            icon: const Icon(Icons.settings, size: 20),
                            label: const Text('فتح الإعدادات'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.battery_alert,
                        size: 34,
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

  /// عرض SnackBar بسيط إذا كان Battery Optimization مفعّل
  static Future<void> showBatteryOptimizationSnackBar(
      BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();

    if (isDisabled || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'لضمان عمل الأذان، يُفضل إيقاف توفير البطارية',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'إعدادات',
          textColor: Colors.white,
          onPressed: () async {
            final granted = await requestBatteryOptimization();
            if (!granted) {
              await openBatteryOptimizationSettings();
            }
          },
        ),
      ),
    );
  }

  /// فحص شامل وعرض رسالة مناسبة
// static Future<void> checkAndPrompt(BuildContext context, {bool showSuccess = true}) async {
//   final isDisabled = await isBatteryOptimizationDisabled();
//
//   if (!context.mounted) return;
//
//   if (isDisabled && showSuccess) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             SizedBox(width: 10),
//             Text(' التطبيق مُستثنى من توفير البطارية'),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   } else if (!isDisabled) {
//     await showBatteryOptimizationDialog(context);
//   }
// }
}
