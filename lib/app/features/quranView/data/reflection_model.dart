import 'dart:convert';
import 'package:flutter/material.dart';

// Available colors for reflections
enum ReflectionColor {
  none,      // بدون لون (افتراضي)
  blue,      // أزرق - تدبر
  green,     // أخضر - فائدة
  orange,    // برتقالي - سؤال
  purple,    // بنفسجي - تذكير
  red,       // أحمر - مهم
  yellow,    // أصفر - ملاحظة
}

extension ReflectionColorExtension on ReflectionColor {
  String get name {
    switch (this) {
      case ReflectionColor.none:
        return 'بدون لون';
      case ReflectionColor.blue:
        return 'تدبر';
      case ReflectionColor.green:
        return 'فائدة';
      case ReflectionColor.orange:
        return 'سؤال';
      case ReflectionColor.purple:
        return 'تذكير';
      case ReflectionColor.red:
        return 'مهم';
      case ReflectionColor.yellow:
        return 'ملاحظة';
    }
  }

  Color get color {
    switch (this) {
      case ReflectionColor.none:
        return Colors.grey;
      case ReflectionColor.blue:
        return Colors.blue;
      case ReflectionColor.green:
        return Colors.green;
      case ReflectionColor.orange:
        return Colors.orange;
      case ReflectionColor.purple:
        return Colors.purple;
      case ReflectionColor.red:
        return Colors.red;
      case ReflectionColor.yellow:
        return Colors.amber;
    }
  }

  String toJson() => toString().split('.').last;

  static ReflectionColor fromJson(String json) {
    return ReflectionColor.values.firstWhere(
      (e) => e.toString().split('.').last == json,
      orElse: () => ReflectionColor.none,
    );
  }
}

class Reflection {
  final String id;
  final int pageIndex;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReflectionColor color;

  Reflection({
    required this.id,
    required this.pageIndex,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.color = ReflectionColor.none,
  });

  // Create a new reflection with current timestamp
  factory Reflection.create({
    required int pageIndex,
    required String content,
    ReflectionColor color = ReflectionColor.none,
  }) {
    final now = DateTime.now();
    return Reflection(
      id: now.millisecondsSinceEpoch.toString(),
      pageIndex: pageIndex,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color,
    );
  }

  // Copy with updated content
  Reflection copyWith({
    String? id,
    int? pageIndex,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReflectionColor? color,
  }) {
    return Reflection(
      id: id ?? this.id,
      pageIndex: pageIndex ?? this.pageIndex,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageIndex': pageIndex,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color.toJson(),
    };
  }

  // Create from JSON
  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'] as String,
      pageIndex: json['pageIndex'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      color: json.containsKey('color')
          ? ReflectionColorExtension.fromJson(json['color'] as String)
          : ReflectionColor.none,
    );
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  factory Reflection.fromJsonString(String jsonString) {
    return Reflection.fromJson(jsonDecode(jsonString));
  }
}

