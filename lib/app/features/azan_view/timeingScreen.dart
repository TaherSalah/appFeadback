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

    // تهيئة خدمة WorkManager
    _adhanService.initialize();

    // تحديث المواقيت من SharedPreferences
    con.refreshPrayerTimesFromPrefs();

    // جدولة الإشعارات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleAllPrayerNotifications();
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تفعيل خدمات الموقع والسماح بالوصول'),
            backgroundColor: Colors.orange,
          ),
        );
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
  Future<void> _showScheduledNotifications() async {
    final pending = await _adhanService.getPendingNotifications();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.green),
            const SizedBox(width: 8),
            const Text('إشعارات الأذان المجدولة'),
          ],
        ),
        content: pending.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'لا توجد إشعارات مجدولة حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        )
            : SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final notification = pending[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.mosque, color: Colors.green),
                  title: Text(
                    notification.title ?? 'بدون عنوان',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notification.body ?? ''),
                  trailing: Text(
                    'ID: ${notification.id}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
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
            // زر عرض الإشعارات المجدولة
            // IconButton(
            //   icon: const Icon(Icons.notifications_active),
            //   tooltip: 'عرض الإشعارات المجدولة',
            //   onPressed: _showScheduledNotifications,
            // ),
            // زر إعادة جدولة الإشعارات
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة جدولة الإشعارات',
              onPressed: _scheduleAllPrayerNotifications,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            children: [
              // اختيار الدولة والمدينة
              Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Row(
                  children: [
                    // Dropdown الدولة
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
                                    color: isDark ? Colors.white : Colors.black,
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

                              // جدولة الإشعارات للموقع الجديد
                              await _scheduleAllPrayerNotifications();
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeColors.cardBackgroundColor(context),
                                  width: 1.5,
                                ),
                                color: AppThemeColors.cardBackgroundColor(context),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              width: MediaQuery.of(context).size.width / 1.2,
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
                    // Dropdown المدينة
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
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: selectedCity,
                            onChanged: (value) async {
                              if (value == null || selectedCountry == null) return;

                              await con.setLocation(
                                country: selectedCountry,
                                city: value,
                              );
                              setState(() {});

                              // جدولة الإشعارات للمدينة الجديدة
                              await _scheduleAllPrayerNotifications();
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeColors.cardBackgroundColor(context),
                                  width: 1.5,
                                ),
                                color: AppThemeColors.cardBackgroundColor(context),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              width: MediaQuery.of(context).size.width / 1.2,
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
                    // زر تحديد الموقع بالـ GPS
                    IconButton(
                      tooltip: 'تحديد موقعي',
                      onPressed: countries.isEmpty ? null : _selectByLocation,
                      icon: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // عرض الموقع الحالي
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

              // باقي الواجهة (الصلاة القادمة وقائمة المواقيت)
              // ... نفس الكود السابق ...

              const SizedBox(height: 20),

              if (prayerTimes != null)
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
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

                      final isNext = nextPrayer.contains(prayerNames[index]);

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: isDark
                                ? const [Color(0xFF020617), Color(0xFF0F172A)]
                                : [baseColor.withOpacity(0.06), Colors.white],
                          ),
                          border: Border.all(
                            color: isNext
                                ? (isDark ? Colors.amberAccent.shade700 : Colors.blue)
                                : Colors.black,
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.sizeOf(context).width > 600 ? 8 : 13,
                            horizontal: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prayerNames[index],
                                style: GoogleFonts.cairo(
                                  color: isNext
                                      ? (isDark
                                      ? Colors.amberAccent.shade700
                                      : Colors.blueAccent)
                                      : (isDark ? Colors.white : Colors.black),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.sizeOf(context).width > 600 ? 10.sp : 17,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(prayerTimesList[index]),
                                style: GoogleFonts.cairo(
                                  color: isNext
                                      ? (isDark
                                      ? Colors.amberAccent.shade700
                                      : Colors.blueAccent)
                                      : (isDark ? Colors.white : Colors.black),
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



// ⚠️ هذه الدالة تعمل في الخلفية - لا تستخدم BuildContext هنا
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("🔊 بدء تشغيل الأذان في الخلفية: $task");

      // الحصول على اسم الصلاة من البيانات
      final prayerName = inputData?['prayerName'] ?? 'الفجر';
      final cityName = inputData?['cityName'] ?? '';

      // تشغيل صوت الأذان
      final audioPlayer = AudioPlayer();
      await audioPlayer.setAsset('assets/athan/athan.mp3');
      await audioPlayer.play();

      // الانتظار حتى ينتهي الأذان
      await audioPlayer.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed,
      );

      await audioPlayer.dispose();

      // إظهار إشعار أن الأذان انتهى
      final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

      await notifications.show(
        999,
        '✅ انتهى أذان $prayerName',
        'تمت قراءة الأذان - $cityName',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_complete_channel',
            'إشعارات اكتمال الأذان',
            importance: Importance.low,
            priority: Priority.low,
          ),
        ),
      );

      print("✅ انتهى تشغيل الأذان بنجاح");
      return Future.value(true);
    } catch (e) {
      print("❌ خطأ في تشغيل الأذان: $e");
      return Future.value(false);
    }
  });
}

class AdhanWorkManagerService {
  static final AdhanWorkManagerService _instance = AdhanWorkManagerService._internal();
  factory AdhanWorkManagerService() => _instance;
  AdhanWorkManagerService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // تهيئة الخدمة
  Future<void> initialize() async {
    // تهيئة WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // غيّرها لـ true للتجربة
    );

