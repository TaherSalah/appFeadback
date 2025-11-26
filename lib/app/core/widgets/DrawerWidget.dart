import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:muslimdaily/app/core/localization/localization_manager.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
class DrawerModle {
  final IconData? icon;
  final String title;
  final String? route;
  final bool loginRequiredShow, isRepl;
  final VoidCallback? onTap;

  DrawerModle({
    this.onTap,
    required this.title,
    this.icon,
    this.isRepl = false,
    this.route,
    this.loginRequiredShow = false,
  });
}

class DrawerSection {
  final String title;
  final List<DrawerModle> items;

  DrawerSection({required this.title, required this.items});
}

class DrawerWidget extends StatefulWidget {
  final String selectItmeRoute;
  final List<DrawerSection> sections;
  final bool isReplacement;

  /// لو true يبدأ الدرج بالحجم الكبير (مفتوح)
  /// لو false يبدأ صغير (السلوك الافتراضي الحالي)
  final bool initiallyExpanded;

  const DrawerWidget(
      this.selectItmeRoute, {
        super.key,
        required this.sections,
        this.isReplacement = false,
        this.initiallyExpanded = false, // الافتراضي زي ما هو (صغير)
      });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  // بدل الـ static maxWidth نخليها حالة داخلية
  late bool _isExpanded;
  // هذه الدالة يتم استدعاؤها بعد اكتمال البناء الأولي
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // الحصول على عرض الشاشة بعد بناء الـ widget
    final double screenWidth = MediaQuery.of(context).size.width;

    // تحديد قيم begin و end بناءً على حجم الشاشة
    double beginValue = screenWidth < 600 ? 85 : 100; // إذا كان الهاتف، يبدأ من 85 وإذا كان التابلت يبدأ من 100
    double endValue = screenWidth < 600 ? 250 : 450; // إذا كان الهاتف، ينتهي عند 250 وإذا كان التابلت ينتهي عند 350

