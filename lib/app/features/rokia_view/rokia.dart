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
import '../sleep_view/sleep_azkar.dart';

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
  bool _isBuffering = false;

  // ✅ نفس منطق المساء/الصباح
  bool _showMiniPlayer = false;
  bool _showFullPlayer = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Full Player constants
  static const String _performerName = 'مشاري العفاسي';
  static const String _performerImageAsset = 'assets/images/affasy.png';

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioManager.initialize();

    final savedPath = await _audioManager.getSavedAudioPath(_roqiaKey);
    if (savedPath != null && mounted) {
      setState(() => _isDownloaded = true);
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

      final processingState = state.processingState;
      final bufferingNow = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;

      final playingNow = _audioManager.isPlaying;

      setState(() {
        _isPlaying = playingNow;
        _isBuffering = bufferingNow;

        // ✅ لو خلص، اقفل الفل والميني
        if (processingState == ProcessingState.completed) {
          _showFullPlayer = false;
          _showMiniPlayer = false;
        }
      });
    });

    _audioManager.bufferingStream.listen((b) {
      if (!mounted) return;
      setState(() => _isBuffering = b);
    });
  }

  Future<void> _playOrPause() async {
    try {
      await _audioManager.playOrPause(
        url: _roqiaUrl,
        localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
        sharedPrefsKey: _roqiaKey,
      );
    } catch (_) {
      KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
    }
  }

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
      if (mounted) setState(() => _isDownloading = false);
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

  // ================== Floating Play Button ==================
  Widget _buildFloatingPlayButton(bool isDark) {
    final theme = Theme.of(context);
    final primaryColor =
        isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final bool isTab = ResponsiveUtil.isTablet(context);
    final bool isPlayingNow = _isPlaying;

    return Positioned(
      bottom: MediaQuery.of(context).viewPadding.bottom + (isTab ? 18 : 10),
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            if (!_isDownloaded && _isBuffering) return;
            HapticFeedback.lightImpact();

            final bool willPlay = !_isPlaying;
            await _playOrPause();

            if (willPlay && mounted) {
              setState(() {
                _showMiniPlayer = true;
                _showFullPlayer = true;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isTab ? 70 : 55,
            height: isTab ? 70 : 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(isPlayingNow ? 0.55 : 0.35),
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
                child: (!_isDownloaded && _isBuffering)
                    ? const SizedBox(
                        key: ValueKey('loader_fab'),
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        isPlayingNow
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey<bool>(isPlayingNow),
                        color: Colors.white,
                        size: 34,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== Mini Bottom Player ==================
  Widget _buildBottomPlayer(bool isDark) {
    final bool isTab = ResponsiveUtil.isTablet(context);
    final theme = Theme.of(context);
    final primaryColor =
        isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final int durationMs = _duration.inMilliseconds;
    final int positionMs = _position.inMilliseconds;

    final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;
    final double sliderValue =
        durationMs > 0 ? positionMs.clamp(0, durationMs).toDouble() : 0.0;

    final modeText = _isDownloaded
        ? 'وضع أوفلاين: يمكن التشغيل بدون إنترنت.'
        : 'وضع أونلاين: يتطلب إنترنت للتشغيل إذا لم يتم التحميل.';

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
          Container(
            margin: EdgeInsets.only(top: isTab ? 30 : 0),
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
                    ? const [Color(0xFF020617), Color(0xFF0F172A)]
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          _performerName,
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Container(
                    key: ValueKey<bool>(isPlayingNow),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: stateBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stateIcon, size: 16, color: stateFg),
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
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    modeText,
                    style: GoogleFonts.cairo(
                      fontSize: isTab ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
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
                              enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0,
                          max: sliderMax,
                          onChanged: durationMs == 0
                              ? null
                              : (v) async {
                                  await _audioManager.seek(
                                    Duration(milliseconds: v.toInt()),
                                  );
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
                Align(
                  alignment: Alignment.center,
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: _isDownloaded
                        ? TextButton.icon(
                            onPressed: null,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.green.withOpacity(0.08),
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.download_done_rounded,
                                size: 18, color: Colors.green),
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
                                  horizontal: 16, vertical: 6),
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
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // زر التشغيل العائم فوق الميني (بنفس منطق المساء)
          Positioned(
            top: isTab ? -4 : -20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (!_isDownloaded && _isBuffering) return;
                  HapticFeedback.lightImpact();

                  final bool willPlay = !_isPlaying;
                  await _playOrPause();

                  if (willPlay && mounted) {
                    setState(() {
                      _showMiniPlayer = true;
                      _showFullPlayer = true;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: isTab ? 70 : 50,
                  height: isTab ? 70 : 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.85)],
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
                      child: (!_isDownloaded && _isBuffering)
                          ? const SizedBox(
                              key: ValueKey('loader'),
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
          ),
        ],
      ),
    );
  }

  // ================== Full Player Overlay ==================
  Widget _buildFullPlayer(bool isDark) {
    final theme = Theme.of(context);
    final primaryColor =
        isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final int durationMs = _duration.inMilliseconds;
    final int positionMs = _position.inMilliseconds;

    final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;
    final double sliderValue =
        durationMs > 0 ? positionMs.clamp(0, durationMs).toDouble() : 0.0;

    final double fullHeight = MediaQuery.sizeOf(context).height * 0.78;
    final bool isTab = ResponsiveUtil.isTablet(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: _showFullPlayer ? 0 : -fullHeight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: fullHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? const [
                      Color(0xFF020617),
                      Color(0xFF0B1220),
                      Color(0xFF0F172A)
                    ]
                  : [
                      primaryColor.withOpacity(0.07),
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ],
            ),
            border: Border.all(
              color: primaryColor.withOpacity(isDark ? 0.45 : 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(isDark ? 0.5 : 0.2),
                blurRadius: 26,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Handle + Close
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 50, // خليه أعلى من 40 عشان الـ IconButton مايضغطش
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // الخط في النص
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),

                        // زر الإغلاق على اليمين
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  _showFullPlayer = false;
                                } else {
                                  _showFullPlayer = false;
                                  _showMiniPlayer = false;
                                }
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 22 : 16,
                    vertical: 6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : primaryColor.withOpacity(0.06),
                      border: Border.all(
                        color: primaryColor.withOpacity(isDark ? 0.25 : 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 350,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/images/OIP.webp",
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Container(
                              width: isTab ? 68 : 56,
                              height: isTab ? 68 : 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  _performerImageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: primaryColor.withOpacity(0.12),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: isTab ? 34 : 28,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _performerName,
                                      style: GoogleFonts.notoKufiArabic(
                                        fontSize: isTab ? 16 : 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : primaryColor.withOpacity(0.95),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'الرقية الشرعية • آيات مختارة للشفاء والسكينة',
                                      style: GoogleFonts.cairo(
                                        fontSize: isTab ? 12.5 : 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isDownloaded)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.green.withOpacity(0.12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.offline_pin_rounded,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'أوفلاين',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Download button
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: _isDownloaded
                      ? TextButton.icon(
                          onPressed: null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
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
                                horizontal: 18, vertical: 7),
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.06)
                                : primaryColor.withOpacity(0.08),
                            shape: const StadiumBorder(),
                          ),
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 10),

                // Slider + 10s buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
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
                        color: isDark
                            ? Colors.white70
                            : primaryColor.withOpacity(0.9),
                      ),
                      Text(
                        _formatDuration(_position),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.8,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.5,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: sliderValue,
                            min: 0,
                            max: sliderMax,
                            onChanged: durationMs == 0
                                ? null
                                : (v) async {
                                    await _audioManager.seek(
                                      Duration(milliseconds: v.toInt()),
                                    );
                                  },
                            activeColor: primaryColor,
                            inactiveColor: primaryColor.withOpacity(0.25),
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
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
                        color: isDark
                            ? Colors.white70
                            : primaryColor.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Big play button
                GestureDetector(
                  onTap: () {
                    if (!_isDownloaded && _isBuffering) return;
                    HapticFeedback.lightImpact();
                    _playOrPause();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: _isPlaying ? (isTab ? 110 : 75) : (isTab ? 102 : 70),
                    height:
                        _isPlaying ? (isTab ? 110 : 75) : (isTab ? 102 : 70),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              primaryColor.withOpacity(_isPlaying ? 0.6 : 0.35),
                          blurRadius: _isPlaying ? 28 : 18,
                          spreadRadius: _isPlaying ? 2.2 : 0.9,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: (!_isDownloaded && _isBuffering)
                            ? const SizedBox(
                                key: ValueKey('loader_full'),
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                key: ValueKey<bool>(_isPlaying),
                                color: Colors.white,
                                size: isTab ? 50 : 44,
                              ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10),
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      'استمع للرقية بهدوء وخشوع، واسأل الله الشفاء والعافية.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        height: 1.6,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== واجهة الشاشة الأساسية ==================
  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();
    final bool allDone = con.isQuranDone;

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
            ),
            child: AppBar(
              leading: CupertinoNavigationBarBackButton(
                color: isDark ? Colors.white : Colors.black,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'إعادة العداد',
                  onPressed: con.resetQuran,
                ),
              ],
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
              ? DoneDialogWidget(
                  repratBtn: "إعادة الرقية",
                  onPressedRepeat: con.resetQuran,
                  doneText: AppString.KZakarRokiaFeaturesDes,
                  KZakarFeaturesTitle: AppString.KRokiaFeaturesTitle,
                  KDaialogText: AppString.KRokiaDaialogText,
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.w),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                            bottom:
                                ResponsiveUtil.isTablet(context) ? 50.h : 80.h),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, quranCurrentIndex) {
                          final bool isDone =
                              Azkary.rokiaQuranRepe[quranCurrentIndex] <= 0;

                          final Color cardColor = isDone
                              ? const Color(AppStyle.yellowColor)
                              : (isDark
                                  ? Colors.black
                                  : const Color(AppStyle.whiteColor));
                          final isDarkLocal =
                              Theme.of(context).brightness == Brightness.dark;

                          const Color primaryColorLocal =
                              Color(AppStyle.primaryColor);

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
                              onTap: () =>
                                  con.decrementQuran(quranCurrentIndex),
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
                                  color: cardAccent,
                                  repertColor: chipText,
                                  repertColor2: chipBg,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 15.h),
                        itemCount: Azkary.rokiaQuranTitle.length,
                      ),
                    ),
                  ],
                ),

          // ✅ الميني يظهر فقط بعد أول Play
          // bottomNavigationBar:
          // _showMiniPlayer ? _buildBottomPlayer(isDark) : null,
        ),

        // خلفية معتمة عند فتح الـ Full
        if (_showFullPlayer)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!_isPlaying) {
                  setState(() {
                    _showFullPlayer = false;
                    _showMiniPlayer = false;
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

        // الـ Full Player
        _buildFullPlayer(isDark),

        // ✅ زر عائم يظهر لو الميني مخفي
        if (!_showMiniPlayer) _buildFloatingPlayButton(isDark),
      ],
    );
  }
}
