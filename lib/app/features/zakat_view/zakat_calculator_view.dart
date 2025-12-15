import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatRecord {
  final String date;
  final double amount;
  final String currency;

  ZakatRecord(
      {required this.date, required this.amount, required this.currency});

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
        'currency': currency,
      };

  factory ZakatRecord.fromJson(Map<String, dynamic> json) => ZakatRecord(
        date: json['date'],
        amount: json['amount'],
        currency: json['currency'],
      );
}

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
  Currency('JOD', 'دينار أردني', 'د.أ'),
  Currency('EUR', 'يورو', '€'),
  Currency('GBP', 'جنية إسترليني', '£'),
  Currency('TRY', 'ليرة تركية', '₺'),
  Currency('DZD', 'دينار جزائري', 'د.ج'),
  Currency('MAD', 'درهم مغربي', 'د.م'),
  Currency('LYD', 'دينار ليبي', 'د.ل'),
  Currency('TND', 'دينار تونسي', 'د.ت'),
  Currency('IQD', 'دينار عراقي', 'د.ع'),
  Currency('LBP', 'ليرة لبناني', 'ل.ل'),
  Currency('SYP', 'ليرة سوري', 'ل.س'),
  Currency('YER', 'ريال يمني', 'ر.ي'),
  Currency('SDG', 'جنية سوداني', 'ج.س'),
];

class ZakatCalculatorView extends StatefulWidget {
  const ZakatCalculatorView({super.key});

  @override
  State<ZakatCalculatorView> createState() => _ZakatCalculatorViewState();
}

