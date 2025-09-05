import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TextDefaultWidget extends StatelessWidget {
  const TextDefaultWidget({super.key,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.color,
    this.gradientColors,
    this.maxLines,
    this.height,
    this.underlineText, this.textBaseline, this.textAlign, this.textOverflow,});
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
  final TextOverflow? textOverflow;
  final double?height;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          height: height,
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color ?? Colors.black,
          textBaseline: textBaseline,
          fontFamily: fontFamily ?? "Almarai",
          foreground: gradientColors,
          overflow: textOverflow ?? TextOverflow.ellipsis,

          decoration: underlineText == true
              ? TextDecoration.underline
              : TextDecoration.none),
      maxLines: maxLines ?? 5,
      overflow: textOverflow ?? TextOverflow.ellipsis,
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
    this.maxlines,
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
  final int? maxlines;

  // = LinearGradient(
  //   colors: <Color>[
  //     Color(0xff42DEBF),
  //     Color(0xff6CA5C2),
  //     Color(0xff4876B2),
  //     Color(0xff315FAA),
  //   ],
  // );
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradientColors.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color ?? Colors.black,
        ),
        maxLines: maxlines,
      ),
    );
  }
}
