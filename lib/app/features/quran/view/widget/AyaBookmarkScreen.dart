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
  late final TextEditingController searchKey;
  List<BookmarkModel> ayah = [];

  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
    _init();
  }

  Future<void> _init() async {
    await QuranLibrary().init();
    await loadBookmarksData();
  }

  Future<void> loadBookmarksData() async {
    // لازم تضمن init قبل أول استخدام
    await QuranLibrary().init();

    // امسح كاش القايمة عشان تتحدث بعد أي تعديل
    QuranLibrary().clearCache('usedBookmarks');
    // أو لو عاوز كل العلامات حتى غير المرتبطة بصفحة:
    // QuranLibrary().clearCache('allBookmarks');

    setState(() {
      ayah = List<BookmarkModel>.from(QuranLibrary().usedBookmarks);
      // لو عايز الكل استخدم:
      // ayah = List<BookmarkModel>.from(QuranLibrary().allBookmarks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: customAppBar(
          "البحث بالاية",
          color: Colors.black,
          leading: const CupertinoNavigationBarBackButton(color: Colors.black),
        ),
        body: RefreshIndicator(
          onRefresh: loadBookmarksData,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ayah.isNotEmpty) ...[
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: ayah.length,
                      // physics: const BouncingScrollPhysics(), // تمكين التمرير
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtil.isTablet(context) ? 6 : 4, // يقلّل الأعمدة → الكروت أوسع
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 25,
                        mainAxisExtent: ResponsiveUtil.isTablet(context) ? 150 : 130, // ارتفاع ثابت مناسب
                      ),
                      itemBuilder: (context, index) {
                        final Map<int, int> colorMap = {
                          2868076663: 0xAAF36077,
                          2852179200: 0xAAFFD354,
                          2868892500: 0xAA00CD00,
                        };

                        final b = ayah[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          child: InkWell(
                            onTap: () {
                              QuranLibrary().jumpToAyah(b.page, b.ayahId);
                              Navigator.pop(context);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Card(
                                  color: Color(colorMap[b.colorCode] ?? 0xFFFFFFFF),
                                  shadowColor: KColors.whiteColor.withOpacity(0.6),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          title: b.name,
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.sizeOf(context).width > 600 ? 6.sp : 10.sp,
                                        ),
                                        TextWidget(
                                          title: "رقم الاية (${b.ayahNumber})",
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.sizeOf(context).width > 600 ? 6.sp : 10.sp,
                                        ),
                                        TextWidget(
                                          title: "الصفحة (${b.page})",
                                          color: CentralizedCubit.isDarkMode
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.sizeOf(context).width > 600 ? 6.sp : 10.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  left: 0,
                                  bottom: -20,
                                  child: InkWell(
                                    onTap: () async {
                                       QuranLibrary().removeBookmark(bookmarkId: ayah[index].id);
                                      await loadBookmarksData(); // تعيد القراءة بعد مسح الكاش
                                    },

                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(colorMap[b.colorCode] ?? 0xFFFFFFFF),
                                      child: const Icon(Icons.delete_forever_outlined, size: 30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: Column(


                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset("assets/json/file-searching.json"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                            child: query.isEmpty
                                ? Column(
                              children: [
                                TextWidget(
                                  title: "لا يوجد علامات محفوظه حالية",
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 14,
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
                                      fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 14,
                                    ),
                                    TextWidget(
                                      title: query,
                                      fontWeight: FontWeight.w600,
                                      color: CentralizedCubit.isDarkMode
                                          ? KColors.primary
                                          : KColors.primary2Color,
                                      fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 14,
                                    ),
                                  ],
                                ),
                                TextWidget(
                                  title: "يمكنك البحث عن أي كلمة في القرأن",
                                  fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

