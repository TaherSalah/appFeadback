import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as initl;
import 'package:intl/intl.dart';
import 'package:muslimdaily/app/core/utils/log.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/constent/router.dart';

class MainController extends ControllerMVC {
  static final MainController _instance = MainController._internal();

  factory MainController() => _instance;

  MainController._internal() : super();

  // مفاتيح SharedPreferences
  static const _kCountryKey = 'selected_country';
  static const _kCityKey = 'selected_city';

  Map<String, dynamic> countries = {};
  Map<String, dynamic> cities = {};
  String? selectedCountry;
  String? selectedCity;

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
      "title": "الْقِبْلَةِ",
      "icon": "assets/images/qibla (1).png",
      "navigate": "/qiblaDirection"
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
      "title": "عَنَّا",
      "icon": "assets/images/info (1).png",
      "navigate": "/about"
    },
  ];

  static const _arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
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
      hijri = HijriCalendar.now();
      setState(() {});
    });

    _loadCountriesAndLocation();
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

      // دولة افتراضية: مصر إن وجدت، وإلا أول دولة
      final defaultCountry =
      countries.keys.contains('مصر') ? 'مصر' : countries.keys.first;

      selectedCountry = savedCountry != null && countries.keys.contains(savedCountry)
          ? savedCountry
          : defaultCountry;

      cities = (countries[selectedCountry!] as Map<String, dynamic>)
        ..removeWhere((k, v) => v == null);

      selectedCity = savedCity != null && cities.keys.contains(savedCity)
          ? savedCity
          : cities.keys.first;

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
  }

  /// تغيير الموقع (تُستدعى من أي شاشة: Main أو TimingScreen أو من الإعدادات)
  Future<void> setLocation({
    required String country,
    required String city,
  }) async {
    if (!countries.containsKey(country)) return;

    final Map<String, dynamic> cityMap =
    (countries[country] as Map<String, dynamic>)
      ..removeWhere((k, v) => v == null);

    if (!cityMap.containsKey(city)) return;

    selectedCountry = country;
    cities = cityMap;
    selectedCity = city;

    await _saveSelection();
    calculatePrayerTimes();
    setState(() {});
  }

  /// إعادة قراءة الموقع من SharedPreferences ثم إعادة حساب المواقيت
  // Future<void> refreshPrayerTimesFromPrefs() async {
  //   if (countries.isEmpty) {
  //     await _loadCountriesAndLocation();
  //     return;
  //   }
  //
  //   final p = await SharedPreferences.getInstance();
  //   final savedCountry = p.getString(_kCountryKey);
  //   final savedCity = p.getString(_kCityKey);
  //
  //   if (savedCountry != null && countries.containsKey(savedCountry)) {
  //     final Map<String, dynamic> cityMap =
  //     (countries[savedCountry] as Map<String, dynamic>)
  //       ..removeWhere((k, v) => v == null);
  //
  //     if (savedCity != null && cityMap.containsKey(savedCity)) {
  //       selectedCountry = savedCountry;
  //       cities = cityMap;
  //       selectedCity = savedCity;
  //     }
  //   }
  //
  //   calculatePrayerTimes();
  //   setState(() {});
  // }

  void calculatePrayerTimes() {
    if (selectedCity == null) return;

    final lat = (cities[selectedCity]!["lat"]).toDouble();
    final lng = (cities[selectedCity]!["lng"]).toDouble();
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.egyptian.getParameters();
    final date = DateComponents.from(DateTime.now());
    final times = PrayerTimes(coordinates, date, params);

    final nowLocal = DateTime.now();
    final prayers = {
      "الفجر": times.fajr,
      "الشروق": times.sunrise,
      "الظهر": times.dhuhr,
      "العصر": times.asr,
      "المغرب": times.maghrib,
      "العشاء": times.isha,
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
        nextPrayer = isIqama
            ? " الإقامة لصلاة $upcomingPrayerName"
            : upcomingPrayerName;
      });
    });
  }

  String formatTime(DateTime t) =>
      toArabicDigits(DateFormat('hh:mm a', 'ar').format(t));

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
      final Map<String, dynamic> cityMap =
      (countries[savedCountry] as Map<String, dynamic>)
        ..removeWhere((k, v) => v == null);

      if (savedCity != null && cityMap.containsKey(savedCity)) {
        selectedCountry = savedCountry;
        cities = cityMap;
        selectedCity = savedCity;
      }
    }

    calculatePrayerTimes();   // يعيد حساب المواقيت بناء على المكان الجديد
    setState(() {});          // يخبّر كل الـ Views اللي راكبة على هذا الكنترولر
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }
}
