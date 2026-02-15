import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
// ignore: unused_import
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
    box = Hive.box<KhatmahModel>('khatmahBox');
    plansBox = Hive.box('khatmahPlans');
  }

  @override
  Widget build(BuildContext context) {
    // Reverse the list to show newest completed first if desired, or keep as is.
    // Here we just take the completed ones.
    final completed = box.values.where((k) => k.isCompleted).toList().reversed.toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
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
              fontSize: 14.sp,
            ),
          ),
        ),
        body: completed.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/json/QuranPers.json", width: 200, height: 200),
                    const Gap(20),
                    TextWidget(
                      title: "لم تُنجز أي ختمة بعد.",
                      fontSize: 16.sp,
                      fontFamily: "cairo",
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ],
                ),
              )
            : AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completed.length,
                  itemBuilder: (context, index) {
                    final khatmah = completed[index];
                    // We need the original index in the box to delete correctly if we are sorting/filtering
                    // but since we are just deleting from the box, filtering by 'k' is better or finding key.
                    // safely find the key or index in original box:
                    final originalIndex = box.values.toList().indexOf(khatmah);

                    // Duration calculation
                    final durationDays = khatmah.endDate.difference(khatmah.startDate).inDays;
                    final durationText = durationDays <= 0 ? "في أقل من يوم" : "في $durationDays يوم";

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Background Pattern or generic decorative element could go here
                                Positioned(
                                  top: -20,
                                  left: -20,
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 100,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              khatmah.title,
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "تمت بحمد الله",
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(12),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range,
                                              color: Colors.white70, size: 16),
                                          const Gap(6),
                                          Text(
                                            "${khatmah.startDate.toString().split(' ').first}  ➔  ${khatmah.endDate.toString().split(' ').first}",
                                            style: GoogleFonts.cairo(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(8),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined,
                                              color: Colors.white70, size: 16),
                                          const Gap(6),
                                          Text(
                                            "أُنجزت $durationText",
                                            style: GoogleFonts.cairo(
                                              color: Colors.amberAccent,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () => _deleteKhatmah(originalIndex),
                                            icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                            tooltip: 'حذف من السجل',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
