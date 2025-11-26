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


  // final List<Map<String, dynamic>> suggestedAdhkar = [
  //   {'text': 'سبحان الله', 'count': 33},
  //   {'text': 'الحمد لله', 'count': 33},
  //   {'text': 'الله أكبر', 'count': 34},
  //   {'text': 'لا إله إلا الله', 'count': 100},
  //   {'text': 'استغفر الله', 'count': 100},
  //   {'text': 'سبحان الله وبحمده', 'count': 100},
  //   {'text': 'لا حول ولا قوة إلا بالله', 'count': 50},
  //   {'text': 'اللهم صل على محمد', 'count': 100},
  //   {'text': 'سبحان الله العظيم', 'count': 50},
  //   {'text': 'أستغفر الله العظيم', 'count': 70},
  // ];


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

  // void addCustomDhikr() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       final textController = TextEditingController();
  //       final countController = TextEditingController(text: '33');
  //       return Directionality(
  //         textDirection: TextDirection.rtl,
  //         child: AlertDialog(
  //           backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
  //           title: Text(
  //             'إضافة ذكر مخصص',
  //             style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: textController,
  //                 style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
  //                 decoration: InputDecoration(
  //                   labelText: 'نص الذكر',
  //                   border: const OutlineInputBorder(),
  //                   labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               TextField(
  //                 controller: countController,
  //                 style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
  //                 decoration: InputDecoration(
  //                   labelText: 'عدد التكرارات',
  //                   border: const OutlineInputBorder(),
  //                   labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
  //                 ),
  //                 keyboardType: TextInputType.number,
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('إلغاء'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 if (textController.text.isNotEmpty) {
  //                   setState(() {
  //                     selectedAdhkar.add(Dhikr(
  //                       id: DateTime.now().toString(),
  //                       text: textController.text,
  //                       targetCount: int.tryParse(countController.text) ?? 33,
  //                     ));
  //                   });
  //                 }
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('إضافة'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: widget.isDark ? Colors.grey.shade900 : Colors.white,
        // appBar: AppBar(
        //   title: const Text('إضافة ورد جديد'),
        //   backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.teal,
        // ),
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(color: isDark?Colors.white:Colors.black,),
            centerTitle: true,
            title: Text(
              "إضافة ورد جديد",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                  MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'اسم الورد',
                  hintText: 'مثال: ورد الصباح',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'الفئة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'اختر الأذكار:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedAdhkar.map((dhikr) {
                  return FilterChip(
                    label: Text('${dhikr['text']} (${dhikr['count']})'),
                    selected: selectedAdhkar.any((d) => d.text == dhikr['text']),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAdhkar.add(Dhikr(
                            id: DateTime.now().toString(),
                            text: dhikr['text'],
                            targetCount: dhikr['count'],
                          ));
                        } else {
                          selectedAdhkar.removeWhere((d) => d.text == dhikr['text']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: addCustomDhikr,
                icon: const Icon(Icons.add),
                label:  TextWidget(title: 'إضافة ذكر مخصص',fontSize: 14.sp,),
              ),
              if (selectedAdhkar.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'الأذكار المختارة (${selectedAdhkar.length}):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...selectedAdhkar.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final dhikr = entry.value;
                  return Card(
                    color: AppThemeColors.cardBackgroundColor(context),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${idx + 1}'),
                        backgroundColor: Colors.black,

                      ),
                      title: Text(
                        dhikr.text,

                        style: TextStyle(color: widget.isDark ? Colors.white : Colors.black,),
                      ),
                      subtitle: Text('${dhikr.targetCount} مرة'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() => selectedAdhkar.remove(dhikr));
                        },
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: selectedAdhkar.isEmpty
                    ? null
                    : () {
                  if (nameController.text.isEmpty) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('الرجاء إدخال اسم الورد')),
                    // );
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('حفظ الورد', style: TextStyle(fontSize: 16,fontFamily: "me")),
                ),
                style: ElevatedButton.styleFrom(

                  backgroundColor:       AppThemeColors.buttonBackgroundColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}