import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar/table_calendar.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/calendar/data/models/calendar_event_model.dart';
import 'package:muslimdaily/app/features/calendar/data/services/calendar_service.dart';

import '../../../../core/utils/style/responsive_util.dart';
import '../widgets/add_event_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEvent> _selectedEvents = [];

  bool _isHijriMode = false; // Toggle to show Hijri priority (visual only)

  Color _calendarThemeColor = const Color(0xFF4CAF50); // Default Green
  BoxShape _calendarShape = BoxShape.circle;
  double _fontScale = 1.0;
  StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.saturday;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _calendarService.init();
    setState(() {
      _calendarThemeColor = Color(_calendarService.getThemeColor());
      final shapeName = _calendarService.getThemeShape();
      _calendarShape =
          shapeName == 'rectangle' ? BoxShape.rectangle : BoxShape.circle;
      _fontScale = _calendarService.getFontScale();

      final startWeek = _calendarService.getStartOfWeek();
      _startingDayOfWeek = startWeek == 7
          ? StartingDayOfWeek.sunday
          : (startWeek == 1
              ? StartingDayOfWeek.monday
              : StartingDayOfWeek.saturday);

      _isHijriMode = _calendarService.getHijriMode();
    });
    _getEventsForDay(_selectedDay ?? DateTime.now());
  }

  void _openStyleEditor() {
    // Determine initial index based on what we want to edit, default 0
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 2,
            child: StatefulBuilder(builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text('تخصيص التقويم',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                contentPadding: EdgeInsets.zero,
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        labelColor: _calendarThemeColor,
                        indicatorColor: _calendarThemeColor,
                        unselectedLabelColor: Colors.grey,
                        labelStyle:
                            GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'المظهر'),
                          Tab(text: 'الإعدادات'),
                        ],
                      ),
                      SizedBox(
                        height: 300.h,
                        child: TabBarView(
                          children: [
                            // Tab 1: Appearance (Color & Shape)
                            SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                children: [
                                  Text('لون واجهة التقويم',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 12.h),
                                  Wrap(
                                    spacing: 12.w,
                                    runSpacing: 12.h,
                                    children: [
                                      Colors.green,
                                      Colors.blue,
                                      Colors.red,
                                      Colors.orange,
                                      Colors.purple,
                                      Colors.teal,
                                      Colors.pink,
                                      Colors.indigo,
                                      Colors.brown,
                                      Colors.black,
                                    ].map((color) {
                                      return GestureDetector(
                                        onTap: () async {
                                          setState(() =>
                                              _calendarThemeColor = color);
                                          setStateDialog(() {});
                                          await _calendarService
                                              .setThemeColor(color.value);
                                        },
                                        child: Container(
                                          width: 36.w,
                                          height: 36.w,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  _calendarThemeColor.value ==
                                                          color.value
                                                      ? Colors.black
                                                      : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: _calendarThemeColor.value ==
                                                  color.value
                                              ? Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 20.sp)
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 20.h),
                                  Divider(),
                                  SizedBox(height: 10.h),
                                  Text('شكل التحديد',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildShapeOption(BoxShape.circle,
                                          'دائري', setStateDialog),
                                      SizedBox(width: 20.w),
                                      _buildShapeOption(BoxShape.rectangle,
                                          'مربع', setStateDialog),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Tab 2: Settings (Font, Start Week)
                            SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                children: [
                                  Text('حجم الخط',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold)),
                                  Slider(
                                    value: _fontScale,
                                    min: 0.8,
                                    max: 1.4,
                                    divisions: 6,
                                    activeColor: _calendarThemeColor,
                                    label: '${(_fontScale * 100).toInt()}%',
                                    onChanged: (val) async {
                                      setState(() => _fontScale = val);
                                      setStateDialog(() {});
                                      await _calendarService.setFontScale(val);
                                    },
                                  ),
                                  Text('مقياس: ${(_fontScale * 100).toInt()}%',
                                      style: GoogleFonts.cairo(
                                          color: Colors.grey)),
                                  SizedBox(height: 20.h),
                                  Divider(),
                                  SizedBox(height: 10.h),
                                  Text('بداية الأسبوع',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold)),
                                  DropdownButton<StartingDayOfWeek>(
                                    value: _startingDayOfWeek,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: _calendarThemeColor),
                                    onChanged: (val) async {
                                      if (val == null) return;
                                      setState(() => _startingDayOfWeek = val);
                                      setStateDialog(() {});
                                      int saveVal =
                                          val == StartingDayOfWeek.sunday
                                              ? 7
                                              : (val == StartingDayOfWeek.monday
                                                  ? 1
                                                  : 6);
                                      await _calendarService
                                          .setStartOfWeek(saveVal);
                                    },
                                    items: [
                                      DropdownMenuItem(
                                        value: StartingDayOfWeek.saturday,
                                        child: Text('السبت (الافتراضي)',
                                            style: GoogleFonts.cairo()),
                                      ),
                                      DropdownMenuItem(
                                        value: StartingDayOfWeek.sunday,
                                        child: Text('الأحد',
                                            style: GoogleFonts.cairo()),
                                      ),
                                      DropdownMenuItem(
                                        value: StartingDayOfWeek.monday,
                                        child: Text('الإثنين',
                                            style: GoogleFonts.cairo()),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  CheckboxListTile(
                                    title: Text('الأولوية للتقويم الهجري',
                                        style: GoogleFonts.cairo()),
                                    value: _isHijriMode,
                                    activeColor: _calendarThemeColor,
                                    onChanged: (val) async {
                                      setState(
                                          () => _isHijriMode = val ?? false);
                                      setStateDialog(() {});
                                      await _calendarService
                                          .setHijriMode(val ?? false);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text('إغلاق', style: GoogleFonts.cairo()),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildShapeOption(
      BoxShape shape, String label, StateSetter setStateDialog) {
    final isSelected = _calendarShape == shape;
    return GestureDetector(
      onTap: () async {
        setState(() => _calendarShape = shape);
        setStateDialog(() {});
        await _calendarService
            .setThemeShape(shape == BoxShape.circle ? 'circle' : 'rectangle');
      },
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? _calendarThemeColor.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                  color:
                      isSelected ? _calendarThemeColor : Colors.grey.shade400,
                  width: 2),
              // Use borderRadius for rectangle to look like rounded rectangle
              borderRadius: shape == BoxShape.rectangle
                  ? BorderRadius.circular(12)
                  : null,
              shape: shape == BoxShape.rectangle
                  ? BoxShape.rectangle
                  : BoxShape.circle,
            ),
            child: isSelected
                ? Icon(Icons.check, color: _calendarThemeColor)
                : null,
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: isSelected ? _calendarThemeColor : Colors.grey)),
        ],
      ),
    );
  }

  void _getEventsForDay(DateTime day) {
    setState(() {
      _selectedEvents = _calendarService.getEventsForDay(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hijriDate = HijriCalendar.fromDate(_focusedDay);
    bool isTab = ResponsiveUtil.isTablet(context);

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
              "التقويم الإسلامي",
              style: GoogleFonts.cairo(
                color: _calendarThemeColor, // Dynamic Theme Color
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.color_lens_outlined),
                tooltip: 'تخصيص المظهر',
                onPressed: _openStyleEditor,
              ),
              IconButton(
                icon: Icon(_isHijriMode ? Icons.date_range : Icons.history_edu),
                tooltip: _isHijriMode ? 'التقويم الميلادي' : 'التقويم الهجري',
                onPressed: () {
                  setState(() {
                    _isHijriMode = !_isHijriMode;
                  });
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Custom Header for Hijri/Gregorian info
            Container(
              padding: EdgeInsets.all(16.w),
              color: isDark
                  ? Colors.black12
                  : _calendarThemeColor.withOpacity(0.05), // Dynamic
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hijriDate.toFormat("MMMM yyyy"), // Hijri Month Year
                        style: GoogleFonts.cairo(
                          fontSize: (isTab ? 14.sp : 18.sp) * _fontScale,
                          fontWeight: FontWeight.bold,
                          color: _calendarThemeColor, // Dynamic
                        ),
                      ),
                      Text(
                        intl.DateFormat('MMMM yyyy', 'ar')
                            .format(_focusedDay), // Gregorian
                        style: GoogleFonts.cairo(
                          fontSize: (isTab ? 10.sp : 14.sp) * _fontScale,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime.now();
                        _selectedDay = DateTime.now();
                        _getEventsForDay(DateTime.now());
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _calendarThemeColor, // Dynamic
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'اليوم',
                        style: GoogleFonts.cairo(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            TableCalendar(
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: _calendarThemeColor,
                  shape: _calendarShape,
                  borderRadius: _calendarShape == BoxShape.rectangle
                      ? BorderRadius.circular(8.r)
                      : null,
                ),
                todayDecoration: BoxDecoration(
                  color: _calendarThemeColor.withOpacity(0.5),
                  shape: _calendarShape,
                  borderRadius: _calendarShape == BoxShape.rectangle
                      ? BorderRadius.circular(8.r)
                      : null,
                ),
                markerDecoration: BoxDecoration(
                  color: _calendarThemeColor.withOpacity(0.7),
                  shape: _calendarShape,
                  borderRadius: _calendarShape == BoxShape.rectangle
                      ? BorderRadius.circular(2.r)
                      : null,
                ),
                defaultTextStyle:
                    GoogleFonts.cairo(fontSize: 14.sp * _fontScale),
                weekendTextStyle: GoogleFonts.cairo(
                    color: Colors.red, fontSize: 14.sp * _fontScale),
                withinRangeTextStyle:
                    GoogleFonts.cairo(fontSize: 14.sp * _fontScale),
                disabledTextStyle: GoogleFonts.cairo(
                    fontSize: 14.sp * _fontScale, color: Colors.grey),
                outsideTextStyle: GoogleFonts.cairo(
                    color: Colors.grey, fontSize: 14.sp * _fontScale),
              ),
              locale: 'ar_SA',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2040, 12, 31),
              rowHeight: 52.h * _fontScale,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: _startingDayOfWeek, // Dynamic setting
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _getEventsForDay(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildCalendarCell(day,
                      isSelected: false,
                      isToday: isSameDay(day, DateTime.now()));
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildCalendarCell(day,
                      isSelected: true,
                      isToday: isSameDay(day, DateTime.now()));
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildCalendarCell(day,
                      isSelected: false, isToday: true);
                },
                markerBuilder: (context, day, events) {
                  final dailyEvents = _calendarService.getEventsForDay(day);
                  if (dailyEvents.isNotEmpty) {
                    return Positioned(
                      bottom: 4,
                      child: _buildEventMarker(dailyEvents),
                    );
                  }
                  return null;
                },
              ),
              headerVisible: false, // We made our own custom header
            ),

            const Divider(),

            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أحداث هذا اليوم',
                        style: GoogleFonts.cairo(
                          fontSize: isTab ? 10.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.r)),
                            ),
                            builder: (context) => AddEventSheet(
                              selectedDate: _selectedDay ?? DateTime.now(),
                              onSave: () async {
                                // Refresh events
                                _getEventsForDay(_selectedDay!);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (_selectedEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: Text(
                          'لا توجد مناسبات أو مهام في هذا اليوم',
                          style: GoogleFonts.cairo(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._selectedEvents
                        .map((event) => _buildEventItem(event))
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day,
      {required bool isSelected, required bool isToday}) {
    final hijri = HijriCalendar.fromDate(day);
    // Determine what to show big vs small based on _isHijriMode
    // But typically TableCalendar deals with Gregorian days.
    // We will show Gregorian as main number, Hijri as subscript (or vice versa).

    final mainText = _isHijriMode ? '${hijri.hDay}' : '${day.day}';
    final subText = _isHijriMode ? '${day.day}' : '${hijri.hDay}';

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.green
            : (isToday ? Colors.green.withOpacity(0.2) : null),
        shape: BoxShape.circle,
        border: isToday && !isSelected ? Border.all(color: Colors.green) : null,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                subText,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white70 : Colors.grey,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventMarker(List<CalendarEvent> events) {
    bool hasReligious = events.any((e) => e.type == 'religious');
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasReligious ? Colors.orange : Colors.green,
      ),
    );
  }

  Widget _buildEventItem(CalendarEvent event) {
    bool isReligious = event.type == 'religious';

    // Determine color
    Color baseColor = event.colorValue != null
        ? Color(event.colorValue!)
        : (isReligious ? Colors.orange : Colors.blue);

    // Icon wrapper color
    Color iconBgColor = baseColor.withOpacity(0.2);

    return Dismissible(
      key: ValueKey(event.id),
      direction:
          isReligious ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment:
            Alignment.centerLeft, // RTL: delete icon appears on the left (end)
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await _calendarService.deleteEvent(event.id);
        _getEventsForDay(_selectedDay!);
        KHelper.showSuccess(message: 'تم حذف المهمة');
      },
      child: Directionality(
        textDirection: TextDirection.rtl, // 🔒 Strict RTL
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            // Use cardBgColor if you intended, or keep theme color
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: baseColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              // Future: Open details or edit
            },
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // 1️⃣ Leading: Icon (Right side in RTL)
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReligious
                          ? Icons.star_rounded
                          : Icons.event_note_rounded,
                      color: baseColor,
                      size: 24.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 2️⃣ Content: Title & Details (Middle)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            // Dim color if done
                            color: event.isDone ? Colors.grey : null,
                            decoration: event.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor:
                                event.isDone ? Colors.grey : baseColor,
                            decorationThickness: 2.0,
                          ),
                        ),

                        if (event.description != null &&
                            event.description!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              event.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ),

                        // Meta Row (Recurrence / Time)
                        if ((event.recurrence != null &&
                                event.recurrence != 'none') ||
                            event.reminderDateTime != null)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Row(
                              children: [
                                if (event.recurrence != null &&
                                    event.recurrence != 'none') ...[
                                  Icon(Icons.repeat_rounded,
                                      size: 12.sp, color: Colors.grey),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _getRecurrenceLabel(event.recurrence!),
                                    style: GoogleFonts.cairo(
                                        fontSize: 10.sp, color: Colors.grey),
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                                if (event.reminderDateTime != null) ...[
                                  Icon(Icons.notifications_active_outlined,
                                      size: 12.sp, color: Colors.grey),
                                  SizedBox(width: 4.w),
                                  Text(
                                    // 12-hour format
                                    intl.DateFormat('hh:mm a', 'ar')
                                        .format(event.reminderDateTime!),
                                    style: GoogleFonts.cairo(
                                        fontSize: 10.sp, color: Colors.grey),
                                  ),
                                ]
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3️⃣ Trailing: Checkbox & Actions (Left side in RTL)
                  if (!isReligious)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: event.isDone,
                            activeColor: baseColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) async {
                              if (val == null) return;
                              await _calendarService
                                  .updateEvent(event.copyWith(isDone: val));
                              _getEventsForDay(_selectedDay!);
                            },
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert,
                              color: Colors.grey, size: 20.sp),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _editEvent(event);
                            } else if (value == 'delete') {
                              await _calendarService.deleteEvent(event.id);
                              _getEventsForDay(_selectedDay!);
                              KHelper.showSuccess(message: 'تم حذف المهمة');
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('تعديل'),
                                  SizedBox(width: 8),
                                  Icon(Icons.edit, color: Colors.blue),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('حذف',
                                      style: TextStyle(color: Colors.red)),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete, color: Colors.red),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editEvent(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => AddEventSheet(
        selectedDate: _selectedDay ?? DateTime.now(),
        eventToEdit: event,
        onSave: () async {
          _getEventsForDay(_selectedDay!);
          setState(() {});
        },
      ),
    );
  }

  String _getRecurrenceLabel(String code) {
    switch (code) {
      case 'daily':
        return 'يتكرر يومياً';
      case 'weekly':
        return 'يتكرر أسبوعياً';
      case 'monthly':
        return 'يتكرر شهرياً';
      default:
        return '';
    }
  }
}
