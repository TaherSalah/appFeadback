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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Adhan ---
  bool get isAdhanEnabled => _prefs.getBool(_kIsAdhanEnabled) ?? true;
  Future<void> setAdhanEnabled(bool value) async {
    await _prefs.setBool(_kIsAdhanEnabled, value);
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
}
