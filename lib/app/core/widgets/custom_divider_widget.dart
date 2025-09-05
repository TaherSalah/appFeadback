import 'package:flutter/material.dart';

Widget customDividerWidget(
    {double? height,
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent}) {
  return Divider(
    height: height ?? 5,
    color: color,
    thickness: thickness ?? 0.5,
    indent: indent ?? 10,
    endIndent: endIndent ?? 10,
  );
}
