import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';

class ComplateKhatmaView extends StatefulWidget {
  const ComplateKhatmaView({super.key});

  @override
  State<ComplateKhatmaView> createState() => _ComplateKhatmaViewState();
}

class _ComplateKhatmaViewState extends State<ComplateKhatmaView> {
  late final Box<KhatmahModel> box;
  late final Box plansBox; // khatmahPlans

  // حذف ختمة
  void _deleteKhatmah(int index) {
    final k = box.getAt(index);
    if (k != null) {
      // احذف خطتها إن وُجدت
      plansBox.delete(k.id);
    }
    box.deleteAt(index);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box<KhatmahModel>('khatmahBox'); // نفس الاسم اللي بتفتحه في main
    plansBox = Hive.box('khatmahPlans');
  }

  @override
  Widget build(BuildContext context) {
    final completed = box.values.where((k) => k.isCompleted).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "الختمات المنجزة",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        // backgroundColor: AppStyle.bgColors,
        body: completed.isEmpty
            ? Center(
                child: Column(
                spacing: 25,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/json/QuranPers.json"),
                  TextWidget(
                    title: "لم تُنجز أي ختمة بعد.",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 80),
                itemCount: completed.length,
                itemBuilder: (_, i) {
                  final k = completed[i];
                  final index = box.values.toList().indexOf(k);
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline),
                        title: TextWidget(
                          title: k.title,
                          fontFamily: "me",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 16.sp,
                        ),
                        subtitle: Text(
                            "انتهت في: ${k.endDate.toLocal().toString().split(' ').first}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteKhatmah(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
