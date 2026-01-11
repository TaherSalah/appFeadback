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
    if (_cachedKidsStories != null) return _cachedKidsStories!;

    try {
      final response = await _supabase
          .from('kids_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      _cachedKidsStories = List<Map<String, dynamic>>.from(response);
      return _cachedKidsStories!;
    } catch (e) {
      print('Failed to fetch kids stories: $e');
      return [];
    }
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
