import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:quran_library/quran.dart';

import '../../../core/utils/style/responsive_util.dart';

class TafsirViewerDetailsScreen extends StatefulWidget {
  /// ابدأ بصفحة معينة (١–٦٠٤). لو ما اتحطتش قيمة، هيبدأ بآخر صفحة محفوظة من المكتبة
  final int? initialPage;

  const TafsirViewerDetailsScreen({super.key, this.initialPage});

  @override
  State<TafsirViewerDetailsScreen> createState() =>
      _TafsirViewerDetailsScreenState();
}

class _TafsirViewerDetailsScreenState extends State<TafsirViewerDetailsScreen> {
  final _ql = QuranLibrary();

  bool _inited = false;
  int _pageNumber = 1; // 1..604
  int _selectedTafsirIndex = 0;
  bool _downloading = false;

  // ✅ استخدم تايب صريح بدل dynamic
  List<AyahModel> _pageAyahs = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // مهم: تهيئة التفسير مرة واحدة
    await _ql.initTafsir();
    _selectedTafsirIndex = _ql.tafsirSelected; // موجودة عندك بالفعل

    // اضبط الصفحة المبدئية
    final startPage = (widget.initialPage != null &&
            widget.initialPage! >= 1 &&
            widget.initialPage! <= 604)
        ? widget.initialPage!
        : (_ql.currentPageNumber >= 1 && _ql.currentPageNumber <= 604
            ? _ql.currentPageNumber
            : 1);

    // اضبط التفسير الحالي من المكتبة
    _selectedTafsirIndex = _ql.tafsirSelected;

    _pageNumber = startPage;
    await _loadPageAyahs();

