// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hive/hive.dart';
// import 'package:muslimdaily/app/core/utils/constent/router.dart';
// import 'package:muslimdaily/app/core/utils/style/k_color.dart';
// import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
// import 'package:muslimdaily/app/features/quran/SurahModel.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../main.dart';
// import '../../Khatmah/data/khatmah_model.dart';
// import 'AzkarQuranWidget.dart';
// import 'OtherAzkarWidget.dart';
// import '../controllar/MainController.dart';
// import '../../../core/cubit/centralized_cubit.dart';
// import '../../../core/shard/exports/all_exports.dart';
//
//
//
//
//
// class MainViewBuilder extends StatefulWidget {
//   const MainViewBuilder({super.key});
//
//   @override
//   _MainViewBuilderState createState() => _MainViewBuilderState();
// }
//
// class _MainViewBuilderState extends StateMVC<MainViewBuilder> {
//   /// Let the 'business logic' run in a Controller
//   _MainViewBuilderState() : super(MainController()) {
//     con = controller as MainController;
//   }
//
//   late MainController con;
//
//   late CentralizedCubit centralizedCubit;
//   int? verseId;
//   String? verseName;
//   List<SurahModel>? surahModel;
//   late final Box<KhatmahModel> box;
//   late final Box plansBox; // khatmahPlans
//   String? _locationText; // 👈 لعرض الموقع في الهيدر
//
//   @override
//   void initState() {
//     centralizedCubit = context.read<CentralizedCubit>();
//     centralizedCubit.checkConnectivity();
//     centralizedCubit.trackConnectivityChange();
//     // TODO: implement initState
//     super.initState();
//     loadSurahList();
//     loadVerseName();
//     loadSurahs();
//     loadBookmark();
//
//     box = Hive.box<KhatmahModel>('khatmahBox'); // نفس الاسم اللي بتفتحه في main
//     plansBox = Hive.box('khatmahPlans');
//     _loadSavedLocation(); // 👈 حمّل الموقع المحفوظ
//
//   }
//
//   Future<void> _loadSavedLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final country = prefs.getString('selected_country');
//     final city = prefs.getString('selected_city');
//
//     setState(() {
//       if (country != null && city != null) {
//         _locationText = '$country - $city';
//       } else {
//         _locationText = 'لم يتم تحديد الموقع';
//       }
//     });
//   }
//
//   Future<void> _onLocationChanged() async {
//     // حدّث الكنترولر حسب القيم الجديدة من الـ SharedPreferences
//     await con.refreshPrayerTimesFromPrefs();
//
//     // حدّث نص الموقع اللي في الهيدر
//     await _loadSavedLocation();
//   }
//
//
//   void loadBookmark() async {
//     final id = await getBookmark();
//     setState(() {
//       // bookmarkId = id;
//     });
//   }
//
//   Future<int?> getBookmark() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('bookmark_verseId');
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     // centralizedCubit.dispose();
//   }
//
//   void loadVerseId() async {
//     final id = await getVerseId();
//     setState(() {
//       verseId = id;
//     });
//   }
//
//   void loadVerseName() async {
//     final name = await getVerseName();
//     setState(() {
//       verseName = name;
//     });
//   }
//
//   Future<String?> getVerseName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('bookmark_verseName');
//   }
//
//   Future<int?> getVerseId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('bookmark_verseId');
//   }
//
//   void loadSurahs() async {
//     final loadedSurahs =
//     await loadSurahList(); // تحميل القائمة من SharedPreferences
//     setState(() {
//       surahModel = loadedSurahs; // تخزينها في المتغير
//     });
//   }
//
//   Future<List<SurahModel>> loadSurahList() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String>? jsonList = prefs.getStringList('saved_surahs');
//
//     if (jsonList == null) return [];
//
//     return jsonList
//         .map((jsonStr) => SurahModel.fromJson(jsonDecode(jsonStr)))
//         .toList();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final completed = box.values.where((k) => k.isCompleted).toList();
//
//     bool isTab = ResponsiveUtil.isTablet(context);
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.transparent,
//       ),
//     );
//     return Scaffold(
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: SingleChildScrollView(
//           child: SafeArea(
//             top: false,
//             bottom: true,
//             child: Column(
//               children: [
//                 // Stack(
//                 //   alignment: Alignment.bottomCenter,
//                 //   children: [
//                 //     SizedBox(
//                 //         width: MediaQuery.of(context).size.width,
//                 //         height: isTab
//                 //             ? MediaQuery.of(context).size.height / 3.5
//                 //             : MediaQuery.of(context).size.height/3.5,
//                 //         child: Image.asset(
//                 //           "assets/images/pattern.webp",
//                 //           height: isTab
//                 //               ? MediaQuery.of(context).size.height / 3.5
//                 //               : MediaQuery.of(context).size.height,
//                 //           fit: BoxFit.cover,
//                 //         )),
//                 //     Positioned.fill(
//                 //         top: 0,
//                 //         right: 0,
//                 //         left: 0,
//                 //         child: Container(
//                 //           width: MediaQuery.of(context).size.width,
//                 //           height: isTab
//                 //               ? MediaQuery.of(context).size.height / 3.5
//                 //               : MediaQuery.of(context).size.height,
//                 //           color: Theme.of(context).brightness == Brightness.dark
//                 //               ? Colors.black.withOpacity(0.8)
//                 //               : AppColors.secondaryLight.withOpacity(0.6),
//                 //         )),
//                 //     Positioned(
//                 //         top: 45,
//                 //         right: 10,
//                 //         child: Padding(
//                 //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 //           child: Column(
//                 //             crossAxisAlignment: CrossAxisAlignment.start,
//                 //             mainAxisAlignment: MainAxisAlignment.start,
//                 //             children: [
//                 //               Row(
//                 //                 children: [
//                 //                   // Icon(Icons.date_range,size: isTab?33:20,color: AppColors.greyLightColor,),
//                 //                   // SizedBox(width: 5.w,),
//                 //                   TextDefaultWidget(
//                 //                     title: con.hijriDate,
//                 //                     color: Theme.of(context).brightness ==
//                 //                         Brightness.dark
//                 //                         ? AppColors.greyLightColor
//                 //                         : Colors.black,
//                 //                     fontSize: isTab ? 12.sp : 14.sp,
//                 //                   ),
//                 //                 ],
//                 //               ),
//                 //               SizedBox(
//                 //                 height: 4.h,
//                 //               ),
//                 //               Row(
//                 //                 crossAxisAlignment: CrossAxisAlignment.center,
//                 //                 mainAxisAlignment: MainAxisAlignment.center,
//                 //                 children: [
//                 //                   Padding(
//                 //                     padding: const EdgeInsets.symmetric(
//                 //                         horizontal: 8.0),
//                 //                     child: TextDefaultWidget(
//                 //                       title: con.gregorian ?? "",
//                 //                       color: Theme.of(context).brightness ==
//                 //                           Brightness.dark
//                 //                           ? AppColors.greyLightColor
//                 //                           : Colors.black,
//                 //                       fontSize: isTab ? 9.sp : 12.sp,
//                 //                     ),
//                 //                   ),
//                 //                 ],
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         )),
//                 //     // Positioned(
//                 //     //   top: 50,
//                 //     //   left: 10,
//                 //     //   child: InkWell(
//                 //     //     onTap: () => showThemeSheet(context),
//                 //     //     child: Padding(
//                 //     //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 //     //       child: AnimatedSwitcher(
//                 //     //         duration: const Duration(milliseconds: 200),
//                 //     //         child: Icon(
//                 //     //           Theme.of(context).brightness == Brightness.dark
//                 //     //               ? Icons.dark_mode
//                 //     //               : Icons.light_mode,
//                 //     //           key: ValueKey(Theme.of(context).brightness),
//                 //     //           size: isTab ? 33 : 20,
//                 //     //           color:
//                 //     //               Theme.of(context).brightness == Brightness.dark
//                 //     //                   ? AppColors.greyLightColor
//                 //     //                   : Colors.black,
//                 //     //         ),
//                 //     //       ),
//                 //     //     ),
//                 //     //   ),
//                 //     // ),
//                 //     Positioned(
//                 //       top: 50,
//                 //       left: 10,
//                 //       child: InkWell(
//                 //         onTap: () => showThemeSheet(context),
//                 //         child: Padding(
//                 //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 //           child: AnimatedSwitcher(
//                 //             duration: const Duration(milliseconds: 200),
//                 //             child: Icon(
//                 //               Icons.settings,
//                 //               // key: ValueKey(Theme.of(context).brightness),
//                 //               size: isTab ? 33 : 20,
//                 //               color:
//                 //               Theme.of(context).brightness == Brightness.dark
//                 //                   ? AppColors.greyLightColor
//                 //                   : Colors.black,
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //     Padding(
//                 //       padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 30),
//                 //       child: Column(
//                 //         crossAxisAlignment: CrossAxisAlignment.center,
//                 //         mainAxisAlignment: MainAxisAlignment.center,
//                 //         children: [
//                 //           TextDefaultWidget(
//                 //             title: "الصلاة القادمة",
//                 //             color: Theme.of(context).brightness == Brightness.dark
//                 //                 ? AppColors.greyLightColor
//                 //                 : Colors.black,
//                 //             fontSize: isTab ? 12.sp : 20.sp,
//                 //             fontWeight: FontWeight.bold,
//                 //             fontFamily: "me",
//                 //           ),
//                 //           TextDefaultWidget(
//                 //             title: con.nextPrayer,
//                 //             color: Theme.of(context).brightness == Brightness.dark
//                 //                 ? AppColors.greyLightColor
//                 //                 : Colors.black,
//                 //             fontSize: isTab ? 12.sp : 20.sp,
//                 //             fontWeight: FontWeight.bold,
//                 //             fontFamily: "me",
//                 //           ),
//                 //           TextDefaultWidget(
//                 //             title: con.remainingTimeText,
//                 //             color: Theme.of(context).brightness == Brightness.dark
//                 //                 ? AppColors.greyLightColor
//                 //                 : Colors.black,
//                 //             fontSize: isTab ? 12.sp : 20.sp,
//                 //             fontFamily: "cairo",
//                 //             fontWeight: FontWeight.bold,
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//                 PrayerHeaderSection(
//                   progressValue: con.progressValue,
//                   hijriDate: con.hijriDate,
//                   gregorian: con.gregorian ?? "",
//                   nextPrayer: con.nextPrayer,
//                   remainingTime: con.remainingTimeText,
//                   location: _locationText ?? 'لم يتم تحديد الموقع',
//                   onSettingsTap: () => showThemeSheet(
//                     context,
//                     onLocationChanged: _onLocationChanged,
//                   ),
//
//                 ),
//                 const SizedBox(height: 10),
//                 const SizedBox(height: 10),
//                 // MediaQuery.sizeOf(context).width > 600
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: isTab ? 10.w : 5.0),
//                   child: SizedBox(
//                     child: GridView.count(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: isTab ? 30 : 7,
//                       mainAxisSpacing: isTab ? 20 : 15,
//                       childAspectRatio: isTab ? 1.9 : 01.20,
//                       shrinkWrap: true,
//
//                       physics: const NeverScrollableScrollPhysics(),
//                       // عشان المكون يكون جزء من ScrollView تانية
//                       children: con.iconsApp.map((item) {
//                         return BlocBuilder<CentralizedCubit, CentralizedState>(
//                           builder: (context, state) {
//                             return InkWell(
//                               onTap: () {
//                                 // NotificationService().showInstantNotification(
//                                 //   '🌅 أذكار الصباح',
//                                 //   'بسم الله الذي لا يضر مع اسمه شيء',
//                                 // );
//                                 bool needsInternet =
//                                     item["navigate"] == Routes.categoriesRoute || item["navigate"] == "/QuranRadioView" ;
//
//                                         // ||
//                                         // item["navigate"] == "/qiblaDirection";
//
//                                 (state is ConnectivityState &&
//                                     state.status ==
//                                         ConnectivityStatus
//                                             .disconnected) ==
//                                     true &&
//                                     needsInternet
//                                     ? Fluttertoast.showToast(
//                                     msg: "يرجي التحقق من اتصالك بالانترنت")
//                                     : Navigator.pushNamed(
//                                     context, item['navigate']!);
//                               },
//                               // child: Card(
//                               //   shape: RoundedRectangleBorder(
//                               //     borderRadius: BorderRadius.circular(10),
//                               //     side: const BorderSide(
//                               //         color: Colors.grey, width: 1),
//                               //   ),
//                               //   child: SizedBox(
//                               //     width: 90,
//                               //     height: 80,
//                               //     child: Padding(
//                               //       padding: const EdgeInsets.all(8.0),
//                               //       child: Column(
//                               //         mainAxisAlignment:
//                               //             MainAxisAlignment.spaceBetween,
//                               //         children: [
//                               //           Image.asset(
//                               //             item["icon"]!,
//                               //             width:
//                               //                 MediaQuery.sizeOf(context).width >
//                               //                         600
//                               //                     ? 90
//                               //                     : 40,
//                               //             height:
//                               //                 MediaQuery.sizeOf(context).width >
//                               //                         600
//                               //                     ? 75
//                               //                     : 40,
//                               //             fit: BoxFit.contain,
//                               //           ),
//                               //           const SizedBox(height: 8),
//                               //           // Text(
//                               //           //   item["title"]!,
//                               //           //   style: GoogleFonts.cairo(
//                               //           //       color: Colors.black,
//                               //           //       fontWeight: FontWeight.bold,
//                               //           //       fontSize: 9.sp),
//                               //           // ),
//                               //           TextDefaultWidget(title:item["title"]! ,fontFamily: "me",fontSize: ResponsiveUtil.isTablet(context)? 10.sp : 11.5.sp,fontWeight: ResponsiveUtil.isTablet(context)?FontWeight.w500: FontWeight.bold,)
//                               //         ],
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               child: IslamicCardWidget(
//                                   title: item["title"]!, iconPath: item["icon"]!),
//                             );
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 )
//                 // : Wrap(
//                 //
//                 //     spacing: 50,
//                 //     runSpacing: 13,
//                 //     crossAxisAlignment: WrapCrossAlignment.center,
//                 //     alignment: WrapAlignment.center,
//                 //     children: iconsApp.map((item) {
//                 //       return InkWell(
//                 //         onTap: () {
//                 //           Navigator.pushNamed(context, item['navigate']!);
//                 //         },
//                 //         child: Card(
//                 //           shape: RoundedRectangleBorder(
//                 //             borderRadius: BorderRadius.circular(10),
//                 //             side: const BorderSide(
//                 //                 color: Colors.grey, width: 1),
//                 //           ),
//                 //           child: Padding(
//                 //             padding: const EdgeInsets.symmetric(
//                 //                 horizontal: 5.0, vertical: 12.0),
//                 //             child: SizedBox(
//                 //               width: 120,
//                 //               height: 80,
//                 //               child: Column(
//                 //                 mainAxisAlignment:
//                 //                     MainAxisAlignment.spaceBetween,
//                 //                 children: [
//                 //                   Image.asset(
//                 //                     item["icon"]!,
//                 //                     width: 40,
//                 //                     height: 40,
//                 //                     fit: BoxFit.contain,
//                 //                   ),
//                 //                   const SizedBox(height: 8),
//                 //                   Text(
//                 //                     item["title"]!,
//                 //                     style: GoogleFonts.cairo(
//                 //                         color: Colors.black,
//                 //                         fontWeight: FontWeight.bold,
//                 //                         fontSize: 13),
//                 //                   ),
//                 //                 ],
//                 //               ),
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       );
//                 //     }).toList(),
//                 //   ),
//                 ,
//                 SizedBox(
//                     height: MediaQuery.sizeOf(context).width > 600 ? 25 : 20),
//                 const AzkarQuranWidget(),
//                 const SizedBox(height: 10),
//                 const OtherAzkarWidget(),
//                 // const SizedBox(height: 10),
//                 //
//                 // Container(
//                 //   padding: const EdgeInsets.all(10),
//                 //   decoration: BoxDecoration(
//                 //     borderRadius: BorderRadius.circular(10),
//                 //     border: const BorderDirectional(
//                 //       start: BorderSide(color: Color(0xffd6bb7a), width: 3),
//                 //     ),
//                 //     color: Theme.of(context).cardColor,
//                 //   ),
//                 //   width: MediaQuery.sizeOf(context).width,
//                 //   child: Padding(
//                 //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                 //     child: Column(
//                 //       crossAxisAlignment: CrossAxisAlignment.start,
//                 //       children: [
//                 //         Text(
//                 //           "وردك اليومي",
//                 //           style: GoogleFonts.cairo(
//                 //               fontWeight: FontWeight.bold, fontSize:MediaQuery.sizeOf(context).width >600?10.sp:  15.sp),
//                 //         ),
//                 //         const SizedBox(height: 10),
//                 //         verseName==null?   Text(
//                 //           "لايوجد",
//                 //           textAlign: TextAlign.justify,
//                 //           style: TextStyle(fontSize: MediaQuery.sizeOf(context).width >600?25: 16),
//                 //         ):  Text(
//                 //           "وِرْدُكَ الأَخِيرُ كَانَ فِي سُورَةِ $verseName",
//                 //           textAlign: TextAlign.justify,
//                 //           style: TextStyle(fontSize: MediaQuery.sizeOf(context).width >600?25: 16),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class PrayerHeaderSection extends StatelessWidget {
//   final String hijriDate;
//   final String location;
//   final String gregorian;
//   final String nextPrayer;
//   final String remainingTime;
//   final VoidCallback onSettingsTap;
//   final double? progressValue;
//   const PrayerHeaderSection({
//     super.key,
//     required this.hijriDate,
//     required this.gregorian,
//     required this.nextPrayer,
//     required this.remainingTime,
//     required this.onSettingsTap, required this.location, this.progressValue,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isTab = ResponsiveUtil.isTablet(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     final size = MediaQuery.sizeOf(context);
//     final double headerHeight =
//     isTab ? size.height / 3.2 : size.height / 3.1;
//
//     return SizedBox(
//       height: headerHeight,
//       width: double.infinity,
//       child: Stack(
//         children: [
//           // الخلفية (الصورة)
//             Positioned.fill(
//             child: Image.asset(
//                "assets/images/8495460.jpg",
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // طبقة التدرّج فوق الصورة
//           // Positioned.fill(
//           //   child: Container(
//           //     decoration: BoxDecoration(
//           //       gradient: LinearGradient(
//           //         begin: Alignment.topCenter,
//           //         end: Alignment.bottomCenter,
//           //         colors: isDark
//           //             ? [
//           //           Colors.black.withOpacity(0.40),
//           //           Colors.black.withOpacity(0.85),
//           //         ]
//           //             : [
//           //           Colors.white.withOpacity(0.10),
//           //           Colors.white.withOpacity(0.20),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           Positioned.fill(
//             child: Container(
//               color: isDark
//                   ? Colors.black.withOpacity(0.55)  // تغميق قوي للصورة في الوضع الليلي
//                   : Colors.white.withOpacity(0.30), // تفتيح/بهتان بسيط في الوضع النهاري
//             ),
//           ),
//           // زر الإعدادات في أعلى اليسار
//           Positioned(
//              top: 35,
//               left: 10,
//             child: InkWell(
//               onTap: onSettingsTap,
//               borderRadius: BorderRadius.circular(30),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isDark
//                       ? Colors.white.withOpacity(0.08)
//                       : Colors.white.withOpacity(0.9),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.settings,
//                   size: isTab ? 26 : 22,
//                   color: isDark
//                       ? AppColors.greyLightColor
//                       : Colors.black87,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//              top: 35,
//               right: 10,
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isDark
//                         ? Colors.white.withOpacity(0.08)
//                         : Colors.white.withOpacity(0.9),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.location_on_rounded,
//                     size: isTab ? 26 : 22,
//                     color: isDark
//                           ? KColors.primaryColor
//                           : AppColors.primary,
//                   ),
//                 ),
//                 // Icon(
//                 //   Icons.location_on_rounded,
//                 //   size:isTab?25: 16,
//                 //   color: isDark
//                 //       ? KColors.primaryColor
//                 //       : AppColors.primary,
//                 // ),
//                 const SizedBox(width: 10),
//                 TextDefaultWidget(
//                   title: location,
//                   fontSize: isTab ? 8.sp : 11.sp,
//                   fontFamily: "cairo",
//                   fontWeight: FontWeight.bold,
//                   color: isDark
//                       ? AppColors.greyLightColor
//                       : Colors.white,
//                 ),
// ]
//             ),
//           ),
//           // التاريخ في أعلى اليمين (هجري + ميلادي)
//           // Padding(
//           //   padding: const EdgeInsets.only(top:45),
//           //   child: Align(
//           //     alignment: Alignment.topRight,
//           //     child: Column(
//           //       // crossAxisAlignment: CrossAxisAlignment.end,
//           //       children: [
//           //         Container(
//           //           padding:
//           //           const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           //           decoration: BoxDecoration(
//           //             borderRadius: BorderRadius.circular(20),
//           //             // color: isDark
//           //             //     ? Colors.black.withOpacity(0.5)
//           //             //     : Colors.white.withOpacity(0.95),
//           //             // border: Border.all(
//           //             //   color: const Color(0xFFD4AF37).withOpacity(0.7),
//           //             //   width: 1,
//           //             // ),
//           //           ),
//           //           child: Column(
//           //             children: [
//           //               Row(
//           //                 mainAxisSize: MainAxisSize.min,
//           //                 children: [
//           //                   Icon(
//           //                     Icons.calendar_today_rounded,
//           //                     size: 14,
//           //                     color: isDark
//           //                         ? AppColors.greyLightColor
//           //                         : const Color(0xFF1B5E20),
//           //                   ),
//           //                   const SizedBox(width: 6),
//           //                   TextDefaultWidget(
//           //                     title: hijriDate,
//           //                     fontSize: isTab ? 10.sp : 12.sp,
//           //                     fontFamily: "cairo",
//           //                     fontWeight: FontWeight.w600,
//           //                     color: isDark
//           //                         ? AppColors.greyLightColor
//           //                         : Colors.black,
//           //                   ),
//           //                 ],
//           //               ),
//           //               const SizedBox(height: 10),
//           //               TextDefaultWidget(
//           //                 title: gregorian,
//           //                 fontSize: isTab ? 9.sp : 11.sp,
//           //                 fontFamily: "cairo",
//           //                 color: isDark
//           //                     ? AppColors.greyLightColor.withOpacity(0.8)
//           //                     : Colors.black87.withOpacity(0.7),
//           //               ),
//           //
//           //             ],
//           //           ),
//           //         ),
//           //         Row(
//           //           mainAxisSize: MainAxisSize.min,
//           //
//           //           children: [
//           //             Icon(
//           //               Icons.location_on_rounded,
//           //               size:isTab?25: 16,
//           //               color: isDark
//           //                   ? AppColors.greyLightColor
//           //                   : const Color(0xFFd32f2f),
//           //             ),
//           //             const SizedBox(width: 4),
//           //             TextDefaultWidget(
//           //               title: location,
//           //               fontSize: isTab ? 9.sp : 11.sp,
//           //               fontFamily: "cairo",
//           //               fontWeight: FontWeight.w500,
//           //               color: isDark
//           //                   ? AppColors.greyLightColor
//           //                   : Colors.black87,
//           //             ),
//           //           ],
//           //         )
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           // كارت "الصلاة القادمة" في الأسفل
//
//           Padding(
//             padding:  EdgeInsets.only(top:isTab? 0:80),
//             child: Align(
//               alignment: Alignment.center,
//               child: Padding(
//                 padding:
//                  EdgeInsets.symmetric(horizontal:isTab?19: 16.0, vertical:12),
//                 child: Container(
//                   width: double.infinity,
//                   padding:
//                    EdgeInsets.symmetric(horizontal: 14, vertical: isTab? 18: 12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color: isDark
//                         ? Colors.black.withOpacity(0.45)
//                         : Colors.white.withOpacity(0.70),
//                     // border: Border.all(
//                     //   color: const Color(0xFFD4AF37).withOpacity(0.7),
//                     //   width: 1.2,
//                     // ),
//                   //   boxShadow: [
//                   //     BoxShadow(
//                   //       color: Colors.black.withOpacity(0.18),
//                   //       blurRadius: 10,
//                   //       offset: const Offset(0, 4),
//                   //     ),
//                   //   ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             padding:  EdgeInsets.all(isTab?10:6),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: isDark? Colors.black.withOpacity(0.6):Colors.white
//                                   .withOpacity( 1.00),
//                             ),
//                             child: Icon(
//                               Icons.calendar_month_outlined,
//                               size: isTab ? 22 : 18,
//                               color: isDark?KColors.primaryColor: const Color(0xFF1B5E20),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Icon(
//                           //   Icons.calendar_today_rounded,
//                           //   size: 14,
//                           //   color: isDark
//                           //       ? AppColors.greyLightColor
//                           //       : const Color(0xFF1B5E20),
//                           // ),
//                           // const SizedBox(width: 6),
//                           TextDefaultWidget(
//                             title: hijriDate,
//                             fontSize: isTab ? 8.sp : 12.sp,
//                             fontFamily: "cairo",
//                             fontWeight: FontWeight.w600,
//                             color: isDark
//                                 ? AppColors.greyLightColor
//                                 : Colors.black,
//                           ),
//                           Spacer(),
//                           TextDefaultWidget(
//                             title: gregorian,
//                             fontSize: isTab ? 8.sp : 12.sp,
//                             fontWeight: FontWeight.w600,
//
//                             fontFamily: "cairo",
//                             color: isDark
//                                 ? AppColors.greyLightColor.withOpacity(0.8)
//                                 : Colors.black87.withOpacity(0.7),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//
//                       // العنوان + اسم الصلاة
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding:  EdgeInsets.all(isTab?10:6),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: isDark? Colors.black.withOpacity(0.6):Colors.white
//                                       .withOpacity( 1.00),
//                                 ),
//                                 child: Icon(
//                                   Icons.mosque_outlined,
//                                   size: isTab ? 22 : 18,
//                                   color: isDark?KColors.primaryColor: const Color(0xFF1B5E20),
//                                 ),
//                               ),
//
//                               const SizedBox(width: 8),
//                               TextDefaultWidget(
//                                 title: "الصلاة القادمة",
//                                 fontFamily: "me",
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: isTab ? 11.sp : 15.sp,
//                                 color: isDark
//                                     ? AppColors.greyLightColor
//                                     : Colors.black87,
//                               ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               color:isDark? const Color(0xFF1B5E20)
//                                   .withOpacity(isDark ? 0.6 : 0.30):Colors.white.withOpacity(isDark ? 0.6 : 1.00),
//                             ),
//                             child: TextDefaultWidget(
//                               title: nextPrayer,
//                               fontFamily: "me",
//                               fontWeight: FontWeight.w600,
//                               fontSize: isTab ? 10.sp : 13.sp,
//                               color: isDark
//                                   ? AppColors.greyLightColor
//                                   : const Color(0xFF1B5E20),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // الوقت المتبقي + شريط بسيط (ديكور)
//                       Row(
//                         children: [
//                           Container(
//                             padding:  EdgeInsets.all(isTab?10:6),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: isDark? Colors.black.withOpacity(0.6):Colors.white
//                                   .withOpacity( 1.00),
//                             ),
//                             child: Icon(
//                               Icons.timer_outlined,
//                               size: isTab ? 22 : 18,
//                               color: isDark?KColors.primaryColor: const Color(0xFF1B5E20),
//                             ),
//                           ),
//
//                           const SizedBox(width: 8),
//                           TextDefaultWidget(
//                             title: "الوقت المتبقي",
//                             fontFamily: "cairo",
//                             fontSize: isTab ? 8.sp : 11.sp,
//                             fontWeight: FontWeight.w600,
//                             color: isDark
//                                 ? AppColors.greyLightColor.withOpacity(0.8)
//                                 : Colors.black,
//                           ),
//             Spacer(),
//                           TextDefaultWidget(
//                             title: remainingTime,
//                             fontFamily: "cairo",
//                             fontWeight: FontWeight.bold,
//                             fontSize: isTab ? 10.sp : 13.sp,
//                             color: isDark
//                                 ? AppColors.greyLightColor
//                                 : Colors.black87,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       // شريط ديكوري (مش progress حقيقي، بس يعطي إحساس)
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(999),
//                         child: LinearProgressIndicator(
//                           value: progressValue, // لو عندك نسبة حقيقية ممكن تمررها هنا
//                           minHeight:isTab?7: 4,
//                           backgroundColor: isDark
//                               ? Colors.white10
//                               : Colors.grey.shade200,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             const Color(0xFF1B5E20),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../main.dart';
import '../../Khatmah/data/khatmah_model.dart';
import 'AzkarQuranWidget.dart';
import 'OtherAzkarWidget.dart';
import '../controllar/MainController.dart';
import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';
import 'PrayerHeaderSection.dart';





