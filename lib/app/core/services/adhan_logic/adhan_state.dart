import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================================
// Constants for GetStorage keys
// ======================================================================
const String PRAYER_TIME = 'PRAYER_TIME';
const String PRAYER_TIME_DATE = 'PRAYER_TIME_DATE';
const String CURRENT_LOCATION = 'CURRENT_LOCATION';
const String SHAFI = 'SHAFI';
const String HIGH_LATITUDE_RULE = 'HIGH_LATITUDE_RULE';
const String AUTO_CALCULATION = 'AUTO_CALCULATION';
const String ADHAN_PATH = 'ADHAN_PATH';
const String ADHAN_PATH_FAJIR = 'ADHAN_PATH_FAJIR';
const String MONTHLY_PRAYER_DATA = 'MONTHLY_PRAYER_DATA_v2';
const String MONTHLY_CACHE_DATE = 'MONTHLY_CACHE_DATE_v2';
const String MONTHLY_CACHE_LOCATION = 'MONTHLY_CACHE_LOCATION_v2';

const allowedMaxAdjustment = 30;
const allowedMinAdjustment = -30;

// ======================================================================
// OurPrayerAdjustments
// ======================================================================
class OurPrayerAdjustments extends PrayerAdjustments {
  int midnight = 0;
  int lastThird = 0;

  OurPrayerAdjustments({
    super.fajr = 0,
    super.sunrise = 0,
    super.dhuhr = 0,
    super.asr = 0,
    super.maghrib = 0,
    super.isha = 0,
    this.midnight = 0,
    this.lastThird = 0,
  });

  static Future<OurPrayerAdjustments> fromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return OurPrayerAdjustments(
      fajr: prefs.getInt('fajr_offset') ?? 0,
      sunrise: prefs.getInt('sunrise_offset') ?? 0,
      dhuhr: prefs.getInt('dhuhr_offset') ?? 0,
      asr: prefs.getInt('asr_offset') ?? 0,
      maghrib: prefs.getInt('maghrib_offset') ?? 0,
      isha: prefs.getInt('isha_offset') ?? 0,
      // Note: midnight and lastThird aren't in MainController yet, keeping them as 0 or separate keys
      midnight: prefs.getInt('midnight_offset') ?? 0,
      lastThird: prefs.getInt('last_third_offset') ?? 0,
    );
  }

  factory OurPrayerAdjustments.fromJson(Map<String, dynamic> json) {
    return OurPrayerAdjustments(
      fajr: json['fajr'] ?? 0,
      sunrise: json['sunrise'] ?? 0,
      dhuhr: json['dhuhr'] ?? 0,
      asr: json['asr'] ?? 0,
      maghrib: json['maghrib'] ?? 0,
      isha: json['isha'] ?? 0,
      midnight: json['midnight'] ?? 0,
      lastThird: json['lastThird'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'midnight': midnight,
      'lastThird': lastThird,
    };
  }
}

// ======================================================================
// AdhanState
// ======================================================================
class AdhanState {
  final box = GetStorage();

  PrayerTimes? prayerTimes;
  String nextPrayerTime = '';
  DateTime get now => DateTime.now();
  RxString countdownTime = ''.obs;
  SunnahTimes? sunnahTimes;
  late Coordinates coordinates;
  late DateComponents dateComponents;
  late CalculationParameters params;
  RxDouble timeProgress = 0.0.obs;
  Timer? timer;
  RxString fajrTime = ''.obs;
  RxString sunriseTime = ''.obs;
  RxString dhuhrTime = ''.obs;
  RxString asrTime = ''.obs;
  RxString maghribTime = ''.obs;
  RxString ishaTime = ''.obs;
  RxString lastThirdTime = ''.obs;
  RxString midnightTime = ''.obs;
  bool isHanafi = true;
  RxInt highLatitudeRuleIndex = 0.obs;
  RxBool twilightAngle = false.obs;
  RxBool middleOfTheNight = true.obs;
  RxBool seventhOfTheNight = false.obs;
  PrayerTimes? prayerTimesNow;
  RxBool autoCalculationMethod = true.obs;
  RxString calculationMethodString = 'أم القرى'.obs;
  RxString selectedCountry = 'Saudi Arabia'.obs;
  List<String> countries = [];
  RxInt prohibitionTimesIndex = 0.obs;
  RxBool isPrayerTimesInitialized = false.obs;
  RxBool isLoadingPrayerData = false.obs;
  Rx<Color> backgroundColor = const Color(0xffB8E0EA).obs;
  var selectedDate = DateTime.now();
  OurPrayerAdjustments adjustments = OurPrayerAdjustments();

  // Selected-date prayer times
  PrayerTimes? selectedDatePrayerTimes;
  SunnahTimes? selectedDateSunnahTimes;
  RxString selectedDateFajrTime = ''.obs;
  RxString selectedDateSunriseTime = ''.obs;
  RxString selectedDateDhuhrTime = ''.obs;
  RxString selectedDateAsrTime = ''.obs;
  RxString selectedDateMaghribTime = ''.obs;
  RxString selectedDateIshaTime = ''.obs;
  RxString selectedDateLastThirdTime = ''.obs;
  RxString selectedDateMidnightTime = ''.obs;
  String location = '';
  
  // Global Offsets (Admin defined)
  int globalFajr = 0;
  int globalSunrise = 0;
  int globalDhuhr = 0;
  int globalAsr = 0;
  int globalMaghrib = 0;
  int globalIsha = 0;

  /// ---- Serialization (for daily cache) ----

  Map<String, dynamic> toJson() {
    if (prayerTimesNow == null || sunnahTimes == null) return {};
    return {
      'fajr': prayerTimesNow!.fajr.toIso8601String(),
      'sunrise': prayerTimesNow!.sunrise.toIso8601String(),
      'dhuhr': prayerTimesNow!.dhuhr.toIso8601String(),
      'asr': prayerTimesNow!.asr.toIso8601String(),
      'maghrib': prayerTimesNow!.maghrib.toIso8601String(),
      'isha': prayerTimesNow!.isha.toIso8601String(),
      'middleOfTheNight': sunnahTimes!.middleOfTheNight.toIso8601String(),
      'lastThirdOfTheNight': sunnahTimes!.lastThirdOfTheNight.toIso8601String(),
      'lat': coordinates.latitude,
      'lng': coordinates.longitude,
      'adjustments': adjustments.toJson(),
      'isHanafi': isHanafi,
      'highLatitudeRuleIndex': highLatitudeRuleIndex.value,
    };
  }

  bool fromJson(Map<String, dynamic> json) {
    try {
      final lat = (json['lat'] as num?)?.toDouble();
      final lng = (json['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return false;
      coordinates = Coordinates(lat, lng);

      // Parse fajr only to reconstruct DateComponents
      final fajr = DateTime.parse(json['fajr']);

      // Reconstruct params minimally
      params = CalculationMethod.egyptian.getParameters();
      final madhabIndex = json['madhabIndex'] ?? 0;
      isHanafi = madhabIndex == 1; 
      highLatitudeRuleIndex.value = json['highLatitudeRuleIndex'] ?? 0;
      if (json['adjustments'] != null) {
        adjustments = OurPrayerAdjustments.fromJson(json['adjustments']);
      }

      dateComponents = DateComponents(fajr.year, fajr.month, fajr.day);
      prayerTimesNow = PrayerTimes(coordinates, dateComponents, params);
      sunnahTimes = SunnahTimes(prayerTimesNow!);
      prayerTimes = prayerTimesNow;
      return true;
    } catch (_) {
      return false;
    }
  }
}
