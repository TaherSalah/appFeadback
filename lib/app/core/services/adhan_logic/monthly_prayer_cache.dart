import 'dart:convert';
import 'dart:developer' show log;
import 'package:adhan/adhan.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'adhan_state.dart';

// ======================================================================
// DayPrayerTimes
// ======================================================================
class DayPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime midnight;
  final DateTime lastThird;

  DayPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.lastThird,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'fajr': fajr.toIso8601String(),
        'sunrise': sunrise.toIso8601String(),
        'dhuhr': dhuhr.toIso8601String(),
        'asr': asr.toIso8601String(),
        'maghrib': maghrib.toIso8601String(),
        'isha': isha.toIso8601String(),
        'midnight': midnight.toIso8601String(),
        'lastThird': lastThird.toIso8601String(),
      };

  factory DayPrayerTimes.fromJson(Map<String, dynamic> json) => DayPrayerTimes(
        date: DateTime.parse(json['date']),
        fajr: DateTime.parse(json['fajr']),
        sunrise: DateTime.parse(json['sunrise']),
        dhuhr: DateTime.parse(json['dhuhr']),
        asr: DateTime.parse(json['asr']),
        maghrib: DateTime.parse(json['maghrib']),
        isha: DateTime.parse(json['isha']),
        midnight: DateTime.parse(json['midnight']),
        lastThird: DateTime.parse(json['lastThird']),
      );
}

// ======================================================================
// MonthlyPrayerData
// ======================================================================
class MonthlyPrayerData {
  final int year;
  final int month;
  final Map<int, DayPrayerTimes> dailyTimes;
  final LatLng location;
  final DateTime calculatedAt;
  final CalculationParameters params;

  MonthlyPrayerData({
    required this.year,
    required this.month,
    required this.dailyTimes,
    required this.location,
    required this.calculatedAt,
    required this.params,
  });

  bool containsDate(DateTime date) =>
      date.year == year &&
      date.month == month &&
      dailyTimes.containsKey(date.day);

  DayPrayerTimes? getPrayerTimesForDay(DateTime date) {
    if (!containsDate(date)) return null;
    return dailyTimes[date.day];
  }

  Map<String, dynamic> toJson() {
    final dailyTimesJson = <String, dynamic>{};
    dailyTimes.forEach((day, times) {
      dailyTimesJson[day.toString()] = times.toJson();
    });
    return {
      'year': year,
      'month': month,
      'dailyTimes': dailyTimesJson,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude
      },
      'calculatedAt': calculatedAt.toIso8601String(),
      'params': {
        'fajrAngle': params.fajrAngle,
        'ishaAngle': params.ishaAngle,
        'madhab': params.madhab.toString(),
        'highLatitudeRule': params.highLatitudeRule.toString(),
      },
    };
  }

  factory MonthlyPrayerData.fromJson(Map<String, dynamic> json) {
    final dailyTimesJson = json['dailyTimes'] as Map<String, dynamic>;
    final dailyTimes = <int, DayPrayerTimes>{};
    dailyTimesJson.forEach((dayStr, timesJson) =>
        dailyTimes[int.parse(dayStr)] =
            DayPrayerTimes.fromJson(timesJson as Map<String, dynamic>));

    final locationJson = json['location'] as Map<String, dynamic>;
    final paramsJson = json['params'] as Map<String, dynamic>;

    final params = CalculationParameters(
      fajrAngle: paramsJson['fajrAngle']?.toDouble() ?? 18.0,
    )..ishaAngle = paramsJson['ishaAngle']?.toDouble() ?? 17.0;

    final madhabStr = paramsJson['madhab'] ?? 'Madhab.shafi';
    params.madhab = madhabStr.contains('hanafi') ? Madhab.hanafi : Madhab.shafi;

    final ruleStr = paramsJson['highLatitudeRule'] ??
        'HighLatitudeRule.middle_of_the_night';
    params.highLatitudeRule = HighLatitudeRule.values.firstWhere(
      (rule) => rule.toString() == ruleStr,
      orElse: () => HighLatitudeRule.middle_of_the_night,
    );

    return MonthlyPrayerData(
      year: json['year'],
      month: json['month'],
      dailyTimes: dailyTimes,
      location: LatLng(
        locationJson['latitude']?.toDouble() ?? 0.0,
        locationJson['longitude']?.toDouble() ?? 0.0,
      ),
      calculatedAt: DateTime.parse(json['calculatedAt']),
      params: params,
    );
  }
}

