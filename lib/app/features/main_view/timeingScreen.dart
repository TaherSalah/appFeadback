import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../core/shard/constanc/app_style.dart';
import '../../core/shard/widgets/def_text_widget.dart';
import '../../core/shard/widgets/ui_animations.dart';

class TimingScreen extends StatefulWidget {
  const TimingScreen({super.key});

  @override
  State<TimingScreen> createState() => _TimingScreenState();
}

class _TimingScreenState extends State<TimingScreen> {
  Map<String, dynamic> countries = {}; // لخزن الدول
  Map<String, dynamic> cities = {}; // لخزن المدن بناءً على الدولة
  String? selectedCountry; // لتخزين الدولة المختارة
  String? selectedCity; // لتخزين المدينة المختارة
  PrayerTimes? prayerTimes;
  double progressValue = 0.0;
  String remainingTimeText = "";
  String nextPrayer = "";
  Timer? countdownTimer;
  bool isIqamaCountdown = false;
  DateTime? previousTime;
  DateTime? targetTime;
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
      final now = DateTime.now();
      final total = to.difference(previousTime!).inSeconds;
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
        progressValue = progress.clamp(0.0, 1.0);
        remainingTimeText =
            "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
        nextPrayer = isIqama
            ? "الإقامة${getNextPrayerName(targetTime!)}"
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

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              overlayColor: MaterialStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ), // Use MaterialStateProperty
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                color: const Color(0xfffaedcd),

                                // Set the background color for the dropdown menu
                                borderRadius: BorderRadius.circular(
                                    10.0), // Optional: rounded corners
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
                              overlayColor: MaterialStateProperty.all(
                                Colors.grey.withOpacity(0.5),
                              ), // Use MaterialStateProperty
                              height: 50,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 1,
                              decoration: BoxDecoration(
                                color: const Color(0xfffaedcd),

                                // Set the background color for the dropdown menu
                                borderRadius: BorderRadius.circular(
                                    10.0), // Optional: rounded corners
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
                      // child: Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       prayerNames[index],
                      //       style: GoogleFonts.cairo(
                      //           color: const Color(0xffbc6c25),
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 17.sp),
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Text(
                      //       DateFormat('h:mm')
                      //           .format(prayerTimesList[index]),
                      //       style: GoogleFonts.cairo(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 18.sp),
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Text(
                      //       "الإقامة: ${DateFormat('h:mm').format(iqamaTime)}", // استخدام تنسيق 24 ساعة
                      //       style: GoogleFonts.cairo(
                      //           color: Colors.grey,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 10.sp),
                      //     ),
                      //   ],
                      // ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              nextPrayer,
                              style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              remainingTimeText,
                              style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp),
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
                // Expanded(
                //   child: ListView(
                //     children: [
                //       prayerRow("الفجر", prayerTimes!.fajr),
                //       prayerRow("الشروق", prayerTimes!.sunrise),
                //       prayerRow("الظهر", prayerTimes!.dhuhr),
                //       prayerRow("العصر", prayerTimes!.asr),
                //       prayerRow("المغرب", prayerTimes!.maghrib),
                //       prayerRow("العشاء", prayerTimes!.isha),
                //     ],
                //   ),
                // )
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
                        color:
                            isNext ? AppStyle.textColors : AppStyle.scondColors,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                images[index],
                                width: 35,
                                color: isNext ? Colors.white : Colors.black,
                              ),
                              Text(
                                prayerNames[index],
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
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

  Widget prayerRow(String title, DateTime adhanTime) {
    final iqama = getIqamaTime(title, adhanTime);
    final isNext = nextPrayer.contains(title);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: isNext ? 6 : 3,
      color: isNext ? Colors.green.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        side: isNext
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          isNext ? Icons.access_alarm : Icons.access_time,
          color: isNext ? Colors.green : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isNext ? Colors.green[800] : Colors.black,
          ),
        ),
        subtitle: iqama.year == 0
            ? null
            : Text("الإقامة: ${formatTime(iqama)}",
                style: const TextStyle(fontSize: 14)),
        trailing: Text(formatTime(adhanTime),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isNext ? Colors.green : Colors.black)),
      ),
    );
  }
}
