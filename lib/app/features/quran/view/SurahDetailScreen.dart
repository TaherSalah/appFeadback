import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/shareCard/PremiumShareCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/shard/exports/all_exports.dart';
import '../../../core/shard/widgets/ui_animations.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../SurahModel.dart';

// ----------------------- Surah Detail Screen -----------------------
class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;
  final List<SurahModel> allSurahs;
  final bool showBottomOnStart;
  final bool isDark;
  final int verseId;
  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.allSurahs,
    this.showBottomOnStart = false,
    this.isDark = false,
    required this.verseId, // قيمة افتراضية
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double fontSize = 28;
  late bool isDark;
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool isScrolling = false;
  double scrollSpeed = 1; // بكسل لكل دورة
  bool showControls = false;
  bool showFab = false;
  bool showBottom = false;
  Timer? _hideTimer;
  late int currentIndex;
  String? selectedFontSize = "20";
  int? bookmarkId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    currentIndex = widget.allSurahs.indexWhere((s) => s.id == widget.surah.id);
    // Show bottom navigation if navigated from next/previous buttons
    showBottom = widget.showBottomOnStart;
    showFab = false;
    isDark = widget.isDark;
    loadBookmark();
    bookmarkId = widget.verseId; //
    // If showing bottom navigation, start the hide timer
    if (showBottom) {
      _startHideTimer();
    }
  }

  List<TextSpan> _buildVerseWithColoredNumbers(String text, bool isDark) {
    // final markRegExp = RegExp(r'۞');
    final numberRegExp = RegExp(r'\d+');
    final markRegExp = RegExp(r'﴿\d+﴾');

    final markRegExp2 = RegExp(r'۞');

    final matches = [
      ...numberRegExp.allMatches(text).map((m) => {
            'start': m.start,
            'end': m.end,
            'type': 'number',
          }),
      ...markRegExp.allMatches(text).map((m) => {
            'start': m.start,
            'end': m.end,
            'type': 'mark',
          }),
      ...markRegExp2.allMatches(text).map((m) => {
            'start': m.start,
            'end': m.end,
            'type': 'mark2',
          }),
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
            // fontSize: 15.sp,
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



  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _hideTimer?.cancel();

    super.dispose();
  }

  void startAutoScroll() {
    const duration = Duration(milliseconds: 50); // تحديث سريع نسبياً
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

  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() {
      isScrolling = false;
    });
  }

  void _showSpeedSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextWidget(
                    title: "اختر سرعة التمرير للايات",
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  Slider(
                    min: 0.5,
                    max: 10,
                    divisions: 20,
                    label: "السرعة: ${scrollSpeed.toStringAsFixed(1)}",
                    value: scrollSpeed,
                    thumbColor: Colors.black,
                    activeColor: Colors.indigoAccent,
                    onChanged: (value) {
                      // تحديث القيمة محليًا
                      setModalState(() {
                        scrollSpeed = value;
                      });

                      // تحديث القيمة عالمياً + إعادة التشغيل لو لازم
                      setState(() {
                        if (isScrolling) {
                          _autoScrollTimer?.cancel();
                          startAutoScroll();
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startHideTimer() {
    _hideTimer?.cancel(); // إلغاء المؤقت السابق
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        showBottom = false;
        showFab = false;
        showControls = false; // Also hide controls
      });
    });
  }

  void _toggleControls() {
    setState(() {
      showBottom = !showBottom;
      showFab = !showFab;
      if (showBottom || showFab) {
        _startHideTimer(); // Start timer to hide after 5 seconds
      } else {
        _hideTimer?.cancel(); // Cancel timer if hiding manually
      }
    });
  }

  void loadBookmark() async {
    final id = await getBookmark();
    setState(() {
      bookmarkId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    List<String> sizes = <String>[
      "20",
      "22",
      "23",
      "25",
      "28",
      "30",
      "40",
      "50",
      "60",
      "70",
      "80",
      "90",
      "100",
    ];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls, // Use the new toggle function

      onHorizontalDragEnd: (details) {
        // بناءً على اتجاه السحب
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            goToNextSurah();
            // سحب لليمين → السورة السابقة
          } else if (details.primaryVelocity! < 0) {
            // سحب لليسار → السورة التالية
            goToPreviousSurah();
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFFFFBEA),
        floatingActionButton: showFab
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // زر تبديل إظهار الأدوات
                  FloatingActionButton(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    heroTag: 'toggleControls',
                    onPressed: () {
                      setState(() {
                        showControls = !showControls;
                      });
                      // Reset the hide timer when interacting with controls
                      if (showControls) {
                        _startHideTimer();
                      }
                    },
                    child: Icon(showControls ? Icons.close : Icons.settings,
                        color: isDark ? Colors.black : Colors.white),
                  ),
                  if (showControls) ...[
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      heroTag: 'playPause',
                      onPressed: () {
                        if (isScrolling) {
                          stopAutoScroll();
                        } else {
                          startAutoScroll();
                        }
                        _startHideTimer(); // Reset timer when interacting
                      },
                      child: Icon(isScrolling ? Icons.pause : Icons.play_arrow,
                          color: isDark ? Colors.black : Colors.white),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      heroTag: 'speed',
                      onPressed: () {
                        _showSpeedSlider(context);
                        _startHideTimer(); // Reset timer when interacting
                      },
                      child: Icon(Icons.speed,
                          color: isDark ? Colors.black : Colors.white),
                    ),
                  ]
                ],
              )
            : null,

        bottomNavigationBar: showBottom
            ? BottomAppBar(
                height: 75,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                isDark ? Colors.white : AppStyle.primColors)),
                        onPressed: currentIndex < widget.allSurahs.length - 1
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SurahDetailScreen(
                                      verseId: widget.verseId,
                                      surah: widget.allSurahs[currentIndex + 1],
                                      allSurahs: widget.allSurahs,
                                      showBottomOnStart:
                                          true, // Show bottom navigation on next screen
                                      isDark: isDark, // 🟢 تمرير القيمة هنا
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: TextDefaultWidget(
                          title: currentIndex < widget.allSurahs.length - 1
                              ? widget.allSurahs[currentIndex + 1].name
                              : "لا يوجد",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 9.sp : 16.sp,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: isDark
                              ? Colors.white
                              : CupertinoColors.darkBackgroundGray,
                        ),
                        onPressed: () {
                          setState(() {
                            isDark = !isDark;
                          });
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              isDark ? Colors.white : AppStyle.primColors),
                        ),
                        onPressed: currentIndex > 0
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SurahDetailScreen(
                                      verseId: widget.verseId,

                                      surah: widget.allSurahs[currentIndex - 1],
                                      allSurahs: widget.allSurahs,
                                      showBottomOnStart:
                                          true, // Show bottom navigation on next screen
                                      isDark: isDark, // 🟢 تمرير القيمة هنا
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: TextDefaultWidget(
                          title:
                              " ${currentIndex > 0 ? widget.allSurahs[currentIndex - 1].name : "لا يوجد"}",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 9.sp : 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        // backgroundColor: isDark ? Colors.black : const Color(0xFFFFFBEA),
        appBar: AppBar(
          actions: [
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: AnimatedWrapper(
                        type: UiAnimationType.slideRight,
                        duration: const Duration(seconds: 1),
                        child: FontSizeDropdown(
                          selectedFontSize: selectedFontSize,
                          sizes: sizes,
                          onChanged: (value) {
                            setState(() {
                              selectedFontSize = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        if (bookmarkId == widget.surah.id) {
                          // إزالة البوك مارك
                          await removeBookmark(); // أنشئ دالة removeBookmark()
                          KHelper.showError(
                              message:
                                  "تَمَّ حَذْفُ عَلَامَةِ سُورَةِ ${widget.surah.name} بِنَجَاحٍ");

                          bookmarkId = null;
                        } else {
                          // حفظ البوك مارك
                          await saveBookmark(
                              widget.surah.id, widget.surah.name);
                          bookmarkId = widget.surah.id;
                          KHelper.showSuccess(
                              message:
                                  "تَمَّ إِضَافَةُ عَلَامَةِ سُورَةِ ${widget.surah.name} بِنَجَاحٍ");
                        }

                        setState(() {});
                      },
                      child: Icon(
                        size: 30,
                        bookmarkId == widget.surah.id
                            ? Icons.bookmark_add
                            : Icons.bookmark,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          leading: const CupertinoNavigationBarBackButton(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "سورة ${widget.surah.name}",
            style: TextStyle(
              fontSize: isTablet ? 28 : 23.sp,
              fontFamily: 'maja',
              height: 2.2,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: ListView.builder(
            controller: _scrollController,
            itemCount: widget.surah.verses.length,
            itemBuilder: (context, index) {
              final verse = widget.surah.verses[index];
              double fontSizeValue = double.parse(selectedFontSize!);

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 24.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      // "التوبة"
                      (widget.surah.name != "الفاتحة" &&
                              widget.surah.name != "التوبة")
                          ? Text(
                              "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                              style: TextStyle(
                                fontSize: isTablet ? 15.sp : 20.sp,
                                fontFamily: 'me',
                                height: 2.2,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.red,
                              ),
                            )
                          : widget.surah.name == "التوبة"
                              ? Text(
                                  "أعوذُ باللهِ منَ الشيطانِ الرَّجيمِ",
                                  style: TextStyle(
                                    fontSize: isTablet ? 15.sp : 20.sp,
                                    fontFamily: 'me',
                                    height: 2.2,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.red,
                                  ),
                                )
                              : const Text(""),

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
                              fontSize: double.parse(selectedFontSize!),
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
                                color: isDark ? Colors.white54 : Colors.grey),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: verse.text));
                              KHelper.showSuccess(
                                  message: "تم نسخ الآية الكريمة");
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.image_outlined,
                                size: 22,
                                color: isDark
                                    ? Colors.amber.withOpacity(0.7)
                                    : Colors.amber.shade700),
                            onPressed: () {
                              showGeneralDialog(
                                context: context,
                                pageBuilder: (context, anim1, anim2) =>
                                    PremiumShareCard(
                                  azkarName: "",
                                  text: verse.text,
                                  source:
                                      "سورة ${widget.surah.name} - آية ${index + 1}",
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(thickness: 0.5, indent: 50, endIndent: 50),
                    ],
                  ),
                ),
              );
            }),
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
            showBottomOnStart: true, // Show bottom navigation on next screen
            isDark: isDark, // 🟢 تمرير القيمة هنا
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
            showBottomOnStart: true, // Show bottom navigation on next screen
            isDark: isDark, // 🟢 تمرير القيمة هنا
          ),
        ),
      );
    }
  }
}

