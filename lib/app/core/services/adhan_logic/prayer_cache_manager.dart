import 'dart:convert';
import 'dart:developer' show log;
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'adhan_state.dart';

/// مدير التخزين المؤقت اليومي لأوقات الصلاة
class PrayerCacheManager {
  static const String _tag = 'PrayerCacheManager';
  static final GetStorage _storage = GetStorage();

  static bool isCacheValid({LatLng? currentLocation}) {
    try {
      final storedDate = _storage.read(PRAYER_TIME_DATE);
      final storedPrayerTimes = _storage.read(PRAYER_TIME);
      final storedLocation = _storage.read(CURRENT_LOCATION);

      if (storedDate == null || storedPrayerTimes == null) return false;
      if (!_isDateValid(storedDate)) return false;
      if (currentLocation != null &&
          !_isLocationValid(storedLocation, currentLocation)) {
        return false;
      }

      return true;
    } catch (e) {
      log('Error checking cache validity: $e', name: _tag);
      return false;
    }
  }

  static bool _isDateValid(String storedDate) {
    try {
      final lastUpdate = DateTime.parse(storedDate);
      final now = DateTime.now();
      return lastUpdate.year == now.year &&
          lastUpdate.month == now.month &&
          lastUpdate.day == now.day;
    } catch (_) {
      return false;
    }
  }

  static bool _isLocationValid(dynamic storedLocation, LatLng currentLocation) {
    try {
      if (storedLocation is! Map) return false;
      final locationMap = Map<String, dynamic>.from(storedLocation);
      final storedLat = locationMap['latitude']?.toDouble();
      final storedLng = locationMap['longitude']?.toDouble();
      if (storedLat == null || storedLng == null) return false;
      const threshold = 0.01;
      return (storedLat - currentLocation.latitude).abs() <= threshold &&
          (storedLng - currentLocation.longitude).abs() <= threshold;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic>? getCachedPrayerData() {
    try {
      final storedData = _storage.read(PRAYER_TIME);
      if (storedData != null) {
        return jsonDecode(storedData) as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error getting cached data: $e', name: _tag);
    }
    return null;
  }

  static void savePrayerData(Map<String, dynamic> data, LatLng? location) {
    try {
      _storage.write(PRAYER_TIME, jsonEncode(data));
      _storage.write(PRAYER_TIME_DATE, DateTime.now().toIso8601String());
      if (location != null) {
        final existing = _storage.read(CURRENT_LOCATION);
        final merged = (existing is Map)
            ? Map<String, dynamic>.from(existing)
            : <String, dynamic>{};
        merged['latitude'] = location.latitude;
        merged['longitude'] = location.longitude;
        _storage.write(CURRENT_LOCATION, merged);
      }
    } catch (e) {
      log('Error saving prayer data: $e', name: _tag);
    }
  }

  static void clearCache() {
    _storage.remove(PRAYER_TIME_DATE);
    _storage.remove(PRAYER_TIME);
  }

  static LatLng? getStoredLocation() {
    try {
      final storedLocation = _storage.read(CURRENT_LOCATION);
      if (storedLocation is Map &&
          storedLocation.containsKey('latitude') &&
          storedLocation.containsKey('longitude')) {
        final locationMap = Map<String, dynamic>.from(storedLocation);
        return LatLng(
          locationMap['latitude']?.toDouble() ?? 0.0,
          locationMap['longitude']?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      log('Error getting stored location: $e', name: _tag);
    }
    return null;
  }

  static Map<String, dynamic> getCacheStats() {
    return {
      'hasData': _storage.hasData(PRAYER_TIME),
      'lastUpdate': _storage.read(PRAYER_TIME_DATE),
      'location': _storage.read(CURRENT_LOCATION),
      'isValid': isCacheValid(),
    };
  }
}
