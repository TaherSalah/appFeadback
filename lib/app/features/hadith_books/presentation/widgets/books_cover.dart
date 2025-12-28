import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';

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
    List<Collection> collectionsGroup = booksCtrl.getCollectionsGroupByTitle(title);
    if (collectionsGroup.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          // Section Title
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                title.tr,
                style: KTextStyle.of(context).subtitle.copyWith(
                  fontSize: ResponsiveUtil.isTablet(context) ? 18.0 : 20,
                  color: KColors.of(context).primary,
                ),
              ),
            ),
          ),
          
          // Books Grid/List
          Align(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 16,
              children: List.generate(
                collectionsGroup.length,
                (index) => AnimationLimiter(
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 450),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () => booksCtrl.setAndShowCollectionByCollectionId(
                              collectionsGroup[index].id!,
                              collectionsGroup[index].id!),
                          child: Container(
                            height: ResponsiveUtil.isTablet(context) ? 160 : 140,
                            width: ResponsiveUtil.isTablet(context) ? 130 : 110,
                            decoration: BoxDecoration(
                                // color: Theme.of(context).cardColor,
                                color: AppThemeColors.cardBackgroundColor(context),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Book Cover Base Color
                                customSvgWithColor(
                                  SvgPath.svgBookCover,
                                  height: ResponsiveUtil.isTablet(context) ? 140.0 : 125,
                                  color: booksColor ?? KColors.of(context).primary,
                                ),
                                
                                // Decorative Pattern
                                customSvg(
                                  SvgPath.svgBookCoverLogo,
                                  height: ResponsiveUtil.isTablet(context) ? 140.0 : 110
                                ),
                                
                                // Book Title (Centered correctly)
                                Positioned(
                                  top: ResponsiveUtil.isTablet(context) ? 40 : 35,
                                  child: SizedBox(
                                    height: ResponsiveUtil.isTablet(context) ? 70 : 60,
                                    width: ResponsiveUtil.isTablet(context) ? 80 : 70,
                                    child: Center(
                                      child: bookNameLogo(
                                        context,
                                        '${max(0, collectionsGroup[index].id! - 1)}',
                                        const Color(0xFF3C2A21), // Dark brown for text contrasts well with primary
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
