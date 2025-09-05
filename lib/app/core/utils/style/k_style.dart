import 'package:flutter/material.dart';

import 'k_color.dart';

class KTextStyle {
  static BuildContext? _context;
  static KTextStyle? _instance;
  KTextStyle._internal() {
    _instance = this;
  }
  static KTextStyle of(BuildContext context) {
    _context = context;
    return _instance ?? KTextStyle._internal();
  }

  static const String fontFamily = 'BalooBhaijaan2';

  //Light
  static const Color mainL = Color(0xFF161616);

  //Dark
  static const Color mainD = Color(0xFFFFFFFF);

  //Getters
  TextStyle get appBar {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
    );
  }

  TextStyle get body {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.light ? mainL : mainD,
      fontSize: 15,
      fontFamily: fontFamily,
    );
  }

  TextStyle get logo {
    return TextStyle(
        color: KColors.of(_context!).accentColor,
        fontSize: 20,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500);
  }

  TextStyle get reBody {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.dark ? mainL : mainD,
      fontSize: 15,
      fontFamily: fontFamily,
    );
  }

  TextStyle get body2 {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.light ? mainL : mainD,
      fontSize: 12.5,
      fontFamily: fontFamily,
    );
  }

  TextStyle get boldBody {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.light ? mainL : mainD,
      fontSize: 12,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get error {
    return const TextStyle(
        color: Colors.red, fontSize: 15, fontFamily: fontFamily);
  }

  TextStyle get rawBtn {
    return TextStyle(
        color:
            Theme.of(_context!).brightness == Brightness.dark ? mainL : mainD,
        fontSize: 16,
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold);
  }

  TextStyle get hint {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.light
          ? mainL.withOpacity(.5)
          : mainD.withOpacity(.5),
      fontSize: 16,
      fontFamily: fontFamily,
    );
  }

  TextStyle get rehint {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.dark
          ? mainL.withOpacity(.7)
          : mainD.withOpacity(.6),
      fontSize: 16,
      fontFamily: fontFamily,
    );
  }

  TextStyle get title {
    return TextStyle(
        color: KColors.of(_context!).primary,
        fontSize: 20,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w800);
  }

  TextStyle get btnTitle {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle get subtitle {
    return TextStyle(
        color: KColors.of(_context!).primary,
        fontSize: 16,
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold);
  }

  TextStyle get smallTitle {
    return TextStyle(
        color: KColors.of(_context!).primary,
        fontSize: 12,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600);
  }

  TextStyle get reTitle {
    return TextStyle(
      color: Theme.of(_context!).brightness == Brightness.dark ? mainL : mainD,
      fontSize: 16,
      fontFamily: fontFamily,
    );
  }

  TextStyle get textBtn {
    return const TextStyle(
      color: Color(0xFF629CFF),
      fontSize: 16,
      fontFamily: fontFamily,
    );
  }
}
