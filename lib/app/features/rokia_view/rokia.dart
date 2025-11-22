import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/k_helper.dart';
import '../../core/utils/style/responsive_util.dart';
import '../../core/widgets/AudioManager.dart';
// class RokiaScreen extends StatefulWidget {
//   const RokiaScreen({super.key});
//
//   @override
//   State<RokiaScreen> createState() => _RokiaScreenState();
// }
//
// class _RokiaScreenState extends State<RokiaScreen> {
//
//
//   // ================== إعدادات الصوت ==================
//   static const String _roqiaUrl = 'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/roqia.mp3';
//   static const String _roqiaKey = 'roqia_audio_path';
//   static const String _fileName = 'azkar_roqia.mp3';
//
//   final AudioManager _audioManager = AudioManager();
//
//   bool _isPlaying = false;
//   bool _isDownloading = false;
//   bool _isDownloaded = false;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAudio();
//   }
//
//   Future<void> _initAudio() async {
//     // تهيئة الـ AudioManager
//     _audioManager.initialize();
//
//     // استرجاع المسار لو تم تحميله من قبل
//     final savedPath = await _audioManager.getSavedAudioPath(_roqiaKey);
//     if (savedPath != null) {
//       _isDownloaded = true;
//     }
//
//     // متابعة التحديثات
//     _audioManager.positionStream.listen((pos) {
//       if (!mounted) return;
//       setState(() => _position = pos);
//     });
//
//     _audioManager.durationStream.listen((dur) {
//       if (!mounted) return;
//       setState(() => _duration = dur ?? Duration.zero);
//     });
//
//     _audioManager.playerStateStream.listen((state) {
//       if (!mounted) return;
//       setState(() => _isPlaying = _audioManager.isPlaying);
//     });
//   }
//
//   void _showSnack(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textDirection: ui.TextDirection.rtl,
//         ),
//       ),
//     );
//   }
//
//   // تشغيل / إيقاف
//   Future<void> _playOrPause() async {
//     try {
//       await _audioManager.playOrPause(
//         url: _roqiaUrl,
//         localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
//         sharedPrefsKey: _roqiaKey,
//       );
//     } catch (e) {
//       _showSnack('حدث خطأ أثناء تشغيل الصوت.');
//     }
//   }
//
//   // تحميل الملف
//   Future<void> _downloadAudio() async {
//     if (_isDownloading) return;
//
//     final hasNet = await _audioManager.hasConnection();
//     if (!hasNet) {
//       _showSnack('لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
//       return;
//     }
//
//     setState(() => _isDownloading = true);
//
//     try {
//       await _audioManager.downloadAudio(
//         url: _roqiaUrl,
//         fileName: _fileName,
//         sharedPrefsKey: _roqiaKey,
//       );
//
//       setState(() => _isDownloaded = true);
//       _showSnack('تم تحميل أذكار الصباح، يمكن تشغيلها بدون إنترنت.');
//     } catch (e) {
//       _showSnack(e.toString());
//     } finally {
//       if (mounted) {
//         setState(() => _isDownloading = false);
//       }
//     }
//   }
//
//   // باقي الكود يبقى كما هو مع تعديل المراجع
//   String _formatDuration(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     final m = two(d.inMinutes.remainder(60));
//     final s = two(d.inSeconds.remainder(60));
//     return '$m:$s';
//   }
//
//   @override
//   void dispose() {
//     // لا نقوم بـ dispose للـ AudioManager لأنه Singleton
//     // وسيتم استخدامه في أماكن أخرى
//     super.dispose();
//   }
//   Widget _buildBottomPlayer(bool isDark) {
//     final primaryColor =
//     isDark ? const Color(AppStyle.primaryColor) : Colors.green;
//
//     final double sliderMax = _duration.inMilliseconds > 0
//         ? _duration.inMilliseconds.toDouble()
//         : 1.0;
//
//     final double sliderValue = _duration.inMilliseconds > 0
//         ? _position.inMilliseconds
//         .clamp(0, _duration.inMilliseconds)
//         .toDouble()   // clamp يرجّع num، فبنحوّله لـ double
//         : 0.0;
//
//
//     final modeText = _isDownloaded
//         ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
//         : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';
//
//     return SafeArea(
//       top: false,
//       bottom: false,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isDark
//                     ? [
//                   Colors.black87,
//                   Colors.black54,
//                 ]
//                     : [
//                   const Color(0xFFe9f5ec),
//                   const Color(0xFFffffff),
//                 ],
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.12),
//                   blurRadius: 10,
//                   offset: const Offset(0, -3),
//                 )
//               ],
//               border: Border(
//                 top: BorderSide(
//                   color: primaryColor.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // الصف الرئيسي: زر التشغيل + العنوان + الحالة
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
//                   child: Row(
//                     children: [
//                       // const SizedBox(width: 10),
//                       Directionality(
//                         textDirection: ui.TextDirection.rtl,
//                         child: Text(
//                           'مشاري العفاسي',
//                           style: GoogleFonts.notoKufiArabic(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: primaryColor,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//
//                       const SizedBox(width: 6),
//                       if (_isDownloaded)
//                         const Icon(
//                           Icons.offline_pin_rounded,
//                           color: Colors.green,
//                           size: 22,
//                         ),
//                       Spacer(),
//                       Directionality(
//                         textDirection: ui.TextDirection.rtl,
//                         child: Text(
//                           'أذكار النوم',
//                           style: GoogleFonts.notoKufiArabic(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: primaryColor,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//                 Directionality(
//                   textDirection: ui.TextDirection.rtl,
//                   child: Text(
//                     modeText,
//                     style: GoogleFonts.aboreto(
//                       fontSize: ResponsiveUtil.isTablet(context)? 13:15,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//                 // السلايدر + التوقيت
//
//                 Row(
//                   children: [
//                     Text(
//                       _formatDuration(_duration),
//                       style: GoogleFonts.cairo(fontSize: 10),
//                     ),
//
//                     Expanded(
//                       child: SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           trackHeight: 3,
//                           thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 7,
//                           ),
//                         ),
//                         child: Slider(
//                           value: sliderValue,
//                           min: 0,
//                           max: sliderMax,
//                           onChanged: _duration.inMilliseconds == 0
//                               ? null
//                               : (v) async {
//                             final newPos = Duration(milliseconds: v.toInt());
//                             await _audioManager.seek(newPos);
//                           },
//                           activeColor: primaryColor,
//                           inactiveColor: primaryColor.withOpacity(0.25),
//                         ),
//                       ),
//                     ),
//                     Text(
//                       _formatDuration(_position),
//                       style: GoogleFonts.cairo(fontSize: 10),
//                     ),
//
//                     const SizedBox(width: 4),
//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.end,
//                     //   children: [
//                     //     Text(
//                     //       _formatDuration(_position),
//                     //       style: GoogleFonts.cairo(fontSize: 10),
//                     //     ),
//                     //     Text(
//                     //       _formatDuration(_duration),
//                     //       style: GoogleFonts.cairo(fontSize: 10),
//                     //     ),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 // زر التحميل
//                 Align(
//                   alignment: Alignment.center,
//                   child: Directionality(
//                     textDirection: ui.TextDirection.rtl,
//                     child: _isDownloaded
//                         ? TextButton.icon(
//                       onPressed: null,
//                       icon: const Icon(
//                         Icons.download_done_rounded,
//                         size: 18,
//                         color: Colors.green,
//                       ),
//                       label: Text(
//                         'تم تحميل الأذكار، تعمل بدون إنترنت',
//                         style: GoogleFonts.notoKufiArabic(
//                           fontSize: 12,
//                           color: Colors.green,
//                         ),
//                       ),
//                     )
//                         : TextButton.icon(
//                       onPressed: _isDownloading ? null : _downloadAudio,
//                       icon: _isDownloading
//                           ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                         ),
//                       )
//                           : Icon(
//                         Icons.download_rounded,
//                         size: 19,
//                         color: primaryColor,
//                       ),
//                       label: Text(
//                         _isDownloading
//                             ? 'جاري تحميل أذكار الصباح...'
//                             : 'تحميل للتشغيل بدون إنترنت',
//                         style: GoogleFonts.aboreto(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: -30,right: ResponsiveUtil.isTablet(context)?370: 150,
//             child:
//             GestureDetector(
//               onTap: _playOrPause,
//               child: Container(
//                 width: 54,
//                 height: 54,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       KColors.primary,
//                       KColors.primaryColor,
//                     ],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: primaryColor.withOpacity(0.4),
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//             ),
//
//           ),
//
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final con = Provider.of<AzkarProvider>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     // نقرأ حجم الخط المحفوظ من الكيوبت
//     final double fontSize = CentralizedCubit.get(context).azkarFontSize();
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(
//           MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
//         ),
//         child: AppBar(
//           leading: CupertinoNavigationBarBackButton(
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           centerTitle: true,
//           // actions: [
//           //   IconButton(
//           //     icon: const Icon(Icons.settings),
//           //     onPressed: () => showThemeSheet(context),
//           //     tooltip: 'الإعدادات',
//           //   ),
//           // ],
//           title: Text(
//             AppString.KRokia,
//             style: GoogleFonts.cairo(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
//             ),
//           ),
//         ),
//       ),
//       body: Azkary.rokiaQuranRepe.isEmpty
//           ? Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(child: Image.asset(doneZakar)),
//               SizedBox(height: 10.h),
//               Text(
//                 AppString.KRokiaDaialogText,
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15.sp,
//                 ),
//               ),
//               SizedBox(height: 15.h),
//               Text(
//                 AppString.KRokiaFeaturesTitle,
//                 style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18.sp,
//                 ),
//               ),
//               SizedBox(height: 10.h),
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
//                     fontFamily: AppStyle.fontFamily,
//                     height: 1.8.h,
//                     fontSize: 17.5.sp,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//           : Column(
//         children: [
//           Padding(padding: EdgeInsets.symmetric(vertical: 8.0.w)),
//           Expanded(
//             child: ListView.separated(
//               shrinkWrap: true,
//               physics: const BouncingScrollPhysics(),
//               itemBuilder: (context, quranCurrentIndex) {
//                 return ScrollAppearAnimation(
//                   duration: const Duration(milliseconds: 700),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         con.decrementQuran(quranCurrentIndex);
//                       });
//                     },
//                     child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: AzkerItemBuilder(
//                         azkarTitle:
//                         Azkary.rokiaQuranTitle[quranCurrentIndex],
//                         azkarDes:
//                         Azkary.rokiaQuranRawi[quranCurrentIndex],
//                         fontSize: fontSize, // ← الحجم المحفوظ من الكيوبت
//                         azkarRepate: con.quranIndex >=
//                             Azkary.rokiaQuranRepe[quranCurrentIndex]
//                             ? '0'
//                             : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
//                         color: con.quranIndex >=
//                             Azkary.rokiaQuranRepe[quranCurrentIndex]
//                             ? const Color(AppStyle.yellowColor)
//                             : isDark
//                             ? Colors.black
//                             : const Color(AppStyle.whiteColor),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) => SizedBox(height: 15.h),
//               itemCount: Azkary.rokiaQuranTitle.length,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class RokiaScreen extends StatefulWidget {
  const RokiaScreen({super.key});

  @override
  State<RokiaScreen> createState() => _RokiaScreenState();
}

