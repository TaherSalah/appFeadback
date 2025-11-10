import '../../core/shard/exports/all_exports.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreenBuilder();
  }
}

// نموذج البيانات
// class Dhikr {
//   final String id;
//   final String text;
//   final int targetCount;
//   int currentCount;
//
//   Dhikr({
//     required this.id,
//     required this.text,
//     required this.targetCount,
//     this.currentCount = 0,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'text': text,
//     'targetCount': targetCount,
//     'currentCount': currentCount,
//   };
//
//   factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
//     id: json['id'],
//     text: json['text'],
//     targetCount: json['targetCount'],
//     currentCount: json['currentCount'] ?? 0,
//   );
// }
//
// class Wird {
//   final String id;
//   final String name;
//   final List<Dhikr> adhkar;
//   final DateTime createdAt;
//   int completedCount;
//
//   Wird({
//     required this.id,
//     required this.name,
//     required this.adhkar,
//     required this.createdAt,
//     this.completedCount = 0,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'adhkar': adhkar.map((d) => d.toJson()).toList(),
//     'createdAt': createdAt.toIso8601String(),
//     'completedCount': completedCount,
//   };
//
//   factory Wird.fromJson(Map<String, dynamic> json) => Wird(
//     id: json['id'],
//     name: json['name'],
//     adhkar: (json['adhkar'] as List)
//         .map((d) => Dhikr.fromJson(d))
//         .toList(),
//     createdAt: DateTime.parse(json['createdAt']),
//     completedCount: json['completedCount'] ?? 0,
//   );
// }
//
// // مدير البيانات
// class WirdManager {
//   static const String _key = 'awrad_data';
//
//   Future<List<Wird>> loadAwrad() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_key);
//     if (data == null) return [];
//
//     final List<dynamic> jsonList = json.decode(data);
//     return jsonList.map((j) => Wird.fromJson(j)).toList();
//   }
//
//   Future<void> saveAwrad(List<Wird> awrad) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String data = json.encode(awrad.map((w) => w.toJson()).toList());
//     await prefs.setString(_key, data);
//   }
// }
//
// // الشاشة الرئيسية
// class WirdHomeScreen extends StatefulWidget {
//   @override
//   _WirdHomeScreenState createState() => _WirdHomeScreenState();
// }
//
// class _WirdHomeScreenState extends State<WirdHomeScreen> {
//   List<Wird> awrad = [];
//   final WirdManager manager = WirdManager();
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//     final data = await manager.loadAwrad();
//     setState(() {
//       awrad = data;
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('أورادي اليومية'),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : awrad.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.book, size: 80, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'لا توجد أوراد بعد',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'اضغط + لإضافة ورد جديد',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: awrad.length,
//         itemBuilder: (context, index) {
//           final wird = awrad[index];
//           return Card(
//             elevation: 3,
//             margin: EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               contentPadding: EdgeInsets.all(16),
//               title: Text(
//                 wird.name,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 8),
//                   Text('${wird.adhkar.length} ذكر'),
//                   Text(
//                     'أكملته ${wird.completedCount} مرة',
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 ],
//               ),
//               trailing: Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TasbihScreen(wird: wird),
//                   ),
//                 );
//                 if (result == true) {
//                   await manager.saveAwrad(awrad);
//                   setState(() {});
//                 }
//               },
//               onLongPress: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text('حذف الورد'),
//                     content: Text('هل تريد حذف "${wird.name}"؟'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text('إلغاء'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() => awrad.removeAt(index));
//                           manager.saveAwrad(awrad);
//                           Navigator.pop(context);
//                         },
//                         child: Text(
//                           'حذف',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final newWird = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddWirdScreen(),
//             ),
//           );
//           if (newWird != null) {
//             setState(() => awrad.add(newWird));
//             await manager.saveAwrad(awrad);
//           }
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Colors.teal,
//       ),
//     );
//   }
// }
//
// // شاشة إضافة ورد جديد
// class AddWirdScreen extends StatefulWidget {
//   @override
//   _AddWirdScreenState createState() => _AddWirdScreenState();
// }
//
// class _AddWirdScreenState extends State<AddWirdScreen> {
//   final nameController = TextEditingController();
//   List<Dhikr> selectedAdhkar = [];
//
//   // أذكار مقترحة
//   final List<Map<String, dynamic>> suggestedAdhkar = [
//     {'text': 'سبحان الله', 'count': 33},
//     {'text': 'الحمد لله', 'count': 33},
//     {'text': 'الله أكبر', 'count': 34},
//     {'text': 'لا إله إلا الله', 'count': 100},
//     {'text': 'استغفر الله', 'count': 100},
//     {'text': 'سبحان الله وبحمده', 'count': 100},
//     {'text': 'لا حول ولا قوة إلا بالله', 'count': 50},
//     {'text': 'اللهم صل على محمد', 'count': 100},
//   ];
//
//   void addCustomDhikr() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final textController = TextEditingController();
//         final countController = TextEditingController(text: '33');
//         return AlertDialog(
//           title: Text('إضافة ذكر مخصص'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: textController,
//                 decoration: InputDecoration(
//                   labelText: 'نص الذكر',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: countController,
//                 decoration: InputDecoration(
//                   labelText: 'عدد التكرارات',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء'),
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
//               child: Text('إضافة'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إضافة ورد جديد'),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 labelText: 'اسم الورد',
//                 hintText: 'مثال: ورد الصباح',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'اختر الأذكار:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: suggestedAdhkar.map((dhikr) {
//                 return FilterChip(
//                   label: Text('${dhikr['text']} (${dhikr['count']})'),
//                   selected: selectedAdhkar.any((d) => d.text == dhikr['text']),
//                   onSelected: (selected) {
//                     setState(() {
//                       if (selected) {
//                         selectedAdhkar.add(Dhikr(
//                           id: DateTime.now().toString(),
//                           text: dhikr['text'],
//                           targetCount: dhikr['count'],
//                         ));
//                       } else {
//                         selectedAdhkar
//                             .removeWhere((d) => d.text == dhikr['text']);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 12),
//             OutlinedButton.icon(
//               onPressed: addCustomDhikr,
//               icon: Icon(Icons.add),
//               label: Text('إضافة ذكر مخصص'),
//             ),
//             if (selectedAdhkar.isNotEmpty) ...[
//               SizedBox(height: 24),
//               Text(
//                 'الأذكار المختارة:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               ...selectedAdhkar.map((dhikr) => Card(
//                 child: ListTile(
//                   title: Text(dhikr.text),
//                   subtitle: Text('${dhikr.targetCount} مرة'),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () {
//                       setState(() => selectedAdhkar.remove(dhikr));
//                     },
//                   ),
//                 ),
//               )),
//             ],
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: selectedAdhkar.isEmpty
//                   ? null
//                   : () {
//                 if (nameController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('الرجاء إدخال اسم الورد')),
//                   );
//                   return;
//                 }
//                 final wird = Wird(
//                   id: DateTime.now().toString(),
//                   name: nameController.text,
//                   adhkar: selectedAdhkar,
//                   createdAt: DateTime.now(),
//                 );
//                 Navigator.pop(context, wird);
//               },
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('حفظ الورد', style: TextStyle(fontSize: 16)),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // شاشة التسبيح
// class TasbihScreen extends StatefulWidget {
//   final Wird wird;
//
//   TasbihScreen({required this.wird});
//
//   @override
//   _TasbihScreenState createState() => _TasbihScreenState();
// }
//
// class _TasbihScreenState extends State<TasbihScreen> {
//   int currentDhikrIndex = 0;
//
//   void incrementCount() {
//     setState(() {
//       final dhikr = widget.wird.adhkar[currentDhikrIndex];
//       if (dhikr.currentCount < dhikr.targetCount) {
//         dhikr.currentCount++;
//
//         if (dhikr.currentCount == dhikr.targetCount) {
//           // الانتقال للذكر التالي
//           if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
//             Future.delayed(Duration(milliseconds: 500), () {
//               setState(() => currentDhikrIndex++);
//             });
//           } else {
//             // إكمال الورد
//             widget.wird.completedCount++;
//             showCompletionDialog();
//           }
//         }
//       }
//     });
//   }
//
//   void showCompletionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('أحسنت! 🎉'),
//         content: Text('لقد أكملت الورد بنجاح\nهذه المرة رقم ${widget.wird.completedCount}'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // إعادة تعيين العدادات
//               for (var dhikr in widget.wird.adhkar) {
//                 dhikr.currentCount = 0;
//               }
//               setState(() => currentDhikrIndex = 0);
//               Navigator.pop(context);
//             },
//             child: Text('ابدأ من جديد'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context, true);
//             },
//             child: Text('إنهاء'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dhikr = widget.wird.adhkar[currentDhikrIndex];
//     final progress = dhikr.currentCount / dhikr.targetCount;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.wird.name),
//         backgroundColor: Colors.teal,
//       ),
//       body: GestureDetector(
//         onTap: incrementCount,
//         child: Container(
//           color: Colors.teal.shade50,
//           child: Column(
//             children: [
//               // شريط التقدم
//               LinearProgressIndicator(
//                 value: progress,
//                 minHeight: 8,
//                 backgroundColor: Colors.grey.shade300,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
//               ),
//               SizedBox(height: 16),
//               // مؤشر الذكر الحالي
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   'الذكر ${currentDhikrIndex + 1} من ${widget.wird.adhkar.length}',
//                   style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // نص الذكر
//                       Padding(
//                         padding: EdgeInsets.all(24),
//                         child: Text(
//                           dhikr.text,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             height: 1.8,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                       // العداد
//                       Container(
//                         width: 200,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 20,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               '${dhikr.currentCount}',
//                               style: TextStyle(
//                                 fontSize: 64,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.teal,
//                               ),
//                             ),
//                             Text(
//                               'من ${dhikr.targetCount}',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                       Text(
//                         'اضغط في أي مكان للتسبيح',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // زر إعادة التعيين
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           dhikr.currentCount = 0;
//                         });
//                       },
//                       icon: Icon(Icons.refresh),
//                       label: Text('إعادة الذكر الحالي'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         for (var d in widget.wird.adhkar) {
//                           d.currentCount = 0;
//                         }
//                         setState(() => currentDhikrIndex = 0);
//                       },
//                       icon: Icon(Icons.restart_alt),
//                       label: Text('إعادة الورد'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// نقطة البداية



