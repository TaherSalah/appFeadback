import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/style/k_color.dart';
import 'custom_text_widget.dart';

class HeadLinesTitleWidget extends StatelessWidget {
  const HeadLinesTitleWidget(
      {super.key,
      required this.title,
      // required this.seeMore,
      required this.onPressed,
      this.bgColor,
      this.fontColor});
  final String title;
  // final String seeMore;
  final void Function() onPressed;
  final Color? bgColor;
  final Color? fontColor;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Padding(
        //   padding: EdgeInsets.symmetric(
        //     vertical: 8.0.h,
        //   ),
        //   child: customDividerWidget(endIndent: 240, height: 1.5),
        // ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: bgColor ?? KColors.lightYellowColor,
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(15.r))),
          child: TextWidget(
            title: title,
            fontSize: 12.sp,
            // FontFamily: 'cairo',
            color: fontColor ?? KColors.brown,
            fontWeight: FontWeight.w700,
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: 8.0.h),
        //   child: customDividerWidget(endIndent: 240, height: 1.5),
        // ),
        // Spacer(),
        // TextButton(
        //   onPressed: onPressed,
        //   child: TextDefaultWidget(
        //     title: seeMore,
        //     fontSize: 10.sp,
        //     FontFamily: 'cairo',
        //     color: KColors.blueLightColor7,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      ],
    );
  }
}
