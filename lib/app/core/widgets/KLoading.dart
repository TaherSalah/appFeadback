import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/constent/assets_manager.dart';
import '../utils/style/k_color.dart';
import '../utils/style/k_helper.dart';
import '../utils/style/responsive_util.dart';
import 'error_view/error_widget.dart';


class KLoading {
  static BuildContext? context;
  static KLoading? _instance;
  KLoading._internal() {
    _instance = this;
  }
  static KLoading of(BuildContext context) {
    context = context;
    return _instance ?? KLoading._internal();
  }

  static Widget loadingOverlay(
      {Widget? child, bool isLoading = false, required BuildContext context}) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          child ??
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height),
          if (isLoading)
            Positioned(
              top: 0,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(KHelper.btnRadius),
                  ),
                ),
              ),
            ),
          if (isLoading)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: ResponsiveUtil.isTablet(context) ? 120 : 80,
                    height: ResponsiveUtil.isTablet(context) ? 120 : 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: KColors.of(context).accentColor,
                      // valueColor: An,
                    ),
                  ),
                  Image.asset(
                    AssetsManager.logo,
                    height: 40,
                    width: 40,
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget requestOverlay({
    final Widget? child,
    final bool isLoading = false,
    final String? error,
    final void Function()? onTryAgain,
  }) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          child ??
              SizedBox(
                  width: MediaQuery.of(context!).size.width,
                  height: MediaQuery.of(context!).size.height),
          if (isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Center(
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: ResponsiveUtil.isTablet(context!) ? 120 : 80,
                        height: ResponsiveUtil.isTablet(context!) ? 120 : 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: KColors.whiteColor,
                        ),
                      ),
                      Image.asset(AssetsManager.logo, height: 40, width: 40)
                    ],
                  ),
                ),
              ),
            ),
          if (error != null) KErrorWidget(error: error, onTryAgain: onTryAgain)
        ],
      ),
    );
  }
  static Widget progressIOSIndicator({
    Color? progressColor,
    double? radius,
    required BuildContext context
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoActivityIndicator(
          radius: radius ?? 15,
          color: Theme.of(context).brightness == Brightness.dark?Colors.white:KColors.primary2Color,
        ),
      ),
    );
  }

  static Widget loadingScreen(
      {required Widget child, bool loading = false, withDropdown}) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          loading
              ? Positioned.fill(
                  child: Container(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                )
              : const SizedBox(),
          loading
              ? Positioned(
                  child:
                      // Container(
                      //     decoration: BoxDecoration(color: KColors.primaryColor),
                      //     child: Image.asset(
                      //       "assets/images/Guidlle.gif",
                      //       height: 150.h,
                      //       width: 250.w,
                      //     )),
                      CircularProgressIndicator(
                    color: withDropdown == true
                        ? Colors.transparent
                        : KColors.primaryColor,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
