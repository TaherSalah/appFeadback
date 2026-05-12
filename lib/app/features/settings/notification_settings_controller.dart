import 'dart:developer';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class NotificationSettingsController extends GetxController {
  final SettingsService _settings = SettingsService();

  // Observable states
  final isAdhanEnabled = false.obs;
  final isAdhanVibrationEnabled = false.obs;
  final isFullAdhanEnabled = true.obs;
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
  final isNightSilentModeEnabled = true.obs;
  
  final isQuranTrackingEnabled = true.obs;
  final isSabahTrackingEnabled = true.obs;
  final isMassaTrackingEnabled = true.obs;
  final nightSilentStartHour = 0.obs;
  final nightSilentEndHour = 6.obs;

  final hasChanges = false.obs;
  final isLoading = false.obs;

  // Dirty flags for selective rescheduling
  bool _isAdhanDirty = false;
  bool _isAzkarDirty = false;
  bool _isSalatAlaNabiDirty = false;
  bool _isRemindersDirty = false;

  @override
  void onInit() {
    super.onInit();
    loadCurrentSettings();
  }

  void loadCurrentSettings() {
    isAdhanEnabled.value = _settings.isAdhanEnabled;
    isAdhanVibrationEnabled.value = _settings.isAdhanVibrationEnabled;
    isFullAdhanEnabled.value = _settings.isFullAdhanEnabled;
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
    isNightSilentModeEnabled.value = _settings.isNightSilentModeEnabled;
    
    isQuranTrackingEnabled.value = _settings.isQuranTrackingEnabled;
    isSabahTrackingEnabled.value = _settings.isSabahTrackingEnabled;
    isMassaTrackingEnabled.value = _settings.isMassaTrackingEnabled;
    nightSilentStartHour.value = _settings.nightSilentStartHour;
    nightSilentEndHour.value = _settings.nightSilentEndHour;

    hasChanges.value = false;
    _isAdhanDirty = false;
    _isAzkarDirty = false;
    _isSalatAlaNabiDirty = false;
    _isRemindersDirty = false;
  }

  void updateChange(Rx<dynamic> field, dynamic newValue) {
    if (field.value != newValue) {
      field.value = newValue;
      hasChanges.value = true;
      _markDirty(field);
    }
  }

  void _markDirty(Rx<dynamic> field) {
    // Categorize settings to decide what needs rescheduling
    if (field == isAdhanEnabled || 
        field == isAdhanVibrationEnabled || 
        field == isFullAdhanEnabled ||
        field == isAdhanOverlayEnabled ||
        field == isPrePrayerReminderEnabled ||
        field == isIqamahReminderEnabled ||
        field == isSunriseReminderEnabled ||
        field == isContinuousShuruqEnabled ||
        field == isBetweenAdhanIqamahEnabled) {
      _isAdhanDirty = true;
    } else if (field == isAzkarSabahEnabled ||
               field == isAzkarMassaEnabled ||
               field == isAzkarSleepEnabled ||
               field == isQiyamEnabled ||
               field == isPostPrayerReminderEnabled ||
               field == postReminderMinutes ||
               field == isDuhaReminderEnabled) {
      _isAzkarDirty = true;
    } else if (field == isSalatAlaNabiEnabled ||
               field == salatFrequency) {
      _isSalatAlaNabiDirty = true;
    } else if (field == isFastingReminderEnabled ||
               field == isFridayRemindersEnabled ||
               field == isDailyQuranReminderEnabled ||
               field == isWhiteDaysReminderEnabled ||
               field == isReligiousOccasionsEnabled ||
               field == isMulkReminderEnabled ||
               field == isSunnahReminderEnabled) {
      _isRemindersDirty = true;
    } else if (field == isNightSilentModeEnabled || 
               field == nightSilentStartHour || 
               field == nightSilentEndHour) {
      // Night mode affects both Azkar and Salawat filters
      _isAzkarDirty = true;
      _isSalatAlaNabiDirty = true;
    }
  }

  Future<void> saveAll() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _settings.setAdhanEnabled(isAdhanEnabled.value);
      await _settings.setAdhanVibrationEnabled(isAdhanVibrationEnabled.value);
      await _settings.setFullAdhanEnabled(isFullAdhanEnabled.value);
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
      await _settings.setNightSilentModeEnabled(isNightSilentModeEnabled.value);
      
      await _settings.setQuranTrackingEnabled(isQuranTrackingEnabled.value);
      await _settings.setSabahTrackingEnabled(isSabahTrackingEnabled.value);
      await _settings.setMassaTrackingEnabled(isMassaTrackingEnabled.value);
      await _settings.setNightSilentStartHour(nightSilentStartHour.value);
      await _settings.setNightSilentEndHour(nightSilentEndHour.value);

      // Trigger notification rescheduling. 
      // 🛠️ [Improvement]: We now reschedule if the category is "dirty" OR if it's currently "enabled".
      // This ensures that clicking "Save" acts as a "Repair" for any notifications the OS might have killed.
      bool shouldRescheduleSalawat = _isSalatAlaNabiDirty || isSalatAlaNabiEnabled.value;
      bool shouldRescheduleAzkar = _isAzkarDirty || (isAzkarSabahEnabled.value || isAzkarMassaEnabled.value || isAzkarSleepEnabled.value);
      bool shouldRescheduleAdhan = _isAdhanDirty || isAdhanEnabled.value;
      bool shouldRescheduleReminders = _isRemindersDirty;

      if (shouldRescheduleAdhan || shouldRescheduleAzkar || shouldRescheduleSalawat || shouldRescheduleReminders) {
        await NotificationManager().rescheduleAll(
          adhan: shouldRescheduleAdhan,
          azkar: shouldRescheduleAzkar,
          salawat: shouldRescheduleSalawat,
          reminders: shouldRescheduleReminders,
        );
      }

      KHelper.showSuccess(message: 'تم حفظ الإعدادات وتحديث التنبيهات بنجاح');
      hasChanges.value = false;
      _isAdhanDirty = false;
      _isAzkarDirty = false;
      _isSalatAlaNabiDirty = false;
      _isRemindersDirty = false;
    } catch (e, stack) {
      log('❌ Error saving settings: $e', name: 'NotificationSettingsController');
      log(stack.toString(), name: 'NotificationSettingsController');
      KHelper.showError(message: 'حدث خطأ أثناء حفظ الإعدادات: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
