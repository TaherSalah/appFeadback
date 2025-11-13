// // lib/app/core/services/rate_service.dart
// import 'dart:io';
// import 'dart:developer';
// import 'package:rate_my_app/rate_my_app.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/material.dart';
//
// class RateService {
//   final RateMyApp rateMyApp;
//   RateService(this.rateMyApp);
//
//   Future<void> init() async {
//     await rateMyApp.init();
//   }
//
//   Future<void> maybeAskForRating(BuildContext context) async {
//     if (rateMyApp.shouldOpenDialog) {
//       await _showRateDialog(context);
//     }
//   }
//
//   Future<void> forceAskForRating(BuildContext context) async {
//     await _showRateDialog(context);
//   }
//
//   Future<void> _showRateDialog(BuildContext context) async {
//     await rateMyApp.showStarRateDialog(
//       context,
//       title: '⭐ قيّم تطبيقنا',
//       message: 'ساعدنا بتقييمك لتطوير التطبيق أكثر',
//       starRatingOptions: const StarRatingOptions(initialRating: 5),
//       actionsBuilder: (context, stars) => [
//         TextButton(
//           onPressed: () {
//             rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//             Navigator.pop(context);
//           },
//           child: const Text('لاحقًا'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final rating = (stars ?? 0).round();
//             if (rating >= 4) {
//               await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
//               await _openStore();
//             } else {
//               await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//             }
//             Navigator.pop(context);
//           },
//           child: const Text('إرسال'),
//         ),
//       ],
//       ignoreNativeDialog: false,
//       dialogStyle: const DialogStyle(
//         titleAlign: TextAlign.center,
//         messageAlign: TextAlign.center,
//       ),
//       onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
//     );
//   }
//
//   Future<void> _openStore() async {
//     try {
//       if (Platform.isAndroid) {
//         if (await _isHuaweiDevice()) {
//           await launchUrl(Uri.parse('https://appgallery.huawei.com/app/C114956477'));
//         } else {
//           await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily'));
//         }
//       } else if (Platform.isIOS) {
//         await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
//       }
//     } catch (e) {
//       log('openStore error: $e');
//     }
//   }
//
//   Future<bool> _isHuaweiDevice() async {
//     try {
//       // مؤشر تقريبي لوجود خدمات Huawei على بعض الأجهزة
//       return await File('/system/app/HwOUC').exists();
//     } catch (_) {
//       return false;
//     }
//   }
// }
// lib/app/core/services/rate_service.dart
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

