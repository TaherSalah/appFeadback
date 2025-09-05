import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/k_color.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: false,
    cardColor: KColors.whiteColor,
    cardTheme: const CardThemeData(color: Colors.white),
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: KColors.whiteColor,
          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: const Color(0xfffafafa),
        elevation: 0,
        shadowColor: KColors.kGrayscale40,
        iconTheme: IconThemeData(color: KColors.primaryColor)),
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: KColors.blackColor,foregroundColor: Colors.white),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    // indicatorColor: KColors.backgroundD,
    brightness: Brightness.light,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        iconColor: KColors.iconSL,
        // Button background color
      ),
    ),

    scaffoldBackgroundColor: const Color(0xfff4f5fa),
    // scaffoldBackgroundColor: KColors.backgroundL,
    // iconTheme: const IconThemeData(color: KColors.iconD),
    // buttonTheme: const ButtonThemeData(
    //   buttonColor: KColors.actionBTNL,
    // ),
    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //     backgroundColor: KColors.primaryColor,
    //     selectedItemColor: KColors.blueLightColor7,
    //     unselectedItemColor: KColors.primaryColor,
    //     selectedLabelStyle: getBoldStyle(color: KColors.brown),
    //     unselectedLabelStyle: getBoldStyle(color: KColors.brown),
    //     showUnselectedLabels: true),
    // inputDecorationTheme: const InputDecorationTheme(
    //   outlineBorder: BorderSide(color: KColors.errorL),
    //     border: OutlineInputBorder(
    //
    //         borderSide: BorderSide(
    //
    //   color:KColors.errorL,
    // ))),
    // appBarTheme: AppBarTheme(
    //   iconTheme: IconThemeData(color: KColors.blackColor),
    //   // backgroundColor: KColors.primaryColor,
    // ),
    //  drawerTheme: DrawerThemeData(
    //   backgroundColor: KColors.whiteColor,
    // ),
  );
}
