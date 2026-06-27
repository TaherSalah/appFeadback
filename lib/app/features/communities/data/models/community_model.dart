import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';

class CommunityModel extends Community {
  const CommunityModel({
    required super.id,
    required super.name,
    super.description,
    super.image,
    required super.inviteCode,
    super.communityType,
    super.targetGender = 'both',
    required super.createdBy,
    required super.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      inviteCode: json['invite_code'] as String,
      communityType: json['community_type'] as String?,
      targetGender: json['target_gender'] as String? ?? 'both',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'invite_code': inviteCode,
      'community_type': communityType,
      'target_gender': targetGender,
      'created_by': createdBy,
    };
  }
}
