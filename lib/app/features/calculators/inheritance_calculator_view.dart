import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/utils/style/responsive_util.dart';
import 'logic/inheritance_logic.dart';
import 'services/inheritance_pdf_service.dart';

class InheritanceCalculatorView extends StatefulWidget {
  const InheritanceCalculatorView({super.key});

  @override
  State<InheritanceCalculatorView> createState() =>
      _InheritanceCalculatorViewState();
}

class _InheritanceCalculatorViewState extends State<InheritanceCalculatorView> {
  // Financial controllers
  final TextEditingController _totalEstateController =
      TextEditingController(text: "0");
  final TextEditingController _debtsController =
      TextEditingController(text: "0");

  Gender _deceasedGender = Gender.male;

  // Wills State
  List<String> _selectedWills = ["لا يوجد", "لا يوجد", "لا يوجد"];
  bool _heirsConsent = false;
  final List<String> _fractionOptions = [
    "لا يوجد",
    "2/3",
    "1/2",
    "1/3",
    "1/4",
    "1/5",
    "1/6",
    "1/7",
    "1/8",
    "1/9",
    "1/10"
  ];

  // Primary Heirs
  int _wives = 0;
  bool _hasHusband = false;
  bool _hasFather = false;
  bool _hasMother = false;
  int _sons = 0;
  int _daughters = 0;

  // Extended Heirs
  int _sonsOfSons = 0;
  int _daughtersOfSons = 0;
  bool _hasPaternalGrandfather = false;
  bool _hasMaternalGrandmother = false;
  bool _hasPaternalGrandmother = false;
  int _fullBrothers = 0;
  int _fullSisters = 0;
  int _consanguineBrothers = 0;
  int _consanguineSisters = 0;
  int _uterineBrothers = 0;
  int _uterineSisters = 0;
  int _nephewsFull = 0;
  int _nephewsConsanguine = 0;
  int _paternalUnclesFull = 0;
  int _paternalUnclesConsanguine = 0;
  int _cousinsFull = 0;
  int _cousinsConsanguine = 0;
  int _grandNephewsFull = 0;
  int _grandNephewsConsanguine = 0;
  int _grandCousinsFull = 0;
  int _grandCousinsConsanguine = 0;
  int _paternalGreatUnclesFull = 0;
  int _paternalGreatUnclesConsanguine = 0;
  int _paternalGreatCousinsFull = 0;
  int _paternalGreatCousinsConsanguine = 0;

  // Special Cases
  bool _isMunasaqhat = false;
  bool _hasObligatoryWill = false;
  bool _isPregnancy = false;
  bool _isHermaphrodite = false;
  bool _isMissingPerson = false;

  String _selectedMadhab = "الجمهور";
  final List<String> _madhabs = [
    "الجمهور",
    "الأحناف",
    "المالكية",
    "الشافعية",
    "الحنابلة",
    "قانون المواريث المصري",
    "نظام الأحوال الشخصية السعودي",
    "قانون الأسرة الجزائري",
    "مدونة الأسرة المغربية",
    "الأحوال الشخصية الأردني",
    "الأحوال الشخصية الإماراتي",
    "القانون العماني",
    "القانون الكويتي",
    "تونس، الصادر عام 1956م",
  ];

  List<DetailedHeirShare> _results = [];
  HeirsInput? _lastInput;

