
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'widgets/prophetic_dua_list.dart';

class PropheticDuaView extends StatelessWidget {
  const PropheticDuaView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final bool allDone = con.isPropheticDone;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          context.isTab ? 70 : 50,
        ),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة العداد',
              onPressed: () {
                con.resetProphetic();
              },
            ),
          ],
          title: Text(
            AppString.KPropheticDua,
            style: TextStyle(
              fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: allDone
          ? DoneDialogWidget(
              onPressedRepeat: con.resetProphetic,
              doneText: AppString.doneText,
              KZakarFeaturesTitle: AppString.KZakarFeaturesTitle,
              KDaialogText: "لقد أتممت قراءة الأدعية النبوية بنجاح.",
            )
          : const PropheticDuaList(),
    );
  }
}
