import 'package:equatable/equatable.dart';

class Community extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String inviteCode;
  final String? communityType;
  final String targetGender;
  final String createdBy;
  final DateTime createdAt;

  const Community({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.inviteCode,
    this.communityType,
    this.targetGender = 'both',
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        inviteCode,
        communityType,
        targetGender,
        createdBy,
        createdAt,
      ];
}
