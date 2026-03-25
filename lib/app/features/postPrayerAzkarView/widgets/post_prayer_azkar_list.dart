
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

class PostPrayerAzkarList extends StatelessWidget {
  const PostPrayerAzkarList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, zPrayerIndex) {
        final bool isDone = Azkary.azkarPrayerRepate[zPrayerIndex] <= 0;

        const Color primaryColorLocal = Color(AppStyle.primaryColor);

        // Premium "Done" style: Keep background consistent with others
        final Color cardAccent = isDone
            ? const Color(AppStyle.yellowColor) // Keeping user choice for card accent if they prefer yellow
            : (isDark ? Colors.black : primaryColorLocal);

        final Color chipBg = isDone
            ? const Color(AppStyle.yellowColor)
            : (isDark ? Colors.black : const Color(0xFFECFDF3));

        final Color chipText = isDone
            ? Colors.black
            : (isDark ? Colors.white : KColors.primaryColor);

        return ScrollAppearAnimation(
          duration: const Duration(milliseconds: 700),
          child: GestureDetector(
            onTap: () {
              con.decrementPrayer(zPrayerIndex);
            },
            child: AzkerItemBuilder(
              azkarName: "أذكار الصلاة",
              azkarTitle: Azkary.azkarPrayer[zPrayerIndex],
              azkarDes: Azkary.azkarPrayerDes[zPrayerIndex],
              fontSize: fontSize,
              azkarRepate: isDone ? 'تم بنجاح' : '${Azkary.azkarPrayerRepate[zPrayerIndex]}',
              color: cardAccent,
            ),
          ),
        );
      },
      separatorBuilder: (context, zPrayerIndex) => SizedBox(height: 15.h),
      itemCount: Azkary.azkarPrayer.length,
    );
  }
}
