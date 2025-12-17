// // // lib/app/core/services/rate_service.dart
// // import 'dart:io';
// // import 'dart:developer';
// // import 'package:rate_my_app/rate_my_app.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:flutter/material.dart';
// //
// // class RateService {
// //   final RateMyApp rateMyApp;
// //   RateService(this.rateMyApp);
// //
// //   Future<void> init() async {
// //     await rateMyApp.init();
// //   }
// //
// //   Future<void> maybeAskForRating(BuildContext context) async {
// //     if (rateMyApp.shouldOpenDialog) {
// //       await _showRateDialog(context);
// //     }
// //   }
// //
// //   Future<void> forceAskForRating(BuildContext context) async {
// //     await _showRateDialog(context);
// //   }
// //
// //   Future<void> _showRateDialog(BuildContext context) async {
// //     await rateMyApp.showStarRateDialog(
// //       context,
// //       title: '⭐ قيّم تطبيقنا',
// //       message: 'ساعدنا بتقييمك لتطوير التطبيق أكثر',
// //       starRatingOptions: const StarRatingOptions(initialRating: 5),
// //       actionsBuilder: (context, stars) => [
// //         TextButton(
// //           onPressed: () {
// //             rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
// //             Navigator.pop(context);
// //           },
// //           child: const Text('لاحقًا'),
// //         ),
// //         ElevatedButton(
// //           onPressed: () async {
// //             final rating = (stars ?? 0).round();
// //             if (rating >= 4) {
// //               await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
// //               await _openStore();
// //             } else {
// //               await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
// //             }
// //             Navigator.pop(context);
// //           },
// //           child: const Text('إرسال'),
// //         ),
// //       ],
// //       ignoreNativeDialog: false,
// //       dialogStyle: const DialogStyle(
// //         titleAlign: TextAlign.center,
// //         messageAlign: TextAlign.center,
// //       ),
// //       onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
// //     );
// //   }
// //
// //   Future<void> _openStore() async {
// //     try {
// //       if (Platform.isAndroid) {
// //         if (await _isHuaweiDevice()) {
// //           await launchUrl(Uri.parse('https://appgallery.huawei.com/app/C114956477'));
// //         } else {
// //           await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily'));
// //         }
// //       } else if (Platform.isIOS) {
// //         await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
// //       }
// //     } catch (e) {
// //       log('openStore error: $e');
// //     }
// //   }
// //
// //   Future<bool> _isHuaweiDevice() async {
// //     try {
// //       // مؤشر تقريبي لوجود خدمات Huawei على بعض الأجهزة
// //       return await File('/system/app/HwOUC').exists();
// //     } catch (_) {
// //       return false;
// //     }
// //   }
// // }
// // lib/app/core/services/rate_service.dart
// import 'dart:io';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:rate_my_app/rate_my_app.dart';
// import 'package:in_app_review/in_app_review.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// // class RateService {
// //   final RateMyApp rateMyApp;
// //   final InAppReview _inAppReview = InAppReview.instance;
// //   bool _reviewInProgress = false;
// //
// //   RateService(this.rateMyApp);
// //
// //   Future<void> init() async {
// //     await rateMyApp.init();
// //   }
// //
// //   /// طلب تلقائي في الـ main حسب الشروط
// //   Future<void> maybeAskForRating(BuildContext context) async {
// //     if (rateMyApp.shouldOpenDialog) {
// //       await _showRateDialog(context); // استخدم حوار النجوم كتحفيز أولي
// //     }
// //   }
// //
// //   /// الزرار في شاشة About
// //   Future<void> askForReview(BuildContext context) async {
// //     if (_reviewInProgress) return;
// //     _reviewInProgress = true;
// //     try {
// //       final available = await _inAppReview.isAvailable();
// //       if (available) {
// //         await _inAppReview.requestReview();       // قد لا يظهر UI بسبب الكوتا
// //       } else {
// //         await _showRateDialog(context);           // Fallback
// //       }
// //     } catch (e) {
// //       await _showRateDialog(context);             // Fallback عند الخطأ
// //     } finally {
// //       _reviewInProgress = false;
// //     }
// //   }
// //
// //   Future<void> _showRateDialog(BuildContext context) async {
// //     await rateMyApp.showStarRateDialog(
// //       context,
// //       title: '⭐ قيّم تطبيقنا',
// //       message: 'ساعدنا بتقييمك لتطوير التطبيق أكثر',
// //       starRatingOptions: const StarRatingOptions(initialRating: 5),
// //       ignoreNativeDialog: false,
// //       dialogStyle: const DialogStyle(
// //         titleAlign: TextAlign.center,
// //         messageAlign: TextAlign.center,
// //       ),
// //       actionsBuilder: (context, stars) => [
// //         TextButton(
// //           onPressed: () {
// //             rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
// //             Navigator.pop(context);
// //           },
// //           child: const Text('لاحقًا'),
// //         ),
// //         ElevatedButton(
// //           onPressed: () async {
// //             final rating = (stars ?? 0).round();
// //             if (rating >= 4) {
// //               await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
// //               await _openStore();                 // افتح المتجر المناسب
// //             } else {
// //               await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
// //             }
// //             Navigator.pop(context);
// //           },
// //           child: const Text('إرسال'),
// //         ),
// //       ],
// //       onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
// //     );
// //   }
// //
// //   Future<void> _openStore() async {
// //     try {
// //       if (Platform.isAndroid) {
// //         if (await _isHuaweiDevice()) {
// //           await launchUrl(Uri.parse('https://appgallery.huawei.com/app/C114956477'));
// //         } else {
// //           await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily')); // غيّر المعرّف
// //         }
// //       } else if (Platform.isIOS) {
// //        await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
// //       }
// //     } catch (e) {
// //       log('openStore error: $e');
// //     }
// //   }
// //
// //   Future<bool> _isHuaweiDevice() async {
// //     try {
// //       return await File('/system/app/HwOUC').exists();
// //     } catch (_) {
// //       return false;
// //     }
// //   }
// // }
// // rate_service.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:in_app_review/in_app_review.dart';
// import 'package:rate_my_app/rate_my_app.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class RateService {
//   final RateMyApp rateMyApp;
//   final InAppReview _inAppReview = InAppReview.instance;
//   bool _inProgress = false;
//
//   static const _kLastPromptKey = 'rate_last_prompt'; // millisSinceEpoch
//   static const _kCooldownDays = 7; // عدّل المدة
//
//   RateService(this.rateMyApp);
//
//   Future<void> init() => rateMyApp.init();
//
//   Future<void> maybeAskForRating(BuildContext context) async {
//     if (await _isCoolingDown()) return;
//     if (rateMyApp.shouldOpenDialog) {
//       await _recordPrompt(); // سجّل محاولة
//       await _showFallback(context); // حوار النجوم
//     }
//   }
//
//   Future<void> askForReview(BuildContext context) async {
//     if (_inProgress) return;
//     if (await _isCoolingDown()) return;
//
//     _inProgress = true;
//     await _recordPrompt();
//
//     try {
//       if (Platform.isAndroid && !(await _hasPlayStore())) {
//         await _showFallback(context); // أجهزة بدون Play (مثلاً Huawei)
//       } else if (await _inAppReview.isAvailable()) {
//         await _inAppReview.requestReview(); // قد لا يظهر UI بسبب الكوتا
//       } else {
//         await _showFallback(context);
//       }
//     } catch (_) {
//       await _showFallback(context);
//     } finally {
//       _inProgress = false;
//     }
//   }
//
//   Future<bool> _isCoolingDown() async {
//     final sp = await SharedPreferences.getInstance();
//     final last = sp.getInt(_kLastPromptKey) ?? 0;
//     final now = DateTime.now().millisecondsSinceEpoch;
//     final diffDays = (now - last) / (1000 * 60 * 60 * 24);
//     return diffDays < _kCooldownDays;
//   }
//
//   Future<void> _recordPrompt() async {
//     final sp = await SharedPreferences.getInstance();
//     await sp.setInt(_kLastPromptKey, DateTime.now().millisecondsSinceEpoch);
//   }
//
//   Future<void> _showFallback(BuildContext context) async {
//     await rateMyApp.showStarRateDialog(
//       context,
//       title: '⭐ قيّم تطبيقنا',
//       message: 'يساعدنا تقييمك على التطوير',
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
//       onDismissed: () =>
//           rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
//     );
//   }
//
//   Future<void> _openStore() async {
//     if (Platform.isAndroid) {
//       final uri = await _hasPlayStore()
//           ? Uri.parse('https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily')
//           : Uri.parse('https://appgallery.huawei.com/app/C114956477'); // عدّل
//       await launchUrl(uri);
//     } else if (Platform.isIOS) {
//         await launchUrl(Uri.parse('https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'));
//     }
//   }
//
//   Future<bool> _hasPlayStore() async {
//     // تحقق بسيط: أجهزة هواوي أو أجهزة بدون متجر
//     try {
//       // على كثير من الأجهزة هواوي لا يوجد هذا الباكيج
//       // أو استخدم حزمة device_apps لفحص الباكيج "com.android.vending"
//       return !Platform.isAndroid
//           ? false
//           : true; // أبقِها true افتراضيًا إن لم تفحص الباكيج
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
import 'package:google_fonts/google_fonts.dart';

