import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import '../azkar_sabah_controller.dart';

class AzkarSabahFAB extends GetView<AzkarSabahController> {
  const AzkarSabahFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDark;
    final primaryColor = isDark ? KColors.primaryColor : theme.colorScheme.primary;
    final bool isTab = ResponsiveUtil.isTablet(context);

    return Obx(() {
      final bool isPlayingNow = controller.isPlaying;
      final bool isBuffering = controller.isBuffering;
      final bool isDownloaded = controller.isDownloaded;

      return Positioned(
        bottom: MediaQuery.of(context).viewPadding.bottom + (isTab ? 18 : 10),
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: () async {
              if (!isDownloaded && isBuffering) return;
              HapticFeedback.lightImpact();

              final bool willPlay = !isPlayingNow;
              await controller.playOrPause();

              if (willPlay) {
                controller.showMiniPlayer = true;
                controller.showFullPlayer = true;
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
                  child: (!isDownloaded && isBuffering)
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
    });
  }
}
