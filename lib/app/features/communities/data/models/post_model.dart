import 'package:muslimdaily/app/features/communities/domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.communityId,
    super.title,
    required super.content,
    super.teacherName,
    required super.createdBy,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      teacherName: json['teacher_name'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'title': title,
      'content': content,
      'teacher_name': teacherName,
      'created_by': createdBy,
    };
  }
}