class MainViewBuilder extends StatefulWidget {
  const MainViewBuilder({super.key});

  @override
  _MainViewBuilderState createState() => _MainViewBuilderState();
}

class _MainViewBuilderState extends StateMVC<MainViewBuilder> {
  _MainViewBuilderState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;
  late CentralizedCubit centralizedCubit;
  int? verseId;
  String? verseName;
  List<SurahModel>? surahModel;
  late final Box<KhatmahModel> box;
  late final Box plansBox;
  String? _locationText;

  // 👇 متغيرات للتحكم في السكرول
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    centralizedCubit = context.read<CentralizedCubit>();
    centralizedCubit.checkConnectivity();
    centralizedCubit.trackConnectivityChange();
    super.initState();
    loadSurahList();
    loadVerseName();
    loadSurahs();
    loadBookmark();
    box = Hive.box<KhatmahModel>('khatmahBox');
    plansBox = Hive.box('khatmahPlans');
    _loadSavedLocation();

    // 👇 استمع للسكرول
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // لما المستخدم يسكرول أكثر من 100 بكسل
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country');
    final city = prefs.getString('selected_city');

    setState(() {
      if (country != null && city != null) {
        _locationText = '$country - $city';
      } else {
        _locationText = 'لم يتم تحديد الموقع';
      }
    });
  }

  Future<void> _onLocationChanged() async {
    await con.refreshPrayerTimesFromPrefs();
    await _loadSavedLocation();
  }

  void loadBookmark() async {
    final id = await getBookmark();
    setState(() {});
  }

  Future<int?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_verseId');
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
    final loadedSurahs = await loadSurahList();
    setState(() {
      surahModel = loadedSurahs;
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

  @override
  Widget build(BuildContext context) {
    final completed = box.values.where((k) => k.isCompleted).toList();
    bool isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: Stack(
          children: [
            // المحتوى القابل للسكرول
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // الهيدر الكبير
                SliverToBoxAdapter(
                  child: PrayerHeaderSection(
                    progressValue: con.progressValue,
                    hijriDate: con.hijriDate,
                    gregorian: con.gregorian ?? "",
                    nextPrayer: con.nextPrayer,
                    remainingTime: con.remainingTimeText,
                    location: _locationText ?? 'لم يتم تحديد الموقع',
                    onSettingsTap: () => showThemeSheet(
                      context,
                      onLocationChanged: _onLocationChanged,
                    ),
                  ),
                ),

                // باقي المحتوى
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTab ? 10.w : 5.0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: isTab ? 30 : 7,
                          mainAxisSpacing: isTab ? 20 : 15,
                          childAspectRatio: isTab ? 1.9 : 01.20,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: con.iconsApp.map((item) {
                            return BlocBuilder<CentralizedCubit,
                                CentralizedState>(
                              builder: (context, state) {
                                return InkWell(
                                  onTap: () {
                                    bool needsInternet =
                                        item["navigate"] ==
                                            Routes.categoriesRoute ||
                                            item["navigate"] ==
                                                "/QuranRadioView";

                                    (state is ConnectivityState &&
                                        state.status ==
                                            ConnectivityStatus
                                                .disconnected) ==
                                        true &&
                                        needsInternet
                                        ? Fluttertoast.showToast(
                                        msg:
                                        "يرجي التحقق من اتصالك بالانترنت")
                                        : Navigator.pushNamed(
                                        context, item['navigate']!);
                                  },
                                  child: IslamicCardWidget(
                                      title: item["title"]!,
                                      iconPath: item["icon"]!),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).width > 600
                              ? 25
                              : 20),
                      const AzkarQuranWidget(),
                      const SizedBox(height: 10),
                      const OtherAzkarWidget(),
                    ],
                  ),
                ),
              ],
            ),

            // الهيدر الثابت المصغر (يظهر عند السكرول)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _isScrolled ? 0 : -150,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isScrolled ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 10,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1a1a2e).withOpacity(0.98),
                        const Color(0xFF16213e).withOpacity(0.95),
                      ],
                    )
                        : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.98),
                        const Color(0xFFFFFBF0).withOpacity(0.95),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? const Color(0xFFD4AF37).withOpacity(0.3)
                            : const Color(0xFFD4AF37).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : const Color(0xFFD4AF37).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.location_on_rounded,
                        //       size: 16,
                        //       color: isDark
                        //           ? const Color(0xFFD4AF37)
                        //           : const Color(0xFF1B5E20),
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Container(
                        //       constraints: const BoxConstraints(maxWidth: 80),
                        //       child: TextDefaultWidget(
                        //         title: _locationText?.split(' - ').last ??
                        //             'موقع',
                        //         fontSize: isTab ? 7.sp : 9.sp,
                        //         fontFamily: "cairo",
                        //         fontWeight: FontWeight.w600,
                        //         color: isDark
                        //             ? AppColors.greyLightColor
                        //             .withOpacity(0.8)
                        //             : const Color(0xFF2C3E50),
                        //         maxLines: 1,
                        //         // overflow: TextOverflow.ellipsis,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: isTab ? 26 : 22,
                              color: isDark ? KColors.whiteColor : AppColors.primary,
                            ),
                          ),
                          // Icon(
                          //   Icons.location_on_rounded,
                          //   size:isTab?25: 16,
                          //   color: isDark
                          //       ? KColors.primaryColor
                          //       : AppColors.primary,
                          // ),
                          const SizedBox(width: 10),
                          TextDefaultWidget(
                            title:  _locationText?.split(' - ').last ??
                                'موقع',
                            fontSize: isTab ? 8.sp : 11.sp,
                            fontFamily: "cairo",
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.greyLightColor : Colors.white,
                          ),
                        ]),
                        // زر الإعدادات
                        // InkWell(
                        //   onTap: () => showThemeSheet(
                        //     context,
                        //     onLocationChanged: _onLocationChanged,
                        //   ),
                        //   borderRadius: BorderRadius.circular(20),
                        //   child: Container(
                        //     padding: const EdgeInsets.all(8),
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       gradient: isDark
                        //           ? LinearGradient(
                        //         colors: [
                        //           const Color(0xFF1B5E20)
                        //               .withOpacity(0.6),
                        //           const Color(0xFF2E7D32)
                        //               .withOpacity(0.4),
                        //         ],
                        //       )
                        //           : LinearGradient(
                        //         colors: [
                        //           Colors.white,
                        //           const Color(0xFFFFFBF0),
                        //         ],
                        //       ),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: isDark
                        //               ? const Color(0xFFD4AF37)
                        //               .withOpacity(0.2)
                        //               : const Color(0xFF1B5E20)
                        //               .withOpacity(0.15),
                        //           blurRadius: 6,
                        //           offset: const Offset(0, 2),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Icon(
                        //       Icons.settings,
                        //       size: 20,
                        //       color: isDark
                        //           ? const Color(0xFFD4AF37)
                        //           : const Color(0xFF1B5E20),
                        //     ),
                        //   ),
                        // ),
                        InkWell(
                          onTap: () => showThemeSheet(
                            context,
                            onLocationChanged: _onLocationChanged,
                          ),                            borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.settings,
                              size: isTab ? 26 : 22,
                              color: isDark ? AppColors.greyLightColor : Colors.black87,
                            ),
                          ),
                        ),
                        // معلومات الصلاة القادمة
                        // Expanded(
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.symmetric(horizontal: 12),
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Container(
                        //               padding: const EdgeInsets.symmetric(
                        //                   horizontal: 12, vertical: 4),
                        //               decoration: BoxDecoration(
                        //                 borderRadius:
                        //                 BorderRadius.circular(15),
                        //                 gradient: isDark
                        //                     ? LinearGradient(
                        //                   colors: [
                        //                     const Color(0xFF1B5E20)
                        //                         .withOpacity(0.5),
                        //                     const Color(0xFF2E7D32)
                        //                         .withOpacity(0.3),
                        //                   ],
                        //                 )
                        //                     : LinearGradient(
                        //                   colors: [
                        //                     Colors.white,
                        //                     const Color(0xFFFFFBF0),
                        //                   ],
                        //                 ),
                        //                 border: Border.all(
                        //                   color: isDark
                        //                       ? const Color(0xFFD4AF37)
                        //                       .withOpacity(0.3)
                        //                       : const Color(0xFF1B5E20)
                        //                       .withOpacity(0.2),
                        //                   width: 1,
                        //                 ),
                        //               ),
                        //               child: TextDefaultWidget(
                        //                 title: con.nextPrayer,
                        //                 fontFamily: "me",
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: isTab ? 9.sp : 11.sp,
                        //                 color: isDark
                        //                     ? const Color(0xFFD4AF37)
                        //                     : const Color(0xFF1B5E20),
                        //               ),
                        //             ),
                        //             const SizedBox(width: 8),
                        //             Icon(
                        //               Icons.mosque_outlined,
                        //               size: 16,
                        //               color: isDark
                        //                   ? const Color(0xFFD4AF37)
                        //                   : const Color(0xFF1B5E20),
                        //             ),
                        //           ],
                        //         ),
                        //         const SizedBox(height: 4),
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Icon(
                        //               Icons.timer_outlined,
                        //               size: 14,
                        //               color: isDark
                        //                   ? AppColors.greyLightColor
                        //                   .withOpacity(0.7)
                        //                   : const Color(0xFF5D6D7E),
                        //             ),
                        //             const SizedBox(width: 4),
                        //             TextDefaultWidget(
                        //               title: con.remainingTimeText,
                        //               fontFamily: "cairo",
                        //               fontWeight: FontWeight.w600,
                        //               fontSize: isTab ? 7.sp : 9.sp,
                        //               color: isDark
                        //                   ? AppColors.greyLightColor
                        //                   .withOpacity(0.8)
                        //                   : const Color(0xFF5D6D7E),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        // الموقع
                      ],
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
}
