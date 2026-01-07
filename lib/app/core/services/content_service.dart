import 'package:supabase_flutter/supabase_flutter.dart';

class ContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  /// Fetch active content (Articles, Tips, etc.)
  /// Returns a list of maps
  Future<List<Map<String, dynamic>>> getActiveContent() async {
    try {
      final response = await _supabase
          .from('app_content')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(5); // Fetch latest 5 items

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to fetch content: $e');
      return [];
    }
  }

  /// Fetch visible Charity stories
  Future<List<Map<String, dynamic>>> getCharityStories() async {
    try {
      final response = await _supabase
          .from('charity_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to fetch charity stories: $e');
      return [];
    }
  }

  /// Fetch visible Kids stories
  Future<List<Map<String, dynamic>>> getKidsStories() async {
    try {
      final response = await _supabase
          .from('kids_stories')
          .select('*')
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to fetch kids stories: $e');
      return [];
    }
  }

  /// Fetch Radio Stations
  Future<List<Map<String, dynamic>>> getRadioStations() async {
    try {
      final response = await _supabase
          .from('radio_channels')
          .select('*')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to fetch radio stations: $e');
      return [];
    }
  }
}
