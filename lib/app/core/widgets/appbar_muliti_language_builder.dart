import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/centralized_cubit.dart';
import '../utils/constent/assets_manager.dart';
import '../utils/style/k_color.dart';


Widget buildEnglishAppBar() {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Image.asset(
          AssetsManager.logo,
          height: 60,
          width: 60,
        ),
      ),
      IconButton(
        icon: Icon(Icons.menu,
            color: CentralizedCubit.isDarkMode
                ? KColors.whiteColor
                : KColors.primary2Color,
            size: 30.sp),
        onPressed: () {
          scaffoldState.currentState?.openEndDrawer();
        },
      ),
    ],
  );
}

Widget buildOtherLanguageAppBar() {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Image.asset(
          AssetsManager.logo,
          height: 60,
          width: 60,
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.menu,
          color: CentralizedCubit.isDarkMode
              ? KColors.whiteColor
              : KColors.primary2Color,
          size: 30.sp,
        ),
        onPressed: () {
          scaffoldState.currentState?.openEndDrawer();
        },
      ),
    ],
  );
}
