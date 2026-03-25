import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/widgets/def_text_widget.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:uuid/uuid.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/calendar/data/models/calendar_event_model.dart';
import 'package:muslimdaily/app/features/calendar/data/services/calendar_service.dart';
import 'package:intl/intl.dart' as intl;

class AddEventSheet extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSave;
  final CalendarEvent? eventToEdit;

  const AddEventSheet({
    super.key,
    required this.selectedDate,
    required this.onSave,
    this.eventToEdit,
  });

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _calendarService = CalendarService();
  bool _isLoading = false;

  // Defaults
  int? _selectedColorValue;
  bool _isReminderEnabled = false;
  DateTime? _reminderTime;
  String _recurrence = 'none';
  bool _syncToDevice = false;

  final List<Color> _availableColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _calendarService.init();

    if (widget.eventToEdit != null) {
      // Pre-fill for editing
      final e = widget.eventToEdit!;
      _titleController.text = e.title;
      _descController.text = e.description ?? '';
      _selectedColorValue = e.colorValue;
      _isReminderEnabled = e.reminderDateTime != null;
      _reminderTime = e.reminderDateTime ??
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            10,
            0,
          );
      _recurrence = e.recurrence ?? 'none';
      _syncToDevice =
          e.externalEventId == 'pending_sync' || e.externalEventId != null;
    } else {
      // Default new event
      _reminderTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        10,
        0,
      );
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      KHelper.showError(message: 'يرجى كتابة عنوان للمهمة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.eventToEdit != null;
      final newEvent = CalendarEvent(
        id: isEdit ? widget.eventToEdit!.id : const Uuid().v4(),
        title: _titleController.text,
        description:
            _descController.text.isNotEmpty ? _descController.text : null,
        date: widget.selectedDate,
        type: 'user',
        colorValue: _selectedColorValue,
        reminderDateTime: _isReminderEnabled ? _reminderTime : null,
        recurrence: _recurrence,
        externalEventId: _syncToDevice ? 'pending_sync' : null,
        // Preserve isDone status if editing
        isDone: isEdit ? widget.eventToEdit!.isDone : false,
      );

      if (isEdit) {
        await _calendarService.updateEvent(newEvent);
      } else {
        await _calendarService.addEvent(newEvent);
      }

      // Trigger sync if enabled
      if (_syncToDevice) {
        await _calendarService.syncToDeviceCalendar(newEvent);
      }

      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      KHelper.showError(message: 'حدث خطأ أثناء الحفظ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderTime!),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Theme Logic
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final primaryColor = const Color(0xFF1B5E20); // Deep Green
    bool isTab = ResponsiveUtil.isTablet(context);
    // Helper for input decoration
    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: "cairo",color: hintColor),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        left: 20.w,
        right: 20.w,
        top: 12.h,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl, // 🔒 Force RTL
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ➖ Pull Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 📝 Header
              Text(
                widget.eventToEdit != null
                    ? 'تعديل المهمة'
                    : 'إضافة مهمة جديدة',
                textAlign: TextAlign.center,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: isTab ? 14.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 24.h),

              // 📌 Title Input
              TextField(
                controller: _titleController,
                   style: TextStyle(
                          fontFamily: "cairo",color: textColor),
                decoration:
                    buildInputDecoration('عنوان المهمة', Icons.task_alt),
              ),
              SizedBox(height: 16.h),

              // 📄 Description Input
              TextField(
                controller: _descController,
                   style: TextStyle(
                          fontFamily: "cairo",color: textColor),
                maxLines: 3,
                minLines: 1,
                decoration: buildInputDecoration(
                    'تفاصيل إضافية (اختياري)', Icons.description_outlined),
              ),
              SizedBox(height: 24.h),

              // 🎨 Color Picker
              Text(
                'لون المهمة',
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: isTab ? 10.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = _selectedColorValue == color.value;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorValue = color.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 48.w : 40.w,
                        height: isSelected ? 48.w : 40.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: textColor, width: 2.5)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                color: Colors.white, size: 24.sp)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // 🔁 Recurrence Dropdown
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: DropdownButtonFormField<String>(
                  value: _recurrence,
                  icon: Icon(Icons.keyboard_arrow_down, color: hintColor),
                     style: TextStyle(
                          fontFamily: "cairo",color: textColor, fontSize: 14.sp),
                  dropdownColor: surfaceColor,
                  decoration: InputDecoration(
                    labelText: 'تكرار المهمة',
                    labelStyle: TextStyle(
                        fontFamily: "cairo",color: hintColor),
                    prefixIcon:
                        Icon(Icons.repeat_rounded, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  items: [
                    DropdownMenuItem(
                        alignment: AlignmentGeometry.centerRight,
                        value: 'none',
                        child: TextDefaultWidget(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: isTab ? 8.sp : 12.sp,
                            title: 'مرة واحدة')),
                    DropdownMenuItem(
                        alignment: AlignmentGeometry.centerRight,
                        value: 'daily',
                        child: TextDefaultWidget(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: isTab ? 8.sp : 12.sp,
                            title: 'يومياً')),
                    DropdownMenuItem(
                        alignment: AlignmentGeometry.centerRight,
                        value: 'weekly',
                        child: TextDefaultWidget(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: isTab ? 8.sp : 12.sp,
                            title: 'أسبوعياً')),
                    DropdownMenuItem(
                        alignment: AlignmentGeometry.centerRight,
                        value: 'monthly',
                        child: TextDefaultWidget(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: isTab ? 8.sp : 12.sp,
                            title: 'شهرياً')),
                  ],
                  onChanged: (val) =>
                      setState(() => _recurrence = val ?? 'none'),
                ),
              ),
              SizedBox(height: 16.h),

              // 🔔 & 🔄 Toggles Section
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    // Reminder Toggle
                    SwitchListTile(
                      title: Text(
                        'تفعيل التذكير',
                           style: TextStyle(
                          fontFamily: "cairo",
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                      secondary: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: _isReminderEnabled
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_active_outlined,
                            color:
                                _isReminderEnabled ? primaryColor : hintColor),
                      ),
                      value: _isReminderEnabled,
                      activeColor: primaryColor,
                      onChanged: (val) =>
                          setState(() => _isReminderEnabled = val),
                    ),

                    if (_isReminderEnabled) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Divider(
                            height: 1, color: Colors.grey.withOpacity(0.1)),
                      ),
                      InkWell(
                        onTap: _pickReminderTime,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                          child: Row(
                            children: [
                              Text(
                                'وقت التنبيه',
                                style:TextStyle(
                                    fontFamily: "cairo",color: hintColor),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  // 12-hour format with AM/PM
                                  intl.DateFormat('hh:mm a', 'ar')
                                      .format(_reminderTime!),
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Divider(
                          height: 1, color: Colors.grey.withOpacity(0.1)),
                    ),

                    // Sync Toggle
                    // SwitchListTile(
                    //   title: Text(
                    //     'مزامنة مع التقويم',
                    //     style: GoogleFonts.cairo(
                    //         fontWeight: FontWeight.bold, color: textColor),
                    //   ),
                    //   subtitle: _syncToDevice
                    //       ? Text(
                    //           'سيتم حفظ نسخة في تقويم الهاتف',
                    //           style: GoogleFonts.cairo(
                    //               fontSize: 10.sp, color: hintColor),
                    //         )
                    //       : null,
                    //   secondary: Container(
                    //     padding: EdgeInsets.all(8.w),
                    //     decoration: BoxDecoration(
                    //       color: _syncToDevice
                    //           ? Colors.blue.withOpacity(0.1)
                    //           : Colors.transparent,
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: Icon(Icons.sync,
                    //         color: _syncToDevice ? Colors.blue : hintColor),
                    //   ),
                    //   value: _syncToDevice,
                    //   activeColor: Colors.blue,
                    //   onChanged: (val) => setState(() => _syncToDevice = val),
                    // ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // 💾 Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24.h,
                        width: 24.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded),
                          SizedBox(width: 8.w),
                          TextDefaultWidget(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: isTab ? 10.sp : 16.sp,
                            title: widget.eventToEdit != null
                                ? 'حفظ التعديلات'
                                : 'حفظ المهمة',
                            fontFamily: "cairo",
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
