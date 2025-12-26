import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/utils/style/responsive_util.dart';
import '../../../data/models/collection_model.dart';

// Helper for SVG rendering
Widget customSvgWithColor(String path, {double? height, Color? color}) {
  return SvgPicture.asset(
    path,
    height: height,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

Widget customSvg(String path, {double? height}) {
  return SvgPicture.asset(
    path,
    height: height,
  );
}

Widget bookNameLogo(String id, Color color, {double? height}) {
  return SvgPicture.asset(
    'assets/svg/book_name/$id.svg',
    height: height,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

class SvgPath {
  static const String svgBookCover = 'assets/svg/bookCover.svg';
  static const String svgBookCoverLogo = 'assets/svg/bookCoverLogo.svg';
}

class BookName extends StatelessWidget {
  const BookName({super.key, required this.bookDetails});
  final dynamic bookDetails; // Expecting Collection

  @override
  Widget build(BuildContext context) {
    Collection collection = bookDetails;
    return Column(
      children: [
        Hero(
          tag: 'book-tag-:${collection.id!}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        )),
                    child: customSvgWithColor(
                      SvgPath.svgBookCover,
                      height: ResponsiveUtil.isTablet(context) ? 280.0 : 300,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  customSvg(SvgPath.svgBookCoverLogo,
                      height: ResponsiveUtil.isTablet(context) ? 280.0 : 300),
                  Transform.translate(
                    offset: ResponsiveUtil.isTablet(context)
                        ? const Offset(-10, 20)
                        : const Offset(-15, 5),
                    child: SizedBox(
                      height: ResponsiveUtil.isTablet(context) ? 140 : 200,
                      width: ResponsiveUtil.isTablet(context) ? 140 : 190,
                      child: bookNameLogo(
                              '${collection.id! - 1}', const Color(0xFF3C2A21),
                              height: ResponsiveUtil.isTablet(context) ? 110 : 130)
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const Gap(20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                width: 1,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              )),
          child: Center(
                child: Text(
                  collection.arAndEnName,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtil.isTablet(context) ? 22.0 : 30,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              )
          ),
      ],
    );
  }
}