class _RokiaScreenState extends State<RokiaScreen> {
  // ================== إعدادات الصوت ==================
  static const String _roqiaUrl =
      'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/roqia.mp3';
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
    _audioManager.initialize();

    final savedPath = await _audioManager.getSavedAudioPath(_roqiaKey);
    if (savedPath != null) {
      _isDownloaded = true;
    }

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

      // لو بتستخدم just_audio
      final processingState = state.processingState;
      final bufferingNow = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;

      setState(() {
        _isPlaying = state.playing; // أو _audioManager.isPlaying
        _isBuffering = bufferingNow;
      });
    });

    // _audioManager.playerStateStream.listen((state) {
    //   if (!mounted) return;
    //   setState(() => _isPlaying = _audioManager.isPlaying);
    // });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textDirection: ui.TextDirection.rtl)),
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
      KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
    }
  }

  // تحميل الملف
  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    final hasNet = await _audioManager.hasConnection();
    if (!hasNet) {
      KHelper.showError(
          message: 'لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
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
      KHelper.showSuccess(
          message: 'تم تحميل الرقية الشرعية، يمكن تشغيلها بدون إنترنت.');
    } catch (e) {
      KHelper.showError(message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  void dispose() {
    // AudioManager Singleton فلا نعمل dispose
    super.dispose();
  }

  // ================== الـ Bottom Player ==================

  // Widget _buildBottomPlayer(bool isDark) {
  //   final theme = Theme.of(context);
  //   final primaryColor =
  //   isDark ? KColors.primaryColor : theme.colorScheme.primary;
  //
  //   final int durationMs = _duration.inMilliseconds;
  //   final int positionMs = _position.inMilliseconds;
  //
  //   final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;
  //
  //   final double sliderValue = durationMs > 0
  //       ? positionMs.clamp(0, durationMs).toDouble()
  //       : 0.0;
  //
  //   final modeText = _isDownloaded
  //       ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
  //       : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';
  //
  //   final bool isPlayingNow = _isPlaying;
  //   final String stateText = isPlayingNow
  //       ? 'جاري تشغيل الرقية الآن'
  //       : 'اضغط على زر التشغيل لسماع الرقية الشرعية';
  //
  //   final IconData stateIcon =
  //   isPlayingNow ? Icons.graphic_eq_rounded : Icons.headphones_rounded;
  //
  //   final Color stateBg = isDark
  //       ? (isPlayingNow
  //       ? Colors.greenAccent.withOpacity(0.15)
  //       : Colors.white.withOpacity(0.06))
  //       : (isPlayingNow
  //       ? Colors.green.withOpacity(0.10)
  //       : primaryColor.withOpacity(0.08));
  //
  //   final Color stateFg = isDark
  //       ? (isPlayingNow ? Colors.greenAccent : Colors.white70)
  //       : (isPlayingNow ? Colors.green.shade700 : Colors.black87);
  //
  //   return SafeArea(
  //     top: false,
  //     child: Stack(
  //       clipBehavior: Clip.none,
  //       children: [
  //         Container(
  //           margin: const EdgeInsets.only(top: 30),
  //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //           decoration: BoxDecoration(
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(22),
  //               topRight: Radius.circular(22),
  //             ),
  //             gradient: LinearGradient(
  //               begin: Alignment.topRight,
  //               end: Alignment.bottomLeft,
  //               colors: isDark
  //                   ? const [
  //                 Color(0xFF020617),
  //                 Color(0xFF0F172A),
  //               ]
  //                   : [
  //                 primaryColor.withOpacity(0.06),
  //                 const Color(0xFFFFFFFF),
  //               ],
  //             ),
  //             border: Border.all(
  //               color: primaryColor.withOpacity(isDark ? 0.5 : 0.25),
  //               width: 1,
  //             ),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: primaryColor.withOpacity(isDark ? 0.45 : 0.18),
  //                 blurRadius: 16,
  //                 spreadRadius: 0.5,
  //                 offset: const Offset(0, -4),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // handle
  //               Container(
  //                 width: 32,
  //                 height: 3,
  //                 margin: const EdgeInsets.only(bottom: 8),
  //                 decoration: BoxDecoration(
  //                   color:
  //                   isDark ? Colors.white24 : Colors.black.withOpacity(0.15),
  //                   borderRadius: BorderRadius.circular(999),
  //                 ),
  //               ),
  //
  //               // الاسم + العنوان + حالة التحميل
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 4,
  //                   vertical: 4,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Directionality(
  //                       textDirection: ui.TextDirection.rtl,
  //                       child: Text(
  //                         'مشاري العفاسي',
  //                         style: GoogleFonts.notoKufiArabic(
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w700,
  //                           color: isDark
  //                               ? Colors.white
  //                               : primaryColor.withOpacity(0.9),
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 6),
  //                     if (_isDownloaded)
  //                       const Icon(
  //                         Icons.offline_pin_rounded,
  //                         color: Colors.green,
  //                         size: 20,
  //                       ),
  //                     const Spacer(),
  //                     Directionality(
  //                       textDirection: ui.TextDirection.rtl,
  //                       child: Text(
  //                         'الرقية الشرعية',
  //                         style: GoogleFonts.notoKufiArabic(
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w700,
  //                           color: isDark ? Colors.white70 : Colors.black87,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 4),
  //
  //               // شارة الحالة
  //               AnimatedSwitcher(
  //                 duration: const Duration(milliseconds: 220),
  //                 transitionBuilder: (child, anim) =>
  //                     FadeTransition(opacity: anim, child: child),
  //                 child: Container(
  //                   key: ValueKey<bool>(isPlayingNow),
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 10,
  //                     vertical: 6,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: stateBg,
  //                     borderRadius: BorderRadius.circular(999),
  //                   ),
  //                   child: Directionality(
  //                     textDirection: ui.TextDirection.rtl,
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(
  //                           stateIcon,
  //                           size: 16,
  //                           color: stateFg,
  //                         ),
  //                         const SizedBox(width: 5),
  //                         Text(
  //                           stateText,
  //                           style: GoogleFonts.cairo(
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w600,
  //                             color: stateFg,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 6),
  //
  //               // نص وضع التشغيل
  //               Directionality(
  //                 textDirection: ui.TextDirection.rtl,
  //                 child: Text(
  //                   modeText,
  //                   style: GoogleFonts.cairo(
  //                     fontSize: ResponsiveUtil.isTablet(context) ? 12 : 13,
  //                     fontWeight: FontWeight.w400,
  //                     color: isDark ? Colors.grey[300] : Colors.grey[700],
  //                   ),
  //                   maxLines: 2,
  //                   textAlign: TextAlign.center,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 6),
  //
  //               // السلايدر + التوقيت + +/- 10 ثواني
  //               Row(
  //                 children: [
  //                   IconButton(
  //                     onPressed: durationMs == 0
  //                         ? null
  //                         : () async {
  //                       final int newMs =
  //                       (positionMs - 10000).clamp(0, durationMs);
  //                       await _audioManager.seek(
  //                         Duration(milliseconds: newMs),
  //                       );
  //                     },
  //                     icon: const Icon(Icons.replay_10_rounded),
  //                     iconSize: 20,
  //                     color: isDark
  //                         ? Colors.white70
  //                         : primaryColor.withOpacity(0.9),
  //                     visualDensity: VisualDensity.compact,
  //                   ),
  //                   Text(
  //                     _formatDuration(_position),
  //                     style: GoogleFonts.cairo(
  //                       fontSize: 10,
  //                       color: isDark ? Colors.white70 : Colors.black54,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: SliderTheme(
  //                       data: SliderTheme.of(context).copyWith(
  //                         trackHeight: 3,
  //                         thumbShape: const RoundSliderThumbShape(
  //                           enabledThumbRadius: 7,
  //                         ),
  //                       ),
  //                       child: Slider(
  //                         value: sliderValue,
  //                         min: 0,
  //                         max: sliderMax,
  //                         onChanged: durationMs == 0
  //                             ? null
  //                             : (v) async {
  //                           final newPos = Duration(
  //                             milliseconds: v.toInt(),
  //                           );
  //                           await _audioManager.seek(newPos);
  //                         },
  //                         activeColor: primaryColor,
  //                         inactiveColor: primaryColor.withOpacity(0.25),
  //                       ),
  //                     ),
  //                   ),
  //                   Text(
  //                     _formatDuration(_duration),
  //                     style: GoogleFonts.cairo(
  //                       fontSize: 10,
  //                       color: isDark ? Colors.white70 : Colors.black54,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: durationMs == 0
  //                         ? null
  //                         : () async {
  //                       final int newMs =
  //                       (positionMs + 10000).clamp(0, durationMs);
  //                       await _audioManager.seek(
  //                         Duration(milliseconds: newMs),
  //                       );
  //                     },
  //                     icon: const Icon(Icons.forward_10_rounded),
  //                     iconSize: 20,
  //                     color: isDark
  //                         ? Colors.white70
  //                         : primaryColor.withOpacity(0.9),
  //                     visualDensity: VisualDensity.compact,
  //                   ),
  //                 ],
  //               ),
  //
  //               const SizedBox(height: 6),
  //
  //               // زر التحميل
  //               Align(
  //                 alignment: Alignment.center,
  //                 child: Directionality(
  //                   textDirection: ui.TextDirection.rtl,
  //                   child: _isDownloaded
  //                       ? TextButton.icon(
  //                     onPressed: null,
  //                     style: TextButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 6,
  //                       ),
  //                       backgroundColor: isDark
  //                           ? Colors.white.withOpacity(0.05)
  //                           : Colors.green.withOpacity(0.08),
  //                       shape: const StadiumBorder(),
  //                     ),
  //                     icon: const Icon(
  //                       Icons.download_done_rounded,
  //                       size: 18,
  //                       color: Colors.green,
  //                     ),
  //                     label: Text(
  //                       'تم تحميل الرقية، تعمل بدون إنترنت',
  //                       style: GoogleFonts.notoKufiArabic(
  //                         fontSize: 12,
  //                         color: isDark
  //                             ? Colors.greenAccent
  //                             : Colors.green.shade700,
  //                       ),
  //                     ),
  //                   )
  //                       : TextButton.icon(
  //                     onPressed:
  //                     _isDownloading ? null : _downloadAudio,
  //                     style: TextButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 6,
  //                       ),
  //                       backgroundColor: isDark
  //                           ? Colors.white.withOpacity(0.06)
  //                           : primaryColor.withOpacity(0.08),
  //                       shape: const StadiumBorder(),
  //                     ),
  //                     icon: _isDownloading
  //                         ? const SizedBox(
  //                       width: 16,
  //                       height: 16,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                       ),
  //                     )
  //                         : Icon(
  //                       Icons.download_rounded,
  //                       size: 19,
  //                       color: isDark
  //                           ? Colors.greenAccent
  //                           : primaryColor,
  //                     ),
  //                     label: Text(
  //                       _isDownloading
  //                           ? 'جاري تحميل الرقية...'
  //                           : 'تحميل للتشغيل بدون إنترنت',
  //                       style: GoogleFonts.cairo(
  //                         fontSize: 13,
  //                         fontWeight: FontWeight.w600,
  //                         color: isDark
  //                             ? Colors.white
  //                             : Colors.grey[900],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         // زر التشغيل العائم
  //         Positioned(
  //           top: -4,
  //           left: 0,
  //           right: 0,
  //           child: Center(
  //             child: GestureDetector(
  //               onTap: () {
  //                 if (!_isDownloaded && _isBuffering) return;
  //                 HapticFeedback.lightImpact();
  //                 _playOrPause();
  //               },
  //
  //               child: AnimatedContainer(
  //                 duration: const Duration(milliseconds: 220),
  //                 width: 70,
  //                 height: 70,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       primaryColor,
  //                       primaryColor.withOpacity(0.85),
  //                     ],
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: primaryColor
  //                           .withOpacity(isPlayingNow ? 0.55 : 0.35),
  //                       blurRadius: isPlayingNow ? 20 : 12,
  //                       spreadRadius: isPlayingNow ? 1.8 : 0.6,
  //                       offset: const Offset(0, 4),
  //                     ),
  //                   ],
  //                 ),
  //                 child: AnimatedSwitcher(
  //                   duration: const Duration(milliseconds: 200),
  //                   transitionBuilder: (child, anim) =>
  //                       ScaleTransition(scale: anim, child: child),
  //                   child: (!_isDownloaded && _isBuffering)
  //                       ? const SizedBox(
  //                     key: ValueKey('loader'),
  //                     width: 26,
  //                     height: 26,
  //                     child: CircularProgressIndicator(
  //                       strokeWidth: 3,
  //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                     ),
  //                   )
  //                       : Icon(
  //                     isPlayingNow
  //                         ? Icons.pause_rounded
  //                         : Icons.play_arrow_rounded,
  //                     key: ValueKey<bool>(isPlayingNow),
  //                     color: Colors.white,
  //                     size: 32,
  //                   ),
  //                 ),
  //
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildBottomPlayer(bool isDark) {
    bool isTab =ResponsiveUtil.isTablet(context);
    final theme = Theme.of(context);
    final primaryColor =
    isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final int durationMs = _duration.inMilliseconds;
    final int positionMs = _position.inMilliseconds;

    final double sliderMax =
    durationMs > 0 ? durationMs.toDouble() : 1.0;

    final double sliderValue = durationMs > 0
        ? positionMs.clamp(0, durationMs).toDouble()
        : 0.0;

    final modeText = _isDownloaded
        ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
        : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';

    // حالة تشجيع المستخدم
    final bool isPlayingNow = _isPlaying;
    final String stateText = isPlayingNow
        ? 'جاري تشغيل الرقية الشرعية الآن'
        : 'اضغط على زر التشغيل لسماع الرقية الشرعية';

    final IconData stateIcon =
    isPlayingNow ? Icons.graphic_eq_rounded : Icons.headphones_rounded;

    final Color stateBg = isDark
        ? (isPlayingNow
        ? Colors.greenAccent.withOpacity(0.15)
        : Colors.white.withOpacity(0.06))
        : (isPlayingNow
        ? Colors.green.withOpacity(0.10)
        : primaryColor.withOpacity(0.08));

    final Color stateFg = isDark
        ? (isPlayingNow ? Colors.greenAccent : Colors.white70)
        : (isPlayingNow ? Colors.green.shade700 : Colors.black87);

    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // جسم المشغل
          Container(
            margin:  EdgeInsets.only(top:isTab? 30:0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? const [
                  Color(0xFF020617),
                  Color(0xFF0F172A),
                ]
                    : [
                  primaryColor.withOpacity(0.06),
                  const Color(0xFFFFFFFF),
                ],
              ),
              border: Border.all(
                color: primaryColor.withOpacity(isDark ? 0.5 : 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(isDark ? 0.45 : 0.18),
                  blurRadius: 16,
                  spreadRadius: 0.5,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الـ handle الصغير في الأعلى
                Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white24
                        : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                // الصف الرئيسي: اسم القارئ + عنوان الأذكار + حالة التحميل
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          'مشاري العفاسي',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : primaryColor.withOpacity(0.9),
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
                          size: 20,
                        ),
                      const Spacer(),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          'الرقية الشرعية',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // شارة الحالة "يعمل الآن / اضغط تشغيل"
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Container(
                    key: ValueKey<bool>(isPlayingNow),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stateBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stateIcon,
                            size: 16,
                            color: stateFg,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            stateText,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stateFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // نص وضع التشغيل (أونلاين / أوفلاين)
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    modeText,
                    style: GoogleFonts.cairo(
                      fontSize: ResponsiveUtil.isTablet(context) ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 6),

                // السلايدر + التوقيت + أزرار ١٠ ثواني
                Row(
                  children: [
                    IconButton(
                      onPressed: durationMs == 0
                          ? null
                          : () async {
                        final int newMs =
                        (positionMs - 10000).clamp(0, durationMs);
                        await _audioManager.seek(
                          Duration(milliseconds: newMs),
                        );
                      },
                      icon: const Icon(Icons.replay_10_rounded),
                      iconSize: 20,
                      color: isDark
                          ? Colors.white70
                          : primaryColor.withOpacity(0.9),
                      visualDensity: VisualDensity.compact,
                    ),

                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
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
                          onChanged: durationMs == 0
                              ? null
                              : (v) async {
                            final newPos = Duration(
                              milliseconds: v.toInt(),
                            );
                            await _audioManager.seek(newPos);
                          },
                          activeColor: primaryColor,
                          inactiveColor: primaryColor.withOpacity(0.25),
                        ),
                      ),
                    ),

                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),

                    IconButton(
                      onPressed: durationMs == 0
                          ? null
                          : () async {
                        final int newMs =
                        (positionMs + 10000).clamp(0, durationMs);
                        await _audioManager.seek(
                          Duration(milliseconds: newMs),
                        );
                      },
                      icon: const Icon(Icons.forward_10_rounded),
                      iconSize: 20,
                      color: isDark
                          ? Colors.white70
                          : primaryColor.withOpacity(0.9),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // زر التحميل / تم التحميل
                Align(
                  alignment: Alignment.center,
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: _isDownloaded
                        ? TextButton.icon(
                      onPressed: null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.green.withOpacity(0.08),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(
                        Icons.download_done_rounded,
                        size: 18,
                        color: Colors.green,
                      ),
                      label: Text(
                        'تم تحميل الرقية الشرعية، تعمل بدون إنترنت',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 12,
                          color: isDark
                              ? Colors.greenAccent
                              : Colors.green.shade700,
                        ),
                      ),
                    )
                        : TextButton.icon(
                      onPressed: _isDownloading ? null : _downloadAudio,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.06)
                            : primaryColor.withOpacity(0.08),
                        shape: const StadiumBorder(),
                      ),
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
                        color: isDark
                            ? Colors.greenAccent
                            : primaryColor,
                      ),
                      label: Text(
                        _isDownloading
                            ? 'جاري تحميل الرقية الشرعية...'
                            : 'تحميل للتشغيل بدون إنترنت',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                          isDark ? Colors.white : Colors.grey[900],
                        ),
                      ),
                    ),
                  ),
                ),

                // const SizedBox(height: 4),
                //
                // // زر فتح المشغّل الكامل
                // TextButton.icon(
                //   onPressed: () => _openFullPlayer(isDark),
                //   icon: const Icon(
                //     Icons.open_in_full_rounded,
                //     size: 18,
                //   ),
                //   label: Text(
                //     'عرض المشغّل الكامل',
                //     style: GoogleFonts.cairo(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                //   style: TextButton.styleFrom(
                //     foregroundColor:
                //     isDark ? Colors.white70 : primaryColor,
                //     visualDensity: VisualDensity.compact,
                //   ),
                // ),
              ],
            ),
          ),

          // زر التشغيل العائم في المنتصف
          Positioned(
            top: isTab?-4:-20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _playOrPause();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: isPlayingNow ? isTab?70:50 : isTab?70:50,
                  height: isPlayingNow ? isTab?70:50 : isTab?70:50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor
                            .withOpacity(isPlayingNow ? 0.55 : 0.35),
                        blurRadius: isPlayingNow ? 20 : 12,
                        spreadRadius: isPlayingNow ? 1.8 : 0.6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: (!_isDownloaded && _isBuffering)
                        ? const SizedBox(
                      key: ValueKey('loader'),
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(
                      isPlayingNow
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey<bool>(isPlayingNow),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== واجهة الشاشة الأساسية ==================
  bool _isBuffering = false;

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // نقرأ حجم الخط المحفوظ من الكيوبت
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    // منطق الانتهاء من كل آيات الرقية
    final bool allDone = con.isQuranDone;

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
          title: Text(
            AppString.KRokia,
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: allDone
      // شاشة "تم الانتهاء من الرقية"
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
                    height: 1.8,
                    fontSize: 17.5.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // الأزرار: إعادة / إنهاء
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // إعادة عدادات الرقية من البداية
                      con.resetQuran();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      'إعادة الرقية من البداية',
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      'إنهاء',
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
      // قائمة آيات/أذكار الرقية
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.w),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 50.h),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, quranCurrentIndex) {
                // الآية/المقطع خلص لما عدّاده <= 0
                final bool isDone =
                    Azkary.rokiaQuranRepe[quranCurrentIndex] <= 0;

                final Color cardColor = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDark
                    ? Colors.black
                    : const Color(AppStyle.whiteColor));

                return ScrollAppearAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: () {
                      // إنقاص العداد لهذا المقطع
                      con.decrementQuran(quranCurrentIndex);
                    },
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: AzkerItemBuilder(
                        azkarTitle:
                        Azkary.rokiaQuranTitle[quranCurrentIndex],
                        azkarDes:
                        Azkary.rokiaQuranRawi[quranCurrentIndex],
                        fontSize: fontSize,
                        azkarRepate: isDone
                            ? '0'
                            : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
                        color: cardColor,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(height: 15.h),
              itemCount: Azkary.rokiaQuranTitle.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomPlayer(isDark),
    );
  }
}

