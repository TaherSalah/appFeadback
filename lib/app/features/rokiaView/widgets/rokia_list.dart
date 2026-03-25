import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:muslimdaily/app/core/model/azkary_model.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:provider/provider.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/constanc/app_style.dart';
import '../../../core/shard/widgets/azkar_item_builder.dart';
import '../../../core/utils/style/k_color.dart';

class RokiaList extends StatelessWidget {
  const RokiaList({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: context.isTab ? 100 : 120,
      ),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: Azkary.rokiaQuranTitle.length,
      itemBuilder: (context, quranCurrentIndex) {
        final bool isDone = Azkary.rokiaQuranRepe[quranCurrentIndex] <= 0;
        final isDarkLocal = context.isDark;
        const Color primaryColorLocal = Color(AppStyle.primaryColor);
        final Color cardAccent = isDone
            ? const Color(AppStyle.yellowColor)
            : (isDarkLocal ? Colors.black : primaryColorLocal);

        final Color chipBg = isDone
            ? const Color(AppStyle.yellowColor)
            : (isDarkLocal ? Colors.black : const Color(0xFFECFDF3));
        final Color chipText = isDone
            ? Colors.black
            : (isDarkLocal ? Colors.white : KColors.primaryColor);

        return ScrollAppearAnimation(
          duration: const Duration(milliseconds: 700),
          child: GestureDetector(
            onTap: () => con.decrementQuran(quranCurrentIndex),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AzkerItemBuilder(
                azkarName: "الرقية الشرعية",
                azkarTitle: Azkary.rokiaQuranTitle[quranCurrentIndex],
                azkarDes: Azkary.rokiaQuranRawi[quranCurrentIndex],
                fontSize: fontSize,
                azkarRepate: isDone
                    ? 'تم بنجاح'
                    : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
                color: cardAccent,

              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 15),
    );
  }
}