    // تهيئة الإشعارات
    tz.initializeTimeZones();

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

    await _notifications.initialize(initSettings);

    print("✅ تم تهيئة خدمة الأذان مع WorkManager");
  }

  // جدولة أذان واحد
  Future<void> scheduleAdhanWithWork({
    required String taskId,
    required DateTime prayerTime,
    required String prayerName,
    required String cityName,
  }) async {
    final now = DateTime.now();

    // لو الوقت فات، ما نجدولش
    if (prayerTime.isBefore(now)) {
      print("⏭️ وقت $prayerName فات، مش هيتجدول");
      return;
    }

    final duration = prayerTime.difference(now);

    // جدولة المهمة في WorkManager
    await Workmanager().registerOneOffTask(
      taskId,
      'playAdhan',
      initialDelay: duration,
      inputData: {
        'prayerName': prayerName,
        'cityName': cityName,
        'time': prayerTime.toIso8601String(),
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // جدولة إشعار تنبيه قبل الأذان بـ 5 دقائق (اختياري)
    await _schedulePreAdhanNotification(
      prayerTime: prayerTime,
      prayerName: prayerName,
      cityName: cityName,
    );

    // جدولة الإشعار الرئيسي
    await _scheduleAdhanNotification(
      prayerTime: prayerTime,
      prayerName: prayerName,
      cityName: cityName,
    );

    print("⏰ تم جدولة أذان $prayerName بعد ${duration.inMinutes} دقيقة");
  }

  // إشعار قبل الأذان بـ 5 دقائق (اختياري)
  Future<void> _schedulePreAdhanNotification({
    required DateTime prayerTime,
    required String prayerName,
    required String cityName,
  }) async {
    final notificationTime = prayerTime.subtract(const Duration(minutes: 5));
    final now = DateTime.now();

    if (notificationTime.isBefore(now)) return;

    final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    await _notifications.zonedSchedule(
      prayerName.hashCode + 1000, // معرف فريد
      '⏰ تنبيه: بقي 5 دقائق على أذان $prayerName',
      'استعد للصلاة - $cityName',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pre_adhan_channel',
          'تنبيهات ما قبل الأذان',
          channelDescription: 'تنبيه قبل موعد الأذان بـ 5 دقائق',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_logoapp',
          color: Color(0xFFFF9800),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // إشعار عند موعد الأذان
  Future<void> _scheduleAdhanNotification({
    required DateTime prayerTime,
    required String prayerName,
    required String cityName,
  }) async {
    final now = DateTime.now();

    if (prayerTime.isBefore(now)) return;

    final scheduledTime = tz.TZDateTime.from(prayerTime, tz.local);

    await _notifications.zonedSchedule(
      prayerName.hashCode, // معرف فريد
      '🕌 حان الآن موعد أذان $prayerName',
      '🔊 جارٍ تشغيل الأذان - $cityName',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'adhan_channel',
          'أذان الصلاة',
          channelDescription: 'إشعارات مواعيد الصلاة مع تشغيل الأذان تلقائياً',
          importance: Importance.max,
          priority: Priority.high,
          // icon: '@drawable/ic_stat_logoapp',
          icon: 'ic_stat_logoapp',
          playSound: true,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFF00C853),
          // يمكن إضافة صوت قصير هنا أيضاً
          // sound: RawResourceAndroidNotificationSound('adhan_short'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // جدولة جميع الصلوات لعدة أيام
  Future<void> scheduleAllPrayersForMultipleDays({
    required Coordinates coordinates,
    required CalculationParameters calculationParams,
    required String cityName,
    int days = 7,
  }) async {
    print("📅 جدولة الأذان لـ $days أيام قادمة...");

    // إلغاء جميع المهام السابقة
    await Workmanager().cancelAll();
    await _notifications.cancelAll();

    int taskCounter = 0;

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final dateComponents = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(
        coordinates,
        dateComponents,
        calculationParams,
      );

      // جدولة كل صلاة (ما عدا الشروق)
      final prayers = {
        'الفجر': prayerTimes.fajr,
        'الظهر': prayerTimes.dhuhr,
        'العصر': prayerTimes.asr,
        'المغرب': prayerTimes.maghrib,
        'العشاء': prayerTimes.isha,
      };

      for (var entry in prayers.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;

        await scheduleAdhanWithWork(
          taskId: 'adhan_${prayerName}_day${i}_$taskCounter',
          prayerTime: prayerTime,
          prayerName: prayerName,
          cityName: cityName,
        );

        taskCounter++;
      }
    }

    // حفظ البيانات في SharedPreferences للاستخدام بعد إعادة التشغيل
    await _savePrayerSchedule(
      coordinates: coordinates,
      calculationParams: calculationParams,
      cityName: cityName,
      days: days,
    );

    print("✅ تم جدولة ${taskCounter} أذان لـ $days أيام");
  }

  // حفظ جدول الصلاة
  Future<void> _savePrayerSchedule({
    required Coordinates coordinates,
    required CalculationParameters calculationParams,
    required String cityName,
    required int days,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduleData = {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'cityName': cityName,
      'days': days,
      'lastUpdate': DateTime.now().toIso8601String(),
    };

    await prefs.setString('prayer_schedule', jsonEncode(scheduleData));
  }

  // إلغاء جميع المهام
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    await _notifications.cancelAll();
    print("🗑️ تم إلغاء جميع مهام الأذان");
  }

  // الحصول على المهام المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}