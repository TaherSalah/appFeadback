import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui' as ui;
//
// import 'package:adhan/adhan.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
//
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart' as intl;
//
// import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
// import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
// import 'package:muslimdaily/app/core/widgets/KLoading.dart';
// import 'package:muslimdaily/app/features/mainView/controllar/MainController.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
//
// import 'package:workmanager/workmanager.dart';
//
// import '../messaView/azkar_massa.dart';
// import 'adhan_callback.dart';
// import 'adhan_workmanager_service.dart';
//
// class AzanView extends StatefulWidget {
//   const AzanView({super.key});
//
//   @override
//   _AzanViewState createState() => _AzanViewState();
// }
//
// class _AzanViewState extends StateMVC<AzanView> {
//   _AzanViewState() : super(MainController()) {
//     con = controller as MainController;
//   }
//
//   late MainController con;
//
//   // استخدام خدمة WorkManager
//   // final AdhanWorkManagerService _adhanService = AdhanWork                  ManagerService();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // _adhanService.initialize();
//     con.refreshPrayerTimesFromPrefs();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // ✅ فحص Battery Optimization أول ما الشاشة تفتح
//       _checkBatteryOptimization();
//
//       _scheduleAllPrayerNotifications();
//     });
//   }
//
//   // /// 🔋 فحص حالة Battery Optimization وعرض تحذير إذا لزم الأمر
//   Future<void> _checkBatteryOptimization() async {
//     // ✅ الدالة دي بتفحص الأول، ولو مش مفعّل بس هتظهر الـ Dialog
//     await BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
//   }
//
//   // جدولة إشعارات الصلاة
//   Future<void> _scheduleAllPrayerNotifications() async {
//     final prayerTimes = con.prayerTimes;
//     final cityName = con.selectedCity ?? "مدينتك";
//     final selectedCity = con.selectedCity;
//
//     if (prayerTimes == null) {
//       print("⚠️ مواقيت الصلاة غير متاحة");
//       return;
//     }
//
//     try {
//       // ✅ 1) إلغاء جميع المهام القديمة أولاً
//       await Workmanager().cancelAll();
//       print('🗑️ تم إلغاء المهام القديمة');
//
//       // ✅ 2) الحصول على الإحداثيات
//       final cities = con.cities;
//       if (cities.isEmpty || selectedCity == null) return;
//
//       final cityData = cities[selectedCity];
//       if (cityData == null) return;
//
//       final lat = (cityData['lat'] as num?)?.toDouble();
//       final lng = (cityData['lng'] as num?)?.toDouble();
//
//       if (lat == null || lng == null) {
//         print("⚠️ إحداثيات المدينة غير متوفرة");
//         return;
//       }
//
//       // ✅ 3) حساب مواقيت الصلاة
//       final coordinates = Coordinates(lat, lng);
//       final calculationParams = con.selectedMethod.getParameters();
//       calculationParams.madhab = con.selectedMadhab;
//
//       // ✅ 4) حفظ البيانات
//       await AdhanWorkManagerService().saveCoordinates(lat, lng);
//       await AdhanWorkManagerService().saveCityName(cityName);
//
//       // ✅ 5) جدولة الأذان لـ 7 أيام
//       await AdhanWorkManagerService().scheduleAllPrayersForMultipleDays(
//         coordinates: coordinates,
//         calculationParams: calculationParams,
//         cityName: cityName,
//         days: 7,
//       );
//
//       if (mounted) {
//         KHelper.showSuccess(
//           message: ' تم جدولة الأذان لـ 7 أيام بنجاح',
//         );
//       }
//     } catch (e) {
//       print("❌ خطأ في جدولة الإشعارات: $e");
//       if (mounted) {
//         KHelper.showError(message: "حدث خطأ في جدولة الإشعارات: $e");
//       }
//     }
//   }
//
//   // التأكد من صلاحيات الموقع
//   Future<bool> _ensureLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       return false;
//     }
//     return true;
//   }
//
//   // دالة حساب المسافة (Haversine)
//   double _haversine(double lat1, double lon1, double lat2, double lon2) {
//     const R = 6371.0;
//     final dLat = (lat2 - lat1) * (math.pi / 180);
//     final dLon = (lon2 - lon1) * (math.pi / 180);
//     final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(lat1 * math.pi / 180) *
//             math.cos(lat2 * math.pi / 180) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);
//     final c = 2 * math.asin(math.sqrt(a));
//     return R * c;
//   }
//
//   // تحديد أقرب مدينة بالـ GPS
//   Future<void> _selectByLocation() async {
//     final ok = await _ensureLocationPermission();
//     if (!ok) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(
//         //     content: Text('يرجى تفعيل خدمات الموقع والسماح بالوصول'),
//         //     backgroundColor: Colors.orange,
//         //   ),
//         // );
//         KHelper.showError(message: 'يرجى تفعيل خدمات الموقع والسماح بالوصول');
//       }
//       return;
//     }
//
//     final pos = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     final userLat = pos.latitude;
//     final userLng = pos.longitude;
//
//     final countries = con.countries;
//     if (countries.isEmpty) return;
//
//     String? bestCountry;
//     String? bestCity;
//     double bestDist = double.infinity;
//
//     countries.forEach((country, cityMap) {
//       final Map<String, dynamic> m = cityMap ?? {};
//       m.forEach((cityName, v) {
//         final lat = (v?['lat'])?.toDouble();
//         final lng = (v?['lng'])?.toDouble();
//         if (lat == null || lng == null) return;
//         final d = _haversine(userLat, userLng, lat, lng);
//         if (d < bestDist) {
//           bestDist = d;
//           bestCountry = country;
//           bestCity = cityName;
//         }
//       });
//     });
//
//     if (bestCountry != null && bestCity != null) {
//       await con.setLocation(country: bestCountry!, city: bestCity!);
//       setState(() {});
//
//       // جدولة الإشعارات للموقع الجديد
//       await _scheduleAllPrayerNotifications();
//
//       if (mounted) {
//         KHelper.showSuccess(
//           message: 'تم تحديد الموقع: $bestCountry - $bestCity',
//         );
//       }
//     }
//   }
//
//   void _showCalculationSettings() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         final isDark = Theme.of(context).brightness == Brightness.dark;
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Directionality(
//               textDirection: TextDirection.rtl,
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: isDark ? const Color(0xFF1E293B) : Colors.white,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Container(
//                         width: 40,
//                         height: 4,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       '⚙️ إعدادات الحساب',
//                       style: GoogleFonts.cairo(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     // طريقة الحساب
//                     Text(
//                       'طريقة الحساب',
//                       style: GoogleFonts.cairo(
//                         fontSize: 14.sp,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildMethodDropdown(isDark, setStateSheet),
//
//                     const SizedBox(height: 16),
//
//                     // المذهب
//                     Text(
//                       'المذهب (صلاة العصر)',
//                       style: GoogleFonts.cairo(
//                         fontSize: 14.sp,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildMadhabDropdown(isDark, setStateSheet),
//
//                     const SizedBox(height: 16),
//
//                     const SizedBox(height: 16),
//
//                     // تعديل الساعات (فارق التوقيت)
//                     Text(
//                       'تعديل الساعات (فارق التوقيت)',
//                       style: GoogleFonts.cairo(
//                         fontSize: 14.sp,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? Colors.black.withOpacity(0.2)
//                             : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                             color:
//                                 isDark ? Colors.white10 : Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle_outline,
//                                 color: Colors.red),
//                             onPressed: () {
//                               setStateSheet(() {
//                                 con.manualOffset--;
//                               });
//                             },
//                           ),
//                           Text(
//                             "${con.manualOffset > 0 ? '+' : ''}${con.manualOffset} ساعة",
//                             style: GoogleFonts.cairo(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black87,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.add_circle_outline,
//                                 color: Colors.green),
//                             onPressed: () {
//                               setStateSheet(() {
//                                 con.manualOffset++;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // زر الحفظ
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         onPressed: () {
//                           // حفظ وتحديث
//                           con.updateCalcSettings(
//                             method: con.selectedMethod,
//                             madhab: con.selectedMadhab,
//                             offset: con.manualOffset,
//                           );
//                           _scheduleAllPrayerNotifications(); // إعادة الجدولة
//                           Navigator.pop(context);
//                           KHelper.showSuccess(
//                               message: "تم تحديث طريقة الحساب بنجاح");
//                         },
//                         child: Text(
//                           'حفظ التغييرات',
//                           style: GoogleFonts.cairo(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildMethodDropdown(
//       bool isDark, void Function(void Function()) setStateSheet) {
//     // قائمة الطرق المعربة
//     final Map<CalculationMethod, String> methods = {
//       CalculationMethod.egyptian: "الهيئة المصرية العامة للمساحة",
//       CalculationMethod.muslim_world_league: "رابطة العالم الإسلامي",
//       CalculationMethod.umm_al_qura: "أم القرى (مكة المكرمة)",
//       CalculationMethod.karachi: "جامعة العلوم الإسلامية، كراتشي",
//       CalculationMethod.dubai: "دبي",
//       CalculationMethod.kuwait: "الكويت",
//       CalculationMethod.north_america: "أمريكا الشمالية (ISNA)",
//       CalculationMethod.singapore: "سنغافورة",
//       CalculationMethod.turkey: "تركيا",
//       CalculationMethod.tehran: "طهران",
//       CalculationMethod.qatar: "قطر",
//     };
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.white10 : Colors.grey.shade300,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<CalculationMethod>(
//           isExpanded: true,
//           hint: Text('اختر الطريقة'),
//           items: methods.entries.map((item) {
//             return DropdownMenuItem<CalculationMethod>(
//               value: item.key,
//               child: Text(
//                 item.value,
//                 style: GoogleFonts.cairo(
//                   fontSize: 13.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }).toList(),
//           value: con.selectedMethod,
//           onChanged: (value) {
//             if (value != null) {
//               setStateSheet(() {
//                 con.selectedMethod = value;
//               });
//             }
//           },
//           buttonStyleData: const ButtonStyleData(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             height: 50,
//           ),
//           dropdownStyleData: DropdownStyleData(
//             maxHeight: 400,
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF334155) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMadhabDropdown(
//       bool isDark, void Function(void Function()) setStateSheet) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.white10 : Colors.grey.shade300,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<Madhab>(
//           isExpanded: true,
//           items: [
//             DropdownMenuItem(
//               value: Madhab.shafi,
//               child: Text(
//                 'الشافعي / المالكي / الحنبلي (الجمهور)',
//                 style: GoogleFonts.cairo(
//                   fontSize: 13.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             DropdownMenuItem(
//               value: Madhab.hanafi,
//               child: Text(
//                 'الحنفي',
//                 style: GoogleFonts.cairo(
//                   fontSize: 13.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//           value: con.selectedMadhab,
//           onChanged: (value) {
//             if (value != null) {
//               setStateSheet(() {
//                 con.selectedMadhab = value;
//               });
//             }
//           },
//           buttonStyleData: const ButtonStyleData(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             height: 50,
//           ),
//           dropdownStyleData: DropdownStyleData(
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF334155) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // لا داعي لـ dispose WorkManager
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final baseColor = const Color(AppStyle.primaryColor);
//
//     final countries = con.countries;
//     final cities = con.cities;
//     final selectedCountry = con.selectedCountry;
//     final selectedCity = con.selectedCity;
//     final prayerTimes = con.prayerTimes;
//     final nextPrayer = con.nextPrayer;
//     final remainingTimeText = con.remainingTimeText;
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize:
//             Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
//         child: AppBar(
//           leading: CupertinoNavigationBarBackButton(
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           centerTitle: true,
//           title: Text(
//             "مواقيت الصلاة",
//             style: GoogleFonts.cairo(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
//             ),
//           ),
//           actions: [
//             // زر اختبار الأذان 🧪
//             // IconButton(
//             //   icon: const Icon(Icons.bug_report, color: Colors.orange),
//             //   tooltip: 'اختبار الأذان (20 ثانية)',
//             //   onPressed: () async {
//             //     // 1. Check Permissions First
//             //     bool isAllowed =
//             //         await AwesomeNotifications().isNotificationAllowed();
//             //     if (!isAllowed) {
//             //       await AwesomeNotifications()
//             //           .requestPermissionToSendNotifications();
//             //       isAllowed =
//             //           await AwesomeNotifications().isNotificationAllowed();
//             //       if (!isAllowed) {
//             //         KHelper.showError(message: 'يجب تفعيل الإشعارات أولاً!');
//             //         return;
//             //       }
//             //     }
//             //
//             //     try {
//             //       KHelper.showSuccess(
//             //           message: 'جاري جدولة الاختبار...'); // Feedback
//             //
//             //       final success = await AdhanWorkManagerService()
//             //           .scheduleTestAdhan(secondsFromNow: 20);
//             //       if (!mounted) return;
//             //
//             //       if (success == null) {
//             //         KHelper.showSuccess(
//             //           message:
//             //               '🧪 تم جدولة أذان تجريبي بعد 20 ثانية\nانتظر وتأكد من الصوت!',
//             //         );
//             //       } else {
//             //         KHelper.showError(
//             //           message:
//             //               '❌ فشلت جدولة الأذان التجريبي\n$success',
//             //         );
//             //       }
//             //     } catch (e) {
//             //       if (!mounted) return;
//             //       // Show exact error
//             //       showDialog(
//             //         context: context,
//             //         builder: (ctx) => AlertDialog(
//             //           title: const Text('خطأ في الاختبار'),
//             //           content: Text(e.toString()),
//             //           actions: [
//             //             TextButton(
//             //                 onPressed: () => Navigator.pop(ctx),
//             //                 child: const Text('Ok'))
//             //           ],
//             //         ),
//             //       );
//             //     }
//             //   },
//             // ),
//             //       // Show exact error
//             //       showDialog(
//             //         context: context,
//             //         builder: (ctx) => AlertDialog(
//             //           title: Text('خطأ في الاختبار'),
//             //           content: Text(e.toString()),
//             //           actions: [
//             //             TextButton(
//             //                 onPressed: () => Navigator.pop(ctx),
//             //                 child: Text('Ok'))
//             //           ],
//             //         ),
//             //       );
//             //     }
//             //   },
//             // ),
//             //
//             // // زر اختبار فوري (بدون جدولة) للتشخيص
//             // IconButton(
//             //   icon: const Icon(Icons.flash_on, color: Colors.blue),
//             //   tooltip: 'اختبار فوري (بدون جدولة)',
//             //   onPressed: () async {
//             //     await AwesomeNotifications().createNotification(
//             //       content: NotificationContent(
//             //         id: 77777,
//             //         channelKey: 'sabah_athkar_channel',
//             //         title: '⚡ اختبار فوري',
//             //         body: 'إذا وصلك هذا، فالإشعارات تعمل (المشكلة في الجدولة).',
//             //         notificationLayout: NotificationLayout.Default,
//             //       ),
//             //     );
//             //     if (context.mounted) {
//             //       KHelper.showSuccess(message: 'تم إرسال إشعار فوري');
//             //     }
//             //   },
//             // ),
//
//             IconButton(
//               icon: const Icon(Icons.settings),
//               tooltip: 'إعدادات الحساب',
//               onPressed: _showCalculationSettings,
//             ),
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               tooltip: 'إعادة جدولة الإشعارات',
//               onPressed: _scheduleAllPrayerNotifications,
//             ),
//           ],
//           // actions: [
//           //   if (Platform.isAndroid)
//           //     FutureBuilder<bool>(
//           //       future: BatteryOptimizationHelper.isBatteryOptimizationDisabled(),
//           //       builder: (context, snapshot) {
//           //         return IconButton(
//           //           icon: const Icon(Icons.battery_charging_full),
//           //           tooltip: 'فحص إعدادات البطارية',
//           //           onPressed: () async {
//           //             final isDisabled = await BatteryOptimizationHelper.isBatteryOptimizationDisabled();
//           //             if (!mounted) return;
//           //
//           //             if (isDisabled) {
//           //               KHelper.showSuccess(message: "التطبيق مُستثنى من توفير البطارية");
//           //             } else {
//           //               BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
//           //             }
//           //           },
//           //         );
//           //       },
//           //     ),
//           //   IconButton(
//           //     icon: const Icon(Icons.refresh),
//           //     tooltip: 'إعادة جدولة الإشعارات',
//           //     onPressed: _scheduleAllPrayerNotifications,
//           //   ),
//           // ],
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: isDark
//                 ? [
//                     const Color(0xFF0F172A),
//                     const Color(0xFF1E293B),
//                     const Color(0xFF0F172A),
//                   ]
//                 : [
//                     Colors.blue.shade50,
//                     Colors.white,
//                     Colors.blue.shade50,
//                   ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Directionality(
//             textDirection: ui.TextDirection.rtl,
//             child: Column(
//               children: [
//                 // 🎯 قسم اختيار الموقع المحسّن
//                 _buildLocationSelector(context, isDark, countries, cities,
//                     selectedCountry, selectedCity),
//
//                 const SizedBox(height: 20),
//
//                 // 📍 عرض الموقع الحالي بتصميم جذاب
//                 if (selectedCountry != null && selectedCity != null)
//                   buildCurrentLocation(
//                       context, isDark, selectedCountry, selectedCity),
//
//                 const SizedBox(height: 24),
//
//                 // ⏰ الصلاة القادمة (بطاقة مميزة)
//                 if (prayerTimes != null && nextPrayer.isNotEmpty)
//                   _buildNextPrayerCard(context, isDark, nextPrayer,
//                       remainingTimeText, prayerTimes),
//
//                 const SizedBox(height: 24),
//
//                 // 📋 قائمة المواقيت المحسّنة
//                 if (prayerTimes != null)
//                   Expanded(
//                     child: _buildPrayerTimesList(
//                         context, isDark, prayerTimes, nextPrayer),
//                   )
//                 else
//                   KLoading.progressIOSIndicator(context: context),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🎯 قسم اختيار الموقع
//   Widget _buildLocationSelector(
//     BuildContext context,
//     bool isDark,
//     Map countries,
//     Map cities,
//     String? selectedCountry,
//     String? selectedCity,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.location_city, color: Colors.green, size: 24),
//               const SizedBox(width: 8),
//               Text(
//                 'اختر موقعك',
//                 style: GoogleFonts.cairo(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               // Dropdown الدولة
//               Expanded(
//                 child: _buildCustomDropdown(
//                   context: context,
//                   isDark: isDark,
//                   hint: 'الدولة',
//                   items: countries.keys.map((e) => e.toString()).toList(),
//                   value: selectedCountry,
//                   icon: Icons.public,
//                   onChanged: (value) async {
//                     if (value == null) return;
//                     final Map<String, dynamic> cityMap = (countries[value]
//                         as Map<String, dynamic>)
//                       ..removeWhere((k, v) => v == null);
//                     final firstCity = cityMap.keys.first;
//                     await con.setLocation(country: value, city: firstCity);
//                     setState(() {});
//                     await _scheduleAllPrayerNotifications();
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // Dropdown المدينة
//               Expanded(
//                 child: _buildCustomDropdown(
//                   context: context,
//                   isDark: isDark,
//                   hint: 'المدينة',
//                   items: cities.keys.map((e) => e.toString()).toList(),
//                   value: selectedCity,
//                   icon: Icons.location_on,
//                   onChanged: (value) async {
//                     if (value == null || selectedCountry == null) return;
//                     await con.setLocation(
//                         country: selectedCountry, city: value);
//                     setState(() {});
//                     await _scheduleAllPrayerNotifications();
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           // زر GPS
//           InkWell(
//             onTap: countries.isEmpty ? null : _selectByLocation,
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: isDark
//                       ? [Colors.teal.shade700, Colors.teal.shade900]
//                       : [Colors.blue.shade400, Colors.blue.shade600],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.my_location, color: Colors.white, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'تحديد موقعي الحالي',
//                     style: GoogleFonts.cairo(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🎨 Dropdown مخصص
//   Widget _buildCustomDropdown({
//     required BuildContext context,
//     required bool isDark,
//     required String hint,
//     required List<String> items,
//     required String? value,
//     required IconData icon,
//     required Function(String?) onChanged,
//   }) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         // decoration: BoxDecoration(
//         //   color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
//         //   borderRadius: BorderRadius.circular(12),
//         //   border: Border.all(
//         //     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//         //   ),
//         // ),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isDark ? Colors.white24 : Colors.grey.shade300,
//           ),
//           color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
//         ),
//
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton2<String>(
//             isExpanded: true,
//             hint: Row(
//               children: [
//                 Icon(icon, size: 18, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Text(
//                   hint,
//                   style: GoogleFonts.cairo(
//                     fontSize: 13.sp,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//             items: items.map((item) {
//               return DropdownMenuItem(
//                 value: item,
//                 child: Text(
//                   item,
//                   style: GoogleFonts.cairo(
//                     fontSize: 12.sp,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               );
//             }).toList(),
//             value: value,
//             onChanged: onChanged,
//             buttonStyleData: const ButtonStyleData(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               height: 50,
//             ),
//             dropdownStyleData: DropdownStyleData(
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF334155) : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             menuItemStyleData: MenuItemStyleData(
//               overlayColor: WidgetStateProperty.all(
//                 isDark
//                     ? Colors.white.withOpacity(0.1)
//                     : Colors.grey.withOpacity(0.1),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 📍 عرض الموقع الحالي
//   Widget buildCurrentLocation(
//     BuildContext context,
//     bool isDark,
//     String selectedCountry,
//     String selectedCity,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//           // gradient: LinearGradient(
//           //   colors:
//           //      [Colors.indigo.shade800, Colors.purple.shade900]
//           //       // : [Colors.blue.shade100, Colors.purple.shade100],
//           // ),
//           borderRadius: BorderRadius.circular(16),
//           // boxShadow: [
//           //   BoxShadow(
//           //     color: isDark ? Colors.black38 : Colors.blue.withOpacity(0.2),
//           //     blurRadius: 10,
//           //     offset: const Offset(0, 4),
//           //   ),
//           // ],
//           color: AppThemeColors.cardBackgroundColor(context)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.place_rounded,
//             color: isDark ? Colors.amberAccent : Colors.blue.shade800,
//             size: 24,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '$selectedCountry - $selectedCity',
//             style: GoogleFonts.cairo(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ⏰ بطاقة الصلاة القادمة
//   Widget _buildNextPrayerCard(
//     BuildContext context,
//     bool isDark,
//     String nextPrayer,
//     String remainingTimeText,
//     dynamic prayerTimes,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Colors.green.shade400, Colors.teal.shade600],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.access_time_rounded,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'الصلاة القادمة',
//                     style: GoogleFonts.cairo(
//                       fontSize: 12.sp,
//                       color: Colors.white.withOpacity(0.9),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     nextPrayer,
//                     style: GoogleFonts.cairo(
//                       fontSize: 20.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'الوقت المتبقي: $remainingTimeText',
//                   style: GoogleFonts.cairo(
//                     fontSize: 14.sp,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📋 قائمة المواقيت
//   Widget _buildPrayerTimesList(
//     BuildContext context,
//     bool isDark,
//     dynamic prayerTimes,
//     String nextPrayer,
//   ) {
//     final prayerData = [
//       {"name": "الفجر", "time": prayerTimes.fajr, "icon": Icons.wb_twilight},
//       {"name": "الشروق", "time": prayerTimes.sunrise, "icon": Icons.wb_sunny},
//       {"name": "الظهر", "time": prayerTimes.dhuhr, "icon": Icons.light_mode},
//       {
//         "name": "العصر",
//         "time": prayerTimes.asr,
//         "icon": Icons.wb_sunny_outlined
//       },
//       {
//         "name": "المغرب",
//         "time": prayerTimes.maghrib,
//         "icon": Icons.wb_twilight
//       },
//       {
//         "name": "العشاء",
//         "time": prayerTimes.isha,
//         "icon": Icons.nightlight_round
//       },
//     ];
//
//     return ListView.separated(
//       physics: const BouncingScrollPhysics(),
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemCount: prayerData.length,
//       itemBuilder: (context, index) {
//         final prayer = prayerData[index];
//         final isNext = nextPrayer.contains(prayer["name"] as String);
//
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors:
//
//                   // isNext
//                   // ? (isDark
//                   // ? [Colors.amber.shade700, Colors.orange.shade800]
//                   // : [Colors.blue.shade400, Colors.blue.shade600])
//                   // :
//                   (isDark
//                       ? [const Color(0xFF1E293B), const Color(0xFF334155)]
//                       : [Colors.white, Colors.grey.shade50]),
//             ),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: isNext
//                     // ? (isDark ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3))
//                     // : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.2)),
//                     ? (isDark
//                         ? Colors.green.withOpacity(0.3)
//                         : Colors.blue.withOpacity(0.3))
//                     : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.2)),
//                 blurRadius: isNext ? 15 : 8,
//                 offset: Offset(0, isNext ? 6 : 3),
//               ),
//             ],
//             border: isNext
//                 ? Border.all(
//                     // color: isDark ? Colors.amberAccent : Colors.white,
//                     color: Colors.green,
//                     width: 2,
//                   )
//                 : null,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//             child: Row(
//               children: [
//                 // أيقونة الصلاة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isNext
//                         ? Colors.grey.withOpacity(0.1)
//                         : (isDark ? Colors.grey.shade800 : Colors.blue.shade50),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     prayer["icon"] as IconData,
//                     color: isNext
//                         ? Colors.green
//                         : (isDark ? Colors.white : Colors.blue.shade700),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // اسم الصلاة
//                 Expanded(
//                   child: Text(
//                     prayer["name"] as String,
//                     style: GoogleFonts.cairo(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: isNext
//                           ? Colors.green
//                           : (isDark ? Colors.white : Colors.black87),
//                     ),
//                   ),
//                 ),
//                 // الوقت
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: isNext
//                         ? Colors.grey.withOpacity(0.2)
//                         : (isDark
//                             ? Colors.grey.shade800
//                             : Colors.grey.shade100),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     intl.DateFormat('h:mm a')
//                         .format((prayer["time"] as DateTime).toLocal()),
//                     style: GoogleFonts.cairo(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.bold,
//                       color: isNext
//                           ? Colors.green.shade400
//                           : (isDark ? Colors.white : Colors.blue.shade700),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// /*
//   @pragma('vm:entry-point')
//   void callbackDispatcher() {  // ✅ يجب أن تكون static
//     Workmanager().executeTask((task, inputData) async {
//       try {
//         // ✅ تحديد نوع الأذان
//         final isFajr = inputData?['isFajr'] ?? false;
//         final prayerName = inputData?['prayerName'] ?? 'الفجر';
//         final cityName = inputData?['cityName'] ?? '';
//         final prayerTime = inputData?['prayerTime'] ?? '';
//
//         // ✅ اختيار القناة المناسبة
//         final channelKey = isFajr ? 'fajr_adhan_channel' : 'adhan_channel';
//         final soundSource = isFajr ? 'resource://raw/fajr' : 'resource://raw/athan';
//
//         print('🔔 جاري تشغيل أذان $prayerName (${isFajr ? "الفجر" : "عادي"})');
//
//         // ✅ تهيئة الإشعارات
//         await AwesomeNotifications().initialize(
//           null,
//           [
//             NotificationChannel(
//               channelKey: 'fajr_adhan_channel',
//               channelName: 'أذان الفجر',
//               channelDescription: 'تشغيل أذان الفجر',
//               importance: NotificationImportance.Max,
//               playSound: true,
//               soundSource: 'resource://raw/fajr',
//               enableVibration: true,
//               enableLights: true,
//               ledColor: Colors.orange,
//             ),
//             NotificationChannel(
//               channelKey: 'adhan_channel',
//               channelName: 'أذان الصلاة',
//               channelDescription: 'تشغيل صوت الأذان',
//               importance: NotificationImportance.Max,
//               playSound: true,
//               soundSource: 'resource://raw/athan',
//               enableVibration: true,
//               enableLights: true,
//               ledColor: Colors.green,
//             ),
//           ],
//         );
//
//         // ✅ إرسال الإشعار مع الصوت المناسب
//         await AwesomeNotifications().createNotification(
//           content: NotificationContent(
//             id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//             channelKey: channelKey, // ⭐ القناة المناسبة
//             title: isFajr
//                 ? '🌅 حان الآن موعد أذان الفجر'
//                 : '🕌 حان الآن موعد أذان $prayerName',
//             body: '$cityName - $prayerTime',
//             category: NotificationCategory.Alarm,
//             notificationLayout: NotificationLayout.Default,
//             wakeUpScreen: true,
//             fullScreenIntent: true,
//             criticalAlert: true,
//             autoDismissible: false,
//             backgroundColor: isFajr ? Colors.orange : Colors.green,
//           ),
//           actionButtons: [
//             NotificationActionButton(
//               key: 'STOP_ADHAN',
//               label: 'إيقاف الأذان',
//               actionType: ActionType.DismissAction,
//             ),
//           ],
//         );
//
//         // ⏰ انتظار انتهاء الأذان (3-5 دقائق تقريباً)
//         await Future.delayed(const Duration(minutes: 3));
//
//         // ✅ إشعار الانتهاء
//         await AwesomeNotifications().createNotification(
//           content: NotificationContent(
//             id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
//             channelKey: channelKey,
//             title: '✅ انتهى أذان $prayerName',
//             body: 'تم تشغيل الأذان بنجاح - $cityName',
//             notificationLayout: NotificationLayout.Default,
//           ),
//         );
//
//         return Future.value(true);
//       } catch (e, s) {
//         print('❌ خطأ في تشغيل الأذان: $e\n$s');
//         return Future.value(false);
//       }
//     });
//   }
//   */
//
// Future<void> _rescheduleNextDay() async {
//   try {
//     await AdhanWorkManagerService().reschedule();
//   } catch (e) {
//     print('❌ خطأ في إعادة الجدولة: $e');
//   }
// }
//
// // ==========================================
// // 🎯 التهيئة الأساسية
// // ==========================================
//
// /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
//
// // ==========================================
// // 📅 جدولة الصلوات
// // ==========================================
//
// /// جدولة جميع الصلوات لعدة أيام قادمة
//
// // Future<bool> _schedulePrayer({
// //   required String prayerName,
// //   required DateTime prayerTime,
// //   int dayOffset = 0,
// //   String? cityName,
// // }) async {
// //   final now = DateTime.now();
// //   var delay = prayerTime.difference(now);
// //
// //   // ✅ تخطي الأوقات التي فاتت
// //   if (delay.isNegative) {
// //     if (dayOffset == 0) {
// //       print('⏭️ تم تخطي $prayerName - الوقت فات (${_formatTime(prayerTime)})');
// //     }
// //     return false;
// //   }
// //
// //   // ✅ التأكد من أن التأخير معقول
// //   if (delay.inMinutes < 1) {
// //     print('⚠️ تأخير قصير جداً لـ $prayerName (${delay.inSeconds} ثانية)');
// //     return false;
// //   }
// //
// //   try {
// //     final savedCityName = cityName ?? await _getCityName();
// //
// //     // ✅ تحديد نوع الأذان (الفجر له أذان مختلف)
// //     final isFajr = prayerName == 'الفجر';
// //     final adhanType = isFajr ? 'fajr' : 'normal';
// //
// //     // ✅ معرف فريد يتضمن timestamp لتجنب التكرار
// //     final uniqueId = 'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';
// //
// //     // ✅ جدولة المهمة مع WorkManager
// //     await Workmanager().registerOneOffTask(
// //       uniqueId,
// //       'adhanTask',
// //       initialDelay: delay,
// //       inputData: {
// //         'prayerName': prayerName,
// //         'cityName': savedCityName,
// //         'prayerTime': _formatTime(prayerTime),
// //         'timestamp': prayerTime.millisecondsSinceEpoch,
// //         'dayOffset': dayOffset,
// //         'adhanType': adhanType, // ⭐ جديد: نوع الأذان
// //         'isFajr': isFajr, // ⭐ جديد: هل هو الفجر؟
// //       },
// //       constraints: Constraints(
// //         networkType: NetworkType.notRequired,
// //         requiresBatteryNotLow: false,
// //         requiresCharging: false,
// //       ),
// //       backoffPolicy: BackoffPolicy.linear,
// //       backoffPolicyDelay: const Duration(seconds: 10),
// //     );
// //
// //     final delayInMinutes = delay.inMinutes;
// //     final delayInHours = delay.inHours;
// //
// //     if (delayInHours > 0) {
// //       print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInHours}س ${delayInMinutes % 60}د)');
// //     } else {
// //       print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInMinutes}د)');
// //     }
// //
// //     return true;
// //   } catch (e, stackTrace) {
// //     print('❌ خطأ في جدولة $prayerName: $e');
// //     print('Stack Trace: $stackTrace');
// //     return false;
// //   }
// // }
//
// // ==========================================
// // 🕌 حساب أوقات الصلاة
// // ==========================================
//
// // ==========================================
// // 🔄 إعادة الجدولة والإلغاء
// // ==========================================
//
// // ==========================================
// // 📊 معلومات الصلاة التالية
// // ==========================================
//
// class AdhanSettingsDialog extends StatefulWidget {
//   @override
//   State<AdhanSettingsDialog> createState() => _AdhanSettingsDialogState();
// }
//
// class _AdhanSettingsDialogState extends State<AdhanSettingsDialog> {
//   bool enableFajr = true;
//   bool enableNormal = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   Future<void> _load() async {
//     final prefs = await AdhanWorkManagerService().getAdhanPreferences();
//     setState(() {
//       enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
//       enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('⚙️ إعدادات الأذان'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SwitchListTile(
//             title: const Text('🌅 أذان الفجر'),
//             value: enableFajr,
//             onChanged: (v) async {
//               setState(() => enableFajr = v);
//               await AdhanWorkManagerService().saveAdhanPreferences(
//                 enableFajrAdhan: v,
//               );
//             },
//           ),
//           SwitchListTile(
//             title: const Text('🕌 الأذان العادي'),
//             value: enableNormal,
//             onChanged: (v) async {
//               setState(() => enableNormal = v);
//               await AdhanWorkManagerService().saveAdhanPreferences(
//                 enableNormalAdhan: v,
//               );
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إغلاق'),
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
//
//
//
//   // <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
//   // ```
//   //
//   // 3. **إنشاء Helper Class** تحتوي على:
//   // - `isBatteryOptimizationDisabled()` → فحص الحالة
//   // - `openBatteryOptimizationSettings()` → فتح الإعدادات مباشرة
//   // - `showBatteryOptimizationDialog()` → عرض Dialog تحذيري
//   // - `showBatteryOptimizationSnackBar()` → عرض SnackBar بسيط
//   //
//   // 4. **في `initState`**:
//   // - استدعاء `_checkBatteryOptimization()` لفحص الحالة أول ما الشاشة تفتح
//   // - إذا كان Battery Optimization مفعّل → يظهر Dialog
//   // - المستخدم يضغط "فتح الإعدادات" → يروح مباشرة لصفحة Battery Settings
//   //
//   // ---
//   //
//   // ## 🎯 **مميزات الحل:**
//   //
//   // ✅ **فحص تلقائي** عند فتح الشاشة
//   // ✅ **Dialog واضح** يشرح للمستخدم المشكلة
//   // ✅ **زر مباشر** لفتح صفحة الإعدادات
//   // ✅ **زر يدوي** في AppBar للفحص في أي وقت
//   // ✅ **دعم اللغة العربية** بالكامل
//   //
//   // ---
//   //
//   // ## 🔥 **بعد التطبيق:**
//   //
//   // المستخدم هيشوف رسالة زي دي:
//   // ```
//   // ⚠️ تنبيه هام
//   //
//   // حتى يعمل الأذان في الخلفية بشكل صحيح،
//   // يجب إيقاف وضع توفير البطارية للتطبيق.
//   //
//   // 📌 سنوجهك الآن إلى الإعدادات لتفعيل هذا الخيار
//   //
//   // [لاحقاً]  [فتح الإعدادات ⚙️]
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   // @pragma('vm:entry-point')
//   // void callbackDispatcher() {
//   //   Workmanager().executeTask((task, inputData) async {
//   //     try {
//   //       // ✅ تهيئة AwesomeNotifications داخل الـ Background Task
//   //       await AwesomeNotifications().initialize(
//   //         null,
//   //         [
//   //           NotificationChannel(
//   //             channelKey: 'adhan_channel',
//   //             channelName: 'أذان الصلاة',
//   //             channelDescription: 'تشغيل صوت الأذان',
//   //             importance: NotificationImportance.Max,
//   //             playSound: true,
//   //             soundSource: 'resource://raw/athan',
//   //             enableVibration: true,
//   //             enableLights: true,
//   //           ),
//   //         ],
//   //         debug: true,
//   //       );
//   //
//   //       final prayerName = inputData?['prayerName'] ?? 'الفجر';
//   //       final cityName = inputData?['cityName'] ?? '';
//   //       final prayerTime = inputData?['prayerTime'] ?? '';
//   //
//   //       print('🔔 جاري تشغيل أذان $prayerName - $cityName');
//   //
//   //       // ✅ إرسال الإشعار
//   //       await AwesomeNotifications().createNotification(
//   //         content: NotificationContent(
//   //           id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//   //           channelKey: 'adhan_channel',
//   //           title: '🕌 حان الآن موعد أذان $prayerName',
//   //           body: '$cityName - $prayerTime',
//   //           category: NotificationCategory.Alarm,
//   //           notificationLayout: NotificationLayout.Default,
//   //           wakeUpScreen: true,
//   //           fullScreenIntent: true,
//   //           criticalAlert: true,
//   //           autoDismissible: false,
//   //         ),
//   //         actionButtons: [
//   //           NotificationActionButton(
//   //             key: 'STOP_ADHAN',
//   //             label: 'إيقاف الأذان',
//   //             actionType: ActionType.DismissAction,
//   //           ),
//   //         ],
//   //       );
//   //
//   //       // ✅ تشغيل صوت الأذان (اختياري - الصوت سيشتغل من الإشعار نفسه)
//   //       try {
//   //         final audioPlayer = AudioPlayer();
//   //         await audioPlayer.setAsset('assets/athan/athan.mp3');
//   //         await audioPlayer.setVolume(1.0);
//   //         await audioPlayer.play();
//   //
//   //         await audioPlayer.playerStateStream.firstWhere(
//   //               (state) => state.processingState == ProcessingState.completed,
//   //         ).timeout(
//   //           const Duration(minutes: 5),
//   //           onTimeout: () => PlayerState(false, ProcessingState.completed),
//   //         );
//   //
//   //         await audioPlayer.dispose();
//   //       } catch (e) {
//   //         print('⚠️ خطأ في تشغيل الصوت: $e');
//   //       }
//   //
//   //       // ✅ إرسال إشعار انتهاء الأذان
//   //       await AwesomeNotifications().createNotification(
//   //         content: NotificationContent(
//   //           id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
//   //           channelKey: 'adhan_channel',
//   //           title: '✅ انتهى أذان $prayerName',
//   //           body: 'تم تشغيل الأذان بنجاح - $cityName',
//   //           notificationLayout: NotificationLayout.Default,
//   //         ),
//   //       );
//   //
//   //       return Future.value(true);
//   //     } catch (e, s) {
//   //       print('❌ خطأ في تشغيل الأذان: $e\n$s');
//   //       return Future.value(false);
//   //     }
//   //   });
//   // }
//   /// إعادة جدولة الأذان لليوم التالي
//
//
//   // =====================================
//   // 📦 AdhanWorkManagerService - نسخة محدثة بالكامل
//   // =====================================
//
//
//   // class AdhanWorkManagerService {
//   //   static final AdhanWorkManagerService _instance = AdhanWorkManagerService._internal();
//   //   factory AdhanWorkManagerService() => _instance;
//   //   AdhanWorkManagerService._internal();
//   //
//   //   // ==========================================
//   //   // 🎯 التهيئة الأساسية
//   //   // ==========================================
//   //
//   //   /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
//   //   Future<void> initialize({
//   //     Coordinates? coordinates,
//   //     CalculationParameters? calculationParams,
//   //     String? cityName,
//   //     int days = 7,
//   //   }) async {
//   //     try {
//   //       print('🚀 بدء تهيئة خدمة الأذان...');
//   //
//   //       // 1️⃣ إلغاء أي مهام قديمة
//   //       await Workmanager().cancelAll();
//   //       print('🗑️ تم إلغاء المهام القديمة');
//   //
//   //       // 2️⃣ جدولة الأذان لعدة أيام
//   //       await scheduleAllPrayersForMultipleDays(
//   //         coordinates: coordinates,
//   //         calculationParams: calculationParams,
//   //         cityName: cityName,
//   //         days: days,
//   //       );
//   //
//   //       print('✅ تم تهيئة خدمة الأذان بنجاح');
//   //     } catch (e, stackTrace) {
//   //       print('❌ خطأ في تهيئة AdhanWorkManager: $e');
//   //       print('Stack Trace: $stackTrace');
//   //     }
//   //   }
//   //
//   //   // ==========================================
//   //   // 📅 جدولة الصلوات
//   //   // ==========================================
//   //
//   //   /// جدولة جميع الصلوات لعدة أيام قادمة
//   //   Future<void> scheduleAllPrayersForMultipleDays({
//   //     Coordinates? coordinates,
//   //     CalculationParameters? calculationParams,
//   //     String? cityName,
//   //     int days = 7,
//   //     int daysCount = 7, // للتوافق مع الكود القديم
//   //   }) async {
//   //     try {
//   //       // استخدام days أو daysCount (أيهما أكبر)
//   //       final totalDays = days > daysCount ? days : daysCount;
//   //
//   //       print('📋 جدولة الأذان لـ $totalDays أيام...');
//   //
//   //       // 1️⃣ حفظ البيانات إذا تم تمريرها
//   //       if (coordinates != null) {
//   //         await saveCoordinates(coordinates.latitude, coordinates.longitude);
//   //         print('📍 تم حفظ الإحداثيات: ${coordinates.latitude}, ${coordinates.longitude}');
//   //       }
//   //       if (cityName != null) {
//   //         await saveCityName(cityName);
//   //         print('🏙️ تم حفظ المدينة: $cityName');
//   //       }
//   //       if (calculationParams != null) {
//   //         await _saveCalculationParams(calculationParams);
//   //         print('⚙️ تم حفظ إعدادات الحساب');
//   //       }
//   //
//   //       // 2️⃣ جدولة الصلوات لكل يوم
//   //       int scheduledCount = 0;
//   //       for (int day = 0; day < totalDays; day++) {
//   //         final targetDate = DateTime.now().add(Duration(days: day));
//   //         final prayerTimes = await _getPrayerTimesForDate(
//   //           targetDate,
//   //           coordinates: coordinates,
//   //           params: calculationParams,
//   //         );
//   //
//   //         for (var entry in prayerTimes.entries) {
//   //           final scheduled = await _schedulePrayer(
//   //             prayerName: entry.key,
//   //             prayerTime: entry.value,
//   //             dayOffset: day,
//   //             cityName: cityName,
//   //           );
//   //           if (scheduled) scheduledCount++;
//   //         }
//   //       }
//   //
//   //       print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
//   //     } catch (e, stackTrace) {
//   //       print('❌ خطأ في جدولة الصلوات: $e');
//   //       print('Stack Trace: $stackTrace');
//   //     }
//   //   }
//   //
//   //   /// جدولة جميع الصلوات لليوم الحالي فقط
//   //   Future<void> scheduleAllPrayers() async {
//   //     try {
//   //       print('📅 جدولة صلوات اليوم...');
//   //       final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
//   //
//   //       int scheduledCount = 0;
//   //       for (var entry in prayerTimes.entries) {
//   //         final scheduled = await _schedulePrayer(
//   //           prayerName: entry.key,
//   //           prayerTime: entry.value,
//   //         );
//   //         if (scheduled) scheduledCount++;
//   //       }
//   //
//   //       print('✅ تم جدولة $scheduledCount صلاة لليوم');
//   //     } catch (e) {
//   //       print('❌ خطأ في جدولة صلوات اليوم: $e');
//   //     }
//   //   }
//   //
//   //   /// جدولة أذان واحد بشكل محسّن
//   //   Future<bool> _schedulePrayer({
//   //     required String prayerName,
//   //     required DateTime prayerTime,
//   //     int dayOffset = 0,
//   //     String? cityName,
//   //   }) async {
//   //     final now = DateTime.now();
//   //     var delay = prayerTime.difference(now);
//   //
//   //     // ✅ تخطي الأوقات التي فاتت
//   //     if (delay.isNegative) {
//   //       if (dayOffset == 0) {
//   //         print('⏭️ تم تخطي $prayerName - الوقت فات (${_formatTime(prayerTime)})');
//   //       }
//   //       return false;
//   //     }
//   //
//   //     // ✅ التأكد من أن التأخير معقول
//   //     if (delay.inMinutes < 1) {
//   //       print('⚠️ تأخير قصير جداً لـ $prayerName (${delay.inSeconds} ثانية)');
//   //       return false;
//   //     }
//   //
//   //     try {
//   //       final savedCityName = cityName ?? await _getCityName();
//   //
//   //       // ✅ معرف فريد يتضمن timestamp لتجنب التكرار
//   //       final uniqueId = 'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';
//   //
//   //       // ✅ جدولة المهمة مع WorkManager
//   //       await Workmanager().registerOneOffTask(
//   //         uniqueId,
//   //         'adhanTask',
//   //         initialDelay: delay,
//   //         inputData: {
//   //           'prayerName': prayerName,
//   //           'cityName': savedCityName,
//   //           'prayerTime': _formatTime(prayerTime),
//   //           'timestamp': prayerTime.millisecondsSinceEpoch,
//   //           'dayOffset': dayOffset,
//   //         },
//   //         constraints: Constraints(
//   //           networkType: NetworkType.notRequired,
//   //           requiresBatteryNotLow: false,
//   //           requiresCharging: false,
//   //         ),
//   //         backoffPolicy: BackoffPolicy.linear,
//   //         backoffPolicyDelay: const Duration(seconds: 10),
//   //       );
//   //
//   //       final delayInMinutes = delay.inMinutes;
//   //       final delayInHours = delay.inHours;
//   //
//   //       if (delayInHours > 0) {
//   //         print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInHours}س ${delayInMinutes % 60}د)');
//   //       } else {
//   //         print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInMinutes}د)');
//   //       }
//   //
//   //       return true;
//   //     } catch (e, stackTrace) {
//   //       print('❌ خطأ في جدولة $prayerName: $e');
//   //       print('Stack Trace: $stackTrace');
//   //       return false;
//   //     }
//   //   }
//   //
//   //   // ==========================================
//   //   // 🕌 حساب أوقات الصلاة
//   //   // ==========================================
//   //
//   //   /// الحصول على أوقات الصلاة لتاريخ محدد
//   //   Future<Map<String, DateTime>> _getPrayerTimesForDate(
//   //       DateTime date, {
//   //         Coordinates? coordinates,
//   //         CalculationParameters? params,
//   //       }) async {
//   //     try {
//   //       // استخدام الإحداثيات المُمررة أو المحفوظة
//   //       final coords = coordinates ?? await _getSavedCoordinates();
//   //
//   //       // استخدام parameters المُمررة أو المحفوظة
//   //       final calculationParams = params ?? await _getSavedCalculationParams();
//   //
//   //       final components = DateComponents(date.year, date.month, date.day);
//   //       final prayerTimes = PrayerTimes(coords, components, calculationParams);
//   //
//   //       return {
//   //         'الفجر': prayerTimes.fajr,
//   //         'الظهر': prayerTimes.dhuhr,
//   //         'العصر': prayerTimes.asr,
//   //         'المغرب': prayerTimes.maghrib,
//   //         'العشاء': prayerTimes.isha,
//   //       };
//   //     } catch (e) {
//   //       print('❌ خطأ في حساب أوقات الصلاة: $e');
//   //       // أوقات افتراضية في حالة الخطأ
//   //       return _getDefaultPrayerTimes(date);
//   //     }
//   //   }
//   //
//   //   /// أوقات افتراضية في حالة الخطأ (القاهرة)
//   //   Map<String, DateTime> _getDefaultPrayerTimes(DateTime date) {
//   //     return {
//   //       'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
//   //       'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
//   //       'العصر': DateTime(date.year, date.month, date.day, 15, 15),
//   //       'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
//   //       'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
//   //     };
//   //   }
//   //
//   //   // ==========================================
//   //   // 💾 حفظ واسترجاع البيانات
//   //   // ==========================================
//   //
//   //   /// الحصول على الإحداثيات المحفوظة
//   //   Future<Coordinates> _getSavedCoordinates() async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
//   //     final longitude = prefs.getDouble('longitude') ?? 31.2357;
//   //     return Coordinates(latitude, longitude);
//   //   }
//   //
//   //   /// حفظ الإحداثيات
//   //   Future<void> saveCoordinates(double latitude, double longitude) async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     await prefs.setDouble('latitude', latitude);
//   //     await prefs.setDouble('longitude', longitude);
//   //   }
//   //
//   //   /// الحصول على اسم المدينة المحفوظ
//   //   Future<String> _getCityName() async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     return prefs.getString('city_name') ?? 'القاهرة';
//   //   }
//   //
//   //   /// حفظ اسم المدينة
//   //   Future<void> saveCityName(String cityName) async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     await prefs.setString('city_name', cityName);
//   //   }
//   //
//   //   /// حفظ إعدادات الحساب
//   //   Future<void> _saveCalculationParams(CalculationParameters params) async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     await prefs.setDouble('fajr_angle', params.fajrAngle);
//   //     await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
//   //     await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);
//   //
//   //     if (params.ishaInterval > 0) {
//   //       await prefs.setInt('isha_interval', params.ishaInterval);
//   //     }
//   //   }
//   //
//   //   /// الحصول على إعدادات الحساب المحفوظة
//   //   Future<CalculationParameters> _getSavedCalculationParams() async {
//   //     final prefs = await SharedPreferences.getInstance();
//   //
//   //     final fajrAngle = prefs.getDouble('fajr_angle');
//   //     final ishaAngle = prefs.getDouble('isha_angle');
//   //     final madhabIndex = prefs.getInt('madhab') ?? 0;
//   //     final ishaInterval = prefs.getInt('isha_interval') ?? 0;
//   //
//   //     // إذا مفيش بيانات محفوظة، استخدم الطريقة المصرية كـ default
//   //     if (fajrAngle == null || ishaAngle == null) {
//   //       final params = CalculationMethod.egyptian.getParameters();
//   //       params.madhab = Madhab.shafi;
//   //       return params;
//   //     }
//   //
//   //     final params = CalculationParameters(
//   //       fajrAngle: fajrAngle,
//   //       ishaAngle: ishaAngle,
//   //       ishaInterval: ishaInterval,
//   //     );
//   //     params.madhab = madhabIndex == 0 ? Madhab.shafi : Madhab.hanafi;
//   //
//   //     return params;
//   //   }
//   //
//   //   // ==========================================
//   //   // 🔄 إعادة الجدولة والإلغاء
//   //   // ==========================================
//   //
//   //   /// إعادة جدولة الأذان (استدعيها يومياً أو عند تغيير الموقع)
//   //   Future<void> reschedule({
//   //     Coordinates? coordinates,
//   //     CalculationParameters? calculationParams,
//   //     String? cityName,
//   //     int days = 7,
//   //   }) async {
//   //     try {
//   //       print('🔄 إعادة جدولة الأذان...');
//   //       await Workmanager().cancelAll();
//   //       await scheduleAllPrayersForMultipleDays(
//   //         coordinates: coordinates,
//   //         calculationParams: calculationParams,
//   //         cityName: cityName,
//   //         days: days,
//   //       );
//   //       print('✅ تمت إعادة الجدولة بنجاح');
//   //     } catch (e) {
//   //       print('❌ خطأ في إعادة الجدولة: $e');
//   //     }
//   //   }
//   //
//   //   /// إلغاء جميع المهام
//   //   Future<void> cancelAll() async {
//   //     try {
//   //       await Workmanager().cancelAll();
//   //       print('🗑️ تم إلغاء جميع مهام الأذان');
//   //     } catch (e) {
//   //       print('❌ خطأ في إلغاء المهام: $e');
//   //     }
//   //   }
//   //
//   //   // ==========================================
//   //   // 📊 معلومات الصلاة التالية
//   //   // ==========================================
//   //
//   //   /// الحصول على الصلاة التالية
//   //   Future<Map<String, dynamic>?> getNextPrayer() async {
//   //     try {
//   //       final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
//   //       final now = DateTime.now();
//   //
//   //       // البحث عن الصلاة التالية اليوم
//   //       for (var entry in prayerTimes.entries) {
//   //         if (entry.value.isAfter(now)) {
//   //           final timeUntil = entry.value.difference(now);
//   //           return {
//   //             'name': entry.key,
//   //             'time': entry.value,
//   //             'timeUntil': timeUntil,
//   //             'formattedTime': _formatTime(entry.value),
//   //             'remainingMinutes': timeUntil.inMinutes,
//   //           };
//   //         }
//   //       }
//   //
//   //       // إذا كل الأوقات فاتت، جيب أول صلاة بكرة (الفجر)
//   //       final tomorrowPrayers = await _getPrayerTimesForDate(
//   //         DateTime.now().add(const Duration(days: 1)),
//   //       );
//   //       final firstPrayer = tomorrowPrayers.entries.first;
//   //       final timeUntil = firstPrayer.value.difference(now);
//   //
//   //       return {
//   //         'name': firstPrayer.key,
//   //         'time': firstPrayer.value,
//   //         'timeUntil': timeUntil,
//   //         'formattedTime': _formatTime(firstPrayer.value),
//   //         'remainingMinutes': timeUntil.inMinutes,
//   //         'isTomorrow': true,
//   //       };
//   //     } catch (e) {
//   //       print('❌ خطأ في الحصول على الصلاة التالية: $e');
//   //       return null;
//   //     }
//   //   }
//   //
//   //   // ==========================================
//   //   // 🛠️ دوال مساعدة
//   //   // ==========================================
//   //
//   //   /// تنسيق الوقت بالعربي
//   //   String _formatTime(DateTime time) {
//   //     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
//   //     final minute = time.minute.toString().padLeft(2, '0');
//   //     final period = time.hour >= 12 ? 'م' : 'ص';
//   //     return '$hour:$minute $period';
//   //   }
//   //
//   //   /// طباعة جميع الأوقات المجدولة (للتجربة والتطوير)
//   //   Future<void> printScheduledPrayers({
//   //     Coordinates? coordinates,
//   //     CalculationParameters? calculationParams,
//   //     int days = 7,
//   //   }) async {
//   //     print('\n╔════════════════════════════════════╗');
//   //     print('║   📋 أوقات الصلاة المجدولة       ║');
//   //     print('╚════════════════════════════════════╝\n');
//   //
//   //     for (int day = 0; day < days; day++) {
//   //       final date = DateTime.now().add(Duration(days: day));
//   //       final prayerTimes = await _getPrayerTimesForDate(
//   //         date,
//   //         coordinates: coordinates,
//   //         params: calculationParams,
//   //       );
//   //
//   //       final dayName = _getDayName(date.weekday);
//   //       print('📅 $dayName ${date.day}/${date.month}/${date.year}:');
//   //       print('─────────────────────────────────────');
//   //
//   //       for (var entry in prayerTimes.entries) {
//   //         final icon = _getPrayerIcon(entry.key);
//   //         print('   $icon ${entry.key}: ${_formatTime(entry.value)}');
//   //       }
//   //       print('');
//   //     }
//   //     print('════════════════════════════════════════\n');
//   //   }
//   //
//   //   /// الحصول على اسم اليوم بالعربي
//   //   String _getDayName(int weekday) {
//   //     const days = [
//   //       'الإثنين',
//   //       'الثلاثاء',
//   //       'الأربعاء',
//   //       'الخميس',
//   //       'الجمعة',
//   //       'السبت',
//   //       'الأحد'
//   //     ];
//   //     return days[weekday - 1];
//   //   }
//   //
//   //   /// الحصول على أيقونة الصلاة
//   //   String _getPrayerIcon(String prayerName) {
//   //     switch (prayerName) {
//   //       case 'الفجر':
//   //         return '🌅';
//   //       case 'الظهر':
//   //         return '☀️';
//   //       case 'العصر':
//   //         return '🌤️';
//   //       case 'المغرب':
//   //         return '🌆';
//   //       case 'العشاء':
//   //         return '🌙';
//   //       default:
//   //         return '🕌';
//   //     }
//   //   }
//   //
//   //   /// التحقق من حالة الجدولة
//   //   Future<Map<String, dynamic>> getSchedulingStatus() async {
//   //     try {
//   //       final nextPrayer = await getNextPrayer();
//   //       final coords = await _getSavedCoordinates();
//   //       final city = await _getCityName();
//   //
//   //       return {
//   //         'isScheduled': nextPrayer != null,
//   //         'nextPrayer': nextPrayer,
//   //         'city': city,
//   //         'coordinates': {
//   //           'latitude': coords.latitude,
//   //           'longitude': coords.longitude,
//   //         },
//   //         'timestamp': DateTime.now().toIso8601String(),
//   //       };
//   //     } catch (e) {
//   //       return {
//   //         'isScheduled': false,
//   //         'error': e.toString(),
//   //       };
//   //     }
//   //   }
//   // }
//   // =====================================
//   // 📦 AdhanWorkManagerService - نسخة محدثة بالكامل
//   // =====================================
//
import 'dart:async';
import 'dart:ui' as ui;

import 'package:adhan/adhan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/features/mainView/controllar/MainController.dart';
import 'package:mvc_pattern/mvc_pattern.dart' hide StateSetter;

import '../../core/utils/style/app_theme_colors.dart';
import 'adhan_callback.dart';
import 'adhan_workmanager_service.dart';

class AzanView extends StatefulWidget {
  const AzanView({super.key});

  @override
  _AzanViewState createState() => _AzanViewState();
}

class _AzanViewState extends StateMVC<AzanView> {
  _AzanViewState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;

  // استخدام خدمة WorkManager
  // final AdhanWorkManagerService _adhanService = AdhanWork                  ManagerService();

  @override
  void initState() {
    super.initState();

    // _adhanService.initialize();
    con.refreshPrayerTimesFromPrefs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ فحص Battery Optimization أول ما الشاشة تفتح
      _checkBatteryOptimization();

      _scheduleAllPrayerNotifications();
    });
  }

  // /// 🔋 فحص حالة Battery Optimization وعرض تحذير إذا لزم الأمر
  Future<void> _checkBatteryOptimization() async {
    // ✅ الدالة دي بتفحص الأول، ولو مش مفعّل بس هتظهر الـ Dialog
    await BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
  }

  // جدولة إشعارات الصلاة
  Future<void> _scheduleAllPrayerNotifications() async {
    try {
      final prayerTimes = con.prayerTimes;
      final selectedCity = con.selectedCity;

      if (prayerTimes == null) {
        print("⚠️ مواقيت الصلاة غير متاحة");
        return;
      }

      final cities = con.cities;
      final double? lat;
      final double? lng;
      final String cityName = selectedCity ?? "غير معروف";

      if (con.isUsingGPS && con.latitude != null && con.longitude != null) {
        lat = con.latitude;
        lng = con.longitude;
      } else {
        if (cities.isEmpty || selectedCity == null) return;
        final cityData = cities[selectedCity];
        if (cityData == null) return;
        lat = (cityData['lat'] as num?)?.toDouble();
        lng = (cityData['lng'] as num?)?.toDouble();
      }

      if (lat == null || lng == null) return;

      final coordinates = Coordinates(lat, lng);
      final calculationParams = con.selectedMethod.getParameters();
      calculationParams.madhab = con.selectedMadhab;

      await AdhanWorkManagerService().initialize(
        coordinates: coordinates,
        calculationParams: calculationParams,
        cityName: cityName,
        days: 7,
      );

      if (mounted) {
        KHelper.showSuccess(
          message: 'تم جدولة الأذان لـ 30 يوماً بنجاح',
        );
      }
    } catch (e) {
      print("❌ خطأ في جدولة الإشعارات: $e");
      if (mounted) {
        KHelper.showError(message: "حدث خطأ في جدولة الإشعارات: $e");
      }
    }
  }

  // تحديد أقرب مدينة بالـ GPS
  Future<void> _selectByLocation() async {
    try {
      await con.autoDetectLocation();
      setState(() {});
      await _scheduleAllPrayerNotifications();
    } catch (e) {
      if (mounted) {
        KHelper.showError(message: 'حدث خطأ أثناء تحديد الموقع');
      }
    }
  }

  void _showCalculationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '⚙️ إعدادات الحساب',
                          style: GoogleFonts.cairo(
                            fontSize: ResponsiveUtil.isTablet(context)
                                ? 11.sp
                                : 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🎯 قسم اختيار الموقع
                        _buildLocationSelector(
                          context,
                          isDark,
                          con.countries,
                          con.cities,
                          con.selectedCountry,
                          con.selectedCity,
                          onLocationChanged: () => setStateSheet(() {}),
                        ),

                        const SizedBox(height: 24),

                        // طريقة الحساب
                        Text(
                          'طريقة الحساب',
                          style: GoogleFonts.cairo(
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMethodDropdown(isDark, setStateSheet),

                        const SizedBox(height: 16),

                        // المذهب
                        Text(
                          'المذهب (صلاة العصر)',
                          style: GoogleFonts.cairo(
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMadhabDropdown(isDark, setStateSheet),

                        const SizedBox(height: 16),

                        const SizedBox(height: 16),

                        // تعديل الساعات (فارق التوقيت)
                        // Text(
                        //   'تعديل الساعات (فارق التوقيت)',
                        //   style: GoogleFonts.cairo(
                        //     fontSize: 14.sp,
                        //     color: Colors.grey,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 12, vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: isDark
                        //         ? Colors.black.withOpacity(0.2)
                        //         : Colors.grey.shade100,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //         color:
                        //             isDark ? Colors.white10 : Colors.grey.shade300),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       IconButton(
                        //         icon: const Icon(Icons.remove_circle_outline,
                        //             color: Colors.red),
                        //         onPressed: () {
                        //           setStateSheet(() {
                        //             con.manualOffset--;
                        //           });
                        //         },
                        //       ),
                        //       Text(
                        //         "${con.manualOffset > 0 ? '+' : ''}${con.manualOffset} ساعة",
                        //         style: GoogleFonts.cairo(
                        //           fontSize: 16.sp,
                        //           fontWeight: FontWeight.bold,
                        //           color: isDark ? Colors.white : Colors.black87,
                        //         ),
                        //       ),
                        //       IconButton(
                        //         icon: const Icon(Icons.add_circle_outline,
                        //             color: Colors.green),
                        //         onPressed: () {
                        //           setStateSheet(() {
                        //             con.manualOffset++;
                        //           });
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        const SizedBox(height: 16),

                        // تعديل الدقائق يدوياً لكل صلاة
                        Text(
                          'تعديل الدقائق يدوياً (لكل صلاة)',
                          style: GoogleFonts.cairo(
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildIndividualOffsetAdjuster(
                            'الفجر', con.fajrOffset, isDark, setStateSheet),
                        _buildIndividualOffsetAdjuster(
                            'الظهر', con.dhuhrOffset, isDark, setStateSheet),
                        _buildIndividualOffsetAdjuster(
                            'العصر', con.asrOffset, isDark, setStateSheet),
                        _buildIndividualOffsetAdjuster(
                            'المغرب', con.maghribOffset, isDark, setStateSheet),
                        _buildIndividualOffsetAdjuster(
                            'العشاء', con.ishaOffset, isDark, setStateSheet),

                        const SizedBox(height: 30),

                        // زر الحفظ
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // حفظ وتحديث
                              con.updateCalcSettings(
                                method: con.selectedMethod,
                                madhab: con.selectedMadhab,
                                offset: con.manualOffset,
                              );
                              _scheduleAllPrayerNotifications(); // إعادة الجدولة
                              Navigator.pop(context);
                              KHelper.showSuccess(
                                  message: "تم تحديث طريقة الحساب بنجاح");
                            },
                            child: Text(
                              'حفظ التغييرات',
                              style: GoogleFonts.cairo(
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 10.sp
                                    : 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.darkerColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _scheduleAllPrayerNotifications(); // إعادة الجدولة
                              Navigator.pop(context);
                            },
                            child: Text(
                              'الغاء',
                              style: GoogleFonts.cairo(
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 10.sp
                                    : 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMethodDropdown(
      bool isDark, void Function(void Function()) setStateSheet) {
    // قائمة الطرق المعربة
    final Map<CalculationMethod, String> methods = {
      CalculationMethod.egyptian: "الهيئة المصرية العامة للمساحة",
      CalculationMethod.muslim_world_league: "رابطة العالم الإسلامي",
      CalculationMethod.umm_al_qura: "أم القرى (مكة المكرمة)",
      CalculationMethod.karachi: "جامعة العلوم الإسلامية، كراتشي",
      CalculationMethod.dubai: "دبي",
      CalculationMethod.kuwait: "الكويت",
      CalculationMethod.north_america: "أمريكا الشمالية (ISNA)",
      CalculationMethod.singapore: "سنغافورة",
      CalculationMethod.turkey: "تركيا",
      CalculationMethod.tehran: "طهران",
      CalculationMethod.qatar: "قطر",
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<CalculationMethod>(
          isExpanded: true,
          hint: const Text('اختر الطريقة'),
          items: methods.entries.map((item) {
            return DropdownMenuItem<CalculationMethod>(
              value: item.key,
              child: Text(
                item.value,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          value: con.selectedMethod,
          onChanged: (value) {
            if (value != null) {
              setStateSheet(() {
                con.selectedMethod = value;
              });
            }
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 50,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 400,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildMadhabDropdown(
      bool isDark, void Function(void Function()) setStateSheet) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Madhab>(
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: Madhab.shafi,
              child: Text(
                'الشافعي / المالكي / الحنبلي (الجمهور)',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DropdownMenuItem(
              value: Madhab.hanafi,
              child: Text(
                'الحنفي',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
          value: con.selectedMadhab,
          onChanged: (value) {
            if (value != null) {
              setStateSheet(() {
                con.selectedMadhab = value;
              });
            }
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 50,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // لا داعي لـ dispose WorkManager
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCountry = con.selectedCountry;
    final selectedCity = con.selectedCity;
    final prayerTimes = con.prayerTimes;
    final nextPrayer = con.nextPrayer;
    final remainingTimeText = con.remainingTimeText;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
        child: AppBar(
leading: Navigator.canPop(context)
              ? CupertinoNavigationBarBackButton(
                  color: isDark ? Colors.white : Colors.black,
                )
              : null,
          centerTitle: true,
          title: Text(
            "مواقيت الصلاة",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
          actions: [
            // زر اختبار الأذان 🧪
            // IconButton(
            //   icon: const Icon(Icons.bug_report, color: Colors.orange),
            //   tooltip: 'اختبار الأذان (20 ثانية)',
            //   onPressed: () async {
            //     bool isAllowed =
            //         await AwesomeNotifications().isNotificationAllowed();
            //     if (!isAllowed) {
            //       await AwesomeNotifications()
            //           .requestPermissionToSendNotifications();
            //       isAllowed =
            //           await AwesomeNotifications().isNotificationAllowed();
            //       if (!isAllowed) {
            //         KHelper.showError(message: 'يجب تفعيل الإشعارات أولاً!');
            //         return;
            //       }
            //     }
            //
            //     try {
            //       KHelper.showSuccess(message: 'جاري جدولة الاختبار...');
            //
            //       final error = await AdhanWorkManagerService()
            //           .scheduleTestAdhan(secondsFromNow: 20);
            //       if (!mounted) return;
            //
            //       if (error == null) {
            //         KHelper.showSuccess(
            //           message:
            //               '🧪 تم جدولة أذان تجريبي بعد 20 ثانية\nانتظر وتأكد من ظهور الشاشة!',
            //         );
            //       } else {
            //         KHelper.showError(
            //           message: '❌ فشلت جدولة الأذان التجريبي: $error',
            //         );
            //       }
            //     } catch (e) {
            //       if (!mounted) return;
            //       showDialog(
            //         context: context,
            //         builder: (ctx) => AlertDialog(
            //           title: const Text('خطأ في الاختبار'),
            //           content: Text(e.toString()),
            //           actions: [
            //             TextButton(
            //                 onPressed: () => Navigator.pop(ctx),
            //                 child: const Text('حسنًا'))
            //           ],
            //         ),
            //       );
            //     }
            //   },
            // ),
            //
            // // زر اختبار فوري (بدون جدولة) للتشخيص
            // IconButton(
            //   icon: const Icon(Icons.flash_on, color: Colors.blue),
            //   tooltip: 'إشعار تجريبي فوري',
            //   onPressed: () async {
            //     await AwesomeNotifications().createNotification(
            //       content: NotificationContent(
            //         id: 77777,
            //         channelKey:
            //             'adhan_channel_v4', // Use adhan channel for sound test
            //         title: '⚡ اختبار فوري',
            //         body: 'إذا وصلك هذا، فالإشعارات تعمل بنجاح!',
            //         notificationLayout: NotificationLayout.Default,
            //         payload: {
            //           'prayerName': 'تجربة',
            //           'route':
            //               'adhan_screen', // Force overlay for instant test too
            //           'prayer_time': 'الآن',
            //           'cityName': 'تجربة'
            //         },
            //       ),
            //     );
            //     if (context.mounted) {
            //       KHelper.showSuccess(message: 'تم إرسال إشعار فوري');
            //     }
            //   },
            // ),

            // زر اختبار الأذان 🧪
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              tooltip: 'اختبار الأذان (20 ثانية)',
              onPressed: () async {
                bool isAllowed =
                    await AwesomeNotifications().isNotificationAllowed();
                if (!isAllowed) {
                  await AwesomeNotifications()
                      .requestPermissionToSendNotifications();
                  isAllowed =
                      await AwesomeNotifications().isNotificationAllowed();
                  if (!isAllowed) {
                    KHelper.showError(message: 'يجب تفعيل الإشعارات أولاً!');
                    return;
                  }
                }

                try {
                  KHelper.showSuccess(message: 'جاري جدولة الاختبار...');
                  final success = await AdhanWorkManagerService()
                      .scheduleTestAdhan(secondsFromNow: 20);
                  if (success == null) {
                    KHelper.showSuccess(
                        message: '🧪 تم جدولة اختبار شامل بعد 20 ثانية');
                  } else {
                    KHelper.showError(message: '❌ فشل الاختبار: $success');
                  }
                } catch (e) {
                  KHelper.showError(message: '❌ خطأ: $e');
                }
              },
            ),

            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات الحساب',
              onPressed: _showCalculationSettings,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة جدولة الإشعارات',
              onPressed: _scheduleAllPrayerNotifications,
            ),
          ],
          // actions: [
          //   if (Platform.isAndroid)
          //     FutureBuilder<bool>(
          //       future: BatteryOptimizationHelper.isBatteryOptimizationDisabled(),
          //       builder: (context, snapshot) {
          //         return IconButton(
          //           icon: const Icon(Icons.battery_charging_full),
          //           tooltip: 'فحص إعدادات البطارية',
          //           onPressed: () async {
          //             final isDisabled = await BatteryOptimizationHelper.isBatteryOptimizationDisabled();
          //             if (!mounted) return;
          //
          //             if (isDisabled) {
          //               KHelper.showSuccess(message: "التطبيق مُستثنى من توفير البطارية");
          //             } else {
          //               BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
          //             }
          //           },
          //         );
          //       },
          //     ),
          //   IconButton(
          //     icon: const Icon(Icons.refresh),
          //     tooltip: 'إعادة جدولة الإشعارات',
          //     onPressed: _scheduleAllPrayerNotifications,
          //   ),
          // ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: isDark
            //       ? [
            //     const Color(0xFF0F172A),
            //     const Color(0xFF1E293B),
            //     const Color(0xFF0F172A),
            //   ]
            //       : [
            //     Colors.blue.shade50,
            //     Colors.white,
            //     Colors.blue.shade50,
            //   ],
            // ),
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Column(
              children: [
                // 🎯 قسم عرض الموقع الحالي فقط
                if (con.isLoadingLocation)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: KLoading.progressIOSIndicator(context: context),
                  )
                else if (selectedCountry != null && selectedCity != null)
                  FadeAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: buildCurrentLocation(
                        context, isDark, selectedCountry, selectedCity),
                  ),

                const SizedBox(height: 24),

                // ⏰ الصلاة القادمة (بطاقة مميزة)
                if (prayerTimes != null && nextPrayer.isNotEmpty)
                  FadeAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _buildNextPrayerCard(context, isDark, nextPrayer,
                        remainingTimeText, prayerTimes),
                  ),

                const SizedBox(height: 24),

                // 📋 قائمة المواقيت المحسّنة
                if (prayerTimes != null)
                  Expanded(
                    child: _buildPrayerTimesList(
                        context, isDark, prayerTimes, nextPrayer),
                  )
                else
                  KLoading.progressIOSIndicator(context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(
    BuildContext context,
    bool isDark,
    Map countries,
    Map cities,
    String? selectedCountry,
    String? selectedCity, {
    VoidCallback? onLocationChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'اختر موقعك',
                style: GoogleFonts.cairo(
                  fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Dropdown الدولة
              Expanded(
                child: _buildCustomDropdown(
                  context: context,
                  isDark: isDark,
                  hint: 'الدولة',
                  items: {
                    ...countries.keys.map((e) => e.toString()),
                    if (selectedCountry != null) selectedCountry,
                    'مخصص',
                    'تحديد تلقائي',
                  }.toList(),
                  value: selectedCountry,
                  icon: Icons.public,
                  onChanged: (value) async {
                    if (value == null ||
                        value == 'مخصص' ||
                        value == 'تحديد تلقائي') return;
                    final Map<String, dynamic> cityMap = (countries[value]
                        as Map<String, dynamic>)
                      ..removeWhere((k, v) => v == null);
                    final firstCity = cityMap.keys.first;
                    await con.setLocation(country: value, city: firstCity);
                    if (onLocationChanged != null) onLocationChanged();
                    setState(() {});
                    await _scheduleAllPrayerNotifications();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown المدينة
              Expanded(
                child: _buildCustomDropdown(
                  context: context,
                  isDark: isDark,
                  hint: 'المدينة',
                  items: {
                    ...cities.keys.map((e) => e.toString()),
                    if (selectedCity != null) selectedCity,
                    'إحداثيات يدوية',
                    'الموقع الفعلي (GPS)',
                  }.toList(),
                  value: selectedCity,
                  icon: Icons.location_on,
                  onChanged: (value) async {
                    if (value == null ||
                        selectedCountry == null ||
                        value == 'إحداثيات يدوية' ||
                        value == 'الموقع الفعلي (GPS)') return;
                    await con.setLocation(
                        country: selectedCountry, city: value);
                    if (onLocationChanged != null) onLocationChanged();
                    setState(() {});
                    await _scheduleAllPrayerNotifications();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // زر GPS
              Expanded(
                child: InkWell(
                  onTap: (countries.isEmpty || con.isLoadingLocation)
                      ? null
                      : () async {
                          await _selectByLocation();
                          if (onLocationChanged != null) onLocationChanged();
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (countries.isEmpty || con.isLoadingLocation)
                            ? [Colors.grey, Colors.grey]
                            : isDark
                                ? [Colors.teal.shade700, Colors.teal.shade900]
                                : [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (con.isLoadingLocation)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          const Icon(Icons.my_location,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          con.isLoadingLocation
                              ? 'جاري التحديد...'
                              : 'تحديد تلقائي',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // زر إدخال يدوي للإحداثيات
              Expanded(
                child: InkWell(
                  onTap: () => _showManualCoordDialog(
                      context, isDark, onLocationChanged),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_location_alt,
                            color:
                                isDark ? Colors.white70 : Colors.grey.shade700,
                            size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'إحداثيات يدوية',
                          style: GoogleFonts.cairo(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualCoordDialog(
      BuildContext context, bool isDark, VoidCallback? onLocationChanged) {
    final latController =
        TextEditingController(text: con.latitude?.toString() ?? '');
    final lngController =
        TextEditingController(text: con.longitude?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إدخال الإحداثيات يدوياً',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل خط العرض وخط الطول بدقة (مثال: 30.04)',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.cairo(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'خط العرض (Latitude)',
                labelStyle: GoogleFonts.cairo(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.cairo(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'خط الطول (Longitude)',
                labelStyle: GoogleFonts.cairo(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              if (lat != null && lng != null) {
                await con.setManualCoordinates(lat, lng);
                if (onLocationChanged != null) onLocationChanged();
                if (context.mounted) Navigator.pop(context);
                KHelper.showSuccess(message: 'تم حفظ الإحداثيات بنجاح');
              } else {
                KHelper.showError(message: 'يرجى إدخال أرقام صحيحة');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🎨 Dropdown مخصص
  Widget _buildCustomDropdown({
    required BuildContext context,
    required bool isDark,
    required String hint,
    required List<String> items,
    required String? value,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        // decoration: BoxDecoration(
        //   color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
        //   borderRadius: BorderRadius.circular(12),
        //   border: Border.all(
        //     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        //   ),
        // ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        ),

        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  hint,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 13.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            value: value,
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 50,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              overlayColor: WidgetStateProperty.all(
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
              ),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: TextEditingController(),
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white : Colors.black87),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'ابحث عن $hint...',
                    hintStyle: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                        color: Colors.grey),
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value.toString().contains(searchValue);
              },
            ),
            // This clears the search value when the dropdown is closed
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                // (searchController as TextEditingController).clear();
              }
            },
          ),
        ),
      ),
    );
  }

  // 📍 عرض الموقع الحالي
  Widget buildCurrentLocation(
    BuildContext context,
    bool isDark,
    String selectedCountry,
    String selectedCity,
  ) {
    if (con.isLoadingLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: KLoading.progressIOSIndicator(context: context),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors:
          //      [Colors.indigo.shade800, Colors.purple.shade900]
          //       // : [Colors.blue.shade100, Colors.purple.shade100],
          // ),
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: isDark ? Colors.black38 : Colors.blue.withOpacity(0.2),
          //     blurRadius: 10,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
          color: AppThemeColors.cardBackgroundColor(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            con.isUsingGPS ? Icons.gps_fixed : Icons.place_rounded,
            color: con.isUsingGPS
                ? Colors.green
                : (isDark ? Colors.amberAccent : Colors.blue.shade800),
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (con.isUsingGPS && selectedCity == 'الموقع الفعلي (GPS)')
                      ? 'موقعك الفعلي (GPS)'
                      : '$selectedCountry - $selectedCity',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (con.isUsingGPS &&
                    con.latitude != null &&
                    con.longitude != null)
                  Text(
                    'إحداثيات: ${con.latitude!.toStringAsFixed(4)}, ${con.longitude!.toStringAsFixed(4)}',
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⏰ بطاقة الصلاة القادمة
  Widget _buildNextPrayerCard(
    BuildContext context,
    bool isDark,
    String nextPrayer,
    String remainingTimeText,
    dynamic prayerTimes,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [KColors.primaryColor, Colors.teal.shade500],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: KColors.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nextPrayer,
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'الوقت المتبقي: $remainingTimeText',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📋 قائمة المواقيت
  Widget _buildPrayerTimesList(
    BuildContext context,
    bool isDark,
    dynamic prayerTimes,
    String nextPrayer,
  ) {
    // ... (logic remains same, just ensuring it's a class member)
    final prayerData = [
      {"name": "الفجر", "time": prayerTimes.fajr, "icon": Icons.wb_twilight},
      {"name": "الشروق", "time": prayerTimes.sunrise, "icon": Icons.wb_sunny},
      {"name": "الظهر", "time": prayerTimes.dhuhr, "icon": Icons.light_mode},
      {
        "name": "العصر",
        "time": prayerTimes.asr,
        "icon": Icons.wb_sunny_outlined
      },
      {
        "name": "المغرب",
        "time": prayerTimes.maghrib,
        "icon": Icons.wb_twilight
      },
      {
        "name": "العشاء",
        "time": prayerTimes.isha,
        "icon": Icons.nightlight_round
      },
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: prayerData.length,
      itemBuilder: (context, index) {
        final prayer = prayerData[index];
        final isNext = nextPrayer.contains(prayer["name"] as String);

        return StaggeredItemAnimation(
          index: index,
          duration: const Duration(milliseconds: 400),
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: (isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                  : [Colors.white, Colors.grey.shade50]),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isNext
                    ? (isDark
                        ? Colors.green.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3))
                    : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.2)),
                blurRadius: isNext ? 15 : 8,
                offset: Offset(0, isNext ? 6 : 3),
              ),
            ],
            border: isNext
                ? Border.all(
                    color: KColors.primaryColor,
                    width: 2,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.grey.withOpacity(0.1)
                        : (isDark ? Colors.grey.shade800 : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    prayer["icon"] as IconData,
                    color: isNext
                        ? Colors.green
                        : (isDark ? Colors.white : Colors.blue.shade700),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    prayer["name"] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isNext
                          ? Colors.green
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.grey.withOpacity(0.2)
                        : (isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    intl.DateFormat('h:mm a')
                        .format((prayer["time"] as DateTime).toLocal()),
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isNext
                          ? Colors.green.shade400
                          : (isDark ? Colors.white : Colors.blue.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ),),
        );
      },
    );
  }

  Widget _buildIndividualOffsetAdjuster(String prayer, int currentOffset,
      bool isDark, StateSetter setStateSheet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayer,
            style: GoogleFonts.cairo(
              fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 20),
                onPressed: () {
                  setStateSheet(() {
                    con.adjustPrayerOffset(prayer, -1);
                  });
                },
              ),
              SizedBox(
                width: ResponsiveUtil.isTablet(context) ? 30 : 45,
                child: Text(
                  "${currentOffset > 0 ? '+' : ''}$currentOffset",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.green, size: 20),
                onPressed: () {
                  setStateSheet(() {
                    con.adjustPrayerOffset(prayer, 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
  @pragma('vm:entry-point')
  void callbackDispatcher() {  // ✅ يجب أن تكون static
    Workmanager().executeTask((task, inputData) async {
      try {
        // ✅ تحديد نوع الأذان
        final isFajr = inputData?['isFajr'] ?? false;
        final prayerName = inputData?['prayerName'] ?? 'الفجر';
        final cityName = inputData?['cityName'] ?? '';
        final prayerTime = inputData?['prayerTime'] ?? '';

        // ✅ اختيار القناة المناسبة
        final channelKey = isFajr ? 'fajr_adhan_channel' : 'adhan_channel';
        final soundSource = isFajr ? 'resource://raw/fajr' : 'resource://raw/athan';

        print('🔔 جاري تشغيل أذان $prayerName (${isFajr ? "الفجر" : "عادي"})');

        // ✅ تهيئة الإشعارات
        await AwesomeNotifications().initialize(
          null,
          [
            NotificationChannel(
              channelKey: 'fajr_adhan_channel',
              channelName: 'أذان الفجر',
              channelDescription: 'تشغيل أذان الفجر',
              importance: NotificationImportance.Max,
              playSound: true,
              soundSource: 'resource://raw/fajr',
              enableVibration: true,
              enableLights: true,
              ledColor: Colors.orange,
            ),
            NotificationChannel(
              channelKey: 'adhan_channel',
              channelName: 'أذان الصلاة',
              channelDescription: 'تشغيل صوت الأذان',
              importance: NotificationImportance.Max,
              playSound: true,
              soundSource: 'resource://raw/athan',
              enableVibration: true,
              enableLights: true,
              ledColor: Colors.green,
            ),
          ],
        );

        // ✅ إرسال الإشعار مع الصوت المناسب
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            channelKey: channelKey, // ⭐ القناة المناسبة
            title: isFajr
                ? '🌅 حان الآن موعد أذان الفجر'
                : '🕌 حان الآن موعد أذان $prayerName',
            body: '$cityName - $prayerTime',
            category: NotificationCategory.Alarm,
            notificationLayout: NotificationLayout.Default,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            autoDismissible: false,
            backgroundColor: isFajr ? Colors.orange : Colors.green,
          ),
          actionButtons: [
            NotificationActionButton(
              key: 'STOP_ADHAN',
              label: 'إيقاف الأذان',
              actionType: ActionType.DismissAction,
              isDangerousOption: true,
            ),
            NotificationActionButton(
              key: 'MUTE_ADHAN',
              label: 'كتم الصوت',
              actionType: ActionType.DismissAction,
            ),
          ],
        );

        // ⏰ انتظار انتهاء الأذان (3-5 دقائق تقريباً)
        await Future.delayed(const Duration(minutes: 3));

        // ✅ إشعار الانتهاء
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
            channelKey: channelKey,
            title: '✅ انتهى أذان $prayerName',
            body: 'تم تشغيل الأذان بنجاح - $cityName',
            notificationLayout: NotificationLayout.Default,
          ),
        );

        return Future.value(true);
      } catch (e, s) {
        print('❌ خطأ في تشغيل الأذان: $e\n$s');
        return Future.value(false);
      }
    });
  }
  */

Future<void> _rescheduleNextDay() async {
  try {
    await AdhanWorkManagerService().reschedule();
  } catch (e) {
    print('❌ خطأ في إعادة الجدولة: $e');
  }
}

// ==========================================
// 🎯 التهيئة الأساسية
// ==========================================

/// تهيئة الخدمة وجدولة جميع أوقات الصلاة

// ==========================================
// 📅 جدولة الصلوات
// ==========================================

/// جدولة جميع الصلوات لعدة أيام قادمة

// Future<bool> _schedulePrayer({
//   required String prayerName,
//   required DateTime prayerTime,
//   int dayOffset = 0,
//   String? cityName,
// }) async {
//   final now = DateTime.now();
//   var delay = prayerTime.difference(now);
//
//   // ✅ تخطي الأوقات التي فاتت
//   if (delay.isNegative) {
//     if (dayOffset == 0) {
//       print('⏭️ تم تخطي $prayerName - الوقت فات (${_formatTime(prayerTime)})');
//     }
//     return false;
//   }
//
//   // ✅ التأكد من أن التأخير معقول
//   if (delay.inMinutes < 1) {
//     print('⚠️ تأخير قصير جداً لـ $prayerName (${delay.inSeconds} ثانية)');
//     return false;
//   }
//
//   try {
//     final savedCityName = cityName ?? await _getCityName();
//
//     // ✅ تحديد نوع الأذان (الفجر له أذان مختلف)
//     final isFajr = prayerName == 'الفجر';
//     final adhanType = isFajr ? 'fajr' : 'normal';
//
//     // ✅ معرف فريد يتضمن timestamp لتجنب التكرار
//     final uniqueId = 'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';
//
//     // ✅ جدولة المهمة مع WorkManager
//     await Workmanager().registerOneOffTask(
//       uniqueId,
//       'adhanTask',
//       initialDelay: delay,
//       inputData: {
//         'prayerName': prayerName,
//         'cityName': savedCityName,
//         'prayerTime': _formatTime(prayerTime),
//         'timestamp': prayerTime.millisecondsSinceEpoch,
//         'dayOffset': dayOffset,
//         'adhanType': adhanType, // ⭐ جديد: نوع الأذان
//         'isFajr': isFajr, // ⭐ جديد: هل هو الفجر؟
//       },
//       constraints: Constraints(
//         networkType: NetworkType.notRequired,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//       ),
//       backoffPolicy: BackoffPolicy.linear,
//       backoffPolicyDelay: const Duration(seconds: 10),
//     );
//
//     final delayInMinutes = delay.inMinutes;
//     final delayInHours = delay.inHours;
//
//     if (delayInHours > 0) {
//       print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInHours}س ${delayInMinutes % 60}د)');
//     } else {
//       print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInMinutes}د)');
//     }
//
//     return true;
//   } catch (e, stackTrace) {
//     print('❌ خطأ في جدولة $prayerName: $e');
//     print('Stack Trace: $stackTrace');
//     return false;
//   }
// }

// ==========================================
// 🕌 حساب أوقات الصلاة
// ==========================================

// ==========================================
// 🔄 إعادة الجدولة والإلغاء
// ==========================================

// ==========================================
// 📊 معلومات الصلاة التالية
// ==========================================

class AdhanSettingsDialog extends StatefulWidget {
  const AdhanSettingsDialog({super.key});

  @override
  State<AdhanSettingsDialog> createState() => _AdhanSettingsDialogState();
}

class _AdhanSettingsDialogState extends State<AdhanSettingsDialog> {
  bool enableFajr = true;
  bool enableNormal = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await AdhanWorkManagerService().getAdhanPreferences();
    setState(() {
      enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
      enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚙️ إعدادات الأذان'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('🌅 أذان الفجر'),
            value: enableFajr,
            onChanged: (v) async {
              setState(() => enableFajr = v);
              await AdhanWorkManagerService().saveAdhanPreferences(
                enableFajrAdhan: v,
              );
            },
          ),
          SwitchListTile(
            title: const Text('🕌 الأذان العادي'),
            value: enableNormal,
            onChanged: (v) async {
              setState(() => enableNormal = v);
              await AdhanWorkManagerService().saveAdhanPreferences(
                enableNormalAdhan: v,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}







// <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
// ```
//
// 3. **إنشاء Helper Class** تحتوي على:
// - `isBatteryOptimizationDisabled()` → فحص الحالة
// - `openBatteryOptimizationSettings()` → فتح الإعدادات مباشرة
// - `showBatteryOptimizationDialog()` → عرض Dialog تحذيري
// - `showBatteryOptimizationSnackBar()` → عرض SnackBar بسيط
//
// 4. **في `initState`**:
// - استدعاء `_checkBatteryOptimization()` لفحص الحالة أول ما الشاشة تفتح
// - إذا كان Battery Optimization مفعّل → يظهر Dialog
// - المستخدم يضغط "فتح الإعدادات" → يروح مباشرة لصفحة Battery Settings
//
// ---
//
// ## 🎯 **مميزات الحل:**
//
// ✅ **فحص تلقائي** عند فتح الشاشة
// ✅ **Dialog واضح** يشرح للمستخدم المشكلة
// ✅ **زر مباشر** لفتح صفحة الإعدادات
// ✅ **زر يدوي** في AppBar للفحص في أي وقت
// ✅ **دعم اللغة العربية** بالكامل
//
// ---
//
// ## 🔥 **بعد التطبيق:**
//
// المستخدم هيشوف رسالة زي دي:
// ```
// ⚠️ تنبيه هام
//
// حتى يعمل الأذان في الخلفية بشكل صحيح،
// يجب إيقاف وضع توفير البطارية للتطبيق.
//
// 📌 سنوجهك الآن إلى الإعدادات لتفعيل هذا الخيار
//
// [لاحقاً]  [فتح الإعدادات ⚙️]
















// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       // ✅ تهيئة AwesomeNotifications داخل الـ Background Task
//       await AwesomeNotifications().initialize(
//         null,
//         [
//           NotificationChannel(
//             channelKey: 'adhan_channel',
//             channelName: 'أذان الصلاة',
//             channelDescription: 'تشغيل صوت الأذان',
//             importance: NotificationImportance.Max,
//             playSound: true,
//             soundSource: 'resource://raw/athan',
//             enableVibration: true,
//             enableLights: true,
//           ),
//         ],
//         debug: true,
//       );
//
//       final prayerName = inputData?['prayerName'] ?? 'الفجر';
//       final cityName = inputData?['cityName'] ?? '';
//       final prayerTime = inputData?['prayerTime'] ?? '';
//
//       print('🔔 جاري تشغيل أذان $prayerName - $cityName');
//
//       // ✅ إرسال الإشعار
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//           channelKey: 'adhan_channel',
//           title: '🕌 حان الآن موعد أذان $prayerName',
//           body: '$cityName - $prayerTime',
//           category: NotificationCategory.Alarm,
//           notificationLayout: NotificationLayout.Default,
//           wakeUpScreen: true,
//           fullScreenIntent: true,
//           criticalAlert: true,
//           autoDismissible: false,
//         ),
//         actionButtons: [
//           NotificationActionButton(
//             key: 'STOP_ADHAN',
//             label: 'إيقاف الأذان',
//             actionType: ActionType.DismissAction,
//           ),
//         ],
//       );
//
//       // ✅ تشغيل صوت الأذان (اختياري - الصوت سيشتغل من الإشعار نفسه)
//       try {
//         final audioPlayer = AudioPlayer();
//         await audioPlayer.setAsset('assets/athan/athan.mp3');
//         await audioPlayer.setVolume(1.0);
//         await audioPlayer.play();
//
//         await audioPlayer.playerStateStream.firstWhere(
//               (state) => state.processingState == ProcessingState.completed,
//         ).timeout(
//           const Duration(minutes: 5),
//           onTimeout: () => PlayerState(false, ProcessingState.completed),
//         );
//
//         await audioPlayer.dispose();
//       } catch (e) {
//         print('⚠️ خطأ في تشغيل الصوت: $e');
//       }
//
//       // ✅ إرسال إشعار انتهاء الأذان
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
//           channelKey: 'adhan_channel',
//           title: '✅ انتهى أذان $prayerName',
//           body: 'تم تشغيل الأذان بنجاح - $cityName',
//           notificationLayout: NotificationLayout.Default,
//         ),
//       );
//
//       return Future.value(true);
//     } catch (e, s) {
//       print('❌ خطأ في تشغيل الأذان: $e\n$s');
//       return Future.value(false);
//     }
//   });
// }
/// إعادة جدولة الأذان لليوم التالي


// =====================================
// 📦 AdhanWorkManagerService - نسخة محدثة بالكامل
// =====================================


// class AdhanWorkManagerService {
//   static final AdhanWorkManagerService _instance = AdhanWorkManagerService._internal();
//   factory AdhanWorkManagerService() => _instance;
//   AdhanWorkManagerService._internal();
//
//   // ==========================================
//   // 🎯 التهيئة الأساسية
//   // ==========================================
//
//   /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
//   Future<void> initialize({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//   }) async {
//     try {
//       print('🚀 بدء تهيئة خدمة الأذان...');
//
//       // 1️⃣ إلغاء أي مهام قديمة
//       await Workmanager().cancelAll();
//       print('🗑️ تم إلغاء المهام القديمة');
//
//       // 2️⃣ جدولة الأذان لعدة أيام
//       await scheduleAllPrayersForMultipleDays(
//         coordinates: coordinates,
//         calculationParams: calculationParams,
//         cityName: cityName,
//         days: days,
//       );
//
//       print('✅ تم تهيئة خدمة الأذان بنجاح');
//     } catch (e, stackTrace) {
//       print('❌ خطأ في تهيئة AdhanWorkManager: $e');
//       print('Stack Trace: $stackTrace');
//     }
//   }
//
//   // ==========================================
//   // 📅 جدولة الصلوات
//   // ==========================================
//
//   /// جدولة جميع الصلوات لعدة أيام قادمة
//   Future<void> scheduleAllPrayersForMultipleDays({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//     int daysCount = 7, // للتوافق مع الكود القديم
//   }) async {
//     try {
//       // استخدام days أو daysCount (أيهما أكبر)
//       final totalDays = days > daysCount ? days : daysCount;
//
//       print('📋 جدولة الأذان لـ $totalDays أيام...');
//
//       // 1️⃣ حفظ البيانات إذا تم تمريرها
//       if (coordinates != null) {
//         await saveCoordinates(coordinates.latitude, coordinates.longitude);
//         print('📍 تم حفظ الإحداثيات: ${coordinates.latitude}, ${coordinates.longitude}');
//       }
//       if (cityName != null) {
//         await saveCityName(cityName);
//         print('🏙️ تم حفظ المدينة: $cityName');
//       }
//       if (calculationParams != null) {
//         await _saveCalculationParams(calculationParams);
//         print('⚙️ تم حفظ إعدادات الحساب');
//       }
//
//       // 2️⃣ جدولة الصلوات لكل يوم
//       int scheduledCount = 0;
//       for (int day = 0; day < totalDays; day++) {
//         final targetDate = DateTime.now().add(Duration(days: day));
//         final prayerTimes = await _getPrayerTimesForDate(
//           targetDate,
//           coordinates: coordinates,
//           params: calculationParams,
//         );
//
//         for (var entry in prayerTimes.entries) {
//           final scheduled = await _schedulePrayer(
//             prayerName: entry.key,
//             prayerTime: entry.value,
//             dayOffset: day,
//             cityName: cityName,
//           );
//           if (scheduled) scheduledCount++;
//         }
//       }
//
//       print('✅ تم جدولة $scheduledCount صلاة لـ $totalDays أيام قادمة');
//     } catch (e, stackTrace) {
//       print('❌ خطأ في جدولة الصلوات: $e');
//       print('Stack Trace: $stackTrace');
//     }
//   }
//
//   /// جدولة جميع الصلوات لليوم الحالي فقط
//   Future<void> scheduleAllPrayers() async {
//     try {
//       print('📅 جدولة صلوات اليوم...');
//       final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
//
//       int scheduledCount = 0;
//       for (var entry in prayerTimes.entries) {
//         final scheduled = await _schedulePrayer(
//           prayerName: entry.key,
//           prayerTime: entry.value,
//         );
//         if (scheduled) scheduledCount++;
//       }
//
//       print('✅ تم جدولة $scheduledCount صلاة لليوم');
//     } catch (e) {
//       print('❌ خطأ في جدولة صلوات اليوم: $e');
//     }
//   }
//
//   /// جدولة أذان واحد بشكل محسّن
//   Future<bool> _schedulePrayer({
//     required String prayerName,
//     required DateTime prayerTime,
//     int dayOffset = 0,
//     String? cityName,
//   }) async {
//     final now = DateTime.now();
//     var delay = prayerTime.difference(now);
//
//     // ✅ تخطي الأوقات التي فاتت
//     if (delay.isNegative) {
//       if (dayOffset == 0) {
//         print('⏭️ تم تخطي $prayerName - الوقت فات (${_formatTime(prayerTime)})');
//       }
//       return false;
//     }
//
//     // ✅ التأكد من أن التأخير معقول
//     if (delay.inMinutes < 1) {
//       print('⚠️ تأخير قصير جداً لـ $prayerName (${delay.inSeconds} ثانية)');
//       return false;
//     }
//
//     try {
//       final savedCityName = cityName ?? await _getCityName();
//
//       // ✅ معرف فريد يتضمن timestamp لتجنب التكرار
//       final uniqueId = 'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';
//
//       // ✅ جدولة المهمة مع WorkManager
//       await Workmanager().registerOneOffTask(
//         uniqueId,
//         'adhanTask',
//         initialDelay: delay,
//         inputData: {
//           'prayerName': prayerName,
//           'cityName': savedCityName,
//           'prayerTime': _formatTime(prayerTime),
//           'timestamp': prayerTime.millisecondsSinceEpoch,
//           'dayOffset': dayOffset,
//         },
//         constraints: Constraints(
//           networkType: NetworkType.notRequired,
//           requiresBatteryNotLow: false,
//           requiresCharging: false,
//         ),
//         backoffPolicy: BackoffPolicy.linear,
//         backoffPolicyDelay: const Duration(seconds: 10),
//       );
//
//       final delayInMinutes = delay.inMinutes;
//       final delayInHours = delay.inHours;
//
//       if (delayInHours > 0) {
//         print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInHours}س ${delayInMinutes % 60}د)');
//       } else {
//         print('✅ جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delayInMinutes}د)');
//       }
//
//       return true;
//     } catch (e, stackTrace) {
//       print('❌ خطأ في جدولة $prayerName: $e');
//       print('Stack Trace: $stackTrace');
//       return false;
//     }
//   }
//
//   // ==========================================
//   // 🕌 حساب أوقات الصلاة
//   // ==========================================
//
//   /// الحصول على أوقات الصلاة لتاريخ محدد
//   Future<Map<String, DateTime>> _getPrayerTimesForDate(
//       DateTime date, {
//         Coordinates? coordinates,
//         CalculationParameters? params,
//       }) async {
//     try {
//       // استخدام الإحداثيات المُمررة أو المحفوظة
//       final coords = coordinates ?? await _getSavedCoordinates();
//
//       // استخدام parameters المُمررة أو المحفوظة
//       final calculationParams = params ?? await _getSavedCalculationParams();
//
//       final components = DateComponents(date.year, date.month, date.day);
//       final prayerTimes = PrayerTimes(coords, components, calculationParams);
//
//       return {
//         'الفجر': prayerTimes.fajr,
//         'الظهر': prayerTimes.dhuhr,
//         'العصر': prayerTimes.asr,
//         'المغرب': prayerTimes.maghrib,
//         'العشاء': prayerTimes.isha,
//       };
//     } catch (e) {
//       print('❌ خطأ في حساب أوقات الصلاة: $e');
//       // أوقات افتراضية في حالة الخطأ
//       return _getDefaultPrayerTimes(date);
//     }
//   }
//
//   /// أوقات افتراضية في حالة الخطأ (القاهرة)
//   Map<String, DateTime> _getDefaultPrayerTimes(DateTime date) {
//     return {
//       'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
//       'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
//       'العصر': DateTime(date.year, date.month, date.day, 15, 15),
//       'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
//       'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
//     };
//   }
//
//   // ==========================================
//   // 💾 حفظ واسترجاع البيانات
//   // ==========================================
//
//   /// الحصول على الإحداثيات المحفوظة
//   Future<Coordinates> _getSavedCoordinates() async {
//     final prefs = await SharedPreferences.getInstance();
//     final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
//     final longitude = prefs.getDouble('longitude') ?? 31.2357;
//     return Coordinates(latitude, longitude);
//   }
//
//   /// حفظ الإحداثيات
//   Future<void> saveCoordinates(double latitude, double longitude) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('latitude', latitude);
//     await prefs.setDouble('longitude', longitude);
//   }
//
//   /// الحصول على اسم المدينة المحفوظ
//   Future<String> _getCityName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('city_name') ?? 'القاهرة';
//   }
//
//   /// حفظ اسم المدينة
//   Future<void> saveCityName(String cityName) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('city_name', cityName);
//   }
//
//   /// حفظ إعدادات الحساب
//   Future<void> _saveCalculationParams(CalculationParameters params) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('fajr_angle', params.fajrAngle);
//     await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
//     await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);
//
//     if (params.ishaInterval > 0) {
//       await prefs.setInt('isha_interval', params.ishaInterval);
//     }
//   }
//
//   /// الحصول على إعدادات الحساب المحفوظة
//   Future<CalculationParameters> _getSavedCalculationParams() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final fajrAngle = prefs.getDouble('fajr_angle');
//     final ishaAngle = prefs.getDouble('isha_angle');
//     final madhabIndex = prefs.getInt('madhab') ?? 0;
//     final ishaInterval = prefs.getInt('isha_interval') ?? 0;
//
//     // إذا مفيش بيانات محفوظة، استخدم الطريقة المصرية كـ default
//     if (fajrAngle == null || ishaAngle == null) {
//       final params = CalculationMethod.egyptian.getParameters();
//       params.madhab = Madhab.shafi;
//       return params;
//     }
//
//     final params = CalculationParameters(
//       fajrAngle: fajrAngle,
//       ishaAngle: ishaAngle,
//       ishaInterval: ishaInterval,
//     );
//     params.madhab = madhabIndex == 0 ? Madhab.shafi : Madhab.hanafi;
//
//     return params;
//   }
//
//   // ==========================================
//   // 🔄 إعادة الجدولة والإلغاء
//   // ==========================================
//
//   /// إعادة جدولة الأذان (استدعيها يومياً أو عند تغيير الموقع)
//   Future<void> reschedule({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     String? cityName,
//     int days = 7,
//   }) async {
//     try {
//       print('🔄 إعادة جدولة الأذان...');
//       await Workmanager().cancelAll();
//       await scheduleAllPrayersForMultipleDays(
//         coordinates: coordinates,
//         calculationParams: calculationParams,
//         cityName: cityName,
//         days: days,
//       );
//       print('✅ تمت إعادة الجدولة بنجاح');
//     } catch (e) {
//       print('❌ خطأ في إعادة الجدولة: $e');
//     }
//   }
//
//   /// إلغاء جميع المهام
//   Future<void> cancelAll() async {
//     try {
//       await Workmanager().cancelAll();
//       print('🗑️ تم إلغاء جميع مهام الأذان');
//     } catch (e) {
//       print('❌ خطأ في إلغاء المهام: $e');
//     }
//   }
//
//   // ==========================================
//   // 📊 معلومات الصلاة التالية
//   // ==========================================
//
//   /// الحصول على الصلاة التالية
//   Future<Map<String, dynamic>?> getNextPrayer() async {
//     try {
//       final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
//       final now = DateTime.now();
//
//       // البحث عن الصلاة التالية اليوم
//       for (var entry in prayerTimes.entries) {
//         if (entry.value.isAfter(now)) {
//           final timeUntil = entry.value.difference(now);
//           return {
//             'name': entry.key,
//             'time': entry.value,
//             'timeUntil': timeUntil,
//             'formattedTime': _formatTime(entry.value),
//             'remainingMinutes': timeUntil.inMinutes,
//           };
//         }
//       }
//
//       // إذا كل الأوقات فاتت، جيب أول صلاة بكرة (الفجر)
//       final tomorrowPrayers = await _getPrayerTimesForDate(
//         DateTime.now().add(const Duration(days: 1)),
//       );
//       final firstPrayer = tomorrowPrayers.entries.first;
//       final timeUntil = firstPrayer.value.difference(now);
//
//       return {
//         'name': firstPrayer.key,
//         'time': firstPrayer.value,
//         'timeUntil': timeUntil,
//         'formattedTime': _formatTime(firstPrayer.value),
//         'remainingMinutes': timeUntil.inMinutes,
//         'isTomorrow': true,
//       };
//     } catch (e) {
//       print('❌ خطأ في الحصول على الصلاة التالية: $e');
//       return null;
//     }
//   }
//
//   // ==========================================
//   // 🛠️ دوال مساعدة
//   // ==========================================
//
//   /// تنسيق الوقت بالعربي
//   String _formatTime(DateTime time) {
//     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.hour >= 12 ? 'م' : 'ص';
//     return '$hour:$minute $period';
//   }
//
//   /// طباعة جميع الأوقات المجدولة (للتجربة والتطوير)
//   Future<void> printScheduledPrayers({
//     Coordinates? coordinates,
//     CalculationParameters? calculationParams,
//     int days = 7,
//   }) async {
//     print('\n╔════════════════════════════════════╗');
//     print('║   📋 أوقات الصلاة المجدولة       ║');
//     print('╚════════════════════════════════════╝\n');
//
//     for (int day = 0; day < days; day++) {
//       final date = DateTime.now().add(Duration(days: day));
//       final prayerTimes = await _getPrayerTimesForDate(
//         date,
//         coordinates: coordinates,
//         params: calculationParams,
//       );
//
//       final dayName = _getDayName(date.weekday);
//       print('📅 $dayName ${date.day}/${date.month}/${date.year}:');
//       print('─────────────────────────────────────');
//
//       for (var entry in prayerTimes.entries) {
//         final icon = _getPrayerIcon(entry.key);
//         print('   $icon ${entry.key}: ${_formatTime(entry.value)}');
//       }
//       print('');
//     }
//     print('════════════════════════════════════════\n');
//   }
//
//   /// الحصول على اسم اليوم بالعربي
//   String _getDayName(int weekday) {
//     const days = [
//       'الإثنين',
//       'الثلاثاء',
//       'الأربعاء',
//       'الخميس',
//       'الجمعة',
//       'السبت',
//       'الأحد'
//     ];
//     return days[weekday - 1];
//   }
//
//   /// الحصول على أيقونة الصلاة
//   String _getPrayerIcon(String prayerName) {
//     switch (prayerName) {
//       case 'الفجر':
//         return '🌅';
//       case 'الظهر':
//         return '☀️';
//       case 'العصر':
//         return '🌤️';
//       case 'المغرب':
//         return '🌆';
//       case 'العشاء':
//         return '🌙';
//       default:
//         return '🕌';
//     }
//   }
//
//   /// التحقق من حالة الجدولة
//   Future<Map<String, dynamic>> getSchedulingStatus() async {
//     try {
//       final nextPrayer = await getNextPrayer();
//       final coords = await _getSavedCoordinates();
//       final city = await _getCityName();
//
//       return {
//         'isScheduled': nextPrayer != null,
//         'nextPrayer': nextPrayer,
//         'city': city,
//         'coordinates': {
//           'latitude': coords.latitude,
//           'longitude': coords.longitude,
//         },
//         'timestamp': DateTime.now().toIso8601String(),
//       };
//     } catch (e) {
//       return {
//         'isScheduled': false,
//         'error': e.toString(),
//       };
//     }
//   }
// }
// =====================================
// 📦 AdhanWorkManagerService - نسخة محدثة بالكامل
// =====================================
