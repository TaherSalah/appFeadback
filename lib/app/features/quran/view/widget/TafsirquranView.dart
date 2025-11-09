import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
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
    // await _ql.initTafsir();
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
  //////***
  // Future<void> _handleDownloadOrOpen(int index) async {
  //   if (_downloading.contains(index)) return;
  //
  //   final isDownloaded = _ql.getTafsirDownloaded(index);
  //
  //   if (isDownloaded) {
  //      _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
  //     if (!mounted) return;
  //     await Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _downloading.add(index));
  //   try {
  //     await _ql.tafsirDownload(index);
  //      _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
  //     if (mounted) {
  //       setState(() {}); // (اختياري لتحديث أيقونة التحميل/الفتح)
  //       await Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (_) => TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
  //         ),
  //       );
  //     }
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
          builder: (_) =>
              TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
        ),
      );
      return;
    }

    setState(() => _downloading.add(index));

    // ✅ Dialog تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Center(
                child: TextWidget(
              title: "جاري التحميل",
              fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
            )),
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    title: "برجاء الانتظار حتى يكتمل تنزيل التفسير",
                    fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                  ),
                  SizedBox(height: 20),
                  KLoading.progressIOSIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await _ql.tafsirDownload(index);
      _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);

      if (mounted) {
        Navigator.of(context).pop(); // يقفل Dialog
        // رسالة نجاح صغيرة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تنزيل التفسير بنجاح")),
        );
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // يقفل Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر تنزيل التفسير: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading.remove(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return Scaffold(
        body: Center(
          child: KLoading.progressIOSIndicator(),
        ),
      );
    }
    String imagePath = "assets/images";
    // مفضّل ناخد الريفرانس مرة
    final ayah = _ql.tafsirAndTraslationsCollection;
    List<String> tafsirImage = [
      "$imagePath/1.jpg",
      "$imagePath/2.jpg",
      "$imagePath/3.jpg",
      "$imagePath/4.jpg",
      "$imagePath/5.jpg",
      "$imagePath/6.jpg",
      // "$imagePath/7.jpg",
      // "$imagePath/8.jpg",
      // "$imagePath/9.jpg",
      // "$imagePath/10.jpg",
      // "$imagePath/11.jpg",
      // "$imagePath/12.jpg",
      // "$imagePath/13.jpg",
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading:
                 CupertinoNavigationBarBackButton(color: Theme.of(context).brightness == Brightness.dark ? Colors.white:Colors.black),
            centerTitle: true,
            title: Text(
              "كتب تفسير القرآن الكريم",
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
                  itemCount: 6,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        ResponsiveUtil.isTablet(context) ? 1 / 1.3 : 1 / 1.8,
                  ),
                  itemBuilder: (context, index) {
                    final isDark = CentralizedCubit.isDarkMode;
                    final isDownloaded = _ql.getTafsirDownloaded(index);
                    final isBusy = _downloading.contains(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
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
                                // color: const Color(0xFFFFFFFF),
                                shadowColor:
                                    KColors.whiteColor.withOpacity(0.6),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: Column(
                                    spacing: 15,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        tafsirImage[index],
                                        fit: BoxFit.fill,
                                        width: MediaQuery.sizeOf(context).width,
                                        height: ResponsiveUtil.isTablet(context)
                                            ? 360
                                            : 210,
                                      ),
                                      TextWidget(
                                        title: ayah[index].name,
                                        // color: isDark
                                        //     ? KColors.scoColor
                                        //     : KColors.primary2Color,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            ResponsiveUtil.isTablet(context)
                                                ? 9.sp
                                                : 13.sp,
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
                                  // backgroundColor: Colors.white,
                                  radius:ResponsiveUtil.isTablet(context)? 25:21,
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
                                        return  Icon(
                                          Icons.open_in_new,
                                          size:ResponsiveUtil.isTablet(context)? 28:22,
                                          // color: Colors.black,
                                        );
                                      }
                                      // ⬇️ لم يُنزّل بعد — أيقونة تنزيل
                                      return  Icon(
                                        Icons.download,
                                        size:ResponsiveUtil.isTablet(context)? 28:22,
                                        // color: Colors.green,
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
