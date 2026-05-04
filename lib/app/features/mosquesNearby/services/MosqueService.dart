import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/MosqueModel.dart';
import 'package:muslimdaily/app/core/utils/log.dart';

class MosqueService {
  static const List<String> overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://z.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get unique device identifier
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      log('MosqueService', msg: 'Error getting device ID', error: e);
    }
    return 'unknown';
  }

  /// Fetch nearby mosques using both Overpass API and Supabase
  Future<List<Mosque>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    try {
      // Fetch both in parallel
      final results = await Future.wait([
        _fetchOSMMosques(latitude, longitude, radiusMeters),
        _fetchUserMosques(latitude, longitude),
      ]);

      final osmMosques = results[0];
      final userMosques = results[1];

      // Combine and filter user mosques by distance (Supabase query doesn't do radius easily without PostGIS)
      final List<Mosque> combined = [...osmMosques];

      for (var userMosque in userMosques) {
        if (userMosque.distance * 1000 <= radiusMeters) {
          combined.add(userMosque);
        }
      }

      // Sort by distance
      combined.sort((a, b) => a.distance.compareTo(b.distance));

      return combined;
    } catch (e) {
      log('MosqueService', msg: 'Error fetching combined mosques', error: e);
      return [];
    }
  }

  /// Fetch nearby mosques using Overpass API with fallback mirrors
  Future<List<Mosque>> _fetchOSMMosques(
      double latitude, double longitude, int radiusMeters) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  node["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center;
''';

    for (String mirrorUrl in overpassMirrors) {
      try {
        final response = await http.post(
          Uri.parse(mirrorUrl),
          headers: {
            'User-Agent': 'RafiqElmuslimApp/2.0 (Contact: support@rafiq.com)',
            'Accept-Charset': 'utf-8',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          final elements = data['elements'] as List;

          List<Mosque> mosques = [];

          for (var element in elements) {
            try {
              // Handle center for ways and relations
              if ((element['type'] == 'way' || element['type'] == 'relation') &&
                  element['center'] != null) {
                element['lat'] = element['center']['lat'];
                element['lon'] = element['center']['lon'];
              }

              if (element['lat'] == null || element['lon'] == null) continue;

              final mosque =
                  Mosque.fromOverpassNode(element, latitude, longitude);
              mosques.add(mosque);
            } catch (e) {
              log('MosqueService', msg: 'Error parsing mosque element', error: e);
            }
          }
          return mosques;
        } else if (response.statusCode == 429) {
          log('MosqueService', msg: 'Rate limited by mirror: $mirrorUrl');
          continue; // Try next mirror
        }
      } catch (e) {
        log('MosqueService', msg: 'Error fetching from mirror: $mirrorUrl', error: e);
        // Continue to next mirror
      }
    }

    return [];
  }

  /// Fetch mosques added by users from Supabase
  Future<List<Mosque>> _fetchUserMosques(double lat, double lon) async {
    try {
      final response = await _supabase.from('user_mosques').select();
      return (response as List)
          .map((m) => Mosque.fromSupabase(m, lat, lon))
          .toList();
    } catch (e) {
      log('MosqueService', msg: 'Error fetching user mosques', error: e);
      return [];
    }
  }

  /// Add a new mosque to Supabase
  Future<bool> addUserMosque({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final deviceId = await getDeviceId();
      await _supabase.from('user_mosques').insert({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'device_id': deviceId,
      });
      return true;
    } catch (e) {
      log('MosqueService', msg: 'Error adding user mosque', error: e);
      return false;
    }
  }

  /// Update an existing user mosque in Supabase
  Future<bool> updateUserMosque({
    required String id,
    required String name,
    required String address,
  }) async {
    try {
      await _supabase.from('user_mosques').update({
        'name': name,
        'address': address,
      }).eq('id', id);
      return true;
    } catch (e) {
      log('MosqueService', msg: 'Error updating user mosque', error: e);
      return false;
    }
  }

  /// Delete a user mosque from Supabase
  Future<bool> deleteUserMosque(String id) async {
    try {
      await _supabase.from('user_mosques').delete().eq('id', id);
      return true;
    } catch (e) {
      log('MosqueService', msg: 'Error deleting user mosque', error: e);
      return false;
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