// =============== نماذج البيانات ===============

class Dhikr {
  final String id;
  final String text;
  final int targetCount;
  int currentCount;

  Dhikr({
    required this.id,
    required this.text,
    required this.targetCount,
    this.currentCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'targetCount': targetCount,
    'currentCount': currentCount,
  };

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
    id: json['id'],
    text: json['text'],
    targetCount: json['targetCount'],
    currentCount: json['currentCount'] ?? 0,
  );
}

class Wird {
  final String id;
  final String name;
  final List<Dhikr> adhkar;
  final DateTime createdAt;
  int completedCount;
  DateTime? lastCompletedDate;
  String? reminderTime;
  String category;
  List<DateTime> completionHistory;
  bool isCompleted;


  // ✅ إضافة حفظ التقدم الحالي
  int currentDhikrIndex;
  bool isInProgress;

  Wird({
    required this.id,
    required this.name,
    required this.adhkar,
    required this.createdAt,
    this.completedCount = 0,
    this.lastCompletedDate,
    this.reminderTime,
    this.category = 'عام',
    List<DateTime>? completionHistory,
    this.currentDhikrIndex = 0,
    this.isInProgress = false,

    this.isCompleted = false, // ✅ افتراضيًا الورد غير منجز

  }) : completionHistory = completionHistory ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'adhkar': adhkar.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'completedCount': completedCount,
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'reminderTime': reminderTime,
    'category': category,
    'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
    'currentDhikrIndex': currentDhikrIndex, // ✅ حفظ
    'isInProgress': isInProgress, // ✅ حفظ
    'isCompleted': isCompleted,

  };

  factory Wird.fromJson(Map<String, dynamic> json) => Wird(
    isCompleted: json['isCompleted'] ?? false,

    id: json['id'],
    name: json['name'],
    adhkar: (json['adhkar'] as List).map((d) => Dhikr.fromJson(d)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    completedCount: json['completedCount'] ?? 0,
    lastCompletedDate: json['lastCompletedDate'] != null
        ? DateTime.parse(json['lastCompletedDate'])
        : null,
    reminderTime: json['reminderTime'],
    category: json['category'] ?? 'عام',
    completionHistory: (json['completionHistory'] as List?)
        ?.map((d) => DateTime.parse(d))
        .toList() ??
        [],
    currentDhikrIndex: json['currentDhikrIndex'] ?? 0, // ✅ استرجاع
    isInProgress: json['isInProgress'] ?? false, // ✅ استرجاع

  );
}
class UserStats {
  int totalTasbihat;
  int currentStreak;
  int longestStreak;
  int level;
  List<String> achievements;
  Map<String, int> dailyCompletions;



