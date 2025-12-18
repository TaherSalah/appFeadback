import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/dua_models.dart';

class DuaService {
  static const String _customDuasBoxName = 'customDuasBox';
  static const String _remindersBoxName = 'duaRemindersBox';
  static const String _favoritesBoxName = 'favoriteDuasBox';

  late Box<CustomDua> _customDuasBox;
  late Box<DuaReminder> _remindersBox;
  late Box _favoritesBox;
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_customDuasBoxName)) {
      _customDuasBox = await Hive.openBox<CustomDua>(_customDuasBoxName);
    } else {
      _customDuasBox = Hive.box<CustomDua>(_customDuasBoxName);
    }

    if (!Hive.isBoxOpen(_remindersBoxName)) {
      _remindersBox = await Hive.openBox<DuaReminder>(_remindersBoxName);
    } else {
      _remindersBox = Hive.box<DuaReminder>(_remindersBoxName);
    }

    if (!Hive.isBoxOpen(_favoritesBoxName)) {
      _favoritesBox = await Hive.openBox(_favoritesBoxName);
    } else {
      _favoritesBox = Hive.box(_favoritesBoxName);
    }
  }

  // Custom Duas
  Future<void> addCustomDua(CustomDua dua) async {
    await _customDuasBox.put(dua.id, dua);
  }

  Future<void> updateCustomDua(CustomDua dua) async {
    await _customDuasBox.put(dua.id, dua);
  }

  Future<void> deleteCustomDua(String id) async {
    await _customDuasBox.delete(id);
  }

  List<CustomDua> getAllCustomDuas() {
    return _customDuasBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Reminders
  Future<void> addReminder(DuaReminder reminder) async {
    await _remindersBox.put(reminder.id, reminder);
    // TODO: Schedule notification
  }

  Future<void> updateReminder(DuaReminder reminder) async {
    await _remindersBox.put(reminder.id, reminder);
    // TODO: Reschedule notification
  }

  Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
    // TODO: Cancel notification
  }

  Future<void> toggleReminder(String id) async {
    final reminder = _remindersBox.get(id);
    if (reminder != null) {
      reminder.isActive = !reminder.isActive;
      await _remindersBox.put(id, reminder);
    }
  }

  List<DuaReminder> getAllReminders() {
    return _remindersBox.values.toList();
  }

  // Favorites
  Future<void> toggleFavorite(String duaId) async {
    if (isFavorite(duaId)) {
      await _favoritesBox.delete(duaId);
    } else {
      await _favoritesBox.put(duaId, true);
    }
  }

  bool isFavorite(String duaId) {
    return _favoritesBox.get(duaId, defaultValue: false) as bool;
  }

  List<String> getAllFavorites() {
    return _favoritesBox.keys.map((k) => k.toString()).toList();
  }

  String generateId() => _uuid.v4();
}
