import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String communityId;
  final String? title;
  final String content;
  final String? teacherName;
  final String createdBy;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.communityId,
    this.title,
    required this.content,
    this.teacherName,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        communityId,
        title,
        content,
        teacherName,
        createdBy,
        createdAt,
      ];
}
