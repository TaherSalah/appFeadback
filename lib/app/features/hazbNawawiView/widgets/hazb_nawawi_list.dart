
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

class HazbNawawiList extends StatelessWidget {
  const HazbNawawiList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();
    final bool allDone = con.isHazbNawawiDone;

    if (allDone) {
      return DoneDialogWidget(
        onPressedRepeat: con.resetHazbNawawi,
        doneText: AppString.doneText,
        KZakarFeaturesTitle: AppString.KZakarSabahFeaturesTitle,
        KDaialogText: "لقد أتممت قراءة حزب الإمام النووي بنجاح.",
      );
    }

    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 8.0.w)),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(
              bottom: context.isTab ? 50.h : 80.h,
            ),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, zHazbIndex) {
              final bool isDone = Azkary.azkarHazbNawawiRepate[zHazbIndex] <= 0;

              const Color primaryColorLocal = Color(AppStyle.primaryColor);

              final Color cardAccent = isDone
                  ? const Color(AppStyle.yellowColor)
                  : (isDark ? Colors.black : primaryColorLocal);

              return StaggeredItemAnimation(
                index: zHazbIndex,
                duration: const Duration(milliseconds: 100),
                child: GestureDetector(
                  onTap: () => con.decrementHazbNawawi(zHazbIndex),
                  child: AzkerItemBuilder(
                    azkarName: "حزب الإمام النووي",
                    azkarTitle: Azkary.azkarHazbNawawi[zHazbIndex],
                    azkarDes: Azkary.azkarHazbNawawiDes[zHazbIndex],
                    fontSize: fontSize,
                    azkarRepate: isDone
                        ? "تم بنجاح"
                        : Azkary.azkarHazbNawawiRepate[zHazbIndex].toString(),
                    color: cardAccent,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemCount: Azkary.azkarHazbNawawi.length,
          ),
        ),
      ],
    );
  }
}
