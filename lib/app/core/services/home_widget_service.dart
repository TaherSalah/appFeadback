import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

/// Enum for widget types
enum WidgetType {
  prayerTimes,
  fullPrayerTimes,
  azkar,
  charity,
}

/// Data model for Prayer Times Widget
class PrayerTimesWidgetData {
  final String prayerName;
  final String prayerTime;
  final String city;

  PrayerTimesWidgetData({
    required this.prayerName,
    required this.prayerTime,
    required this.city,
  });
}

/// Data model for Azkar Widget
class AzkarWidgetData {
  final String text;
  final int count;
  final String title;

  AzkarWidgetData({
    required this.text,
    required this.count,
    this.title = 'أذكار اليوم',
  });
}

/// Data model for Charity Widget
class CharityWidgetData {
  final double monthlyTotal;
  final int streakDays;
  final String currency;

  CharityWidgetData({
    required this.monthlyTotal,
    required this.streakDays,
    this.currency = ' ج.م',
  });
}

class HomeWidgetService {
  // Widget provider names - must match AndroidManifest.xml
  static const String prayerWidgetName = 'HomeWidgetProvider';
  static const String fullPrayerWidgetName = 'FullPrayerWidgetProvider';
  static const String azkarWidgetName = 'AzkarWidgetProvider';
  static const String charityWidgetName = 'CharityWidgetProvider';

  // iOS widget names
  static const String iosPrayerWidget = 'MuslimDailyWidget';
  static const String iosFullPrayerWidget = 'FullPrayerWidget';
  static const String iosAzkarWidget = 'AzkarWidget';
  static const String iosCharityWidget = 'CharityWidget';

  /// Updates the Prayer Times widget with the next prayer info
  static Future<void> updatePrayerTimesWidget({
    required String prayerName,
    required String prayerTime,
    required String city,
    String? timeLeft,
    String? hijriDate,
  }) async {
    try {
      // Save data to SharedPreferences
      await HomeWidget.saveWidgetData<String>('prayer_name', prayerName);
      await HomeWidget.saveWidgetData<String>('prayer_time', prayerTime);
      await HomeWidget.saveWidgetData<String>('city', city);
      if (timeLeft != null) {
        await HomeWidget.saveWidgetData<String>('time_left', timeLeft);
      }
      if (hijriDate != null) {
        await HomeWidget.saveWidgetData<String>('hijri_date', hijriDate);
      }

      // Request widget update
      await HomeWidget.updateWidget(
        name: prayerWidgetName,
        iOSName: iosPrayerWidget,
      );

      debugPrint("✅ Prayer Widget Updated: $prayerName at $prayerTime");
    } catch (e) {
      debugPrint("❌ Error Updating Prayer Widget: $e");
    }
  }

  /// Updates the Full Prayer Times widget with all prayer times
  static Future<void> updateFullPrayerWidget({
    required String fajrTime,
    required String sunriseTime,
    required String dhuhrTime,
    required String asrTime,
    required String maghribTime,
    required String ishaTime,
    required String nextPrayer,
    required DateTime nextPrayerTime, // New parameter for Chronometer
    required String city,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>('next_prayer_time_millis', nextPrayerTime.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('fajr_time', fajrTime);
      await HomeWidget.saveWidgetData<String>('sunrise_time', sunriseTime);
      await HomeWidget.saveWidgetData<String>('dhuhr_time', dhuhrTime);
      await HomeWidget.saveWidgetData<String>('asr_time', asrTime);
      await HomeWidget.saveWidgetData<String>('maghrib_time', maghribTime);
      await HomeWidget.saveWidgetData<String>('isha_time', ishaTime);
      await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
      await HomeWidget.saveWidgetData<String>('city', city);

      await HomeWidget.updateWidget(
        name: fullPrayerWidgetName,
        iOSName: iosFullPrayerWidget,
      );

      debugPrint("✅ Full Prayer Widget Updated: $nextPrayer next, in $city");
    } catch (e) {
      debugPrint("❌ Error Updating Full Prayer Widget: $e");
    }
  }

  /// Updates the Azkar widget with daily remembrance
  static Future<void> updateAzkarWidget({
    required String azkarText,
    required int repetitions,
    String title = 'أذكار اليوم',
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('azkar_text', azkarText);
      await HomeWidget.saveWidgetData<String>('azkar_count', repetitions.toString());
      await HomeWidget.saveWidgetData<String>('azkar_title', title);

      await HomeWidget.updateWidget(
        name: azkarWidgetName,
        iOSName: iosAzkarWidget,
      );

      debugPrint("✅ Azkar Widget Updated: $azkarText ($repetitions times)");
    } catch (e) {
      debugPrint("❌ Error Updating Azkar Widget: $e");
    }
  }

  /// Updates the Charity widget with donation stats
  static Future<void> updateCharityWidget({
    required double monthlyTotal,
    required int streakDays,
    String currency = ' ج.م',
    String title = 'صدقاتي هذا الشهر',
  }) async {
    try {
      // Format amount with thousands separator
      final formattedAmount = _formatNumber(monthlyTotal);
      
      await HomeWidget.saveWidgetData<String>('charity_amount', formattedAmount);
      await HomeWidget.saveWidgetData<String>('charity_currency', currency);
      await HomeWidget.saveWidgetData<String>('charity_streak', streakDays.toString());
      await HomeWidget.saveWidgetData<String>('charity_title', title);

      await HomeWidget.updateWidget(
        name: charityWidgetName,
        iOSName: iosCharityWidget,
      );

      debugPrint("✅ Charity Widget Updated: $formattedAmount$currency, $streakDays days streak");
    } catch (e) {
      debugPrint("❌ Error Updating Charity Widget: $e");
    }
  }

  /// Updates all widgets at once
  static Future<void> updateAllWidgets({
    PrayerTimesWidgetData? prayerData,
    AzkarWidgetData? azkarData,
    CharityWidgetData? charityData,
  }) async {
    if (prayerData != null) {
      await updatePrayerTimesWidget(
        prayerName: prayerData.prayerName,
        prayerTime: prayerData.prayerTime,
        city: prayerData.city,
      );
    }

    if (azkarData != null) {
      await updateAzkarWidget(
        azkarText: azkarData.text,
        repetitions: azkarData.count,
        title: azkarData.title,
      );
    }

    if (charityData != null) {
      await updateCharityWidget(
        monthlyTotal: charityData.monthlyTotal,
        streakDays: charityData.streakDays,
        currency: charityData.currency,
      );
    }
  }

  /// Helper to format numbers with thousands separator
  static String _formatNumber(double number) {
    if (number >= 1000) {
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return number.toStringAsFixed(0);
  }

  // Legacy method for backward compatibility
  static Future<void> updateWidget({
    required String prayerName,
    required String prayerTime,
    required String city,
  }) async {
    await updatePrayerTimesWidget(
      prayerName: prayerName,
      prayerTime: prayerTime,
      city: city,
    );
  }
}