  UserStats({
    this.totalTasbihat = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,

    this.level = 1,
    List<String>? achievements,
    Map<String, int>? dailyCompletions,
  })  : achievements = achievements ?? [],
        dailyCompletions = dailyCompletions ?? {};

  Map<String, dynamic> toJson() => {
    'totalTasbihat': totalTasbihat,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'level': level,
    'achievements': achievements,
    'dailyCompletions': dailyCompletions,

  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalTasbihat: json['totalTasbihat'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    level: json['level'] ?? 1,
    achievements: List<String>.from(json['achievements'] ?? []),
    dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
  );
}

// =============== مدير البيانات ===============

class WirdManager {
  static const String _awradKey = 'awrad_data';
  static const String _statsKey = 'user_stats';
  static const String _themeKey = 'app_theme';
  static const String _soundKey = 'sound_enabled';
  static const String _hapticKey = 'haptic_enabled';

  Future<List<Wird>> loadAwrad() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_awradKey);
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((j) => Wird.fromJson(j)).toList();
  }

  Future<void> saveAwrad(List<Wird> awrad) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(awrad.map((w) => w.toJson()).toList());
    await prefs.setString(_awradKey, data);
  }

  Future<UserStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_statsKey);
    if (data == null) return UserStats();
    return UserStats.fromJson(json.decode(data));
  }

  Future<void> saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> updateStats(int tasbihatCount) async {
    final stats = await loadStats();
    stats.totalTasbihat += tasbihatCount;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    stats.dailyCompletions[today] = (stats.dailyCompletions[today] ?? 0) + 1;

    // تحديث المستوى
    stats.level = (stats.totalTasbihat / 1000).floor() + 1;

    // تحديث السلسلة
    _updateStreak(stats);

    // فتح الإنجازات
    _checkAchievements(stats);

    await saveStats(stats);
  }

  void _updateStreak(UserStats stats) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: 1)));

    if (stats.dailyCompletions.containsKey(today)) {
      if (stats.dailyCompletions.containsKey(yesterday)) {
        stats.currentStreak++;
      } else {
        stats.currentStreak = 1;
      }
      if (stats.currentStreak > stats.longestStreak) {
        stats.longestStreak = stats.currentStreak;
      }
    }
  }

  void _checkAchievements(UserStats stats) {
    final achievements = <String>[];

    if (stats.totalTasbihat >= 100 && !stats.achievements.contains('beginner')) {
      achievements.add('beginner');
    }
    if (stats.totalTasbihat >= 1000 && !stats.achievements.contains('dedicated')) {
      achievements.add('dedicated');
    }
    if (stats.totalTasbihat >= 10000 && !stats.achievements.contains('master')) {
      achievements.add('master');
    }
    if (stats.currentStreak >= 7 && !stats.achievements.contains('week_streak')) {
      achievements.add('week_streak');
    }
    if (stats.currentStreak >= 30 && !stats.achievements.contains('month_streak')) {
      achievements.add('month_streak');
    }

    stats.achievements.addAll(achievements);
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<bool> isHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticKey) ?? true;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }

  Future<String> exportData() async {
    final awrad = await loadAwrad();
    final stats = await loadStats();
    final data = {
      'awrad': awrad.map((w) => w.toJson()).toList(),
      'stats': stats.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    return json.encode(data);
  }

  Future<void> importData(String jsonData) async {
    final data = json.decode(jsonData);
    final awrad = (data['awrad'] as List).map((w) => Wird.fromJson(w)).toList();
    final stats = UserStats.fromJson(data['stats']);
    await saveAwrad(awrad);
    await saveStats(stats);
  }
}