// class RokiaScreen extends StatefulWidget {
//   const RokiaScreen({super.key});
//
//   @override
//   State<RokiaScreen> createState() => _RokiaScreenState();
// }
//
// class _RokiaScreenState extends State<RokiaScreen> {
//   // ================== إعدادات الصوت ==================
//   static const String _roqiaUrl =
//       'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/roqia.mp3';
//   static const String _roqiaKey = 'roqia_audio_path';
//   static const String _fileName = 'azkar_roqia.mp3';
//
//   final AudioManager _audioManager = AudioManager();
//
//   bool _isPlaying = false;
//   bool _isDownloading = false;
//   bool _isDownloaded = false;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAudio();
//   }
//
//   Future<void> _initAudio() async {
//     _audioManager.initialize();
//
//     final savedPath = await _audioManager.getSavedAudioPath(_roqiaKey);
//     if (savedPath != null) {
//       _isDownloaded = true;
//     }
//
//     _audioManager.positionStream.listen((pos) {
//       if (!mounted) return;
//       setState(() => _position = pos);
//     });
//
//     _audioManager.durationStream.listen((dur) {
//       if (!mounted) return;
//       setState(() => _duration = dur ?? Duration.zero);
//     });
//
//     _audioManager.playerStateStream.listen((state) {
//       if (!mounted) return;
//       setState(() => _isPlaying = _audioManager.isPlaying);
//     });
//   }
//
//   void _showSnack(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message, textDirection: ui.TextDirection.rtl)),
//     );
//   }
//
//   // تشغيل / إيقاف
//   Future<void> _playOrPause() async {
//     try {
//       await _audioManager.playOrPause(
//         url: _roqiaUrl,
//         localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
//         sharedPrefsKey: _roqiaKey,
//       );
//     } catch (e) {
//       // بدّل على نفس أسلوب AzkarMassa
//       // _showSnack('حدث خطأ أثناء تشغيل الصوت.');
//       KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
//     }
//   }
//
//   // تحميل الملف
//   Future<void> _downloadAudio() async {
//     if (_isDownloading) return;
//
//     final hasNet = await _audioManager.hasConnection();
//     if (!hasNet) {
//       // _showSnack('لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
//       KHelper.showError(
//           message: 'لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
//       return;
//     }
//
//     setState(() => _isDownloading = true);
//
//     try {
//       await _audioManager.downloadAudio(
//         url: _roqiaUrl,
//         fileName: _fileName,
//         sharedPrefsKey: _roqiaKey,
//       );
//
//       setState(() => _isDownloaded = true);
//       // _showSnack('تم تحميل الرقية، يمكن تشغيلها بدون إنترنت.');
//       KHelper.showSuccess(
//           message: 'تم تحميل الرقية الشرعية، يمكن تشغيلها بدون إنترنت.');
//     } catch (e) {
//       // _showSnack(e.toString());
//       KHelper.showError(message: e.toString());
//     } finally {
//       if (mounted) {
//         setState(() => _isDownloading = false);
//       }
//     }
//   }
//
//   String _formatDuration(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     final m = two(d.inMinutes.remainder(60));
//     final s = two(d.inSeconds.remainder(60));
//     return '$m:$s';
//   }
//
//   @override
//   void dispose() {
//     // AudioManager Singleton فلا نعمل dispose
//     super.dispose();
//   }
//
//   // ================== الـ Bottom Player (نفس روح AzkarMassa) ==================
//
//   Widget _buildBottomPlayer(bool isDark) {
//     final theme = Theme.of(context);
//     final primaryColor =
//     isDark ? KColors.primaryColor : theme.colorScheme.primary;
//
//     final int durationMs = _duration.inMilliseconds;
//     final int positionMs = _position.inMilliseconds;
//
//     final double sliderMax =
//     durationMs > 0 ? durationMs.toDouble() : 1.0;
//
//     final double sliderValue = durationMs > 0
//         ? positionMs.clamp(0, durationMs).toDouble()
//         : 0.0;
//
//     final modeText = _isDownloaded
//         ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
//         : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';
//
//     final bool isPlayingNow = _isPlaying;
//     final String stateText = isPlayingNow
//         ? 'جاري تشغيل الرقية الآن'
//         : 'اضغط على زر التشغيل لسماع الرقية الشرعية';
//
//     final IconData stateIcon =
//     isPlayingNow ? Icons.graphic_eq_rounded : Icons.headphones_rounded;
//
//     final Color stateBg = isDark
//         ? (isPlayingNow
//         ? Colors.greenAccent.withOpacity(0.15)
//         : Colors.white.withOpacity(0.06))
//         : (isPlayingNow
//         ? Colors.green.withOpacity(0.10)
//         : primaryColor.withOpacity(0.08));
//
//     final Color stateFg = isDark
//         ? (isPlayingNow ? Colors.greenAccent : Colors.white70)
//         : (isPlayingNow ? Colors.green.shade700 : Colors.black87);
//
//     return SafeArea(
//       top: false,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 30),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(22),
//                 topRight: Radius.circular(22),
//               ),
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: isDark
//                     ? const [
//                   Color(0xFF020617),
//                   Color(0xFF0F172A),
//                 ]
//                     : [
//                   primaryColor.withOpacity(0.06),
//                   const Color(0xFFFFFFFF),
//                 ],
//               ),
//               border: Border.all(
//                 color: primaryColor.withOpacity(isDark ? 0.5 : 0.25),
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(isDark ? 0.45 : 0.18),
//                   blurRadius: 16,
//                   spreadRadius: 0.5,
//                   offset: const Offset(0, -4),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // handle
//                 Container(
//                   width: 32,
//                   height: 3,
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? Colors.white24
//                         : Colors.black.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                 ),
//
//                 // الاسم + العنوان + حالة التحميل
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 4,
//                   ),
//                   child: Row(
//                     children: [
//                       Directionality(
//                         textDirection: ui.TextDirection.rtl,
//                         child: Text(
//                           'مشاري العفاسي',
//                           style: GoogleFonts.notoKufiArabic(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: isDark
//                                 ? Colors.white
//                                 : primaryColor.withOpacity(0.9),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       if (_isDownloaded)
//                         const Icon(
//                           Icons.offline_pin_rounded,
//                           color: Colors.green,
//                           size: 20,
//                         ),
//                       const Spacer(),
//                       Directionality(
//                         textDirection: ui.TextDirection.rtl,
//                         child: Text(
//                           'الرقية الشرعية',
//                           style: GoogleFonts.notoKufiArabic(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: isDark ? Colors.white70 : Colors.black87,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 4),
//
//                 // شارة الحالة
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 220),
//                   transitionBuilder: (child, anim) =>
//                       FadeTransition(opacity: anim, child: child),
//                   child: Container(
//                     key: ValueKey<bool>(isPlayingNow),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: stateBg,
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                     child: Directionality(
//                       textDirection: ui.TextDirection.rtl,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             stateIcon,
//                             size: 16,
//                             color: stateFg,
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             stateText,
//                             style: GoogleFonts.cairo(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: stateFg,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 // نص وضع التشغيل
//                 Directionality(
//                   textDirection: ui.TextDirection.rtl,
//                   child: Text(
//                     modeText,
//                     style: GoogleFonts.cairo(
//                       fontSize: ResponsiveUtil.isTablet(context) ? 12 : 13,
//                       fontWeight: FontWeight.w400,
//                       color: isDark ? Colors.grey[300] : Colors.grey[700],
//                     ),
//                     maxLines: 2,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 // السلايدر + التوقيت + +/- 10 ثواني
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: durationMs == 0
//                           ? null
//                           : () async {
//                         final int newMs =
//                         (positionMs - 10000).clamp(0, durationMs);
//                         await _audioManager.seek(
//                           Duration(milliseconds: newMs),
//                         );
//                       },
//                       icon: const Icon(Icons.replay_10_rounded),
//                       iconSize: 20,
//                       color: isDark
//                           ? Colors.white70
//                           : primaryColor.withOpacity(0.9),
//                       visualDensity: VisualDensity.compact,
//                     ),
//                     Text(
//                       _formatDuration(_position),
//                       style: GoogleFonts.cairo(
//                         fontSize: 10,
//                         color: isDark ? Colors.white70 : Colors.black54,
//                       ),
//                     ),
//                     Expanded(
//                       child: SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           trackHeight: 3,
//                           thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 7,
//                           ),
//                         ),
//                         child: Slider(
//                           value: sliderValue,
//                           min: 0,
//                           max: sliderMax,
//                           onChanged: durationMs == 0
//                               ? null
//                               : (v) async {
//                             final newPos = Duration(
//                               milliseconds: v.toInt(),
//                             );
//                             await _audioManager.seek(newPos);
//                           },
//                           activeColor: primaryColor,
//                           inactiveColor: primaryColor.withOpacity(0.25),
//                         ),
//                       ),
//                     ),
//                     Text(
//                       _formatDuration(_duration),
//                       style: GoogleFonts.cairo(
//                         fontSize: 10,
//                         color: isDark ? Colors.white70 : Colors.black54,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: durationMs == 0
//                           ? null
//                           : () async {
//                         final int newMs =
//                         (positionMs + 10000).clamp(0, durationMs);
//                         await _audioManager.seek(
//                           Duration(milliseconds: newMs),
//                         );
//                       },
//                       icon: const Icon(Icons.forward_10_rounded),
//                       iconSize: 20,
//                       color: isDark
//                           ? Colors.white70
//                           : primaryColor.withOpacity(0.9),
//                       visualDensity: VisualDensity.compact,
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 // زر التحميل
//                 Align(
//                   alignment: Alignment.center,
//                   child: Directionality(
//                     textDirection: ui.TextDirection.rtl,
//                     child: _isDownloaded
//                         ? TextButton.icon(
//                       onPressed: null,
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 6,
//                         ),
//                         backgroundColor: isDark
//                             ? Colors.white.withOpacity(0.05)
//                             : Colors.green.withOpacity(0.08),
//                         shape: const StadiumBorder(),
//                       ),
//                       icon: const Icon(
//                         Icons.download_done_rounded,
//                         size: 18,
//                         color: Colors.green,
//                       ),
//                       label: Text(
//                         'تم تحميل الرقية، تعمل بدون إنترنت',
//                         style: GoogleFonts.notoKufiArabic(
//                           fontSize: 12,
//                           color: isDark
//                               ? Colors.greenAccent
//                               : Colors.green.shade700,
//                         ),
//                       ),
//                     )
//                         : TextButton.icon(
//                       onPressed:
//                       _isDownloading ? null : _downloadAudio,
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 6,
//                         ),
//                         backgroundColor: isDark
//                             ? Colors.white.withOpacity(0.06)
//                             : primaryColor.withOpacity(0.08),
//                         shape: const StadiumBorder(),
//                       ),
//                       icon: _isDownloading
//                           ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                         ),
//                       )
//                           : Icon(
//                         Icons.download_rounded,
//                         size: 19,
//                         color: isDark
//                             ? Colors.greenAccent
//                             : primaryColor,
//                       ),
//                       label: Text(
//                         _isDownloading
//                             ? 'جاري تحميل الرقية...'
//                             : 'تحميل للتشغيل بدون إنترنت',
//                         style: GoogleFonts.cairo(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: isDark
//                               ? Colors.white
//                               : Colors.grey[900],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // زر التشغيل العائم
//           Positioned(
//             top: -4,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: GestureDetector(
//                 onTap: () {
//                   HapticFeedback.lightImpact();
//                   _playOrPause();
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   width: 70,
//                   height: 70,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         primaryColor,
//                         primaryColor.withOpacity(0.85),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor
//                             .withOpacity(isPlayingNow ? 0.55 : 0.35),
//                         blurRadius: isPlayingNow ? 20 : 12,
//                         spreadRadius: isPlayingNow ? 1.8 : 0.6,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 200),
//                       transitionBuilder: (child, anim) =>
//                           ScaleTransition(scale: anim, child: child),
//                       child: Icon(
//                         isPlayingNow
//                             ? Icons.pause_rounded
//                             : Icons.play_arrow_rounded,
//                         key: ValueKey<bool>(isPlayingNow),
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================== واجهة الشاشة الأساسية ==================
//
//   @override
//   Widget build(BuildContext context) {
//     final con = Provider.of<AzkarProvider>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     // نقرأ حجم الخط المحفوظ من الكيوبت
//     final double fontSize = CentralizedCubit.get(context).azkarFontSize();
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(
//           MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
//         ),
//         child: AppBar(
//           leading: CupertinoNavigationBarBackButton(
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           centerTitle: true,
//           title: Text(
//             AppString.KRokia,
//             style: GoogleFonts.cairo(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize:
//               MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
//             ),
//           ),
//         ),
//       ),
//       body: Azkary.rokiaQuranRepe.isEmpty
//           ? Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(child: Image.asset(doneZakar)),
//               SizedBox(height: 10.h),
//               Text(
//                 AppString.KRokiaDaialogText,
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15.sp,
//                 ),
//               ),
//               SizedBox(height: 15.h),
//               Text(
//                 AppString.KRokiaFeaturesTitle,
//                 style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18.sp,
//                 ),
//               ),
//               SizedBox(height: 10.h),
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
//                     fontFamily: AppStyle.fontFamily,
//                     height: 1.8,
//                     fontSize: 17.5.sp,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//           : Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 8.0.w),
//           ),
//           Expanded(
//             child: ListView.separated(
//               padding: EdgeInsets.only(bottom: 50.h),
//               shrinkWrap: true,
//               physics: const BouncingScrollPhysics(),
//               itemBuilder: (context, quranCurrentIndex) {
//                 return ScrollAppearAnimation(
//                   duration: const Duration(milliseconds: 700),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         con.decrementQuran(quranCurrentIndex);
//                       });
//                     },
//                     child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: AzkerItemBuilder(
//                         azkarTitle:
//                         Azkary.rokiaQuranTitle[quranCurrentIndex],
//                         azkarDes:
//                         Azkary.rokiaQuranRawi[quranCurrentIndex],
//                         fontSize: fontSize,
//                         azkarRepate: con.quranIndex >=
//                             Azkary.rokiaQuranRepe[
//                             quranCurrentIndex]
//                             ? '0'
//                             : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
//                         color: con.quranIndex >=
//                             Azkary.rokiaQuranRepe[
//                             quranCurrentIndex]
//                             ? const Color(AppStyle.yellowColor)
//                             : isDark
//                             ? Colors.black
//                             : const Color(AppStyle.whiteColor),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) =>
//                   SizedBox(height: 15.h),
//               itemCount: Azkary.rokiaQuranTitle.length,
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomPlayer(isDark),
//     );
//   }
// }



