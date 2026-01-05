import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SystemControlService {
  static final SystemControlService _instance = SystemControlService._internal();
  factory SystemControlService() => _instance;
  SystemControlService._internal();

  final _supabase = Supabase.instance.client;
  static const String _quoteCacheKey = 'cached_daily_quote';

  /// 🛠️ Check if Maintenance Mode is active
  Future<bool> isMaintenanceModeActive() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'maintenance_mode')
          .maybeSingle();
      
      return response != null && response['value'] == 'true';
    } catch (e) {
      return false; // Fail safe
    }
  }

  /// 🎮 Get All Feature Statuses (Active/Maintenance/Hidden)
  Future<Map<String, String>> getFeatureStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_feature_statuses';
    
    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'like', 'section_%');

      if (response != null && response is List) {
        final Map<String, String> statuses = {};
        for (var item in response) {
          final String key = item['key'].toString().replaceFirst('section_', '').replaceFirst('_status', '');
          statuses[key] = item['value'].toString();
        }
        await prefs.setString(cacheKey, jsonEncode(statuses));
        return statuses;
      }
    } catch (e) {
      print('Error fetching feature statuses: $e');
    }

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// 📖 Get Quote of the Day with Offline Fallback
  Future<String> getQuoteOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'quote_of_the_day')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        final quote = response['value'] as String;
        await prefs.setString(_quoteCacheKey, quote);
        return quote;
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }
    // Fallback to cache or hardcoded default
    return prefs.getString(_quoteCacheKey) ?? 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';
  }

  /// 📢 Get News Marquee Metadata
  Future<Map<String, String>?> getNewsMarquee() async {
    final prefs = await SharedPreferences.getInstance();
    const String newsKey = 'cached_news_marquee';
    const String labelKey = 'cached_news_label';
    const String typeKey = 'cached_news_type';

    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in', '("news_marquee", "news_marquee_label", "news_marquee_type")');

      if (response != null && response is List) {
        final data = response as List;
        final news = _findValue(data, 'news_marquee');
        final label = _findValue(data, 'news_marquee_label') ?? 'تنبيه عاجل';
        final type = _findValue(data, 'news_marquee_type') ?? 'urgent';

        if (news != null) {
          await prefs.setString(newsKey, news);
          await prefs.setString(labelKey, label);
          await prefs.setString(typeKey, type);
          return {'text': news, 'label': label, 'type': type};
        }
      }
    } catch (e) {
      print('Error fetching news metadata: $e');
    }

    final cachedNews = prefs.getString(newsKey);
    if (cachedNews != null) {
      return {
        'text': cachedNews,
        'label': prefs.getString(labelKey) ?? 'تنبيه عاجل',
        'type': prefs.getString(typeKey) ?? 'urgent',
      };
    }
    return null;
  }

  String? _findValue(List data, String key) {
    try {
      return data.firstWhere((e) => e['key'] == key)['value'];
    } catch (_) {
      return null;
    }
  }

  /// 🖼️ Get Active Banners
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await _supabase
          .from('banners')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching banners: $e');
    }
    return [];
  }

  /// 📝 Log Error to Supabase
  Future<void> logError(String message, String? stackTrace) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> info = {};
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info = {
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'brand': androidInfo.brand,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info = {
          'model': iosInfo.utsname.machine,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      }

      final packageInfo = await PackageInfo.fromPlatform();
      info['app_version'] = packageInfo.version;

      await _supabase.from('error_logs').insert({
        'message': message,
        'stack_trace': stackTrace ?? 'No stack trace',
        'device_info': info,
      });
    } catch (e) {
      print('Failed to log error to Supabase: $e');
    }
  }

  /// 📢 Get Broadcast Message
  Future<Map<String, String>?> getBroadcastMessage() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in', '("broadcast_message", "broadcast_id", "broadcast_active")');

      if (response != null && response is List) {
        final data = response as List;
        final active = _findValue(data, 'broadcast_active') == 'true';
        final message = _findValue(data, 'broadcast_message');
        final id = _findValue(data, 'broadcast_id');

        if (active && message != null && message.isNotEmpty) {
          return {'message': message, 'id': id ?? '0'};
        }
      }
    } catch (e) {
      print('Error fetching broadcast: $e');
    }
    return null;
  }

  /// 🎨 Get Primary Theme Color
  Future<String?> getThemePrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_primary_color';
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'primary_hex_color')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        final color = response['value'] as String;
        await prefs.setString(cacheKey, color);
        return color;
      } else {
        await prefs.remove(cacheKey); // Clear cache to revert to original
        return null;
      }
    } catch (e) {
      print('Error fetching theme color: $e');
    }
    return prefs.getString(cacheKey);
  }

  /// 🎯 Log Feature Usage (Analytics)
  Future<void> logFeatureUsage(String featureId) async {
    try {
      await _supabase.from('feature_usage').insert({
        'feature_name': featureId,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (e) {
      // Sliently fail for analytics
    }
  }
}
