import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/quran/data/reflection_model.dart';
import 'package:muslimdaily/app/features/quran/data/reflections_service.dart';

class PageReflectionsScreen extends StatefulWidget {
  final int pageIndex;

  const PageReflectionsScreen({
    super.key,
    required this.pageIndex,
  });

  @override
  State<PageReflectionsScreen> createState() => _PageReflectionsScreenState();
}

class _PageReflectionsScreenState extends State<PageReflectionsScreen> {
  final ReflectionsService _reflectionsService = ReflectionsService();
  final TextEditingController _searchController = TextEditingController();
  List<Reflection> _reflections = [];
  List<Reflection> _filteredReflections = [];
  bool _isLoading = true;
  bool _isSearching = false;
  ReflectionColor? _filterColor;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReflections() async {
    final reflections =
        await _reflectionsService.getPageReflections(widget.pageIndex);
    if (mounted) {
      setState(() {
        _reflections = reflections;
        _filteredReflections = reflections;
        _isLoading = false;
      });
    }
  }

  void _filterReflections(String query) {
    setState(() {
      if (query.isEmpty && _filterColor == null) {
        _filteredReflections = _reflections;
      } else {
        _filteredReflections = _reflections.where((r) {
          final matchesSearch = query.isEmpty || r.content.contains(query);
          final matchesColor = _filterColor == null || r.color == _filterColor;
          return matchesSearch && matchesColor;
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Reflection? reflection}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ReflectionDialog(
        initialContent: reflection?.content ?? '',
        initialColor: reflection?.color ?? ReflectionColor.none,
        isEdit: reflection != null,
      ),
    );

    if (result != null) {
      final content = result['content'] as String;
      final color = result['color'] as ReflectionColor;

      if (reflection != null) {
        await _reflectionsService.updateReflection(
          widget.pageIndex,
          reflection.id,
          content,
        );
        // Update color separately if needed
        final reflections =
            await _reflectionsService.getPageReflections(widget.pageIndex);
        final index = reflections.indexWhere((r) => r.id == reflection.id);
        if (index != -1) {
          reflections[index] = reflections[index].copyWith(color: color);
          await _reflectionsService.deleteReflection(
              widget.pageIndex, reflection.id);
          await _reflectionsService.addReflection(widget.pageIndex, content,
              color: color);
        }
      } else {
        await _reflectionsService.addReflection(widget.pageIndex, content,
            color: color);
      }
      _loadReflections();
    }
  }

  Future<void> _deleteReflection(Reflection reflection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(),
    );

    if (confirmed == true) {
      await _reflectionsService.deleteReflection(
          widget.pageIndex, reflection.id);
      _loadReflections();
      KHelper.showSuccess(message: 'تم حذف الخاطرة بنجاح');
    }
  }

  void _copyReflection(Reflection reflection) {
    Clipboard.setData(ClipboardData(text: reflection.content));
    KHelper.showSuccess(message: 'تم نسخ الخاطرة');
  }

  Future<void> _exportReflections() async {
    if (_reflections.isEmpty) {
      KHelper.showError(message: 'لا توجد خواطر للتصدير');
      return;
    }

    try {
      final pageNumber = widget.pageIndex + 1;
      final buffer = StringBuffer();
      buffer.writeln('خواطر صفحة $pageNumber من القرآن الكريم');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (var i = 0; i < _reflections.length; i++) {
        final r = _reflections[i];
        buffer.writeln('${i + 1}. ${r.color.name}');
        buffer.writeln(
            '   التاريخ: ${intl.DateFormat('yyyy/MM/dd HH:mm').format(r.createdAt)}');
        buffer.writeln('   ${r.content}');
        buffer.writeln();
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/خواطر صفحة _$pageNumber.txt');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'خواطر صفحة $pageNumber من القرآن الكريم',
      );
    } catch (e) {
      KHelper.showError(message: 'حدث خطأ أثناء التصدير');
    }
  }

  void _showStatistics() {
    final colorCounts = <ReflectionColor, int>{};
    for (var r in _reflections) {
      colorCounts[r.color] = (colorCounts[r.color] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (context) => _StatisticsDialog(
        totalCount: _reflections.length,
        colorCounts: colorCounts,
        pageIndex: widget.pageIndex,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${intl.DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'أمس ${intl.DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return intl.DateFormat('yyyy/MM/dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final pageNumber = widget.pageIndex + 1;

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
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'ابحث في الخواطر...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54),
                      border: InputBorder.none,
                    ),
                    onChanged: _filterReflections,
                  )
                : Text(
                    'خواطر صفحة $pageNumber',
                    style: GoogleFonts.cairo(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.sizeOf(context).width > 600
                            ? 12.sp
                            : 18.sp),
                  ),
            centerTitle: true,
            actions: [
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _filterReflections('');
                    });
                  },
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() => _isSearching = true);
                  },
                  tooltip: 'بحث',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'export':
                        _exportReflections();
                        break;
                      case 'stats':
                        _showStatistics();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          // const SizedBox(width: 8),
                          Text(
                            'تصدير الخواطر',
                            style: GoogleFonts.cairo(),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 15),

                          const Icon(Icons.share, size: 20),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stats',
                      child: Row(
                        children: [
                          // const SizedBox(width: 8),
                          Text('الإحصائيات', style: GoogleFonts.cairo()),
                          const SizedBox(width: 30),

                          const Icon(Icons.bar_chart, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
            // title: Text(
            //   "احزاب القران الكريم",
            //   style: GoogleFonts.cairo(
            //       color: Colors.green,
            //       fontWeight: FontWeight.bold,
            //       fontSize:
            //       MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            // ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: KColors.primaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'إضافة خاطرة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Color filter chips
            if (_reflections.isNotEmpty)
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    _buildColorChip(null, 'الكل', isDark),
                    ...ReflectionColor.values.map(
                        (color) => _buildColorChip(color, color.name, isDark)),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReflections.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildReflectionsList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(ReflectionColor? color, String label, bool isDark) {
    final isSelected = _filterColor == color;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterColor = selected ? color : null;
            _filterReflections(_searchController.text);
          });
        },
        backgroundColor: color?.color.withOpacity(0.2),
        selectedColor:
            color?.color.withOpacity(0.4) ?? Colors.teal.withOpacity(0.4),
        labelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80.sp,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            _searchController.text.isNotEmpty || _filterColor != null
                ? 'لا توجد نتائج'
                : 'لا توجد خواطر مسجلة لهذه الصفحة',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionsList(bool isDark) {
    final sortedReflections = List<Reflection>.from(_filteredReflections)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: sortedReflections.length,
      itemBuilder: (context, index) {
        final reflection = sortedReflections[index];
        return _buildReflectionCard(reflection, isDark);
      },
    );
  }

  Widget _buildReflectionCard(Reflection reflection, bool isDark) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: reflection.color.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      color: isDark ? const Color(0xFF1B263B) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (reflection.color != ReflectionColor.none)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: reflection.color.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reflection.color.name,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: reflection.color.color,
                          ),
                        ),
                      ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(reflection.createdAt),
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, size: 18.sp, color: Colors.green),
                      onPressed: () => _copyReflection(reflection),
                      tooltip: 'نسخ',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          size: 18.sp, color: Colors.blue),
                      onPressed: () =>
                          _showAddEditDialog(reflection: reflection),
                      tooltip: 'تعديل',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 18.sp, color: Colors.red),
                      onPressed: () => _deleteReflection(reflection),
                      tooltip: 'حذف',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200]!,
                ),
              ),
              child: Text(
                reflection.content,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (reflection.updatedAt
                    .difference(reflection.createdAt)
                    .inSeconds >
                1)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.edit,
                        size: 11.sp,
                        color: isDark ? Colors.white38 : Colors.grey[500]),
                    SizedBox(width: 4.w),
                    Text(
                      'تم التعديل ${_formatDate(reflection.updatedAt)}',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Dialog for adding/editing reflection
class _ReflectionDialog extends StatefulWidget {
  final String initialContent;
  final ReflectionColor initialColor;
  final bool isEdit;

  const _ReflectionDialog({
    required this.initialContent,
    required this.initialColor,
    required this.isEdit,
  });

  @override
  State<_ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<_ReflectionDialog> {
  late TextEditingController _controller;
  late ReflectionColor _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isEdit ? 'تعديل الخاطرة' : 'إضافة خاطرة جديدة',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سجل ما تعلمته أو تدبرته من هذه الصفحة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.indigo.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      autofocus: true,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "اكتب ما في ذهنك هنا...",
                        hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white12
                            : Colors.white.withOpacity(0.6),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'التصنيف:',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        final selected =
                            await showModalBottomSheet<ReflectionColor>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _ColorPickerBottomSheet(
                            selectedColor: _selectedColor,
                            isDark: isDark,
                          ),
                        );
                        if (selected != null) {
                          setState(() => _selectedColor = selected);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white12
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedColor.color.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _selectedColor.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _selectedColor.color
                                            .withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  _selectedColor.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.indigo.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A237E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                Navigator.pop(context, {
                                  'content': _controller.text.trim(),
                                  'color': _selectedColor,
                                });
                              }
                            },
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: Text(widget.isEdit ? 'حفظ' : 'إضافة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -35,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3F51B5).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.edit_note_rounded,
                        size: 42, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Delete confirmation dialog
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Body
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF2B0B0B), const Color(0xFF200505)]
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
                  Text(
                    'تأكيد الحذف',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'هل أنت متأكد من حذف هذه الخاطرة؟\nلا يمكن التراجع عن هذا الإجراء.',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),

                  /// Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.red.withOpacity(0.06),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'سيتم حذف العنصر نهائيًا من القائمة.',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding:
                            EdgeInsets.symmetric(vertical: 11.h),
                          ),
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: isDark
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            'حذف',
                            style: GoogleFonts.cairo(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14.r),
                            ),
                            padding:
                            EdgeInsets.symmetric(vertical: 11.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Top Icon
            Positioned(
              top: -30.h,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.deepOrange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_forever_rounded,
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
  }
}

