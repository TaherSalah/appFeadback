import 'package:equatable/equatable.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';

abstract class ExploreCommunitiesState extends Equatable {
  const ExploreCommunitiesState();

  @override
  List<Object> get props => [];
}

class ExploreCommunitiesInitial extends ExploreCommunitiesState {}

class ExploreCommunitiesLoading extends ExploreCommunitiesState {}

class ExploreCommunitiesLoaded extends ExploreCommunitiesState {
  final List<Community> communities;
  final List<String> joinedCommunityIds;

  const ExploreCommunitiesLoaded({required this.communities, required this.joinedCommunityIds});

  @override
  List<Object> get props => [communities, joinedCommunityIds];
}

class ExploreCommunitiesError extends ExploreCommunitiesState {
  final String message;

  const ExploreCommunitiesError({required this.message});

  @override
  List<Object> get props => [message];
}

class ExploreCommunityJoinLoading extends ExploreCommunitiesState {}

class ExploreCommunityJoinSuccess extends ExploreCommunitiesState {}