class FontSizeDropdown extends StatefulWidget {
  final String? selectedFontSize;
  final List<String> sizes;
  final ValueChanged<String?> onChanged;

  const FontSizeDropdown({
    super.key,
    required this.selectedFontSize,
    required this.sizes,
    required this.onChanged,
  });

  @override
  State<FontSizeDropdown> createState() => _FontSizeDropdownState();
}

class _FontSizeDropdownState extends State<FontSizeDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: const TextDefaultWidget(
          textAlign: TextAlign.right,
          title: "حجم الخط",
          fontSize: 15,
          color: Color(0xff1A1A1A),
        ),
        items: widget.sizes.map((e) {
          return DropdownMenuItem(
            value: e,
            child: TextDefaultWidget(
              textAlign: TextAlign.right,
              title: e,
              fontSize: 12.5,
            ),
          );
        }).toList(),
        value: widget.selectedFontSize,
        onChanged: widget.onChanged,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            border: Border.all(color: AppStyle.scondColors, width: 1.5),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          width: MediaQuery.of(context).size.width / 1.2,
        ),
        menuItemStyleData: MenuItemStyleData(
          overlayColor: MaterialStateProperty.all(
            Colors.grey.withOpacity(0.5),
          ),
          height: 50,
        ),
        dropdownStyleData: DropdownStyleData(
          elevation: 1,
          decoration: BoxDecoration(
            color: const Color(0xfffaedcd),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}

Future<void> saveBookmark(
  int verseId,
  String verseName,
) async {
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
