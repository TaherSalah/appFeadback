import 'package:flutter/cupertino.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(
    double fontSize, FontWeight fontWeight, Color color, double height,
    {String? fontFamily}) {
  return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      height: height);
}

// Regular style

TextStyle getRegularStyle(
    {double fontSize = FontSize.s12,
    required Color color,
    double height = 0.0}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color, height);
}

// Medium style

TextStyle getMediumStyle(
    {double fontSize = FontSize.s12,
    required Color color,
    double height = 0.0}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color, height);
}

// SemiBold style

TextStyle getSemiBoldStyle(
    {double fontSize = FontSize.s12,
    required Color color,
    double height = 0.0}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color, height);
}

// Bold style

TextStyle getBoldStyle(
    {double fontSize = FontSize.s12,
    double height = 1.4,
    required Color color,
    String? fontFamily}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color, height,
      fontFamily: fontFamily);
}

// ligth style

TextStyle getLigthStyle(
    {double fontSize = FontSize.s12,
    double height = 0.0,
    required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.light, color, height);
}
