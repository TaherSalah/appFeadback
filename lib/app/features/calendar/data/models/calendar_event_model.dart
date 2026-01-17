import 'package:hive/hive.dart';

part 'calendar_event_model.g.dart';

@HiveType(typeId: 25)
class CalendarEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isDone;

  @HiveField(5)
  final bool isHijriEvent; // True if it's an auto-generated religious event

  @HiveField(6)
  final String type; // 'user', 'religious', 'national'

  @HiveField(7)
  final int? colorValue;

  @HiveField(8)
  final DateTime? reminderDateTime;

  @HiveField(9)
  final String? recurrence; // 'daily', 'weekly', 'monthly', 'yearly', 'none'

  @HiveField(10)
  final String? externalEventId;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.isDone = false,
    this.isHijriEvent = false,
    this.type = 'user',
    this.colorValue,
    this.reminderDateTime,
    this.recurrence,
    this.externalEventId,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isDone,
    bool? isHijriEvent,
    String? type,
    int? colorValue,
    DateTime? reminderDateTime,
    String? recurrence,
    String? externalEventId,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      isHijriEvent: isHijriEvent ?? this.isHijriEvent,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      recurrence: recurrence ?? this.recurrence,
      externalEventId: externalEventId ?? this.externalEventId,
    );
  }
}
