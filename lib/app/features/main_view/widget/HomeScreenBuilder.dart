import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Khatmah/data/khatmah_model.dart';
import 'AzkarQuranWidget.dart';
import 'OtherAzkarWidget.dart';
import '../../../core/controller/timing.dart';
import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';





class MainViewBuilder extends StatefulWidget {
  const MainViewBuilder({super.key});

  @override
  _MainViewBuilderState createState() => _MainViewBuilderState();
}

class _MainViewBuilderState extends StateMVC<MainViewBuilder> {
  /// Let the 'business logic' run in a Controller
  _MainViewBuilderState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;

  late CentralizedCubit centralizedCubit;
  int? verseId;
  String? verseName;
  List<SurahModel>? surahModel;
  late final Box<KhatmahModel> box;
  late final Box plansBox; // khatmahPlans
  @override
  void initState() {
    centralizedCubit = context.read<CentralizedCubit>();
    centralizedCubit.checkConnectivity();
    centralizedCubit.trackConnectivityChange();
    // TODO: implement initState
    super.initState();
    loadSurahList();
    loadVerseName();
    loadSurahs();
    loadBookmark();
    box = Hive.box<KhatmahModel>('khatmahBox'); // نفس الاسم اللي بتفتحه في main
    plansBox = Hive.box('khatmahPlans');
  }

  void loadBookmark() async {
    final id = await getBookmark();
    setState(() {
      // bookmarkId = id;
    });
  }

