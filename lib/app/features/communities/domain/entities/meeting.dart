import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  final String id;
  final String communityId;
  final String title;
  final String? meetUrl;
  final DateTime meetingDate;
  final int durationMinutes;
  final String? teacherName;
  final String? reportContent;
  final String createdBy;
  final DateTime createdAt;
  final String targetGender;

  const Meeting({
    required this.id,
    required this.communityId,
    required this.title,
    this.meetUrl,
    required this.meetingDate,
    required this.durationMinutes,
    this.teacherName,
    this.reportContent,
    required this.createdBy,
    required this.createdAt,
    this.targetGender = 'both',
  });

  @override
  List<Object?> get props => [
        id,
        communityId,
        title,
        meetUrl,
        meetingDate,
        durationMinutes,
        teacherName,
        reportContent,
        createdBy,
        createdAt,
        targetGender,
      ];
}
