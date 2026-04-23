import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';

class SystemControlService {
  static final SystemControlService _instance =
      SystemControlService._internal();
  factory SystemControlService() => _instance;
  SystemControlService._internal();

  final _supabase = Supabase.instance.client;
  static const String _quoteCacheKey = 'cached_daily_quote';
  static const MethodChannel _channel =
      MethodChannel('com.muslimdaily.app/system_control');

  /// 🛠️ Check if Maintenance Mode is active
  Future<bool> isMaintenanceModeActive() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'maintenance_mode')
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      return response != null && response['value'] == 'true';
    } catch (e) {
      return false; // Fail safe
    }
  }

  /// 🎮 Get All Feature Statuses (Active/Maintenance/Hidden) from app_features table
  Future<Map<String, String>> getFeatureStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'cached_feature_statuses';

    // 🏎️ Return cached data immediately if available
    final cached = prefs.getString(cacheKey);
    Map<String, String> cachedMap = {};
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        cachedMap =
            decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {}
    }

    // 🛡️ Provide default statuses if no cache is available (e.g., first run offline)
    if (cachedMap.isEmpty) {
      cachedMap = {
        'quranView': 'active',
        'azkar': 'active',
        'sebha': 'active',
        'khatmah': 'active',
        'zakat': 'active',
        'inheritance': 'active',
        'expiation': 'active',
        'wird': 'active',
        'radioView': 'active',
        'hadith': 'active',
        'mosques': 'active',
        'kids': 'active',
        'timing': 'active',
        'qibla': 'active',
        'fajr_alarm': 'active',
        'calendar': 'active',
        'settings': 'active',
        'news': 'hidden', // Default news to hidden if no data
        'banners': 'hidden',
      };
    }

    // 🛰️ Fetch in background and update cache
    _fetchAndCacheStatuses(cacheKey);

    return cachedMap;
  }

  Future<void> _fetchAndCacheStatuses(String cacheKey) async {
    try {
      final response = await _supabase
          .from('app_features')
          .select('feature_name, status')
          .timeout(const Duration(seconds: 10));

      if (response is List) {
        final Map<String, String> statuses = {};
        for (var item in response) {
          final String key = item['feature_name']?.toString() ?? '';
          final String value = item['status']?.toString() ?? 'active';
          if (key.isNotEmpty) {
            statuses[key] = value;
          }
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(statuses));
      }
    } catch (e) {
      logger.e('Error fetching feature statuses: $e');
    }
  }

  /// 📖 Get Quote of the Day with Offline Fallback
  Future<String> getQuoteOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedQuote = prefs.getString(_quoteCacheKey);

    // 🛰️ Trigger background fetch
    _fetchAndCacheQuote();

    return cachedQuote ?? 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';
  }

  Future<void> _fetchAndCacheQuote() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'quote_of_the_day')
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (response != null && response['value'] != null) {
        final quote = response['value'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_quoteCacheKey, quote);
      }
    } catch (e) {
      logger.e('Error fetching quote: $e');
    }
  }

  /// 👁️ Check if Quote should be visible
  Future<bool> isQuoteVisible() async {
    final prefs = await SharedPreferences.getInstance();
    const String key = 'cached_quote_visible';
    final cached = prefs.getBool(key) ?? false;

    // 🛰️ Trigger background fetch
    _fetchAndCacheQuoteVisibility(key);

    return cached;
  }

  Future<void> _fetchAndCacheQuoteVisibility(String cacheKey) async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .timeout(const Duration(seconds: 10));

      if (response is List) {
        final targetKeys = [
          'quote_enabled',
          'quote_visible',
          'show_quote',
          'is_quote_enabled',
          'quote_active'
        ];

        bool isVisible = false;
        for (var item in response) {
          if (targetKeys.contains(item['key'].toString())) {
            final val = item['value'].toString().toLowerCase();
            if (val == 'true' || val == '1') {
              isVisible = true;
            }
          }
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(cacheKey, isVisible);
      }
    } catch (e) {
      logger.e('Error fetching quote visibility: $e');
    }
  }

  /// 📢 Get News Marquee Metadata
  Future<Map<String, String>?> getNewsMarquee() async {
    final prefs = await SharedPreferences.getInstance();
    const String newsKey = 'cached_news_marquee';
    const String labelKey = 'cached_news_label';
    const String typeKey = 'cached_news_type';

    final cachedNews = prefs.getString(newsKey);
    if (cachedNews != null) {
      // 🛰️ Trigger background fetch
      _fetchAndCacheNews();
      return {
        'text': cachedNews,
        'label': prefs.getString(labelKey) ?? 'تنبيه عاجل',
        'type': prefs.getString(typeKey) ?? 'urgent',
      };
    }

    // If no cache, return null immediately but fetch for next time
    _fetchAndCacheNews();
    return null;
  }

  Future<void> _fetchAndCacheNews() async {
    final prefs = await SharedPreferences.getInstance();
    const String newsKey = 'cached_news_marquee';
    const String labelKey = 'cached_news_label';
    const String typeKey = 'cached_news_type';

    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .timeout(const Duration(seconds: 10));

      if (response is List) {
        final data = response as List;
        final newsActiveVal = _findValue(data, 'news_active')?.toLowerCase();
        final active = newsActiveVal == 'true' ||
            newsActiveVal == '1' ||
            newsActiveVal == 'active';

        final news = _findValue(data, 'news_marquee');
        final label = _findValue(data, 'news_marquee_label') ?? 'تنبيه عاجل';
        final type = _findValue(data, 'news_marquee_type') ?? 'urgent';

        if (active && news != null && news.trim().isNotEmpty) {
          await prefs.setString(newsKey, news);
          await prefs.setString(labelKey, label);
          await prefs.setString(typeKey, type);
        } else {
          await prefs.remove(newsKey);
        }
      }
    } catch (e) {
      logger.e('Error fetching news: $e');
    }
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
    final prefs = await SharedPreferences.getInstance();
    const String key = 'cached_banners';
    final cached = prefs.getString(key);

    _fetchAndCacheBanners(key);

    if (cached != null) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(cached));
      } catch (_) {}
    }
    return [];
  }

  Future<void> _fetchAndCacheBanners(String cacheKey) async {
    try {
      final response = await _supabase
          .from('banners')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      if (response is List) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(response));
      }
    } catch (e) {
      logger.e('Error fetching banners: $e');
    }
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
      logger.e('Failed to log error to Supabase: $e');
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

      if (response is List) {
        final data = response as List;
        final active = _findValue(data, 'broadcast_active') == 'true';
        final message = _findValue(data, 'broadcast_message');
        final id = _findValue(data, 'broadcast_id');

        if (active && message != null && message.isNotEmpty) {
          return {'message': message, 'id': id ?? '0'};
        }
      }
    } catch (e) {
      logger.e('Error fetching broadcast: $e');
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
      logger.e('Error fetching theme color: $e');
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

      if (response is List) {
        final Map<String, String> links = {};
        for (var item in response) {
          links[item['key'].toString()] = item['value'].toString();
        }
        await prefs.setString(cacheKey, jsonEncode(links));
        return links;
      }
    } catch (e) {
      logger.e('Error fetching support links: $e');
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

    // 🏎️ Return cached offsets immediately
    final cached = prefs.getString(cacheKey);
    Map<String, int> offsets = {};
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        offsets = decoded
            .map((key, value) => MapEntry(key, int.parse(value.toString())));
      } catch (_) {}
    }

    // 🛰️ Trigger background update
    _fetchAndCacheGlobalOffsets(cacheKey);

    return offsets;
  }

  Future<void> _fetchAndCacheGlobalOffsets(String cacheKey) async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('key, value')
          .filter('key', 'in',
              '("prayer_offset_fajr", "prayer_offset_sunrise", "prayer_offset_dhuhr", "prayer_offset_asr", "prayer_offset_maghrib", "prayer_offset_isha")')
          .timeout(const Duration(seconds: 10));

      if (response is List) {
        final Map<String, int> offsets = {};
        for (var item in response) {
          final key = item['key'].toString().replaceFirst('prayer_offset_', '');
          final value = int.tryParse(item['value'].toString()) ?? 0;
          offsets[key] = value;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(offsets));
      }
    } catch (e) {
      logger.e('Error fetching global offsets: $e');
    }
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

      if (response is List && response.isNotEmpty) {
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
      logger.e('Error fetching social banner config: $e');
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

  /// 🔇 Activate Silent Mode for a specific duration (minutes)
  Future<void> activateSilentMode(int durationMinutes) async {
    if (!Platform.isAndroid) return;
    try {
      logger.i('🔇 Activating Auto-Silent Mode for $durationMinutes minutes');
      await _setRingerMode('vibrate'); // Or 'silent'

      // Schedule revert
      final revertTime = DateTime.now().add(Duration(minutes: durationMinutes));
      await AndroidAlarmManager.oneShotAt(
        revertTime,
        888, // Unique ID for revert alarm
        revertSilentModeCallback,
        exact: true,
        wakeup: true,
      );
    } catch (e) {
      logger.e('❌ Fail to activate silent mode: $e');
    }
  }

  Future<void> _setRingerMode(String mode) async {
    try {
      await _channel.invokeMethod('setRingerMode', {'mode': mode});
    } catch (e) {
      logger.e('❌ MethodChannel Error (setRingerMode): $e');
    }
  }
}

/// 🔄 Callback to revert silent mode
@pragma('vm:entry-point')
void revertSilentModeCallback() async {
  logger.i('🔊 Reverting Silent Mode to normal');
  const MethodChannel channel =
      MethodChannel('com.muslimdaily.app/system_control');
  try {
    await channel.invokeMethod('setRingerMode', {'mode': 'normal'});
  } catch (e) {
    logger.e('❌ Failed to revert ringer mode: $e');
  }
}
