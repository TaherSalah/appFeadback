import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/responsive_util.dart';
import '../../core/widgets/AudioManager.dart';
class RokiaScreen extends StatefulWidget {
  const RokiaScreen({super.key});

  @override
  State<RokiaScreen> createState() => _RokiaScreenState();
}

class _RokiaScreenState extends State<RokiaScreen> {


  // ================== إعدادات الصوت ==================
  static const String _roqiaUrl = 'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/roqia.mp3';
  static const String _roqiaKey = 'roqia_audio_path';
  static const String _fileName = 'azkar_roqia.mp3';

  final AudioManager _audioManager = AudioManager();

  bool _isPlaying = false;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    // تهيئة الـ AudioManager
    _audioManager.initialize();

    // استرجاع المسار لو تم تحميله من قبل
    final savedPath = await _audioManager.getSavedAudioPath(_roqiaKey);
    if (savedPath != null) {
      _isDownloaded = true;
    }

    // متابعة التحديثات
    _audioManager.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    _audioManager.durationStream.listen((dur) {
      if (!mounted) return;
      setState(() => _duration = dur ?? Duration.zero);
    });

    _audioManager.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = _audioManager.isPlaying);
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: ui.TextDirection.rtl,
        ),
      ),
    );
  }

  // تشغيل / إيقاف
  Future<void> _playOrPause() async {
    try {
      await _audioManager.playOrPause(
        url: _roqiaUrl,
        localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
        sharedPrefsKey: _roqiaKey,
      );
    } catch (e) {
      _showSnack('حدث خطأ أثناء تشغيل الصوت.');
    }
  }

  // تحميل الملف
  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    final hasNet = await _audioManager.hasConnection();
    if (!hasNet) {
      _showSnack('لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      await _audioManager.downloadAudio(
        url: _roqiaUrl,
        fileName: _fileName,
        sharedPrefsKey: _roqiaKey,
      );

      setState(() => _isDownloaded = true);
      _showSnack('تم تحميل أذكار الصباح، يمكن تشغيلها بدون إنترنت.');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // باقي الكود يبقى كما هو مع تعديل المراجع
  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  void dispose() {
    // لا نقوم بـ dispose للـ AudioManager لأنه Singleton
    // وسيتم استخدامه في أماكن أخرى
    super.dispose();
  }
  Widget _buildBottomPlayer(bool isDark) {
    final primaryColor =
    isDark ? const Color(AppStyle.primaryColor) : Colors.green;

    final double sliderMax = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds.toDouble()
        : 1.0;

    final double sliderValue = _duration.inMilliseconds > 0
        ? _position.inMilliseconds
        .clamp(0, _duration.inMilliseconds)
        .toDouble()   // clamp يرجّع num، فبنحوّله لـ double
        : 0.0;


    final modeText = _isDownloaded
        ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
        : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';

    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                  Colors.black87,
                  Colors.black54,
                ]
                    : [
                  const Color(0xFFe9f5ec),
                  const Color(0xFFffffff),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
              border: Border(
                top: BorderSide(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الصف الرئيسي: زر التشغيل + العنوان + الحالة

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Row(
                    children: [
                      // const SizedBox(width: 10),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          'مشاري العفاسي',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 6),
                      if (_isDownloaded)
                        const Icon(
                          Icons.offline_pin_rounded,
                          color: Colors.green,
                          size: 22,
                        ),
                      Spacer(),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          'أذكار النوم',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    ],
                  ),
                ),
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    modeText,
                    style: GoogleFonts.aboreto(
                      fontSize: ResponsiveUtil.isTablet(context)? 13:15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 6),
                // السلايدر + التوقيت

                Row(
                  children: [
                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),

                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0,
                          max: sliderMax,
                          onChanged: _duration.inMilliseconds == 0
                              ? null
                              : (v) async {
                            final newPos = Duration(milliseconds: v.toInt());
                            await _audioManager.seek(newPos);
                          },
                          activeColor: primaryColor,
                          inactiveColor: primaryColor.withOpacity(0.25),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),

                    const SizedBox(width: 4),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       _formatDuration(_position),
                    //       style: GoogleFonts.cairo(fontSize: 10),
                    //     ),
                    //     Text(
                    //       _formatDuration(_duration),
                    //       style: GoogleFonts.cairo(fontSize: 10),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 4),
                // زر التحميل
                Align(
                  alignment: Alignment.center,
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: _isDownloaded
                        ? TextButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.download_done_rounded,
                        size: 18,
                        color: Colors.green,
                      ),
                      label: Text(
                        'تم تحميل الأذكار، تعمل بدون إنترنت',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    )
                        : TextButton.icon(
                      onPressed: _isDownloading ? null : _downloadAudio,
                      icon: _isDownloading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(
                        Icons.download_rounded,
                        size: 19,
                        color: primaryColor,
                      ),
                      label: Text(
                        _isDownloading
                            ? 'جاري تحميل أذكار الصباح...'
                            : 'تحميل للتشغيل بدون إنترنت',
                        style: GoogleFonts.aboreto(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -30,right: ResponsiveUtil.isTablet(context)?370: 150,
            child:
            GestureDetector(
              onTap: _playOrPause,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      KColors.primary,
                      KColors.primaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

          ),

        ],
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // نقرأ حجم الخط المحفوظ من الكيوبت
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.settings),
          //     onPressed: () => showThemeSheet(context),
          //     tooltip: 'الإعدادات',
          //   ),
          // ],
          title: Text(
            AppString.KRokia,
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: Azkary.rokiaQuranRepe.isEmpty
          ? Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset(doneZakar)),
              SizedBox(height: 10.h),
              Text(
                AppString.KRokiaDaialogText,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                AppString.KRokiaFeaturesTitle,
                style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 10.h),
              const Divider(
                color: Color(AppStyle.primaryColor),
                thickness: 2,
                indent: 150,
                endIndent: 150,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  AppString.KZakarRokiaFeaturesDes,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: AppStyle.fontFamily,
                    height: 1.8.h,
                    fontSize: 17.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0.w)),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, quranCurrentIndex) {
                return ScrollAppearAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        con.decrementQuran(quranCurrentIndex);
                      });
                    },
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: AzkerItemBuilder(
                        azkarTitle:
                        Azkary.rokiaQuranTitle[quranCurrentIndex],
                        azkarDes:
                        Azkary.rokiaQuranRawi[quranCurrentIndex],
                        fontSize: fontSize, // ← الحجم المحفوظ من الكيوبت
                        azkarRepate: con.quranIndex >=
                            Azkary.rokiaQuranRepe[quranCurrentIndex]
                            ? '0'
                            : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
                        color: con.quranIndex >=
                            Azkary.rokiaQuranRepe[quranCurrentIndex]
                            ? const Color(AppStyle.yellowColor)
                            : isDark
                            ? Colors.black
                            : const Color(AppStyle.whiteColor),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 15.h),
              itemCount: Azkary.rokiaQuranTitle.length,
            ),
          ),
        ],
      ),
    );
  }
}



