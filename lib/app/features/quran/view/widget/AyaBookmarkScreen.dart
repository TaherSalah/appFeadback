import 'dart:developer' as dev;

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

  // @override
  // void initState() {
  //   super.initState();
  //   searchKey = TextEditingController();
  //   _init();
  // }
  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
    _init();
  }


  late List<BookmarkModel> books;
  Future<void> _init() async {
    await QuranLibrary.init();
    await loadBookmarksData();
    books = QuranLibrary().allBookmarks;
  }

  // Future<void> loadBookmarksData() async {
  //   QuranLibrary().clearCache('allBookmarks'); // يمسح الكاش القديم
  //
  //   final List<BookmarkModel> bookmarks = List<BookmarkModel>.from(
  //     QuranLibrary().allBookmarks, // ✅ الأفضل من usedBookmarks
  //   );
  //
  //   setState(() => ayah = bookmarks);
  // }
  // Future<void> loadBookmarksData() async {
  //   // debug helper
  //   void dbg(String s) => dev.log('[Bookmarks] $s');
  //
  //   List<BookmarkModel> bookmarks = [];
  //
  //   try {
  //     // 1) محاولة مباشرة من QuranLibrary (ممكن property موجودة)
  //     try {
  //       final direct = QuranLibrary().allBookmarks;
  //       if (direct != null && direct is List<BookmarkModel> && direct.isNotEmpty) {
  //         bookmarks = List<BookmarkModel>.from(direct);
  //         dbg('got bookmarks from QuranLibrary().allBookmarks (${bookmarks.length})');
  //       } else {
  //         dbg('QuranLibrary().allBookmarks is empty or null');
  //       }
  //     } catch (e) {
  //       dbg('QuranLibrary().allBookmarks not available: $e');
  //     }
  //
  //     // 2) محاولة usedBookmarks
  //     if (bookmarks.isEmpty) {
  //       try {
  //         final used = QuranLibrary().usedBookmarks;
  //         if (used != null && used is List<BookmarkModel> && used.isNotEmpty) {
  //           bookmarks = List<BookmarkModel>.from(used);
  //           dbg('got bookmarks from QuranLibrary().usedBookmarks (${bookmarks.length})');
  //         } else {
  //           dbg('QuranLibrary().usedBookmarks is empty or null');
  //         }
  //       } catch (e) {
  //         dbg('QuranLibrary().usedBookmarks not available: $e');
  //       }
  //     }
  //
  //     // 3) محاولة عبر BookmarksCtrl (بعض الإصدارات تحوي كنترولر مستقل)
  //     if (bookmarks.isEmpty) {
  //       try {
  //         // حاول استخدام BookmarksCtrl() أو BookmarksCtrl.instance
  //         // قد تحتاج الى استيراد: import 'package:quran_library/quran_library.dart';
  //         final bc = BookmarksCtrl();
  //         // أشهر أسماء ممكنة: allBookmarks, bookmarks, getAll, items
  //         if ((bc as dynamic).allBookmarks != null) {
  //           final list = (bc as dynamic).allBookmarks as List;
  //           bookmarks = List<BookmarkModel>.from(list.cast<BookmarkModel>());
  //           dbg('got bookmarks from new BookmarksCtrl().allBookmarks (${bookmarks.length})');
  //         } else {
  //           dbg('BookmarksCtrl().allBookmarks exists but empty');
  //         }
  //       } catch (e) {
  //         dbg('BookmarksCtrl() approach failed (maybe no default ctor): $e');
  //       }
  //
  //       if (bookmarks.isEmpty) {
  //         try {
  //           final bcInstance = BookmarksCtrl.instance; // بعض الإصدارات توفر instance
  //           final list = (bcInstance as dynamic).allBookmarks as List?;
  //           if (list != null && list.isNotEmpty) {
  //             bookmarks = List<BookmarkModel>.from(list.cast<BookmarkModel>());
  //             dbg('got bookmarks from BookmarksCtrl.instance.allBookmarks (${bookmarks.length})');
  //           } else {
  //             dbg('BookmarksCtrl.instance.allBookmarks empty or missing');
  //           }
  //         } catch (e) {
  //           dbg('BookmarksCtrl.instance approach failed: $e');
  //         }
  //       }
  //     }
  //
  //     // 4) أخيراً: حاول الـ repository/ctrl العام في QuranLibrary (بعض الإصدارات توفر getter مختلف)
  //     if (bookmarks.isEmpty) {
  //       try {
  //         final ql = QuranLibrary();
  //         // أسماء ممكنة: bookmarks, bookmarksCtrl, bookmarksList, bookmarksAyahs
  //         final candNames = ['bookmarks', 'bookmarksList', 'bookmarksAyahs', 'bookmarksCtrl'];
  //         for (final name in candNames) {
  //           try {
  //             final val = (ql as dynamic).__noSuchMethod__; // dummy to avoid analyzer; ignore
  //           } catch (_) {}
  //           try {
  //             final dyn = (ql as dynamic);
  //             final maybe = dyn.toJson == null ? null : null; // noop to satisfy analyzer
  //             // attempt reflection-like access:
  //             final prop = (ql as dynamic).__getProperty == null ? null : null;
  //             // Actual access attempt (will throw if property missing)
  //             final value = (ql as dynamic)[name]; // may crash
  //             if (value != null && value is List && value.isNotEmpty) {
  //               bookmarks = List<BookmarkModel>.from(value.cast<BookmarkModel>());
  //               dbg('got bookmarks from QuranLibrary().$name (${bookmarks.length})');
  //               break;
  //             }
  //           } catch (_) {
  //             // ignore
  //           }
  //         }
  //       } catch (e) {
  //         dbg('final QuranLibrary property scan failed: $e');
  //       }
  //     }
  //   } catch (e, st) {
  //     dev.log('[Bookmarks] Unexpected error: $e\n$st');
  //   }
  //
  //   // fallback: لو لسه فاضية اعرض طول العناصر فعليًا من أي getter معروف (للمساعدة في التخطيط)
  //   try {
  //     final a = (QuranLibrary().allBookmarks is List) ? (QuranLibrary().allBookmarks as List).length : null;
  //     final b = (QuranLibrary().usedBookmarks is List) ? (QuranLibrary().usedBookmarks as List).length : null;
  //     dev.log('[Bookmarks] after tries -> allBookmarks length: $a, usedBookmarks length: $b, local list: ${bookmarks.length}');
  //   } catch (_) {}
  //
  //   setState(() {
  //     ayah = bookmarks;
  //   });
  // }
  Future<void> loadBookmarksData() async {
    try {
      await QuranLibrary.init();

      final bookmarksMap = BookmarksCtrl.instance.bookmarks; // Map<int, List<BookmarkModel>>
      // دمج كل القوائم في قائمة واحدة
      final bookmarks = bookmarksMap.values.expand((list) => list).toList();

      dev.log("[Bookmarks] Loaded ${bookmarks.length} bookmarks.");

      setState(() {
        ayah = bookmarks;
      });
    } catch (e, st) {
      dev.log("[Bookmarks] Error loading bookmarks: $e\n$st");
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();
    bool isDark =  Theme.of(context).brightness == Brightness.dark;
    print("Bookmarks ==== >${books}");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: customAppBar(
          " قائمة بالايات المحفوظه",
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
                        // final Map<int, int> colorMap = {
                        //   2868076663: 0xAAF36077,
                        //   2852179200: 0xAAFFD354,
                        //   2868892500: 0xAA00CD00,
                        // };

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
                                  color: Color(b.colorCode),
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
                                          color: isDark
                                              ? KColors.black2Color
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.sizeOf(context).width > 600 ? 6.sp : 10.sp,
                                        ),
                                        TextWidget(
                                          title: "رقم الاية (${b.ayahNumber})",
                                          color: isDark
                                              ? KColors.black2Color
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.sizeOf(context).width > 600 ? 6.sp : 10.sp,
                                        ),
                                        TextWidget(
                                          title: "الصفحة (${b.page})",
                                          color: isDark
                                              ? KColors.black2Color
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
                                      backgroundColor: Colors.black,
                                      foregroundColor: Color(b.colorCode),
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

