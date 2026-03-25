
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'azkar_other_item.dart';

class AzkarOtherList extends StatelessWidget {
  const AzkarOtherList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, zOtherIndex) {
        final bool isFinished = Azkary.azkarRepate[zOtherIndex] <= 0;
        final String repeatText =
            isFinished ? "تم بنجاح" : '${Azkary.azkarRepate[zOtherIndex]}';

        const Color primaryColorLocal = Color(AppStyle.primaryColor);
        final Color cardAccent = isFinished
            ? const Color(AppStyle.yellowColor)
            : (isDark ? Colors.black : primaryColorLocal);

        return ScrollAppearAnimation(
          duration: const Duration(milliseconds: 700),
          child: GestureDetector(
            onTap: () {
              con.decrementOther(zOtherIndex);
            },
            child: AzkarOtherItem(
              azkarOtherTitle: Azkary.azkarOtherTitle[zOtherIndex],
              azkarOtherDesc: Azkary.azkarOtherDesc[zOtherIndex],
              azkarRepate: repeatText,
              fontSize: fontSize,
              color: cardAccent,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 30.h),
      itemCount: Azkary.azkarOtherTitle.length,
    );
  }
}
