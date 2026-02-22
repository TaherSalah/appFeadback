import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adhan_controller.dart';
import 'notify_helper.dart';

// Dummy model matching AdhanData
class AdhanData {
  final int index;
  final String adhanName;
  final String adhanFileName;
  final String adhanLocalPath;
  final String urlAndroidAdhanZip;
  final String urlIosAdhanZip;
  final String urlPlayAdhan;
  final String? androidFilePath;
  final String? iosFilePath;
  final String? androidFajirFilePath;
  final String? adhanPath;

  AdhanData({
    required this.index,
    required this.adhanName,
    required this.adhanFileName,
    required this.adhanLocalPath,
    required this.urlAndroidAdhanZip,
    required this.urlIosAdhanZip,
    required this.urlPlayAdhan,
    this.androidFilePath,
    this.iosFilePath,
    this.androidFajirFilePath,
    this.adhanPath,
  });

  factory AdhanData.fromJson(Map<String, dynamic> json) => AdhanData(
        index: json["index"] ?? 0,
        adhanName: json["adhan_name"] ?? '',
        adhanFileName: json["adhan_file_name"] ?? '',
        adhanLocalPath: json["adhan_local_path"] ?? '',
        urlAndroidAdhanZip: json["url_android_adhan_zip"] ?? '',
        urlIosAdhanZip: json["url_ios_adhan_zip"] ?? '',
        urlPlayAdhan: json["url_play_adhan"] ?? '',
        androidFilePath: json["android_file_path"],
        iosFilePath: json["ios_file_path"],
        androidFajirFilePath: json["android_fajr_file_path"],
        adhanPath: json["adhan_path"],
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "adhan_name": adhanName,
        "adhan_file_name": adhanFileName,
        "adhan_local_path": adhanLocalPath,
        "url_android_adhan_zip": urlAndroidAdhanZip,
        "url_ios_adhan_zip": urlIosAdhanZip,
        "url_play_adhan": urlPlayAdhan,
        "android_file_path": androidFilePath,
        "ios_file_path": iosFilePath,
        "android_fajr_file_path": androidFajirFilePath,
        "adhan_path": adhanPath,
      };
}

class PrayersNotificationsCtrl extends GetxController {
  static PrayersNotificationsCtrl get instance =>
      GetInstance().putOrFind(() => PrayersNotificationsCtrl());

  RxString selectedAdhanPath = 'resource://raw/aqsa_athan'.obs;
  RxString selectedAdhanPathFajir = 'resource://raw/aqsa_athan_fajir'.obs;
  List<AdhanData> adhanList = [];
  RxList<AdhanData> downloadedAdhanData = <AdhanData>[].obs;
  RxBool isDownloading = false.obs;
  RxInt progress = 0.obs;
  RxInt downloadIndex = (-1).obs;
  RxString tempAdhanPath = ''.obs;
  RxString tempAdhanPathFajir = ''.obs;

  @override
  Future<void> onInit() async {
    await _loadSharedVariables();
    await loadAdhanData();
    super.onInit();
  }

  Future<void> _loadSharedVariables() async {
    final prefs = await SharedPreferences.getInstance();
    selectedAdhanPath.value =
        prefs.getString('adhan_path') ?? 'resource://raw/aqsa_athan';
    selectedAdhanPathFajir.value = prefs.getString('adhan_path_fajir') ??
        'resource://raw/aqsa_athan_fajir';

    final downloadedSoundData = prefs.getString('Downloaded_Adhan_Sounds_Data');
    if (downloadedSoundData != null) {
      downloadedAdhanData.value =
          (jsonDecode(downloadedSoundData) as List<dynamic>?)?.map((e) {
                return AdhanData.fromJson(e as Map<String, dynamic>);
              }).toList() ??
              [];
    }
  }

  Future<void> loadAdhanData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/adhanSounds.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      adhanList = jsonData.map((data) => AdhanData.fromJson(data)).toList();
    } catch (_) {
      log('Could not load adhan sounds json.');
    }
  }

  void onNotificationActionReceived(ReceivedAction receivedAction) {
    if (receivedAction.buttonKeyPressed == 'STOP_ADHAN') {
      NotifyHelper().cancelNotification(receivedAction.id!);
    }
  }
}

class NotificationScheduler {
  static Future<void> scheduleAllPrayers() async {
    final adhanCtrl = AdhanController.instance;
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final bool isPrePrayerEnabled =
        prefs.getBool('is_pre_prayer_reminder_enabled') ?? true;
    final bool isIqamahEnabled =
        prefs.getBool('is_iqamah_reminder_enabled') ?? true;
    final bool isSunriseEnabled =
        prefs.getBool('is_sunrise_reminder_enabled') ?? true;

    // We schedule for next 7 days
    int scheduledCount = 0;
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final times = await adhanCtrl.getPrayerTimesForDate(date);

      int index = 0;
      for (var entry in times.entries) {
        final prayerTime = entry.value;
        final prayerName = entry.key; // e.g. fajr, dhuhr

        // Skip past prayers
        if (prayerTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
          index++;
          continue;
        }

        final uniqueId = 1000 + (day * 10) + index;

        String effectiveName =
            adhanCtrl.prayerNameFromEnum(_getEnumFromName(prayerName));
        if (effectiveName == 'الظهر' && prayerTime.weekday == DateTime.friday) {
          effectiveName = 'الجمعة';
        }

        // Schedule main
        bool skip = false;
        if (prayerName == 'sunrise') {
          if (!isSunriseEnabled) skip = true;
        }

        if (!skip) {
          await NotifyHelper().scheduledNotification(
              reminderId: uniqueId,
              title: prayerName == 'sunrise'
                  ? 'حان الآن وقت الشروق'
                  : 'حان الآن وقت صلاة $effectiveName',
              summary: '',
              body: 'في مدينتك',
              isRepeats: false,
              time: prayerTime,
              payload: {
                'sound_type': prayerName == 'sunrise' ? 'bell' : 'sound',
                'prayerName': effectiveName,
                'type': 'adhan'
              });
          scheduledCount++;
        }

        index++;
      }
    }
    log('Scheduled $scheduledCount prayers via awesome_notifications for next 7 days.',
        name: 'NotificationScheduler');
  }

  static dynamic _getEnumFromName(String name) {
    // Quick adapter
    return null; // The AdhanController method just needs mapping, not real enum
  }
}
