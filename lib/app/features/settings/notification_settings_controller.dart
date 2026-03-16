import 'package:get/get.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class NotificationSettingsController extends GetxController {
  final SettingsService _settings = SettingsService();

  // Observable states
  final isAdhanEnabled = false.obs;
  final isAdhanVibrationEnabled = false.obs;
  final isAdhanOverlayEnabled = false.obs;
  final isPrePrayerReminderEnabled = false.obs;
  final isIqamahReminderEnabled = false.obs;
  final isSunriseReminderEnabled = false.obs;
  final isContinuousShuruqEnabled = false.obs;
  final isPostPrayerReminderEnabled = false.obs;
  final postReminderMinutes = 10.obs;
  final isAzkarSabahEnabled = false.obs;
  final isAzkarMassaEnabled = false.obs;
  final isAzkarSleepEnabled = false.obs;
  final isQiyamEnabled = false.obs;
  final isSalatAlaNabiEnabled = false.obs;
  final salatFrequency = 5.obs;

  // New Reminders
  final isFastingReminderEnabled = false.obs;
  final isFridayRemindersEnabled = false.obs;
  final isDailyQuranReminderEnabled = false.obs;
  final isWhiteDaysReminderEnabled = false.obs;
  final isReligiousOccasionsEnabled = false.obs;
  final isMulkReminderEnabled = false.obs;
  final isDuhaReminderEnabled = false.obs;
  final isSunnahReminderEnabled = false.obs;
  final isBetweenAdhanIqamahEnabled = false.obs;
  final isMuteActionEnabled = false.obs;
  final isStopActionEnabled = false.obs;
  final isAutoSilentEnabled = false.obs;
  final autoSilentDuration = 15.obs;

  final hasChanges = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentSettings();
  }

  void loadCurrentSettings() {
    isAdhanEnabled.value = _settings.isAdhanEnabled;
    isAdhanVibrationEnabled.value = _settings.isAdhanVibrationEnabled;
    isAdhanOverlayEnabled.value = _settings.isAdhanOverlayEnabled;
    isPrePrayerReminderEnabled.value = _settings.isPrePrayerReminderEnabled;
    isIqamahReminderEnabled.value = _settings.isIqamahReminderEnabled;
    isSunriseReminderEnabled.value = _settings.isSunriseReminderEnabled;
    isContinuousShuruqEnabled.value = _settings.isContinuousShuruqEnabled;
    isPostPrayerReminderEnabled.value = _settings.isPostPrayerReminderEnabled;
    postReminderMinutes.value = _settings.postReminderMinutes;
    isAzkarSabahEnabled.value = _settings.isAzkarSabahEnabled;
    isAzkarMassaEnabled.value = _settings.isAzkarMassaEnabled;
    isAzkarSleepEnabled.value = _settings.isAzkarSleepEnabled;
    isQiyamEnabled.value = _settings.isQiyamEnabled;
    isSalatAlaNabiEnabled.value = _settings.isSalatAlaNabiEnabled;
    salatFrequency.value = _settings.getSalatAlaNabiMinutes();

    // New Reminders
    isFastingReminderEnabled.value = _settings.isFastingReminderEnabled;
    isFridayRemindersEnabled.value = _settings.isFridayRemindersEnabled;
    isDailyQuranReminderEnabled.value = _settings.isDailyQuranReminderEnabled;
    isWhiteDaysReminderEnabled.value = _settings.isWhiteDaysReminderEnabled;
    isReligiousOccasionsEnabled.value = _settings.isReligiousOccasionsEnabled;
    isMulkReminderEnabled.value = _settings.isMulkReminderEnabled;
    isDuhaReminderEnabled.value = _settings.isDuhaReminderEnabled;
    isSunnahReminderEnabled.value = _settings.isSunnahReminderEnabled;
    isBetweenAdhanIqamahEnabled.value = _settings.isBetweenAdhanIqamahEnabled;
    isMuteActionEnabled.value = _settings.isMuteActionEnabled;
    isStopActionEnabled.value = _settings.isStopActionEnabled;
    isAutoSilentEnabled.value = _settings.isAutoSilentEnabled;
    autoSilentDuration.value = _settings.autoSilentDuration;

    hasChanges.value = false;
  }

  void updateChange(Rx<dynamic> field, dynamic newValue) {
    if (field.value != newValue) {
      field.value = newValue;
      hasChanges.value = true;
    }
  }

  Future<void> saveAll() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _settings.setAdhanEnabled(isAdhanEnabled.value);
      await _settings.setAdhanVibrationEnabled(isAdhanVibrationEnabled.value);
      await _settings.setAdhanOverlayEnabled(isAdhanOverlayEnabled.value);
      await _settings.setPrePrayerReminderEnabled(isPrePrayerReminderEnabled.value);
      await _settings.setIqamahReminderEnabled(isIqamahReminderEnabled.value);
      await _settings.setSunriseReminderEnabled(isSunriseReminderEnabled.value);
      await _settings.setContinuousShuruqEnabled(isContinuousShuruqEnabled.value);
      await _settings.setPostPrayerReminderEnabled(isPostPrayerReminderEnabled.value);
      await _settings.setPostReminderMinutes(postReminderMinutes.value);
      await _settings.setAzkarSabahEnabled(isAzkarSabahEnabled.value);
      await _settings.setAzkarMassaEnabled(isAzkarMassaEnabled.value);
      await _settings.setAzkarSleepEnabled(isAzkarSleepEnabled.value);
      await _settings.setQiyamEnabled(isQiyamEnabled.value);
      await _settings.setSalatAlaNabiEnabled(isSalatAlaNabiEnabled.value);
      await _settings.setSalatAlaNabiMinutes(salatFrequency.value);

      // New Reminders
      await _settings.setFastingReminderEnabled(isFastingReminderEnabled.value);
      await _settings.setFridayRemindersEnabled(isFridayRemindersEnabled.value);
      await _settings.setDailyQuranReminderEnabled(isDailyQuranReminderEnabled.value);
      await _settings.setWhiteDaysReminderEnabled(isWhiteDaysReminderEnabled.value);
      await _settings.setReligiousOccasionsEnabled(isReligiousOccasionsEnabled.value);
      await _settings.setMulkReminderEnabled(isMulkReminderEnabled.value);
      await _settings.setDuhaReminderEnabled(isDuhaReminderEnabled.value);
      await _settings.setSunnahReminderEnabled(isSunnahReminderEnabled.value);
      await _settings.setBetweenAdhanIqamahEnabled(isBetweenAdhanIqamahEnabled.value);
      await _settings.setMuteActionEnabled(isMuteActionEnabled.value);
      await _settings.setStopActionEnabled(isStopActionEnabled.value);
      await _settings.setAutoSilentEnabled(isAutoSilentEnabled.value);
      await _settings.setAutoSilentDuration(autoSilentDuration.value);

      // Trigger notification rescheduling
      await NotificationManager().rescheduleAll();

      KHelper.showSuccess(message: 'تم حفظ الإعدادات وتحديث التنبيهات بنجاح');
      hasChanges.value = false;
    } catch (e) {
      KHelper.showError(message: 'حدث خطأ أثناء حفظ الإعدادات');
    } finally {
      isLoading.value = false;
    }
  }
}
