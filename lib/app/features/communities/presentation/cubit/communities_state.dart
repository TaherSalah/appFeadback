import 'package:equatable/equatable.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';

abstract class CommunitiesState extends Equatable {
  const CommunitiesState();

  @override
  List<Object> get props => [];
}

class CommunitiesInitial extends CommunitiesState {}

class CommunitiesLoading extends CommunitiesState {}

class CommunitiesProfileRequired extends CommunitiesState {}

class CommunitiesLoaded extends CommunitiesState {
  final List<Community> communities;

  const CommunitiesLoaded({required this.communities});

  @override
  List<Object> get props => [communities];
}

class CommunitiesError extends CommunitiesState {
  final String message;

  const CommunitiesError({required this.message});

  @override
  List<Object> get props => [message];
}

class CommunityActionLoading extends CommunitiesState {}

class CommunityActionSuccess extends CommunitiesState {
  final Community community;
  
  const CommunityActionSuccess({required this.community});

  @override
  List<Object> get props => [community];
}

class CommunitiesStatisticsLoaded extends CommunitiesState {
  final Map<String, dynamic> statistics;

  const CommunitiesStatisticsLoaded({required this.statistics});

  @override
  List<Object> get props => [statistics];
}