    if (mounted) setState(() => _inited = true);
  }

  Future<void> _loadPageAyahs() async {
    // NOTE: الميثود تحت بتتوقع رقم صفحة (١–٦٠٤) حسب تعريف مكتبتك
    final list = _ql.getPageAyahsByPageNumber(pageNumber: _pageNumber);
    // ✅ تأكد إننا List<AyahModel>
    _pageAyahs = List<AyahModel>.from(list);
    setState(() {});
  }

  // Future<void> _onChangeTafsir(int newIndex) async {
  //   // لو متحمّل خلاص — بدّله فورًا
  //   if (_ql.getTafsirDownloaded(newIndex)) {
  //     _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
  //     setState(() => _selectedTafsirIndex = newIndex);
  //     return;
  //   }
  //
  //   // نزّل التفسير ثم عيّنه
  //   setState(() => _downloading = true);
  //   try {
  //     await _ql.tafsirDownload(newIndex);
  //     _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
  //     setState(() => _selectedTafsirIndex = newIndex);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('تم تنزيل التفسير وتفعيله')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('تعذّر تنزيل التفسير: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _downloading = false);
  //   }
  // }

  //////////************///////////
  // Future<void> _onChangeTafsir(int newIndex) async {
  //   setState(() => _downloading = true);
  //   try {
  //     if (!_ql.getTafsirDownloaded(newIndex)) {
  //       await _ql.tafsirDownload(newIndex);
  //     }
  //      _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
  //     setState(() => _selectedTafsirIndex = newIndex);
  //
  //     // ✅ بعد التفعيل، حدّث قائمة الآيات/النصوص المعروضة (لو بتتأثر بنوع التفسير)
  //     await _loadPageAyahs();
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('تم تفعيل التفسير المختار')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('تعذّر تفعيل التفسير: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _downloading = false);
  //   }
  // }
  Future<void> _onChangeTafsir(int newIndex) async {
    setState(() => _downloading = true);
    try {
      if (!_ql.getTafsirDownloaded(newIndex)) {
        await _ql.tafsirDownload(newIndex);
      }

      _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);

      // ★ حدّث المؤشّر المحلي فورًا
      _selectedTafsirIndex = newIndex;
      setState(() {}); // ★ تحدّث الـ UI مباشرة

      // (اختياري لكن مُستحسن) محدِّث آيات الصفحة لو بتتأثر بالنوع
      await _loadPageAyahs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تفعيل التفسير المختار')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر تفعيل التفسير: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _changePage(int delta) async {
    final next = (_pageNumber + delta).clamp(1, 604);
    if (next == _pageNumber) return;
    setState(() => _pageNumber = next);
    await _loadPageAyahs();
  }

  final _formKey = GlobalKey<FormState>();
//   Future<void> _gotoPageDialog() async {
//     final controller = TextEditingController(text: _pageNumber.toString());
//     final result = await showDialog<int>(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: const Text('اذهب إلى صفحة',style: TextStyle(fontFamily: "me"),),
//           content:Form(
//             key: _formKey,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // زرار نقص
//                 IconButton(
//                   icon: const Icon(Icons.remove),
//                   onPressed: () {
//                     int current = int.tryParse(controller.text) ?? 1;
//                     if (current > 1) {
//                       controller.text = (current - 1).toString();
//                     }
//                   },
//                 ),
//
//                   // خانة الكتابة
//                   SizedBox(
//                     width: 100,
//                     child: TextFormField(
//                       controller: controller,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3),],
//                       validator: (value) {
//                         if (value == null || value.isEmpty) return 'مطلوب';
//                         final n = int.tryParse(value);
//                         if (n == null) return 'أرقام فقط';
//                         if (n < 1 || n > 604) return 'الصفحة بين 1 و 604';
//                         return null; // صحيح
//                       },
//                       textAlign: TextAlign.center,
//                       decoration: const InputDecoration(
//                         hintText: 'اكتب رقم الصفحة (1–604)',
//                       ),
//                     ),
//                   ),
//
//                   // زرار زيادة
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () {
//                     final current = int.tryParse(controller.text) ?? 0;
//                     if (current < 604) {
//                       controller.text = (current + 1).toString();
//                     }
//                     // اعمل re-validate بعد التغيير
//                     _formKey.currentState?.validate();
//                   },
//                 ),
//               ],
//             ),
//           )
// ,
//             actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('إلغاء')),
//             ElevatedButton(
//               onPressed: () {
//                 final value = int.tryParse(controller.text) ?? _pageNumber;
//                 Navigator.pop(context, value.clamp(1, 604));
//                 _formKey.currentState?.validate();
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
  Future<void> _gotoPageDialog() async {
    final controller = TextEditingController(text: _pageNumber.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title:
              const Text('اذهب إلى صفحة', style: TextStyle(fontFamily: "me")),
          content: Form(
            key: _formKey,
            // مهم: خليه Column علشان الـ error تحت الـ TextFormField يلاقي مكان يظهر فيه
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زرار نقص
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final current = int.tryParse(controller.text) ?? 1;
                        if (current > 1) {
                          controller.text = (current - 1).toString();
                        }
                        _formKey.currentState?.validate();
                      },
                    ),

                    // خانة الكتابة
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'اكتب رقم الصفحة (1–604)',
                          // نص رسالة الخطأ
                          errorStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'me',
                            height: 1.2, // للتحكم في تباعد السطور
                          ),
                          errorMaxLines: 2, // عدد أسطر الرسالة
                          // حدود الحقل وقت الخطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.grey),
                          ),
                          // حدود الحقل وقت الخطأ وهو فوكس
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.grey),
                          ),
                          // الحدود العادية (اختياري للمقارنة)
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true, // يقلل الارتفاع
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رقم الصفحة مطلوب';
                          }
                          final n = int.tryParse(value);
                          if (n == null) return 'أرقام فقط';
                          if (n < 1 || n > 604) return 'الصفحة بين 1 و 604';
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          // لو المستخدم ضغط Done من الكيبورد
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context, int.parse(controller.text));
                          }
                        },
                      ),
                    ),

                    // زرار زيادة
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final current = int.tryParse(controller.text) ?? 0;
                        if (current < 604) {
                          controller.text = (current + 1).toString();
                        }
                        _formKey.currentState?.validate();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',style: TextStyle(fontFamily: "cairo"),),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:WidgetStatePropertyAll(Colors.indigo) ,
              ),
              onPressed: () {
                // مهم: ما نقفلش غير لو Valid
                if (_formKey.currentState?.validate() ?? false) {
                  final value = int.parse(controller.text);
                  Navigator.pop(context, value);
                }
              },
              child: const Text('اذهب',style: TextStyle(fontFamily: "cairo"),),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != _pageNumber) {
      setState(() => _pageNumber = result);
      await _loadPageAyahs();
    }
  }

  Future<void> _openAyahTafsir(AyahModel ayah) async {
    // ✅ استخدم الحقول اللي موجودة في AyahModel عندك
    final int surahNum = ayah.surahNumber ?? 1;
    final int ayahNum = ayah.ayahNumber ?? 1;

    // اختياري: الرقم الفريد لو موجود—لو مش موجود سيبه 0
    final int ayahUQ = (ayah.ayahUQNumber ?? 0);

    // لو نص الآية عندك باسم مختلف (uthmani / ayahText) غيّر السطر ده
    final String text = (ayah.text ?? '').toString();

    await QuranLibrary().showTafsir(
      context: context,
      surahNum: surahNum,
      ayahNum: ayahNum,
      ayahText: text,
      pageIndex: _pageNumber,
      // << المهم: صفر-مبني
      ayahTextN: text,
      ayahUQNum: ayahUQ,
      ayahNumber: ayahNum,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final names = _ql.tafsirAndTraslationCollection; // List<TafsirNameModel>
    final isDownloaded = _ql.getTafsirDownloaded(_selectedTafsirIndex);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColors,
        appBar: AppBar(
          leading: const CupertinoNavigationBarBackButton(color: Colors.black),
          centerTitle: true,
          title: Text(
            "تفسير الايات",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'اذهب إلى صفحة',
              onPressed: _gotoPageDialog,
              icon: const Icon(Icons.find_in_page),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 8.h),
            // شريط التحكم (اختيار التفسير + التحكم في الصفحة)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              // child: Row(
              //   children: [
              //     // Expanded(
              //     //   child: DecoratedBox(
              //     //     decoration: BoxDecoration(
              //     //       color: Colors.white,
              //     //       borderRadius: BorderRadius.circular(12.r),
              //     //       border: Border.all(color: Colors.black12),
              //     //     ),
              //     //     child: Padding(
              //     //       padding: EdgeInsets.symmetric(horizontal: 8.w),
              //     //       child: DropdownButtonHideUnderline(
              //     //         child: DropdownButton<int>(
              //     //           isExpanded: true,
              //     //           value: _selectedTafsirIndex,
              //     //           icon: _downloading
              //     //               ? const SizedBox(
              //     //             height: 20,
              //     //             width: 20,
              //     //             child: CircularProgressIndicator(strokeWidth: 2),
              //     //           )
              //     //               : const Icon(Icons.arrow_drop_down),
              //     //           items: List.generate(names.length, (i) {
              //     //             final n = names[i];
              //     //             final downloaded = _ql.getTafsirDownloaded(i);
              //     //             final label = n.name ?? n.bookName ?? 'تفسير #$i';
              //     //             return DropdownMenuItem<int>(
              //     //               value: i,
              //     //               child: Row(
              //     //                 children: [
              //     //                   Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              //     //                   const SizedBox(width: 6),
              //     //                   Icon(
              //     //                     downloaded ? Icons.check_circle : Icons.download,
              //     //                     size: 18,
              //     //                     color: downloaded ? Colors.green : Colors.grey,
              //     //                   ),
              //     //                 ],
              //     //               ),
              //     //             );
              //     //           }),
              //     //           onChanged: (val) {
              //     //             if (val == null) return;
              //     //             _onChangeTafsir(val);
              //     //           },
              //     //         ),
              //     //       ),
              //     //     ),
              //     //   ),
              //     // ),
              //     // SizedBox(width: 10.w),
              //   ],
              // ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'الصفحة السابقة',
                    onPressed: () => _changePage(-1),
                    icon: const Icon(Icons.chevron_left, size: 28),
                  ),
                  CircleAvatar(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Column(
                      children: [
                        Text(
                          'صفحة',
                          style: TextStyle(fontFamily: "me"),
                        ),
                        Text(
                          _pageNumber.toString(),
                          style: TextStyle(fontFamily: "me"),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'الصفحة التالية',
                    onPressed: () => _changePage(1),
                    icon: const Icon(Icons.chevron_right, size: 28),
                  ),
                ],
              ),
            ),
            // ملاحظة حالة التنزيل
            if (!isDownloaded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.orange),
                    SizedBox(width: 6),
                    Expanded(
                        child: Text(
                            'قم بتنزيل التفسير أولًا من القائمة لاستخدامه بدون إنترنت')),
                  ],
                ),
              ),
            SizedBox(height: 4.h),

            // قائمة آيات الصفحة — اضغط على أي آية لفتح التفسير
            Expanded(
              child: _pageAyahs.isEmpty
                  ? const Center(child: Text('لا توجد آيات لهذه الصفحة'))
                  : ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      itemCount: _pageAyahs.length,
                      separatorBuilder: (_, __) => const Divider(height: 30),
                      // separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final AyahModel ayah = _pageAyahs[index];

                        final int? s = ayah.surahNumber;
                        final int? a = ayah.ayahNumber;
                        final String ayahLabel = 'س:${s ?? '-'} آ:${a ?? '-'}';

                        // لو نص الآية عندك اسمُه غير text غيّر السطر ده
                        final String ayahText = (ayah.text ?? '').toString();
                        final String ayahNum = (ayah.text ?? '').toString();

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => _openAyahTafsir(ayah),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveUtil.isTablet(context)
                                        ? 40
                                        : 20,
                                    horizontal: 8),
                                width: MediaQuery.sizeOf(context).width,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(13))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text.rich(
                                    textAlign: TextAlign.justify,
                                    TextSpan(
                                        style: TextStyle(
                                            height: 1.6,
                                            fontFamily: "me",
                                            fontSize:
                                                ResponsiveUtil.isTablet(context)
                                                    ? 10.sp
                                                    : 14.sp),
                                        text: ayahText.isNotEmpty
                                            ? ayahText
                                            : ayahLabel,
                                        children: [
                                          TextSpan(
                                            style:
                                                TextStyle(color: Colors.green),
                                            text: ayahText.isNotEmpty
                                                ? ' ' "(${a.toString()})" ' '
                                                : ayahLabel,
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                            // Positioned(
                            //   bottom:  ResponsiveUtil.isTablet(context)?-20:-17,
                            //   right: 0,
                            //   left: 0,
                            //   child: InkWell(
                            //     onTap: () => _openAyahTafsir(ayah),
                            //     child: CircleAvatar(
                            //         radius: ResponsiveUtil.isTablet(context)?15.r:25.r,
                            //         backgroundColor: Colors.white,
                            //         child: const Icon(
                            //           Icons.menu_book_outlined,
                            //           color: Colors.black87,
                            //         )),
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