  void _calculate() {
    final input = HeirsInput(
      totalEstate:
          double.tryParse(_totalEstateController.text.replaceAll(',', '')) ??
              0.0,
      debts: double.tryParse(_debtsController.text.replaceAll(',', '')) ?? 0.0,
      willFractions: _selectedWills.where((w) => w != "لا يوجد").toList(),
      heirsConsent: _heirsConsent,
      deceasedGender: _deceasedGender,
      madhab: _selectedMadhab,
      wives: _deceasedGender == Gender.male ? _wives : 0,
      hasHusband: _deceasedGender == Gender.female && _hasHusband,
      hasFather: _hasFather,
      hasMother: _hasMother,
      sons: _sons,
      daughters: _daughters,
      sonsOfSons: _sonsOfSons,
      daughtersOfSons: _daughtersOfSons,
      hasPaternalGrandfather: _hasPaternalGrandfather,
      hasMaternalGrandmother: _hasMaternalGrandmother,
      hasPaternalGrandmother: _hasPaternalGrandmother,
      fullBrothers: _fullBrothers,
      fullSisters: _fullSisters,
      consanguineBrothers: _consanguineBrothers,
      consanguineSisters: _consanguineSisters,
      uterineBrothers: _uterineBrothers,
      uterineSisters: _uterineSisters,
      nephewsFull: _nephewsFull,
      nephewsConsanguine: _nephewsConsanguine,
      paternalUnclesFull: _paternalUnclesFull,
      paternalUnclesConsanguine: _paternalUnclesConsanguine,
      cousinsFull: _cousinsFull,
      cousinsConsanguine: _cousinsConsanguine,
      grandNephewsFull: _grandNephewsFull,
      grandNephewsConsanguine: _grandNephewsConsanguine,
      grandCousinsFull: _grandCousinsFull,
      grandCousinsConsanguine: _grandCousinsConsanguine,
      paternalGreatUnclesFull: _paternalGreatUnclesFull,
      paternalGreatUnclesConsanguine: _paternalGreatUnclesConsanguine,
      paternalGreatCousinsFull: _paternalGreatCousinsFull,
      paternalGreatCousinsConsanguine: _paternalGreatCousinsConsanguine,
      isMunasaqhat: _isMunasaqhat,
      hasObligatoryWill: _hasObligatoryWill,
      isPregnancy: _isPregnancy,
      isHermaphrodite: _isHermaphrodite,
      isMissingPerson: _isMissingPerson,
    );

    setState(() {
      _lastInput = input;
      _results = InheritanceEngine.calculate(input);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor:
        //     isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        // appBar: AppBar(
        //   title: Text("حاسبة المواريث الاحترافية",
        //       style: GoogleFonts.cairo(
        //           fontWeight: FontWeight.bold, fontSize: 18.sp)),
        //   centerTitle: true,
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios),
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ),
        appBar: AppBar(
          centerTitle: true,
          leading: Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: isDark ? Colors.white : Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          )
              : null,
          title: Text(
            "حاسبة المواريث",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              _buildDisclaimerNote(isDark),

              // 1. General & Financial Information
              StaggeredItemAnimation(
                index: 0,
                child: _buildSection(
                  title: "بيانات المتوفى والتركة",
                  isDark: isDark,
                  children: [
                    _buildGenderToggle(isDark),
                    SizedBox(height: 16.h),
                    _buildInputField(
                        "إجمالي قيمة التركة", _totalEstateController, isDark,
                        suffix: "جنية"),
                    SizedBox(height: 12.h),
                    _buildInputField(
                        "الديون المترتبة", _debtsController, isDark,
                        suffix: "جنية"),
                    Divider(
                        height: 24.h,
                        color: KColors.primaryColor.withOpacity(0.1)),
                    Text("الوصايا والمنح",
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize:isTap?8.sp: 15.sp,

                            color: KColors.primaryColor)),
                    SizedBox(height: 12.h),
                    _buildWillDropdown("هل توجد وصية؟", 0),
                    _buildWillDropdown("وصية ثانية؟", 1),
                    _buildWillDropdown("وصية ثالثة؟", 2),
                    SizedBox(height: 8.h),
                    _buildSwitchField(
                        "موافقة الورثة على زيادة الوصية عن الثلث؟",
                        _heirsConsent,
                        (v) => setState(() => _heirsConsent = v)),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 2. Madhab/Law Selection
              StaggeredItemAnimation(
                index: 1,
                child: _buildSection(
                  title: "مذهب التقسيم / القانون المتبع",
                  isDark: isDark,
                  children: [
                    SizedBox(
                      height: 45.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _madhabs
                            .map((m) => Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: ChoiceChip(
                                    label: Text(m,
                                        style:
                                            GoogleFonts.cairo(fontSize:isTap?8.sp: 12.sp)),
                                    selected: _selectedMadhab == m,
                                    selectedColor:
                                        KColors.primaryColor.withOpacity(0.2),
                                    onSelected: (selected) {
                                      if (selected)
                                        setState(() => _selectedMadhab = m);
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 3. Primary Heirs
              StaggeredItemAnimation(
                index: 2,
                child: _buildSection(
                  title: "الورثة الأساسيون",
                  isDark: isDark,
                  children: [
                    if (_deceasedGender == Gender.male)
                      _buildCounterField("عدد الزوجات", _wives,
                          (v) => setState(() => _wives = v),
                          max: 4),
                    if (_deceasedGender == Gender.female)
                      _buildSwitchField("هل الزوج موجود؟", _hasHusband,
                          (v) => setState(() => _hasHusband = v)),
                    _buildSwitchField("هل الأب موجود؟", _hasFather,
                        (v) => setState(() => _hasFather = v)),
                    _buildSwitchField("هل الأم موجودة؟", _hasMother,
                        (v) => setState(() => _hasMother = v)),
                    _buildCounterField("عدد الأبناء (الذكور)", _sons,
                        (v) => setState(() => _sons = v)),
                    _buildCounterField("عدد البنات (الإناث)", _daughters,
                        (v) => setState(() => _daughters = v)),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 4. Extended Heirs
              StaggeredItemAnimation(
                index: 3,
                child: _buildSection(
                  title: "أقارب آخرون (الحواشي والأجداد)",
                  isDark: isDark,
                  children: [
                    _buildCounterField("عدد أبناء الابن", _sonsOfSons,
                        (v) => setState(() => _sonsOfSons = v)),
                    _buildCounterField("عدد بنات الابن", _daughtersOfSons,
                        (v) => setState(() => _daughtersOfSons = v)),
                    if (!_hasFather)
                      _buildSwitchField(
                          "هل الجد للأب موجود؟",
                          _hasPaternalGrandfather,
                          (v) => setState(() => _hasPaternalGrandfather = v)),
                    if (!_hasMother) ...[
                      _buildSwitchField(
                          "هل الجدة للأم موجودة؟",
                          _hasMaternalGrandmother,
                          (v) => setState(() => _hasMaternalGrandmother = v)),
                      _buildSwitchField(
                          "هل الجدة للأب موجودة؟",
                          _hasPaternalGrandmother,
                          (v) => setState(() => _hasPaternalGrandmother = v)),
                    ],
                    ExpansionTile(
                      title: Text("الإخوة والأعمام",
                          style: GoogleFonts.cairo(
                              fontSize:isTap? 10.sp:14.sp, color: KColors.primaryColor)),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(children: [
                              _buildCounterField("أخ لأم", _uterineBrothers,
                                  (v) => setState(() => _uterineBrothers = v)),
                              _buildCounterField("ابن أخ شقيق", _nephewsFull,
                                  (v) => setState(() => _nephewsFull = v)),
                              _buildCounterField(
                                  "ابن ابن أخ شقيق",
                                  _grandNephewsFull,
                                  (v) => setState(() => _grandNephewsFull = v)),
                              _buildCounterField(
                                  "عم شقيق",
                                  _paternalUnclesFull,
                                  (v) =>
                                      setState(() => _paternalUnclesFull = v)),
                              _buildCounterField("ابن عم شقيق", _cousinsFull,
                                  (v) => setState(() => _cousinsFull = v)),
                              _buildCounterField(
                                  "ابن ابن عم شقيق",
                                  _grandCousinsFull,
                                  (v) => setState(() => _grandCousinsFull = v)),
                              _buildCounterField(
                                  "عم الأب (شقيق)",
                                  _paternalGreatUnclesFull,
                                  (v) => setState(
                                      () => _paternalGreatUnclesFull = v)),
                              _buildCounterField(
                                  "ابن عم الأب (شقيق)",
                                  _paternalGreatCousinsFull,
                                  (v) => setState(
                                      () => _paternalGreatCousinsFull = v)),
                            ])),
                            SizedBox(width: 8.w),
                            Expanded(
                                child: Column(children: [
                              _buildCounterField("أخت لأم", _uterineSisters,
                                  (v) => setState(() => _uterineSisters = v)),
                              _buildCounterField(
                                  "ابن أخ لأب",
                                  _nephewsConsanguine,
                                  (v) =>
                                      setState(() => _nephewsConsanguine = v)),
                              _buildCounterField(
                                  "ابن ابن أخ لأب",
                                  _grandNephewsConsanguine,
                                  (v) => setState(
                                      () => _grandNephewsConsanguine = v)),
                              _buildCounterField(
                                  "عم لأب",
                                  _paternalUnclesConsanguine,
                                  (v) => setState(
                                      () => _paternalUnclesConsanguine = v)),
                              _buildCounterField(
                                  "ابن عم لأب",
                                  _cousinsConsanguine,
                                  (v) =>
                                      setState(() => _cousinsConsanguine = v)),
                              _buildCounterField(
                                  "ابن ابن عم لأب",
                                  _grandCousinsConsanguine,
                                  (v) => setState(
                                      () => _grandCousinsConsanguine = v)),
                              _buildCounterField(
                                  "عم الأب (لأب)",
                                  _paternalGreatUnclesConsanguine,
                                  (v) => setState(() =>
                                      _paternalGreatUnclesConsanguine = v)),
                              _buildCounterField(
                                  "ابن عم الأب (من الأب)",
                                  _paternalGreatCousinsConsanguine,
                                  (v) => setState(() =>
                                      _paternalGreatCousinsConsanguine = v)),
                            ])),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 5. Special Cases
              StaggeredItemAnimation(
                index: 4,
                child: _buildSection(
                  title: "حالات ومسائل خاصة",
                  isDark: isDark,
                  children: [
                    _buildCheckboxField(
                        "هل توفى أحد الورثة قبل تقسيم التركة (المناسخات)؟",
                        _isMunasaqhat,
                        (v) => setState(() => _isMunasaqhat = v!)),
                    _buildCheckboxField(
                        "هل يوجد أولاد لابن متوفى أو لبنت متوفاة (وصية واجبة)؟",
                        _hasObligatoryWill,
                        (v) => setState(() => _hasObligatoryWill = v!)),
                    _buildCheckboxField("هل يوجد حَمْل؟", _isPregnancy,
                        (v) => setState(() => _isPregnancy = v!)),
                    _buildCheckboxField(
                        "هل يوجد خُنثى (مُشْكِل) فيمن اخترتهم؟",
                        _isHermaphrodite,
                        (v) => setState(() => _isHermaphrodite = v!)),
                    _buildCheckboxField(
                        "هل يوجد مفقود فيمن اخترتهم؟",
                        _isMissingPerson,
                        (v) => setState(() => _isMissingPerson = v!)),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Calculate & Reset Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: KColors.primaryColor.withOpacity(0.4),
                      ),
                      label: Text("احسب التقسيم",
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: isTap? 10.sp :16.sp,
                              color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _totalEstateController.text = "0";
                          _debtsController.text = "0";
                          _selectedWills = ["لا يوجد", "لا يوجد", "لا يوجد"];
                          _heirsConsent = false;
                          _wives = 0;
                          _hasHusband = false;
                          _hasFather = false;
                          _hasMother = false;
                          _sons = 0;
                          _daughters = 0;
                          _sonsOfSons = 0;
                          _daughtersOfSons = 0;
                          _hasPaternalGrandfather = false;
                          _hasMaternalGrandmother = false;
                          _hasPaternalGrandmother = false;
                          _fullBrothers = 0;
                          _fullSisters = 0;
                          _consanguineBrothers = 0;
                          _consanguineSisters = 0;
                          _uterineBrothers = 0;
                          _uterineSisters = 0;
                          _nephewsFull = 0;
                          _nephewsConsanguine = 0;
                          _paternalUnclesFull = 0;
                          _paternalUnclesConsanguine = 0;
                          _cousinsFull = 0;
                          _cousinsConsanguine = 0;
                          _results = [];
                        });
                      },
                      icon:  Icon(Icons.refresh, size: isTap?20:18),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      label: Text("مسح",
                          style: GoogleFonts.cairo(
                              color: Colors.red.shade700, fontSize: isTap?9.5.sp:14.sp)),
                    ),
                  ),
                ],
              ),

              if (_results.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildResultsSection(isDark),
              ],

              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWillDropdown(String label, int index) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTap = ResponsiveUtil.isTablet(context);


    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: GoogleFonts.cairo(fontSize:isTap?9.5.sp :14.sp))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedWills[index],
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: KColors.primaryColor),
              items: _fractionOptions
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f,
                            style: GoogleFonts.cairo(
                                fontSize:isTap? 8.sp:13.sp, fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedWills[index] = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required List<Widget> children,
      required bool isDark}) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: KColors.primaryColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize:isTap?9.5.sp: 16.sp,

                  color: KColors.primaryColor)),
          Divider(height: 20.h, color: KColors.primaryColor.withOpacity(0.05)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildGenderToggle(bool isDark) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Row(
      children: [
        Text("جنس المتوفى:", style: GoogleFonts.cairo(
          fontSize:isTap?8.8.sp: 14.sp,

        )),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _deceasedGender = Gender.male),
          child:
              _buildGenderOption("ذكر", _deceasedGender == Gender.male, isDark),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => setState(() => _deceasedGender = Gender.female),
          child: _buildGenderOption(
              "أنثى", _deceasedGender == Gender.female, isDark),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, bool isSelected, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? KColors.primaryColor
            : (isDark ? Colors.white10 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: GoogleFonts.cairo(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, bool isDark,
      {String? suffix}) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize:isTap?8.sp: 13.sp
                ,
                color: isDark ? Colors.white70 : Colors.black54)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            suffixText: suffix,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterField(
      String label, int value, Function(int) onValueChange,
      {int max = 100}) {
    final bool isTap = context.isTablet;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: GoogleFonts.cairo(fontSize:isTap? 9.sp:13.sp))),
          Row(
            children: [
              IconButton(
                  onPressed: value > 0 ? () => onValueChange(value - 1) : null,
                  icon: Icon(Icons.remove_circle_outline,
                      color: KColors.primaryColor, size: 20)),
              SizedBox(
                  width:isTap? 25.w:7.w,
                  child: Center(
                      child: Text("$value",
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 13.sp)))),
              IconButton(
                  onPressed:
                      value < max ? () => onValueChange(value + 1) : null,
                  icon: Icon(Icons.add_circle_outline,
                      color: KColors.primaryColor, size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchField(
      String label, bool value, Function(bool) onValueChange) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: GoogleFonts.cairo(fontSize:isTap?8.sp : 13.sp))),
          Transform.scale(
            scale: 0.8,
            child: Switch(
                value: value,
                activeColor: KColors.primaryColor,
                onChanged: onValueChange),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("نتائج تقسيم الميراث",
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: KColors.primaryColor)),
        SizedBox(height: 12.h),
        ..._results.map((res) => _buildResultCard(res, isDark)),
        SizedBox(height: 24.h),
        _buildResultReportTable(isDark),
        _buildIndividualSharesTable(isDark),
        // Center(
        //   child: TextButton.icon(
        //     onPressed: () async {
        //       if (_results.isNotEmpty && _lastInput != null) {
        //         final netEstate = _lastInput!.totalEstate - _lastInput!.debts;
        //         await InheritancePdfService.generateInheritanceReport(
        //           results: _results,
        //           input: _lastInput!,
        //           netEstate: netEstate,
        //         );
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //             content:
        //                 Text("يرجى إجراء الحساب أولاً قبل تصدير التقرير")));
        //       }
        //     },
        //     icon: const Icon(Icons.share, size: 18),
        //     label: Text("مشاركة التقرير كـ PDF",
        //         style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        //   ),
        // ),
        SizedBox(height: 15.h),

        Center(
          child: ElevatedButton.icon(
                onPressed: () async {
                  if (_results.isNotEmpty && _lastInput != null) {
                    final netEstate = _lastInput!.totalEstate - _lastInput!.debts;
                    await InheritancePdfService.generateInheritanceReport(
                      results: _results,
                      input: _lastInput!,
                      netEstate: netEstate,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("يرجى إجراء الحساب أولاً قبل تصدير التقرير")));
                  }
                },
            icon: const Icon(Icons.share, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: KColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 10.w),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: KColors.primaryColor.withOpacity(0.4),
            ),
            label: Text("مشاركة التقرير كـ PDF",
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.white)),
          ),
        ),

      ],
    );
  }

  Widget _buildCheckboxField(
      String label, bool value, Function(bool?) onValueChange) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: KColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onValueChange,
          ),
          Expanded(
              child: Text(label, style: GoogleFonts.cairo(fontSize:isTap?8.5.sp :12.sp))),
        ],
      ),
    );
  }

  Widget _buildResultCard(DetailedHeirShare share, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: share.isAsabah
                ? Colors.orange.withOpacity(0.3)
                : KColors.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(share.name,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text(intl.NumberFormat("#,##0.##").format(share.amount) + " ج.م",
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: KColors.primaryColor,
                      fontSize: 16.sp)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(share.description,
              style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildDisclaimerNote(bool isDark) {
    final bool isTap = ResponsiveUtil.isTablet(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: KColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KColors.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: KColors.primaryColor, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "هذه النتائج استرشادية فقط، ويرجى الرجوع لأهل العلم والاختصاص.",
              textAlign: TextAlign.justify,
              style: GoogleFonts.cairo(
                fontSize:isTap?9.sp: 12.sp,

                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultReportTable(bool isDark) {
    if (_results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Divider(
              color: KColors.primaryColor.withOpacity(0.2), thickness: 2),
        ),
        Text(
          "تقرير توزيع الميراث التفصيلي:",
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: KColors.primaryColor),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KColors.primaryColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: KColors.primaryColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text("الوارث",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold, fontSize: 13.sp))),
                    Expanded(
                        flex: 1,
                        child: Text("نصيبه",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold, fontSize: 13.sp))),
                    Expanded(
                        flex: 3,
                        child: Text("التوضيح",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold, fontSize: 13.sp))),
                  ],
                ),
              ),
              // Table Rows
              ...List.generate(_results.length, (index) {
                final share = _results[index];
                final bool isEven = index % 2 == 0;
                return Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isEven
                        ? (isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.grey.shade50)
                        : Colors.transparent,
                    border: Border(
                      bottom: index == _results.length - 1
                          ? BorderSide.none
                          : BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(share.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600, fontSize: 12.sp)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          decoration: BoxDecoration(
                            color: KColors.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            share.fractionString.isNotEmpty
                                ? share.fractionString
                                : (share.fraction > 0
                                    ? share.fraction.toStringAsFixed(2)
                                    : "0"),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor,
                                fontSize: 12.sp),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(share.description,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualSharesTable(bool isDark) {
    if (_results.isEmpty) return const SizedBox.shrink();

    // Check if any result has numerator/denominator (Tashih logic applied)
    bool hasTashih = _results.any((r) => r.denominator > 0);
    if (!hasTashih) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Divider(
              color: KColors.primaryColor.withOpacity(0.2), thickness: 2),
        ),
        Text(
          "تصحيح المسألة وإخراج نصيب كل فرد:",
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: KColors.primaryColor),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KColors.primaryColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: KColors.primaryColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _tableHeader("الوارث")),
                    Expanded(flex: 1, child: _tableHeader("عدد الأفراد")),
                    Expanded(flex: 2, child: _tableHeader("نصيب الفرد")),
                    Expanded(flex: 2, child: _tableHeader("نصيب الفرد مئويًا")),
                    Expanded(flex: 2, child: _tableHeader("من المال")),
                  ],
                ),
              ),
              // Table Rows
              ...List.generate(_results.length, (index) {
                final share = _results[index];
                final bool isEven = index % 2 == 0;
                final double percentage = share.denominator > 0
                    ? (share.numerator / share.denominator) * 100
                    : 0;

                return Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isEven
                        ? (isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.grey.shade50)
                        : Colors.transparent,
                    border: Border(
                        bottom: index == _results.length - 1
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey.withOpacity(0.1))),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _tableCell(share.name)),
                      Expanded(
                          flex: 1, child: _tableCell(share.count.toString())),
                      Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(share.numerator.toString(),
                                  style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  height: 1,
                                  width: 20,
                                  color:
                                      isDark ? Colors.white30 : Colors.black38),
                              Text(share.denominator.toString(),
                                  style: GoogleFonts.cairo(fontSize: 11.sp)),
                            ],
                          )),
                      Expanded(
                          flex: 2,
                          child: _tableCell("%${percentage.toStringAsFixed(2)}",
                              isPrimary: true)),
                      Expanded(
                          flex: 2,
                          child: _tableCell(
                              intl.NumberFormat("#,##0").format(share.amount),
                              isBold: true)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (_results.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "إجمالي ما تم تقسيمه على الورثة = ",
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                Text(
                  "${intl.NumberFormat("#,##0").format(_results.fold(0.0, (sum, item) => sum + item.amount))} ج.م",
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: KColors.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Text(text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 10.sp));
  }

  Widget _tableCell(String text,
      {bool isPrimary = false, bool isBold = false}) {
    return Text(text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isPrimary ? KColors.primaryColor : null,
        ));
  }
}
