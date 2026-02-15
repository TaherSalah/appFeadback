import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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

      // 3. Get Device/App Info
      final packageInfo = await PackageInfo.fromPlatform();
      String os = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other');
      
      // 4. Send to Supabase
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
