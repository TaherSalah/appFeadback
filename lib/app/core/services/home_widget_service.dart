import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class HomeWidgetService {
  // Must match the class name in AndroidManifest.xml (without package)
  static const String androidWidgetName = 'HomeWidgetProvider';

  // Must match the kind in iOS WidgetExtension
  static const String iosWidgetName = 'MuslimDailyWidget';

  /// Updates the home screen widget with the latest prayer info
  static Future<void> updateWidget({
    required String prayerName,
    required String prayerTime,
    required String city,
  }) async {
    try {
      // Save data to SharedPreferences (or UserDefaults on iOS)
      // Keys must match those used in the native code
      await HomeWidget.saveWidgetData<String>('prayer_name', prayerName);
      await HomeWidget.saveWidgetData<String>('prayer_time', prayerTime);
      await HomeWidget.saveWidgetData<String>('city', city);

      // Request widget update
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );

      debugPrint("✅ Home Widget Updated: $prayerName at $prayerTime");
    } catch (e) {
      debugPrint("❌ Error Updating Home Widget: $e");
    }
  }
}
