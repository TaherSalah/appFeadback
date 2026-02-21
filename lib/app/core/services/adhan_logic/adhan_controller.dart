import 'dart:async';
import 'dart:developer' show log;

import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart';

import 'adhan_state.dart';
import 'prayer_cache_manager.dart';
import 'monthly_prayer_cache.dart';

/// AdhanController – lifted from almasjid-main, adapted for rafuiqElmuslim.
/// This controller is UI-agnostic: it calculates prayer times, caches them,
/// and exposes observables that any widget can consume.
class AdhanController extends GetxController {
  static AdhanController get instance =>
      GetInstance().putOrFind(() => AdhanController());

  AdhanState state = AdhanState();

  int _lastCurrentPrayerIndex = -1;
  Timer? _currentPrayerTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _readSharedPreferences();
    await _tryInitialize();
  }

  @override
  void onClose() {
    state.timer?.cancel();
    _currentPrayerTimer?.cancel();
    super.onClose();
  }

  // ============================================================
  // Public API
  // ============================================================

  /// Returns a formatted prayer time string with optional offset.
  Future<String> getPrayerTimeString(DateTime dt) async {
    final formatted = intl.DateFormat('hh:mm a').format(dt);
    return formatted;
  }

  /// Full initialization: fetches location, calculates, caches.
  Future<void> initializeStoredAdhan({
    LatLng? currentLocation,
    LatLng? newLocation,
    bool forceUpdate = false,
  }) async {
    try {
      state.isLoadingPrayerData.value = true;
      update(['loading_state']);
      log('Initializing adhan data...', name: 'AdhanController');

      currentLocation ??= PrayerCacheManager.getStoredLocation();
      if (currentLocation == null) {
        currentLocation = await _detectCurrentLocation();
      }
      if (currentLocation == null) {
        log('No location available', name: 'AdhanController');
        state.isLoadingPrayerData.value = false;
        update(['loading_state']);
        return;
      }

      // 1. Try monthly cache
      if (!forceUpdate) {
        if (MonthlyPrayerCache.isMonthlyDataValid(
            currentLocation: currentLocation)) {
          log('Using monthly cached prayer data', name: 'AdhanController');
          if (await _loadFromMonthlyCache()) return;
        }

        // 2. Try daily cache
        if (PrayerCacheManager.isCacheValid(currentLocation: currentLocation)) {
          log('Using daily cached prayer data', name: 'AdhanController');
          final cachedData = PrayerCacheManager.getCachedPrayerData();
          if (cachedData != null && state.fromJson(cachedData)) {
            await _finalizePrayerTimeInitialization();
            return;
          }
        }
      }

      // 3. Full re-calculation
      log('Fetching new prayer data', name: 'AdhanController');
      await _fetchAndCalculatePrayerTimes(newLocation ?? currentLocation);
      await _saveToMonthlyCache(newLocation ?? currentLocation);
      await _finalizePrayerTimeInitialization();
    } catch (e) {
      log('Error initializing adhan: $e', name: 'AdhanController');
      state.isLoadingPrayerData.value = false;
      update(['loading_state']);
      await _tryUseCachedData();
    }
  }

  /// Clears cache and forces a full recalculation.
  Future<void> clearCacheAndRecalculate() async {
    state.isLoadingPrayerData.value = true;
    update(['loading_state']);
    PrayerCacheManager.clearCache();
    MonthlyPrayerCache.clearMonthlyCache();
    await initializeStoredAdhan(forceUpdate: true);
  }

  /// Returns prayer times for a specific date (uses monthly cache first).
  Future<Map<String, DateTime>> getPrayerTimesForDate(DateTime date) async {
    try {
      final cached = MonthlyPrayerCache.getPrayerTimesForDate(date);
      if (cached != null) {
        return {
          'fajr': cached.fajr,
          'sunrise': cached.sunrise,
          'dhuhr': cached.dhuhr,
          'asr': cached.asr,
          'maghrib': cached.maghrib,
          'isha': cached.isha,
          'midnight': cached.midnight,
          'lastThird': cached.lastThird,
        };
      }
    } catch (_) {}
    // Fallback: recalculate
    return _calculateForDate(date);
  }

  /// Updates selected date and recalculates.
  Future<void> updateSelectedDate(DateTime newDate) async {
    state.selectedDate = newDate;
    await _loadSelectedDateTimes(newDate);
  }

  /// Updates monthly data in background for current + next month.
  Future<void> updateMonthlyDataInBackground() async {
    try {
      final currentLocation = PrayerCacheManager.getStoredLocation();
      if (currentLocation == null) return;
      log('Updating monthly prayer data in background',
          name: 'AdhanController');
      final now = DateTime.now();
      await MonthlyPrayerCache.saveMonthlyPrayerData(
        location: currentLocation,
        params: state.params,
        month: DateTime(now.year, now.month, 1),
      );
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      await MonthlyPrayerCache.saveMonthlyPrayerData(
        location: currentLocation,
        params: state.params,
        month: nextMonth,
      );
      log('Monthly data updated successfully', name: 'AdhanController');
    } catch (e) {
      log('Error updating monthly data: $e', name: 'AdhanController');
    }
  }

  // ============================================================
  // Getters
  // ============================================================

  String prayerNameFromEnum(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'الفجر';
    }
  }

  int getCurrentPrayerIndex() {
    if (state.prayerTimes == null) return 0;
    final p = state.prayerTimes!;
    final now = state.now;
    if (now.isBefore(p.fajr)) return 7;
    if (now.isBefore(p.sunrise)) return 0;
    if (now.isBefore(p.dhuhr)) return 1;
    if (now.isBefore(p.asr)) return 2;
    if (now.isBefore(p.maghrib)) return 3;
    if (now.isBefore(p.isha)) return 4;
    return 5;
  }

  Duration getTimeLeftForNextPrayer() {
    if (state.prayerTimes == null) return Duration.zero;
    final p = state.prayerTimes!;
    final now = state.now;
    final times = [p.fajr, p.sunrise, p.dhuhr, p.asr, p.maghrib, p.isha];
    for (final t in times) {
      if (t.isAfter(now)) return t.difference(now);
    }
    // All past today → next fajr
    return p.fajr.add(const Duration(days: 1)).difference(now);
  }

  Madhab _getMadhab() => state.isHanafi ? Madhab.shafi : Madhab.hanafi;

  HighLatitudeRule _getHighLatitudeRule() {
    switch (state.highLatitudeRuleIndex.value) {
      case 1:
        return HighLatitudeRule.seventh_of_the_night;
      case 2:
        return HighLatitudeRule.twilight_angle;
      default:
        return HighLatitudeRule.middle_of_the_night;
    }
  }

  // ============================================================
  // Private helpers
  // ============================================================

  Future<void> _readSharedPreferences() async {
    state.isHanafi = state.box.read(SHAFI) ?? true;
    state.highLatitudeRuleIndex.value = state.box.read(HIGH_LATITUDE_RULE) ?? 0;
    state.autoCalculationMethod.value =
        state.box.read(AUTO_CALCULATION) ?? true;
  }

  Future<void> _tryInitialize() async {
    unawaited(initializeStoredAdhan());
    _updateProgressBar();
    Future.delayed(const Duration(seconds: 10), updateCurrentPrayer);
  }

  Future<LatLng?> _detectCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(position.latitude, position.longitude);
      PrayerCacheManager.savePrayerData({}, loc);
      return loc;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchAndCalculatePrayerTimes(LatLng location) async {
    state.coordinates = Coordinates(location.latitude, location.longitude);
    state.dateComponents = DateComponents.from(state.now);

    if (state.autoCalculationMethod.value) {
      state.params = await _getParamsByJson() ??
          CalculationMethod.egyptian.getParameters();
    } else {
      state.params = CalculationMethod.egyptian.getParameters();
    }

    state.adjustments = OurPrayerAdjustments.fromGetStorage();
    state.params.adjustments = state.adjustments;
    state.params.madhab = _getMadhab();
    state.params.highLatitudeRule = _getHighLatitudeRule();

    state.prayerTimesNow =
        PrayerTimes(state.coordinates, state.dateComponents, state.params);
    state.sunnahTimes = SunnahTimes(state.prayerTimesNow!);
    state.prayerTimes = state.prayerTimesNow;

    PrayerCacheManager.savePrayerData(state.toJson(), location);
  }

  Future<CalculationParameters?> _getParamsByJson() async {
    try {
      // Try to load madhabV2.json, fallback to Egyptian method
      await rootBundle.loadString('assets/json/madhabV2.json');
      return CalculationMethod.egyptian.getParameters();
    } catch (_) {
      return null;
    }
  }

  Future<bool> _loadFromMonthlyCache() async {
    try {
      final today = DateTime.now();
      final todayData = MonthlyPrayerCache.getPrayerTimesForDate(today);
      if (todayData != null) {
        await _setStateFromDayData(todayData);
        await _finalizePrayerTimeInitialization();
        return true;
      }
      return false;
    } catch (e) {
      log('Error loading from monthly cache: $e', name: 'AdhanController');
      return false;
    }
  }

  Future<void> _setStateFromDayData(DayPrayerTimes dayData) async {
    final loc = PrayerCacheManager.getStoredLocation();
    if (loc != null) {
      state.coordinates = Coordinates(loc.latitude, loc.longitude);
      state.dateComponents = DateComponents.from(dayData.date);
      state.params = CalculationMethod.egyptian.getParameters();
      state.prayerTimesNow =
          PrayerTimes(state.coordinates, state.dateComponents, state.params);
      state.sunnahTimes = SunnahTimes(state.prayerTimesNow!);
      state.prayerTimes = state.prayerTimesNow;
    }
  }

  Future<void> _finalizePrayerTimeInitialization() async {
    await _initTimeStrings();
    state.isPrayerTimesInitialized.value = true;
    state.isLoadingPrayerData.value = false;
    update(['loading_state', 'init_athan']);

    await _loadSelectedDateTimes(state.selectedDate);
    update(['init_athan', 'update_progress']);
    updateCurrentPrayer();
  }

  Future<void> _initTimeStrings() async {
    if (state.prayerTimes == null || state.sunnahTimes == null) return;
    state.fajrTime.value = await getPrayerTimeString(state.prayerTimes!.fajr);
    state.sunriseTime.value =
        await getPrayerTimeString(state.prayerTimes!.sunrise);
    state.dhuhrTime.value = await getPrayerTimeString(state.prayerTimes!.dhuhr);
    state.asrTime.value = await getPrayerTimeString(state.prayerTimes!.asr);
    state.maghribTime.value =
        await getPrayerTimeString(state.prayerTimes!.maghrib);
    state.ishaTime.value = await getPrayerTimeString(state.prayerTimes!.isha);
    state.midnightTime.value =
        await getPrayerTimeString(state.sunnahTimes!.middleOfTheNight);
    state.lastThirdTime.value =
        await getPrayerTimeString(state.sunnahTimes!.lastThirdOfTheNight);
  }

  Future<void> _loadSelectedDateTimes(DateTime date) async {
    try {
      final cached = MonthlyPrayerCache.getPrayerTimesForDate(date);
      if (cached != null) {
        state.selectedDateFajrTime.value =
            await getPrayerTimeString(cached.fajr);
        state.selectedDateSunriseTime.value =
            await getPrayerTimeString(cached.sunrise);
        state.selectedDateDhuhrTime.value =
            await getPrayerTimeString(cached.dhuhr);
        state.selectedDateAsrTime.value = await getPrayerTimeString(cached.asr);
        state.selectedDateMaghribTime.value =
            await getPrayerTimeString(cached.maghrib);
        state.selectedDateIshaTime.value =
            await getPrayerTimeString(cached.isha);
        state.selectedDateMidnightTime.value =
            await getPrayerTimeString(cached.midnight);
        state.selectedDateLastThirdTime.value =
            await getPrayerTimeString(cached.lastThird);
        update(['selected_date_prayers']);
        return;
      }
      // Fallback: calculate manually
      final times = await _calculateForDate(date);
      state.selectedDateFajrTime.value =
          await getPrayerTimeString(times['fajr']!);
      state.selectedDateSunriseTime.value =
          await getPrayerTimeString(times['sunrise']!);
      state.selectedDateDhuhrTime.value =
          await getPrayerTimeString(times['dhuhr']!);
      state.selectedDateAsrTime.value =
          await getPrayerTimeString(times['asr']!);
      state.selectedDateMaghribTime.value =
          await getPrayerTimeString(times['maghrib']!);
      state.selectedDateIshaTime.value =
          await getPrayerTimeString(times['isha']!);
      state.selectedDateMidnightTime.value =
          await getPrayerTimeString(times['midnight']!);
      state.selectedDateLastThirdTime.value =
          await getPrayerTimeString(times['lastThird']!);
      update(['selected_date_prayers']);
    } catch (e) {
      log('Error loading selected date times: $e', name: 'AdhanController');
    }
  }

  Future<Map<String, DateTime>> _calculateForDate(DateTime date) async {
    final coords = state.coordinates;
    final params = state.params;
    final dc = DateComponents.from(date);
    final pt = PrayerTimes(coords, dc, params);
    final st = SunnahTimes(pt);
    return {
      'fajr': pt.fajr,
      'sunrise': pt.sunrise,
      'dhuhr': pt.dhuhr,
      'asr': pt.asr,
      'maghrib': pt.maghrib,
      'isha': pt.isha,
      'midnight': st.middleOfTheNight,
      'lastThird': st.lastThirdOfTheNight,
    };
  }

  Future<void> _saveToMonthlyCache(LatLng location) async {
    try {
      final now = DateTime.now();
      await MonthlyPrayerCache.saveMonthlyPrayerData(
        location: location,
        params: state.params,
        month: DateTime(now.year, now.month, 1),
      );
      log('Data saved to monthly cache', name: 'AdhanController');
    } catch (e) {
      log('Error saving to monthly cache: $e', name: 'AdhanController');
    }
  }

  Future<void> _tryUseCachedData() async {
    try {
      final currentLocation = PrayerCacheManager.getStoredLocation();
      if (currentLocation != null &&
          MonthlyPrayerCache.isMonthlyDataValid(
              currentLocation: currentLocation)) {
        if (await _loadFromMonthlyCache()) return;
      }
      final cachedData = PrayerCacheManager.getCachedPrayerData();
      if (cachedData != null && state.fromJson(cachedData)) {
        await _finalizePrayerTimeInitialization();
        return;
      }
      log('No valid cached data available', name: 'AdhanController');
      state.isLoadingPrayerData.value = false;
      update(['init_athan', 'loading_state']);
    } catch (e) {
      log('Error in _tryUseCachedData: $e', name: 'AdhanController');
      state.isLoadingPrayerData.value = false;
      update(['loading_state']);
    }
  }

  void _updateProgressBar() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      update(['update_progress', 'init_athan']);
    });
  }

  void updateCurrentPrayer() {
    _currentPrayerTimer?.cancel();
    _lastCurrentPrayerIndex = getCurrentPrayerIndex();
    update(['update_progress', 'init_athan']);
    _scheduleNextPrayerTick();
  }

  void _scheduleNextPrayerTick() {
    final wait = _timeUntilNextPrayerChange();
    final safeWait = wait.inSeconds <= 0 ? const Duration(seconds: 1) : wait;
    _currentPrayerTimer = Timer(safeWait, () {
      final currentIndex = getCurrentPrayerIndex();
      final changed = currentIndex != _lastCurrentPrayerIndex;
      _lastCurrentPrayerIndex = currentIndex;
      if (changed) {
        update(['init_athan', 'selected_date_prayers', 'update_progress']);
      } else {
        update(['update_progress']);
      }
      _scheduleNextPrayerTick();
    });
  }

  Duration _timeUntilNextPrayerChange() {
    try {
      return getTimeLeftForNextPrayer();
    } catch (_) {
      return const Duration(seconds: 5);
    }
  }
}