  Future<int?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_verseId');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // centralizedCubit.dispose();
  }

  void loadVerseId() async {
    final id = await getVerseId();
    setState(() {
      verseId = id;
    });
  }

  void loadVerseName() async {
    final name = await getVerseName();
    setState(() {
      verseName = name;
    });
  }

  Future<String?> getVerseName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bookmark_verseName');
  }

  Future<int?> getVerseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_verseId');
  }

  void loadSurahs() async {
    final loadedSurahs =
    await loadSurahList(); // تحميل القائمة من SharedPreferences
    setState(() {
      surahModel = loadedSurahs; // تخزينها في المتغير
    });
  }

  Future<List<SurahModel>> loadSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('saved_surahs');

    if (jsonList == null) return [];

    return jsonList
        .map((jsonStr) => SurahModel.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  final List<Map<String, String>> iconsApp = [
    {
      "title": "أَذْكَارُ الصَّبَاحِ",
      "icon": "assets/images/contrast.png",
      "navigate": "/azkarSabah"
    },
    {
      "title": "أَذْكَارُ الْمَسَاءِ",
      "icon": "assets/images/islam.png",
      "navigate": "/azkarMassa"
    },
    {
      "title": "السبحة",
      "icon": "assets/images/beads2.png",
      "navigate": "/azkarCounter"
    },
    {
      "title": "المصحف",
      "icon": "assets/images/koran.png",
      "navigate": "/surahListScreen"
    },
    {
      "title": "أَذْكَارٌ مُتَنَوِّعَةٌ",
      "icon": "assets/images/open-hands.png",
      "navigate": "/allazkarlistview"
    },
    {
      "title": "مَوَاقِيتُ الصَّلَاةِ",
      "icon": "assets/images/mosque.png",
      "navigate": "/timingScreen"
    },
    {
      "title": "الْقِبْلَةِ",
      "icon": "assets/images/qibla (1).png",
      "navigate": "/qiblaDirection"
    },
    {
      "title": "مَوْسُوعَةُ الْأَحَادِيثِ",
      "icon": "assets/images/kaaba.png",
      "navigate": Routes.categoriesRoute,
    },
    {
      "title": "راديو القران الكريم",
      "icon": "assets/icons/radio.png",
      "navigate": "/QuranRadioView"
    },
    {
      "title": "الختمات المنجزه",
      "icon": "assets/images/achivement.png",
      "navigate": "/compplateKhatna"
    },
    {
      "title": " اورادك من الذكر",
      "icon": "assets/images/tauhid.png",
      "navigate": "/WirdHomeScreen"
    },
    // {
    //   "title": "قناة القران الكريم",
    //   "icon": "assets/icons/radio.png",
    //   "navigate": "/QuranChannalPlayerView"
    // },
    // {
    //   "title": "قناة السنة النبوية",
    //   "icon": "assets/icons/radio.png",
    //   "navigate": "/QuranChannalPlayerView"
    // },
    {
      "title": "عَنَّا",
      "icon": "assets/images/info (1).png",
      "navigate": "/about"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final completed = box.values.where((k) => k.isCompleted).toList();

    bool isTab = ResponsiveUtil.isTablet(context);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: isTab
                            ? MediaQuery.of(context).size.height / 3.5
                            : MediaQuery.of(context).size.height/3.5,
                        child: Image.asset(
                          "assets/images/pattern.webp",
                          height: isTab
                              ? MediaQuery.of(context).size.height / 3.5
                              : MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        )),
                    Positioned.fill(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: isTab
                              ? MediaQuery.of(context).size.height / 3.5
                              : MediaQuery.of(context).size.height,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.8)
                              : AppColors.secondaryLight.withOpacity(0.6),
                        )),
                    Positioned(
                        top: 45,
                        right: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Icon(Icons.date_range,size: isTab?33:20,color: AppColors.greyLightColor,),
                                  // SizedBox(width: 5.w,),
                                  TextDefaultWidget(
                                    title: con.hijriDate,
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? AppColors.greyLightColor
                                        : Colors.black,
                                    fontSize: isTab ? 12.sp : 14.sp,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: TextDefaultWidget(
                                      title: con.gregorian ?? "",
                                      color: Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? AppColors.greyLightColor
                                          : Colors.black,
                                      fontSize: isTab ? 9.sp : 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    // Positioned(
                    //   top: 50,
                    //   left: 10,
                    //   child: InkWell(
                    //     onTap: () => showThemeSheet(context),
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //       child: AnimatedSwitcher(
                    //         duration: const Duration(milliseconds: 200),
                    //         child: Icon(
                    //           Theme.of(context).brightness == Brightness.dark
                    //               ? Icons.dark_mode
                    //               : Icons.light_mode,
                    //           key: ValueKey(Theme.of(context).brightness),
                    //           size: isTab ? 33 : 20,
                    //           color:
                    //               Theme.of(context).brightness == Brightness.dark
                    //                   ? AppColors.greyLightColor
                    //                   : Colors.black,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Positioned(
                      top: 50,
                      left: 10,
                      child: InkWell(
                        onTap: () => showThemeSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.settings,
                              // key: ValueKey(Theme.of(context).brightness),
                              size: isTab ? 33 : 20,
                              color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.greyLightColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextDefaultWidget(
                            title: "الصلاة القادمة",
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.greyLightColor
                                : Colors.black,
                            fontSize: isTab ? 12.sp : 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "me",
                          ),
                          TextDefaultWidget(
                            title: con.nextPrayer,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.greyLightColor
                                : Colors.black,
                            fontSize: isTab ? 12.sp : 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "me",
                          ),
                          TextDefaultWidget(
                            title: con.remainingTimeText,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.greyLightColor
                                : Colors.black,
                            fontSize: isTab ? 12.sp : 20.sp,
                            fontFamily: "cairo",
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    // Positioned(
                    //     top: isTab ? 180 : 120,
                    //     right: isTab ? 330 : 125,
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           TextDefaultWidget(
                    //             title: "الصلاة القادمة",
                    //             color: Theme.of(context).brightness ==
                    //                     Brightness.dark
                    //                 ? AppColors.greyLightColor
                    //                 : Colors.black,
                    //             fontSize: isTab ? 12.sp : 20.sp,
                    //             fontWeight: FontWeight.bold,
                    //             fontFamily: "me",
                    //           ),
                    //           TextDefaultWidget(
                    //             title: con.nextPrayer,
                    //             color: Theme.of(context).brightness ==
                    //                     Brightness.dark
                    //                 ? AppColors.greyLightColor
                    //                 : Colors.black,
                    //             fontSize: isTab ? 12.sp : 20.sp,
                    //             fontWeight: FontWeight.bold,
                    //             fontFamily: "me",
                    //           ),
                    //           TextDefaultWidget(
                    //             title: con.remainingTimeText,
                    //             color: Theme.of(context).brightness ==
                    //                     Brightness.dark
                    //                 ? AppColors.greyLightColor
                    //                 : Colors.black,
                    //             fontSize: isTab ? 12.sp : 20.sp,
                    //             fontFamily: "cairo",
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ],
                    //       ),
                    //     )),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                //       style: GoogleFonts.cairo(
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //           fontSize: MediaQuery.sizeOf(context).width > 600
                //               ? 10.sp
                //               : 16.sp),
                //     ),
                //   ],
                // ),
                // const Padding(
                //    padding: EdgeInsets.symmetric(vertical: 15),
                //    child: GreetingWidget()),
                // Row(
                //   children: [
                //     Expanded(
                //       flex: 2,
                //       child: AnimatedWrapper(
                //         type: UiAnimationType.slideLeft,
                //         child: SizedBox(
                //           width: MediaQuery.sizeOf(context).width / 1.8,
                //           height: MediaQuery.sizeOf(context).width > 600
                //               ? MediaQuery.sizeOf(context).width / 6
                //               : MediaQuery.sizeOf(context).width / 4,
                //           child: Card(
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //             color: CupertinoColors.systemBackground,
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 10.0, vertical: 7),
                //               child: Center(
                //                 child: Column(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceEvenly,
                //                   children: [
                //                     Text(
                //                       con.gregorian ?? "",
                //                       style: GoogleFonts.cairo(
                //                           color: Colors.black,
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: MediaQuery.sizeOf(context)
                //                                       .width >
                //                                   600
                //                               ? 17
                //                               : 13),
                //                     ),
                //                     const SizedBox(
                //                       height: 10,
                //                     ),
                //                     Text(
                //                       con.hijriDate,
                //                       style: GoogleFonts.cairo(
                //                           color: Colors.black,
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: 11.sp),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //     con.nextPrayer.isNotEmpty
                //         ?  Expanded(
                //       child: AnimatedWrapper(
                //         type: UiAnimationType.slideRight,
                //         child: SizedBox(
                //           height: MediaQuery.sizeOf(context).width > 600
                //               ? MediaQuery.sizeOf(context).width / 6
                //               : MediaQuery.sizeOf(context).width / 4,
                //           width: MediaQuery.sizeOf(context).width / 1.8,
                //           child: Card(
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //             color: CupertinoColors.systemBackground,
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 10.0, vertical: 7),
                //               child: Center(
                //                 child: Column(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceEvenly,
                //                   children: [
                //                   Text(
                //                             con.nextPrayer,
                //                             style: GoogleFonts.cairo(
                //                                 color: Colors.black,
                //                                 fontWeight: FontWeight.w600,
                //                                 fontSize:
                //                                     MediaQuery.sizeOf(context)
                //                                                 .width >
                //                                             600
                //                                         ? 14.sp
                //                                         : 15.sp),
                //                           ),
                //                     const SizedBox(
                //                       height: 10,
                //                     ),
                //                     Text(
                //                       con.remainingTimeText,
                //                       style: GoogleFonts.cairo(
                //                           color: Colors.black,
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: MediaQuery.sizeOf(context)
                //                                       .width >
                //                                   600
                //                               ? 11.sp
                //                               : 13.sp),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ):const Expanded(child: Center(child: CircularProgressIndicator(),)),
                //   ],
                // ),
                // IslamicHeaderWidget(gregorian: con.gregorian, hijriDate: con.hijriDate, nextPrayer: con.nextPrayer, remainingTimeText: con.remainingTimeText),
                const SizedBox(height: 10),
                // MediaQuery.sizeOf(context).width > 600
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTab ? 10.w : 5.0),
                  child: SizedBox(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: isTab ? 30 : 7,
                      mainAxisSpacing: isTab ? 20 : 15,
                      childAspectRatio: isTab ? 1.9 : 01.20,
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),
                      // عشان المكون يكون جزء من ScrollView تانية
                      children: iconsApp.map((item) {
                        return BlocBuilder<CentralizedCubit, CentralizedState>(
                          builder: (context, state) {
                            return InkWell(
                              onTap: () {
                                bool needsInternet =
                                    item["navigate"] == Routes.categoriesRoute || item["navigate"] == "/QuranRadioView" ;

                                        // ||
                                        // item["navigate"] == "/qiblaDirection";

                                (state is ConnectivityState &&
                                    state.status ==
                                        ConnectivityStatus
                                            .disconnected) ==
                                    true &&
                                    needsInternet
                                    ? Fluttertoast.showToast(
                                    msg: "يرجي التحقق من اتصالك بالانترنت")
                                    : Navigator.pushNamed(
                                    context, item['navigate']!);
                              },
                              // child: Card(
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(10),
                              //     side: const BorderSide(
                              //         color: Colors.grey, width: 1),
                              //   ),
                              //   child: SizedBox(
                              //     width: 90,
                              //     height: 80,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.spaceBetween,
                              //         children: [
                              //           Image.asset(
                              //             item["icon"]!,
                              //             width:
                              //                 MediaQuery.sizeOf(context).width >
                              //                         600
                              //                     ? 90
                              //                     : 40,
                              //             height:
                              //                 MediaQuery.sizeOf(context).width >
                              //                         600
                              //                     ? 75
                              //                     : 40,
                              //             fit: BoxFit.contain,
                              //           ),
                              //           const SizedBox(height: 8),
                              //           // Text(
                              //           //   item["title"]!,
                              //           //   style: GoogleFonts.cairo(
                              //           //       color: Colors.black,
                              //           //       fontWeight: FontWeight.bold,
                              //           //       fontSize: 9.sp),
                              //           // ),
                              //           TextDefaultWidget(title:item["title"]! ,fontFamily: "me",fontSize: ResponsiveUtil.isTablet(context)? 10.sp : 11.5.sp,fontWeight: ResponsiveUtil.isTablet(context)?FontWeight.w500: FontWeight.bold,)
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              child: IslamicCardWidget(
                                  title: item["title"]!, iconPath: item["icon"]!),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                )
                // : Wrap(
                //
                //     spacing: 50,
                //     runSpacing: 13,
                //     crossAxisAlignment: WrapCrossAlignment.center,
                //     alignment: WrapAlignment.center,
                //     children: iconsApp.map((item) {
                //       return InkWell(
                //         onTap: () {
                //           Navigator.pushNamed(context, item['navigate']!);
                //         },
                //         child: Card(
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //             side: const BorderSide(
                //                 color: Colors.grey, width: 1),
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 5.0, vertical: 12.0),
                //             child: SizedBox(
                //               width: 120,
                //               height: 80,
                //               child: Column(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.spaceBetween,
                //                 children: [
                //                   Image.asset(
                //                     item["icon"]!,
                //                     width: 40,
                //                     height: 40,
                //                     fit: BoxFit.contain,
                //                   ),
                //                   const SizedBox(height: 8),
                //                   Text(
                //                     item["title"]!,
                //                     style: GoogleFonts.cairo(
                //                         color: Colors.black,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 13),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                ,
                SizedBox(
                    height: MediaQuery.sizeOf(context).width > 600 ? 25 : 20),
                const AzkarQuranWidget(),
                const SizedBox(height: 10),
                const OtherAzkarWidget(),
                // const SizedBox(height: 10),
                //
                // Container(
                //   padding: const EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     border: const BorderDirectional(
                //       start: BorderSide(color: Color(0xffd6bb7a), width: 3),
                //     ),
                //     color: Theme.of(context).cardColor,
                //   ),
                //   width: MediaQuery.sizeOf(context).width,
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           "وردك اليومي",
                //           style: GoogleFonts.cairo(
                //               fontWeight: FontWeight.bold, fontSize:MediaQuery.sizeOf(context).width >600?10.sp:  15.sp),
                //         ),
                //         const SizedBox(height: 10),
                //         verseName==null?   Text(
                //           "لايوجد",
                //           textAlign: TextAlign.justify,
                //           style: TextStyle(fontSize: MediaQuery.sizeOf(context).width >600?25: 16),
                //         ):  Text(
                //           "وِرْدُكَ الأَخِيرُ كَانَ فِي سُورَةِ $verseName",
                //           textAlign: TextAlign.justify,
                //           style: TextStyle(fontSize: MediaQuery.sizeOf(context).width >600?25: 16),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}