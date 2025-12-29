import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';

import '../../../../core/shard/exports/all_exports.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/utils/style/k_style.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/collection_model.dart';

// Helper for SVG rendering
Widget customSvgWithColor(String path, {double? height, Color? color}) {
  return SvgPicture.asset(
    path,
    height: height,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    placeholderBuilder: (context) => Container(
      height: height,
      width: (height ?? 170) * 0.7,
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.book, color: color),
    ),
  );
}

Widget customSvg(String path, {double? height}) {
  return SvgPicture.asset(
    path,
    height: height,
    placeholderBuilder: (context) => const SizedBox.shrink(),
  );
}

Widget bookNameLogo(BuildContext context, String id, Color color, String collectionName) {
  return SvgPicture.asset(
    'assets/svg/book_name/$id.svg',
    color: Colors.white,
    fit: BoxFit.contain,
    placeholderBuilder: (context) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            collectionName.substring(0, min(10, collectionName.length)), // Increased length text
            textAlign: TextAlign.center,
            style: KTextStyle.of(context).body2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14 : 16,
              height: 1.2,
            ),
          ),
        ),
      );
    },
  );
}

class SvgPath {
  static const String svgBookCover = 'assets/svg/bookCover.svg';
  static const String svgBookCoverLogo = 'assets/svg/bookCoverLogo.svg';
}

class BooksCover extends StatelessWidget {
  final String title;
  final Color? booksColor;

  BooksCover({super.key, required this.title, this.booksColor});

  final booksCtrl = Get.find<BooksController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    List<Collection> collectionsGroup = booksCtrl.getCollectionsGroupByTitle(title);
    if (collectionsGroup.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          // Section Title with Decoration
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0), AppColors.primary.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    title.tr,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Books Grid/List
          Align(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.w,
              runSpacing: 16.h,
              children: List.generate(
                collectionsGroup.length,
                (index) => AnimationLimiter(
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 450),
                    child: ScaleAnimation(
                      scale: 0.9,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () => booksCtrl.setAndShowCollectionByCollectionId(
                              collectionsGroup[index].id!,
                              collectionsGroup[index].id!),
                          child: Container(
                            decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDark ? Colors.white24 : const Color(0xFFD4AF37).withOpacity(0.4),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Book Cover Base Color
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: customSvgWithColor(
                                    SvgPath.svgBookCover,
                                    height: ResponsiveUtil.isTablet(context) ? 140.0 : 125,
                                    color: booksColor ?? KColors.of(context).primary,
                                  ),
                                ),
                                
                                // Decorative Pattern
                                customSvg(
                                  SvgPath.svgBookCoverLogo,
                                  height: ResponsiveUtil.isTablet(context) ? 140.0 : 110
                                ),
                                
                                // Book Title (Centered correctly)
                                Positioned(
                                  top: ResponsiveUtil.isTablet(context) ? 40 : 45,
                                  child: SizedBox(
                                    height: ResponsiveUtil.isTablet(context) ? 70 : 60,
                                    width: ResponsiveUtil.isTablet(context) ? 80 : 70,
                                    child: Center(
                                      child: bookNameLogo(
                                        context,
                                        '${max(0, collectionsGroup[index].id! - 1)}',
                                        const Color(0xFF3C2A21), 
                                        collectionsGroup[index].bookName
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
