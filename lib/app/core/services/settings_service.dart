import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  // Keys
  static const String _kIsAdhanEnabled = 'is_adhan_enabled';
  static const String _kIsAzkarSabahEnabled = 'is_azkar_sabah_enabled';
  static const String _kIsAzkarMassaEnabled = 'is_azkar_massa_enabled';
  static const String _kIsAzkarSleepEnabled = 'is_azkar_sleep_enabled';
  static const String _kIsQiyamEnabled = 'is_qiyam_enabled';
  static const String _kIsSalatAlaNabiEnabled = 'is_salat_ala_nabi_enabled';

  static const String _kFajrAlarmEnabled = 'fajr_alarm_enabled';
  static const String _kFajrAlarmHour = 'fajr_alarm_hour';
  static const String _kFajrAlarmMinute = 'fajr_alarm_minute';
  static const String _kFajrAlarmDays = 'fajr_alarm_days';
  static const String _kFajrAlarmRepetitions = 'fajr_alarm_repetitions';
  static const String _kFajrAlarmVibrate = 'fajr_alarm_vibrate';
  static const String _kFajrAlarmFadeIn = 'fajr_alarm_fade_in';

  // New Reminders
  static const String _kIsFastingReminderEnabled =
      'is_fasting_reminder_enabled';
  static const String _kIsFridayRemindersEnabled =
      'is_friday_reminders_enabled';
  static const String _kIsDailyQuranReminderEnabled =
      'is_daily_quran_reminder_enabled';
  static const String _kIsWhiteDaysReminderEnabled =
      'is_white_days_reminder_enabled';
  static const String _kIsReligiousOccasionsEnabled =
      'is_religious_occasions_enabled';
  static const String _kIsMulkReminderEnabled = 'is_mulk_reminder_enabled';
  static const String _kIsDuhaReminderEnabled = 'is_duha_reminder_enabled';
  static const String _kIsSunnahReminderEnabled = 'is_sunnah_reminder_enabled';
  static const String _kIsBetweenAdhanIqamahEnabled =
      'is_between_adhan_iqamah_enabled';
  static const String _kIsMuteActionEnabled = 'is_mute_action_enabled';
  static const String _kIsStopActionEnabled = 'is_stop_action_enabled';
  static const String _kIsAutoSilentEnabled = 'is_auto_silent_enabled';
  static const String _kAutoSilentDuration = 'auto_silent_duration';
  static const String _kIsAutoLocationEnabled = 'is_auto_location_enabled';
  static const String _kIsHomeWidgetEnabled = 'is_home_widget_enabled';
  static const String _kIsNightSilentModeEnabled = 'is_night_silent_mode_enabled';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Adhan ---
  bool get isAdhanEnabled => _prefs.getBool(_kIsAdhanEnabled) ?? true;
  Future<void> setAdhanEnabled(bool value) async {
    await _prefs.setBool(_kIsAdhanEnabled, value);
  }

  static const String _kIsAdhanVibrationEnabled = 'is_adhan_vibration_enabled';
  bool get isAdhanVibrationEnabled =>
      _prefs.getBool(_kIsAdhanVibrationEnabled) ?? false;
  Future<void> setAdhanVibrationEnabled(bool value) async {
    await _prefs.setBool(_kIsAdhanVibrationEnabled, value);
  }

  static const String _kIsPrePrayerReminderEnabled =
      'is_pre_prayer_reminder_enabled';
  bool get isPrePrayerReminderEnabled =>
      _prefs.getBool(_kIsPrePrayerReminderEnabled) ?? true;
  Future<void> setPrePrayerReminderEnabled(bool value) async {
    await _prefs.setBool(_kIsPrePrayerReminderEnabled, value);
  }

  static const String _kIsIqamahReminderEnabled = 'is_iqamah_reminder_enabled';
  bool get isIqamahReminderEnabled =>
      _prefs.getBool(_kIsIqamahReminderEnabled) ?? true;
  Future<void> setIqamahReminderEnabled(bool value) async {
    await _prefs.setBool(_kIsIqamahReminderEnabled, value);
  }

  static const String _kIsSunriseReminderEnabled =
      'is_sunrise_reminder_enabled';
  bool get isSunriseReminderEnabled =>
      _prefs.getBool(_kIsSunriseReminderEnabled) ?? true;
  Future<void> setSunriseReminderEnabled(bool value) async {
    await _prefs.setBool(_kIsSunriseReminderEnabled, value);
  }

  static const String _kIsContinuousShuruqEnabled =
      'is_continuous_shuruq_enabled';
  bool get isContinuousShuruqEnabled =>
      _prefs.getBool(_kIsContinuousShuruqEnabled) ?? false;
  Future<void> setContinuousShuruqEnabled(bool value) async {
    await _prefs.setBool(_kIsContinuousShuruqEnabled, value);
  }

  static const String _kIsPostPrayerReminderEnabled =
      'post_prayer_reminder_enabled';
  bool get isPostPrayerReminderEnabled =>
      _prefs.getBool(_kIsPostPrayerReminderEnabled) ?? false;
  Future<void> setPostPrayerReminderEnabled(bool value) async {
    await _prefs.setBool(_kIsPostPrayerReminderEnabled, value);
  }

  static const String _kPostReminderMinutes = 'post_reminder_minutes';
  int get postReminderMinutes => _prefs.getInt(_kPostReminderMinutes) ?? 10;
  Future<void> setPostReminderMinutes(int value) async {
    await _prefs.setInt(_kPostReminderMinutes, value);
  }

  // --- Azkar ---
  bool get isAzkarSabahEnabled => _prefs.getBool(_kIsAzkarSabahEnabled) ?? true;
  Future<void> setAzkarSabahEnabled(bool value) async {
    await _prefs.setBool(_kIsAzkarSabahEnabled, value);
  }

  bool get isAzkarMassaEnabled => _prefs.getBool(_kIsAzkarMassaEnabled) ?? true;
  Future<void> setAzkarMassaEnabled(bool value) async {
    await _prefs.setBool(_kIsAzkarMassaEnabled, value);
  }

  bool get isAzkarSleepEnabled => _prefs.getBool(_kIsAzkarSleepEnabled) ?? true;
  Future<void> setAzkarSleepEnabled(bool value) async {
    await _prefs.setBool(_kIsAzkarSleepEnabled, value);
  }

  bool get isQiyamEnabled => _prefs.getBool(_kIsQiyamEnabled) ?? true;
  Future<void> setQiyamEnabled(bool value) async {
    await _prefs.setBool(_kIsQiyamEnabled, value);
  }

  // --- Salat Ala Nabi ---
  bool get isSalatAlaNabiEnabled =>
      _prefs.getBool(_kIsSalatAlaNabiEnabled) ?? true;
  Future<void> setSalatAlaNabiEnabled(bool value) async {
    await _prefs.setBool(_kIsSalatAlaNabiEnabled, value);
  }

  // --- Adhan Overlay ---
  static const String _kIsAdhanOverlayEnabled = 'is_adhan_overlay_enabled';
  bool get isAdhanOverlayEnabled =>
      _prefs.getBool(_kIsAdhanOverlayEnabled) ?? false;
  Future<void> setAdhanOverlayEnabled(bool value) async {
    await _prefs.setBool(_kIsAdhanOverlayEnabled, value);
  }

  static const String _kSalatAlaNabiFrequencyMinutes =
      'salat_ala_nabi_frequency_minutes';

  int getSalatAlaNabiMinutes() {
    return _prefs.getInt(_kSalatAlaNabiFrequencyMinutes) ??
        15; // Default to 15 min
  }

  Future<void> setSalatAlaNabiMinutes(int minutes) async {
    await _prefs.setInt(_kSalatAlaNabiFrequencyMinutes, minutes);
  }

  // --- Advanced Fajr Alarm ---
  bool get isFajrAlarmEnabled => _prefs.getBool(_kFajrAlarmEnabled) ?? false;
  Future<void> setFajrAlarmEnabled(bool value) async =>
      await _prefs.setBool(_kFajrAlarmEnabled, value);

  int get fajrAlarmHour => _prefs.getInt(_kFajrAlarmHour) ?? 4;
  Future<void> setFajrAlarmHour(int value) async =>
      await _prefs.setInt(_kFajrAlarmHour, value);

  int get fajrAlarmMinute => _prefs.getInt(_kFajrAlarmMinute) ?? 0;
  Future<void> setFajrAlarmMinute(int value) async =>
      await _prefs.setInt(_kFajrAlarmMinute, value);

  List<int> get fajrAlarmDays =>
      _prefs.getStringList(_kFajrAlarmDays)?.map(int.parse).toList() ??
      [1, 2, 3, 4, 5, 6, 7];
  Future<void> setFajrAlarmDays(List<int> days) async => await _prefs
      .setStringList(_kFajrAlarmDays, days.map((e) => e.toString()).toList());

  int get fajrAlarmRepetitions => _prefs.getInt(_kFajrAlarmRepetitions) ?? 1;
  Future<void> setFajrAlarmRepetitions(int value) async =>
      await _prefs.setInt(_kFajrAlarmRepetitions, value);

  bool get fajrAlarmVibrate => _prefs.getBool(_kFajrAlarmVibrate) ?? true;
  Future<void> setFajrAlarmVibrate(bool value) async =>
      await _prefs.setBool(_kFajrAlarmVibrate, value);

  bool get fajrAlarmFadeIn => _prefs.getBool(_kFajrAlarmFadeIn) ?? false;
  Future<void> setFajrAlarmFadeIn(bool value) async =>
      await _prefs.setBool(_kFajrAlarmFadeIn, value);

  // --- New Reminders ---
  bool get isFastingReminderEnabled =>
      _prefs.getBool(_kIsFastingReminderEnabled) ?? false;
  Future<void> setFastingReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsFastingReminderEnabled, value);

  bool get isFridayRemindersEnabled =>
      _prefs.getBool(_kIsFridayRemindersEnabled) ?? true;
  Future<void> setFridayRemindersEnabled(bool value) async =>
      await _prefs.setBool(_kIsFridayRemindersEnabled, value);

  bool get isDailyQuranReminderEnabled =>
      _prefs.getBool(_kIsDailyQuranReminderEnabled) ?? true;
  Future<void> setDailyQuranReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsDailyQuranReminderEnabled, value);

  bool get isWhiteDaysReminderEnabled =>
      _prefs.getBool(_kIsWhiteDaysReminderEnabled) ?? true;
  Future<void> setWhiteDaysReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsWhiteDaysReminderEnabled, value);

  bool get isReligiousOccasionsEnabled =>
      _prefs.getBool(_kIsReligiousOccasionsEnabled) ?? true;
  Future<void> setReligiousOccasionsEnabled(bool value) async =>
      await _prefs.setBool(_kIsReligiousOccasionsEnabled, value);

  bool get isMulkReminderEnabled =>
      _prefs.getBool(_kIsMulkReminderEnabled) ?? true;
  Future<void> setMulkReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsMulkReminderEnabled, value);

  bool get isDuhaReminderEnabled =>
      _prefs.getBool(_kIsDuhaReminderEnabled) ?? true;
  Future<void> setDuhaReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsDuhaReminderEnabled, value);

  bool get isSunnahReminderEnabled =>
      _prefs.getBool(_kIsSunnahReminderEnabled) ?? true;
  Future<void> setSunnahReminderEnabled(bool value) async =>
      await _prefs.setBool(_kIsSunnahReminderEnabled, value);

  bool get isBetweenAdhanIqamahEnabled =>
      _prefs.getBool(_kIsBetweenAdhanIqamahEnabled) ?? true;
  Future<void> setBetweenAdhanIqamahEnabled(bool value) async =>
      await _prefs.setBool(_kIsBetweenAdhanIqamahEnabled, value);

  // --- Premium Features ---
  bool get isMuteActionEnabled => _prefs.getBool(_kIsMuteActionEnabled) ?? true;
  Future<void> setMuteActionEnabled(bool value) async =>
      await _prefs.setBool(_kIsMuteActionEnabled, value);

  bool get isStopActionEnabled => _prefs.getBool(_kIsStopActionEnabled) ?? true;
  Future<void> setStopActionEnabled(bool value) async =>
      await _prefs.setBool(_kIsStopActionEnabled, value);

  bool get isAutoSilentEnabled =>
      _prefs.getBool(_kIsAutoSilentEnabled) ?? false;
  Future<void> setAutoSilentEnabled(bool value) async =>
      await _prefs.setBool(_kIsAutoSilentEnabled, value);

  int get autoSilentDuration => _prefs.getInt(_kAutoSilentDuration) ?? 20;
  Future<void> setAutoSilentDuration(int value) async =>
      await _prefs.setInt(_kAutoSilentDuration, value);

  // --- Location & Widget ---
  bool get isAutoLocationEnabled =>
      _prefs.getBool(_kIsAutoLocationEnabled) ?? true;
  Future<void> setAutoLocationEnabled(bool value) async =>
      await _prefs.setBool(_kIsAutoLocationEnabled, value);

  bool get isHomeWidgetEnabled => _prefs.getBool(_kIsHomeWidgetEnabled) ?? true;
  Future<void> setHomeWidgetEnabled(bool value) async =>
      await _prefs.setBool(_kIsHomeWidgetEnabled, value);

  // --- Night Silent Mode ---
  bool get isNightSilentModeEnabled => _prefs.getBool(_kIsNightSilentModeEnabled) ?? true;
  Future<void> setNightSilentModeEnabled(bool value) async =>
      await _prefs.setBool(_kIsNightSilentModeEnabled, value);

  // --- Smart Tracking ---
  static const String _kIsQuranTrackingEnabled = 'is_quran_tracking_enabled';
  bool get isQuranTrackingEnabled => _prefs.getBool(_kIsQuranTrackingEnabled) ?? true;
  Future<void> setQuranTrackingEnabled(bool value) async =>
      await _prefs.setBool(_kIsQuranTrackingEnabled, value);

  static const String _kIsSabahTrackingEnabled = 'is_sabah_tracking_enabled';
  bool get isSabahTrackingEnabled => _prefs.getBool(_kIsSabahTrackingEnabled) ?? true;
  Future<void> setSabahTrackingEnabled(bool value) async =>
      await _prefs.setBool(_kIsSabahTrackingEnabled, value);

  static const String _kIsMassaTrackingEnabled = 'is_massa_tracking_enabled';
  bool get isMassaTrackingEnabled => _prefs.getBool(_kIsMassaTrackingEnabled) ?? true;
  Future<void> setMassaTrackingEnabled(bool value) async =>
      await _prefs.setBool(_kIsMassaTrackingEnabled, value);

  static const String _kIsAppAbsenceTrackingEnabled = 'is_app_absence_tracking_enabled';
  bool get isAppAbsenceTrackingEnabled => _prefs.getBool(_kIsAppAbsenceTrackingEnabled) ?? true;
  Future<void> setAppAbsenceTrackingEnabled(bool value) async =>
      await _prefs.setBool(_kIsAppAbsenceTrackingEnabled, value);
}
