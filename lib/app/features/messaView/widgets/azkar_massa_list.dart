import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';

class AzkarMassaList extends StatelessWidget {
  const AzkarMassaList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      // removed shrinkWrap for performance (already has Scaffold body space)
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, zMessaIndex) {
        final bool isFinished = Azkary.azkarMassaRepate[zMessaIndex] <= 0;
        final String repeatText =
            isFinished ? "تم بنجاح" : '${Azkary.azkarMassaRepate[zMessaIndex]}';

        const Color primaryColorLocal = Color(AppStyle.primaryColor);
        final Color cardAccent = isFinished
            ? const Color(AppStyle.yellowColor)
            : (isDark ? Colors.black : primaryColorLocal);

        return ScrollAppearAnimation(
          duration: const Duration(milliseconds: 700),
          child: GestureDetector(
            onTap: () {
              con.decrementMessa(zMessaIndex);
            },
            child: AzkerItemBuilder(
              azkarTitle: Azkary.azkarMassa[zMessaIndex],
              azkarDes: Azkary.azkarMassaDes[zMessaIndex],
              azkarRepate: repeatText,
              fontSize: fontSize,
              color: cardAccent,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 15.h),
      itemCount: Azkary.azkarMassa.length,
    );
  }
}
