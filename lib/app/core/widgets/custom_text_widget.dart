import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constent/font_manager.dart';
import '../utils/style/k_color.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.title,
      this.fontSize,
      this.fontWeight,
      this.fontFamily,
      this.color,
      this.gradientColors,
      this.maxLines,
      this.height,
      this.underlineText,
      this.textBaseline,
      this.textAlign,
      this.overflow,
      this.letterSpacing});
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final Color? color;
  final Paint? gradientColors;
  final String title;
  final int? maxLines;
  final bool? underlineText;
  final TextBaseline? textBaseline;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: height,
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color,
          letterSpacing: letterSpacing,
          textBaseline: textBaseline,
          fontFamily: fontFamily ?? FontConstants.cairoFontFamily,
          foreground: gradientColors,
          overflow: overflow ?? TextOverflow.ellipsis,

          decoration: underlineText == true
              ? TextDecoration.underline
              : TextDecoration.none),
      maxLines: maxLines ?? 10000,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

class GradientTextWidget extends StatelessWidget {
  const GradientTextWidget({
    super.key,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.gradientColors = const LinearGradient(
      colors: <Color>[
        Color(0xff42DEBF),
        Color(0xff6CA5C2),
        Color(0xff4876B2),
        Color(0xff315FAA),
      ],
    ),
  });

  final String title;
  final Gradient gradientColors;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradientColors.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color ?? KColors.whiteColor,
        ),
        maxLines: maxLines,
      ),
    );
  }
}
