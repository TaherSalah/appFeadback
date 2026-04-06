import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:muslimdaily/app/core/model/azkary_model.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:provider/provider.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/constanc/app_style.dart';
import '../../../core/shard/widgets/azkar_item_builder.dart';

class SleepList extends StatelessWidget {
  const SleepList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: context.isTab ? 100 : 120,
      ),
      // removed shrinkWrap for performance (already has Scaffold body space)
      physics: const BouncingScrollPhysics(),
      itemCount: Azkary.azkarSleep.length,
      itemBuilder: (context, zSleepIndex) {
        final bool isDone = Azkary.azkarSleepRepate[zSleepIndex] <= 0;
        final isDarkLocal = context.isDark;
        const Color primaryColorLocal = Color(AppStyle.primaryColor);
        final Color cardAccent = isDone ? const Color(AppStyle.yellowColor) : (isDarkLocal ? Colors.black : primaryColorLocal);

        return StaggeredItemAnimation(
          index: zSleepIndex,
          duration: const Duration(milliseconds: 100),
          child: GestureDetector(
            onTap: () => con.decrementSleep(zSleepIndex),
            child: AzkerItemBuilder(
              azkarName: "أذكار النوم",
              azkarTitle: Azkary.azkarSleep[zSleepIndex],
              azkarDes: Azkary.azkarSleepDes[zSleepIndex],
              fontSize: fontSize,
              azkarRepate: isDone ? "تم بنجاح" : Azkary.azkarSleepRepate[zSleepIndex].toString(),
              color: cardAccent,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}
