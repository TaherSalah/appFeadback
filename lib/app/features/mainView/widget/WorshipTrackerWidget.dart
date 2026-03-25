import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorshipTrackerWidget extends StatefulWidget {
  const WorshipTrackerWidget({super.key});

  @override
  State<WorshipTrackerWidget> createState() => _WorshipTrackerWidgetState();
}

class _WorshipTrackerWidgetState extends State<WorshipTrackerWidget> {
  // القائمة الأساسية للمهام
  final List<Map<String, dynamic>> _defaultTasks = [
    {"title": "صلاة الفجر", "icon": Icons.wb_twilight, "done": false},
    {"title": "أذكار الصباح", "icon": Icons.wb_sunny, "done": false},
    {"title": "صلاة الظهر", "icon": Icons.sunny, "done": false},
    {"title": "صلاة العصر", "icon": Icons.cloud, "done": false},
    {"title": "صلاة المغرب", "icon": Icons.nights_stay_outlined, "done": false},
    {"title": "أذكار المساء", "icon": Icons.mode_night_outlined, "done": false},
    {"title": "صلاة العشاء", "icon": Icons.nightlight_round, "done": false},
    {"title": "الوتر", "icon": Icons.star_border, "done": false},
    {"title": "ورد القرآن", "icon": Icons.book, "done": false},
  ];

  List<Map<String, dynamic>> _dailyTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // التحقق هل هناك بيانات محفوظة لهذا اليوم؟
    final savedDate = prefs.getString('worship_last_date');
    
    if (savedDate == todayKey) {
      // تحميل التقدم المحفوظ
      final savedTasksJson = prefs.getString('worship_tasks');
      if (savedTasksJson != null) {
        final List<dynamic> decoded = jsonDecode(savedTasksJson);
        _dailyTasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        
        // إعادة تعيين الأيقونات (لأن JSON لا يحفظ IconData)
        for (int i = 0; i < _dailyTasks.length; i++) {
          if (i < _defaultTasks.length) {
            _dailyTasks[i]['icon'] = _defaultTasks[i]['icon'];
          }
        }
      } else {
         _resetTasks();
      }
    } else {
      // يوم جديد! إعادة تعيين
      _resetTasks();
      // حفظ تاريخ اليوم
      await prefs.setString('worship_last_date', todayKey);
      await _saveProgress();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _resetTasks() {
    _dailyTasks = List.from(_defaultTasks.map((e) => Map<String, dynamic>.from(e)));
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // نحتاج إزالة الأيقونات قبل الحفظ
    final tasksToSave = _dailyTasks.map((e) {
      final taskMap = Map<String, dynamic>.from(e);
      taskMap.remove('icon'); 
      return taskMap;
    }).toList();
    
    await prefs.setString('worship_tasks', jsonEncode(tasksToSave));
  }

  void _toggleTask(int index) async {
    setState(() {
      _dailyTasks[index]['done'] = !_dailyTasks[index]['done'];
    });
    await _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    final isDark = context.isDark;
    final int completedCount = _dailyTasks.where((t) => t['done']).length;
    final double progress = completedCount / _dailyTasks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "جدول الطاعات اليومي 📝",
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progress == 1.0 ? Colors.green : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(progress * 100).toInt()}% مكتمل",
                  style: TextStyle(
                  fontFamily: "cairo",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: progress == 1.0 ? Colors.white : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                // شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                       progress == 1.0 ? Colors.green : const Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // قائمة المهام (2 عمود)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_dailyTasks.length, (index) {
                    final task = _dailyTasks[index];
                    final isDone = task['done'];

                    return InkWell(
                      onTap: () => _toggleTask(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 64) / 2, // نصف العرض تقريباً
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDone 
                              ? Colors.green.withOpacity(isDark? 0.2 : 0.1)
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDone 
                              ? Colors.green.withOpacity(0.5) 
                              : (isDark ? Colors.white10 : Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDone ? Icons.check_circle : task['icon'],
                              color: isDone ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task['title'],
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: 12.sp,
                                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                  color: isDone 
                                      ? (isDark ? Colors.green.shade300 : Colors.green.shade800)
                                      : (isDark ? Colors.white70 : Colors.black87),
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                if (progress == 1.0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                         width: double.infinity,
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.green,
                           borderRadius: BorderRadius.circular(12),
                         ), 
                         child: Center(
                           child: Text(
                             "ما شاء الله! يوم مبارك 🌟",
                             style: TextStyle(
                  fontFamily: "cairo",
                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                               fontSize: 14.sp
                             ),
                           ),
                         ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

