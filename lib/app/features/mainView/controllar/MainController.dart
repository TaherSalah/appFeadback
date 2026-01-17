import 'dart:async';
import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as initl;
import 'package:intl/intl.dart';
import 'package:muslimdaily/app/core/utils/log.dart';
import 'package:muslimdaily/app/features/azanView/adhan_workmanager_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/system_control_service.dart';
import '../../../core/utils/constent/router.dart';
import '../../../core/utils/style/k_helper.dart';

class MainController extends ControllerMVC {
  static final MainController _instance = MainController._internal();

  factory MainController() => _instance;

  MainController._internal() : super();

  // مفاتيح SharedPreferences
  static const _kCountryKey = 'selected_country';
  static const _kCityKey = 'selected_city';
  static const _kLatKey = 'latitude';
  static const _kLngKey = 'longitude';
  static const _kUseGPSKey = 'is_using_gps';
  static const _kHijriAdjustmentKey = 'hijri_adjustment';

  Map<String, dynamic> countries = {};
  Map<String, dynamic> cities = {};
  String? selectedCountry;
  String? selectedCity;
  double? latitude;
  double? longitude;
  bool isUsingGPS = false;
  bool isLoadingLocation = false; // حالة تحميل الموقع التلقائي
  int hijriAdjustment = 0; // تعديل التاريخ الهجري يدوياً

  // إعدادات الحساب
  CalculationMethod selectedMethod = CalculationMethod.egyptian;
  Madhab selectedMadhab = Madhab.shafi;
  int manualOffset = 0; // تعديل الساعات يدوياً

  // تعديلات الدقائق لكل صلاة بشكل منفصل
  int fajrOffset = 0;
  int sunriseOffset = 0;
  int dhuhrOffset = 0;
  int asrOffset = 0;
  int maghribOffset = 0;
  int ishaOffset = 0;

  // تعديلات الدقائق العامة (إدارة)
  int globalFajrOffset = 0;
  int globalSunriseOffset = 0;
  int globalDhuhrOffset = 0;
  int globalAsrOffset = 0;
  int globalMaghribOffset = 0;
  int globalIshaOffset = 0;

  // إعدادات أذكار بعد الصلاة
  bool postPrayerReminderEnabled = false;
  int postReminderMinutes = 10; // الافتراضي 10 دقائق

  PrayerTimes? prayerTimes;
  double progressValue = 0.0;
  String remainingTimeText = "";
  String nextPrayer = "";
  Timer? countdownTimer;
  bool isIqamaCountdown = false;
  DateTime? previousTime;
  DateTime? targetTime;

