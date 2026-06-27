import 'package:muslimdaily/app/features/communities/domain/entities/community_member.dart';

class CommunityMemberModel extends CommunityMember {
  const CommunityMemberModel({
    required super.id,
    required super.communityId,
    required super.userId,
    required super.role,
    required super.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'user_id': userId,
      'role': role,
    };
  }
}
