import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData light({Color? primaryColor}) => lightTheme(primaryColor: primaryColor);
  static ThemeData dark({Color? primaryColor}) => darkTheme(primaryColor: primaryColor);
}
