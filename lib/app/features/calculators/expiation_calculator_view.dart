import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import '../../core/shard/widgets/ui_animations.dart';
import 'logic/expiation_logic.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;
  const Currency(this.code, this.name, this.symbol);
}

const List<Currency> currencies = [
  Currency('EGP', 'جنية مصري', 'ج.م'),
  Currency('SAR', 'ريال سعودي', 'ر.س'),
  Currency('USD', 'دولار أمريكي', '\$'),
  Currency('AED', 'درهم إماراتي', 'د.إ'),
  Currency('KWD', 'دينار كويتي', 'د.ك'),
  Currency('QAR', 'ريال قطري', 'ر.ق'),
  Currency('BHD', 'دينار بحريني', 'د.ب'),
  Currency('OMR', 'ريال عماني', 'ر.ع'),
  Currency('JOD', 'دينار أردني', 'د.ا'),
  Currency('LBP', 'ليرة لبناني', 'ل.ل'),
  Currency('SYP', 'ليرة سوري', 'ل.س'),
  Currency('YER', 'ريال يمني', 'ر.ي'),
  Currency('SDG', 'جنية سوداني', 'ج.س'),
];

class ExpiationCalculatorView extends StatefulWidget {
  const ExpiationCalculatorView({super.key});

  @override
  State<ExpiationCalculatorView> createState() =>
      _ExpiationCalculatorViewState();
}

class _ExpiationCalculatorViewState extends State<ExpiationCalculatorView> {
  final TextEditingController _mealPriceController =
      TextEditingController(text: "50");
  final TextEditingController _quantityController =
      TextEditingController(text: "1");
  ExpiationType _selectedType =
      ExpiationType.fasting; // Default to Fidya as per image
  Currency _selectedCurrency = currencies[0]; // Default to SAR as per image

