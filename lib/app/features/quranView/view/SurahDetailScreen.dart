import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/style/k_color.dart';
import '../SurahModel.dart';
import 'widget/surahListView.dart';

// ----------------------- Surah Detail Screen -----------------------
class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;
  final List<SurahModel> allSurahs;
  final bool showBottomOnStart;
  final bool? isDark; // جعل المظهر اختيارياً ليعتمد على الإعدادات المحفوظة
  final int verseId;
  final double? initialScrollOffset;
  final double? initialFontSize;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.allSurahs,
    this.showBottomOnStart = false,
    this.isDark,
    required this.verseId,
    this.initialScrollOffset,
    this.initialFontSize,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late bool isDark;
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool isScrolling = false;
  double scrollSpeed = 1.0;
  bool showControls = false;
  bool showFab = false;
  bool showBottom = false;
  Timer? _hideTimer;
  late int currentIndex;
  double fontSizeValue = 23.0; // القيمة الافتراضية لحجم الخط
  int? bookmarkId;

  // --- متغيرات خاصة بحفظ حالة القراءة ---
  double _lastSavedOffset = 0; // آخر مكان تم حفظه للتمرير
  Timer? _scrollSaveTimer; // مؤقت لتجنب الحفظ المتعدد في كل بكسل

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    currentIndex = widget.allSurahs.indexWhere((s) => s.id == widget.surah.id);
    showBottom = widget.showBottomOnStart;

    // المظهر: الأولوية للقيمة الممررة، ثم الإعدادات المحفوظة، ثم مظهر النظام
    isDark = widget.isDark ??
        (View.of(context).platformDispatcher.platformBrightness ==
            ui.Brightness.dark);

    loadBookmark();
    loadSavedSettings(); // تحميل المظهر وحجم الخط المحفوظين

    bookmarkId = widget.verseId;
    if (showBottom) {
      _startHideTimer();
    }

    // استعادة مكان التمرير إذا كان ممرراً للشاشة (عند الاستكمال التلقائي)
    if (widget.initialScrollOffset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(widget.initialScrollOffset!);
          _lastSavedOffset = widget.initialScrollOffset!;
        }
      });
    }

    // إضافة مراقب لحركة الشاشة لحفظ مكان الوقوف
    _scrollController.addListener(_onScroll);

    // وسم الدخول الأول للمصحف لتفعيل ميزة الاستكمال في المرات القادمة
    _initialMarkEntry();
    WakelockPlus.enable();
  }

  // تحميل الإعدادات المحفوظة (المظهر وحجم الخط)
  Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // تحميل حجم الخط: إذا لم يكن موجوداً نستخدم القيمة الممررة أو 23.0
      fontSizeValue = widget.initialFontSize ??
          prefs.getDouble('old_mushaf_font_size') ??
          23.0;

      // تحميل المظهر: إذا لم تكن القيمة ممررة في الـ widget نأخذها من الإعدادات
      if (widget.isDark == null) {
        isDark = prefs.getBool('old_mushaf_is_dark') ?? isDark;
      }
    });
  }

  Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('old_mushaf_font_size', size);
  }

  // حفظ المظهر المختار في ذاكرة الجهاز
  Future<void> saveThemePreference(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('old_mushaf_is_dark', dark);
  }

  // دالة تُعلم التطبيق أن المستخدم دخل المصحف مرة واحدة على الأقل
  Future<void> _initialMarkEntry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('old_mushaf_opened_once', true);
    await prefs.setInt('old_mushaf_last_surah_id', widget.surah.id);
  }

  // يتم استدعاء هذه الدالة مع كل حركة تمرير
  void _onScroll() {
    if (_scrollController.hasClients) {
      // إذا تحرك المستخدم أكثر من 30 بكسل عن آخر مكان تم حفظه
      if ((_scrollController.offset - _lastSavedOffset).abs() > 30) {
        _scrollSaveTimer?.cancel();
        // ننتظر ثانية واحدة بعد توقف الحركة قبل الحفظ لضمان الأداء السلس
        _scrollSaveTimer = Timer(const Duration(seconds: 1), () {
          _saveCurrentState();
        });
      }
    }
  }

  // حفظ البيانات في ذاكرة الجهاز (SharedPreferences)
  Future<void> _saveCurrentState() async {
    if (!mounted || !_scrollController.hasClients) return;
    _lastSavedOffset = _scrollController.offset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'old_mushaf_last_surah_id', widget.surah.id); // حفظ رقم السورة
    await prefs.setDouble(
        'old_mushaf_last_scroll_offset', _lastSavedOffset); // حفظ مكان التمرير
    await prefs.setBool(
        'old_mushaf_opened_once', true); // تفعيل علامة الاستكمال
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _saveCurrentState(); // Final save
    _scrollSaveTimer?.cancel();
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void loadBookmark() async {
    final id = await getBookmark();
    if (mounted) {
      setState(() {
        bookmarkId = id;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        showBottom = false;
        showFab = false;
        showControls = false;
      });
    });
  }

  void _toggleControls() {
    setState(() {
      showBottom = !showBottom;
      showFab = !showFab;
      if (showBottom || showFab) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void toggleAutoScroll() {
    if (isScrolling) {
      _autoScrollTimer?.cancel();
      setState(() {
        isScrolling = false;
      });
    } else {
      const duration = Duration(milliseconds: 50);
      _autoScrollTimer = Timer.periodic(duration, (timer) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.offset + scrollSpeed,
            duration: duration,
            curve: Curves.linear,
          );
        }
      });
      setState(() {
        isScrolling = true;
      });
    }
  }

  List<TextSpan> _buildVerseWithColoredNumbers(String text, bool isDark) {
    final numberRegExp = RegExp(r'\d+');
    final markRegExp = RegExp(r'﴿\d+﴾');
    final markRegExp2 = RegExp(r'۞');

    final matches = [
      ...numberRegExp
          .allMatches(text)
          .map((m) => {'start': m.start, 'end': m.end, 'type': 'number'}),
      ...markRegExp
          .allMatches(text)
          .map((m) => {'start': m.start, 'end': m.end, 'type': 'mark'}),
      ...markRegExp2
          .allMatches(text)
          .map((m) => {'start': m.start, 'end': m.end, 'type': 'mark2'}),
    ];

    matches.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
    List<TextSpan> spans = [];
    int currentIndex = 0;
    for (final match in matches) {
      final int start = match['start'] as int;
      final int end = match['end'] as int;
      final String type = match['type'] as String;

      if (start < currentIndex) continue;
      if (start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(
            color: type == 'number'
                ? Colors.green
                : type == 'mark'
                    ? (isDark ? Colors.amber : Colors.red)
                    : type == "mark2"
                        ? (isDark ? Colors.greenAccent : Colors.lightGreen)
                        : Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      currentIndex = end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }
    return spans;
  }

  void _showFontSizeSlider() {
    _hideTimer?.cancel(); // إيقاف المؤقت عند فتح النافذة
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff11151d) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          title: "حجم الخط",
                          fontSize:
                              context.isTab ? 10.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        TextWidget(
                          title: "${fontSizeValue.toInt()}",
                          fontSize:
                              context.isTab ? 10.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                          color: KColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: KColors.primaryColor,
                        inactiveTrackColor: Colors.green.withOpacity(0.2),
                        thumbColor: KColors.primaryColor,
                        overlayColor: KColors.primaryColor.withOpacity(0.2),
                        valueIndicatorColor: KColors.primaryColor,
                        valueIndicatorTextStyle:
                            const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: fontSizeValue,
                        min: 20,
                        max: 100,
                        divisions: 80,
                        label: fontSizeValue.toInt().toString(),
                        onChanged: (value) {
                          setModalState(() {
                            fontSizeValue = value;
                          });
                          setState(() {
                            fontSizeValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          saveFontSize(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSizeValue,
                        fontFamily: 'me',
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
             ),
            );
          },
        );
      },
    ).then((_) => _startHideTimer()); // إعادة تشغيل المؤقت عند إغلاق النافذة
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTab;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      floatingActionButton: showFab
          ? Padding(
              padding: EdgeInsets.only(bottom: showBottom ? 80.h : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // زر تبديل إظهار الأدوات
                  FloatingActionButton(
                    heroTag: "toggleControls_detail",
                    onPressed: () {
                      setState(() {
                        showControls = !showControls;
                        if (showControls) _startHideTimer();
                      });
                    },
                    backgroundColor: KColors.primaryColor,
                    mini: true,
                    child: Icon(showControls ? Icons.close : Icons.settings,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  if (showControls) ...[
                    // زر تقليل سرعة التمرير
                    FloatingActionButton(
                      heroTag: "speedDown",
                      onPressed: () {
                        setState(() {
                          if (scrollSpeed > 0.5) scrollSpeed -= 0.5;
                        });
                        KHelper.showSuccess(
                            message: "سرعة التمرير: $scrollSpeed");
                      },
                      backgroundColor: KColors.primary2Color,
                      mini: true,
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // زر زيادة سرعة التمرير
                    FloatingActionButton(
                      heroTag: "speedUp",
                      onPressed: () {
                        setState(() {
                          if (scrollSpeed < 10) scrollSpeed += 0.5;
                        });
                        KHelper.showSuccess(
                            message: "سرعة التمرير: $scrollSpeed");
                      },
                      backgroundColor: KColors.primary2Color,
                      mini: true,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // زر تفعيل/إلغاء التمرير التلقائي
                  FloatingActionButton(
                    heroTag: "autoScroll",
                    onPressed: toggleAutoScroll,
                    backgroundColor: isScrolling ? Colors.red : Colors.green,
                    child: Icon(isScrolling ? Icons.stop : Icons.play_arrow,
                        color: Colors.white),
                  ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        actions: [
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showFontSizeSlider,
                    icon: Icon(
                      Icons.format_size,
                      color: isDark ? Colors.white : Colors.black,
                      size: 26,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // InkWell(
                  //   onTap: () async {
                  //     if (bookmarkId == widget.surah.id) {
                  //       await removeBookmark();
                  //       KHelper.showError(
                  //           message:
                  //               "تَمَّ حَذْفُ عَلَامَةِ سُورَةِ ${widget.surah.name} بِنَجَاحٍ");
                  //       bookmarkId = null;
                  //     } else {
                  //       await saveBookmark(widget.surah.id, widget.surah.name);
                  //       bookmarkId = widget.surah.id;
                  //       KHelper.showSuccess(
                  //           message:
                  //               "تَمَّ إِضَافَةُ عَلَامَةِ سُورَةِ ${widget.surah.name} بِنَجَاحٍ");
                  //     }
                  //     setState(() {});
                  //   },
                  //   child: Icon(
                  //     size: 30,
                  //     bookmarkId == widget.surah.id
                  //         ? Icons.bookmark_add
                  //         : Icons.bookmark,
                  //     color: isDark ? Colors.white : Colors.black,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
        leading: CupertinoNavigationBarBackButton(
          color: isDark ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        title: Text(
          "سورة ${widget.surah.name}",
          style: TextStyle(
            fontSize: isTablet ? 28 : 23.sp,
            fontFamily: 'maja',
            height: 2.2,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            // المحتوى الأساسي (المصحف)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  const threshold = 200;
                  if (details.primaryVelocity! > threshold) {
                    // Swipe Right (تحريك لليمين) -> التالي (Next)
                    goToNextSurah();
                  } else if (details.primaryVelocity! < -threshold) {
                    // Swipe Left (تحريك لليسار) -> السابق (Previous)
                    goToPreviousSurah();
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? const [Color(0xff05060a), Color(0xff0d1514)]
                        : const [Color(0xfff4f6f8), Color(0xfffdfcf9)],
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: showBottom ? 100.h : 20.h),
                  itemCount: widget.surah.verses.length,
                  itemBuilder: (context, index) {
                    final verse = widget.surah.verses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 24.0),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            if (index == 0 &&
                                widget.surah.name != "الفاتحة" &&
                                widget.surah.name != "التوبة")
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                                  style: TextStyle(
                                    fontSize: isTablet ? 15.sp : 20.sp,
                                    fontFamily: 'me',
                                    height: 2.2,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.red,
                                  ),
                                ),
                              ),
                            if (index == 0 && widget.surah.name == "التوبة")
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "أعوذُ باللهِ منَ الشيطانِ الرَّجيمِ",
                                  style: TextStyle(
                                    fontSize: isTablet ? 15.sp : 20.sp,
                                    fontFamily: 'me',
                                    height: 2.2,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.red,
                                  ),
                                ),
                              ),
                            Center(
                              child: RichText(
                                textAlign: widget.surah.name == "الفاتحة"
                                    ? TextAlign.center
                                    : fontSizeValue >= 50
                                        ? TextAlign.center
                                        : TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: fontSizeValue,
                                    fontFamily: 'me',
                                    height: 2.2,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  children: _buildVerseWithColoredNumbers(
                                      verse.text
                                          .replaceAll("(", "﴿")
                                          .replaceAll(")", "﴾"),
                                      isDark),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.copy,
                                      size: 20,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: verse.text));
                                    KHelper.showSuccess(
                                        message: "   تم نسخ السورة");
                                  },
                                ),
                              ],
                            ),
                            const Divider(
                                thickness: 0.5, indent: 50, endIndent: 50),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // شريط التنقل السفلي الاحترافي (Premium Bar)
            if (showBottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: showBottom ? 1.0 : 0.0,
                  child: Container(
                    margin: EdgeInsets.all(20.r),
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // السورة السابقة (تظهر في اليمين في RTL)
                              _buildNavButton(
                                title: currentIndex > 0
                                    ? widget.allSurahs[currentIndex - 1].name
                                    : "البداية",
                                icon: Icons
                                    .arrow_back_ios_new_rounded, // سهم لليمين
                                onPressed:
                                    currentIndex > 0 ? goToPreviousSurah : null,
                                isPrev:
                                    false, // وضع الأيقونة في اليمين (بداية الصف في RTL)
                              ),

                              // زر المظهر (Theme)
                              // _buildThemeSwitcher(),

                              // زر الفهرس (Index)
                              _buildIndexButton(),

                              // السورة التالية (تظهر في اليسار في RTL)
                              _buildNavButton(
                                title: currentIndex <
                                        widget.allSurahs.length - 1
                                    ? widget.allSurahs[currentIndex + 1].name
                                    : "النهاية",
                                icon: Icons
                                    .arrow_forward_ios_rounded, // سهم لليسار
                                onPressed:
                                    currentIndex < widget.allSurahs.length - 1
                                        ? goToNextSurah
                                        : null,
                                isPrev:
                                    true, // وضع الأيقونة في اليسار (نهاية الصف في RTL)
                              ),
                            ],
                          ),
                        ),
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

  // أداة تبديل المظهر بتصميم عصري
  Widget _buildThemeSwitcher() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDark = !isDark;
          saveThemePreference(isDark);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.amber : AppStyle.primColors,
          size: 24,
        ),
      ),
    );
  }

  // زر العودة للفهرس بتصميم متقن
  Widget _buildIndexButton() {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SurahListScreen(useOldMushaf: true, autoResume: false),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SurahListScreen(useOldMushaf: true, autoResume: false),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        child: Icon(
          Icons.format_list_bulleted_rounded,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  // أزرار التنقل بين السور بتصميم Premium
  Widget _buildNavButton({
    required String title,
    required IconData icon,
    VoidCallback? onPressed,
    required bool isPrev,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPrev)
              Icon(icon,
                  size: 16,
                  color: onPressed == null
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black87)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                title,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: onPressed == null
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isPrev)
              Icon(icon,
                  size: 16,
                  color: onPressed == null
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  void goToPreviousSurah() {
    if (currentIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurahDetailScreen(
            verseId: widget.verseId,
            surah: widget.allSurahs[currentIndex - 1],
            allSurahs: widget.allSurahs,
            showBottomOnStart: true,
            isDark: isDark,
            initialFontSize:
                fontSizeValue, // تمرير حجم الخط الحالي للسورة التالية
          ),
        ),
      );
    }
  }

  void goToNextSurah() {
    if (currentIndex < widget.allSurahs.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurahDetailScreen(
            verseId: widget.verseId,
            surah: widget.allSurahs[currentIndex + 1],
            allSurahs: widget.allSurahs,
            showBottomOnStart: true,
            isDark: isDark,
            initialFontSize:
                fontSizeValue, // تمرير حجم الخط الحالي للسورة التالية
          ),
        ),
      );
    }
  }
}

Future<void> saveBookmark(int verseId, String verseName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('bookmark_verseId', verseId);
  await prefs.setString('bookmark_verseName', verseName);
}

Future<void> saveSurahList(List<SurahModel> surahList) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> jsonList =
      surahList.map((surah) => jsonEncode(surah.toJson())).toList();
  await prefs.setStringList('saved_surahs', jsonList);
}

Future<void> saveSingleSurah(SurahModel surah) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(surah.toJson());
  await prefs.setString('bookmarked_surah', jsonString);
}

Future<int?> getBookmark() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('bookmark_verseId');
}

Future<void> removeBookmark() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('bookmark_verseId');
  await prefs.remove('bookmark_verseName');
}