    _isExpanded = widget.initiallyExpanded;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: beginValue, end: endValue).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );

    // لو حابب يبدأ بالحجم الكبير
    if (_isExpanded) {
      _animationController.value = 1.0; // مباشرة على النهاية (قيمة end)
    } else {
      _animationController.value = 0.0; // بداية (قيمة begin)
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  // @override
  // void initState() {
  //   super.initState();
  //
  //   _isExpanded = widget.initiallyExpanded;
  //
  //   _animationController = AnimationController(
  //     duration: const Duration(milliseconds: 200),
  //     vsync: this,
  //   );
  //
  //   _widthAnimation = Tween<double>(begin: 85, end: 250).animate(
  //     CurvedAnimation(parent: _animationController, curve: Curves.ease),
  //   );
  //
  //   // لو حابب يبدأ بالحجم الكبير
  //   if (_isExpanded) {
  //     _animationController.value = 1.0; // مباشرة على النهاية (عرض 250)
  //   } else {
  //     _animationController.value = 0.0; // بداية (عرض 85)
  //   }
  // }

  // @override
  // void dispose() {
  //   _animationController.dispose();
  //   super.dispose();
  // }
  //
  // void _toggleDrawer() {
  //   setState(() {
  //     _isExpanded = !_isExpanded;
  //     if (_isExpanded) {
  //       _animationController.forward();
  //     } else {
  //       _animationController.reverse();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Drawer(
                width: _widthAnimation.value,
                backgroundColor: isDark ? Color(0xFF020617): Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    style: BorderStyle.none,
                    color: isDark ? Colors.amberAccent.shade700 : Colors.white,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.r),
                    bottomLeft: Radius.circular(50.r),
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(context, theme, isDark),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        children: [
                          ...widget.sections.map(
                                (section) =>
                                _buildSection(context, theme, section, isDark),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_widthAnimation.value > 180)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefaultWidget(
                    title: 'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                    fontWeight: FontWeight.bold,
                    fontSize: isTab?15.sp:20.sp,
                    fontFamily: "me",
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  TextDefaultWidget(
                    title: "اقرأ وتدبّر",
                    fontWeight: FontWeight.w600,
                    fontSize: isTab?12.sp:17.sp,
                    fontFamily: "me",
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ],
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleDrawer,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isExpanded ? Icons.menu_open : Icons.menu,
                  color: theme.colorScheme.primary,
                  size: isTab? 45:24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, ThemeData theme,
      DrawerSection section, bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_widthAnimation.value > 180)
          Padding(
            padding:
            const EdgeInsets.only(right: 12, top: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                TextDefaultWidget(
                  title: section.title,
                  fontWeight: FontWeight.w600,
                  fontSize: isTab?10.sp:17.sp,
                  fontFamily: "cairo",
                  color: isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 8),
        ...section.items
            .map((item) => _buildDrawerItem(context, theme, item, isDark)),
        if (_widthAnimation.value > 180)
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 12),
            child: Divider(
              thickness: 0.5,
              color:
              theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, ThemeData theme,
      DrawerModle item, bool isDark) {
    final isSelected = item.route == widget.selectItmeRoute;
    bool isTab = ResponsiveUtil.isTablet(context);

    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);

            if (item.onTap != null) {
              item.onTap!();
              return;
            }

            if (item.route != null &&
                item.route!.isNotEmpty &&
                !isSelected) {
              if (widget.isReplacement || item.isRepl) {
                Navigator.of(context)
                    .pushReplacementNamed(item.route!);
              } else {
                Navigator.of(context).pushNamed(item.route!);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.colorScheme.primary
                      .withOpacity(0.15),
                  theme.colorScheme.primary
                      .withOpacity(0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: theme.colorScheme.primary
                    .withOpacity(0.3),
                width: 1,
              )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        .withOpacity(0.2)
                        : theme.colorScheme.onSurface
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color?.withOpacity(0.7),
                    size: isTab?30:20,
                  ),
                ),
                if (_isExpanded) const SizedBox(width: 12),
                if (_widthAnimation.value > 180)
                  Flexible(
                    child: TextDefaultWidget(
                      title: item.title,
                      fontWeight: FontWeight.w400,
                      fontSize:isTab? 12.sp:17.sp,
                      fontFamily: "me",
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                if (_isExpanded && isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class DrawerModle {
//   final IconData? icon;
//   final String title;
//   final String? route;
//   final bool loginRequiredShow,isRepl;
//   final VoidCallback? onTap;    // اختياري: لتنفيذ دالة مباشرة
//
//
//   DrawerModle(  {
//   this.onTap,
//     required this.title,
//     this.icon,
//      this.isRepl = false,
//     this.route,
//     this.loginRequiredShow = false,
//   });
// }
//
// class DrawerSection {
//   final String title;
//   final List<DrawerModle> items;
//
//   DrawerSection({required this.title, required this.items});
// }
//
// class DrawerWidget extends StatefulWidget {
//   final String selectItmeRoute;
//   final List<DrawerSection> sections;
//   final bool isReplacement;
//   final bool initiallyExpanded;
//
//   const DrawerWidget(
//       this.selectItmeRoute, {
//         super.key,
//         required this.sections,
//         this.isReplacement = false, required this.initiallyExpanded,
//       });
//
//   @override
//   State<DrawerWidget> createState() => _DrawerWidgetState();
// }
//
// class _DrawerWidgetState extends State<DrawerWidget> with SingleTickerProviderStateMixin {
//   static bool maxWidth = false;
//   late AnimationController _animationController;
//   late Animation<double> _widthAnimation;
//   late bool _isExpanded;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _widthAnimation = Tween<double>(begin: 85, end: 250).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.ease),
//     );
//     if (maxWidth) _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleDrawer() {
//     setState(() {
//       maxWidth = !maxWidth;
//       if (maxWidth) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: AnimatedBuilder(
//         animation: _widthAnimation,
//         builder: (context, child) {
//           return ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(20),
//               bottomLeft: Radius.circular(20),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Drawer(
//                 width: _widthAnimation.value,
//                 backgroundColor: isDark
//                     ? Colors.black
//                     : Colors.white,
//                 elevation: 0,
//                 shape:  RoundedRectangleBorder(
//                   side: BorderSide(color:isDark
//                     ? Colors.blue
//                     : Colors.white,),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(50.r),
//                     bottomLeft: Radius.circular(50.r),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     // Header مع زر التوسيع/الطي
//                     _buildHeader(context, theme, isDark),
//
//                     // المحتوى
//                     Expanded(
//                       child: ListView(
//                        physics: BouncingScrollPhysics(),
//                         shrinkWrap: true,
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         children: [
//                           ...widget.sections.map(
//                                 (section) => _buildSection(context, theme, section, isDark),
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical:30, horizontal: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [
//             theme.colorScheme.primary.withOpacity(0.1),
//             theme.colorScheme.primary.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (_widthAnimation.value > 180)
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextDefaultWidget(title:
//                   'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20.sp,
//                     fontFamily: "me",
//                     color: isDark?Colors.white:AppColors.primary,
//                     // style: theme.textTheme.titleLarge!.copyWith(
//                     //   fontWeight: FontWeight.bold,
//                       // color: theme.colorScheme.primary,
//                     // ),
//                   ),
//                   const SizedBox(height: 10),
//                   TextDefaultWidget(title:
//                   "اقرأ وتدبّر",
//                     fontWeight: FontWeight.w600,
//                     fontSize: 17.sp,
//                     fontFamily: "me",
//                     color: isDark?Colors.white:AppColors.primary,
//                     // style: theme.textTheme.titleLarge!.copyWith(
//                     //   fontWeight: FontWeight.bold,
//                     // color: theme.colorScheme.primary,
//                     // ),
//                   ),
//
//                 ],
//               ),
//             ),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: _toggleDrawer,
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   maxWidth ? Icons.menu_open : Icons.menu,
//                   color: theme.colorScheme.primary,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSection(BuildContext context, ThemeData theme, DrawerSection section, bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_widthAnimation.value > 180)          Padding(
//             padding: const EdgeInsets.only(right: 12, top: 16, bottom: 8),
//             child: Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 16,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Text(
//                 //   section.title,
//                 //   style: theme.textTheme.labelLarge!.copyWith(
//                 //     fontWeight: FontWeight.bold,
//                 //     color: theme.colorScheme.primary,
//                 //     letterSpacing: 0.5,
//                 //   ),
//                 // ),
//                 TextDefaultWidget(title:
//                 section.title,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 17.sp,
//                   fontFamily: "cairo",
//                   color: isDark?Colors.white:Colors.black,
//                   // style: theme.textTheme.titleLarge!.copyWith(
//                   //   fontWeight: FontWeight.bold,
//                   // color: theme.colorScheme.primary,
//                   // ),
//                 ),
//
//               ],
//             ),
//           )
//         else
//           const SizedBox(height: 8),
//
//         ...section.items.map(
//               (item) => _buildDrawerItem(context, theme, item, isDark),
//         ),
//
//         if (_widthAnimation.value > 180)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             child: Divider(
//               thickness: 0.5,
//               color: theme.colorScheme.onSurface.withOpacity(0.1),
//             ),
//           )
//         else
//           const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildDrawerItem(BuildContext context, ThemeData theme, DrawerModle item, bool isDark) {
//     final isSelected = item.route == widget.selectItmeRoute;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//
//             if (item.onTap != null) {
//               item.onTap!();
//               return;
//             }
//
//             if (item.route != null && item.route!.isNotEmpty && !isSelected) {
//               if (widget.isReplacement || item.isRepl) {
//                 Navigator.of(context).pushReplacementNamed(item.route!);
//               } else {
//                 Navigator.of(context).pushNamed(item.route!);
//               }
//             }
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: [
//                   theme.colorScheme.primary.withOpacity(0.15),
//                   theme.colorScheme.primary.withOpacity(0.08),
//                 ],
//               )
//                   : null,
//               borderRadius: BorderRadius.circular(12),
//               border: isSelected
//                   ? Border.all(
//                 color: theme.colorScheme.primary.withOpacity(0.3),
//                 width: 1,
//               )
//                   : null,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? theme.colorScheme.primary.withOpacity(0.2)
//                         : theme.colorScheme.onSurface.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     item.icon,
//                     color: isSelected
//                         ? theme.colorScheme.primary
//                         : theme.iconTheme.color?.withOpacity(0.7),
//                     size: 20,
//                   ),
//                 ),
//                 if (maxWidth) const SizedBox(width: 12),
//                 if (_widthAnimation.value > 180)
//                   Flexible(
//                     // child: Text(
//                     //   item.title,
//                     //   style: theme.textTheme.bodyMedium!.copyWith(
//                     //     color: isSelected
//                     //         ? theme.colorScheme.primary
//                     //         : theme.textTheme.bodyMedium!.color,
//                     //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     //   ),
//                     //   overflow: TextOverflow.ellipsis,
//                     // ),
//                     child:   TextDefaultWidget(title:
//                     item.title,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 17.sp,
//                       fontFamily: "me",
//                       color: isDark?Colors.white:Colors.black,
//                       // style: theme.textTheme.titleLarge!.copyWith(
//                       //   fontWeight: FontWeight.bold,
//                       // color: theme.colorScheme.primary,
//                       // ),
//                     ),
//
//                   ),
//                 if (maxWidth && isSelected)
//                   Container(
//                     width: 6,
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

