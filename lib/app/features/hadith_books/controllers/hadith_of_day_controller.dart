import 'dart:developer' show log;
import 'dart:math' hide log;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:objectbox/objectbox.dart';
import 'package:get_it/get_it.dart';

import '../../../core/utils/objectbox.dart';
import '../data/models/ar_hadith_model.dart';
import '../../../../objectbox.g.dart';

class HadithOfDayController extends GetxController {
  static HadithOfDayController get instance =>
      Get.isRegistered<HadithOfDayController>()
          ? Get.find<HadithOfDayController>()
          : Get.put(HadithOfDayController());

  late Store store;
  final box = GetStorage();
  
  // Current hadith of the day
  Rx<ARHadithModel?> todayHadith = Rx<ARHadithModel?>(null);
  RxBool isLoading = false.obs;

  // Storage keys
  static const String _keyLastUpdate = 'hadith_of_day_last_update';
  static const String _keyHadithId = 'hadith_of_day_id';

  @override
  void onInit() {
    super.onInit();
    
    // Initialize Store
    if (GetIt.I.isRegistered<ObjBox>()) {
      store = GetIt.I.get<ObjBox>().store;
      getTodayHadith();
    } else {
      log('ObjBox not registered yet in GetIt', name: 'HadithOfDayController');
    }
  }

  /// Get today's hadith (loads from cache or selects new one)
  Future<void> getTodayHadith() async {
    try {
      isLoading.value = true;

      final today = _getTodayDateString();
      final lastUpdate = box.read<String>(_keyLastUpdate);

      // Check if we need a new hadith (new day)
      if (lastUpdate == today) {
        // Load from cache
        final cachedHadithId = box.read<int>(_keyHadithId);
        if (cachedHadithId != null) {
          final hadith = store.box<ARHadithModel>().get(cachedHadithId);
          if (hadith != null) {
            todayHadith.value = hadith;
            log('Loaded cached hadith of the day', name: 'HadithOfDayController');
            return;
          }
        }
      }

      // Select new hadith for today
      await _selectNewHadith();
    } catch (e) {
      log('Error getting today hadith: $e', name: 'HadithOfDayController');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a new hadith for today
  Future<void> _selectNewHadith() async {
    try {
      final seed = _generateDailySeed();
      final hadith = _selectRandomHadith(seed);

      if (hadith != null) {
        todayHadith.value = hadith;
        
        // Cache for today
        final today = _getTodayDateString();
        box.write(_keyLastUpdate, today);
        box.write(_keyHadithId, hadith.id);
        
        log('Selected new hadith of the day: ${hadith.hadithNumber}', name: 'HadithOfDayController');
      }
    } catch (e) {
      log('Error selecting new hadith: $e', name: 'HadithOfDayController');
    }
  }

  /// Generate a seed based on today's date (same seed = same hadith for the day)
  int _generateDailySeed() {
    final now = DateTime.now();
    // Use year + day of year to create unique seed per day
    return now.year * 1000 + _dayOfYear(now);
  }

  /// Get day of year (1-365/366)
  int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  /// Select a random hadith using the given seed
  ARHadithModel? _selectRandomHadith(int seed) {
    try {
      final hadithBox = store.box<ARHadithModel>();
      final totalHadiths = hadithBox.count();

      if (totalHadiths == 0) {
        log('No hadiths available', name: 'HadithOfDayController');
        return null;
      }

      // Use seed to get consistent "random" hadith for the day
      final random = Random(seed);
      final randomIndex = random.nextInt(totalHadiths);

      // Get hadith at that index
      final allHadiths = hadithBox.getAll();
      if (randomIndex < allHadiths.length) {
        return allHadiths[randomIndex];
      }

      return null;
    } catch (e) {
      log('Error selecting random hadith: $e', name: 'HadithOfDayController');
      return null;
    }
  }

  /// Get today's date as string (YYYY-MM-DD)
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Force refresh hadith (for testing or manual refresh)
  Future<void> forceRefresh() async {
    box.remove(_keyLastUpdate);
    box.remove(_keyHadithId);
    await getTodayHadith();
  }

  /// Check if hadith needs update (called when app opens)
  Future<void> checkForUpdate() async {
    final today = _getTodayDateString();
    final lastUpdate = box.read<String>(_keyLastUpdate);

    if (lastUpdate != today) {
      await getTodayHadith();
    }
  }
}
