import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../main.dart';

class ContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  // Content Cache
  List<Map<String, dynamic>>? _cachedActiveContent;
  List<Map<String, dynamic>>? _cachedCharityStories;
  List<Map<String, dynamic>>? _cachedKidsStories;
  List<Map<String, dynamic>>? _cachedRadioStations;

  static const String _kidsStoriesBoxName = 'kidsStoriesCacheBox';
  static const String _charityStoriesBoxName = 'charityStoriesCacheBox';
  static const String _radioStationsBoxName = 'radioStationsCacheBox';
  static const String _activeContentBoxName = 'activeContentCacheBox';

  late Box _kidsStoriesBox;
  late Box _charityStoriesBox;
  late Box _radioStationsBox;
  late Box _activeContentBox;
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _kidsStoriesBox = await _openBox(_kidsStoriesBoxName);
    _charityStoriesBox = await _openBox(_charityStoriesBoxName);
    _radioStationsBox = await _openBox(_radioStationsBoxName);
    _activeContentBox = await _openBox(_activeContentBoxName);
    
    _isInitialized = true;
  }

  Future<Box> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  /// Fetch active content (Articles, Tips, etc.)
  Future<List<Map<String, dynamic>>> getActiveContent() async {
    await init();
    if (_cachedActiveContent != null) return _cachedActiveContent!;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        final cached = _activeContentBox.get('items');
        if (cached != null) {
          _cachedActiveContent = List<Map<String, dynamic>>.from(
            (cached as List).map((e) => Map<String, dynamic>.from(e))
          );
          return _cachedActiveContent!;
        }
        return [];
      }

      final response = await _supabase
          .from('app_content')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(5);

      final data = List<Map<String, dynamic>>.from(response);
      await _activeContentBox.put('items', data);
      _cachedActiveContent = data;
      return data;
    } catch (e) {
      print('Failed to fetch content: $e');
      final cached = _activeContentBox.get('items');
      if (cached != null) {
        _cachedActiveContent = List<Map<String, dynamic>>.from(
          (cached as List).map((e) => Map<String, dynamic>.from(e))
        );
        return _cachedActiveContent!;
      }
      return [];
    }
  }

  /// Fetch visible Charity stories
  Future<List<Map<String, dynamic>>> getCharityStories() async {
    await init();
    if (_cachedCharityStories != null) return _cachedCharityStories!;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        final cached = _charityStoriesBox.get('stories');
        if (cached != null) {
          _cachedCharityStories = _castToList(cached);
          return _cachedCharityStories!;
        }
        return [];
      }

      final response = await _supabase
          .from('charity_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      await _charityStoriesBox.put('stories', data);
      _cachedCharityStories = data;
      return data;
    } catch (e) {
      logger.e('Failed to fetch charity stories: $e');

      final cached = _charityStoriesBox.get('stories');
      if (cached != null) return _castToList(cached);
      return [];
    }
  }

  /// Fetch visible Kids stories
  Future<List<Map<String, dynamic>>> getKidsStories() async {
    await init();
    if (_cachedKidsStories != null) return _cachedKidsStories!;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        final cached = _kidsStoriesBox.get('stories');
        if (cached != null) {
          _cachedKidsStories = _castToList(cached);
          return _cachedKidsStories!;
        }
        return _getFallbackKidsStories();
      }

      final response = await _supabase
          .from('kids_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      final rawStories = List<Map<String, dynamic>>.from(response);
      final stories = rawStories.map((s) {
        String content = s['content'] ?? '';
        if (content.isEmpty && s['paragraphs'] != null) {
          if (s['paragraphs'] is List) {
            content = (s['paragraphs'] as List).join('\n\n');
          }
        }
        return {
          'id': s['id'],
          'title': s['title'] ?? 'بدون عنوان',
          'emoji': s['emoji'] ?? '📖',
          'content': content,
          'moral': s['moral'] ?? '',
          'category': s['category'] ?? 'منوع',
          'stars_reward': s['stars_reward'] ?? 20,
        };
      }).toList();

      await _kidsStoriesBox.put('stories', stories);
      _cachedKidsStories = stories;
      return stories;
    } catch (e) {
      print('Error fetching kids stories: $e');
      final cached = _kidsStoriesBox.get('stories');
      if (cached != null) return _castToList(cached);
      return _getFallbackKidsStories();
    }
  }

  /// Fallback local kids stories data
  List<Map<String, dynamic>> _getFallbackKidsStories() {
    return [
      {
        'id': 'fallback_1',
        'title': 'قصة النبي نوح عليه السلام',
        'emoji': '⛵',
        'category': 'قصص الأنبياء',
        'content': '''كان نوح عليه السلام نبياً صالحاً، دعا قومه إلى عبادة الله وحده لمدة 950 سنة! 

لكن قومه رفضوا وأصروا على عبادة الأصنام. فأمر الله نوحاً ببناء سفينة كبيرة جداً.

بنى نوح السفينة وحمل فيها من كل حيوان زوجين، ومن آمن معه من الناس.

ثم جاء الطوفان العظيم! غرقت الأرض كلها، ونجا نوح ومن معه في السفينة.

الدرس: الصبر والإيمان بالله ينجيان المؤمن من كل شدة! 🌈''',
        'stars_reward': 15,
        'is_visible': true,
        'moral': 'الصبر والإيمان بالله ينجيان المؤمن من كل شدة!',
      },
      {
        'id': 'fallback_2',
        'title': 'الصدق منجاة',
        'emoji': '✅',
        'category': 'أخلاق',
        'content': '''كان هناك ولد صغير اسمه أحمد، كان يحب اللعب بالكرة.

في يوم من الأيام، كسر أحمد نافذة الجيران بالخطأ أثناء اللعب!

خاف أحمد كثيراً، لكنه تذكر أن الصدق من صفات المؤمنين.

ذهب أحمد إلى الجيران واعتذر بصدق، وأخبرهم بما حدث.

فرح الجيران بصدقه وسامحوه، وساعده والده في إصلاح النافذة.

الدرس: الصدق دائماً هو الطريق الصحيح! 💚''',
        'stars_reward': 10,
        'is_visible': true,
        'moral': 'الصدق دائماً هو الطريق الصحيح!',
      },
      {
        'id': 'fallback_3',
        'title': 'الصحابي الصغير أسامة بن زيد',
        'emoji': '⚔️',
        'category': 'صحابة',
        'content': '''أسامة بن زيد كان صحابياً صغيراً، لكنه كان شجاعاً جداً!

أحبه النبي محمد ﷺ كثيراً وكان يسميه "حِبّي" أي حبيبي.

عندما كبر أسامة قليلاً، جعل النبي ﷺ قائداً للجيش وهو لم يبلغ 18 سنة!

كان أسامة ذكياً وشجاعاً، وقاد الجيش بنجاح.

الدرس: العمر ليس مهماً، المهم هو الإيمان والشجاعة! 🌟''',
        'stars_reward': 12,
        'is_visible': true,
        'moral': 'المهم هو الإيمان والشجاعة وليس العمر!',
      },
    ];
  }

  /// Fetch Radio Stations
  Future<List<Map<String, dynamic>>> getRadioStations() async {
    await init();
    if (_cachedRadioStations != null) return _cachedRadioStations!;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        final cached = _radioStationsBox.get('stations');
        if (cached != null) {
          _cachedRadioStations = _castToList(cached);
          return _cachedRadioStations!;
        }
        return [];
      }

      final response = await _supabase
          .from('radio_channels')
          .select('*')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final data = List<Map<String, dynamic>>.from(response);
      await _radioStationsBox.put('stations', data);
      _cachedRadioStations = data;
      return data;
    } catch (e) {
      print('Failed to fetch radio stations: $e');
      final cached = _radioStationsBox.get('stations');
      if (cached != null) return _castToList(cached);
      return [];
    }
  }

  List<Map<String, dynamic>> _castToList(dynamic data) {
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e))
    );
  }

  /// Clear all cache (Call this on refresh)
  void clearCache() {
    _cachedActiveContent = null;
    _cachedCharityStories = null;
    _cachedKidsStories = null;
    _cachedRadioStations = null;
  }
}
