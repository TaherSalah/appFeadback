import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<Map<String, String>?> getAddressFromLatLng(
      double lat, double lng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, lng, localeIdentifier: 'ar');
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return {
          'city': place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Unknown',
          'country': place.country ?? 'Unknown',
        };
      }
    } catch (e) {
      log('Error in reverse geocoding: $e', name: 'LocationService');
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
