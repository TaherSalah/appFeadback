import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adhan/adhan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl ;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:adhan/adhan.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_view/controllar/MainController.dart';
import '../../core/shard/widgets/def_text_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';
import 'package:just_audio/just_audio.dart';




import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import '../messa_view/azkar_massa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import 'adhan_callback.dart';

class TimingScreen extends StatefulWidget {
  const TimingScreen({super.key});

  @override
  _TimingScreenState createState() => _TimingScreenState();
}



class _TimingScreenState extends StateMVC<TimingScreen> {
  _TimingScreenState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;

  // استخدام خدمة WorkManager
  final AdhanWorkManagerService _adhanService = AdhanWorkManagerService();

  @override
  void initState() {
    super.initState();

    _adhanService.initialize();
    con.refreshPrayerTimesFromPrefs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ فحص Battery Optimization أول ما الشاشة تفتح
      _checkBatteryOptimization();

      _scheduleAllPrayerNotifications();
    });
  }

  /// 🔋 فحص حالة Battery Optimization وعرض تحذير إذا لزم الأمر
  Future<void> _checkBatteryOptimization() async {
    // ✅ الدالة دي بتفحص الأول، ولو مش مفعّل بس هتظهر الـ Dialog
    await BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
  }


  // جدولة إشعارات الصلاة
  Future<void> _scheduleAllPrayerNotifications() async {
    final prayerTimes = con.prayerTimes;
    final cityName = con.selectedCity ?? "مدينتك";
    final selectedCountry = con.selectedCountry;
    final selectedCity = con.selectedCity;

    if (prayerTimes == null) {
      print("⚠️ مواقيت الصلاة غير متاحة");
      return;
    }

    try {
      // إلغاء جميع المهام القديمة
      await _adhanService.cancelAll();

      // الحصول على الإحداثيات من الكنترولر
      final cities = con.cities;
      if (cities.isEmpty || selectedCity == null) return;

      final cityData = cities[selectedCity];
      if (cityData == null) return;

      final lat = (cityData['lat'] as num?)?.toDouble();
      final lng = (cityData['lng'] as num?)?.toDouble();

      if (lat == null || lng == null) {
        print("⚠️ إحداثيات المدينة غير متوفرة");
        return;
      }

      // إنشاء Coordinates و CalculationParameters
      final coordinates = Coordinates(lat, lng);
      final calculationParams = CalculationMethod.egyptian.getParameters();
      calculationParams.madhab = Madhab.shafi;

      // جدولة الأذان لـ 7 أيام قادمة مع WorkManager
      await _adhanService.scheduleAllPrayersForMultipleDays(
        coordinates: coordinates,
        calculationParams: calculationParams,
        cityName: cityName,
        days: 7,
      );

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('✅ تم جدولة الأذان لـ 7 أيام - سيعمل تلقائياً في الخلفية'),
        //     duration: Duration(seconds: 3),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        // KHelper.showSuccess(message: "✅ تم جدولة الأذان لـ 7 أيام - سيعمل تلقائياً في الخلفية");
      }
    } catch (e) {
      print("❌ خطأ في جدولة الإشعارات: $e");
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('حدث خطأ في جدولة الإشعارات: $e'),
        //     duration: const Duration(seconds: 3),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        KHelper.showSuccess(message: "حدث خطأ في جدولة الإشعارات: $e");

      }
    }
  }

  // التأكد من صلاحيات الموقع
  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // دالة حساب المسافة (Haversine)
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return R * c;
  }

  // تحديد أقرب مدينة بالـ GPS
  Future<void> _selectByLocation() async {
    final ok = await _ensureLocationPermission();
    if (!ok) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('يرجى تفعيل خدمات الموقع والسماح بالوصول'),
        //     backgroundColor: Colors.orange,
        //   ),
        // );
        KHelper.showError(message: 'يرجى تفعيل خدمات الموقع والسماح بالوصول');
      }
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final userLat = pos.latitude;
    final userLng = pos.longitude;

    final countries = con.countries;
    if (countries.isEmpty) return;

    String? bestCountry;
    String? bestCity;
    double bestDist = double.infinity;

    countries.forEach((country, cityMap) {
      final Map<String, dynamic> m = cityMap ?? {};
      m.forEach((cityName, v) {
        final lat = (v?['lat'])?.toDouble();
        final lng = (v?['lng'])?.toDouble();
        if (lat == null || lng == null) return;
        final d = _haversine(userLat, userLng, lat, lng);
        if (d < bestDist) {
          bestDist = d;
          bestCountry = country;
          bestCity = cityName;
        }
      });
    });

    if (bestCountry != null && bestCity != null) {
      await con.setLocation(country: bestCountry!, city: bestCity!);
      setState(() {});

      // جدولة الإشعارات للموقع الجديد
      await _scheduleAllPrayerNotifications();

      if (mounted) {
        KHelper.showSuccess(
          message: 'تم تحديد الموقع: $bestCountry - $bestCity',
        );
      }
    }
  }

  // عرض الإشعارات المجدولة
  // Future<void> _showScheduledNotifications() async {
  //   final pending = await _adhanService.scheduleAllPrayers();
  //
  //   if (!mounted) return;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           const Icon(Icons.notifications_active, color: Colors.green),
  //           const SizedBox(width: 8),
  //           const Text('إشعارات الأذان المجدولة'),
  //         ],
  //       ),
  //       content: pending.isEmpty
  //           ? const Padding(
  //         padding: EdgeInsets.all(20),
  //         child: Text(
  //           'لا توجد إشعارات مجدولة حالياً',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 16),
  //         ),
  //       )
  //           : SizedBox(
  //         width: double.maxFinite,
  //         height: 400,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: pending.length,
  //           itemBuilder: (context, index) {
  //             final notification = pending[index];
  //             return Card(
  //               margin: const EdgeInsets.symmetric(vertical: 4),
  //               child: ListTile(
  //                 leading: const Icon(Icons.mosque, color: Colors.green),
  //                 title: Text(
  //                   notification.title ?? 'بدون عنوان',
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 subtitle: Text(notification.body ?? ''),
  //                 trailing: Text(
  //                   'ID: ${notification.id}',
  //                   style: const TextStyle(fontSize: 10),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('إغلاق'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    // لا داعي لـ dispose WorkManager
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = const Color(AppStyle.primaryColor);

    final countries = con.countries;
    final cities = con.cities;
    final selectedCountry = con.selectedCountry;
    final selectedCity = con.selectedCity;
    final prayerTimes = con.prayerTimes;
    final nextPrayer = con.nextPrayer;
    final remainingTimeText = con.remainingTimeText;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
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
            if (Platform.isAndroid)
              FutureBuilder<bool>(
                future: BatteryOptimizationHelper.isBatteryOptimizationDisabled(),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: const Icon(Icons.battery_charging_full),
                    tooltip: 'فحص إعدادات البطارية',
                    onPressed: () async {
                      final isDisabled = await BatteryOptimizationHelper.isBatteryOptimizationDisabled();
                      if (!mounted) return;

                      if (isDisabled) {
                        KHelper.showSuccess(message: "التطبيق مُستثنى من توفير البطارية");
                      } else {
                        BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
                      }
                    },
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة جدولة الإشعارات',
              onPressed: _scheduleAllPrayerNotifications,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ]
                : [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Column(
              children: [
                // 🎯 قسم اختيار الموقع المحسّن
                _buildLocationSelector(context, isDark, countries, cities, selectedCountry, selectedCity),

                const SizedBox(height: 20),

                // 📍 عرض الموقع الحالي بتصميم جذاب
                if (selectedCountry != null && selectedCity != null)
                  _buildCurrentLocation(context, isDark, selectedCountry, selectedCity),

                const SizedBox(height: 24),

                // ⏰ الصلاة القادمة (بطاقة مميزة)
                if (prayerTimes != null && nextPrayer.isNotEmpty)
                  _buildNextPrayerCard(context, isDark, nextPrayer, remainingTimeText, prayerTimes),

                const SizedBox(height: 24),

                // 📋 قائمة المواقيت المحسّنة
                if (prayerTimes != null)
                  Expanded(
                    child: _buildPrayerTimesList(context, isDark, prayerTimes, nextPrayer),
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

// 🎯 قسم اختيار الموقع
  Widget _buildLocationSelector(
      BuildContext context,
      bool isDark,
      Map countries,
      Map cities,
      String? selectedCountry,
      String? selectedCity,
      ) {
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
                  fontSize: 16.sp,
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
                  items: countries.keys.map((e) => e.toString()).toList(),
                  value: selectedCountry,
                  icon: Icons.public,
                  onChanged: (value) async {
                    if (value == null) return;
                    final Map<String, dynamic> cityMap =
                    (countries[value] as Map<String, dynamic>)
                      ..removeWhere((k, v) => v == null);
                    final firstCity = cityMap.keys.first;
                    await con.setLocation(country: value, city: firstCity);
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
                  items: cities.keys.map((e) => e.toString()).toList(),
                  value: selectedCity,
                  icon: Icons.location_on,
                  onChanged: (value) async {
                    if (value == null || selectedCountry == null) return;
                    await con.setLocation(country: selectedCountry, city: value);
                    setState(() {});
                    await _scheduleAllPrayerNotifications();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // زر GPS
          InkWell(
            onTap: countries.isEmpty ? null : _selectByLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.teal.shade700, Colors.teal.shade900]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.my_location, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'تحديد موقعي الحالي',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
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
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white24
                : Colors.grey.shade300,
          ),
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.white,
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
                    fontSize: 13.sp,
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
                    fontSize: 12.sp,
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              overlayColor: WidgetStateProperty.all(
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }

// 📍 عرض الموقع الحالي
  Widget _buildCurrentLocation(
      BuildContext context,
      bool isDark,
      String selectedCountry,
      String selectedCity,
      ) {
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
        color: AppThemeColors.cardBackgroundColor(context)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place_rounded,
            color: isDark ? Colors.amberAccent : Colors.blue.shade800,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCountry - $selectedCity',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
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
          colors:
             [Colors.green.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:  Colors.green.withOpacity(0.4),
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
    final prayerData = [
      {"name": "الفجر", "time": prayerTimes.fajr, "icon": Icons.wb_twilight},
      {"name": "الشروق", "time": prayerTimes.sunrise, "icon": Icons.wb_sunny},
      {"name": "الظهر", "time": prayerTimes.dhuhr, "icon": Icons.light_mode},
      {"name": "العصر", "time": prayerTimes.asr, "icon": Icons.wb_sunny_outlined},
      {"name": "المغرب", "time": prayerTimes.maghrib, "icon": Icons.wb_twilight},
      {"name": "العشاء", "time": prayerTimes.isha, "icon": Icons.nightlight_round},
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: prayerData.length,
      itemBuilder: (context, index) {
        final prayer = prayerData[index];
        final isNext = nextPrayer.contains(prayer["name"] as String);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:

              // isNext
                  // ? (isDark
                  // ? [Colors.amber.shade700, Colors.orange.shade800]
                  // : [Colors.blue.shade400, Colors.blue.shade600])
                  // :
                (isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                  : [Colors.white, Colors.grey.shade50]),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isNext
                    // ? (isDark ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3))
                    // : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.2)),
        ? (isDark ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3))
            : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.2)),
                blurRadius: isNext ? 15 : 8,
                offset: Offset(0, isNext ? 6 : 3),
              ),
            ],
            border: isNext
                ? Border.all(
              // color: isDark ? Colors.amberAccent : Colors.white,
              color:  Colors.green ,
              width: 2,
            )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                // أيقونة الصلاة
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
                // اسم الصلاة
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
                // الوقت
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Colors.grey.withOpacity(0.2)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    intl.DateFormat('h:mm a').format(prayer["time"] as DateTime),
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
          ),
        );
      },
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

















@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      print("🔊 بدء تشغيل الأذان: ${inputData?['prayerName']}");

      final prayerName = inputData?['prayerName'] ?? 'الفجر';
      final cityName = inputData?['cityName'] ?? '';

      // 1) تهيئة الإشعارات
      final notifications = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await notifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      // 2) تشغيل الأذان
      final audioPlayer = AudioPlayer();
      await audioPlayer.setAsset('assets/athan/athan.mp3');
      await audioPlayer.setVolume(1.0); // صوت كامل
      await audioPlayer.play();

      // انتظار انتهاء الأذان
      await audioPlayer.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed,
        orElse: () => PlayerState(
          false,
          ProcessingState.completed,
        ),
      ).timeout(
        const Duration(minutes: 5), // حد أقصى 5 دقائق
        onTimeout: () =>  PlayerState(
          false,
          ProcessingState.completed,
        ),
      );

      await audioPlayer.dispose();

      // 3) إظهار إشعار بعد الانتهاء
      await notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID فريد
        '✅ انتهى أذان $prayerName',
        'تم تشغيل الأذان - $cityName',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_complete_channel',
            'إشعارات اكتمال الأذان',
            channelDescription: 'إشعار بعد انتهاء الأذان',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          ),
        ),
      );

      print("✅ انتهى أذان $prayerName بنجاح");

      // 4) إعادة جدولة الأذان لليوم التالي
      await _rescheduleNextDay();

      return Future.value(true);
    } catch (e, s) {
      print("❌ خطأ في تشغيل الأذان: $e");
      print(s);
      return Future.value(false);
    }
  });
}

