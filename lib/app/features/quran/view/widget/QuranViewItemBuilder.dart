import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/DrawerWidget.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/data/reading_analytics_service.dart';
import 'package:muslimdaily/app/features/quran/data/reflections_service.dart';
import 'package:muslimdaily/app/features/quran/view/ReadingAnalyticsScreen.dart';
import 'package:muslimdaily/app/features/quran/view/widget/page_reflections_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_library/quran_library.dart';
import 'package:screen_brightness/screen_brightness.dart' as sb;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum _QuranMenuAction {
  audio,
  orientation,
  background,
  wakelock,
  brightness,
  share,
  note,
  autoscroll,
  confirm,
}

class QuranViewItemBuilder extends StatefulWidget {
  final int? initialPage;
  final VoidCallback? onConfirm;
  final String? campaignId;
  final int? targetPage;

  const QuranViewItemBuilder({
    super.key,
    this.initialPage,
    this.onConfirm,
    this.campaignId,
    this.targetPage,
  });

  @override
  _QuranViewItemBuilderState createState() => _QuranViewItemBuilderState();
}

class _QuranViewItemBuilderState extends State<QuranViewItemBuilder>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  bool get isDark => context.isDark;

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
              final bool isSelected =
                  c == (isDark ? _darkBackgroundColor : _lightBackgroundColor);

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
        // DrawerModle(
        //   icon: Icons.picture_as_pdf_outlined,
        //   title: "القِرَاءَةُ مِنَ PDF",
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const PdfListScreen()),
        //     );
        //   },
        // ),
        DrawerModle(
          icon: Icons.analytics_outlined,
          title: "إِحْصَائِيَّاتُ القِرَاءَةِ",
          onTap: _openAnalytics,
        ),
        DrawerModle(
          icon: Icons.description_outlined,
          title: "قائمة الخواطر",
          onTap: () {
            Navigator.pushNamed(context, "/reflectionsList");
          },
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
        // DrawerModle(
        //   icon: Icons.history_edu_outlined,
        //   title: "المُصْحَفُ القَدِيمُ (نَصِّي)",
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const SurahListScreen(useOldMushaf: true),
        //       ),
        //     );
        //   },
        // ),
        // DrawerModle(
        //   icon: Icons.dashboard_customize_outlined,
        //   title: "الأَجْزَاءُ",
        //   route: Routes.jozzaListScreenRoute,
        // ),
        // DrawerModle(
        //   icon: Icons.category_outlined,
        //   title: "الأَحْزَابُ",
        //   route: Routes.hizbeListScreenRoute,
        // ),
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
    _initBrightness();
    _loadPages();
    // فتح التدوير داخل صفحة القرآن
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Enable wakelock by default
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    _startTrackingTime();
  }

  // Analytics
  Timer? _analyticsTimer;
  int _sessionSeconds = 0;
  final ReadingAnalyticsService _analyticsService = ReadingAnalyticsService();
  final ReflectionsService _reflectionsService = ReflectionsService();
  bool _hasPageNote = false;

  Future<void> _checkPageNote(int pageIndex) async {
    final count = await _reflectionsService.getPageReflectionsCount(pageIndex);
    if (mounted) {
      setState(() {
        _hasPageNote = count > 0;
      });
    }
  }

  Future<void> _showPageNoteDialog() async {
    if (_currentPage == null) return;

    // Navigate to the new multi-reflections screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageReflectionsScreen(pageIndex: _currentPage!),
      ),
    );

    // Refresh the note indicator after returning
    _checkPageNote(_currentPage!);
  }

  Future<void> _openAnalytics() async {
    await _flushReadingTime();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReadingAnalyticsScreen()),
    );
  }

  void _startTrackingTime() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      if (_sessionSeconds % 60 == 0) {
        _flushReadingTime();
      }
    });
  }

  void _stopTrackingTime() {
    _analyticsTimer?.cancel();
    _flushReadingTime();
  }

  Future<void> _flushReadingTime() async {
    if (_sessionSeconds > 0) {
      await _analyticsService.addReadingTime(_sessionSeconds);
      _sessionSeconds = 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopTrackingTime();
    } else if (state == AppLifecycleState.resumed) {
      _startTrackingTime();
    }
  }

  bool _isAutoScrolling = false;
  double _scrollSpeed = 1.0; // Seconds per pixel approx or just step
  Timer? _scrollTimer;
  bool _showAutoScrollControls = true;
  Timer? _hideControlsTimer;

  bool _keepScreenOn = true;
  double _currentBrightness = 0.5;
  bool _showBrightnessIndicator = false;
  double _brightnessIndicatorValue = 0.5;
  Timer? _brightnessIndicatorTimer;

  Future<void> _initBrightness() async {
    try {
      _currentBrightness = await sb.ScreenBrightness().current;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error initializing brightness: $e");
    }
  }

  void _updateBrightness(double delta) async {
    double newBrightness = _currentBrightness - (delta / 250); // Sensitivity
    newBrightness = newBrightness.clamp(0.0, 1.0);

    if (newBrightness != _currentBrightness) {
      setState(() {
        _currentBrightness = newBrightness;
        _showBrightnessIndicator = true;
        _brightnessIndicatorValue = newBrightness;
      });

      try {
        await sb.ScreenBrightness().setScreenBrightness(newBrightness);
      } catch (e) {
        debugPrint("Error setting brightness: $e");
      }

      _brightnessIndicatorTimer?.cancel();
      _brightnessIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showBrightnessIndicator = false;
          });
        }
      });
    }
  }

  void _toggleWakelock() {
    setState(() {
      _keepScreenOn = !_keepScreenOn;
      WakelockPlus.toggle(enable: _keepScreenOn);
    });
    KHelper.showSuccess(
      message: _keepScreenOn
          ? 'تم تفعيل وضع منع انطفاء الشاشة'
          : 'تم إيقاف وضع منع انطفاء الشاشة',
    );
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showAutoScrollControls = false;
        });
        _showHintOnce();
      }
    });
  }

  Future<void> _showHintOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('has_shown_scroll_hint') ?? false;
    if (!hasShown && mounted) {
      KHelper.showSuccess(
        message: 'تم إخفاء الأدوات.. انقر مرتين في أي مكان لإظهارها ثانية ',
      );
      await prefs.setBool('has_shown_scroll_hint', true);
    }
  }

  void _resetHideTimer() {
    if (!_showAutoScrollControls) {
      setState(() {
        _showAutoScrollControls = true;
      });
    }
    _startHideTimer();
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      if (_isAutoScrolling) {
        _showAutoScrollControls = true;
        _startHideTimer();
        if (!_verticalMode) {
          _toggleMode(); // Force vertical mode for auto-scroll
        }
        // Wait for the controller to be attached after setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoScroll();
        });
      } else {
        _stopAutoScroll();
        _hideControlsTimer?.cancel();
      }
    });
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    // 16ms for ~60fps smoothness
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_verticalController != null &&
          _verticalController!.hasClients &&
          _isAutoScrolling) {
        final maxScroll = _verticalController!.position.maxScrollExtent;
        final currentPos = _verticalController!.offset;

        if (currentPos >= maxScroll) {
          _toggleAutoScroll(); // Stop at the end
          return;
        }

        // Adjust step for 16ms interval (prev was 100ms)
        // Previous speed 5*speed at 100ms = 50*speed pixels per second
        // New step at 16ms for same speed = (50*speed) / 60 frames approx = 0.8
        double moveStep = 0.8 * _scrollSpeed;
        _verticalController!.jumpTo(currentPos + moveStep);
      } else if (!_isAutoScrolling) {
        timer.cancel();
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();

    // Determine the storage key (campaign-specific or global)
    final key = widget.campaignId != null
        ? 'last_page_${widget.campaignId}'
        : 'last_page';

    int lastPage = widget.initialPage ?? (prefs.getInt(key) ?? 0);
    _bookmarkedPage = prefs.getInt('bookmark_page');

    setState(() {
      _currentPage = lastPage;
    });
    _checkPageNote(lastPage);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_currentPage != null) {
        QuranLibrary().jumpToPage(_currentPage! + 1);
        // Eagerly save the current page to ensure it's in SharedPreferences even if no scrolling happens
        final prefs = await SharedPreferences.getInstance();
        final key = widget.campaignId != null
            ? 'last_page_${widget.campaignId}'
            : 'last_page';
        await prefs.setInt(key, _currentPage!);
      }
    });
  }

  // Method replaced by inline logic in _handlePageChanged

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

  bool _verticalMode = false;

  PageController? _verticalController;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _scrollTimer?.cancel();
    _hideControlsTimer?.cancel();
    _verticalController?.dispose();
    WakelockPlus.disable(); // Ensure wakelock is off when leaving
    WidgetsBinding.instance.removeObserver(this);
    _stopTrackingTime();
    super.dispose();
  }

  Future<void> _handlePageChanged(int page) async {
    setState(() {
      _currentPage = page;
    });
    _checkPageNote(page);

    final prefs = await SharedPreferences.getInstance();
    final key = widget.campaignId != null
        ? 'last_page_${widget.campaignId}'
        : 'last_page';
    await prefs.setInt(key, page);

    // Track pages read
    if (_currentPage != null) _analyticsService.incrementPagesRead();
  }

  Future<void> _showSadaqahDialog() async {
    String selectedName = "";
    final names = ["والديّ", "جميع المسلمين", "والدي ووالدتي", "نفسي"];
    final bool isDark = context.isDark;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // جسم الديالوج
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? [const Color(0xFF0B1A14), const Color(0xFF070B14)]
                          : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // العنوان
                      Text(
                        'مشاركة كصدقة جارية',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // النص التوضيحي
                      Text(
                        'اكتب اسم الشخص الذي تود إهداء ثواب القراءة له، أو اختر من الخيارات السريعة.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          color: isDark ? Colors.white70 : Colors.teal.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),

                      // حقل إدخال الاسم
                      TextField(
                        onChanged: (v) => selectedName = v,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: "اكتب الاسم هنا...",
                          hintStyle: TextStyle(
                              color: isDark ? Colors.grey : Colors.grey[600]),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white12
                              : Colors.white.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // الخيارات السريعة
                      Wrap(
                        spacing: 8,
                        children: names
                            .map((n) => ChoiceChip(
                                  label: Text(
                                    n,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedName == n
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.teal.shade900),
                                    ),
                                  ),
                                  selected: selectedName == n,
                                  onSelected: (s) {
                                    setModalState(() => selectedName = n);
                                  },
                                  selectedColor: Colors.teal,
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.teal.shade50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ))
                            .toList(),
                      ),

                      SizedBox(height: 24.h),

                      // الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.teal.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                              ),
                              child: Text(
                                'تراجع',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.teal.shade900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                _sharePageImage(sadaqahName: selectedName);
                              },
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('مشاركة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // الأيقونة الدائرية أعلى الديالوج
                Positioned(
                  top: -35,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.tealAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sharePageImage({String? sadaqahName}) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/quran_page_${_currentPage! + 1}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(buffer);

      final pageNumber = _currentPage! + 1;
      String text = "💫 صفحة من القرآن الكريم (صفحة $pageNumber) 💫\n";

      if (sadaqahName != null && sadaqahName.trim().isNotEmpty) {
        text += "🌿 صدقة جارية عن: $sadaqahName 🌿\n";
      }

      text += "عبر تطبيق *رفيق المسلم اليومي*\n"
          "حمل التطبيق الآن: https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily";

      await Share.shareXFiles([XFile(imagePath)], text: text);
    } catch (e) {
      debugPrint("Error sharing page: $e");
      KHelper.showError(message: "حدث خطأ أثناء مشاركة الصفحة");
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
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
        // في الوضع الأفقي، نوقف التمرير التلقائي إذا كان يعمل
        if (_isAutoScrolling) {
          _isAutoScrolling = false;
          _stopAutoScroll();
        }
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
            iconTheme: IconThemeData(
                color: isDark ? Colors.white : KColors.primaryColor),
            actions: [
              if (_isSharing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.teal),
                    ),
                  ),
                ),
              IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () {
                    QuranCtrl.instance.isShowControl.value = true;
                    QuranCtrl.instance.update(['isShowControl']);

                    showDialog(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: Dialog(
                            alignment: AlignmentGeometry.centerRight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TajweedMenuWidget(
                              languageCode: "ar",
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                    );
                  }),
              FontsDownloadDialog(
                topBarStyle: QuranTopBarStyle(
                  iconColor: isDark ? Colors.white : KColors.primaryColor,
                ),
                downloadFontsDialogStyle: DownloadFontsDialogStyle(
                  iconColor: isDark ? Colors.white : Colors.blueAccent,
                  headerTitle: 'الخطوط المتاحة',
                  titleColor: isDark ? Colors.white : Colors.black,
                  notes:
                      'لجعل مظهر المصحف مشابه لمصحف المدينة يمكنك تحميل خط مصحف المدينة من اسفل وتفعيله بدلا من الخط الاساسي',
                  notesColor: isDark ? Colors.white : Colors.black,
                  linearProgressBackgroundColor: Colors.blue.shade100,
                  linearProgressColor: Colors.blue,
                  downloadButtonBackgroundColor: Colors.blue,
                  downloadingText: 'جارِ التحميل',
                  backgroundColor: isDark
                      ? const Color(0xff1E1E1E)
                      : const Color(0xFFF7EFE0),
                ),
                languageCode: 'ar',
                isFontsLocal: false, // تحميل من النت
                isDark: isDark,
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: PopupMenuButton<_QuranMenuAction>(
                  color: AppThemeColors.cardBackgroundColor(context),
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
                  icon: const Icon(
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
                            builder: (context) =>
                                SurahAudioScreen(isDark: isDark),
                          ),
                        );
                        break;
                      case _QuranMenuAction.orientation:
                        _toggleMode();
                        break;
                      case _QuranMenuAction.background:
                        _showBackgroundColorPicker();
                        break;
                      case _QuranMenuAction.wakelock:
                        _toggleWakelock();
                        break;
                      case _QuranMenuAction.brightness:
                        _showBrightnessPicker();
                        break;
                      case _QuranMenuAction.share:
                        _showSadaqahDialog();
                        break;
                      case _QuranMenuAction.note:
                        _showPageNoteDialog();
                        break;
                      case _QuranMenuAction.autoscroll:
                        _toggleAutoScroll();
                        break;
                      case _QuranMenuAction.confirm:
                        if (widget.onConfirm != null) widget.onConfirm!();
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

                    // السطوع
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.brightness,
                      title: 'سطوع الشاشة',
                      subtitle: 'التحكم في درجة سطوع المصحف',
                      iconData: Icons.brightness_6,
                      iconColor: Colors.orange,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.1),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),

                    // منع انطفاء الشاشة
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.wakelock,
                      title: _keepScreenOn
                          ? 'السماح بقفل الشاشة'
                          : 'عدم انطفاء الشاشة',
                      subtitle: _keepScreenOn
                          ? 'تفعيل القفل التلقائي'
                          : 'إبقاء الشاشة مفعلة دائماً',
                      iconData: _keepScreenOn
                          ? Icons.screen_lock_portrait
                          : Icons.screen_lock_rotation,
                      iconColor: Colors.purple,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.purple.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),

                    // العنصر الثاني - تغيير الاتجاه
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.orientation,
                      title: _verticalMode ? 'الوضع الأفقي' : 'الوضع الرأسي',
                      subtitle: _verticalMode
                          ? 'تغيير إلى القراءة الأفقية'
                          : 'تغيير إلى القراءة العمودية',
                      iconData:
                          _verticalMode ? Icons.swap_horiz : Icons.swap_vert,
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
                      subtitle: isDark
                          ? 'اختر خلفية داكنة مناسية للقرأة'
                          : 'اختر خلفية فاتحة مناسية للقرأة',
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
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.share,
                      title: 'مشاركة الصفحة',
                      subtitle:
                          'شارك صورة من الصفحة الحالية (اختياري: كصدقة جارية)',
                      iconData: Icons.share_rounded,
                      iconColor: Colors.teal,
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withOpacity(0.1),
                          Colors.teal.withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.note,
                      title: 'تدوين خواطر',
                      subtitle: 'سجل ملاحظاتك وتدبرك للصفحة',
                      iconData: _hasPageNote
                          ? Icons.description
                          : Icons.description_outlined,
                      iconColor: _hasPageNote ? Colors.amber : Colors.orange,
                      gradient: LinearGradient(
                        colors: [
                          (_hasPageNote ? Colors.amber : Colors.orange)
                              .withOpacity(0.1),
                          (_hasPageNote ? Colors.amber : Colors.orange)
                              .withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context: ctx,
                      value: _QuranMenuAction.autoscroll,
                      title:
                          _isAutoScrolling ? 'إيقاف التمرير' : 'تشغيل التمرير',
                      subtitle: _isAutoScrolling
                          ? 'إيقاف التمرير التلقائي'
                          : 'بدء التمرير التلقائي للصفحة',
                      iconData: _isAutoScrolling
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      iconColor: _isAutoScrolling ? Colors.red : Colors.green,
                      gradient: LinearGradient(
                        colors: [
                          (_isAutoScrolling ? Colors.red : Colors.green)
                              .withOpacity(0.1),
                          (_isAutoScrolling ? Colors.red : Colors.green)
                              .withOpacity(0.05),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    if (widget.onConfirm != null)
                      _buildMenuItem(
                        context: ctx,
                        value: _QuranMenuAction.confirm,
                        title: 'إتمام القراءة',
                        subtitle: 'تأكيد إكمال قراءة هذه الورد',
                        iconData: Icons.check_circle_outline_rounded,
                        iconColor: Colors.blueAccent,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.1),
                            Colors.blueAccent.withOpacity(0.05),
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
                 style: TextStyle(
                          fontFamily: "cairo",
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        // floatingActionButton: widget.onConfirm != null
        //     ? Container(
        //         margin:
        //             const EdgeInsets.only(bottom: 50), // ابعده عن مكان التقليب
        //         child: FloatingActionButton.extended(
        //           onPressed: widget.onConfirm,
        //           backgroundColor: Colors.teal,
        //           icon: const Icon(Icons.check_circle_outline,
        //               color: Colors.white),
        //           label: Text('تمت القراءة ✅',
        //                  style: TextStyle(
                          //fontFamily: "cairo",
        //                   color: Colors.white, fontWeight: FontWeight.bold)),
        //         ),
        //       )
        //     : null,
        body: GestureDetector(
          onDoubleTap: () {
            if (_isAutoScrolling) {
              _resetHideTimer();
            }
          },
          onVerticalDragUpdate: (details) {
            // Only trigger on the left 20% of the screen
            if (details.globalPosition.dx <
                MediaQuery.of(context).size.width * 0.2) {
              _updateBrightness(details.delta.dy);
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  if (widget.targetPage != null && widget.initialPage != null)
                    _buildProgressIndicator(),
                  Expanded(
                    child: Container(
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
                        child: RepaintBoundary(
                          key: _shareKey,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: _currentPage == null
                                ? Center(
                                    child: KLoading.progressIOSIndicator(
                                        context: context),
                                  )
                                : _verticalMode
                                    ? PageView.builder(
                                        scrollDirection: Axis.vertical,
                                        controller: _verticalController,
                                        itemCount: 604,
                                        onPageChanged: _handlePageChanged,
                                        itemBuilder: (context, index) {
                                          return QuranLibraryScreen(
                                            appIconPathForPlayAudioInBackground:
                                                "https://raw.githubusercontent.com/TaherSalah/shareCardImage/refs/heads/master/perLogo.png",
                                            backgroundColor: _backgroundColor,
                                            withPageView: false,
                                            isDark: isDark,
                                            appLanguageCode: "ar",
                                            isFontsLocal: false,
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
                                        appIconPathForPlayAudioInBackground:
                                            "https://raw.githubusercontent.com/TaherSalah/shareCardImage/refs/heads/master/perLogo.png",

                                        backgroundColor: _backgroundColor,
                                        // backgroundColor:isDark? Color(0xFF101623):Color(0xFFF7F1E1),
                                        withPageView: true,
                                        isDark: isDark,
                                        pageIndex: _currentPage!,
                                        appLanguageCode: "ar",
                                        isFontsLocal: false,
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
                    ),
                  ),
                ],
              ),
              // Bookmark Indicator
              if (_isCurrentPageBookmarked)
                Positioned(
                  top: -5,
                  left:
                      155, // Adjusted for RTL/LTR preference, usually left in physical Qurans
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: -50, end: 0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _delBookmark,
                      child: Container(
                        width: 40,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000), // Deep red color
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x94A50000),
                              Color(0x578B0000),
                              Color(0x64600000),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Decoration line
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 20,
                              height: 2,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Brightness Indicator Overlay
              if (_showBrightnessIndicator)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _brightnessIndicatorValue > 0.5
                              ? Icons.brightness_high
                              : Icons.brightness_medium,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_brightnessIndicatorValue * 100).toInt()}%',
                             style: TextStyle(
                          fontFamily: "cairo",
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isAutoScrolling) _buildAutoScrollControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoScrollControls() {
    if (!_showAutoScrollControls) return const SizedBox.shrink();

    return Positioned(
      bottom: 60,
      left: 30,
      right: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // مور ترانسبيرنت
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed, color: Colors.white70, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: _scrollSpeed,
                      min: 0.1,
                      max: 5.0,
                      activeColor: Colors.teal.withOpacity(0.8),
                      inactiveColor: Colors.white12,
                      onChangeStart: (_) => _hideControlsTimer?.cancel(),
                      onChangeEnd: (_) => _startHideTimer(),
                      onChanged: (value) {
                        setState(() {
                          _scrollSpeed = value;
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _toggleAutoScroll,
                  icon: const Icon(Icons.stop_circle,
                      color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ),
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
      child: Directionality(
        textDirection: TextDirection.rtl,
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
                fontFamily: 'me', // يمكنك استخدام خط عثماني
              ),
            ),
            // subtitle: Text(
            //   subtitle,
            //   style: TextStyle(
            //     fontSize: 11,
            //     color: isDark ? Colors.white70 : Colors.black54,
            //   ),
            // ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.teal[300] : Colors.brown[600],
            ),
          ),
        ),
      ),
    );
  }

  void _showBrightnessPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1E1E1E) : const Color(0xFFF7EFE0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سطوع الشاشة',
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.teal[800],
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: _currentBrightness,
                activeColor: Colors.teal,
                onChanged: (value) async {
                  setModalState(() => _currentBrightness = value);
                  setState(() => _currentBrightness = value);
                  try {
                    await sb.ScreenBrightness().setScreenBrightness(value);
                  } catch (_) {}
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIslamicMenuItem({
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
                gradient: const LinearGradient(
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
                color: isDark
                    ? Colors.teal.withOpacity(0.2)
                    : Colors.green.withOpacity(0.1),
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
                  fontFamily: 'cairo', // خط أميري
                ),
              ),
            ),
            // سهم صغير
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDark ? Colors.teal[300] : Colors.brown[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (_currentPage == null ||
        widget.initialPage == null ||
        widget.targetPage == null) {
      return const SizedBox.shrink();
    }

    // Normalize progress between initial and target
    int totalPages = (widget.targetPage! - widget.initialPage!).abs() + 1;
    int currentRelative = (_currentPage! - widget.initialPage!).abs() + 1;
    double progress =
        totalPages > 0 ? (currentRelative / totalPages).clamp(0.0, 1.0) : 1.0;

    return Container(
      height: 4,
      width: double.infinity,
      color: Colors.white10,
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteDialogWidget extends StatefulWidget {
  final String? initialText;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  const NoteDialogWidget({super.key,
    this.initialText,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<NoteDialogWidget> createState() => _NoteDialogWidgetState();
}

class _NoteDialogWidgetState extends State<NoteDialogWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // جسم الديالوج
            Container(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Text(
                    'خواطري حول الصفحة',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // النص التوضيحي
                  Text(
                    'سجل ما تعلمته أو تدبرته من هذه الصفحة ليسهل عليك العودة إليه لاحقاً.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.indigo.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),

                  // حقل إدخال الخواطر
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "اكتب ما في ذهنك هنا...",
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white12
                          : Colors.white.withOpacity(0.6),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // الأزرار
                  Row(
                    children: [
                      if (widget.initialText != null) ...[
                        IconButton(
                          onPressed: () {
                            widget.onDelete();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                          tooltip: 'حذف الخاطرة',
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.indigo.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A237E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              widget.onSave(_controller.text);
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('حفظ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // الأيقونة الدائرية أعلى الديالوج
            Positioned(
              top: -35,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3F51B5).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
