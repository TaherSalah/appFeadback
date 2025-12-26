import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../core/shard/constanc/app_style.dart';
import '../controllers/books_controller.dart';
import '../controllers/extensions/books_getters_extension.dart';
import 'widgets/chapters_widget.dart';
import 'bookmarks_view.dart';
import 'search_view.dart';
// import '../../core/utils/helpers/notifications_manager.dart'; // Stubbed



import 'package:flutter/cupertino.dart';

class ReadView extends StatelessWidget {
  ReadView({super.key});

  final booksCtrl = Get.find<BooksController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          booksCtrl.currentCollection.bookName,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchView(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.bookmarks,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksView(),
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Flexible(
             // Removed ChangeBackgroundColorWidget wrapper for now
              child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                    // Simplified orientation padding
                    padding: const EdgeInsets.only(
                            right: 10.0, left: 10.0, bottom: 16.0), 
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, // Use theme color
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        )),
                    child: const HadithsPageView(),
                  )),
        ],
      ),
    );
  }
}
