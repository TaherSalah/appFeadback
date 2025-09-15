import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/centralized_cubit.dart';
import '../utils/style/k_color.dart';
import '../utils/style/responsive_util.dart';
import 'custom_text_widget.dart';

class KButtons {
  static BuildContext? _context;
  static KButtons? _instance;

  KButtons._internal() {
    _instance = this;
  }

  static KButtons of(BuildContext context) {
    _context = context;
    return _instance ?? KButtons._internal();
  }

  static Widget buttonWithLoader(
      {final String? title,
      final bool? isLoading = false,
      final Color? kFillColor,
      final Function()? onPressed,
      final double? width,
      final double? radius,
      height,
      final IconData? icon,
      required final BuildContext context,
      final bool isFlat = false}) {
    return ElevatedButton(
        onPressed: isLoading ?? false ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
          textStyle: TextStyle(
            fontSize: ResponsiveUtil.isTablet(context) ? 13 : 8,
          ),
          backgroundColor: CentralizedCubit.isDarkMode
              ? KColors.cardBackgroundD
              : KColors.whiteColor,
          // shape: const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //         topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        ),
        child: Ink(
            decoration: !isFlat
                ? BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [KColors.accentColorL, KColors.primary],
                    //   begin: Alignment.centerLeft,
                    //   end: Alignment.centerRight,
                    // ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(radius ?? 10)),
                  )
                : BoxDecoration(
                    color: kFillColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
            child: Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                child: isLoading == true
                    ? FittedBox(
                        child: SizedBox(
                            height: (height ?? 45) - 10,
                            child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white))))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            if (icon != null) Icon(icon, size: 22),
                            const SizedBox(
                              width: 4,
                            ),
                            TextWidget(fontSize: 10, title: title.toString())
                          ]))));
  }

  static Widget buttonColIcon(
    ThemeData theme, {
    required String text,
    required IconData icon,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
          ),
          SizedBox(height: 10.h),
          TextWidget(
            title: text,
            // style: theme.textTheme.bodySmall!.copyWith(
            fontSize: 11,
            //   color: KColors.whiteDarkColor,
            // ),
          )
        ],
      ),
    );
  }

  static Widget buttonIcon(ThemeData theme,
      {required String text,
      required IconData icon,
      void Function()? onTap,
      Color? bgColor,
      fontColor,
      double? borderRadius,
      fontSize}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(borderRadius ?? 10.r)),
            color: bgColor ?? Colors.grey),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 5, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25,
                color: fontColor,
              ),
              SizedBox(width: 10.w),
              TextWidget(
                title: text,
                fontWeight: FontWeight.bold,
                color: fontColor ?? Colors.black,
                // style: theme.textTheme.bodySmall!.copyWith(
                fontSize: fontSize ?? 11,
                //   color: KColors.whiteDarkColor,
                // ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget buttonCircleIcon(
      {void Function()? onTap,
      String? text,
      double? width,
      iconSize,
      height,
      fontSize,
      FontWeight? fontWight,
      IconData? icon,
      Color? iconColor,
      titleColor,
      gradiantColor1,
      gradiantColor2}) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            Container(
              width: width ?? 50.0,
              height: height ?? 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    gradiantColor1 ?? const Color(0xffF65F6F),
                    gradiantColor2 ?? const Color(0xffF78164),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  size: iconSize ?? 25,
                  icon ?? Icons.add,
                  color: iconColor ?? KColors.whiteDarkColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextWidget(
              fontWeight: fontWight ?? FontWeight.w600,
              title: text ?? "title",
              color: titleColor ?? KColors.whiteDarkColor,
              fontSize: fontSize ?? 16,
            )
          ],
        ),
      ),
    );
  }

  static Widget defButton(
      {required BuildContext context,
      void Function()? onTap,
      Key? key,
      required String btnTitle,
      Color? titleColor,
      Color? borderColor,
      double? width,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      EdgeInsetsGeometry? buttonPadding,
      BorderRadiusGeometry? borderRadius,
      List<BoxShadow>? boxShadow,
      TextAlign? textAlign}) {
    return InkWell(
        key: key,
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
            padding: buttonPadding ??
                EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
            decoration: BoxDecoration(
                boxShadow: boxShadow,
                color: backgroundColor,
                border: Border.all(
                    color: borderColor ?? KColors.transparentColor,
                    width: width ?? 1.0),
                borderRadius: borderRadius ?? BorderRadius.circular(16.r)),
            child: TextWidget(
                title: btnTitle,
                textAlign: textAlign,
                fontSize: fontSize ?? 20.sp,
                color: titleColor,
                fontWeight: fontWeight ?? FontWeight.w600)));
  }

  static Widget circularIconButton({
    final IconData? iconData,
    final Color fillColor = Colors.transparent,
    final Color outlineColor = Colors.transparent,
    final Color iconColor = Colors.blue,
    final Color notificationFillColor = Colors.red,
    final int? notificationCount,
    final Function? onPressed,
    final double radius = 48.0,
    final double? iconSize,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Ink(
          width: radius,
          height: radius,
          decoration: ShapeDecoration(
            color: fillColor,
            shape: CircleBorder(side: BorderSide(color: outlineColor)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: radius,

            iconSize: iconSize ??25,
            icon: Icon(iconData, color: iconColor),
            splashColor: iconColor.withOpacity(.4),
            onPressed: onPressed as void Function()?,
          ),
        ),
        if (notificationCount != null) ...[
          Positioned(
            top: radius / -14,
            right: radius / -14,
            child: Container(
              width: radius / 2.2,
              height: radius / 2.2,
              decoration: ShapeDecoration(
                color: notificationFillColor,
                shape: const CircleBorder(),
              ),
              child: Center(
                child: Text(
                  notificationCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius / 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Widget outlinedButton({
    final Widget? child,
    final Function? onPressed,
    final double borderRadius = 6,
    final Color? outlineColor,
    final Color? textColor,
    final EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
  }) {
    ThemeData currentTheme = Theme.of(_context!);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? outlineColor ?? currentTheme.primaryColor,
        padding: padding,
        textStyle: TextStyle(color: currentTheme.primaryColor),
        side: BorderSide(color: outlineColor ?? currentTheme.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed as void Function()?,
      child: child!,
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.title,
      this.width = 425,
      this.height,
      this.radius = 30,
      this.backgroundColor,
      this.fontSize,
      this.horizontalPadding,
      this.verticalPadding,
      this.fontWeight,
      this.margin,
      required this.onTap,
      this.style,
      this.decoration,
      this.textColor,
      this.hasBackgroundColor = true,
      this.borderColor,
      this.iconWidget});

  final void Function()? onTap;
  final String title;
  final double? width, height;
  final Color? backgroundColor;
  final double? radius;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextStyle? style;
  final double? horizontalPadding, verticalPadding;
  final BoxDecoration? decoration;
  final Widget? iconWidget;
  final bool hasBackgroundColor;
  final Color? textColor, borderColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        // height: height,
        // width: width.w,
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? 14.h,
            horizontal: horizontalPadding ?? 0),
        // margin: margin?? EdgeInsets.symmetric(horizontal: 8.w),
        decoration: decoration ??
            BoxDecoration(
                color: backgroundColor,
                // gradient: hasBackgroundColor ? KColors.gradientBtn : null,
                borderRadius: radius == null
                    ? BorderRadius.circular(10.w)
                    : BorderRadius.circular(radius!.w),
                border: Border.all(
                    color: borderColor ??
                        (CentralizedCubit.isDarkMode == true
                            ? KColors.greyColor
                            : KColors.whiteColor))),
        child: iconWidget != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextWidget(
                      title: title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                  iconWidget!
                ],
              )
            : TextWidget(
                title: title,
                color: textColor ?? Colors.white,
                fontSize: fontSize,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
      ),
    );
  }
}
