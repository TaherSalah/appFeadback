import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/DrawerWidget.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/style/responsive_util.dart';

enum _QuranMenuAction {
  audio,
  orientation,
   background
}

class QuranViewItemBuilder extends StatefulWidget {
  const QuranViewItemBuilder({super.key});

  @override
  _QuranViewItemBuilderState createState() => _QuranViewItemBuilderState();
}

class _QuranViewItemBuilderState extends State<QuranViewItemBuilder>
    with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color _darkBackgroundColor = const Color(0xFF101623);
  Color _lightBackgroundColor = const Color(0xFFF7F1E1);

  Color get _backgroundColor =>
      isDark ? _darkBackgroundColor : _lightBackgroundColor;
  List<Color> get _darkColors => const [
    Color(0xFF101623), // رمادي مزرق
    Color(0xFF121212), // رمادي داكن
    Color(0xFF0B1A14), // أخضر داكن
    Color(0xFF0B1020), // أزرق داكن
  ];

  List<Color> get _lightColors => const [
    Color(0xFFF7F1E1), // بيج فاتح
    Color(0xFFFFFFFF), // أبيض
    Color(0xFFF0F4F8), // رمادي فاتح مزرق
    Color(0xFFFFF8E1), // أصفر فاتح دافئ
  ];

  void _showBackgroundColorPicker() async {
    // يختار الباليت حسب الوضع الحالي
    final colors = isDark ? _darkColors : _lightColors;

    final Color? selected = await showModalBottomSheet<Color>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((c) {
              final bool isSelected = c ==
                  (isDark ? _darkBackgroundColor : _lightBackgroundColor);

              return GestureDetector(
                onTap: () => Navigator.of(context).pop(c),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isDark) {
          _darkBackgroundColor = selected;
        } else {
          _lightBackgroundColor = selected;
        }
      });
    }
  }

  // late List<DrawerModle?> topBar = [
  //   DrawerModle(
  //       icon: Icons.search, title: "البحث بالاية", route: "/ayaSearchScreen"),
  //   DrawerModle(
  //       icon: Icons.gpp_good_outlined,
  //       title: "التفسير",
  //       route: Routes.tafsirQuranRoute),
  //
  //   DrawerModle(
  //       icon: Icons.list, title: "فهرس القران الكريم", route: "/ListScreen"),
  //   DrawerModle(
  //       icon: Icons.dashboard_customize_outlined,
  //       title: "الاجزاء",
  //       route: Routes.jozzaListScreenRoute),
  //   DrawerModle(
  //       icon: Icons.category_outlined,
  //       title: "الاحزاب",
  //       route: Routes.hizbeListScreenRoute),
  //   DrawerModle(
  //       icon: Icons.chrome_reader_mode_outlined,
  //       title: "انشاء ختمة جديدة",
  //       isRepl: true,
  //       route: "/KhatmahHome"),
  //   DrawerModle(
  //       icon: Icons.preview_outlined,
  //       title: "الختمات المنجزه",
  //       route: "/compplateKhatna"),
  //
  //   DrawerModle(
  //     icon: Icons.bookmark_add_outlined,
  //     title: "اضافة علامة للصفحة",
  //     onTap: () => _saveBookmark(_currentPage!),
  //   ),
  //   DrawerModle(
  //     icon: Icons.bookmark_remove_outlined,
  //     title: " ازالة العلامه",
  //     onTap: _delBookmark,
  //   ),
  //   DrawerModle(
  //     icon: Icons.navigation_outlined,
  //     title: "انتقال الي العلامه",
  //     onTap: _goToBookmark,
  //   ),
  //   DrawerModle(
  //       icon: Icons.bookmarks_outlined,
  //       title: "الايات المحفوظة",
  //       route: "/ayaBookmarkScreen"),
  //   DrawerModle(
  //       icon: Icons.info_outline,
  //       title: "دعاء ختم القران الكريم",
  //       route: Routes.quranKhitamRoute),
  //   DrawerModle(
  //       icon: Icons.favorite_border,
  //       title: "فضل قرأه القران",
  //       route: Routes.quranLoveRoute),
  //
  //   // DrawerModle(
  //   //     icon: Icons.dark_mode_outlined,
  //   //     title: "الوضع الليلي",
  //   //     onTap: _changeMode),
  // ];
  late List<DrawerSection> drawerSections = [
    DrawerSection(
      title: "بَحْثٌ وَتَفْسِيرٌ",
      items: [
        DrawerModle(
          icon: Icons.search,
          title: "البَحْثُ بِالآيَةِ",
          route: "/ayaSearchScreen",
        ),
        DrawerModle(
          icon: Icons.gpp_good_outlined,
          title: "التَّفْسِيرُ",
          route: Routes.tafsirQuranRoute,
        ),
      ],
    ),
    DrawerSection(
      title: "فِهْرِسُ القُرْآنِ",
      items: [
        DrawerModle(
          icon: Icons.list,
          title: "فِهْرِسُ القُرْآنِ الكَرِيمِ",
          route: "/ListScreen",
        ),
        DrawerModle(
          icon: Icons.dashboard_customize_outlined,
          title: "الأَجْزَاءُ",
          route: Routes.jozzaListScreenRoute,
        ),
        DrawerModle(
          icon: Icons.category_outlined,
          title: "الأَحْزَابُ",
          route: Routes.hizbeListScreenRoute,
        ),
      ],
    ),
    DrawerSection(
      title: "الخَتْمَاتُ",
      items: [
        DrawerModle(
          icon: Icons.chrome_reader_mode_outlined,
          title: "إِنْشَاءُ خَتْمَةٍ جَدِيدَةٍ",
          // isRepl: false,
          route: "/KhatmahHome",
        ),
        DrawerModle(
          icon: Icons.preview_outlined,
          title: "الخَتْمَاتُ المُنْجَزَةُ",
          route: "/compplateKhatna",
        ),
      ],
    ),
    DrawerSection(
      title: "العَلامَاتُ",
      items: [
        DrawerModle(
          icon: Icons.bookmark_add_outlined,
          title: "إِضَافَةُ عَلَامَةٍ لِلصَّفْحَةِ",
          onTap: () => _saveBookmark(_currentPage!),
        ),
        DrawerModle(
          icon: Icons.bookmark_remove_outlined,
          title: "إِزَالَةُ العَلَامَةِ",
          onTap: _delBookmark,
        ),
        DrawerModle(
          icon: Icons.navigation_outlined,
          title: "الِانْتِقَالُ إِلَى العَلَامَةِ",
          onTap: _goToBookmark,
        ),
        DrawerModle(
          icon: Icons.bookmarks_outlined,
          title: "الآيَاتُ المَحْفُوظَةُ",
          route: "/ayaBookmarkScreen",
        ),
      ],
    ),
    DrawerSection(
      title: "عَنِ القُرْآنِ الكَرِيمِ",
      items: [
        DrawerModle(
          icon: Icons.info_outline,
          title: "دُعَاءُ خَتْمِ القُرْآنِ الكَرِيمِ",
          route: Routes.quranKhitamRoute,
        ),
        DrawerModle(
          icon: Icons.favorite_border,
          title: "فَضْلُ قِرَاءَةِ القُرْآنِ",
          route: Routes.quranLoveRoute,
        ),
        // DrawerModle(
        //   icon: Icons.dark_mode_outlined,
        //   title: "الوَضْعُ اللَّيْلِيُّ",
        //   onTap: _changeMode,
        // ),
      ],
    ),
  ];

  int? _currentPage = 0;
  int? _bookmarkedPage;

  @override
  void initState() {
    super.initState();
    _loadPages();
    // فتح التدوير داخل صفحة القرآن
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    QuranLibrary.init();
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

  // void _saveBookmark(int page) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('bookmark_page', page);
  //   setState(() {
  //     _bookmarkedPage = page;
  //   });
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   SnackBar(content: Text('✅ تم حفظ العلامة على الصفحة $page')),
  //   // );
  //   KHelper.showSuccess(message: ' ✅ تم حفظ العلامة على الصفحة $page ');
  // }
  void _saveBookmark(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bookmark_page', pageIndex);

    setState(() {
      _bookmarkedPage = pageIndex;
    });

    final pageNumber = pageIndex + 1; // تحويل من index إلى رقم صفحة حقيقي

    KHelper.showSuccess(
      message: ' ✅ تم حفظ العلامة على الصفحة $pageNumber ',
    );
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

  // void _goToBookmark() {
  //   if (_bookmarkedPage != null) {
  //     setState(() {
  //       _currentPage = _bookmarkedPage!;
  //       QuranLibrary().jumpToPage(_bookmarkedPage!);
  //     });
  //   } else {
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   const SnackBar(content: Text('⚠️ لا توجد علامة محفوظة')),
  //     // );
  //     KHelper.showSuccess(message: " لا توجد علامة محفوظة");
  //   }
  // }
  void _goToBookmark() {
    if (_bookmarkedPage != null) {
      final pageIndex = _bookmarkedPage!; // 0-based
      final pageNumber = pageIndex + 1; // 1-based للعرض وللباكدج

      setState(() {
        _currentPage = pageIndex;
        QuranLibrary().jumpToPage(pageNumber); // الباكدج تتعامل مع 1-based هنا
      });
    } else {
      KHelper.showSuccess(message: " لا توجد علامة محفوظة");
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

  // false = الوضع الأفقي (الـ default من الباكدج)
  // true  = الوضع الرأسي (PageView خارجي)
  bool _verticalMode = false;

  PageController? _verticalController;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _verticalController?.dispose();
    super.dispose();
  }

  Future<void> _handlePageChanged(int page) async {
    setState(() {
      _currentPage = page;
    });

    // KHelper.showSuccess(
    //   message: "الصفحة رقم ${page + 1}",
    //   backgroundColor: Colors.black,
    // );

    _saveCurrentPage(page);
  }

  void _toggleMode() {
    setState(() {
      _verticalMode = !_verticalMode;

      if (_verticalMode) {
        // عند التحويل للوضع الرأسي:
        // نعيد إنشاء الـ PageController بحيث يبدأ من الصفحة الحالية
        _verticalController?.dispose();
        _verticalController = PageController(initialPage: _currentPage ?? 0);
      } else {
        // في الوضع الأفقي، الباكدج نفسها هتبدأ من _currentPage (عن طريق pageIndex)
        // لا نحتاج لأي PageController هنا
      }
    });
  }

  bool get _isCurrentPageBookmarked =>
      _bookmarkedPage != null && _currentPage == _bookmarkedPage;
  @override
  Widget build(BuildContext context) {

    final ayahIconColor = isDark ? AppStyle.scondColors : AppColors.primary;

    final topBottomStyle = TopBottomQuranStyle.defaults(
      isDark: isDark,
      context: context,
    ).copyWith(
      pageNumberColor: isDark ? Colors.white : Colors.black,
      surahNameColor: isDark ? Colors.white : Colors.black,
      hizbTextColor: isDark ? Colors.white : Colors.black,
      juzTextColor: isDark ? Colors.white : Colors.black,
    );

    final ayahMenuStyle =
        AyahMenuStyle.defaults(isDark: isDark, context: context);

    final indexTabStyle = IndexTabStyle(
      labelColor: isDark ? Colors.white : Colors.black,
      accentColor: isDark ? Colors.white : Colors.black,
    );
    QuranLibrary().currentPageNumber;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // خلفية السكافولد
        drawer: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
            child: DrawerWidget(
              initiallyExpanded: true,
              "/surahListScreen",
              sections: drawerSections,
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.cure, // غيّرها باللي انت عايزه
            //     color: isDark ? Colors.white : Colors.black,
            //   ),
            //   onPressed: () {
            //     Scaffold.of(context).openDrawer();
            //   },
            // ),
            // leading: Builder(
            //   builder: (context) => IconButton(
            //     icon: Image.asset(
            //       "assets/images/menu2.png",
            //       width: 32,
            //       height: 32,
            //       fit: BoxFit.contain,
            //     color:     isDark?Colors.white:Colors.black
            //     ),
            //     onPressed: () {
            //       Scaffold.of(context).openDrawer();
            //     },
            //   ),
            // ),
            iconTheme:
                IconThemeData(color: isDark ? Colors.white : Colors.blue),
            actions: [
              // FontsDownloadDialog(
              //   topBarStyle: QuranTopBarStyle(
              //     iconColor: isDark ? Colors.white : Colors.blue,
              //   ),
              //   downloadFontsDialogStyle: DownloadFontsDialogStyle(
              //     iconColor: isDark ? Colors.white : Colors.blueAccent,
              //     headerTitle: 'الخطوط المتاحة',
              //     titleColor: isDark ? Colors.white : Colors.black,
              //     notes:
              //         'لجعل مظهر المصحف مشابه لمصحف المدينة يمكنك تحميل خط مصحف المدينة من اسفل وتفعيله بدلا من الخط الاساسي',
              //     notesColor: isDark ? Colors.white : Colors.black,
              //     linearProgressBackgroundColor: Colors.blue.shade100,
              //     linearProgressColor: Colors.blue,
              //     downloadButtonBackgroundColor: Colors.blue,
              //     downloadingText: 'جارِ التحميل',
              //     backgroundColor: isDark
              //         ? const Color(0xff1E1E1E)
              //         : const Color(0xFFF7EFE0),
              //   ),
              //   languageCode: 'ar',
              //   isFontsLocal: false, // تحميل من النت
              //   isDark: isDark,
              // ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: PopupMenuButton<_QuranMenuAction>(
                  tooltip: "خيارات إضافية",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    // side: BorderSide(
                    //   color: isDark ? Colors.teal.withOpacity(0.3) : Colors.brown.withOpacity(0.3),
                    //   width: 1,
                    // ),
                  ),
                  // elevation: 8,
                  // shadowColor: Colors.amber.withOpacity(0.2),
                  icon: Icon(
                    Icons.more_vert,
                    size: 22,
                  ),
                  offset: const Offset(0, 50),
                  onSelected: (value) {
                    switch (value) {
                      case _QuranMenuAction.audio:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahAudioScreen(isDark: isDark),
                          ),
                        );
                        break;
                      case _QuranMenuAction.orientation:
                        _toggleMode();
                        break;
                      case _QuranMenuAction.background:
                        _showBackgroundColorPicker();
                        break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    // العنصر الأول - الاستماع للسور
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.audio,
                      title: 'الإستماع للسور',
                      subtitle: 'استمع للقرآن بصوت القارئ',
                      iconData: Icons.play_circle_filled_rounded,
                      iconColor: Colors.green,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),

                    // العنصر الثاني - تغيير الاتجاه
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.orientation,
                      title: _verticalMode ? 'الوضع الأفقي' : 'الوضع الرأسي',
                      subtitle: _verticalMode ? 'تغيير إلى القراءة الأفقية' : 'تغيير إلى القراءة العمودية',

                      iconData:    _verticalMode ? Icons.swap_horiz : Icons.swap_vert,
                      iconColor: Colors.blue,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.background,
                      title: isDark ? 'الوضع الليلي' : 'الوضع النهاري',
                      subtitle: isDark ? 'اختر خلفية داكنة مناسية للقرأة' : 'اختر خلفية فاتحة مناسية للقرأة',
                      iconData: isDark ? Icons.light_mode : Icons.dark_mode,
                      iconColor: isDark ? Colors.amber : Colors.indigo,
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                          Colors.amber.withOpacity(0.1),
                          Colors.orange.withOpacity(0.05),
                        ]
                            : [
                          Colors.indigo.withOpacity(0.1),
                          Colors.purple.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),

                    // يمكنك إضافة المزيد من العناصر هنا
                  ],
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _showBackgroundColorPicker,
        //   child: const Icon(Icons.color_lens),
        // ),

        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                              KLoading.progressIOSIndicator(context: context),
                        )
                      : _verticalMode
                          ? PageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: _verticalController,
                              itemCount: 604,
                              onPageChanged: _handlePageChanged,
                              itemBuilder: (context, index) {
                                return QuranLibraryScreen(
                                  backgroundColor: _backgroundColor,

                                  withPageView: false,
                                  isDark: isDark,
                                  pageIndex: index,
                                  ayahIconColor: ayahIconColor,
                                  topBottomQuranStyle: topBottomStyle,
                                  ayahMenuStyle: ayahMenuStyle,
                                  indexTabStyle: indexTabStyle,
                                  useDefaultAppBar: false,
                                  parentContext: context,
                                );
                              },
                            )
                          : QuranLibraryScreen(
                    backgroundColor: _backgroundColor,

                    // backgroundColor:isDark? Color(0xFF101623):Color(0xFFF7F1E1),
                              withPageView: true,
                              isDark: isDark,
                              pageIndex: _currentPage!,
                              ayahIconColor: ayahIconColor,
                              topBottomQuranStyle: topBottomStyle,
                              ayahMenuStyle: ayahMenuStyle,
                              indexTabStyle: indexTabStyle,
                              useDefaultAppBar: false,
                              parentContext: context,
                              onPageChanged: (page) {
                                _handlePageChanged(page);
                              },
                            ),
                ),
              ),
            ),
            if (_isCurrentPageBookmarked)
              Positioned(
                top: 0,
                right: 160, // أو left في حال أردت
                child: Icon(
                  Icons.bookmark,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لبناء عناصر القائمة
  PopupMenuItem<_QuranMenuAction> _buildMenuItem({
    required BuildContext context,
    required _QuranMenuAction value,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required Gradient gradient,
    required bool isDark,
  }) {
    return PopupMenuItem<_QuranMenuAction>(
      value: value,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.15),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Uthmanic', // يمكنك استخدام خط عثماني
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          trailing: Icon(
            Icons.arrow_back_ios_new,
            size: 14,
            color: isDark ? Colors.teal[300] : Colors.brown[600],
          ),
        ),
      ),
    );
  }

// أو تصميم بديل بلمسة إسلامية أكثر
  PopupMenuItem<_QuranMenuAction> _buildIslamicMenuItem({
    required BuildContext context,
    required _QuranMenuAction value,
    required String title,
    required IconData iconData,
    required bool isDark,
  }) {
    return PopupMenuItem<_QuranMenuAction>(
      value: value,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // زخرفة إسلامية على الجانب
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.teal,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // أيقونة مع خلفية دائرية
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.teal.withOpacity(0.2) : Colors.green.withOpacity(0.1),
              ),
              child: Icon(
                iconData,
                color: isDark ? Colors.teal[300] : Colors.green[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // النص
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Amiri', // خط أميري
                ),
              ),
            ),
            // سهم صغير
            Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: isDark ? Colors.teal[300] : Colors.brown[600],
            ),
          ],
        ),
      ),
    );
  }





}
