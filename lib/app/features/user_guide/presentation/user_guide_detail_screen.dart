import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../data/model/user_guide_item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:showcaseview/showcaseview.dart';

import '../data/source/user_guide_data.dart';

class UserGuideDetailScreen extends StatefulWidget {
  final UserGuideItem item;

  const UserGuideDetailScreen({super.key, required this.item});

  @override
  State<UserGuideDetailScreen> createState() => _UserGuideDetailScreenState();
}

class _UserGuideDetailScreenState extends State<UserGuideDetailScreen> {
  final GlobalKey _pdfKey = GlobalKey();
  final GlobalKey _favKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();

  bool _isFavorite = false;
  int _currentStep = 0;
  bool? _isHelpful;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _checkShowcaseStatus();
  }

  Future<void> _checkShowcaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShownShowcase =
        prefs.getBool('showcase_user_guide_detail') ?? false;

    if (!hasShownShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          ShowCaseWidget.of(context)
              .startShowCase([_pdfKey, _favKey, _shareKey]);
          prefs.setBool('showcase_user_guide_detail', true);
        } catch (e) {}
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_guides') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.item.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_guides') ?? [];
    if (_isFavorite) {
      favorites.remove(widget.item.id);
    } else {
      favorites.add(widget.item.id);
    }
    await prefs.setStringList('favorite_guides', favorites);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'تمت الإضافة للمفضلة' : 'تم الإزالة من المفضلة',
            style: GoogleFonts.cairo(),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareGuide() {
    final text = 'دليل ميزة: ${widget.item.title}\n\n'
        '${widget.item.description}\n\n'
        '${widget.item.details.replaceAll('•', '- ')}\n\n'
        'تمت المشاركة من تطبيق رفيق المسلم 🌙';
    Share.share(text);
  }

  Future<void> _watchVideo() async {
    if (widget.item.videoUrl != null) {
      final url = Uri.parse(widget.item.videoUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'دليل مستخدم رفيق المسلم',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('الميزة: ${widget.item.title}',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text(widget.item.description,
                    style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Text('التفاصيل:',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(widget.item.details.replaceAll('•', '-'),
                    style: pw.TextStyle(fontSize: 12)),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text('شكراً لاستخدامكم تطبيق رفيق المسلم',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: '${widget.item.id}_guide.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: isDark ? Colors.white : Colors.black,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            actions: [
              Showcase(
                key: _pdfKey,
                description: 'تصدير الشرح كملف PDF للطباعة أو القراءة أوفلاين',
                child: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'تصدير PDF',
                  onPressed: _exportToPdf,
                ),
              ),
              Showcase(
                key: _favKey,
                description:
                    'أضف هذه الميزة للمفضلة للوصول السريع إليها لاحقاً',
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite
                        ? Colors.amber
                        : (isDark ? Colors.white : Colors.black),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
              Showcase(
                key: _shareKey,
                description: 'شارك شرح هذه الميزة مع أصدقائك وأهلك',
                child: IconButton(
                  icon: const Icon(Icons.share),
                  color: isDark ? Colors.white : Colors.black,
                  onPressed: _shareGuide,
                ),
              ),
            ],
            centerTitle: true,
            title: Text(
              widget.item.title,
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.item.requiresInternet ? Icons.wifi : Icons.wifi_off,
                    size: 60,
                    color: widget.item.requiresInternet
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.item.videoUrl != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _watchVideo,
                    icon:
                        const Icon(Icons.play_circle_filled, color: Colors.red),
                    label: Text(
                      'شاهد شرح الفيديو',
                      style: GoogleFonts.cairo(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (widget.item.images != null &&
                  widget.item.images!.isNotEmpty) ...[
                _buildSectionTitle(context, 'معرض الصور'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.item.images!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageDialog(
                            context, widget.item.images![index]),
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              widget.item.images![index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey.withOpacity(0.1),
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle(context, 'حول الميزة'),
              const SizedBox(height: 8),
              Text(
                widget.item.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              if (widget.item.steps != null &&
                  widget.item.steps!.isNotEmpty) ...[
                _buildSectionTitle(context, 'خطوات التنفيذ'),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(primary: Colors.green),
                  ),
                  child: Stepper(
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    onStepContinue: _currentStep < widget.item.steps!.length - 1
                        ? () => setState(() => _currentStep++)
                        : null,
                    onStepCancel: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                    steps: widget.item.steps!
                        .map((step) => Step(
                              title: const SizedBox.shrink(),
                              content: Text(
                                step,
                                style: GoogleFonts.cairo(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              isActive: widget.item.steps!.indexOf(step) <=
                                  _currentStep,
                              state: widget.item.steps!.indexOf(step) <
                                      _currentStep
                                  ? StepState.complete
                                  : StepState.indexed,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle(context, 'تفاصيل إضافية'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  widget.item.details,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'متطلبات التشغيل'),
              const SizedBox(height: 12),
              _buildRequirementInfo(
                context,
                widget.item.requiresInternet
                    ? 'تتطلب هذه الميزة اتصالاً نشطاً بالإنترنت لتعمل بشكل كامل.'
                    : 'هذه الميزة متاحة بالكامل أوفلاين ولا تحتاج إلى إنترنت.',
                widget.item.requiresInternet,
              ),
              const SizedBox(height: 32),
              _buildFeedbackSection(context),
              const SizedBox(height: 32),
              _buildRelatedFeatures(context),
              if (widget.item.routeName != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, widget.item.routeName!);
                    },
                    icon: const Icon(Icons.rocket_launch),
                    label: Text(
                      'جرب الميزة الآن',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'هل كان هذا الشرح مفيداً؟',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (_isHelpful == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeedbackButton(
                    Icons.thumb_up_alt_outlined, 'نعم', Colors.green, () {
                  setState(() => _isHelpful = true);
                }),
                const SizedBox(width: 20),
                _buildFeedbackButton(
                    Icons.thumb_down_alt_outlined, 'لا', Colors.red, () {
                  setState(() => _isHelpful = false);
                }),
              ],
            )
          else
            Text(
              'شكراً لتقييمك! نسعى دائماً للأفضل.',
              style: GoogleFonts.cairo(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(label,
              style:
                  GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRelatedFeatures(BuildContext context) {
    final related = UserGuideData.items
        .where(
            (i) => i.category == widget.item.category && i.id != widget.item.id)
        .take(3)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'ميزات قد تهمك'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final r = related[index];
              return InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserGuideDetailScreen(item: r)),
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child:const Icon(Icons.lightbulb_outline,
                            color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 13),
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
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildRequirementInfo(
      BuildContext context, String text, bool requiresInternet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: requiresInternet
            ? Colors.blue.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: requiresInternet
              ? Colors.blue.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            requiresInternet ? Icons.info_outline : Icons.check_circle_outline,
            color: requiresInternet ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: requiresInternet
                    ? Colors.blue.shade900
                    : Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
