import 'package:flutter/cupertino.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/k_helper.dart';
import 'data/Dhikr.dart';
import 'data/Wird.dart';

class AddWirdScreen extends StatefulWidget {
  final bool isDark;

  const AddWirdScreen({super.key, required this.isDark});

  @override
  _AddWirdScreenState createState() => _AddWirdScreenState();
}

class _AddWirdScreenState extends State<AddWirdScreen> {
  final nameController = TextEditingController();
  final customCategoryController = TextEditingController();
  List<Dhikr> selectedAdhkar = [];
  String selectedCategory = 'صَبَاح';
  String selectedFrequency = 'daily'; // daily, weekly, monthly, once
  bool isCustomCategory = false;
  TimeOfDay? selectedTime;
  int selectedColor = 0xFF00897B; // ✅ متغير اللون المختار

  final List<int> kColors = [
    0xFF00897B, // Teal
    0xFF1E88E5, // Blue
    0xFF43A047, // Green
    0xFFFB8C00, // Orange
    0xFF8E24AA, // Purple
    0xFFE53935, // Red
    0xFF546E7A, // Blue Grey
    0xFFD81B60, // Pink
  ];

  final List<String> categories = [
    'صَبَاح', 'مَسَاء', 'نَوْم', 'بَعْدَ الصَّلَاة', 'أخرى'
  ];

