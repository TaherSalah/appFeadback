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

class AyaBookmarkScreen extends StatefulWidget {
  const AyaBookmarkScreen({super.key});

  @override
  State<AyaBookmarkScreen> createState() => _AyaBookmarkScreenState();
}

class _AyaBookmarkScreenState extends State<AyaBookmarkScreen> {
  late TextEditingController searchKey;
  List<BookmarkModel> ayah = [];

  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
    QuranLibrary().init();
    loadBookmarksData();
  }


  Future<void> loadBookmarksData() async {
    // لو في ميثود اسمها loadBookmarks في المكتبة لازم تستدعيها

    setState(() {
      ayah = List.from(QuranLibrary().usedBookmarks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();
print(ayah);
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

            // النتائج
            if (ayah.isNotEmpty) ...[

              Expanded(
                child:  GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: ayah.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1/1.2
                        ),
                    itemBuilder: (context, index) {
                      final Map<int, int> colorMap = {
                        2868076663: 0xAAF36077,  // لون 1
                        2852179200: 0xAAFFD354,  // لون 2
                        2868892500: 0xAA00CD00,  // لون 3
                      };                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 2),
                        child: InkWell(
                            onTap: () {
                         QuranLibrary().jumpToAyah(ayah[index].page, ayah[index].ayahId);
                         Navigator.pop(context);
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Card(
                                  color: Color(colorMap[ayah[index].colorCode] ?? 0xFFFFFFFF),
                                  shadowColor:
                                  KColors.whiteColor.withOpacity(0.6),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment:MainAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          title:ayah[index].name,
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                
                                          fontSize:
                                          MediaQuery.sizeOf(context).width > 600
                                              ? 6.sp
                                              : 10.sp,
                                        ),
                                        TextWidget(
                                          title:"رقم الاية (${ayah[index].ayahNumber.toString()})",
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                
                                          fontSize:
                                          MediaQuery.sizeOf(context).width > 600
                                              ? 6.sp
                                              : 10.sp,
                                        ),
                                        TextWidget(
                                          title:" الصفحة (${ayah[index].page.toString()})",
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                
                                          fontSize:
                                          MediaQuery.sizeOf(context).width > 600
                                              ? 6.sp
                                              : 10.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                    left: 0,
                                    bottom: -15,
                                    child: InkWell(
                                      onTap: () {
                                        QuranLibrary().removeBookmark(bookmarkId: ayah[index].id);

                                        setState(() {
                                          loadBookmarksData();                                        });
                                      },

                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Color(colorMap[ayah[index].colorCode] ?? 0xFFFFFFFF),
                                                                        child: Icon(Icons.delete_forever_outlined,size: 30,),
                                                                      ),
                                    )),

                              ],
                            )),
                      );
                    }),
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