/// إعادة جدولة الأذان لليوم التالي
Future<void> _rescheduleNextDay() async {
  try {
    await AdhanWorkManagerService().reschedule();
  } catch (e) {
    print('❌ خطأ في إعادة الجدولة: $e');
  }
}



// ⚠️ هذه الدالة تعمل في الخلفية - لا تستخدم BuildContext هنا
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       print("🔊 بدء تشغيل الأذان في الخلفية: $task");
//
//       // الحصول على اسم الصلاة من البيانات
//       final prayerName = inputData?['prayerName'] ?? 'الفجر';
//       final cityName = inputData?['cityName'] ?? '';
//
//       // تشغيل صوت الأذان
//       final audioPlayer = AudioPlayer();
//       await audioPlayer.setAsset('assets/athan/athan.mp3');
//       await audioPlayer.play();
//
//       // الانتظار حتى ينتهي الأذان
//       await audioPlayer.playerStateStream.firstWhere(
//             (state) => state.processingState == ProcessingState.completed,
//       );
//
//       await audioPlayer.dispose();
//
//       // إظهار إشعار أن الأذان انتهى
//       final FlutterLocalNotificationsPlugin notifications =
//       FlutterLocalNotificationsPlugin();
//
//       await notifications.show(
//         999,
//         '✅ انتهى أذان $prayerName',
//         'تمت قراءة الأذان - $cityName',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'adhan_complete_channel',
//             'إشعارات اكتمال الأذان',
//             importance: Importance.low,
//             priority: Priority.low,
//           ),
//         ),
//       );
//
//       print("✅ انتهى تشغيل الأذان بنجاح");
//       return Future.value(true);
//     } catch (e) {
//       print("❌ خطأ في تشغيل الأذان: $e");
//       return Future.value(false);
//     }
//   });
// }
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       print("🔊 بدء تشغيل الأذان في الخلفية: $task");
//
//       // الحصول على اسم الصلاة من البيانات
//       final prayerName = inputData?['prayerName'] ?? 'الفجر';
//       final cityName = inputData?['cityName'] ?? '';
//
//       // تحديد ملف الصوت
//       String audioFile;
//       if (prayerName.trim() == 'الفجر' || prayerName.trim() == 'Fajr') {
//         audioFile = 'assets/athan/fajr.mp3';
//       } else {
//         audioFile = 'assets/athan/athan.mp3';
//       }
//
//       print("🎵 سيتم تشغيل ملف: $audioFile للصلاة: $prayerName");
//
//       // تشغيل صوت الأذان
//       final audioPlayer = AudioPlayer();
//       await audioPlayer.setAsset(audioFile);
//       await audioPlayer.play();
//
//       // الانتظار حتى ينتهي التشغيل
//       await audioPlayer.playerStateStream.firstWhere(
//             (state) => state.processingState == ProcessingState.completed,
//       );
//
//       await audioPlayer.dispose();
//
//       // إظهار إشعار انتهاء الأذان
//       final FlutterLocalNotificationsPlugin notifications =
//       FlutterLocalNotificationsPlugin();
//
//       await notifications.show(
//         999,
//         '✅ انتهى أذان $prayerName',
//         'تمت قراءة الأذان - $cityName',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'adhan_complete_channel',
//             'إشعارات اكتمال الأذان',
//             importance: Importance.low,
//             priority: Priority.low,
//           ),
//         ),
//       );
//
//       print("✅ انتهى تشغيل الأذان بنجاح");
//       return Future.value(true);
//
//     } catch (e) {
//       print("❌ خطأ في تشغيل الأذان: $e");
//       return Future.value(false);
//     }
//   });
// }

