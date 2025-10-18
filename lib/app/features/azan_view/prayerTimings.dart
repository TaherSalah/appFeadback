import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:just_audio/just_audio.dart'; // لتشغيل الصوت

class TimingScreen extends StatefulWidget {
  const TimingScreen({super.key});

  @override
  State<TimingScreen> createState() => _TimingScreenState();
}

class _TimingScreenState extends State<TimingScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic> countries = {}; // لخزن الدول
  Map<String, dynamic> cities = {}; // لخزن المدن بناءً على الدولة
  String? selectedCountry; // لتخزين الدولة المختارة
  String? selectedCity; // لتخزين المدينة المختارة
  PrayerTimes? prayerTimes;
  Timer? countdownTimer;
  DateTime? previousTime;
  DateTime? targetTime;

  // المتغيرات الناقصة
  String nextPrayer = "";
  String remainingTimeText = "";
  double progressValue = 0.0; // إضافة المتغير لحفظ التقدم في العد التنازلي

  Map<String, String> adhanSounds = {
    "الفجر": "assets/sounds/fajr_adhan.mp3",
    "الظهر": "assets/sounds/dhuhr_adhan.mp3",
    "العصر": "assets/sounds/asr_adhan.mp3",
    "المغرب": "assets/sounds/maghrib_adhan.mp3",
    "العشاء": "assets/sounds/isha_adhan.mp3",
  };

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    final String response =
    await rootBundle.loadString('assets/images/egypt_governorates.json');
    final data = json.decode(response) as Map<String, dynamic>;
    setState(() {
      countries = data;
      selectedCountry = countries.keys.first;
      cities = countries[selectedCountry!] ?? {};
      selectedCity = cities.keys.first;
      calculatePrayerTimes();
    });
  }

  void calculatePrayerTimes() {
    if (selectedCity == null) return;

    final lat = cities[selectedCity]!["lat"];
    final lng = cities[selectedCity]!["lng"];
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.egyptian.getParameters();
    final date = DateComponents.from(DateTime.now());
    final times = PrayerTimes(coordinates, date, params);

    final now = DateTime.now();
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
      if (now.isBefore(entry.value)) {
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

    final iqama = getIqamaTime(upcoming!, next);
    previousTime = DateTime.now();
    targetTime = next;

    // بدء العد التنازلي للصلاة
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

    // تشغيل صوت الأذان عند وقت الصلاة
    scheduleAdhan(next, upcoming);

    setState(() {
      prayerTimes = times;
    });
  }

  // دالة لتشغيل صوت الأذان
  void playAdhanSound(DateTime prayerTime, String prayerName) {
    final sound = adhanSounds[prayerName] ?? "assets/sounds/default_adhan.mp3";

    // استخدام AudioPlayer من just_audio لتشغيل الصوت من الـ assets
    _audioPlayer.setAsset(sound).then((_) {
      _audioPlayer.play();
    }).catchError((e) {
      print("Error playing sound: $e");
    });
  }

  // دالة لتجدول الأذان عند الصلاة
  void scheduleAdhan(DateTime prayerTime, String prayerName) {
    final now = DateTime.now();
    final duration = Duration(seconds: 0); // اجعل الأذان يعمل فورًا للاختبار

    // تشغيل الأذان الآن
    Future.delayed(duration, () {
      playAdhanSound(prayerTime, prayerName);
      print("تشغيل الأذان الآن!");
    });
  }

  DateTime getIqamaTime(String prayerName, DateTime adhanTime) {
    switch (prayerName) {
      case "الفجر":
        return adhanTime.add(const Duration(minutes: 20));
      case "المغرب":
        return adhanTime.add(const Duration(minutes: 5));
      case "الشروق":
        return DateTime(0); // لا إقامة
      default:
        return adhanTime.add(const Duration(minutes: 10));
    }
  }

  void stopAdhanSound() {
    _audioPlayer.stop();
  }

  // دالة لبدء العد التنازلي
  void startCountdown({
    required DateTime from,
    required DateTime to,
    required bool isIqama,
    required VoidCallback onDone,
  }) {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final total = to.difference(from).inSeconds;
      final remaining = to.difference(now).inSeconds;

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
        progressValue = progress.clamp(0.0, 1.0); // تحديث التقدم
        remainingTimeText =
        "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
        nextPrayer = isIqama
            ? "الإقامة ${getNextPrayerName(targetTime!)}"
            : getNextPrayerName(targetTime!);
      });
    });
  }

  String getNextPrayerName(DateTime time) {
    final prayers = {
      "الفجر": prayerTimes?.fajr,
      "الشروق": prayerTimes?.sunrise,
      "الظهر": prayerTimes?.dhuhr,
      "العصر": prayerTimes?.asr,
      "المغرب": prayerTimes?.maghrib,
      "العشاء": prayerTimes?.isha,
    };
    for (var entry in prayers.entries) {
      if (entry.value?.hour == time.hour &&
          entry.value?.minute == time.minute) {
        return entry.key;
      }
    }
    return " للصلاة";
  }

  String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
        Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
        child: AppBar(
          leading:  CupertinoNavigationBarBackButton(
            color: Theme.of(context).brightness == Brightness.dark ?Colors.white:Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "مواقيت الصلاة",
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            children: [
              Text(
                nextPrayer.isNotEmpty ? nextPrayer : "جارٍ حساب الصلاة التالية...",
                style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp),
              ),
              Text(
                remainingTimeText,
                style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
              const SizedBox(height: 20),
              if (prayerTimes != null)
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: 6, // عدد الصلوات
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
                        prayerTimes!.fajr,
                        prayerTimes!.sunrise,
                        prayerTimes!.dhuhr,
                        prayerTimes!.asr,
                        prayerTimes!.maghrib,
                        prayerTimes!.isha
                      ];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prayerNames[index],
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('h:mm a').format(prayerTimesList[index]),
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
