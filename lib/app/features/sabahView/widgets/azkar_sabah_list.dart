import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:muslimdaily/app/core/model/azkary_model.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:provider/provider.dart';
import '../../../core/controller/azkar_controller.dart';
import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/constanc/app_style.dart';
import '../../../core/shard/widgets/azkar_item_builder.dart';

class AzkarSabahList extends StatelessWidget {
  const AzkarSabahList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtil.isTablet(context) ? 100 : 120,
      ),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: Azkary.azkarSabah.length,
      itemBuilder: (context, zSabahIndex) {
        final bool isDone = Azkary.azkarSabahRepate[zSabahIndex] <= 0;
        const Color primaryColorLocal = Color(AppStyle.primaryColor);
        final Color cardAccent = isDone
            ? const Color(AppStyle.yellowColor)
            : (isDark ? Colors.black : primaryColorLocal);

        return StaggeredItemAnimation(
          index: zSabahIndex,
          duration: const Duration(milliseconds: 100),
          child: GestureDetector(
            onTap: () => con.decrementSabah(zSabahIndex),
            child: AzkerItemBuilder(
              azkarName: "أذكار الصباح",
              azkarTitle: Azkary.azkarSabah[zSabahIndex],
              azkarDes: Azkary.azkarSabahDes[zSabahIndex],
              fontSize: fontSize,
              azkarRepate: isDone
                  ? "تم بنجاح"
                  : Azkary.azkarSabahRepate[zSabahIndex].toString(),
              color: cardAccent,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}
