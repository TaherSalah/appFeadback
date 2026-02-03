import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  static const String _kidsStoriesCacheBoxName = 'kidsStoriesCacheBox';
  late Box _kidsStoriesCacheBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    if (!Hive.isBoxOpen(_kidsStoriesCacheBoxName)) {
      _kidsStoriesCacheBox = await Hive.openBox(_kidsStoriesCacheBoxName);
    } else {
      _kidsStoriesCacheBox = Hive.box(_kidsStoriesCacheBoxName);
    }
    _isInitialized = true;
  }

  /// Fetch active content (Articles, Tips, etc.)
  /// Returns a list of maps
  Future<List<Map<String, dynamic>>> getActiveContent() async {
    if (_cachedActiveContent != null) return _cachedActiveContent!;

    try {
      final response = await _supabase
          .from('app_content')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(5); // Fetch latest 5 items

      // Cache the result
      _cachedActiveContent = List<Map<String, dynamic>>.from(response);
      return _cachedActiveContent!;
    } catch (e) {
      print('Failed to fetch content: $e');
      return [];
    }
  }

  /// Fetch visible Charity stories
  Future<List<Map<String, dynamic>>> getCharityStories() async {
    if (_cachedCharityStories != null) return _cachedCharityStories!;

    try {
      final response = await _supabase
          .from('charity_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      _cachedCharityStories = List<Map<String, dynamic>>.from(response);
      return _cachedCharityStories!;
    } catch (e) {
      print('Failed to fetch charity stories: $e');
      return [];
    }
  }

  /// Fetch visible Kids stories
  Future<List<Map<String, dynamic>>> getKidsStories() async {
    await init();
    
    if (_cachedKidsStories != null) {
      return _cachedKidsStories!;
    }

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult == ConnectivityResult.none;

      if (isOffline) {
        print('📶 App is offline, loading kids stories from cache...');
        final cachedData = _kidsStoriesCacheBox.get('stories');
        if (cachedData != null) {
          _cachedKidsStories = List<Map<String, dynamic>>.from(
            (cachedData as List).map((e) => Map<String, dynamic>.from(e))
          );
          return _cachedKidsStories!;
        }
        _cachedKidsStories = _getFallbackKidsStories();
        return _cachedKidsStories!;
      }

      print('🔍 Fetching kids stories from Supabase...');
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

      // Update cache
      await _kidsStoriesCacheBox.put('stories', stories);
      
      _cachedKidsStories = stories;
      return _cachedKidsStories!;
    } catch (e) {
      print('❌ Error fetching kids stories: $e');
      final cachedData = _kidsStoriesCacheBox.get('stories');
      if (cachedData != null) {
        _cachedKidsStories = List<Map<String, dynamic>>.from(
          (cachedData as List).map((e) => Map<String, dynamic>.from(e))
        );
      } else {
        _cachedKidsStories = _getFallbackKidsStories();
      }
      return _cachedKidsStories!;
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
    if (_cachedRadioStations != null) return _cachedRadioStations!;

    try {
      final response = await _supabase
          .from('radio_channels')
          .select('*')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      _cachedRadioStations = List<Map<String, dynamic>>.from(response);
      return _cachedRadioStations!;
    } catch (e) {
      print('Failed to fetch radio stations: $e');
      return [];
    }
  }

  /// Clear all cache (Call this on refresh)
  void clearCache() {
    _cachedActiveContent = null;
    _cachedCharityStories = null;
    _cachedKidsStories = null;
    _cachedRadioStations = null;
  }
}
