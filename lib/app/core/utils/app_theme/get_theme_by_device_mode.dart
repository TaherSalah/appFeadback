import 'package:flutter/material.dart';

import '../style/k_color.dart';

ThemeData lightThemeData = ThemeData(
    brightness: Brightness.light,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    scaffoldBackgroundColor: const Color(0xffFDF7E4),
    iconTheme: IconThemeData(color: KColors.blueColor),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderSide: BorderSide(color: KColors.lightYellowColor)),
    ),
    buttonTheme: ButtonThemeData(buttonColor: KColors.brown),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: KColors.blackColor, weight: 10),
      backgroundColor: const Color(0xffFDF7E4),
    )
    //
    // fontFamily: FontConstants.cairoFontFamily
    );
ThemeData darkThemeData = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    brightness: Brightness.dark,
    // scaffoldBackgroundColor: const Color(0xff0F2C59),
    scaffoldBackgroundColor: KColors.blackDarktColor,
    iconTheme: IconThemeData(color: KColors.whiteDarkColor),
    buttonTheme: ButtonThemeData(buttonColor: KColors.brown),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(
      color: KColors.whiteColor,
    ))),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: KColors.whiteDarkColor),
      backgroundColor: KColors.blackDarktColor,
    )

    // fontFamily:FontConstants.cairoFontFamily
    );

ThemeData getThemeByDeviceMode(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return darkThemeData;
  } else {
    return lightThemeData;
  }
}

TextStyle getTextStyle(
    BuildContext context, TextStyle darkTextStyles, TextStyle lightTextStyles) {
  if (MediaQuery.of(context).platformBrightness == Brightness.light) {
    return lightTextStyles;
  } else {
    return darkTextStyles;
  }
}

class DarkTextStyles {
  static const TextStyle fontSize25WeightBoldAmiri = TextStyle(
    color: Colors.white,
    fontSize: 25,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.bold,
    height: 0,
  );
  static const TextStyle fontSize16Weight400 = TextStyle(
    color: Color(0xFFA19CC5),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 0,
  );
  static const TextStyle onBoardingtitle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle appBartitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 0,
  );
  static const TextStyle onBoardingSubtitle = TextStyle(
    color: Color(0xFFA19BC4),
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 0,
  );
  static const TextStyle getStartedButton = TextStyle(
    color: Color(0xFF091945),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // FontSize: 18, FontWeight: FontWeight.w700
  static const TextStyle fontSize20Weight700Amiri = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle fontSize18Weight700Amiri = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle fontSize18Weight600 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize16Weight600 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize16Weight500Unselected = TextStyle(
    color: Color(0xFFA19BC4),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize16Weight500 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 0,
  );

  // FontSize: 16, FontWeight: FontWeight.w400
  static const TextStyle fontSize14Weight500 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize12Weight500 = TextStyle(
    color: Color(0xFFA19BC4),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );

  // FontSize: 14, FontWeight: FontWeight.w600
  static const TextStyle fontSize14Weight600 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize14Weight500Unselected = TextStyle(
    color: Color(0xFF8789A3),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize14Weight400 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 0,
  );
}

Color getDividerColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color(0x59BBC4CE)
      : const Color(0x597B80AD);
}

Color getBottomSheetContainerColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.white
      : const Color(0xFF111930);
}

Color getAyatFucntionsContainerColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color(0x0C121931)
      : const Color(0xFF121931);
}

class LightTextStyles {
  static const TextStyle fontSize12Weight500 = TextStyle(
    color: Color(0xFFA19BC4),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );

  static const TextStyle onBoardingtitle = TextStyle(
    color: Color(0xFF672CBC),
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle appBartitle = TextStyle(
    color: Color(0xFF672CBC),
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 0,
  );
  static const TextStyle onBoardingSubtitle = TextStyle(
    color: Color(0xFF8789A3),
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 0,
  );
  static const TextStyle getStartedButton = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // FontSize: 18, FontWeight: FontWeight.w700
  static const TextStyle fontSize20Weight700Amiri = TextStyle(
    color: Color(0xFF230E4E),
    fontSize: 20,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle fontSize18Weight700Amiri = TextStyle(
    color: Color(0xFF230E4E),
    fontSize: 18,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle fontSize18Weight600 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize16Weight600 = TextStyle(
    color: Color(0xFF672CBC),
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize16Weight500Unselected = TextStyle(
    color: Color(0xFF8789A3),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize16Weight400 = TextStyle(
    color: Color(0xFF230E4E),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 0,
  );
  static const TextStyle fontSize16Weight500 = TextStyle(
    color: Color(0xFF230E4E),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 0,
  );

  // FontSize: 16, FontWeight: FontWeight.w400
  static const TextStyle fontSize14Weight500 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize14Weight500Dark = TextStyle(
    color: Color(0xFF230E4E),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );

  // FontSize: 14, FontWeight: FontWeight.w600
  static const TextStyle fontSize14Weight600 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 0,
  );
  static const TextStyle fontSize14Weight500Unselected = TextStyle(
    color: Color(0xFF8789A3),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0,
  );
  static const TextStyle fontSize14Weight700Amiri = TextStyle(
    color: Color(0xFF863ED5),
    fontSize: 20,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 0,
  );
  static const TextStyle fontSize14Weight400 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 0,
  );

// Add more text styles as needed based on fontSize and fontWeight
}
