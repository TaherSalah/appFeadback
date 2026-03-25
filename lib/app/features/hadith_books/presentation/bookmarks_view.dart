import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../../core/utils/style/k_color.dart';
import '../controllers/books_controller.dart';
import 'widgets/bookmark_card.dart';

class BookmarksView extends StatelessWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseColor = KColors.primaryColor;

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text(
      //     'الأحاديث المحفوظة',
      //     style: GoogleFonts.cairo(
      //       fontWeight: FontWeight.bold,
      //       color: isDark ? Colors.white : Colors.black87,
      //       fontSize: 18.sp,
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => CreateKhatmahScreen(),
          //       ),
          //     ),
          //     icon: const Icon(Icons.add),
          //   )
          // ],
          centerTitle: true,
          title: Text(
              'الأحاديث المحفوظة',
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

      body: GetBuilder<BooksController>(
        builder: (ctrl) {
          final categories = ctrl.getBookmarkCategories();
          
          return DefaultTabController(
            length: categories.length + 1, // +1 for "الكل" tab
            child: Column(
              children: [
                // Category Tabs
                if (categories.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[700],
                      labelStyle: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: 'الكل (${ctrl.getBookmarkCount()})'),
                        ...categories.map((cat) => Tab(
                          text: '$cat (${ctrl.getBookmarkCount(category: cat)})',
                        )),
                      ],
                    ),
                  ),
                
                // Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // All bookmarks
                      _buildBookmarksList(ctrl, null, isDark),
                      // Category-specific bookmarks
                      ...categories.map((cat) => _buildBookmarksList(ctrl, cat, isDark)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarksList(BooksController ctrl, String? category, bool isDark) {
    final bookmarks = ctrl.getBookmarks(category: category);
    
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد أحاديث محفوظة',
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بحفظ الأحاديث المفضلة لديك',
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return BookmarkCard(
          bookmark: bookmark,
          onDelete: () async {
            await ctrl.deleteBookmark(bookmark.id!);
          },
          onCategoryChange: (newCategory) async {
            await ctrl.updateBookmarkCategory(bookmark.id!, newCategory);
          },
        );
      },
    );
  }
}
