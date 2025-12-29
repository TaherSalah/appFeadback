import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/bn_hadith_model.dart';
import '../../data/models/en_hadith_model.dart';
import '../../data/models/ur_hadith_model.dart';
import 'book_other_name.dart';
import 'chapter_expansion_widget.dart';
import 'hadith_in_arabic.dart';

class HadithsPageView extends StatelessWidget {
  final PageController pageController;
  const HadithsPageView({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final baseColor = KColors.primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetX<BooksController>(
        builder: (booksCtrl) => booksCtrl.arabicHadiths.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : PageView.builder(
                itemCount: booksCtrl.currentBookHadithsCount + 1,
                controller: pageController,
                reverse: false, // Let Directionality handle RTL naturally
                onPageChanged: (index) {
                   booksCtrl.changePage(index);
                   // If we need to sync back to controller, we could, but better to keep it decoupled
                },
                itemBuilder: (context, index) {
                  ENHadithModel? enLangHadith;
                  URHadithModel? urLangHadith;
                  BNHadithModel? bnLangHadith;
                  
                  if (index != 0) {
                    if (booksCtrl.currentTranslationLangCode.value == 'ur') {
                      urLangHadith = booksCtrl.getUrHadithByIndex(index - 1);
                    } else if (booksCtrl.currentTranslationLangCode.value == 'bn') {
                      bnLangHadith = booksCtrl.getBnHadithByIndex(index - 1);
                    } else {
                      enLangHadith = booksCtrl.getEnHadithByIndex(index - 1);
                    }
                  }

                  return booksCtrl.arabicHadiths.length < index && index != 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('جاري التحميل...'),
                            const CircularProgressIndicator.adaptive(),
                          ],
                        )
                      : ListView(
                          primary: false,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (index != 0)
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 16.w, left: 16.w, top: 24.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    hadithBookAndCollectionNames(
                                        booksCtrl, context, index),
                                    const Gap(8),
                                    ChapterExpansionWidget(
                                      chapterTitle: booksCtrl
                                              .arabicHadiths[index - 1]
                                              .babName ??
                                          'تحميل الباب...',
                                      index: index,
                                      pageController: pageController,
                                    ),
                                    const Gap(16),
                                  ],
                                ),
                              ),
                            if (index == 0) const BookOtherName(),
                            if (index != 0)
                              ActualHadithWidget(
                                hadithIndex: index,
                                otherLangText: enLangHadith?.hadithText ?? 
                                               urLangHadith?.hadithText ?? 
                                               bnLangHadith?.hadithText ?? 
                                               'لا يوجد ترجمة حالياً',
                                pageController: pageController,
                              ),
                            const Gap(40),
                          ],
                        );
                },
              ),
      ),
    );
  }

  Widget hadithBookAndCollectionNames(
      BooksController booksCtrl, BuildContext context, int index) {
    final baseColor = KColors.primaryColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.collections_bookmark_rounded, size: 16.sp, color: baseColor),
          SizedBox(width: 8.w),
          Text(
            booksCtrl.currentCollection.bookName,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: baseColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text("/", style: TextStyle(color: baseColor.withOpacity(0.3))),
          ),
          Expanded(
            child: Text(
              booksCtrl.arabicHadiths[index - 1].bookName,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ActualHadithWidget extends StatelessWidget {
  const ActualHadithWidget({
    super.key,
    required this.hadithIndex,
    required this.otherLangText,
    required this.pageController,
  });
  
  final int hadithIndex;
  final String otherLangText;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();
    return HadithInArabic(
      arabicHadith: booksCtrl.arabicHadiths[hadithIndex - 1],
      otherLangHadithText: otherLangText,
    );
  }
}