  late DateTime now;
  String? gregorian;
  HijriCalendar? hijri;
  String upcomingPrayerName = "";
  final List<Map<String, String>> iconsApp = [
    {
      "title": "أَذْكَارُ الصَّبَاحِ",
      "icon": "assets/images/contrast.png",
      "navigate": "/azkarSabah"
    },
    {
      "title": "أَذْكَارُ الْمَسَاءِ",
      "icon": "assets/images/islam.png",
      "navigate": "/azkarMassa"
    },
    {
      "title": "السبحة",
      "icon": "assets/images/beads2.png",
      "navigate": "/azkarCounter"
    },
    {
      "title": "المصحف",
      "icon": "assets/images/koran.png",
      "navigate": "/surahListScreen"
    },
    {
      "title": "أَذْكَارٌ مُتَنَوِّعَةٌ",
      "icon": "assets/images/open-hands.png",
      "navigate": "/allazkarlistview"
    },
    {
      "title": "مَوَاقِيتُ الصَّلَاةِ",
      "icon": "assets/images/mosque.png",
      "navigate": "/timingScreen"
    },
    {
      "icon":
          "assets/images/deadline.png", // Using clock as placeholder for calendar
      "title": "التقويم",
      "navigate": "/calendar",
      "visible": "true"
    },
    {
      "icon": "assets/images/qibla (1).png",
      "title": "القبلة",
      "navigate": "/qiblaDirection",
      "visible": "true"
    },
    {
      "title": "مَوْسُوعَةُ الْأَحَادِيثِ",
      "icon": "assets/images/kaaba.png",
      "navigate": Routes.categoriesRoute,
    },
    {
      "title": "راديو القران الكريم",
      "icon": "assets/icons/radio.png",
      "navigate": "/QuranRadioView"
    },
    {
      "title": "الختمات المنجزه",
      "icon": "assets/images/achivement.png",
      "navigate": "/compplateKhatna"
    },
    {
      "title": " اورادك من الذكر",
      "icon": "assets/images/tauhid.png",
      "navigate": "/WirdHomeScreen"
    },
    // {
    //   "title": "قناة القران الكريم",
    //   "icon": "assets/icons/radio.png",
    //   "navigate": "/QuranChannalPlayerView"
    // },
    // {
    //   "title": "قناة السنة النبوية",
    //   "icon": "assets/icons/radio.png",
    //   "navigate": "/QuranChannalPlayerView"
    // },
    {
      "title": "حاسبة الزكاة",
      "icon": "assets/images/charity.png",
      "navigate": Routes.zakatCalculatorRoute
    },
    {
      "title": "المساجد القريبة",
      "icon": "assets/images/mosque.png",
      "navigate": "/mosquesMap"
    },
    {
      "title": "منبه الفجر",
      "icon": "assets/images/clock.png",
      "navigate": "/fajrAlarm"
    },
    {
      "title": "كتب الحديث",
      "icon": "assets/images/book-stack.png",
      "navigate": "/NineBooksScreen"
    },
    {
      "title": "الاعدادات",
      "icon": "assets/images/app.png",
      "navigate": "/settingsRoute"
    },
  ];

