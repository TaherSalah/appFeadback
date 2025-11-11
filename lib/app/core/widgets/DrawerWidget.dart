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
class DrawerSection {
  final String title;
  final List<DrawerModle> items;

  DrawerSection({required this.title, required this.items});
}

class DrawerWidget extends StatefulWidget {
  final String selectItmeRoute;
  final List<DrawerSection> sections;
  final bool isReplacement;

  const DrawerWidget(
      this.selectItmeRoute, {
        super.key,
        required this.sections,
        this.isReplacement = false,
      });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> with SingleTickerProviderStateMixin {
  static bool maxWidth = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 85, end: 300).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (maxWidth) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      maxWidth = !maxWidth;
      if (maxWidth) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

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
            child: Drawer(
              width: _widthAnimation.value,
              backgroundColor: isDark
                  ? theme.colorScheme.surface
                  : Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header مع زر التوسيع/الطي
                    _buildHeader(context, theme, isDark),

                    // المحتوى
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        children: [
                          ...widget.sections.map(
                                (section) => _buildSection(context, theme, section, isDark),
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

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                  Text(
                    "رفيق المسلم اليومي",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "اقرأ وتدبّر",
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
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
                  maxWidth ? Icons.menu_open : Icons.menu,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, ThemeData theme, DrawerSection section, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_widthAnimation.value > 180)          Padding(
            padding: const EdgeInsets.only(right: 12, top: 16, bottom: 8),
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
                Text(
                  section.title,
                  style: theme.textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 8),

        ...section.items.map(
              (item) => _buildDrawerItem(context, theme, item, isDark),
        ),

        if (_widthAnimation.value > 180)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Divider(
              thickness: 0.5,
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, ThemeData theme, DrawerModle item, bool isDark) {
    final isSelected = item.route == widget.selectItmeRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);

            if (item.onTap != null) {
              item.onTap!();
              return;
            }

            if (item.route != null && item.route!.isNotEmpty && !isSelected) {
              if (widget.isReplacement || item.isRepl) {
                Navigator.of(context).pushReplacementNamed(item.route!);
              } else {
                Navigator.of(context).pushNamed(item.route!);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.primary.withOpacity(0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
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
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color?.withOpacity(0.7),
                    size: 20,
                  ),
                ),
                if (maxWidth) const SizedBox(width: 12),
                if (_widthAnimation.value > 180)
                  Flexible(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium!.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (maxWidth && isSelected)
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

