import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import '../mainView/controllar/MainController.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';

class SettingsController extends GetxController {
  final BuildContext context;
  late final CentralizedCubit cubit;

  SettingsController(this.context) {
    cubit = CentralizedCubit.get(context);
  }

  // --- Theme Management ---
  ThemeMode get currentTheme => cubit.themeMode();

  void setThemeMode(ThemeMode mode) {
    cubit.setThemeMode(mode);
    update();
  }

  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
      case ThemeMode.light:
        return 'فاتح ☀️';
      case ThemeMode.dark:
        return 'داكن 🌙';
    }
  }

  // --- Font Size Management ---
  double get azkarFontSize => cubit.azkarFontSize();
  double get hadithFontSize => cubit.hadithFontSize();

  void setAzkarFontSize(double value) {
    cubit.setAzkarFontSize(value);
    update();
  }

  void setHadithFontSize(double value) {
    cubit.setHadithFontSize(value);
    update();
  }

  // --- Hijri Management ---
  int get hijriAdjustment => MainController.instance.hijriAdjustment;

  void setHijriAdjustment(int newValue) {
    MainController.instance.setHijriAdjustment(newValue);
    update();
  }

  // --- External Links ---
  Future<void> launchTelegram() async {
    final Uri url = Uri.parse('https://t.me/rafiqMuslim');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // --- Screen Awake Management ---
  bool get isKeepScreenAwake => SettingsService().isKeepScreenAwakeEnabled;

  void setKeepScreenAwake(bool value) {
    SettingsService().setKeepScreenAwakeEnabled(value);
    update();
  }
}
