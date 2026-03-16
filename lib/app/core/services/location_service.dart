import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const String kCountryKey = 'selected_country';
  static const String kCityKey = 'selected_city';
  static const String kLatKey = 'latitude';
  static const String kLngKey = 'longitude';
  static const String kUseGPSKey = 'is_using_gps';

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> handlePermission() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    bool hasPermission = await handlePermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      log('Error getting current position: $e', name: 'LocationService');
      return null;
    }
  }

  /// يحاول أولاً Google Geocoding (يحتاج GMS).
  /// إذا فشل (مثل هواوي بدون GMS) يستخدم Nominatim (OpenStreetMap) كـ fallback.
  Future<Map<String, String>?> getAddressFromLatLng(
      double lat, double lng) async {
    // ── 1. محاولة Google Geocoding ──
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, lng, localeIdentifier: 'ar');
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final city = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
        final country = place.country;
        if (city != null && city.isNotEmpty) {
          log('Geocoding via Google: $country - $city', name: 'LocationService');
          return {'city': city, 'country': country ?? 'Unknown'};
        }
      }
    } catch (e) {
      log('Google geocoding failed (likely no GMS): $e', name: 'LocationService');
    }

    // ── 2. Fallback: Nominatim (OpenStreetMap) - يعمل بدون GMS ──
    return await _getAddressFromNominatim(lat, lng);
  }

  Future<Map<String, String>?> _getAddressFromNominatim(
      double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&accept-language=ar',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MuslimDailyApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Nominatim يعطي عدة أسماء، نأخذ أفضلها
          final city = address['city'] as String? ??
              address['town'] as String? ??
              address['county'] as String? ??
              address['state'] as String?;
          final country = address['country'] as String?;
          log('Geocoding via Nominatim: $country - $city', name: 'LocationService');
          if (city != null && city.isNotEmpty) {
            return {'city': city, 'country': country ?? 'Unknown'};
          }
        }
      }
    } catch (e) {
      log('Nominatim geocoding also failed: $e', name: 'LocationService');
    }
    return null;
  }

  Future<void> saveLocation({
    required double lat,
    required double lng,
    String? city,
    String? country,
    bool isGPS = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(kLatKey, lat);
    await prefs.setDouble(kLngKey, lng);
    await prefs.setBool(kUseGPSKey, isGPS);
    if (city != null) await prefs.setString(kCityKey, city);
    if (country != null) await prefs.setString(kCountryKey, country);
  }

  Future<Map<String, dynamic>> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lat': prefs.getDouble(kLatKey),
      'lng': prefs.getDouble(kLngKey),
      'city': prefs.getString(kCityKey),
      'country': prefs.getString(kCountryKey),
      'isGPS': prefs.getBool(kUseGPSKey) ?? false,
    };
  }
}