// class AdhanWorkManagerService {
//   static final AdhanWorkManagerService _instance = AdhanWorkManagerService._internal();
//   factory AdhanWorkManagerService() => _instance;
//   AdhanWorkManagerService._internal();
//
//   final FlutterLocalNotificationsPlugin _notifications =
//   FlutterLocalNotificationsPlugin();
//
//   // تهيئة الخدمة
//   Future<void> initialize() async {
//     // تهيئة WorkManager
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: false, // غيّرها لـ true للتجربة
//     );
//
//     // تهيئة الإشعارات
//     tz.initializeTimeZones();
//
//     const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notifications.initialize(initSettings);
//
//     print("✅ تم تهيئة خدمة الأذان مع WorkManager");
//   }
//
//   // جدولة أذان واحد
//   Future<void> scheduleAdhanWithWork({
//     required String taskId,
//     required DateTime prayerTime,
//     required String prayerName,
//     required String cityName,
//   }) async {
//     final now = DateTime.now();
//
//     // لو الوقت فات، ما نجدولش
//     if (prayerTime.isBefore(now)) {
//       print("⏭️ وقت $prayerName فات، مش هيتجدول");
//       return;
//     }
//
//     final duration = prayerTime.difference(now);
//
//     // جدولة المهمة في WorkManager
//     await Workmanager().registerOneOffTask(
//       taskId,
//       'playAdhan',
//       initialDelay: duration,
//       inputData: {
//         'prayerName': prayerName,
//         'cityName': cityName,
//         'time': prayerTime.toIso8601String(),
//       },
//       constraints: Constraints(
//         networkType: NetworkType.notRequired,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//
//     // جدولة إشعار تنبيه قبل الأذان بـ 5 دقائق (اختياري)
//     await _schedulePreAdhanNotification(
//       prayerTime: prayerTime,
//       prayerName: prayerName,
//       cityName: cityName,
//     );
//
//     // جدولة الإشعار الرئيسي
//     await _scheduleAdhanNotification(
//       prayerTime: prayerTime,
//       prayerName: prayerName,
//       cityName: cityName,
//     );
//
//     print("⏰ تم جدولة أذان $prayerName بعد ${duration.inMinutes} دقيقة");
//   }
//
//   // إشعار قبل الأذان بـ 5 دقائق (اختياري)
//   Future<void> _schedulePreAdhanNotification({
//     required DateTime prayerTime,
//     required String prayerName,
//     required String cityName,
//   }) async {
//     final notificationTime = prayerTime.subtract(const Duration(minutes: 5));
//     final now = DateTime.now();
//
//     if (notificationTime.isBefore(now)) return;
//
//     final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);
//
//     await _notifications.zonedSchedule(
//       prayerName.hashCode + 1000, // معرف فريد
//       '⏰ تنبيه: بقي 5 دقائق على أذان $prayerName',
//       'استعد للصلاة - $cityName',
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'pre_adhan_channel',
//           'تنبيهات ما قبل الأذان',
//           channelDescription: 'تنبيه قبل موعد الأذان بـ 5 دقائق',
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/launcher_icon',
//           color: Color(0xFFFF9800),
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//
//       // uiLocalNotificationDateInterpretation:
//       // UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   // إشعار عند موعد الأذان
//   Future<void> _scheduleAdhanNotification({
//     required DateTime prayerTime,
//     required String prayerName,
//     required String cityName,
//   }) async {
//     final now = DateTime.now();
//
//     if (prayerTime.isBefore(now)) return;
//
//     final scheduledTime = tz.TZDateTime.from(prayerTime, tz.local);
//
//     await _notifications.zonedSchedule(
//       prayerName.hashCode, // معرف فريد
//       '🕌 حان الآن موعد أذان $prayerName',
//       '🔊 جارٍ تشغيل الأذان - $cityName',
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'adhan_channel',
//           'أذان الصلاة',
//           channelDescription: 'إشعارات مواعيد الصلاة مع تشغيل الأذان تلقائياً',
//           importance: Importance.max,
//           priority: Priority.high,
//           // icon: '@drawable/@mipmap/launcher_icon',
//           icon: '@mipmap/launcher_icon',
//           playSound: true,
//           enableVibration: true,
//           enableLights: true,
//           color: Color(0xFF00C853),
//           // يمكن إضافة صوت قصير هنا أيضاً
//           // sound: RawResourceAndroidNotificationSound('adhan_short'),
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       // uiLocalNotificationDateInterpretation:
//       // UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   // جدولة جميع الصلوات لعدة أيام
//   Future<void> scheduleAllPrayersForMultipleDays({
//     required Coordinates coordinates,
//     required CalculationParameters calculationParams,
//     required String cityName,
//     int days = 7,
//   }) async {
//     print("📅 جدولة الأذان لـ $days أيام قادمة...");
//
//     // إلغاء جميع المهام السابقة
//     await Workmanager().cancelAll();
//     await _notifications.cancelAll();
//
//     int taskCounter = 0;
//
//     for (int i = 0; i < days; i++) {
//       final date = DateTime.now().add(Duration(days: i));
//       final dateComponents = DateComponents(date.year, date.month, date.day);
//       final prayerTimes = PrayerTimes(
//         coordinates,
//         dateComponents,
//         calculationParams,
//       );
//
//       // جدولة كل صلاة (ما عدا الشروق)
//       final prayers = {
//         'الفجر': prayerTimes.fajr,
//         'الظهر': prayerTimes.dhuhr,
//         'العصر': prayerTimes.asr,
//         'المغرب': prayerTimes.maghrib,
//         'العشاء': prayerTimes.isha,
//       };
//
//       for (var entry in prayers.entries) {
//         final prayerName = entry.key;
//         final prayerTime = entry.value;
//
//         await scheduleAdhanWithWork(
//           taskId: 'adhan_${prayerName}_day${i}_$taskCounter',
//           prayerTime: prayerTime,
//           prayerName: prayerName,
//           cityName: cityName,
//         );
//
//         taskCounter++;
//       }
//     }
//
//     // حفظ البيانات في SharedPreferences للاستخدام بعد إعادة التشغيل
//     await _savePrayerSchedule(
//       coordinates: coordinates,
//       calculationParams: calculationParams,
//       cityName: cityName,
//       days: days,
//     );
//
//     print("✅ تم جدولة ${taskCounter} أذان لـ $days أيام");
//   }
//
//   // حفظ جدول الصلاة
//   Future<void> _savePrayerSchedule({
//     required Coordinates coordinates,
//     required CalculationParameters calculationParams,
//     required String cityName,
//     required int days,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final scheduleData = {
//       'latitude': coordinates.latitude,
//       'longitude': coordinates.longitude,
//       'cityName': cityName,
//       'days': days,
//       'lastUpdate': DateTime.now().toIso8601String(),
//     };
//
//     await prefs.setString('prayer_schedule', jsonEncode(scheduleData));
//   }
//
//   // إلغاء جميع المهام
//   Future<void> cancelAll() async {
//     await Workmanager().cancelAll();
//     await _notifications.cancelAll();
//     print("🗑️ تم إلغاء جميع مهام الأذان");
//   }
//
//   // الحصول على المهام المجدولة
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _notifications.pendingNotificationRequests();
//   }
// }
// ملف: lib/services/adhan_workmanager_service.dart


