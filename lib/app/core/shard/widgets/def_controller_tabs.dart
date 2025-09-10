import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as initl;
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:muslimdaily/app/features/quran/view/SurahDetailScreen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:quran_library/quran.dart' as sr;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/main_view/widget/AzkarQuranWidget.dart';
import '../../../features/main_view/widget/OtherAzkarWidget.dart';
import '../../../features/main_view/widget/morningWidget.dart';
import '../../controller/timing.dart';
import '../../cubit/centralized_cubit.dart';
import '../exports/all_exports.dart';


class DefControllerTabs extends StatefulWidget {
  const DefControllerTabs({super.key});

  @override
  State<DefControllerTabs> createState() => _DefControllerTabsState();
}

class _DefControllerTabsState extends State<DefControllerTabs> {
  late String selectedFontSize;

  @override
  void initState() {
    super.initState();
    selectedFontSize = "20";
  }
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String gregorian =
        initl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);
    final HijriCalendar hijri = HijriCalendar.now();
    final String hijriDate =
        "${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ";
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.notifications_active_outlined,
                        size: 35, color: CupertinoColors.activeGreen),
                    TextDefaultWidget(
                        title: "رفيق المسلم",
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffbaa063),
                        fontSize: MediaQuery.sizeOf(context).width > 600
                            ? 16.sp
                            : 25.sp),
                    Image.asset(
                      "assets/images/azkary_logo.png",
                      height: 50,
                    ),
                  ],
                ),
                TextDefaultWidget(
                  title: "يومك سعيد !",
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffbaa063),
                  fontSize: 25.sp,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gregorian,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                hijriDate,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "العصر بعد",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "1:0:0",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenBuilder extends StatefulWidget {
  const HomeScreenBuilder({super.key});

  @override
  _HomeScreenBuilderState createState() => _HomeScreenBuilderState();
}

class _HomeScreenBuilderState extends StateMVC<HomeScreenBuilder> {
  /// Let the 'business logic' run in a Controller
  _HomeScreenBuilderState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;

  late CentralizedCubit centralizedCubit;
int? verseId;
String? verseName;
  List<SurahModel>? surahModel;
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
    final loadedSurahs = await loadSurahList(); // تحميل القائمة من SharedPreferences
    setState(() {
      surahModel = loadedSurahs; // تخزينها في المتغير
    });
  }

  Future<List<SurahModel>> loadSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('saved_surahs');

    if (jsonList == null) return [];

    return jsonList.map((jsonStr) => SurahModel.fromJson(jsonDecode(jsonStr))).toList();
  }

  final List<Map<String, String>> iconsApp =
  [
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
      "title": "الْمِسْبَحَةُ الإِلِكْتْرُونِيَّةُ",
      "icon": "assets/images/tasbih.png",
      "navigate": "/azkarCounter"
    },
    {
      "title": "الْقُرْآنُ الْكَرِيمُ",
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
      "title": "اتِّجَاهُ الْقِبْلَةِ",
      "icon": "assets/images/qibla-compass.png",
      "navigate": "/qiblaDirection"
    },
    {
      "title": "مَوْسُوعَةُ الْأَحَادِيثِ",
      "icon": "assets/images/kaaba.png",
      "navigate": Routes.categoriesRoute,
    },
    {
      "title": "عَنَّا",
      "icon": "assets/images/info (1).png",
      "navigate": "/about"
    } ,
    {
      "title": "ختمتك",
      "icon": "assets/images/info (1).png",
      "navigate": "/KhatmahHome"
    }
  ];


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppStyle.bgColors,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppStyle.bgColors,
    ),
    );
    return Scaffold(
      backgroundColor: AppStyle.bgColors,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
                        style: GoogleFonts.cairo(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.sizeOf(context).width > 600
                                ? 10.sp
                                : 16.sp),
                      ),
                    ],
                  ),
                   const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: GreetingWidget()),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AnimatedWrapper(
                          type: UiAnimationType.slideLeft,
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width / 1.8,
                            height: MediaQuery.sizeOf(context).width > 600
                                ? MediaQuery.sizeOf(context).width / 6
                                : MediaQuery.sizeOf(context).width / 4,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: CupertinoColors.systemBackground,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 7),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        con.gregorian ?? "",
                                        style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.sizeOf(context)
                                                        .width >
                                                    600
                                                ? 17
                                                : 13),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        con.hijriDate,
                                        style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      con.nextPrayer.isNotEmpty
                          ?  Expanded(
                        child: AnimatedWrapper(
                          type: UiAnimationType.slideRight,
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).width > 600
                                ? MediaQuery.sizeOf(context).width / 6
                                : MediaQuery.sizeOf(context).width / 4,
                            width: MediaQuery.sizeOf(context).width / 1.8,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: CupertinoColors.systemBackground,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 7),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                    Text(
                                              con.nextPrayer,
                                              style: GoogleFonts.cairo(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      MediaQuery.sizeOf(context)
                                                                  .width >
                                                              600
                                                          ? 14.sp
                                                          : 15.sp),
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        con.remainingTimeText,
                                        style: GoogleFonts.cairo(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.sizeOf(context)
                                                        .width >
                                                    600
                                                ? 11.sp
                                                : 13.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ):const Expanded(child: Center(child: CircularProgressIndicator(),)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // MediaQuery.sizeOf(context).width > 600
                  SizedBox(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing:
                          MediaQuery.sizeOf(context).width > 600 ? 18 : 9,
                      mainAxisSpacing: 15,
                      childAspectRatio:
                          MediaQuery.sizeOf(context).width > 600 ? 1.6 : 1.1,
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),
                      // عشان المكون يكون جزء من ScrollView تانية
                      children: iconsApp.map((item) {
                        return BlocBuilder<CentralizedCubit, CentralizedState>(
                          builder: (context, state) {
                            return InkWell(
                              onTap: () {


                                bool needsInternet = item["navigate"] ==  Routes.categoriesRoute ||
                                    item["navigate"] == "/qiblaDirection";

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
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                child: SizedBox(
                                  width: 90,
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          item["icon"]!,
                                          width:
                                              MediaQuery.sizeOf(context).width >
                                                      600
                                                  ? 90
                                                  : 40,
                                          height:
                                              MediaQuery.sizeOf(context).width >
                                                      600
                                                  ? 75
                                                  : 40,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(height: 8),
                                        // Text(
                                        //   item["title"]!,
                                        //   style: GoogleFonts.cairo(
                                        //       color: Colors.black,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontSize: 9.sp),
                                        // ),
                                        TextDefaultWidget(title:item["title"]! ,fontFamily: "me",fontSize: ResponsiveUtil.isTablet(context)? 10.sp : 11.5.sp,fontWeight: ResponsiveUtil.isTablet(context)?FontWeight.w500: FontWeight.bold,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
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
                      height: MediaQuery.sizeOf(context).width > 600 ? 25 : 10),
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
      ),
    );
  }
}
