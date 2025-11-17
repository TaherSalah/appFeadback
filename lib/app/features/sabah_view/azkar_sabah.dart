import 'dart:ui' as ui;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';



import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// imports الخاصة بمشروعك
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// imports الخاصة بمشروعك
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';

class AzkarSabah extends StatefulWidget {
  const AzkarSabah({super.key});

  @override
  State<AzkarSabah> createState() => _AzkarSabahState();
}

class _AzkarSabahState extends State<AzkarSabah> {
  // ================== إعدادات الصوت ==================
  static const String _sabahUrl =
      'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/sabah.mp3';
  static const String _sabahKey = 'sabah_audio_path';

  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _localPath;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    // استرجاع المسار لو تم تحميله من قبل
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_sabahKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      _localPath = savedPath;
      _isDownloaded = true;
    }

    // متابعة تقدّم التشغيل
    _positionSub = _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    // مدة الملف
    _durationSub = _player.durationStream.listen((dur) {
      if (!mounted) return;
      setState(() => _duration = dur ?? Duration.zero);
    });

    // حالة المشغّل
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing = state.playing;
      final processingState = state.processingState;

      setState(() {
        _isPlaying = playing && processingState != ProcessingState.completed;
      });

      if (processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  Future<bool> _hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
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

  // تشغيل / إيقاف مع شرط الإنترنت والأوفلاين
  Future<void> _playOrPause() async {
    // لو شغّال → إيقاف مؤقت
    if (_isPlaying) {
      await _player.pause();
      return;
    }

    try {
      // لو متحمّل → شغّل من الجهاز (أوفلاين)
      if (_isDownloaded &&
          _localPath != null &&
          File(_localPath!).existsSync()) {
        await _player.setFilePath(_localPath!);
      } else {
        // غير متحمّل → لازم إنترنت
        final hasNet = await _hasConnection();
        if (!hasNet) {
          _showSnack(
              'لا يوجد اتصال بالإنترنت.\nقم بتحميل أذكار الصباح للتشغيل بدون إنترنت.');
          return;
        }
        await _player.setUrl(_sabahUrl);
      }

      await _player.play();
    } catch (e) {
      _showSnack('حدث خطأ أثناء تشغيل الصوت.');
    }
  }

  // تحميل الملف للتشغيل أوفلاين
  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    final hasNet = await _hasConnection();
    if (!hasNet) {
      _showSnack('لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final uri = Uri.parse(_sabahUrl);
      final response =
      await http.get(uri).timeout(const Duration(seconds: 40));

      if (response.statusCode != 200) {
        _showSnack('فشل تحميل الملف الصوتي (كود ${response.statusCode}).');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/azkar_sabah.mp3');
      await file.writeAsBytes(response.bodyBytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sabahKey, file.path);

      setState(() {
        _localPath = file.path;
        _isDownloaded = true;
      });

      _showSnack('تم تحميل أذكار الصباح، يمكن تشغيلها بدون إنترنت.');
    } on TimeoutException {
      _showSnack('انتهت مهلة الاتصال أثناء التحميل، حاول مرة أخرى.');
    } catch (e) {
      _showSnack('حدث خطأ أثناء تحميل الصوت، حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
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

                Row(
                  children: [
                    // const SizedBox(width: 10),
                    Expanded(
                      child: Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أذكار الصباح',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // const SizedBox(height: 3),
                            // Text(
                            //   modeText,
                            //   style: GoogleFonts.cairo(
                            //     fontSize: 11,
                            //     color: isDark
                            //         ? Colors.grey[300]
                            //         : Colors.grey[700],
                            //   ),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_isDownloaded)
                      const Icon(
                        Icons.offline_pin_rounded,
                        color: Colors.green,
                        size: 22,
                      ),
                  ],
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
                            await _player.seek(newPos);
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
                        style: GoogleFonts.cairo(
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
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -30,right: 150,
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
                      primaryColor,
                      primaryColor.withOpacity(0.8),
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
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            AppString.Ksabah,
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      // جسم الصفحة كما كان (النصوص)
      body: Azkary.azkarSabahRepate.isEmpty
          ? Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset(doneZakar)),
              SizedBox(height: 10.h),
              Text(
                AppString.KSabahDaialogText,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                AppString.KZakarSabahFeaturesTitle,
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
                  AppString.doneText,
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.w),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 50),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, zSabahIndex) {
                return ScrollAppearAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: () {
                      con.decrementSabah(zSabahIndex);
                    },
                    child: AzkerItemBuilder(
                      azkarTitle: Azkary.azkarSabah[zSabahIndex],
                      azkarDes: Azkary.azkarSabahDes[zSabahIndex],
                      fontSize: fontSize,
                      azkarRepate: con.zSabahIndex >=
                          Azkary.azkarSabahRepate[zSabahIndex]
                          ? '0'
                          : '${Azkary.azkarSabahRepate[zSabahIndex]}',
                      color: con.zSabahIndex >=
                          Azkary.azkarSabahRepate[zSabahIndex]
                          ? const Color(AppStyle.yellowColor)
                          : isDark
                          ? Colors.black
                          : const Color(AppStyle.whiteColor),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, zSabahIndex) =>
                  SizedBox(height: 15.h),
              itemCount: Azkary.azkarSabah.length,
            ),
          ),
        ],
      ),
      // البلاير "الجامد" في أسفل الصفحة
      bottomNavigationBar: _buildBottomPlayer(isDark),
    );
  }
}









