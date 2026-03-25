import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';


class ChapterExpansionWidget extends StatelessWidget {
  final String chapterTitle;
  final int index;
  final PageController pageController;

  const ChapterExpansionWidget({
    super.key,
    required this.chapterTitle,
    required this.index,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;
    const Color goldColor = Color(0xFFD4AF37);

    // Get all unique chapters and sort them if necessary
    final uniqueChaptersList = booksCtrl.arabicHadiths
        .map((h) => (babName: h.babName, babNumber: h.babNumber))
        .toSet()
        .toList();

    uniqueChaptersList.sort((a, b) {
      // Try to extract numeric part from babNumber (which might be "1.0")
      double aNum = double.tryParse(a.babNumber ?? '0') ?? 0;
      double bNum = double.tryParse(b.babNumber ?? '0') ?? 0;
      return aNum.compareTo(bNum);
    });

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white24 : goldColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: Icon(
            Icons.format_list_bulleted_rounded,
            color: isDark ? goldColor : baseColor,
          ),
          title: Text(
            _cleanText(chapterTitle),
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: uniqueChaptersList.length,
                itemBuilder: (context, chapterIndex) {
                  final chapter = uniqueChaptersList[chapterIndex];
                  final isCurrentChapter = chapter.babName == chapterTitle;

                  return InkWell(
                    onTap: () {
                      if (isCurrentChapter) return;

                      int targetIndex = booksCtrl.arabicHadiths.indexWhere(
                        (h) => h.babName == chapter.babName,
                      );

                      if (targetIndex != -1) {
                         // +1 because index 0 is book title/cover page
                         final targetPage = targetIndex + 1;
                         
                        pageController.animateToPage(
                          targetPage,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isCurrentChapter
                            ? baseColor.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white10 : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrentChapter
                                  ? baseColor.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              '${chapterIndex + 1}',
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: isCurrentChapter ? baseColor : Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _cleanText(chapter.babName ?? 'بدون عنوان'),
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 13.sp,
                                fontWeight: isCurrentChapter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentChapter
                                    ? baseColor
                                    : (isDark ? Colors.grey[300] : Colors.black87),
                              ),
                            ),
                          ),
                          if (isCurrentChapter)
                            Icon(Icons.check_circle, color: baseColor, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>|&[a-z0-9]+;|<[a-zA-Z]+[^>]*$', caseSensitive: false), '')
        .trim();
  }
}
