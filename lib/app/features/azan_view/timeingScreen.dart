import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_view/controllar/MainController.dart';
import '../../core/shard/widgets/def_text_widget.dart';





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

  final AudioPlayer _audioPlayer = AudioPlayer();

  // أصوات الأذان لكل صلاة
  final Map<String, String> adhanSounds = {
    "الفجر": "assets/sounds/fajr_adhan.mp3",
    "الظهر": "assets/sounds/dhuhr_adhan.mp3",
    "العصر": "assets/sounds/asr_adhan.mp3",
    "المغرب": "assets/sounds/maghrib_adhan.mp3",
    "العشاء": "assets/sounds/isha_adhan.mp3",
  };

  bool _adhanScheduled = false;

  @override
  void initState() {
    super.initState();

    // تأكد أن الكنترولر قرأ الموقع والمواقيت من الـ SharedPreferences
    con.refreshPrayerTimesFromPrefs();

    // بعد أول فريم حاول جدول الأذان لليوم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleAllAdhanForToday();
    });
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

  // تحديد أقرب مدينة بالـ GPS وتحديث الكنترولر
  Future<void> _selectByLocation() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

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
      _scheduleAllAdhanForToday();
      KHelper.showSuccess(
          message: ' تم تحديد الموقع: $bestCountry - $bestCity');
    }
  }

  // تشغيل صوت الأذان
  void _playAdhanSound(String prayerName) {
    final sound =
        adhanSounds[prayerName] ?? "assets/sounds/default_adhan.mp3";

    _audioPlayer.setAsset(sound).then((_) {
      _audioPlayer.play();
    }).catchError((e) {
      debugPrint("Error playing adhan sound: $e");
    });
  }

  // جدولة الأذان لصلاة معينة
  void _scheduleAdhan(DateTime prayerTime, String prayerName) {
    final now = DateTime.now();
    final duration = prayerTime.difference(now);

    if (duration.isNegative) {
      return;
    }

    Future.delayed(duration, () {
      _playAdhanSound(prayerName);
    });

    debugPrint("هيشتغل أذان $prayerName بعد ${duration.inMinutes} دقيقة");
  }

  // جدولة جميع الأذان لليوم الحالي بناءً على prayerTimes في الكنترولر
  void _scheduleAllAdhanForToday() {
    if (_adhanScheduled) return; // لا تكرر الجدولة في نفس الجلسة
    final times = con.prayerTimes;
    if (times == null) return;

    final now = DateTime.now();

    final Map<String, DateTime> prayers = {
      "الفجر": times.fajr,
      "الشروق": times.sunrise,
      "الظهر": times.dhuhr,
      "العصر": times.asr,
      "المغرب": times.maghrib,
      "العشاء": times.isha,
    };

    prayers.forEach((name, time) {
      if (time.isAfter(now)) {
        _scheduleAdhan(time, name);
      }
    });

    _adhanScheduled = true;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
        preferredSize:
        Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
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
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            children: [
              // اختيار الدولة والمدينة + زر تحديد موقعي
              Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedWrapper(
                        type: UiAnimationType.slideRight,
                        duration: const Duration(seconds: 1),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const TextDefaultWidget(
                              textAlign: TextAlign.right,
                              title: 'اختر الدولة',
                              fontSize: 15,
                              color: Color(0xff1A1A1A),
                            ),
                            items: countries.keys.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextDefaultWidget(
                                    textAlign: TextAlign.right,
                                    title: country,
                                    fontSize: 12.5,
                                    color:
                                    isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: selectedCountry,
                            onChanged: (value) async {
                              if (value == null) return;

                              final Map<String, dynamic> cityMap =
                              (countries[value] as Map<String, dynamic>)
                                ..removeWhere((k, v) => v == null);

                              final firstCity = cityMap.keys.first;

                              await con.setLocation(
                                country: value,
                                city: firstCity,
                              );
                              setState(() {});
                              _adhanScheduled = false;
                              _scheduleAllAdhanForToday();
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeColors
                                      .cardBackgroundColor(context),
                                  width: 1.5,
                                ),
                                color: AppThemeColors.cardBackgroundColor(
                                    context),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              height: 50,
                              width:
                              MediaQuery.of(context).size.width / 1.2,
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              overlayColor: WidgetStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ),
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedWrapper(
                        type: UiAnimationType.slideLeft,
                        duration: const Duration(seconds: 1),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const TextDefaultWidget(
                              title: 'اختر المدينة',
                              fontSize: 15,
                            ),
                            items: cities.keys.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextDefaultWidget(
                                    textAlign: TextAlign.right,
                                    title: c,
                                    fontSize: 12.5,
                                    color:
                                    isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: selectedCity,
                            onChanged: (value) async {
                              if (value == null ||
                                  selectedCountry == null) return;

                              await con.setLocation(
                                country: selectedCountry,
                                city: value,
                              );
                              setState(() {});
                              _adhanScheduled = false;
                              _scheduleAllAdhanForToday();
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeColors
                                      .cardBackgroundColor(context),
                                  width: 1.5,
                                ),
                                color: AppThemeColors.cardBackgroundColor(
                                    context),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              height: 50,
                              width:
                              MediaQuery.of(context).size.width / 1.2,
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              overlayColor: WidgetStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ),
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'تحديد موقعي',
                      onPressed: countries.isEmpty ? null : _selectByLocation,
                      icon: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (selectedCountry != null && selectedCity != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Center(
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.place, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'الموقع الحالي: $selectedCountry - $selectedCity',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // الكارت العلوي (الصلاة القادمة والوقت المتبقي)
              AnimatedWrapper(
                type: UiAnimationType.crossFade,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 1.8,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDark
                            ? const [
                          Color(0xFF020617),
                          Color(0xFF0F172A),
                        ]
                            : [
                          baseColor.withOpacity(0.06),
                          Colors.white,
                        ],
                      ),
                      border: Border.all(
                        color: baseColor.withOpacity(isDark ? 0.5 : 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            nextPrayer.isNotEmpty
                                ? Text(
                              nextPrayer,
                              style: GoogleFonts.cairo(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.sizeOf(context).width >
                                    600
                                    ? 10.sp
                                    : 16.sp,
                              ),
                            )
                                : Center(
                              child: KLoading.progressIOSIndicator(
                                  context: context),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              remainingTimeText,
                              style: GoogleFonts.cairo(
                                color:
                                isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.sizeOf(context).width > 600
                                    ? 10.sp
                                    : 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (prayerTimes != null)
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final prayerNames = [
                        "الفجر",
                        "الشروق",
                        "الظهر",
                        "العصر",
                        "المغرب",
                        "العشاء"
                      ];
                      final prayerTimesList = [
                        prayerTimes.fajr,
                        prayerTimes.sunrise,
                        prayerTimes.dhuhr,
                        prayerTimes.asr,
                        prayerTimes.maghrib,
                        prayerTimes.isha
                      ];

                      final isNext =
                      nextPrayer.contains(prayerNames[index]);

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: isDark
                                ? const [
                              Color(0xFF020617),
                              Color(0xFF0F172A),
                            ]
                                : [
                              baseColor.withOpacity(0.06),
                              Colors.white,
                            ],
                          ),
                          border: Border.all(
                            color: isNext
                                ? (isDark
                                ? Colors.amberAccent.shade700
                                : Colors.blue)
                                : Colors.black,
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.sizeOf(context).width > 600
                                ? 8
                                : 13,
                            horizontal: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prayerNames[index],
                                style: GoogleFonts.cairo(
                                  color: isNext
                                      ? (isDark
                                      ? Colors.amberAccent.shade700
                                      : Colors.blueAccent)
                                      : (isDark
                                      ? Colors.white
                                      : Colors.black),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.sizeOf(context).width >
                                      600
                                      ? 10.sp
                                      : 17,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a')
                                    .format(prayerTimesList[index]),
                                style: GoogleFonts.cairo(
                                  color: isNext
                                      ? (isDark
                                      ? Colors.amberAccent.shade700
                                      : Colors.blueAccent)
                                      : (isDark
                                      ? Colors.white
                                      : Colors.black),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                KLoading.progressIOSIndicator(context: context),
            ],
          ),
        ),
      ),
    );
  }
}



