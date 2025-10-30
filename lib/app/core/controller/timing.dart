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

class MainController extends ControllerMVC {
  static final MainController _instance = MainController._internal();

  factory MainController() => _instance;

  MainController._internal() : super();

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
  static const _arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
  String toArabicDigits(String s) =>
      s.replaceAllMapped(RegExp(r'\d'), (m) => _arabicDigits[int.parse(m[0]!)]);

  List<String> images = [
    "assets/images/fajr.png",
    "assets/images/shrok.png",
    "assets/images/dohr.png",
    "assets/images/asr.png",
    "assets/images/maghrab.png",
    "assets/images/ihsaa.png",
  ];
  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    initializeDateFormatting('ar').then((_) {
      setState(() {
        now = DateTime.now();
        gregorian = toArabicDigits(initl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(now));
        hijri = HijriCalendar.now();
      });
    });
    loadCountries();
  }
  String get hijriDate => hijri == null
      ? ''
      : toArabicDigits('${hijri!.hDay} ${hijri!.getLongMonthName()} ${hijri!.hYear} هـ');

  // @override
  // void initState() {
  //   super.initState();
  //   HijriCalendar.setLocal("ar"); // ⬅️ يُفعِّل اللغة العربية
  //
  //   // 1) تهيئة فورمات التاريخ العربي
  //   initializeDateFormatting('ar').then((_) {
  //     setState(() {
  //       now = DateTime.now();
  //       gregorian = initl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);
  //       hijri = HijriCalendar.now();
  //     });
  //   });
  //
  //   // 2) تحميل الدول والـ JSON
  //   loadCountries();
  // }

  // String get hijriDate => hijri != null
  //     ? "${hijri!.hDay} ${hijri!.getLongMonthName()} ${hijri!.hYear} هـ"
  //     : "";

  Future<void> loadCountries() async {
    try {
      log("Loading countries...");
      final String response =
          await rootBundle.loadString('assets/images/egypt_governorates.json');
      final data = json.decode(response) as Map<String, dynamic>;
      setState(() {
        countries = data;
        // أول دولة في الماب
        selectedCountry = countries.keys.first;
        cities = countries[selectedCountry!] as Map<String, dynamic>;
        selectedCity = cities.keys.first;
        calculatePrayerTimes();
      });
    } catch (e) {
      log('Error loading JSON: $e');
      // ممكن هنا تعرض Snackbar أو AlertDialog للمستخدم
    }
  }

  void calculatePrayerTimes() {
    if (selectedCity == null) return;

    final lat = cities[selectedCity]!["lat"] as double;
    final lng = cities[selectedCity]!["lng"] as double;
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

    log('PrayerTimes computed: $times'); // للطباعة في الكونصول علشان تشوفه
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

  // String formatTime(DateTime time) {
  //   return DateFormat.jm().format(time);
  // }
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

  zakarShared(
      {String? azkarConten, String? azkarContenDes, zakarType, subjectType}) {
    Share.share(
      subject: subjectType,
      ' من $zakarType \n\n$azkarConten\n\n$azkarContenDes',
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }
}
