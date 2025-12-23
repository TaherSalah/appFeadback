import 'package:flutter/cupertino.dart';
import '../../core/shard/exports/all_exports.dart';
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
  List<Dhikr> selectedAdhkar = [];
  String selectedCategory = 'صَبَاح';

  final List<String> categories = [
    'صَبَاح', 'مَسَاء', 'نَوْم', 'عَام', 'مُخَصَّص', 'بَعْدَ الصَّلَاة', 
    'قَبْلَ الطَّعَام', 'بَعْدَ الطَّعَام', 'عِنْدَ الضِّيق', 'عِنْدَ القَلَق', 
    'عِنْدَ النَّوْم', 'عِنْدَ الاسْتِيقاظ', 'أَيَّام الْعِيد', 'رَمَضَان', 
    'ذِكْرٌ عَامّ', 'ذِكْرٌ مُنْفَرِد', 'بَعْدَ الوُضُوء', 'قَبْلَ الوُضُوء', 
    'عِنْدَ السَّفَر', 'عِنْدَ الْوُجُودِ فِي المَسْجِد', 'فِي الطَّرِيق', 
    'فِي الْمَدْرَسَة', 'فِي الْعَمَل', 'عِنْدَ الشِّدَّة', 'عِنْدَ الْفَرَح', 
    'عِنْدَ الْحُزْن', 'عِنْدَ الْمَرَض', 'فِي الْجَمَاعَة', 'خِصّ بِاللَّيْل', 
    'خِصّ بِالنَّهَار', 'أَيَّام الجُمُعَة', 'أَيَّام الشَّهْر الحَرَام', 
    'أَيَّام رَمَضَان', 'أَيَّام الْحَجّ', 'فِي الْبَيْت', 'فِي السُّوق', 
    'فِي الْحَقْل', 'عِنْدَ الْوِلَادَة', 'أَيَّام مُخْتَلِفَة'
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

  void addCustomDhikr() {
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        final countController = TextEditingController(text: '33');
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إضافة ذكر مخصص',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: textController,
                    style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'نص الذكر',
                      labelStyle: GoogleFonts.cairo(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: countController,
                    style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'عدد التكرارات',
                      labelStyle: GoogleFonts.cairo(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              setState(() {
                                selectedAdhkar.add(Dhikr(
                                  id: DateTime.now().toString(),
                                  text: textController.text,
                                  targetCount: int.tryParse(countController.text) ?? 33,
                                ));
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('إضافة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              "إضافة ورد جديد",              style: GoogleFonts.cairo(
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
                // SliverAppBar(
                //   expandedHeight: 120.h,
                //   floating: false,
                //   pinned: true,
                //   backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF00897B),
                //   leading: const CupertinoNavigationBarBackButton(color: Colors.white),
                //   flexibleSpace: FlexibleSpaceBar(
                //     centerTitle: true,
                //     title: Text(
                //       "إضافة ورد جديد",
                //       style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                //     ),
                //     background: Container(
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: isDark
                //               ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                //               : [const Color(0xFF00BFA5), const Color(0xFF00897B)],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SliverPadding(
                  padding: EdgeInsets.all(20.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader("اسم الورد", Icons.drive_file_rename_outline, isDark),
                      SizedBox(height: 12.h),
                      _buildNameInput(isDark),
                      SizedBox(height: 24.h),

                      _buildSectionHeader("الفئة", Icons.category_rounded, isDark),
                      SizedBox(height: 12.h),
                      _buildCategoryGrid(isDark),
                      SizedBox(height: 24.h),

                      _buildSectionHeader("اختر الأذكار", Icons.format_quote_rounded, isDark),
                      SizedBox(height: 12.h),
                      ...suggestedAdhkar.map((dhikr) => _buildDhikrOption(dhikr, isDark)),
                      
                      if (selectedAdhkar.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        _buildSectionHeader("الأذكار المختارة", Icons.playlist_add_check_rounded, isDark),
                        SizedBox(height: 12.h),
                        ...selectedAdhkar.asMap().entries.map((entry) => _buildSelectedDhikrItem(entry.value, entry.key, isDark)),
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
              final newWird = Wird(
                id: DateTime.now().toString(),
                name: nameController.text,
                category: selectedCategory,
                adhkar: selectedAdhkar,
                createdAt: DateTime.now(),
              );
              Navigator.pop(context, newWird);
            } else {
              KHelper.showError(message: "يرجى إدخال اسم الورد واختيار ذكر واحد على الأقل");
            }
          },
          label: Text("حفظ الورد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.check_circle_outline_rounded),
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
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
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? Colors.tealAccent : const Color(0xFF00897B)) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
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
    final primaryColor = isDark ? Colors.tealAccent : const Color(0xFF00897B);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? (isDark ? Colors.tealAccent.withOpacity(0.1) : const Color(0xFF00897B).withOpacity(0.05)) : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