// class RokiaScreen extends StatefulWidget {
//   const RokiaScreen({super.key});
//   @override
//   State<RokiaScreen> createState() => _RokiaScreenState();
// }
//
// class _RokiaScreenState extends State<RokiaScreen> {
//   var selectedFontSize;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedFontSize = "20";
//   }
//   List<String> sizes = <String>[
//     "10",
//     "20",
//     "30",
//     "40",
//     "50",
//     "60",
//     "70",
//     "80",
//     "90",
//     "100",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final con = Provider.of<AzkarProvider>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
//         child: AppBar(
//           leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
//               ? Colors.white
//               : Colors.black,),
//           centerTitle: true,
//           actions: [
//             Directionality(
//               textDirection: ui.TextDirection.rtl,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
//
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 85,
//                       child: AnimatedWrapper(
//                         type: UiAnimationType.slideRight,
//                         duration: const Duration(seconds: 1),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: const TextDefaultWidget(
//                               textAlign: TextAlign.right,
//                               title: "حجم الخط",
//                               fontSize: 15,
//                               color: Color(0xff1A1A1A),
//                             ),
//                             items: sizes.map((e) {
//                               return DropdownMenuItem(
//                                   value: e,
//                                   child: TextDefaultWidget(
//                                     textAlign: TextAlign.right,
//                                     title: e,
//                                     fontSize: 12.5,
//                                     color: isDark? Colors.white:Colors.black,
//                                   ));
//                             }).toList(),
//                             value: selectedFontSize,
//                             onChanged: (value) {
//                               selectedFontSize = value;
//                               setState(() {});
//                             },
//                             buttonStyleData: ButtonStyleData(
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: AppStyle.scondColors, width: 1.5),
//                                   color: Theme.of(context).cardColor,
//                                   borderRadius: BorderRadius.circular(10.0)),
//                               padding:
//                               const EdgeInsets.symmetric(horizontal: 16),
//                               height: 50,
//                               width: MediaQuery.of(context).size.width / 1.2,
//                             ),
//                             menuItemStyleData: MenuItemStyleData(
//                               overlayColor: MaterialStateProperty.all(
//                                 Colors.grey.withOpacity(0.5),
//                               ), // Use MaterialStateProperty
//                               height: 50,
//                             ),
//                             dropdownStyleData: DropdownStyleData(
//                               elevation: 1,
//                               decoration: BoxDecoration(
//                                 color:isDark? Theme.of(context).cardColor :  Color(0xfffaedcd),
//
//                                 // Set the background color for the dropdown menu
//                                 borderRadius: BorderRadius.circular(
//                                     10.0), // Optional: rounded corners
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//           title: Text(
//             AppString.KRokia,
//             style: GoogleFonts.cairo(
//                 color: Colors.green,
//                 fontWeight: FontWeight.bold,
//                 fontSize:
//                 MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
//           ),
//         ),
//       ),
//       // backgroundColor: Azkary.azkarMassaRepate.isEmpty? Colors.white :        AppStyle.bgColors,
//       body: Azkary.rokiaQuranRepe.isEmpty? Center(
//         child:  SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(
//                   child: Image.asset(
//                     doneZakar,
//                   )),
//               SizedBox(
//                 height: 10.h,
//               ),
//               Text(
//                 AppString.KRokiaDaialogText,
//                 style: GoogleFonts.cairo(
//                     fontWeight: FontWeight.bold, fontSize: 15.sp),
//               ),
//               SizedBox(
//                 height: 15.h,
//               ),
//               Text(
//                 AppString.KRokiaFeaturesTitle,
//                 style: GoogleFonts.cairo(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18.sp),
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               const Divider(
//                 color: Color(AppStyle.primaryColor),
//                 thickness: 2,
//                 indent: 150,
//                 endIndent: 150,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Text(
//                   AppString.KZakarRokiaFeaturesDes,
//                   textAlign: TextAlign.justify,
//                   style: TextStyle(
//                       fontFamily: AppStyle.fontFamily,
//                       height: 1.8.h,
//                       fontSize: 17.5.sp),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ) :  Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 8.0.w),
//           ),
//           Expanded(
//             child: ListView.separated(
//                 shrinkWrap: true,
//                 physics: const BouncingScrollPhysics(),
//                 itemBuilder: (context, quranCurrentIndex) {
//                   return ScrollAppearAnimation(
//                     duration: const Duration(milliseconds: 700),
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           con.decrementQuran(quranCurrentIndex);
//                         });
//                       },
//                       child: Directionality(
//                         textDirection: TextDirection.rtl,
//                         child: AzkerItemBuilder(
//                           azkarTitle: Azkary.rokiaQuranTitle[quranCurrentIndex],
//                           azkarDes: Azkary.rokiaQuranRawi[quranCurrentIndex],
//                           fontSize: double.parse(selectedFontSize),
//                           azkarRepate: con.quranIndex >=
//                                   Azkary.rokiaQuranRepe[quranCurrentIndex]
//                               ? '0'
//                               : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
//                           color: con.quranIndex >=
//                                   Azkary.rokiaQuranRepe[quranCurrentIndex]
//                               ? const Color(AppStyle.yellowColor)
//                               : isDark?Colors.black: Color(AppStyle.whiteColor),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) => SizedBox(
//                       height: 15.h,
//                     ),
//                 itemCount: Azkary.rokiaQuranTitle.length),
//           )
//         ],
//       ),
//     );
//   }
// }