class AdhanWorkManagerService {
  static final AdhanWorkManagerService _instance = AdhanWorkManagerService._internal();
  factory AdhanWorkManagerService() => _instance;
  AdhanWorkManagerService._internal();

  /// تهيئة الخدمة وجدولة جميع أوقات الصلاة
  Future<void> initialize({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 3,
  }) async {
    try {
      // إلغاء أي مهام قديمة
      await Workmanager().cancelAll();

      // جدولة الأذان لعدة أيام
      await scheduleAllPrayersForMultipleDays(
        coordinates: coordinates,
        calculationParams: calculationParams,
        cityName: cityName,
        days: days,
      );

      print('✅ تم تهيئة خدمة الأذان بنجاح');
    } catch (e) {
      print('❌ خطأ في تهيئة AdhanWorkManager: $e');
    }
  }

  /// جدولة جميع الصلوات لعدة أيام قادمة
  Future<void> scheduleAllPrayersForMultipleDays({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 3,
    int daysCount = 3, // للتوافق مع الكود القديم
  }) async {
    try {
      // استخدام days أو daysCount (أيهما أكبر)
      final totalDays = days > daysCount ? days : daysCount;

      // حفظ البيانات إذا تم تمريرها
      if (coordinates != null) {
        await saveCoordinates(coordinates.latitude, coordinates.longitude);
      }
      if (cityName != null) {
        await saveCityName(cityName);
      }
      if (calculationParams != null) {
        await _saveCalculationParams(calculationParams);
      }

      for (int day = 0; day < totalDays; day++) {
        final targetDate = DateTime.now().add(Duration(days: day));
        final prayerTimes = await _getPrayerTimesForDate(
          targetDate,
          coordinates: coordinates,
          params: calculationParams,
        );

        for (var entry in prayerTimes.entries) {
          await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            cityName: cityName,
          );
        }
      }
      print('✅ تم جدولة الأذان لـ $totalDays أيام قادمة');
    } catch (e) {
      print('❌ خطأ في جدولة الصلوات: $e');
    }
  }

  /// جدولة جميع الصلوات لليوم الحالي فقط
  Future<void> scheduleAllPrayers() async {
    final prayerTimes = await _getPrayerTimesForDate(DateTime.now());

    for (var entry in prayerTimes.entries) {
      await _schedulePrayer(
        prayerName: entry.key,
        prayerTime: entry.value,
      );
    }
  }

  /// جدولة أذان واحد
  Future<void> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    int dayOffset = 0,
    String? cityName,
  }) async {
    final now = DateTime.now();
    var delay = prayerTime.difference(now);

    // إذا الوقت فات، تخطى الجدولة
    if (delay.isNegative && dayOffset == 0) {
      print('⏭️ تم تخطي $prayerName - الوقت فات');
      return;
    }

    // تأكد من أن التأخير موجب
    if (delay.isNegative) {
      print('⚠️ خطأ: وقت سالب لـ $prayerName');
      return;
    }

    try {
      final savedCityName = cityName ?? await _getCityName();

      await Workmanager().registerOneOffTask(
        'adhan_${prayerName}_day$dayOffset', // معرف فريد
        'adhanTask',
        initialDelay: delay,
        inputData: {
          'prayerName': prayerName,
          'cityName': savedCityName,
          'prayerTime': prayerTime.toString(),
        },
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );

      print('📅 جدولة $prayerName: ${_formatTime(prayerTime)} (بعد ${delay.inMinutes} دقيقة)');
    } catch (e) {
      print('❌ خطأ في جدولة $prayerName: $e');
    }
  }

  /// الحصول على أوقات الصلاة لتاريخ محدد
  Future<Map<String, DateTime>> _getPrayerTimesForDate(
      DateTime date, {
        Coordinates? coordinates,
        CalculationParameters? params,
      }) async {
    try {
      // استخدام الإحداثيات المُمررة أو المحفوظة
      final coords = coordinates ?? await _getSavedCoordinates();

      // استخدام parameters المُمررة أو المحفوظة
      final calculationParams = params ?? await _getSavedCalculationParams();

      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        'الفجر': prayerTimes.fajr,
        'الظهر': prayerTimes.dhuhr,
        'العصر': prayerTimes.asr,
        'المغرب': prayerTimes.maghrib,
        'العشاء': prayerTimes.isha,
      };
    } catch (e) {
      print('❌ خطأ في حساب أوقات الصلاة: $e');
      // أوقات افتراضية في حالة الخطأ
      return _getDefaultPrayerTimes(date);
    }
  }

  /// الحصول على الإحداثيات المحفوظة
  Future<Coordinates> _getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude') ?? 30.0444; // القاهرة
    final longitude = prefs.getDouble('longitude') ?? 31.2357;
    return Coordinates(latitude, longitude);
  }

  /// أوقات افتراضية في حالة الخطأ
  Map<String, DateTime> _getDefaultPrayerTimes(DateTime date) {
    return {
      'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
      'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
      'العصر': DateTime(date.year, date.month, date.day, 15, 15),
      'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
      'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
    };
  }

  /// الحصول على اسم المدينة المحفوظ
  Future<String> _getCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('city_name') ?? 'القاهرة';
  }

  /// حفظ الإحداثيات
  Future<void> saveCoordinates(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  /// حفظ اسم المدينة
  Future<void> saveCityName(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', cityName);
  }

  /// حفظ إعدادات الحساب
  Future<void> _saveCalculationParams(CalculationParameters params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fajr_angle', params.fajrAngle);
    await prefs.setDouble('isha_angle', params.ishaAngle??0.0);
    await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);

    if (params.ishaInterval > 0) {
      await prefs.setInt('isha_interval', params.ishaInterval);
    }
  }

  /// الحصول على إعدادات الحساب المحفوظة
  Future<CalculationParameters> _getSavedCalculationParams() async {
    final prefs = await SharedPreferences.getInstance();

    final fajrAngle = prefs.getDouble('fajr_angle');
    final ishaAngle = prefs.getDouble('isha_angle');
    final madhabIndex = prefs.getInt('madhab') ?? 0;
    final ishaInterval = prefs.getInt('isha_interval') ?? 0;

    // إذا مفيش بيانات محفوظة، استخدم الطريقة المصرية كـ default
    if (fajrAngle == null || ishaAngle == null) {
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;
      return params;
    }

    final params = CalculationParameters(
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
      ishaInterval: ishaInterval,
    );
    params.madhab = madhabIndex == 0 ? Madhab.shafi : Madhab.hanafi;

    return params;
  }

  /// إعادة جدولة الأذان (استدعيها يومياً)
  Future<void> reschedule({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 3,
  }) async {
    await Workmanager().cancelAll();
    await scheduleAllPrayersForMultipleDays(
      coordinates: coordinates,
      calculationParams: calculationParams,
      cityName: cityName,
      days: days,
    );
  }

  /// إلغاء جميع المهام
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    print('🗑️ تم إلغاء جميع مهام الأذان');
  }

  /// الحصول على الصلاة التالية
  Future<Map<String, dynamic>?> getNextPrayer() async {
    final prayerTimes = await _getPrayerTimesForDate(DateTime.now());
    final now = DateTime.now();

    for (var entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        final timeUntil = entry.value.difference(now);
        return {
          'name': entry.key,
          'time': entry.value,
          'timeUntil': timeUntil,
          'formattedTime': _formatTime(entry.value),
        };
      }
    }

    // إذا كل الأوقات فاتت، جيب أول صلاة بكرة
    final tomorrowPrayers = await _getPrayerTimesForDate(
      DateTime.now().add(const Duration(days: 1)),
    );
    final firstPrayer = tomorrowPrayers.entries.first;
    final timeUntil = firstPrayer.value.difference(now);

    return {
      'name': firstPrayer.key,
      'time': firstPrayer.value,
      'timeUntil': timeUntil,
      'formattedTime': _formatTime(firstPrayer.value),
    };
  }

  /// تنسيق الوقت
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  /// طباعة جميع الأوقات المجدولة (للتجربة)
  Future<void> printScheduledPrayers({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    int days = 3,
  }) async {
    print('\n📋 أوقات الصلاة المجدولة:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    for (int day = 0; day < days; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final prayerTimes = await _getPrayerTimesForDate(
        date,
        coordinates: coordinates,
        params: calculationParams,
      );

      print('\n📅 ${date.day}/${date.month}/${date.year}:');

      for (var entry in prayerTimes.entries) {
        print('   ${entry.key}: ${_formatTime(entry.value)}');
      }
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}