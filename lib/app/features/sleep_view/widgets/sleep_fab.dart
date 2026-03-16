import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import '../sleep_controller.dart';

class SleepFAB extends GetView<SleepController> {
  const SleepFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final theme = Theme.of(context);
    final primaryColor = isDark ? KColors.primaryColor : theme.colorScheme.primary;
    final bool isTab = ResponsiveUtil.isTablet(context);

    return Obx(() {
      if (controller.showMiniPlayer) return const SizedBox.shrink();

      return Positioned(
        bottom: MediaQuery.of(context).viewPadding.bottom + (isTab ? 18 : 10),
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: () async {
              if (!controller.isDownloaded && controller.isBuffering) return;
              HapticFeedback.lightImpact();

              final bool willPlay = !controller.isPlaying;
              await controller.playOrPause();

              if (willPlay) {
                controller.toggleMiniPlayer(true);
                controller.toggleFullPlayer(true);
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
                    color: primaryColor.withOpacity(controller.isPlaying ? 0.55 : 0.35),
                    blurRadius: controller.isPlaying ? 20 : 12,
                    spreadRadius: controller.isPlaying ? 1.8 : 0.6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: (!controller.isDownloaded && controller.isBuffering)
                      ? const SizedBox(
                          key: ValueKey('loader_fab'),
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          key: ValueKey<bool>(controller.isPlaying),
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
