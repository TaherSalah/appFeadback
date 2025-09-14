import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/centralized_cubit.dart';
import '../localization/localization_manager.dart';
import '../utils/style/k_color.dart';
import '../utils/style/k_style.dart';
import '../utils/style/responsive_util.dart';


class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final bool? obscure;
  final bool? readOnly;
  final String? hint;
  final String? label;
  final Color? backGroundColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final int? maxLine;
  final int? prefixWidth;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final bool? enable, isDense;
  final Color? borderColor;
  final double? borderRadiusValue, width, height;
  final EdgeInsets? insidePadding;
  final Widget? prefixIcon, suffixIcon;
  final void Function(String)? onchange;
  final void Function(String)? onFieldSubmitted;
  final Function()? onSuffixTap;
  final void Function()? onTap;
  final List<TextInputFormatter>? formatter;
  final TextInputAction? textInputAction;
  final bool? noBorder;
  final TextDirection? textDirection;
  final Color? labelColor;
  final Color? cursorColor;
  final FocusNode? focusNode;
  final int? minLines;

  const CustomTextFieldWidget({
    super.key,
    this.isDense,
    this.cursorColor,
    this.style,
    this.onchange,
    this.insidePadding,
    this.validator,
    this.maxLine,
    this.hint,
    this.label,
    this.backGroundColor,
    this.controller,
    this.obscure = false,
    this.enable = true,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.borderColor,
    this.borderRadiusValue,
    this.prefixIcon,
    this.width,
    this.hintStyle,
    this.suffixIcon,
    this.onSuffixTap,
    this.height,
    this.onTap,
    this.prefixWidth,
    this.labelColor,
    // this.noBorder = true,
    this.formatter,
    this.onFieldSubmitted,
    this.textDirection,
    this.noBorder = false,
    this.focusNode,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          LocalizationManager.isEn ? TextDirection.ltr : TextDirection.rtl,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: TextFormField(
          minLines: minLines,
          focusNode: focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // cursorHeight: 20.h,
          readOnly: readOnly ?? false,
          textAlignVertical: TextAlignVertical.center,
          validator: validator,
          onTap: () => onTap,
          enabled: enable,
          inputFormatters: formatter ?? [],
          obscureText: obscure ?? false,
          obscuringCharacter: obscure != null ? "*" : '',
          textInputAction: textInputAction,
          controller: controller,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0),
              // label: TextWidget(
              //   title: label ?? "",
              //   color: labelColor,
              //   fontWeight: FontWeight.w500,
              //   fontSize: 14.sp,
              // ),
              labelText: label,
              floatingLabelStyle: TextStyle(
                  fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                  fontFamily: 'cairo',
                  color: CentralizedCubit.isDarkMode
                      ? KColors.whiteColor
                      : KColors.blackColor,
                  fontWeight: FontWeight.w500),
              enabledBorder: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(borderRadiusValue ?? 10.w),
                      borderSide: BorderSide(
                          color: borderColor ??
                              KColors.greyColor.withOpacity(0.2))),
              disabledBorder: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(borderRadiusValue ?? 10.w),
                      borderSide: BorderSide(
                          color: borderColor ??
                              KColors.greyColor.withOpacity(0.2))),
              focusedBorder: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(borderRadiusValue ?? 10.w),
                      borderSide: BorderSide(
                          color: borderColor ??
                              KColors.greyColor.withOpacity(0.3))),
              border: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(borderRadiusValue ?? 10.w),
                      borderSide: BorderSide(
                        color:
                            borderColor ?? KColors.greyColor.withOpacity(0.2),
                      )),
              isDense: isDense ?? false,
              prefixIconConstraints: BoxConstraints(
                  minWidth: prefixIcon == null ? 0 : 45.w, maxHeight: 25.w),
              suffixIconConstraints: BoxConstraints(
                  minWidth: suffixIcon == null ? 0 : 45.w, maxHeight: 40.h),
              contentPadding: insidePadding ??
                  EdgeInsets.symmetric(
                      vertical: ResponsiveUtil.isTablet(context) ? 6.5.h : 9.h),
              fillColor: backGroundColor,
              filled: backGroundColor != null,
              hintText: hint,
              prefixIcon: prefixIcon == null
                  ? SizedBox(width: 10.w)
                  : SizedBox(width: 30.w, child: prefixIcon),
              suffixIcon: suffixIcon == null
                  ? SizedBox(width: 5.w)
                  : InkWell(
                      onTap: onSuffixTap,
                      child: SizedBox(width: 30.w, child: suffixIcon),
                    ),
              hintStyle: hintStyle ??
                  TextStyle(
                      fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                      color: CentralizedCubit.isDarkMode
                          ? KColors.whiteColor
                          : const Color(0xFFA5A5A5),
                      height: 1.5.h,
                      fontFamily: 'cairo',
                      fontWeight: FontWeight.w400),
              labelStyle: TextStyle(
                  fontSize: ResponsiveUtil.isTablet(context) ? 7.sp : 11.sp,
                  color: CentralizedCubit.isDarkMode
                      ? KColors.whiteColor
                      : KColors.greyColor,
                  height: 1.5.h,
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.w400)),
          onChanged: onchange,
          textCapitalization: TextCapitalization.words,
          maxLines: maxLine ?? 1,
          keyboardType: textInputType,
          style: style ??
              TextStyle(
                fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 14.sp,
                fontWeight: FontWeight.w400,
                // color: KColors.blackColor,
              ),
          cursorColor: cursorColor ?? KColors.brown,
          onEditingComplete: () {
            if (controller?.text.indexOf(' ', 0) != null) {
              controller?.text.replaceFirst(" ", '');
            }
          },
        ),
      ),
    );
  }
}