// =============== الشاشة الرئيسية ===============
class WirdHomeScreen extends StatefulWidget {
  @override
  _WirdHomeScreenState createState() => _WirdHomeScreenState();
}

class _WirdHomeScreenState extends State<WirdHomeScreen> {
  List<Wird> awrad = [];
  List<Wird> completedAwrad = [];
  UserStats stats = UserStats();
  final WirdManager manager = WirdManager();
  bool isLoading = true;
  String selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await manager.loadAwrad();
    final statsData = await manager.loadStats();

    setState(() {
      awrad = data.where((w) => !w.isCompleted).toList();
      completedAwrad = data.where((w) => w.isCompleted).toList();
      stats = statsData;
      isLoading = false;
    });
  }

  List<String> get categories {
    final cats = awrad.map((w) => w.category).toSet().toList();
    return ['الكل', ...cats];
  }

  List<Wird> get filteredAwrad {
    if (selectedCategory == 'الكل') return awrad;
    return awrad.where((w) => w.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('أورادك اليومية'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(stats: stats),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // بطاقة الإحصائيات السريعة
          _buildStatsCard(isDark),

          // فلتر الفئات
          if (categories.length > 1)
            _buildCategoryFilter(isDark),

          // قائمة الأوراد
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text('الأوراد الجارية (${filteredAwrad.length})'),
                  children: filteredAwrad
                      .map((wird) => _buildWirdCard(wird, isDark: isDark))
                      .toList(),
                ),
                ExpansionTile(
                  initiallyExpanded: false,
                  title: Text('الأوراد المنجزة (${completedAwrad.length})'),
                  children: completedAwrad
                      .map((wird) => _buildWirdCard(wird, isDark: isDark, completed: true))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newWird = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWirdScreen(isDark: isDark),
            ),
          );
          if (newWird != null) {
            setState(() => awrad.add(newWird));
            await manager.saveAwrad([...awrad, ...completedAwrad]);
          }
        },
        icon: Icon(Icons.add),
        label: Text('ورد جديد'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade800, Colors.grey.shade700]
              : [Colors.teal, Colors.teal.shade300],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('🔥', '${stats.currentStreak}', 'يوم متتالي', isDark),
          _buildStatItem('⭐', 'المستوى ${stats.level}', '${stats.totalTasbihat} تسبيحة', isDark),
          _buildStatItem('🏆', '${stats.achievements.length}', 'إنجاز', isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.teal
                    : (isDark ? Colors.grey.shade800 : Colors.white),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey.shade300,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWirdCard(Wird wird, {required bool isDark, bool completed = false}) {
    final totalCount = wird.adhkar.fold<int>(0, (sum, dhikr) => sum + dhikr.targetCount);

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: completed
            ? null
            : () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasbihScreen(
                wird: wird,
                isDark: isDark,
              ),
            ),
          );

          if (result == 'completed') {
            setState(() {
              wird.isCompleted = true;
              awrad.remove(wird);
              completedAwrad.add(wird);
            });
            await manager.saveAwrad([...awrad, ...completedAwrad]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ تم نقل الورد إلى قائمة الأوراد المنجزة')),
            );
          } else if (result == true) {
            await manager.saveAwrad([...awrad, ...completedAwrad]);
            await loadData();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('📿', style: TextStyle(fontSize: 30))),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wird.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${wird.adhkar.length} ذكر • $totalCount تسبيحة',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'أكملته ${wird.completedCount} مرة',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!completed)
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
//////////*******************//////////
// class WirdHomeScreen extends StatefulWidget {
//   @override
//   _WirdHomeScreenState createState() => _WirdHomeScreenState();
// }
//
// class _WirdHomeScreenState extends State<WirdHomeScreen> {
//   List<Wird> awrad = [];
//   UserStats stats = UserStats();
//   List<Wird> completedAwrad = [];
//
//   final WirdManager manager = WirdManager();
//   bool isLoading = true;
//   // String currentTheme = 'light';
//   String selectedCategory = 'الكل';
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   // Future<void> loadData() async {
//   //   final data = await manager.loadAwrad();
//   //   final statsData = await manager.loadStats();
//   //   // final theme = await manager.getTheme();
//   //   setState(() {
//   //     awrad = data;
//   //     stats = statsData;
//   //     // currentTheme = theme;
//   //     isLoading = false;
//   //   });
//   // }
//   Future<void> loadData() async {
//     final data = await manager.loadAwrad();
//     final statsData = await manager.loadStats();
//
//     setState(() {
//       awrad = data.where((w) => !w.isCompleted).toList();
//       completedAwrad = data.where((w) => w.isCompleted).toList();
//       stats = statsData;
//       isLoading = false;
//     });
//   }
//
//   List<String> get categories {
//     final cats = awrad.map((w) => w.category).toSet().toList();
//     return ['الكل', ...cats];
//   }
//
//   List<Wird> get filteredAwrad {
//     if (selectedCategory == 'الكل') return awrad;
//     return awrad.where((w) => w.category == selectedCategory).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text('أورادك اليومية'),
//         centerTitle: true,
//         backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.bar_chart),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => StatisticsScreen(stats: stats),
//                 ),
//               );
//             },
//           ),
//           // IconButton(
//           //   icon: Icon(Icons.settings),
//           //   onPressed: () async {
//           //     await Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) => SettingsScreen(
//           //           currentTheme: currentTheme,
//           //           onThemeChanged: (theme) {
//           //             setState(() => currentTheme = theme);
//           //             manager.saveTheme(theme);
//           //           },
//           //         ),
//           //       ),
//           //     );
//           //   },
//           // ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // بطاقة الإحصائيات السريعة
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isDark
//                     ? [Colors.grey.shade800, Colors.grey.shade700]
//                     : [Colors.teal, Colors.teal.shade300],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildStatCard(
//                       '🔥',
//                       '${stats.currentStreak}',
//                       'يوم متتالي',
//                       isDark,
//                     ),
//                     _buildStatCard(
//                       '⭐',
//                       'المستوى ${stats.level}',
//                       '${stats.totalTasbihat} تسبيحة',
//                       isDark,
//                     ),
//                     _buildStatCard(
//                       '🏆',
//                       '${stats.achievements.length}',
//                       'إنجاز',
//                       isDark,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // فلتر الفئات
//           if (categories.length > 1)
//             Container(
//               height: 50,
//               margin: EdgeInsets.symmetric(vertical: 8),
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final cat = categories[index];
//                   final isSelected = cat == selectedCategory;
//                   return GestureDetector(
//                     onTap: () => setState(() => selectedCategory = cat),
//                     child: Container(
//                       margin: EdgeInsets.only(left: 8),
//                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Colors.teal
//                             : (isDark ? Colors.grey.shade800 : Colors.white),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: isSelected ? Colors.teal : Colors.grey.shade300,
//                         ),
//                       ),
//                       child: Text(
//                         cat,
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.white
//                               : (isDark ? Colors.white : Colors.black87),
//                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//           // قائمة الأوراد
//           Expanded(
//             child: filteredAwrad.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.book,
//                     size: 80,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     selectedCategory == 'الكل'
//                         ? 'لا توجد أوراد بعد'
//                         : 'لا توجد أوراد في هذه الفئة',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               padding: EdgeInsets.all(16),
//               itemCount: filteredAwrad.length,
//               itemBuilder: (context, index) {
//                 final wird = filteredAwrad[index];
//                 final totalCount = wird.adhkar.fold<int>(
//                   0,
//                       (sum, dhikr) => sum + dhikr.targetCount,
//                 );
//
//                 return Card(
//                   elevation: 3,
//                   margin: EdgeInsets.only(bottom: 12),
//                   color: isDark ? Colors.grey.shade800 : Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(15),
//                     onTap: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => TasbihScreen(
//                             wird: wird,
//                             isDark: isDark,
//                           ),
//                         ),
//                       );
//
//                       if (result == 'completed') {
//                         setState(() {
//                           wird.isCompleted = true;
//                           awrad.remove(wird);
//                           completedAwrad.add(wird);
//                         });
//                         await manager.saveAwrad([...awrad, ...completedAwrad]);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('✅ تم نقل الورد إلى قائمة الأوراد المنجزة')),
//                         );
//                       } else if (result == true) {
//                         await manager.saveAwrad([...awrad, ...completedAwrad]);
//                         await loadData();
//                       }
//                     },
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.teal.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 '📿',
//                                 style: TextStyle(fontSize: 30),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   wird.name,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: isDark ? Colors.white : Colors.black87,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   '${wird.adhkar.length} ذكر • $totalCount تسبيحة',
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.check_circle,
//                                       size: 16,
//                                       color: Colors.green,
//                                     ),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       'أكملته ${wird.completedCount} مرة',
//                                       style: TextStyle(
//                                         color: Colors.green,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.redAccent),
//                                 onPressed: () async {
//                                   final confirm = await showDialog<bool>(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: Text('تأكيد الحذف'),
//                                       content: Text('هل أنت متأكد أنك تريد حذف هذا الورد؟'),
//                                       actions: [
//                                         TextButton(
//                                           child: Text('إلغاء'),
//                                           onPressed: () => Navigator.pop(context, false),
//                                         ),
//                                         TextButton(
//                                           child: Text('حذف', style: TextStyle(color: Colors.red)),
//                                           onPressed: () => Navigator.pop(context, true),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//
//                                   if (confirm == true) {
//                                     setState(() {
//                                       awrad.removeAt(index);
//                                     });
//                                     await manager.saveAwrad(awrad);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('تم حذف الورد بنجاح')),
//                                     );
//                                   }
//                                 },
//                               ),
//                               Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                             ],
//                           ),
//
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final newWird = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddWirdScreen(isDark: isDark),
//             ),
//           );
//           if (newWird != null) {
//             setState(() => awrad.add(newWird));
//             await manager.saveAwrad(awrad);
//           }
//         },
//         icon: Icon(Icons.add),
//         label: Text('ورد جديد'),
//         backgroundColor: Colors.teal,
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String emoji, String value, String label, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(emoji, style: TextStyle(fontSize: 24)),
//           SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white70,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// =============== شاشة إضافة ورد ===============

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

  final List<String> categories = ['صباح', 'مساء', 'نوم', 'عام', 'مخصص'];

  final List<Map<String, dynamic>> suggestedAdhkar = [
    {'text': 'سبحان الله', 'count': 33},
    {'text': 'الحمد لله', 'count': 33},
    {'text': 'الله أكبر', 'count': 34},
    {'text': 'لا إله إلا الله', 'count': 100},
    {'text': 'استغفر الله', 'count': 100},
    {'text': 'سبحان الله وبحمده', 'count': 100},
    {'text': 'لا حول ولا قوة إلا بالله', 'count': 50},
    {'text': 'اللهم صل على محمد', 'count': 100},
    {'text': 'سبحان الله العظيم', 'count': 50},
    {'text': 'أستغفر الله العظيم', 'count': 70},
  ];

  void addCustomDhikr() {
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        final countController = TextEditingController(text: '33');
        return AlertDialog(
          backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
          title: Text(
            'إضافة ذكر مخصص',
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'نص الذكر',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: countController,
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'عدد التكرارات',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
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
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        title: Text('إضافة ورد جديد'),
        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'اسم الورد',
                hintText: 'مثال: ورد الصباح',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: widget.isDark ? Colors.white70 : null),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'الفئة:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 24),
            Text(
              'اختر الأذكار:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
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
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: addCustomDhikr,
              icon: Icon(Icons.add),
              label: Text('إضافة ذكر مخصص'),
            ),
            if (selectedAdhkar.isNotEmpty) ...[
              SizedBox(height: 24),
              Text(
                'الأذكار المختارة (${selectedAdhkar.length}):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              ...selectedAdhkar.asMap().entries.map((entry) {
                final idx = entry.key;
                final dhikr = entry.value;
                return Card(
                  color: widget.isDark ? Colors.grey.shade800 : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${idx + 1}'),
                      backgroundColor: Colors.teal,
                    ),
                    title: Text(
                      dhikr.text,
                      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                    ),
                    subtitle: Text('${dhikr.targetCount} مرة'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => selectedAdhkar.remove(dhikr));
                      },
                    ),
                  ),
                );
              }),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedAdhkar.isEmpty
                  ? null
                  : () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الرجاء إدخال اسم الورد')),
                  );
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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('حفظ الورد', style: TextStyle(fontSize: 16)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== شاشة التسبيح المتقدمة ===============

class TasbihScreen extends StatefulWidget {
  final Wird wird;
  final bool isDark;

  TasbihScreen({required this.wird, required this.isDark});

  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  late int currentDhikrIndex;
  bool isFocusMode = false;
  bool hapticEnabled = true;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  final WirdManager manager = WirdManager();

  @override
  void initState() {
    super.initState();
    // ✅ ابدأ من آخر ذكر كان المستخدم فيه
    currentDhikrIndex = widget.wird.currentDhikrIndex;
    widget.wird.isInProgress = true;

    loadSettings();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // ✅ احفظ التقدم قبل الخروج
    _saveProgress();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    widget.wird.currentDhikrIndex = currentDhikrIndex;
    widget.wird.isInProgress = true;

    // احفظ البيانات
    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }
  }

  Future<void> loadSettings() async {
    final h = await manager.isHapticEnabled();
    setState(() {
      hapticEnabled = h;
    });
  }

  void incrementCount() async {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      final dhikr = widget.wird.adhkar[currentDhikrIndex];
      if (dhikr.currentCount < dhikr.targetCount) {
        dhikr.currentCount++;

        if (dhikr.currentCount == dhikr.targetCount) {
          if (hapticEnabled) {
            HapticFeedback.mediumImpact();
          }

          // الانتقال للذكر التالي تلقائياً
          if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
            Future.delayed(Duration(milliseconds: 800), () {
              _goToNextDhikr();
            });
          } else {
            // إكمال الورد
            _completeWird();
          }
        }

        // ✅ احفظ التقدم بعد كل تسبيحة
        _saveProgress();
      }
    });
  }

  // ✅ دالة الانتقال للذكر التالي
  void _goToNextDhikr() {
    if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
      setState(() {
        currentDhikrIndex++;
      });
      _saveProgress();
    }
  }

  // ✅ دالة الرجوع للذكر السابق
  void _goToPreviousDhikr() {
    if (currentDhikrIndex > 0) {
      setState(() {
        currentDhikrIndex--;
      });
      _saveProgress();
    }
  }

  // ✅ دالة تخطي الذكر الحالي
  void _skipCurrentDhikr() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'تخطي الذكر؟',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'هل تريد تخطي هذا الذكر والانتقال للتالي؟',
          style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // ضع العداد على الحد الأقصى وانتقل
              widget.wird.adhkar[currentDhikrIndex].currentCount =
                  widget.wird.adhkar[currentDhikrIndex].targetCount;

              if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
                _goToNextDhikr();
              } else {
                _completeWird();
              }
              Navigator.pop(context);
            },
            child: Text('تخطي'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  // void _completeWird() {
  //   widget.wird.completedCount++;
  //   widget.wird.lastCompletedDate = DateTime.now();
  //   widget.wird.isInProgress = false;
  //
  //   final totalTasbihat = widget.wird.adhkar.fold<int>(
  //     0,
  //         (sum, d) => sum + d.targetCount,
  //   );
  //   manager.updateStats(totalTasbihat);
  //
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     showCompletionDialog();
  //   });
  // }
  void _completeWird() async {
    widget.wird.completedCount++;
    widget.wird.lastCompletedDate = DateTime.now();
    widget.wird.isInProgress = false;
    widget.wird.isCompleted = true; // ✅ أضف هذا السطر لتعليم الورد أنه منجز

    final totalTasbihat = widget.wird.adhkar.fold<int>(
      0,
          (sum, d) => sum + d.targetCount,
    );
    manager.updateStats(totalTasbihat);

    // ✅ حفظ الحالة الجديدة (المنجزة) داخل قائمة الأوراد
    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }

    Future.delayed(Duration(milliseconds: 500), () {
      showCompletionDialog();
    });
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 50)),
            SizedBox(height: 8),
            Text(
              'أحسنت!',
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لقد أكملت الورد بنجاح',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'المرة رقم ${widget.wird.completedCount}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // إعادة تعيين كل شيء
              for (var dhikr in widget.wird.adhkar) {
                dhikr.currentCount = 0;
              }
              widget.wird.currentDhikrIndex = 0;
              widget.wird.isInProgress = false;
              setState(() => currentDhikrIndex = 0);
              _saveProgress();
              Navigator.pop(context);
            },
            icon: Icon(Icons.refresh),
            label: Text('ابدأ من جديد'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // إعادة تعيين عند الخروج
              for (var dhikr in widget.wird.adhkar) {
                dhikr.currentCount = 0;
              }
              widget.wird.currentDhikrIndex = 0;
              widget.wird.isInProgress = false;
              _saveProgress();
              Navigator.pop(context);
              // Navigator.pop(context, true);
              Navigator.pop(context, 'completed');

            },
            icon: Icon(Icons.check),
            label: Text('إنهاء'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = widget.wird.adhkar[currentDhikrIndex];
    final progress = dhikr.currentCount / dhikr.targetCount;
    final isCompleted = dhikr.currentCount == dhikr.targetCount;

    return WillPopScope(
      // ✅ احفظ التقدم عند الضغط على زر الرجوع
      onWillPop: () async {
        await _saveProgress();
        return true;
      },
      child: Scaffold(
        backgroundColor: widget.isDark ? Colors.grey.shade900 : Colors.teal.shade50,
        appBar: isFocusMode
            ? null
            : AppBar(
          title: Text(widget.wird.name),
          backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.teal,
          actions: [
            IconButton(
              icon: Icon(isFocusMode ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => isFocusMode = !isFocusMode),
              tooltip: 'وضع التركيز',
            ),
          ],
        ),
        body: GestureDetector(
          onTap: isCompleted ? null : incrementCount,
          child: Container(
            color: widget.isDark ? Colors.grey.shade900 : Colors.teal.shade50,
            child: Column(
              children: [
                if (!isFocusMode) ...[
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Colors.teal,
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الذكر ${currentDhikrIndex + 1} من ${widget.wird.adhkar.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${((dhikr.currentCount / dhikr.targetCount) * 100).toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isFocusMode ? 40 : 32,
                              fontWeight: FontWeight.bold,
                              height: 2,
                              color: widget.isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            child: Text(dhikr.text),
                          ),
                        ),
                        SizedBox(height: 40),
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: isFocusMode ? 220 : 200,
                                height: isFocusMode ? 220 : 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(
                                        0.3 + (_pulseController.value * 0.2),
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${dhikr.currentCount}',
                                      style: TextStyle(
                                        fontSize: isFocusMode ? 72 : 64,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? Colors.green : Colors.teal,
                                      ),
                                    ),
                                    if (!isFocusMode)
                                      Text(
                                        'من ${dhikr.targetCount}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (!isFocusMode) ...[
                          SizedBox(height: 40),
                          Text(
                            'اضغط في أي مكان للتسبيح',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ✅ أزرار التحكم الجديدة
                if (!isFocusMode)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // أزرار التنقل (السابق / التالي)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // زر السابق
                            ElevatedButton.icon(
                              onPressed: currentDhikrIndex > 0 ? _goToPreviousDhikr : null,
                              icon: Icon(Icons.arrow_back),
                              label: Text('السابق'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                            SizedBox(width: 12),
                            // زر التخطي
                            ElevatedButton.icon(
                              onPressed: _skipCurrentDhikr,
                              icon: Icon(Icons.skip_next),
                              label: Text('تخطي'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                            SizedBox(width: 12),
                            // زر التالي
                            ElevatedButton.icon(
                              onPressed: currentDhikrIndex < widget.wird.adhkar.length - 1
                                  ? _goToNextDhikr
                                  : null,
                              icon: Icon(Icons.arrow_forward),
                              label: Text('التالي'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // أزرار الإعادة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => dhikr.currentCount = 0);
                                _saveProgress();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('إعادة الحالي'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
                                    title: Text(
                                      'إعادة الورد؟',
                                      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
                                    ),
                                    content: Text(
                                      'هل تريد إعادة الورد من البداية؟',
                                      style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          for (var d in widget.wird.adhkar) {
                                            d.currentCount = 0;
                                          }
                                          widget.wird.currentDhikrIndex = 0;
                                          widget.wird.isInProgress = false;
                                          setState(() => currentDhikrIndex = 0);
                                          _saveProgress();
                                          Navigator.pop(context);
                                        },
                                        child: Text('إعادة الكل'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.restart_alt),
                              label: Text('إعادة الكل'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============== شاشة الإحصائيات ===============

class StatisticsScreen extends StatelessWidget {
  final UserStats stats;

  StatisticsScreen({required this.stats});

  @override
  Widget build(BuildContext context) {
    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      return {
        'date': DateFormat('E', 'ar').format(date),
        'count': stats.dailyCompletions[key] ?? 0,
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('الإحصائيات'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'إجمالي التسبيحات',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${stats.totalTasbihat}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
                          SizedBox(height: 8),
                          Text(
                            '${stats.currentStreak}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text('يوم متتالي', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                          SizedBox(height: 8),
                          Text(
                            '${stats.longestStreak}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text('أطول سلسلة', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'نشاط آخر 7 أيام',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (last7Days.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                            return Text(
                              last7Days[value.toInt()]['date'] as String,
                              style: TextStyle(fontSize: 12),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: last7Days.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['count'] as int).toDouble(),
                          color: Colors.teal,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'الإنجازات (${stats.achievements.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _buildAchievements(stats),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAchievements(UserStats stats) {
    final allAchievements = [
      {'id': 'beginner', 'icon': '🌱', 'title': 'البداية', 'desc': '100 تسبيحة'},
      {'id': 'dedicated', 'icon': '⭐', 'title': 'المواظب', 'desc': '1000 تسبيحة'},
      {'id': 'master', 'icon': '👑', 'title': 'الخبير', 'desc': '10000 تسبيحة'},
      {'id': 'week_streak', 'icon': '🔥', 'title': 'أسبوع', 'desc': '7 أيام متتالية'},
      {'id': 'month_streak', 'icon': '💎', 'title': 'شهر', 'desc': '30 يوم متتالي'},
    ];

    return allAchievements.map((ach) {
      final isUnlocked = stats.achievements.contains(ach['id']);
      return Container(
        width: 100,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.teal.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? Colors.teal : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              ach['icon'] as String,
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              ach['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.teal : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              ach['desc'] as String,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }
}

// =============== شاشة الإعدادات ===============

// class SettingsScreen extends StatefulWidget {
//   final String currentTheme;
//   final Function(String) onThemeChanged;
//
//   SettingsScreen({required this.currentTheme, required this.onThemeChanged});
//
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   final WirdManager manager = WirdManager();
//   bool soundEnabled = true;
//   bool hapticEnabled = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadSettings();
//   }
//
//   Future<void> loadSettings() async {
//     final s = await manager.isSoundEnabled();
//     final h = await manager.isHapticEnabled();
//     setState(() {
//       soundEnabled = s;
//       hapticEnabled = h;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = widget.currentTheme == 'dark';
//
//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
//       appBar: AppBar(
//         title: Text('الإعدادات'),
//         backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal,
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: Icon(Icons.dark_mode, color: isDark ? Colors.white : null),
//             title: Text(
//               'الوضع الليلي',
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//             trailing: Switch(
//               value: isDark,
//               onChanged: (value) {
//                 widget.onThemeChanged(value ? 'dark' : 'light');
//               },
//             ),
//           ),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.volume_up, color: isDark ? Colors.white : null),
//             title: Text(
//               'الأصوات',
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//             trailing: Switch(
//               value: soundEnabled,
//               onChanged: (value) {
//                 setState(() => soundEnabled = value);
//                 manager.setSoundEnabled(value);
//               },
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.vibration, color: isDark ? Colors.white : null),
//             title: Text(
//               'الاهتزاز',
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//             trailing: Switch(
//               value: hapticEnabled,
//               onChanged: (value) {
//                 setState(() => hapticEnabled = value);
//                 manager.setHapticEnabled(value);
//               },
//             ),
//           ),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.file_download, color: isDark ? Colors.white : null),
//             title: Text(
//               'تصدير البيانات',
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//             onTap: () async {
//               final data = await manager.exportData();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('تم تصدير البيانات بنجاح')),
//               );
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.info, color: isDark ? Colors.white : null),
//             title: Text(
//               'عن التطبيق',
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: 'أورادي',
//                 applicationVersion: '2.0',
//                 applicationIcon: Text('📿', style: TextStyle(fontSize: 40)),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// =============== نقطة البداية ===============
