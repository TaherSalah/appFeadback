import 'dart:async';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchKey = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchKey.dispose();
    super.dispose();
  }

  void loadeData({String? searchText}) {
    final query = searchText?.trim() ?? '';
    if (query.isEmpty) {
      setState(() {
        ayah.clear();
      });
      return;
    }

    setState(() {
      ayah = QuranLibrary().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey.text.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtil.isTablet(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenWidth > 600 ? 80 : 60),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CupertinoNavigationBarBackButton(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            title: Text(
              "البحث بالآية",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: screenWidth > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xff05060a),
                      Color(0xff0d1514),
                    ]
                  : const [
                      Color(0xfff4f6f8),
                      Color(0xfffdfcf9),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // الهيدر + حقل البحث
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 18.w : 16,
                    vertical: isTablet ? 8.h : 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 14.w : 12,
                          vertical: isTablet ? 10.h : 8,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white)
                              .withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                          border: Border.all(
                            color: (isDark
                                    ? KColors.primaryColor
                                    : KColors.primary2Color)
                                .withOpacity(0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark
                                        ? KColors.primaryColor
                                        : KColors.primary2Color)
                                    .withOpacity(0.12),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: isTablet ? 18.sp : 22,
                                color: isDark
                                    ? KColors.primaryColor
                                    : KColors.primary2Color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    title: "ابحث داخل القرآن الكريم",
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 9.sp : 14,
                                  ),
                                  const SizedBox(height: 2),
                                  TextWidget(
                                    title:
                                        "اكتب كلمة، جزءًا من آية، أو رقم آية.",
                                    fontSize: isTablet ? 8.sp : 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoSearchTextField(
                        controller: searchKey,
                        itemColor: isDark ? Colors.white : Colors.black54,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: GoogleFonts.cairo().fontFamily,
                          fontSize: isTablet ? 9.sp : 14,
                        ),
                        onSuffixTap: () {
                          searchKey.clear();
                          setState(() {
                            ayah.clear();
                          });
                        },
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xff151515) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark
                                ? KColors.primary.withOpacity(0.6)
                                : KColors.scoColor.withOpacity(0.7),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(0.04),
                            ),
                          ],
                        ),
                        placeholder: "اكتب نص الآية أو كلمة منها",
                        placeholderStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontFamily: GoogleFonts.cairo().fontFamily,
                          fontSize: isTablet ? 8.sp : 13,
                        ),
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce =
                              Timer(const Duration(milliseconds: 450), () {
                            loadeData(searchText: value);
                          });
                        },
                        onSubmitted: (value) => loadeData(searchText: value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // النتائج أو حالة فارغة
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ayah.isNotEmpty
                        ? ListView.separated(
                            key: const ValueKey("results"),
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 18.w : 16,
                              4,
                              isTablet ? 18.w : 16,
                              24,
                            ),
                            itemCount: ayah.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = ayah[index];
                              return _AyaResultCard(
                                ayah: item,
                                onTap: () {
                                  QuranLibrary().jumpToAyah(
                                    item.page,
                                    item.ayahUQNumber,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )
                        : _EmptyState(
                            key: const ValueKey("empty"),
                            query: query,
                            isDark: isDark,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AyaResultCard extends StatelessWidget {
  final AyahModel ayah;
  final VoidCallback onTap;

  const _AyaResultCard({
    required this.ayah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtil.isTablet(context);

    final Color primary = isDark ? KColors.primaryColor : KColors.primary2Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      const Color(0xff0d1017),
                      const Color(0xff171c25),
                    ]
                  : [
                      const Color(0xfffefdf9),
                      const Color(0xfff4f7fb),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              // شريط جانبي كأنه تجليد مصحف
              Positioned.fill(
                left: null,
                right: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primary.withOpacity(0.7),
                          primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // السطر العلوي: رقم الآية + اسم السورة + الصفحة
                    Row(
                      children: [
                        // دائرة رقم الآية
                        Container(
                          width: isTablet ? 36 : 32,
                          height: isTablet ? 36 : 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primary.withOpacity(0.1),
                                primary.withOpacity(0.5),
                              ],
                            ),
                            border: Border.all(
                              color: primary,
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextWidget(
                            title: ayah.ayahNumber.toString(),
                            fontFamily: "me",
                            fontSize: isTablet ? 8.sp : 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // اسم السورة + وصف صغير
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                title: ayah.arabicName.toString(),
                                fontFamily: "me",
                                fontSize: isTablet ? 9.sp : 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 2),
                              TextWidget(
                                title:
                                    "الآية رقم ${ayah.ayahNumber} - صفحة ${ayah.page}",
                                fontSize: isTablet ? 7.sp : 11.sp,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // شارة الصفحة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: primary.withOpacity(0.12),
                            border: Border.all(
                              color: primary.withOpacity(0.7),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: isTablet ? 12.sp : 16,
                                color: primary,
                              ),
                              const SizedBox(width: 4),
                              TextWidget(
                                title: "ص ${ayah.page}",
                                fontSize: isTablet ? 7.sp : 11.sp,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // نص الآية
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isDark
                            ? const Color(0xff11151d)
                            : const Color(0xfffdfcf9),
                        border: Border.all(
                          color: primary.withOpacity(0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        ayah.ayaTextEmlaey,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: "me",
                          fontSize: isTablet ? 9.sp : 15.sp,
                          height: 1.9,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // سطر إرشادي خفيف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.hand_draw,
                              size: isTablet ? 10.sp : 14,
                              color: primary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            TextWidget(
                              title: "اضغط للانتقال إلى هذه الآية",
                              fontSize: isTablet ? 7.sp : 11.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ],
                        ),
                        Icon(
                          CupertinoIcons.chevron_back,
                          size: isTablet ? 10.sp : 14,
                          color: primary.withOpacity(0.9),
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final bool isDark;

  const _EmptyState({
    super.key,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 190,
              width: 190,
              child: Lottie.asset("assets/json/file-searching.json"),
            ),
            const SizedBox(height: 8),
            if (query.isEmpty) ...[
              TextWidget(
                title: "ابدأ بالبحث في آيات القرآن الكريم",
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 9.sp : 16,
              ),
              const SizedBox(height: 4),
              TextWidget(
                title:
                    "اكتب أي كلمة أو جملة؛ وسنُظهر لك المواضع التي وردت في المصحف.",
                fontSize: isTablet ? 8.sp : 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    title: "لا توجد نتائج عن ",
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 9.sp : 15,
                  ),
                  TextWidget(
                    title: query,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KColors.primary : KColors.primary2Color,
                    fontSize: isTablet ? 9.sp : 15,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextWidget(
                title: "حاول استخدام كلمة أخرى أو جزءًا أقصر من الآية.",
                fontSize: isTablet ? 8.sp : 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
