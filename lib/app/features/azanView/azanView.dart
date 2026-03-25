import 'dart:async';
import 'dart:ui' as ui;

import 'package:adhan/adhan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
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
        final isDark = context.isDark;
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
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: context.isTab
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
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize:
                                context.isTab ? 9.sp : 14.sp,
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
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize:
                                context.isTab ? 9.sp : 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 16),
                        _buildMadhabDropdown(isDark, setStateSheet),

                        const SizedBox(height: 16),

                        // التوقيت الصيفي
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تفعيل التوقيت الصيفي (+ساعة)',
                              style: TextStyle(
                                fontFamily: "cairo",
                                fontSize: context.isTab
                                    ? 9.sp
                                    : 14.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: con.isDSTEnabled,
                              onChanged: (value) {
                                setStateSheet(() {
                                  con.toggleDST(value);
                                });
                              },
                              activeColor: KColors.primaryColor,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // تعديل الساعات (فارق التوقيت)
                        Text(
                          'تعديل الساعات يدوياً',
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize:
                                context.isTab ? 9.sp : 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  setStateSheet(() {
                                    con.manualOffset--;
                                    con.updateCalcSettings(
                                      method: con.selectedMethod,
                                      madhab: con.selectedMadhab,
                                      offset: con.manualOffset,
                                      dstEnabled: con.isDSTEnabled,
                                    );
                                  });
                                },
                              ),
                              Text(
                                "${con.manualOffset > 0 ? '+' : ''}${con.manualOffset} ساعة",
                                style: TextStyle(
                                  fontFamily: "cairo",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () {
                                  setStateSheet(() {
                                    con.manualOffset++;
                                    con.updateCalcSettings(
                                      method: con.selectedMethod,
                                      madhab: con.selectedMadhab,
                                      offset: con.manualOffset,
                                      dstEnabled: con.isDSTEnabled,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // تعديل الدقائق يدوياً لكل صلاة
                        Text(
                          'تعديل الدقائق يدوياً (لكل صلاة)',
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize:
                                context.isTab ? 9.sp : 14.sp,
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
                              style: TextStyle(
                                fontFamily: "cairo",
                                fontSize: context.isTab
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
                              style: TextStyle(
                                fontFamily: "cairo",
                                fontSize: context.isTab
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
                style: TextStyle(
                  fontFamily: "cairo",
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
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DropdownMenuItem(
              value: Madhab.hanafi,
              child: Text(
                'الحنفي',
                style: TextStyle(
                  fontFamily: "cairo",
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
    final isDark = context.isDark;
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
            style: TextStyle(
              fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
          actions: [
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
            //       final success = await AdhanWorkManagerService()
            //           .scheduleTestAdhan(secondsFromNow: 20);
            //       if (success == null) {
            //         KHelper.showSuccess(
            //             message: '🧪 تم جدولة اختبار شامل بعد 20 ثانية');
            //       } else {
            //         KHelper.showError(message: '❌ فشل الاختبار: $success');
            //       }
            //     } catch (e) {
            //       KHelper.showError(message: '❌ خطأ: $e');
            //     }
            //   },
            // ),

            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات الحساب',
              onPressed: _showCalculationSettings,
            ),
            // IconButton(
            //   icon: const Icon(Icons.volume_up_rounded),
            //   tooltip: 'أصوات الأذان',
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (_) => const AdhanSoundsSettingsScreen()),
            //     );
            //   },
            // ),
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
              // const Icon(Icons.location_city, color: Colors.green, size: 24),
              // const SizedBox(width: 8),
              Text(
                'اختر موقعك',
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: context.isTab ? 10.sp : 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,

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
                        value == 'تحديد تلقائي') {
                      return;
                    }
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
                             style: TextStyle(
                          fontFamily: "cairo",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                context.isTab ? 8.sp : 12.sp,
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
                             style: TextStyle(
                          fontFamily: "cairo",
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                context.isTab ? 8.sp : 12.sp,
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
        title: const Text(
          'إدخال الإحداثيات يدوياً',
          textAlign: TextAlign.center,
             style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل خط العرض وخط الطول بدقة (مثال: 30.04)',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "cairo",fontSize: 12.sp, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                  fontFamily: "cairo",
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'خط العرض (Latitude)',
                labelStyle: const TextStyle(
                    fontFamily: "cairo"),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                  fontFamily: "cairo",
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'خط الطول (Longitude)',
                labelStyle: const TextStyle(
                  fontFamily: "cairo",),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',    style: TextStyle(
                          fontFamily: "cairo",color: Colors.red)),
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
            child: const Text('حفظ',    style: TextStyle(
                          fontFamily: "cairo",color: Colors.white)),
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
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 8.sp : 13.sp,
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
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 8.sp : 12.sp,
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
                     style: TextStyle(
                          fontFamily: "cairo",
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
                    hintStyle: TextStyle(
                        fontFamily: "cairo",
                        fontSize:
                            context.isTab ? 8.sp : 12.sp,
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
                     style: TextStyle(
                          fontFamily: "cairo",
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
                       style: TextStyle(
                          fontFamily: "cairo",
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: con.getNextPrayerGradient(),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: con.getNextPrayerGradient().first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: con.progressValue,
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nextPrayer,
                       style: TextStyle(
                          fontFamily: "cairo",
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
                     style: TextStyle(
                          fontFamily: "cairo",
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
    final adj = con.adjustedPrayersForUI;
    final isRamadan = con.isRamadan;

    final allPrayerData = [
      {
        "name": "الإمساك",
        "time": adj["الإمساك"],
        "icon": Icons.timer_outlined,
        "isRamadan": true,
        
      },
      {
        "name": "السحور",
        "time": adj["السحور"],
        "icon": Icons.restaurant_menu_outlined,
        "isRamadan": true
      },
      {
        "name": "الفجر",
        "time": adj["الفجر"] ?? prayerTimes.fajr,
        "icon": "assets/icons/widget_fajr_on.png"
      },
      {
        "name": "الشروق",
        "time": adj["الشروق"] ?? prayerTimes.sunrise,
        "icon": "assets/icons/widget_shrouq_on.png"
      },
      {
        "name": "الظهر",
        "time": adj["الظهر"] ?? prayerTimes.dhuhr,
        "icon": "assets/icons/widget_zohr_large.png"
      },
      {
        "name": "العصر",
        "time": adj["العصر"] ?? prayerTimes.asr,
        "icon": "assets/icons/widget_asr_on.png"
      },
      {
        "name": "المغرب",
        "time": adj["المغرب"] ?? prayerTimes.maghrib,
        "icon": "assets/icons/widget_maghreb_on.png"
      },
      {
        "name": "العشاء",
        "time": adj["العشاء"] ?? prayerTimes.isha,
        "icon": "assets/icons/widget_esha_on.png"
      },
      {
        "name": "التراويح",
        "time": (adj["العشاء"] ?? prayerTimes.isha).add(const Duration(minutes: 20)),
        "icon": Icons.mosque_outlined,
        "isRamadan": true
      },
      {
        "name": "منتصف الليل",
        "time": adj["منتصف الليل"],
        "icon": Icons.bedtime_outlined,
        "isSunnah": true
      },
      {
        "name": "الثلث الأخير",
        "time": adj["الثلث الأخير"],
        "icon": Icons.auto_awesome_rounded,
        "isSunnah": true
      },
    ];

    final prayerData = allPrayerData.where((p) {
      if (p["isRamadan"] == true && !isRamadan) return false;
      return true;
    }).toList();

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
                      : (isDark
                          ? Colors.black26
                          : Colors.grey.withOpacity(0.2)),
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
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.blue.shade50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: prayer["icon"] is IconData
                        ? Icon(
                            prayer["icon"] as IconData,
                            color: isNext
                                ? Colors.green
                                : (isDark ? Colors.white : Colors.blue.shade700),
                            size: 24,
                          )
                        : Image.asset(
                            prayer["icon"] as String,
                            width: 24,
                            height: 24,
                            color: isNext
                                ? Colors.green
                                : (isDark ? Colors.white : Colors.blue.shade700),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer["name"] as String,
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isNext
                                ? Colors.green
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (con.getIqamaTextForPrayer(prayer["name"] as String).isNotEmpty)
                          Text(
                            con.getIqamaTextForPrayer(prayer["name"] as String),
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: 10.sp,
                              color: isNext ? Colors.green.withOpacity(0.7) : Colors.grey,
                            ),
                          ),
                      ],
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
                         style: TextStyle(
                          fontFamily: "cairo",
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
          ),
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
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: context.isTab ? 9.sp : 14.sp,
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
                width: context.isTab ? 30 : 45,
                child: Text(
                  "${currentOffset > 0 ? '+' : ''}$currentOffset",
                  textAlign: TextAlign.center,
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 9.sp : 14.sp,
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

Future<void> _rescheduleNextDay() async {
  try {
    await AdhanWorkManagerService().reschedule();
  } catch (e) {
    print('❌ خطأ في إعادة الجدولة: $e');
  }
}