  final List<Map<String, dynamic>> suggestedAdhkar = [
    {'text': 'سُبْحَانَ اللهِ', 'count': 33},
    {'text': 'الْحَمْدُ لِلّهِ', 'count': 33},
    {'text': 'اللهُ أَكْبَرُ', 'count': 34},
    {'text': 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ', 'count': 70},
    {'text': 'لَا إِلَهَ إِلَّا اللهُ', 'count': 100},
    {'text': 'أَسْتَغْفِرُ اللهَ', 'count': 100},
    {'text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ', 'count': 100},
    {'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ', 'count': 50},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى مُحَمَّدٍ', 'count': 100},
    {'text': 'سُبْحَانَ اللهِ الْعَظِيمِ', 'count': 50},
    {'text': 'لَا إِلَهَ إِلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 'count': 100},
  ];

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Colors.tealAccent,
                    onPrimary: Colors.black,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: const Color(0xFF00897B),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.tealAccent : const Color(0xFF00897B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void addCustomDhikr() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final textController = TextEditingController();

        final countController =
        TextEditingController(text: '33');

        int repeatCount = 33;

        final bool isDark =
            Theme.of(context).brightness == Brightness.dark;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// جسم الديالوج
                Container(
                  padding:
                  const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? [
                        const Color(0xFF0B2B23),
                        const Color(0xFF05201B),
                      ]
                          : [
                        const Color(0xFFE0F7F5),
                        const Color(0xFFB2DFDB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (context, setLocalState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// العنوان
                          Text(
                            'إضافة ذكر مخصص',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// نص الذكر
                          TextField(
                            controller: textController,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'نص الذكر',
                              filled: true,
                              fillColor: isDark
                                  ? Colors.black26
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// عنوان العداد
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'عدد التكرار',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// العداد (➕➖ + كتابة)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Row(
                              children: [
                                /// زر النقصان
                                IconButton(
                                  onPressed: () {
                                    if (repeatCount > 1) {
                                      setLocalState(() {
                                        repeatCount--;
                                        countController.text =
                                            repeatCount
                                                .toString();
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.remove_circle_outline),
                                  color: Colors.redAccent,
                                ),

                                /// إدخال يدوي
                                Expanded(
                                  child: TextField(
                                    controller: countController,
                                    textAlign: TextAlign.center,
                                    keyboardType:
                                    TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    decoration:
                                    const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                      EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      final parsed =
                                      int.tryParse(value);

                                      if (parsed != null &&
                                          parsed > 0) {
                                        setLocalState(() {
                                          repeatCount =
                                              parsed;
                                        });
                                      }
                                    },
                                  ),
                                ),

                                /// زر الزيادة
                                IconButton(
                                  onPressed: () {
                                    setLocalState(() {
                                      repeatCount++;
                                      countController.text =
                                          repeatCount
                                              .toString();
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.add_circle_outline),
                                  color: Colors.teal,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          /// الأزرار
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(
                                        dialogContext)
                                        .pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors
                                          .grey.shade400
                                          : Colors
                                          .grey.shade600,
                                    ),
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(14),
                                    ),
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        vertical: 11),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey
                                          .shade800,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (textController
                                        .text.isNotEmpty) {
                                      setState(() {
                                        selectedAdhkar.add(
                                          Dhikr(
                                            id: DateTime
                                                .now()
                                                .toString(),
                                            text:
                                            textController
                                                .text,
                                            targetCount:
                                            repeatCount,
                                          ),
                                        );
                                      });

                                      Navigator.of(
                                          dialogContext)
                                          .pop();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label:
                                  const Text('إضافة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.teal,
                                    foregroundColor:
                                    Colors.white,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(14),
                                    ),
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        vertical: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /// الأيقونة فوق
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
                          colors: [
                            Colors.teal,
                            Colors.green
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal
                                .withOpacity(0.6),
                            blurRadius: 12,
                            offset:
                            const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent : const Color(0xFF00897B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "إضافة ورد جديد",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.03,
                child: Image.asset("assets/images/pattern.webp", repeat: ImageRepeat.repeat),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(20.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader("اسم الورد", Icons.drive_file_rename_outline, isDark),
                      SizedBox(height: 12.h),
                      _buildNameInput(isDark),
                      SizedBox(height: 24.h),

                      _buildSectionHeader("تكرار الورد", Icons.repeat_rounded, isDark),
                      SizedBox(height: 12.h),
                      _buildFrequencySelector(isDark),
                      SizedBox(height: 24.h),

                      _buildSectionHeader("وقت التنبيه (اختياري)", Icons.alarm_rounded, isDark),
                      SizedBox(height: 12.h),
                      _buildTimePicker(isDark),
                      SizedBox(height: 24.h),

                      // ✅ إضافة قسم اختيار اللون
                      _buildSectionHeader("لون الورد", Icons.color_lens_rounded, isDark),
                      SizedBox(height: 12.h),
                      _buildColorSelector(isDark),
                      SizedBox(height: 24.h),

                      _buildSectionHeader("الفئة", Icons.category_rounded, isDark),
                      SizedBox(height: 12.h),
                      _buildCategoryGrid(isDark),
                      if (isCustomCategory) ...[
                        SizedBox(height: 12.h),
                        _buildCustomCategoryInput(isDark),
                      ],
                      SizedBox(height: 24.h),

                      _buildSectionHeader("اختر الأذكار", Icons.format_quote_rounded, isDark),
                      SizedBox(height: 12.h),
                      ...suggestedAdhkar.map((dhikr) => _buildDhikrOption(dhikr, isDark)),
                      
                      if (selectedAdhkar.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            _buildSectionHeader("الأذكار المختارة", Icons.playlist_add_check_rounded, isDark),
                            const Spacer(),
                            Text(
                              "اسحب للترتيب",
                              style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.drag_indicator, size: 14.sp, color: Colors.grey),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // ✅ جعل القائمة قابلة للترتيب
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedAdhkar.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = selectedAdhkar.removeAt(oldIndex);
                              selectedAdhkar.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final dhikr = selectedAdhkar[index];
                            return KeyedSubtree(
                              key: ValueKey(dhikr.id + index.toString()), // مفتاح فريد
                              child: _buildSelectedDhikrItem(dhikr, index, isDark),
                            );
                          },
                        ),
                      ],

                      SizedBox(height: 16.h),
                      _buildAddCustomButton(isDark),
                      SizedBox(height: 120.h),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (nameController.text.isNotEmpty && selectedAdhkar.isNotEmpty) {
              
              String finalCategory = selectedCategory;
              if (selectedCategory == 'أخرى' && customCategoryController.text.isNotEmpty) {
                 finalCategory = customCategoryController.text;
              }

              final newWird = Wird(
                id: DateTime.now().toString(),
                name: nameController.text,
                category: finalCategory,
                adhkar: selectedAdhkar,
                createdAt: DateTime.now(),
                frequency: selectedFrequency,
                color: selectedColor, // ✅ حفظ اللون المختار
                reminderTime: selectedTime != null 
                    ? "${selectedTime!.hour}:${selectedTime!.minute}" 
                    : null,
              );
              Navigator.pop(context, newWird);
            } else {
              KHelper.showError(message: "يرجى إدخال اسم الورد واختيار ذكر واحد على الأقل");
            }
          },
          label: Text("حفظ الورد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.check_circle_outline_rounded),
          backgroundColor: KColors.primaryColor,
          foregroundColor:Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: isDark ? Colors.tealAccent : const Color(0xFF00897B)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildNameInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: nameController,
        style: GoogleFonts.cairo(fontSize: 13.sp, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: "مثال: أذكار ما بعد الصلاة",
          hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildCustomCategoryInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: TextField(
        controller: customCategoryController,
        style: GoogleFonts.cairo(fontSize: 13.sp, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: "اكتب اسم التصنيف الجديد...",
          hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          prefixIcon: Icon(Icons.edit, color: Colors.amber, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(bool isDark) {
    final frequencies = [
      {'val': 'daily', 'label': 'يومي'},
      {'val': 'weekly', 'label': 'أسبوعي'},
      {'val': 'monthly', 'label': 'شهري'},
      {'val': 'once', 'label': 'مرة واحدة'},
    ];

    return Row(
      children: frequencies.map((f) {
        final isSelected = selectedFrequency == f['val'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFrequency = f['val']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? KColors.primaryColor : const Color(0xFF00897B)) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  f['label']!,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(bool isDark) {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedTime != null 
                ? (isDark ? KColors.primaryColor: const Color(0xFF00897B))
                : Colors.transparent
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_filled_rounded,
              color: selectedTime != null 
                  ? (isDark ? KColors.primaryColor: const Color(0xFF00897B))
                  : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              selectedTime != null 
                  ? selectedTime!.format(context) 
                  : "اضغط لضبط ميعاد التنبيه",
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: selectedTime != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (selectedTime != null) ...[
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red.shade300, size: 20.sp),
                onPressed: () => setState(() => selectedTime = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark) {
    return Container(
      height: 45.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = cat;
                isCustomCategory = cat == 'أخرى';
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? KColors.primaryColor : const Color(0xFF00897B)) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDhikrOption(Map<String, dynamic> dhikr, bool isDark) {
    final isSelected = selectedAdhkar.any((d) => d.text == dhikr['text']);
    final primaryColor = isDark ? KColors.primaryColor : const Color(0xFF00897B);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? (isDark ? KColors.primaryColor.withOpacity(0.1) : const Color(0xFF00897B).withOpacity(0.05)) : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedAdhkar.removeWhere((d) => d.text == dhikr['text']);
            } else {
              selectedAdhkar.add(Dhikr(id: DateTime.now().toString(), text: dhikr['text'], targetCount: dhikr['count']));
            }
          });
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(isSelected ? Icons.check_rounded : Icons.add_rounded, color: isSelected ? (isDark ? Colors.black : Colors.white) : Colors.grey, size: 20.sp),
        ),
        title: Text(
          dhikr['text'],
          style: GoogleFonts.amiri(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, height: 1.4),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text("التكرار: ${dhikr['count']} مرة", style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildSelectedDhikrItem(Dhikr dhikr, int index, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF00897B),
            child: Text("${index + 1}", style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(dhikr.text, style: GoogleFonts.cairo(fontSize: 12.sp, color: isDark ? Colors.white : Colors.black87)),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade300, size: 20.sp),
            onPressed: () => setState(() => selectedAdhkar.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomButton(bool isDark) {
    return InkWell(
      onTap: addCustomDhikr,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.tealAccent : const Color(0xFF00897B), style: BorderStyle.solid, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 20.sp, color: isDark ? Colors.tealAccent : const Color(0xFF00897B)),
            SizedBox(width: 10.w),
            Text(
              "إضافة ذكر مخصص",
              style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.tealAccent : const Color(0xFF00897B)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ويدجت اختيار اللون
  Widget _buildColorSelector(bool isDark) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kColors.length,
        itemBuilder: (context, index) {
          final colorVal = kColors[index];
          final isSelected = selectedColor == colorVal;
          return GestureDetector(
            onTap: () => setState(() => selectedColor = colorVal),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Color(colorVal),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: Color(colorVal).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 20.sp)
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }
}
