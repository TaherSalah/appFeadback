import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart' as surahModel;
import 'package:quran_library/quran.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final List<String> surahs = QuranLibrary().getAllSurahs();
  final List<String> surahss = QuranLibrary().getAllSurahsArtPath();

  final List<BookmarkModel> bookmark = QuranLibrary().usedBookmarks;

  List<surahModel.SurahModel> surahInfoList = [];

  bool isLoading = true;

  Future<void> loadSurahInfo() async {
    isLoading = true;
    setState(() {});
    final String response =
        await rootBundle.loadString('assets/json/quran.json');
    final List data = jsonDecode(response);
    setState(() {
      surahInfoList =
          data.map((json) => surahModel.SurahModel.fromJson(json)).toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSurahInfo();
  }

  @override
  Widget build(BuildContext context) {
    print("surahss $surahss");
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: AppStyle.bgColors,


        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading:  CupertinoNavigationBarBackButton(
              color: Theme.of(context).brightness == Brightness.dark? Colors.white:Colors.black,
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
                child: KLoading.progressIOSIndicator(radius: 15.r),
              )
            : ListView.separated(
          separatorBuilder: (context, index) => Divider(),
                physics: const BouncingScrollPhysics(),
                itemCount: surahInfoList.length,
                itemBuilder: (ctx, index) {
                  final surah = surahInfoList[index];
                  final types = surah.type == "medinan"
                      ? "assets/images/madina.png"
                      : "assets/images/macca.png";
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        QuranLibrary().jumpToSurah(index + 1);
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
                                title: "${index + 1}",
                                fontSize:ResponsiveUtil.isTablet(context)?9.sp: 14.sp,
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
                                    fontSize: ResponsiveUtil.isTablet(context)?9.sp: 17.5.sp,
                                    fontWeight: FontWeight.bold,
                                    title: surahs[index]),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextWidget(
                                      fontFamily: "me",
                                      fontSize:ResponsiveUtil.isTablet(context)?10.sp: 16.sp,
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
                                    surahInfoStyle: SurahInfoStyle(
                                            primaryColor: Theme.of(context).brightness == Brightness.dark? Colors.black12:Colors.green,
                                      indicatorColor: Theme.of(context).brightness == Brightness.dark? Colors.greenAccent:Colors.green,
                                      surahNumberColor: Theme.of(context).brightness == Brightness.dark? Colors.greenAccent:Colors.green,
                                      titleColor: Theme.of(context).brightness == Brightness.dark? Colors.greenAccent:Colors.green,
                                      backgroundColor:  Theme.of(context).brightness == Brightness.dark?Theme.of(context).cardColor:Theme.of(context).cardColor,
                                      textColor:Theme.of(context).brightness == Brightness.dark?Colors.white: CupertinoColors.black,
                                        // backgroundColor: AppStyle.bgColors,
                                      ),
                                    surahNumber: index + 1,
                                    context: context);
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
    );
  }
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
