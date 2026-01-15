import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SystemControlService {
  static final SystemControlService _instance =
      SystemControlService._internal();
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
          final String key = item['key']
              .toString()
              .replaceFirst('section_', '')
              .replaceFirst('_status', '');
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
    return prefs.getString(_quoteCacheKey) ??
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';
  }

  /// 👁️ Check if Quote should be visible
  Future<bool> isQuoteVisible() async {
    final prefs = await SharedPreferences.getInstance();
    const String key = 'cached_quote_visible';

    try {
      // Fetch all settings and filter in Dart to be safe
      final response =
          await _supabase.from('app_settings').select('key, value');

      if (response != null && response is List) {
        // Broad check for any key that looks like a quote enable toggle
        final targetKeys = [
          'quote_enabled',
          'quote_visible',
          'show_quote',
          'is_quote_enabled',
          'quote_active'
        ];

        for (var item in response) {
          if (targetKeys.contains(item['key'].toString())) {
            final val = item['value'].toString().toLowerCase();
            // Explicit false/0 -> Hide
            if (val == 'false' || val == '0') {
              await prefs.setBool(key, false);
              return false;
            }
            // Explicit true/1 -> Show
            if (val == 'true' || val == '1') {
              await prefs.setBool(key, true);
              return true;
            }
          }
        }
      }
    } catch (e) {
      // If network fails, return cached value, defaulting to FALSE for safety
      return prefs.getBool(key) ?? false;
    }

    // Default to FALSE if no keys found.
    return prefs.getBool(key) ?? false;
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
          .filter('key', 'in',
              '("news_marquee", "news_marquee_label", "news_marquee_type", "news_active")');

      if (response != null && response is List) {
        final data = response as List;
        final active = _findValue(data, 'news_active') == 'true';
        final news = _findValue(data, 'news_marquee');
        final label = _findValue(data, 'news_marquee_label') ?? 'تنبيه عاجل';
        final type = _findValue(data, 'news_marquee_type') ?? 'urgent';

        if (active && news != null) {
          await prefs.setString(newsKey, news);
          await prefs.setString(labelKey, label);
          await prefs.setString(typeKey, type);
          return {'text': news, 'label': label, 'type': type};
        } else if (!active) {
          await prefs.remove(newsKey);
          return null;
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
          .filter('key', 'in',
              '("broadcast_message", "broadcast_id", "broadcast_active")');

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

  /// 🔗 Get Support Links (Facebook, WhatsApp, Stores)
  Future<Map<String, String>> getSupportLinks() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_support_links';

    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in',
              '("link_facebook", "link_whatsapp", "link_appstore", "link_playstore")');

      if (response != null && response is List) {
        final Map<String, String> links = {};
        for (var item in response) {
          links[item['key'].toString()] = item['value'].toString();
        }
        await prefs.setString(cacheKey, jsonEncode(links));
        return links;
      }
    } catch (e) {
      print('Error fetching support links: $e');
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

  /// 🕌 Get Global Prayer Offsets (Admin defined)
  Future<Map<String, int>> getGlobalPrayerOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_global_offsets';

    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in',
              '("prayer_offset_fajr", "prayer_offset_sunrise", "prayer_offset_dhuhr", "prayer_offset_asr", "prayer_offset_maghrib", "prayer_offset_isha")');

      if (response != null && response is List) {
        final Map<String, int> offsets = {};
        for (var item in response) {
          final key = item['key'].toString().replaceFirst('prayer_offset_', '');
          final value = int.tryParse(item['value'].toString()) ?? 0;
          offsets[key] = value;
        }
        await prefs.setString(cacheKey, jsonEncode(offsets));
        return offsets;
      }
    } catch (e) {
      print('Error fetching global offsets: $e');
    }

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((key, value) => MapEntry(key, int.parse(value.toString())));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// 📢 Get Social Media Banner Config
  Future<Map<String, dynamic>?> getSocialBannerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_social_banner_config';

    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in',
              '("social_banner_title", "social_banner_url", "social_banner_platform", "social_banner_active")');

      if (response != null && response is List && response.isNotEmpty) {
        final data = response as List;
        final title = _findValue(data, 'social_banner_title');
        final url = _findValue(data, 'social_banner_url');
        final platform = _findValue(data, 'social_banner_platform');
        final activeStr = _findValue(data, 'social_banner_active');

        final config = {
          'title': title,
          'url': url,
          'platform': platform,
          'isActive': activeStr == 'true',
        };

        await prefs.setString(cacheKey, jsonEncode(config));
        return config;
      }
    } catch (e) {
      print('Error fetching social banner config: $e');
    }

    // Fallback to cache
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return jsonDecode(cached) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
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
