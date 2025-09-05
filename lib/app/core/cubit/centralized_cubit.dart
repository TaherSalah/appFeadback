// ignore_for_file: avoid_print

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cache/storage.dart';
import '../localization/localization_manager.dart';
import '../utils/log.dart';

part 'centralized_state.dart';

class CentralizedCubit extends Cubit<CentralizedState> {
  SharedPreferences sharedPreferences;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static CentralizedCubit get(context) =>
      BlocProvider.of<CentralizedCubit>(context);

  CentralizedCubit({required this.sharedPreferences})
      : super(CentralizedInitial());

  static bool isDarkMode = false;

  ThemeMode themeMode() {
    ThemeMode theme = ThemeMode.system;
    bool? value = sharedPreferences.getBool("isDark");
    if (value != null) {
      if (value) {
        theme = ThemeMode.dark;
        isDarkMode = true;
      } else {
        theme = ThemeMode.light;
        isDarkMode = false;
      }
    } else {
      theme = ThemeMode.system;
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
    }
    return theme;
  }

  void changeThemeMode() async {
    isDarkMode = !isDarkMode;
    await sharedPreferences.setBool("isDark", isDarkMode);
    sharedPreferences.reload();
    emit(ThemeState());
  }

  // void localization() {
  //   // log("_getDeviceLanguage()", msg: _isDeviceLanguageAr());
  //   LocalizationManager.isEn = (sharedPreferences.getBool("isEn") ?? true);
  // }
  // void localization() {
  //   bool? storedLang = sharedPreferences.getBool("isEn");
  //   if (storedLang != null) {
  //     LocalizationManager.isEn = storedLang;
  //   } else {
  //     LocalizationManager.isEn = false; // Default to Arabic
  //   }
  // }

  // void changeLangage() async {
  //   LocalizationManager.change();
  //   await sharedPreferences.setBool("isEn", false);
  //   // await sharedPreferences.setBool("isEn", true);
  //   emit(LocalizationState());
  // }

  void localization() {
    log("_getDeviceLanguage()", msg: _isDeviceLanguageAr());
    LocalizationManager.isEn =
        // (sharedPreferences.getBool("isEn") ?? !_isDeviceLanguageAr());
        // (KStorage.i.getIsEg ?? !_isDeviceLanguageAr());
        (KStorage.i.getIsEg ?? false);
  }

  void changeLangage() async {
    LocalizationManager.change();
    await KStorage.i.setIsEng(LocalizationManager.isEn);
    // await sharedPreferences.setBool("isEn", LocalizationManager.isEn);
    emit(LocalizationState());
  }

  bool textDirectionEn = true;

  void onChangetext(String value) {
    value = value.trim();
    if (value.length == 1) {
      // print(value.trim().codeUnitAt(0));
      if (value.trim().codeUnitAt(0) <= 127) {
        textDirectionEn = true;
      } else {
        textDirectionEn = false;
      }
      emit(OnChangetextState());
    }
  }

  bool _isDeviceLanguageAr() {
    final String defaultLocale = Platform.localeName;
    log("defaultLocale", msg: defaultLocale);

    return defaultLocale.toLowerCase().startsWith(RegExp("ar"));
  }

// void changeLanguageInApp(context) {
//   CentralizedCubit.get(context).changeLangage();
//   emit(ChangeLanguageState());
// }

  // void _updateConnectivity(ConnectivityResult connectionResult) {
  //   if (connectionResult == ConnectivityResult.none) {
  //     emit(ConnectivityState(status: ConnectivityStatus.disconnected));
  //     print('ConnectivityState in updateConnectivity disconnected');
  //   } else {
  //     emit(ConnectivityState(status: ConnectivityStatus.connected));
  //     print('ConnectivityState in updateConnectivity connected');
  //   }
  // }

  void checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();

      if (result == ConnectivityResult.none) {
        emit(ConnectivityState(status: ConnectivityStatus.disconnected));
        log('ConnectivityState: disconnected');
      } else {
        emit(ConnectivityState(status: ConnectivityStatus.connected));
        log('ConnectivityState: connected');
      }
    } catch (e) {
      log('Error checking connectivity: $e');
      // Optionally emit a special state or log this
    }
  }


  // StreamSubscription<ConnectivityResult?>? _streamSubscription;

  void trackConnectivityChange() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // For simplicity, let's just take the first result (you can modify this logic as needed)
      final result = results.first;

      if (result == ConnectivityResult.none) {
        emit(ConnectivityState(status: ConnectivityStatus.disconnected));
      } else {
        emit(ConnectivityState(status: ConnectivityStatus.connected));
      }

      print('Tracked connectivity change => $result');
    });
  }

// void dispose() {
//   _streamSubscription?.cancel();
// }
}
