import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:muslimdaily/app/core/localization/localization_manager.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

class DrawerModle {
  final IconData? icon;
  final String title;
  final String? route;
  final bool loginRequiredShow,isRepl;
  final VoidCallback? onTap;    // اختياري: لتنفيذ دالة مباشرة


  DrawerModle(  {
  this.onTap,
    required this.title,
    this.icon,
     this.isRepl = false,
    this.route,
    this.loginRequiredShow = false,
  });
}

// List<DrawerModle?> topBar = [
//   DrawerModle(icon: Icons.home, title: "فضل قرأه القران", route: Routes.homeRoute),
//
//   DrawerModle(
//       icon: Icons.favorite,
//       title: "فهرس القران الكريم",
//       route: Routes.myFavorites),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "الاجزاء", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "الاحزاب", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "حفظ علامة", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "انتقال الي العلامه", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "دعاء ختم القران الكريم", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "التفسير", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "الوضع الليلي", route: Routes.myCard),
//   DrawerModle(
//       icon: Icons.shopping_cart, title: "دعاء الختم", route: Routes.myCard),
//
// ];

class DrawerWidget extends StatefulWidget {
  final String selectItmeRoute;
  final List<DrawerModle?> topBar;
  final bool isReplacement;
  const DrawerWidget(this.selectItmeRoute, {super.key, required this.topBar,  this.isReplacement = false});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  static bool maxWidth = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        
        width: maxWidth ? 219 : 64,
        backgroundColor: Colors.black12,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              maxWidth = true;
              setState(() {});
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 15),
                ...List.generate(
                  widget.topBar.length,
                      (index) => _buildDrawerItem(index, context, theme,widget.isReplacement),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildDrawerItem(int index, BuildContext context, ThemeData theme,bool isReplacement) {
    final item = widget.topBar[index];
    final isSelected = item?.route != null && item!.route == widget.selectItmeRoute;
    final bool isReplacement = widget.isReplacement;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      child: GestureDetector(
        onTap: item == null
            ? null
            : () {
          // اقفل الدرج الأول
          Navigator.pop(context);

          // لو عندي onTap.. نفّذها
          if (item.onTap != null) {
            item.onTap!();
            return;
          }

          // لو عندي route صالح ومش هو الحالي.. روح له
          if (item.route != null &&
              item.route!.isNotEmpty &&
              item.route != widget.selectItmeRoute) {
            Navigator.of(context).pushNamed(item.route!);
          }
        },
        child: Center(
          child: widget.topBar[index] != null
              ? Container(
            width: maxWidth ? ResponsiveUtil.isTablet(context)? 215 :200 : 40,
            height: ResponsiveUtil.isTablet(context)?50:40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: widget.topBar[index]?.route == widget.selectItmeRoute
                  ? KColors.backgroundD
                  : Colors.black26,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    widget.topBar[index]!.icon,
                    color:
                    widget.topBar[index]?.route == widget.selectItmeRoute
                        ? AppStyle.scondColors
                        : Colors.white,
                    size: 24,
                  ),
                  if (maxWidth) const SizedBox(width: 10),
                  if (maxWidth)
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          widget.topBar[index]!.title,
                          style: theme.textTheme.titleSmall!.copyWith(
                              fontSize: ResponsiveUtil.isTablet(context)?10.sp: 14.sp,
                            fontFamily: "me",
                            color:widget. topBar[index]?.route ==
                                widget.selectItmeRoute
                                ? KColors.actionBTNL
                                : KColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
              : SizedBox(
            width: maxWidth ? 219 : 40,
            child: Divider(
              indent: maxWidth ? 25 : 5,
              thickness: 0.8,
              endIndent: maxWidth ? 25 : 5,
              color: theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }

  void changePage(context, index) {
    Navigator.pop(context);
if(widget.isReplacement== true){
  Navigator.of(context).pushReplacementNamed(widget.topBar[index]?.route ?? "");

}else{
  Navigator.of(context).pushNamed(widget.topBar[index]?.route ?? "");

}


  }

  }