  static const _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩'
  ];
  String toArabicDigits(String s) =>
      s.replaceAllMapped(RegExp(r'\d'), (m) => _arabicDigits[int.parse(m[0]!)]);

  // List<String> images = [
  //   "assets/images/fajr.png",
  //   "assets/images/shrok.png",
  //   "assets/images/dohr.png",
  //   "assets/images/asr.png",
  //   "assets/images/maghrab.png",
  //   "assets/images/ihsaa.png",
  // ];

  @override
  void initState() {
    super.initState();

    HijriCalendar.setLocal('ar');

    // التاريخ الميلادي والهجري
    initializeDateFormatting('ar').then((_) {
      now = DateTime.now();
      gregorian = toArabicDigits(
        initl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(now),
      );
      _updateHijriDate();
      setState(() {});
    });

    _loadCountriesAndLocation();
    _loadSettings(); // تحميل إعدادات الحساب
  }

  // تحميل إعدادات الحساب والمذهب
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // المذهب
    final madhabIndex = prefs.getInt('madhab') ?? 0;
    selectedMadhab = madhabIndex == 1 ? Madhab.hanafi : Madhab.shafi;
    manualOffset = prefs.getInt('manual_offset') ?? 0;

    fajrOffset = prefs.getInt('fajr_offset') ?? 0;
    sunriseOffset = prefs.getInt('sunrise_offset') ?? 0;
    dhuhrOffset = prefs.getInt('dhuhr_offset') ?? 0;
    asrOffset = prefs.getInt('asr_offset') ?? 0;
    maghribOffset = prefs.getInt('maghrib_offset') ?? 0;
    ishaOffset = prefs.getInt('isha_offset') ?? 0;

    postPrayerReminderEnabled =
        prefs.getBool('post_prayer_reminder_enabled') ?? false;
    postReminderMinutes = prefs.getInt('post_reminder_minutes') ?? 10;

    // طريقة الحساب (نحاول استرجاعها من المؤشر المحفوظ، أو نخمنها من المعلمات إذا لم يوجد)
    final methodIndex = prefs.getInt('calculation_method_index');
    if (methodIndex != null &&
        methodIndex >= 0 &&
        methodIndex < CalculationMethod.values.length) {
      selectedMethod = CalculationMethod.values[methodIndex];
    } else {
      // الافتراضي
      selectedMethod = CalculationMethod.egyptian;
    }

    hijriAdjustment = prefs.getInt(_kHijriAdjustmentKey) ?? 0;
    _updateHijriDate();

    // تحميل التعديلات العامة من السيرفر
    final globalOffsets = await SystemControlService().getGlobalPrayerOffsets();
    globalFajrOffset = globalOffsets['fajr'] ?? 0;
    globalSunriseOffset = globalOffsets['sunrise'] ?? 0;
    globalDhuhrOffset = globalOffsets['dhuhr'] ?? 0;
    globalAsrOffset = globalOffsets['asr'] ?? 0;
    globalMaghribOffset = globalOffsets['maghrib'] ?? 0;
    globalIshaOffset = globalOffsets['isha'] ?? 0;

    calculatePrayerTimes();
    setState(() {});
  }

  void _updateHijriDate() {
    final adjustedDate = DateTime.now().add(Duration(days: hijriAdjustment));
    hijri = HijriCalendar.fromDate(adjustedDate);
  }

  Future<void> setHijriAdjustment(int val) async {
    hijriAdjustment = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHijriAdjustmentKey, val);
    _updateHijriDate();
    setState(() {});
  }

  /// تحديد الموقع تلقائياً باستخدام GPS
  ///
  /// ملاحظة: GPS لا يحتاج إنترنت، لكن تحويل الإحداثيات لاسم مدينة يحتاج إنترنت
  /// إذا لم يتوفر إنترنت، سيظهر "تحديد تلقائي - الموقع الفعلي (GPS)"
  Future<void> autoDetectLocation({bool silent = false}) async {
    // بدء حالة التحميل
    isLoadingLocation = true;
    setState(() {});

    try {
      final locationService = LocationService();

      // الخطوة 1: الحصول على الموقع من GPS (لا يحتاج إنترنت)
      final pos = await locationService.getCurrentPosition();

      if (pos == null) {
        if (!silent)
          KHelper.showError(
              message:
                  'تعذر الحصول على الموقع. تحقق من الصلاحيات وخدمة الموقع.');
        return;
      }

      latitude = pos.latitude;
      longitude = pos.longitude;
      isUsingGPS = true;

      // الخطوة 2: محاولة الحصول على اسم المدينة (يحتاج إنترنت)
      final address =
          await locationService.getAddressFromLatLng(latitude!, longitude!);

      if (address != null) {
        // نجح Geocoding - لدينا اسم المدينة
        selectedCountry = address['country'];
        selectedCity = address['city'];

        if (!silent)
          KHelper.showSuccess(
              message: 'تم تحديد الموقع بنجاح: ${selectedCity ?? ""}');
      } else {
        // فشل Geocoding - ربما لا يوجد إنترنت
        selectedCountry = 'تحديد تلقائي';
        selectedCity = 'الموقع الفعلي (GPS)';

        if (!silent)
          KHelper.showSuccess(
              message:
                  'تم تحديد موقعك بنجاح\n💡 الإنترنت مطلوب فقط لعرض اسم المدينة');
      }

      await locationService.saveLocation(
        lat: latitude!,
        lng: longitude!,
        city: selectedCity,
        country: selectedCountry,
        isGPS: true,
      );

      calculatePrayerTimes();
      await AdhanWorkManagerService().initialize();
      setState(() {});
    } catch (e) {
      if (!silent) KHelper.showError(message: 'حدث خطأ أثناء تحديد الموقع');
      log('Error in autoDetectLocation: $e');
    } finally {
      // إنهاء حالة التحميل
      isLoadingLocation = false;
      setState(() {});
    }
  }

  // تحديث إعدادات الحساب
  Future<void> updateCalcSettings({
    required CalculationMethod method,
    required Madhab madhab,
    required int offset,
    bool? postReminderEnabled,
    int? postRemMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    selectedMethod = method;
    selectedMadhab = madhab;
    manualOffset = offset;
    if (postReminderEnabled != null) {
      postPrayerReminderEnabled = postReminderEnabled;
    }
    if (postRemMinutes != null) postReminderMinutes = postRemMinutes;

    // حفظ المؤشرات للواجهة
    await prefs.setInt('calculation_method_index', method.index);
    await prefs.setInt('madhab', madhab == Madhab.hanafi ? 1 : 0);
    await prefs.setInt('manual_offset', manualOffset);

    await prefs.setInt('fajr_offset', fajrOffset);
    await prefs.setInt('sunrise_offset', sunriseOffset);
    await prefs.setInt('dhuhr_offset', dhuhrOffset);
    await prefs.setInt('asr_offset', asrOffset);
    await prefs.setInt('maghrib_offset', maghribOffset);
    await prefs.setInt('isha_offset', ishaOffset);

    await prefs.setBool(
        'post_prayer_reminder_enabled', postPrayerReminderEnabled);
    await prefs.setInt('post_reminder_minutes', postReminderMinutes);

    // حفظ القيم التفصيلية للـ WorkManager
    final params = method.getParameters();
    await prefs.setDouble('fajr_angle', params.fajrAngle);
    await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
    if (params.ishaInterval > 0) {
      await prefs.setInt('isha_interval', params.ishaInterval);
    } else {
      await prefs.remove('isha_interval');
    }

    // إعادة الحساب والجدولة
    calculatePrayerTimes();
    await AdhanWorkManagerService().initialize();
    setState(() {});
  }

  // دوال تعديل الدقائق يدوياً
  Future<void> adjustPrayerOffset(String prayer, int delta) async {
    switch (prayer) {
      case 'الفجر':
        fajrOffset += delta;
        break;
      case 'الشروق':
        sunriseOffset += delta;
        break;
      case 'الظهر':
        dhuhrOffset += delta;
        break;
      case 'العصر':
        asrOffset += delta;
        break;
      case 'المغرب':
        maghribOffset += delta;
        break;
      case 'العشاء':
        ishaOffset += delta;
        break;
    }
    await updateCalcSettings(
      method: selectedMethod,
      madhab: selectedMadhab,
      offset: manualOffset,
    );
  }

  String get hijriDate => hijri == null
      ? ''
      : toArabicDigits(
          '${hijri!.hDay} ${hijri!.getLongMonthName()} ${hijri!.hYear} هـ',
        );

  // تحميل الدول + قراءة الموقع المخزون (إن وجد)
  Future<void> _loadCountriesAndLocation() async {
    try {
      final String response =
          await rootBundle.loadString('assets/images/egypt_governorates.json');
      final data = json.decode(response) as Map<String, dynamic>;
      countries = data;

      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString(_kCountryKey);
      final savedCity = prefs.getString(_kCityKey);
      latitude = prefs.getDouble(_kLatKey);
      longitude = prefs.getDouble(_kLngKey);
      isUsingGPS = prefs.getBool(_kUseGPSKey) ?? false;

      if (savedCountry == null && savedCity == null && !isUsingGPS) {
        // أول مرة يفتح التطبيق، نحاول تحديد الموقع تلقائياً
        await autoDetectLocation(silent: true);
      }

      // دولة افتراضية: مصر إن وجدت، وإلا أول دولة
      final defaultCountry =
          countries.keys.contains('مصر') ? 'مصر' : countries.keys.first;

      if (isUsingGPS && savedCountry != null && savedCity != null) {
        // إذا كان GPS، نستخدم القيم المحفوظة مباشرة لتجنب حذف أسماء المدن خارج القائمة الثابتة
        selectedCountry = savedCountry;
        selectedCity = savedCity;

        if (countries.containsKey(selectedCountry)) {
          cities = (countries[selectedCountry!] as Map<String, dynamic>)
            ..removeWhere((k, v) => v == null);
        } else {
          cities = {}; // قائمة فارغة لأنها خارج القائمة اليدوية
        }
      } else {
        // اختيار يدوي أو تأكد من الوجود في القائمة
        selectedCountry =
            savedCountry != null && countries.keys.contains(savedCountry)
                ? savedCountry
                : defaultCountry;

        cities = (countries[selectedCountry!] as Map<String, dynamic>)
          ..removeWhere((k, v) => v == null);

        selectedCity = savedCity != null && cities.keys.contains(savedCity)
            ? savedCity
            : cities.keys.first;
      }

      setState(() {});
      calculatePrayerTimes();
    } catch (e) {
      log('Error loading JSON: $e');
    }
  }

  Future<void> _saveSelection() async {
    final p = await SharedPreferences.getInstance();
    if (selectedCountry != null) {
      await p.setString(_kCountryKey, selectedCountry!);
    }
    if (selectedCity != null) {
      await p.setString(_kCityKey, selectedCity!);
    }
    await p.setBool(_kUseGPSKey, isUsingGPS);
    if (latitude != null) await p.setDouble(_kLatKey, latitude!);
    if (longitude != null) await p.setDouble(_kLngKey, longitude!);
  }

  /// تغيير الموقع (تُستدعى من أي شاشة: Main أو TimingScreen أو من الإعدادات)
  Future<void> setLocation({
    required String country,
    required String city,
  }) async {
    if (!countries.containsKey(country)) return;

    final Map<String, dynamic> cityMap = (countries[country]
        as Map<String, dynamic>)
      ..removeWhere((k, v) => v == null);

    if (!cityMap.containsKey(city)) return;

    selectedCountry = country;
    cities = cityMap;
    selectedCity = city;
    isUsingGPS = false; // اختيار يدوي يلغي وضع الـ GPS المباشر

    // تحديث الإحداثيات من الـ JSON للاختيار اليدوي
    latitude = (cityMap[city]!["lat"]).toDouble();
    longitude = (cityMap[city]!["lng"]).toDouble();

    await _saveSelection();
    calculatePrayerTimes();
    await AdhanWorkManagerService().initialize();
    setState(() {});
  }

  /// إدخال الإحداثيات يدوياً
  Future<void> setManualCoordinates(double lat, double lng) async {
    latitude = lat;
    longitude = lng;
    isUsingGPS = true; // نعتبرها "موقع مخصص" ونستخدم الإحداثيات مباشرة
    selectedCountry = 'مخصص';
    selectedCity = 'إحداثيات يدوية';

    await _saveSelection();
    calculatePrayerTimes();
    await AdhanWorkManagerService().initialize();
    setState(() {});
  }

  void calculatePrayerTimes() {
    if (selectedCity == null && !isUsingGPS) return;

    final double lat;
    final double lng;

    if (isUsingGPS && latitude != null && longitude != null) {
      lat = latitude!;
      lng = longitude!;
    } else if (selectedCity != null) {
      lat = (cities[selectedCity]!["lat"]).toDouble();
      lng = (cities[selectedCity]!["lng"]).toDouble();
    } else {
      return;
    }

    final coordinates = Coordinates(lat, lng);

    // استخدام الإعدادات الحالية
    final params = selectedMethod.getParameters();
    params.madhab = selectedMadhab;
    final date = DateComponents.from(DateTime.now());
    final times = PrayerTimes(coordinates, date, params);

    final nowLocal = DateTime.now();
    final hourOffset = Duration(hours: manualOffset);

    final prayers = {
      "الفجر": times.fajr
          .add(hourOffset)
          .add(Duration(minutes: fajrOffset + globalFajrOffset)),
      "الشروق": times.sunrise
          .add(hourOffset)
          .add(Duration(minutes: sunriseOffset + globalSunriseOffset)),
      "الظهر": times.dhuhr
          .add(hourOffset)
          .add(Duration(minutes: dhuhrOffset + globalDhuhrOffset)),
      "العصر": times.asr
          .add(hourOffset)
          .add(Duration(minutes: asrOffset + globalAsrOffset)),
      "المغرب": times.maghrib
          .add(hourOffset)
          .add(Duration(minutes: maghribOffset + globalMaghribOffset)),
      "العشاء": times.isha
          .add(hourOffset)
          .add(Duration(minutes: ishaOffset + globalIshaOffset)),
    };

    DateTime? next;
    String? upcoming;
    for (var entry in prayers.entries) {
      if (nowLocal.isBefore(entry.value)) {
        next = entry.value;
        upcoming = entry.key;
        break;
      }
    }

    if (next == null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextFajr =
          PrayerTimes(coordinates, DateComponents.from(tomorrow), params).fajr;
      next = nextFajr;
      upcoming = "الفجر";
    }

    upcomingPrayerName = upcoming!;
    final iqama = getIqamaTime(upcomingPrayerName, next);
    previousTime = DateTime.now();
    targetTime = next;

    startCountdown(
      from: DateTime.now(),
      to: next,
      isIqama: false,
      onDone: () {
        if (iqama.year != 0) {
          previousTime = next;
          targetTime = iqama;
          startCountdown(
            from: DateTime.now(),
            to: iqama,
            isIqama: true,
            onDone: () {
              calculatePrayerTimes();
            },
          );
        } else {
          calculatePrayerTimes();
        }
      },
    );

    log('PrayerTimes computed: $times');
    setState(() {
      prayerTimes = times;
    });
  }

  void startCountdown({
    required DateTime from,
    required DateTime to,
    required bool isIqama,
    required VoidCallback onDone,
  }) {
    countdownTimer?.cancel();
    isIqamaCountdown = isIqama;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final nowLocal = DateTime.now();
      final total = to.difference(previousTime!).inSeconds;
      final remaining = to.difference(nowLocal).inSeconds;

      if (remaining <= 0) {
        countdownTimer?.cancel();
        onDone();
        return;
      }

      final progress = 1.0 - (remaining / total);
      final h = remaining ~/ 3600;
      final m = (remaining % 3600) ~/ 60;
      final s = remaining % 60;

      setState(() {
        progressValue = progress.clamp(0.0, 1.0);
        remainingTimeText =
            "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
        nextPrayer =
            isIqama ? " الإقامة لصلاة $upcomingPrayerName" : upcomingPrayerName;
      });
    });
  }

  String formatTime(DateTime t) =>
      toArabicDigits(DateFormat('hh:mm a', 'ar').format(t.toLocal()));

  DateTime getIqamaTime(String prayerName, DateTime adhanTime) {
    switch (prayerName) {
      case "الفجر":
        return adhanTime.add(const Duration(minutes: 20));
      case "المغرب":
        return adhanTime.add(const Duration(minutes: 5));
      case "الشروق":
        return DateTime(0); // لا إقامة للشروق
      default:
        return adhanTime.add(const Duration(minutes: 10));
    }
  }

  zakarShared({
    String? azkarConten,
    String? azkarContenDes,
    zakarType,
    subjectType,
  }) {
    Share.share(
      subject: subjectType,
      ' من $zakarType \n\n$azkarConten\n\n$azkarContenDes',
    );
  }

  Future<void> refreshPrayerTimesFromPrefs() async {
    // لو لسه الدول ما اتحملتش، استعمل نفس لوجيك التحميل الأساسي
    if (countries.isEmpty) {
      await _loadCountriesAndLocation(); // أو loadCountries() عندك حسب اسمها
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedCountry = prefs.getString('selected_country');
    final savedCity = prefs.getString('selected_city');

    if (savedCountry != null && countries.containsKey(savedCountry)) {
      final Map<String, dynamic> cityMap = (countries[savedCountry]
          as Map<String, dynamic>)
        ..removeWhere((k, v) => v == null);

      if (savedCity != null && cityMap.containsKey(savedCity)) {
        selectedCountry = savedCountry;
        cities = cityMap;
        selectedCity = savedCity;
      }
    }

    calculatePrayerTimes(); // يعيد حساب المواقيت بناء على المكان الجديد
    setState(() {}); // يخبّر كل الـ Views اللي راكبة على هذا الكنترولر
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }
}
