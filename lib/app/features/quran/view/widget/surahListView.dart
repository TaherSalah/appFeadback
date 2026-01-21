import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
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

  // Voice Search
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // New views data
  final List<String> jozzs = QuranLibrary.allJoz;
  final List<String> hizbs = QuranLibrary.allHizb;
  List<String> _filteredJozzs = [];
  List<String> _filteredHizbs = [];

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
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
      setState(() => _filteredHizbs = List.from(hizbs));
      return;
    }
    setState(() {
      _filteredHizbs = hizbs
          .where((h) =>
              _normalizeArabic(h.toLowerCase())
                  .contains(_normalizeArabic(query.toLowerCase())) ||
              (hizbs.indexOf(h) + 1).toString().contains(query))
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
    _filteredHizbs = List.from(hizbs);

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
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "فهرس القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp),
            ),
            bottom: TabBar(
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "سورة"),
                Tab(text: "جزء"),
                Tab(text: "حزب"),
              ],
            ),
          ),
          body: isLoading == true
              ? Center(
                  child: KLoading.progressIOSIndicator(
                      radius: 15.r, context: context),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoSearchTextField(
                              controller: _searchController,
                              onChanged: _filterAll,
                              placeholder: "بحث باسم السورة او الرقم...",
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _listen,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                border: Border.all(
                                    color: _isListening
                                        ? Colors.red
                                        : Colors.green),
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening ? Colors.red : Colors.green,
                                size: 20,
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
    );
  }

  Widget _buildSurahTab() {
    if (_filteredSurahItems.isEmpty) {
      return Center(
          child:
              Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp)));
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredSurahItems.length,
      itemBuilder: (ctx, index) {
        final item = _filteredSurahItems[index];
        final surah = item.model;
        final realIndex = item.index;

        final types = surah.type == "medinan"
            ? "assets/images/madina.png"
            : "assets/images/macca.png";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: InkWell(
            onTap: () {
              QuranLibrary().jumpToSurah(realIndex + 1);
              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset("assets/icons/suraNum.svg"),
                    TextWidget(
                      title: "${realIndex + 1}",
                      fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                          fontFamily: "me",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 9.sp : 17.5.sp,
                          fontWeight: FontWeight.bold,
                          title: item.arabicName),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextWidget(
                            fontFamily: "me",
                            fontSize: ResponsiveUtil.isTablet(context)
                                ? 10.sp
                                : 16.sp,
                            fontWeight: FontWeight.w500,
                            title: " اياتها ${surah.totalVerses.toString()}"),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    QuranLibrary().getSurahInfoBottomSheet(
                        surahNumber: realIndex + 1,
                        context: context,
                        isDark:
                            Theme.of(context).brightness == Brightness.dark);
                  },
                  child: const Icon(Icons.info_outline),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  types,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ],
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
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredJozzs.length,
      itemBuilder: (ctx, index) {
        final jozName = _filteredJozzs[index];
        final actualIndex = jozzs.indexOf(jozName);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: InkWell(
            onTap: () {
              QuranLibrary().jumpToJoz(actualIndex + 1);
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset("assets/icons/suraNum.svg"),
                    TextWidget(
                      title: "${actualIndex + 1}",
                      fontSize: 14.sp,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                TextWidget(
                  title: jozName,
                  fontFamily: "me",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHizbTab() {
    if (_filteredHizbs.isEmpty) {
      return Center(
          child:
              Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp)));
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredHizbs.length,
      itemBuilder: (ctx, index) {
        final hizbName = _filteredHizbs[index];
        final actualIndex = hizbs.indexOf(hizbName);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: InkWell(
            onTap: () {
              QuranLibrary().jumpToHizb(actualIndex + 1);
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset("assets/icons/suraNum.svg"),
                    TextWidget(
                      title: "${actualIndex + 1}",
                      fontSize: 14.sp,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                TextWidget(
                  title: hizbName,
                  fontFamily: "me",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
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
