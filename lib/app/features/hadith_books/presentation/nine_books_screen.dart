import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/constent/lists.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../controllers/books_controller.dart';
import 'widgets/books_cover.dart';

class NineBooksScreen extends StatelessWidget {
  const NineBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final BooksController booksCtrl = Get.put(BooksController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('الكت'), // Ensure translation key exists
      //   centerTitle: true,
      //   // backgroundColor: Theme.of(context).primaryColor,
      // ),
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
            "المكتبة الاسلامية",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Force RTL for Arabic content
        child: GetBuilder<BooksController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Display "Six Books" (Index 0 in Constants)
                  BooksCover(
                    booksColor: Colors.red,
                    title: Constants.collectionsGroupsTitles[0],
                  ),
                  const Gap(10),
                  // Display "Nine Books" (Index 1 in Constants)
                  BooksCover(
                    booksColor: Colors.red,

                    title: Constants.collectionsGroupsTitles[1],
                  ),
                  const Gap(10),
                  // Display "Other Books" (Index 2 in Constants)
                  BooksCover(
                    booksColor: Colors.red,

                    title: Constants.collectionsGroupsTitles[2],
                  ),
                  const Gap(20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
