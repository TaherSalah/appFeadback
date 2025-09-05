import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/localization/localization_manager.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';

class AyaSearchScreen extends StatefulWidget {
  const AyaSearchScreen({super.key});

  @override
  State<AyaSearchScreen> createState() => _AyaSearchScreenState();
}

class _AyaSearchScreenState extends State<AyaSearchScreen> {
  late TextEditingController searchKey;
  List<AyahModel> ayah = [];

  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
  }

  loadeData({String? searchText}) {
    setState(() {
      ayah = QuranLibrary().search(searchText ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: customAppBar(
          " البحث بالاية ",
          color: Colors.black,
          leading: CupertinoNavigationBarBackButton(color: Colors.black),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 8, top: 10),
              child: CupertinoSearchTextField(
                onSuffixTap: () {
                  searchKey.clear();
                  setState(() {
                    ayah.clear();
                  });
                },
                controller: searchKey,
                decoration: BoxDecoration(
                  color: CentralizedCubit.isDarkMode
                      ? const Color(0xff1d1b20)
                      : Theme.of(context).cardColor,
                  border: Border.all(
                    color: CentralizedCubit.isDarkMode
                        ? Colors.white
                        : KColors.scoColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5.r)),
                ),
                onChanged: (value) {
                  Future.delayed(const Duration(seconds: 1), () {
                    loadeData(searchText: value);
                  });
                },
                onSubmitted: (value) {
                  loadeData(searchText: value);
                },
                placeholder: "ادخل الاية",
              ),
            ),

            // النتائج
            if (ayah.isNotEmpty) ...[
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                    height: 15,
                  ),
                  itemCount: ayah.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        print("ssss");
                        QuranLibrary().jumpToAyah(ayah[index].page, ayah[index].ayahUQNumber);
                        Navigator.pop(context);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        // alignment: AlignmentGeometry.topCenter,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 35),
                                // child: TextWidget(
                                //   textAlign: TextAlign.justify,
                                //   title: ayah[index].ayaTextEmlaey +
                                //       "﴿${ayah[index].ayahNumber.toString()}﴾ ",
                                //   fontFamily: "me",
                                // ),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: ayah[index].ayaTextEmlaey,
                                      style: TextStyle(fontFamily: "me")),
                                  TextSpan(
                                      text:
                                          "﴿${ayah[index].ayahNumber.toString()}﴾ ",
                                      style: TextStyle(color: Colors.red)),
                                ])),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -17, // يطلع من فوق الكارت
                            left: 20,
                            child: Center(
                              child: Card(
                                elevation: 3,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: TextWidget(
                                    textAlign: TextAlign.center,
                                    title: "الصفحة ${ayah[index].page.toString()}",
                                    fontFamily: "me",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -17, // يطلع من فوق الكارت
                            right: 20,
                            child: Center(
                              child: Card(
                                elevation: 3,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: TextWidget(
                                    textAlign: TextAlign.center,
                                    title: ayah[index].arabicName.toString(),
                                    fontFamily: "me",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ] else ...[
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset("assets/json/file-searching.json"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                    child: query.isEmpty
                        ? Column(
                            children: [
                              TextWidget(
                                title: "لا يوجد نتائج حالية",
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 8.sp
                                    : 14,
                              ),
                              TextWidget(
                                title: "يمكنك البحث عن أي كلمة في القرأن ",
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 8.sp
                                    : 12,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextWidget(
                                    title: "لا يوجد نتائج عن ",
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtil.isTablet(context)
                                        ? 8.sp
                                        : 14,
                                  ),
                                  TextWidget(
                                    title: query,
                                    fontWeight: FontWeight.w600,
                                    color: CentralizedCubit.isDarkMode
                                        ? KColors.primary
                                        : KColors.primary2Color,
                                    fontSize: ResponsiveUtil.isTablet(context)
                                        ? 8.sp
                                        : 14,
                                  ),
                                ],
                              ),
                              TextWidget(
                                title: "يمكنك البحث عن أي كلمة في القرأن ",
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 8.sp
                                    : 12,
                              ),
                            ],
                          ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
