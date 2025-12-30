import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cubit/centralized_cubit.dart';
import '../style/k_color.dart';

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: false,
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: KColors.primaryColor),
    cupertinoOverrideTheme: MaterialBasedCupertinoThemeData(
        materialTheme: ThemeData(
            primaryColor: CentralizedCubit
                    .isDarkMode // color: CentralizedCubit.isDarkMode
                ? KColors.whiteColor
                : KColors.primary2Color)),
    // indicatorColor: KColors.backgroundL,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(iconColor: KColors.iconD)),
    appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: Color(0xff000000),

          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Color(0xff1F1F1F),
        // shadowColor: Colors.grey,
        iconTheme: IconThemeData(color: KColors.iconL)),

    brightness: Brightness.dark,
    // backgroundColor: Colors.red,
    // cardColor: Color(0xff1F1F1F),

    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    // scaffoldBackgroundColor: const Color(0xff1a1a2e),
    scaffoldBackgroundColor: Colors.black,
    iconTheme: const IconThemeData(color: KColors.iconD),
    inputDecorationTheme: InputDecorationTheme(
        // fillColor: KColors.whiteColor,
        border: OutlineInputBorder(
            borderSide: BorderSide(color: KColors.whiteColor))),
    buttonTheme: ButtonThemeData(
        splashColor: Colors.black.withOpacity(0.5),
        shape: Border.all(color: Colors.white, style: BorderStyle.solid),
        // buttonColor: KColors.actionBTND,
        textTheme: ButtonTextTheme.normal),

    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //   backgroundColor: KColors.primaryColor,
    //   selectedItemColor: KColors.blueLightColor7,
    //   unselectedItemColor: KColors.primaryColor,
    //   selectedLabelStyle: getBoldStyle(color: KColors.brown),
    //   unselectedLabelStyle: getBoldStyle(color: KColors.brown),
    //   showUnselectedLabels: true,
    // ),
    // appBarTheme: AppBarTheme(
    //   elevation: 0,
    //   iconTheme: IconThemeData(
    //     color: KColors.whiteColor,
    //     weight: 10,
    //   ),
    //   // backgroundColor: KColors.primaryColor,
    // ),
    //
    // drawerTheme: DrawerThemeData(
    //   backgroundColor: KColors.blackColor,
    // ),

    // fontFamily: FontConstants.cairoFontFamily
  );
}
