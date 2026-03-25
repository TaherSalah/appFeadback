// ===== 1. Model للذكر =====
import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../core/shard/exports/all_exports.dart';
import 'counter_azkar.dart';

class Zikr {
  final String id;
  final String text;
  final int targetCount;
  final bool isCustom;
  int currentProgress;
  int completedCycles;
  DateTime? lastUpdated;

  Zikr({
    required this.id,
    required this.text,
    required this.targetCount,
    this.isCustom = false,
    this.currentProgress = 0,
    this.completedCycles = 0,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'targetCount': targetCount,
        'isCustom': isCustom,
        'currentProgress': currentProgress,
        'completedCycles': completedCycles,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory Zikr.fromJson(Map<String, dynamic> json) => Zikr(
        id: json['id'],
        text: json['text'],
        targetCount: json['targetCount'],
        isCustom: json['isCustom'] ?? false,
        currentProgress: json['currentProgress'] ?? 0,
        completedCycles: json['completedCycles'] ?? 0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : null,
      );

  Zikr copyWith({
    String? id,
    String? text,
    int? targetCount,
    bool? isCustom,
    int? currentProgress,
    int? completedCycles,
    DateTime? lastUpdated,
  }) {
    return Zikr(
      id: id ?? this.id,
      text: text ?? this.text,
      targetCount: targetCount ?? this.targetCount,
      isCustom: isCustom ?? this.isCustom,
      currentProgress: currentProgress ?? this.currentProgress,
      completedCycles: completedCycles ?? this.completedCycles,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// ===== 2. Provider لإدارة الأذكار =====
class AzkarManagementProvider extends ChangeNotifier {
  List<Zikr> _azkarList = [];
  Zikr? _selectedZikr;
  int _totalTodayCount = 0;

  List<Zikr> get azkarList => _azkarList;
  Zikr? get selectedZikr => _selectedZikr;
  int get totalTodayCount => _totalTodayCount;

  AzkarManagementProvider() {
    _initializeDefaultAzkar();
    _loadFromStorage();
  }

  void _initializeDefaultAzkar() {
    _azkarList = [
      Zikr(
        id: 'default_1',
        text: 'سُبْحَانَ اللهِ',
        targetCount: 33,
      ),
      Zikr(
        id: 'default_2',
        text: 'الْحَمْدُ للهِ',
        targetCount: 33,
      ),
      Zikr(
        id: 'default_3',
        text: 'اللهُ أَكْبَر',
        targetCount: 34,
      ),
      Zikr(
        id: 'default_4',
        text: 'لَا إِلَهَ إِلَّا اللهُ',
        targetCount: 100,
      ),
      Zikr(
        id: 'default_5',
        text: 'أَسْتَغْفِرُ اللهَ',
        targetCount: 100,
      ),
      Zikr(
        id: 'default_6',
        text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
        targetCount: 100,
      ),
      Zikr(
        id: 'default_7',
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        targetCount: 100,
      ),
    ];
  }

  Future<void> _loadFromStorage() async {
    // هنا تحمل البيانات من SharedPreferences أو قاعدة بيانات
    // مثال بسيط:
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = prefs.getString('azkar_list');
    // if (jsonString != null) {
    //   final List decoded = json.decode(jsonString);
    //   _azkarList = decoded.map((e) => Zikr.fromJson(e)).toList();
    // }
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    // حفظ البيانات
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = json.encode(_azkarList.map((e) => e.toJson()).toList());
    // await prefs.setString('azkar_list', jsonString);
  }

  void selectZikr(Zikr zikr) {
    _selectedZikr = zikr;
    notifyListeners();
  }

  void incrementProgress() {
    if (_selectedZikr == null) return;

    final index = _azkarList.indexWhere((z) => z.id == _selectedZikr!.id);
    if (index == -1) return;

    _azkarList[index].currentProgress++;
    _azkarList[index].lastUpdated = DateTime.now();
    _totalTodayCount++;

    // إذا وصل للهدف
    if (_azkarList[index].currentProgress >= _azkarList[index].targetCount) {
      _azkarList[index].completedCycles++;
      _azkarList[index].currentProgress = 0;
      // يمكن إضافة notification هنا
    }

    _selectedZikr = _azkarList[index];
    _saveToStorage();
    notifyListeners();
  }

  void resetProgress(String zikrId) {
    final index = _azkarList.indexWhere((z) => z.id == zikrId);
    if (index != -1) {
      _azkarList[index].currentProgress = 0;
      _azkarList[index].lastUpdated = DateTime.now();
      if (_selectedZikr?.id == zikrId) {
        _selectedZikr = _azkarList[index];
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  void addCustomZikr(String text, int targetCount) {
    final newZikr = Zikr(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      targetCount: targetCount,
      isCustom: true,
    );
    _azkarList.add(newZikr);
    _saveToStorage();
    notifyListeners();
  }

  void updateZikr(String id, String text, int targetCount) {
    final index = _azkarList.indexWhere((z) => z.id == id);
    if (index != -1 && _azkarList[index].isCustom) {
      _azkarList[index] = _azkarList[index].copyWith(
        text: text,
        targetCount: targetCount,
      );
      _saveToStorage();
      notifyListeners();
    }
  }

  void deleteZikr(String id) {
    final zikr = _azkarList.firstWhere((z) => z.id == id);
    if (zikr.isCustom) {
      _azkarList.removeWhere((z) => z.id == id);
      if (_selectedZikr?.id == id) {
        _selectedZikr = null;
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  void resetDailyCount() {
    _totalTodayCount = 0;
    notifyListeners();
  }
}

// ===== 3. صفحة إدارة الأذكار =====
class AzkarCounter extends StatelessWidget {
  const AzkarCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'إدارة الأذكار',
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddZikrDialog(context),
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF10B981)),
              iconSize: 28.sp,
            ),
          ],
        ),
        body: Consumer<AzkarManagementProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: provider.azkarList.length,
              itemBuilder: (context, index) {
                final zikr = provider.azkarList[index];
                return _buildZikrCard(context, zikr, provider);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildZikrCard(
      BuildContext context, Zikr zikr, AzkarManagementProvider provider) {
    final progress = zikr.currentProgress / zikr.targetCount;
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: provider.selectedZikr?.id == zikr.id
              ? const Color(0xFF10B981)
              : const Color(0xFF475569),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.selectZikr(zikr);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // النص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zikr.text,
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: isTablet ? 20.sp : 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                    width: 1.w,
                                  ),
                                ),
                                child: Text(
                                  'الهدف: ${zikr.targetCount}',
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    fontSize: 12.sp,
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (zikr.completedCycles > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: const Color(0xFFFBBF24),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12.sp,
                                        color: const Color(0xFFFBBF24),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${zikr.completedCycles}',
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 12.sp,
                                          color: const Color(0xFFFBBF24),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // الأزرار
                    Column(
                      children: [
                        if (zikr.isCustom) ...[
                          IconButton(
                            onPressed: () => _showEditZikrDialog(context, zikr),
                            icon: const Icon(Icons.edit_outlined),
                            color: const Color(0xFF6366F1),
                            iconSize: 20.sp,
                          ),
                          IconButton(
                            onPressed: () => _showDeleteConfirmation(
                                context, zikr, provider),
                            icon: const Icon(Icons.delete_outline),
                            color: const Color(0xFFEF4444),
                            iconSize: 20.sp,
                          ),
                        ] else
                          SizedBox(height: 48.h),
                        if (zikr.currentProgress > 0)
                          IconButton(
                            onPressed: () => provider.resetProgress(zikr.id),
                            icon: const Icon(Icons.refresh),
                            color: const Color(0xFFF59E0B),
                            iconSize: 20.sp,
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // شريط التقدم
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقدم: ${zikr.currentProgress} / ${zikr.targetCount}',
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 12.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 12.sp,
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8.h,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddZikrDialog(BuildContext context) {
    final textController = TextEditingController();
    final countController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text(
            'إضافة ذكر جديد',
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                   style: const TextStyle(
                          fontFamily: "cairo",color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'نص الذكر',
                  hintStyle: const TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                   style: const TextStyle(
                          fontFamily: "cairo",color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'العدد المطلوب',
                  hintStyle: const TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                   style: TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  final count = int.tryParse(countController.text) ?? 33;
                  Provider.of<AzkarManagementProvider>(context, listen: false)
                      .addCustomZikr(textController.text, count);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'إضافة',
                   style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditZikrDialog(BuildContext context, Zikr zikr) {
    final textController = TextEditingController(text: zikr.text);
    final countController = TextEditingController(text: '${zikr.targetCount}');

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text(
            'تعديل الذكر',
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                   style: const TextStyle(
                          fontFamily: "cairo",color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'نص الذكر',
                  hintStyle: const TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                   style: const TextStyle(
                          fontFamily: "cairo",color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'العدد المطلوب',
                  hintStyle: const TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                   style: TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  final count =
                      int.tryParse(countController.text) ?? zikr.targetCount;
                  Provider.of<AzkarManagementProvider>(context, listen: false)
                      .updateZikr(zikr.id, textController.text, count);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'حفظ',
                   style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Zikr zikr, AzkarManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'حذف الذكر',
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا الذكر؟',
               style: TextStyle(
                          fontFamily: "cairo",color: const Color(0xFF94A3B8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                   style: TextStyle(
                          fontFamily: "cairo",color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteZikr(zikr.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'حذف',
                   style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 4. تحديث المسبحة لدعم الذكر المختار =====
class UpdatedAzkarCounter extends StatefulWidget {
  const UpdatedAzkarCounter({super.key});

  @override
  State<UpdatedAzkarCounter> createState() => _UpdatedAzkarCounterState();
}

class _UpdatedAzkarCounterState extends State<UpdatedAzkarCounter> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: context.isDark
                  ? Colors.white
                  : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              'المسبحة الإلكترونية',
                 style: TextStyle(
                          fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AzkarCounter(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
        body: const UpdatedCounterWidgetBuilder(),
      ),
    );
  }
}

class UpdatedCounterWidgetBuilder extends StatefulWidget {
  const UpdatedCounterWidgetBuilder({super.key});

  @override
  State<UpdatedCounterWidgetBuilder> createState() =>
      _UpdatedCounterWidgetBuilderState();
}

class _UpdatedCounterWidgetBuilderState
    extends State<UpdatedCounterWidgetBuilder> {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Consumer<AzkarManagementProvider>(
          builder: (context, provider, child) {
            final selectedZikr = provider.selectedZikr;

            if (selectedZikr == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 80.sp,
                      color: const Color(0xFF475569),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'اختر ذكرًا للبدء',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 24.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AzkarCounter(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: Text(
                        'اختر من القائمة',
                           style: TextStyle(
                          fontFamily: "cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 16.0,
                vertical: 2.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // معلومات الذكر المختار
                  _buildSelectedZikrHeader(selectedZikr, isTablet),
                  SizedBox(height: isTablet ? 20.h : 15.h),

                  // العداد والمسبحة
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCounterDisplay(selectedZikr),
                          SizedBox(height: isTablet ? 40.h : 20.h),
                          UpdatedTasbeehReal(
                            beadsCount: selectedZikr.targetCount,
                            currentProgress: selectedZikr.currentProgress,
                            onIncrement: () => provider.incrementProgress(),
                            onReset: () =>
                                provider.resetProgress(selectedZikr.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedZikrHeader(Zikr zikr, bool isTablet) {
    final progress = zikr.currentProgress / zikr.targetCount;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            zikr.text,
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: isTablet ? 24.sp : 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatBadge(
                icon: Icons.flag,
                label: 'الهدف',
                value: '${zikr.targetCount}',
                color: const Color(0xFF6366F1),
              ),
              SizedBox(width: 16.w),
              _buildStatBadge(
                icon: Icons.star,
                label: 'المكتمل',
                value: '${zikr.completedCycles}',
                color: const Color(0xFFFBBF24),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.h,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${zikr.currentProgress} / ${zikr.targetCount}',
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: 14.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 10.sp,
                  color: color,
                ),
              ),
              Text(
                value,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 16.sp,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(Zikr zikr) {
    bool isTablet = MediaQuery.sizeOf(context).width > 600;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF475569),
              width: 3.w,
            ),
          ),
          child: Text(
            '${zikr.currentProgress}',
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: isTablet ? 48.sp : 42.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== 5. المسبحة المحدثة =====
class UpdatedTasbeehReal extends StatefulWidget {
  final int beadsCount;
  final int currentProgress;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const UpdatedTasbeehReal({
    super.key,
    required this.beadsCount,
    required this.currentProgress,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  State<UpdatedTasbeehReal> createState() => _UpdatedTasbeehRealState();
}

class _UpdatedTasbeehRealState extends State<UpdatedTasbeehReal>
    with TickerProviderStateMixin {
  static const Duration animDur = Duration(milliseconds: 400);

  late AnimationController _moveController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late Animation<double> _moveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;

  final List<Offset> _beadPositions = [];
  final List<ParticleEffect> _particles = [];

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: animDur,
      vsync: this,
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOutCubic,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _glowAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _shimmerAnimation =
        Tween<double>(begin: -2.0, end: 2.0).animate(_shimmerController);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _calculateBeadPositions(Size size) {
    _beadPositions.clear();
    final double radius = size.width * 0.38;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (int i = 0; i < widget.beadsCount; i++) {
      final angle = (2 * pi / widget.beadsCount) * i - pi / 2;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      _beadPositions.add(Offset(x, y));
    }
  }

  void _moveToNextBead() {
    if (_moveController.isAnimating) return;
    HapticFeedback.mediumImpact();

    _createParticleEffect();
    widget.onIncrement();

    // تحقق إذا أكمل الدورة
    if ((widget.currentProgress + 1) % widget.beadsCount == 0) {
      HapticFeedback.heavyImpact();
      _createCompletionEffect();
    }

    _moveController.reset();
    _moveController.forward();
    _particleController.reset();
    _particleController.forward();
  }

  void _createParticleEffect() {
    final random = Random();
    for (int i = 0; i < 8; i++) {
      _particles.add(ParticleEffect(
        angle: (2 * pi / 8) * i + random.nextDouble() * 0.3,
        distance: 40 + random.nextDouble() * 30,
        size: 4 + random.nextDouble() * 6,
      ));
    }
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  void _createCompletionEffect() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(ParticleEffect(
        angle: random.nextDouble() * 2 * pi,
        distance: 60 + random.nextDouble() * 80,
        size: 6 + random.nextDouble() * 10,
        color: i % 2 == 0 ? const Color(0xFFFBBF24) : const Color(0xFF10B981),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    final currentBead = widget.currentProgress % widget.beadsCount;

    return Column(
      children: [
        SizedBox(
          height: isTablet ? 420.h : 340.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              _calculateBeadPositions(size);

              return Stack(
                children: [
                  // طبقة توهج خلفية
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _glowAnimation.value * 2 * pi,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF10B981).withOpacity(0.15),
                                  Colors.transparent,
                                  const Color(0xFF6366F1).withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // الحلقة الخارجية
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E293B),
                          width: 5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الخرزات
                  ...List.generate(widget.beadsCount, (index) {
                    if (_beadPositions.isEmpty) return const SizedBox();
                    final pos = _beadPositions[index];
                    final isPassed = index < currentBead;
                    final isNext =
                        index == (currentBead + 1) % widget.beadsCount;

                    return Positioned(
                      left: pos.dx - 18,
                      top: pos.dy - 18,
                      child: _buildBead(
                        isPassed: isPassed,
                        isNext: isNext,
                        index: index,
                        size: 36,
                      ),
                    );
                  }),

                  // الخرزة النشطة
                  if (_beadPositions.isNotEmpty &&
                      currentBead < _beadPositions.length)
                    AnimatedBuilder(
                      animation: _moveAnimation,
                      builder: (context, child) {
                        final startPos = _beadPositions[currentBead];
                        final nextIndex = (currentBead + 1) % widget.beadsCount;
                        final nextPos = _beadPositions[nextIndex];

                        final x = startPos.dx +
                            (nextPos.dx - startPos.dx) * _moveAnimation.value;
                        final y = startPos.dy +
                            (nextPos.dy - startPos.dy) * _moveAnimation.value;

                        return Positioned(
                          left: x - 28,
                          top: y - 28,
                          child: _buildActiveBead(
                              size: 56, currentBead: currentBead),
                        );
                      },
                    ),

                  // جزيئات التأثير
                  if (_particles.isNotEmpty && _beadPositions.isNotEmpty)
                    ..._particles.map((particle) {
                      final centerX = size.width / 2;
                      final centerY = size.height / 2;
                      return AnimatedBuilder(
                        animation: _particleAnimation,
                        builder: (context, child) {
                          final distance =
                              particle.distance * _particleAnimation.value;
                          final opacity = 1.0 - _particleAnimation.value;
                          return Positioned(
                            left: centerX +
                                cos(particle.angle) * distance -
                                particle.size / 2,
                            top: centerY +
                                sin(particle.angle) * distance -
                                particle.size / 2,
                            child: Container(
                              width: particle.size,
                              height: particle.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (particle.color ?? const Color(0xFFFBBF24))
                                        .withOpacity(opacity),
                                boxShadow: [
                                  BoxShadow(
                                    color: (particle.color ??
                                            const Color(0xFFFBBF24))
                                        .withOpacity(opacity * 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),

                  // الزر المركزي
                  Center(
                    child: _buildCenterButton(isTablet),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: 35.h),

        // زر إعادة التعيين
        _buildResetButton(isTablet),
      ],
    );
  }

  Widget _buildBead({
    required bool isPassed,
    required bool isNext,
    required int index,
    required double size,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPassed
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              )
            : isNext
                ? const RadialGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF334155),
                      Color(0xFF1E293B),
                    ],
                  ),
        boxShadow: isPassed
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
        border: Border.all(
          color: isPassed
              ? const Color(0xFF34D399)
              : isNext
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF475569),
          width: isPassed ? 3.w : 1.5.w,
        ),
      ),
      child: isPassed
          ? Center(
              child: Icon(
                Icons.check_circle,
                size: 18.sp,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildActiveBead({required double size, required int currentBead}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // توهج خارجي
              Container(
                width: size * 1.6,
                height: size * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFBBF24).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // الخرزة الرئيسية
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      Color(0xFFFDE047),
                      Color(0xFFFBBF24),
                      Color(0xFFF59E0B),
                      Color(0xFFFBBF24),
                      Color(0xFFFDE047),
                    ],
                    transform: GradientRotation(_glowAnimation.value * 2 * pi),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 4.w,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: size * 0.55,
                    height: size * 0.55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        '${currentBead + 1}',
                           style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 18.sp,
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterButton(bool isTablet) {
    return GestureDetector(
      onTap: _moveToNextBead,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _shimmerAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // توهج خارجي
              Container(
                width: isTablet ? 180 : 160,
                height: isTablet ? 180 : 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1)
                          .withOpacity(0.3 * _pulseAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // الزر الرئيسي
              Container(
                width: isTablet ? 130 : 110,
                height: isTablet ? 130 : 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.6),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 32.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'سبِّح',
                           style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResetButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onReset();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 40.w : 32.w,
          vertical: isTablet ? 18.h : 16.h,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          'إعادة تعيين',
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: isTablet ? 16.sp : 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
