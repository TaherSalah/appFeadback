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

import '../../core/shard/widgets/def_text_widget.dart';





import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui' as ui;

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
    final duration = prayerTime.difference(now);

    if (duration.isNegative) {
      // يعني الوقت فات بالفعل
      print("وقت $prayerName فات خلاص");
      return;
    }

    // نعمل Timer لحد ما ييجي وقت الصلاة
    Future.delayed(duration, () {
      playAdhanSound(prayerTime, prayerName);
    });

    print("هيشتغل أذان $prayerName بعد ${duration.inMinutes} دقيقة");
  }
  // void scheduleAdhan(DateTime prayerTime, String prayerName) {
  //   // ضبط وقت الاختبار (الآن)
  //   final now = DateTime.now();
  //   final duration = Duration(seconds: 0); // يتم تشغيل الأذان فورًا
  //
  //   // نعمل Timer لحد ما ييجي وقت الصلاة
  //   Future.delayed(duration, () {
  //     playAdhanSound(prayerTime, prayerName);  // شغل الصوت مباشرة عند الاختبار
  //   });
  //
  //   print("هيشتغل أذان $prayerName الآن مباشرة");
  // }

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
        Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
        child: AppBar(
          leading: const CupertinoNavigationBarBackButton(
            color: Colors.black,
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
      // backgroundColor: AppStyle.bgColors,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            children: [
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
                                child: TextDefaultWidget(
                                  textAlign: TextAlign.right,
                                  title: country,
                                  fontSize: 12.5,
                                ),
                              );
                            }).toList(),
                            value: selectedCountry,
                            onChanged: (value) {
                              setState(() {
                                selectedCountry = value!;
                                cities = countries[selectedCountry!] ?? {};
                                selectedCity = cities.keys.first;
                                calculatePrayerTimes();
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppStyle.scondColors, width: 1.5),
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              width: MediaQuery.of(context).size.width / 1.2,
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              overlayColor: WidgetStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ), // Use MaterialStateProperty
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                color: const Color(0xfffaedcd),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
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
                            items: cities.keys.map((cities) {
                              return DropdownMenuItem(
                                value: cities,
                                child: TextDefaultWidget(
                                  title: cities,
                                  fontSize: 12.5,
                                ),
                              );
                            }).toList(),
                            value: selectedCity,
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value!;
                                calculatePrayerTimes();
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppStyle.scondColors, width: 1.5),
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              width: MediaQuery.of(context).size.width / 1.2,
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              overlayColor: WidgetStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ), // Use MaterialStateProperty
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                color: const Color(0xfffaedcd),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedWrapper(
                type: UiAnimationType.slideOpacityLoop,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 1.8,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                    color: AppStyle.primColors,
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
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.sizeOf(context).width >
                                      600
                                      ? 14.sp
                                      : 16.sp),
                            )
                                : const Center(
                              child: CircularProgressIndicator(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              remainingTimeText,
                              style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.sizeOf(context).width > 600
                                      ? 14.sp
                                      : 16.sp),
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
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: prayerTimes != null
                        ? 6
                        : 0, // عدد العناصر في Grid (6 صلوات)
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
                      final iqamaTime = getIqamaTime(
                          prayerNames[index], prayerTimesList[index]);
                      final isNext = nextPrayer.contains(prayerNames[index]);
                      return Card(
                        color: isNext
                            ? AppStyle.textColors
                            : CupertinoColors.systemBackground,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.sizeOf(context).width > 600
                                  ? 8
                                  : 13,
                              horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prayerNames[index],
                                style: GoogleFonts.cairo(
                                    color: isNext ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp),
                              ),
                              Text(
                                DateFormat('h:mm a')
                                    .format(prayerTimesList[index]),
                                style: GoogleFonts.cairo(
                                    color: isNext ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}