class CustomTextFieldWidgetHome extends StatelessWidget {
  final TextEditingController? controller;
  final bool? obscure;
  final bool? readOnly;
  final String? hint;
  final Color? backGroundColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final int? maxLine;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final bool? enable, isDense, autofocus;
  final Color? borderColor;
  final double? borderRadiusValue, width, height;
  final EdgeInsets? insidePadding;
  final Widget? prefixIcon, suffixIcon;
  final void Function(String)? onchange;
  final void Function(String)? onFieldSubmitted;
  final Function()? onSuffixTap;
  final void Function()? onTap;
  final List<TextInputFormatter>? formatter;
  final TextInputAction? textInputAction;

  const CustomTextFieldWidgetHome({
    super.key,
    this.isDense,
    this.style,
    this.onchange,
    this.insidePadding,
    this.validator,
    this.maxLine,
    this.hint,
    this.backGroundColor,
    this.controller,
    this.obscure = false,
    this.enable = true,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.borderColor,
    this.borderRadiusValue,
    this.prefixIcon,
    this.width,
    this.hintStyle,
    this.suffixIcon,
    this.onSuffixTap,
    this.height,
    this.onTap,
    this.formatter,
    this.onFieldSubmitted,
    this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350.w,
      height: height ?? 52.h,
      child: TextFormField(
        textDirection:
            LocalizationManager.isEn ? TextDirection.ltr : TextDirection.rtl,
        // cursorHeight: 20.h,
        readOnly: readOnly ?? false,
        textAlignVertical: TextAlignVertical.center,
        validator: validator,
        onTap: () => onTap,
        enabled: enable,
        inputFormatters: formatter ?? [],
        obscureText: obscure ?? false,
        obscuringCharacter: obscure != null ? "*" : '',
        textInputAction: textInputAction,
        controller: controller,
        onFieldSubmitted: onFieldSubmitted,
        autofocus: autofocus ?? false,
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30.r),
              borderSide: BorderSide(color: borderColor ?? KColors.blackColor)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30.r),
              borderSide:
                  BorderSide(color: borderColor ?? const Color(0xff555555))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30.r),
              borderSide:
                  BorderSide(color: borderColor ?? KColors.primaryColor)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30.r),
              borderSide:
                  BorderSide(color: borderColor ?? const Color(0xFF555555))),
          isDense: isDense ?? false,
          prefixIconConstraints: BoxConstraints(
              minWidth: prefixIcon == null ? 0 : 35.w, maxHeight: 20.w),
          suffixIconConstraints: BoxConstraints(
              minWidth: suffixIcon == null ? 0 : 45.w, maxHeight: 40.h),
          contentPadding: insidePadding ?? EdgeInsets.symmetric(vertical: 6.h),
          fillColor: backGroundColor,
          filled: backGroundColor != null,
          hintText: hint,
          prefixIcon: prefixIcon == null
              ? SizedBox(width: 10.w)
              : SizedBox(width: 30.w, child: prefixIcon),
          suffixIcon: suffixIcon == null
              ? SizedBox(width: 5.w)
              : InkWell(
                  onTap: onSuffixTap,
                  child: SizedBox(width: 30.w, child: suffixIcon),
                ),
          hintStyle: hintStyle ??
              TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF8A8B8D),
                  fontWeight: FontWeight.w400),
        ),
        onChanged: onchange,
        textCapitalization: TextCapitalization.words,
        maxLines: maxLine ?? 1,
        keyboardType: textInputType,
        style: style ??
            TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: KColors.blackColor,
            ),
        cursorColor: KColors.primaryColor,
      ),
    );
  }
}

///*    *///

class KTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Widget? suffixIcon, prefixIcon;
  final String? hintText, errorText;
  final bool autofocus, enabled, expanded;
  final double? kWidth, height;
  final int? maxLines;
  final bool obscureText;
  final String? initVal;
  final TextStyle? style;
  final List<TextInputFormatter>? formatter;
  final void Function()? onTap;
  final Color? kFillColor;

  const KTextFormField({
    super.key,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.hintText,
    this.onTap,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.prefixIcon,
    this.enabled = true,
    this.kWidth,
    this.height,
    this.maxLines,
    this.formatter,
    this.expanded = false,
    this.initVal,
    this.style,
    this.kFillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      inputFormatters: formatter,
      keyboardAppearance: Theme.of(context).brightness,
      keyboardType: keyboardType,
      controller: controller,
      autofocus: autofocus,
      enabled: enabled,
      onTap: onTap,
      expands: expanded,
      initialValue: controller == null ? initVal : null,
      cursorColor: KColors.of(context).cursor,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      style: style ?? KTextStyle.of(context).body,
      maxLines: maxLines ?? (obscureText ? 1 : null),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: kFillColor ?? KColors.of(context).textField,
        hintStyle: KTextStyle.of(context).hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        errorStyle: KTextStyle.of(context).error,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        isDense: false,
      ),
    );
  }
}
