import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('books'.tr), // Ensure translation key exists
        centerTitle: true,
        // backgroundColor: Theme.of(context).primaryColor,
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
                    title: Constants.collectionsGroupsTitles[0],
                    booksColor: const Color(0xffa24308),
                  ),
                  const Gap(10),
                  // Display "Nine Books" (Index 1 in Constants)
                  BooksCover(
                    title: Constants.collectionsGroupsTitles[1],
                    booksColor: const Color(0xffa24308),
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