// ======================================================================
// MonthlyPrayerCache
// ======================================================================
class MonthlyPrayerCache {
  static const String _tag = 'MonthlyPrayerCache';
  static final GetStorage _storage = GetStorage();

  static Future<void> saveMonthlyPrayerData({
    required LatLng location,
    required CalculationParameters params,
    required DateTime month,
  }) async {
    try {
      log('Calculating monthly prayer data for ${month.month}/${month.year}',
          name: _tag);
      final monthlyData = await _calculateMonthlyPrayerTimes(
          location: location, params: params, month: month);

      _storage.write(MONTHLY_PRAYER_DATA, jsonEncode(monthlyData.toJson()));
      _storage.write(MONTHLY_CACHE_DATE, DateTime.now().toIso8601String());
      _storage.write(MONTHLY_CACHE_LOCATION, {
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
      log('Monthly prayer data saved successfully', name: _tag);
    } catch (e) {
      log('Error saving monthly prayer data: $e', name: _tag);
    }
  }

  static bool isMonthlyDataValid({required LatLng currentLocation}) {
    try {
      final storedData = _storage.read(MONTHLY_PRAYER_DATA);
      final storedDate = _storage.read(MONTHLY_CACHE_DATE);
      final storedLocation = _storage.read(MONTHLY_CACHE_LOCATION);

      if (storedData == null || storedDate == null || storedLocation == null) {
        return false;
      }
      if (!_isLocationValid(storedLocation, currentLocation)) return false;

      final monthlyData = MonthlyPrayerData.fromJson(
          jsonDecode(storedData) as Map<String, dynamic>);
      return monthlyData.containsDate(DateTime.now());
    } catch (e) {
      log('Error validating monthly cache: $e', name: _tag);
      return false;
    }
  }

  static DayPrayerTimes? getPrayerTimesForDate(DateTime date) {
    try {
      final storedData = _storage.read(MONTHLY_PRAYER_DATA);
      if (storedData == null) return null;
      final monthlyData = MonthlyPrayerData.fromJson(
          jsonDecode(storedData) as Map<String, dynamic>);
      return monthlyData.getPrayerTimesForDay(date);
    } catch (e) {
      log('Error getting prayer times for date: $e', name: _tag);
      return null;
    }
  }

  static Future<MonthlyPrayerData> _calculateMonthlyPrayerTimes({
    required LatLng location,
    required CalculationParameters params,
    required DateTime month,
  }) async {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dailyTimes = <int, DayPrayerTimes>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateComponents = DateComponents.from(date);
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
      final sunnahTimes = SunnahTimes(prayerTimes);

      dailyTimes[day] = DayPrayerTimes(
        date: date,
        fajr: prayerTimes.fajr,
        sunrise: prayerTimes.sunrise,
        dhuhr: prayerTimes.dhuhr,
        asr: prayerTimes.asr,
        maghrib: prayerTimes.maghrib,
        isha: prayerTimes.isha,
        midnight: sunnahTimes.middleOfTheNight,
        lastThird: sunnahTimes.lastThirdOfTheNight,
      );
    }

    return MonthlyPrayerData(
      year: month.year,
      month: month.month,
      dailyTimes: dailyTimes,
      location: location,
      calculatedAt: DateTime.now(),
      params: params,
    );
  }

  static bool _isLocationValid(dynamic storedLocation, LatLng currentLocation) {
    try {
      if (storedLocation is! Map) return false;
      final storedLat = storedLocation['latitude']?.toDouble();
      final storedLng = storedLocation['longitude']?.toDouble();
      if (storedLat == null || storedLng == null) return false;
      const threshold = 0.01;
      return (storedLat - currentLocation.latitude).abs() <= threshold &&
          (storedLng - currentLocation.longitude).abs() <= threshold;
    } catch (_) {
      return false;
    }
  }

  static void clearMonthlyCache() {
    _storage.remove(MONTHLY_PRAYER_DATA);
    _storage.remove(MONTHLY_CACHE_DATE);
    _storage.remove(MONTHLY_CACHE_LOCATION);
  }
}
