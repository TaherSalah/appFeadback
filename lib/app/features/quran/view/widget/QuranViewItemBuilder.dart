import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/DrawerWidget.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:quran_library/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranViewItemBuilder extends StatefulWidget {
  const QuranViewItemBuilder({super.key});

  @override
  _QuranViewItemBuilderState createState() => _QuranViewItemBuilderState();
}

class _QuranViewItemBuilderState extends State<QuranViewItemBuilder>
    with SingleTickerProviderStateMixin {
  var selectedFontSize;

  late List<DrawerModle?> topBar = [
    DrawerModle(
        icon: Icons.search, title: "البحث بالاية", route: "/ayaSearchScreen"),

    DrawerModle(
        icon: Icons.favorite_border,
        title: "فضل قرأه القران",
        route: Routes.quranLoveRoute),
    DrawerModle(
        icon: Icons.list, title: "فهرس القران الكريم", route: "/ListScreen"),
    DrawerModle(
        icon: Icons.dashboard_customize_outlined,
        title: "الاجزاء",
        route: Routes.jozzaListScreenRoute),
    DrawerModle(
        icon: Icons.chrome_reader_mode_outlined,
        title: "انشاء ختمة جديدة",
        isRepl: true,
        route: "/KhatmahHome"),
    DrawerModle(
        icon: Icons.preview_outlined,
        title: "الختمات المنجزه",

        route: "/compplateKhatna"),

    DrawerModle(
        icon: Icons.category_outlined,
        title: "الاحزاب",
        route: Routes.hizbeListScreenRoute),
    DrawerModle(
      icon: Icons.bookmark_add_outlined,
      title: "اضافة علامة للصفحة",
      onTap: () => _saveBookmark(_currentPage!),
    ),
    DrawerModle(
      icon: Icons.bookmark_remove_outlined,
      title: " ازالة العلامه",
      onTap: _delBookmark,
    ),
    DrawerModle(
      icon: Icons.navigation_outlined,
      title: "انتقال الي العلامه",
      onTap: _goToBookmark,
    ),
    // DrawerModle(
    //     icon: Icons.bookmarks_outlined,
    //     title: "الايات المحفوظة",
    //     route: "/ayaBookmarkScreen"),
    DrawerModle(
        icon: Icons.info_outline,
        title: "دعاء ختم القران الكريم",
        route: Routes.quranKhitamRoute),
    DrawerModle(
        icon: Icons.gpp_good_outlined,
        title: "التفسير",
        route: Routes.tafsirQuranRoute),
    DrawerModle(
        icon: Icons.dark_mode_outlined,
        title: "الوضع الليلي",
        onTap: _changeMode),
  ];

  int? _currentPage = 0;
  int? _bookmarkedPage;

  @override
  void initState() {
    super.initState();
    _loadPages();
    QuranLibrary().init();
    selectedFontSize = "25";
  }

  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('last_page') ?? 0; // افتراضي الصفحة الأولى
    _bookmarkedPage = prefs.getInt('bookmark_page');

    setState(() {
      _currentPage = lastPage;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPage != null) {
        QuranLibrary().jumpToPage(_currentPage! + 1);
      }
    });
  }

  void _saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', page);
  }

  void _saveBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bookmark_page', page);
    setState(() {
      _bookmarkedPage = page;
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('✅ تم حفظ العلامة على الصفحة $page')),
    // );
    KHelper.showSuccess(message: ' ✅ تم حفظ العلامة على الصفحة $page ');
  }

  void _delBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmark_page');
    setState(() {
      _bookmarkedPage = null;
    });
    KHelper.showSuccess(message: "تم ازالة العلامة");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('✅ تم ازالة العلامة')),
    // );
  }

  void _goToBookmark() {
    if (_bookmarkedPage != null) {
      setState(() {
        _currentPage = _bookmarkedPage!;
        QuranLibrary().jumpToPage(_bookmarkedPage!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا توجد علامة محفوظة')),
      );
    }
  }

  Widget _buildList(List<String> items, Function(int index) onTap) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, index) => ListTile(
        title: TextWidget(
          title: items[index],
        ),
        onTap: () => onTap(index),
      ),
    );
  }

  bool isDark = false;

  void _changeMode() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    QuranLibrary().currentPageNumber;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // خلفية السكافولد
        drawer: DrawerWidget(
          "/surahListScreen",
          topBar: topBar,
        ), // <<< هنا بتحط الـ Drawer

        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/ayaSearchScreen");
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.search,
                    size: 30,
                  ),
                ),
              ),
            ],
            centerTitle: true,
            title: Text(
              "القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),

        body: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            // color: isDark ? Colors.black : AppStyle.bgColors,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black87],
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.zero,
              child: _currentPage == null
                  ? Center(
                      child:
                          KLoading.progressIOSIndicator()) // لحد ما يجيب الصفحة
                  : QuranLibraryScreen(
                      ayaFontSize: double.parse(selectedFontSize),
                      isDark: isDark,

                      pageIndex: _currentPage!,
                      // يبدأ من آخر صفحة محفوظة
                      backgroundColor:
                          isDark ? Colors.black : const Color(0xffFFFFF0),
                      topTitleChild: const SizedBox(),

                      optimizeScrolling: false,
                      useDefaultAppBar: false,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                        _saveCurrentPage(page); // تحديث التخزين
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
