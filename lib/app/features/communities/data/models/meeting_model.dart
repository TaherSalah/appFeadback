import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.communityId,
    required super.title,
    super.meetUrl,
    required super.meetingDate,
    required super.durationMinutes,
    super.teacherName,
    super.reportContent,
    required super.createdBy,
    required super.createdAt,
    super.targetGender = 'both',
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      title: json['title'] as String,
      meetUrl: json['meet_url'] as String?,
      meetingDate: DateTime.parse(json['meeting_date'] as String),
      durationMinutes: json['duration_minutes'] as int,
      teacherName: json['teacher_name'] as String?,
      reportContent: json['report_content'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      targetGender: json['target_gender'] as String? ?? 'both',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'title': title,
      'meet_url': meetUrl,
      'meeting_date': meetingDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'teacher_name': teacherName,
      'report_content': reportContent,
      'created_by': createdBy,
      'target_gender': targetGender,
    };
  }
}
