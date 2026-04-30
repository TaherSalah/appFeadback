import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import '../logic/inheritance_logic.dart';

class InheritancePdfService {
  /// Generate and share inheritance report PDF
  static Future<void> generateInheritanceReport({
    required List<DetailedHeirShare> results,
    required HeirsInput input,
    required double netEstate,
  }) async {
    final pdf = pw.Document();

    // Load Fonts
    final fontData =
        await rootBundle.load("assets/fonts/cairo/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData =
        await rootBundle.load("assets/fonts/cairo/Cairo-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    // Load Logo
    final logoImage = await imageFromAssetBundle('assets/images/logoApp.png');

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Center(
                child: pw.Opacity(
                  opacity: 0.15, // زيادة الوضوح لتكون 15% بدلاً من 5%
                  child: pw.Image(logoImage, width: 450), // تكبير الحجم قليلاً وبدون دوران
                ),
              ),
            );
          },
        ),
        header: (context) => _buildHeader(ttfBold, logoImage),

        footer: (context) => _buildFooter(ttf),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildSummarySection(input, netEstate),
          pw.SizedBox(height: 15),
          _buildHeirsInputDetails(input),
          pw.SizedBox(height: 20),
          _buildMainResultsTable(results),
          pw.SizedBox(height: 25),
          _buildIndividualSharesTable(results),
          pw.SizedBox(height: 20),
          _buildFinalSummary(results),
        ],

      ),
    );

    // Shared PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'تقرير_مواريث_${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildHeader(pw.Font boldFont, pw.ImageProvider logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.teal700, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("تقرير تقسيم الميراث الشرعي",
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 22, color: PdfColors.teal900)),
              pw.Text("تطبيق رفيق المسلم اليومي- حاسبة المواريث",
                  style: const pw.TextStyle(
                      fontSize: 14, color: PdfColors.grey700)),
            ],
          ),
          pw.Container(height: 60, width: 60, child: pw.Image(logo)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(HeirsInput input, double netEstate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("بيانات التركة والحالة:",
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("إجمالي التركة:",
                  "${intl.NumberFormat("#,##0").format(input.totalEstate)} ج.م"),
              _summaryItem("الديون المستقطعة:",
                  "${intl.NumberFormat("#,##0").format(input.debts)} ج.م"),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("التركة الصافية:",
                  "${intl.NumberFormat("#,##0").format(netEstate)} ج.م"),
              _summaryItem("المذهب/القانون:", input.madhab),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.SizedBox(width: 5),
        pw.Text(value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  static pw.Widget _buildMainResultsTable(List<DetailedHeirShare> results) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("ملخص توزيع الميراث:",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
          cellAlignment: pw.Alignment.center,
          columnWidths: {
            0: const pw.FlexColumnWidth(2), // Heir
            1: const pw.FlexColumnWidth(1), // Share
            2: const pw.FlexColumnWidth(3), // Description
          },
          headers: ['الوارث', 'النصيب', 'التوضيح الفقهي'],
          data: results
              .map((res) => [
                    res.name,
                    res.fractionString.isNotEmpty
                        ? res.fractionString
                        : res.fraction.toStringAsFixed(3),
                    res.description,
                  ])
              .toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildIndividualSharesTable(
      List<DetailedHeirShare> results) {
    final hasTashih = results.any((r) => r.denominator > 0);
    if (!hasTashih) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("تفصيل نصيب كل فرد (بعد التصحيح):",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
          cellAlignment: pw.Alignment.center,
          headers: [
            'الوارث',
            'العدد',
            'السهم (من أصل)',
            'النسبة',
            'المبلغ المستحق'
          ],
          data: results.map((res) {
            final percentage = res.denominator > 0
                ? (res.numerator / res.denominator) * 100
                : 0;
            return [
              res.name,
              res.count.toString(),
              res.denominator > 0 ? "${res.numerator}/${res.denominator}" : "-",
              "%${percentage.toStringAsFixed(2)}",
              intl.NumberFormat("#,##0").format(res.amount),
            ];
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildFinalSummary(List<DetailedHeirShare> results) {
    final total = results.fold(0.0, (sum, item) => sum + item.amount);
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        "إجمالي المبلغ الموزع: ${intl.NumberFormat("#,##0").format(total)} ج.م",
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 15,
            color: PdfColors.teal900),
      ),
    );
  }

  static pw.Widget _buildHeirsInputDetails(HeirsInput input) {
    final List<String> details = [];

    // Basic Info
    details.add(
        "نوع المتوفى: ${input.deceasedGender == Gender.male ? "ذكر" : "أنثى"}");

    // Heirs
    if (input.wives > 0) details.add("عدد الزوجات: ${input.wives}");
    if (input.hasHusband) details.add("الزوج موجود");
    if (input.hasFather) details.add("الأب موجود");
    if (input.hasMother) details.add("الأم موجودة");
    if (input.sons > 0) details.add("عدد الأبناء: ${input.sons}");
    if (input.daughters > 0) details.add("عدد البنات: ${input.daughters}");

    if (input.sonsOfSons > 0) details.add("أبناء الابن: ${input.sonsOfSons}");
    if (input.daughtersOfSons > 0) {
      details.add("بنات الابن: ${input.daughtersOfSons}");
    }
    if (input.hasPaternalGrandfather) details.add("الجد لأب موجود");
    if (input.hasMaternalGrandmother) details.add("الجدة لأم موجودة");
    if (input.hasPaternalGrandmother) details.add("الجدة لأب موجودة");

    if (input.fullBrothers > 0) details.add("الإخوة الأشقاء: ${input.fullBrothers}");
    if (input.fullSisters > 0) {
      details.add("الأخوات الشقيقات: ${input.fullSisters}");
    }
    if (input.consanguineBrothers > 0) {
      details.add("الإخوة لأب: ${input.consanguineBrothers}");
    }
    if (input.consanguineSisters > 0) {
      details.add("الأخوات لأب: ${input.consanguineSisters}");
    }
    if (input.uterineBrothers > 0) {
      details.add("الإخوة لأم: ${input.uterineBrothers}");
    }
    if (input.uterineSisters > 0) {
      details.add("الأخوات لأم: ${input.uterineSisters}");
    }

    // Extended Heirs (only if count > 0)
    if (input.nephewsFull > 0) details.add("أبناء أخ شقيق: ${input.nephewsFull}");
    if (input.nephewsConsanguine > 0) {
      details.add("أبناء أخ لأب: ${input.nephewsConsanguine}");
    }
    if (input.paternalUnclesFull > 0) details.add("أعمام أشقاء: ${input.paternalUnclesFull}");
    if (input.paternalUnclesConsanguine > 0) {
      details.add("أعمام لأب: ${input.paternalUnclesConsanguine}");
    }
    if (input.cousinsFull > 0) details.add("أبناء عم شقيق: ${input.cousinsFull}");
    if (input.cousinsConsanguine > 0) {
      details.add("أبناء عم لأب: ${input.cousinsConsanguine}");
    }

    // Wills
    if (input.willFractions.isNotEmpty) {
      details.add("الوصية: ${input.willFractions.join(" + ")}");
      if (input.heirsConsent) details.add("موافقة الورثة على الزيادة: نعم");
    }

    if (input.hasObligatoryWill) details.add("توجد وصية واجبة");

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("تفاصيل الورثة والمُدخلات:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 15,
            runSpacing: 8,
            children: details
                .map((d) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(d, style: const pw.TextStyle(fontSize: 10)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Text(
          "تنويه هام: هذه النتائج استرشادية، ويُنصح بالرجوع إلى المختصين ولجان الفتوى أو المحاكم المختصة لاعتماد التقسيم النهائي.\nتقبل الله منكم صالح الأعمال. صادر من تطبيق رفيق المسلم اليومي.",
          style:
              pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
