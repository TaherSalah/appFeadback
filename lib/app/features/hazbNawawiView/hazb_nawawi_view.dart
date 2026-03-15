import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/widgets/AudioManager.dart';
import '../sleep_view/sleep_azkar.dart';

class HazbNawawiView extends StatefulWidget {
  const HazbNawawiView({super.key});

  @override
  State<HazbNawawiView> createState() => _HazbNawawiViewState();
}

class _HazbNawawiViewState extends State<HazbNawawiView> {
  // ================== إعدادات الصوت ==================
  static const String _hazbUrl =
      'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/hazb.mp3';
  static const String _hazbKey = 'hazb_audio_path';
  static const String _fileName = 'hazb.mp3';

  final AudioManager _audioManager = AudioManager();

  bool _isPlaying = false;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  bool _isBuffering = false;

  bool _showMiniPlayer = false;
  bool _showFullPlayer = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const String _performerName = 'مشاري العفاسي';
  static const String _performerImageAsset =
      'assets/images/natural-view-night_1112329-37092.jpg';

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioManager.initialize();

    final savedPath = await _audioManager.getSavedAudioPath(_hazbKey);
    if (savedPath != null) {
      if (!mounted) return;
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

      final processing = state.processingState;
      final playingNow = _audioManager.isPlaying;

      setState(() {
        _isPlaying = playingNow;

        if (processing == ProcessingState.completed) {
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
        url: _hazbUrl,
        localPath: _isDownloaded ? _audioManager.currentLocalPath : null,
        sharedPrefsKey: _hazbKey,
      );
    } catch (_) {
      KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
    }
  }

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
        url: _hazbUrl,
        fileName: _fileName,
        sharedPrefsKey: _hazbKey,
      );

      setState(() => _isDownloaded = true);

      KHelper.showSuccess(
          message: 'تم تحميل حزب الإمام النووي، يمكن تشغيلها بدون إنترنت.');
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

            if (willPlay) {
              if (!mounted) return;
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Stack(
                      children: [
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
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://images.unsplash.com/photo-1600814832809-579119f47045?q=80&w=731&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop",
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/beautiful-view-sunset-light.jpg",
                              fit: BoxFit.cover,
                            ),
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
                                      KHazbNawawiTitle,
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
                                      'حزب الإمام النووي',
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
                            const SizedBox(width: 15),
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
                            'تم تحميل الحزب، يعمل بدون إنترنت',
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
                                ? 'جاري تحميل حزب الإمام النووي...'
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
                      'استمع للأذكار بهدوء وخشوع، وحاول ترديدها بقلب حاضر.',
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

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();
    final bool allDone = con.isHazbNawawiDone;

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
                  onPressed: con.resetHazbNawawi,
                ),
              ],
              title: Text(
                AppString.KHazbNawawi,
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
                  onPressedRepeat: con.resetHazbNawawi,
                  doneText: AppString.doneText,
                  KZakarFeaturesTitle: AppString.KZakarSabahFeaturesTitle,
                  KDaialogText: "لقد أتممت قراءة حزب الإمام النووي بنجاح.",
                )
              : Column(
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0.w)),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                            bottom:
                                ResponsiveUtil.isTablet(context) ? 50.h : 80.h),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, zHazbIndex) {
                          final isDarkLocal =
                              Theme.of(context).brightness == Brightness.dark;

                          final bool isDone =
                              Azkary.azkarHazbNawawiRepate[zHazbIndex] <= 0;

                          const Color primaryColorLocal =
                              Color(AppStyle.primaryColor);

                          final Color cardAccent = isDone
                              ? const Color(AppStyle.yellowColor)
                              : (isDarkLocal
                                  ? Colors.black
                                  : primaryColorLocal);

                          return StaggeredItemAnimation(
                            index: zHazbIndex,
                            duration: const Duration(milliseconds: 500),
                            child: GestureDetector(
                              onTap: () => con.decrementHazbNawawi(zHazbIndex),
                              child: AzkerItemBuilder(
                                azkarName: "حزب الإمام النووي",
                                azkarTitle: Azkary.azkarHazbNawawi[zHazbIndex],
                                azkarDes: Azkary.azkarHazbNawawiDes[zHazbIndex],
                                fontSize: fontSize,
                                azkarRepate: isDone
                                    ? "تم بنجاح"
                                    : Azkary.azkarHazbNawawiRepate[zHazbIndex]
                                        .toString(),
                                color: cardAccent,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemCount: Azkary.azkarHazbNawawi.length,
                      ),
                    ),
                  ],
                ),
        ),
        if (!_showMiniPlayer) _buildFloatingPlayButton(isDark),
        if (_showFullPlayer) _buildFullPlayer(isDark),
        if (_showMiniPlayer && !_showFullPlayer)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showFullPlayer = true),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: KColors.primaryColor.withOpacity(0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _performerImageAsset,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppString.KHazbNawawi,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _performerName,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: KColors.primaryColor,
                      ),
                      onPressed: _playOrPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => setState(() {
                        _showMiniPlayer = false;
                        if (!_isPlaying) {
                          _audioManager.stop();
                        }
                      }),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const String KHazbNawawiTitle = "حزب الإمام النووي";
}
