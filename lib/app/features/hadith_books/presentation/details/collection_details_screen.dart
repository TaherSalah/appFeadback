import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../../core/utils/constent/lists.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import 'widgets/about_book.dart';
import 'widgets/book_name.dart';
import 'widgets/books_list.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final int? bookNumber;
  final int? bookIndex;

  const CollectionDetailsScreen({super.key, this.bookNumber, this.bookIndex});

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();
    final collection = booksCtrl.currentCollection;
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              collection.bookName,
              style: TextStyle(
                  fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: CustomScrollView(
          slivers: [
            // Premium SliverAppBar
            // SliverAppBar(
            //   expandedHeight: 140.h,
            //   floating: false,
            //   pinned: true,
            //   backgroundColor: isDark ? const Color(0xFF1a1a2e) : AppColors.primary,
            //   elevation: 0,
            //   leading: IconButton(
            //     icon: Icon(CupertinoIcons.back, color: Colors.white),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            //   flexibleSpace: FlexibleSpaceBar(
            //     centerTitle: true,
            //     title: Text(
            //       collection.bookName,
            //       style: GoogleFonts.cairo(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 18.sp,
            //       ),
            //     ),
            //     background: Stack(
            //       fit: StackFit.expand,
            //       children: [
            //         if (!isDark)
            //           Image.asset(
            //             "assets/images/8180jjj00005.webp",
            //             fit: BoxFit.cover,
            //             opacity: const AlwaysStoppedAnimation(0.2),
            //           ),
            //         Container(
            //           decoration: BoxDecoration(
            //             gradient: LinearGradient(
            //               begin: Alignment.topCenter,
            //               end: Alignment.bottomCenter,
            //               colors: [
            //                 Colors.black.withOpacity(0.3),
            //                 Colors.transparent,
            //               ],
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Collection Summary/Cover
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: BookName(bookDetails: collection),
              ),
            ),

            // About Book Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AboutBook(
                  bookDetails: _getBookDetails(collection.id ?? 1),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(24)),

            // Books List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'قائمة الكتب',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Books List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: const SliverToBoxAdapter(
                child: BooksList(),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(40)),
          ],
        ),
      ),
    );
  }

  String _getBookDetails(int collectionId) {
    // Collection IDs are 1-indexed, booksList is 0-indexed
    final bookIndex = collectionId - 1;
    if (bookIndex >= 0 && bookIndex < booksList.length) {
      return booksList[bookIndex]['details'] ??
          'لا توجد معلومات متاحة عن هذا الكتاب';
    }
    return 'لا توجد معلومات متاحة عن هذا الكتاب';
  }
}
