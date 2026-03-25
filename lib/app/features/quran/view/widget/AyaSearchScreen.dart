
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AyaSearchScreen extends StatefulWidget {
  const AyaSearchScreen({super.key});

  @override
  State<AyaSearchScreen> createState() => _AyaSearchScreenState();
}

class _AyaSearchScreenState extends State<AyaSearchScreen> {
  late TextEditingController searchKey;
  List<AyahModel> ayah = [];
  Timer? _debounce;

  // Voice Search
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Search History
  List<String> searchHistory = [];
  bool isHistoryLoading = true;

  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
    _initSpeech();
    loadSearchHistory();
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('quran_search_history') ?? [];
      isHistoryLoading = false;
    });
  }

  Future<void> addToHistory(String term) async {
    final text = term.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.remove(text);
      searchHistory.insert(0, text);
      if (searchHistory.length > 10) {
        searchHistory = searchHistory.sublist(0, 10);
      }
    });
    await prefs.setStringList('quran_search_history', searchHistory);
  }

  Future<void> removeFromHistory(String term) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.remove(term);
    });
    await prefs.setStringList('quran_search_history', searchHistory);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.clear();
    });
    await prefs.remove('quran_search_history');
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
  }

  void _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (val) {
            debugPrint("Speech error: ${val.errorMsg}");
            setState(() => _isListening = false);
          },
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              setState(() {
                searchKey.text = val.recognizedWords;
                loadeData(searchText: val.recognizedWords);
              });
            },
            localeId: 'ar_SA',
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "عذراً، ميزة البحث الصوتي غير مدعومة على هذا الجهاز",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: "cairo"),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Speech recognition exception: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "حدث خطأ أثناء تشغيل البحث الصوتي",
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: "cairo"),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchKey.dispose();
    super.dispose();
  }

  void loadeData({String? searchText}) {
    final query = searchText?.trim() ?? '';
    if (query.isEmpty) {
      setState(() {
        ayah.clear();
      });
      return;
    }

    // Add to history only if we have results (optional) or just add it
    // Adding it here implies any submitted search is saved
    addToHistory(query);

    setState(() {
      ayah = QuranLibrary().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtil.isTablet(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenWidth > 600 ? 80 : 60),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CupertinoNavigationBarBackButton(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            title: Text(
              "البحث بالآية",
              style: TextStyle(
                  fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: screenWidth > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xff05060a),
                      Color(0xff0d1514),
                    ]
                  : const [
                      Color(0xfff4f6f8),
                      Color(0xfffdfcf9),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // الهيدر + حقل البحث
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 18.w : 16,
                    vertical: isTablet ? 8.h : 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 14.w : 12,
                          vertical: isTablet ? 10.h : 8,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white)
                              .withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                          border: Border.all(
                            color: (isDark
                                    ? KColors.primaryColor
                                    : KColors.primary2Color)
                                .withOpacity(0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark
                                        ? KColors.primaryColor
                                        : KColors.primary2Color)
                                    .withOpacity(0.12),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: isTablet ? 18.sp : 22,
                                color: isDark
                                    ? KColors.primaryColor
                                    : KColors.primary2Color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    title: "ابحث داخل القرآن الكريم",
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 9.sp : 14,
                                  ),
                                  const SizedBox(height: 2),
                                  TextWidget(
                                    title:
                                        "اكتب كلمة، جزءًا من آية، أو رقم آية.",
                                    fontSize: isTablet ? 8.sp : 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoSearchTextField(
                              controller: searchKey,
                              itemColor: isDark ? Colors.white : Colors.black54,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontFamily: TextStyle(
                  fontFamily: "cairo",).fontFamily,
                                fontSize: isTablet ? 9.sp : 14,
                              ),
                              onSuffixTap: () {
                                searchKey.clear();
                                setState(() {
                                  ayah.clear();
                                });
                              },
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xff151515)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isDark
                                      ? KColors.primary.withOpacity(0.6)
                                      : KColors.scoColor.withOpacity(0.7),
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                    color: Colors.black.withOpacity(0.04),
                                  ),
                                ],
                              ),
                              placeholder: "اكتب نص الآية أو كلمة منها",
                              placeholderStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontFamily: TextStyle(
                  fontFamily: "cairo",).fontFamily,
                                fontSize: isTablet ? 8.sp : 13,
                              ),
                              onChanged: (value) {
                                _debounce?.cancel();
                                _debounce = Timer(
                                    const Duration(milliseconds: 450), () {
                                  loadeData(searchText: value);
                                });
                              },
                              onSubmitted: (value) =>
                                  loadeData(searchText: value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _listen,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? Colors.red.withOpacity(0.1)
                                    : (isDark
                                            ? KColors.primaryColor
                                            : KColors.primary2Color)
                                        .withOpacity(0.12),
                                border: Border.all(
                                    color: _isListening
                                        ? Colors.red
                                        : (isDark
                                                ? KColors.primaryColor
                                                : KColors.primary2Color)
                                            .withOpacity(0.3),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening
                                            ? Colors.red
                                            : Colors.green)
                                        .withOpacity(0.15),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red
                                    : (isDark
                                        ? KColors.primaryColor
                                        : KColors.primary2Color),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // النتائج أو حالة فارغة
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ayah.isNotEmpty
                        ? ListView.separated(
                            key: const ValueKey("results"),
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 18.w : 16,
                              4,
                              isTablet ? 18.w : 16,
                              24,
                            ),
                            itemCount: ayah.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = ayah[index];
                              return _AyaResultCard(
                                ayah: item,
                                onTap: () {
                                  QuranLibrary().jumpToAyah(
                                    item.page,
                                    item.ayahUQNumber,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )
                        : (query.isEmpty && searchHistory.isNotEmpty)
                            ? _SearchHistoryList(
                                key: const ValueKey("history"),
                                history: searchHistory,
                                isDark: isDark,
                                onSelect: (val) {
                                  searchKey.text = val;
                                  loadeData(searchText: val);
                                },
                                onDelete: removeFromHistory,
                                onClearAll: clearHistory,
                              )
                            : _EmptyState(
                                key: const ValueKey("empty"),
                                query: query,
                                isDark: isDark,
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
}

class _AyaResultCard extends StatelessWidget {
  final AyahModel ayah;
  final VoidCallback onTap;

  const _AyaResultCard({
    required this.ayah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtil.isTablet(context);

    final Color primary = isDark ? KColors.primaryColor : KColors.primary2Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      const Color(0xff0d1017),
                      const Color(0xff171c25),
                    ]
                  : [
                      const Color(0xfffefdf9),
                      const Color(0xfff4f7fb),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              // شريط جانبي كأنه تجليد مصحف
              Positioned.fill(
                left: null,
                right: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primary.withOpacity(0.7),
                          primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // السطر العلوي: رقم الآية + اسم السورة + الصفحة
                    Row(
                      children: [
                        // دائرة رقم الآية
                        Container(
                          width: isTablet ? 36 : 32,
                          height: isTablet ? 36 : 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primary.withOpacity(0.1),
                                primary.withOpacity(0.5),
                              ],
                            ),
                            border: Border.all(
                              color: primary,
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextWidget(
                            title: ayah.ayahNumber.toString(),
                            fontFamily: "me",
                            fontSize: isTablet ? 8.sp : 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // اسم السورة + وصف صغير
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                title: ayah.arabicName.toString(),
                                fontFamily: "me",
                                fontSize: isTablet ? 9.sp : 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 2),
                              TextWidget(
                                title:
                                    "الآية رقم ${ayah.ayahNumber} - صفحة ${ayah.page}",
                                fontSize: isTablet ? 7.sp : 11.sp,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // شارة الصفحة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: primary.withOpacity(0.12),
                            border: Border.all(
                              color: primary.withOpacity(0.7),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: isTablet ? 12.sp : 16,
                                color: primary,
                              ),
                              const SizedBox(width: 4),
                              TextWidget(
                                title: "ص ${ayah.page}",
                                fontSize: isTablet ? 7.sp : 11.sp,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // نص الآية
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isDark
                            ? const Color(0xff11151d)
                            : const Color(0xfffdfcf9),
                        border: Border.all(
                          color: primary.withOpacity(0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        ayah.ayaTextEmlaey,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: "me",
                          fontSize: isTablet ? 9.sp : 15.sp,
                          height: 1.9,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // سطر إرشادي خفيف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.hand_draw,
                              size: isTablet ? 10.sp : 14,
                              color: primary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            TextWidget(
                              title: "اضغط للانتقال إلى هذه الآية",
                              fontSize: isTablet ? 7.sp : 11.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ],
                        ),
                        Icon(
                          CupertinoIcons.chevron_back,
                          size: isTablet ? 10.sp : 14,
                          color: primary.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final bool isDark;

  const _EmptyState({
    super.key,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 190,
              width: 190,
              child: Lottie.asset("assets/json/file-searching.json"),
            ),
            const SizedBox(height: 8),
            if (query.isEmpty) ...[
              TextWidget(
                title: "ابدأ بالبحث في آيات القرآن الكريم",
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 9.sp : 16,
              ),
              const SizedBox(height: 4),
              TextWidget(
                title:
                    "اكتب أي كلمة أو جملة؛ وسنُظهر لك المواضع التي وردت في المصحف.",
                fontSize: isTablet ? 8.sp : 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    title: "لا توجد نتائج عن ",
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 9.sp : 15,
                  ),
                  TextWidget(
                    title: query,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KColors.primary : KColors.primary2Color,
                    fontSize: isTablet ? 9.sp : 15,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextWidget(
                title: "حاول استخدام كلمة أخرى أو جزءًا أقصر من الآية.",
                fontSize: isTablet ? 8.sp : 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  final List<String> history;
  final bool isDark;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onClearAll;

  const _SearchHistoryList({
    super.key,
    required this.history,
    required this.isDark,
    required this.onSelect,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 18.w : 20,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                title: "آخر عمليات البحث",
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 9.sp : 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              TextButton(
                onPressed: onClearAll,
                child: TextWidget(
                  title: "مسح الكل",
                  fontSize: isTablet ? 8.sp : 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 18.w : 16),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final term = history[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff151515) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.04),
                  ),
                ),
                child: ListTile(
                  onTap: () => onSelect(term),
                  leading: Icon(
                    Icons.history,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    size: 20,
                  ),
                  title: TextWidget(
                    title: term,
                    fontSize: isTablet ? 9.sp : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    onPressed: () => onDelete(term),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