// class RateService {
//   final RateMyApp rateMyApp;
//   final InAppReview _inAppReview = InAppReview.instance;
//   bool _reviewInProgress = false;
//
//   RateService(this.rateMyApp);
//
//   Future<void> init() async {
//     await rateMyApp.init();
//   }
//
//   /// طلب تلقائي في الـ main حسب الشروط
//   Future<void> maybeAskForRating(BuildContext context) async {
//     if (rateMyApp.shouldOpenDialog) {
//       await _showRateDialog(context); // استخدم حوار النجوم كتحفيز أولي
//     }
//   }
//
//   /// الزرار في شاشة About
//   Future<void> askForReview(BuildContext context) async {
//     if (_reviewInProgress) return;
//     _reviewInProgress = true;
//     try {
//       final available = await _inAppReview.isAvailable();
//       if (available) {
//         await _inAppReview.requestReview();       // قد لا يظهر UI بسبب الكوتا
//       } else {
//         await _showRateDialog(context);           // Fallback
//       }
//     } catch (e) {
//       await _showRateDialog(context);             // Fallback عند الخطأ
//     } finally {
//       _reviewInProgress = false;
//     }
//   }
//
//   Future<void> _showRateDialog(BuildContext context) async {
//     await rateMyApp.showStarRateDialog(
//       context,
//       title: '⭐ قيّم تطبيقنا',
//       message: 'ساعدنا بتقييمك لتطوير التطبيق أكثر',
//       starRatingOptions: const StarRatingOptions(initialRating: 5),
//       ignoreNativeDialog: false,
//       dialogStyle: const DialogStyle(
//         titleAlign: TextAlign.center,
//         messageAlign: TextAlign.center,
//       ),
//       actionsBuilder: (context, stars) => [
//         TextButton(
//           onPressed: () {
//             rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//             Navigator.pop(context);
//           },
//           child: const Text('لاحقًا'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final rating = (stars ?? 0).round();
//             if (rating >= 4) {
//               await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
//               await _openStore();                 // افتح المتجر المناسب
//             } else {
//               await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
//             }
//             Navigator.pop(context);
//           },
//           child: const Text('إرسال'),
//         ),
//       ],
//       onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
//     );
//   }
//
//   Future<void> _openStore() async {
//     try {
//       if (Platform.isAndroid) {
//         if (await _isHuaweiDevice()) {
//           await launchUrl(Uri.parse('https://appgallery.huawei.com/app/C114956477'));
//         } else {
//           await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily')); // غيّر المعرّف
//         }
//       } else if (Platform.isIOS) {
//        await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
//       }
//     } catch (e) {
//       log('openStore error: $e');
//     }
//   }
//
//   Future<bool> _isHuaweiDevice() async {
//     try {
//       return await File('/system/app/HwOUC').exists();
//     } catch (_) {
//       return false;
//     }
//   }
// }
// rate_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class RateService {
  final RateMyApp rateMyApp;
  final InAppReview _inAppReview = InAppReview.instance;
  bool _inProgress = false;

  static const _kLastPromptKey = 'rate_last_prompt'; // millisSinceEpoch
  static const _kCooldownDays = 7; // عدّل المدة

  RateService(this.rateMyApp);

  Future<void> init() => rateMyApp.init();

  Future<void> maybeAskForRating(BuildContext context) async {
    if (await _isCoolingDown()) return;
    if (rateMyApp.shouldOpenDialog) {
      await _recordPrompt(); // سجّل محاولة
      await _showFallback(context); // حوار النجوم
    }
  }

  Future<void> askForReview(BuildContext context) async {
    if (_inProgress) return;
    if (await _isCoolingDown()) return;

    _inProgress = true;
    await _recordPrompt();

    try {
      if (Platform.isAndroid && !(await _hasPlayStore())) {
        await _showFallback(context); // أجهزة بدون Play (مثلاً Huawei)
      } else if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview(); // قد لا يظهر UI بسبب الكوتا
      } else {
        await _showFallback(context);
      }
    } catch (_) {
      await _showFallback(context);
    } finally {
      _inProgress = false;
    }
  }

  Future<bool> _isCoolingDown() async {
    final sp = await SharedPreferences.getInstance();
    final last = sp.getInt(_kLastPromptKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffDays = (now - last) / (1000 * 60 * 60 * 24);
    return diffDays < _kCooldownDays;
  }

  Future<void> _recordPrompt() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kLastPromptKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _showFallback(BuildContext context) async {
    await rateMyApp.showStarRateDialog(
      context,
      title: '⭐ قيّم تطبيقنا',
      message: 'يساعدنا تقييمك على التطوير',
      starRatingOptions: const StarRatingOptions(initialRating: 5),
      actionsBuilder: (context, stars) => [
        TextButton(
          onPressed: () {
            rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
            Navigator.pop(context);
          },
          child: const Text('لاحقًا'),
        ),
        ElevatedButton(
          onPressed: () async {
            final rating = (stars ?? 0).round();
            if (rating >= 4) {
              await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              await _openStore();
            } else {
              await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
            }
            Navigator.pop(context);
          },
          child: const Text('إرسال'),
        ),
      ],
      ignoreNativeDialog: false,
      dialogStyle: const DialogStyle(
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
      ),
      onDismissed: () =>
          rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
    );
  }

  Future<void> _openStore() async {
    if (Platform.isAndroid) {
      final uri = await _hasPlayStore()
          ? Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily')
          : Uri.parse('https://appgallery.huawei.com/app/C114956477'); // عدّل
      await launchUrl(uri);
    } else if (Platform.isIOS) {
        await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
    }
  }

  Future<bool> _hasPlayStore() async {
    // تحقق بسيط: أجهزة هواوي أو أجهزة بدون متجر
    try {
      // على كثير من الأجهزة هواوي لا يوجد هذا الباكيج
      // أو استخدم حزمة device_apps لفحص الباكيج "com.android.vending"
      return !Platform.isAndroid
          ? false
          : true; // أبقِها true افتراضيًا إن لم تفحص الباكيج
    } catch (_) {
      return false;
    }
  }
}
