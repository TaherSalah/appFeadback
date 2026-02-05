import 'package:shared_preferences/shared_preferences.dart';

class ReflectionsService {
  // Generic key helper
  String _getPageKey(int pageIndex) => 'reflection_page_$pageIndex';
  String _getVerseKey(int surahId, int ayahId) =>
      'reflection_${surahId}_$ayahId';

  Future<void> savePageNote(int pageIndex, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getPageKey(pageIndex), content);
  }

  Future<String?> getPageNote(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getPageKey(pageIndex));
  }

  Future<void> deletePageNote(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getPageKey(pageIndex));
  }

  // Keep verse methods for future or if needed
  Future<void> saveVerseNote(int surahId, int ayahId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getVerseKey(surahId, ayahId), content);
  }

  Future<String?> getVerseNote(int surahId, int ayahId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getVerseKey(surahId, ayahId));
  }

  Future<void> deleteVerseNote(int surahId, int ayahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getVerseKey(surahId, ayahId));
  }

  Future<Map<int, String>> getAllReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final Map<int, String> reflections = {};

    for (final key in allKeys) {
      if (key.startsWith('reflection_page_')) {
        final pageIndexStr = key.replaceFirst('reflection_page_', '');
        final pageIndex = int.tryParse(pageIndexStr);
        if (pageIndex != null) {
          final content = prefs.getString(key);
          if (content != null && content.isNotEmpty) {
            reflections[pageIndex] = content;
          }
        }
      }
    }
    return reflections;
  }
}
