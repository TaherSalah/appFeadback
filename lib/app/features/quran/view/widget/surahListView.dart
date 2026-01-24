import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart' as surahModel;
import 'package:quran_library/quran.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../messaView/azkar_massa.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final List<String> surahs = QuranLibrary.getAllSurahs();
  final List<BookmarkModel> bookmark = QuranLibrary().usedBookmarks;

  List<surahModel.SurahModel> surahInfoList = [];
  List<SurahItem> _allSurahItems = [];
  List<SurahItem> _filteredSurahItems = [];
  TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  // Smart Index - Hizb Data
  final List<String> _allHizbItems = QuranLibrary.allHizb;
  List<String> _filteredHizbItems = [];

  // Voice Search
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // New views data
  final List<String> jozzs = QuranLibrary.allJoz;
  List<String> _filteredJozzs = [];

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
                _searchController.text = val.recognizedWords;
                _filterAll(val.recognizedWords);
              });
            },
            localeId: 'ar_SA',
          );
        } else {
          if (mounted) {
            KHelper.showError(message: "عذراً، ميزة البحث الصوتي غير مدعومة على هذا الجهاز (قد تحتاج لتثبيت خدمات جوجل الصوتية)",);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text(
            //       "عذراً، ميزة البحث الصوتي غير مدعومة على هذا الجهاز (قد تحتاج لتثبيت خدمات جوجل الصوتية)",
            //       textAlign: TextAlign.right,
            //       style: TextStyle(fontFamily: "cairo"),
            //     ),
            //     backgroundColor: Colors.redAccent,
            //   ),
            // );
          }
        }
      } catch (e) {
        debugPrint("Speech recognition exception: $e");
        if (mounted) {
          KHelper.showError(message:  "حدث خطأ أثناء تشغيل البحث الصوتي",);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //       "حدث خطأ أثناء تشغيل البحث الصوتي",
          //       textAlign: TextAlign.right,
          //       style: TextStyle(fontFamily: "cairo"),
          //     ),
          //     backgroundColor: Colors.redAccent,
          //   ),
          // );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _filterAll(String query) {
    _filterSurahs(query);
    _filterJozzs(query);
    _filterHizbs(query);
  }

  void _filterJozzs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredJozzs = List.from(jozzs));
      return;
    }
    setState(() {
      _filteredJozzs = jozzs
          .where((j) =>
              _normalizeArabic(j.toLowerCase())
                  .contains(_normalizeArabic(query.toLowerCase())) ||
              (jozzs.indexOf(j) + 1).toString().contains(query))
          .toList();
    });
  }

  void _filterHizbs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredHizbItems = List.from(_allHizbItems));
      return;
    }
    final normalizedQuery = _normalizeArabic(query.toLowerCase());
    setState(() {
      _filteredHizbItems = _allHizbItems
          .where((h) =>
              _normalizeArabic(h.toLowerCase()).contains(normalizedQuery) ||
              (_allHizbItems.indexOf(h) + 1).toString().contains(query))
          .toList();
    });
  }

  Future<void> loadSurahInfo() async {
    isLoading = true;
    setState(() {});
    final String response =
        await rootBundle.loadString('assets/json/quran.json');
    final List data = jsonDecode(response);

    surahInfoList =
        data.map((json) => surahModel.SurahModel.fromJson(json)).toList();

    // Prepare searchable items
    _allSurahItems = [];
    for (int i = 0; i < surahInfoList.length; i++) {
      // QuranLibrary.getAllSurahs() usually returns Arabic names.
      // If you need transliteration, ensure it's available in surahModel or surahs list.
      // Assuming surahModel has accurate data as well.
      _allSurahItems.add(SurahItem(
        index: i,
        arabicName: surahs.length > i ? surahs[i] : surahInfoList[i].name,
        model: surahInfoList[i],
      ));
    }
    _filteredSurahItems = List.from(_allSurahItems);
    _filteredJozzs = List.from(jozzs);
    _filteredHizbItems = List.from(_allHizbItems);

    isLoading = false;
    setState(() {});
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), ''); // Remove harakat
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahItems = List.from(_allSurahItems);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final normalizedQuery = _normalizeArabic(lowerQuery);

    setState(() {
      _filteredSurahItems = _allSurahItems.where((item) {
        final numberMatch = (item.index + 1).toString().contains(lowerQuery);
        final normalizedArabicName =
            _normalizeArabic(item.arabicName.toLowerCase());
        final arabicNameMatch = normalizedArabicName.contains(normalizedQuery);
        final transliterationMatch =
            item.model.transliteration.toLowerCase().contains(lowerQuery);

        return numberMatch || arabicNameMatch || transliterationMatch;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadSurahInfo();
    _initSpeech();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor:
                isDark ? const Color(0xff05060a) : const Color(0xfff4f6f8),
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "فِهْرِسُ القُرْآنِ الكَرِيم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp),
            ),
            bottom: TabBar(
              indicatorColor: Colors.green,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.green,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              tabs: const [
                Tab(text: "سورة"),
                Tab(text: "جزء"),
                Tab(text: "أحزاب"),
              ],
            ),
          ),
          body: isLoading == true
              ? Center(
                  child: KLoading.progressIOSIndicator(
                      radius: 15.r, context: context),
                )
              : Container(
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CupertinoSearchTextField(
                                  controller: _searchController,
                                  onChanged: _filterAll,
                                  placeholder: "بحث باسم السورة او الرقم...",
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white,
                                  style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black),
                                ),
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
                                      : Colors.green.withOpacity(0.1),
                                  border: Border.all(
                                      color: _isListening
                                          ? Colors.red
                                          : Colors.green,
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
                                  color:
                                      _isListening ? Colors.red : Colors.green,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSurahTab(),
                            _buildJozTab(),
                            _buildHizbTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSurahTab() {
    if (_filteredSurahItems.isEmpty) {
      return Center(
          child:
              Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp)));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredSurahItems.length,
      itemBuilder: (ctx, index) {
        final item = _filteredSurahItems[index];
        final surah = item.model;
        final realIndex = item.index;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final types = surah.type == "medinan"
            ? "assets/images/madina.png"
            : "assets/images/macca.png";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isDark ? const Color(0xff11151d) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                QuranLibrary().jumpToSurah(realIndex + 1);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/suraNum.svg",
                          colorFilter: ColorFilter.mode(
                            Colors.green.withOpacity(0.7),
                            BlendMode.srcIn,
                          ),
                          height: 45,
                        ),
                        TextWidget(
                          title: "${realIndex + 1}",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            title: item.arabicName,
                            fontFamily: "me",
                            fontSize: ResponsiveUtil.isTablet(context)
                                ? 12.sp
                                : 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              TextWidget(
                                title: "${surah.totalVerses} آية",
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 8.sp
                                    : 12.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextWidget(
                                title:
                                    surah.type == "medinan" ? "مدنية" : "مكية",
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 8.sp
                                    : 12.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            QuranLibrary().getSurahInfoBottomSheet(
                                surahNumber: realIndex + 1,
                                context: context,
                                isDark: isDark);
                          },
                          icon: Icon(
                            Icons.info_outline_rounded,
                            color: Colors.green.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          types,
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJozTab() {
    if (_filteredJozzs.isEmpty) {
      return Center(
          child:
              Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp)));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredJozzs.length,
      itemBuilder: (ctx, index) {
        final jozName = _filteredJozzs[index];
        final actualIndex = jozzs.indexOf(jozName);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isDark ? const Color(0xff11151d) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                QuranLibrary().jumpToJoz(actualIndex + 1);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/suraNum.svg",
                          colorFilter: const ColorFilter.mode(
                            Colors.green,
                            BlendMode.srcIn,
                          ),
                          height: 45,
                        ),
                        TextWidget(
                          title: "${actualIndex + 1}",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextWidget(
                        title: jozName,
                        fontFamily: "me",
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHizbTab() {
    if (_filteredHizbItems.isEmpty) {
      return Center(
          child:
              Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp)));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredHizbItems.length,
      itemBuilder: (ctx, index) {
        final hizbName = _filteredHizbItems[index];
        final actualIndex = _allHizbItems.indexOf(hizbName);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isDark ? const Color(0xff11151d) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                QuranLibrary().jumpToHizb(actualIndex + 1);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/suraNum.svg",
                          colorFilter: const ColorFilter.mode(
                            Colors.green,
                            BlendMode.srcIn,
                          ),
                          height: 45,
                        ),
                        TextWidget(
                          title: "${actualIndex + 1}",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextWidget(
                        title: hizbName,
                        fontFamily: "me",
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SurahItem {
  final int index;
  final String arabicName;
  final surahModel.SurahModel model;

  SurahItem(
      {required this.index, required this.arabicName, required this.model});
}
// return ListTile(
// leading: Stack(
// alignment: Alignment.center,
// children: [
// SvgPicture.asset("assets/icons/suraNum.svg"),
// TextWidget(title: "${index+1}",fontSize: 14.sp,),
// ],
// ),
// title: TextWidget(
// fontFamily: "me", fontSize: 17.5.sp, title: surahs[index]),
// subtitle: TextWidget(
// fontFamily: "me",
// fontSize: 15.sp,
// title: " اياتها ${surah.totalVerses.toString()}"),
// trailing: Image.asset(types),
// onTap: () {
// QuranLibrary().jumpToSurah(index + 1);
// Navigator.pop(context);
// },
// );
