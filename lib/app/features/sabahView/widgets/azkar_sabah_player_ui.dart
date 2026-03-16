import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import '../azkar_sabah_controller.dart';

class AzkarSabahPlayerUI extends GetView<AzkarSabahController> {
  const AzkarSabahPlayerUI({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Obx(() {
      return Stack(
        children: [
          if (controller.showMiniPlayer && !controller.showFullPlayer)
            _buildMiniPlayer(context, isDark),
          _buildFullPlayer(context, isDark),
        ],
      );
    });
  }

  Widget _buildMiniPlayer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = isDark ? KColors.primaryColor : theme.colorScheme.primary;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => controller.toggleFullPlayer(true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AzkarSabahController.performerImageAsset,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أذكار الصباح',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        AzkarSabahController.performerName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  onPressed: () => controller.playOrPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    controller.toggleMiniPlayer(false);
                    if (controller.isPlaying) controller.playOrPause();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullPlayer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = isDark ? KColors.primaryColor : theme.colorScheme.primary;

    final int durationMs = controller.duration.inMilliseconds;
    final int positionMs = controller.position.inMilliseconds;

    final double sliderMax = durationMs > 0 ? durationMs.toDouble() : 1.0;
    final double sliderValue = durationMs > 0 ? positionMs.clamp(0, durationMs).toDouble() : 0.0;

    final double fullHeight = MediaQuery.sizeOf(context).height * 0.78;
    final bool isTab = ResponsiveUtil.isTablet(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: controller.showFullPlayer ? 0 : -fullHeight,
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
                  ? const [Color(0xFF020617), Color(0xFF0B1220), Color(0xFF0F172A)]
                  : [primaryColor.withOpacity(0.07), const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
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
                              color: isDark ? Colors.white24 : Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              if (controller.isPlaying) {
                                controller.toggleFullPlayer(false);
                              } else {
                                controller.toggleFullPlayer(false);
                                controller.toggleMiniPlayer(false);
                              }
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
                  padding: EdgeInsets.symmetric(horizontal: isTab ? 22 : 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isDark ? Colors.white.withOpacity(0.04) : primaryColor.withOpacity(0.06),
                      border: Border.all(color: primaryColor.withOpacity(isDark ? 0.25 : 0.12)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: isTab ? 450 : 350,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
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
                                  AzkarSabahController.performerImageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: primaryColor.withOpacity(0.12),
                                    child: Icon(Icons.person_rounded, size: isTab ? 34 : 28, color: primaryColor),
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
                                      AzkarSabahController.performerName,
                                      style: GoogleFonts.notoKufiArabic(
                                        fontSize: isTab ? 16 : 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : primaryColor.withOpacity(0.95),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'أذكار الصباح • صوت هادئ وخاشع',
                                      style: GoogleFonts.cairo(
                                        fontSize: isTab ? 12.5 : 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            if (controller.isDownloaded)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.green.withOpacity(0.12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.offline_pin_rounded, color: Colors.green, size: 16),
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
                  child: controller.isDownloaded
                      ? TextButton.icon(
                          onPressed: null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.green.withOpacity(0.08),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.download_done_rounded, size: 18, color: Colors.green),
                          label: Text(
                            'تم تحميل الأذكار، تعمل بدون إنترنت',
                            style: GoogleFonts.notoKufiArabic(
                              fontSize: 12,
                              color: isDark ? Colors.greenAccent : Colors.green.shade700,
                            ),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: controller.isDownloading ? null : controller.downloadAudio,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            backgroundColor: isDark ? Colors.white.withOpacity(0.06) : primaryColor.withOpacity(0.08),
                            shape: const StadiumBorder(),
                          ),
                          icon: controller.isDownloading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.download_rounded, size: 19, color: isDark ? Colors.greenAccent : primaryColor),
                          label: Text(
                            controller.isDownloading ? 'جاري تحميل أذكار الصباح...' : 'تحميل للتشغيل بدون إنترنت',
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
                                final int newMs = (positionMs - 10000).clamp(0, durationMs);
                                await controller.audioManager.seek(Duration(milliseconds: newMs));
                              },
                        icon: const Icon(Icons.replay_10_rounded),
                        color: isDark ? Colors.white70 : primaryColor.withOpacity(0.9),
                      ),
                      Text(
                        controller.formatDuration(controller.position),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.8,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.5),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          ),
                          child: Slider(
                            value: sliderValue,
                            min: 0,
                            max: sliderMax,
                            onChanged: durationMs == 0
                                ? null
                                : (v) async {
                                    await controller.audioManager.seek(Duration(milliseconds: v.toInt()));
                                  },
                            activeColor: primaryColor,
                            inactiveColor: primaryColor.withOpacity(0.25),
                          ),
                        ),
                      ),
                      Text(
                        controller.formatDuration(controller.duration),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      IconButton(
                        onPressed: durationMs == 0
                            ? null
                            : () async {
                                final int newMs = (positionMs + 10000).clamp(0, durationMs);
                                await controller.audioManager.seek(Duration(milliseconds: newMs));
                              },
                        icon: const Icon(Icons.forward_10_rounded),
                        color: isDark ? Colors.white70 : primaryColor.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    if (!controller.isDownloaded && controller.isBuffering) return;
                    HapticFeedback.lightImpact();
                    controller.playOrPause();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: controller.isPlaying ? (isTab ? 110 : 75) : (isTab ? 102 : 70),
                    height: controller.isPlaying ? (isTab ? 110 : 75) : (isTab ? 102 : 70),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(controller.isPlaying ? 0.6 : 0.35),
                          blurRadius: controller.isPlaying ? 28 : 18,
                          spreadRadius: controller.isPlaying ? 2.2 : 0.9,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: (!controller.isDownloaded && controller.isBuffering)
                            ? const SizedBox(
                                key: ValueKey('loader_full'),
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                key: ValueKey<bool>(controller.isPlaying),
                                color: Colors.white,
                                size: isTab ? 50 : 44,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
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
}
