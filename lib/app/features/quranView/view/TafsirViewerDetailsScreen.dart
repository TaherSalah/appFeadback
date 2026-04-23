import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:quran_library/quran.dart';

import '../../../core/utils/style/k_helper.dart';

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
    final names = _ql.tafsirAndTraslationsCollection; // قائمة التفسيرات
    _selectedTafsirIndex = 0; // ابتدائيًا مثلا 0

    // اضبط الصفحة المبدئية
    final startPage = (widget.initialPage != null &&
            widget.initialPage! >= 1 &&
            widget.initialPage! <= 604)
        ? widget.initialPage!
        : (_ql.currentPageNumber >= 1 && _ql.currentPageNumber <= 604
            ? _ql.currentPageNumber
            : 1);

    _pageNumber = startPage;
    await _loadPageAyahs();

    if (mounted) setState(() => _inited = true);
  }

  Future<void> _loadPageAyahs() async {
    final list = _ql.getPageAyahsByPageNumber(pageNumber: _pageNumber);
    _pageAyahs = List<AyahModel>.from(list);
    if (mounted) setState(() {});
  }

  // ✅ dialog تحميل مميز بأسلوب حذف الورد
  void _showDownloadingDialog() {
    final bool isDark = context.isDark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF0A1F12), const Color(0xFF061209)]
                        : [const Color(0xFFF2FFF6), const Color(0xFFE1FFE9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'جاري تحميل التفسير',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cairo',
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يتم الآن تنزيل ملف التفسير.\nيُرجى الانتظار حتى اكتمال التحميل.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'cairo',
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.green.withOpacity(0.07),
                        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1.2),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لن تحتاج إلى تنزيله مجدداً — سيُحفظ على جهازك.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontFamily: 'cairo',
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cloud_download_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onChangeTafsir(int newIndex) async {
    setState(() => _downloading = true);
    try {
      if (!_ql.getTafsirDownloaded(newIndex)) {
        _showDownloadingDialog();
        await _ql.tafsirDownload(newIndex);
        if (mounted) Navigator.of(context).pop();
      }
      _ql.changeTafsirSwitch(newIndex, pageNumber: _pageNumber);
      _selectedTafsirIndex = newIndex;
      setState(() {});
      await _loadPageAyahs();
      if (mounted) {
        KHelper.showSuccess(message:  'تم تفعيل التفسير المختار');

      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        KHelper.showError(message:  'تعذّر تفعيل التفسير: $e');

      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _changePage(int delta) async {
    final next = (_pageNumber + delta).clamp(1, 604);
    if (next == _pageNumber) return;
    setState(() => _pageNumber = next);
    _ql.jumpToPage(next);
    await _loadPageAyahs();
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _gotoPageDialog() async {
    final controller = TextEditingController(text: _pageNumber.toString());
    final bool isDark = context.isDark;

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                        : [const Color(0xFFF0F4F8), const Color(0xFFD9E2EC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'اذهب إلى صفحة',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'أدخل رقم الصفحة (1–604) للانتقال إليها مباشرة.',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dialogCircleButton(
                            icon: Icons.remove,
                            onTap: () {
                              final current = int.tryParse(controller.text) ?? 1;
                              if (current > 1) {
                                controller.text = (current - 1).toString();
                                _formKey.currentState?.validate();
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 110,
                            child: TextFormField(
                              controller: controller,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                  fontFamily: "cairo",
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                filled: true,
                                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                                ),
                                errorStyle: const TextStyle(
                  fontFamily: "cairo",fontSize: 10, height: 0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'مطلوب';
                                final n = int.tryParse(value);
                                if (n == null || n < 1 || n > 604) return '1-604 فقط';
                                return null;
                              },
                              onFieldSubmitted: (v) {
                                if (_formKey.currentState?.validate() ?? false) {
                                  Navigator.pop(dialogContext, int.parse(v));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          _dialogCircleButton(
                            icon: Icons.add,
                            onTap: () {
                              final current = int.tryParse(controller.text) ?? 0;
                              if (current < 604) {
                                controller.text = (current + 1).toString();
                                _formKey.currentState?.validate();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 16,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  Navigator.pop(dialogContext, int.parse(controller.text));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'انتقال',
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.find_in_page_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result != _pageNumber) {
      setState(() => _pageNumber = result);
      _ql.jumpToPage(result);
      await _loadPageAyahs();
    }
  }

  Widget _dialogCircleButton({required IconData icon, required VoidCallback onTap}) {
    final bool isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        ),
      ),
    );
  }

  Future<void> _openAyahTafsir(AyahModel ayah, int index) async {
    final int ayahNum = ayah.ayahNumber;
    final int ayahUQ = ayah.ayahUQNumber ?? 0;
    final String text = ayah.text ?? '';

    await _ql.showTafsir(
      isDark: true,
      context: context,
      ayahNum: index,
      pageIndex: _pageNumber - 1,
      ayahTextN: text,
      ayahUQNum: ayahUQ,
      ayahNumber: ayahNum,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    final isDark = context.isDark;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7F5);
    final cardColor = isDark ? const Color(0xFF161D1B) : Colors.white;
    final isDownloaded = _ql.getTafsirDownloaded(_selectedTafsirIndex);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 70 : 56),
          child: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black87,
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'تفسير الآيات',
                  style: TextStyle(
                  fontFamily: "cairo",
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 14.sp : 17.sp,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFFD4AF37)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'اذهب إلى صفحة',
                onPressed: _gotoPageDialog,
                icon: Icon(
                  Icons.find_in_page_rounded,
                  color: const Color(0xFF4CAF50),
                  size: isTablet ? 20.sp : 24.sp,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      isDark: isDark,
                      onTap: () => _changePage(-1),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'صفحة $_pageNumber',
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: isTablet ? 10.sp : 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      isDark: isDark,
                      onTap: () => _changePage(1),
                    ),
                  ],
                ),
              ),
            ),
            if (!isDownloaded)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'قم بتنزيل التفسير أولاً للاستخدام بدون إنترنت',
                        style: TextStyle(
                  fontFamily: "cairo",fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _pageAyahs.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد آيات لهذه الصفحة',
                        style: TextStyle(
                  fontFamily: "cairo",color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      itemCount: _pageAyahs.length,
                      itemBuilder: (context, index) {
                        final AyahModel ayah = _pageAyahs[index];
                        final int a = ayah.ayahNumber;
                        final String ayahText = (ayah.text ?? '').toString();
                        final String ayahLabel = 'س:${ayah.surahNumber ?? '-'} آ:$a';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: () => _openAyahTafsir(ayah, index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [const Color(0xFF1A2E1C), const Color(0xFF0F1F11)]
                                            : [const Color(0xFFE8F5E9), const Color(0xFFF1F8F1)],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$a',
                                              style: TextStyle(
                  fontFamily: "cairo",
                                                fontSize: isTablet ? 8.sp : 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          ayah.surahNumber != null ? 'سورة رقم ${ayah.surahNumber}' : ayahLabel,
                                          style: TextStyle(
                  fontFamily: "cairo",
                                            fontSize: isTablet ? 8.sp : 11.sp,
                                            color: isDark ? Colors.white54 : Colors.black45,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Icon(Icons.touch_app_rounded, size: 14, color: const Color(0xFF4CAF50).withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'اضغط للتفسير',
                                              style: TextStyle(
                  fontFamily: "cairo",
                                                fontSize: isTablet ? 7.sp : 10.sp,
                                                color: const Color(0xFF4CAF50).withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    child: Text.rich(
                                      textAlign: TextAlign.justify,
                                      TextSpan(
                                        style: TextStyle(
                                          height: isTablet ? 1.7 : 2.0,
                                          fontFamily: 'me',
                                          fontSize: isTablet ? 10.sp : 19.sp,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        text: ayahText.isNotEmpty ? ayahText : ayahLabel,
                                        children: [
                                          TextSpan(
                                            style: TextStyle(
                                              color: const Color(0xFFD4AF37),
                                              fontFamily: 'me',
                                              fontSize: isTablet ? 10.sp : 18.sp,
                                            ),
                                            text: ayahText.isNotEmpty ? ' ﴿$a﴾ ' : '',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE8F5E9),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF4CAF50)),
      ),
    );
  }
}
