import 'package:equatable/equatable.dart';

class CommunityMember extends Equatable {
  final String id;
  final String communityId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const CommunityMember({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        communityId,
        userId,
        role,
        joinedAt,
      ];
}