class _ZakatCalculatorViewState extends State<ZakatCalculatorView> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // Controllers for Gold Prices
  final TextEditingController _goldPrice21Controller = TextEditingController();
  final TextEditingController _goldPrice18Controller = TextEditingController();
  final TextEditingController _silverPriceController =
      TextEditingController(); // For Silver Nisab

  // Settings
  bool _isGoldStandard = true; // true = Gold (85g), false = Silver (595g)

  // Controllers for Money
  final TextEditingController _moneyController = TextEditingController();

  // Controllers for Assets
  final TextEditingController _stocksController = TextEditingController();
  final TextEditingController _bondsController =
      TextEditingController(); // Or "Securities"
  final TextEditingController _profitsController = TextEditingController();

  // Controllers for Gold Weight
  final TextEditingController _goldWeight18Controller = TextEditingController();
  final TextEditingController _goldWeight21Controller = TextEditingController();

  // Controllers for Silver Weight
  final TextEditingController _silverWeightController = TextEditingController();

  // Controllers for Real Estate
  final TextEditingController _realEstateRentController =
      TextEditingController();

  // Zakat Components
  double _zakatMoney = 0.0;
  double _zakatAssets = 0.0;
  double _zakatGold = 0.0;
  double _zakatSilver = 0.0;
  double _zakatRealEstate = 0.0;

  // Totals
  double _totalZakat = 0.0;
  double _totalWealth = 0.0;
  double _nisabValue = 0.0;

  Currency _selectedCurrency = currencies[0]; // Default to EGP
  List<ZakatRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _calculate(); // Initial calc
    _loadHistory();
  }

  // --- History ---
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('zakat_history');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _history = jsonList.map((e) => ZakatRecord.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveToHistory() async {
    if (_totalZakat <= 0) return;

    final record = ZakatRecord(
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      amount: _totalZakat,
      currency: _selectedCurrency.symbol,
    );

    setState(() {
      _history.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        json.encode(_history.map((e) => e.toJson()).toList());
    await prefs.setString('zakat_history', jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حفظ العملية في السجل")),
    );
  }

  void _showHistorySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "سجل حسابات الزكاة",
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(AppStyle.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _history.isEmpty
                    ? Center(
                        child: Text("لا يوجد سجلات محفوظة",
                            style: GoogleFonts.cairo(color: Colors.grey)),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final record = _history[index];
                          return Card(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.history,
                                  color: Color(AppStyle.primaryColor)),
                              title: Text(
                                "${NumberFormat("#,##0.######", "en_US").format(record.amount)} ${record.currency}",
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp),
                              ),
                              subtitle: Text(record.date,
                                  style: GoogleFonts.cairo(fontSize: 12.sp)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Share ---
  Future<void> _shareResult() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/zakat_result.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)],
          text: 'نتيجة حساب الزكاة من تطبيق رفيق المسلم');
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  // --- Reminder ---
  Future<void> _scheduleReminder() async {
    // Schedule for 354 days later (Hijri year Approx)
    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(days: 354));

    // Ensure we have permission
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 888, // Unique ID for Zakat
          channelKey: 'zakat_reminder_channel',
          title: "تذكير حول الزكاة 💰",
          body:
              "مر عام هجري على حسابك للزكاة، يرجى مراجعة نصابك وإخراج الزكاة إن وجبت.",
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: 9, // Reminder at 9 AM
          minute: 0,
          second: 0,
          repeats: false,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "تم ضبط التذكير بنجاح ليوم ${DateFormat('yyyy-MM-dd').format(scheduledDate)}"),
            backgroundColor: const Color(AppStyle.primaryColor),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ في ضبط التذكير: $e")),
        );
      }
    }
  }

  void _calculate() {
    // 1. Parse Inputs (Remove commas if any)
    double parse(TextEditingController c) {
      String text = c.text.replaceAll(',', '');
      return double.tryParse(text) ?? 0.0;
    }

    double price21 = parse(_goldPrice21Controller);
    double price18 = parse(_goldPrice18Controller);

    double silverPrice = parse(_silverPriceController);

    // ✅ Reset if Mandatory Price is missing
    if (_isGoldStandard) {
      if (price21 <= 0) {
        _nisabValue = 0.0;
        _totalZakat = 0.0;
        setState(() {});
        return;
      }
    } else {
      if (silverPrice <= 0) {
        _nisabValue = 0.0;
        _totalZakat = 0.0;
        setState(() {});
        return;
      }
    }

    double money = parse(_moneyController);

    double stocks = parse(_stocksController);
    double bonds = parse(_bondsController); // Or "Securities"
    double profits = parse(_profitsController);

    double weight18 = parse(_goldWeight18Controller);
    double weight21 = parse(_goldWeight21Controller);
    double weightSilver = parse(_silverWeightController);

    double rentMonthly = parse(_realEstateRentController);

    // 2. Calculate Nisab
    if (_isGoldStandard) {
      _nisabValue = 85 * price21;
    } else {
      _nisabValue = 595 * silverPrice;
    }

    // 3. Calculate Components Wealth
    double moneyZakatable = money;
    double assetsZakatable = stocks + bonds + profits;

    // Gold value
    double goldValue = (weight18 * price18) + (weight21 * price21);

    // Silver value
    double silverValue = weightSilver * silverPrice;

    // Real Estate: Annual Rent
    double realEstateZakatable = rentMonthly * 12;

    _totalWealth = moneyZakatable +
        assetsZakatable +
        goldValue +
        silverValue +
        realEstateZakatable;

    // 4. Calculate Zakat
    if (_totalWealth >= _nisabValue) {
      _zakatMoney = moneyZakatable * 0.025;
      _zakatAssets = assetsZakatable * 0.025;
      _zakatGold = goldValue * 0.025;
      _zakatSilver = silverValue * 0.025;
      _zakatRealEstate = realEstateZakatable * 0.025;

      _totalZakat = _zakatMoney +
          _zakatAssets +
          _zakatGold +
          _zakatSilver +
          _zakatRealEstate;
    } else {
      _zakatMoney = 0.0;
      _zakatAssets = 0.0;
      _zakatGold = 0.0;
      _zakatSilver = 0.0;
      _zakatRealEstate = 0.0;
      _totalZakat = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Determine number format pattern based on decimals
    String formatMoney(double value) {
      if (value == 0) return "0";
      // Allow up to 6 decimal places if needed, remove trailing zeros
      return NumberFormat("#,##0.######", "en_US").format(value);
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "حاسبة الزكاة",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(AppStyle.primaryColor),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          // History Button
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showHistorySheet(isDark),
          ),
          // Currency Dropdown
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(AppStyle.primaryColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Currency>(
                value: _selectedCurrency,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold),
                onChanged: (Currency? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCurrency = newValue;
                    });
                  }
                },
                items: currencies
                    .map<DropdownMenuItem<Currency>>((Currency value) {
                  return DropdownMenuItem<Currency>(
                    value: value,
                    child: Text(value.code + " " + value.symbol),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Summary / Nisab Card ---
            _buildNisabCard(isDark, formatMoney),

            const SizedBox(height: 16),

            // --- Inputs Section ---
            // --- Global Settings (Gold Prices) ---
            _buildSectionCard(
              title: "إعدادات الأسعار (مطلوب)",
              children: [
                // Toggle Standard
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isGoldStandard = true);
                            _calculate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isGoldStandard
                                  ? const Color(AppStyle.primaryColor)
                                  : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "نصاب الذهب (85g)",
                              style: GoogleFonts.cairo(
                                color: _isGoldStandard
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black54),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isGoldStandard = false);
                            _calculate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isGoldStandard
                                  ? const Color(AppStyle.primaryColor)
                                  : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "نصاب الفضة (595g)",
                              style: GoogleFonts.cairo(
                                color: !_isGoldStandard
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black54),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Gold Prices Row
                Row(
                  children: [
                    Expanded(
                        child: Text(
                            "سعر جرام 18 اليوم (${_selectedCurrency.symbol})",
                            style: GoogleFonts.cairo(
                                fontSize: 12.sp, color: Colors.grey[600]),
                            textAlign: TextAlign.center)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            "سعر جرام 21 اليوم (${_selectedCurrency.symbol})",
                            style: GoogleFonts.cairo(
                                fontSize: 12.sp, color: Colors.grey[600]),
                            textAlign: TextAlign.center)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                        child: _buildSmallInput(
                            _goldPrice18Controller, isDark, "أدخل السعر")),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildSmallInput(
                            _goldPrice21Controller, isDark, "أدخل السعر")),
                  ],
                ),

                const SizedBox(height: 12),

                // Silver Price Row
                Text("سعر جرام الفضة اليوم (${_selectedCurrency.symbol})",
                    style: GoogleFonts.cairo(
                        fontSize: 12.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _buildSmallInput(
                      _silverPriceController, isDark, "أدخل سعر جرام الفضة"),
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // --- 1. Money Section ---
            _buildSectionCard(
              title: "زكاة المال",
              children: [
                _buildInputRow(
                  label: "قيمة المال الذي أملكه",
                  controller: _moneyController,
                  isDark: isDark,
                  suffix: _selectedCurrency.name,
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // --- 2. Assets Section ---
            _buildSectionCard(
              title: "زكاة الأصول والممتلكات",
              children: [
                _buildInputRow(
                  label: "قيمة الأسهم التي أمتلكها في السوق",
                  controller: _stocksController,
                  isDark: isDark,
                  suffix: _selectedCurrency.name,
                ),
                _buildInputRow(
                  label: "قيمة السندات التي أمتلكها في السوق",
                  controller: _bondsController,
                  isDark: isDark,
                  suffix: _selectedCurrency.name,
                ),
                _buildInputRow(
                  label: "قيمة الأرباح التي حصلت عليها",
                  controller: _profitsController,
                  isDark: isDark,
                  suffix: _selectedCurrency.name,
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // --- 3. Gold Section ---
            _buildSectionCard(
              title: "زكاة الذهب",
              children: [
                // Weights
                _buildInputRow(
                  label: "وزن الذهب الذي تملكه من عيار 18",
                  controller: _goldWeight18Controller,
                  isDark: isDark,
                  suffix: "الجرام",
                  labelPrefix: "وحدة القياس",
                ),
                _buildInputRow(
                  label: "وزن الذهب الذي تملكه من عيار 21",
                  controller: _goldWeight21Controller,
                  isDark: isDark,
                  suffix: "الجرام",
                  labelPrefix: "وحدة القياس",
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // --- 3b. Silver Section ---
            _buildSectionCard(
              title: "زكاة الفضة",
              children: [
                _buildInputRow(
                  label: "وزن الفضة الذي تملكه",
                  controller: _silverWeightController,
                  isDark: isDark,
                  suffix: "الجرام",
                  labelPrefix: "وحدة القياس",
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // --- 4. Real Estate Section ---
            _buildSectionCard(
              title: "زكاة العقارات المملوكة",
              children: [
                _buildInputRow(
                  label: "قيمة إيجار العقار الشهري الذي امتلكه",
                  controller: _realEstateRentController,
                  isDark: isDark,
                  suffix: _selectedCurrency.name,
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 30),

            // --- Result Breakdown ---
            _buildResultSection(isDark, formatMoney),

            // --- Actions (Share, Save, Reminder) ---
            if (_totalZakat > 0) ...[
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      isDark: isDark,
                      icon: Icons.share,
                      label: "مشاركة",
                      onTap: _shareResult,
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      isDark: isDark,
                      icon: Icons.save,
                      label: "حفظ",
                      onTap: _saveToHistory,
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      isDark: isDark,
                      icon: Icons.alarm,
                      label: "منبه الحول",
                      onTap: _scheduleReminder,
                    ),
                  ],
                ),
              ),
            ],

            // --- Info Text ---
            _buildInfoText(isDark),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppStyle.primaryColor),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.cairo()),
    );
  }

  Widget _buildNisabCard(bool isDark, String Function(double) formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppStyle.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(AppStyle.primaryColor).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _isGoldStandard
                      ? "نصاب الزكاة (85 جرام عيار 21)"
                      : "نصاب الزكاة (595 جرام فضة)",
                  style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(AppStyle.primaryColor))),
              Text(formatter(_nisabValue) + " ${_selectedCurrency.symbol}",
                  style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(AppStyle.primaryColor))),
            ],
          ),
          Icon(Icons.info_outline,
              color: const Color(AppStyle.primaryColor).withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00897B), // Teal-ish color like screenshot
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSmallInput(
      TextEditingController controller, bool isDark, String hint) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [ThousandsSeparatorInputFormatter()],
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD97706)), // Amber color for price
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey.shade400),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(AppStyle.primaryColor))),
          filled: true,
          fillColor: isDark ? Colors.black12 : Colors.white,
        ),
        onChanged: (v) => _calculate(),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required String suffix,
    String? labelPrefix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (labelPrefix != null)
                Text(
                  labelPrefix,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              Expanded(
                child: Text(
                  label,
                  textAlign:
                      labelPrefix != null ? TextAlign.end : TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  suffix,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFFD97706), // Amber text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: InputDecoration(
                      hintText: "القيمة هنا",
                      hintStyle: GoogleFonts.cairo(
                          color: Colors.grey.withOpacity(0.5), fontSize: 12.sp),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                              color: Color(AppStyle.primaryColor))),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.white,
                    ),
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                    onChanged: (v) => _calculate(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(bool isDark, String Function(double) formatter) {
    if (_totalWealth == 0) {
      if (_nisabValue > 0) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "أدخل تفاصيل ممتلكاتك (مال، ذهب، أصول...) لظهور البطاقة",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14.sp),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    bool reachedNisab = _totalWealth >= _nisabValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: const AssetImage(
                  'assets/images/pattern.png'), // Optional: Add a subtle pattern if available
              fit: BoxFit.cover,
              opacity: isDark ? 0.05 : 0.03,
              onError: (_, __) {}, // Ignore if missing
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(AppStyle.primaryColor),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "بطاقة زكاة",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "رفيق المسلم",
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Date
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now()),
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),

              const Divider(height: 30, indent: 40, endIndent: 40),

              // Total Wealth
              _buildReceiptRow(
                  "💰 إجمالي الثروة",
                  "${formatter(_totalWealth)} ${_selectedCurrency.symbol}",
                  isDark),

              // Nisab Status
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      reachedNisab ? Icons.check_circle : Icons.cancel,
                      color: reachedNisab ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reachedNisab
                            ? "بلغ النصاب (تجب الزكاة)"
                            : "لم يبلغ النصاب (لا تجب الزكاة)",
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: reachedNisab ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 30, indent: 40, endIndent: 40),

              if (reachedNisab) ...[
                // Breakdown
                if (_zakatMoney > 0)
                  _buildReceiptRow(
                      "زكاة المال",
                      "${formatter(_zakatMoney)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),
                if (_zakatAssets > 0)
                  _buildReceiptRow(
                      "زكاة الأصول",
                      "${formatter(_zakatAssets)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),
                if (_zakatGold > 0)
                  _buildReceiptRow(
                      "زكاة الذهب",
                      "${formatter(_zakatGold)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),
                if (_zakatSilver > 0)
                  _buildReceiptRow(
                      "زكاة الفضة",
                      "${formatter(_zakatSilver)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),
                if (_zakatSilver > 0)
                  _buildReceiptRow(
                      "زكاة الفضة",
                      "${formatter(_zakatSilver)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),
                if (_zakatRealEstate > 0)
                  _buildReceiptRow(
                      "زكاة العقارات",
                      "${formatter(_zakatRealEstate)} ${_selectedCurrency.symbol}",
                      isDark,
                      isSub: true),

                const Divider(height: 30, indent: 40, endIndent: 40),

                // Total Zakat
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(AppStyle.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(AppStyle.primaryColor)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "قيمة الزكاة المستحقة",
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: const Color(AppStyle.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${formatter(_totalZakat)} ${_selectedCurrency.symbol}",
                        style: GoogleFonts.cairo(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(AppStyle.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
              Text(
                "تقبل الله منا ومنكم صالح الأعمال",
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark,
      {bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSub ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: isSub ? 13.sp : 15.sp,
              color: isSub
                  ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                  : (isDark ? Colors.white : Colors.black87),
              fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isSub ? 13.sp : 15.sp,
              color: isSub
                  ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                  : (isDark ? Colors.white : Colors.black87),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Color(AppStyle.primaryColor)),
              const SizedBox(width: 8),
              Text(
                "كيف تحسب زكاتك؟",
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(AppStyle.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "حاسبة الزكاة على موقع مؤسسة إكرام للتنمية والأعمال الخيرية، تمكنك من حساب قيمة الزكاة الخاصة بك بعد كتابة المال أو المبلغ الذي تملكه بعد تحقق نصاب الزكاة، وكما يمكنك أيضاً من حساب قيمة زكاة الذهب من خلال إدخال مقدار الذهب وبالتالي تتعرف على قيمة الزكاة الواجبة عليها. ويمكنك حساب الزكاة للممتلكات الخاصة بك أو الأسهم أو السندات بكتابة قيمة السهم أو السند، وبعد ذلك يظهر لك قيمة الزكاة الخاصة بها. وتقوم مؤسسة إكرام للتنمية والأعمال الخيرية بصرف زكاة المال الخاصة بك في مصارف الزكاة الشرعية.\n\n* يرجى التواصل مع جهة أو دار فتوى شرعية حتى تتحقق من شروط وضوابط الزكاة الواجبة.",
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanedText = newValue.text.replaceAll(separator, '');

    // Split integer and decimal parts
    List<String> parts = cleanedText.split('.');
    String integerPart = parts[0];

    // Remove leading zeros
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = int.parse(integerPart).toString();
    }

    if (integerPart.isEmpty) integerPart = "0";

    final formatter = NumberFormat("#,##0", "en_US");
    // Handle case where input is just "0" or empty
    String newText = "";
    if (integerPart == "0" && parts.length == 1 && !cleanedText.endsWith('.')) {
      // Allow pure 0
      newText = "0";
    } else {
      newText = formatter.format(int.tryParse(integerPart) ?? 0);
    }

    if (parts.length > 1) {
      newText += "." + parts[1];
    } else if (cleanedText.endsWith('.')) {
      newText += ".";
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
// الزكاة ركنٌ عظيمٌ من أركان الإسلام، وقد خصَّها الله تعالى بمصارف معيَّنة تضمن وصولها إلى مستحقيها، وأكد النبي ﷺ أهميتها بقوله لمعاذ رضي الله عنه: «فَأَخْبِرْهُمْ أَنَّ اللَّهَ قَدْ فَرَضَ عَلَيْهِمْ صَدَقَةً، تُؤْخَذُ مِنْ أَغْنِيَائِهِمْ فَتُرَدُّ عَلَى فُقَرَائِهِمْ». فهي منظومةٌ شرعيةٌ متكاملةٌ للتكافل الاجتماعي، تضمن سدَّ حاجة الفقراء، وتُوجِد روابط الرحمة بين أفراد المجتمع. ويؤدي العمل الخيري -القائم على هذه الفريضة- دورًا بارزًا في الحفاظ على كرامة الإنسان وتجنيبه ذلَّ السؤال والحاجة.
//
// رجاء ملاحظة أنه يتم حساب الزكاة على المبلغ حتى وإن لم يبلغ النصاب؛ والنصاب هو سعر 85 جرام من الذهب عيار 21، مرعليه حولا كاملا
//

