import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/style/responsive_util.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/ar_hadith_model.dart';
import 'chapters_widget.dart'; // For moveToPage usually, but it's on controller extension?
// booksCtrl.moveToPage is used. I need to make sure moveToPage is in extension or controller.
// It was in books_ui_helper.dart in source.

class ChapterExpansionWidget extends StatelessWidget {
  final String chapterTitle;
  final int index;

  const ChapterExpansionWidget({
    super.key,
    required this.chapterTitle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();

    String currentBookName = booksCtrl.arabicHadiths[index - 1].bookName;
    List<ARHadithModel> uniqueChapters = [];

    for (var hadith in booksCtrl.arabicHadiths) {
      if (hadith.bookName == currentBookName &&
          hadith.babName != null &&
          !uniqueChapters.any((element) => element.babName == hadith.babName)) {
        uniqueChapters.add(hadith);
      }
    }

    uniqueChapters.sort((a, b) {
      int aNum = int.tryParse(a.babNumber) ?? 0;
      int bNum = int.tryParse(b.babNumber) ?? 0;
      return aNum.compareTo(bNum);
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        collapsedBackgroundColor:
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
        backgroundColor:
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                chapterTitle,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: ResponsiveUtil.isTablet(context) ? 16 : 22,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        children: [
          SizedBox(
            height: 220,
            child: Scrollbar(
              radius: const Radius.circular(12),
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: uniqueChapters.length,
                itemBuilder: (context, index) {
                  final chapter = uniqueChapters[index];
                  final bool isCurrentChapter =
                      chapter.babName == chapterTitle;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (isCurrentChapter) return;

                      int targetIndex =
                      booksCtrl.arabicHadiths.indexWhere(
                            (h) => h.babName == chapter.babName,
                      );

                      if (targetIndex != -1) {
                        booksCtrl.bookChaptersPageViewCrl.animateToPage(
                          targetIndex + 1,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrentChapter
                            ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentChapter
                            ? Border(
                          right: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            width: 4,
                          ),
                        )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_left_rounded,
                            color: isCurrentChapter
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              chapter.babName ?? 'باب',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'naskh',
                                fontSize: ResponsiveUtil.isTablet(context) ? 15 : 20,
                                fontWeight: isCurrentChapter
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
