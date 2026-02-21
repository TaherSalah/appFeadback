import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  factory OurPrayerAdjustments.fromGetStorage() {
    final box = GetStorage();
    return OurPrayerAdjustments(
      fajr: box.read('ADJUSTMENT_FAJR') ?? 0,
      sunrise: box.read('ADJUSTMENT_SUNRISE') ?? 0,
      dhuhr: box.read('ADJUSTMENT_DHUHR') ?? 0,
      asr: box.read('ADJUSTMENT_ASR') ?? 0,
      maghrib: box.read('ADJUSTMENT_MAGHRIB') ?? 0,
      isha: box.read('ADJUSTMENT_ISHA') ?? 0,
      midnight: box.read('ADJUSTMENT_MIDNIGHT') ?? 0,
      lastThird: box.read('ADJUSTMENT_LAST_THIRD') ?? 0,
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
      params = CalculationMethod.umm_al_qura.getParameters();
      isHanafi = json['isHanafi'] ?? true;
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
