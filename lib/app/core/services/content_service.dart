import 'package:supabase_flutter/supabase_flutter.dart';

class ContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  // Crap Cache
  List<Map<String, dynamic>>? _cachedActiveContent;
  List<Map<String, dynamic>>? _cachedCharityStories;
  List<Map<String, dynamic>>? _cachedKidsStories;
  List<Map<String, dynamic>>? _cachedRadioStations;

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
    if (_cachedKidsStories != null) {
      print('📦 Returning cached kids stories: ${_cachedKidsStories!.length} stories');
      return _cachedKidsStories!;
    }

    try {
      print('🔍 Fetching kids stories from Supabase...');
      final response = await _supabase
          .from('kids_stories')
          .select('*')
          // Temporarily fetch ALL stories to debug
          // .eq('is_visible', true)
          .order('created_at', ascending: false);

      print('✅ Supabase response: $response');
      final stories = List<Map<String, dynamic>>.from(response);
      print('📊 Parsed ${stories.length} stories from Supabase');
      
      // If Supabase returns empty, use fallback local data
      if (stories.isEmpty) {
        print('⚠️ Supabase returned empty, using fallback data');
        _cachedKidsStories = _getFallbackKidsStories();
        return _cachedKidsStories!;
      }
      
      print('✨ Using Supabase stories');
      _cachedKidsStories = stories;
      return _cachedKidsStories!;
    } catch (e) {
      print('❌ Failed to fetch kids stories: $e');
      // Return fallback data on error
      print('⚠️ Using fallback data due to error');
      _cachedKidsStories = _getFallbackKidsStories();
      return _cachedKidsStories!;
    }
  }

  /// Fallback local kids stories data
  List<Map<String, dynamic>> _getFallbackKidsStories() {
    return [
      {
        'id': 1,
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
      },
      {
        'id': 2,
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
      },
      {
        'id': 3,
        'title': 'الصحابي الصغير أسامة بن زيد',
        'emoji': '⚔️',
        'category': 'صحابة',
        'content': '''أسامة بن زيد كان صحابياً صغيراً، لكنه كان شجاعاً جداً!

أحبه النبي محمد ﷺ كثيراً وكان يسميه "حِبّي" أي حبيبي.

عندما كبر أسامة قليلاً، جعله النبي ﷺ قائداً للجيش وهو لم يبلغ 18 سنة!

كان أسامة ذكياً وشجاعاً، وقاد الجيش بنجاح.

الدرس: العمر ليس مهماً، المهم هو الإيمان والشجاعة! 🌟''',
        'stars_reward': 12,
        'is_visible': true,
      },
      {
        'id': 4,
        'title': 'النملة الذكية',
        'emoji': '🐜',
        'category': 'عبر',
        'content': '''في يوم من الأيام، كان النبي سليمان عليه السلام يسير مع جيشه.

سمع نملة صغيرة تقول: "يا أيها النمل ادخلوا مساكنكم لا يحطمنكم سليمان وجنوده!"

تبسم سليمان عليه السلام من قولها، وشكر الله على نعمة السمع.

النملة الصغيرة كانت ذكية وحذرة، وحمت قومها من الخطر.

الدرس: حتى الصغار يمكنهم أن يكونوا أذكياء ومفيدين! 🧠''',
        'stars_reward': 10,
        'is_visible': true,
      },
      {
        'id': 5,
        'title': 'الطفل الذي ساعد أمه',
        'emoji': '❤️',
        'category': 'أخلاق',
        'content': '''كان هناك طفل اسمه يوسف، كانت أمه تعمل بجد في البيت.

رأى يوسف أمه متعبة، فقرر أن يساعدها.

رتب يوسف غرفته، وساعد في غسل الأطباق، وحمل الأغراض من السوق.

فرحت أمه كثيراً ودعت له بالخير والبركة.

في الليل، حلم يوسف أنه في الجنة مع أمه، وهما سعيدان جداً!

الدرس: بر الوالدين طريق الجنة! 🌺''',
        'stars_reward': 15,
        'is_visible': true,
      },
      {
        'id': 6,
        'title': 'قصة النبي يوسف عليه السلام',
        'emoji': '👑',
        'category': 'قصص الأنبياء',
        'content': '''كان يوسف عليه السلام ولداً جميلاً جداً، أحبه والده يعقوب كثيراً.

غار إخوته منه، فألقوه في البئر! لكن الله حفظه ونجاه.

وجده تجار وباعوه في مصر، لكن يوسف كان صابراً ومؤمناً بالله.

بعد سنوات طويلة، أصبح يوسف وزيراً عظيماً في مصر!

وسامح إخوته الذين ظلموه، وجمع الله شمل العائلة.

الدرس: الصبر والإيمان يحولان المحنة إلى منحة! ✨''',
        'stars_reward': 20,
        'is_visible': true,
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
