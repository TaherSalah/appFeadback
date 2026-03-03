import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import '../../core/adhan_system/manager/adhan_manager.dart';
import '../../core/services/adhan_logic/prayer_background_manager.dart';
import '../../core/services/home_widget_service.dart';
import 'package:muslimdaily/app/features/mainView/controllar/MainController.dart';

class AdhanWorkManagerService {
  static final AdhanWorkManagerService _instance =
      AdhanWorkManagerService._internal();
  factory AdhanWorkManagerService() => _instance;
  AdhanWorkManagerService._internal();

  /// Proxy to new logic initialize
  Future<void> initialize({
    bool forceReschedule = false,
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int? days,
    bool? enableNormalAdhan,
  }) async {
    await PrayerBackgroundManager.checkAndUpdatePrayerTimes();
    await updateWidget();
  }

  /// Proxy to update widget
  Future<void> updateWidget() async {
    final nextPrayer = await getNextPrayer();
    if (nextPrayer != null) {
      final prefs = await SharedPreferences.getInstance();
      final city = prefs.getString('selected_city') ?? 'مكة المكرمة';
      await HomeWidgetService.updateWidget(
        prayerName: nextPrayer['name'],
        prayerTime: nextPrayer['formattedTime'],
        city: city,
      );
    }
  }

  /// Get Next Prayer map for UI
  Future<Map<String, dynamic>?> getNextPrayer() async {
    try {
      final mainCtrl = MainController();
      // Target time is calculated and stored in MainController
      if (mainCtrl.upcomingPrayerName.isNotEmpty &&
          mainCtrl.targetTime != null) {
        return {
          'name': mainCtrl.upcomingPrayerName,
          'formattedTime': mainCtrl.formatTime(mainCtrl.targetTime!),
        };
      }
    } catch (e) {
      // fallback
      return null;
    }
    return null;
  }

  Future<SharedPreferences> getAdhanPreferences() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> saveAdhanPreferences({
    bool? enableFajrAdhan,
    bool? enableNormalAdhan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (enableFajrAdhan != null) {
      await prefs.setBool('enableFajrAdhan', enableFajrAdhan);
    }
    if (enableNormalAdhan != null) {
      await prefs.setBool('enableNormalAdhan', enableNormalAdhan);
    }
  }

  Future<String?> scheduleTestAdhan({required int secondsFromNow}) async {
    try {
      await AdhanManager.scheduleTestAlarm(seconds: secondsFromNow);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> getSelectedAdhan(String type) async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 'none' or some basic ID
    return prefs.getString('selected_${type}_adhan') ?? 'none';
  }

  Future<void> reschedule({int days = 7}) async {
    await AdhanManager.rescheduleAll();
  }

  Future<void> setSelectedAdhan(String type, String adhanId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_${type}_adhan', adhanId);
  }
}