  double _total = 0;
  int _mealsCount = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double price =
        double.tryParse(_mealPriceController.text.replaceAll(',', '')) ?? 0.0;
    int qty = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      _total = ExpiationCalculator.calculate(
        type: _selectedType,
        mealPrice: price,
        quantity: qty,
      );
      // Calculate total meals
      int baseMeals =
          _selectedType == ExpiationType.intentionalFasting ? 60 : 1;
      if (_selectedType == ExpiationType.oath) baseMeals = 10;
      _mealsCount = baseMeals * qty;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor:
        //     isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          centerTitle: true,
          actions: [
            _buildCurrencyDropdown(isDark),
          ],
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: isDark ? Colors.white : Colors.black,
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(
            "حاسبة الكفارات",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "اختر نوع الحساب",
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Type Selection Cards
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      type: ExpiationType.fasting,
                      title: "الفدية",
                      subtitle:
                          "لمن لا يستطيع القيام بعذر دائم (مرض مزمن، كبر سن)",
                      icon: Icons.bakery_dining_outlined,
                      isSelected: _selectedType == ExpiationType.fasting,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      type: ExpiationType.intentionalFasting,
                      title: "الكفارة",
                      subtitle: "لمن أفطر عمداً في رمضان بغير عذر شرعي",
                      icon: Icons.menu_book_outlined,
                      isSelected:
                          _selectedType == ExpiationType.intentionalFasting,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Calculator Card
              StaggeredItemAnimation(
                index: 1,
                child: _buildCalculatorCard(isDark),
              ),

              const SizedBox(height: 16),

              // 3. Info Box "What is Fidya/Kaffara?"
              StaggeredItemAnimation(
                index: 2,
                child: _buildInfoBox(isDark),
              ),

              const SizedBox(height: 16),

              // 4. Comparison Table
              StaggeredItemAnimation(
                index: 3,
                child: _buildComparisonTable(isDark),
              ),

              const SizedBox(height: 16),

              // 5. FAQ Section
              StaggeredItemAnimation(
                index: 4,
                child: _buildFAQSection(isDark),
              ),

              // const SizedBox(height: 32),
              // Text(
              //   "أدوات إسلامية ذات صلة",
              //   style: GoogleFonts.cairo(
              //     fontSize: 14.sp,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey,
              //   ),
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required List<Widget> children,
      required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppThemeColors.cardBorderColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold, fontSize: 16.sp)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTypeOption(ExpiationType type, String label, bool isDark) {
    bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        _calculate();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? KColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? KColors.primaryColor
                  : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.cairo(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected)
              Icon(Icons.check_circle, color: KColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    String? suffix,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: isDark ? Colors.white70 : Colors.black54)),
        const SizedBox(height: 8),
        TextField(

          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            suffixText: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required ExpiationType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        _calculate();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        // height: 140.h,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? KColors.primaryColor.withOpacity(0.2)
                  : const Color(0xFFECFDF5))
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? KColors.primaryColor
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: KColors.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? KColors.primaryColor
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? KColors.primaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 9.sp,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedType == ExpiationType.fasting
                    ? "حاسبة الفدية"
                    : "حاسبة الكفارة",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInputRow(
                    label: "عدد الأيام",
                    controller: _quantityController,
                    isDark: isDark,
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildInputRow(
                    label: "سعر الفدية لليوم",
                    controller: _mealPriceController,
                    isDark: isDark,
                    suffix: _selectedCurrency.symbol,
                    onChanged: (_) => _calculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _selectedType == ExpiationType.fasting
                        ? "مبلغ الفدية الإجمالي"
                        : "مبلغ الكفارة الإجمالي",
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _selectedCurrency.symbol,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        intl.NumberFormat("#,##0").format(_total),
                        style: GoogleFonts.cairo(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "$_mealsCount وجبة بإطعام المساكين",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF334155).withOpacity(0.3)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ما هي الفدية؟",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "الفدية واجبة على من لا يستطيع الصيام بعذر دائم لا يُرجى زواله، مثل:",
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: isDark ? Colors.white70 : const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 4),
          _buildBulletItem(
              "المرض المزمن (السكري، ضغط الدم، السرطان الخ..)", isDark),
          _buildBulletItem("عجز السن، كالشيوخ العجزة عن الصوم.", isDark),
          _buildBulletItem(
              "الحامل والمرضع التي تخاف على ولدها (قضاء وفدية).", isDark),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: isDark ? Colors.white60 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          alignment: AlignmentGeometry.centerRight,
          value: _selectedCurrency,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
          onChanged: (Currency? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCurrency = newValue;
              });
              _calculate();
            }
          },
          items: currencies.map<DropdownMenuItem<Currency>>((Currency value) {
            return DropdownMenuItem<Currency>(
              alignment: AlignmentGeometry.centerRight,
              value: value,
              child: Text(
                textAlign: TextAlign.right,
                value.name,
                style: GoogleFonts.cairo(
                    fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(bool isDark) {
    final double price =
        double.tryParse(_mealPriceController.text.replaceAll(',', '')) ?? 0.0;
    final String priceStr = intl.NumberFormat("#,##0").format(price);
    final String kaffaraPriceStr =
        intl.NumberFormat("#,##0").format(price * 60);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B), // Dark Slate
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(
            "جدول المقارنة",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppThemeColors.cardBackgroundColor(context),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Table(
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            children: [
              _buildTableRow(["البند", "الفدية", "الكفارة"], isHeader: true),
              _buildTableRow(
                  ["السبب", "عذر دائم عن الصيام", "إفطار عمد بدون عذر"]),
              _buildTableRow([
                "المقدار",
                "إطعام مسكين عن كل يوم",
                "إطعام 60 مسكيناً عن كل يوم"
              ]),
              _buildTableRow(["البديل", "لا بديل", "صيام 60 يوماً متتابعاً"]),
              _buildTableRow(["القضاء", "لا يجب", "يجب القضاء أيضاً"]),
              _buildTableRow(
                [
                  "التكلفة التقديرية",
                  "~$priceStr ${_selectedCurrency.symbol}/يوم",
                  "~$kaffaraPriceStr ${_selectedCurrency.symbol}/يوم"
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFF065F46) : null,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: isHeader ? 11.sp : 10.sp,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFAQSection(bool isDark) {
    final faqs = [
      {
        "q": "هل يجوز دفع الفدية نقداً؟",
        "a":
            "نعم، يجوز دفع قيمة الطعام نقداً عند جمهور العلماء، خاصة إذا كان ذلك أنفع للفقير. يمكنك دفعها للجمعيات الخيرية الموثوقة."
      },
      {
        "q": "متى يجب دفع الفدية؟",
        "a":
            "يُستحب دفعها في رمضان أو قبله، لكن يجوز تأخيرها. الأفضل إخراجها يومياً أو دفعها كاملة في بداية الشهر."
      },
      {
        "q": "ماذا لو شُفيت من المرض؟",
        "a":
            "إذا كان العذر مؤقتاً وشُفيت، يجب قضاء الأيام الفائتة. الفدية تكون لمن عذره دائم لا يُرجى زواله."
      },
      {
        "q": "هل الحامل والمرضع تدفع فدية أم تقضي؟",
        "a":
            "اختلف العلماء: الجمهور يرى القضاء فقط، وبعضهم يرى الفدية مع القضاء إذا كان الإفطار خوفاً على الجنين. استشيري عالماً موثوقاً."
      },
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration:  BoxDecoration(
            color:isDark ?KColors.primaryColor.withOpacity(0.2) :const Color(0xFF1E40AF), // Dark Blue
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(
            "أسئلة شائعة",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppThemeColors.cardBackgroundColor(context),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Column(
            children: faqs.map((faq) {
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.blue.withOpacity(0.05),
                  iconColor: Colors.blue,
                  title: Text(
                    faq["q"]!,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color:isDark ?Colors.white: const Color(0xFF1E40AF),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq["a"]!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
