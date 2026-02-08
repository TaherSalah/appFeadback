import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'reflection_model.dart';

class ReflectionsService {
  // Key helpers for multiple reflections per page
  String _getPageReflectionsKey(int pageIndex) => 'reflections_page_$pageIndex';
  String _getVerseKey(int surahId, int ayahId) => 'reflection_${surahId}_$ayahId';

  // ========== Multiple Reflections Methods ==========

  /// Add a new reflection to a page
  Future<void> addReflection(
    int pageIndex,
    String content, {
    ReflectionColor color = ReflectionColor.none,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final reflections = await getPageReflections(pageIndex);
    
    final newReflection = Reflection.create(
      pageIndex: pageIndex,
      content: content,
      color: color,
    );
    
    reflections.add(newReflection);
    await _savePageReflections(pageIndex, reflections);
  }

  /// Get all reflections for a specific page
  Future<List<Reflection>> getPageReflections(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPageReflectionsKey(pageIndex);
    final jsonString = prefs.getString(key);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Reflection.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update an existing reflection
  Future<void> updateReflection(int pageIndex, String reflectionId, String newContent) async {
    final reflections = await getPageReflections(pageIndex);
    final index = reflections.indexWhere((r) => r.id == reflectionId);
    
    if (index != -1) {
      reflections[index] = reflections[index].copyWith(
        content: newContent,
        updatedAt: DateTime.now(),
      );
      await _savePageReflections(pageIndex, reflections);
    }
  }

  /// Delete a specific reflection
  Future<void> deleteReflection(int pageIndex, String reflectionId) async {
    final reflections = await getPageReflections(pageIndex);
    reflections.removeWhere((r) => r.id == reflectionId);
    await _savePageReflections(pageIndex, reflections);
  }

  /// Check if a page has any reflections
  Future<bool> hasPageReflections(int pageIndex) async {
    final reflections = await getPageReflections(pageIndex);
    return reflections.isNotEmpty;
  }

  /// Get count of reflections for a page
  Future<int> getPageReflectionsCount(int pageIndex) async {
    final reflections = await getPageReflections(pageIndex);
    return reflections.length;
  }

  /// Save reflections list to SharedPreferences
  Future<void> _savePageReflections(int pageIndex, List<Reflection> reflections) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPageReflectionsKey(pageIndex);
    
    if (reflections.isEmpty) {
      await prefs.remove(key);
    } else {
      final jsonList = reflections.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(key, jsonString);
    }
  }

  /// Get all reflections from all pages (for the reflections list screen)
  Future<Map<int, List<Reflection>>> getAllReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final Map<int, List<Reflection>> allReflections = {};

    for (final key in allKeys) {
      if (key.startsWith('reflections_page_')) {
        final pageIndexStr = key.replaceFirst('reflections_page_', '');
        final pageIndex = int.tryParse(pageIndexStr);
        if (pageIndex != null) {
          final reflections = await getPageReflections(pageIndex);
          if (reflections.isNotEmpty) {
            allReflections[pageIndex] = reflections;
          }
        }
      }
    }
    return allReflections;
  }

  // ========== Legacy Methods (kept for backward compatibility) ==========

  /// @deprecated Use addReflection instead
  Future<void> savePageNote(int pageIndex, String content) async {
    await addReflection(pageIndex, content);
  }

  /// @deprecated Use getPageReflections instead
  Future<String?> getPageNote(int pageIndex) async {
    final reflections = await getPageReflections(pageIndex);
    return reflections.isNotEmpty ? reflections.first.content : null;
  }

  /// @deprecated Use deleteReflection instead
  Future<void> deletePageNote(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getPageReflectionsKey(pageIndex));
  }

  // ========== Verse Methods (kept for future use) ==========

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
}
