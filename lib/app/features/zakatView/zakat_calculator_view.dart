import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart'; //
import '../../core/utils/style/app_theme_colors.dart';
import '../../core/utils/style/responsive_util.dart';
import '../messaView/azkar_massa.dart';
import 'zakat_pdf_service.dart';
import 'metal_price_service.dart';
import '../azanView/adhan_workmanager_service.dart';

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
  final TextEditingController _goldPrice24Controller = TextEditingController();
  final TextEditingController _goldPrice21Controller = TextEditingController();
  final TextEditingController _goldPrice18Controller = TextEditingController();
  final TextEditingController _silverPriceController =
      TextEditingController(); // For Silver Nisab

  // Settings
  bool _isGoldStandard = true; // true = Gold (85g), false = Silver (595g)
  bool _isHijriYear = true; // true = 2.5%, false = 2.577%
  bool _isFajrEnabled = true;
  bool _isGoldInvestment = true; // true = Investment (Zakat due), false = Ornament (No Zakat)
  bool _isRealEstateTrading = false; // true = Trading (Market Value), false = Rental (Rent income)
  bool _isSpeculativeStock = true; // true = Speculative (Market Value), false = Dividend (Long term)
  bool _isLoadingPrices = false;
  double _paidZakat = 0.0; // For Zakat Ledger
  final MetalPriceService _metalPriceService = MetalPriceService();

  // Controllers for Money
  final TextEditingController _moneyController = TextEditingController();

  // Controllers for Assets
  final TextEditingController _stocksController = TextEditingController();
  final TextEditingController _bondsController =
      TextEditingController(); // Or "Securities"
  final TextEditingController _profitsController = TextEditingController();
  final TextEditingController _receivablesController = TextEditingController(); // Personal receivables

  // Controllers for Gold Weight
  final TextEditingController _goldWeight18Controller = TextEditingController();
  final TextEditingController _goldWeight21Controller = TextEditingController();
  final TextEditingController _goldWeight24Controller = TextEditingController();

  // Controllers for Silver Weight
  final TextEditingController _silverWeightController = TextEditingController();

  // Controllers for Real Estate
  final TextEditingController _realEstateRentController =
      TextEditingController();
  final TextEditingController _realEstateMarketValueController =
      TextEditingController();

  // Controllers for Zakat al-Fitr
  final TextEditingController _fitrMembersController = TextEditingController();
  final TextEditingController _fitrValueController = TextEditingController();

  // Controllers for Debts & Trade
  final TextEditingController _debtsController = TextEditingController();
  final TextEditingController _tradeGoodsController = TextEditingController();
  final TextEditingController _tradeCashController = TextEditingController();
  final TextEditingController _tradeReceivablesController = TextEditingController();

  // Controllers for Cattle
  final TextEditingController _camelsController = TextEditingController();
  final TextEditingController _cowsController = TextEditingController();
  final TextEditingController _sheepController = TextEditingController();

  // Controllers for Crops
  final TextEditingController _cropsValueController = TextEditingController();
  final TextEditingController _cropsWeightController = TextEditingController(); // Weight in KG
  // 0 = Natural (10%), 1 = Artificial (5%), 2 = Mixed (7.5%)
  int _irrigationMethod = 1;

  // Zakat Components
  double _zakatMoney = 0.0;
  double _zakatAssets = 0.0;
  double _zakatGold = 0.0;
  double _zakatSilver = 0.0;
  double _zakatRealEstate = 0.0;
  double _zakatCrops = 0.0;
  double _zakatFitrTotal = 0.0;
  String _zakatCattleResult = "";

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
    _loadFajrSettings();
  }

  @override
  void dispose() {
    _goldPrice24Controller.dispose();
    _goldPrice21Controller.dispose();
    _goldPrice18Controller.dispose();
    _silverPriceController.dispose();
    _moneyController.dispose();
    _stocksController.dispose();
    _bondsController.dispose();
    _profitsController.dispose();
    _goldWeight18Controller.dispose();
    _goldWeight21Controller.dispose();
    _goldWeight24Controller.dispose();
    _silverWeightController.dispose();
    _realEstateRentController.dispose();
    _fitrMembersController.dispose();
    _fitrValueController.dispose();
    _debtsController.dispose();
    _tradeGoodsController.dispose();
    _camelsController.dispose();
    _cowsController.dispose();
    _sheepController.dispose();
    _cropsValueController.dispose();
    _cropsWeightController.dispose();
    _receivablesController.dispose();
    _tradeCashController.dispose();
    _tradeReceivablesController.dispose();
    _realEstateMarketValueController.dispose();
    super.dispose();
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
      date: intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
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

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("تم حفظ العملية في السجل")),
    // );
    KHelper.showSuccess(message: "تم حفظ العملية في السجل");
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
                                "${intl.NumberFormat("#,##0.######", "en_US").format(record.amount)} ${record.currency}",
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

  // --- PDF ---
  Future<void> _generatePdf() async {
    await ZakatPdfService.generateAndPrint(
      totalWealth: _totalWealth,
      totalZakat: _totalZakat,
      nisabValue: _nisabValue,
      currencySymbol: _selectedCurrency.symbol,
      isHijri: _isHijriYear,
      reachedNisab: (_totalWealth >= _nisabValue && _nisabValue > 0) || _zakatCattleResult.isNotEmpty || _zakatCrops > 0,
      money: (double.tryParse(_moneyController.text.replaceAll(',', '')) ?? 0) + (double.tryParse(_receivablesController.text.replaceAll(',', '')) ?? 0),
      gold: _zakatGold > 0 ? (double.tryParse(_goldWeight24Controller.text) ?? 0) : 0, // Simplified for PDF
      silver: _zakatSilver > 0 ? (double.tryParse(_silverWeightController.text) ?? 0) : 0,
      assets: _zakatAssets,
      realEstate: _zakatRealEstate,
      crops: _zakatCrops,
      cattleDetails: _zakatCattleResult,
      fitrTotal: _zakatFitrTotal,
    );
  }

  // --- Automatic Price Fetch ---
  Future<void> _updatePrices() async {
    setState(() => _isLoadingPrices = true);
    try {
      final prices = await _metalPriceService.fetchPricesInUSD();
      final rate = await _metalPriceService.fetchExchangeRate(_selectedCurrency.code);
      
      setState(() {
        double gold24USD = prices['gold']!;
        double silverUSD = prices['silver']!;
        
        // Convert to selected currency
        double gold24 = gold24USD * rate;
        double silver = silverUSD * rate;

        _goldPrice24Controller.text = _formatValue(gold24);
        _goldPrice21Controller.text = _formatValue(gold24 * (21 / 24));
        _goldPrice18Controller.text = _formatValue(gold24 * (18 / 24));
        _silverPriceController.text = _formatValue(silver);
      });
      
      _calculate();
      KHelper.showSuccess(message: "تم تحديث الأسعار بنجاح طبقاً لسعر الصرف اليوم");
    } catch (e) {
      KHelper.showError(message: e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoadingPrices = false);
    }
  }

  String _formatValue(double val) {
    return intl.NumberFormat("#,##0.##", "en_US").format(val);
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       textAlign: TextAlign.right,
        //         "تم ضبط التذكير بنجاح ليوم ${intl.DateFormat('yyyy-MM-dd').format(scheduledDate)}"),
        //   ),
        // );
        KHelper.showSuccess(
            message:
                "تم ضبط التذكير بنجاح ليوم ${intl.DateFormat('yyyy-MM-dd').format(scheduledDate)}");
      }
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("حدث خطأ في ضبط التذكير: $e")),
        // );
        KHelper.showError(message: "حدث خطأ في ضبط التذكير: $e");
      }
    }
  }

  Future<void> _loadFajrSettings() async {
    final prefs = await AdhanWorkManagerService().getAdhanPreferences();
    if (mounted) {
      setState(() {
        _isFajrEnabled = prefs.getBool('enableFajrAdhan') ?? true;
      });
    }
  }

  Future<void> _toggleFajrAlarm() async {
    setState(() {
      _isFajrEnabled = !_isFajrEnabled;
    });

    await AdhanWorkManagerService().saveAdhanPreferences(
      enableFajrAdhan: _isFajrEnabled,
    );

    KHelper.showSuccess(
      message: _isFajrEnabled ? "تم تفعيل منبه الفجر بنجاح" : "تم إيقاف منبه الفجر",
    );

    // Update background tasks
    await AdhanWorkManagerService().initialize();
  }

  Future<void> _launchGoldPriceUrl() async {
    final Uri url = Uri.parse('https://goldprice.org/live-gold-price.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
      KHelper.showError(message: "تعذر فتح الرابط");
    }
  }

  void _calculate() {
    // 1. Parse Inputs (Remove commas if any)
    double parse(TextEditingController c) {
      String text = c.text.replaceAll(',', '').trim()
          .replaceAll('٠', '0').replaceAll('١', '1').replaceAll('٢', '2')
          .replaceAll('٣', '3').replaceAll('٤', '4').replaceAll('٥', '5')
          .replaceAll('٦', '6').replaceAll('٧', '7').replaceAll('٨', '8')
          .replaceAll('٩', '9');
      return double.tryParse(text) ?? 0.0;
    }

    double price24 = parse(_goldPrice24Controller);
    double price21 = parse(_goldPrice21Controller);
    double price18 = parse(_goldPrice18Controller);
    double silverPrice = parse(_silverPriceController);

    // ✅ Check if Mandatory Price is present for Nisab
    bool hasPrice = _isGoldStandard ? price24 > 0 : silverPrice > 0;

    double money = parse(_moneyController);
    double receivables = parse(_receivablesController);
    double tradeGoods = parse(_tradeGoodsController);
    double tradeCash = parse(_tradeCashController);
    double tradeReceivables = parse(_tradeReceivablesController);
    double debts = parse(_debtsController);

    double stocksValue = parse(_stocksController);
    double bonds = parse(_bondsController);
    double profits = parse(_profitsController);

    double weight18 = parse(_goldWeight18Controller);
    double weight21 = parse(_goldWeight21Controller);
    double weight24 = parse(_goldWeight24Controller);
    double weightSilver = parse(_silverWeightController);

    double rentMonthly = parse(_realEstateRentController);
    double marketValue = parse(_realEstateMarketValueController);

    // Crops inputs
    double cropsValue = parse(_cropsValueController);

    // Cattle inputs
    int parseCattle(String text) {
      String normalized = text.replaceAll(',', '').trim()
          .replaceAll('٠', '0').replaceAll('١', '1').replaceAll('٢', '2')
          .replaceAll('٣', '3').replaceAll('٤', '4').replaceAll('٥', '5')
          .replaceAll('٦', '6').replaceAll('٧', '7').replaceAll('٨', '8')
          .replaceAll('٩', '9');
      return int.tryParse(normalized) ?? 0;
    }
    int camels = parseCattle(_camelsController.text);
    int cows = parseCattle(_cowsController.text);
    int sheep = parseCattle(_sheepController.text);

    // Fitr Inputs
    int fitrMembers = parseCattle(_fitrMembersController.text);
    double fitrValue = parse(_fitrValueController);

    // 2. Calculate Nisabs
    double goldNisabValue = 85 * price24;
    double silverNisabValue = 595 * silverPrice;

    if (_isGoldStandard) {
      _nisabValue = goldNisabValue;
    } else {
      _nisabValue = silverNisabValue;
    }

    // 3. Calculate Components Wealth
    // Net Zakatable Money & Commercial Assets
    double tradeAssets = tradeGoods + tradeCash + tradeReceivables;
    
    // Stocks logic
    // We use stocksValue in both cases because the UI label toggles between Market Value and Dividends
    double zakatableStocks = stocksValue; 

    double personalLiquidAssets = money + receivables + zakatableStocks + bonds + profits;

    // Gold value (Only if for investment/savings)
    double goldValue = 0.0;
    if (_isGoldInvestment) {
      goldValue = (weight18 * price18) + (weight21 * price21) + (weight24 * price24);
    }

    // Silver value
    double silverValue = weightSilver * silverPrice;

    // Real Estate: Rental vs Trading
    double realEstateZakatable = 0.0;
    if (_isRealEstateTrading) {
      realEstateZakatable = marketValue; // Zakat on total current value
    } else {
      realEstateZakatable = rentMonthly * 12; // Zakat on annual rent
    }

    // Total Liquid Wealth excluding debts
    double totalLiquidWealth =
        personalLiquidAssets + tradeAssets + goldValue + silverValue + realEstateZakatable;
    double netWealth = totalLiquidWealth - debts;

    // Ensure negative net wealth is zero
    if (netWealth < 0) netWealth = 0;

    _totalWealth = netWealth;

    // Determine Zakat Percentage
    double zakatPercentage = _isHijriYear ? 0.025 : 0.02577;

    // 4. Calculate Zakat
    if (hasPrice) {
      // "Lower Nisab" Principle
      double effectiveNisab = _nisabValue;
      bool reachedEffectiveNisab = _totalWealth >= effectiveNisab;

      if (reachedEffectiveNisab) {
        _totalZakat = netWealth * zakatPercentage;
        _zakatMoney = (money + receivables) * zakatPercentage;
        _zakatAssets = (tradeAssets + zakatableStocks + bonds) * zakatPercentage;
        _zakatGold = goldValue * zakatPercentage;
        _zakatSilver = silverValue * zakatPercentage;
        _zakatRealEstate = realEstateZakatable * zakatPercentage;
      } else {
        _zakatMoney = 0.0;
        _zakatAssets = 0.0;
        _zakatGold = 0.0;
        _zakatSilver = 0.0;
        _zakatRealEstate = 0.0;
        _totalZakat = 0.0;
      }
    } else {
      // Clear Zakat amounts if price is missing
      _totalZakat = 0.0;
      _zakatMoney = 0.0;
      _zakatAssets = 0.0;
      _zakatGold = 0.0;
      _zakatSilver = 0.0;
      _zakatRealEstate = 0.0;
      _nisabValue = 0.0;
    }

    // 5. Crops Zakat
    double cropsRate = 0.10; // Natural
    if (_irrigationMethod == 1) {
      cropsRate = 0.05; // Artificial
    } else if (_irrigationMethod == 2) cropsRate = 0.075; // Mixed

    double cropsWeight = parse(_cropsWeightController);
    // Nisab for crops is 5 Awsuq ≈ 653 KG
    if (cropsWeight >= 653 && cropsValue > 0) {
      _zakatCrops = cropsValue * cropsRate;
      _totalZakat += _zakatCrops;
    } else {
      _zakatCrops = 0.0;
    }

    // 6. Cattle Zakat
    _zakatCattleResult = _calculateCattleZakat(camels, cows, sheep);

    // 7. Zakat al-Fitr
    if (fitrMembers > 0 && fitrValue > 0) {
      _zakatFitrTotal = fitrMembers * fitrValue;
    } else {
      _zakatFitrTotal = 0.0;
    }

    setState(() {});
  }

  void _resetValues() {
    _nisabValue = 0.0;
    _totalZakat = 0.0;
    _zakatCrops = 0.0;
    _zakatFitrTotal = 0.0;
    _zakatCattleResult = "";
    _paidZakat = 0.0;
    setState(() {});
  }

  void _resetAll() {
    _moneyController.clear();
    _stocksController.clear();
    _bondsController.clear();
    _profitsController.clear();
    _goldWeight18Controller.clear();
    _goldWeight21Controller.clear();
    _goldWeight24Controller.clear();
    _goldPrice24Controller
        .clear(); // Clear price too if needed, or keep it? Better clear for "Reset All"
    _silverWeightController.clear();
    _realEstateRentController.clear();
    _cropsValueController.clear();
    _tradeGoodsController.clear();
    _debtsController.clear();
    _camelsController.clear();
    _cowsController.clear();
    _sheepController.clear();
    _fitrMembersController.clear();
    _fitrValueController.clear();
    _cropsWeightController.clear();
    _receivablesController.clear();
    _tradeCashController.clear();
    _tradeReceivablesController.clear();
    _realEstateMarketValueController.clear();
    _realEstateRentController.clear();
    _realEstateMarketValueController.clear();

    _irrigationMethod = 1; // Reset to default

    _resetValues();
    _calculate(); // Recalculate to zero everything out

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("تم تصفير جميع القيم")),
    // );
    KHelper.showSuccess(message: "تم تصفير جميع القيم");
  }

  void _showZakatChannelsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        "مصارف الزكاة الشرعية",
                        style: GoogleFonts.cairo(
                            fontSize: ResponsiveUtil.isTablet(context)?10.sp: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(AppStyle.primaryColor)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(AppStyle.primaryColor)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "۞ إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ ۖ فَرِيضَةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَكِيمٌ ۞",
                          style:
                              GoogleFonts.amiri(fontSize:  ResponsiveUtil.isTablet(context)?12.sp:16.sp, height: 1.8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildChannelItem(isDark, "1. الفقراء",
                          "هم من لا يملكون شيئاً، أو يملكون أقل من نصف كفايتهم."),
                      _buildChannelItem(isDark, "2. المساكين",
                          "هم من يملكون نصف كفايتهم أو أكثر، ولكن لا يملكون ما يكفيهم."),
                      _buildChannelItem(isDark, "3. العاملين عليها",
                          "هم السعاة والجباة الذين يعينهم الحاكم لجمع الزكاة وتوزيعها."),
                      _buildChannelItem(isDark, "4. المؤلفة قلوبهم",
                          "هم الذين يُراد تأليف قلوبهم للإسلام، أو تثبيتهم عليه."),
                      _buildChannelItem(isDark, "5. في الرقاب",
                          "هم الأرقاء والمكاتبون الذين يريدون شراء حريتهم (غير موجود حالياً)."),
                      _buildChannelItem(isDark, "6. الغارمين",
                          "هم المدينون الذين عجزوا عن سداد ديونهم."),
                      _buildChannelItem(isDark, "7. في سبيل الله",
                          "هم المجاهدون في سبيل الله، ويدخل فيه الدعوة إلى الله وكل خير يعود نفعه على المسلمين."),
                      _buildChannelItem(isDark, "8. ابن السبيل",
                          "هو المسافر المنقطع عن بلده وماله."),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyConverter(TextEditingController targetController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.cardBackgroundColor(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _CurrencyConverterSheet(
            targetController: targetController,
            baseCurrency: _selectedCurrency,
          ),
        );
      },
    );
  }

  Widget _buildChannelItem(bool isDark, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: ResponsiveUtil.isTablet(context)?10.sp:14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
          Text(description,
              style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey)),
          const Divider(),
        ],
      ),
    );
  }

  String _calculateCattleZakat(int camels, int cows, int sheep) {
    List<String> parts = [];

    // Camels
    if (camels >= 5) {
      String due = "";
      if (camels < 10) {
        due = "شاة واحدة";
      } else if (camels < 15)
        due = "شاتان";
      else if (camels < 20)
        due = "3 شياه";
      else if (camels < 25)
        due = "4 شياه";
      else if (camels < 36)
        due = "بنت مخاض (أنثى إبل سنة)";
      else if (camels < 46)
        due = "بنت لبون (أنثى إبل سنتين)";
      else if (camels < 61)
        due = "حقة (أنثى إبل 3 سنوات)";
      else if (camels < 76)
        due = "جذعة (أنثى إبل 4 سنوات)";
      else if (camels < 91)
        due = "بنتا لبون";
      else if (camels < 121)
        due = "حقتان";
      else
        due = "ثلاث بنات لبون (أو أكثر حسب العدد)";
      parts.add("الإبل ($camels): $due");
    }

    // Cows
    if (cows >= 30) {
      String due = "";
      if (cows < 40) {
        due = "تبيع (سنة)";
      } else if (cows < 60)
        due = "مسنة (سنتين)";
      else {
        int tabia = cows ~/ 30;
        int musinna = (cows % 30) ~/ 40; // Simplified
        due = "تبيع عن كل 30 ومسنة عن كل 40";
      }
      parts.add("البقر ($cows): $due");
    }

    // Sheep
    if (sheep >= 40) {
      String due = "";
      if (sheep < 121) {
        due = "شاة واحدة";
      } else if (sheep < 201)
        due = "شاتان";
      else if (sheep < 400)
        due = "3 شياه";
      else
        due = "شاة عن كل 100";

      parts.add("الغنم ($sheep): $due");
    }

    return parts.join("\n");
  }

  Widget _buildCattleResultCards(bool isDark) {
    int parseCattle(String text) {
      String normalized = text.replaceAll(',', '').trim()
          .replaceAll('٠', '0').replaceAll('١', '1').replaceAll('٢', '2')
          .replaceAll('٣', '3').replaceAll('٤', '4').replaceAll('٥', '5')
          .replaceAll('٦', '6').replaceAll('٧', '7').replaceAll('٨', '8')
          .replaceAll('٩', '9');
      return int.tryParse(normalized) ?? 0;
    }
    int camels = parseCattle(_camelsController.text);
    int cows = parseCattle(_cowsController.text);
    int sheep = parseCattle(_sheepController.text);

    List<Widget> cards = [];

    if (camels >= 5) cards.add(_buildCattleItemCard(isDark, "إبل", camels, _getCamelDue(camels), Icons.pets));
    if (cows >= 30) cards.add(_buildCattleItemCard(isDark, "بقر", cows, _getCowDue(cows), Icons.pets));
    if (sheep >= 40) cards.add(_buildCattleItemCard(isDark, "غنم", sheep, _getSheepDue(sheep), Icons.pets));

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(children: cards);
  }

  Widget _buildCattleItemCard(bool isDark, String type, int count, String due, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.amber.withOpacity(0.05) : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.amber.shade800, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$type (العدد: $count)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                Text("المستخرج شرعاً: $due", style: GoogleFonts.cairo(color: Colors.amber.shade900, fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getCamelDue(int n) {
    if (n < 5) return "لا زكاة";
    if (n < 10) return "شاة واحدة";
    if (n < 15) return "شاتان";
    if (n < 20) return "3 شياه";
    if (n < 25) return "4 شياه";
    if (n < 36) return "بنت مخاض (سنة)";
    if (n < 46) return "بنت لبون (سنتين)";
    if (n < 61) return "حقة (3 سنوات)";
    if (n < 76) return "جذعة (4 سنوات)";
    if (n < 91) return "بنتا لبون";
    if (n < 121) return "حقتان";
    return "3 بنات لبون";
  }

  String _getCowDue(int n) {
     if (n < 30) return "لا زكاة";
     if (n < 40) return "تبيع (ذو سنة)";
     if (n < 60) return "مسنة (ذات سنتين)";
     return "تبيع عن كل 30 ومسنة عن كل 40";
  }

  String _getSheepDue(int n) {
    if (n < 40) return "لا زكاة";
    if (n < 121) return "شاة واحدة";
    if (n < 201) return "شاتان";
    if (n < 400) return "3 شياه";
    return "شاة عن كل 100";
  }

  void _showProfessionalZakatGuide(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text("زكاة المهن الحرة والرواتب 💼", style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold, color: KColors.primaryColor)),
                    const SizedBox(height: 16),
                    _buildGuideItem(
                      "كيف أحسب زكاة دخلي الشهري؟",
                      "إذا كنت تمتلك دخلاً متغيراً أو راتباً شهرياً، هناك طريقتان لحساب الزكاة:",
                    ),
                    _buildGuideItem(
                      "الطريقة الأولى (الأسهل):",
                      "أن تحدد يوماً واحداً في السنة (مثلاً 1 رمضان) وتحسب كل ما تملكه في هذا اليوم وتخرج عنه 2.5% إذا بلغ النصاب، بغض النظر عن وقت دخول كل مبلغ.",
                    ),
                    _buildGuideItem(
                      "الطريقة الثانية (الأدق):",
                      "أن تخرج الزكاة عن كل مبلغ ادخرته بعد مرور سنة قمرية كاملة (حول) على ملكك له. وهذا يتطلب سجلاً دقيقاً لكل شهر.",
                    ),
                    _buildGuideItem(
                      "ملاحظة هامة:",
                      "الزكاة تجب على (المبلغ المدخر) الفائض عن حاجتك الأصلية الذي بلغ النصاب وحال عليه الحول، وليس على إجمالي الراتب الذي تنفقه شهرياً.",
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: KColors.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                      child: Text("فهمت، شكراً", style: GoogleFonts.cairo()),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          const SizedBox(height: 4),
          Text(content, style: GoogleFonts.cairo(fontSize: 13.sp, height: 1.5, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine number format pattern based on decimals
    String formatMoney(double value) {
      if (value == 0) return "0";
      // Allow up to 6 decimal places if needed, remove trailing zeros
      return intl.NumberFormat("#,##0.######", "en_US").format(value);
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => _showHistorySheet(isDark),
            ),

            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: "تصفير الكل",
              onPressed: _resetAll,
            ),
          ],
          title: Text(
            "حاسبة الزكاة",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // --- Summary / Nisab Card ---
              _buildNisabCard(isDark, formatMoney),

              const SizedBox(height: 16),

              _buildSectionCard(
                title: "إعدادات عملة البلد",
                isDark: isDark,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(AppStyle.primaryColor).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.currency_exchange, color: Color(AppStyle.primaryColor), size: 20),
                      ),
                      title: Text(
                        "العملة الحالية",
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: AppThemeColors.cardBackgroundColor(context),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Currency>(
                            dropdownColor: AppThemeColors.cardBackgroundColor(context),
                            value: _selectedCurrency,
                            icon: Icon(Icons.keyboard_arrow_down, 
                                color: isDark ? Colors.white70 : Colors.black54),
                            style: GoogleFonts.cairo(
                                color: const Color(AppStyle.primaryColor), 
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp),
                            onChanged: (Currency? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCurrency = newValue;
                                });
                                _calculate(); // Recalculate if needed
                              }
                            },
                            items: currencies
                                .map<DropdownMenuItem<Currency>>((Currency value) {
                              return DropdownMenuItem<Currency>(
                                value: value,
                                child: Text("${value.code} (${value.symbol})"),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Inputs Section ---
              // --- Global Settings (Gold Prices) ---
              _buildSectionCard(
                title: "إعدادات الأسعار (مطلوب)",
                children: [
                   // Update Prices Button
                  InkWell(
                    onTap: _isLoadingPrices ? null : _updatePrices,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: KColors.primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoadingPrices)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                             Icon(Icons.cloud_download_outlined, color: KColors.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isLoadingPrices ? "جاري التحديث..." : "تحديث الأسعار تلقائياً للان",
                            style: GoogleFonts.cairo(
                              color: KColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                    ? KColors.primaryColor
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
                                  fontSize:ResponsiveUtil.isTablet(context)?9.5.sp:  12.sp,
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
                                    ? KColors.primaryColor
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
                                  fontSize: ResponsiveUtil.isTablet(context)?9.5.sp:12.sp,
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
                  Text("أسعار الذهب (الجرام) - أدخل عيار 24 لحساب النصاب",
                      style: GoogleFonts.cairo(
                          fontSize: ResponsiveUtil.isTablet(context)?8.sp:12.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Text("عيار 24 (للنصاب)",
                              style: GoogleFonts.cairo(
                                  fontSize:ResponsiveUtil.isTablet(context)?8.sp: 10.sp, color: Colors.amber[800])),
                          const SizedBox(height: 4),
                          _buildSmallInput(
                              _goldPrice24Controller, isDark, "سعر 24"),
                        ],
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                        children: [
                          Text("عيار 21",
                              style: GoogleFonts.cairo(
                                  fontSize: ResponsiveUtil.isTablet(context)?8.sp:10.sp, color: Colors.grey)),
                          const SizedBox(height: 4),
                          _buildSmallInput(
                              _goldPrice21Controller, isDark, "سعر 21"),
                        ],
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                        children: [
                          Text("عيار 18",
                              style: GoogleFonts.cairo(
                                  fontSize:ResponsiveUtil.isTablet(context)?8.sp: 10.sp, color: Colors.grey)),
                          const SizedBox(height: 4),
                          _buildSmallInput(
                              _goldPrice18Controller, isDark, "سعر 18"),
                        ],
                      )),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Silver Price Row
                  Text("سعر جرام الفضة اليوم (${_selectedCurrency.symbol})",
                      style: GoogleFonts.cairo(
                          fontSize:ResponsiveUtil.isTablet(context)?8.sp: 12.sp, color: Colors.grey[600]),
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

              // --- Year Type Toggle ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppThemeColors.cardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("نوع الحول (العام)",
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize:ResponsiveUtil.isTablet(context)?10.sp:  13.sp,
                                color: isDark ? Colors.white : Colors.black87)),
                        Text(_isHijriYear ? "هجري (2.5%)" : "ميلادي (2.577%)",
                            style: GoogleFonts.cairo(
                                fontSize:ResponsiveUtil.isTablet(context)?7.sp:  11.sp, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildToggleBtn("هجري", _isHijriYear, () {
                          setState(() => _isHijriYear = true);
                          _calculate();
                        }),
                        const SizedBox(width: 8),
                        _buildToggleBtn("ميلادي", !_isHijriYear, () {
                          setState(() => _isHijriYear = false);
                          _calculate();
                        }),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- 1. Money Section ---
              _buildSectionCard(
                title: "زكاة المال",
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ملاحظة: لا تجب الزكاة في الحاجات الأصلية كالمسكن الشخصي، السيارات، والأثاث.",
                            style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInputRow(
                    label: "الأموال النقدية (كاش/بنك)",
                    controller: _moneyController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                    trailing: IconButton(
                      icon: Icon(Icons.help_outline, size: 20, color: KColors.primaryColor),
                      onPressed: () => _showProfessionalZakatGuide(isDark),
                      tooltip: "كيف أحسب زكاة راتبي/مهنتي؟",
                    ),
                  ),
                  _buildInputRow(
                    label: "مبالغ مستحقة لك عند الغير (ديون جيدة)",
                    controller: _receivablesController,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("طبيعة الاستثمار:", style: GoogleFonts.cairo(fontSize: 12.sp)),
                        Row(
                          children: [
                            _buildToggleBtn("مضاربة", _isSpeculativeStock, () {
                              setState(() => _isSpeculativeStock = true);
                              _calculate();
                            }),
                            const SizedBox(width: 8),
                            _buildToggleBtn("استثمار طويل", !_isSpeculativeStock, () {
                              setState(() => _isSpeculativeStock = false);
                              _calculate();
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildInputRow(
                    label: _isSpeculativeStock ? "القيمة السوقية للأسهم" : "إجمالي الأرباح الموزعة",
                    controller: _stocksController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  _buildInputRow(
                    label: "قيمة السندات التي أمتلكها",
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

              // --- 2.2 Trade & Debts ---
              _buildSectionCard(
                title: "زكاة عروض التجارة والديون",
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ملاحظة: زكاة التجارة على (الكاش + البضائع بسعر البيع + الديون الجيدة). الأصول الثابتة (أثاث، مبيعات، ماكينات) لا زكاة عليها.",
                            style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInputRow(
                    label: "الكاش الموجود في النشاط التجاري",
                    controller: _tradeCashController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  _buildInputRow(
                    label: "قيمة البضائع (بسعر البيع الحالي)",
                    controller: _tradeGoodsController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  _buildInputRow(
                    label: "مبالغ مستحقة للنشاط عند العملاء",
                    controller: _tradeReceivablesController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  _buildInputRow(
                    label: "الديون والالتزامات للغير (تُخصم)",
                    controller: _debtsController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                    isNegative: true,
                  ),
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // --- 3. Gold Section ---
              _buildSectionCard(
                title: "زكاة الذهب",
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Text("غرض اقتناء الذهب:",
                            style: GoogleFonts.cairo(fontSize: 12.sp)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToggleBtn("ادخار/استثمار", _isGoldInvestment, () {
                              setState(() => _isGoldInvestment = true);
                              _calculate();
                            }),
                            const SizedBox(width: 8),
                            _buildToggleBtn("زينة شخصية", !_isGoldInvestment, () {
                              setState(() => _isGoldInvestment = false);
                              _calculate();
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_isGoldInvestment)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "ملاحظة: ذهب الزينة المعتاد لا زكاة فيه عند جمهور الفقهاء. إذا كان الوزن كبيراً جداً (خارج المعتاد) يُفضل احتسابه كادخار.",
                          style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.blue.shade800),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Weights
                  _buildInputRow(
                    label: "وزن الذهب عيار 24",
                    controller: _goldWeight24Controller,
                    isDark: isDark,
                    suffix: "جرام",
                    labelPrefix: "السبائك الخالصة",
                  ),
                  _buildInputRow(
                    label: "وزن الذهب عيار 21",
                    controller: _goldWeight21Controller,
                    isDark: isDark,
                    suffix: "جرام",
                    labelPrefix: "المشغولات",
                  ),
                  _buildInputRow(
                    label: "وزن الذهب عيار 18",
                    controller: _goldWeight18Controller,
                    isDark: isDark,
                    suffix: "جرام",
                    labelPrefix: "المشغولات",
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
                title: "زكاة العقارات والأراضي",
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("نوع العقار:", style: GoogleFonts.cairo(fontSize: 12.sp)),
                        Row(
                          children: [
                            _buildToggleBtn("للإيجار", !_isRealEstateTrading, () {
                              setState(() => _isRealEstateTrading = false);
                              _calculate();
                            }),
                            const SizedBox(width: 8),
                            _buildToggleBtn("للمتاجرة", _isRealEstateTrading, () {
                              setState(() => _isRealEstateTrading = true);
                              _calculate();
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_isRealEstateTrading)
                    _buildInputRow(
                      label: "متوسط الإيجار الشهري للعقار",
                      controller: _realEstateRentController,
                      isDark: isDark,
                      suffix: _selectedCurrency.name,
                    )
                  else
                    _buildInputRow(
                      label: "القيمة السوقية الحالية للعقار",
                      controller: _realEstateMarketValueController,
                      isDark: isDark,
                      suffix: _selectedCurrency.name,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isRealEstateTrading 
                                ? "المتاجرة: زكاتك على القيمة الإجمالية." 
                                : "للإيجار: زكاتك على صافي الإيراد السنوي.",
                              style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // --- 5. Crops Section ---
              _buildSectionCard(
                title: "زكاة الزروع والثمار",
                children: [
                  Text(
                    "تختلف النسبة حسب طريقة الري",
                    style:
                        GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  // Irrigation Dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _irrigationMethod,
                        isExpanded: true,
                        dropdownColor:
                            AppThemeColors.cardBackgroundColor(context),
                        items: [
                          DropdownMenuItem(
                              value: 0,
                              child: Text("ري طبيعي (مطر/عيون) - 10%",
                                  style: GoogleFonts.cairo(fontSize: 14.sp))),
                          DropdownMenuItem(
                              value: 1,
                              child: Text("ري صناعي (آلات) - 5%",
                                  style: GoogleFonts.cairo(fontSize: 14.sp))),
                          DropdownMenuItem(
                              value: 2,
                              child: Text("ري مختلط - 7.5%",
                                  style: GoogleFonts.cairo(fontSize: 14.sp))),
                        ],
                        onChanged: (v) {
                          setState(() => _irrigationMethod = v ?? 1);
                          _calculate();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputRow(
                    label: "وزن المحصول",
                    controller: _cropsWeightController,
                    isDark: isDark,
                    suffix: "كيلوجرام",
                  ),
                  _buildInputRow(
                    label: "قيمة المحصول",
                    controller: _cropsValueController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                    child: Text(
                      "* لا تجب الزكاة إلا إذا بلغ المحصول 5 أوسق (653 كجم تقريباً)",
                      style: GoogleFonts.cairo(
                          fontSize: 10.sp, color: Colors.grey),
                    ),
                  ),
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // --- 6. Cattle Section ---
              _buildSectionCard(
                title: "زكاة الأنعام (المواشي)",
                children: [
                   Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ملاحظة: الزكاة في السائمة (التي ترعى) فقط. أما المعلوفة (التي تشتري لها علفاً أغلب العام) فلا زكاة فيها.",
                            style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInputRow(
                    label: "عدد رؤوس الإبل",
                    controller: _camelsController,
                    isDark: isDark,
                    suffix: "رأس",
                    labelPrefix: "النصاب: 5 رؤوس",
                  ),
                  const SizedBox(height: 8),
                  _buildInputRow(
                    label: "عدد رؤوس البقر",
                    controller: _cowsController,
                    isDark: isDark,
                    suffix: "رأس",
                    labelPrefix: "النصاب: 30 رأس",
                  ),
                  const SizedBox(height: 8),
                  _buildInputRow(
                    label: "عدد رؤوس الغنم",
                    controller: _sheepController,
                    isDark: isDark,
                    suffix: "رأس",
                    labelPrefix: "النصاب: 40 رأس",
                  ),
                  if (_camelsController.text.isNotEmpty || _cowsController.text.isNotEmpty || _sheepController.text.isNotEmpty)
                    _buildCattleResultCards(isDark),
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // --- 7. Zakat al-Fitr Section ---
              _buildSectionCard(
                title: "زكاة الفطر",
                children: [
                  _buildInputRow(
                    label: "عدد الأفراد",
                    controller: _fitrMembersController,
                    isDark: isDark,
                    suffix: "فرد",
                  ),
                  const SizedBox(width: 8),
                  _buildInputRow(
                    label: "قيمة الفرد",
                    controller: _fitrValueController,
                    isDark: isDark,
                    suffix: _selectedCurrency.name,
                  ),
                  if (_zakatFitrTotal > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "إجمالي زكاة الفطر:",
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color:
                                  isDark ? Colors.purpleAccent : Colors.purple,
                            ),
                          ),
                          Text(
                            "${formatMoney(_zakatFitrTotal)} ${_selectedCurrency.symbol}",
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.purpleAccent : Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    )
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 30),

              // --- Result Breakdown ---
              _buildResultSection(isDark, formatMoney),

              // --- Actions (Share, Save, Reminder) ---
              // if (_totalZakat > 0) ...[
              //   const SizedBox(height: 20),
              //   SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         _buildActionButton(
              //           isDark: isDark,
              //           icon: Icons.share,
              //           label: "مشاركة",
              //           onTap: _shareResult,
              //         ),
              //         // const SizedBox(width: 10),
              //         // _buildActionButton(
              //         //   isDark: isDark,
              //         //   icon: Icons.save,
              //         //   label: "حفظ",
              //         //   onTap: _saveToHistory,
              //         // ),
              //         const SizedBox(width: 10),
              //         _buildActionButton(
              //           isDark: isDark,
              //           icon: Icons.alarm,
              //           label: "منبه الحول",
              //           onTap: _scheduleReminder,
              //         ),
              //         const SizedBox(width: 10),
              //         _buildActionButton(
              //           isDark: isDark,
              //           icon: Icons.picture_as_pdf,
              //           label: "تحميل تقرير",
              //           onTap: () => ZakatPdfService.generateAndPrint(
              //             totalWealth: _totalWealth,
              //             totalZakat: _totalZakat,
              //             nisabValue: _nisabValue,
              //             currencySymbol: _selectedCurrency.symbol,
              //             isHijri: _isHijriYear,
              //             reachedNisab: _totalWealth >= _nisabValue,
              //             money: _zakatMoney,
              //             gold: _zakatGold,
              //             silver: _zakatSilver,
              //             assets: _zakatAssets,
              //             realEstate: _zakatRealEstate,
              //             crops: _zakatCrops,
              //             cattleDetails: _zakatCattleResult,
              //             fitrTotal: _zakatFitrTotal,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ],

              // --- Info Text ---
              _buildInfoText(isDark),

              const SizedBox(height: 50),
            ],
          ),
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
        backgroundColor: KColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.cairo()),
    );
  }

  Widget _buildNisabCard(bool isDark, String Function(double) formatter) {
    double goldNisab = 85 * (double.tryParse(_goldPrice24Controller.text.replaceAll(',', '')) ?? 0);
    double silverNisab = 595 * (double.tryParse(_silverPriceController.text.replaceAll(',', '')) ?? 0);

    bool showRecommendation = _isGoldStandard && 
                            _totalWealth >= silverNisab && 
                            _totalWealth < goldNisab &&
                            silverNisab > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(AppStyle.primaryColor).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(AppStyle.primaryColor).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _isGoldStandard
                            ? "نصاب الزكاة (85 جرام ذهب 24)"
                            : "نصاب الزكاة (595 جرام فضة)",
                        style: GoogleFonts.cairo(
                            fontSize: ResponsiveUtil.isTablet(context)?9.sp:16.sp,
                            color:isDark?KColors.primaryColor:Colors.black)),
                    Text("${formatter(_nisabValue)} ${_selectedCurrency.symbol}",
                        style: GoogleFonts.cairo(
                            fontSize:ResponsiveUtil.isTablet(context)?10.sp: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark?KColors.primaryColor:Colors.black)),
                  ],
                ),
              ),
              if (goldNisab > 0 && silverNisab > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isGoldStandard ? "نصاب الفضة: ${formatter(silverNisab)}" : "نصاب الذهب: ${formatter(goldNisab)}",
                      style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (showRecommendation)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "ثروتك بلغت نصاب الفضة ولم تبلغ نصاب الذهب. يُنصح بإخراج الزكاة (الأحظ للفقراء) في عروض التجارة والنقود.",
                    style: GoogleFonts.cairo(fontSize: 11.sp, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          title: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize:ResponsiveUtil.isTablet(context)?10.sp: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00897B),
            ),
          ),
          iconColor: const Color(0xFF00897B),
          collapsedIconColor: Colors.grey,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSmallInput(
      TextEditingController controller, bool isDark, String hint) {
    return SizedBox(
      height:ResponsiveUtil.isTablet(context)?90: 40,
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
              GoogleFonts.cairo(fontSize:ResponsiveUtil.isTablet(context)?8.sp: 10.sp, color: Colors.grey.shade400),
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
    bool isNegative = false,
    Widget? trailing,
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
                    fontSize: ResponsiveUtil.isTablet(context)?7.sp: 12.sp,
                    color: isNegative
                        ? Colors.red
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height:ResponsiveUtil.isTablet(context)?70:  45,
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: InputDecoration(
                      hintText: "القيمة هنا",
                      hintStyle: GoogleFonts.cairo(
                          color: Colors.grey.withOpacity(0.5), fontSize:ResponsiveUtil.isTablet(context)?9.sp:  12.sp),
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
              const SizedBox(width: 8),
              // GestureDetector(
              //   onTap: () => _showCurrencyConverter(controller),
              //   child: Container(
              //     width: 30,
              //     height: 30,
              //     decoration: BoxDecoration(
              //       color: Colors.grey.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: const Icon(Icons.currency_exchange,
              //         size: 16, color: Colors.blueGrey),
              //   ),
              // ),
              // const SizedBox(width: 4),
              SizedBox(
                width: 70,
                child: Text(
                  suffix,
                  style: GoogleFonts.cairo(
                    fontSize:ResponsiveUtil.isTablet(context)?7.sp:  12.sp,
                    color: const Color(0xFFD97706), // Amber text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(bool isDark, String Function(double) formatter) {
    bool hasAnyInput = _totalWealth > 0 || 
                      _zakatCrops > 0 || 
                      _zakatFitrTotal > 0 || 
                      _zakatCattleResult.isNotEmpty ||
                      _moneyController.text.isNotEmpty ||
                      _receivablesController.text.isNotEmpty ||
                      _tradeGoodsController.text.isNotEmpty ||
                      _tradeCashController.text.isNotEmpty ||
                      _tradeReceivablesController.text.isNotEmpty ||
                      _stocksController.text.isNotEmpty ||
                      _goldWeight24Controller.text.isNotEmpty ||
                      _silverWeightController.text.isNotEmpty ||
                      _camelsController.text.isNotEmpty ||
                      _cowsController.text.isNotEmpty ||
                      _sheepController.text.isNotEmpty;

    if (!hasAnyInput) {
      // Only show the "guide" message if wealth is 0 and no controllers have text
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "أدخل تفاصيل ممتلكاتك (مال، ذهب، بضائع...) لظهور البطاقة",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    }

    // Check if prices are missing
    bool priceMissing = _isGoldStandard 
        ? (double.tryParse(_goldPrice24Controller.text.replaceAll(',', '')) ?? 0) <= 0
        : (double.tryParse(_silverPriceController.text.replaceAll(',', '')) ?? 0) <= 0;

    if (priceMissing && _totalWealth > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.calculate_outlined, color: Colors.blue, size: 40),
            const SizedBox(height: 12),
            Text(
              "يرجى إدخال سعر الذهب/الفضة الحالي في \"إعدادات الأسعار\" في الأعلى ليتمكن التطبيق من معرفة بلوغ النصاب وحساب الزكاة.",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "إجمالي ثروتك الحالية: ${formatter(_totalWealth)} ${_selectedCurrency.symbol}",
              style: GoogleFonts.cairo(color: Colors.blue.shade700, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    // Use the effective logic from _calculate
    double silverNisabValue = 595 * (double.tryParse(_silverPriceController.text.replaceAll(',', '')) ?? 0);
    double effectiveNisab = _isGoldStandard ? _nisabValue : _nisabValue; // Already set in _calculate
    
    // Check if we reached Nisab (Gold, Silver, Cattle, or Crops)
    bool reachedNisab = (_totalWealth >= _nisabValue && _nisabValue > 0) || 
                        _zakatCattleResult.isNotEmpty || 
                        _zakatCrops > 0;
    
    // Check if there's ANY Zakat due from any source
    bool anyZakatDue = _totalZakat > 0 || _zakatCattleResult.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          RepaintBoundary(
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
                    decoration: BoxDecoration(
                      color: KColors.primaryColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        // const Icon(Icons.receipt_long,
                        //     color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          "تفاصيل زكاتك",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date
                  Text(
                    intl.DateFormat('EEEE, d MMMM yyyy', 'ar')
                        .format(DateTime.now()),
                    style: GoogleFonts.cairo(
                      color: Colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),

                  const Divider(height: 30, indent: 40, endIndent: 40),

                  // Total Wealth
                  _buildReceiptRow(
                      _zakatCattleResult.isNotEmpty ? "💰 إجمالي الثروة النقدية" : "💰 إجمالي الثروة",
                      "${formatter(_totalWealth)} ${_selectedCurrency.symbol}",
                      isDark),

                  // Nisab Status
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
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

                    if (_zakatRealEstate > 0)
                      _buildReceiptRow(
                          "زكاة العقارات",
                          "${formatter(_zakatRealEstate)} ${_selectedCurrency.symbol}",
                          isDark,
                          isSub: true),

                    if (_zakatCrops > 0)
                      _buildReceiptRow(
                          "زكاة الزروع",
                          "${formatter(_zakatCrops)} ${_selectedCurrency.symbol}",
                          isDark,
                          isSub: true),

                    if (_zakatCattleResult.isNotEmpty) ...[
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text("زكاة الأنعام:",
                              style: GoogleFonts.cairo(
                                  fontSize: 13.sp, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: Text(
                          _zakatCattleResult,
                          style: GoogleFonts.cairo(
                              fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],

                    const Divider(height: 30, indent: 40, endIndent: 40),

                    // Total Zakat
                    if (anyZakatDue)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppThemeColors.cardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(AppStyle.primaryColor)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "إجمالي قيمة الزكاة المستحقة (${_isHijriYear ? 'هجري' : 'ميلادي'})",
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
                            if (_paidZakat > 0) ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("تم دفع:", style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey)),
                                  Text("${formatter(_paidZakat)} ${_selectedCurrency.symbol}", style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.teal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("المتبقي:", style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                  Text("${formatter(_totalZakat - _paidZakat)} ${_selectedCurrency.symbol}", style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            if (_zakatCattleResult.isNotEmpty && _totalZakat == 0)
                               Text(
                                "(راجع تفاصيل زكاة الأنعام أعلاه)",
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "لم تبلغ ممتلكاتك النصاب الشرعي بعد، لا تجب عليك الزكاة حالياً.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleActionButton(
                          icon: Icons.share,
                          label: "مشاركة",
                          onTap: _shareResult,
                          color: Colors.blue,
                        ),
                        // const SizedBox(width: 12),
                        _buildCircleActionButton(
                          icon: Icons.picture_as_pdf,
                          label: "تقرير PDF",
                          onTap: _generatePdf,
                          color: Colors.red,
                        ),
                        // const SizedBox(width: 12),
                        _buildCircleActionButton(
                          icon: Icons.history,
                          label: "السجل",
                          onTap: () => _showHistorySheet(isDark),
                          color: Colors.orange,
                        ),
                        // const SizedBox(width: 12),
                        // _buildCircleActionButton(
                        //   icon: _isFajrEnabled ? Icons.notifications_active : Icons.notifications_off,
                        //   label: "منبه الفجر",
                        //   onTap: _toggleFajrAlarm,
                        //   color: _isFajrEnabled ? Colors.purple : Colors.grey,
                        // ),
                        // const SizedBox(width: 12),
                        _buildCircleActionButton(
                          icon: Icons.alarm,
                          label: "منبه الحول",
                          onTap: _scheduleReminder,
                          color: Colors.green,
                        ),
                        // const SizedBox(width: 12),
                        _buildCircleActionButton(
                          icon: Icons.payments_outlined,
                          label: "تسجيل دفع",
                          onTap: () => _showRecordPaymentSheet(isDark),
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
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
          if (reachedNisab && _totalZakat > 0) _buildChartSection(isDark),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isDark) {
    if (_totalZakat <= 0) return const SizedBox.shrink();

    // Prepare chart data
    List<PieChartSectionData> sections = [];
    double radius = 50;

    if (_zakatMoney > 0) {
      sections.add(PieChartSectionData(
        value: _zakatMoney,
        title: "${((_zakatMoney / _totalZakat) * 100).toStringAsFixed(0)}%",
        color: Colors.green,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_zakatGold > 0) {
      sections.add(PieChartSectionData(
        value: _zakatGold,
        title: "${((_zakatGold / _totalZakat) * 100).toStringAsFixed(0)}%",
        color: Colors.amber,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_zakatAssets > 0) {
      sections.add(PieChartSectionData(
        value: _zakatAssets,
        title: "${((_zakatAssets / _totalZakat) * 100).toStringAsFixed(0)}%",
        color: Colors.blue,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_zakatRealEstate > 0) {
      sections.add(PieChartSectionData(
        value: _zakatRealEstate,
        title:
            "${((_zakatRealEstate / _totalZakat) * 100).toStringAsFixed(0)}%",
        color: Colors.brown,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_zakatCrops > 0) {
      sections.add(PieChartSectionData(
        value: _zakatCrops,
        title: "${((_zakatCrops / _totalZakat) * 100).toStringAsFixed(0)}%",
        color: Colors.lightGreen,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_zakatSilver > 0) {
      sections.add(PieChartSectionData(
        value: _zakatSilver,
        title: ".", // Too small
        color: Colors.blueGrey,
        radius: radius,
        showTitle: false,
      ));
    }

    // Fallback if empty to avoid crash (though _totalZakat > 0 prevents this usually)
    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text("تحليل مصادر الزكاة",
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: const Color(AppStyle.primaryColor))),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  )),
                ),
                // Legend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_zakatMoney > 0) _buildIndicator(Colors.green, "المال"),
                    if (_zakatGold > 0) _buildIndicator(Colors.amber, "الذهب"),
                    if (_zakatAssets > 0)
                      _buildIndicator(Colors.blue, "أصول/تجارة"),
                    if (_zakatRealEstate > 0)
                      _buildIndicator(Colors.brown, "عقارات"),
                    if (_zakatCrops > 0)
                      _buildIndicator(Colors.lightGreen, "زروع"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.cairo(fontSize: 10.sp)),
        ],
      ),
    );
  }

  void _showRecordPaymentSheet(bool isDark) {
    final TextEditingController amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("تسجيل مبلغ مدفوع من الزكاة", style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSmallInput(amountController, isDark, "أدخل المبلغ الذي دفعته"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
                    if (amount > 0) {
                      setState(() => _paidZakat += amount);
                      Navigator.pop(context);
                      KHelper.showSuccess(message: "تم تسجيل الدفعة بنجاح");
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 50)),
                  child: Text("تأكيد التسجيل", style: GoogleFonts.cairo(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _paidZakat = 0);
                    Navigator.pop(context);
                  },
                  child: Text("تصفير المدفوعات", style: GoogleFonts.cairo(color: Colors.red)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 10.sp, color: color),
          ),
        ],
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

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? KColors.primaryColor : Colors.grey),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize:ResponsiveUtil.isTablet(context)?8.sp:  12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
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
               Icon(Icons.info, color:    KColors.primaryColor,),
              const SizedBox(width: 8),
              Text(
                "كيف تحسب زكاتك؟",
                style: GoogleFonts.cairo(
                  fontSize: ResponsiveUtil.isTablet(context)?10.sp: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: KColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "حاسبة الزكاة على تطبيقنا، تمكنك من حساب قيمة الزكاة المالية، الذهب، عروض التجارة، الزروع، والأنعام بشكل احترافي ودقيق.\n\n"
            "ملاحظات هامة للدقة:\n"
            "* ذهب الزينة المعتاد لا زكاة فيه (يمكنك استثناؤه بالخيار الجديد).\n"
            "* الأسهم: إذا كنت مضارباً تُحسب الزكاة على كامل القيمة السوقية، أما إذا كنت مستثمراً طويل الأجل فالزكاة على الأرباح الموزعة فقط.\n"
            "* الديون: أضفنا خانة للديون التي لك عند الناس (المضمونة) لتُحسب ضمن زكاتك، والديون التي عليك تُخصم تلقائياً.\n"
            "* عروض التجارة: يفضل حسابها بدقة (كاش في النشاط + بضائع بسعر البيع + ديون النشاط).\n"
            "* نصاب الفضة: يظهر لك تنبيه (الأحظ للفقراء) إذا بلغت ثروتك نصاب الفضة ولم تبلغ نصاب الذهب.\n\n"
            "* يرجى التواصل مع جهة أو دار فتوى شرعية للتحقق من الحالات الخاصة.",
            style: GoogleFonts.cairo(
              fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showZakatChannelsSheet,
              icon: const Icon(Icons.people_outline, size: 18),
              label: Text("لمن تعطى الزكاة؟ (مصارف الزكاة)",
                  style: GoogleFonts.cairo(color: isDark?Colors.white:CupertinoColors.black)),
              style: OutlinedButton.styleFrom(
                foregroundColor: KColors.whiteGrayColor,
                side:  BorderSide(color:KColors.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
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

    final formatter = intl.NumberFormat("#,##0", "en_US");
    // Handle case where input is just "0" or empty
    String newText = "";
    if (integerPart == "0" && parts.length == 1 && !cleanedText.endsWith('.')) {
      // Allow pure 0
      newText = "0";
    } else {
      newText = formatter.format(int.tryParse(integerPart) ?? 0);
    }

    if (parts.length > 1) {
      newText += ".${parts[1]}";
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

class _CurrencyConverterSheet extends StatefulWidget {
  final TextEditingController targetController;
  final Currency baseCurrency;

  const _CurrencyConverterSheet(
      {required this.targetController, required this.baseCurrency});

  @override
  State<_CurrencyConverterSheet> createState() =>
      _CurrencyConverterSheetState();
}

class _CurrencyConverterSheetState extends State<_CurrencyConverterSheet> {
  final TextEditingController _amountController = TextEditingController();
  Currency _fromCurrency = currencies.firstWhere((c) => c.code == 'USD',
      orElse: () => currencies[2]); // Default USD
  double _result = 0.0;

  // Mock rates (In real app, fetch from API)
  final Map<String, double> _ratesToUSD = {
    'EGP': 0.02, // 1 EGP = 0.02 USD (approx 50 EGP/USD)
    'SAR': 0.266,
    'USD': 1.0,
    'AED': 0.27,
    'KWD': 3.25,
    'EUR': 1.08,
    'GBP': 1.25,
    'TRY': 0.03,
  };

  void _convert() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      setState(() => _result = 0.0);
      return;
    }

    // Convert FROM to USD first
    double amountInUSD = amount;
    if (_fromCurrency.code != 'USD') {
      // We need rate of FROM -> USD.
      // If we assume the map is Value in USD.
      // e.g. EGP = 0.02 USD.  So 100 EGP * 0.02 = 2 USD.
      // KWD = 3.25 USD. So 10 KWD * 3.25 = 32.5 USD.

      double rate = _ratesToUSD[_fromCurrency.code] ?? 1.0;
      // If missing, assume 1:1 for safety or 0
      if (!_ratesToUSD.containsKey(_fromCurrency.code)) rate = 1.0; // Fallback

      amountInUSD = amount * rate;
    }

    // Convert USD to Target (Base)
    // Rate USD -> Base.
    // If Base is EGP (0.02 USD). 1 USD = 1/0.02 = 50 EGP.
    double targetRateInUSD = _ratesToUSD[widget.baseCurrency.code] ?? 1.0;

    // We have AmountInUSD. to get Target: AmountInUSD / TargetRateInUSD
    // Example: 2 USD. Target EGP (0.02). 2 / 0.02 = 100 EGP. Correct.
    if (targetRateInUSD == 0) targetRateInUSD = 1.0;

    _result = amountInUSD / targetRateInUSD;
    setState(() {});
  }

  void _apply() {
    widget.targetController.text =
        intl.NumberFormat("#,##0.##", "en_US").format(_result);
    // Trigger calculation in parent? The parent listens to controller changes usually?
    // In Flutter TextField controller changes don't auto-trigger listener unless specific setup.
    // But the parent has `onChanged: (v) => _calculate()`.
    // Just setting text doesn't trigger onChanged.
    // We normally need to call the callback or notify.
    // As a workaround, the user might need to tap the field or we accept it as is,
    // but better if we could trigger it. For now, we just set text.
    // The user will likely tap "Done" or Close.
    Navigator.pop(context);

    // To trigger update we might need to invoke the logic if accessible,
    // but controller update is visible immediately.
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("محول العملات السريع",
              style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(AppStyle.primaryColor))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "المبلغ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10)),
                  onChanged: (v) => _convert(),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<Currency>(
                value: _fromCurrency,
                onChanged: (v) {
                  if (v != null)
                    setState(() {
                      _fromCurrency = v;
                      _convert();
                    });
                },
                items: currencies
                    .where((c) => _ratesToUSD.containsKey(c.code))
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.code)))
                    .toList(),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Icon(Icons.arrow_downward, color: Colors.grey),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: isDark ? Colors.black26 : Colors.grey.shade100,
            child: Text(
              "${intl.NumberFormat("#,##0.##").format(_result)} ${widget.baseCurrency.symbol}",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppStyle.primaryColor)),
              child: Text("اعتماد القيمة",
                  style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Text("* أسعار التحويل تقريبية (ثابتة في الكود حالياً للتجربة)",
              style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

// بناءً على تصفحي للكود والمميزات الحالية، دي بعض الاقتراحات اللي ممكن تنقل التطبيق لمستوى أعلى وتفيد المستخدمين جداً:
//
// ويدجت للشاشة الرئيسية (Home Screen Widgets): 📱
// الفكرة: عرض مواقيت الصلاة القادمة، أو "آية اليوم"، أو أذكار الصباح/المساء مباشرة على شاشة الموبايل من الخارج من غير ما يفتح التطبيق.
// ليه مهمة؟: دي أكتر ميزة بيطلبها المستخدمين عشان السرعة والسهولة. (لاحظت إن مكتبة home_widget كانت موجودة في الـ pubspec بس معمولة comment، فواضح إن كان في نية لعملها).
// حاسبة الزكاة (Zakat Calculator): 💰
// الفكرة: أداة بسيطة تحسب زكاة المال، الذهب، والفضة. المستخدم يدخل المبلغ أو الوزن، والتطبيق يحسب القيمة المستحقة فوراً بناءً على النصاب.
// ليه مهمة؟: أداة عملية جداً وبيحتاجها المسلم كل سنة، وبتخلي التطبيق شامل لكل أركان الإسلام.
// متتبع الصيام (Fasting Tracker): 🌙
// الفكرة: قسم لتسجيل الأيام اللي صامها المستخدم (قضاء رمضان، الاثنين والخميس، الأيام البيض) مع إحصائيات بسيطة.
// ليه مهمة؟: بتشجع على السنة وتساعد في تنظيم قضاء الصيام.
// الوضع الهادئ التلقائي (Auto Silent Mode): 🔕
// الفكرة: ميزة تحول الموبايل لـ "صامت" أو "هزاز" أوتوماتيكياً وقت الصلاة (لمدة 15-20 دقيقة) وترجعه بعدها لوضعه الطبيعي.
// ليه مهمة؟: حل عملي عشان محدش ينسى موبايله يرن في المسجد.
// رأيي الشخصي: أرشح نبدأ بـ الويدجت (Widgets)، لأنها بتخلي التطبيق "حي" قدام المستخدم طول اليوم وبتديه شكل احترافي وعصري.
//
// تحب نبدأ في الويدجت ولا عندك تفضيل لحاجة تانية؟
