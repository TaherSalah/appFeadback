import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/features/quran/view/TafsirViewerDetailsScreen.dart';
import 'package:quran_library/quran.dart';

import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/utils/style/k_color.dart';

class TafsirQuranView extends StatefulWidget {
  const TafsirQuranView({super.key});

  @override
  State<TafsirQuranView> createState() => _TafsirQuranViewState();
}

class _TafsirQuranViewState extends State<TafsirQuranView> {
  final _ql = QuranLibrary();
  final Set<int> _downloading = {}; // بتتبع الفهارس اللي بتتنزل حاليًا
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    _initTafsirOnce();
  }

  Future<void> _initTafsirOnce() async {
    await _ql.initTafsir();
    if (mounted) setState(() => _inited = true);
  }

  // Future<void> _handleDownloadOrOpen(int index) async {
  //   if (_downloading.contains(index)) return;
  //
  //   final isDownloaded = _ql.getTafsirDownloaded(index);
  //
  //   if (isDownloaded) {
  //     // ✅ افتح شاشة العرض هنا
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) =>  TafsirViewerScreen(initialPage: _ql.currentPageNumber),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   // ⬇️ تحميل ثم فتح
  //   setState(() => _downloading.add(index));
  //   try {
  //     await _ql.tafsirDownload(index);
  //     _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
  //
  //     if (!mounted) return;
  //     // ✅ افتح شاشة العرض بعد التحميل مباشرة
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => TafsirViewerScreen(
  //           // افتح على الصفحة الحالية من المكتبة بدل رقم ثابت لو تحب
  //           initialPage: _ql.currentPageNumber,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('تعذّر تنزيل التفسير: $e')),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _downloading.remove(index));
  //   }
  // }
  Future<void> _handleDownloadOrOpen(int index) async {
    if (_downloading.contains(index)) return;

    final isDownloaded = _ql.getTafsirDownloaded(index);

    if (isDownloaded) {
       _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
        ),
      );
      return;
    }

    setState(() => _downloading.add(index));
    try {
      await _ql.tafsirDownload(index);
       _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
      if (mounted) {
        setState(() {}); // (اختياري لتحديث أيقونة التحميل/الفتح)
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر تنزيل التفسير: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading.remove(index));
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // مفضّل ناخد الريفرانس مرة
    final ayah = _ql.tafsirAndTraslationCollection;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: const CupertinoNavigationBarBackButton(color: Colors.black),
            centerTitle: true,
            title: Text(
              "تفسير القرآن الكريم",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: ayah.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2 / 2,
                  ),
                  itemBuilder: (context, index) {
                    final isDark = CentralizedCubit.isDarkMode;
                    final isDownloaded = _ql.getTafsirDownloaded(index);
                    final isBusy = _downloading.contains(index);

                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: InkWell(
                        onTap: () {
                          // لو حابب لما تدوس على الكارت نفسه تعمل حاجة (اختياري)
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: const Color(0xFFFFFFFF),
                                shadowColor:
                                KColors.whiteColor.withOpacity(0.6),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWidget(
                                        title: ayah[index].name,
                                        color: isDark
                                            ? KColors.scoColor
                                            : KColors.primary2Color,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                        MediaQuery.sizeOf(context).width > 600
                                            ? 6.sp
                                            : 10.sp,
                                      ),
                                      TextWidget(
                                        title:
                                        "رقم الآية (${ayah[index].databaseName.toString()})",
                                        color: isDark
                                            ? KColors.scoColor
                                            : KColors.primary2Color,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                        MediaQuery.sizeOf(context).width > 600
                                            ? 6.sp
                                            : 10.sp,
                                      ),
                                      TextWidget(
                                        title:
                                        "الصفحة (${ayah[index].name.toString()})",
                                        color: isDark
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
                            ),

                            // زر التحميل/الفتح مع الحالات الثلاثة
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: -15,
                              child: InkWell(
                                onTap: () => _handleDownloadOrOpen(index),
                                child: CircleAvatar(
                                  backgroundColor: AppStyle.primColors,
                                  radius: 22,
                                  child: Builder(
                                    builder: (_) {
                                      if (isBusy) {
                                        // ⏳ جاري التنزيل
                                        return const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                          ),
                                        );
                                      }
                                      if (isDownloaded) {
                                        // ✅ تم التنزيل — أيقونة فتح
                                        return const Icon(
                                          Icons.open_in_new,
                                          size: 26,
                                          color: Colors.white,
                                        );
                                      }
                                      // ⬇️ لم يُنزّل بعد — أيقونة تنزيل
                                      return const Icon(
                                        Icons.download,
                                        size: 28,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// لو عندك ستايلات/ألوان مخصصة بدّلها هنا حسب مشروعك
class AppStyle {
  static const bgColors = Color(0xFFF7F7F7);
  static const primColors = Color(0xFF2E7D32);
}

class KColors {
  static const primary2Color = Color(0xFF1B5E20);
  static const scoColor = Color(0xFF333333);
  static const whiteColor = Colors.white;
}

// /// شاشة عرض التفسير مع اختيار نوع التفسير والصفحة
// class TafsirViewerScreen extends StatefulWidget {
//   /// ابدأ بصفحة معينة (١–٦٠٤). لو ما اتحطتش قيمة، هيبدأ بآخر صفحة محفوظة من المكتبة
//   final int? initialPage;
//
//   const TafsirViewerScreen({super.key, this.initialPage});
//
//   @override
//   State<TafsirViewerScreen> createState() => _TafsirViewerScreenState();
// }
//
// class _TafsirViewerScreenState extends State<TafsirViewerScreen> {
//   final _ql = QuranLibrary();
//
//   bool _inited = false;
//   int _pageNumber = 1; // 1..604
//   int _selectedTafsirIndex = 0;
//   bool _downloading = false;
//
//   // علشان نعيد بناء قائمة الآيات لما تتغير الصفحة
//   List<dynamic> _pageAyahs = const [];
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   Future<void> _init() async {
//     // مهم: تهيئة التفسير مرة واحدة
//     await _ql.initTafsir();
//
//     // اضبط الصفحة المبدئية
//     final startPage = (widget.initialPage != null && widget.initialPage! >= 1 && widget.initialPage! <= 604)
//         ? widget.initialPage!
//         : (_ql.currentPageNumber >= 1 && _ql.currentPageNumber <= 604 ? _ql.currentPageNumber : 1);
//
//     // اضبط التفسير الحالي من المكتبة
//     _selectedTafsirIndex = _ql.tafsirSelected;
//
//     _pageNumber = startPage;
//     await _loadPageAyahs();
//
//     if (mounted) setState(() => _inited = true);
//   }
//
//   Future<void> _loadPageAyahs() async {
//     // NOTE: الميثود تحت بتتوقع رقم صفحة (١–٦٠٤) حسب تعريف مكتبتك
//     // لو مكتبتك تستخدم index (0-based) بدّل القيمة المناسبة هنا
//     _pageAyahs = _ql.getPageAyahsByPageNumber(pageNumber: _pageNumber);
//     setState(() {});
//   }
//
//   Future<void> _onChangeTafsir(int newIndex) async {
//     // لو متحمّل خلاص — بدّله فورًا
//     if (_ql.getTafsirDownloaded(newIndex)) {
//       _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
//       setState(() => _selectedTafsirIndex = newIndex);
//       return;
//     }
//
//     // نزّل التفسير ثم عيّنه
//     setState(() => _downloading = true);
//     try {
//       await _ql.tafsirDownload(newIndex);
//       _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
//       setState(() => _selectedTafsirIndex = newIndex);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم تنزيل التفسير وتفعيله')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('تعذّر تنزيل التفسير: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _downloading = false);
//     }
//   }
//
//   void _changePage(int delta) async {
//     final next = (_pageNumber + delta).clamp(1, 604);
//     if (next == _pageNumber) return;
//     setState(() => _pageNumber = next);
//     await _loadPageAyahs();
//   }
//
//   Future<void> _gotoPageDialog() async {
//     final controller = TextEditingController(text: _pageNumber.toString());
//     final result = await showDialog<int>(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: const Text('اذهب إلى صفحة'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             decoration: const InputDecoration(hintText: 'اكتب رقم الصفحة (1–604)'),
//             textAlign: TextAlign.center,
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(
//               onPressed: () {
//                 final value = int.tryParse(controller.text) ?? _pageNumber;
//                 Navigator.pop(context, value.clamp(1, 604));
//               },
//               child: const Text('اذهب'),
//             ),
//           ],
//         ),
//       ),
//     );
//     if (result != null && result != _pageNumber) {
//       setState(() => _pageNumber = result);
//       await _loadPageAyahs();
//     }
//   }
//
//   Future<void> _openAyahTafsir(AyahModel ayah) async {
//     // لو محتاج رقم السورة/الآية:
//     final int surahNum = ayah.surahNumber ?? 1;
//     final int ayahNum  = ayah.ayahNumber  ?? 1;
//
//     // الرقم الفريد (لو متاح في موديلك). لو مش موجود، سيبه 0:
//     final int ayahUQ   = (ayah.ayahUQNumber);
//
//     final String text  = (ayah.text ?? '').toString();
//
//     await QuranLibrary().showTafsir(
//       context: context,
//       surahNum: surahNum,
//       ayahNum: ayahNum,
//       ayahText: text,
//       pageIndex: _pageNumber - 1,
//       ayahTextN: text,
//       ayahUQNum: ayahUQ,
//       ayahNumber: ayahNum,
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_inited) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     final names = _ql.tafsirAndTraslationCollection; // List<TafsirNameModel>
//     final isDownloaded = _ql.getTafsirDownloaded(_selectedTafsirIndex);
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: AppStyle.bgColors,
//         appBar: AppBar(
//           leading: const CupertinoNavigationBarBackButton(color: Colors.black),
//           centerTitle: true,
//           title: Text(
//             "عارض التفسير",
//             style: GoogleFonts.cairo(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
//             ),
//           ),
//           actions: [
//             IconButton(
//               tooltip: 'اذهب إلى صفحة',
//               onPressed: _gotoPageDialog,
//               icon: const Icon(Icons.find_in_page),
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             SizedBox(height: 8.h),
//             // شريط التحكم (اختيار التفسير + التحكم في الصفحة)
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: Colors.black12),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8.w),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<int>(
//                             isExpanded: true,
//                             value: _selectedTafsirIndex,
//                             icon: _downloading
//                                 ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                                 : const Icon(Icons.arrow_drop_down),
//                             items: List.generate(names.length, (i) {
//                               final n = names[i];
//                               final downloaded = _ql.getTafsirDownloaded(i);
//                               final label = n.name ?? n.bookName ?? 'تفسير #$i';
//                               return DropdownMenuItem<int>(
//                                 value: i,
//                                 child: Row(
//                                   children: [
//                                     Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
//                                     const SizedBox(width: 6),
//                                     Icon(
//                                       downloaded ? Icons.check_circle : Icons.download,
//                                       size: 18,
//                                       color: downloaded ? Colors.green : Colors.grey,
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                             onChanged: (val) {
//                               if (val == null) return;
//                               _onChangeTafsir(val);
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Row(
//                     children: [
//                       IconButton(
//                         tooltip: 'الصفحة السابقة',
//                         onPressed: () => _changePage(-1),
//                         icon: const Icon(Icons.chevron_right, size: 28),
//                       ),
//                       SizedBox(
//                         width: 80.w,
//                         child: Center(
//                           child: Text(
//                             'ص: $_pageNumber',
//                             style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         tooltip: 'الصفحة التالية',
//                         onPressed: () => _changePage(1),
//                         icon: const Icon(Icons.chevron_left, size: 28),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // ملاحظة حالة التنزيل
//             if (!isDownloaded)
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.info_outline, size: 18, color: Colors.orange),
//                     SizedBox(width: 6),
//                     Expanded(child: Text('قم بتنزيل التفسير أولًا من القائمة لاستخدامه بدون إنترنت')),
//                   ],
//                 ),
//               ),
//             SizedBox(height: 4.h),
//
//             // قائمة آيات الصفحة — اضغط على أي آية لفتح التفسير
//             Expanded(
//               child: _pageAyahs.isEmpty
//                   ? const Center(child: Text('لا توجد آيات لهذه الصفحة'))
//                   : ListView.separated(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                 itemCount: _pageAyahs.length,
//                 separatorBuilder: (_, __) => const Divider(height: 12),
//                 itemBuilder: (context, index) {
//                   final ayah = _pageAyahs[index];
//
//                   // ⚠️ غيّر الحقول حسب موديلك
//                   final String ayahLabel = (() {
//                     final s = (ayah.surahNumber ?? ayah.surah ?? '') .toString();
//                     final a = (ayah.ayahNumber  ?? ayah.numberInSurah ?? '').toString();
//                     return 'س:$s آ:$a';
//                   })();
//
//                   final String ayahText = (ayah.text ?? ayah.uthmani ?? ayah.ayahText ?? '').toString();
//
//                   return ListTile(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                     tileColor: Colors.white,
//                     title: Text(
//                       ayahText.isNotEmpty ? ayahText : ayahLabel,
//                       textAlign: TextAlign.right,
//                       style: GoogleFonts.cairo(fontSize: 14.sp),
//                     ),
//                     subtitle: ayahText.isNotEmpty
//                         ? Text(ayahLabel, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.black54))
//                         : null,
//                     trailing: const Icon(Icons.menu_book_outlined),
//                     onTap: () => _openAyahTafsir(ayah),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
/// شاشة عرض التفسير مع اختيار نوع التفسير والصفحة