class RateService {
  final RateMyApp rateMyApp;
  final InAppReview _inAppReview = InAppReview.instance;
  bool _inProgress = false;

  static const _kLastPromptKey = 'rate_last_prompt';
  static const _kCooldownDays = 7;

  RateService(this.rateMyApp);

  Future<void> init() => rateMyApp.init();

  /// للاستدعاء التلقائي في main
  Future<void> maybeAskForRating(BuildContext context) async {
    if (await _isCoolingDown()) return;
    if (rateMyApp.shouldOpenDialog) {
      await _recordPrompt();
      await _showCustomDialog(context);
    }
  }

  /// للزر في صفحة About - يعرض دايالوج جميل مباشرة
  Future<void> askForReview(BuildContext context) async {
    if (_inProgress) return;
    _inProgress = true;

    try {
      // جرب InAppReview أولاً (قد لا يظهر بسبب الكوتا)
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();

        // انتظر قليلاً ثم اعرض الدايالوج كـ fallback
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) {
          await _showCustomDialog(context);
        }
      } else {
        // اعرض الدايالوج مباشرة
        await _showCustomDialog(context);
      }
    } catch (e) {
      // في حالة الخطأ، اعرض الدايالوج
      if (context.mounted) {
        await _showCustomDialog(context);
      }
    } finally {
      _inProgress = false;
    }
  }

  /// دايالوج مخصص جميل
  // Future<void> _showCustomDialog(BuildContext context) async {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //
  //   return showDialog(
  //     context: context,
  //     builder: (context) => Directionality(
  //       textDirection: TextDirection.rtl,
  //       child: AlertDialog(
  //         backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(24),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // أيقونة النجوم
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 gradient: const LinearGradient(
  //                   colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                 ),
  //                 shape: BoxShape.circle,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: const Color(0xFF00897B).withOpacity(0.3),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: const Icon(
  //                 Icons.star_rounded,
  //                 color: Colors.white,
  //                 size: 48,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 24),
  //
  //             // العنوان
  //             Text(
  //               'قيّم تطبيقنا ⭐',
  //               style: GoogleFonts.cairo(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: isDark ? Colors.white : Colors.black87,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 12),
  //
  //             // الرسالة
  //             Text(
  //               'يساعدنا تقييمك الإيجابي على تطوير التطبيق وإفادة المزيد من المسلمين',
  //               textAlign: TextAlign.center,
  //               style: GoogleFonts.cairo(
  //                 fontSize: 15,
  //                 color: isDark ? Colors.white70 : Colors.black54,
  //                 height: 1.6,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 24),
  //
  //             // الأزرار
  //             Row(
  //               children: [
  //                 // زر لاحقاً
  //                 Expanded(
  //                   child: TextButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     style: TextButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       'لاحقاً',
  //                       style: GoogleFonts.cairo(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w600,
  //                         color: isDark ? Colors.white70 : Colors.black54,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(width: 12),
  //
  //                 // زر التقييم
  //                 Expanded(
  //                   flex: 2,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       gradient: const LinearGradient(
  //                         colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                       ),
  //                       borderRadius: BorderRadius.circular(12),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: const Color(0xFF00897B).withOpacity(0.3),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 3),
  //                         ),
  //                       ],
  //                     ),
  //                     child: ElevatedButton.icon(
  //                       onPressed: () async {
  //                         Navigator.pop(context);
  //                         await _openStore();
  //                       },
  //                       icon: const Icon(Icons.star_rate_rounded, size: 20),
  //                       label: Text(
  //                         'تقييم الآن',
  //                         style: GoogleFonts.cairo(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.transparent,
  //                         foregroundColor: Colors.white,
  //                         elevation: 0,
  //                         shadowColor: Colors.transparent,
  //                         padding: const EdgeInsets.symmetric(vertical: 14),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Future<void> _showCustomDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
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
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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
                      'قيّم تطبيقنا ',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⭐' * 5,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // الرسالة
                    Text(
                      'يساعدنا تقييمك الإيجابي على تطوير التطبيق وإفادة المزيد من المسلمين.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // نص توضيحي داخل كارت
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF00897B).withOpacity(0.08),
                        border: Border.all(
                          color: const Color(0xFF00897B).withOpacity(0.4),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rate_rounded,
                              size: 18, color: Color(0xFF00897B)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تقييمك يساعدنا كثيراً في دعم التطبيق.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF00897B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // الأزرار
                    Row(
                      children: [
                        // زر لاحقاً
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
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

                        // زر تقييم الآن
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              await _openStore();
                            },
                            icon: const Icon(Icons.star_rounded),
                            label: const Text('تقييم الآن'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
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
                        colors: [Color(0xFF00897B), Color(0xFF00695C)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00897B).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star_rounded,
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

  Future<void> _openStore() async {
    try {
      if (Platform.isAndroid) {
        final hasPlayStore = await _hasPlayStore();
        final uri = hasPlayStore
            ? Uri.parse(
                'https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily')
            : Uri.parse('https://appgallery.huawei.com/app/C114956477');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (Platform.isIOS) {
        await launchUrl(
          Uri.parse(
              'https://apps.apple.com/us/app/رفيق-المسلم-اليومي/id6749927338'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error opening store: $e');
    }
  }

  Future<bool> _hasPlayStore() async {
    try {
      // فحص بسيط لأجهزة هواوي
      final huaweiFile = File('/system/app/HwOUC');
      if (await huaweiFile.exists()) return false;

      return true; // افتراضياً معظم أجهزة أندرويد لديها Play Store
    } catch (_) {
      return true;
    }
  }
}
