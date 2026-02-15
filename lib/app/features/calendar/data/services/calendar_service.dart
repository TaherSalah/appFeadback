import 'package:hive/hive.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:muslimdaily/app/features/calendar/data/models/calendar_event_model.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class CalendarService {
  static const String _boxName = 'calendar_events';
  static const String _settingsBoxName = 'calendar_settings';
  Box<CalendarEvent>? _box;
  Box? _settingsBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<CalendarEvent>(_boxName);
    } else {
      _box = Hive.box<CalendarEvent>(_boxName);
    }

    if (!Hive.isBoxOpen(_settingsBoxName)) {
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } else {
      _settingsBox = Hive.box(_settingsBoxName);
    }
  }

  // --- Settings ---
  int getThemeColor() {
    return _settingsBox?.get('theme_color') ?? 0xFF4CAF50; // Default Green
  }

  Future<void> setThemeColor(int colorValue) async {
    await _settingsBox?.put('theme_color', colorValue);
  }

  String getThemeShape() {
    return _settingsBox?.get('theme_shape') ?? 'circle';
  }

  Future<void> setThemeShape(String shapeName) async {
    await _settingsBox?.put('theme_shape', shapeName);
  }

  double getFontScale() {
    return _settingsBox?.get('font_scale') ?? 1.0;
  }

  Future<void> setFontScale(double scale) async {
    await _settingsBox?.put('font_scale', scale);
  }

  int getStartOfWeek() {
    // 6 = Saturday (Default in Arab world), 7 = Sunday, 1 = Monday
    return _settingsBox?.get('start_week') ?? 6;
  }

  Future<void> setStartOfWeek(int day) async {
    await _settingsBox?.put('start_week', day);
  }

  bool getHijriMode() {
    return _settingsBox?.get('is_hijri_mode') ?? false;
  }

  Future<void> setHijriMode(bool isHijri) async {
    await _settingsBox?.put('is_hijri_mode', isHijri);
  }

  // --- Event Management ---

  List<CalendarEvent> getEventsForDay(DateTime date) {
    if (_box == null || !_box!.isOpen) return [];

    // Filter events for the specific Gregorian date
    final events = _box!.values.where((event) {
      if (event.isHijriEvent) {
        return false;
      }

      // Check for Recurrence
      if (event.recurrence != null && event.recurrence != 'none') {
        return _isRecurrentEvent(event, date);
      }

      return isSameDay(event.date, date);
    }).toList();

    // Add generated religious events
    final religiousEvents = _getReligiousEventsForDay(date);
    events.addAll(religiousEvents);

    return events;
  }

  bool _isRecurrentEvent(CalendarEvent event, DateTime date) {
    if (date.isBefore(
        DateTime(event.date.year, event.date.month, event.date.day))) {
      return false; // Don't show before start date
    }

    switch (event.recurrence) {
      case 'daily':
        return true;
      case 'weekly':
        return event.date.weekday == date.weekday;
      case 'monthly':
        return event.date.day == date.day;
      case 'yearly':
        return event.date.month == date.month && event.date.day == date.day;
      default:
        return false;
    }
  }

  Future<void> addEvent(CalendarEvent event) async {
    if (_box == null || !_box!.isOpen) await init();
    await _box!.put(event.id, event);

    if (event.reminderDateTime != null) {
      await scheduleReminder(event);
    }

    if (event.externalEventId == 'pending_sync') {
      // Logic to sync to device calendar could go here or be called explicitly
    }
  }

  Future<void> deleteEvent(String id) async {
    if (_box == null || !_box!.isOpen) return;
    await _box!.delete(id);
    await cancelReminder(id);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    if (_box == null || !_box!.isOpen) return;
    await _box!.put(event.id, event);

    if (event.reminderDateTime != null) {
      await scheduleReminder(event);
    } else {
      await cancelReminder(event.id);
    }
  }

  // --- Notifications ---

  Future<void> scheduleReminder(CalendarEvent event) async {
    if (event.reminderDateTime == null) return;

    // Generate unique numeric ID from string ID
    final notificationId = event.id.hashCode.abs() % 100000;

    await NotificationManager().scheduleCalendarReminder(
      id: notificationId,
      title: event.title,
      body: event.description ?? 'تذكير بموعد',
      scheduledDate: event.reminderDateTime!,
    );
  }

  Future<void> cancelReminder(String eventId) async {
    final notificationId = eventId.hashCode.abs() % 100000;
    await NotificationManager().cancelCalendarReminder(notificationId);
  }

  // --- Device Calendar Sync ---
  // Note: This requires the 'device_calendar' package to be working and permissions granted.
  // We will add a simple placeholder here that can be expanded with the actual plugin logic.

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<void> syncToDeviceCalendar(CalendarEvent event) async {
    try {
      print('🚀 Starting sync for event: ${event.title}');
      if (!await _requestCalendarPermissions()) {
        print('❌ Calendar permission denied');
        KHelper.showError(message: 'يجب السماح بالوصول للتقويم للمزامنة');
        return;
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess ||
          calendarsResult.data == null ||
          calendarsResult.data!.isEmpty) {
        print('❌ No calendars found or error: ${calendarsResult.errors}');
        KHelper.showError(message: 'لم يتم العثور على تقويم صالح في الهاتف');
        return;
      }

      // Try to find a primary calendar or the first writable one
      final calendar = calendarsResult.data!.firstWhere(
          (c) => c.isReadOnly == false && (c.isDefault ?? false),
          orElse: () => calendarsResult.data!.firstWhere(
              (c) => c.isReadOnly == false,
              orElse: () => calendarsResult.data!.first));

      if (calendar.isReadOnly == true) {
        print('❌ No writable calendar found among: ${calendarsResult.data!.map((c) => c.name)}');
        KHelper.showError(message: 'التقويم الموجود للقراءة فقط');
        return;
      }

      print('🎯 Using calendar: ${calendar.name} (ID: ${calendar.id})');

      final deviceEvent = Event(calendar.id, eventId: event.externalEventId == 'pending_sync' ? null : event.externalEventId);
      deviceEvent.title = event.title;
      deviceEvent.description = event.description;
      
      // Use local timezone location
      final location = local;
      deviceEvent.start = TZDateTime.from(event.date, location);
      deviceEvent.end =
          TZDateTime.from(event.date.add(const Duration(hours: 1)), location);

      // Handle reminders for device calendar if set
      if (event.reminderDateTime != null) {
        deviceEvent.reminders = [
          Reminder(minutes: event.date.difference(event.reminderDateTime!).inMinutes)
        ];
      }

      print('📝 Creating/Updating event on device...');
      final result =
          await _deviceCalendarPlugin.createOrUpdateEvent(deviceEvent);
      
      if (result?.isSuccess == true && result?.data != null) {
        final updatedEvent = event.copyWith(externalEventId: result!.data);
        await updateEvent(updatedEvent);
        print('✅ Synced event to device calendar ID: ${result.data}');
        KHelper.showSuccess(message: 'تمت المزامنة مع تقويم الهاتف بنجاح');
      } else {
        print('❌ Failed to sync event: ${result?.errors}');
         final errorMsg = result?.errors.map((e) => e.errorMessage).join(', ') ?? 'Unknown error';
        KHelper.showError(message: 'فشلت المزامنة: $errorMsg');
      }
    } catch (e,s) {
      print('❌ Error syncing to device calendar: $e $s');
      KHelper.showError(message: 'حدث خطأ أثناء المزامنة: $e');
    }
  }

  Future<bool> _requestCalendarPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && permissionsGranted.data == true) {
      return true;
    }

    final requestResult = await _deviceCalendarPlugin.requestPermissions();
    return requestResult.isSuccess && requestResult.data == true;
  }

  // --- Hijri & Religious Occasions ---

  HijriCalendar getHijriDate(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<CalendarEvent> _getReligiousEventsForDay(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final events = <CalendarEvent>[];

    final occasion = _getOccasionName(hijri.hMonth, hijri.hDay);
    if (occasion != null) {
      final description = _getOccasionDescription(hijri.hMonth, hijri.hDay);
      events.add(CalendarEvent(
        id: 'hijri_${date.year}_${date.month}_${date.day}',
        title: occasion,
        date: date,
        isHijriEvent: true,
        type: 'religious',
        description: description ?? 'مناسبة دينية عظيمة',
      ));
    }

    return events;
  }

  String? _getOccasionName(int hMonth, int hDay) {
    // 1: Muharram
    if (hMonth == 1 && hDay == 1) return 'رأس السنة الهجرية';
    if (hMonth == 1 && hDay == 10) return 'يوم عاشوراء';

    // 3: Rabi' al-Awwal
    if (hMonth == 3 && hDay == 12) return 'المولد النبوي الشريف';

    // 7: Rajab
    if (hMonth == 7 && hDay == 27) return 'الإسراء والمعراج';

    // 8: Sha'ban
    if (hMonth == 8 && hDay == 15) return 'ليلة النصف من شعبان';

    // 9: Ramadan
    if (hMonth == 9 && hDay == 1) return 'بداية شهر رمضان';

    // 10: Shawwal
    if (hMonth == 10 && hDay == 1) return 'عيد الفطر المبارك';
    if (hMonth == 10 && hDay == 2) return 'ثاني أيام عيد الفطر';
    if (hMonth == 10 && hDay == 3) return 'ثالث أيام عيد الفطر';

    // 12: Dhu al-Hijjah
    if (hMonth == 12 && hDay == 9) return 'يوم عرفة';
    if (hMonth == 12 && hDay == 10) return 'عيد الأضحى المبارك';
    if (hMonth == 12 && hDay == 11) return 'ثاني أيام عيد الأضحى';
    if (hMonth == 12 && hDay == 12) return 'ثالث أيام عيد الأضحى';
    if (hMonth == 12 && hDay == 13) return 'رابع أيام عيد الأضحى';

    return null;
  }

  String? _getOccasionDescription(int hMonth, int hDay) {
    if (hMonth == 1 && hDay == 1) {
      return 'بداية العام الهجري الجديد، فرصة لمحاسبة النفس وتجديد النية.';
    }
    if (hMonth == 1 && hDay == 10) {
      return 'يوم نجا الله فيه موسى عليه السلام، ويُستحب صيامه تكفيراً لذنوب سنة ماضية.';
    }
    if (hMonth == 3 && hDay == 12) {
      return 'ذكرى مولد خير البشرية محمد ﷺ، فرصة للإكثار من الصلاة عليه ودراسة سيرته.';
    }
    if (hMonth == 7 && hDay == 27) {
      return 'معجزة الإسراء والمعراج، رحلة النبي ﷺ من مكة إلى القدس ثم إلى السماوات العلا.';
    }
    if (hMonth == 8 && hDay == 15) {
      return 'ليلة ترفع فيها الأعمال، ويغفر الله فيها للمستغفرين، فاجتهد في الدعاء والقيام.';
    }
    if (hMonth == 9 && hDay == 1) {
      return 'شهر الرحمة والمغفرة والعتق من النار، فيه ليلة القدر خير من ألف شهر.';
    }
    if (hMonth == 10 && hDay == 1) {
      return 'يوم الجائزة للصائمين، يُستحب فيه إظهار الفرح وصلة الرحم والتكبير.';
    }
    if (hMonth == 12 && hDay == 9) {
      return 'خير أيام الدنيا، صيامه يكفر سنة ماضية وسنة باقية، وهو يوم الحج الأكبر.';
    }
    if (hMonth == 12 && hDay == 10) {
      return 'يوم النحر، تقرب إلى الله بالأضاحي وصلة الأرحام والتكبير.';
    }
    if (hMonth == 12 && hDay >= 11 && hDay <= 13) {
      return 'أيام التشريق، أيام أكل وشرب وذكر لله، يُستحب فيها التكبير المقيد بعد الصلوات.';
    }
    return null;
  }
}
