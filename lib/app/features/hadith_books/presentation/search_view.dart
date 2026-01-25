import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/features/hadith_books/presentation/widgets/search_result_card.dart';

import '../../../core/utils/style/k_color.dart';
import '../../../core/widgets/KLoading.dart';
import '../controllers/books_controller.dart';
import '../controllers/search_controller.dart' as hadith_search;

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final searchCtrl = Get.put(hadith_search.SearchController());
  final booksCtrl = Get.find<BooksController>();
  final TextEditingController textController = TextEditingController();
  
  String _searchType = 'text'; // 'text', 'narrator', 'book', 'advanced'

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
         // appBar: AppBar(
        //   centerTitle: true,
        //   title: Text(
        //     'البحث في الأحاديث',
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
              'البحث في الأحاديث',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
      
        body: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: baseColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: textController,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  hintStyle: GoogleFonts.cairo(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: baseColor,
                  ),
                  suffixIcon: Obx(() {
                    if (searchCtrl.currentQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        textController.clear();
                        searchCtrl.clearSearch();
                      },
                    );
                  }),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                onChanged: (value) {
                  if (value.length >= 2) {
                    _performSearch(value);
                  } else if (value.isEmpty) {
                    searchCtrl.clearSearch();
                  }
                },
              ),
            ),
      
            // Search Type Chips
            SizedBox(
              height: 45.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildSearchTypeChip('نص الحديث', 'text', Icons.text_fields, isDark, baseColor),
                  SizedBox(width: 8.w),
                  _buildSearchTypeChip('الراوي', 'narrator', Icons.person, isDark, baseColor),
                  SizedBox(width: 8.w),
                  _buildSearchTypeChip('الكتاب', 'book', Icons.book, isDark, baseColor),
                ],
              ),
            ),
      
            SizedBox(height: 16.h),
      
            // Results Count
            Obx(() {
              if (searchCtrl.searchResults.isEmpty && searchCtrl.currentQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18.sp,
                      color: baseColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'النتائج: ${searchCtrl.searchResults.length}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
      
            SizedBox(height: 8.h),
      
            // Results List
            Expanded(
              child: Obx(() {
                if (searchCtrl.isSearching.value) {
                  return Center(
                    child:  KLoading.progressIOSIndicator(context: context,progressColor: baseColor),
                  );
                }
      
                if (searchCtrl.currentQuery.value.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search,
                    title: 'ابدأ البحث',
                    subtitle: 'اكتب كلمة أو عبارة للبحث في الأحاديث',
                    isDark: isDark,
                  );
                }
      
                if (searchCtrl.searchResults.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off,
                    title: 'لا توجد نتائج',
                    subtitle: 'جرب كلمات بحث مختلفة',
                    isDark: isDark,
                  );
                }
      
                return ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: searchCtrl.searchResults.length,
                  itemBuilder: (context, index) {
                    final hadith = searchCtrl.searchResults[index];
                    return SearchResultCard(
                      hadith: hadith,
                      searchQuery: textController.text,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeChip(
    String label,
    String type,
    IconData icon,
    bool isDark,
    Color baseColor,
  ) {
    final isSelected = _searchType == type;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _searchType = type;
          if (textController.text.isNotEmpty) {
            _performSearch(textController.text);
          }
        });
      },
      selectedColor: baseColor,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? baseColor : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_searchType) {
      case 'narrator':
        return 'ابحث عن راوي الحديث...';
      case 'book':
        return 'ابحث عن كتاب...';
      default:
        return 'ابحث في الأحاديث...';
    }
  }

  void _performSearch(String query) {
    switch (_searchType) {
      case 'narrator':
        searchCtrl.searchByNarrator(query);
        break;
      case 'book':
        searchCtrl.filterByBook(query);
        break;
      default:
        searchCtrl.searchInText(query);
    }
  }
}
