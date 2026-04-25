import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import 'location_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final _supabase = Supabase.instance.client;
  final _deviceInfo = DeviceInfoPlugin();

  Future<void> logAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Get or Generate unique Device ID
      String? deviceId = prefs.getString('analytics_device_id');
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('analytics_device_id', deviceId);
      }

      // 2. Get Location Info
      final savedLocation = await LocationService().getSavedLocation();
      String country = savedLocation['country'] ?? 'Unknown';
      String city = savedLocation['city'] ?? 'Unknown';

      // 3. Fallback to IP Geolocation if unknown
      if (country == 'Unknown') {
        try {
          final response = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == 'success') {
              country = data['country'] ?? 'Unknown';
              city = data['city'] ?? 'Unknown';
              
              // Normalize common Arabic country names if they come in Arabic (though ip-api usually returns English)
              // But if we want consistency, we can map them here.
            }
          }
        } catch (e) {
          logger.e('IP Geo Fallback Error: $e');
        }
      }

      // 4. Get Device/App Info
      final packageInfo = await PackageInfo.fromPlatform();
      String os = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other');
      
      // 5. Send to Supabase
      await _supabase.from('app_usage').insert({
        'device_id': deviceId,
        'country': country,
        'city': city,
        'os': os,
        'app_version': packageInfo.version,
      });

    } catch (e) {
      // Fail silently to not disturb user
      logger.e('CoreAnalytics Error: $e');

    }
  }
}
