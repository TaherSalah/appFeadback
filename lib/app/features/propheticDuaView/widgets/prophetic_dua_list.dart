
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

class PropheticDuaList extends StatelessWidget {
  const PropheticDuaList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

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
            itemBuilder: (context, index) {
              final bool isDone = Azkary.azkarPropheticRepate[index] <= 0;

              const Color primaryColorLocal = Color(AppStyle.primaryColor);

              final Color cardAccent = isDone
                  ? const Color(AppStyle.yellowColor)
                  : (isDark ? Colors.black : primaryColorLocal);

              return StaggeredItemAnimation(
                index: index,
                duration: const Duration(milliseconds: 100),
                child: GestureDetector(
                  onTap: () => con.decrementProphetic(index),
                  child: AzkerItemBuilder(
                    azkarName: AppString.KPropheticDua,
                    azkarTitle: Azkary.azkarProphetic[index],
                    azkarDes: Azkary.azkarPropheticDes[index],
                    fontSize: fontSize,
                    azkarRepate: isDone
                        ? "تم بنجاح"
                        : Azkary.azkarPropheticRepate[index].toString(),
                    color: cardAccent,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemCount: Azkary.azkarProphetic.length,
          ),
        ),
      ],
    );
  }
}
