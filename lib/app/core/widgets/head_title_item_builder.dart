import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../cubit/centralized_cubit.dart';
import '../utils/style/k_color.dart';
import 'custom_text_widget.dart';

class HeadTitleItemBuilder extends StatelessWidget {
  const HeadTitleItemBuilder(
      {super.key,
      required this.headTitle,
      this.padding,
      this.lineColor,
      this.fontSize,
      this.titleColor,
      this.fontWeight,
      this.icon,
      this.iconColor,
      this.iconSize});

  final String headTitle;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor, iconColor, lineColor;
  final double? fontSize, iconSize;
  final FontWeight? fontWeight;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 8.0.h, vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
           SizedBox(width:ResponsiveUtil.isTablet(context)?7: 3),
          TextWidget(
            title: headTitle,
            color: titleColor,
            fontSize: fontSize ?? 13.5.sp,
            fontWeight: fontWeight ?? FontWeight.w600,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                thickness: 1,
                color: lineColor ??
                    (CentralizedCubit.isDarkMode
                        ? KColors.whiteColor
                        : KColors.greyColor.withOpacity(0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
