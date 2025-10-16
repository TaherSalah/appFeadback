import 'package:flutter/material.dart';

abstract class KColors {
  static ColorsGetter of(BuildContext context) {
    return ColorsGetter.of(context);
  }

  static Color yalloColor = const Color(0xffFAcc64);
  static Color whiteGrayColor = const Color(0xffF7F7F7);
  static Color darkerColor = const Color(0xff313131);
  static Color primaryColor = const Color(0xff178B74);
  static Color gray2Color = const Color(0xffB7B7B7);
  static Color greennColor = const Color(0xffE9FFE3);
  static Color orangColor = const Color(0xffFFF9C7);
  static Color orang2Color = const Color(0xffEDAE16);
  static Color black2Color = const Color(0xff252525);
  static Color primary2Color = const Color(0xff005c9a);
  static Color scoColor = const Color(0xffc1bebe);
  static Color accentColor = const Color(0x0ffe9c37);
  static Color chooseBgColor = const Color(0xffF4F5FA);
  static Color chooseBordColor = const Color(0xffd9d9d9);
  static Color whiteColor = const Color(0xffFFFFFF);
  static Color whiteDarkColor = const Color(0xffFAFBFA);
  static Color blackColor = const Color(0xff2a2a2a);
  static Color blackDarktColor = const Color(0xff191A1C);
  static Color circularPercentBg = const Color(0xFFB8C7CB);

  static Color greyColor = const Color(0xff292D32);
  static Color correctChart = const Color(0xff118B50);
  static Color wrongChart = const Color(0xffed254e);
  static Color skipChart = const Color(0xFF424242);
  static Color normalgreyColor = const Color(0xffB9B9B9);
  static Color greyDisplayText1 = const Color(0xff434343);
  static Color greyDisplayText2 = const Color(0xff414141);
  static Color greyLightColor = const Color(0xffF9F9F9);
  static Color greyLightColor2 = const Color(0xffe8e7e8);
  static Color greyDarkColor = const Color(0xff364356);
  static Color greyColorAccent = const Color(0xffFAFBFB);
  static Color messageGreyColor = const Color(0xffefefef);
  static Color blueColor = const Color(0xff22577A);
  static Color blueDarkColor = const Color(0xff031a40);
  static Color blueLightColor0 = const Color(0xff008ABF);
  static Color blueLightColor = const Color(0xff85c8ea);
  static Color blueLightColor2 = const Color(0xffc3dbf7);
  static Color blueLightColor4 = const Color(0xff84c6df);
  static Color blueLightColor5 = const Color(0xffb8deed);
  static Color blueLightColor6 = const Color(0xff6cbbe5);
  static Color blueLightColor7 = const Color(0xffb5ccf9);
  static Color greenColor = const Color(0xff4DB847);
  static Color correctBgColor = const Color(0xffEDF8EC);
  static Color correctBgColorD = Colors.green.withOpacity(0.5);
  static Color skipBgColor = const Color(0xff9AA4B2);
  static Color wrongBgColor = const Color(0xffFDE9ED);
  static Color progressBgColor = const Color(0xffE9ECEF);
  static Color wrongBordColor = const Color(0xffed254e);
  static Color wrongBgColorD = const Color(0xffAF1740);
  static Color deExplainBgColor = const Color(0xffF0F0F0);
  static Color blueLightColor3 = const Color(0xffdfeaef);
  static Color lightBlueColor = const Color(0xffDAEAF1);
  static Color yellowColor = const Color(0xffF0C929);
  static Color mustardColor = const Color(0xffFFCA28);
  static Color orangeColor = const Color(0xffff5f00);
  static Color kPrimary = const Color(0XFF1460F2);
  static Color kWhite = const Color(0XFFFFFFFF);
  static Color kOnBoardingColor = const Color(0XFFFEFEFE);
  static Color kGrayscale40 = const Color(0XFFAEAEB2);
  static Color kGrayscaleDark100 = const Color(0XFF1C1C1E);
  static Color brown = const Color(0xff886C4D);
  static Color transparentColor = Colors.transparent;
  static Color lightYellowColor = const Color(0xffF4E06D);
  static Color hintColor = const Color(0xffF4E06D);
  static Color textFieldBackgroundColor = const Color(0xFFEDF8EC);
  static Color containerBackground = const Color(0xFFDDE9DC);
  static Color containerWBackground = const Color(0xFFFAF7EF);
  // Light
  static const Color backgroundL = Color(0xFFF5F5F5);
  static const Color elevatedBoxL = Color(0xFFffffff);
  static const Color containerBgL = Color(0xFFFFFFFF);
  static const Color navBarL = Color(0xFFF8F8F8);
  static const Color actionBTNL = Color(0xFF3C3DBF);
  static const Color inActionBTNL = Color(0xFF8BD8D7);
  static const Color fabL = Color(0xFF45C0BE);
  static const Color iconL = Color(0xffE6FAF0);
  static const Color iconSL = Color(0xff031a40);
  static const Color selectedIconL = Color(0xFF222134);
  static const Color errorL = Color(0xFFBE0202);
  static const Color shadowL = Color(0x20000000);
  static const Color cursorL = Color(0xFFBE0202);
  static const Color accentColorL = Color(0xffE6FAF0);
  static const Color textFieldL = Color(0xffEAECF0);
  static const Color linearOne = Color(0xff189fab);
  static const Color primary = Color(0xFF1E1E1E);
  //Dark
  static const Color backgroundD = Color(0xff000000);
  static const Color cardBackgroundD = Color(0xff1E1E1E);
  static const Color elevatedBoxD = Color(0xFF3C3A56);
  static const Color navBarD = Color(0xFF222134);
  static const Color actionBTND = Color(0xFF3C3DBF);
  static const Color inActionBTND = Color(0xFF8BD8D7);
  static const Color fabD = Color(0xFF45C0BE);
  static const Color iconD = Color(0xffF5F7FA);
  static const Color selectedIconD = Colors.white;
  static const Color errorD = Color(0xFFD80000);
  static const Color shadowD = Color(0x20000000);
  static const Color cursorD = Color(0xFFBE0202);
  static const Color textFieldD = Color(0xffE6E9EA);
  static const Color accentColorD = Color(0xffE6FAF0);
}

