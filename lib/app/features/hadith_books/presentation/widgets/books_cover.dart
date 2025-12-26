import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/collection_model.dart';

// Helper for SVG rendering since original extensions are missing
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

Widget bookNameLogo(String id, Color color, String collectionName) {
  print('Loading SVG: assets/svg/book_name/$id.svg'); // Debug log
  return SvgPicture.asset(
    'assets/svg/book_name/$id.svg',
    // Temporarily removed colorFilter to test if it's causing issues
    // colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    fit: BoxFit.contain,
    placeholderBuilder: (context) {
      print('Placeholder shown for: $id'); // Debug log
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            collectionName.substring(0, min(2, collectionName.length)).toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'cairo'
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

// Simplified BooksCover for Collections only
class BooksCover extends StatelessWidget {
  final String title;
  final Color? booksColor;

  BooksCover({super.key, required this.title, this.booksColor});

  final booksCtrl = Get.find<BooksController>();

  @override
  Widget build(BuildContext context) {
    List<Collection> collectionsGroup = booksCtrl.getCollectionsGroupByTitle(title);
    if (collectionsGroup.isEmpty) return const SizedBox.shrink();

    // Stubbing CheckRtlLayout for now, defaulting to align right for Arabic context usually or center
    Alignment hAlign = Alignment.centerRight; // Default for Arabic lists usually

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          Align(
            alignment: hAlign,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title.tr, // Ensure .tr is available via Get
                style: TextStyle(
                  fontSize: ResponsiveUtil.isTablet(context) ? 15.0 : 19,
                  fontFamily: 'kufi',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.start,
              children: List.generate(
                collectionsGroup.length,
                (index) => Column(
                  children: [
                    AnimationLimiter(
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
                                height: ResponsiveUtil.isTablet(context) ? 135 : 120,
                                width: ResponsiveUtil.isTablet(context) ? 120 : 120,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    )),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: ResponsiveUtil.isTablet(context) ? 25 : 45,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: RotatedBox(
                                            quarterTurns: 3,
                                            child: Text(
                                              collectionsGroup[index].bookName,
                                              style: TextStyle(
                                                fontSize: ResponsiveUtil.isTablet(context) ? 12.0 : 16,
                                                fontFamily: 'kufi',
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).primaryColorDark,
                                              ),
                                              textAlign: TextAlign.justify,
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Hero(
                                      tag: 'book-tag-:${collectionsGroup[index].id!}',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            customSvgWithColor(
                                              SvgPath.svgBookCover,
                                              height: ResponsiveUtil.isTablet(context) ? 130.0 : 170,
                                              color: booksColor ?? Theme.of(context).primaryColor, // Fallback color
                                            ),
                                            customSvg(SvgPath.svgBookCoverLogo,
                                                height: ResponsiveUtil.isTablet(context) ? 130.0 : 170),
                                            Transform.translate(
                                              offset: ResponsiveUtil.isTablet(context)
                                                  ? const Offset(-5, 10)
                                                  : const Offset(-10, 0),
                                              child: SizedBox(
                                                height: ResponsiveUtil.isTablet(context) ? 60 : 120,
                                                width: ResponsiveUtil.isTablet(context) ? 70 : 110,
                                                child: bookNameLogo(
                                                  '${max(0, collectionsGroup[index].id! - 1)}',
                                                  const Color(0xFF3C2A21),
                                                  collectionsGroup[index].bookName
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
