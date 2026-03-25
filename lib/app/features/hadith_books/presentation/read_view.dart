
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/books_controller.dart';
import '../controllers/extensions/books_getters_extension.dart';
import 'bookmarks_view.dart';
import 'search_view.dart';
import 'widgets/chapters_widget.dart';

class ReadView extends StatefulWidget {
  final int initialPage;
  const ReadView({super.key, this.initialPage = 0});

  @override
  State<ReadView> createState() => _ReadViewState();
}

class _ReadViewState extends State<ReadView> {
  final booksCtrl = Get.find<BooksController>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text(
      //     booksCtrl.currentCollection.bookName,
      //     style: GoogleFonts.cairo(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //       fontSize: 18.sp,
      //     ),
      //   ),
      //   backgroundColor: isDark ? const Color(0xFF1a1a2e) : AppColors.primary,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(
      //       CupertinoIcons.back,
      //       color: Colors.white,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.search,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => const SearchView(),
      //           ),
      //         );
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(
      //         Icons.bookmarks,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => const BookmarksView(),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),

        child: AppBar(
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
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
                color: Colors.white,
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
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            booksCtrl.currentCollection.bookName,
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

      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Flexible(
              child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.only(
                            right: 10.0, left: 10.0, bottom: 16.0), 
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        )),
                    child: HadithsPageView(pageController: _pageController),
                  )),
        ],
      ),
    );
  }
}