class ColorsGetter extends KColors {
  static BuildContext? _context;
  static ColorsGetter? _instance;

  ColorsGetter._internal() {
    _instance = this;
  }

  static ColorsGetter of(BuildContext context) {
    _context = context;
    return _instance ?? ColorsGetter._internal();
  }

  //Getters
  Color get error {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.errorL
        : KColors.errorD;
  }

  Color get textField {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.textFieldD
        : KColors.textFieldL;
  }

  Color get actionBTN {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.actionBTNL
        : KColors.actionBTND;
  }

  Color get icons {
    return Theme.of(_context!).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color get freeShiping {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.inActionBTNL
        : KColors.inActionBTND;
  }

  Color get navBar {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.navBarD
        : KColors.navBarL;
  }

  Color get background {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.backgroundD
        : KColors.backgroundL;
  }

  Color get elevatedBox {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.elevatedBoxL
        : KColors.elevatedBoxD;
  }

  Color get shadow {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.shadowL
        : KColors.shadowD;
  }

  Color get cursor {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.cursorL
        : KColors.cursorD;
  }

  Color get reBackground {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.backgroundD
        : KColors.backgroundL;
  }

  Color get card {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.accentColorL
        : KColors.elevatedBoxD;
  }

  Color get border {
    return Theme.of(_context!).brightness == Brightness.dark
        ? KColors.backgroundD.withOpacity(.2)
        : KColors.backgroundL;
  }

  Color get trackColor {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.actionBTND
        : KColors.actionBTND;
  }

  Color get thumbColor {
    return Colors.white;
  }

  Color get activeIcons {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.iconL
        : KColors.iconD;
  }

  Color get selected {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.selectedIconL
        : KColors.selectedIconD;
  }

  Color get fabBackground {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.fabL
        : KColors.fabD;
  }

  Color get accentColor {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.accentColorL
        : KColors.accentColorD;
  }

  Color get primary {
    return Theme.of(_context!).brightness == Brightness.light
        ? KColors.primary
        : KColors.primary;
  }
}

class AppColors {
  // Primary (Green)
  static const Color primary        = Color(0xFF006754);
  static const Color primaryDark    = Color(0xFF065446);
  static const Color primaryAlt     = Color(0xFF158467);
  static const Color primaryLight   = Color(0xFF87D1A4);
  static Color greyLightColor = const Color(0xffF9F9F9);
  // Secondary (Gray/Purple scale)
  static const Color secondary      = Color(0xFF827D89);
  static const Color secondaryDark  = Color(0xFF180E25);
  static const Color secondaryAlt   = Color(0xFFC8C5CB);
  static const Color secondaryLight = Color(0xFFEFEEF0);

  // Neutrals (اختياري)
  static const Color bg     = secondaryLight;
  static const Color text   = secondaryDark;
}

const ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.secondary,
  onSecondary: Colors.white,
  surface: AppColors.secondaryLight,
  onSurface: AppColors.secondaryDark,
  background: AppColors.bg,
  onBackground: AppColors.text,
  error: Color(0xFFB00020),
  onError: Colors.white,
);

final ThemeData appTheme = ThemeData(
  colorScheme: appColorScheme,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.bg,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  ),
);