// Statistics dialog
class _StatisticsDialog extends StatelessWidget {
  final int totalCount;
  final Map<ReflectionColor, int> colorCounts;
  final int pageIndex;

  const _StatisticsDialog({
    required this.totalCount,
    required this.colorCounts,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1B263B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.teal, size: 28.sp),
            SizedBox(width: 8.w),
            Text('إحصائيات الخواطر',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'صفحة ${pageIndex + 1}',
              style: GoogleFonts.cairo(
                  fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildStatRow('إجمالي الخواطر', totalCount.toString(), Colors.teal),
            SizedBox(height: 12.h),
            Text('التصنيفات:',
                style: GoogleFonts.cairo(
                    fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            ...colorCounts.entries.map((entry) {
              if (entry.value > 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildStatRow(
                      entry.key.name, entry.value.toString(), entry.key.color),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.cairo(fontSize: 13.sp)),
          ],
        ),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 13.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Color Picker Bottom Sheet
class _ColorPickerBottomSheet extends StatelessWidget {
  final ReflectionColor selectedColor;
  final bool isDark;

  const _ColorPickerBottomSheet({
    required this.selectedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B263B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            // Title
            Text(
              'اختر التصنيف',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            // Color options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ReflectionColor.values.length,
              itemBuilder: (context, index) {
                final color = ReflectionColor.values[index];
                final isSelected = color == selectedColor;

                return InkWell(
                  onTap: () => Navigator.pop(context, color),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.color.withOpacity(0.15)
                          : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Color circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        // Color name
                        Expanded(
                          child: Text(
                            color.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        // Selected indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: color.color,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
