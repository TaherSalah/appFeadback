import 'package:flutter/material.dart';

extension AppSizeExtension on num {
  // Height SizedBox
  Widget get sh => SizedBox(height: toDouble());

  // Width SizedBox
  Widget get sw => SizedBox(width: toDouble());
}
