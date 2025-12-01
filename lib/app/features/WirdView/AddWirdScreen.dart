import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_helper.dart';
import '../messa_view/azkar_massa.dart';
import 'data/Dhikr.dart';
import 'data/Wird.dart';

class AddWirdScreen extends StatefulWidget {
  final bool isDark;

  AddWirdScreen({required this.isDark});

  @override
  _AddWirdScreenState createState() => _AddWirdScreenState();
}

class _AddWirdScreenState extends State<AddWirdScreen> {
  final nameController = TextEditingController();
  List<Dhikr> selectedAdhkar = [];
  String selectedCategory = 'صباح';

  // final List<String> categories = ['صباح', 'مساء', 'نوم', 'عام', 'مخصص'];
  final List<String> categories = [
    'صَبَاح',                   // صباح
    'مَسَاء',                   // مساء
    'نَوْم',                     // نوم
    'عَام',                      // عام
    'مُخَصَّص',                  // مخصص
    'بَعْدَ الصَّلَاة',           // بعد الصلاة
    'قَبْلَ الطَّعَام',           // قبل الطعام
    'بَعْدَ الطَّعَام',           // بعد الطعام
    'عِنْدَ الضِّيق',             // عند الضيق
    'عِنْدَ القَلَق',             // عند القلق
    'عِنْدَ النَّوْم',             // عند النوم
    'عِنْدَ الاسْتِيقاظ',          // عند الاستيقاظ
    'أَيَّام الْعِيد',            // أيام العيد
    'رَمَضَان',                   // رمضان
    'ذِكْرٌ عَامّ',                // ذكر عام
    'ذِكْرٌ مُنْفَرِد',             // ذكر منفرد
    'بَعْدَ الوُضُوء',             // بعد الوضوء
    'قَبْلَ الوُضُوء',             // قبل الوضوء
    'عِنْدَ السَّفَر',             // عند السفر
    'عِنْدَ الْوُجُودِ فِي المَسْجِد', // عند وجودك في المسجد
    'فِي الطَّرِيق',               // في الطريق
    'فِي الْمَدْرَسَة',            // في المدرسة
    'فِي الْعَمَل',               // في العمل
    'عِنْدَ الشِّدَّة',             // عند الشدة
    'عِنْدَ الْفَرَح',             // عند الفرح
    'عِنْدَ الْحُزْن',             // عند الحزن
    'عِنْدَ الْمَرَض',             // عند المرض
    'فِي الْجَمَاعَة',            // في الجماعة
    'خِصّ بِاللَّيْل',             // خص بالليل
    'خِصّ بِالنَّهَار',             // خص بالنهار
    'أَيَّام الجُمُعَة',           // أيام الجمعة
    'أَيَّام الشَّهْر الحَرَام',     // أيام الشهر الحرام
    'أَيَّام رَمَضَان',            // أيام رمضان
    'أَيَّام الْحَجّ',             // أيام الحج
    'فِي الْبَيْت',               // في البيت
    'فِي السُّوق',                 // في السوق
    'فِي الْحَقْل',               // في الحقل
    'عِنْدَ الْوِلَادَة',          // عند الولادة
    'أَيَّام مُخْتَلِفَة',          // أيام مختلفة
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
    {'text': 'اللّهُـمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ', 'count': 100},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ', 'count': 100},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِهِ وَأَصْحَابِهِ', 'count': 100},
    {'text': 'سُبْحَانَ اللهِ الْعَظِيمِ', 'count': 50},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى النَّبِيِّ وَسَلِّمْ', 'count': 100},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى مُحَمَّدٍ وَبَارِكْ عَلَيْهِ', 'count': 100},
    {'text': 'اللّهُـمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ', 'count': 100},
    {'text': 'سُبْحَانَ اللهِ وَالْحَمْدُ لِلّهِ وَاللهُ أَكْبَرُ', 'count': 100},
    {'text': 'لَا إِلَهَ إِلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 'count': 100},
    {'text': 'سُبْحَانَ اللهِ وَالْحَمْدُ لِلّهِ وَاللهُ أَكْبَرُ وَلا حَوْلَ وَلا قُوَّةَ إِلَّا بِاللهِ', 'count': 100},
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main body of the dialog
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? [
                        const Color(0xFF1C1C2D), // Deep blue/dark purple
                        const Color(0xFF2A2A46), // Darker shade of blue/purple
                      ]
                          : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
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
                      // Title
                      Text(
                        'إضافة ذكر مخصص',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Text input for Dhikr text
                      TextField(
                        controller: textController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'نص الذكر',
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Text input for repetition count
                      TextField(
                        controller: countController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'عدد التكرارات',
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
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
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('إضافة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Positioned icon at the top of the dialog
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
                          colors: [Colors.green, Colors.lightGreen],
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
                          Icons.add_circle_rounded,
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

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(isTablet ? 80 : 60),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: isDark
        //             ? [Colors.grey.shade800, Colors.grey.shade900]
        //             : [const Color(0xFF00897B), const Color(0xFF00695C)],
        //         begin: Alignment.topRight,
        //         end: Alignment.bottomLeft,
        //       ),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.1),
        //           blurRadius: 8,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: AppBar(
        //       leading: CupertinoNavigationBarBackButton(
        //         color: Colors.white,
        //       ),
        //       centerTitle: true,
        //       backgroundColor: Colors.transparent,
        //       elevation: 0,
        //       title: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(
        //             Icons.auto_stories_rounded,
        //             color: Colors.white,
        //             size: isTablet ? 28 : 24,
        //           ),
        //           const SizedBox(width: 12),
        //           Text(
        //             "إضافة ورد جديد",
        //             style: GoogleFonts.cairo(
        //               color: Colors.white,
        //               fontWeight: FontWeight.bold,
        //               fontSize: isTablet ? 12.sp : 18.sp,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
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
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة اسم الورد
              _buildCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.drive_file_rename_outline,
                            color: const Color(0xFF00897B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'اسم الورد',
                          style: GoogleFonts.cairo(
                            fontSize: isTablet ? 14.sp : 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.cairo(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: isTablet ? 12.sp : 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'مثال: ورد الصباح',
                        hintStyle: GoogleFonts.cairo(
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00897B),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // بطاقة الفئة
              _buildCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: const Color(0xFF00897B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'الفئة',
                          style: GoogleFonts.cairo(
                            fontSize: isTablet ? 14.sp : 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return InkWell(
                          onTap: () => setState(() => selectedCategory = cat),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                colors: [Color(0xFF00897B), Color(0xFF00695C)],
                              )
                                  : null,
                              color: isSelected
                                  ? null
                                  : isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.cairo(
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white70
                                    : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: isTablet ? 11.sp : 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // بطاقة الأذكار المقترحة
              _buildCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            color: const Color(0xFF00897B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'اختر الأذكار',
                          style: GoogleFonts.cairo(
                            fontSize: isTablet ? 14.sp : 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // عرض الأذكار في قائمة بطاقات أنيقة
                    ...suggestedAdhkar.map((dhikr) {
                      final isSelected = selectedAdhkar.any((d) => d.text == dhikr['text']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedAdhkar.removeWhere((d) => d.text == dhikr['text']);
                                } else {
                                  selectedAdhkar.add(Dhikr(
                                    id: DateTime.now().toString(),
                                    text: dhikr['text'],
                                    targetCount: dhikr['count'],
                                  ));
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                  colors: [Color(0xFF00897B), Color(0xFF00695C)],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                )
                                    : null,
                                color: isSelected
                                    ? null
                                    : isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: const Color(0xFF00897B).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // أيقونة الذكر
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : const Color(0xFF00897B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF00897B),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // نص الذكر
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dhikr['text'],
                                          style: GoogleFonts.amiri(
                                            fontSize: isTablet ? 14.sp : 17,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.repeat_rounded,
                                              size: 16,
                                              color: isSelected
                                                  ? Colors.white.withOpacity(0.9)
                                                  : const Color(0xFF00897B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'يُكرر ${dhikr['count']} مرة',
                                              style: GoogleFonts.cairo(
                                                fontSize: isTablet ? 10.sp : 13,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(0.9)
                                                    : const Color(0xFF00897B),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // أيقونة الاختيار
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                      Icons.check,
                                      color: Color(0xFF00897B),
                                      size: 18,
                                    )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 8),

                    // زر إضافة ذكر مخصص
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00897B),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: addCustomDhikr,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00897B).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF00897B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'إضافة ذكر مخصص',
                                  style: GoogleFonts.cairo(
                                    fontSize: isTablet ? 11.sp : 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00897B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (selectedAdhkar.isNotEmpty) ...[
                const SizedBox(height: 20),

                // بطاقة الأذكار المختارة
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.playlist_add_check_rounded,
                              color: const Color(0xFF00897B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'الأذكار المختارة',
                            style: GoogleFonts.cairo(
                              fontSize: isTablet ? 14.sp : 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00897B), Color(0xFF00695C)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${selectedAdhkar.length}',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 11.sp : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...selectedAdhkar.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final dhikr = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00897B), Color(0xFF00695C)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00897B).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 13.sp : 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              dhikr.text,
                              style: GoogleFonts.cairo(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: isTablet ? 12.sp : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${dhikr.targetCount} مرة',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF00897B),
                                  fontSize: isTablet ? 10.sp : 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() => selectedAdhkar.remove(dhikr));
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // زر الحفظ
              Container(
                decoration: BoxDecoration(
                  gradient: selectedAdhkar.isEmpty
                      ? null
                      : const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00695C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selectedAdhkar.isEmpty
                      ? null
                      : [
                    BoxShadow(
                      color: const Color(0xFF00897B).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: selectedAdhkar.isEmpty
                      ? null
                      : () {
                    if (nameController.text.isEmpty) {
                      KHelper.showSuccess(message: 'الرجاء إدخال اسم الورد');
                      return;
                    }
                    final wird = Wird(
                      id: DateTime.now().toString(),
                      name: nameController.text,
                      adhkar: selectedAdhkar,
                      createdAt: DateTime.now(),
                      category: selectedCategory,
                    );
                    Navigator.pop(context, wird);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 24),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'حفظ الورد',
                      style: GoogleFonts.cairo(
                        fontSize: isTablet ? 13.sp : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAdhkar.isEmpty
                        ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                        : Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: isDark ? Colors.grey.shade800 : Colors.white,
        color:  AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //   final screenWidth = MediaQuery.sizeOf(context).width;
  //   final isTablet = screenWidth > 600;
  //
  //   return Directionality(
  //     textDirection: TextDirection.rtl,
  //     child: Scaffold(
  //       backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
  //       appBar: PreferredSize(
  //         preferredSize: Size.fromHeight(isTablet ? 80 : 60),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: isDark
  //                   ? [Colors.grey.shade800, Colors.grey.shade900]
  //                   : [const Color(0xFF00897B), const Color(0xFF00695C)],
  //               begin: Alignment.topRight,
  //               end: Alignment.bottomLeft,
  //             ),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: AppBar(
  //             leading: CupertinoNavigationBarBackButton(
  //               color: Colors.white,
  //             ),
  //             centerTitle: true,
  //             backgroundColor: Colors.transparent,
  //             elevation: 0,
  //             title: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(
  //                   Icons.auto_stories_rounded,
  //                   color: Colors.white,
  //                   size: isTablet ? 28 : 24,
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Text(
  //                   "إضافة ورد جديد",
  //                   style: GoogleFonts.cairo(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: isTablet ? 12.sp : 18.sp,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       body: SingleChildScrollView(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             // بطاقة اسم الورد
  //             _buildCard(
  //               isDark: isDark,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFF00897B).withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: Icon(
  //                           Icons.drive_file_rename_outline,
  //                           color: const Color(0xFF00897B),
  //                           size: 20,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Text(
  //                         'اسم الورد',
  //                         style: GoogleFonts.cairo(
  //                           fontSize: isTablet ? 14.sp : 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: isDark ? Colors.white : Colors.black87,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   TextField(
  //                     controller: nameController,
  //                     style: GoogleFonts.cairo(
  //                       color: isDark ? Colors.white : Colors.black,
  //                       fontSize: isTablet ? 12.sp : 16,
  //                     ),
  //                     decoration: InputDecoration(
  //                       hintText: 'مثال: ورد الصباح',
  //                       hintStyle: GoogleFonts.cairo(
  //                         color: isDark ? Colors.white38 : Colors.grey.shade400,
  //                       ),
  //                       filled: true,
  //                       fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                       enabledBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                         borderSide: BorderSide(
  //                           color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
  //                         ),
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                         borderSide: const BorderSide(
  //                           color: Color(0xFF00897B),
  //                           width: 2,
  //                         ),
  //                       ),
  //                       contentPadding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 16,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             const SizedBox(height: 20),
  //
  //             // بطاقة الفئة
  //             _buildCard(
  //               isDark: isDark,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFF00897B).withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: Icon(
  //                           Icons.category_rounded,
  //                           color: const Color(0xFF00897B),
  //                           size: 20,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Text(
  //                         'الفئة',
  //                         style: GoogleFonts.cairo(
  //                           fontSize: isTablet ? 14.sp : 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: isDark ? Colors.white : Colors.black87,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Wrap(
  //                     spacing: 10,
  //                     runSpacing: 10,
  //                     children: categories.map((cat) {
  //                       final isSelected = selectedCategory == cat;
  //                       return InkWell(
  //                         onTap: () => setState(() => selectedCategory = cat),
  //                         borderRadius: BorderRadius.circular(20),
  //                         child: Container(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 20,
  //                             vertical: 12,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             gradient: isSelected
  //                                 ? const LinearGradient(
  //                               colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                             )
  //                                 : null,
  //                             color: isSelected
  //                                 ? null
  //                                 : isDark
  //                                 ? Colors.grey.shade800
  //                                 : Colors.grey.shade100,
  //                             borderRadius: BorderRadius.circular(20),
  //                             border: Border.all(
  //                               color: isSelected
  //                                   ? Colors.transparent
  //                                   : isDark
  //                                   ? Colors.grey.shade700
  //                                   : Colors.grey.shade300,
  //                             ),
  //                           ),
  //                           child: Text(
  //                             cat,
  //                             style: GoogleFonts.cairo(
  //                               color: isSelected
  //                                   ? Colors.white
  //                                   : isDark
  //                                   ? Colors.white70
  //                                   : Colors.black87,
  //                               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //                               fontSize: isTablet ? 11.sp : 14,
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             const SizedBox(height: 20),
  //
  //             // بطاقة الأذكار المقترحة
  //             _buildCard(
  //               isDark: isDark,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFF00897B).withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: Icon(
  //                           Icons.format_quote_rounded,
  //                           color: const Color(0xFF00897B),
  //                           size: 20,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Text(
  //                         'اختر الأذكار',
  //                         style: GoogleFonts.cairo(
  //                           fontSize: isTablet ? 14.sp : 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: isDark ? Colors.white : Colors.black87,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Wrap(
  //                     spacing: 10,
  //                     runSpacing: 10,
  //                     children: suggestedAdhkar.map((dhikr) {
  //                       final isSelected = selectedAdhkar.any((d) => d.text == dhikr['text']);
  //                       return InkWell(
  //                         onTap: () {
  //                           setState(() {
  //                             if (isSelected) {
  //                               selectedAdhkar.removeWhere((d) => d.text == dhikr['text']);
  //                             } else {
  //                               selectedAdhkar.add(Dhikr(
  //                                 id: DateTime.now().toString(),
  //                                 text: dhikr['text'],
  //                                 targetCount: dhikr['count'],
  //                               ));
  //                             }
  //                           });
  //                         },
  //                         borderRadius: BorderRadius.circular(16),
  //                         child: Container(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 10,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: isSelected
  //                                 ? const Color(0xFF00897B).withOpacity(0.15)
  //                                 : isDark
  //                                 ? Colors.grey.shade800
  //                                 : Colors.grey.shade50,
  //                             borderRadius: BorderRadius.circular(16),
  //                             border: Border.all(
  //                               color: isSelected
  //                                   ? const Color(0xFF00897B)
  //                                   : isDark
  //                                   ? Colors.grey.shade700
  //                                   : Colors.grey.shade200,
  //                               width: isSelected ? 2 : 1,
  //                             ),
  //                           ),
  //                           child: Row(
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: [
  //                               if (isSelected)
  //                                 Container(
  //                                   margin: const EdgeInsets.only(left: 8),
  //                                   padding: const EdgeInsets.all(2),
  //                                   decoration: const BoxDecoration(
  //                                     color: Color(0xFF00897B),
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: const Icon(
  //                                     Icons.check,
  //                                     color: Colors.white,
  //                                     size: 14,
  //                                   ),
  //                                 ),
  //                               Text(
  //                                 '${dhikr['text']} ',
  //                                 style: GoogleFonts.cairo(
  //                                   color: isDark ? Colors.white : Colors.black87,
  //                                   fontSize: isTablet ? 11.sp : 13,
  //                                   fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //                                 ),
  //                               ),
  //                               Container(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 8,
  //                                   vertical: 2,
  //                                 ),
  //                                 decoration: BoxDecoration(
  //                                   color: const Color(0xFF00897B).withOpacity(0.2),
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Text(
  //                                   '${dhikr['count']}',
  //                                   style: GoogleFonts.cairo(
  //                                     color: const Color(0xFF00897B),
  //                                     fontSize: isTablet ? 10.sp : 12,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   OutlinedButton.icon(
  //                     onPressed: addCustomDhikr,
  //                     icon: const Icon(Icons.add_circle_outline, size: 20),
  //                     label: Text(
  //                       'إضافة ذكر مخصص',
  //                       style: GoogleFonts.cairo(
  //                         fontSize: isTablet ? 11.sp : 14,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     style: OutlinedButton.styleFrom(
  //                       foregroundColor: const Color(0xFF00897B),
  //                       side: const BorderSide(color: Color(0xFF00897B), width: 2),
  //                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             if (selectedAdhkar.isNotEmpty) ...[
  //               const SizedBox(height: 20),
  //
  //               // بطاقة الأذكار المختارة
  //               _buildCard(
  //                 isDark: isDark,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Container(
  //                           padding: const EdgeInsets.all(8),
  //                           decoration: BoxDecoration(
  //                             color: const Color(0xFF00897B).withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: Icon(
  //                             Icons.playlist_add_check_rounded,
  //                             color: const Color(0xFF00897B),
  //                             size: 20,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Text(
  //                           'الأذكار المختارة',
  //                           style: GoogleFonts.cairo(
  //                             fontSize: isTablet ? 14.sp : 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: isDark ? Colors.white : Colors.black87,
  //                           ),
  //                         ),
  //                         const Spacer(),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 12,
  //                             vertical: 6,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             gradient: const LinearGradient(
  //                               colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                             ),
  //                             borderRadius: BorderRadius.circular(20),
  //                           ),
  //                           child: Text(
  //                             '${selectedAdhkar.length}',
  //                             style: GoogleFonts.cairo(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: isTablet ? 11.sp : 14,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 16),
  //                     ...selectedAdhkar.asMap().entries.map((entry) {
  //                       final idx = entry.key;
  //                       final dhikr = entry.value;
  //                       return Container(
  //                         margin: const EdgeInsets.only(bottom: 12),
  //                         decoration: BoxDecoration(
  //                           color: isDark ? Colors.grey.shade800 : Colors.white,
  //                           borderRadius: BorderRadius.circular(16),
  //                           border: Border.all(
  //                             color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
  //                           ),
  //                         ),
  //                         child: ListTile(
  //                           contentPadding: const EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 8,
  //                           ),
  //                           leading: Container(
  //                             width: 40,
  //                             height: 40,
  //                             decoration: BoxDecoration(
  //                               gradient: const LinearGradient(
  //                                 colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                               ),
  //                               shape: BoxShape.circle,
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: const Color(0xFF00897B).withOpacity(0.3),
  //                                   blurRadius: 8,
  //                                   offset: const Offset(0, 2),
  //                                 ),
  //                               ],
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 '${idx + 1}',
  //                                 style: GoogleFonts.cairo(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: isTablet ? 13.sp : 16,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           title: Text(
  //                             dhikr.text,
  //                             style: GoogleFonts.cairo(
  //                               color: isDark ? Colors.white : Colors.black87,
  //                               fontSize: isTablet ? 12.sp : 15,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                           subtitle: Padding(
  //                             padding: const EdgeInsets.only(top: 6),
  //                             child: Text(
  //                               '${dhikr.targetCount} مرة',
  //                               style: GoogleFonts.cairo(
  //                                 color: const Color(0xFF00897B),
  //                                 fontSize: isTablet ? 10.sp : 13,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                           trailing: IconButton(
  //                             icon: const Icon(Icons.delete_outline, color: Colors.red),
  //                             onPressed: () {
  //                               setState(() => selectedAdhkar.remove(dhikr));
  //                             },
  //                           ),
  //                         ),
  //                       );
  //                     }),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //
  //             const SizedBox(height: 24),
  //
  //             // زر الحفظ
  //             Container(
  //               decoration: BoxDecoration(
  //                 gradient: selectedAdhkar.isEmpty
  //                     ? null
  //                     : const LinearGradient(
  //                   colors: [Color(0xFF00897B), Color(0xFF00695C)],
  //                 ),
  //                 borderRadius: BorderRadius.circular(16),
  //                 boxShadow: selectedAdhkar.isEmpty
  //                     ? null
  //                     : [
  //                   BoxShadow(
  //                     color: const Color(0xFF00897B).withOpacity(0.4),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: ElevatedButton.icon(
  //                 onPressed: selectedAdhkar.isEmpty
  //                     ? null
  //                     : () {
  //                   if (nameController.text.isEmpty) {
  //                     KHelper.showSuccess(message: 'الرجاء إدخال اسم الورد');
  //                     return;
  //                   }
  //                   final wird = Wird(
  //                     id: DateTime.now().toString(),
  //                     name: nameController.text,
  //                     adhkar: selectedAdhkar,
  //                     createdAt: DateTime.now(),
  //                     category: selectedCategory,
  //                   );
  //                   Navigator.pop(context, wird);
  //                 },
  //                 icon: const Icon(Icons.check_circle_outline, size: 24),
  //                 label: Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 16),
  //                   child: Text(
  //                     'حفظ الورد',
  //                     style: GoogleFonts.cairo(
  //                       fontSize: isTablet ? 13.sp : 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: selectedAdhkar.isEmpty
  //                       ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
  //                       : Colors.transparent,
  //                   foregroundColor: Colors.white,
  //                   elevation: 0,
  //                   shadowColor: Colors.transparent,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(16),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //
  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildCard({required bool isDark, required Widget child}) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: isDark ? Colors.grey.shade800 : Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: isDark
  //               ? Colors.black.withOpacity(0.3)
  //               : Colors.grey.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: child,
  //   );
  // }
}