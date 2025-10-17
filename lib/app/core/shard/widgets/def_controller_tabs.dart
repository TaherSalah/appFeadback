import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/main_view/widget/AzkarQuranWidget.dart';
import '../../../features/main_view/widget/OtherAzkarWidget.dart';
import '../../controller/timing.dart';
import '../../cubit/centralized_cubit.dart';
import '../exports/all_exports.dart';


// class DefControllerTabs extends StatefulWidget {
//   const DefControllerTabs({super.key});
//
//   @override
//   State<DefControllerTabs> createState() => _DefControllerTabsState();
// }
//
// class _DefControllerTabsState extends State<DefControllerTabs> {
//   late String selectedFontSize;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedFontSize = "20";
//   }
//   @override
//   Widget build(BuildContext context) {
//     final DateTime now = DateTime.now();
//     final String gregorian =
//         initl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);
//     final HijriCalendar hijri = HijriCalendar.now();
//     final String hijriDate =
//         "${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ";
//     return Scaffold(
//       body: SafeArea(
//         child: Directionality(
//           textDirection: TextDirection.rtl,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Icon(Icons.notifications_active_outlined,
//                         size: 35, color: CupertinoColors.activeGreen),
//                     TextDefaultWidget(
//                         title: "رفيق المسلم",
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xffbaa063),
//                         fontSize: MediaQuery.sizeOf(context).width > 600
//                             ? 16.sp
//                             : 25.sp),
//                     Image.asset(
//                       "assets/images/azkary_logo.png",
//                       height: 50,
//                     ),
//                   ],
//                 ),
//                 TextDefaultWidget(
//                   title: "يومك سعيد !",
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xffbaa063),
//                   fontSize: 25.sp,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Card(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 gregorian,
//                                 style: const TextStyle(
//                                     fontSize: 15, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 hijriDate,
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Expanded(
//                       child: Card(
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "العصر بعد",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 "1:0:0",
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
      "title": "السبحة",
      "icon": "assets/images/tasbih.png",
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
      "icon": "assets/images/qibla-compass.png",
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
    } ,

  ];


  @override
  Widget build(BuildContext context) {
    bool isTab =ResponsiveUtil.isTablet(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
    );
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
        Stack(
          children: [
            Image.asset("assets/images/pattern.webp"),
            Positioned.fill(
              top: 0,
              right: 0,
              left:0 ,
              child: Container(
                color: AppColors.primary.withOpacity(0.6),
              )),
            Positioned(
              top: 45,
                right: 10,
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(

                        children: [
                          // Icon(Icons.date_range,size: isTab?33:20,color: AppColors.greyLightColor,),
                          // SizedBox(width: 5.w,),
                          TextDefaultWidget(title: con.hijriDate ?? "",color: AppColors.greyLightColor,fontSize: 16.sp,),
                        ],
                      ),
                      SizedBox(height: 4.h,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextDefaultWidget(title: con.gregorian ?? "",color: AppColors.greyLightColor,fontSize: 15.sp,),
                          ),
                        ],
                      ),
                    ],
                  ),
                )

            ),
            Positioned(
              top: 45, left: 10,
              child: InkWell(
                onTap: () => showThemeSheet(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      key: ValueKey(Theme.of(context).brightness),
                      size: isTab?33:25,
                      color: AppColors.greyLightColor,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 100,
                right: isTab? 300:130,
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextDefaultWidget(title: "الصلاة القادمة",color: AppColors.greyLightColor,fontSize: 25.sp,fontWeight: FontWeight.bold,fontFamily: "me",),
                      TextDefaultWidget(title: con.nextPrayer,color:AppColors.greyLightColor,fontSize: 25.sp,fontWeight: FontWeight.bold,fontFamily: "me",),
                      TextDefaultWidget(title: con.remainingTimeText,color: AppColors.greyLightColor,fontSize: 20.sp,fontFamily: "cairo",fontWeight: FontWeight.bold,),

                    ],
                  ),
                )

            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing:
                        MediaQuery.sizeOf(context).width > 600 ? 18 : 7,
                    mainAxisSpacing: 15,
                    childAspectRatio:
                        MediaQuery.sizeOf(context).width > 600 ? 1.6 : 01.20,
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
                            child: IslamicCardWidget(title: item["title"]!, iconPath: item["icon"]!),
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
    );
  }
}

class IslamicHeaderWidget extends StatelessWidget {
  final String? gregorian;
  final String hijriDate;
  final String nextPrayer;
  final String remainingTimeText;

  const IslamicHeaderWidget({
    super.key,
    required this.gregorian,
    required this.hijriDate,
    required this.nextPrayer,
    required this.remainingTimeText,
  });

  String _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'الفجر':
        return '🌅';
      case 'الظهر':
        return '☀️';
      case 'العصر':
        return '🌤️';
      case 'المغرب':
        return '🌇';
      case 'العشاء':
        return '🌙';
      default:
        return '🕌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width > 600;

    return Row(
      children: [
        // بطاقة التاريخ
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: isTablet ? width / 6 : width / 3.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xfffacf70),
                  Color(0xfffaf38e),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.shade100.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.teal.shade700,
                    size: isTablet ? 36 : 28,
                  ),
                  Text(
                    gregorian ?? '',
                    style: GoogleFonts.cairo(
                      color: Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 17 : 12,
                    ),
                  ),
                  Text(
                    hijriDate,
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // بطاقة الصلاة القادمة
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: isTablet ? width / 6 : width / 3.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFede7f6),
                  Color(0xFFd1c4e9),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade100.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${_getPrayerIcon(nextPrayer)} $nextPrayer',
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 15,
                    ),
                  ),
                  Text(
                    'الوقت المتبقي:',
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 13 : 12,
                    ),
                  ),
                  Text(
                    remainingTimeText,
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}


class IslamicCardWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const IslamicCardWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 130 : 95,
        height: isTablet ? 120 : 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // gradient: LinearGradient(
          //   colors: [
          //     const Color(0xFFFAF3E0),
          //     const Color(0xFFF1E5C3),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFD4AF37), // لون ذهبي راقٍ
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  // gradient: LinearGradient(
                  //   colors:  [
                  //     Theme.of(context).brightness == Brightness.dark ?  Color(
                  //         0xFF272725):KColors.whiteGrayColor,
                  //     Theme.of(context).brightness == Brightness.dark ?  Color(
                  //         0xFF191816):KColors.whiteGrayColor,
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.brown.withOpacity(0.3),
                  //     blurRadius: 5,
                  //     offset: const Offset(0, 3),
                  //   ),
                  // ],
                ),
                child: Image.asset(
                  iconPath,
                  width: isTablet ? 45 : 25,
                  height: isTablet ? 45 : 25,
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 13 : 12.sp,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                    )
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

void showThemeSheet(BuildContext ctx) {
  final cubit = CentralizedCubit.get(ctx);
  final current = cubit.themeMode();

  showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (bc) {
      ListTile tile(String title, IconData icon, ThemeMode mode) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: current == mode ? const Icon(Icons.check) : null,
        onTap: () async {
          await cubit.setThemeMode(mode);
          Navigator.pop(bc);
        },
      );
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text('اختر النمط', style: TextStyle(fontSize: 18,fontFamily: "cairo")),
              tile('فاتح', Icons.light_mode, ThemeMode.light),
              tile('داكن', Icons.dark_mode, ThemeMode.dark),
              tile('حسب النظام', Icons.phone_android, ThemeMode.system),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
