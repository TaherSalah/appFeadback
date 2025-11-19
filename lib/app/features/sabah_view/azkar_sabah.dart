import 'dart:io';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/widgets/AudioManager.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// استيراداتك العادية: Azkary, AzkarProvider, CentralizedCubit, AppStyle, AppString, KColors, doneZakar, ScrollAppearAnimation, AzkerItemBuilder, ResponsiveUtil, AudioManager...

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
  static const String _fileName = 'azkar_sabah.mp3';

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

    final savedPath = await _audioManager.getSavedAudioPath(_sabahKey);
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
      setState(() => _isPlaying = _audioManager.isPlaying);
    });
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
        url: _sabahUrl,
        localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
        sharedPrefsKey: _sabahKey,
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
      KHelper.showSuccess(
          message: 'لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      await _audioManager.downloadAudio(
        url: _sabahUrl,
        fileName: _fileName,
        sharedPrefsKey: _sabahKey,
      );

      setState(() => _isDownloaded = true);
      KHelper.showSuccess(
          message: 'تم تحميل أذكار الصباح، يمكن تشغيلها بدون إنترنت.');
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

  // ================== الـ Bottom Player (Mini) ==================

  Widget _buildBottomPlayer(bool isDark) {
    final theme = Theme.of(context);
    final primaryColor =
    isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final int durationMs = _duration.inMilliseconds;
    final int positionMs = _position.inMilliseconds;

    final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;

    final double sliderValue = durationMs > 0
        ? positionMs.clamp(0, durationMs).toDouble()
        : 0.0;

    final modeText = _isDownloaded
        ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
        : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';

    // حالة تشجيع المستخدم
    final bool isPlayingNow = _isPlaying;
    final String stateText = isPlayingNow
        ? 'جاري تشغيل الأذكار الآن'
        : 'اضغط على زر التشغيل لسماع الأذكار';

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
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    color:
                    isDark ? Colors.white24 : Colors.black.withOpacity(0.15),
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
                          'أذكار الصباح',
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
                        'تم تحميل الأذكار، تعمل بدون إنترنت',
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 12,
                          color: isDark
                              ? Colors.greenAccent
                              : Colors.green.shade700,
                        ),
                      ),
                    )
                        : TextButton.icon(
                      onPressed:
                      _isDownloading ? null : _downloadAudio,
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
                            ? 'جاري تحميل أذكار الصباح...'
                            : 'تحميل للتشغيل بدون إنترنت',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : Colors.grey[900],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // زر التشغيل العائم في المنتصف
          Positioned(
            top: -4,
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
                  width: isPlayingNow ? 70 : 70,
                  height: isPlayingNow ? 70 : 70,
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
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
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
          ),
        ],
      ),
    );
  }

  // ================== المشغّل الكامل (Full Player) ==================

  void _openFullPlayer(bool isDark) {
    final theme = Theme.of(context);
    final primaryColor =
    isDark ? const Color(AppStyle.primaryColor) : theme.colorScheme.primary;

    final int durationMs = _duration.inMilliseconds;
    final int positionMs = _position.inMilliseconds;

    final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;

    final double sliderValue = durationMs > 0
        ? positionMs.clamp(0, durationMs).toDouble()
        : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
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
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(isDark ? 0.5 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                      isDark ? Colors.white24 : Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // العنوان + إغلاق
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Text(
                            'مشغل أذكار الصباح',
                            style: GoogleFonts.notoKufiArabic(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color:
                              isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color:
                          isDark ? Colors.white70 : Colors.black54,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // زر تشغيل كبير في الوسط
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _playOrPause();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: _isPlaying ? 90 : 80,
                      height: _isPlaying ? 90 : 80,
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
                                .withOpacity(_isPlaying ? 0.6 : 0.35),
                            blurRadius: _isPlaying ? 22 : 14,
                            spreadRadius: _isPlaying ? 2.0 : 0.8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            key: ValueKey<bool>(_isPlaying),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // نص تشجيعي / توجيهي
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Text(
                        'استمع للأذكار بهدوء وخشوع، وحاول ترديدها بقلب حاضر. '
                            'يمكنك استخدام أزرار التقديم والترجيع لمتابعة ما فاتك.',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          height: 1.6,
                          color:
                          isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // السلايدر + التوقيت + أزرار 10 ثواني
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: durationMs == 0
                              ? null
                              : () async {
                            final int newMs = (positionMs - 10000)
                                .clamp(0, durationMs);
                            await _audioManager.seek(
                              Duration(milliseconds: newMs),
                            );
                          },
                          icon: const Icon(Icons.replay_10_rounded),
                          color: isDark
                              ? Colors.white70
                              : primaryColor.withOpacity(0.9),
                        ),
                        Text(
                          _formatDuration(_position),
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color:
                            isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
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
                              inactiveColor:
                              primaryColor.withOpacity(0.25),
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color:
                            isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        IconButton(
                          onPressed: durationMs == 0
                              ? null
                              : () async {
                            final int newMs = (positionMs + 10000)
                                .clamp(0, durationMs);
                            await _audioManager.seek(
                              Duration(milliseconds: newMs),
                            );
                          },
                          icon: const Icon(Icons.forward_10_rounded),
                          color: isDark
                              ? Colors.white70
                              : primaryColor.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // مساحة مستقبلية لنص الذكر أو قائمة الأذكار
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نصيحة:',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'يمكنك جعل هذا المكان يعرض نص الذكر الحالي، أو قائمة الأذكار، '
                                  'أو تفسير مختصر، أو دعاء ختام الأذكار. فقط اربطه بمصدر البيانات عندك.',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                height: 1.7,
                                color:
                                isDark ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================== واجهة الشاشة الأساسية ==================

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    // هنا المنطق الجديد: تشيك لو كل أذكار الصباح خلصت
    final bool allDone = con.isSabahDone;

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
      body: allDone
      // شاشة "تم الانتهاء" مع إعادة من البداية
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
                      // إعادة العدادات من الأول
                      con.resetSabah();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      'إعادة الأذكار من البداية',
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
      // قائمة الأذكار
          : Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0.w)),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 50.h),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, zSabahIndex) {
                final isDarkLocal =
                    Theme.of(context).brightness == Brightness.dark;

                // الذكر يعتبر خلص لما عدّاده صفر أو أقل
                final bool isDone =
                    Azkary.azkarSabahRepate[zSabahIndex] <= 0;

                final Color primaryColorLocal =
                const Color(AppStyle.primaryColor);

                final Color cardAccent = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDarkLocal
                    ? Colors.black
                    : primaryColorLocal);

                final Color chipBg = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDarkLocal
                    ? Colors.black
                    : const Color(0xFFECFDF3));

                final Color chipText = isDone
                    ? Colors.black
                    : (isDarkLocal
                    ? Colors.white
                    : KColors.primaryColor);

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
                      azkarRepate: isDone
                          ? '0'
                          : '${Azkary.azkarSabahRepate[zSabahIndex]}',
                      color: cardAccent,
                      repertColor: chipText,
                      repertColor2: chipBg,
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
      bottomNavigationBar: _buildBottomPlayer(isDark),
    );
  }
}




