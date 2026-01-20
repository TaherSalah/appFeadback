import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart' as surahModel;
import 'package:quran_library/quran.dart';

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
        final normalizedArabicName = _normalizeArabic(item.arabicName.toLowerCase());
        final arabicNameMatch = normalizedArabicName.contains(normalizedQuery);
        final transliterationMatch = item.model.transliteration.toLowerCase().contains(lowerQuery);
        
        return numberMatch || arabicNameMatch || transliterationMatch;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadSurahInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "فهرس القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
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
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      onChanged: _filterSurahs,
                      placeholder: "بحث باسم السورة او الرقم",
                      style: TextStyle(
                         color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredSurahItems.isEmpty 
                    ?  Center(child: Text("لا توجد نتائج", style: GoogleFonts.cairo(fontSize: 16.sp),))
                    : ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredSurahItems.length,
                        itemBuilder: (ctx, index) {
                          final item = _filteredSurahItems[index];
                          final surah = item.model;
                          final realIndex = item.index; // This is the 0-based index from original list
                    
                          final types = surah.type == "medinan"
                              ? "assets/images/madina.png"
                              : "assets/images/macca.png";
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
                                        fontSize: ResponsiveUtil.isTablet(context)
                                            ? 9.sp
                                            : 14.sp,
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
                                            fontSize: ResponsiveUtil.isTablet(context)
                                                ? 9.sp
                                                : 17.5.sp,
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
                                              title:
                                                  " اياتها ${surah.totalVerses.toString()}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        QuranLibrary().getSurahInfoBottomSheet(
                                            surahNumber: realIndex + 1,
                                            context: context,
                                            isDark: Theme.of(context).brightness ==
                                                Brightness.dark);
                                      },
                                      child: const Icon(Icons.info_outline),
                                    ),
                                  ),
                                  Image.asset(
                                    types,
                                    height: 45,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SurahItem {
  final int index;
  final String arabicName;
  final surahModel.SurahModel model;

  SurahItem({required this.index, required this.arabicName, required this.model});
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
