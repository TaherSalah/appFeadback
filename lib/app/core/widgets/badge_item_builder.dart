import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/style/k_color.dart';
import '../utils/style/responsive_util.dart';
import 'custom_text_widget.dart';


class BadgeItemBuilder extends StatelessWidget {
  const BadgeItemBuilder(
      {super.key, required this.widget, this.badgeNumber, this.badgePosition});

  final Widget widget;
  final String? badgeNumber;
  final BadgePosition? badgePosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: badges.Badge(
          badgeContent: TextWidget(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            title: badgeNumber ?? '0',
            fontSize: ResponsiveUtil.isTablet(context) ? 6.sp : 9.sp,
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: KColors.greenColor,
            // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            borderRadius: BorderRadius.circular(6.r),
            elevation: 2,
          ),
          position: badgePosition ??
              badges.BadgePosition.topStart(start: -3, top: -16.5),
          child: widget),
    );
  }
}
